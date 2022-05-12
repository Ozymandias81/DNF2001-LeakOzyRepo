//=============================================================================
// barrel3.
//=============================================================================
class Barrel3 extends ut_Decoration;

#exec MESH IMPORT MESH=barrel3M ANIVFILE=MODELS\barrel3_a.3D DATAFILE=MODELS\barrel3_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=barrel2M STRENGTH=0.5
#exec MESH ORIGIN MESH=barrel3M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=barrel3M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=barrel3M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jbarrel3 FILE=MODELS\barrel3.pcx GROUP=Skins   LODSET=2
#exec MESHMAP SCALE MESHMAP=barrel3M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=barrel3M NUM=1 TEXTURE=jbarrel3 TLOD=30

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.barrel3M'
     DrawScale=0.250000
     CollisionHeight=30.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
