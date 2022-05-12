class UTIndivBotSetupSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTIndivBotSetupClient';
	FixedAreaClass = None;
	Super.Created();
}