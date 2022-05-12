//=============================================================================
// ut_malearm.
//=============================================================================
class UT_MaleArm extends UTPlayerChunks;


#exec MESH IMPORT MESH=malearmm ANIVFILE=MODELS\malearm_a.3D DATAFILE=MODELS\malearm_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=malearmm X=0 Y=0 Z=0 YAW=0 PITCH=0
#exec MESH SEQUENCE MESH=malearmm SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=malearmm SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=malearmT  FILE=MODELS\malearm.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=malearmm X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=malearmm NUM=1 TEXTURE=malearmT

defaultproperties
{
     Mesh=Mesh'Botpack.malearmm'
     CollisionRadius=25.000000
     CollisionHeight=6.000000
	 Fatness=140
}
