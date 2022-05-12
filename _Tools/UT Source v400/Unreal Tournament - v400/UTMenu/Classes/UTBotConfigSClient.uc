class UTBotConfigSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTBotConfigClient';
	FixedAreaClass = None;
	Super.Created();
}