//=============================================================================
// Z1_PoolToy1.
//============================================== Keith Schuler 3/18/99
class Z1_PoolToy1 expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Inflatable'
     FragType(3)=Class'dnParticles.dnDebrisMesh_InflatableA'
     FragType(4)=Class'dnParticles.dnDebrisMesh_InflatableB'
     FragType(5)=Class'dnParticles.dnDebris_Fabric1'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandUpright=True
     LandDirection=LAND_Upright
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-4.250000,Y=0.500000,Z=-4.000000)
     BobDamping=0.900000
     ItemName="Pool Toy"
     bFlammable=True
     CollisionRadius=32.000000
     CollisionHeight=15.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.pool_toy1'
}
