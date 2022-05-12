//=============================================================================
// PlainStud.
//=============================================================================
class PlainStud extends StudMetal;

#exec MESH IMPORT MESH=PlainStud ANIVFILE=MODELS\PlainStud_a.3d DATAFILE=MODELS\PlainStud_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PlainStud X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=PlainStud SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=PlainStud SEQ=PlainStud STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=PlainStud MESH=PlainStud
#exec MESHMAP SCALE MESHMAP=PlainStud X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=PlainStud NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=PlainStud
}
