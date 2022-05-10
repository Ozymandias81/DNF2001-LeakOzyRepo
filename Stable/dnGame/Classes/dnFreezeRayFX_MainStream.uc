//=============================================================================
// dnFreezeRayFX_MainStream. 				May 25th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFreezeRayFX_MainStream expands dnFreezeRayFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.025000
     Lifetime=0.750000
     RelativeSpawn=True
     InitialVelocity=(X=512.000000,Z=0.000000)
     InitialAcceleration=(Z=-256.000000)
     MaxVelocityVariance=(X=0.000000,Y=32.000000,Z=32.000000)
     Bounce=True
     DieOnBounce=True
     ParticlesCollideWithWorld=True
     UseZoneGravity=False
     Textures(0)=Texture't_firefx.icespray2.iceshardC3RC'
     StartDrawScale=0.050000
     EndDrawScale=0.625000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=False
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
