/*-----------------------------------------------------------------------------
	UDukeJoinMultiCW
	Author: Brandon Reinhart, Scott Alden
-----------------------------------------------------------------------------*/
class UDukeJoinMultiCW expands UDukePageWindow;

var UDukeServerBrowserCW            ServerBrowser;
var UDukeServerFilterCW             ServerFilter;
var UDukeServerFilterWindow			ServerFilterWindow;
var UDukeServerBrowserControlsCW    ServerControls;

function Created()
{
    Super.Created();

	// Controls
    ServerControls = UDukeServerBrowserControlsCW( CreateWindow( class'UDukeServerBrowserControlsCW', 0, 0, WinWidth, 70 ) );

	// Filter
	ServerFilterWindow = UDukeServerFilterWindow( Root.CreateWindow( class'UDukeServerFilterWindow', 0, 0, 550, 450 ) );
	ServerFilterWindow.HideWindow();
	ServerFilter = UDukeServerFilterCW( UDukeServerFilterSC(ServerFilterWindow.ClientArea).ClientArea );

	// Browser
	ServerBrowser = UDukeServerBrowserCW( CreateWindow( class'UDukeServerBrowserCW', 10, 70, WinWidth-20, WinHeight-70 ) );
    ServerBrowser.StatusLabel	= ServerControls.StatusLabel;
	ServerBrowser.ServerFilter	= ServerFilter;
	ServerFilter.ServerBrowser	= ServerBrowser;
	ServerControls.JoinGameWindow= Self;
	ServerControls.ServerBrowser= ServerBrowser;

	ServerFilter.InitializeFilter();
}

function UDukeServerBrowserCW GetServerBrowser()
{
    return ServerBrowser;
}

function UDukeServerFilterCW GetServerFilter()
{
    return ServerFilter;
}

function ChangeBrowserMode( int NewMode )
{
	if ( NewMode == 0 )
		UDukeJoinMultiSC(ParentWindow).serverListFactoryType = "dnWindow.UDukeLocalFact";
	else
		UDukeJoinMultiSC(ParentWindow).serverListFactoryType = "dnWindow.UDukeGSpyFact";

	ServerBrowser.Refresh();
}

function BeforePaint( Canvas C, float X, float Y )
{
    Super.BeforePaint( C, X, Y );
}

function Resized()
{
	Super.Resized();

	ServerBrowser.WinTop = 70;
	ServerBrowser.WinLeft = 10;
	ServerBrowser.SetSize( WinWidth-20, WinHeight - 70 );

    ServerControls.SetSize( WinWidth, 70 );
    ServerControls.WinTop  = 0;
    ServerControls.WinLeft = 0;
}
