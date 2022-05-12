class UMenuCustomizeScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	// UGLY HACK BELOW :-(
	if(GetPlayerOwner().IsA('TournamentPlayer') || GetPlayerOwner().IsA('CHSpectator'))
		ClientClass = class<UWindowDialogClientWindow>(DynamicLoadObject("UTMenu.UTCustomizeClientWindow", class'Class'));
	else
		ClientClass = class'UMenuCustomizeClientWindow';

	FixedAreaClass = None;
	Super.Created();
}
