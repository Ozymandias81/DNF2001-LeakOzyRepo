//=============================================================================
// TriStud.
//=============================================================================
class TriStud extends StudMetal;

#exec MESH IMPORT MESH=TriStud ANIVFILE=MODELS\TriStud_a.3d DATAFILE=MODELS\TriStud_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TriStud X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=TriStud SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TriStud SEQ=TriStudA STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=TriStud MESH=TriStud
#exec MESHMAP SCALE MESHMAP=TriStud X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=TriStud NUM=0 TEXTURE=StudMap


defaultproperties
{
    DrawType=DT_Mesh
    Mesh=TriStud
}
