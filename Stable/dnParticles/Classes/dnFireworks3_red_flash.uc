//=============================================================================
// dnFireworks3_red_flash. (AHB3d)
//=============================================================================
class dnFireworks3_red_flash expands dnFireworks3_red;

defaultproperties
{
     Enabled=False
     BSPOcclude=False
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     AdditionalSpawn(2)=(SpawnClass=None)
     AdditionalSpawn(3)=(SpawnClass=None)
     SpawnNumber=2
     SpawnPeriod=0.000000
     MaximumParticles=100
     Lifetime=0.050000
     LifetimeVariance=0.050000
     RelativeSpawn=True
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare1'
     DrawScaleVariance=2.000000
     StartDrawScale=2.500000
     AlphaEnd=0.000000
     RotationVariance=32.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.350000
     PulseMagnitude=0.010000
     LifeSpan=3.000000
     Style=STY_Translucent
     bUnlit=True
     VisibilityRadius=16000.000000
     VisibilityHeight=16000.000000
     CollisionRadius=16.000000
}
