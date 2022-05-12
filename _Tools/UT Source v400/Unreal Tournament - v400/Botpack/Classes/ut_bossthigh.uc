//=============================================================================
// ut_bossthigh.
//=============================================================================
class UT_bossthigh extends UTPlayerChunks;


#exec MESH IMPORT MESH=bossthighm ANIVFILE=MODELS\bossthigh_a.3D DATAFILE=MODELS\bossthigh_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bossthighm X=0 Y=0 Z=0 YAW=0 PITCH=0
#exec MESH SEQUENCE MESH=bossthighm SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=bossthighm SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=bossthighT  FILE=MODELS\boss.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=bossthighm X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=bossthighm NUM=1 TEXTURE=bossthighT

defaultproperties
{
     Mesh=LodMesh'Botpack.bossthighm'
     DrawScale=0.400000
     CollisionRadius=25.000000
     CollisionHeight=6.000000
     Mass=40.000000
}
