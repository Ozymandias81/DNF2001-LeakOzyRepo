//=============================================================================
// icbm.
//=============================================================================
class ICBM extends UT_Decoration;

#exec MESH IMPORT MESH=icbmM ANIVFILE=MODELS\icbm_a.3D DATAFILE=MODELS\icbm_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=icbmM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=icbmM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=icbmM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jicbm FILE=MODELS\icbm.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=icbmM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=icbmM NUM=1 TEXTURE=jicbm

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.icbmM'
     bCollideActors=True
}
