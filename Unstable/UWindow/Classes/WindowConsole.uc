//=============================================================================
// WindowConsole - console replacer to implement UWindow UI System
//=============================================================================
class WindowConsole extends Console;

var UWindowRootWindow	Root;
var() config string		RootWindow;

var float				OldClipX;
var float				OldClipY;
var bool				bCreatedRoot;
//var float				MouseX;
//var float				MouseY;

var class<UWindowFramedWindow> ConsoleClass;
var config float		MouseScale;
var config bool			ShowDesktop;
var config bool			bShowConsole;
var bool				bBlackout;
var bool				bUWindowType;

var bool				bUWindowActive;
var bool				bQuickKeyEnable;
var bool				bLocked;
var bool				bCloseForSureThisTime;		//TLW: Added for closing animation
var bool				bLevelChange;
var bool				bDontDrawMouse;
var string				OldLevel;
var globalconfig byte	ConsoleKey;

var config EInputKey	UWindowKey;

var UWindowFramedWindow ConsoleWindow;

var bool				bShowBootup;
var bool				bShowDeathSequence;

function ResetUWindow()
{
	if(Root != None)
		Root.Close();
	Root = None;
	bCreatedRoot = false;
	ConsoleWindow = None;
	bShowConsole = false;
	CloseUWindow();
}

function CancelBootSequence();
function SetupDeathSequence();

event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	local byte k;
	k = Key;
	switch(Action)
	{
	case IST_Axis:
		if(MouseCapture)
			switch(Key)
			{
				case IK_MouseX:
					MouseX = MouseX + (MouseScale * Delta);
					break;
				case IK_MouseY:
					MouseY = MouseY - (MouseScale * Delta);
					break;					
			}

	case IST_Press:
		if(MouseCapture)
		{
			switch(Key)
			{
				case IK_LeftMouse:
				case IK_MiddleMouse:
				case IK_RightMouse:
					if (Viewport.Actor.MyHUD != none)
						Viewport.Actor.InventoryActivate();
					return true;
					break;
			}
		}
			
		switch(k)
		{
		case EInputKey.IK_Escape:
			if (Viewport.Actor.InventoryEscape())
				return true;

			if (bLocked)
				return true;

			bQuickKeyEnable = false;
			LaunchUWindow();
			return true;
		case ConsoleKey:
			if ( bLocked )
				return true;

			bQuickKeyEnable = true;
			LaunchUWindow();
			if ( !bShowConsole )
				ShowConsole();
			return true;
		}
		break;
	}

	return False; 
	//!! because of ConsoleKey
	//!! return Super.KeyEvent(Key, Action, Delta);
}

function ShowConsole()
{
	bDontDrawMouse = false;
	bShowConsole = true;
	if ( bCreatedRoot )
		ConsoleWindow.ShowWindow();
}

function HideConsole( optional bool bNoCloseAnim )
{
	ConsoleLines = 0;
	bShowConsole = false;
	if ( ConsoleWindow != None )
	{
		if ( bNoCloseAnim )
			ConsoleWindow.DelayedClose();
		else
			ConsoleWindow.Close();
	}
}

event Tick( float Delta )
{
	Super.Tick(Delta);

	if(bLevelChange && Root != None && string(Viewport.Actor.Level) != OldLevel)
	{
		OldLevel = string(Viewport.Actor.Level);
		// if this is Entry, we could be falling through to another level...
		if(Viewport.Actor.Level != Viewport.Actor.GetEntryLevel())
			bLevelChange = False;
		Root.NotifyAfterLevelChange();
	}
}

state UWindow
{
	event Tick( float Delta )
	{
		Global.Tick(Delta);
		if(Root != None)
			Root.DoTick(Delta);
	}

	event PostRender( canvas Canvas )
	{
		if( bTimeDemo )
		{	
			TimeDemoCalc();
			TimeDemoRender( Canvas );
		}

		if(Root != None)
			Root.bUWindowActive = True;
		RenderUWindow( Canvas );

		// Call overridable "level action" rendering code to draw the "big message."
		DrawLevelAction( Canvas );

	}

	function LaunchUWindow( optional bool bNoStartShades )
	{
	}

	event bool KeyType( EInputKey Key )
	{
		if (Root != None)
			Root.WindowEvent(WM_KeyType, None, MouseX, MouseY, Key);
		return True;
	}

	event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local byte k;
		k = Key;

		switch (Action)
		{
		case IST_Release:
			switch (k)
			{
			case EInputKey.IK_LeftMouse:
				if(Root != None) 
					Root.WindowEvent(WM_LMouseUp, None, MouseX, MouseY, k);
				break;
			case EInputKey.IK_RightMouse:
				if(Root != None)
					Root.WindowEvent(WM_RMouseUp, None, MouseX, MouseY, k);
				break;
			case EInputKey.IK_MiddleMouse:
				if(Root != None)
					Root.WindowEvent(WM_MMouseUp, None, MouseX, MouseY, k);
				break;
			default:
				if(Root != None)
					Root.WindowEvent(WM_KeyUp, None, MouseX, MouseY, k);
				break;
			}
			break;

		case IST_Press:
			switch (k)
			{
			//case EInputKey.IK_F9:	// Screenshot			// (JEP) Commented out
			//	return Global.KeyEvent(Key, Action, Delta);
			//	break;
			case EInputKey.IK_F9:	// QuickLoad			// (JEP) Special case quickload!
				return false;		// Let the input system handle it
			case EInputKey.IK_F10:	// SShot				// (JEP) Special case screenshot!
				return false;		// Let the input system handle it

			case ConsoleKey:
				if ( bShowConsole )
				{
					HideConsole();
				}
				else
				{
					if ( Root.bAllowConsole && Root.ActiveWindow.IsA('UDukeDesktopWindow') )
						ShowConsole();
					else
						Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);
				}
				break;
			case EInputKey.IK_Escape:
				if(Root != None)
				{
					CloseFromEscape( k );
				}
				break;
			case EInputKey.IK_LeftMouse:
				if(Root != None)
					Root.WindowEvent(WM_LMouseDown, None, MouseX, MouseY, k);
				break;
			case EInputKey.IK_RightMouse:
				if(Root != None)
					Root.WindowEvent(WM_RMouseDown, None, MouseX, MouseY, k);
				break;
			case EInputKey.IK_MiddleMouse:
				if(Root != None)
					Root.WindowEvent(WM_MMouseDown, None, MouseX, MouseY, k);
				break;
			default:
				if(Root != None)
					Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);
				break;
			}
			break;
		case IST_Axis:
			switch (Key)
			{
			case IK_MouseX:
				MouseX = MouseX + (MouseScale * Delta);
				break;
			case IK_MouseY:
				MouseY = MouseY - (MouseScale * Delta);
				break;					
			}
		default:
			break;
		}

		return true;
	}

Begin:
}

function CloseFromEscape( byte k )
{
	if ( Root.DontCloseOnEscape )
		Root.WindowEvent(WM_KeyDown, None, MouseX, MouseY, k);
	else if ((Root.GetLevel().Game != None) && (Root.GetLevel().Game.IsA('DukeIntro')) && 
		(Root.ActiveWindow.IsA('UDukeDesktopWindow')) )
		Root.ConfirmQuit();
	else
	{
		if ( Root.ActiveWindow.IsA('UDukeDesktopWindow') )
			CloseUWindow();
		else
			Root.CloseActiveWindow();
	}
}

function ToggleUWindow()
{
}

function LaunchUWindow( optional bool bNoStartShades )
{
	local int i;

	Viewport.bSuspendPrecaching = True;
	bUWindowActive = !bQuickKeyEnable;
	Viewport.bShowWindowsMouse = True;

	if(bQuickKeyEnable)
		bNoDrawWorld = false;
	else
	{
		if(Viewport.Actor.Level.NetMode == NM_Standalone)
			Viewport.Actor.SetPause( true );
		bNoDrawWorld = true;
	}
	if(Root != None)
		Root.ShowUWindowSystem( bNoStartShades );

	GotoState('UWindow');
}

function CloseUWindow()
{
	local UWindowFramedWindow Child;

	// Force closed any windows that are closing.
	Child = UWindowFramedWindow( Root.FindChildWindow( class'UWindowFramedWindow' ) );
	if ( (Child != None) && Child.bPlayingClose )
		Child.DelayedClose();

	if ( !bQuickKeyEnable )
		Viewport.Actor.SetPause( false );

	bNoDrawWorld = false;
	bUWindowActive = false;
	bQuickKeyEnable = false;
	if ( Root != None )  
		Root.bWindowVisible = false;

	GotoState('');
	Viewport.bSuspendPrecaching = false;
}

function CreateRootWindow(Canvas Canvas)
{
	local int i;

	if(Canvas != None)
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;
	}
	else
	{
		OldClipX = 0;
		OldClipY = 0;
	}
	
	Root = New(None) class<UWindowRootWindow>(DynamicLoadObject(RootWindow, class'Class'));

	Root.BeginPlay();
	Root.WinTop = 0;
	Root.WinLeft = 0;

	if(Canvas != None)
	{
		Root.WinWidth = Canvas.ClipX / Root.GUIScale;
		Root.WinHeight = Canvas.ClipY / Root.GUIScale;
		Root.RealWidth = Canvas.ClipX;
		Root.RealHeight = Canvas.ClipY;
	}
	else
	{
		Root.WinWidth = 0;
		Root.WinHeight = 0;
		Root.RealWidth = 0;
		Root.RealHeight = 0;
	}

	Root.ClippingRegion.X = 0;
	Root.ClippingRegion.Y = 0;
	Root.ClippingRegion.W = Root.WinWidth;
	Root.ClippingRegion.H = Root.WinHeight;

	Root.Console = Self;

	Root.bUWindowActive = bUWindowActive;

	Root.Created();
	Root.LoadFonts( Canvas );
	bCreatedRoot = True;

	// Create the console window.
	ConsoleWindow = UWindowFramedWindow(Root.CreateWindow(ConsoleClass, 100, 100, 200, 200));
	HideConsole( true );

	UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(" ");
	for (I=0; I<4; I++)
		UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(MsgText[I]);
}

function RenderUWindow( canvas Canvas )
{
	local UWindowWindow NewFocusWindow;

	Canvas.Z = 1;
	Canvas.Style = 1;
	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;

	if(Viewport.bWindowsMouseAvailable && Root != None)
	{
		MouseX = Viewport.WindowsMouseX/Root.GUIScale;
		MouseY = Viewport.WindowsMouseY/Root.GUIScale;
	}

	if(!bCreatedRoot) 
		CreateRootWindow(Canvas);

	Root.bWindowVisible = True;
	Root.bUWindowActive = bUWindowActive;
	Root.bQuickKeyEnable = bQuickKeyEnable;

	if(Canvas.ClipX != OldClipX || Canvas.ClipY != OldClipY)
	{
		OldClipX = Canvas.ClipX;
		OldClipY = Canvas.ClipY;
		
		Root.WinTop = 0;
		Root.WinLeft = 0;
		Root.WinWidth = Canvas.ClipX / Root.GUIScale;
		Root.WinHeight = Canvas.ClipY / Root.GUIScale;

		Root.RealWidth = Canvas.ClipX;
		Root.RealHeight = Canvas.ClipY;

		Root.ClippingRegion.X = 0;
		Root.ClippingRegion.Y = 0;
		Root.ClippingRegion.W = Root.WinWidth;
		Root.ClippingRegion.H = Root.WinHeight;

		Root.Resized();
	}

	if(MouseX > Root.WinWidth) MouseX = Root.WinWidth;
	if(MouseY > Root.WinHeight) MouseY = Root.WinHeight;
	if(MouseX < 0) MouseX = 0;
	if(MouseY < 0) MouseY = 0;


	// Check for keyboard focus
	NewFocusWindow = Root.CheckKeyFocusWindow();

	if(NewFocusWindow != Root.KeyFocusWindow)
	{
		Root.KeyFocusWindow.KeyFocusExit();		
		Root.KeyFocusWindow = NewFocusWindow;
		Root.KeyFocusWindow.KeyFocusEnter();
	}


	Root.MoveMouse(MouseX, MouseY);
	Root.WindowEvent(WM_Paint, Canvas, MouseX, MouseY, 0);
	if((bUWindowActive || bQuickKeyEnable) && !bDontDrawMouse) 
		Root.DrawMouse(Canvas);
}

event Message( PlayerReplicationInfo PRI, coerce string Msg, name N )
{
	local string OutText;

	Super.Message( PRI, Msg, N );

	if ( Viewport.Actor == None )
		return;

	if( Msg!="" )
	{
		if (( MsgType[TopLine] == 'Say' ) || ( MsgType[TopLine] == 'TeamSay' ))
			OutText = MsgPlayer[TopLine].PlayerName$": "$MsgText[TopLine];
		else if ( MsgType[TopLine] == 'Private' )
			OutText = "(Private):"$MsgPlayer[TopLine].PlayerName$": "$MsgText[TopLine];
		else
			OutText = MsgText[TopLine];
		if (ConsoleWindow != None)
			UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(OutText);
	}
}

event AddString( coerce string Msg )
{
	Super.AddString( Msg );

	if( Msg!="" )
	{
		if (ConsoleWindow != None)
			UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText(Msg);
	}
}

function UpdateHistory()
{
	// Update history buffer.
	History[HistoryCur++ % MaxHistory] = TypedStr;
	if( HistoryCur > HistoryBot )
		HistoryBot++;
	if( HistoryCur - HistoryTop >= MaxHistory )
		HistoryTop = HistoryCur - MaxHistory + 1;
}

function HistoryUp()
{
	if( HistoryCur > HistoryTop )
	{
		History[HistoryCur % MaxHistory] = TypedStr;
		TypedStr = History[--HistoryCur % MaxHistory];
	}
}

function HistoryDown()
{
	History[HistoryCur % MaxHistory] = TypedStr;
	if( HistoryCur < HistoryBot )
		TypedStr = History[++HistoryCur % MaxHistory];
	else
		TypedStr="";
}

function NotifyLevelChange()
{
	Super.NotifyLevelChange();
	bLevelChange = True;
	if(Root != None)
		Root.NotifyBeforeLevelChange();
}

defaultproperties
{
     RootWindow="UWindow.UWindowRootWindow"
     ConsoleClass=Class'UWindow.UWindowConsoleWindow'
     MouseScale=0.600000
     ConsoleKey=192
}
