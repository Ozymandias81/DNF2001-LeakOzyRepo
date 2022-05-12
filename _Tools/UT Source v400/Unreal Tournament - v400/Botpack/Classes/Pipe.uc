//=============================================================================
// pipe.
//=============================================================================
class Pipe extends UT_Decoration;

#exec MESH IMPORT MESH=pipeM ANIVFILE=MODELS\pipe_a.3D DATAFILE=MODELS\pipe_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=pipeM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=pipeM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=pipeM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jpipe FILE=MODELS\pipe.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=pipeM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=pipeM NUM=1 TEXTURE=jpipe

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.pipeM'
     DrawScale=0.500000
}
