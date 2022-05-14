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

//TLW: This is old, and could be removed except for FunStuff is still done the 
//		old way
enum eExplorerTypes
{
	//Settings Types
	eEXPLORER_Game,
	eEXPLORER_Multiplayer,
	eEXPLORER_Settings,
	eEXPLORER_Tools,
	eEXPLORER_Stats,
	
	eEXPLORER_FunStuff,
	
	eEXPLORER_TYPES_MAX
}; 

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

var(MessageBoxQuit) localized string QuitTitle;		//Used for Quit message box
var(MessageBoxQuit) localized string QuitText;		//  "

var eExplorerTypes eTypeOfExplorerToCreate;			//Used for defining which kind of explorer window to open
var UDukeFakeExplorerWindow	explorerDirectory;		//  "
var class<UDukeFakeExplorerWindow> classExplorer;	//  "

var(FakeExplorerWindow) Region WindowOffsetAndSize;	//Used for size and placement of any window opened by this icon

//Commands
var String strTravelCommand;						//Used for new/load game that results in ClientTravel()
var class<UWindowFramedWindow> winToOpen;			//Type of window icon opens up
var eWindowCommands eWindowCommand;					//command to execute, if no window is opened

var bool CannotClick;

simulated function Click(float X, float Y) 
{
	if (CannotClick)
		return;

	//call into super click, instead of handling
	if(bWindowVisible)
		Super.Click(X, Y);	//do not process if not visible	
}	

simulated function DoubleClick(float X, float Y) 
{
	if (CannotClick)
		return;

	Click(X, Y);
}

function PerformSelect()
{
	local float fLocX,
				fLocY;

	//Call super to play the menu sound
	Super.PerformSelect();

	if( !ExecuteCommand() && 
		classExplorer != None)  {
		
		fLocX = Root.WinLeft + (Root.WinWidth  / 2) - (WindowOffsetAndSize.W / 2);
		fLocY = Root.WinTop  + (Root.WinHeight / 2) - (WindowOffsetAndSize.H / 2);
		explorerDirectory = UDukeFakeExplorerWindow( Root.CreateWindow( classExplorer,
																		fLocX, fLocY,
																	   	WindowOffsetAndSize.W, WindowOffsetAndSize.H,
																		self,
																		!bDesktopIcon	//only one unique kind of window open at a time														
													 )
		);
		
		switch(eTypeOfExplorerToCreate)  {	
			case eEXPLORER_Game			: //explorerDirectory.CreateIconsForGameWindow();		break;
			case eEXPLORER_Multiplayer	: //explorerDirectory.CreateIconsForMultiplayerWindow();	break;
			case eEXPLORER_Settings 	: //explorerDirectory.CreateIconsForSettingsWindow();	break;
			case eEXPLORER_Tools 		: //explorerDirectory.CreateIconsForToolsWindow();		break;
			case eEXPLORER_Stats 		: //explorerDirectory.CreateIconsForStatsWindow();
										  break;
			case eEXPLORER_FunStuff		: explorerDirectory.CreateIconsForFunstuffWindow();	break;
		}
		
	//	explorerDirectory.bSizable = True;	//give it the ability to resize
		if( (UDukeRootWindow(Root) != None) && (UDukeRootWindow(Root).Desktop != None) )
			UDukeRootWindow(Root).Desktop.HideIcons();
	}
	else
		explorerDirectory = None;
}

function bool ExecuteCommand()  
{
	local float fLocX,
				fLocY;
				
	if(IsValidString(strTravelCommand))  {
		GetPlayerOwner().ClientTravel( strTravelCommand $ "?noauto", TRAVEL_Absolute, True );
		//GetPlayerOwner().ClientTravel( strTravelCommand, TRAVEL_Absolute, True );
		//return true;
	}
	
	if(winToOpen != None)  {
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
	
	switch(eWindowCommand)  
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
		case eWINDOW_COMMAND_LaunchSpaceInvaders:
			UDukeFakeExplorerCW(ParentWindow).LaunchClassicGame("Space Invaders", WindowOffsetAndSize);										
			return true;
		case eWINDOW_COMMAND_LaunchMissileCommand: 
			UDukeFakeExplorerCW(ParentWindow).LaunchClassicGame("Missile Command", WindowOffsetAndSize);
			return true;
		case eWINDOW_COMMAND_LaunchBreakOut:
			UDukeFakeExplorerCW(ParentWindow).LaunchClassicGame("Break Out", WindowOffsetAndSize);
			return true;
		case eWINDOW_COMMAND_NaughtyLink:
			GetPlayerOwner().ConsoleCommand("start http://www.playboy.com/");
			return true;	
		case eWINDOW_COMMAND_Profile:
			UDukeDesktopWindow(ParentWindow).ShowProfileWindow(true);
			return true;	
		case eWINDOW_COMMAND_NONE:
		case eWINDOW_COMMAND_MAX: 
			break;	//not a valid windowcommand, fall thru
	} 
	
	return false;	//no command to execute
}

//For keyboard control of icon selection
function KeyDown(int Key, float X, float Y)
{
	local PlayerPawn P;
	local UDukeDesktopWindow winDesk;

	P = Root.GetPlayerOwner();
	winDesk = UDukeRootWindow(Root).Desktop;

	switch (Key)  {
		case P.EInputKey.IK_Up:		winDesk.SelectIcon(eICON_SELECT_UP);
									return;									
		case P.EInputKey.IK_Down:	winDesk.SelectIcon(eICON_SELECT_DOWN);
									return;
		case P.EInputKey.IK_Left:	winDesk.SelectIcon(eICON_SELECT_LEFT);
									return;
		case P.EInputKey.IK_Right:	winDesk.SelectIcon(eICON_SELECT_RIGHT);
									return;
	}
	
	//default:
	Super.KeyDown(Key, X, Y);
}


simulated function MouseEnter()
{
	if(bDesktopIcon && bWindowVisible)
		UDukeRootWindow(Root).Desktop.DesktopIconMouseEvent(self);
	
	Super.MouseEnter();
}

defaultproperties
{
     QuitTitle="Confirm Quit"
     QuitText="Are you sure you want to quit?"
     eTypeOfExplorerToCreate=eEXPLORER_TYPES_MAX
     WindowOffsetAndSize=(X=150,Y=200,W=300,h=200)
     bIgnoreLDoubleClick=False
}
