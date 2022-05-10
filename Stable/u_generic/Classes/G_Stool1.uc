//=============================================================================
// G_Stool1.
//=============================================================================
class G_Stool1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold
//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(5)=Class'dnParticles.dnDebris_Smoke'
     FragType(6)=Class'dnParticles.dnDebris_Fabric1'
     NumberFragPieces=24
     FragBaseScale=0.500000
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     ItemName="Stool"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=12.000000
     CollisionHeight=18.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.stool1'
}
