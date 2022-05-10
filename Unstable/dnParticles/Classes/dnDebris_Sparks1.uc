//=============================================================================
// dnDebris_Sparks1. 				  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Sparks1 expands dnDebris;

// Root of the spark debris spawners. Average spark effect for most objects.

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=45
     MaximumParticles=45
     Lifetime=0.750000
     LifetimeVariance=0.750000
     InitialVelocity=(Z=316.000000)
     MaxVelocityVariance=(X=800.000000,Y=800.000000,Z=384.000000)
     LocalFriction=128.000000
     BounceElasticity=0.100000
     UseLines=True
     ConstantLength=True
     LineStartColor=(R=255,G=255,B=255)
     LineEndColor=(R=255,G=255,B=255)
     LineStartWidth=1.500000
     LineEndWidth=1.500000
     Textures(0)=Texture't_generic.Sparks.spark1RC'
     Textures(1)=Texture't_generic.Sparks.spark3RC'
     Textures(2)=Texture't_generic.Sparks.spark2RC'
     Textures(3)=Texture't_generic.Sparks.spark4RC'
     StartDrawScale=8.000000
     EndDrawScale=24.000000
     TriggerType=SPT_None
     PulseSeconds=4.000000
     AlphaVariance=0.250000
     AlphaEnd=0.000000
     bBurning=True
     bHidden=True
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Translucent
     bUnlit=True
}
