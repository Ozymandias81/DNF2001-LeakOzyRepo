//=============================================================================
// dnDebris_Dirt1.    				  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Dirt1 expands dnDebris;

// Root of the dirt debris spawners. Good bit of dirt chunks.

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
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=256.000000)
     RealtimeAccelerationVariance=(X=2048.000000,Y=2048.000000,Z=512.000000)
     LocalFriction=450.000000
     BounceElasticity=0.100000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.dirtparticle.dirtparticle2aR'
     Textures(1)=Texture't_generic.dirtparticle.dirtparticle2bR'
     DrawScaleVariance=0.200000
     StartDrawScale=0.250000
     EndDrawScale=0.250000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     AlphaMid=1.000000
     AlphaRampMid=0.850000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
     bUnlit=True
}
