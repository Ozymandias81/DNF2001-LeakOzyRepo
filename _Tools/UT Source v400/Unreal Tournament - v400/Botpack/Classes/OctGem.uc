//=============================================================================
// OctGem.
//=============================================================================
class OctGem extends StudMetal;

#exec MESH IMPORT MESH=OctGem ANIVFILE=MODELS\OctGem_a.3d DATAFILE=MODELS\OctGem_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=OctGem X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=OctGem SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=OctGem SEQ=OctGem STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=OctGem MESH=OctGem
#exec MESHMAP SCALE MESHMAP=OctGem X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=OctGem NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=OctGem
}
