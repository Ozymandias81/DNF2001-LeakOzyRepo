//=============================================================================
// Z5_Lab_Flask. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Lab_Flask expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(4)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=7.000000
     LandFrontCollisionHeight=3.750000
     LandSideCollisionRadius=7.000000
     LandSideCollisionHeight=3.750000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=1.000000,Y=-2.500000,Z=4.000000)
     BobDamping=0.900000
     ItemName="Flask"
     CollisionRadius=4.000000
     CollisionHeight=6.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.lab_flash'
}
