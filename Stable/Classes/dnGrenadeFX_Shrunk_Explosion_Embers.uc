//=============================================================================
// dnGrenadeFX_Shrunk_Explosion_Embers.                   June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnGrenadeFX_Shrunk_Explosion_Embers expands dnGrenadeFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=30
     MaximumParticles=30
     Lifetime=2.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=384.000000)
     MaxVelocityVariance=(X=384.000000,Y=384.000000,Z=384.000000)
     LocalFriction=128.000000
     BounceElasticity=0.500000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.particle_efx.pflare4ABC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.20000
     EndDrawScale=0.20000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Style=STY_Translucent
     bIgnoreBList=True
}
