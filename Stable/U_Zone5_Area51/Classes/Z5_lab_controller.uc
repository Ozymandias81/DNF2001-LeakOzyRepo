//=============================================================================
// Z5_lab_controller.
//=============================================================================
class Z5_lab_controller expands Zone5_Area51;

///====================================  March 18th, Matt Wood

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     HealthMarkers(0)=(Threshold=50)
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     LandFrontCollisionRadius=15.000000
     LandFrontCollisionHeight=11.000000
     LandSideCollisionRadius=15.000000
     LandSideCollisionHeight=11.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=-0.500000,Z=1.000000)
     BobDamping=0.875000
     ItemName="Controller"
     bFlammable=True
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.lab_controller'
}
