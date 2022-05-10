//=============================================================================
// G_RedSiren.
//=============================================================================
// AllenB
class G_Siren_Red expands dnSwitchDecoration;

defaultproperties
{
     SwitchStates(0)=(Sequence=sirenon,SequenceLoop=True)
     SwitchStates(1)=(Sequence=sirenoff)
     Loop=True
     NumberStates=2
     TriggerRetriggerDelay=0.500000
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     bUseTriggered=True
     bFlammable=True
     CollisionRadius=7.000000
     CollisionHeight=7.000000
     Mesh=DukeMesh'c_generic.redsirenRC'
}
