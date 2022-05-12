class UTSettingsSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTSettingsCWindow';
	FixedAreaClass = None;
	Super.Created();
}