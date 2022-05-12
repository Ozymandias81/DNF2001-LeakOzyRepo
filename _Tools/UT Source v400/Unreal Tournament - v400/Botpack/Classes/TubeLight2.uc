//=============================================================================
// tubelight2.
//=============================================================================
class TubeLight2 extends ut_Decoration;

#exec MESH IMPORT MESH=tubelight2M ANIVFILE=MODELS\tubelight2_a.3D DATAFILE=MODELS\tubelight2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=tubelight2M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=tubelight2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=tubelight2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jtubelight2 FILE=MODELS\tubelight2.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=tubelight2M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=tubelight2M NUM=1 TEXTURE=jtubelight2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.tubelight2M'
     DrawScale=0.500000
}
