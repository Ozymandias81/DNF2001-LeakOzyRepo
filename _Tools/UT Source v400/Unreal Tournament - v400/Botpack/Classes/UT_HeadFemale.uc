//=============================================================================
// ut_HeadFemale.
//=============================================================================
class UT_HeadFemale extends UTHeads;


#exec MESH IMPORT MESH=HeadFemaleM ANIVFILE=MODELS\headfemale_a.3D DATAFILE=MODELS\headfemale_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=HeadFemaleM X=0 Y=0 Z=0 YAW=64 PITCH=64
#exec MESH SEQUENCE MESH=HeadFemaleM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=HeadFemaleM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=FMT1  FILE=MODELS\headfemale.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=HeadFemaleM X=0.07 Y=0.07 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=HeadFemaleM NUM=1 TEXTURE=FMT1

defaultproperties
{
     Mesh=Mesh'Botpack.HeadFemaleM'
}
