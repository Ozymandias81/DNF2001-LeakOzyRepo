//=============================================================================
// Z1_StatueFountainWoman. 			   November 28th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_StatueFountainWoman expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebrisMesh_Cement1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Cement1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Cement1b'
     FragType(3)=Class'dnParticles.dnDebris_Cement1'
     FragType(4)=Class'dnParticles.dnDebris_Cement1_Small'
     FragType(6)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     DestroyedSound=Sound'a_impact.Rock.RockBrk03'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Zone1_Vegas.Z1_StatueFountainWoman_Broken')
     HealthPrefab=HEALTH_Hard
     Health=0
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=18.000000
     CollisionHeight=116.000000
     bCollideWorld=False
     bMeshLowerByCollision=False
     Mesh=DukeMesh'c_zone1_vegas.StatueGPillar'
}
