//=============================================================================
// ut_bossarm.
//=============================================================================
class UT_bossarm extends UTPlayerChunks;


#exec MESH IMPORT MESH=bossarmm ANIVFILE=MODELS\bossarm_a.3D DATAFILE=MODELS\bossarm_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bossarmm X=0 Y=0 Z=0 YAW=0 PITCH=0
#exec MESH SEQUENCE MESH=bossarmm SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=bossarmm SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=bossarmT  FILE=MODELS\boss.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=bossarmm X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=bossarmm NUM=1 TEXTURE=bossarmT

defaultproperties
{
     Mesh=LodMesh'Botpack.bossarmm'
     DrawScale=0.500000
     CollisionRadius=25.000000
     Mass=40.000000
	 Fatness=140
}
