//=============================================================================
// Z2_Column_224. 						November 6th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Column_224 expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     bTumble=False
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=16.000000
     CollisionHeight=224.000000
     bCollideWorld=False
     bProjTarget=True
     WaterSplashClass=None
     Mesh=DukeMesh'c_zone2_dam.column224'
}
