class UDukeServerSettingsSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeServerSettingsCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
