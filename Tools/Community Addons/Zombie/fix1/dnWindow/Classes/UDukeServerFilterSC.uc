class UDukeServerFilterSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeServerFilterCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
