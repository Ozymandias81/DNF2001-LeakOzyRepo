//=============================================================================
// dnFreezeRayFX_NozzleStream. 				May 25th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFreezeRayFX_NozzleStream expands dnFreezeRayFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnFreezeRayFX_MainStream',TakeParentTag=True,Mount=True)
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnFreezeRayFX_NozzleMist',TakeParentTag=True)
     SpawnPeriod=0.032500
     Lifetime=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=96.000000,Z=0.000000)
     InitialAcceleration=(Z=-8.000000)
     MaxVelocityVariance=(X=0.000000,Y=4.000000,Z=4.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_firefx.icespray2.iceshardCRC'
     StartDrawScale=0.050000
     EndDrawScale=0.175000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=False
     AlphaEnd=0.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
	 UseParticleCollisionActors=true
	 ParticlesPerCollision=6
	 NumCollisionActors=5
	 CollisionActorClass=class'FreezerCollisionActor'
}
