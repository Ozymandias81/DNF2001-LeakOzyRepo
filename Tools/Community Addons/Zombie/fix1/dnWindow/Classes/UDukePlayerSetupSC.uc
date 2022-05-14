class UDukePlayerSetupSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukePlayerSetupCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
