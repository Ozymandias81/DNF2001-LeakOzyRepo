//=============================================================================
// wreck1.
//=============================================================================
class Wreck1 extends UT_Decoration;

#exec MESH IMPORT MESH=wreck1M ANIVFILE=MODELS\wreck1_a.3D DATAFILE=MODELS\wreck1_d.3D LODSTYLE=12
#exec MESH ORIGIN MESH=wreck1M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=wreck1M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=wreck1M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jwreck1 FILE=MODELS\wreck1.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=wreck1M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=wreck1M NUM=1 TEXTURE=jwreck1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.wreck1M'
}
