//=============================================================================
// dnTestParticles.
//=============================================================================
class dnTestParticles expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnPeriod=0.500000
     MaximumParticles=1
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.lensflares.lensflare3RC'
     UpdateWhenNotVisible=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
