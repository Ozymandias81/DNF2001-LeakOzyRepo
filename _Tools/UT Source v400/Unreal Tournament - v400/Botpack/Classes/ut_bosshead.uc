//=============================================================================
// ut_bosshead.
//=============================================================================
class UT_bosshead extends UTHeads;


#exec MESH IMPORT MESH=bossheadm ANIVFILE=MODELS\bosshead_a.3D DATAFILE=MODELS\bosshead_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bossheadm X=0 Y=0 Z=0 YAW=0 PITCH=64
#exec MESH SEQUENCE MESH=bossheadm SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=bossheadm SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=bossheadT  FILE=MODELS\boss.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=bossheadm X=0.05 Y=0.05 Z=0.10
#exec MESHMAP SETTEXTURE MESHMAP=bossheadm NUM=1 TEXTURE=bossheadT

defaultproperties
{
     Mesh=LodMesh'Botpack.bossheadm'
     DrawScale=0.220000
     CollisionRadius=25.000000
     CollisionHeight=6.000000
     Mass=40.000000
}
