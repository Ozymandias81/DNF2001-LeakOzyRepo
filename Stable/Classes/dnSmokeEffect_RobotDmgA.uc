//=============================================================================
// dnSmokeEffect_RobotDmgA.uc
//=============================================================================
class dnSmokeEffect_RobotDmgA expands dnSmokeEffect;

defaultproperties
{
     DestroyWhenEmpty=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.100000
     PrimeCount=0
     PrimeTimeIncrement=0.050000
     MaximumParticles=16
     Lifetime=2.500000
     RelativeSpawn=False
     InitialVelocity=(X=0.000000,Z=24.000000)
     InitialAcceleration=(X=0.000000,Z=0.000000)
     MaxVelocityVariance=(X=4.000000,Y=4.000000,Z=0.000000)
     RealtimeVelocityVariance=(Z=32.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke4aRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke4cRC'
     Textures(2)=Texture't_generic.Smoke.gensmoke4dRC'
     Textures(3)=None
     DrawScaleVariance=0.050000
     StartDrawScale=0.025000
     EndDrawScale=0.100000
     AlphaStart=1.000000
     AlphaEnd=1.000000
     RotationInitial=0.500000
     RotationVariance=65535.000000
     TriggerAfterSeconds=2.500000
     TriggerType=SPT_Disable
     PulseSeconds=1.000000
     Physics=PHYS_MovingBrush
}
