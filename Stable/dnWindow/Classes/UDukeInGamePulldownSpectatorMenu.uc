/*-----------------------------------------------------------------------------
	UDukeInGamePulldownSpectatorMenu
	Author: Scott Alden
-----------------------------------------------------------------------------*/

class UDukeInGamePulldownSpectatorMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Options[2];
var localized string		OptionNames[2];

//=============================================================================
//Created
//=============================================================================
function Created()
{
	local int i;

	Super.Created();

	for ( i=0; i<2; i++ )
	{
		Options[i] = AddMenuItem( OptionNames[i], None );
	}
}

//=============================================================================
//ExecuteItem
//=============================================================================
function ExecuteItem( UWindowPulldownMenuItem Item ) 
{
	switch( Item )
	{
	case Options[0]:
		GetPlayerOwner().JoinSpectator();
		break;
	case Options[1]:
		GetPlayerOwner().LeaveSpectator();
		break;
	}

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
	OptionNames(0)="Join Spectators"
	OptionNames(1)="Leave Spectators"
}

