//=============================================================================
// bin3.
//=============================================================================
class Bin3 extends ut_Decoration;

#exec MESH IMPORT MESH=bin3M ANIVFILE=MODELS\bin3_a.3D DATAFILE=MODELS\bin3_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bin3M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=bin3M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=bin3M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jbin3 FILE=MODELS\bin3.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=bin3M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=bin3M NUM=1 TEXTURE=jbin3

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.bin3M'
     DrawScale=0.250000
     CollisionHeight=30.000000
     bBlockActors=True
     bBlockPlayers=True
}
