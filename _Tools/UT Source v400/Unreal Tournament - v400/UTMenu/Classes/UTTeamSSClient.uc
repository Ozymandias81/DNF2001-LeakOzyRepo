class UTTeamSSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTTeamSCWindow';
	FixedAreaClass = None;
	Super.Created();
}