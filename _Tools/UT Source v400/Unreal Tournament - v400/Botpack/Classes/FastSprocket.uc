//=============================================================================
// FastSprocket.
//=============================================================================
class FastSprocket extends StudMetal;

#exec MESH IMPORT MESH=FastSprocket ANIVFILE=MODELS\FastSprocket_a.3d DATAFILE=MODELS\FastSprocket_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FastSprocket X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=FastSprocket SEQ=All          STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=FastSprocket SEQ=FastSprocket STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=FastSprocket MESH=FastSprocket
#exec MESHMAP SCALE MESHMAP=FastSprocket X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=FastSprocket NUM=0 TEXTURE=StudMap

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=FastSprocket
}
