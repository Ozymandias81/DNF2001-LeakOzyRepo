//=============================================================================
// dnFireworks3_red_spark. (AHB3d)
//=============================================================================
class dnFireworks3_red_spark expands dnFireworks3_red;

defaultproperties
{
     Enabled=False
     BSPOcclude=False
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     AdditionalSpawn(2)=(SpawnClass=None)
     AdditionalSpawn(3)=(SpawnClass=None)
     SpawnNumber=3
     SpawnPeriod=0.000000
     MaximumParticles=100
     Lifetime=1.000000
     LifetimeVariance=0.500000
     RelativeSpawn=True
     InitialVelocity=(Z=1200.000000)
     InitialAcceleration=(Z=-1200.000000)
     MaxVelocityVariance=(X=128.000000,Y=128.000000)
     MaxAccelerationVariance=(Z=200.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare1'
     StartDrawScale=0.300000
     EndDrawScale=1.250000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     RotationVariance=32.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.350000
     PulseMagnitude=0.010000
     LifeSpan=3.000000
     Style=STY_Translucent
     DrawScale=0.250000
     bUnlit=True
     VisibilityRadius=16000.000000
     VisibilityHeight=16000.000000
     CollisionRadius=0.000000
     CollisionHeight=32.000000
}
