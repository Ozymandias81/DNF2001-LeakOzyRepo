//=============================================================================
// ut_femalefoot.
//=============================================================================
class UT_FemaleFoot extends UTPlayerChunks;


#exec MESH IMPORT MESH=femalefootm ANIVFILE=MODELS\femalefoot_a.3D DATAFILE=MODELS\femalefoot_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=femalefootm X=0 Y=0 Z=0 YAW=0 PITCH=0
#exec MESH SEQUENCE MESH=femalefootm SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=femalefootm SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=femalefootT  FILE=MODELS\femalefoot.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=femalefootm X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=femalefootm NUM=1 TEXTURE=femalefootT

defaultproperties
{
     Mesh=Mesh'Botpack.femalefootm'
     CollisionRadius=25.000000
     CollisionHeight=6.000000
	 Mass=+40.000
}
