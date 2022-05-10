//=============================================================================
// dnRocketFX_Shrunk_Explosion_LightDebris_White.                  August 8th, 2000 - Charlie Wiederhold
//=============================================================================
class dnRocketFX_Shrunk_Explosion_LightDebris_White expands dnRocketFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=25
     MaximumParticles=25
     Lifetime=2.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=612.000000)
     MaxVelocityVariance=(X=1000.000000,Y=1000.000000,Z=512.000000)
     RealtimeAccelerationVariance=(X=3084.000000,Y=3084.000000,Z=1024.000000)
     LocalFriction=945.000000
     BounceElasticity=0.100000
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.stuffing.stuffing1RC'
     Textures(1)=Texture't_generic.stuffing.stuffing2RC'
     Textures(2)=Texture't_generic.stuffing.stuffing3RC'
     Textures(3)=Texture't_generic.stuffing.stuffing4aRC'
     Textures(4)=Texture't_generic.stuffing.stuffing4bRC'
     Textures(5)=Texture't_generic.stuffing.stuffing4cRC'
     DrawScaleVariance=0.03250000
     StartDrawScale=0.050000
     EndDrawScale=0.050000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     TimeWarp=0.750000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     bUnlit=True
     bIgnoreBList=True
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.850000
     bUseAlphaRamp=True
     Style=STY_Translucent
}
