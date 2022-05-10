//=============================================================================
// G_PushSwitch_A.
//=============================================================================
// AllenB
// Note: Don't forget to change the TAG so it will only activate one LightSwitch
//
// BrandonR
// Note: Ignore Allen's note.  It'll only trigger this one.
// 
// KeithS
// Note: I wanna add a note too!
//
// Hint: To make a group of switchs activate at the same time, give them all
//		the same TAG and animation sequences. But only make one of the switches
//		call the EVENTS

class G_PushSwitch_A expands dnSwitchDecoration;

#exec OBJ LOAD FILE=..\Sounds\a_switch.dfx

defaultproperties
{
     SwitchStates(0)=(AfterSequence=True,Sequence=turnon,Sound=Sound'a_switch.Mechanical.MSwitch116a')
     SwitchStates(1)=(AfterSequence=True,Sequence=turnoff,Sound=Sound'a_switch.Mechanical.MSwitch116a')
     Loop=True
     CurrentSwitchState=1
     NumberStates=2
     DontDie=True
     TriggerRetriggerDelay=0.500000
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     Health=0
     ItemName="Switch"
     bTakeMomentum=False
     bUseTriggered=True
     bFlammable=True
     CollisionRadius=3.000000
     CollisionHeight=6.000000
     Mesh=DukeMesh'c_generic.Switch_PushA'
     AnimSequence=turnoff
}
