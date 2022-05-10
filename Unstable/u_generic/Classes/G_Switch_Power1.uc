//=============================================================================
// G_Switch_Power1.
//=============================================================================

class G_Switch_Power1 expands dnSwitchDecoration;

defaultproperties
{
     bTakeMomentum=False
     SwitchStates(0)=(AfterSequence=True,Sequence=switchoff-on)
     SwitchStates(1)=(AfterSequence=True,Sequence=switchon-off)
     loop=True
     CurrentSwitchState=1
     NumberStates=2
	 bUseTriggered=true
     TriggerRetriggerDelay=0.500000
     Mesh=DukeMesh'c_generic.switch_power1'
     CollisionRadius=6.000000
     CollisionHeight=12.000000
     AnimSequence=switchoff
     Health=0
}
