//=============================================================================
// CircleStud.
//=============================================================================
class CircleStud extends StudMetal;

#exec MESH IMPORT MESH=CircleStud ANIVFILE=MODELS\CircleStud2_a.3d DATAFILE=MODELS\CircleStud2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CircleStud X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=CircleStud SEQ=All        STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=CircleStud SEQ=CircleStud STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=CircleStud MESH=CircleStud
#exec MESHMAP SCALE MESHMAP=CircleStud X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=CircleStud NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=CircleStud
}
