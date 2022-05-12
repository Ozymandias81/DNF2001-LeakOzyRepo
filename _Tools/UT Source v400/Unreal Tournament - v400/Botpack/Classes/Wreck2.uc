//=============================================================================
// wreck2.
//=============================================================================
class Wreck2 extends UT_Decoration;

#exec MESH IMPORT MESH=wreck2M ANIVFILE=MODELS\wreck2_a.3D DATAFILE=MODELS\wreck2_d.3D LODSTYLE=12
#exec MESH ORIGIN MESH=wreck2M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=wreck2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=wreck2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jwreck2 FILE=MODELS\wreck2.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=wreck2M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=wreck2M NUM=1 TEXTURE=jwreck2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.wreck2M'
}
