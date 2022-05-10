//=============================================================================
// Z3_Lantern. 							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Lantern expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     HealthMarkers(0)=(Threshold=35,PlaySequence=Damage1,SpawnActor=Class'dnParticles.dnBulletFX_GlassSpawner')
     HealthMarkers(1)=(Threshold=25,PlaySequence=Damage2,SpawnActor=Class'dnParticles.dnBulletFX_GlassSpawner')
     HealthMarkers(2)=(Threshold=15,PlaySequence=damage3,SpawnActor=Class'dnParticles.dnBulletFX_GlassSpawner')
     HealthMarkers(3)=(Threshold=5,PlaySequence=Damage4,SpawnActor=Class'dnParticles.dnBulletFX_GlassSpawner')
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(6)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     HealthPrefab=HEALTH_SortaHard
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=9.000000
     LandFrontCollisionHeight=5.000000
     LandSideCollisionRadius=9.000000
     LandSideCollisionHeight=5.000000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.750000,Y=0.000000,Z=2.250000)
     BobDamping=0.900000
     ItemName="Lantern"
     bFlammable=True
     CollisionRadius=5.000000
     CollisionHeight=10.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.Lantern'
}
