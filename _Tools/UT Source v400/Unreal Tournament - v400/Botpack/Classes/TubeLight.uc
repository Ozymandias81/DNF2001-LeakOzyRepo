//=============================================================================
// tubelight.
//=============================================================================
class TubeLight extends ut_Decoration;

#exec MESH IMPORT MESH=tubelightM ANIVFILE=MODELS\tubelight_a.3D DATAFILE=MODELS\tubelight_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=tubelightM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=tubelightM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=tubelightM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jtubelight FILE=MODELS\tubelight.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=tubelightM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=tubelightM NUM=1 TEXTURE=jtubelight

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.tubelightM'
     DrawScale=0.500000
}
