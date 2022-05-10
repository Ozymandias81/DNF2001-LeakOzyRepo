//=============================================================================
// Z2_Holo_Powercell. 					November 7th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Holo_Powercell expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandUpright=True
     LandFrontCollisionRadius=9.000000
     LandFrontCollisionHeight=2.750000
     LandSideCollisionRadius=9.000000
     LandSideCollisionHeight=2.750000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.250000,Y=-1.750000,Z=2.000000)
     BobDamping=0.875000
     ItemName="Projector Battery"
     bFlammable=True
     CollisionRadius=9.000000
     CollisionHeight=5.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone2_dam.holo_powercell'
}
