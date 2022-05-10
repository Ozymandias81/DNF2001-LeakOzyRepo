//=============================================================================
// dnDebris_Glass1.					  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Glass1 expands dnDebris;

// Root of the glass debris spawners. Good bit of glass chunks.

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
     MaxVelocityVariance=(X=420.000000,Y=420.000000,Z=256.000000)
     LocalFriction=128.000000
     BounceElasticity=0.625000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.glassshards.glasshard1aRC'
     Textures(1)=Texture't_generic.glassshards.glasshard1bRC'
     Textures(2)=Texture't_generic.glassshards.glasshard1cRC'
     Textures(3)=Texture't_generic.glassshards.glasshard1dRC'
     Textures(4)=Texture't_generic.glassshards.glasshard1eRC'
     Textures(5)=Texture't_generic.glassshards.glasshard1fRC'
     StartDrawScale=0.062500
     EndDrawScale=0.062500
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
