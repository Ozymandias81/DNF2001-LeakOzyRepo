//=============================================================================
// TriggerUntrigger.
//=============================================================================
class TriggerUntrigger expands Triggers;

function Trigger(Actor Other, Pawn EventInstigator)
{
	GlobalUntrigger( Event, Instigator );
}

defaultproperties
{
    Texture=Texture'Engine.S_TrigTriggerUntrigger'
}
