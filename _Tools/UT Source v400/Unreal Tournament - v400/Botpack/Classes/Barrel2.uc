//=============================================================================
// barrel2.
//=============================================================================
class Barrel2 extends ut_Decoration;

#exec MESH IMPORT MESH=barrel2M ANIVFILE=MODELS\barrel2_a.3D DATAFILE=MODELS\barrel2_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=barrel2M STRENGTH=0.5
#exec MESH ORIGIN MESH=barrel2M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=barrel2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=barrel2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jbarrel2 FILE=MODELS\barrel2.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=barrel2M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=barrel2M NUM=1 TEXTURE=jbarrel2 TLOD=30

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.barrel2M'
     DrawScale=0.250000
     CollisionHeight=30.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
