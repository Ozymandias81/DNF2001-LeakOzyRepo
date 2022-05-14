class DukesInfoBrowserSC extends UWindowDialogClientWindow;

function Created()
{
	DesiredWidth = WinWidth;
	DesiredHeight = 500;

	Super.Created();
}

defaultproperties
{
     bNoScanLines=True
     bNoClientTexture=True
}
