class UDukeJoinMultiSC extends UWindowScrollingDialogClient;

var string serverListFactoryType;

function Created()
{
	ClientClass = class'UDukeJoinMultiCW';

	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
