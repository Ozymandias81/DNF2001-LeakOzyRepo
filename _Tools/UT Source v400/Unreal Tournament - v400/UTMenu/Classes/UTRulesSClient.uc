class UTRulesSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTRulesCWindow';
	FixedAreaClass = None;
	Super.Created();
}