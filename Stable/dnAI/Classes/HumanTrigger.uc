//=============================================================================
// HumanTrigger: 
// Used when you want both NPCs and Players but not all pawns to be able to 
// trigger something.
// 
//=============================================================================
class HumanTrigger expands Trigger;

defaultproperties
{
     ClassProximityType=class'Engine.PlayerPawn'
     ClassProximityType2=class'dnAI.HumanNPC'
     TriggerType=TT_ClassProximity
}
