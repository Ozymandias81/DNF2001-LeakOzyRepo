/*-----------------------------------------------------------------------------
	QuestTrigger
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class QuestTrigger extends Trigger;

struct SQuestInfo
{
	var() class<QuestItem>		Item;
	var() bool					bDestroyOnUse;
	var() name					ItemEvent;
};

var() SQuestInfo				QuestInfo[10];

function TriggerTarget( actor Other )
{
	local Actor A;
	local int i;
	local PlayerPawn Instigator;

	if (PlayerPawn(Other.Instigator) == none)
		return;

	Instigator = PlayerPawn(Other.Instigator);

	if (QuestItem(Instigator.UsedItem) == none)
		return;

	for (i=0; i<10; i++)
	{
		if (Instigator.UsedItem.Class == QuestInfo[i].Item)
		{
			// We found the item we want, trigger our event.
			if( QuestInfo[i].ItemEvent != '' )
			{
				foreach AllActors( class 'Actor', A, QuestInfo[i].ItemEvent )
				{
					A.Trigger( Self, Instigator );
				}
			}
			
			// Destroy the item if we are supposed to.
			if (QuestInfo[i].bDestroyOnUse)
			{
				Instigator.UsedItem.Destroy();
				Instigator.UsedItem = none;
				Instigator.WeaponUp();
			}
		}
	}
}

defaultproperties
{
	TriggerType=TT_PlayerProximityAndUse
}