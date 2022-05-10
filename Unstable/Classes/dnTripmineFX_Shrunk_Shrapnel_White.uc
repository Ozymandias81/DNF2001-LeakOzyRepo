//=============================================================================
// dnTripmineFX_Shrunk_Shrapnel_White.                  June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnTripmineFX_Shrunk_Shrapnel_White expands dnTripmineFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     TimeWarp=0.750000
     SpawnNumber=8
     SpawnPeriod=0.070000
     PrimeCount=1
     MaximumParticles=24
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.2100000
     UseZoneGravity=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     Lifetime=2.000000
     LifetimeVariance=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=512.000000,Z=384.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=384.000000)
     Bounce=True
     ParticlesCollideWithWorld=True
     UpdateWhenNotVisible=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bIgnoreBList=True
     RealtimeAccelerationVariance=(X=3084.000000,Y=3084.000000,Z=1024.000000)
     LocalFriction=950.000000
     BounceElasticity=0.100000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     Textures(0)=Texture't_generic.stuffing.stuffing1RC'
     Textures(1)=Texture't_generic.stuffing.stuffing2RC'
     Textures(2)=Texture't_generic.stuffing.stuffing3RC'
     Textures(3)=Texture't_generic.stuffing.stuffing4aRC'
     Textures(4)=Texture't_generic.stuffing.stuffing4bRC'
     Textures(5)=Texture't_generic.stuffing.stuffing4cRC'
     DrawScaleVariance=0.0450000
     StartDrawScale=0.0450000
     EndDrawScale=0.0450000
     bUnlit=True
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.850000
     bUseAlphaRamp=True
     Style=STY_Translucent
}
