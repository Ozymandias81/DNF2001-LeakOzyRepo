//=============================================================================
// Z3_Boulder1.							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Boulder1 expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=29.000000
     CollisionHeight=26.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.Boulder1'
}
