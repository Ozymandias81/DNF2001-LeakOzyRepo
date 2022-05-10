//=============================================================================
// UDukeDesktopWindowBase.
//=============================================================================
class UDukeDesktopWindowBase expands UWindowListControl
	abstract;

var UWindowMessageBox		ConfirmQuit;
var UBrowserMainWindow		BrowserWindow;

//TLW: Needed an abstract class, since there is no forward declare
//		for class definitions

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(W == ConfirmQuit && Result == MR_Yes)  
    {
		Root.QuitGame();
	}
}

function OpenBrowser( class<UWindowFramedWindow> winBrowserClass )
{
	if( BrowserWindow == None)  {
		BrowserWindow = UBrowserMainWindow(Root.CreateWindow(winBrowserClass, 50, 30, 500, 300));
	}
	else
	{
		BrowserWindow.ShowWindow();
		BrowserWindow.BringToFront();
	}
}

function StartBrowsingInternet( class<UWindowFramedWindow> winBrowserClass )
{
	OpenBrowser(winBrowserClass);
	BrowserWindow.SelectInternet();
}

function StartBrowsingLAN( class<UWindowFramedWindow> winBrowserClass )
{
	OpenBrowser(winBrowserClass);
	BrowserWindow.SelectLAN();
}

function StartBrowsingLocation( class<UWindowFramedWindow> winBrowserClass )
{
	OpenBrowser(winBrowserClass);
	BrowserWindow.ShowOpenWindow();
	BrowserWindow.SelectInternet();
}

function Close(optional bool bByParent)
{
	Root.Console.CloseUWindow();
}

function StartShadesOS();		//Do Nothing stub
function EndShadesOS();		//Do Nothing Stub

defaultproperties
{
}
