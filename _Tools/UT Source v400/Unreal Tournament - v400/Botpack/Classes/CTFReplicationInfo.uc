//=============================================================================
// CTFReplicationInfo.
//=============================================================================
class CTFReplicationInfo extends TournamentGameReplicationInfo;

var CTFFlag FlagList[4];

replication
{
	reliable if ( Role == ROLE_Authority )
		FlagList;
}

defaultproperties
{
}
