//=============================================================================
// ut_femalearm.
//=============================================================================
class UT_FemaleArm extends UTPlayerChunks;


#exec MESH IMPORT MESH=femalearmm ANIVFILE=MODELS\femalearm_a.3D DATAFILE=MODELS\femalearm_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=femalearmm X=0 Y=0 Z=0 YAW=0 PITCH=0
#exec MESH SEQUENCE MESH=femalearmm SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=femalearmm SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=femalearmT  FILE=MODELS\femalearm.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=femalearmm X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=femalearmm NUM=1 TEXTURE=femalearmT

defaultproperties
{
     Mesh=Mesh'Botpack.femalearmm'
     CollisionRadius=25.000000
     CollisionHeight=6.000000
}
