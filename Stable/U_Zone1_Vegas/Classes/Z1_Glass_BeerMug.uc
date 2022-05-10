//=============================================================================
// Z1_Glass_BeerMug.					October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Glass_BeerMug expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=6.000000
     LandFrontCollisionHeight=2.000000
     LandSideCollisionRadius=6.000000
     LandSideCollisionHeight=2.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.325000,Y=-0.250000,Z=1.000000)
     BobDamping=0.950000
     ItemName="Beer Mug"
     CollisionRadius=3.000000
     CollisionHeight=4.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.gls_beermug2'
}
