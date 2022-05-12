//=============================================================================
// CoopGame.
//=============================================================================
class CoopGame extends UnrealGameInfo;

var() config bool	bNoFriendlyFire;
var bool	bSpecialFallDamage;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	bClassicDeathMessages = True;
}

function bool IsRelevant(actor Other)
{
	// hide all playerpawns

	if ( Other.IsA('PlayerPawn') && !Other.IsA('Spectator') )
	{
		Other.SetCollision(false,false,false);
		Other.bHidden = true;
	}
	return Super.IsRelevant(Other);
}

function float PlaySpawnEffect(inventory Inv)
{
	Playsound(sound'RespawnSound');
	if ( !bCoopWeaponMode || !Inv.IsA('Weapon') )
	{
		spawn( class 'ReSpawn',,, Inv.Location );
		return 0.3;
	}
	return 0.0;
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn      NewPlayer;
	local string          InName, InPassword;
	local pawn			  aPawn;

	NewPlayer =  Super.Login(Portal, Options, Error, SpawnClass);
	if ( NewPlayer != None )
	{
		if ( !NewPlayer.IsA('Spectator') )
		{
			NewPlayer.bHidden = false;
			NewPlayer.SetCollision(true,true,true);
		}
		log("Logging in to "$Level.Title);
		if ( Level.Title ~= "The Source Antechamber" )
		{
			bSpecialFallDamage = true;
			log("reduce fall damage");
		}
	}
	return NewPlayer;
}
	
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest, Candidate[8], Best;
	local float Score[8], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;

	num = 0;
	//choose candidates	
	foreach AllActors( class 'PlayerStart', Dest )
	{
		if ( (Dest.bSinglePlayerStart || Dest.bCoopStart) && !Dest.Region.Zone.bWaterZone )
		{
			if (num<4)
				Candidate[num] = Dest;
			else if (Rand(num) < 4)
				Candidate[Rand(4)] = Dest;
			num++;
		}
	}
	
	if (num>4) num = 4;
	else if (num == 0)
		return None;
		
	//assess candidates
	for (i=0;i<num;i++)
		Score[i] = 4000 * FRand(); //randomize
		
	foreach AllActors( class 'Pawn', OtherPlayer )
	{
		if (OtherPlayer.bIsPlayer)
		{
			for (i=0;i<num;i++)
			{
				NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
				Score[i] += NextDist;
				if (NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight)
					Score[i] -= 1000000.0;
			}
		}
	}
	
	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1;i<num;i++)
	{
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	}			
				
	return Best;
}

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	if ( bNoFriendlyFire && (instigatedBy != None) 
		&& instigatedBy.bIsPlayer && injured.bIsPlayer && (instigatedBy != injured) )
		return 0;

	if ( (DamageType == 'Fell') && bSpecialFallDamage )
		return Min(Damage, 5);

	return Super.ReduceDamage(Damage, DamageType, injured, instigatedBy);
}

function bool ShouldRespawn(Actor Other)
{
	if ( Other.IsA('Weapon') && !Weapon(Other).bHeldItem && (Weapon(Other).ReSpawnTime != 0) )
	{
		Inventory(Other).ReSpawnTime = 1.0;
		return true;
	}
	return false;
}

function SendPlayer( PlayerPawn aPlayer, string URL )
{
	// hack to skip end game in coop play
	if ( left(URL,6) ~= "endgame")
	{
		Level.ServerTravel( "Vortex2", false);
		return;
	}

	Level.ServerTravel( URL, true );
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}

function Killed(pawn killer, pawn Other, name damageType)
{
	super.Killed(killer, Other, damageType);
	if ( (Killer != None) && (Other.bIsPlayer || Other.IsA('Nali')) )
		killer.PlayerReplicationInfo.Score -= 2;
}	

function AddDefaultInventory( pawn PlayerPawn )
{
	local Translator newTranslator;

	if ( Level.DefaultGameType != class'VRikersGame' ) 
		Super.AddDefaultInventory(PlayerPawn);

	// Spawn translator.
	if( PlayerPawn.IsA('Spectator') || PlayerPawn.FindInventoryType(class'Translator') != None )
		return;
	newTranslator = Spawn(class'Translator',,, Location);
	if( newTranslator != None )
	{
		newTranslator.bHeldItem = true;
		newTranslator.GiveTo( PlayerPawn );
		PlayerPawn.SelectedItem = newTranslator;
		newTranslator.PickupFunction(PlayerPawn);
	}
}

defaultproperties
{
     bNoFriendlyFire=True
     bHumansOnly=True
     bRestartLevel=False
     bPauseable=False
     bCoopWeaponMode=True
     GameMenuType=Class'UnrealShare.UnrealCoopGameOptions'
     BeaconName="Coop"
     GameName="Coop Game"
     ScoreBoardType=Class'UnrealShare.UnrealScoreBoard'
	 RulesMenuType="UMenu.UMenuCoopGameRulesSClient"
	 SettingsMenuType="UMenu.UMenuCoopGameRulesSClient"
}
