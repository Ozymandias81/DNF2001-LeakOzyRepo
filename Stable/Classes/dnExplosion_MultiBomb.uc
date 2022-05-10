/*-----------------------------------------------------------------------------
	dnExplosion_MultiBomb
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnExplosion_MultiBomb expands dnExplosion1;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
	 AdditionalSpawn(4)=(SpawnClass=Class'dnParticles.dnDecal_BlastMark2')
}
