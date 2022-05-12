//=============================================================================
// ut_malefoot.
//=============================================================================
class UT_MaleFoot extends UTPlayerChunks;


#exec MESH IMPORT MESH=malefootm ANIVFILE=MODELS\malefoot_a.3D DATAFILE=MODELS\malefoot_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=malefootm X=0 Y=0 Z=0 YAW=0 PITCH=0
#exec MESH SEQUENCE MESH=malefootm SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=malefootm SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=malefootT  FILE=MODELS\malefoot.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=malefootm X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=malefootm NUM=1 TEXTURE=malefootT

defaultproperties
{
     Mesh=Mesh'Botpack.malefootm'
     CollisionRadius=25.000000
     CollisionHeight=6.000000
	 Mass=+40.000
	 Fatness=140
}
