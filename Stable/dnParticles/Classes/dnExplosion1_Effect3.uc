//=============================================================================
// dnExplosion1_Effect3.								Keith Schuler 4/12/2000
//=============================================================================
class dnExplosion1_Effect3 expands dnExplosion1;

// Explosion effect subclass spawned by other particle systems. 
// No damage.
// Flying spark particles unaffected by gravity.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     AdditionalSpawn(2)=(SpawnClass=None)
     AdditionalSpawn(3)=(SpawnClass=None)
     AdditionalSpawn(4)=(SpawnClass=None)
     CreationSound=None
     PrimeCount=10
     Lifetime=1.000000
     MaxVelocityVariance=(X=300.000000,Y=300.000000,Z=300.000000)
     Textures(0)=Texture't_generic.particle_efx.pflare4ABC'
     StartDrawScale=1.000000
     EndDrawScale=1.000000
     AlphaEnd=0.000000
     RotationVariance=1000.000000
}
