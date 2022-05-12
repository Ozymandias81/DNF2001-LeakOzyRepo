class UMenuInputOptionsScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	// UGLY HACK BELOW :-(
	if(GetPlayerOwner().IsA('TournamentPlayer'))
		ClientClass = class<UWindowDialogClientWindow>(DynamicLoadObject("UTMenu.UTInputOptionsCW", class'Class'));
	else
		ClientClass = class'UMenuInputOptionsClientWindow';
		
	FixedAreaClass = None;
	Super.Created();
}

