//=============================================================================
// dnSmokeEffect2.	Keith Schuler September 16,2000
// Large black smoke for outside the Lady Killer
// Used in conjunction with dnFireEffect2 and dnFireEffect3
//=============================================================================
class dnSmokeEffect2 expands dnSmokeEffect;

defaultproperties
{
     Enabled=False
     PrimeTimeIncrement=0.034000
     MaximumParticles=0
     Lifetime=6.000000
     LifetimeVariance=0.000000
     RelativeSpawn=False
     InitialVelocity=(X=0.000000,Y=200.000000,Z=200.000000)
     InitialAcceleration=(X=0.000000,Y=-40.000000,Z=0.000000)
     MaxVelocityVariance=(X=100.000000,Y=100.000000,Z=0.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke4aRC'
     Textures(1)=None
     Textures(2)=None
     Textures(3)=None
     StartDrawScale=1.000000
     EndDrawScale=5.000000
     RotationVariance=32767.000000
     TriggerOnSpawn=True
     PulseSeconds=8.000000
     PulseSecondsVariance=1.000000
     AlphaStart=1.000000
     AlphaEnd=1.000000
     VisibilityRadius=8192.000000
     VisibilityHeight=8192.000000
     CollisionRadius=128.000000
     CollisionHeight=22.000000
     bCollideActors=True
}
