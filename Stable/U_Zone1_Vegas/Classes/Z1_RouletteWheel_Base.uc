//=============================================================================
// Z1_RouletteWheel_Base. 				October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_RouletteWheel_Base expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=3.000000
     Mesh=DukeMesh'c_zone1_vegas.rwheelbase'
}
