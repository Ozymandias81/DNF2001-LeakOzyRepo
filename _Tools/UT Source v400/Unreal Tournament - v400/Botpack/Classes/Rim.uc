//=============================================================================
// rim.
//=============================================================================
class Rim extends UT_Decoration;

#exec MESH IMPORT MESH=rimM ANIVFILE=MODELS\rim_a.3D DATAFILE=MODELS\rim_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=rimM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=rimM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=rimM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jrim FILE=MODELS\rim.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=rimM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=rimM NUM=1 TEXTURE=jrim

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.rimM'
     DrawScale=0.150000
     CollisionRadius=18.000000
     CollisionHeight=7.000000
     bCollideActors=True
}
