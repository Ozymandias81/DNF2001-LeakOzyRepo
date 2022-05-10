//=============================================================================
// Z2_Statue.							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Statue expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=41.000000
     CollisionHeight=105.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone2_dam.statue1_dam'
}
