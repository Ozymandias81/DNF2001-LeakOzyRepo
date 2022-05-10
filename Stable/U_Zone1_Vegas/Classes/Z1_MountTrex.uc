//=============================================================================
// Z1_MountTrex.
//=============================================================================
class Z1_MountTrex expands Zone1_Vegas;

// Keith Schuler 2/23/99

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Wood1'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Generic1b'
     FragType(7)=Class'dnParticles.dnDebris_Fabric1'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     HealthPrefab=HEALTH_Hard
     ItemName="Stuffed T-Rex Trophy"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=36.000000
     CollisionHeight=41.000000
     Mesh=DukeMesh'c_zone1_vegas.t-rexmount'
}
