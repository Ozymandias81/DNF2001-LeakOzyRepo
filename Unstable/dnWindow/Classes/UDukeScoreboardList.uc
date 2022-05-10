/*-----------------------------------------------------------------------------
	UDukeScoreboardList
	Author: Scott Alden
-----------------------------------------------------------------------------*/

class UDukeScoreboardList extends UWindowList;

var PlayerReplicationInfo	PRI;
var int						PlayerID;
var string					PlayerName;
var int						Kills;
var int						Deaths;
var int						Ping;
var int						Time;
var bool					bHidden;

function int Compare( UWindowList T, UWindowList B )
{
	local UDukeScoreboardList	PT, PB;

	if ( B == None )  
		return 0; 

	PT = UDukeScoreboardList(T);
	PB = UDukeScoreboardList(B);

	if ( PT.Kills > PB.Kills )
		return 1;
	else if ( PT.Kills < PB.Kills )
		return -1;
	else if ( PT.Deaths > PB.Deaths )
		return 1;
	else if ( PT.Deaths < PB.Deaths )
		return -1;
	else if ( PT.PlayerName > PB.PlayerName )
		return 1;
	else if ( PT.PlayerName < PB.PlayerName )
		return -1;

	return 0;
}

defaultproperties
{
	bHidden=false;
}