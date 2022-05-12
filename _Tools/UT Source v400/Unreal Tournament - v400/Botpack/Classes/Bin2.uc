//=============================================================================
// bin2.
//=============================================================================
class Bin2 extends ut_Decoration;

#exec MESH IMPORT MESH=bin2M ANIVFILE=MODELS\bin2_a.3D DATAFILE=MODELS\bin2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bin2M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=bin2M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=bin2M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jbin2 FILE=MODELS\bin2.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=bin2M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=bin2M NUM=1 TEXTURE=jbin2

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.bin2M'
     DrawScale=0.250000
     CollisionHeight=30.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
