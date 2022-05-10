//=============================================================================
// dnDebris_Metal1.                   September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Metal1 expands dnDebris;

// Root of the metal debris spawner. Good chunk of metal.

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
     MaxVelocityVariance=(X=480.000000,Y=480.000000,Z=256.000000)
     LocalFriction=128.000000
     BounceElasticity=0.500000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.metalshards.metalshard1aRC'
     Textures(1)=Texture't_generic.metalshards.metalshard1bRC'
     Textures(2)=Texture't_generic.metalshards.metalshard1cRC'
     Textures(3)=Texture't_generic.metalshards.metalshard1dRC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.150000
     EndDrawScale=0.150000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
}
