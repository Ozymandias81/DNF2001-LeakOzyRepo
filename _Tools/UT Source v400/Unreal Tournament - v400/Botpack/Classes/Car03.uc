//=============================================================================
// car03.
//=============================================================================
class Car03 extends Decoration;


#exec MESH IMPORT MESH=car03M ANIVFILE=MODELS\car02_a.3D DATAFILE=MODELS\car02_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=car03M  ZDISP=550
#exec MESH ORIGIN MESH=car03M X=0 Y=0 Z=0 PITCH=0 ROLL=-64
#exec MESH SEQUENCE MESH=car03M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=car03M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jcar3 FILE=MODELS\car03.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=car03M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=car03M NUM=1 TEXTURE=Jcar3

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.car03M'
}
