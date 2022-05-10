//=============================================================================
// Z1_StuffedBossEye.							Keith Schuler 5/19/99
//=============================================================================
class Z1_StuffedBossEye expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Wood1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Generic1b'
     FragType(7)=Class'dnParticles.dnDebrisMesh_Generic1'
     IdleAnimations(0)=ceeyefloat
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     MassPrefab=MASS_Heavy
     bLandForward=True
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=3.000000,Z=1.000000)
     ItemName="Cycloid Emperor Eyeball"
     bTakeMomentum=False
     CollisionRadius=20.000000
     CollisionHeight=37.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.CEeye'
     DrawScale=0.750000
}
