//=============================================================================
// dnSparkEffect_Spawner1. 							Keith Schuler April 13,2000
//=============================================================================
class dnSparkEffect_Spawner1 expands dnSparkEffect;

// Spark effect spawner
// Does NOT do damage 
// Uses dnSparkEffect_Effect1
// Spark explosion used by Lady Killer sign

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
	 UpdateWhenNotVisible=true
}
