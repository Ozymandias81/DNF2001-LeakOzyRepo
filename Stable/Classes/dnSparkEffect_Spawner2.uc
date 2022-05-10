//=============================================================================
// dnSparkEffect_Spawner2.							Keith Schuler April 13,2000
//=============================================================================
class dnSparkEffect_Spawner2 expands dnSparkEffect;

// Spark effect spawner
// Does NOT do damage 
// Uses dnSparkEffect_Effect2, dnExplosion1_Effect1
// Spark explosion used by Lady Killer sign

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnSparkEffect_Effect2')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnExplosion1_Effect1')
     StartDrawScale=10.000000
 	 UpdateWhenNotVisible=true

}
