//=============================================================================
// TeamGamePlus.
//=============================================================================
class TeamGamePlus extends DeathMatchPlus
	config;

#exec MESH IMPORT MESH=Flag1M ANIVFILE=MODELS\flag_a.3D DATAFILE=MODELS\flag_d.3D X=0 Y=0 Z=0 ZeroTex=1
#exec MESH ORIGIN MESH=Flag1M X=0 Y=100 Z=0 YAW=128 PITCH=0 ROLL=-64
#exec MESH SEQUENCE MESH=flag1M SEQ=All    STARTFRAME=0  NUMFRAMES=14
#exec MESH SEQUENCE MESH=flag1M SEQ=Wave  STARTFRAME=1  NUMFRAMES=13
#exec TEXTURE IMPORT NAME=JFlag11 FILE=MODELS\flag_red.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=JFlag12 FILE=MODELS\flag_blue.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=JFlag13 FILE=MODELS\flag_green.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=JFlag14 FILE=MODELS\flag_yellow.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=JFlag15 FILE=MODELS\flag3.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=flag1M X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=flag1M NUM=0 TEXTURE=Jflag11
	
var()		 bool   bSpawnInTeamArea;
var()		 bool	bScoreTeamKills;
var() config bool	bNoTeamChanges;
var			 int	NumSupportingPlayer; 
var globalconfig	 bool	bBalanceTeams;	// bots balance teams
var globalconfig	 bool	bPlayersBalanceTeams;	// players balance teams
var			 bool	bBalancing;
var() config float  FriendlyFireScale; //scale friendly fire damage by this value
var() config int	MaxTeams; //Maximum number of teams allowed in (up to MaxAllowedTeams)
var			 int	MaxAllowedTeams;
var	TeamInfo Teams[4]; // Red, Blue, Green, Gold
var() config float  GoalTeamScore; //like fraglimit
var() config int	MaxTeamSize;
var  localized string StartUpTeamMessage, TeamChangeMessage,TeamPrefix;
var localized string TeamColor[4];

var		int			NextBotTeam;
var byte TEAM_Red, TEAM_Blue, TEAM_Green, TEAM_Gold;
var name CurrentOrders[4];
var int PlayerTeamNum;

function PostBeginPlay()
{
	local int i;
	for (i=0;i<4;i++)
	{
		Teams[i] = Spawn(class'TeamInfo');
		Teams[i].Size = 0;
		Teams[i].Score = 0;
		Teams[i].TeamName = TeamColor[i];
		Teams[i].TeamIndex = i;
		TournamentGameReplicationInfo(GameReplicationInfo).Teams[i] = Teams[i];
	}
	
	Super.PostBeginPlay();

	if ( bRatedGame )
	{
		FriendlyFireScale = 0;
		MaxTeams = 2;
	}
}

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
	MaxTeams = Min(MaxTeams,MaxAllowedTeams);
}

function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();

	TournamentGameReplicationInfo(GameReplicationInfo).GoalTeamScore = GoalTeamScore;
}

// Set game settings based on ladder information.
// Called when RatedPlayer logs in.
function InitRatedGame(LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
	local class<RatedMatchInfo> RMI;
	local Weapon W;

	GoalTeamScore = LadderObj.CurrentLadder.Default.GoalTeamScore[IDnum];
	Super.InitRatedGame(LadderObj, LadderPlayer);	
	bCoopWeaponMode = true;
	FriendlyFireScale = 0.0;
	MaxTeams = 2;
	ForEach AllActors(class'Weapon', W)
		W.SetWeaponStay();
}

function CheckReady()
{
	if ( (TimeLimit == 0) && (GoalTeamScore == 0) )
	{
		TimeLimit = 20;
		RemainingTime = 60 * TimeLimit;
	}
}

event PostLogin( playerpawn NewPlayer )
{
	Super.PostLogin(NewPlayer);

	if ( Level.NetMode != NM_Standalone )
		NewPlayer.ClientChangeTeam(NewPlayer.PlayerReplicationInfo.Team);
}

function LogGameParameters(StatLog StatLog)
{
	if (StatLog == None)
		return;
	
	Super.LogGameParameters(StatLog);

	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GoalTeamScore"$Chr(9)$int(GoalTeamScore));
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"FriendlyFireScale"$Chr(9)$FriendlyFireScale);
}

function bool SetEndCams(string Reason)
{
	local TeamInfo BestTeam;
	local int i;
	local pawn P, Best;
	local PlayerPawn player;

	// find individual winner
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.bIsPlayer && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
			Best = P;

	// find winner
	BestTeam = Teams[0];
	for ( i=1; i<MaxTeams; i++ )
		if ( Teams[i].Score > BestTeam.Score )
			BestTeam = Teams[i];

	for ( i=0; i<MaxTeams; i++ )
		if ( (BestTeam.TeamIndex != i) && (BestTeam.Score == Teams[i].Score) )
		{
			BroadcastLocalizedMessage( class'DeathMatchMessage', 0 );
			return false;
		}		

	GameReplicationInfo.GameEndedComments = TeamPrefix@BestTeam.TeamName@GameEndedMessage;

	EndTime = Level.TimeSeconds + 3.0;
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		player = PlayerPawn(P);
		if ( Player != None )
		{
			if (!bTutorialGame)
				PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == BestTeam.TeamIndex));
			player.bBehindView = true;
			if ( Player == Best )
				Player.ViewTarget = None;
			else
				Player.ViewTarget = Best;
			player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	CalcEndStats();
	return true;
}

//------------------------------------------------------------------------------
// Player start functions

function PlayStartUpMessage(PlayerPawn NewPlayer)
{
	local int i;
	local color WhiteColor;

	NewPlayer.ClearProgressMessages();

	// GameName
	NewPlayer.SetProgressMessage(GameName, i++);
	if ( bRequireReady && (Level.NetMode != NM_Standalone) )
		NewPlayer.SetProgressMessage(TourneyMessage, i++);
	else
		NewPlayer.SetProgressMessage(StartUpMessage, i++);

	if ( GoalTeamScore > 0 )
		NewPlayer.SetProgressMessage(int(GoalTeamScore)@GameGoal, i++);

	if ( NewPlayer.PlayerReplicationInfo.Team < 4 )
	{
		NewPlayer.SetProgressColor(class'ChallengeTeamHUD'.Default.TeamColor[NewPlayer.PlayerReplicationInfo.Team], i);
		NewPlayer.SetProgressMessage(StartupTeamMessage@Teams[NewPlayer.PlayerReplicationInfo.Team].TeamName$".", i++);
		WhiteColor.R = 255;
		WhiteColor.G = 255;
		WhiteColor.B = 255;
		NewPlayer.SetProgressColor(WhiteColor, i);
		if ( !bRatedGame )
			NewPlayer.SetProgressMessage(TeamChangeMessage, i++);
	}

	if ( Level.NetMode == NM_Standalone )
		NewPlayer.SetProgressMessage(SingleWaitingMessage, i++);
}

function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn newPlayer;
	local NavigationPoint StartSpot;

	newPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	if ( newPlayer == None)
		return None;

	if ( bSpawnInTeamArea )
	{
		StartSpot = FindPlayerStart(NewPlayer,255, Portal);
		if ( StartSpot != None )
		{
			NewPlayer.SetLocation(StartSpot.Location);
			NewPlayer.SetRotation(StartSpot.Rotation);
			NewPlayer.ViewRotation = StartSpot.Rotation;
			NewPlayer.ClientSetRotation(NewPlayer.Rotation);
			StartSpot.PlayTeleportEffect( NewPlayer, true );
		}
	}
	PlayerTeamNum = NewPlayer.PlayerReplicationInfo.Team;
		
	return newPlayer;
}

function Logout(pawn Exiting)
{
	Super.Logout(Exiting);
	if ( Exiting.IsA('Spectator') || Exiting.IsA('Commander') )
		return;
    Teams[Exiting.PlayerReplicationInfo.Team].Size--;
	ClearOrders(Exiting);
	if ( !bGameEnded && bBalanceTeams && !bRatedGame )
		ReBalance();
}

// Find a team given its name
function byte FindTeamByName( string TeamName )
{
	local byte i;

	for ( i=0; i<MaxTeams; i++ )
		if ( Teams[i].TeamName == TeamName )
			return i;

	return 255; // No Team
}

// rebalance teams after player changes teams or leaves
// find biggest and smallest teams.  If 2 apart, move bot from biggest to smallest

function ReBalance()
{
	local int big, small, i, bigsize, smallsize;
	local Pawn P, A;
	local Bot B;

	if ( bBalancing || (NumBots == 0) )
		return;

	big = 0;
	small = 0;
	bigsize = Teams[0].Size;
	smallsize = Teams[0].Size;
	for ( i=1; i<MaxTeams; i++ )
	{
		if ( Teams[i].Size > bigsize )
		{
			big = i;
			bigsize = Teams[i].Size;
		}
		else if ( Teams[i].Size < smallsize )
		{
			small = i;
			smallsize = Teams[i].Size;
		}
	}
	
	bBalancing = true;
	while ( bigsize - smallsize > 1 )
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == big)
				&& P.IsA('Bot') )
			{
				B = Bot(P);
				break;
			}
		if ( B != None )
		{
			B.Health = 0;
			B.Died( None, 'Suicided', B.Location );
			bigsize--;
			smallsize++;
			ChangeTeam(B, small);
		}
		else
			Break;
	}
	bBalancing = false;

	// re-assign orders to follower bots with no leaders
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.bIsPlayer && P.IsA('Bot') && (BotReplicationInfo(P.PlayerReplicationInfo).RealOrders == 'Follow') )
		{
			A = Pawn(Bot(P).OrderObject);
			if ( (A == None) || A.bDeleteMe || !A.bIsPlayer || (A.PlayerReplicationInfo.Team != P.PlayerReplicationInfo.Team) )
			{
				Bot(P).OrderObject = None;
				SetBotOrders(Bot(P));
			}
		}

}
	
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest, Candidate[16], Best;
	local float Score[16], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N;
	local byte Team;

	if ( bStartMatch && (Player != None) && Player.IsA('TournamentPlayer') 
		&& (Level.NetMode == NM_Standalone)
		&& (TournamentPlayer(Player).StartSpot != None) )
		return TournamentPlayer(Player).StartSpot;

	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
		Team = Player.PlayerReplicationInfo.Team;
	else
		Team = InTeam;

	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;

	if ( Team == 255 )
		Team = 0;
				
	//choose candidates	
	for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
	{
		Dest = PlayerStart(N);
		if ( (Dest != None) && Dest.bEnabled
			&& (!bSpawnInTeamArea || (Team == Dest.TeamNumber)) )
		{
			if (num<16)
				Candidate[num] = Dest;
			else if (Rand(num) < 16)
				Candidate[Rand(16)] = Dest;
			num++;
		}
	}

	if (num == 0 )
	{
		log("Didn't find any player starts in list for team"@Team@"!!!"); 
		foreach AllActors( class'PlayerStart', Dest )
		{
			if (num<16)
				Candidate[num] = Dest;
			else if (Rand(num) < 16)
				Candidate[Rand(16)] = Dest;
			num++;
		}
		if ( num == 0 )
			return None;
	}

	if (num>16) 
		num = 16;
	
	//assess candidates
	for (i=0;i<num;i++)
	{
		if ( Candidate[i] == LastStartSpot )
			Score[i] = -6000.0;
		else
			Score[i] = 4000 * FRand(); //randomize
	}		
	
	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)	
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) && !OtherPlayer.IsA('Spectator') )
			for (i=0; i<num; i++)
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone ) 
				{
					Score[i] -= 1500;
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if (NextDist < 2 * (CollisionRadius + CollisionHeight))
						Score[i] -= 1000000.0;
					else if ( (NextDist < 2000) && (OtherPlayer.PlayerReplicationInfo.Team != Team)
							&& FastTrace(Candidate[i].Location, OtherPlayer.Location) )
						Score[i] -= (10000.0 - NextDist);
				}
	
	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1; i<num; i++)
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	LastStartSpot = Best;
				
	return Best;
}

//-------------------------------------------------------------------------------------
// Level gameplay modification

//Use reduce damage for teamplay modifications, etc.
function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	Damage = Super.ReduceDamage(Damage, DamageType, injured, instigatedBy);
	
	if ( instigatedBy == None )
		return Damage;

	if ( (instigatedBy != injured) && injured.bIsPlayer && instigatedBy.bIsPlayer 
		&& (injured.PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team) )
	{
		if ( injured.IsA('Bot') )
			Bot(Injured).YellAt(instigatedBy);
		return (Damage * FriendlyFireScale);
	}
	else
		return Damage;
}

function ScoreKill(pawn Killer, pawn Other)
{
	if ( (Killer == None) || (Killer == Other) || !Other.bIsPlayer || !Killer.bIsPlayer 
		|| (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
		Super.ScoreKill(Killer, Other);

	if ( !bScoreTeamKills )
		return;
	if ( Other.bIsPlayer && ((Killer == None) || Killer.bIsPlayer) )
	{
		if ( (Killer == Other) || (Killer == None) )
			Teams[Other.PlayerReplicationInfo.Team].Score -= 1;
		else if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
			Teams[Killer.PlayerReplicationInfo.Team].Score += 1;
		else if ( FriendlyFireScale > 0 )
		{
			Teams[Other.PlayerReplicationInfo.Team].Score -= 1;
			Killer.PlayerReplicationInfo.Score -= 1;
		}
	}

	if ( (bOverTime || (GoalTeamScore > 0)) && Killer.bIsPlayer
		&& (Teams[killer.PlayerReplicationInfo.Team].Score >= GoalTeamScore) )
		EndGame("teamscorelimit");
}

function bool ChangeTeam(Pawn Other, int NewTeam)
{
	local int i, s, DesiredTeam;
	local pawn APlayer, P;
	local teaminfo SmallestTeam;

	if ( bRatedGame && (Other.PlayerReplicationInfo.Team != 255) )
		return false;

	for( i=0; i<MaxTeams; i++ )
		if ( (Teams[i].Size < MaxTeamSize) 
				&& ((SmallestTeam == None) || (SmallestTeam.Size > Teams[i].Size)) )
		{
			s = i;
			SmallestTeam = Teams[i];
		}

	if ( bPlayersBalanceTeams && (Level.NetMode != NM_Standalone) )
	{
		if ( NumBots == 1 )
		{
			// join bot's team, because he will leave
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('Bot') )
					break;
			
			if ( (P != None) && (P.PlayerReplicationInfo != None)
				&& (Teams[P.PlayerReplicationInfo.Team].Size == SmallestTeam.Size) )
			{					
				Other.PlayerReplicationInfo.Team = 255;
				NewTeam = P.PlayerReplicationInfo.Team;
			}
			else if ( (NewTeam >= MaxTeams) 
				|| (Teams[NewTeam].Size > SmallestTeam.Size) )
			{	
				Other.PlayerReplicationInfo.Team = 255;
				NewTeam = 255;
			}
		}
		else if ( (NewTeam >= MaxTeams) 
			|| (Teams[NewTeam].Size > SmallestTeam.Size) )
		{	
			Other.PlayerReplicationInfo.Team = 255;
			NewTeam = 255;
		}
	}

	if ( (NewTeam == 255) || (NewTeam >= MaxTeams) )
		NewTeam = s;

	if ( Other.IsA('Spectator') )
	{
		Other.PlayerReplicationInfo.Team = 255;
		if (LocalLog != None)
			LocalLog.LogTeamChange(Other);
		if (WorldLog != None)
			WorldLog.LogTeamChange(Other);
		return true;
	}
	if ( Other.IsA('Commander') )
	{
		Other.PlayerReplicationInfo.Team = NewTeam;
		if (LocalLog != None)
			LocalLog.LogTeamChange(Other);
		if (WorldLog != None)
			WorldLog.LogTeamChange(Other);
		return true;
	}
	if ( (Other.PlayerReplicationInfo.Team == NewTeam) && bNoTeamChanges )
		return false;

	if ( Other.IsA('TournamentPlayer') )
		TournamentPlayer(Other).StartSpot = None;

	if ( Other.PlayerReplicationInfo.Team != 255 )
	{
		ClearOrders(Other);
		Teams[Other.PlayerReplicationInfo.Team].Size--;
	}

	if (Teams[NewTeam].Size < MaxTeamSize)
	{
		AddToTeam(NewTeam, Other);
		return true;
	}

	if ( (SmallestTeam != None) && (SmallestTeam.Size < MaxTeamSize) )
	{
		AddToTeam(s, Other);
		return true;
	}

	return false;
}

function AddToTeam( int num, Pawn Other )
{
	local teaminfo aTeam;
	local Pawn P;
	local bool bSuccess;
	local string SkinName, FaceName;

	if ( Other == None )
	{
		log("Added none to team!!!");
		return;
	}

	aTeam = Teams[num];

	aTeam.Size++;
	Other.PlayerReplicationInfo.Team = num;
	Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;
	if (LocalLog != None)
		LocalLog.LogTeamChange(Other);
	if (WorldLog != None)
		WorldLog.LogTeamChange(Other);
	bSuccess = false;
	if ( Other.IsA('PlayerPawn') )
	{
		Other.PlayerReplicationInfo.TeamID = 0;
		PlayerPawn(Other).ClientChangeTeam(Other.PlayerReplicationInfo.Team);
	}
	else
		Other.PlayerReplicationInfo.TeamID = 1;

	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
            if ( P.bIsPlayer && (P != Other) 
				&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) 
				&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
				bSuccess = false;
		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID++;
	}

	BroadcastLocalizedMessage( class'DeathMatchMessage', 3, Other.PlayerReplicationInfo, None, aTeam );

	Other.static.GetMultiSkin(Other, SkinName, FaceName);
	Other.static.SetMultiSkin(Other, SkinName, FaceName, num);

	if ( bBalanceTeams && !bRatedGame )
		ReBalance();
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	if ( ViewTarget.bIsPawn && (Pawn(ViewTarget).PlayerReplicationInfo != None)
		&& Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator )
		return false;
	if ( Viewer.PlayerReplicationInfo.bIsSpectator && (Viewer.PlayerReplicationInfo.Team == 255) )
		return true;
	return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).bIsPlayer 
		&& (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
}

function TeamInfo GetTeam(int TeamNum )
{
	if ( TeamNum < ArrayCount(Teams) )
		return Teams[TeamNum];
	else return None;
}

function bool IsOnTeam(Pawn Other, int TeamNum)
{
	if ( Other.PlayerReplicationInfo.Team == TeamNum )
		return true;

	return false;
}

function bool AddBot()
{
	local bot NewBot;
	local NavigationPoint StartSpot, OldStartSpot;
	local int DesiredTeam, i, MinSize;

	NewBot = SpawnBot(StartSpot);
	if ( NewBot == None )
	{
		log("Failed to spawn bot");
		return false;
	}

	if ( bBalanceTeams && !bRatedGame )
	{
		MinSize = Teams[0].Size;
		DesiredTeam = 0;
		for ( i=1; i<MaxTeams; i++ )
			if ( Teams[i].Size < MinSize )
			{
				MinSize = Teams[i].Size;
				DesiredTeam = i;
			}	
	}
	else
		DesiredTeam = NewBot.PlayerReplicationInfo.Team;
	NewBot.PlayerReplicationInfo.Team = 255;
	if ( (DesiredTeam == 255) || !ChangeTeam(NewBot, DesiredTeam) )
	{
		ChangeTeam(NewBot, NextBotTeam);
		NextBotTeam++;
		if ( NextBotTeam >= MaxTeams )
			NextBotTeam = 0;
	}

	if ( bSpawnInTeamArea )
	{
		OldStartSpot = StartSpot;
		StartSpot = FindPlayerStart(NewBot,255);
		if ( StartSpot != None )
		{
			NewBot.SetLocation(StartSpot.Location);
			NewBot.SetRotation(StartSpot.Rotation);
			NewBot.ViewRotation = StartSpot.Rotation;
			NewBot.SetRotation(NewBot.Rotation);
			StartSpot.PlayTeleportEffect( NewBot, true );
		}
		else
			StartSpot = OldStartSpot;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);

	SetBotOrders(NewBot);

	// Log it.
	if (LocalLog != None)
	{
		LocalLog.LogPlayerConnect(NewBot);
		LocalLog.FlushLog();
	}
	if (WorldLog != None)
	{
		WorldLog.LogPlayerConnect(NewBot);
		WorldLog.FlushLog();
	}

	return true;
}

function SetBotOrders(Bot NewBot)
{
	local Pawn P, L;
	local int num, total;

	// only follow players, if there are any
	if ( (NumSupportingPlayer == 0)
		 || (NumSupportingPlayer < Teams[NewBot.PlayerReplicationInfo.Team].Size/2 - 1) ) 
	{
		For ( P=Level.PawnList; P!=None; P= P.NextPawn )
			if ( P.IsA('PlayerPawn') && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team)
				&& !P.IsA('Spectator') )
		{
			num++;
			if ( (L == None) || (FRand() < 1.0/float(num)) )
				L = P;
		}

		if ( L != None )
		{
			NumSupportingPlayer++;
			NewBot.SetOrders('Follow',L,true);
			return;
		}
	}
	num = 0;
	For ( P=Level.PawnList; P!=None; P= P.NextPawn )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team) )
		{
			total++;
			if ( (P != NewBot) && P.IsA('Bot') && (Bot(P).Orders == 'FreeLance') )
			{
				num++;
				if ( (L == None) || (FRand() < 1/float(num)) )
					L = P;
			}
		}
				
	if ( (L != None) && (FRand() < float(num)/float(total)) )
	{
		NewBot.SetOrders('Follow',L,true);
		return;
	}
	NewBot.SetOrders('Freelance', None,true);
}				 

function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	if ( (Other.bIsPlayer && (aBot.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team))
		|| (Other.IsA('TeamCannon') 
			&& (StationaryPawn(Other).SameTeamAs(aBot.PlayerReplicationInfo.Team))) ) 
		return 3;
	else 
		return Super.AssessBotAttitude(aBot, Other);
}

function Actor SetDefenseFor(Bot aBot)
{
	return None;
}

function bool FindSpecialAttractionFor(Bot aBot)
{
	return false;
}

function SetAttractionStateFor(Bot aBot)
{
	if ( aBot.Enemy != None )
	{
		if ( !aBot.IsInState('FallBack') )
		{
			aBot.bNoClearSpecial = true;
			aBot.TweenToRunning(0.1);
			aBot.GotoState('FallBack','SpecialNavig');
		}
	}
	else if ( !aBot.IsInState('Roaming') )
	{
		aBot.bNoClearSpecial = true;
		aBot.TweenToRunning(0.1);
		aBot.GotoState('Roaming', 'SpecialNavig');
	}
}

function PickAmbushSpotFor(Bot aBot)
{
	local NavigationPoint N;

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('Ambushpoint') && !N.taken )
		{
			if ( aBot.Orders == 'Defend' )
			{
				if ( N.IsA('DefensePoint') && (DefensePoint(N).team == aBot.PlayerReplicationInfo.team) )
				{
					if ( (DefensePoint(aBot.Ambushspot) == None)
						|| (DefensePoint(N).priority > DefensePoint(aBot.Ambushspot).priority) )
						aBot.Ambushspot = Ambushpoint(N);
					else if ( (DefensePoint(N).priority == DefensePoint(aBot.Ambushspot).priority)
						&& (FRand() < 0.4) ) 
						aBot.Ambushspot = Ambushpoint(N);
				}		
				else if ( (DefensePoint(aBot.AmbushSpot) == None)
						&& (VSize(N.Location - aBot.OrderObject.Location) < 1500)
						&& FastTrace(aBot.OrderObject.Location, N.Location)
						&& ((aBot.Ambushspot == None) || (FRand() < 0.5)) )
							aBot.Ambushspot = Ambushpoint(N);
			}
			else if ( (aBot.AmbushSpot == None)
				|| (VSize(aBot.Location - aBot.Ambushspot.Location)
					 > VSize(aBot.Location - N.Location)) )
				aBot.Ambushspot = Ambushpoint(N);
		}
}

function byte PriorityObjective(Bot aBot)
{
	return 0;
}

function bool SuccessfulGame()
{
	local TeamInfo BestTeam;
	local int i;
	BestTeam = Teams[0];
	for ( i=1; i<MaxTeams; i++ )
		if ( Teams[i].Score > BestTeam.Score )
			BestTeam = Teams[i];

	bFulfilledSpecial = True; // Override and implement if you have a special condition.
	if (BestTeam.TeamIndex == RatedPlayer.PlayerReplicationInfo.Team)
		return ( bFulfilledSpecial && (BestTeam.Score >= GoalTeamScore) );
	else
		return false;
}

function ClearOrders(Pawn Leaving)
{
	local Pawn P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('Bot') && (Bot(P).OrderObject == Leaving) )
			Bot(P).SetOrders('Freelance', None);
}
function bool WaitForPoint(bot aBot)
{
	return false;
}

function bool SendBotToGoal(Bot aBot)
{
	return false;
}

function bool HandleTieUp(Bot Bumper, Bot Bumpee)
{
	return false;
}

//------------------------------------------------------------------------------
// Game Querying.

function string GetRules()
{
	local string ResultSet;
	ResultSet = Super(TournamentGameInfo).GetRules();

	// Timelimit.
	ResultSet = ResultSet$"\\timelimit\\"$TimeLimit;
		
	// Fraglimit
	ResultSet = ResultSet$"\\goalteamscore\\"$int(GoalTeamScore);
		
	// MinPlayers
	Resultset = ResultSet$"\\minplayers\\"$MinPlayers;

	// Change Levels
	Resultset = ResultSet$"\\changelevels\\"$bChangeLevels;

	// Max Teams
	ResultSet = ResultSet$"\\maxteams\\"$MaxTeams;

	// Balance Teams
	ResultSet = ResultSet$"\\balanceteams\\"$bBalanceTeams;

	// Players Balance Teams
	ResultSet = ResultSet$"\\playersbalanceteams\\"$bPlayersBalanceTeams;

	// FriendlyFire
	ResultSet = ResultSet$"\\friendlyfire\\"$int(FriendlyFireScale*100)$"%";
	
	return ResultSet;
}

defaultproperties
{
     bScoreTeamKills=True
     MaxTeams=2
	 MaxCommanders=2
	 MaxAllowedTeams=4
     MaxTeamSize=16
     StartUpTeamMessage="You are on"
	 TeamChangeMessage="Use Options->Player Setup to change teams."
     TeamColor(0)="Red"
     TeamColor(1)="Blue"
     TeamColor(2)="Green"
     TeamColor(3)="Gold"
     TEAM_Blue=1
     TEAM_Green=2
     TEAM_Gold=3
     CurrentOrders(0)=Defend
     CurrentOrders(1)=Defend
     CurrentOrders(2)=Defend
     CurrentOrders(3)=Defend
     StartUpMessage="Work with your teammates against the other teams."
     bCanChangeSkin=False
	 bBalanceTeams=true
     bSpawnInTeamArea=false
	 bTeamGame=True
     ScoreBoardType=Class'Botpack.TeamScoreBoard'
     HUDType=Class'BotPack.ChallengeTeamHUD'
     BeaconName="TTeam"
     GameName="Tournament Team Game"
     RulesMenuType="UTMenu.UTTeamRSClient"
     SettingsMenuType="UTMenu.UTTeamSSClient"
	 NetWait=17
}
