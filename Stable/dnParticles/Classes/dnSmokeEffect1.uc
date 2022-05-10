//=============================================================================
// dnSmokeEffect1. 									Keith Schuler Sept 13, 2000
// Spawned by the G_FireEffect1 decoration
// Generic black smoke for generic fire
//=============================================================================
class dnSmokeEffect1 expands dnSmokeEffect;

defaultproperties
{
     DestroyWhenEmpty=False
     SpawnPeriod=0.100000
     PrimeCount=0
     PrimeTimeIncrement=0.050000
     MaximumParticles=0
     Lifetime=2.000000
     LifetimeVariance=0.250000
     InitialVelocity=(X=0.000000,Y=64.000000,Z=150.000000)
     InitialAcceleration=(X=0.000000,Z=0.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=32.000000)
     RealtimeVelocityVariance=(X=64.000000,Y=64.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke4aRC'
     Textures(1)=None
     Textures(2)=None
     Textures(3)=None
     DrawScaleVariance=0.250000
     StartDrawScale=0.250000
     EndDrawScale=1.000000
     RotationInitial=0.500000
     RotationVariance=3.000000
     RotationVelocity=0.500000
     RotationVelocityMaxVariance=3.000000
     TriggerType=SPT_Toggle
     PulseSeconds=1.000000
     AlphaStart=1.000000
     AlphaEnd=1.000000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Physics=PHYS_MovingBrush
}
