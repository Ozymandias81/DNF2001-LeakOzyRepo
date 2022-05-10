/*-----------------------------------------------------------------------------
	UDukeInGamePulldownTeamsMenu
	Author: Scott Alden
-----------------------------------------------------------------------------*/

class UDukeInGamePulldownTeamsMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Options[8];

//=============================================================================
//Created
//=============================================================================
function Created()
{
	local int i, NumTeams;
	local class<dnTeamGame>	V;

	Super.Created();	

	if ( GetPlayerOwner().GameReplicationInfo != None )
	{
	    V = class<dnTeamGame>( DynamicLoadObject( GetPlayerOwner().GameReplicationInfo.GameClass, class'Class' ) );
	}
	else 
	{
		// No teams in this game
		return;
	}

	NumTeams = Min( 8, V.default.MaxTeams );

	for ( i=0; i<NumTeams; i++ )
	{
		Options[i] = AddMenuItem( V.default.TeamNames[i], None );
		Options[i].Index = i;
	}
}

//=============================================================================
//ExecuteItem
//=============================================================================
function ExecuteItem( UWindowPulldownMenuItem Item ) 
{
	GetPlayerOwner().ChangeTeam( Item.Index );
	Super.ExecuteItem( Item );
}

//=============================================================================
//CloseUp
//=============================================================================
function CloseUp( bool bByParent )
{
	Super.CloseUp( bByParent );
	HideWindow();
}

//=============================================================================
//ShowWindow
//=============================================================================
function ShowWindow()
{
	Selected = None;
	Super.ShowWindow();
}

//=============================================================================
//defaultproperties
//=============================================================================
defaultproperties
{
}

