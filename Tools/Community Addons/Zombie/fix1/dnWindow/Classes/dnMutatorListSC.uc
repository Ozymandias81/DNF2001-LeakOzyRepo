class dnMutatorListSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'dnMutatorListCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
     bNoScanLines=True
     bNoClientTexture=True
}
