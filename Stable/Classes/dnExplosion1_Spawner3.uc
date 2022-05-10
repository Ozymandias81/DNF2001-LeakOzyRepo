//=============================================================================
// dnExplosion1_Spawner3. 							Keith Schuler April 13,2000
//=============================================================================
class dnExplosion1_Spawner3 expands dnExplosion1;

// Explosion effect spawner.
// Does NOT do damage
// Uses dnExplosion1_Effect4, Effect2
// Largish explosion for Lady Killer sign

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Effect4')
     AdditionalSpawn(2)=(SpawnClass=None)
     AdditionalSpawn(3)=(SpawnClass=None)
     AdditionalSpawn(4)=(SpawnClass=None)
     CreationSoundRadius=8192.000000
     StartDrawScale=24.000000
     bBurning=True
}
