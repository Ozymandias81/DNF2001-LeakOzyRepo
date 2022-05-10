//=============================================================================
// Z1_Ps_Flag.							October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Ps_Flag expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     IdleAnimations(0)=blowflag
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=80.000000
     CollisionHeight=55.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     WaterSplashClass=None
     Mesh=DukeMesh'c_zone1_vegas.Flag_pirate'
}
