//=============================================================================
// dnDebris_Gravel1.                  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Gravel1 expands dnDebris;

// Root of the Gravel debris spawners. Good bit of gravel.

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
     Textures(0)=Texture't_generic.pebbles.pebble1aRC'
     Textures(1)=Texture't_generic.pebbles.pebble1bRC'
     Textures(2)=Texture't_generic.pebbles.pebble1cRC'
     Textures(3)=Texture't_generic.pebbles.pebble1dRC'
     Textures(4)=Texture't_generic.pebbles.pebble1eRC'
     Textures(5)=Texture't_generic.pebbles.pebble1fRC'
     Textures(6)=Texture't_generic.pebbles.pebble1gRC'
     Textures(7)=Texture't_generic.pebbles.pebble1hRC'
     Textures(8)=Texture't_generic.pebbles.pebble1iRC'
     Textures(9)=Texture't_generic.pebbles.pebble2aRC'
     Textures(10)=Texture't_generic.pebbles.pebble2bRC'
     Textures(11)=Texture't_generic.pebbles.pebble2cRC'
     Textures(12)=Texture't_generic.pebbles.pebble2dRC'
     Textures(13)=Texture't_generic.pebbles.pebble2eRC'
     Textures(14)=Texture't_generic.pebbles.pebble2fRC'
     Textures(15)=Texture't_generic.pebbles.pebble2iRC'
     StartDrawScale=0.075000
     EndDrawScale=0.075000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     SystemAlphaScale=0.000000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
}
