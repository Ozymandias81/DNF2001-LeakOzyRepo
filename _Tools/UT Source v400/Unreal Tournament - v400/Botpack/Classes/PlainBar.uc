//=============================================================================
// PlainBar.
//=============================================================================
class PlainBar extends StudMetal;

#exec MESH IMPORT MESH=PlainBar ANIVFILE=MODELS\PlainBar_a.3d DATAFILE=MODELS\PlainBar_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PlainBar X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=PlainBar SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=PlainBar SEQ=PlainBar STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=PlainBar MESH=PlainBar
#exec MESHMAP SCALE MESHMAP=PlainBar X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=PlainBar NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=PlainBar
}
