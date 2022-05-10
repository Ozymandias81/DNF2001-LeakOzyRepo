//=============================================================================
// UWindowFramedWindow - a Windows95 style framed window
//=============================================================================
class UWindowFramedWindow extends UWindowWindow;


var class<UWindowWindow>	ClientClass;
var UWindowWindow			ClientArea;
var localized string		WindowTitle;
var string					StatusBarText;
var float					MoveX, MoveY;	// co-ordinates where the move was requested
var float					MinWinWidth, MinWinHeight;

var bool					bTLSizing;
var bool					bTSizing;
var bool					bTRSizing;
var bool					bLSizing;
var bool					bRSizing;
var bool					bBLSizing;
var bool					bBSizing;
var bool					bBRSizing;

var bool					bMoving;
var bool					bSizable;
var bool					bStatusBar;
var bool					bMessageBoxFrame;
var bool					bNoOpenSound, bNoCloseSound;
var UWindowFrameCloseBox	CloseBox;

// BR: Open/close animation
var bool					bPlayingSmack;
var bool					bPlayingClose;
var float					FrameTime, LastFrameTime;
var bool					bCloseByParent;

function Created()
{
	Super.Created();

	MinWinWidth = 50;
	MinWinHeight = 50;
	ClientArea = CreateWindow(	ClientClass, 
								LookAndFeel.FrameL.W, 
								LookAndFeel.FrameT.H, 
								WinWidth - LookAndFeel.FrameL.W - LookAndFeel.FrameR.W, 
								WinHeight - LookAndFeel.FrameT.H - LookAndFeel.FrameB.H, 
								OwnerWindow
	);
//	CloseBox = UWindowFrameCloseBox(CreateWindow(Class'UWindowFrameCloseBox', WinWidth-20, WinHeight-20, 11, 10));
}

function Texture GetLookAndFeelTexture()
{
	return LookAndFeel.GetTexture(Self);
}

function bool IsActive()
{
	return ParentWindow.ActiveWindow == Self;
}

function BeforePaint(Canvas C, float X, float Y)
{	
	Super.BeforePaint(C, X, Y);
	Resized();
	LookAndFeel.FW_SetupFrameButtons(Self, C);
}

function CloseChildWindows()
{
	ClientArea.Close(true);
}

function HideChildWindows()
{
	ClientArea.HideWindow();
}

function ShowChildWindows()
{
	ClientArea.ShowWindow();
}

function Paint( Canvas C, float X, float Y )
{
	local smackertexture OpenSmack;

	if ( !bPlayingSmack )
	{
		LookAndFeel.FW_DrawWindowFrame( Self, C );
		return;
	}

	OpenSmack = Root.GetOpenSmack();
	if ( OpenSmack.currentFrame+1 < OpenSmack.GetFrameCount() )
	{
		if ( ClientArea.bWindowVisible && (OpenSmack.currentFrame < 4) )
		{
			if ( !bPlayingClose )
				HideChildWindows();
		}
		else if ( !ClientArea.bWindowVisible && (OpenSmack.currentFrame >= 4) )
		{
			if ( !bPlayingClose )
			{
				ShowChildWindows();

				// Glaring example of "it's Friday and I want to go see Fiona" programming:
				if ( UWindowConsoleClientWindow(ClientArea) != None )
					UWindowConsoleClientWindow(ClientArea).EditControl.EditBox.ActivateWindow( 0, false );
			}

			LookAndFeel.FW_DrawWindowFrame(Self, C);
		}
		else if ( ClientArea.bWindowVisible )
			LookAndFeel.FW_DrawWindowFrame(Self, C);

		if ( !bPlayingClose )
			OpenSmack.pause = false;
	}
	else
	{
		if ( !ClientArea.bWindowVisible && !bPlayingClose )
			ShowChildWindows();
		bPlayingSmack = false;
		LookAndFeel.FW_DrawWindowFrame(Self, C);
	}
}

function AfterPaint( Canvas C, float X, float Y )
{
	local smackertexture OpenSmack;

	if ( !bPlayingSmack )
		return;

	OpenSmack = Root.GetOpenSmack();
	if ( OpenSmack.currentFrame+1 < OpenSmack.GetFrameCount() )
	{
		Super.AfterPaint( C, X, Y );
		C.Style = 3;
		DrawStretchedTexture( C, 2, 3, WinWidth-4, WinHeight-8, OpenSmack, 1.f );
		if ( bPlayingClose )
		{
			if ( OpenSmack.currentFrame == 0 )
			{
				bPlayingSmack = false;
				bPlayingClose = false;
				DelayedClose();
				return;
			}
			if ( GetLevel().TimeSeconds - LastFrameTime > 0.03 )
			{
				OpenSmack.currentFrame--;
				LastFrameTime = GetLevel().TimeSeconds;
			}
		}
	}
	else
		Super.AfterPaint( C, X, Y );
}

function DelayedClose()
{
	bPlayingSmack = false;
	bPlayingClose = false;
	Super.Close( bCloseByParent );
}

function Close( optional bool bByParent )
{
	local smackertexture OpenSmack;

	if ( bPlayingClose )
		return;

	// Play the sound.
	if ( !bNoCloseSound )
		LookAndFeel.PlayMenuSound( Self, MS_MenuDown );

	// Delay the close behavior.
	OpenSmack = Root.GetOpenSmack();

	// Set up the smack to be played backwards.
	OpenSmack.pause = true;
	OpenSmack.currentFrame = 4;
	bPlayingSmack = true;
	bPlayingClose = true;
	LastFrameTime = GetLevel().TimeSeconds;
	bCloseByParent = bByParent;

	// Close the client area.
	CloseChildWindows();
	HideChildWindows();
}

function LMouseDown(float X, float Y)
{
	local FrameHitTest H;
	H = LookAndFeel.FW_HitTest(Self, X, Y);

	Super.LMouseDown(X, Y);


	if(H == HT_TitleBar)
	{
		// !BR: Disabled window dragging.
		/*
		MoveX = X;
		MoveY = Y;
		bMoving = True;
		Root.CaptureMouse();
		*/

		return;
	}

	if(bSizable) 
	{
		switch(H)
		{
		case HT_NW:
			bTLSizing = True;
			Root.CaptureMouse();
			return;
		case HT_NE:
			bTRSizing = True;
			Root.CaptureMouse();
			return;
		case HT_SW:
			bBLSizing = True;
			Root.CaptureMouse();
			return;		
		case HT_SE:
			bBRSizing = True;
			Root.CaptureMouse();
			return;
		case HT_N:
			bTSizing = True;
			Root.CaptureMouse();
			return;
		case HT_S:
			bBSizing = True;
			Root.CaptureMouse();
			return;
		case HT_W:
			bLSizing = True;
			Root.CaptureMouse();
			return;
		case HT_E:
			bRSizing = True;
			Root.CaptureMouse();
			return;
		}
	}
}

function Resized()
{
	local Region R;

	if(ClientArea == None)
	{
		Log("Client Area is None for "$Self);
		return;
	}

	R = LookAndFeel.FW_GetClientArea(Self);

	ClientArea.WinLeft = R.X;
	ClientArea.WinTop = R.Y;

	if((R.W != ClientArea.WinWidth) || (R.H != ClientArea.WinHeight)) 
	{
		ClientArea.SetSize(R.W, R.H);
	}
}

function MouseMove(float X, float Y)
{
	local float OldW, OldH;
	local FrameHitTest H;
	H = LookAndFeel.FW_HitTest(Self, X, Y);


	if(bMoving && bMouseDown)
	{
		WinLeft = Int(WinLeft + X - MoveX);
		WinTop = Int(WinTop + Y - MoveY);
	}
	else
		bMoving = False;


	Cursor = Root.NormalCursor;

	if(bSizable && !bMoving)
	{
		switch(H)
		{
		case HT_NW:
		case HT_SE:
			Cursor = Root.DiagCursor1;
			break;
		case HT_NE:
		case HT_SW:
			Cursor = Root.DiagCursor2;
			break;
		case HT_W:
		case HT_E:
			Cursor = Root.WECursor;
			break;
		case HT_N:
		case HT_S:
			Cursor = Root.NSCursor;
			break;
		}
	}	

	// Top Left
	if(bTLSizing && bMouseDown)
	{
		Cursor = Root.DiagCursor1;	
		OldW = WinWidth;
		OldH = WinHeight;
		SetSize(Max(MinWinWidth, WinWidth - X), Max(MinWinHeight, WinHeight - Y));
		WinLeft = Int(WinLeft + OldW - WinWidth);
		WinTop = Int(WinTop + OldH - WinHeight);
	}
	else 
		bTLSizing = False;


	// Top
	if(bTSizing && bMouseDown)
	{
		Cursor = Root.NSCursor;
		OldH = WinHeight;
		SetSize(WinWidth, Max(MinWinHeight, WinHeight - Y));
		WinTop = Int(WinTop + OldH - WinHeight);
	}
	else 
		bTSizing = False;

	// Top Right
	if(bTRSizing && bMouseDown)
	{
		Cursor = Root.DiagCursor2;
		OldH = WinHeight;
		SetSize(Max(MinWinWidth, X), Max(MinWinHeight, WinHeight - Y));
		WinTop = Int(WinTop + OldH - WinHeight);
	}
	else 
		bTRSizing = False;


	// Left
	if(bLSizing && bMouseDown)
	{
		Cursor = Root.WECursor;
		OldW = WinWidth;
		SetSize(Max(MinWinWidth, WinWidth - X), WinHeight);
		WinLeft = Int(WinLeft + OldW - WinWidth);
	}
	else 
		bLSizing = False;

	// Right
	if(bRSizing && bMouseDown)
	{
		Cursor = Root.WECursor;
		SetSize(Max(MinWinWidth, X), WinHeight);
	}
	else 
		bRSizing = False;

	// Bottom Left
	if(bBLSizing && bMouseDown)
	{
		Cursor = Root.DiagCursor2;
		OldW = WinWidth;
		SetSize(Max(MinWinWidth, WinWidth - X), Max(MinWinHeight, Y));
		WinLeft = Int(WinLeft + OldW - WinWidth);
	}
	else 
		bBLSizing = False;

	// Bottom
	if(bBSizing && bMouseDown)
	{
		Cursor = Root.NSCursor;
		SetSize(WinWidth, Max(MinWinHeight, Y));
	}
	else 
		bBSizing = False;

	// Bottom Right
	if(bBRSizing && bMouseDown)
	{
		Cursor = Root.DiagCursor1;
		SetSize(Max(MinWinWidth, X), Max(MinWinHeight, Y));
	}
	else
		bBRSizing = False;

}

function ToolTip(string strTip)
{
	StatusBarText = strTip;
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	if(Msg == WM_Paint || !WaitModal())
		Super.WindowEvent(Msg, C, X, Y, Key);
}

function StartSmack()
{
	local smackertexture OpenSmack;

	if ( !bPlayingSmack )
	{
		if ( !bNoOpenSound )
			LookAndFeel.PlayMenuSound( Self, MS_MenuUp );
		bNoOpenSound = false;

		OpenSmack = Root.GetOpenSmack();
		OpenSmack.pause = false;
		OpenSmack.currentFrame = 0;
		bPlayingSmack = true;
	}
}

function WindowShown()
{
	Super.WindowShown();

	StartSmack();
}

function WindowHidden()
{
	Super.WindowHidden();

	bNoCloseSound = false;
	bPlayingSmack = false;
	bPlayingClose = false;
}

defaultproperties
{
     ClientClass=Class'UWindow.UWindowClientWindow'
}
