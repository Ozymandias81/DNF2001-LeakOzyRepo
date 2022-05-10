//=============================================================================
// Z5_Door_PlasticStrip. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Door_PlasticStrip expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     IdleAnimations(0)=M_door_idle
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     TouchedSequence=M_door_into
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=33.000000
     CollisionHeight=56.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone5_area51.m_door'
}
