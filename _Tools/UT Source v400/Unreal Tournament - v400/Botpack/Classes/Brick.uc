//=============================================================================
// brick.
//=============================================================================
class Brick extends ut_Decoration;

#exec MESH IMPORT MESH=brickM ANIVFILE=MODELS\brick_a.3D DATAFILE=MODELS\brick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=brickM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=brickM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=brickM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jbrick FILE=MODELS\brick.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=brickM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=brickM NUM=1 TEXTURE=jbrick

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.brickM'
     DrawScale=0.150000
     CollisionRadius=17.000000
     CollisionHeight=7.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
