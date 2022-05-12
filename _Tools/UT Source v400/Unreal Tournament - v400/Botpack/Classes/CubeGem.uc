//=============================================================================
// CubeGem.
//=============================================================================
class CubeGem extends StudMetal;

#exec MESH IMPORT MESH=CubeGem ANIVFILE=MODELS\CubeGem_a.3d DATAFILE=MODELS\CubeGem_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CubeGem X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=CubeGem SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=CubeGem SEQ=CubeGem STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=CubeGem MESH=CubeGem
#exec MESHMAP SCALE MESHMAP=CubeGem X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=CubeGem NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=CubeGem
}
