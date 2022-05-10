//=============================================================================
// Z3_Barrel_Wood. 						November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Barrel_Wood expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebris_Wood1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Wood1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(7)=Class'dnParticles.dnDebris_Wood1'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Spawner1')
     MassPrefab=MASS_Heavy
     bLandForward=True
     LandFrontCollisionRadius=28.000000
     LandFrontCollisionHeight=15.000000
     LandSideCollisionRadius=28.000000
     LandSideCollisionHeight=15.000000
     bPushable=True
     PlayerViewOffset=(X=-0.500000,Y=0.500000,Z=0.250000)
     ItemName="Barrel"
     bFlammable=True
     CollisionRadius=16.000000
     CollisionHeight=22.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.barrel_wood1'
}
