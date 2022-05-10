//=============================================================================
// dnMultibombFX_Explosion_Embers.                   June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnMultibombFX_Explosion_Embers expands dnMultibombFX;

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
     InitialVelocity=(Z=384.000000)
     MaxVelocityVariance=(X=1024.000000,Y=1024.000000,Z=512.000000)
     LocalFriction=128.000000
     BounceElasticity=0.500000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.particle_efx.pflare4ABC'
     DrawScaleVariance=0.400000
     StartDrawScale=0.325000
     EndDrawScale=0.325000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Translucent
     bIgnoreBList=True
}
