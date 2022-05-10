//=============================================================================
// TriggerSelfForward.
//=============================================================================
class TriggerSelfForward expands TriggerForward;

// Trigger passes on the event to my owner.
function Trigger( actor Other, pawn EventInstigator )
{
	if(Owner!=none)
	{
		Owner.Trigger(self,EventInstigator);
	}
}

defaultproperties
{
}
