//=============================================================================
// Crystal.
//=============================================================================
class Crystal extends StudMetal;

#exec MESH IMPORT MESH=Crystal ANIVFILE=MODELS\Crystal_a.3d DATAFILE=MODELS\Crystal_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Crystal X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=Crystal SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Crystal SEQ=Crystal STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=Crystal MESH=Crystal
#exec MESHMAP SCALE MESHMAP=Crystal X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Crystal NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=Crystal
}
