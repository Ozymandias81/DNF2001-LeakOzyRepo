//=============================================================================
// Diamond.
//=============================================================================
class Diamond extends StudMetal;

#exec MESH IMPORT MESH=Diamond ANIVFILE=MODELS\Diamond_a.3d DATAFILE=MODELS\Diamond_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Diamond X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=Diamond SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Diamond SEQ=Diamond STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=Diamond MESH=Diamond
#exec MESHMAP SCALE MESHMAP=Diamond X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Diamond NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=Diamond
}
