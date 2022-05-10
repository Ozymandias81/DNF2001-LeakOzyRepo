//=============================================================================
// dnBloodFX_BloodChunks.				 January 4th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodChunks expands dnBloodFX;

// Gibby goodness, standard amount.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     PrimeCount=32
     MaximumParticles=32
     Lifetime=0.850000
     LifetimeVariance=0.250000
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=256.000000,Y=256.000000,Z=256.000000)
     DieOnBounce=True
     ParticlesCollideWithWorld=True
     UseZoneGravity=True
     Textures(0)=Texture't_generic.bloodgibs.genbloodgib1RC'
     Textures(1)=Texture't_generic.bloodgibs.genbloodgib2RC'
     Textures(2)=Texture't_generic.bloodgibs.genbloodgib3RC'
     Textures(3)=Texture't_generic.bloodgibs.genbloodgib4RC'
     Textures(4)=Texture't_generic.bloodgibs.genbloodgib5RC'
     DrawScaleVariance=0.075000
     StartDrawScale=0.050000
     EndDrawScale=0.050000
     AlphaEnd=1.000000
     RotationVelocityMaxVariance=32.000000
     SpawnOnBounceChance=0.800000
     SpawnOnBounce=Class'dnParticles.dnBloodFX_BloodSplat'
     Style=STY_Masked
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     TimeWarp=0.700000
}
