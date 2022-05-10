/*-----------------------------------------------------------------------------
	dnDeathmatchGame
-----------------------------------------------------------------------------*/
class dnDeathmatchGame expands GameInfo;

var() globalconfig  int	            FragLimit;          // number of kills needed to exit DM level
var() globalconfig  int	            TimeLimit;          // time limit in minutes
var() globalconfig  int             RestartWait;        // Time before starting next level
var() globalconfig  int             NetWait;            // time to wait for players in netgames w/ bNetReady (typically team games)
var() globalconfig  bool	        bMultiWeaponStay;   // Weapons stay when picked up
var() globalconfig  bool	        bForceRespawn;      // Force respawn
var() globalconfig  bool	        bAlwaysForceRespawn;// Force respawn
var() globalconfig  bool            bChangeLevels;      // Cycle through levels based on a maplist
var() globalconfig  int             MinPlayers;		    // bots fill in to guarantee this level in net game 
var() globalconfig	bool			bTournament;        // Run game as a tournament (requires all players to hit ready)
var() globalconfig  bool            bMegaSpeed;
var() globalconfig  bool            bHardCoreMode;

var                 int             RemainingTime;
var					int				ElapsedTime;
var                 int             CountDown;
var                 int             StartCount;
var                 float           EndTime;
var		            bool	        bDontRestart;
var		            bool	        bAlreadyChanged;
var                 bool            bNetReady;
var                 bool            bRequireReady;
var                 bool            bFirstBlood;
var                 bool            bDoSpree;

// Bot related Info
var                 int				NumBots;
var	                int				RemainingBots;

var localized string                StartMessage;
var localized string                StartUpMessage;
var localized string                CountdownMessage;
var localized string                WaitingMessage1, WaitingMessage2;
var localized string                ReadyMessage, NotReadyMessage;
var localized string				GameGoal;	
var localized string				TimeLimitMessageStart;
var localized string				TimeLimitMessageEnd;

var NavigationPoint					LastStartSpot; // Keep track of the last spawn point used

var localized string				GameEndedMessage;
var bool							bDisallowOverride;
var bool                            bPlayHitNotification;
var bool							bRoundEnded;

//===============================================================
//Login - Called when a new user joins the server
//===============================================================
event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{    
	local PlayerPawn		NewPlayer;
	local string			OverrideClass;
	local class<PlayerPawn> SpecClass;
	local string			InVoice;

	NewPlayer = Super.Login( Portal, Options, Error, SpawnClass );

	if ( NewPlayer != None )
	{
		if ( Left( NewPlayer.PlayerReplicationInfo.PlayerName, 6 ) == DefaultPlayerName )
			ChangeName( NewPlayer, ( DefaultPlayerName$NumPlayers ), false );

		NewPlayer.bAutoActivate = true;
	}

	// Setup the player's voice
	if ( NewPlayer != None )
	{
		if ( !NewPlayer.PlayerReplicationInfo.bIsSpectator )
		{
			InVoice = ParseOption ( Options, "Voice" );
		
			if ( InVoice != "" )
				NewPlayer.PlayerReplicationInfo.VoiceType = 
					class<VoicePack>(DynamicLoadObject(InVoice, class'Class'));

			if ( NewPlayer.PlayerReplicationInfo.VoiceType == None )
				NewPlayer.PlayerReplicationInfo.VoiceType = 
					class<VoicePack>(DynamicLoadObject(NewPlayer.VoiceType, class'Class'));
	
			if ( NewPlayer.PlayerReplicationInfo.VoiceType == None )
				NewPlayer.PlayerReplicationInfo.VoiceType = 
					class<VoicePack>(DynamicLoadObject("dnGame.MalePlayerSounds", class'Class')); 

			Log( "LOGIN::InVoice:" $ InVoice );
			Log( "LOGIN::Setting voice type to:" $ NewPlayer.PlayerReplicationInfo.VoiceType );

			NewPlayer.ServerChangeVoice( NewPlayer.PlayerReplicationInfo.VoiceType );
		}
	}

	// Match has not yet started, so put the player into waiting mode.
	if ( !bStartMatch && !NewPlayer.PlayerReplicationInfo.bIsSpectator )
	{		
		NewPlayer.EnterWaiting();
	}

	return NewPlayer;
}

//===============================================================
//PostLogin
//===============================================================
event PostLogin( playerpawn NewPlayer )
{
	Super.PostLogin( NewPlayer );
	
	// Display startup messages.
	PlayStartUpMessage( NewPlayer );
	NewPlayer.SetProgressTime( NetWait );
}

//===============================================================
//PlayStartUpMessage
//===============================================================
function PlayStartUpMessage(PlayerPawn NewPlayer, optional int Countdown )
{
	local int i;

	NewPlayer.ClearProgressMessages();

	// Game Name
	NewPlayer.SetProgressMessage( GameName, i++ );

	// Optional FragLimit
	if ( fraglimit > 0 )
	{
		NewPlayer.SetProgressMessage( FragLimit @ GameGoal, i++ );
	}

	// Optional TimeLimit
	if ( timelimit > 0 )
	{
		NewPlayer.SetProgressMessage( TimeLimitMessageStart @ TimeLimit @ TimeLimitMessageEnd, i++ );
	}
 	
	if ( Countdown > 0 )
	{
		NewPlayer.SetProgressMessage( Countdown $ CountdownMessage, ++i );
	}

	/*
	if ( Level.NetMode == NM_Standalone )
	{
		NewPlayer.SetProgressMessage( SingleWaitingMessage, i++ );
	}
	else if ( bRequireReady )
	{
		NewPlayer.SetProgressMessage( TourneyMessage, i++ );
	}
	*/
}

//===============================================================
//InitGameReplicationInfo - Initialization of the GRI for this dnDeathmatchGame
//===============================================================
function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();

	dnDeathmatchGameReplicationInfo(GameReplicationInfo).FragLimit = FragLimit;
	dnDeathmatchGameReplicationInfo(GameReplicationInfo).TimeLimit = TimeLimit;
}

//===============================================================
//PostBeginPlay
//===============================================================
function PostBeginPlay()
{
	local string NextPlayerClass;
	local int i;

	Super.PostBeginPlay();
	GameReplicationInfo.RemainingTime = RemainingTime;
}

//===============================================================
//SetGameSpeed - Set up the speed of the game and setup a timer
//===============================================================
function SetGameSpeed( Float T )
{
	GameSpeed = FMax(T, 0.1);

	// FIXME: Add this for Hardcore mode if we want it
	/*
	if ( bHardCoreMode )
	{
		if ( bChallengeMode )
			Level.TimeDilation = 1.25 * GameSpeed;
		else
			Level.TimeDilation = 1.1 * GameSpeed;
	}
	else
	*/

	Level.TimeDilation = GameSpeed;
	SaveConfig();
	SetTimer(Level.TimeDilation, true);
}
//===============================================================
//DoEffectSpawn - Creates a dnFXSpawn that will be sent to client and kick off effects
//===============================================================
function DoEffectSpawn( Actor Incoming, class<Actor>ClassName, vector Offset )
{
	local dnFXSpawner   SpawnFX;
	local Actor         HitActor;
	local Vector        StartTrace,EndTrace,HitLocation,HitNormal;

	StartTrace      = Incoming.Location;
	EndTrace        = StartTrace - vect(0,0,64);
	HitActor        = Trace( HitLocation, HitNormal, EndTrace, StartTrace, false );   
	HitLocation    += Offset;
	SpawnFX         = Spawn( class'dnFXSpawner',,, HitLocation, Incoming.Rotation );
	SpawnFX.FXClass = ClassName;

	// Do the spawn right away on the authortative side.
	if ( Role == ROLE_Authority )
		SpawnFX.DoSpawn();
}

//===============================================================
//PlayTeleportEffect - Played for respawning and joining players as well as teleporting
//===============================================================
function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound )
{
	DoEffectSpawn( Incoming, Class'dnParticles.dnSpawnFX_PlayerSpawn', vect(0,0,72) );
}

//===============================================================
//PlaySpawnEffect - Played for respawning inventory
//===============================================================
function float PlaySpawnEffect( Inventory Incoming )
{
	DoEffectSpawn( Incoming, Class'dnParticles.dnSpawnFX_ItemSpawn', vect(0,0,64) );
}

//===============================================================
//ShouldRespawn
//===============================================================
function bool ShouldRespawn( Actor other )
{
	return ( (Inventory(Other) != None ) && ( Inventory(Other).ReSpawnTime!=0.0 ) );
}

//===============================================================
//NeedPlayers
//===============================================================
function bool NeedPlayers()
{
	return ( !bGameEnded && ( NumPlayers + NumBots < MinPlayers ) );
}

//===============================================================
//RefreshProgress
//===============================================================
function RefreshProgress()
{
	local Pawn P;

	for (P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('PlayerPawn') )
			PlayerPawn(P).SetProgressTime(2);
}

//===============================================================
//Timer
//===============================================================
function Timer( optional int TimerNum )
{
	local Pawn P;
	local bool bReady;
	local int M;

	Super.Timer();

	// bNetReady - If true, we are getting ready to start a match
	if ( bNetReady )
	{
		// Only elapse time on the server if there is a player on here
		if ( NumPlayers > 0 )
			ElapsedTime++;
		else
			ElapsedTime = 0;

		// Wait at least NetWait time before kicking off anything, this allows real players
		// to connect before bots get spawned in.
		if ( ElapsedTime > NetWait )
		{
			if ( (NumPlayers + NumBots < 4) && NeedPlayers() )
				AddBot();
			else if ( 
					 ( CanStartMatch() ) && 
					 ( ( NumPlayers + NumBots > 1 ) || ( ( NumPlayers > 0 ) && ( ElapsedTime > 2 * NetWait ) ) )
					)
			{
				bNetReady = false;
			}
		}

		if ( bNetReady )
		{
			RefreshProgress();
			return;
		}
		else
		{
			// Add bots, and start the match!
			while ( NeedPlayers() )
				AddBot();

			bRequireReady = false;
			StartMatch();
		}
	}

	// If we require players to press fire (Ready) and there is a CountDown set up
	if ( bRequireReady && ( CountDown > 0 ) )
	{
		while ( (RemainingBots > 0) && AddBot() )
			RemainingBots--;

		RefreshProgress();

		if ( ( ( NumPlayers == MaxPlayers ) || ( Level.NetMode == NM_Standalone ) ) 
				&& ( RemainingBots <= 0 ) )

		{	
			bReady = true;
			
			// Check to see if all players are ready
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			{
				if ( P.IsA('PlayerPawn') && 
					 !PlayerPawn(P).PlayerReplicationInfo.bIsSpectator && 
					 !PlayerPawn(P).bReadyToPlay 
				   )
				{
					bReady = false;
				}
			}
			
			if ( bReady )  // Everyone is ready start the countdown!
			{	
				StartCount = 30;
				CountDown--;

				if ( CountDown <= 0 )
				{
					StartMatch(); // Start the match if countdown is done.
				}
				else
				{
					for ( P = Level.PawnList; P!=None; P=P.nextPawn )
						if ( P.IsA('PlayerPawn') )
						{
							PlayerPawn(P).ClearProgressMessages();
							if ( CountDown < 11 )
								PlayerPawn(P).SetProgressMessage( CountDown$CountDownMessage, 0 );
						}
				}
			}
			else if ( StartCount > 8 ) // After 8 seconds, send out messages to remind player to get ready
			{
				for ( P = Level.PawnList; P!=None; P=P.nextPawn )
					if ( P.IsA('PlayerPawn') )
					{
						PlayerPawn(P).ClearProgressMessages();
						PlayerPawn(P).SetProgressTime(2);
						PlayerPawn(P).SetProgressMessage( WaitingMessage1, 0 );
						PlayerPawn(P).SetProgressMessage( WaitingMessage2, 1 );
						
						if ( PlayerPawn(P).bReadyToPlay )
							PlayerPawn(P).SetProgressMessage( ReadyMessage, 2 );
						else
							PlayerPawn(P).SetProgressMessage( NotReadyMessage, 2 );
					}
			}
			else
			{
				StartCount++;
				if ( Level.NetMode != NM_Standalone )
					StartCount = 30;
			}
		}
		else
		{
			for ( P = Level.PawnList; P!=None; P=P.nextPawn )
				if ( P.IsA('PlayerPawn') )
					PlayStartupMessage(PlayerPawn(P));
		}
	}	
	else
	{
		if ( bAlwaysForceRespawn || 
			 ( bForceRespawn && ( Level.NetMode != NM_Standalone ) ) )
		{
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			{
				if ( P.GetControlState() == CS_Dead && P.IsA('PlayerPawn') && P.bHidden )
					PlayerPawn(P).ServerRestartPlayer();
			}
		}

		if ( Level.NetMode != NM_Standalone )
		{
			if ( NeedPlayers() )
				AddBot();
		}
		else
		{
			while ( (RemainingBots > 0) && AddBot() )
			{
				RemainingBots--;
			}
		}

		if ( bGameEnded )
		{
			if ( Level.TimeSeconds > EndTime + RestartWait )
				RestartGame();
		}
		else if ( !bOverTime && (TimeLimit > 0) )
		{
			GameReplicationInfo.bStopCountDown = false;
			RemainingTime--;
			GameReplicationInfo.RemainingTime = RemainingTime;
			
			if ( RemainingTime % 60 == 0 )
				GameReplicationInfo.RemainingMinute = RemainingTime;

			if ( RemainingTime <= 0 )
				EndGame("timelimit");
		}
		else
		{
			ElapsedTime++;
			GameReplicationInfo.ElapsedTime = ElapsedTime;

			// FIXME: Change this so we use some other variable (not RemainingTime)
			if ( RemainingTime > 0 && !bRoundEnded ) // For match games that have time remaining
			{
				RemainingTime--;
				GameReplicationInfo.RemainingTime = RemainingTime;
			}

			if ( RemainingTime <= 0 && !bRoundEnded )
				EndMatch( "timelimit" );
		}
	}
}

//===============================================================
//SendStartMessage
//===============================================================
function SendStartMessage( PlayerPawn P )
{
	P.ClearProgressMessages();
	P.SetProgressMessage( StartMessage, 0 );
	P.SetProgressTime( 1 );
}

//===============================================================
//StartMatch
//===============================================================
function StartMatch()
{	
	local Pawn P;
		
	/* FIXME : Do we need this?
	local TimedTrigger T;
	ForEach AllActors( class'TimedTrigger', T ) 
		T.SetTimer( T.DelaySeconds, T.bRepeating );    
	*/
	
	if ( Level.NetMode != NM_Standalone )
		RemainingBots = 0;

	GameReplicationInfo.RemainingMinute = RemainingTime;

	// Start players first (in their current startspots)
	for ( P = Level.PawnList; P!=None; P=P.nextPawn )
	{
		if ( P.bIsPlayer && P.IsA( 'PlayerPawn') )
		{
			if ( bGameEnded ) 
			{
				return; // telefrag ended the game with ridiculous frag limit
			}
			else if ( !PlayerPawn(P).PlayerReplicationInfo.bIsSpectator ) // Not a spectator
			{
				// Get them out of starting spectator mode and put them in the game
				P.PlayerReplicationInfo.bWaitingPlayer = false;
				P.PlayerRestartState			       = P.Default.PlayerRestartState;
				PlayerPawn(P).ServerRestartPlayer( true );
			}

			SendStartMessage( PlayerPawn( P ) );
		}
	}

	// Restart all the non-player pawns
	for ( P = Level.PawnList; P!=None; P=P.nextPawn )
	{
		if ( P.bIsPlayer && !P.IsA('PlayerPawn') )
		{
			P.RestartPlayer();
			/*
			if ( P.IsA( 'Bot' ) )
				Bot(P).StartMatch();
				*/
		}
	}

	bStartMatch = true;
}

//===============================================================
//FindPlayerStart - Find a start location to spawn the player in
//===============================================================
function NavigationPoint FindPlayerStart(Pawn Player, optional byte InTeam, optional string incomingName)
{
	local PlayerStart Dest, Candidate[16], Best;
	local float Score[16], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N, LastPlayerStartSpot;

	// Look for a Teleporter by the name specified
	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;

	// Choose candidates	from all the PlayerStarts in the level
	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		Dest = PlayerStart(N);
		if ( (Dest != None) && Dest.bEnabled && !Dest.Region.Zone.bWaterZone )
		{
			if ( num<16 )
				Candidate[num] = Dest;
			else if (Rand(num) < 16)
				Candidate[Rand(16)] = Dest;
			num++;
		}
	}

	// None found, search for PlayerStart by classname
	if ( num == 0 )
		foreach AllActors( class 'PlayerStart', Dest )
		{
			if ( num<16 )
				Candidate[num] = Dest;
			else if (Rand(num) < 16)
				Candidate[Rand(16)] = Dest;
			num++;
		}

	// Clamp to 16 locations
	if ( num>16 ) 
	{
		num = 16;
	}
	else if ( num == 0 ) // Couldn't find a PlayerStart		
	{
		Log( "dnDeatmatchGame::FindPlayerStart: Could not find a PlayerStart" );
		return None;
	}

	// Save off the Player's LastStartSpot so we don't duplicate it
	if ( 
		( Player != None ) && 
		( Player.IsA('DukePlayer') && ( DukePlayer(Player).StartSpot != None ) )
	   )
	{
		LastPlayerStartSpot = DukePlayer(Player).StartSpot;
	}

	// Assess candidates

	// Check for using the player's last start spot and avoid using it again
	for ( i=0; i<num; i++ )
	{
		if ( ( Candidate[i] == LastStartSpot ) || ( Candidate[i] == LastPlayerStartSpot ) )
			Score[i] = -10000.0;
		else
			Score[i] = 3000 * FRand(); //randomize
	}

	// Assign scores for distances to other players in the level
	for ( OtherPlayer = Level.PawnList; OtherPlayer != None; OtherPlayer = OtherPlayer.NextPawn )	
	{
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) && !OtherPlayer.PlayerReplicationInfo.bIsSpectator )
		{
			for ( i=0; i<num; i++ )
			{
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
				{
					Score[i] -= 1500;
					NextDist = VSize( OtherPlayer.Location - Candidate[i].Location );
					
					if ( NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight )
						Score[i] -= 1000000.0;
					else if ( (NextDist < 2000) && FastTrace(Candidate[i].Location, OtherPlayer.Location) )
						Score[i] -= (10000.0 - NextDist);
				}
				else if ( NumPlayers == 2 ) // Special case for 2 player
				{
					Score[i] += 2 * VSize( OtherPlayer.Location - Candidate[i].Location );
					if ( FastTrace( Candidate[i].Location, OtherPlayer.Location ) )
						Score[i] -= 10000;
				}
			}
		}
	}
	
	BestScore = Score[0];
	Best      = Candidate[0];

	for (i=1;i<num;i++)
	{
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	}

	LastStartSpot = Best;
	return Best;
}

//===============================================================
//AcceptInventory
//===============================================================
event AcceptInventory( pawn PlayerPawn )
{
	if ( PlayerPawn.PlayerReplicationInfo.bIsSpectator || PlayerPawn.PlayerReplicationInfo.bWaitingPlayer )
		return;

	Super.AcceptInventory( PlayerPawn );
}

//===============================================================
//AddDefaultInventory - Setup the default inventory for the pawn
//===============================================================
function AddDefaultInventory( pawn InventoryPawn )
{
	local Inventory Inv;
	local Weapon Weap;
	local Inventory InventoryItem;

	// Assign default inventory.
	Super.AddDefaultInventory( InventoryPawn );

	if ( InventoryPawn.IsSpectating() )
		return;

	// Pistol
	GiveWeaponTo( InventoryPawn, class'pistol' );
}

//===============================================================
//Killed - Called when a pawn is killed by another pawn
//===============================================================
function Killed( Pawn Killer, Pawn Victim, class<DamageType> DamageType )
{
	local int NextTaunt, i;
	local bool bAutoTaunt, bEndOverTime, bSpecialDamage;
	local Pawn P, Best;

	Super.Killed( Killer, Victim, DamageType );

	if ( Victim.Spree > 4 )
	{
		EndSpree( Killer, Victim ); 
	}
	Victim.Spree = 0;    	

	BroadcastRegularDeathMessage( Killer, Victim, damageType );

	if ( Victim.bIsPlayer )
	{
		if ( ( Killer != Victim ) && ( Killer != None ) ) // Not suicide
		{
			Victim.PlayerReplicationInfo.Deaths += 1;
		}
	}

	if ( !bTeamGame )
	{
		if ( bOverTime )
		{
			bEndOverTime = true;
			//check for clear winner now

			// find individual winner
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
			{
				if ( P.bIsPlayer && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
				{
					Best = P;
				}
			}

			// check for tie
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
			{
				if ( P.bIsPlayer && (Best != P) && (P.PlayerReplicationInfo.Score == Best.PlayerReplicationInfo.Score) )
				{
					bEndOverTime = false;
				}
			}

			if ( bEndOverTime )
			{
				if ( (FragLimit > 0) && (Best.PlayerReplicationInfo.Score >= FragLimit) )
				{
					EndGame("fraglimit");
				}
				else
				{
					EndGame("timelimit");
				}
			}
		}
		else if ( ( FragLimit > 0 ) && 
				  ( killer != None ) && 
				  ( killer.PlayerReplicationInfo != None ) &&
				  ( killer.PlayerReplicationInfo.Score >= FragLimit )
				)
		{
			EndGame("fraglimit");
		}
	}

	if ( ( Killer == None) || ( Victim == None ) )
	{
		return;
	}

	// First Blood Message
	if ( !bFirstBlood )
	{
		if ( Killer.bIsPlayer && (Killer != Victim) )
		{
			bFirstBlood = true;
			BroadcastLocalizedMessage( class'dnFirstBloodMessage', 0, Killer.PlayerReplicationInfo );
		}
	}

	// FIXME: Put Killing Spree functionality in
	if ( bDoSpree && Victim.bIsPlayer && (Killer != None) && Killer.bIsPlayer && (Killer != Victim) 
		&& ( !bTeamGame || ( Victim.PlayerReplicationInfo.Team != Killer.PlayerReplicationInfo.Team ) ) )
	{
		Killer.Spree++;
		if ( Killer.Spree > 4 )
		{
			NotifySpree( Killer, Killer.Spree );
		}
	}
}

//===============================================================
//NotifySpree
//===============================================================
function NotifySpree(Pawn Other, int num)
{
	local Pawn P;

	if ( num == 5 )
		num = 0;
	else if ( num == 10 )
		num = 1;
	else if ( num == 15 )
		num = 2;
	else if ( num == 20 )
		num = 3;
	else if ( num == 25 )
		num = 4;
	else
		return;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		P.ReceiveLocalizedMessage( class'dnKillingSpreeMessage', Num, Other.PlayerReplicationInfo );
	}
}

//===============================================================
//EndSpree
//===============================================================
function EndSpree( Pawn Killer, Pawn Other )
{
	local Pawn P;

	if ( !Other.bIsPlayer )
		return;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if ( !P.IsA('DukePlayer') )
			continue;

		if ( (Killer == None) || !Killer.bIsPlayer )
		{
			// Spree ended by non player
			DukePlayer(P).EndSpree( None, Other.PlayerReplicationInfo );
		}
		else
		{
			DukePlayer(P).EndSpree( Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo );
		}
	}
}

//===============================================================
//SetEndCams
//===============================================================
function bool SetEndCams( string Reason )
{
	local pawn P, Best;
	local PlayerPawn Player;

	// find individual winner
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.bIsPlayer && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
			Best = P;

	// check for tie between players, and extend the game by returning false (overtime)
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.bIsPlayer && (Best != P) && (P.PlayerReplicationInfo.Score == Best.PlayerReplicationInfo.Score) )
		{
			// Send a message to players about overtime.
			BroadcastLocalizedMessage( class'dnDeathmatchMessage', 0 );
			return false;
		}		

	if ( Best != None )
		Best.bAlwaysRelevant = true;

	EndTime									= Level.TimeSeconds + 3.0;
	GameReplicationInfo.GameEndedComments	= Best.PlayerReplicationInfo.PlayerName@GameEndedMessage;

	Log( "Game ended at "$EndTime );

	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		Player = PlayerPawn(P);
		
		if ( Player != None )
		{
			Player.bBehindView = true;
						
			if ( Player == Best )
			{
				Player.ViewTarget = None;
			}
			else
			{
				Player.ViewTarget = Best;				
			}

			Player.ClientGameEnded();
		}

		P.SetControlState( CS_Stasis );
	}

	// FIXME: Calculation of end level stats
	//CalcEndStats();
	return true;
}

//===============================================================
//RestartGame
//===============================================================
function RestartGame()
{
	local string NextMap;
	local MapList myList;

	// multipurpose don't restart variable
	if ( bDontRestart )
		return;

	// still showing end screen
	if ( EndTime > Level.TimeSeconds ) 
		return;

	// these server travels should all be relative to the current URL
	if ( bChangeLevels && !bAlreadyChanged && ( MapListType != None ) )
	{
		// open a the nextmap actor for this game type and get the next map
		bAlreadyChanged = true;
		myList          = spawn( MapListType );
		NextMap         = myList.GetNextMap();
		myList.Destroy();
		if ( NextMap == "" )
			NextMap = GetMapName( MapPrefix, NextMap,1 );

		if ( NextMap != "" )
		{
			Level.ServerTravel(NextMap, false);
			return;
		}
	}
	Level.ServerTravel("?Restart" , false);
}

//===============================================================
//InitGame - Setup options for the game
//===============================================================
event InitGame( string Options, out string Error )
{
	local string InOpt;

	Super.InitGame(Options, Error);
	bStartMatch = false;

	FragLimit     = GetIntOption( Options, "FragLimit", FragLimit );
	TimeLimit     = GetIntOption( Options, "TimeLimit", TimeLimit );
	RemainingTime = 60 * TimeLimit;

	SetGameSpeed( GameSpeed );

	if ( bTournament ) // Tourney game requires all players to click ready when maxplayers is reached
	{
		bRequireReady = true;
	}

	if ( Level.NetMode == NM_StandAlone ) // Standalone requires ready, but quick countdown
	{
		bRequireReady = true;
		CountDown = 1;
	}

	if ( !bRequireReady && (Level.NetMode != NM_Standalone) ) // Regular game
	{
		bRequireReady	= true;
		bNetReady		= true;
	}
}

//===============================================================
//GetRules
//===============================================================
function string GetRules()
{
	local string ResultSet;
	ResultSet = Super.GetRules();

	ResultSet = ResultSet$"\\timelimit\\"$TimeLimit;
	ResultSet = ResultSet$"\\fraglimit\\"$FragLimit;
	Resultset = ResultSet$"\\minplayers\\"$MinPlayers;
	Resultset = ResultSet$"\\changelevels\\"$bChangeLevels;

	if ( bMegaSpeed )
		Resultset = ResultSet$"\\gamestyle\\Turbo";
	else if ( bHardcoreMode )
		Resultset = ResultSet$"\\gamestyle\\Hardcore";
	else
		Resultset = ResultSet$"\\gamestyle\\Classic";

	/*
	if ( MinPlayers > 0 )
		Resultset = ResultSet$"\\botskill\\"$class'ChallengeBotInfo'.default.Skills[Difficulty];
	*/

	return ResultSet;
}

function bool MatchStarted()
{
	return bStartMatch;
}

function bool CanStartMatch()
{
	return true;
}

function EndMatch( optional string Reason )
{
}

//===============================================================
//defaultproperties
//===============================================================
defaultproperties
{
	GameName="Duke Deathmatch"    
	DefaultWeapon=class'dnGame.mightyfoot'
	MapPrefix="DM-"
	BeaconName="!Z"
	bRestartLevel=false
	bPlayDeathSequence=false
	bPlayStartLevelSequence=false
	bMeshAccurateHits=false

	// Classes to use
	GameReplicationInfoClass=class'dnGame.dnDeathmatchGameReplicationInfo'
	DeathMessageClass=class'dnGame.dnDeathMessage'
	DMMessageClass=class'dnGame.dnDeathMatchMessage'
	ScoreboardType=class'dnGame.dnDeathmatchGameScoreboard'
	HUDType=class'dnGame.dnDeathmatchGameHUD'    
	RulesMenuType="dnWindow.UDukeMultiRulesSC"
	BotMenuType="dnWindow.UDukeBotSettingsSC"
	MapListType=class'MapList'
	RespawnMarkerType="dnGame.dnRespawnMarker"

	// Game messages
	GameEndedMessage="wins the match!"
	GameGoal="frags wins the match."
	TimeLimitMessageStart="Time Limit:"
	TimeLimitMessageEnd="Minutes"
	StartMessage="The match has begun!"
	StartUpMessage=""
	CountDownMessage=" seconds until play starts!"
	WaitingMessage1="Waiting for ready signals."
	WaitingMessage2="(Use your fire button to toggle ready!)"
	ReadyMessage="You are READY!"
	NotReadyMessage="You are NOT READY!"

	FragLimit=20
	CountDown=5
	RestartWait=10
	NetWait=5
	bDontRestart=false
	bDeathmatch=true
	bPlayHitNotification=true;
	FallingDamageScale=0.5
	bPauseable=false
	bPlayStinger=false
	bShowScores=true
	bValidateSkins=true
}
