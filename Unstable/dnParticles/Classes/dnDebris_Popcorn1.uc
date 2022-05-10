//=============================================================================
// dnDebris_Popcorn1.                 September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Popcorn1 expands dnDebris;

// Root of the popcorn debris spawner. Good bit of popcorn.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=75
     MaximumParticles=75
     Lifetime=2.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=384.000000)
     RealtimeAccelerationVariance=(X=2048.000000,Y=2048.000000,Z=512.000000)
     LocalFriction=800.000000
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.popcorn.popcorn1RC'
     Textures(1)=Texture't_generic.popcorn.popcorn2RC'
     Textures(2)=Texture't_generic.popcorn.popcorn3RC'
     Textures(3)=Texture't_generic.popcorn.popcorn4RC'
     StartDrawScale=0.075000
     EndDrawScale=0.075000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     TimeWarp=0.750000
     Style=STY_Masked
}
