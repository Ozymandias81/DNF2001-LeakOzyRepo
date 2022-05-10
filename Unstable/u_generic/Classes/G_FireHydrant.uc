//=============================================================================
// G_FireHydrant.
//=============================================================================
class G_FireHydrant expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

// AllenB

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1'
     FragType(3)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Generic1b'
     NumberFragPieces=6
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_FireHydrant_Broken')
     bTakeMomentum=False
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_Hard
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.hydrant4'
     ItemName="Fire Hydrant"
     CollisionRadius=12.000000
     CollisionHeight=26.000000
     Health=20
}
