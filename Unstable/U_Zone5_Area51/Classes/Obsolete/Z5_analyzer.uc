//=============================================================================
// Z5_analyzer.
//=============================================================================
class Z5_analyzer expands dnSwitchDecoration
	obsolete;

///====================================  May 13th, Matt Wood

defaultproperties
{
     SwitchStates(0)=(Sequence=Active)
     SwitchStates(1)=(Sequence=Active)
     loop=True
     CurrentSwitchState=1
     NumberStates=2
     HealthMarkers(0)=(Threshold=140)
     TriggerRadius=80.000000
     TriggerHeight=60.000000
     TriggerType=TT_PlayerProximityAndLookUse
     TriggerRetriggerDelay=10.000000
     PushSound=None
     EndPushSound=None
     Mesh=DukeMesh'c_zone5_area51.lab_analyzer'
     CollisionRadius=22.000000
     CollisionHeight=10.000000
     Health=200
}
