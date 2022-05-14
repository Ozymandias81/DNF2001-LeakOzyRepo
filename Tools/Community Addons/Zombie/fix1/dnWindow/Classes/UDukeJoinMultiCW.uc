//=============================================================================
// 
// FILE:			UDukeJoinMultiCW.uc
// 
// AUTHOR:			Scott Alden
// 
// DESCRIPTION:		Tabwindow for joining a server.
//                  Consists of multiple pages
//                  - ServerBrowser
//                  - Filters
// 
// MOD HISTORY: 
// 
//==========================================================================
class UDukeJoinMultiCW expands UDukePageWindow;

var UWindowPageControl              Pages;
var UDukeServerBrowserCW            ServerBrowser;
var UDukeServerFilterCW             ServerFilter;
var UDukeServerBrowserControlsCW    ServerControls;

var localized string ServerBrowserTab, FilterTab;

function Created()
{
    Super.Created();

    // Controls on the bottom
    ServerControls = UDukeServerBrowserControlsCW( CreateWindow( class'UDukeServerBrowserControlsCW', 
                                                   0, 0,
                                                   WinWidth, 24 ) );
    CreatePages();
}

function CreatePages()
{
    local class<UWindowPageWindow> PageClass;

	Pages = UWindowPageControl( CreateWindow( class'UWindowPageControl', 0, 30, WinWidth, WinHeight-30 ) );
	Pages.SetMultiLine( True );

    Pages.AddPage( ServerBrowserTab, class'UDukeServerBrowserSC' );
    Pages.AddPage( FilterTab,        class'UDukeServerFilterSC' );

    ServerBrowser = UDukeServerBrowserCW( UDukeServerBrowserSC( Pages.GetPage( ServerBrowserTab ).Page ).ClientArea );
    ServerFilter  = UDukeServerFilterCW( UDukeServerFilterSC( Pages.GetPage( FilterTab ).Page ).ClientArea );

    ServerFilter.ServerBrowser   = ServerBrowser;
    ServerBrowser.ServerFilter   = ServerFilter;
    ServerControls.ServerBrowser = ServerBrowser;
    ServerBrowser.StatusLabel    = ServerControls.StatusLabel;

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

function BeforePaint( Canvas C, float X, float Y )
{
    Super.BeforePaint( C, X, Y );
}

function Resized()
{
	Super.Resized();

    Pages.WinWidth  = WinWidth;
    Pages.WinHeight = WinHeight-24;

    ServerControls.SetSize( WinWidth, 24 );    
    ServerControls.WinTop  = WinHeight-24;
    ServerControls.WinLeft = 0;
}

defaultproperties
{
     ServerBrowserTab="Server Browser"
     FilterTab="Filters"
     bBuildDefaultButtons=False
     bNoScanLines=True
     bNoClientTexture=True
}
