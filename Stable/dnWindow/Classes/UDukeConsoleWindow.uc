class UDukeConsoleWindow extends UDukeFramedWindow;

var float OldParentWidth, OldParentHeight;

function Created() 
{
	Super.Created();
	bSizable = False;
	bStatusBar = False;
	bLeaveOnScreen = True;

	OldParentWidth = ParentWindow.WinWidth;
	OldParentHeight = ParentWindow.WinHeight;

	UWindowConsoleClientWindow(ClientArea).TextArea.Font = F_Small;
	UWindowConsoleClientWindow(ClientArea).TextArea.VertSB.HideWindow();
	UWindowConsoleClientWindow(ClientArea).TextArea.bExternalVertSB = true;
	UWindowConsoleClientWindow(ClientArea).TextArea.VertSB = VertSB;
	VertSB.ShowWindow();

	SetDimensions();

	SetAcceptsFocus();

	UWindowConsoleClientWindow(ClientArea).EditControl.EditBox.ActivateWindow( 0, false );
}

function ShowWindow()
{
	Super.ShowWindow();

	if(ParentWindow.WinWidth != OldParentWidth || ParentWindow.WinHeight != OldParentHeight)
	{
		SetDimensions();
		OldParentWidth = ParentWindow.WinWidth;
		OldParentHeight = ParentWindow.WinHeight;
	}
	UWindowConsoleClientWindow(ClientArea).EditControl.EditBox.ActivateWindow( 0, false );
}

function ShowChildWindows()
{
	Super.ShowChildWindows();

	VertSB.ShowWindow();
}

function ResolutionChanged(float W, float H)
{
	SetDimensions();
}

function SetDimensions()
{
	if (ParentWindow.WinWidth < 1024)
	{
		SetSize(410, 310);
	} else {
		SetSize(510, 410);
	}
	WinLeft = ParentWindow.WinWidth/2 - WinWidth/2;
	WinTop = ParentWindow.WinHeight/2 - WinHeight/2;
}

function DelayedClose()
{
//	bPlayingSmack = false;
//	bPlayingClose = false;
	Super.DelayedClose();

	if ( Root.bQuickKeyEnable )
	{
		Root.Console.bCloseForSureThisTime = true;
		Root.Console.CloseUWindow();
		Root.Console.bCloseForSureThisTime = false;
	}
}

function BeforePaint( Canvas C, float X, float Y )
{
	VertSB.WinTop = 52;
	VertSB.WinLeft = WinWidth - LookAndFeel.SBPosIndicator.W - 26;
	VertSB.WinWidth = LookAndFeel.SBPosIndicator.W;
	VertSB.WinHeight = WinHeight - 80;

	VertSB.SetRange( 0, UWindowConsoleClientWindow(ClientArea).TextArea.Count, UWindowConsoleClientWindow(ClientArea).TextArea.VisibleRows );

	Super(UWindowFramedWindow).BeforePaint( C, X, Y );
}

function ScrollUp()
{
	if ( VertSB != None )
		VertSB.Scroll( VertSB.ScrollAmount*6 );
}

function ScrollDown()
{
	if ( VertSB != None )
		VertSB.Scroll( -VertSB.ScrollAmount*6 );
}

defaultproperties
{
	WindowTitle="Shades OS Console ";
	ClientClass=class'UWindowConsoleClientWindow'
	bNoOpenSound=true
}