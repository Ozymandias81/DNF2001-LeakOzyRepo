//=============================================================================
// ArrowStud.
//=============================================================================
class ArrowStud extends StudMetal;

#exec MESH IMPORT MESH=ArrowStud ANIVFILE=MODELS\ArrowStud_a.3d DATAFILE=MODELS\ArrowStud_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ArrowStud X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=ArrowStud SEQ=All        STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ArrowStud SEQ=ArrowStudA STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=ArrowStud MESH=ArrowStud
#exec MESHMAP SCALE MESHMAP=ArrowStud X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=ArrowStud NUM=0 TEXTURE=StudMap


defaultproperties
{
    DrawType=DT_Mesh
    Mesh=ArrowStud
}
