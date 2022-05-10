//=============================================================================
// dnExplosion1_Effect4.							Keith Schuler April 13,2000
//=============================================================================
class dnExplosion1_Effect4 expands dnExplosion1;

// Explosion effect subclass spawned by other particle systems. 
// No damage.
// Large animated explosion

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Effect2')
     AdditionalSpawn(1)=(SpawnClass=None)
     AdditionalSpawn(2)=(SpawnClass=None)
     AdditionalSpawn(3)=(SpawnClass=None)
     AdditionalSpawn(4)=(SpawnClass=None)
     CreationSound=None
     Lifetime=0.000000
     Textures(0)=Texture't_explosionFx.explosions.R326_002'
     DieOnLastFrame=True
     StartDrawScale=6.000000
     EndDrawScale=6.000000
}
