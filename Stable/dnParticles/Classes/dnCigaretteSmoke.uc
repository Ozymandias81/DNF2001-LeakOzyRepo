//=============================================================================
// dnCigaretteSmoke. 					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class dnCigaretteSmoke expands dnSmokeEffect;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmpty=False
     SpawnPeriod=0.250000
     MaximumParticles=6
     Lifetime=2.000000
     LifetimeVariance=0.000000
     InitialVelocity=(X=3.000000)
     InitialAcceleration=(X=0.000000,Z=0.000000)
     MaxVelocityVariance=(X=2.000000,Y=0.000000,Z=2.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     Textures(1)=None
     Textures(2)=None
     Textures(3)=None
     DrawScaleVariance=0.000000
     StartDrawScale=0.000000
     EndDrawScale=0.050000
     AlphaStart=1.000000
     RotationVariance=65535.000000
     TriggerType=SPT_Disable
     Style=STY_Translucent
}
