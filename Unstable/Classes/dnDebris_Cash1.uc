//=============================================================================
// dnDebris_Cash1. 	  				  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Cash1 expands dnDebris;

// Root of the Cash debris spawners. Good bit of cash.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=45
     MaximumParticles=45
     Lifetime=2.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=384.000000)
     RealtimeAccelerationVariance=(X=3084.000000,Y=3084.000000,Z=1024.000000)
     LocalFriction=945.000000
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.money.dollar2aRC'
     Textures(1)=Texture't_generic.money.dollar1aRC'
     StartDrawScale=0.075000
     EndDrawScale=0.075000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=4.000000
     TriggerType=SPT_None
     TimeWarp=0.750000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
}
