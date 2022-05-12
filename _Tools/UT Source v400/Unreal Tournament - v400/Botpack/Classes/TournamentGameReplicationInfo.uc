//=============================================================================
// TournamentGameReplicationInfo.
//=============================================================================
class TournamentGameReplicationInfo extends GameReplicationInfo;

var localized string HumanString, CommanderString, SupportString, DefendString, AttackString, HoldString, FreelanceString;
var TeamInfo Teams[4];

var int GoalTeamScore;
var int FragLimit;
var int TimeLimit;

var int TotalGames;
var int TotalFrags;
var int TotalDeaths;
var int TotalFlags;
var string BestPlayers[3];
var int BestFPHs[3];
var string BestRecordDate[3];

replication
{
	reliable if ( Role == ROLE_Authority )
		Teams, FragLimit, TimeLimit, GoalTeamScore;
		
	reliable if ( (Role == ROLE_Authority) && bNetInitial )
		TotalGames, TotalFrags, TotalDeaths, BestPlayers, BestFPHs, BestRecordDate,
		TotalFlags;
}

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	if (TournamentGameInfo(Level.Game) != None)
	{
		TotalGames = TournamentGameInfo(Level.Game).EndStatsClass.Default.TotalGames;
		TotalFrags = TournamentGameInfo(Level.Game).EndStatsClass.Default.TotalFrags;
		TotalDeaths = TournamentGameInfo(Level.Game).EndStatsClass.Default.TotalDeaths;
		TotalFlags = TournamentGameInfo(Level.Game).EndStatsClass.Default.TotalFlags;
		for (i=0; i<3; i++)
		{
			BestPlayers[i] = TournamentGameInfo(Level.Game).EndStatsClass.Default.BestPlayers[i];
			BestFPHs[i] = TournamentGameInfo(Level.Game).EndStatsClass.Default.BestFPHs[i];
			BestRecordDate[i] = TournamentGameInfo(Level.Game).EndStatsClass.Default.BestRecordDate[i];
		}
	}
}

simulated function string GetOrderString(PlayerReplicationInfo PRI)
{
	local BotReplicationInfo BRI;

	BRI = BotReplicationInfo(PRI);
	if ( BRI == None )
	{
		if ( PRI.bIsSpectator && !PRI.bWaitingPlayer )
			return CommanderString;
		return HumanString;
	}
	if ( BRI.RealOrders == 'follow' )
		return SupportString@BRI.RealOrderGiverPRI.PlayerName;
	if ( BRI.RealOrders == 'defend' )
	{
		if ( (BRI.OrderObject != None)
			&& (BRI.OrderObject.IsA('ControlPoint') || BRI.OrderObject.IsA('FortStandard')) )
			return DefendString@BRI.OrderObject.GetHumanName();
		return DefendString;
	}
	if ( BRI.RealOrders	== 'freelance' )
		return FreelanceString;
	if ( BRI.RealOrders	== 'attack' )
	{
		if ( (BRI.OrderObject != None)
			&& (BRI.OrderObject.IsA('ControlPoint') || BRI.OrderObject.IsA('FortStandard')) )
			return AttackString@BRI.OrderObject.GetHumanName();
		return AttackString;
	}
	if ( BRI.RealOrders == 'hold' )
		return HoldString;
}

defaultproperties
{
	 ServerName="Another UT Server"
	 ShortName="UT Server"
	 CommanderString="*Commander*"
	 HumanString="*Human*"
	 SupportString="supporting"
	 DefendString="defending"
	 AttackString="attacking"
	 HoldString="holding"
	 FreeLanceString="freelancing"
}
