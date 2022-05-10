//=============================================================================
// Z5_PetTaxi. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_PetTaxi expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1c'
     HealthPrefab=HEALTH_SortaHard
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=26.000000
     LandFrontCollisionHeight=12.000000
     LandSideCollisionRadius=26.000000
     LandSideCollisionHeight=12.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-1.500000,Y=-1.000000,Z=-1.000000)
     BobDamping=0.900000
     ItemName="Pet Taxi"
     bFlammable=True
     CollisionRadius=26.000000
     CollisionHeight=15.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.pettaxi'
}
