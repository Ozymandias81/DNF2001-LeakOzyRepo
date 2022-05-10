//=============================================================================
// dnFireEffect3.	Keith Schuler September 16,2000
// Large fire effect for missile hits outside the Lady Killer
// Used in conjunction with dnFireEffect2 and dnSmokeEffect2
//=============================================================================
class dnFireEffect3 expands dnFireEffect;

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnPeriod=0.100000
     PrimeCount=1
     Lifetime=2.000000
     RelativeLocation=False
     RelativeRotation=False
     InitialVelocity=(X=0.000000,Y=200.000000,Z=200.000000)
     InitialAcceleration=(Y=-40.000000,Z=0.000000)
     MaxVelocityVariance=(X=100.000000,Y=100.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke7aRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke7bRC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.500000
     AlphaStart=0.850000
     AlphaEnd=0.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=8.000000
     PulseSecondsVariance=1.000000
     VisibilityRadius=8192.000000
     VisibilityHeight=8192.000000
     CollisionHeight=22.000000
     bCollideActors=True
}
