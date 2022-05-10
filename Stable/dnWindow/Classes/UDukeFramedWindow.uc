/*-----------------------------------------------------------------------------
	UDukeFramedWindow
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeFramedWindow extends UWindowFramedWindow;

var float fInitialWidth;
var float fInitialHeight;

var bool bShowVertSB;
var UWindowVScrollBar VertSB;

// Duke framed windows have these two buttons.
var UDukeFrameButton	ResetButton;
var string				ResetHelpText;
var UDukeFrameButton	CloseButton;
var string				CloseHelpText;

function Created()
{
	Super.Created();

	fInitialWidth = WinWidth;
	fInitialHeight = WinHeight;

	SetSizeAndPos( Root.WinWidth, Root.WinHeight );

	VertSB = UWindowVScrollbar(CreateWindow(class'UWindowVScrollbar', WinWidth-11, 0, 12, WinHeight));
	VertSB.bAlwaysOnTop = True;
	VertSB.bFramedWindow = True;
	VertSB.HideWindow();

	// Add the close button.
    CloseButton = UDukeFrameButton(CreateWindow(class'UDukeFrameButton', WinWidth - 64, 23, 18, 18));
    CloseButton.SetHelpText(CloseHelpText);
	CloseButton.bStretched = true;
	CloseButton.bSolid = true;
	CloseButton.bUseRegion = true;
	CloseButton.DownTexture = GetLookAndFeelTexture();
	CloseButton.DownRegion = LookAndFeel.CloseButtonRegion;
	CloseButton.ShowWindow();
	CloseButton.bAlwaysOnTop = true;
	CloseButton.FrameWindow = Self;

	// Add the close button.
    ResetButton = UDukeFrameButton(CreateWindow(class'UDukeFrameButton', WinWidth - 85, 23, 18, 18));
    ResetButton.SetHelpText(ResetHelpText);
	ResetButton.bStretched = true;
	ResetButton.bSolid = true;
	ResetButton.bUseRegion = true;
	ResetButton.DownTexture = GetLookAndFeelTexture();
	ResetButton.DownRegion = LookAndFeel.ResetButtonRegion;
	ResetButton.ShowWindow();
	ResetButton.bAlwaysOnTop = true;
	ResetButton.FrameWindow = Self;
}

function ResolutionChanged( float W, float H )
{
	ClientArea.ResolutionChanged( W, H );

	SetSizeAndPos( W, H );
}

function SetSizeAndPos( float fNewWidth, float fNewHeight, optional float fStatusBarHeight )
{
	SetSize( FMin(fNewWidth, fInitialWidth), FMin(fNewHeight - fStatusBarHeight, fInitialHeight) );

	WinLeft = (Root.WinWidth -  WinWidth)  / 2;
	WinTop = ((Root.WinHeight - WinHeight) / 2) - fStatusBarHeight;
}

function CloseChildWindows()
{
	Super.CloseChildWindows();
	VertSB.Close(true);
}

function HideChildWindows()
{
	Super.HideChildWindows();
	VertSB.HideWindow();
}

function ShowChildWindows()
{
	local float ClientHeight;
	local Region ClientAreaRegion;
	local UDukeEmbeddedClient DiagClient;

	Super.ShowChildWindows();

	DiagClient = UDukeEmbeddedClient(ClientArea);
	if ( DiagClient != None )
	{
		ClientAreaRegion = LookAndFeel.FW_GetClientArea( Self );
		ClientHeight = DiagClient.ClientArea.DesiredHeight;

		if ( ClientHeight > ClientAreaRegion.H )
			VertSB.ShowWindow();
	}
}

function BeforePaint( Canvas C, float X, float Y )
{
	local float ClientHeight;
	local Region ClientAreaRegion;
	local UDukeEmbeddedClient DiagClient;

	DiagClient = UDukeEmbeddedClient(ClientArea);
	if ( DiagClient != None )
	{
		ClientAreaRegion = LookAndFeel.FW_GetClientArea( Self );
		ClientHeight = DiagClient.ClientArea.DesiredHeight;

		bShowVertSB = ClientHeight > ClientAreaRegion.H;

		if ( bShowVertSB && !bPlayingSmack )
		{
			if ( !VertSB.bWindowVisible )
				VertSB.ShowWindow();
			VertSB.WinTop = ClientAreaRegion.Y;
			VertSB.WinLeft = WinWidth - LookAndFeel.SBPosIndicator.W - 25;
			VertSB.WinWidth = LookAndFeel.SBPosIndicator.W;
			VertSB.WinHeight = ClientAreaRegion.H;

			VertSB.SetRange( 0, ClientHeight, VertSB.WinHeight, 10 );
		}
		else
		{
			VertSB.HideWindow();
			VertSB.Pos = 0;
		}

		DiagClient.ClientArea.WinTop = -VertSB.Pos;
	}

	Super.BeforePaint( C, X, Y );
}

function DelayedClose()
{
	Super.DelayedClose();

	if ( (UDukeFakeIcon(OwnerWindow) != None) && (UDukeRootWindow(Root) != None) && (UDukeRootWindow(Root).Desktop != None) )
		UDukeRootWindow(Root).Desktop.ShowIcons();
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

function Notify( UWindowDialogControl C, byte E )
{
	if ( (C == CloseButton) && (E == DE_Click) )
	{
		ClosePressed();
	}
	else if ( (C == ResetButton) && (E == DE_Click) )
	{
		ResetPressed();
	}

	if ( E == DE_MouseMove )
		StatusBarText = C.HelpText;

	if ( E == DE_HelpChanged && C.MouseIsOver() )
		StatusBarText = C.HelpText;

	if ( E == DE_MouseLeave )
		StatusBarText = "";
}

function ClosePressed()
{
	Close();
}

function Close( optional bool bByParent )
{
	VertSB.HideWindow();
	Super.Close( bByParent );
}

function ResetPressed()
{
}

defaultproperties
{
	CloseHelpText="Press to close this window."
	ResetHelpText="Press to restore defaults."
}
