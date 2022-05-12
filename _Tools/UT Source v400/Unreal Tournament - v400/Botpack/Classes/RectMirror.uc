//=============================================================================
// RectMirror.
//=============================================================================
class RectMirror extends StudMetal;

#exec MESH IMPORT MESH=RectMirror ANIVFILE=MODELS\RectMirror_a.3d DATAFILE=MODELS\RectMirror_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RectMirror X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=RectMirror SEQ=All        STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=RectMirror SEQ=RectMirror STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=RectMirror MESH=RectMirror
#exec MESHMAP SCALE MESHMAP=RectMirror X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=RectMirror NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=RectMirror
}
