//=============================================================================
// GameInfo.
//
// default game info is normal single player
//
//=============================================================================
class GameInfo extends Info
	native;

//-----------------------------------------------------------------------------
// Variables.
var() globalconfig int		MaxPlayers;				// Max Players allowed
var   int					NumPlayers;				// Number of players in game
var   int					CurrentID;				// Unique ID number for a player
var   byte					Difficulty;				// 0=easy, 1=medium, 2=hard, 3=very hard.
var() config bool   		bNoMonsters;			// Whether monsters are allowed in this play mode.
var() globalconfig bool		bMuteSpectators;		// Whether spectators are allowed to speak.
var() config bool			bHumansOnly;			// Whether non human player models are allowed.
var() bool				    bRestartLevel;			// Whether or not to restart the level
var() bool				    bPauseable;				// Whether the level is pauseable.
var() config bool			bCoopWeaponMode;		// Whether or not weapons stay when picked up.
var   globalconfig bool	    bLowGore;				// Whether or not to reduce gore.
var	  bool				    bCanChangeSkin;			// Allow player to change skins in game.
var() bool				    bTeamGame;				// This is a teamgame.
var() bool				    bShowScores;			// Show scoreboard when dead
var	  globalconfig bool	    bVeryLowGore;			// Greatly reduces gore.
var() globalconfig bool     bNoCheating;			// Disallows cheating. Hehe.
var() globalconfig bool     bAllowFOV;				// Allows FOV changes in net games
var() bool					bDeathMatch;			// This game is some type of deathmatch (where players can respawn during gameplay)
var	  bool					bGameEnded;				// set when game ends
var	  bool					bOverTime;				// Game went into overtime
var	  localized bool		bAlternateMode;			 
var	  bool				    bCanViewOthers;			// Can view other player's names
var	  bool					bPlayDeathSequence;		// Play a death seequence when the player is killed.
var	  bool					bPlayStartLevelSequence;// Play a startup sequence on the level
var() config bool			bRespawnMarkers;		// Whether or not respawn markers are visible.
var	  bool					bMeshAccurateHits;		// The game allows mesh accurate hits.
var() globalconfig float	AutoAim;				// How much autoaiming to do (1 = none, 0 = always).
													// (cosine of max error to correct)

var() float					GameSpeed;				// Scale applied to game rate.
var	  float                 StartTime;				// Start time fo the game
var() class<playerpawn>     DefaultPlayerClass;		// Default player class to fallback to
var() class<weapon>         DefaultWeapon;			// Default weapon given to player at start.

var() globalconfig int	    MaxSpectators;			// Maximum number of spectators.
var	  int					NumSpectators;			// Current number of spectators.

var() class<Scoreboard>		ScoreboardType;			// Type of scoreboard this game uses.
var() string			    RulesMenuType;			// Type of rules menu to display.
var() string				GameOptionsMenuType;	// Type of options dropdown to display.
var() string				BotMenuType;		    // Type of bot settings to display.
var() string				MapMenuType;		    // Type of map info menu to display.
var() string				MutatorMenuType;	    // Type of mutator menu to display.
var() string				ServerMenuType;			// Type of server info menu to display.
var() string                RespawnMarkerType;      // Type of marker to respawn for this game.

var() class<hud>			HUDType;				// HUD class this game uses.
var() class<MapList>		MapListType;			// Maplist this game uses.
var() string			    MapPrefix;				// Prefix characters for names of maps for this game type.
var() string			    BeaconName;				// Identifying string used for finding LAN servers.
var	  int					SentText;
var   localized string	    DefaultPlayerName;
var   localized string	    LeftMessage;			// Left the game message
var   localized string	    FailedSpawnMessage;		// Failed to spawn message
var   localized string	    FailedPlaceMessage;		// Couldn't find a start spot
var   localized string	    FailedTeamMessage;		// Couldn't join the team
var   localized string	    NameChangedMessage;		// Player changed their name
var   localized string	    EnteredMessage;			// Player entered the game
var   localized string	    EnteredSpectatorMessage;// Player entered the game as a spectator
var   localized string	    GameName;				// Name of the game
var	  localized string	    MaxedOutMessage;		// Something was maxed out (Spectator/Players)
var	  localized string	    WrongPassword;			// Wrong password for the game
var	  localized string      NeedPassword;			// Needs a password to play
var	  localized string      IPBanned;				// IP was banned message
var() globalconfig string   IPPolicies[50];			
var   class<ZoneInfo>		WaterZoneType;			// Default waterzone entry and exit effects
var   globalconfig string	ServerLogName;			// Server Log

var   class<LocalMessage>	DeathMessageClass;      // Message classes.
var   class<LocalMessage>	DMMessageClass;			// Message classes.

// Mutators (for modifying actors as they enter the game)
var	  class<Mutator>		MutatorClass;			// Base Mutator class name
var   Mutator				BaseMutator;			// linked list of mutators which affect the game
var   Mutator				DamageMutator;			// linked list of mutators which affect damage

var   string				RandomNames[32];		// Creature carcass names.
var   string				SortedRandomNames[32];	// Creature carcass names.
var   int					RandomNameIndex, UsedRandomNames[32]; 
var   bool					bStartMatch;
var   float                 FallingDamageScale;		// Amount to scale falling damage by
var   bool					bPlayStinger;			// Play a stinger sound when you die

var() private globalconfig string AdminPassword;    // Password to receive bAdmin privileges.
var() private globalconfig string GamePassword;	    // Password to enter game.

var() bool					bCanChangeClass;		// Allows a player to change classes.
var   bool					bSearchBodies;			// Allows searchable carcasses
var   bool					bOverridePlayerClass;	// Allows the game to override the player class
var() globalconfig  bool    bValidateSkins;         // Validate skins using the multiplayer.mds file


// Game Replication
var() class<GameReplicationInfo>	GameReplicationInfoClass;
var   GameReplicationInfo			GameReplicationInfo;

//------------------------------------------------------------------------------
// Admin

function AdminLogin( PlayerPawn P, string Password )
{
	if ( AdminPassword == "" )
		return;

	if ( Password == AdminPassword )
	{
		P.bAdmin						= True;
		P.PlayerReplicationInfo.bAdmin	= P.bAdmin;
		Log( "Administrator logged in." );
		BroadcastMessage( P.PlayerReplicationInfo.PlayerName@"became a server administrator." );
	}
}

function AdminLogout( PlayerPawn P )
{
	if ( AdminPassword == "" )
		return;

	if ( P.bAdmin )
	{
		P.bAdmin						= False;
		P.PlayerReplicationInfo.bAdmin	= P.bAdmin;
		Log( "Administrator logged out." );
		BroadcastMessage( P.PlayerReplicationInfo.PlayerName@"gave up administrator abilities." );
	}
}

//------------------------------------------------------------------------------
// Engine notifications.

function PreBeginPlay()
{
	local int i, j, used;

	//Log( "GameInfo::PreBeginPlay" );

	StartTime = 0;
	SetGameSpeed( GameSpeed );
	Level.bNoCheating = bNoCheating;
	Level.bAllowFOV   = bAllowFOV;
	
	if ( GameReplicationInfoClass != None )
    {
		GameReplicationInfo = Spawn( GameReplicationInfoClass );
        Log( "Using GameReplicationInfo class:"$GameReplicationInfoClass );
    }
	else
    {
		GameReplicationInfo = Spawn( class'GameReplicationInfo' );
        Log( "Using GameReplicationInfo class:GameReplicationInfo" );
    }

	InitGameReplicationInfo();

	Level.GRI = GameReplicationInfo;

	for ( i=0; i<32; i++ )
	{
		j	 = Rand(32);
		used = UsedRandomNames[j];
		while ( used != 0 )
		{
			j++;
			if ( j > 31 )
				j = 0;
			used = UsedRandomNames[j];
		}
		SortedRandomNames[i] = RandomNames[j];
		UsedRandomNames[j]   = 1;
	}
}

function PostBeginPlay()
{
	local ZoneInfo W;

	//Log( "GameInfo::PostBeginPlay" );

	if ( bAlternateMode )
	{
		bLowGore = true;
		bVeryLowGore = true;
	}

	if ( bVeryLowGore )
		bLowGore = true;

	if ( WaterZoneType != None )
	{
		ForEach AllActors(class'ZoneInfo', W )
			if ( W.bWaterZone )
			{
				if( W.EntryActor == None )
					W.EntryActor = WaterZoneType.Default.EntryActor;
				if( W.ExitActor == None )
					W.ExitActor = WaterZoneType.Default.ExitActor;
				if( W.EntrySound == None )
					W.EntrySound = WaterZoneType.Default.EntrySound;
				if( W.ExitSound == None )
					W.ExitSound = WaterZoneType.Default.ExitSound;
			}
	}

	Super.PostBeginPlay();
}

function Timer( optional int TimerNum )
{
	SentText = 0;
}

// Called when game shutsdown.
event GameEnding()
{
}

//------------------------------------------------------------------------------
// Replication

function InitGameReplicationInfo()
{
	GameReplicationInfo.bTeamGame               = bTeamGame;
	GameReplicationInfo.GameName                = GameName;
	GameReplicationInfo.GameClass               = string(Class);
	GameReplicationInfo.bMeshAccurateHits       = bMeshAccurateHits;
	GameReplicationInfo.bPlayDeathSequence      = bPlayDeathSequence;
	GameReplicationInfo.bShowScores             = bShowScores;
}

native function string GetNetworkNumber();

//------------------------------------------------------------------------------
// Game Querying.

function string GetInfo()
{
	local string ResultSet;

	return ResultSet;
}

function string GetRules()
{
	local string ResultSet;
	local Mutator M;
	local string NextMutator, NextDesc;
	local string EnabledMutators;
	local int Num, i;

	ResultSet = "";

	EnabledMutators = "";
	for ( M = BaseMutator.NextMutator; M != None; M = M.NextMutator )
	{
		Num			= 0;
		NextMutator = "";
		GetNextIntDesc( "Engine.Mutator", 0, NextMutator, NextDesc );
		while ( ( NextMutator != "" ) && ( Num < 50 ) )
		{
			if ( NextMutator ~= string( M.Class ) )
			{
				i = InStr( NextDesc, "," );
				if ( i != -1 )
					NextDesc = Left( NextDesc, i );

				if ( EnabledMutators != "" )
					EnabledMutators = EnabledMutators $ ", ";

				 EnabledMutators = EnabledMutators $ NextDesc;
				 break;
			}
			
			Num++;
			GetNextIntDesc( "Engine.Mutator", Num, NextMutator, NextDesc );
		}
	}

	if ( EnabledMutators != "" )
		ResultSet = ResultSet $ "\\mutators\\"$EnabledMutators;

	ResultSet = ResultSet $ "\\listenserver\\"$string( Level.NetMode==NM_ListenServer );

	return ResultSet;
}

// Return the server's port number.
function int GetServerPort()
{
	local string S;
	local int i;

	// Figure out the server's port.
	S = Level.GetAddressURL();
	i = InStr( S, ":" );
	assert( i>=0 );
	return int( Mid( S, i + 1 ) );
}

function bool SetPause( BOOL bPause, PlayerPawn P )
{
	if ( bPauseable || P.bAdmin || Level.Netmode==NM_Standalone )
	{
		if( bPause )
			Level.Pauser=P.PlayerReplicationInfo.PlayerName;
		else
			Level.Pauser="";
		
		return true;
	}
	else 
	{
		return false;
	}
}

//------------------------------------------------------------------------------
// Game parameters.

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
	GameSpeed			= FMax(T, 0.1);
	Level.TimeDilation	= GameSpeed;
	SetTimer( Level.TimeDilation, true );
}

static function ResetGame();

//
// Called after setting low or high detail mode.
//
event DetailChange()
{
	local renderactor A;
	local light L;
	local zoneinfo Z;
	local skyzoneinfo S;

/*
	// NJS: Destroy all non mesh affecting lights/items.
	foreach AllActors(class'Light', L)
	{
		if( !L.AffectMeshes && !L.bDynamicLight)
		{
			//L.bNoDelete=false;
			//L.bStasis=false;
			L.Destroy();
		}
	}
*/
	if( !Level.bHighDetailMode )
	{
		foreach AllActors(class'RenderActor', A)
		{
			if( A.bHighDetail && !A.bGameRelevant )
				A.Destroy();
		}
	}

	foreach AllActors(class'ZoneInfo', Z)
	{
		Z.LinkToSkybox();
	}
}

//
// Return whether an actor should be destroyed in
// this type of game.
//	
function bool IsRelevant( actor Other )
{
	local byte bSuperRelevant;

	// let the mutators mutate the actor or choose to remove it
	if ( BaseMutator.AlwaysKeep( Other ) )
		return true;

	if ( BaseMutator.IsRelevant( Other, bSuperRelevant ) )
	{
		if ( bSuperRelevant == 1 ) // mutator wants to override any logic in here
			return true;
	}
	else
	{
		return false;
	}

	if (
	     ( Difficulty==0 && !Other.bDifficulty0 ) ||
	     ( Difficulty==1 && !Other.bDifficulty1 ) ||
	     ( Difficulty==2 && !Other.bDifficulty2 ) ||
	     ( Difficulty==3 && !Other.bDifficulty3 ) ||
	     ( !Other.bSinglePlayer && ( Level.NetMode==NM_Standalone ) ) ||
	     ( !Other.bNet && ( ( Level.NetMode == NM_DedicatedServer ) || (Level.NetMode == NM_ListenServer)) ) ||
	     ( !Other.bNetSpecial  && ( Level.NetMode==NM_Client ) ) 
	   )
		{
			return false;
		}

	if ( bNoMonsters && ( Pawn( Other ) != None ) && !Pawn( Other ).bIsPlayer )
		return false;

	if ( FRand() > Other.OddsOfAppearing )
		return false;

	return true;
}

//------------------------------------------------------------------------------
// Player start functions

//
// Grab the next option from a string.
//
function bool GrabOption( out string Options, out string Result )
{
	if( Left(Options,1)=="?" )
	{
		// Get result.
		Result = Mid(Options,1);
		if( InStr(Result,"?")>=0 )
			Result = Left( Result, InStr(Result,"?") );

		// Update options.
		Options = Mid(Options,1);
		if( InStr(Options,"?")>=0 )
			Options = Mid( Options, InStr(Options,"?") );
		else
			Options = "";

		return true;
	}
	else return false;
}

//
// Break up a key=value pair into its key and value.
//
function GetKeyValue( string Pair, out string Key, out string Value )
{
	if( InStr(Pair,"=")>=0 )
	{
		Key   = Left(Pair,InStr(Pair,"="));
		Value = Mid(Pair,InStr(Pair,"=")+1);
	}
	else
	{
		Key   = Pair;
		Value = "";
	}
}

//
// See if an option was specified in the options string.
//
function bool HasOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return true;
	}
	return false;
}

//
// Find an option in the options string and return it.
//
function string ParseOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return Value;
	}
	return "";
}

//
// Initialize the game.
//warning: this is called before actors' PreBeginPlay.
//
event InitGame( string Options, out string Error )
{
	local string InOpt, LeftOpt;
	local int pos;
	local class<Mutator> MClass;

	Log( "GameInfo::InitGame:" @ Options );

	MaxPlayers = Min( 32,GetIntOption( Options, "MaxPlayers", MaxPlayers ));
	InOpt = ParseOption( Options, "Difficulty" );
	if( InOpt != "" )
		Difficulty = int(InOpt);

	InOpt = ParseOption( Options, "AdminPassword");
	if( InOpt!="" )
		AdminPassword = InOpt;

	InOpt = ParseOption( Options, "GameSpeed");
	if( InOpt != "" )
	{
		log("GameSpeed"@InOpt);
		SetGameSpeed(float(InOpt));
	}

	BaseMutator = spawn(MutatorClass);
	log("Base Mutator is "$BaseMutator);
	InOpt = ParseOption( Options, "Mutator");
	if ( InOpt != "" )
	{
		log("Mutators"@InOpt);
		while ( InOpt != "" )
		{
			pos = InStr(InOpt,",");
			if ( pos > 0 )
			{
				LeftOpt = Left(InOpt, pos);
				InOpt = Right(InOpt, Len(InOpt) - pos - 1);
			}
			else
			{
				LeftOpt = InOpt;
				InOpt = "";
			}
			log("Add mutator "$LeftOpt);
			MClass = class<Mutator>(DynamicLoadObject(LeftOpt, class'Class'));	
			BaseMutator.AddMutator(Spawn(MClass));
		}
	}

	InOpt = ParseOption( Options, "GamePassword");
	if( InOpt != "" )
	{
		GamePassWord = InOpt;
		log( "GamePassword" @ InOpt );
	}
}

//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{	
	return
		Level.ComputerName
	$	" "
	$	Left(Level.Title,24) 
	$	" "
	$	BeaconName
	$	" "
	$	NumPlayers
	$	"/"
	$	MaxPlayers;
}

//
// Optional handling of ServerTravel for network games.
//
function ProcessServerTravel( string URL, bool bItems )
{
	local playerpawn P, LocalPlayer;

	// Notify clients we're switching level and give them time to receive.
	// We call PreClientTravel directly on any local PlayerPawns (ie listen server)
	log("ProcessServerTravel:"@URL);
	foreach AllActors( class'PlayerPawn', P )
    {
		if( NetConnection(P.Player)!=None )
        {
			P.ClientTravel( URL, TRAVEL_Relative, bItems );
        }
		else
		{	
			LocalPlayer = P;
			P.PreClientTravel();
		}
    }

	if ( ( Level.NetMode == NM_ListenServer ) && ( LocalPlayer != None ) )
    {
		Level.NextURL = Level.NextURL$"?Mesh="$LocalPlayer.GetDefaultURL("Mesh")
					 $"?Face="$LocalPlayer.GetDefaultURL("Face")
					 $"?Torso="$LocalPlayer.GetDefaultURL("Torso")
				     $"?Arms="$LocalPlayer.GetDefaultURL("Arms")
					 $"?Legs="$LocalPlayer.GetDefaultURL("Legs")
					 $"?Team="$LocalPlayer.GetDefaultURL("Team")
					 $"?Name="$LocalPlayer.GetDefaultURL("Name")
					 $"?Icon="$LocalPlayer.GetDefaultURL("Icon")
					 $"?Voice="$LocalPlayer.GetDefaultURL("Voice")
					 $"?Spectator="$LocalPlayer.GetDefaultURL("Spectator");
    }

	// Switch immediately if not networking.
	if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		Level.NextSwitchCountdown = 0.0;
}

function bool AtCapacity(string Options)
{
	return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode
)
{
	// Do any name or password or name validation here.
	local string InPassword;

	//Log( "GameInfo::PreLogin" );

	Error="";
	InPassword = ParseOption( Options, "Password" );
	if( (Level.NetMode != NM_Standalone) && AtCapacity(Options) )
	{
		Error=MaxedOutMessage;
	}
	else if
	(	GamePassword!=""
	&&	caps(InPassword)!=caps(GamePassword)
	&&	(AdminPassword=="" || caps(InPassword)!=caps(AdminPassword)) )
	{
		if( InPassword == "" )
		{
			Error = NeedPassword;
			FailCode = "NEEDPW";
		}
		else
		{
			Error = WrongPassword;
			FailCode = "WRONGPW";
		}
	}

	if(!CheckIPPolicy(Address))
		Error = IPBanned;
}

function bool CheckIPPolicy(string Address)
{
	local int i, j, LastMatchingPolicy;
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;
	
	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<50 && IPPolicies[i] != ""; i++)
	{
		j = InStr(IPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(IPPolicies[i], j);
		Mask = Mid(IPPolicies[i], j+1);
		if(Policy ~= "ACCEPT") 
			bAcceptPolicy = True;
		else
		if(Policy ~= "DENY") 
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
	}

	if(!bAcceptAddress)
		Log("Denied connection for "$Address$" with IP policy "$IPPolicies[LastMatchingPolicy]);
		
	return bAcceptAddress;
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	
	if ( InOpt != "" )
	{
		return int( InOpt );
	}	

	return CurrentValue;
}

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local NavigationPoint	StartSpot;
	local PlayerPawn		NewPlayer, TestPlayer;
	local Pawn				PawnLink;
	local string			InName, InPassword, InFace, InArms, InTorso, InLegs, InMesh, InVoice, InChecksum, InIcon;
	local byte				InTeam, InSpectate;
	local class<PlayerPawn>	OverrideSpawnClass;

	//Log( "GameInfo::Login" );

	InSpectate = GetIntOption( Options, "Spectate", 0 );

	// Make sure there is capacity. (This might have changed since the PreLogin call).
	if ( Level.NetMode != NM_Standalone )
	{
		if ( InSpectate != 0 )
		{
			if ( 
				 ( NumSpectators >= MaxSpectators ) &&
				 ( ( Level.NetMode != NM_ListenServer ) || ( NumPlayers > 0 ) )
			   )
			{
				Error=MaxedOutMessage;
				return None;
			}
		}
		else if ( ( MaxPlayers > 0 ) && ( NumPlayers >= MaxPlayers ) )
		{
			Error=MaxedOutMessage;
			return None;
		}
	} 
	else
	{
		MusicPlay( Level.Mp3, true );
	}

	// Get URL options.
	InName      = Left( ParseOption ( Options, "Name"), 20  );
	InTeam      = GetIntOption( Options, "Team",        255 ); // default to "no team"
	InPassword  = ParseOption ( Options, "Password"         );
	InMesh      = ParseOption ( Options, "Mesh"				);
	InFace      = ParseOption ( Options, "Face"				);	
	InArms      = ParseOption ( Options, "Arms"				);
	InTorso     = ParseOption ( Options, "Torso"			);
	InLegs      = ParseOption ( Options, "Legs"				);
	InVoice     = ParseOption ( Options, "Voice"			);
	InChecksum  = ParseOption ( Options, "Checksum"			);
	InIcon      = ParseOption ( Options, "Icon"				);	

	Log( "GameInfo::Login:" @ InName );

	if( InPassword != "" )
	{
		log( "Password"@InPassword );
	}
	
	// Find a start spot.
	StartSpot = FindPlayerStart( None, InTeam, Portal );

	if( StartSpot == None )
	{
		Error = FailedPlaceMessage;
		return None;
	}

	// Try to match up to existing unoccupied player in level,
	// for savegames and coop level switching.
	for( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.NextPawn )
	{
		TestPlayer = PlayerPawn( PawnLink );
		if (
			 TestPlayer!=None                         &&
			 TestPlayer.Player==None                  &&
			 TestPlayer.PlayerReplicationInfo != None &&
			 TestPlayer.bIsPlayer                     &&	
			 TestPlayer.PlayerReplicationInfo.PlayerName != class'PlayerReplicationInfo'.default.PlayerName
		   )
		{
			if (
				( Level.NetMode==NM_Standalone ) ||
				( TestPlayer.PlayerReplicationInfo.PlayerName~=InName && TestPlayer.Password~=InPassword )
			   )
			{
				// Found matching unoccupied player, so use this one.
				NewPlayer = TestPlayer;
				break;
			}
		}
	}

	// If not found, spawn a new player.
	if( NewPlayer == None )
	{
		// Make sure this kind of player is allowed.
		if ( ( bHumansOnly || Level.bHumansOnly ) && !SpawnClass.Default.bIsHuman && ( InSpectate == 0 ) )
		{
			SpawnClass = DefaultPlayerClass;
		}

		// Check if the game overrides the player class
		if ( Level.Game.bOverridePlayerClass )
		{			
			OverrideSpawnClass = Level.Game.GetOverridePlayerClass( InTeam );
			Log( "LOGIN:Using Override Class: " @ OverrideSpawnClass );
		}

		if ( OverrideSpawnClass != None )
		{
			SpawnClass = OverrideSpawnClass;
		}

		Log( "LOGIN:Spawning New Player Class" @ SpawnClass );

		NewPlayer = Spawn( SpawnClass,,,StartSpot.Location,StartSpot.Rotation );

		if( NewPlayer != None )
		{
			NewPlayer.bCollideWorld = true;
			NewPlayer.ViewRotation  = StartSpot.Rotation;
		}
	}
	
	// Handle spawn failure.
	if( NewPlayer == None )
	{
		Log( "Couldn't spawn player at "$StartSpot );
		Error = FailedSpawnMessage;
		return None;
	}
	
	// Change Mesh and Skin to the player's preference, if not overidden by the game
	if ( !Level.Game.bOverridePlayerClass )
	{
		NewPlayer.ServerChangeMesh( InMesh );
		NewPlayer.ServerChangeSkin( InFace, InTorso, InArms, InLegs, InIcon );
		// Setup the player's voice
		NewPlayer.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject("dnGame.MalePlayerSounds", class'Class'));
		NewPlayer.ServerChangeVoice( NewPlayer.PlayerReplicationInfo.VoiceType );
	}
		
	// Set the player's ID.
	NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Init player's information.
	NewPlayer.ClientSetRotation( NewPlayer.Rotation );
	
	// Get a default name going
	if( InName=="" )
		InName=DefaultPlayerName;
	
	// Change the player's name if we're on a server.
	if( Level.NetMode != NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName == DefaultPlayerName )
	{
		ChangeName( NewPlayer, InName, false );
	}

	// Change player's team.
	if ( !ChangeTeam( newPlayer, InTeam ) )
	{
		Error = FailedTeamMessage;
		return None;
	}

	// Mark the player as spectator
	if( ( InSpectate != 0 ) && ( Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer ) )
	{
		//Log( "GameInfo::Login: Adding spectator to game" );
		NumSpectators++;
		NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
		NewPlayer.bHidden							 = true;
	}

	// Init player's administrative privileges
	NewPlayer.Password	= InPassword;
	NewPlayer.bAdmin	= AdminPassword!="" && caps(InPassword)==caps(AdminPassword);

	if( NewPlayer.bAdmin )
		Log( "Administrator logged in!" );

	// Init player's replication info
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// If we are a server, broadcast a welcome message.
	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
	{
		if( NewPlayer.PlayerReplicationInfo.bIsSpectator )
			BroadcastMessage( NewPlayer.PlayerReplicationInfo.PlayerName$EnteredMessage, false );
		else
			BroadcastMessage( NewPlayer.PlayerReplicationInfo.PlayerName$EnteredMessage, false );
	}

	// Teleport-in effect.
	if ( !NewPlayer.PlayerReplicationInfo.bIsSpectator )
		StartSpot.PlayTeleportEffect( NewPlayer, true );

	if ( InSpectate == 0 )
		NumPlayers++;

	return newPlayer;
}	

//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
event PostLogin( playerpawn NewPlayer )
{
	local Pawn P;
	// Start player's music.
	NewPlayer.ClientSetMusic( Level.Song, Level.SongSection, Level.CdTrack, MTRAN_Fade );

	if ( Level.NetMode != NM_Standalone )
	{
		// replicate skins
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P != NewPlayer) )
			{
				if ( P.bIsMultiSkinned )
					NewPlayer.ClientReplicateSkins(P.MultiSkins[0], P.MultiSkins[1], P.MultiSkins[2], P.MultiSkins[3]);
				else
					NewPlayer.ClientReplicateSkins(P.Skin);	
					
				if ( (P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bWaitingPlayer && P.IsA('PlayerPawn') )
				{
					if ( NewPlayer.bIsMultiSkinned )
						PlayerPawn(P).ClientReplicateSkins(NewPlayer.MultiSkins[0], NewPlayer.MultiSkins[1], NewPlayer.MultiSkins[2], NewPlayer.MultiSkins[3]);
					else
						PlayerPawn(P).ClientReplicateSkins(NewPlayer.Skin);	
				}						
			}
	}
}

//
// Add bot to game.
//
function bool AddBot();
function bool ForceAddBot();

//
// Pawn exits.
//
function Logout( pawn Exiting )
{
	local bool bMessage;

	bMessage = true;
	if ( Exiting.IsA('PlayerPawn') )
	{
		if ( Exiting.PlayerReplicationInfo.bIsSpectator )
		{
			bMessage = false;
			if ( Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer )
				NumSpectators--;
		}
		else
			NumPlayers--;
	}
	if( bMessage && (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) )
	{
		BroadcastMessage( Exiting.PlayerReplicationInfo.PlayerName$LeftMessage, false );
	}
}

// A chance to discard a player's inventory as he travels between maps.
event AcceptInventory( pawn PlayerPawn )
{
	local Actor A;

	// Initialize the inventory.
	AddDefaultInventory( PlayerPawn );

	// Adjust actor position from traveling.
	if ( PlayerPawn.IsA('PlayerPawn') && (Level.NetMode == NM_Standalone) && PlayerPawn(PlayerPawn).TeleportTravel )
	{
		// Adjust all traveled actors.
		foreach AllActors( class'Actor', A )
		{
			if ( A.bWillTravel )
			{
				A.bWillTravel = false;
				A.SetRotation( A.TravelRotation );
				A.SetLocation( PlayerPawn.Location + A.TravelLocation );
			}
		}

		// Adjust the player.
		PlayerPawn.SetLocation( PlayerPawn.Location + PlayerPawn(PlayerPawn).TravelLocation );
		PlayerPawn.SetRotation( PlayerPawn(PlayerPawn).TravelRotation );
		PlayerPawn.ViewRotation = PlayerPawn(PlayerPawn).TravelViewRotation;
		PlayerPawn(PlayerPawn).TeleportTravel = false;
	}
}

// Spawn any default inventory for the player.
function AddDefaultInventory( pawn P )
{
	local Weapon newWeapon;
	local class<Weapon> WeapClass;

	P.JumpZ = P.Default.JumpZ * PlayerJumpZScaling();
	 
	if ( P.IsSpectating() )
		return;

	// Spawn default weapon.
	GiveWeaponTo( P, BaseMutator.MutatedDefaultWeapon() );

	// Ask the mutator to modify the player.
	BaseMutator.ModifyPlayer( P );
}

function GiveWeaponTo( pawn InventoryPawn, class<Weapon> WeapClass, optional bool bDontSwitch )
{
	local Weapon newWeapon;
	local Inventory Inv;

	// Check to see if we already have that weapon.
	Inv = InventoryPawn.FindInventoryType( WeapClass );
	if ( Inv != None )
		return;

	// Add the weapon to the player's inventory list.
	newWeapon = Spawn( WeapClass );
	if( newWeapon != None )
	{
		newWeapon.GiveTo( InventoryPawn );
		if ( !bDontSwitch )
			InventoryPawn.ChangeToWeapon( newWeapon );
	}
}

//
// Return the 'best' player start for this player to start from.
// Re-implement for each game type.
//
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest;
	local Teleporter Tel;
	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;
	foreach AllActors( class 'PlayerStart', Dest )
		if( Dest.bSinglePlayerStart && Dest.bEnabled )
			return Dest;

	// if none, check for any that aren't enabled
	log("WARNING: All single player starts were disabled - picking one anyway!");
	foreach AllActors( class 'PlayerStart', Dest )
		if( Dest.bSinglePlayerStart )
			return Dest;
	log( "No single player start found" );
	return None;
}

//
// Restart a player.
//
function bool RestartPlayer( pawn aPlayer )	
{
	local NavigationPoint	startSpot;
	local bool				foundStart;

	//Log( "GameInfo::RestartPlayer" );

	if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		return true;

	startSpot = FindPlayerStart(aPlayer, 255);
	if( startSpot == None )
	{
		log(" Player start not found!!!");
		return false;
	}	
	
	foundStart = aPlayer.SetLocation(startSpot.Location);
	if( foundStart )
	{
		startSpot.PlayTeleportEffect(aPlayer, true);
		
		aPlayer.SetRotation(startSpot.Rotation);
		aPlayer.ViewRotation	= aPlayer.Rotation;
		aPlayer.Acceleration	= vect(0,0,0);
		aPlayer.Velocity		= vect(0,0,0);
		aPlayer.Health			= aPlayer.Default.Health;
		aPlayer.SetCollision( true, true, true );
		aPlayer.ClientSetLocation( startSpot.Location, startSpot.Rotation );
		aPlayer.bHidden			= false;
		aPlayer.DamageScaling	= aPlayer.Default.DamageScaling;
		aPlayer.SoundDampening	= aPlayer.Default.SoundDampening;

		AddDefaultInventory(aPlayer);
	}
	else
	{
		log(startspot$" Player start not useable!!!");
	}

	return foundStart;
}

//
// Start a player.
//
function StartPlayer(PlayerPawn Other)
{
	if( Level.NetMode == NM_DedicatedServer || 
		Level.NetMode == NM_ListenServer    ||
		!bRestartLevel )
	{
		Other.SetControlState( Other.PlayerRestartState );
	}
	else
	{
		Other.ClientTravel( "?restart", TRAVEL_Relative, false );
	}
}

//------------------------------------------------------------------------------
// Level death message functions.

function Killed( pawn Killer, pawn Victim, class<DamageType> DamageType )
{
	ScoreKill( Killer, Victim );
}

function BroadcastRegularDeathMessage( pawn Killer, pawn Victim, class<DamageType> DamageType )
{
	local PlayerReplicationInfo KillerPRI, VictimPRI;
	local class<Weapon> KillerWepClass;

	if ( Killer != None )
	{
		KillerPRI = Killer.PlayerReplicationInfo;
		if ( Killer.Weapon != None )
			KillerWepClass = Killer.Weapon.Class;
	}
	if ( Victim != None )
		VictimPRI = Victim.PlayerReplicationInfo;

	BroadcastLocalizedMessage( DeathMessageClass, 0, KillerPRI, VictimPRI, KillerWepClass, DamageType );
}

// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %w = Owner's Weapon ItemName
static native function string ParseKillMessage( string KillerName, string VictimName, string WeaponName, string DeathMessage );

function ScoreKill(pawn Killer, pawn Victim)
{
	if( (killer == Victim) || (killer == None) )
	{
		Victim.PlayerReplicationInfo.Score -= 1;
	}
	else if ( killer != None )
	{
		if ( killer.PlayerReplicationInfo != None )
		{
			killer.PlayerReplicationInfo.Score += 1;
		}
	}

	BaseMutator.ScoreKill(Killer, Victim);
}

//
// Default death message.
//
static function string KillMessage( class<DamageType> DamageType, Pawn Victim )
{
	return " died.";
}

//-------------------------------------------------------------------------------------
// Level gameplay modification.

//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return true;
}

function RegisterDamageMutator(Mutator M)
{
	M.NextDamageMutator = DamageMutator;
	DamageMutator = M;
}

//
// Use reduce damage for teamplay modifications, etc.
//
function int ReduceDamage( int Damage, class<DamageType> DamageType, Pawn Injured, Pawn InstigatedBy )
{
	if ( Injured.Region.Zone.bNeutralZone )
		return 0;	
	return Damage;
}

//
// Award a score to an actor.
//
function ScoreEvent( name EventName, actor EventActor, pawn InstigatedBy )
{
}

//
// Return whether an item should respawn.
//
function bool ShouldRespawn( actor Other )
{
	if( Level.NetMode == NM_StandAlone )
		return false;
	return Inventory(Other)!=None && Inventory(Other).ReSpawnTime!=0.0;
}

//
// Called when pawn has a chance to pick Item up (i.e. when 
// the pawn touches a weapon pickup). Should return true if 
// he wants to pick it up, false if he does not want it.
//
function bool PickupQuery( Pawn Other, Inventory item )
{
	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery( Item );
}
		
//
// Discard a player's inventory after he dies.
//
function DiscardInventory( Pawn Other )
{
	local actor dropped;
	local inventory Inv;
	local weapon weap;
	local float speed;

	if( Other.DropWhenKilled != None )
	{
		dropped = Spawn(Other.DropWhenKilled,,,Other.Location);
		Inv = Inventory(dropped);
		if ( Inv != None )
		{ 
			Inv.RespawnTime = 0.0; //don't respawn
			Inv.BecomePickup();		
		}
		if ( dropped != None )
		{
			dropped.RemoteRole = ROLE_DumbProxy;
			dropped.SetPhysics(PHYS_Falling);
			dropped.bCollideWorld = true;
			dropped.Velocity = Other.Velocity + VRand() * 280;
		}
		if ( Inv != None )
			Inv.GotoState('PickUp', 'Dropped');
	}					
	if( (Other.Weapon!=None) && (Other.Weapon.Class!=Level.Game.BaseMutator.MutatedDefaultWeapon()) 
		&& Other.Weapon.bCanThrow )
	{
		speed = VSize(Other.Velocity);
		weap = Other.Weapon;
		if (speed != 0)
			weap.Velocity = Normal(Other.Velocity/speed + 0.5 * VRand()) * (speed + 280);
		else {
			weap.Velocity.X = 0;
			weap.Velocity.Y = 0;
			weap.Velocity.Z = 0;
		}
		Other.TossWeapon();
		if ( weap.PickupAmmoCount[0] == 0 )
			weap.PickupAmmoCount[0] = 1;
	}
	Other.Weapon = None;
	Other.SelectedItem = None;	
	for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory )
		Inv.Destroy();
}

// Return the player jumpZ scaling for this gametype
function float PlayerJumpZScaling()
{
	return 1.0;
}

//
// Try to change a player's name.
//	
function ChangeName( Pawn Other, coerce string S, bool bNameChange )
{
	if( S == "" )
		return;

	Other.PlayerReplicationInfo.PlayerName = S;
	if( bNameChange )
		Other.ClientMessage( NameChangedMessage $ Other.PlayerReplicationInfo.PlayerName );
}

//
// Return whether a team change is allowed.
//
function bool ChangeTeam(Pawn Other, int N)
{
	Other.PlayerReplicationInfo.Team = N;
	return true;
}

//
// Play an inventory respawn effect.
//
function float PlaySpawnEffect( inventory Inv )
{
	return 0.3;
}

//
// Send a player to a URL.
//
function SendPlayer( PlayerPawn aPlayer, string URL )
{
	aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
}

//
// Play a teleporting special effect.
//
function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound);

//
// Restart the game.
//
function RestartGame()
{
	Level.ServerTravel( "?Restart", false );
}

//
// Whether players are allowed to broadcast messages now.
//
function bool AllowsBroadcast( actor broadcaster, int Len )
{
	return true;
//	SentText += Len;

//	return (SentText < 260);
}

function bool AllowsPrivateMessage( actor sender, int Len )
{
	return true;
}

//
// End of game.
//
function EndGame( string Reason )
{
	local actor A;

	// don't end game if not really ready
	if ( !SetEndCams(Reason) )
	{
		bOverTime = true;
		return;
	}
	bGameEnded = true;
	foreach AllActors(class'Actor', A, 'EndGame')
		A.trigger(self, none);
}

function bool SetEndCams(string Reason)
{
	local pawn aPawn;

	for ( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
	{
		if ( aPawn.bIsPlayer )
		{
			aPawn.SetControlState(CS_Stasis);
			aPawn.ClientGameEnded();
		}	
	}

	return true;
}

// Creature names
function string GetRandomName()
{
	local int i, used;

	if ( RandomNameIndex == -1 )
		RandomNameIndex = Rand(32);

	RandomNameIndex++;
	if ( RandomNameIndex > 31 )
		RandomNameIndex = 0;

	return RandomNames[RandomNameIndex];
}

function bool MatchStarted()
{
	return true;
}

event PlayerPawn LoginNewClass
(
	PlayerPawn				OldPlayer,
	class<PlayerPawn>		SpawnClass,
	out string				Error
)
{
	local NavigationPoint StartSpot;
	local PlayerPawn      NewPlayer;
	
	Log( "PlayerPawn::LoginNewClass" );
	Log( "PlayerPawn::LoginNewClass : Finding StartSpot for Team:"@ OldPlayer.PlayerReplicationInfo.Team );

	// Find a start spot.
	StartSpot = FindPlayerStart( None, OldPlayer.PlayerReplicationInfo.Team );

	if( StartSpot == None )
	{
		Error = FailedPlaceMessage;
		return None;
	}

	Log( "PlayerPawn::LoginNewClass : Spawning new Player" );

	// Spawn the new player
	NewPlayer = Spawn( SpawnClass, , , StartSpot.Location, StartSpot.Rotation );

	if ( NewPlayer != None )
	{
		NewPlayer.bCollideWorld			= true;
		NewPlayer.ViewRotation			= StartSpot.Rotation;
		
		// Spawning a new player creates a PRI.  Destroy it and assign the old one to the new player.
		if ( NewPlayer.PlayerReplicationInfo != None )
		{
			Log( "PlayerPawn::LoginNewClass : Deleting NEW PRI" );
			NewPlayer.PlayerReplicationInfo.Destroy();
		}

		Log( "PlayerPawn::LoginNewClass : Assigning OLD PRI" );
		NewPlayer.PlayerReplicationInfo = OldPlayer.PlayerReplicationInfo;
		NewPlayer.PlayerReplicationInfo.SetOwner( NewPlayer );
		
		// Clear out some stuff for the old player, we don't really want him to completely logout
		OldPlayer.PlayerReplicationInfo = None;
		OldPlayer.bNoLogout = true;
	}
	else
	{
		// Handle spawn failure.
		Log( "Couldn't spawn player at "$StartSpot );
		Error = FailedSpawnMessage;
		return None;
	}
	
	// Change Mesh and Skin to the class's specified mesh
	//NewPlayer.SetDefaultMeshAndSkin();

	// Setup the player's voice
	//NewPlayer.SetDefaultVoice();

	// Init player's information.
	NewPlayer.ClientSetRotation( NewPlayer.Rotation );
	
	// Init player's replication info
	Log( "PlayerPawn::LoginNewClass : Assigning GRI" );
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// If we are a server, broadcast a class change message
	/*
	if ( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
	{
		BroadcastMessage( NewPlayer.PlayerReplicationInfo.PlayerName @ "Changed to class:" $ SpawnClass );
	}
	*/

	Log( "PlayerPawn::LoginNewClass : Teleporting In" );
	// Teleport-in effect.
	if ( !NewPlayer.IsSpectating() )
		StartSpot.PlayTeleportEffect( NewPlayer, true );
	else
		NewPlayer.EnterWaiting();

	return newPlayer;
}

function bool CanChangeClass( PlayerPawn P, string NewClass )
{
	return false;
}

function string GetClassNameForString( string NewClassName )
{
	return "";
}

function class<PlayerPawn> GetClassForString( string newClassName )
{
	return None;
}

function int GetCreditCostForString( string NewClassName )
{
	return 0;
}

function class<playerpawn> GetOverridePlayerClass( int InTeam )
{
	return None;
}

function string GetOverridePlayerClassName( int InTeam )
{
	return "";
}

defaultproperties
{
	bCanChangeClass=false
	bNoCheating=true
	MaxPlayers=16
    Difficulty=1
    bRestartLevel=true
    bPauseable=true
    bCanChangeSkin=true
	bCanViewOthers=true
	bRespawnMarkers=true
    AutoAim=0.930000
    GameSpeed=1.000000
    MaxSpectators=2
    DefaultPlayerName="Player"
    LeftMessage=" left the game."
    FailedSpawnMessage="Failed to spawn player actor"
    FailedPlaceMessage="Could not find starting spot (level might need a 'PlayerStart' actor)"
    MaxedOutMessage="Server is already at capacity."
    NameChangedMessage="Name changed to "
    EnteredMessage=" entered the game."
	EnteredSpectatorMessage=" entered the game as a spectator."
	WrongPassword="The password you entered is incorrect."
	NeedPassword="You need to enter a password to join this game."
	FailedTeamMessage="Could not find team for player"
	GameName="Game"
    RulesMenuType="dnWindow.UDukeMultiRulesSC"
    BotMenuType="dnWindow.UDukeBotSettingsSC"
    ServerMenuType="dnWindow.UDukeServerSettingsSC"
    MapMenuType="dnWindow.dnMapListSC"
	MutatorMenuType="dnWindow.dnMutatorListSC"
    ServerLogName="server.log"
	MutatorClass=class'Engine.Mutator'
	DeathMessageClass=class'LocalMessage'
	IPBanned="Your IP address has been banned on this server."
	IPPolicies(0)="ACCEPT,*"
	bMeshAccurateHits=true
	RandomNames(0)="Harry"
	RandomNames(1)="Bob"
	RandomNames(2)="John"
	RandomNames(3)="Micky"
	RandomNames(4)="Jimmy"
	RandomNames(5)="Tim"
	RandomNames(6)="Keith"
	RandomNames(7)="Stephen"
	RandomNames(8)="Nick"
	RandomNames(9)="Jess"
	RandomNames(10)="Brandon"
	RandomNames(11)="George"
	RandomNames(12)="Scott"
	RandomNames(13)="Matt"
	RandomNames(14)="Ruben"
	RandomNames(15)="Allen"
	RandomNames(16)="Lee"
	RandomNames(17)="Joe"
	RandomNames(18)="Brian"
	RandomNames(19)="Bryan"
	RandomNames(20)="Steven"
	RandomNames(21)="Paul"
	RandomNames(22)="Jimbo"
	RandomNames(23)="Frank"
	RandomNames(24)="Pancho"
	RandomNames(25)="David"
	RandomNames(26)="Cliff"
	RandomNames(27)="Alan"
	RandomNames(28)="Jose"
	RandomNames(29)="Marcus"
	RandomNames(30)="Albert"
	RandomNames(31)="Ron"
	RandomNameIndex=-1
	bStartMatch=true
	FallingDamageScale=1.0
	bPlayStinger=true
	bSearchBodies=true
	bOverridePlayerClass=false
	bShowScores=false
	bValidateSkins=false
}
