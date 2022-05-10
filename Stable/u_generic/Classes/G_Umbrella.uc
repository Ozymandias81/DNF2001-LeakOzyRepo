//=============================================================================
// G_Umbrella.
//==========================================
// AllenB, Cole
class G_Umbrella expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=25
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Fabric1'
     FragType(2)=Class'dnParticles.dnDebris_Metal1'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebris_Sparks1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(7)=Class'dnParticles.dnDebrisMesh_Metal1b'
     IdleAnimations(0)=Still
     IdleAnimations(1)=breeze
     IdleAnimations(2)=breeze
     IdleAnimations(3)=breeze
     IdleAnimations(4)=breeze
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bTakeMomentum=False
     Mesh=DukeMesh'c_generic.umbrella1'
     ItemName="Umbrella"
     CollisionRadius=46.000000
     CollisionHeight=60.000000
     bBlockPlayers=False
     bProjTarget=True
     Health=50
}
