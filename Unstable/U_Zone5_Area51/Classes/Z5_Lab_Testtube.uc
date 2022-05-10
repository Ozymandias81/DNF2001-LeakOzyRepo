//=============================================================================
// Z5_Lab_Testtube. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Lab_Testtube expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke_Small1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=8.000000
     LandFrontCollisionHeight=1.000000
     LandSideCollisionRadius=8.000000
     LandSideCollisionHeight=1.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     BobDamping=0.900000
     ItemName="Test Tube"
     CollisionRadius=1.000000
     CollisionHeight=4.500000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.lab_testtube'
}
