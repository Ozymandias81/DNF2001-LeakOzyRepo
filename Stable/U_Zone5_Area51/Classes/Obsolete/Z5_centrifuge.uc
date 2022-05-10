//=============================================================================
// Z5_centrifuge.
//=============================================================================
class Z5_centrifuge expands dnSwitchDecoration
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
     FragBaseScale=0.200000
     TriggerRadius=60.000000
     TriggerHeight=80.000000
     TriggerType=TT_PlayerProximityAndLookUse
     TriggerRetriggerDelay=10.000000
     PushSound=None
     EndPushSound=None
     LodScale=0.900000
     Mesh=DukeMesh'c_zone5_area51.lab_centrifuge'
     CollisionHeight=22.000000
     Health=200
}
