//=============================================================================
// dnDebris_SmokeSubtle. 			  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_SmokeSubtle expands dnDebris_Smoke;

// Large subtle puff of white smoke.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
}
