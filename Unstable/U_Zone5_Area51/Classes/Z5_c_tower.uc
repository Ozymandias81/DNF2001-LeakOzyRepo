//=============================================================================
// Z5_c_tower.
//=============================================================================
//=====================  MW
class Z5_c_tower expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1c'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionHeight=6.000000
     LandSideCollisionHeight=6.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     Health=140
     ItemName="Computer Tower"
     bFlammable=True
     CollisionRadius=14.000000
     CollisionHeight=14.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.comp_tower'
}
