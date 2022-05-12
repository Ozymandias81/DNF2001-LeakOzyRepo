//=============================================================================
// boulder1.
//=============================================================================
class Boulder1 extends ut_Decoration;

#exec MESH IMPORT MESH=boulder1M ANIVFILE=MODELS\boulder1_a.3D DATAFILE=MODELS\boulder1_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=boulder1M X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=boulder1M SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=boulder1M SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jboulder1 FILE=MODELS\boulder1.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=boulder1M X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=boulder1M NUM=1 TEXTURE=jboulder1

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.boulder1M'
     bBlockActors=True
     bBlockPlayers=True
	 CollisionHeight=+22.0
	 CollisionRadius=+40.0
}
