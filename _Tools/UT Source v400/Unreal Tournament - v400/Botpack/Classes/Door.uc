//=============================================================================
// door.
//=============================================================================
class Door extends UT_Decoration;

#exec MESH IMPORT MESH=doorM ANIVFILE=MODELS\door_a.3D DATAFILE=MODELS\door_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=doorM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=doorM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=doorM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jdoor FILE=MODELS\door.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=doorM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=doorM NUM=1 TEXTURE=jdoor

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.doorM'
}
