class UTAssaultRulesSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UTAssaultRulesCW';
	FixedAreaClass = None;
	Super.Created();
}