//==========================================================================
// 
// FILE:			UDukeFakeIcon.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		A Win9x style icon
// 
// NOTES:			Expansion of UDukeButton to similate a Win9x interface, 
//					with clickable icons to execute commands or open submenus
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeFakeIcon expands UDukeButton;

//Each icon that doesn't open a window, usually has a command,
//	a eWindowCommand to differentiate which one
enum eWindowCommands
{
	eWINDOW_COMMAND_NONE,
	
	eWINDOW_COMMAND_Close,
	eWINDOW_COMMAND_Quit,
	eWINDOW_COMMAND_Profile,

	eWINDOW_COMMAND_BrowseInternet,
	eWINDOW_COMMAND_BrowseLAN,
	eWINDOW_COMMAND_BrowseLocation,
	eWINDOW_COMMAND_ServerDisconnect,
	eWINDOW_COMMAND_ServerReconnect,
	eWINDOW_COMMAND_LatestVer,
	
	eWINDOW_COMMAND_ToggleConsole,
	eWINDOW_COMMAND_TimeDemo,
	eWINDOW_COMMAND_ShowLog,
	
	eWINDOW_COMMAND_StatView,
	eWINDOW_COMMAND_StatGlobal,
	eWINDOW_COMMAND_StatHelp,
	eWINDOW_COMMAND_StatHelpGlobal,

	eWINDOW_COMMAND_About,
	
	eWINDOW_COMMAND_LaunchSpaceInvaders,
	eWINDOW_COMMAND_LaunchMissileCommand,
	eWINDOW_COMMAND_LaunchBreakOut,
	eWINDOW_COMMAND_NaughtyLink,
	
	eWINDOW_COMMAND_MAX
};

var(MessageBoxQuit) localized string QuitTitle;
var(MessageBoxQuit) localized string QuitText;

var UDukeFramedWindow	explorerDirectory;
var class<UDukeFramedWindow> classExplorer;

var(FramedWindow) Region WindowOffsetAndSize;

var String strTravelCommand;
var class<UWindowFramedWindow> winToOpen;
var eWindowCommands eWindowCommand;

simulated function Click( float X, float Y )
{
	if ( CannotClick )
		return;

	if ( bWindowVisible )
		Super.Click( X, Y );
}	

simulated function DoubleClick( float X, float Y ) 
{
	if ( CannotClick )
		return;

	Click( X, Y );
}

function PerformSelect()
{
	local float fLocX, fLocY;

	if ( Root.FindChildWindow( class'UWindowFramedWindow' ) != None )
		return;

	if ( bDesktopIcon )
	{
		if ( UDukeRootWindow(Root).Desktop.BlurButton != Self )
		{
			if( !bHighlightButton && !bDesktopIcon )
				LookAndFeel.PlayMenuSound( Self, MS_OptionHL );

			if ( bDesktopIcon && bWindowVisible )
				UDukeRootWindow(Root).Desktop.IconBlur( self );
				return;
		}
	}

	Super.PerformSelect();

	if ( !ExecuteCommand() && classExplorer != None )
	{
		fLocX = Root.WinLeft + (Root.WinWidth  / 2) - (WindowOffsetAndSize.W / 2);
		fLocY = Root.WinTop  + (Root.WinHeight / 2) - (WindowOffsetAndSize.H / 2);
		explorerDirectory = UDukeFramedWindow( Root.CreateWindow( classExplorer,
																		fLocX, fLocY,
																	   	WindowOffsetAndSize.W, WindowOffsetAndSize.H,
																		self,
																		!bDesktopIcon	//only one unique kind of window open at a time														
													 )
		);
	}
	else
		explorerDirectory = None;
}

function bool ExecuteCommand()  
{
	local float fLocX, fLocY;
				
	if ( IsValidString(strTravelCommand) )
	{
		GetPlayerOwner().ClientTravel( strTravelCommand $ "?noauto", TRAVEL_Absolute, True );
	}
	
	if ( winToOpen != None )
	{
		fLocX = Root.WinLeft + (Root.WinWidth  / 2) - (WindowOffsetAndSize.W / 2);
		fLocY = Root.WinTop  + (Root.WinHeight / 2) - (WindowOffsetAndSize.H / 2);
		Root.CreateWindow(winToOpen, 
						  fLocX, fLocY,		//	  WindowOffsetAndSize.X, WindowOffsetAndSize.Y, 
						  WindowOffsetAndSize.W, WindowOffsetAndSize.H, 
						  self, 
						  true
		);
		return true;
	}
	
	switch( eWindowCommand )
	{
		case eWINDOW_COMMAND_Close: 
			Root.CloseActiveWindow();
			Root.Console.CloseUWindow();	
			return true;		
		case eWINDOW_COMMAND_Quit: 
			UDukeDesktopWindow(ParentWindow).ConfirmQuit = 
				ParentWindow.MessageBox(QuitTitle, QuitText, MB_YesNo, MR_No, MR_Yes);	
			return true;
		case eWINDOW_COMMAND_BrowseInternet: 
			UDukeDesktopWindow(ParentWindow).StartBrowsingInternet(winToOpen);
			return true;
		case eWINDOW_COMMAND_BrowseLAN: 
			UDukeDesktopWindow(ParentWindow).StartBrowsingLAN(winToOpen);
			return true;
		case eWINDOW_COMMAND_BrowseLocation: 	
			UDukeDesktopWindow(ParentWindow).StartBrowsingLocation(winToOpen);						 	
			return true;
		case eWINDOW_COMMAND_ServerDisconnect: 
			GetPlayerOwner().ConsoleCommand("disconnect");
			Root.Console.CloseUWindow();
			return true;
		case eWINDOW_COMMAND_ServerReconnect:	
			if(GetLevel().NetMode == NM_Client)
				GetPlayerOwner().ConsoleCommand("disconnect");	
			GetPlayerOwner().ConsoleCommand("reconnect");
			Root.Console.CloseUWindow();
			return true;	
		case eWINDOW_COMMAND_LatestVer: 
			GetPlayerOwner().ConsoleCommand("start http://www.3drealms.com/");
			return true;	
		case eWINDOW_COMMAND_About:
			GetPlayerOwner().ClientTravel( "UTCredits.unr", TRAVEL_Absolute, False );
			Root.Console.CloseUWindow();
			return true;
		case eWINDOW_COMMAND_Profile:
			UDukeDesktopWindow(ParentWindow).ShowProfileWindow(true);
			return true;	
		case eWINDOW_COMMAND_NONE:
		case eWINDOW_COMMAND_MAX: 
			break;
	} 
	
	return false;
}

defaultproperties
{
     QuitTitle="Confirm Quit "
     QuitText="Are you sure you want to quit?"
     WindowOffsetAndSize=(X=150,Y=200,W=300,H=200)
     bIgnoreLDoubleClick=False
}
