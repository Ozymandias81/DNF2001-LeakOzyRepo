/*-----------------------------------------------------------------------------
	UDukeScoreboardMenu
	Author: Scott Alden
-----------------------------------------------------------------------------*/

class UDukeScoreboardMenu extends UWindowRightClickMenu;

var UWindowPulldownMenuItem Tell;
var UWindowPulldownMenuItem Taunts[4];
var UWindowPulldownMenuItem Kick;

var localized string TellName;
var localized string TauntNames[4];
var localized string KickName;

var UDukeScoreboardGrid	Grid;
var UDukeScoreboardList Item;

var class<dnVoicePack> VoicePack;

//=============================================================================
//Created
//=============================================================================
function Created()
{
	local int i;

	Super.Created();
	
	Tell      = AddMenuItem( TellName,      None );
	Taunts[0] = AddMenuItem( TauntNames[0], None );
	Taunts[1] = AddMenuItem( TauntNames[1], None );
	Taunts[2] = AddMenuItem( TauntNames[2], None );
	Taunts[3] = AddMenuItem( TauntNames[3], None );
	Kick      = AddMenuItem( KickName,      None );
}

//=============================================================================
//ShowWindow
//=============================================================================
function ShowWindow()
{	
	local int i;

	Selected = None;

	if ( VoicePack != class<dnVoicePack>( GetPlayerOwner().PlayerReplicationInfo.VoiceType ) )
	{
		VoicePack = class<dnVoicePack>( GetPlayerOwner().PlayerReplicationInfo.VoiceType );
		RefreshTaunts();
	}

	for ( i=0; i<4; i++ )
		UDukeScoreboardTauntMenu( Taunts[i].SubMenu ).Grid = Grid;

	Super.ShowWindow();
}

//=============================================================================
//RefreshTaunts
//=============================================================================
function RefreshTaunts()
{
	local int i;

	for ( i=0; i<4; i++ )
	{	
		UDukeScoreboardTauntMenu( Taunts[i].SubMenu ).AddTaunts( i*8, i*8+8, VoicePack );
		
		Taunts[i].SubMenu.bLeaveOnScreen  = true;
		Taunts[i].SubMenu.Font            = F_Small;
		Taunts[i].SubMenu.bCloseOnExecute = false;
		Taunts[i].bDisabled = false;

		if ( Taunts[i].SubMenu.Items.Count() == 0 )
			Taunts[i].bDisabled = true;
	}
}

//=============================================================================
//ExecuteItem
//=============================================================================
function ExecuteItem( UWindowPulldownMenuItem I ) 
{	
	switch(I)
	{
	case Tell:	
		Grid.DoTell( Item.PlayerID, Item.PlayerName );
		break;
	case Kick:
		break;
	}

	Super.ExecuteItem( I );
}

defaultproperties
{
	TellName="Tell"
	TauntNames(0)="Taunts 1"
	TauntNames(1)="Taunts 2"
	TauntNames(2)="Taunts 3"
	TauntNames(3)="Taunts 4"
	KickName="Kick"
}
