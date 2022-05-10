//=============================================================================
// dnDebris_Cement1. 				  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Cement1 expands dnDebris;

// Root of the cement debris spawners. Good bit of white concrete stuff.

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
     BounceElasticity=0.325000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.concrtparticles.concrtpart1aRC'
     Textures(1)=Texture't_generic.concrtparticles.concrtpart1bRC'
     Textures(2)=Texture't_generic.concrtparticles.concrtpart1cRC'
     Textures(3)=Texture't_generic.concrtparticles.concrtpart1dRC'
     Textures(4)=Texture't_generic.concrtparticles.concrtpart1eRC'
     Textures(5)=Texture't_generic.concrtparticles.concrtpart1fRC'
     StartDrawScale=0.200000
     EndDrawScale=0.200000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     AlphaRampMid=0.850000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
}
