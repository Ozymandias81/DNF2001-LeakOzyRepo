class UDukeControlsSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeControlsCW';

	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
