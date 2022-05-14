class UDukeRootWindow extends UWindowRootWindow;

var	UDukeStatusBar StatusBar;
var config string UDesktopClassName;
var config string UDukeStatusBarName;
var UDukeDesktopWindow Desktop;

var(MessageBoxQuit) localized string QuitTitle;
var(MessageBoxQuit) localized string QuitText;

function Created() 
{
	local class<UDukeDesktopWindow> UDesktopClass;
	local class<UDukeStatusBar> UDukeStatusBarClass;
	Super.Created();

	UDesktopClass = class<UDukeDesktopWindow>(DynamicLoadObject(UDesktopClassName, class'Class'));
	Desktop = UDukeDesktopWindow(CreateWindow(UDesktopClass, 0, 0, WinWidth, WinHeight));

	// JEP (had to do this, since DrawSunGlasses was beeing called before this was setup, quick hack for now, need to investigate...)
	Desktop.ClippingRegion.W = WinWidth;
	Desktop.ClippingRegion.H = WinHeight;

	UDukeStatusBarClass = class<UDukeStatusBar>(DynamicLoadObject(UDukeStatusBarName, class'Class'));
	StatusBar = UDukeStatusBar(CreateWindow(UDukeStatusBarClass, 0, 0, 50, 16));
	StatusBar.HideWindow();	//Hide it til after desktop and icons are showing

	Resized();
}

function Resized() 
{
	local float fTextureSizeRatioX, fTextureSizeBL, fTextureSizeBR;

	Super.Resized();

	fTextureSizeRatioX = WinWidth  / Desktop.FullSizeTextureWidth;
	fTextureSizeBL = Desktop.texSunglasses[2].USize * fTextureSizeRatioX;
	fTextureSizeBR = Desktop.texSunglasses[3].USize * fTextureSizeRatioX;

	StatusBar.WinLeft = fTextureSizeBL;
	StatusBar.WinWidth = WinWidth - (fTextureSizeBL + fTextureSizeBR);
	StatusBar.WinTop = WinHeight - StatusBar.WinHeight;

	Desktop.WinLeft = 0;;
	Desktop.WinTop = 0;
	Desktop.WinWidth = WinWidth;
	Desktop.WinHeight = WinHeight;
}

function DoQuitGame()
{
	if (LookAndFeel != None)
		LookAndFeel.SaveConfig();
	if ( GetLevel().Game != None )
	{
		GetLevel().Game.SaveConfig();
		if (GetLevel().Game.GameReplicationInfo != None)
        {
            Log( "Saving GRI defaults" @ GetLevel().Game.GameReplicationInfo.AdminName );
			GetLevel().Game.GameReplicationInfo.SaveConfig();
        }
	}
	Super.DoQuitGame();
}

function ShowUWindowSystem( optional bool bNoStartShades )
{
	Super.ShowUWindowSystem( bNoStartShades );
	Desktop.bFirstPaint = false;

	if ( !bNoStartShades )
		Desktop.StartShadesOS();
}

function HideUWindowSystem()
{
	Desktop.EndShadesOS();
}

function ConfirmQuit()
{
	Desktop.ConfirmQuit = Desktop.MessageBox(QuitTitle, QuitText, MB_YesNo, MR_No, MR_Yes);	
}

defaultproperties
{
     UDesktopClassName="dnWindow.UDukeDesktopWindow"
     UDukeStatusBarName="dnWindow.UDukeStatusBar"
     QuitTitle="Confirm Quit"
     QuitText="Are you sure you want to quit?"
     LookAndFeelClass="dnWindow.UDukeLookAndFeel"
}
