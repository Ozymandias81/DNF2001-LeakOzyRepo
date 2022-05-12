class UMenuAudioScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	// UGLY HACK BELOW :-(
	if(GetPlayerOwner().IsA('TournamentPlayer'))
		ClientClass = class<UWindowDialogClientWindow>(DynamicLoadObject("UTMenu.UTAudioClientWindow", class'Class'));
	else
		ClientClass = class'UMenuAudioClientWindow';
		
	FixedAreaClass = None;
	Super.Created();

}