//=============================================================================
// OctStud.
//=============================================================================
class OctStud extends StudMetal;

#exec MESH IMPORT MESH=OctStud ANIVFILE=MODELS\OctStud_a.3d DATAFILE=MODELS\OctStud_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=OctStud X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=OctStud SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=OctStud SEQ=OctStudA STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=OctStud MESH=OctStud
#exec MESHMAP SCALE MESHMAP=OctStud X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=OctStud NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=OctStud
}
