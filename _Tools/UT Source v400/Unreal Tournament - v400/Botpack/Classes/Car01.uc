//=============================================================================
// car01.
//=============================================================================
class Car01 extends Decoration;


#exec MESH IMPORT MESH=car01M ANIVFILE=MODELS\car01_a.3D DATAFILE=MODELS\car01_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=car01M  ZDISP=550
#exec MESH ORIGIN MESH=car01M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=car01M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=car01M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jcar1 FILE=MODELS\car01.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=car01M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=car01M NUM=1 TEXTURE=Jcar1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.car01M'
}
