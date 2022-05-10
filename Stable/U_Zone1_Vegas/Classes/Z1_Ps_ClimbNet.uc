//=============================================================================
// Z1_ps_ClimbNet.						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_ps_ClimbNet expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     SpawnOnHit=None
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     WaterSplashClass=None
     Mesh=DukeMesh'c_zone1_vegas.ps_climbnet'
}
