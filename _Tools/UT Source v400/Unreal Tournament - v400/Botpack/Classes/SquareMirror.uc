//=============================================================================
// SquareMirror.
//=============================================================================
class SquareMirror extends StudMetal;

#exec MESH IMPORT MESH=SquareMirror ANIVFILE=MODELS\SquareMirror_a.3d DATAFILE=MODELS\SquareMirror_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SquareMirror X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=SquareMirror SEQ=All          STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=SquareMirror SEQ=SquareMirror STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=SquareMirror MESH=SquareMirror
#exec MESHMAP SCALE MESHMAP=SquareMirror X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=SquareMirror NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=SquareMirror
}
