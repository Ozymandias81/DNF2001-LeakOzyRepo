class UTMenuStartMatchSC expands UMenuStartMatchScrollClient;

function Created()
{
	ClientClass = class'UTMenuStartMatchCW';
	FixedAreaClass = None;
	Super(UWindowScrollingDialogClient).Created();
}