class DukesInfoBrowser extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'DukesInfoBrowserSC';
	FixedAreaClass = None;

	Super.Created();
}

defaultproperties
{
     bNoScanLines=True
     bNoClientTexture=True
}
