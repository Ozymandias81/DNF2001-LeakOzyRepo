//=============================================================================
// SquareStud.
//=============================================================================
class SquareStud extends StudMetal;

#exec MESH IMPORT MESH=SquareStud ANIVFILE=MODELS\SquareStud_a.3d DATAFILE=MODELS\SquareStud_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SquareStud X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=SquareStud SEQ=All        STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=SquareStud SEQ=SquareStud STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=SquareStud MESH=SquareStud
#exec MESHMAP SCALE MESHMAP=SquareStud X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=SquareStud NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=SquareStud
}
