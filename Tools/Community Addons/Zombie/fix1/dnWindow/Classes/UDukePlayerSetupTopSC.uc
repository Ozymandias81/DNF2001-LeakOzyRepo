class UDukePlayerSetupTopSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukePlayerSetupTopCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
