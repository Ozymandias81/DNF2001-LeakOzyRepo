//=============================================================================
// dnExplosion1_Spawner2.						   Keith Schuler April 12, 2000
//=============================================================================
class dnExplosion1_Spawner2 expands dnExplosion1;

// Explosion effect spawner.
// Does NOT do damage. 
// Uses dnExplosion1_Effect1, dnExplosion1_Effect2, dnExplosion1_Effect3.
// General purpose explosion.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
     AdditionalSpawn(3)=(SpawnClass=None)
     AdditionalSpawn(4)=(SpawnClass=None)
     CreationSoundRadius=8192.000000
     bBurning=True
     CollisionRadius=22.000000
     CollisionHeight=22.000000
}
