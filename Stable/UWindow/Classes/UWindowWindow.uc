//=============================================================================
// UWindowWindow - the parent class for all Window objects
//=============================================================================
class UWindowWindow extends UWindowBase;

// Dimensions, offset relative to parent.
var float				WinLeft;
var float				WinTop;
var float				WinWidth;
var float				WinHeight;

// Relationships to other windows
var UWindowWindow		ParentWindow;			// Parent window
var UWindowWindow		FirstChildWindow;		// First child window - bottom window first
var UWindowWindow		LastChildWindow;		// Last child window - WinTop window first
var UWindowWindow		NextSiblingWindow;		// sibling window - next window above us
var UWindowWindow		PrevSiblingWindow;		// previous sibling window - next window below us
var UWindowWindow		ActiveWindow;			// The child of ours which is currently active
var UWindowRootWindow	Root;					// The root window
var UWindowWindow		OwnerWindow;			// Some arbitary owner window
var UWindowWindow		ModalWindow;			// Some window we've opened modally.

var bool				bWindowVisible;
var bool				bNoClip;				// Clipping disabled for this window?
var bool				bMouseDown;				// Pressed down in this window?
var bool				bRMouseDown;			// Pressed down in this window?
var bool				bMMouseDown;			// Pressed down in this window?
var bool				bAlwaysBehind;			// Window doesn't bring to front on click.
var bool				bAcceptsFocus;			// Accepts key messages
var bool				bAlwaysOnTop;			// Always on top
var bool				bLeaveOnscreen;			// Window is left onscreen when UWindow isn't active.
var bool				bUWindowActive;			// Is UWindow active?
var bool				bTransient;				// Never the active window. Used for combo dropdowns7
var bool				bAcceptsHotKeys;		// Does this window accept hotkeys?
var bool				bIgnoreLDoubleClick;
var bool				bIgnoreMDoubleClick;
var bool				bIgnoreRDoubleClick;

var float				ClickTime;
var float				MClickTime;
var float				RClickTime;
var float				ClickX;
var float				ClickY;
var float				MClickX;
var float				MClickY;
var float				RClickX;
var float				RClickY;
var float				ClientAreaAlpha;		// Alpha of the client area backdrop

var UWindowLookAndFeel	LookAndFeel;

var Region	ClippingRegion;

var color WhiteColor;

var int ResizeFrames;

struct MouseCursor
{
	var Texture tex;
	var int HotX;
	var int HotY;
	var byte WindowsCursor;
};

var MouseCursor Cursor;

enum WinMessage
{
	WM_LMouseDown,
	WM_LMouseUp,
	WM_MMouseDown,
	WM_MMouseUp,
	WM_RMouseDown,
	WM_RMouseUp,
	WM_KeyUp,
	WM_KeyDown,
	WM_KeyType,
	WM_Paint	// Window needs painting
};

// Dialog messages
const DE_Created = 0;
const DE_Change	 = 1;
const DE_Click	 = 2;
const DE_Enter	 = 3;
const DE_Exit	 = 4;
const DE_MClick	 = 5;
const DE_RClick	 = 6;
const DE_EnterPressed = 7;
const DE_MouseMove = 8;
const DE_MouseLeave = 9;
const DE_LMouseDown = 10;
const DE_DoubleClick = 11;
const DE_MouseEnter = 12;
const DE_HelpChanged = 13;
const DE_WheelUpPressed = 14;
const DE_WheelDownPressed = 15;

var bool bPaintFrameSkip;

// Ideally Key would be a EInputKey but I can't see that class here.
function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	switch(Msg)
	{
	case WM_Paint:
		if ( bPaintFrameSkip )
			Paint(C, X, Y);
		else
			bPaintFrameSkip = true;
		PaintClients(C, X, Y);
		break;
	case WM_LMouseDown:
		if(!Root.CheckCaptureMouseDown())
		{
			if(!MessageClients(Msg, C, X, Y, Key)) 
				LMouseDown(X, Y);
		}
		break;	
	case WM_LMouseUp:
		if(!Root.CheckCaptureMouseUp())
		{
			if(!MessageClients(Msg, C, X, Y, Key))
				LMouseUp(X, Y);
		}
		break;	
	case WM_RMouseDown:
		if(!MessageClients(Msg, C, X, Y, Key)) RMouseDown(X, Y);
		break;	
	case WM_RMouseUp:
		if(!MessageClients(Msg, C, X, Y, Key)) RMouseUp(X, Y);
		break;	
	case WM_MMouseDown:
		if(!MessageClients(Msg, C, X, Y, Key)) MMouseDown(X, Y);
		break;	
	case WM_MMouseUp:
		if(!MessageClients(Msg, C, X, Y, Key)) MMouseUp(X, Y);
		break;	
	case WM_KeyDown:
		if(!PropagateKey(Msg, C, X, Y, Key))
			KeyDown(Key, X, Y);
		break;	
	case WM_KeyUp:
		if(!PropagateKey(Msg, C, X, Y, Key))
			KeyUp(Key, X, Y);
		break;	
	case WM_KeyType:
		if(!PropagateKey(Msg, C, X, Y, Key))
			KeyType(Key, X, Y);
		break;	
	default:
		break;
	}
}

function SaveConfigs()
{

	// Implemented in a child class
}

final function PlayerPawn GetPlayerOwner()
{
	return Root.Console.ViewPort.Actor;
}

final function LevelInfo GetLevel()
{
	return Root.Console.ViewPort.Actor.Level;
}

final function LevelInfo GetEntryLevel()
{
	return Root.Console.ViewPort.Actor.GetEntryLevel();
}

function Resized()
{
	ResizeFrames = 3;
}

function PrePaint(Canvas C)
{
	// Implemented in a child class
}

function BeforePaint(Canvas C, float X, float Y)
{
	// Implemented in a child class
}

function AfterPaint(Canvas C, float X, float Y)
{
	// Implemented in a child class
}

function Paint(Canvas C, float X, float Y)
{
	// Implemented in a child class
}

function Click(float X, float Y)
{
	// Implemented in a child class
}


function MClick(float X, float Y)
{
	// Implemented in a child class
}

function RClick(float X, float Y)
{
	// Implemented in a child class
}

function DoubleClick(float X, float Y)
{
	// Implemented in a child class
}

function MDoubleClick(float X, float Y)
{
	// Implemented in a child class
}

function RDoubleClick(float X, float Y)
{
	// Implemented in a child class
}

function BeginPlay()
{
	// Implemented in a child class
}

function BeforeCreate()
{
	// Implemented in a child class
}

function Created()
{
	// Implemented in a child class
}

function AfterCreate()
{
	// Implemented in a child class
}

function MouseEnter()
{
	// Implemented in a child class
}

function Activated()
{
	// Implemented in a child class
}

function Deactivated()
{
	// Implemented in a child class
}

function MouseLeave()
{
	bMouseDown = False;
	bMMouseDown = False;
	bRMouseDown = False;
}

function MouseMove(float X, float Y)
{
}

function KeyUp(int Key, float X, float Y)
{
	// Implemented in child class
}

function KeyDown(int Key, float X, float Y)
{
	// Implemented in child class
}

function bool HotKeyDown(int Key, float X, float Y)
{
	// Implemented in child class
	//Log("UWindowWindow: Checking HotKeyDown for "$Self);
	return False;
}

function bool HotKeyUp(int Key, float X, float Y)
{
	// Implemented in child class
	//Log("UWindowWindow: Checking HotKeyUp for "$Self);
	return False;
}

function KeyType(int Key, float X, float Y)
{
	// Implemented in child class
}

function ProcessMenuKey(int Key, string KeyName)
{
	// Implemented in child class
}

function KeyFocusEnter()
{
	// Implemented in child class
}

function KeyFocusExit()
{
	// Implemented in child class
}


function RMouseDown(float X, float Y) 
{
	ActivateWindow(0, False);
	bRMouseDown = True;
}

function RMouseUp(float X, float Y) 
{
	if(bRMouseDown)
	{
		if(!bIgnoreRDoubleClick && Abs(X-RClickX) <= 1 && Abs(Y-RClickY) <= 1 && GetLevel().TimeSeconds < RClickTime + 0.600)
		{
			RDoubleClick(X, Y);
			RClickTime = 0;
		}
		else
		{
			RClickTime = GetLevel().TimeSeconds;
			RClickX = X;
			RClickY = Y;
			RClick(X, Y);
		}
	}
	bRMouseDown = False;

}

function MMouseDown(float X, float Y) 
{
	ActivateWindow(0, False);
	/* DEBUG
	HideWindow();
	*/
	bMMouseDown = True;
}

function MMouseUp(float X, float Y) 
{
	if(bMMouseDown)
	{
		if(!bIgnoreMDoubleClick && Abs(X-MClickX) <= 1 && (Y-MClickY)<=1 && GetLevel().TimeSeconds < MClickTime + 0.600)
		{
			MDoubleClick(X, Y);
			MClickTime = 0;
		}
		else
		{
			MClickTime = GetLevel().TimeSeconds;
			MClickX = X;
			MClickY = Y;
			MClick(X, Y);
		}
	}
	bMMouseDown = False;
}


function LMouseDown(float X, float Y)
{
	ActivateWindow(0, False);
	bMouseDown = True;
}

function LMouseUp(float X, float Y)
{
	if(bMouseDown)
	{
		if(!bIgnoreLDoubleClick && Abs(X-ClickX) <= 1 && (Y-ClickY) <= 1 && GetLevel().TimeSeconds < ClickTime + 0.600)
		{
			DoubleClick(X, Y);
			ClickTime = 0;
		}
		else
		{
			ClickTime = GetLevel().TimeSeconds;
			ClickX = X;
			ClickY = Y;
			Click(X, Y);
		}
	}
	bMouseDown = False;
}

function FocusWindow()
{
	if(Root.FocusedWindow != None && Root.FocusedWindow != Self)
		Root.FocusedWindow.FocusOtherWindow(Self);

	Root.FocusedWindow = Self;
}

function FocusOtherWindow(UWindowWindow W)
{
}

function EscClose()
{
	Close();
}

function DelayedClose()
{
}

function Close(optional bool bByParent)
{
	local UWindowWindow Prev, Child;

	for( Child = LastChildWindow;Child != None;Child = Prev )
	{
		Prev = Child.PrevSiblingWindow;
		Child.Close( true );
	}
	SaveConfigs();
	if ( !bByParent )
	{
		HideWindow();
	}
}

function AllHide()
{
	local UWindowWindow Prev, Child;

	for(Child = LastChildWindow;Child != None;Child = Prev)
	{
		Prev = Child.PrevSiblingWindow;
		Child.HideWindow();
	}
}

function AllShow()
{
	local UWindowWindow Prev, Child;

	for(Child = LastChildWindow;Child != None;Child = Prev)
	{
		Prev = Child.PrevSiblingWindow;
		Child.ShowWindow();
	}
}

final function SetSize(float W, float H)
{
	if(WinWidth != W || WinHeight != H)
	{
		WinWidth = W;
		WinHeight = H;
		Resized();
	}
}

function Tick(float Delta)
{
}

final function DoTick(float Delta) 
{
	local UWindowWindow Child;

	Tick(Delta);

	Child = FirstChildWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if(bUWindowActive || Child.bLeaveOnscreen)
		{
			Child.DoTick(Delta);
		}

		Child = Child.NextSiblingWindow;
	}
}

final function PaintClients(Canvas C, float X, float Y)
{
	local float   OrgX, OrgY;   
	local float   ClipX, ClipY; 
	local UWindowWindow Child;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	Child = FirstChildWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		C.SetPos(0,0);
		C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.SpaceX = 0;
		C.SpaceY = 0;

		Child.BeforePaint(C, X - Child.WinLeft, Y - Child.WinTop);

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if(bUWindowActive || Child.bLeaveOnscreen)
		{

			C.OrgX = C.OrgX + Child.WinLeft*Root.GUIScale;
			C.OrgY = C.OrgY + Child.WinTop*Root.GUIScale;

			if(!Child.bNoClip)
			{
				C.ClipX = FMin(WinWidth - Child.WinLeft, Child.WinWidth)*Root.GUIScale;
				C.ClipY = FMin(WinHeight - Child.WinTop, Child.WinHeight)*Root.GUIScale;


				// Translate to child's co-ordinate system
				Child.ClippingRegion.X = ClippingRegion.X - Child.WinLeft;
				Child.ClippingRegion.Y = ClippingRegion.Y - Child.WinTop;
				Child.ClippingRegion.W = ClippingRegion.W;
				Child.ClippingRegion.H = ClippingRegion.H;

				if(Child.ClippingRegion.X < 0)
				{
					Child.ClippingRegion.W += Child.ClippingRegion.X;
					Child.ClippingRegion.X = 0;
				}

				if(Child.ClippingRegion.Y < 0)
				{
					Child.ClippingRegion.H += Child.ClippingRegion.Y;
					Child.ClippingRegion.Y = 0;
				}

				if(Child.ClippingRegion.W > Child.WinWidth - Child.ClippingRegion.X)
				{
					Child.ClippingRegion.W = Child.WinWidth - Child.ClippingRegion.X;
				}

				if(Child.ClippingRegion.H > Child.WinHeight - Child.ClippingRegion.Y)
				{
					Child.ClippingRegion.H = Child.WinHeight - Child.ClippingRegion.Y;
				}
			}

			if(Child.ClippingRegion.W > 0 && Child.ClippingRegion.H > 0) 
			{		
				Child.WindowEvent(WM_Paint, C, X - Child.WinLeft, Y - Child.WinTop, 0);
				Child.AfterPaint(C, X - Child.WinLeft, Y - Child.WinTop);
			}
	
			C.OrgX = OrgX;
			C.OrgY = OrgY;
		}

		Child = Child.NextSiblingWindow;
	}

	C.ClipX = ClipX;
	C.ClipY = ClipY;
}

final function UWindowWindow FindWindowUnder(float X, float Y)
{
	local UWindowWindow Child;

	// go from Topmost downwards
	Child = LastChildWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if(bUWindowActive || Child.bLeaveOnscreen)
		{
			if((X >= Child.WinLeft) && (X <= Child.WinLeft+Child.WinWidth) &&
			   (Y >= Child.WinTop) && (Y <= Child.WinTop+Child.WinHeight) &&
			   (!Child.CheckMousePassThrough(X-Child.WinLeft, Y-Child.WinTop)))
			{
				return Child.FindWindowUnder(X - Child.WinLeft, Y - Child.WinTop);
			}
		}
	
		Child = Child.PrevSiblingWindow;
	}

	// Doesn't correspond to any children - it's us.
	return Self;
}

final function bool PropagateKey(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local UWindowWindow Child;

	// Check from WinTopmost for windows which accept focus
	Child = LastChildWindow;

	// HACK for always on top windows...need a better solution
	if(ActiveWindow != None && Child != ActiveWindow && !Child.bTransient)
		Child = ActiveWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if((bUWindowActive || Child.bLeaveOnscreen) && Child.bAcceptsFocus)
		{
//			Log("Sending keystrokes to:  "$Child);
			Child.WindowEvent(Msg, C, X - Child.WinLeft, Y - Child.WinTop, Key);
			return True;		
		}
		//else
			//Log("Ignoring child:  "$Child);
		Child = Child.PrevSiblingWindow;
	}

	return False;
}

final function UWindowWindow CheckKeyFocusWindow()
{
	local UWindowWindow Child;

	// Check from WinTopmost for windows which accept key focus
	Child = LastChildWindow;

	if(ActiveWindow != None && Child != ActiveWindow && !Child.bTransient)
		Child = ActiveWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if(bUWindowActive || Child.bLeaveOnscreen)
		{
			if(Child.bAcceptsFocus)
			{
				return Child.CheckKeyFocusWindow();
			}
		}
		Child = Child.PrevSiblingWindow;
	}

	return Self;
}

final function bool MessageClients(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local UWindowWindow Child;

	// go from topmost downwards
	Child = LastChildWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if(bUWindowActive || Child.bLeaveOnscreen)
		{
			if((X >= Child.WinLeft) && (X <= Child.WinLeft+Child.WinWidth) &&
			   (Y >= Child.WinTop) && (Y <= Child.WinTop+Child.WinHeight)  &&
			   (!Child.CheckMousePassThrough(X-Child.WinLeft, Y-Child.WinTop))) 
			{
				Child.WindowEvent(Msg, C, X - Child.WinLeft, Y - Child.WinTop, Key);
				return True;
			}
		}
	
		Child = Child.PrevSiblingWindow;
	}

	return False;
}

function ActivateWindow(int Depth, bool bTransientNoDeactivate)
{
	if(Self == Root)
	{
		if(Depth == 0)
			FocusWindow();
		return;
	}

	if(WaitModal()) return;

	if(!bAlwaysBehind)
	{
		ParentWindow.HideChildWindow(Self);
		ParentWindow.ShowChildWindow(Self);
	}
	
	//Log("Activating Window "$Self);
	
	if(!(bTransient || bTransientNoDeactivate))
	{
		if(ParentWindow.ActiveWindow != None && ParentWindow.ActiveWindow != Self)
		{
			ParentWindow.ActiveWindow.Deactivated();
		}

		ParentWindow.ActiveWindow = Self;
		ParentWindow.ActivateWindow(Depth + 1, False);

		Activated();
	}
	else
	{
		ParentWindow.ActivateWindow(Depth + 1, True);
	}

	if(Depth == 0)
		FocusWindow();
}

final function BringToFront()
{
	if(Self == Root)
		return;

	if(!bAlwaysBehind && !WaitModal())
	{
		ParentWindow.HideChildWindow(Self);
		ParentWindow.ShowChildWindow(Self);
	}
	ParentWindow.BringToFront();
}

final function SendToBack()
{
	ParentWindow.HideChildWindow(Self);
	ParentWindow.ShowChildWindow(Self, True);
}

final function HideChildWindow(UWindowWindow Child)
{
	local UWindowWindow Window;

	if(!Child.bWindowVisible) return;
	Child.bWindowVisible = False;

	if(Child.bAcceptsHotKeys)
		Root.RemoveHotkeyWindow(Child);

	// Check WinTopmost
	if(LastChildWindow == Child) 
	{
		LastChildWindow = Child.PrevSiblingWindow;
		if(LastChildWindow != None)
		{
			LastChildWindow.NextSiblingWindow = None;
		}
		else
		{
			FirstChildWindow = None;
		}
	} 
	else if(FirstChildWindow == Child) // Check bottommost
	{ 
		FirstChildWindow = Child.NextSiblingWindow;
		if(FirstChildWindow != None)
		{
			FirstChildWindow.PrevSiblingWindow = None;
		}
		else
		{
			LastChildWindow = None;
		}
	} 
	else 
	{
		// you mean I have to go looking for it???
		Window = FirstChildWindow;
		while(Window != None)
		{
			if(Window.NextSiblingWindow == Child)
			{
				Window.NextSiblingWindow = Child.NextSiblingWindow;
				Window.NextSiblingWindow.PrevSiblingWindow = Window;
				break;
			}
			Window = Window.NextSiblingWindow;
		}
	}

	// Set the active window
	ActiveWindow = None;
	Window = LastChildWindow;
	while(Window != None)
	{
		if(!Window.bAlwaysOnTop)
		{
			ActiveWindow = Window;
			break;
		}
		Window = Window.PrevSiblingWindow;
	}
	if(ActiveWindow == None) ActiveWindow = LastChildWindow;
}

final function SetAcceptsFocus()
{
	if(bAcceptsFocus) return;
	bAcceptsFocus = True;

	if(Self != Root)
		ParentWindow.SetAcceptsFocus();
}

final function CancelAcceptsFocus()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow; Child != None; Child = Child.PrevSiblingWindow)
		Child.CancelAcceptsFocus();

	bAcceptsFocus = False;
}

final function GetMouseXY(out float X, out float Y)
{
	local UWindowWindow P;

	X = Int(Root.MouseX);
	Y = Int(Root.MouseY);
	
	P = Self;
	while(P != Root)
	{		
		X = X - P.WinLeft;
		Y = Y - P.WinTop;
		P = P.ParentWindow;
	}
}

final function GlobalToWindow(float GlobalX, float GlobalY, out float WinX, out float WinY)
{
	local UWindowWindow P;

	WinX = GlobalX;
	WinY = GlobalY;

	P = Self;
	while(P != Root)
	{		
		WinX -= P.WinLeft;
		WinY -= P.WinTop;
		P = P.ParentWindow;
	}
}

final function WindowToGlobal(float WinX, float WinY, out float GlobalX, out float GlobalY)
{
	local UWindowWindow P;

	GlobalX = WinX;
	GlobalY = WinY;

	P = Self;
	while(P != Root)
	{		
		GlobalX += P.WinLeft;
		GlobalY += P.WinTop;
		P = P.ParentWindow;
	}
}

final function ShowChildWindow(UWindowWindow Child, optional bool bAtBack)
{
	local UWindowWindow W;
	
	if(!Child.bTransient) ActiveWindow = Child;

	if(Child.bWindowVisible) return;
	Child.bWindowVisible = True;

	if(Child.bAcceptsHotKeys)
		Root.AddHotkeyWindow(Child);

	if(bAtBack)
	{
		if(FirstChildWindow == None)
		{
			Child.NextSiblingWindow = None;
			Child.PrevSiblingWindow = None;
			LastChildWindow = Child;
			FirstChildWindow = Child;
		}
		else
		{
			FirstChildWindow.PrevSiblingWindow = Child;
			Child.NextSiblingWindow = FirstChildWindow;
			Child.PrevSiblingWindow = None;
			FirstChildWindow = Child;
		}
	}
	else
	{
		W = LastChildWindow;
		while(True) 
		{
			if((Child.bAlwaysOnTop) || (W == None) || (!W.bAlwaysOnTop))
			{
				if(W == None)
				{	
					if(LastChildWindow == None)
					{
						// We're the only window
						Child.NextSiblingWindow = None;
						Child.PrevSiblingWindow = None;
						LastChildWindow = Child;
						FirstChildWindow = Child;
					}
					else
					{
						// We feel off the end of the list, we're the bottom (first) child window.
						Child.NextSiblingWindow = FirstChildWindow;
						Child.PrevSiblingWindow = None;
						FirstChildWindow.PrevSiblingWindow = Child;
						FirstChildWindow = Child;
					}
				}
				else
				{
					// We're either the new topmost (last) or we need to be inserted in the list.

					Child.NextSiblingWindow = W.NextSiblingWindow;
					Child.PrevSiblingWindow = W;
					if(W.NextSiblingWindow != None)
					{
						W.NextSiblingWindow.PrevSiblingWindow = Child;
					}
					else
					{
						LastChildWindow = Child;
					}
					W.NextSiblingWindow = Child;
				}
				
				// We're done.
				break;
			}
			
			W = W.PrevSiblingWindow;
		}
	}
}

function ShowWindow()
{
	ParentWindow.ShowChildWindow(Self);
	WindowShown();
}

function HideWindow()
{
	WindowHidden();
	ParentWindow.HideChildWindow(Self);
}

final function UWindowWindow CreateWindow(class<UWindowWindow> WndClass, float X, float Y, float W, float H, optional UWindowWindow OwnerW, optional bool bUnique, optional name ObjectName)
{
	local UWindowWindow Child;

	if(bUnique)
	{
		Child = Root.FindChildWindow(WndClass, True);

		if(Child != None)
		{
			Child.ShowWindow();
			Child.BringToFront();
			return Child;
		}
	}

	if(ObjectName != '')
		Child = New(None, ObjectName) WndClass;
	else
		Child = New(None) WndClass;

	Child.BeginPlay();
	Child.WinTop = Y;
	Child.WinLeft = X;
	Child.WinWidth = W;
	Child.WinHeight = H;
	Child.Root = Root;
	Child.ParentWindow = Self;
	Child.OwnerWindow = OwnerW;
	if(Child.OwnerWindow == None)
		Child.OwnerWindow = Self;
	Child.Cursor = Cursor;
	Child.bAlwaysBehind = False;
	Child.LookAndFeel = LookAndFeel;
	Child.BeforeCreate();
	Child.Created();

	// Now add it at the WinTop of the Z-Order and then adjust child list.
	Child.ShowWindow();
//	ShowChildWindow(Child);

	Child.AfterCreate();

	return Child;
}

final function Tile(Canvas C, Texture T)
{
	local int X, Y;

	X = 0;
	Y = 0;

	While(X < WinWidth)
	{
		While(Y < WinHeight)
		{
			DrawClippedTexture( C, X, Y, T );
			Y += T.VSize;
		}
		X += T.USize;
		Y = 0;
	}
}

final function DrawHorizTiledPieces( Canvas C, 
									 float DestX, float DestY, 
									 float DestW, float DestH, 
									 Region R1, Texture T1,
									 optional float fAlpha, optional bool bNoColorSet
									 )
{
	local float Length, DeltaX;

	Length = DestW;
	while( Length > 0 )
	{
		DeltaX = FMin(R1.W, Length);
		DrawStretchedTextureSegment( C, 
									 DestX, DestY, 
									 DeltaX, DestH,
									 R1.X, R1.Y,
									 DeltaX, R1.H, 
									 T1, 
									 fAlpha, 
									 bNoColorSet,
									 ,
									 ,
									 true			// Disable bilinear.
		);
		
		Length -= DeltaX;
		DestX += DeltaX;
	}
}

final function DrawVertTiledPieces( Canvas C, 
									 float DestX, float DestY, 
									 float DestW, float DestH, 
									 Region R1, Texture T1, optional float Alpha
)
{
	local float Length, DeltaY;

	Length = DestH;
	while( Length > 0 )
	{
		DeltaY = FMin(R1.H, Length);
		DrawStretchedTextureSegment( C, 
									 DestX, DestY, 
									 DestW, DeltaY, 
									 R1.X, R1.Y, 
									 R1.W, DeltaY, 
									 T1, Alpha
		);
		Length -= DeltaY;
		DestY += DeltaY;
	}
}


final function DrawClippedTexture( Canvas C, float X, float Y, texture Tex, optional float fAlpha, optional bool bNoColorSet, optional bool bBilinear )
{
	DrawStretchedTextureSegment( C, X, Y, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize, Tex, fAlpha, bNoColorSet, bBilinear );
}

final function DrawStretchedTexture( Canvas C, float X, float Y, float W, float H, texture Tex, optional float fAlpha, optional bool bNoColorSet, optional bool bBilinear )
{
	DrawStretchedTextureSegment( C, X, Y, W, H, 0, 0, Tex.USize, Tex.VSize, Tex, fAlpha, bNoColorSet, bBilinear );
}

final function DrawStretchedTextureSegment( Canvas C, 
											float X, float Y, 
											float W, float H, 
											float tX, float tY, 
											float tW, float tH,  
											texture Tex, 
											optional float fAlpha, 
											optional bool bNoColorSet,
											optional bool bObsoleteIgnore,
											optional float rotation,
											optional bool bNoBilinear )
{
	local byte byteOldStyle;
	local color colorOld;
	local float OrgX, OrgY, ClipX, ClipY;
	local bool bTransparent;
	local bool bBilinear;

	bBilinear = !bNoBilinear;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	C.SetOrigin( OrgX + ClippingRegion.X*Root.GUIScale, OrgY + ClippingRegion.Y*Root.GUIScale );
	C.SetClip( ClippingRegion.W*Root.GUIScale, ClippingRegion.H*Root.GUIScale );
	C.SetPos( (X - ClippingRegion.X)*Root.GUIScale, (Y - ClippingRegion.Y)*Root.GUIScale );

	/*
	bTransparent = ( fAlpha > 0.0f && fAlpha <  1.0f );
	
	if ( bTransparent )
	{
		byteOldStyle = C.Style; 
		if ( fAlpha > 0.0f )
			C.Style = GetPlayerOwner().ERenderStyle.STY_Modulated;
		else
			C.Style = GetPlayerOwner().ERenderStyle.STY_Translucent;

		if ( !bNoColorSet )
		{
			colorOld = C.DrawColor;
			C.DrawColor.R = 255;
			C.DrawColor.G = 255;
			C.DrawColor.B = 255;
		}
	}
	else
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
	*/

	if ( fAlpha >= 0.f && fAlpha < 1.f )
		C.Style = GetPlayerOwner().ERenderStyle.STY_Translucent;
//	else
//		C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;

	C.DrawTileClipped( Tex, W*Root.GUIScale, H*Root.GUIScale, tX, tY, tW, tH, fAlpha, bBilinear, rotation );

/*	if ( bTransparent )
	{
		C.Style = byteOldStyle;
		if ( !bNoColorSet )
			C.DrawColor = colorOld;
	}
*/		
	C.SetClip( ClipX, ClipY );
	C.SetOrigin( OrgX, OrgY );
}

final function ClipText(Canvas C, float X, float Y, coerce string S, optional bool bCheckHotkey)
{
	local float OrgX, OrgY, ClipX, ClipY;
	local byte byteOldStyle;

	byteOldStyle = C.Style;
	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	C.Style = GetPlayerOwner().ERenderStyle.STY_Translucent;
	C.SetOrigin(OrgX + ClippingRegion.X*Root.GUIScale, OrgY + ClippingRegion.Y*Root.GUIScale);
	C.SetClip(ClippingRegion.W*Root.GUIScale, ClippingRegion.H*Root.GUIScale);

	C.SetPos((X - ClippingRegion.X)*Root.GUIScale, (Y - ClippingRegion.Y)*Root.GUIScale);
	C.DrawTextClipped(S, bCheckHotKey);

	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
	C.Style = byteOldStyle;
}

final function int WrapClipText(Canvas C, float X, float Y, coerce string S, optional bool bCheckHotkey, optional int Length, optional int PaddingLength, optional bool bNoDraw)
{
	local float W, H;
	local int SpacePos, CRPos, WordPos, TotalPos;
	local string Out, Temp, Padding;
	local bool bCR, bSentry;
	local int i;
	local int NumLines;
	local float pW, pH;

	// replace \\n's with Chr(13)'s
	i = InStr(S, "\\n");
	while(i != -1)
	{
		S = Left(S, i) $ Chr(13) $ Mid(S, i + 2);
		i = InStr(S, "\\n");
	}

	i = 0;
	bSentry = True;
	Out = "";
	NumLines = 1;
	while( bSentry && Y < WinHeight )
	{
		// Get the line to be drawn.
		if(Out == "")
		{
			i++;
			if (Length > 0)
				Out = Left(S, Length);
			else
				Out = S;
		}

		// Find the word boundary.
		SpacePos = InStr(Out, " ");
		CRPos = InStr(Out, Chr(13));
		
		bCR = False;
		if(CRPos != -1 && (CRPos < SpacePos || SpacePos == -1))
		{
			WordPos = CRPos;
			bCR = True;
		}
		else
		{
			WordPos = SpacePos;
		}
		
		// Get the current word.
		C.SetPos(0, 0);
		if(WordPos == -1)
			Temp = Out;
		else
			Temp = Left(Out, WordPos)$" ";
		TotalPos += WordPos;

		TextSize(C, Temp, W, H);

		// Calculate draw offset.
		if ( (Mid(Out, Len(Temp)) == "") && (PaddingLength > 0) )
		{
			Padding = Mid(S, Length, PaddingLength);
			TextSize(C, Padding, pW, pH);
			if(W + X + pW > WinWidth && X > 0)
			{
				X = 0;
				Y += H;
				NumLines++;
			}
		}
		else
		{
			if(W + X > WinWidth && X > 0)
			{
				X = 0;
				Y += H;
				NumLines++;
			}
		}

		// Draw the line.
		if(!bNoDraw)
			ClipText(C, X, Y, Temp, bCheckHotKey);

		// Increment the draw offset.
		X += W;
		if(bCR)
		{
			X =0;
			Y += H;
			NumLines++;
		}
		Out = Mid(Out, Len(Temp));
		if ((Out == "") && (i > 0))
			bSentry = False;
	}
	return NumLines;
}

final function ClipTextWidth(Canvas C, float X, float Y, coerce string S, float W)
{
	ClipText(C, X, Y, S);
}

final function DrawClippedActor( Canvas C, float X, float Y, Actor A, bool WireFrame, rotator RotOffset, vector LocOffset )
{
	local vector MeshLoc;
	local float FOV;
    local vector Min, Max;

	FOV = GetPlayerOwner().FOVAngle * Pi / 180;
	
	MeshLoc.X = 0; //4 / tan(FOV/2); SDA - Took this out, we should calculate this in an above function
    MeshLoc.Y = 0;
	MeshLoc.Z = 0;

	A.SetRotation(RotOffset);
	A.SetLocation(MeshLoc + LocOffset);

	C.DrawClippedActor(A, WireFrame, ClippingRegion.W * Root.GUIScale, ClippingRegion.H * Root.GUIScale, C.OrgX + ClippingRegion.X * Root.GUIScale, C.OrgY + ClippingRegion.Y * Root.GUIScale, True);
}

final function DrawUpBevel( Canvas C, float X, float Y, float W, float H, Texture T, optional float fAlpha, optional bool Fill, optional bool bNoColorSet)
{
	local Region R;

	R = LookAndFeel.BevelUpTL;
	DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, fAlpha, bNoColorSet );

	R = LookAndFeel.BevelUpT;
	DrawStretchedTextureSegment( C, X+LookAndFeel.BevelUpTL.W, Y, 
									W - LookAndFeel.BevelUpTL.W
									- LookAndFeel.BevelUpTR.W,
									R.H, R.X, R.Y, R.W, R.H, 
									T, fAlpha, bNoColorSet
	);

	R = LookAndFeel.BevelUpTR;
	DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, fAlpha, bNoColorSet );
	
	R = LookAndFeel.BevelUpL;
	DrawStretchedTextureSegment( C, X, Y + LookAndFeel.BevelUpTL.H,
									R.W,  
									H - LookAndFeel.BevelUpTL.H
									- LookAndFeel.BevelUpBL.H,
									R.X, R.Y, R.W, R.H, 
									T, fAlpha, bNoColorSet 
	);

	R = LookAndFeel.BevelUpR;
	DrawStretchedTextureSegment( C, X + W - R.W, Y + LookAndFeel.BevelUpTL.H,
									R.W,  
									H - LookAndFeel.BevelUpTL.H
									- LookAndFeel.BevelUpBL.H,
									R.X, R.Y, R.W, R.H, 
									T, fAlpha, bNoColorSet 
	);
	
	R = LookAndFeel.BevelUpBL;
	DrawStretchedTextureSegment( C, X, Y + H - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, fAlpha, bNoColorSet);

	R = LookAndFeel.BevelUpB;
	DrawStretchedTextureSegment( C, X + LookAndFeel.BevelUpBL.W, Y + H - R.H, 
									W - LookAndFeel.BevelUpBL.W
									- LookAndFeel.BevelUpBR.W,
									R.H, R.X, R.Y, R.W, R.H, 
									T, fAlpha, bNoColorSet
	);

	R = LookAndFeel.BevelUpBR;
	DrawStretchedTextureSegment( C, X + W - R.W, Y + H - R.H, R.W, R.H, 
									R.X, R.Y, R.W, R.H, 
									T, fAlpha, bNoColorSet
	);

	if (Fill)
	{
		R = LookAndFeel.BevelUpArea;
		DrawStretchedTextureSegment( C, X + LookAndFeel.BevelUpTL.W,
			                            Y + LookAndFeel.BevelUpTL.H,
										W - LookAndFeel.BevelUpBL.W
										- LookAndFeel.BevelUpBR.W,
										H - LookAndFeel.BevelUpTL.H
										- LookAndFeel.BevelUpBL.H,
										R.X, R.Y, R.W, R.H, 
										T, fAlpha, bNoColorSet
		);
	}
}

final function DrawMiscBevel( Canvas C, float X, float Y, float W, float H, Texture T, int BevelType, optional float fAlpha)
{
	local Region R;

	R = LookAndFeel.MiscBevelTL[BevelType];
	DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, fAlpha);

	R = LookAndFeel.MiscBevelT[BevelType];
	DrawStretchedTextureSegment( C, X+LookAndFeel.MiscBevelTL[BevelType].W, Y, 
									W - LookAndFeel.MiscBevelTL[BevelType].W
									- LookAndFeel.MiscBevelTR[BevelType].W,
									R.H, R.X, R.Y, R.W, R.H, 
									T, fAlpha
	);

	R = LookAndFeel.MiscBevelTR[BevelType];
	DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, fAlpha);
	
	R = LookAndFeel.MiscBevelL[BevelType];
	DrawStretchedTextureSegment( C, X, Y + LookAndFeel.MiscBevelTL[BevelType].H,
									R.W,  
									H - LookAndFeel.MiscBevelTL[BevelType].H
									- LookAndFeel.MiscBevelBL[BevelType].H,
									R.X, R.Y, R.W, R.H, 
									T, fAlpha
	);

	R = LookAndFeel.MiscBevelR[BevelType];
	DrawStretchedTextureSegment( C, X + W - R.W, Y + LookAndFeel.MiscBevelTL[BevelType].H,
									R.W,  
									H - LookAndFeel.MiscBevelTL[BevelType].H
									- LookAndFeel.MiscBevelBL[BevelType].H,
									R.X, R.Y, R.W, R.H, 
									T, fAlpha 
	);
	
	R = LookAndFeel.MiscBevelBL[BevelType];
	DrawStretchedTextureSegment( C, X, Y + H - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, fAlpha );

	R = LookAndFeel.MiscBevelB[BevelType];
	DrawStretchedTextureSegment( C, X + LookAndFeel.MiscBevelBL[BevelType].W, Y + H - R.H, 
									W - LookAndFeel.MiscBevelBL[BevelType].W
									- LookAndFeel.MiscBevelBR[BevelType].W,
									R.H, R.X, R.Y, R.W, R.H, 
									T, fAlpha
	);

	R = LookAndFeel.MiscBevelBR[BevelType];
	DrawStretchedTextureSegment( C, X + W - R.W, Y + H - R.H, R.W, R.H, 
									R.X, R.Y, R.W, R.H, 
									T, fAlpha 
	);

	R = LookAndFeel.MiscBevelArea[BevelType];
	DrawStretchedTextureSegment( C, X + LookAndFeel.MiscBevelTL[BevelType].W,
	                                Y + LookAndFeel.MiscBevelTL[BevelType].H,
									W - LookAndFeel.MiscBevelBL[BevelType].W
									- LookAndFeel.MiscBevelBR[BevelType].W,
									H - LookAndFeel.MiscBevelTL[BevelType].H
									- LookAndFeel.MiscBevelBL[BevelType].H,
									R.X, R.Y, R.W, R.H, 
									T, fAlpha 
	);
}

final function string RemoveAmpersand(string S)
{
	local string Result;
	local string Underline;

	ParseAmpersand(S, Result, Underline, False);

	return Result;
}

final function byte ParseAmpersand(string S, out string Result, out string Underline, bool bCalcUnderline)
{
	local string Temp;
	local int Pos, NewPos;
	local int i;
	local byte HotKey;
	
	HotKey = 0;
	Pos = 0;
	Result = "";
	Underline = "";

	while(True)
	{
		Temp = Mid(S, Pos);

		NewPos = InStr(Temp, "&");
		
		if(NewPos == -1) break;
		Pos += NewPos;

		if(Mid(Temp, NewPos + 1, 1) == "&")
		{
			// It's a double &, lets add one to the output.
			Result = Result $ Left(Temp, NewPos) $ "&";
			
			if(bCalcUnderline) 
				Underline = Underline $ " ";

			Pos++;
		}
		else
		{
			if(HotKey == 0)
				HotKey = Asc(Caps(Mid(Temp, NewPos + 1, 1)));

			Result = Result $ Left(Temp, NewPos);
			
			if(bCalcUnderline)
			{
				for(i=0;i<NewPos - 1;i++) 
					Underline = Underline $ " ";
				Underline = Underline $ "_";
			}
		}

		Pos++;
	}
	Result = Result $ Temp;

	return HotKey;
}

function bool MouseIsOver()
{
	return (Root.MouseWindow == Self);
}

function ToolTip(string strTip) 
{
	if(ParentWindow != Root) ParentWindow.ToolTip(strTip);
}

// Sets mouse window for mouse capture.
final function SetMouseWindow()
{
	Root.MouseWindow = Self;
}

function Texture GetLookAndFeelTexture()
{
	return ParentWindow.GetLookAndFeelTexture();
}

function Texture GetLookAndFeelTexture2()
{
	return ParentWindow.GetLookAndFeelTexture2();
}

function Texture GetLookAndFeelTexture3()
{
	return ParentWindow.GetLookAndFeelTexture3();
}

function Texture GetLookAndFeelGlowTexture()
{
	return ParentWindow.GetLookAndFeelGlowTexture();
}

function Texture GetLookAndFeelGlowTexture2()
{
	return ParentWindow.GetLookAndFeelGlowTexture2();
}

function Texture GetLookAndFeelGlowTexture3()
{
	return ParentWindow.GetLookAndFeelGlowTexture3();
}

function bool IsActive()
{
	return ParentWindow.IsActive();
}

function SetAcceptsHotKeys(bool bNewAccpetsHotKeys)
{
	if(bNewAccpetsHotKeys && !bAcceptsHotKeys && bWindowVisible)
		Root.AddHotkeyWindow(Self);
	
	if(!bNewAccpetsHotKeys && bAcceptsHotKeys && bWindowVisible)
		Root.RemoveHotkeyWindow(Self);

	bAcceptsHotKeys = bNewAccpetsHotKeys;
}

final function UWindowWindow GetParent(class<UWindowWindow> ParentClass, optional bool bExactClass)
{
	local UWindowWindow P;

	P = ParentWindow;
	while(P != Root)
	{
		if(bExactClass)
		{
			if(P.Class == ParentClass)
				return P;
		}
		else
		{
			if(ClassIsChildOf(P.Class, ParentClass))
				return P;
		}
		P = P.ParentWindow;
	}

	return None;
}

final function UWindowWindow FindChildWindow(class<UWindowWindow> ChildClass, optional bool bExactClass)
{
	local UWindowWindow Child, Found;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
	{
		if(bExactClass)
		{
			if(Child.Class == ChildClass) return Child;
		}
		else
		{
			if(ClassIsChildOf(Child.Class, ChildClass)) return Child;
		}

		Found = Child.FindChildWindow(ChildClass);
		if(Found != None) return Found;
	}

	return None;
}

function GetDesiredDimensions(out float W, out float H)
{
	local float MaxW, MaxH, TW, TH;
	local UWindowWindow Child, Found;
	
	MaxW = 0;
	MaxH = 0;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
	{
		Child.GetDesiredDimensions(TW, TH);
		//Log("Calling: "$GetPlayerOwner().GetItemName(string(Child)));
		

		if(TW > MaxW) MaxW = TW;
		if(TH > MaxH) MaxH = TH;
	}
	W = MaxW;
	H = MaxH;
	//Log(GetPlayerOwner().GetItemName(string(Self))$": DesiredHeight: "$H);
}

final function TextSize(Canvas C, string Text, out float W, out float H)
{
	C.SetPos(0, 0);
	C.TextSize(Text, W, H);
	W = W / Root.GUIScale;
	H = H / Root.GUIScale;
}

function ResolutionChanged(float W, float H)
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
	{
		Child.ResolutionChanged(W, H);
	}
}

function ShowModal(UWindowWindow W)
{
	ModalWindow = W;
	W.ShowWindow();
	W.BringToFront();		
}

function bool WaitModal()
{
	if(ModalWindow != None && ModalWindow.bWindowVisible)
		return True;

	ModalWindow = None;

	return False;
}

function WindowHidden()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.WindowHidden();
}

function WindowShown()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.WindowShown();
}

// Should mouse events at these co-ordinates be passed through to underlying windows?
function bool CheckMousePassThrough(float X, float Y)
{
	return False;
}

final function bool WindowIsVisible()
{
	if(Self == Root)
		return True;

	if(!bWindowVisible)
		return False;
	return ParentWindow.WindowIsVisible();
}

function SetParent(UWindowWindow NewParent)
{
	HideWindow();
	ParentWindow = NewParent;
	ShowWindow();
}

function UWindowMessageBox MessageBox(string Title, string Message, MessageBoxButtons Buttons, MessageBoxResult ESCResult, optional MessageBoxResult EnterResult, optional int TimeOut)
{
	local UWindowMessageBox W;
	local UWindowFramedWindow F;
	
	W = UWindowMessageBox(Root.CreateWindow(class'UWindowMessageBox', 100, 100, 100, 100, Self));
	W.SetupMessageBox(Title, Message, Buttons, ESCResult, EnterResult, TimeOut);
	F = UWindowFramedWindow(GetParent(class'UWindowFramedWindow'));

	if(F!= None)
		F.ShowModal(W);
	else
		Root.ShowModal(W);

	return W;
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
}

function NotifyQuitUnreal()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.NotifyQuitUnreal();
}

function NotifyBeforeLevelChange()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.NotifyBeforeLevelChange();
}

function SetCursor(MouseCursor C)
{
	local UWindowWindow Child;

	Cursor = C;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.SetCursor(C);
}

function NotifyAfterLevelChange()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.NotifyAfterLevelChange();
}

final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;
		
	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{	
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));	
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

function StripCRLF(out string Text)
{
	ReplaceText(Text, Chr(13)$Chr(10), "");
	ReplaceText(Text, Chr(13), "");
	ReplaceText(Text, Chr(10), "");
}

function color VEC_HSVToRGB(Vector inHSV)
{
	local float h, s, v, m, n, f;
	local int i;
	
	h = inHSV.X*6.0f;	
	s = inHSV.Y;	
	v = inHSV.Z;
	
	if (s == 0.0f)
		return(NewColor(v,v,v));
		
	i = int(h);
	f = h - i;
	if ((i & 1) == 0)
		f = 1.0f - f;
	m = v * (1.0f - s);
	n = v * (1.0f - s*f);

	switch(i)  {
		case 6: 
		case 0:  return(NewColor(v,n,m));
		case 1:  return(NewColor(n,v,m));
		case 2:  return(NewColor(m,v,n));
		case 3:  return(NewColor(m,n,v));
		case 4:  return(NewColor(n,m,v));
		case 5:  return(NewColor(v,m,n));
		default: return(NewColor(0,0,0));
	}
}

function Vector VEC_RGBToHSV(color inRGB)
{
	local float r, g, b, v, x, f;
	local Vector vecResult;
	local int i;
	
	//Get values into range from 0.0-1.0
	r = inRGB.R / 255.0;	
	g = inRGB.G / 255.0;	
	b = inRGB.B / 255.0;
	
	x = FMin( r, FMin(g, b));
	v = FMax( r, FMax(g, b));
	
	vecResult.X = 0;
	vecResult.Y = 0;
	vecResult.Z = v;
	
	if(v == x)		 
		return vecResult;
	
	if(r == x)  	 {	f = g - b;	i = 3;	}
	else if(g == x)  {	f = b - r;	i = 5;	}
	else		 	 {	f = r - g;	i = 1;	}
	
	vecResult.X = (i-f / (v-x)) / 6.0f;
	vecResult.Y = (v-x) / v;
//	vecResult.Z = v;
	return vecResult;
}

function color NewColor(float fR, float fG, float fB)
{	
	local color C;
	//Get values out from range 0.0-1.0 to 0-255
	C.R = fR * 255;
	C.G = fG * 255;
	C.B = fB * 255;
	return C;
}

defaultproperties
{
	WhiteColor=(R=255,G=255,B=255)
	ClientAreaAlpha=1.0
}
