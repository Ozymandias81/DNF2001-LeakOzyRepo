//=============================================================================
// Z1_StratosfearBall.
//=============================================================================
class Z1_StratosfearBall expands Zone1_Vegas;

// Keith Schuler 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Glass1'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(7)=Class'dnParticles.dnDebrisMesh_Metal1c'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SmallElectronic')
     HealthPrefab=HEALTH_Hard
     Health=0
     ItemName="Stratosfear Globe"
     bTakeMomentum=False
     CollisionRadius=32.000000
     CollisionHeight=31.000000
     Mesh=DukeMesh'c_zone1_vegas.stratoball1'
}
