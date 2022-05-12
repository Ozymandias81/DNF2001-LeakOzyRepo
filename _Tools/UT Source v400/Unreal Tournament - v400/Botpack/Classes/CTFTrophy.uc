//=============================================================================
// ctftrophy.
//=============================================================================
class CTFTrophy extends Trophy;

#exec MESH IMPORT MESH=ctftrophyM ANIVFILE=MODELS\ctftrophy_a.3D DATAFILE=MODELS\ctftrophy_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ctftrophyM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=ctftrophyM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=ctftrophyM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jctftrophy FILE=MODELS\ctftrophy.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=ctftrophyM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=ctftrophyM NUM=1 TEXTURE=jctftrophy

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.ctftrophyM'
     DrawScale=0.200000
}
