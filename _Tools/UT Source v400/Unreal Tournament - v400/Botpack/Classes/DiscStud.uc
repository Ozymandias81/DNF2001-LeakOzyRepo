//=============================================================================
// DiscStud.
//=============================================================================
class DiscStud extends StudMetal;

#exec MESH IMPORT MESH=DiscStud ANIVFILE=MODELS\DiscStud_a.3d DATAFILE=MODELS\DiscStud_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=DiscStud X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=DiscStud SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=DiscStud SEQ=DiscStud STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=DiscStud MESH=DiscStud
#exec MESHMAP SCALE MESHMAP=DiscStud X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=DiscStud NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=DiscStud
}
