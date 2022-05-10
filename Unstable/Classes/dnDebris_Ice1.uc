//=============================================================================
// dnDebris_Ice1. 					  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Ice1 expands dnDebris;

// Root of the ice debris spawners. Good bit of ice chunks.

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
     LocalFriction=256.000000
     BounceElasticity=0.750000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.iceparticles.iceparticle1aRC'
     Textures(1)=Texture't_generic.iceparticles.iceparticle1bRC'
     Textures(2)=Texture't_generic.iceparticles.iceparticle1cRC'
     StartDrawScale=0.075000
     EndDrawScale=0.075000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.850000
     bUseAlphaRamp=True
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Style=STY_Translucent
     bUnlit=True
}
