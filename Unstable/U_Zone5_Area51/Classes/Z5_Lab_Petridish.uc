//=============================================================================
// Z5_Lab_Petridish. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Lab_Petridish expands Zone5_Area51;

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
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.625000,Y=-1.750000,Z=2.000000)
     BobDamping=0.900000
     ItemName="Petridish"
     CollisionRadius=3.000000
     CollisionHeight=1.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.lab_petridish'
}
