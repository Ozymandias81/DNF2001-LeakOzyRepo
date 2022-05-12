//=============================================================================
// barrel1.
//=============================================================================
class Barrel1 extends ut_Decoration;

#exec MESH IMPORT MESH=barrel1M ANIVFILE=MODELS\barrel1_a.3D DATAFILE=MODELS\barrel1_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=barrel1M STRENGTH=0.5
#exec MESH ORIGIN MESH=barrel1M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=barrel1M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=barrel1M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jbarreli1 FILE=MODELS\barrel1.pcx GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=barrel1M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=barrel1M NUM=1 TEXTURE=jbarreli1 TLOD=30

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.barrel1M'
     DrawScale=0.250000
     CollisionHeight=30.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
