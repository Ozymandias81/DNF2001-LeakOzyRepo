/*-----------------------------------------------------------------------------
	UDukeInGamePulldownClassesMenu
	Author: Scott Alden
-----------------------------------------------------------------------------*/

class UDukeInGamePulldownClassesMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Options[16];

//=============================================================================
//Created
//=============================================================================
function Created()
{
	local int				i, NumOptions;
	local class<dnTeamGame>	V;
	local int				Team;

	Team = int(GetPlayerOwner().GetDefaultURL( "Team" ) );

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

	if ( V == None )
		return;

	NumOptions = V.default.NumTeamClassNames;

	for ( i=0; i<NumOptions; i++ )
	{
		if ( ( Team == 0 ) && ( V.default.HumanTeamClassNames[i] != "" ) )
			AddMenuItem( V.default.HumanTeamClassNames[i] @ "(" $ V.default.HumanTeamCost[i] $ ")", None );
		else if ( ( Team == 1 ) && ( V.default.BugTeamClassNames[i] != "" ) )
			AddMenuItem( V.default.BugTeamClassNames[i] @ "(" $ V.default.BugTeamCost[i] $ ")", None );
	}
}

//=============================================================================
//ExecuteItem
//=============================================================================
function ExecuteItem( UWindowPulldownMenuItem Item ) 
{
	GetPlayerOwner().ChangeClass( Left( Item.Caption, Len(Item.Caption) - 4 ) );
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

