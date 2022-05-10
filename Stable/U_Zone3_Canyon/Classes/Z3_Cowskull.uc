//=============================================================================
// Z3_Cowskull. 						November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Cowskull expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     HealthMarkers(0)=(Threshold=35)
     HealthMarkers(1)=(Threshold=25)
     HealthMarkers(2)=(Threshold=15)
     HealthMarkers(3)=(Threshold=5)
     FragType(0)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragType(4)=Class'dnParticles.dnDebris_Cement1_Small'
     FragType(5)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     bLandUpright=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-1.500000,Z=0.750000)
     ItemName="Cow Skull"
     bFlammable=True
     CollisionRadius=30.000000
     CollisionHeight=8.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.cowskull'
}
