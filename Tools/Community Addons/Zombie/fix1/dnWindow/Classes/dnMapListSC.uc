class dnMapListSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'dnMapListCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
     bNoScanLines=True
     bNoClientTexture=True
}
