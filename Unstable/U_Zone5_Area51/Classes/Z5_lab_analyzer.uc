//=============================================================================
// Z5_lab_analyzer.
//=============================================================================
class Z5_lab_analyzer expands Zone5_Area51;

///================================  March 19th, Matt Wood

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     HealthMarkers(0)=(Threshold=190)
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandBackwards=True
     bLandUpright=True
     LandFrontCollisionRadius=20.000000
     LandFrontCollisionHeight=15.000000
     LandSideCollisionRadius=20.000000
     LandSideCollisionHeight=15.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-1.000000,Y=-1.000000,Z=0.500000)
     BobDamping=0.900000
     Health=200
     ItemName="Analyzer"
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.lab_analyzer'
}
