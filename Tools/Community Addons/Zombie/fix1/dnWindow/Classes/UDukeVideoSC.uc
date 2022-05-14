class UdUKEVideoSC extends UWindowScrollingDialogClient;

var config string UVideoClientClassName;

function Created()
{
	ClientClass = class<UWindowDialogClientWindow>(DynamicLoadObject(UVideoClientClassName, class'Class'));
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
     UVideoClientClassName="dnWindow.UDukeVideoCW"
}
