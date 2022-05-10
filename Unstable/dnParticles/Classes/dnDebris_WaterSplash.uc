//=============================================================================
// dnDebris_WaterSplash.			  September 23rd, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_WaterSplash expands dnDebris;

// Root of the water splash spawner.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=20
     MaximumParticles=20
     Lifetime=1.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=384.000000)
     MaxVelocityVariance=(X=128.000000,Y=128.000000,Z=256.000000)
     LocalFriction=320.000000
     BounceElasticity=0.100000
     Textures(0)=Texture't_generic.WaterImpact.waterimpact5RC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.200000
     EndDrawScale=0.600000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     TriggerType=SPT_None
     AlphaStart=0.750000
     AlphaMid=0.250000
     AlphaEnd=0.000000
     TimeWarp=0.750000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Translucent
     bUnlit=True
}
