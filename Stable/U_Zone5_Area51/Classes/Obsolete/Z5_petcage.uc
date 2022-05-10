//=============================================================================
// Z5_petcage.
//=============================================================================
//========================  MW, june 7th
class Z5_petcage expands dnSwitchDecoration
	obsolete;

defaultproperties
{
     SwitchStates(0)=(Sequence=Open)
     SwitchStates(1)=(Sequence=Close)
     loop=True
     NumberStates=2
     DamageThreshold=40
     TriggerRadius=80.000000
     TriggerHeight=80.000000
     TriggerType=TT_PlayerProximityAndLookUse
     Grabbable=True
     Mesh=DukeMesh'c_zone5_area51.pettaxi'
     CollisionRadius=17.000000
     CollisionHeight=14.000000
     Health=50
}
