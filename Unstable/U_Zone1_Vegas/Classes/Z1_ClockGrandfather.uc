//=============================================================================
// Z1_ClockGrandfather.
//=============================================================================
class Z1_ClockGrandfather expands Zone1_Vegas;

// Keith Schuler 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebris_Glass1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Wood1b'
     FragType(7)=Class'dnParticles.dnDebrisMesh_Wood1b'
     IdleAnimations(0)=gf_tictoc
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_Hard
     ItemName="Grandfather Clock"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=21.000000
     CollisionHeight=52.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.gf_clock'
}
