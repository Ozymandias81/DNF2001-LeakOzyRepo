//=============================================================================
// UT_Thigh.
//=============================================================================
class UT_Thigh extends UTPlayerChunks;


#exec MESH IMPORT MESH=ThighUTM ANIVFILE=MODELS\THigh_a.3D DATAFILE=MODELS\thigh_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ThighUTM X=70 Y=0 Z=-80 YAW=64 PITCH=64
#exec MESH SEQUENCE MESH=ThighUTM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=ThighUTM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=ThighT  FILE=MODELS\Thigh.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=ThighUTM X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=ThighUTM NUM=1 TEXTURE=ThighT

defaultproperties
{
     Mesh=Mesh'Botpack.ThighUTM'
     CollisionRadius=25.000000
     CollisionHeight=6.000000
}
