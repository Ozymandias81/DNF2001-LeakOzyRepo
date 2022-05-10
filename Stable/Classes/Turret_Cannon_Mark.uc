//=============================================================================
// Turret_Cannon_Mark.
//   =============================================================================

// Cole

class Turret_Cannon_Mark expands dnDecal;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Decals(0)=Texture't_generic.blastmarks.blastmarks3RC'
     BehaviorArgument=2.000000
     Behavior=DB_DestroyNotVisibleForArgumentSeconds
     DrawScale=0.100000
}
