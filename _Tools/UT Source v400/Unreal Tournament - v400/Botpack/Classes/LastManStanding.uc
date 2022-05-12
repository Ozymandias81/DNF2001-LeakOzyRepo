//=============================================================================
// LastManStanding.
//=============================================================================
class LastManStanding extends DeathMatchPlus;

var config bool bHighDetailGhosts;
var() int Lives;
var int TotalKills, NumGhosts;
var localized string AltStartupMessage;
var PlayerPawn LocalPlayer;

event InitGame( string Options, out string Error )
{
	local string InOpt;

	TimeLimit = 0;
	Super.InitGame(Options, Error);
	if ( FragLimit == 0 )
		Lives = 10;
	else
		Lives = Fraglimit;
}

function float GameThreatAdd(Bot aBot, Pawn Other)
{
	if ( !Other.bIsPlayer ) 
		return 0;
	else
		return 0.1 * Other.PlayerReplicationInfo.Score;
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local playerpawn NewPlayer;
	local Pawn P;

	// if more than 15% of the game is over, must join as spectator
	if ( TotalKills > 0.15 * (NumPlayers + NumBots) * Lives )
	{
		SpawnClass = class'CHSpectator';
		if ( (NumSpectators >= MaxSpectators)
			&& ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) )
		{
			MaxSpectators++;
		}
	}
	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);

	if ( (NewPlayer != None) && !NewPlayer.IsA('Spectator') && !NewPlayer.IsA('Commander') )
		NewPlayer.PlayerReplicationInfo.Score = Lives;

	return NewPlayer;
}

event PostLogin( playerpawn NewPlayer )
{
	if( NewPlayer.Player != None && Viewport(NewPlayer.Player) != None)
		LocalPlayer = NewPlayer;

	if ( (TotalKills > 0.15 * (NumPlayers + NumBots) * Lives) && NewPlayer.IsA('CHSpectator') )
		GameName = AltStartupMessage;	
	Super.PostLogin(NewPlayer);
	GameName = Default.GameName;
}

function Timer()
{
	local Pawn P;

	Super.Timer();
	For ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsInState('FeigningDeath') )
			P.GibbedBy(P);
}
 
function bool NeedPlayers()
{
	if ( bGameEnded || (TotalKills > 0.15 * (NumPlayers + NumBots) * Lives) )
		return false;
	return (NumPlayers + NumBots < MinPlayers);
}

function bool IsRelevant(actor Other) 
{
	local Mutator M;
	local bool bArenaMutator;

	for (M = BaseMutator; M != None; M = M.NextMutator)
	{
		if (M.IsA('Arena'))
			bArenaMutator = True;
	}

	if ( bArenaMutator )
	{
		if ( Other.IsA('Inventory')	&& (Inventory(Other).MyMarker != None) && !Other.IsA('UT_Jumpboots') && !Other.IsA('Ammo'))
		{
			Inventory(Other).MyMarker.markedItem = None;
			return false;
		}
	} else {
		if ( Other.IsA('Inventory')	&& (Inventory(Other).MyMarker != None) && !Other.IsA('UT_Jumpboots'))
		{
			Inventory(Other).MyMarker.markedItem = None;
			return false;
		}
	}

	return Super.IsRelevant(Other);
}

function bool RestartPlayer( pawn aPlayer )	
{
	local NavigationPoint startSpot;
	local bool foundStart;
	local Pawn P;

	if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		return true;

	if ( aPlayer.PlayerReplicationInfo.Score < 1 )
	{
		BroadcastLocalizedMessage(class'LMSOutMessage', 0, aPlayer.PlayerReplicationInfo);
		For ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P.PlayerReplicationInfo.Score >= 1) )
				P.PlayerReplicationInfo.Score += 0.00001;
		if ( aPlayer.IsA('Bot') )
		{
			aPlayer.PlayerReplicationInfo.bIsSpectator = true;
			aPlayer.PlayerReplicationInfo.bWaitingPlayer = true;
			aPlayer.GotoState('GameEnded');
			return false; // bots don't respawn when ghosts
		}
	}

	startSpot = FindPlayerStart(None, 255);
	if( startSpot == None )
		return false;
		
	foundStart = aPlayer.SetLocation(startSpot.Location);
	if( foundStart )
	{
		startSpot.PlayTeleportEffect(aPlayer, true);
		aPlayer.SetRotation(startSpot.Rotation);
		aPlayer.ViewRotation = aPlayer.Rotation;
		aPlayer.Acceleration = vect(0,0,0);
		aPlayer.Velocity = vect(0,0,0);
		aPlayer.Health = aPlayer.Default.Health;
		aPlayer.ClientSetRotation( startSpot.Rotation );
		aPlayer.bHidden = false;
		aPlayer.SoundDampening = aPlayer.Default.SoundDampening;
		if ( aPlayer.PlayerReplicationInfo.Score < 1 )
		{
			// This guy is a ghost.  Add a visual effect.
			if ( bHighDetailGhosts )
			{
				aPlayer.Style = STY_Translucent;
				aPlayer.ScaleGlow = 0.5;
			} 
			else 
				aPlayer.bHidden = true;
			aPlayer.PlayerRestartState = 'PlayerSpectating';
		} 
		else
		{
			aPlayer.SetCollision( true, true, true );
			AddDefaultInventory(aPlayer);
		}
	}
	return foundStart;
}

function Logout( pawn Exiting )
{
	Super.Logout(Exiting);

	// Don't run endgame if it's the local player leaving
	// - stats saveconfig messes up saved defaults
	if( LocalPlayer == None || Exiting != LocalPlayer )
		CheckEndGame();
}

function Killed( pawn killer, pawn Other, name damageType )
{
	local int OldFragLimit;

	OldFragLimit = FragLimit;
	FragLimit = 0;

	if ( Other.bIsPlayer )
		TotalKills++;
			
	Super.Killed(Killer, Other, damageType);	

	FragLimit = OldFragLimit;

	CheckEndGame();
}

function CheckEndGame()
{
	local Pawn PawnLink;
	local int StillPlaying;
	local bool bStillHuman;
	local bot B, D;

	if ( bGameEnded )
		return;

	// Check to see if everyone is a ghost.
	NumGhosts = 0;
	for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
		if ( PawnLink.bIsPlayer )
		{
			if ( PawnLink.PlayerReplicationInfo.Score < 1 )
				NumGhosts++;
			else
			{
				if ( PawnLink.IsA('PlayerPawn') )
					bStillHuman = true;
				StillPlaying++;
			}
		}

	// End the game if there is only one man standing.
	if ( StillPlaying < 2 )
		EndGame("lastmanstanding");
	else if ( !bStillHuman )
	{
		// no humans left - get bots to be more aggressive and finish up
		for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.NextPawn )
		{
			B = Bot(PawnLink);
			if ( B != None )
			{
				B.CampingRate = 0;
				B.Aggressiveness += 0.8;
				if ( D == None )
					D = B;
				else if ( B.Enemy == None )
					B.SetEnemy(D);
			}
		}
	}		
}

function ScoreKill(pawn Killer, pawn Other)
{
	Other.DieCount++;
	if (Other.PlayerReplicationInfo.Score > 0)
		Other.PlayerReplicationInfo.Score -= 1;
	if( (killer != Other) && (killer != None) )
		killer.killCount++;
	BaseMutator.ScoreKill(Killer, Other);
}	

function bool PickupQuery( Pawn Other, Inventory item )
{
	if ( Other.PlayerReplicationInfo.Score < 1 )
		return false;
	
	return Super.PickupQuery( Other, item );
}

/*
AssessBotAttitude returns a value that translates to an attitude
		0 = ATTITUDE_Fear;
		1 = return ATTITUDE_Hate;
		2 = return ATTITUDE_Ignore;
		3 = return ATTITUDE_Friendly;
*/	
function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	local float Adjust;

	if ( aBot.bNovice )
		Adjust = -0.2;
	else
		Adjust = -0.2 - 0.1 * aBot.Skill;
	if ( Other.bIsPlayer && (Other.PlayerReplicationInfo.Score < 1) )
		return 2; //bots ignore ghosts
	else if ( aBot.bKamikaze )
		return 1;
	else if ( Other.IsA('TeamCannon')
		|| (aBot.RelativeStrength(Other) > aBot.Aggressiveness - Adjust) )
		return 0;
	else
		return 1;
}

function AddDefaultInventory( pawn PlayerPawn )
{
	local Weapon weap;
	local int i;
	local inventory Inv;
	local float F;

	if ( PlayerPawn.IsA('Spectator') || (bRequireReady && (CountDown > 0)) )
		return;
	Super.AddDefaultInventory(PlayerPawn);

	GiveWeapon(PlayerPawn, "Botpack.ShockRifle");
	GiveWeapon(PlayerPawn, "Botpack.UT_BioRifle");
	GiveWeapon(PlayerPawn, "Botpack.Ripper");
	GiveWeapon(PlayerPawn, "Botpack.UT_FlakCannon");

	if ( PlayerPawn.IsA('PlayerPawn') )
	{
		GiveWeapon(PlayerPawn, "Botpack.SniperRifle");
		GiveWeapon(PlayerPawn, "Botpack.PulseGun");
		GiveWeapon(PlayerPawn, "Botpack.Minigun2");
		GiveWeapon(PlayerPawn, "Botpack.UT_Eightball");
		PlayerPawn.SwitchToBestWeapon();
	}
	else
	{
		// randomize order for bots so they don't always use the same weapon
		F = FRand();
		if ( F < 0.7 ) 
		{
			GiveWeapon(PlayerPawn, "Botpack.SniperRifle");
			GiveWeapon(PlayerPawn, "Botpack.PulseGun");
			if ( F < 0.4 )
			{
				GiveWeapon(PlayerPawn, "Botpack.Minigun2");
				GiveWeapon(PlayerPawn, "Botpack.UT_Eightball");
			}
			else
			{
				GiveWeapon(PlayerPawn, "Botpack.UT_Eightball");
				GiveWeapon(PlayerPawn, "Botpack.Minigun2");
			}
		}
		else
		{
			GiveWeapon(PlayerPawn, "Botpack.Minigun2");
			GiveWeapon(PlayerPawn, "Botpack.UT_Eightball");
			if ( F < 0.88 )
			{
				GiveWeapon(PlayerPawn, "Botpack.SniperRifle");
				GiveWeapon(PlayerPawn, "Botpack.PulseGun");
			}
			else
			{
				GiveWeapon(PlayerPawn, "Botpack.PulseGun");
				GiveWeapon(PlayerPawn, "Botpack.SniperRifle");
			}
		}
	}
				
	for ( inv=PlayerPawn.inventory; inv!=None; inv=inv.inventory )
	{
		weap = Weapon(inv);
		if ( (weap != None) && (weap.AmmoType != None) )
			weap.AmmoType.AmmoAmount = weap.AmmoType.MaxAmmo;
	}

	inv = Spawn(class'Armor2');
	if( inv != None )
	{
		inv.bHeldItem = true;
		inv.RespawnTime = 0.0;
		inv.GiveTo(PlayerPawn);
	}
}	

function ModifyBehaviour(Bot NewBot)
{
	// Set the Bot's Lives
	NewBot.PlayerReplicationInfo.Score = Lives;

	NewBot.CampingRate += FRand();
}

function bool OneOnOne()
{
	return ( NumPlayers + NumBots - NumGhosts == 2 );
}

defaultproperties
{
     bTournament=True
     StartUpMessage="Last Man Standing.  How long can you live?"
	 AltStartUpMessage"Last Man Standing - already in progress!"
     BeaconName="LMS"
     GameName="Last Man Standing"
     ScoreBoardType=Class'Botpack.LMSScoreBoard'
     RulesMenuType="UTMenu.UTLMSRulesSC"
	 bAlwaysForceRespawn=true
}
