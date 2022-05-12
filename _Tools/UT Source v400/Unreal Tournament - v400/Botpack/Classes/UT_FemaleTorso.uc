//=============================================================================
// ut_femaletorso.
//=============================================================================
class UT_FemaleTorso extends UTPlayerChunks;


#exec MESH IMPORT MESH=femaletorsom ANIVFILE=MODELS\FemaleTorso_a.3D DATAFILE=MODELS\FemaleTorso_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=femaletorsom X=0 Y=0 Z=0 YAW=0 PITCH=0
#exec MESH SEQUENCE MESH=femaletorsom SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=femaletorsom SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=FemaleTorsoT  FILE=MODELS\FemaleTorso.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=femaletorsom X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=femaletorsom NUM=1 TEXTURE=FemaleTorsoT

defaultproperties
{
     Mesh=Mesh'Botpack.femaletorsom'
     CollisionRadius=25.000000
     CollisionHeight=6.000000
	 Mass=+50.000
}
