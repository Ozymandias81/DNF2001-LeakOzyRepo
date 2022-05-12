class UTLMSRulesSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTLMSRulesCW';
	FixedAreaClass = None;
	Super.Created();
}