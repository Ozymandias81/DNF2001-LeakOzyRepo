//=============================================================================
// TriggerForward. (NJS)
//
//     Trigger forward forwards any incoming triggers that it receives directly 
// to it's owner.  Originally written to be used internally by Inpatcher, but 
// could certainlly be used on it's own as well.
//=============================================================================
class TriggerForward expands Triggers;

// Trigger passes on the event to my owner.
function Trigger( actor Other, pawn EventInstigator )
{
	if(Owner!=none)
		Owner.Trigger(Other,EventInstigator);
}

defaultproperties
{
}
