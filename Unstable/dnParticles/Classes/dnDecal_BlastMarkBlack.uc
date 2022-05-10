/*-----------------------------------------------------------------------------
	dnDecal_BlastMarkBlack
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnDecal_BlastMarkBlack expands dnDecal_BlastMark;

#exec OBJ LOAD FILE=..\Textures\dnModulation.dtx

defaultproperties
{
     Decals(0)=Texture't_generic.blastmarks1rc'
     Decals(1)=Texture't_generic.blastmarks3rc'
}
