//=============================================================================
// DeathMatchGame.
//=============================================================================
class DeathMatchGame extends UnrealGameInfo;

var() globalconfig int	FragLimit; 
var() globalconfig int	TimeLimit; // time limit in minutes
var() globalconfig bool	bMultiPlayerBots;
var() globalconfig bool bChangeLevels;
var() globalconfig bool bHardCoreMode;
var() globalconfig bool bMegaSpeed;

var		bool	bDontRestart;
var		bool	bGameEnded;
var		bool	bAlreadyChanged;
var	  int RemainingTime;

// Bot related info
var   int			NumBots;
var	  int			RemainingBots;
var() globalconfig int	InitialBots;
var		BotInfo		BotConfig;
var localized string GlobalNameChange;
var localized string NoNameChange;
var localized string TimeMessage[16];
var class<BotInfo> BotConfigType;

function PostBeginPlay()
{
	local string NextPlayerClass;
	local int i;

	BotConfig = spawn(BotConfigType);
	RemainingTime = 60 * TimeLimit;
	if ( (Level.NetMode == NM_Standalone) || bMultiPlayerBots )
		RemainingBots = InitialBots;
	Super.PostBeginPlay();

	// load all player classes
	NextPlayerClass = GetNextInt("UnrealiPlayer", 0); 
	while ( NextPlayerClass != "" )
	{
		DynamicLoadObject(NextPlayerClass, class'Class');
		i++;
		NextPlayerClass = GetNextInt("UnrealiPlayer", i); 
	}
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
	if ( !bTeamGame && (ParseString ~= "Team") )
		return 255;

	return Super.GetIntOption(Options, ParseString, CurrentValue);
}

function bool IsRelevant(actor Other) 
{
	if ( bMegaSpeed && Other.IsA('Pawn') && Pawn(Other).bIsPlayer )
	{
		Pawn(Other).GroundSpeed *= 1.5;
		Pawn(Other).WaterSpeed *= 1.5;
		Pawn(Other).AirSpeed *= 1.5;
		Pawn(Other).Acceleration *= 1.5;
	}
	return Super.IsRelevant(Other);
}

function LogGameParameters(StatLog StatLog)
{
	if (StatLog == None)
		return;
	
	Super.LogGameParameters(StatLog);

	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"FragLimit"$Chr(9)$FragLimit);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TimeLimit"$Chr(9)$TimeLimit);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MultiPlayerBots"$Chr(9)$bMultiPlayerBots);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"HardCore"$Chr(9)$bHardCoreMode);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MegaSpeed"$Chr(9)$bMegaSpeed);
}

function float PlayerJumpZScaling()
{
	if ( bHardCoreMode )
		return 1.1;
	else
		return 1.0;
}

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
	GameSpeed = FMax(T, 0.1);
	if ( bHardCoreMode )
		Level.TimeDilation = 1.1 * GameSpeed;
	else
		Level.TimeDilation = GameSpeed;
}

event InitGame( string Options, out string Error )
{
	local string InOpt;

	Super.InitGame(Options, Error);

	SetGameSpeed(GameSpeed);
	FragLimit = GetIntOption( Options, "FragLimit", FragLimit );
	TimeLimit = GetIntOption( Options, "TimeLimit", TimeLimit );

	InOpt = ParseOption( Options, "CoopWeaponMode");
	if ( InOpt != "" )
	{
		log("CoopWeaponMode "$bool(InOpt));
		bCoopWeaponMode = bool(InOpt);
	}
}

//------------------------------------------------------------------------------
// Game Querying.

function string GetRules()
{
	local string ResultSet;
	ResultSet = Super.GetRules();

	// Timelimit.
	ResultSet = "\\timelimit\\"$TimeLimit;
		
	// Fraglimit
	ResultSet = ResultSet$"\\fraglimit\\"$FragLimit;
		
	// Bots in Multiplay?
	if( bMultiplayerBots )
		Resultset = ResultSet$"\\MultiplayerBots\\"$true;
	else
		Resultset = ResultSet$"\\MultiplayerBots\\"$false;

	// Change levels?
	if( bChangeLevels )
		Resultset = ResultSet$"\\ChangeLevels\\"$true;
	else
		Resultset = ResultSet$"\\ChangeLevels\\"$false;

	return ResultSet;
}

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	if (injured.Region.Zone.bNeutralZone)
		return 0;

	if ( instigatedBy == None)
		return Damage;

	if ( bHardCoreMode )
		Damage *= 1.5;

	//skill level modification
	if ( (instigatedBy.Skill < 1.5) && instigatedBy.IsA('Bots') && injured.IsA('PlayerPawn') )
		Damage = Damage * (0.7 + 0.15 * instigatedBy.skill);

	return (Damage * instigatedBy.DamageScaling);
}

function float PlaySpawnEffect(inventory Inv)
{
	spawn( class 'ReSpawn',,, Inv.Location );
	return 0.3;
}

function RestartGame()
{
	local string NextMap;
	local MapList myList;

	// multipurpose don't restart variable
	if ( bDontRestart )
		return;

	log("Restart Game");

	// these server travels should all be relative to the current URL
	if ( bChangeLevels && !bAlreadyChanged && (MapListType != None) )
	{
		// open a the nextmap actor for this game type and get the next map
		bAlreadyChanged = true;
		myList = spawn(MapListType);
		NextMap = myList.GetNextMap();
		myList.Destroy();
		if ( NextMap == "" )
			NextMap = GetMapName(MapPrefix, NextMap,1);
		if ( NextMap != "" )
		{
			log("Changing to "$NextMap);
			Level.ServerTravel(NextMap, false);
			return;
		}
	}

	Level.ServerTravel("?Restart" , false);
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

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass );
	if ( NewPlayer != None )
	{
		if ( Left(NewPlayer.PlayerReplicationInfo.PlayerName, 6) == DefaultPlayerName )
			ChangeName( NewPlayer, (DefaultPlayerName$NumPlayers), false );
		NewPlayer.bAutoActivate = true;
	}

	return NewPlayer;
}

function bool AddBot()
{
	local NavigationPoint StartSpot;
	local bots NewBot;
	local int BotN;

	Difficulty = BotConfig.Difficulty;
	BotN = BotConfig.ChooseBotInfo();
	
	// Find a start spot.
	StartSpot = FindPlayerStart(None, 255);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return false;
	}

	// Try to spawn the player.
	NewBot = Spawn(BotConfig.GetBotClass(BotN),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot == None )
		return false;

	if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		NewBot.Destroy();
		log("Failed to spawn bot");
		return false;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);

	// Init player's information.
	BotConfig.Individualize(NewBot, BotN, NumBots);
	NewBot.ViewRotation = StartSpot.Rotation;

	// broadcast a welcome message.
	BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage, true );

	AddDefaultInventory( NewBot );
	NumBots++;

	NewBot.PlayerReplicationInfo.bIsABot = True;

	// Set the player's ID.
	NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Log it.
	if (LocalLog != None)
		LocalLog.LogPlayerConnect(NewBot);
	if (WorldLog != None)
		WorldLog.LogPlayerConnect(NewBot);

	return true;
}

function Logout(pawn Exiting)
{
	Super.Logout(Exiting);
	if ( Exiting.IsA('Bots') )
		NumBots--;
}
	
function Timer()
{
	Super.Timer();

	if ( (RemainingBots > 0) && AddBot() )
		RemainingBots--;

	if ( bGameEnded )
	{
		RemainingTime--;
		if ( RemainingTime < -7 )
			RestartGame();
	}
	else if ( TimeLimit > 0 )
	{
		RemainingTime--;
		switch (RemainingTime)
		{
			case 300:
				BroadcastMessage(TimeMessage[0], True, 'CriticalEvent');
				break;
			case 240:
				BroadcastMessage(TimeMessage[1], True, 'CriticalEvent');
				break;
			case 180:
				BroadcastMessage(TimeMessage[2], True, 'CriticalEvent');
				break;
			case 120:
				BroadcastMessage(TimeMessage[3], True, 'CriticalEvent');
				break;
			case 60:
				BroadcastMessage(TimeMessage[4], True, 'CriticalEvent');
				break;
			case 30:
				BroadcastMessage(TimeMessage[5], True, 'CriticalEvent');
				break;
			case 10:
				BroadcastMessage(TimeMessage[6], True, 'CriticalEvent');
				break;
			case 5:
				BroadcastMessage(TimeMessage[7], True, 'CriticalEvent');
				break;
			case 4:
				BroadcastMessage(TimeMessage[8], True, 'CriticalEvent');
				break;
			case 3:
				BroadcastMessage(TimeMessage[9], True, 'CriticalEvent');
				break;
			case 2:
				BroadcastMessage(TimeMessage[10], True, 'CriticalEvent');
				break;
			case 1:
				BroadcastMessage(TimeMessage[11], True, 'CriticalEvent');
				break;
			case 0:
				BroadcastMessage(TimeMessage[12], True, 'CriticalEvent');
				break;
		}
		if ( RemainingTime <= 0 )
			EndGame("timelimit");
	}
}

/* FindPlayerStart()
returns the 'best' player start for this player to start from.
Re-implement for each game type
*/
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest, Candidate[4], Best;
	local float Score[4], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N;

	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;

	num = 0;
	//choose candidates	
	N = Level.NavigationPointList;
	While ( N != None )
	{
		if ( N.IsA('PlayerStart') && !N.Region.Zone.bWaterZone )
		{
			if (num<4)
				Candidate[num] = PlayerStart(N);
			else if (Rand(num) < 4)
				Candidate[Rand(4)] = PlayerStart(N);
			num++;
		}
		N = N.nextNavigationPoint;
	}

	if (num == 0 )
		foreach AllActors( class 'PlayerStart', Dest )
		{
			if (num<4)
				Candidate[num] = Dest;
			else if (Rand(num) < 4)
				Candidate[Rand(4)] = Dest;
			num++;
		}

	if (num>4) num = 4;
	else if (num == 0)
		return None;
		
	//assess candidates
	for (i=0;i<num;i++)
		Score[i] = 4000 * FRand(); //randomize
		
	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)	
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) )
			for (i=0;i<num;i++)
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
				{
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if (NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight)
						Score[i] -= 1000000.0;
					else if ( (NextDist < 2000) && OtherPlayer.LineOfSightTo(Candidate[i]) )
						Score[i] -= 10000.0;
				}
	
	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1;i<num;i++)
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}

	return Best;
}

/* AcceptInventory()
Examine the passed player's inventory, and accept or discard each item
* AcceptInventory needs to gracefully handle the case of some inventory
being accepted but other inventory not being accepted (such as the default
weapon).  There are several things that can go wrong: A weapon's
AmmoType not being accepted but the weapon being accepted -- the weapon
should be killed off. Or the player's selected inventory item, active
weapon, etc. not being accepted, leaving the player weaponless or leaving
the HUD inventory rendering messed up (AcceptInventory should pick another
applicable weapon/item as current).
*/
function AcceptInventory(pawn PlayerPawn)
{
	//deathmatch accepts no inventory
	local inventory Inv;
	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		Inv.Destroy();
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
	AddDefaultInventory( PlayerPawn );
}

function ChangeName( Pawn Other, coerce string S, bool bNameChange )
{
	local pawn APlayer;

	if ( S == "" )
		return;

	if (Other.PlayerReplicationInfo.PlayerName~=S)
		return;
	
	APlayer = Level.PawnList;
	
	While ( APlayer != None )
	{	
		if ( APlayer.bIsPlayer && (APlayer.PlayerReplicationInfo.PlayerName~=S) )
		{
			Other.ClientMessage(S$NoNameChange);
			return;
		}
		APlayer = APlayer.NextPawn;
	}

	if (bNameChange)
		BroadcastMessage(Other.PlayerReplicationInfo.PlayerName$GlobalNameChange$S, false);
			
	Other.PlayerReplicationInfo.PlayerName = S;

	if (LocalLog != None)
		LocalLog.LogNameChange(Other);
	if (WorldLog != None)
		WorldLog.LogNameChange(Other);
}

function bool ShouldRespawn(Actor Other)
{
	return ( (Inventory(Other) != None) && (Inventory(Other).ReSpawnTime!=0.0) );
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return ( (Level.NetMode == NM_Standalone) || (Spectator(Viewer) != None) );
}

// Monitor killed messages for fraglimit
function Killed(pawn killer, pawn Other, name damageType)
{
	Super.Killed(killer, Other, damageType);
	if ( (killer == None) || (Other == None) )
		return;
	if ( !bTeamGame && (FragLimit > 0) && (killer.PlayerReplicationInfo.Score >= FragLimit) )
		EndGame("fraglimit");

	if ( BotConfig.bAdjustSkill && (killer.IsA('PlayerPawn') || Other.IsA('PlayerPawn')) )
	{
		if ( killer.IsA('Bots') )
			Bots(killer).AdjustSkill(true);
		if ( Other.IsA('Bots') )
			Bots(Other).AdjustSkill(false);
	}
}	

function EndGame( string Reason )
{
	local actor A;
	local pawn aPawn;

	Super.EndGame(Reason);

	bGameEnded = true;
	aPawn = Level.PawnList;
	RemainingTime = -1; // use timer to force restart
}

defaultproperties
{
	 bDeathMatch=true
     bMultiPlayerBots=False
     bChangeLevels=True
     InitialBots=4
     GlobalNameChange=" changed name to "
     NoNameChange=" is already in use"
     BotConfigType=Class'UnrealShare.BotInfo'
     bNoMonsters=True
     bRestartLevel=False
     bPauseable=False
	 bHardCoreMode=True
     AutoAim=1.000000
     ScoreBoardType=Class'UnrealShare.UnrealScoreBoard'
     GameMenuType=Class'UnrealShare.UnrealDMGameOptionsMenu'
     MapListType=Class'UnrealShare.DMmaplist'
     MapPrefix="DM"
     BeaconName="DM"
     GameName="DeathMatch"
	 MaxPlayers=10
	 TimeMessage(0)="5 minutes left in the game!"
	 TimeMessage(1)="4 minutes left in the game!"
	 TimeMessage(2)="3 minutes left in the game!"
	 TimeMessage(3)="2 minutes left in the game!"
	 TimeMessage(4)="1 minute left in the game!"
	 TimeMessage(5)="30 seconds left!"
	 TimeMessage(6)="10 seconds left!"
	 TimeMessage(7)="5 seconds and counting..."
	 TimeMessage(8)="4..."
	 TimeMessage(9)="3..."
	 TimeMessage(10)="2..."
	 TimeMessage(11)="1..."
	 TimeMessage(12)="Time Up!"
}
