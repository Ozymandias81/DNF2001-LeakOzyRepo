//=============================================================================
// Z5_agitator.
//=============================================================================
class Z5_agitator expands dnSwitchDecoration
	obsolete;

//==============================May 13th, Matt Wood

defaultproperties
{
     SwitchStates(0)=(Sequence=Idle)
     SwitchStates(1)=(Sequence=Active,SequenceLoop=True)
     loop=True
     CurrentSwitchState=1
     NumberStates=2
     HealthMarkers(0)=(Threshold=140)
     IdleAnimations(0)=Idle
     TriggerRadius=60.000000
     TriggerHeight=60.000000
     TriggerType=TT_PlayerProximityAndLookUse
     PushSound=None
     EndPushSound=None
     LodScale=0.900000
     Mesh=DukeMesh'c_zone5_area51.lab_agitator'
     CollisionRadius=19.000000
     CollisionHeight=9.000000
     Health=200
}
