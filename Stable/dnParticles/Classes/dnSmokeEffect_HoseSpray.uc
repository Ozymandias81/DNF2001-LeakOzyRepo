//=============================================================================
// dnSmokeEffect_HoseSpray. 		   November 14th, 2000 - Charlie Wiederhold
//=============================================================================
class dnSmokeEffect_HoseSpray expands dnSmokeEffect;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=False
     SpawnPeriod=0.025000
     MaximumParticles=36
     Lifetime=0.325000
     LifetimeVariance=0.125000
     InitialVelocity=(X=0.000000,Z=256.000000)
     InitialAcceleration=(X=0.000000,Z=0.000000)
     MaxVelocityVariance=(Z=32.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1bRC'
     Textures(1)=None
     Textures(2)=None
     Textures(3)=None
     RotationVariance=65535.000000
     TriggerType=SPT_Toggle
     Style=STY_Translucent
}
