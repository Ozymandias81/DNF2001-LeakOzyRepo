/*-----------------------------------------------------------------------------
	UDukeInGamePulldownMenu
	Author: Scott Alden
-----------------------------------------------------------------------------*/

class UDukeInGamePulldownMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem	Options[32];
var localized string		OptionNames[32];
var class<dnVoicePack>		VoicePack;

//=============================================================================
//Created
//=============================================================================
function Created()
{
	local int i;

	Super.Created();	
	
	// Taunts I-IV
	VoicePack = class<dnVoicePack>( GetPlayerOwner().PlayerReplicationInfo.VoiceType );
	
	if ( VoicePack != None )
		CreateTaunts();

	for ( i=4; i<32; i++ )
	{
		if ( OptionNames[i] != "" )
		{
			Options[i] = AddMenuItem( OptionNames[i], None );
			Options[i].bDisabled = true;
		}
	}
	
	
	CreateClasses(4);
	CreateTeams(10);
	CreateSpectator(11);
	
	bTransient = true;
}

//=============================================================================
//CreateClasses
//=============================================================================
function CreateClasses(int Index)
{
	Options[Index].CreateSubMenu( class'UDukeInGamePulldownClassesMenu' );
	Options[Index].SubMenu.bLeaveOnScreen   = true;
	Options[Index].SubMenu.bCloseOnExecute  = true;
	Options[Index].bDisabled				= false;
	Options[Index].SubMenu.Font             = F_Small;

	if ( Options[Index].SubMenu.Items.Count() == 0 )
		Options[Index].bDisabled = true;
}

//=============================================================================
//CreateSpectator
//=============================================================================
function CreateSpectator(int Index)
{
	Options[Index].CreateSubMenu( class'UDukeInGamePulldownSpectatorMenu' );
	Options[Index].SubMenu.bLeaveOnScreen  = true;
	Options[Index].SubMenu.bCloseOnExecute = true;
	Options[Index].bDisabled				= false;

	if ( Options[Index].SubMenu.Items.Count() == 0 )
		Options[Index].bDisabled = true;
}

//=============================================================================
//CreateTeams
//=============================================================================
function CreateTeams(int Index)
{
	Options[Index].CreateSubMenu( class'UDukeInGamePulldownTeamsMenu' );
	Options[Index].SubMenu.bLeaveOnScreen  = true;
	Options[Index].SubMenu.bCloseOnExecute = true;
	Options[Index].bDisabled				= false;
	
	if ( Options[Index].SubMenu.Items.Count() == 0 )
		Options[Index].bDisabled = true;
}

//=============================================================================
//CreateTaunts
//=============================================================================
function CreateTaunts()
{
	local int i;

	for ( i=0; i<4; i++ )
	{
		Options[i] = AddMenuItem( OptionNames[i], None );
		Options[i].CreateSubMenu( class'UDukeScoreboardTauntMenu' );
		
		UDukeScoreboardTauntMenu( Options[i].SubMenu ).AddTaunts( i*8, i*8+8, VoicePack );
		
		Options[i].SubMenu.bLeaveOnScreen  = true;
		Options[i].SubMenu.Font            = F_Small;
		Options[i].SubMenu.bCloseOnExecute = false;

		if ( Options[i].SubMenu.Items.Count() == 0 )
			Options[i].bDisabled = true;

	}
}

//=============================================================================
//RefreshTaunts
//=============================================================================
function RefreshTaunts()
{
	local int i;

	for ( i=0; i<4; i++ )
	{	
		UDukeScoreboardTauntMenu( Options[i].SubMenu ).AddTaunts( i*8, i*8+8, VoicePack );
		
		Options[i].SubMenu.bLeaveOnScreen  = true;
		Options[i].SubMenu.Font            = F_Small;
		Options[i].SubMenu.bCloseOnExecute = false;
		Options[i].bDisabled = false;

		if ( Options[i].SubMenu.Items.Count() == 0 )
			Options[i].bDisabled = true;
	}
}

//=============================================================================
//BeforePaint
//=============================================================================
function BeforePaint( Canvas C, float X, float Y )
{
	Super.BeforePaint( C, X, Y );

	WinTop  = ( C.ClipY - WinHeight ) / 2;
	WinLeft = 0;
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

	Super.ShowWindow();
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
//defaultproperties
//=============================================================================
defaultproperties
{
	OptionNames(0)="Taunts I"
	OptionNames(1)="Taunts II"
	OptionNames(2)="Taunts III"
	OptionNames(3)="Taunts IV"
	OptionNames(4)="Change Class"
	OptionNames(5)="Acknowledge"
	OptionNames(6)="Friendly Fire"
	OptionNames(7)="Orders"	
	OptionNames(8)="Other/Misc"
	OptionNames(9)="Gesture"
	OptionNames(10)="Change Teams"
	OptionNames(11)="Spectator"
}