//=============================================================================
// dnExplosion1_Effect1.							Keith Schuler April 12,2000
//=============================================================================
class dnExplosion1_Effect1 expands dnExplosion1;

// Explosion effect subclass spawned by other particle systems. 
// No damage.
// Explosion animated particle.

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
     PrimeCount=2
     Lifetime=0.000000
     Textures(0)=Texture't_explosionFx.explosions.Herc_001'
     DieOnLastFrame=True
     StartDrawScale=1.500000
     EndDrawScale=1.500000
     RotationVariance=65535.000000
     CollisionRadius=20.000000
     CollisionHeight=20.000000
}
