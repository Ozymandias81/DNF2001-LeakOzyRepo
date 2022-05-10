//=============================================================================
// dnExplosion1_Effect5.
//=============================================================================
class dnExplosion1_Effect5 expands dnExplosion1;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     AdditionalSpawn(2)=(SpawnClass=None)
     CreationSound=None
     Textures(0)=Texture't_explosionFx.explosion64.R321_004'
     DieOnLastFrame=True
     StartDrawScale=2.000000
     EndDrawScale=1.000000
     RotationVariance=65535.000000
}
