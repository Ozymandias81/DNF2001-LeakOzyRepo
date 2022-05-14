class UDukeStartMatchSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeStartMatchCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
