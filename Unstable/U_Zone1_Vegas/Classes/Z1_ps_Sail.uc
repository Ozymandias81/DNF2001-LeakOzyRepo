//=============================================================================
// Z1_ps_Sail.
//=============================================================================
// AllenB
class Z1_ps_Sail expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     IdleAnimations(0)=saildead
     IdleAnimations(1)=sailblow
     IdleAnimations(2)=sailblow
     IdleAnimations(3)=sailblow
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     HealthPrefab=HEALTH_NeverBreak
     Health=0
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=190.000000
     CollisionHeight=120.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     bMeshLowerByCollision=False
     Mesh=DukeMesh'c_zone1_vegas.ps_sail'
}
