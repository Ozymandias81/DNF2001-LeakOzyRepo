//=============================================================================
// car02.
//=============================================================================
class Car02 extends Decoration;


#exec MESH IMPORT MESH=car02M ANIVFILE=MODELS\car02_a.3D DATAFILE=MODELS\car02_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=car02M  ZDISP=550
#exec MESH ORIGIN MESH=car02M X=0 Y=0 Z=0 PITCH=0 ROLL=-64
#exec MESH SEQUENCE MESH=car02M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=car02M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jcar2 FILE=MODELS\car02.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=car02M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=car02M NUM=1 TEXTURE=Jcar2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.car02M'
}
