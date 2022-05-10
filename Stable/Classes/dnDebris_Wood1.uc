//=============================================================================
// dnDebris_Wood1. 					  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Wood1 expands dnDebris;

// Root of the wood debris spawners. Good bit of wood chunks.

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
     LocalFriction=256.000000
     BounceElasticity=0.325000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.woodshards.woodshard4aRC'
     Textures(1)=Texture't_generic.woodshards.woodshard4bRC'
     Textures(2)=Texture't_generic.woodshards.woodshard4cRC'
     Textures(3)=Texture't_generic.woodshards.woodshard4dRC'
     Textures(4)=Texture't_generic.woodshards.woodshard4eRC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.325000
     EndDrawScale=0.325000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
     bUnlit=True
}
