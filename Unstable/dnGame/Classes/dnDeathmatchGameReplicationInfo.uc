//=============================================================================
// dnDeathmatchGameReplicationInfo.
//=============================================================================
class dnDeathmatchGameReplicationInfo extends GameReplicationInfo;

var		int			TimeLimit;
var		int			FragLimit;
var     int         GoalTeamScore;
var		dnTeamInfo	Teams[2];
	
replication
{
	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		TimeLimit, FragLimit;
}
