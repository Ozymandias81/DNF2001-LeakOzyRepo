class UDukeRootWindow extends UWindowRootWindow;

var config string UDesktopClassName;
var UDukeDesktopWindow Desktop;

var(MessageBoxQuit) localized string QuitTitle;
var(MessageBoxQuit) localized string QuitText;

function Created() 
{
	local class<UDukeDesktopWindow> UDesktopClass;
	Super.Created();

	UDesktopClass = class<UDukeDesktopWindow>(DynamicLoadObject(UDesktopClassName, class'Class'));
	Desktop = UDukeDesktopWindow(CreateWindow(UDesktopClass, 0, 0, WinWidth, WinHeight));

	// JEP (had to do this, since DrawSunGlasses was beeing called before this was setup, quick hack for now, need to investigate...)
	Desktop.ClippingRegion.W = WinWidth;
	Desktop.ClippingRegion.H = WinHeight;

	Resized();
}

function Resized() 
{
	local float fTextureSizeRatioX, fTextureSizeBL, fTextureSizeBR;

	Super.Resized();

	fTextureSizeRatioX = WinWidth  / Desktop.FullSizeTextureWidth;
	fTextureSizeBL = Desktop.texSunglasses[2].USize * fTextureSizeRatioX;
	fTextureSizeBR = Desktop.texSunglasses[3].USize * fTextureSizeRatioX;

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
	Desktop.bFirstPaint = false;
	DukeConsole(Root.Console).CancelBootSequence();
	Super.ShowUWindowSystem( bNoStartShades );

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

function smackertexture GetOpenSmack()
{
	return Desktop.WindowOpenSmack;
}


defaultproperties
{
     UDesktopClassName="dnWindow.UDukeDesktopWindow"
     LookAndFeelClass="dnWindow.UDukeLookAndFeel"
     QuitTitle="Confirm Quit "
     QuitText="Are you sure you want to quit?"
}
