//=============================================================================
// FlatMirror.
//=============================================================================
class FlatMirror extends StudMetal;

#exec MESH IMPORT MESH=FlatMirror ANIVFILE=MODELS\FlatMirror_a.3d DATAFILE=MODELS\FlatMirror_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FlatMirror X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=FlatMirror SEQ=All        STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=FlatMirror SEQ=FlatMirror STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=FlatMirror MESH=FlatMirror
#exec MESHMAP SCALE MESHMAP=FlatMirror X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=FlatMirror NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=FlatMirror
}
