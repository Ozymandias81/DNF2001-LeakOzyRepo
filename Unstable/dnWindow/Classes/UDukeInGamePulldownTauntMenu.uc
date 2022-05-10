/*-----------------------------------------------------------------------------
	UDukeInGamePulldownTauntMenu
	Author: Scott Alden
-----------------------------------------------------------------------------*/

class UDukeInGamePulldownTauntMenu extends UWindowPulldownMenu;

var localized string		TauntNames[4];
var UWindowPulldownMenuItem Taunts[4];

//=============================================================================
//Created
//=============================================================================
function Created()
{
	Super.Created();
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
	TauntNames(0)="Taunts 1"
	TauntNames(1)="Taunts 2"
	TauntNames(2)="Taunts 3"
	TauntNames(3)="Taunts 4"
	bCloseOnExecute=false
}