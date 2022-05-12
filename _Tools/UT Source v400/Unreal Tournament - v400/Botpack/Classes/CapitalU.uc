//=============================================================================
// CapitalU.
//=============================================================================
class CapitalU extends StudMetal;

#exec MESH IMPORT MESH=CapitalU ANIVFILE=MODELS\CapitalU_a.3d DATAFILE=MODELS\CapitalU_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CapitalU X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=CapitalU SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=CapitalU SEQ=CapitalU STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=CapitalU MESH=CapitalU
#exec MESHMAP SCALE MESHMAP=CapitalU X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=CapitalU NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=CapitalU
}
