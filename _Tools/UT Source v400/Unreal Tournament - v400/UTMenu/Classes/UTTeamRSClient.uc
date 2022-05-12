class UTTeamRSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTTeamRCWindow';
	FixedAreaClass = None;
	Super.Created();
}