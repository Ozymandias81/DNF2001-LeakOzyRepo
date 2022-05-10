//=============================================================================
// Z3_WagonWheel1.						November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_WagonWheel1 expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebris_Wood1'
     FragType(2)=Class'dnParticles.dnDebris_Wood1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Wood1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-1.000000,Y=-2.000000,Z=0.000000)
     BobDamping=0.875000
     ItemName="Wagon Wheel"
     bFlammable=True
     CollisionRadius=25.000000
     CollisionHeight=6.000000
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.wagonwhl1'
}
