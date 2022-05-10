//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
	native nativereplication;

var string	GameName;						// Assigned by GameInfo.
var string	GameClass;						// Assigned by GameInfo.
var bool	bTeamGame;						// Assigned by GameInfo.
var bool	bStopCountDown;
var bool	bMeshAccurateHits;				// Indicates whether the game allows mesh accurate hits or not.
var bool    bPlayDeathSequence;				// Assigned by GameInfo.
var bool    bShowScores;					// Assigned by GameInfo.
var int		RemainingTime;
var int     ElapsedTime;
var int		RemainingMinute;
var float	SecondCount;
var int		NumPlayers;
var int		NumSpectators;
var float	UpdateTimer;

var() globalconfig string ServerName;		// Name of the server, i.e.: Bob's Server.
var() globalconfig string ShortName;		// Abbreviated name of server, i.e.: B's Serv (stupid example)
var() globalconfig string AdminName;		// Name of the server admin.
var() globalconfig string AdminEmail;		// Email address of the server admin.
var() globalconfig int 		 Region;		// Region of the game server.

var() globalconfig string MOTDLine1;		// Message
var() globalconfig string MOTDLine2;		// Of
var() globalconfig string MOTDLine3;		// The
var() globalconfig string MOTDLine4;		// Day

var string GameEndedComments;				// set by gameinfo when game ends

var PlayerReplicationInfo PRIArray[32];

replication
{
	reliable if ( Role == ROLE_Authority )
		GameName, GameClass, bTeamGame, ServerName, ShortName, AdminName,
		AdminEmail, Region, MOTDLine1, MOTDLine2, 
		MOTDLine3, MOTDLine4, RemainingMinute, bStopCountDown, GameEndedComments,
		NumPlayers, NumSpectators;

	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		RemainingTime, ElapsedTime, bMeshAccurateHits, bPlayDeathSequence, bShowScores;
}

simulated function PostBeginPlay()
{
    if( Level.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank 
		ServerName = "";
		AdminName = "";
		AdminEmail = "";
		MOTDLine1 = "";
		MOTDLine2 = "";
		MOTDLine3 = "";
		MOTDLine4 = "";
	}

	SecondCount = Level.TimeSeconds;
	SetTimer(0.2, true);
}

simulated function Timer(optional int TimerNum)
{
	local PlayerReplicationInfo PRI;
	local int i, FragAcc;

	if ( Level.NetMode == NM_Client )
	{
		if (Level.TimeSeconds - SecondCount >= Level.TimeDilation)
		{
			ElapsedTime++;
			if ( RemainingMinute != 0 )
			{
				RemainingTime = RemainingMinute;
				RemainingMinute = 0;
			}
			if ( (RemainingTime > 0) && !bStopCountDown )
				RemainingTime--;
			SecondCount += Level.TimeDilation;
		}
	}

	for ( i=0; i<32; i++ )
		PRIArray[i] = None;

	i=0;
	foreach AllActors( class'PlayerReplicationInfo', PRI )
	{
		PRIArray[i++] = PRI;
	}

	if ( Level.Game != None )
	{
		NumPlayers	  = Level.Game.NumPlayers;
		NumSpectators = Level.Game.NumSpectators;
	}
}

defaultproperties
{
	bStopCountDown=true
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	ServerName="Another UT Demo Server"
	ShortName="UT Server"
	MOTDLine1=""
	MOTDLine2=""
	MOTDLine3=""
	MOTDLine4=""
    NetUpdateFrequency=4
}
