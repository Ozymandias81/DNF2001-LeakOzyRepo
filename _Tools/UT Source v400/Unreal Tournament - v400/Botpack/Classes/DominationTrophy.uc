//=============================================================================
// dominationtrophy.
//=============================================================================
class DominationTrophy extends Trophy;

#exec MESH IMPORT MESH=dominationM ANIVFILE=MODELS\domination_a.3D DATAFILE=MODELS\domination_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=dominationM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=dominationM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=dominationM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jdomination FILE=MODELS\domination.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=dominationM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=dominationM NUM=1 TEXTURE=jdomination

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.dominationM'
     DrawScale=0.200000
}
