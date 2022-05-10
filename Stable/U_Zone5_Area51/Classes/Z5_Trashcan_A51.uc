//=============================================================================
// Z5_Trashcan_A51. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Trashcan_A51 expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_Paper1'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(7)=Class'dnParticles.dnDebrisMesh_Metal1c'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     HealthPrefab=HEALTH_SortaHard
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=28.000000
     LandFrontCollisionHeight=14.000000
     LandSideCollisionRadius=28.000000
     LandSideCollisionHeight=14.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-1.500000,Y=0.500000,Z=0.000000)
     BobDamping=0.900000
     ItemName="Trash Can"
     CollisionRadius=20.000000
     CollisionHeight=23.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.trashcan_a51'
}
