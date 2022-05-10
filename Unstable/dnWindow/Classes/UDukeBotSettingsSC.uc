class UDukeBotSettingsSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeBotSettingsCW';
	FixedAreaClass = None;
	Super.Created();
}