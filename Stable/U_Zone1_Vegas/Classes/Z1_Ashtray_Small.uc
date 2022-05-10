//=============================================================================
// Z1_Ashtray_Small. 					October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Ashtray_Small expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(3)=Class'dnParticles.dnDebris_SmokeSubtle'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     HealthPrefab=HEALTH_Easy
     bLandUpright=True
     bLandUpsideDown=True
     Grabbable=True
     PlayerViewOffset=(X=0.500000,Y=-1.625000,Z=1.500000)
     BobDamping=0.925000
     ItemName="Small Ashtray"
     CollisionRadius=4.500000
     CollisionHeight=1.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.ashtray2'
}
