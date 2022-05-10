/*-----------------------------------------------------------------------------
	dnDecal_BlastMark
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnDecal_BlastMark expands dnDecal;

#exec OBJ LOAD FILE=..\Textures\dnModulation.dtx

defaultproperties
{
     Decals(0)=Texture'dnModulation.mofoblast_1tw'
     Decals(1)=Texture'dnModulation.mofoblast_2tw'
     BehaviorArgument=4.000000
     Behavior=DB_DestroyNotVisibleForArgumentSeconds
     MinSpawnDistance=2.000000
     DrawScale=1.0
}
