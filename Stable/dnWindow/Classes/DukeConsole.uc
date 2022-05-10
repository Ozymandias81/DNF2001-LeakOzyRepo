class DukeConsole extends WindowConsole;

// Timedemo
var bool						bTimeDemoIsEntry;
var dnFontInfo					MyFontInfo;

var UDukeDesktopWindow			Desktop;

var config string				SavedPasswords[10];
var string						LoadStateText[9];

//var UDukeInGameWindow			InGameWindow;
var UDukeInGamePulldownMenu		InGameWindow;
var globalconfig byte			InGameWindowKey;

var UDukeScoreboard             ScoreboardWindow;
var globalconfig byte			ScoreboardKey;

var bool						bShowInGameWindow;
var bool						bShowScoreboard;
var bool						bAskingAboutQuickLoad;			// JEP == true if duke is confirming QuickLoad

function CancelBootSequence()
{
	bShowBootup = false;
}

function SetupDeathSequence()
{
	bShowDeathSequence = true;
}

event PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);

	if ( bShowInGameWindow || bShowScoreboard )
	{
		RenderUWindow( Canvas );
	}

	DrawQuickLoadConfirm(Canvas);		// JEP
}

function CloseFromEscape( byte k )
{
	if ( Root.DontCloseOnEscape )
		Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);
	else if ( (Root.GetLevel().Game != None) && Root.GetLevel().Game.IsA('DukeIntro') && Root.ActiveWindow.IsA('UDukeDesktopWindow') )
		Root.ConfirmQuit();
	else
	{
		if ( Root.ActiveWindow.IsA('UDukeDesktopWindow') )
			CloseUWindow();
		else if ( Root.ActiveWindow.IsA('UDukeConsoleWindow') )
			HideConsole();
		else
			Root.CloseActiveWindow();
	}
}

// JEP...
//===========================================================================
//	DrawQuickLoadConfirm
//===========================================================================
function DrawQuickLoadConfirm(canvas Canvas)
{
	local string	Str;
	local float		W, H;

	// QuickLoad confirmation
	if (!bAskingAboutQuickLoad)
		return;

	//UseStr = HUDToUse.SpecialKeys[HUDToUse.ESpecialKeys.SK_Use];
	Str = "Press F9 again to QuickLoad, press ESC to cancel...";

	Canvas.Style = 3;
	Canvas.Font = Root.Fonts[Root.F_Bold];
	Canvas.DrawColor = Root.LookAndFeel.GetTextColor( Root );

	Canvas.TextSize( Str, W, H );
	Canvas.SetPos((Canvas.ClipX-W)*0.5, Canvas.ClipY*0.4);

	Canvas.DrawText( Str );
}

//===========================================================================
//	GetLevel
//===========================================================================
final function LevelInfo GetLevel()
{
	return ViewPort.Actor.Level;
}

//===========================================================================
//	GetEntryLevel
//===========================================================================
final function LevelInfo GetEntryLevel()
{
	return ViewPort.Actor.GetEntryLevel();
}

//===========================================================================
//	Tick
//===========================================================================
event Tick( float Delta )
{
	Super.Tick(Delta);

	if (GetLevel().Pauser == "")
		bAskingAboutQuickLoad = false;
}

//===========================================================================
//	QuickLoad
//===========================================================================
exec function QuickLoad()
{
	if ((GetLevel().NetMode == NM_Standalone) && !GetLevel().Game.bDeathMatch)
	{
		if (GetLevel() == GetEntryLevel() || bAskingAboutQuickLoad)
		{
			Root.Console.bCloseForSureThisTime = true;
			Root.Console.CloseUWindow();
			Root.Console.bCloseForSureThisTime = false;

			ViewPort.Actor.LoadGame(SAVE_Quick, -1);			// the -1 means load the last saved of this type
		}
	
		if (GetLevel() != GetEntryLevel())
		{
			bAskingAboutQuickLoad = !bAskingAboutQuickLoad;
			Viewport.Actor.SetPause(bAskingAboutQuickLoad);
		}
	}
}
// ...JEP

event ConnectFailure( string FailCode, string URL )
{
	local int i, j;
	local string Server;
	local UDukePasswordWindow W;

	if(FailCode == "NEEDPW")
	{
		Server = Left(URL, InStr(URL, "/"));
		for(i=0; i<10; i++)
		{
			j = InStr(SavedPasswords[i], "=");
			if(Left(SavedPasswords[i], j) == Server)
			{
				Viewport.Actor.ClearProgressMessages();
				Viewport.Actor.ClientTravel(URL$"?password="$Mid(SavedPasswords[i], j+1), TRAVEL_Absolute, false);
				return;
			}
		}
	}

	if(FailCode == "NEEDPW" || FailCode == "WRONGPW")
	{
		Viewport.Actor.ClearProgressMessages();
		CloseUWindow();
		bQuickKeyEnable = True;
		LaunchUWindow();
		W = UDukePasswordWindow(Root.CreateWindow(class'UDukePasswordWindow', 100, 100, 100, 100));
		UDukePasswordCW(W.ClientArea).URL = URL;
	}
}

function ConnectWithPassword(string URL, string Password)
{
	local int i;
	local string Server;
	local bool bFound;

	if(Password == "")
	{
		Viewport.Actor.ClientTravel(URL, TRAVEL_Absolute, false);
		return;
	}

	bFound = False;
	Server = Left(URL, InStr(URL, "/"));
	for(i=0; i<10; i++)
	{
		if(Left(SavedPasswords[i], InStr(SavedPasswords[i], "=")) == Server)
		{
			SavedPasswords[i] = Server$"="$Password;
			bFound = True;
			break;
		}
	}
	if(!bFound)
	{
		for(i=9; i>0; i--)
			SavedPasswords[i] = SavedPasswords[i-1];
		SavedPasswords[0] = Server$"="$Password;	
	}
	SaveConfig();
	Viewport.Actor.ClientTravel(URL$"?password="$Password, TRAVEL_Absolute, false);
}

exec function MenuCmd(int Menu, int Item)
{
	if (bLocked)
		return;

	bQuickKeyEnable = False;
	LaunchUWindow();
	if(!bCreatedRoot) 
		CreateRootWindow(None);
}

function StartTimeDemo()
{
	TimeDemoFont = None;
	Super.StartTimeDemo();
	bTimeDemoIsEntry =		Viewport.Actor.Level.Game != None
						&&	Viewport.Actor.Level.Game.IsA('UTIntro') 
						&&	!(Left(Viewport.Actor.Level.GetLocalURL(), 9) ~= "cityintro");
}

function TimeDemoRender( Canvas C )
{
	if (MyFontInfo == None)
		MyFontInfo = Viewport.Actor.Spawn(class'dnFontInfo');
	if(	TimeDemoFont == None )
		TimeDemoFont = MyFontInfo.GetSmallFont(C);

	if( !bTimeDemoIsEntry )
		Super.TimeDemoRender(C);
	else
	{
		if( Viewport.Actor.Level.Game == None ||
			!Viewport.Actor.Level.Game.IsA('UTIntro') ||
			(Left(Viewport.Actor.Level.GetLocalURL(), 9) ~= "cityintro")
		)
		{
			bTimeDemoIsEntry = False;
			Super.TimeDemoRender(C);
		}
	}
}

function PrintTimeDemoResult()
{
	if( !bTimeDemoIsEntry )
		Super.PrintTimeDemoResult();
}

function PrintActionMessage( Canvas C, string BigMessage )
{
	local float XL, YL;
	local color	ColorToUse;	

	if( !bCreatedRoot ) 
		CreateRootWindow( C );

	C.Font = font'HUDFont';
	C.Style = 3;
	C.bCenter = false;
	C.TextSize( BigMessage, XL, YL );
	
	ColorToUse = UDukeLookAndFeel(Root.LookAndFeel).colorTextSelected;

	// Draw normal
	C.SetPos(FrameX/2 - XL/2, (FrameY/2) - YL/2);
	
	C.DrawColor = ColorToUse;
	C.DrawText( BigMessage, false );
}


event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	// JEP...
	if ((Key == EInputKey.IK_Escape || Key == ConsoleKey) && bAskingAboutQuickLoad)
	{
		bAskingAboutQuickLoad = false;
		Viewport.Actor.SetPause(bAskingAboutQuickLoad);

		if (Key == EInputKey.IK_Escape)
			return true;
	}
	//...JEP
	
	if( Key == InGameWindowKey ) // In Game Window
	{
		if ( !bShowInGameWindow && !bTyping )
		{
			ShowInGameWindow();
			bQuickKeyEnable				= true;
			Root.Console.bDontDrawMouse = false;
			LaunchUWindow( true );
		}
		return true;
	}
	else if( Key == ScoreboardKey && Action == IST_Press ) // Scoreboard
	{
		if ( !bShowScoreboard && !bTyping )
		{
			ShowScoreboard();
		}
		return true;
	}

	return Super.KeyEvent(Key, Action, Delta );
}

state UWindow
{
	event PostRender( canvas Canvas )
	{
		Super.PostRender(Canvas);
		DrawQuickLoadConfirm(Canvas);
	}

	event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local byte k;
		k = Key;

		// JEP...
		if ( Key == EInputKey.IK_Escape )
		{
			if ( bAskingAboutQuickLoad )
			{
				bAskingAboutQuickLoad = false;
				return true;
			}
		}
		
		if (Key == ConsoleKey)
		{
			bAskingAboutQuickLoad = false;
		}
		//...JEP

		if ((Root != none) && 
			(UDukeRootWindow(Root).Desktop != none) && 
			!bQuickKeyEnable && 
			(UDukeRootWindow(Root).Desktop.bDoingBootupSequence ||
			 UDukeRootWindow(Root).Desktop.bDoing3DRLogo ||
			 UDukeRootWindow(Root).Desktop.bDoingNukemLogo) )
		{
			switch (Action)
			{
			case IST_Press:
				// Abort the movie.
				if ( UDukeRootWindow(Root).Desktop.bDoingBootupSequence )
					UDukeRootWindow(Root).Desktop.EndBootupSequence();
				else if ( UDukeRootWindow(Root).Desktop.bDoing3DRLogo )
				{
					Root.GetPlayerOwner().StopSound( SLOT_Interact );
					UDukeRootWindow(Root).Desktop.End3DRLogo( true );
				}
				else if ( UDukeRootWindow(Root).Desktop.bDoingNukemLogo )
					UDukeRootWindow(Root).Desktop.EndNukemLogo( true );
			}
			return false; // Absorb the key.
		}
		else
		{
			if ( Key==InGameWindowKey && Action == IST_Release )
			{
				if ( bShowInGameWindow )
				{
					Root.Console.bDontDrawMouse = false;
					HideInGameWindow();
				}
				return true;
			}

/*
			if ( Key==ScoreboardKey && Action == IST_Release )
			{
				if ( bShowScoreboard )
				{
					Root.Console.bDontDrawMouse = false;
					HideScoreboard();
				}
				return true;
			}
*/
			
			if ( bShowInGameWindow && ( InGameWindow != None) )
			{				
				//forward input to in-game window
				//if ( InGameWindow.KeyEvent( Key, Action, Delta ) )
				//	return true;
			}
			else  if ( bShowScoreboard && ( ScoreboardWindow != None ) )
			{				
				//forward input to scoreboard window
				if ( ScoreboardWindow.KeyEvent( Key, Action, Delta ) )
					return true;
			}

			return Super.KeyEvent(Key, Action, Delta);
		}
	}
}

state Typing
{
	exec function MenuCmd(int Menu, int Item)
	{
	}
}

function ShowConsole()
{
	if ( UDukeRootWindow(Root).Desktop.bDoingBootupSequence )
		UDukeRootWindow(Root).Desktop.EndBootupSequence();

	Super.ShowConsole();
}

event NotifyLevelChange()
{
	Super.NotifyLevelChange();

	// We need to recreate InGameWindow when level changes
	if ( InGameWindow != None )
		InGameWindow = None;
}

/*
 * InGameWindow
 */

function CreateInGameWindow()
{
	if ( InGameWindow == None )
	{
		//InGameWindow = UDukeInGameWindow( Root.CreateWindow( Class'UDukeInGameWindow', 100, 100, 200, 200 ) );
		InGameWindow = UDukeInGamePulldownMenu( Root.CreateWindow( Class'UDukeInGamePulldownMenu', 
			100, 100, 200, 200 ) );
	}

	InGameWindow.bLeaveOnScreen = true;

	if ( bShowInGameWindow )
	{
		Root.SetMousePos( 0, 132.0/768 * Root.WinWidth );
		InGameWindow.HideWindow();
		//InGameWindow.SlideInWindow();
	} 
	else
	{
		InGameWindow.HideWindow();
	}
}

function ShowInGameWindow()
{
	if ( bUWindowActive )
		return;
	
	bShowInGameWindow = true;
	
	if( !bCreatedRoot )
		CreateRootWindow( None );

	if ( InGameWindow == None )
		CreateInGameWindow();

	Root.SetMousePos( 0, 132.0/768 * Root.WinWidth );
	
	//InGameWindow.SlideInWindow();
	InGameWindow.ShowWindow();
}

function HideInGameWindow()
{
	bShowInGameWindow = false;

	if ( InGameWindow != None )
	{
		//InGameWindow.SlideOutWindow();
		InGameWindow.CloseUp( true );
		Root.Console.bCloseForSureThisTime = true;
		Root.Console.CloseUWindow();
		Root.Console.bQuickKeyEnable = false;
	}
}

function CreateRootWindow(Canvas Canvas)
{
	Super.CreateRootWindow(Canvas);
}

function CreateScoreboard( string ScoreboardWindowType, Canvas C )
{
	local class <UWindowWindow> WinClass;

	if( !bCreatedRoot )
		CreateRootWindow( C );

	WinClass = class<UDukeScoreboard>( DynamicLoadObject( ScoreboardWindowType, class'Class' ) );

	if ( WinClass != None )
	{
		ScoreboardWindow = UDukeScoreboard( Root.CreateWindow( WinClass,
 															   100, 100, 
															   Root.WinWidth - 50, Root.WinHeight - 50 ) );

		ScoreboardWindow.bLeaveOnScreen = true;
	}

	if ( bShowScoreboard )
	{
		Root.SetMousePos( 0, 132.0/768 * Root.WinWidth );
		ScoreboardWindow.ShowWindow();
	} 
	else
	{
		ScoreboardWindow.HideWindow();
	}
}

function ShowScoreboard()
{
	if ( ScoreboardWindow == None || bUWindowActive || bShowScoreboard )
		return;

	bShowScoreboard = true;
	
	if( !bCreatedRoot )
		CreateRootWindow( None );

	Root.SetMousePos( Root.WinWidth / 2, Root.WinHeight / 2 );
	
	if ( ScoreboardWindow != None )
		ScoreboardWindow.ShowWindow();

	Root.Console.bDontDrawMouse = false;
	bQuickKeyEnable				= true;
	LaunchUWindow( true );
}

function HideScoreboard()
{
	if ( !bShowScoreboard )
		return;

	bShowScoreboard = false;

	if ( ScoreboardWindow != None )
	{
		ScoreboardWindow.Close();
	}	
}

defaultproperties
{
	ConsoleClass=class'UDukeConsoleWindow'
	RootWindow="dnWindow.UDukeRootWindow"

	LoadStateText(0)="Load State Text 0"
	LoadStateText(1)="Load State Text 1"
	LoadStateText(2)="Load State Text 2"
	LoadStateText(3)="Load State Text 3"
	LoadStateText(4)="Load State Text 4"
	LoadStateText(5)="Load State Text 5"
	LoadStateText(6)="Load State Text 6"
	LoadStateText(7)="Load State Text 7"
	LoadStateText(8)="Load State Text 8"
}