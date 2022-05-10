//=============================================================================
// Z1_Ps_Hull. 							October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Ps_Hull expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=450.000000
     CollisionHeight=220.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     bMeshLowerByCollision=False
     WaterSplashClass=None
     Mesh=DukeMesh'c_zone1_vegas.ps_hull'
}
