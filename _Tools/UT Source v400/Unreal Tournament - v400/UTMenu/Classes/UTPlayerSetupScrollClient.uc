class UTPlayerSetupScrollClient extends UMenuPlayerSetupScrollClient;

function Created()
{
	ClientClass = class'UTPlayerSetupClient';
	FixedAreaClass = None;

	Super(UWindowScrollingDialogClient).Created();
}
