//=============================================================================
// Z2_Sphere.							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Sphere expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Mesh=DukeMesh'c_zone2_dam.sphere_dam'
}
