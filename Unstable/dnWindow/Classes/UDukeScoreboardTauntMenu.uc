/*-----------------------------------------------------------------------------
	UDukeScoreboardTauntMenu
	Author: Scott Alden
-----------------------------------------------------------------------------*/

class UDukeScoreboardTauntMenu extends UWindowRightClickMenu;

var UWindowPulldownMenuItem  Taunts[32];
var UDukeScoreboardGrid      Grid;
var int					     NumTaunts;

//=============================================================================
//AddTaunts
//=============================================================================
function AddTaunts( int Start, int End, class<dnVoicePack> VoicePack )
{
	local int i;

	Clear();

	if ( GetPlayerOwner().PlayerReplicationInfo == None )
		return;

	VoicePack = class<dnVoicePack>( GetPlayerOwner().PlayerReplicationInfo.VoiceType );
	
	if ( VoicePack == None )
		return;

	NumTaunts = VoicePack.default.NumTaunts;

	for ( i=Start; i<End; i++ )
	{
		if ( i >= 32 )
			break;

		if ( VoicePack.static.GetTauntString(i) != "" )
		{
			Taunts[i]       = AddMenuItem( VoicePack.static.GetTauntString(i), None );
			Taunts[i].Index = i;
		}
	}
}

//=============================================================================
//ExecuteItem
//=============================================================================
function ExecuteItem( UWindowPulldownMenuItem Item )
{
	local int Callsign;
	
	Callsign = -1;

	if ( Grid != None && Grid.SelectedItem != None )
		Callsign = Grid.SelectedItem.PlayerID;	

	GetPlayerOwner().Speech( 3, Item.Index, Callsign ); // 3 = taunt
	Super.ExecuteItem( Item );
}

//=============================================================================
//ShowWindow
//=============================================================================
function ShowWindow()
{
	Selected = None;
	Super.ShowWindow();
}

defaultproperties
{
}
