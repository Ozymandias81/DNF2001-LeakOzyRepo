//=============================================================================
// ut_headmale.
//=============================================================================
class UT_HeadMale extends UTHeads;

#exec MESH IMPORT MESH=headmalem ANIVFILE=MODELS\headmale_a.3D DATAFILE=MODELS\headmale_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=headmalem X=0 Y=0 Z=0 YAW=64 PITCH=64
#exec MESH SEQUENCE MESH=headmalem SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=headmalem SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=MMT1  FILE=MODELS\headmale.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=headmalem X=0.07 Y=0.07 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=headmalem NUM=1 TEXTURE=MMT1

defaultproperties
{
     Mesh=Mesh'Botpack.headmalem'
}
