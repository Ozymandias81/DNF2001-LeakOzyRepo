//=============================================================================
// BigSprocket.
//=============================================================================
class BigSprocket extends StudMetal;

#exec MESH IMPORT MESH=BigSprocket ANIVFILE=MODELS\BigSprocket_a.3d DATAFILE=MODELS\BigSprocket_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BigSprocket X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=BigSprocket SEQ=All         STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BigSprocket SEQ=BigSprocket STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=BigSprocket MESH=BigSprocket
#exec MESHMAP SCALE MESHMAP=BigSprocket X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=BigSprocket NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=BigSprocket
}
