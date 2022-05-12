//=============================================================================
// assaulttrophy.
//=============================================================================
class AssaultTrophy extends Trophy;

#exec MESH IMPORT MESH=assaulttrophyM ANIVFILE=MODELS\assaulttrophy_a.3D DATAFILE=MODELS\assaulttrophy_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=assaulttrophyM STRENGTH=0.5
#exec MESH ORIGIN MESH=assaulttrophyM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=assaulttrophyM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=assaulttrophyM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jassaulttrophy FILE=MODELS\assaulttrophy.pcx GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=assaulttrophyM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=assaulttrophyM NUM=1 TEXTURE=jassaulttrophy

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.assaulttrophyM'
     DrawScale=0.200000
}
