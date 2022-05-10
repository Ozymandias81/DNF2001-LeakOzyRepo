//=============================================================================
// dnColaMachine_Beer. 				   November 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnColaMachine_Beer expands dnColaMachine_Brown;

// Stream of beer from the beer machine

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Textures(0)=Texture't_generic.liquids.genliquidber1RC'
     Textures(1)=Texture't_generic.liquids.genliquidber2RC'
     Textures(2)=Texture't_generic.liquids.genliquidber3RC'
}
