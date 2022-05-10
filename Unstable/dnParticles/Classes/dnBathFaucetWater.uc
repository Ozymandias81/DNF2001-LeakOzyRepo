//=============================================================================
// dnBathFaucetWater.                        Created by Matt Wood Sept 11, 2000
//=============================================================================
class dnBathFaucetWater expands SoftParticleSystem;

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.090000
     MaximumParticles=25
     Lifetime=0.250000
     LifetimeVariance=0.020000
     RelativeSpawn=True
     InitialVelocity=(Y=-30.000000,Z=-15.000000)
     MaxVelocityVariance=(X=40.000000,Y=40.000000)
     BounceElasticity=0.300000
     Bounce=True
     ParticlesCollideWithWorld=True
     UseLines=True
     LineStartColor=(R=24,G=24,B=24)
     LineEndColor=(R=24,G=24,B=24)
     LineStartWidth=0.500000
     LineEndWidth=0.500000
     Textures(0)=Texture't_generic.waterdrops.waterdrop1eRC'
     DrawScaleVariance=0.100000
     StartDrawScale=4.000000
     EndDrawScale=0.100000
     UpdateWhenNotVisible=True
     AlphaStart=0.900000
     AlphaEnd=0.900000
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     Style=STY_Translucent
}
