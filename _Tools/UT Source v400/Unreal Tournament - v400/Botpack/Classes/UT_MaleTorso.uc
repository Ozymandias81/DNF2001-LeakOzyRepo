//=============================================================================
// ut_maletorso.
//=============================================================================
class UT_MaleTorso extends UTPlayerChunks;


#exec MESH IMPORT MESH=maletorsom ANIVFILE=MODELS\maleTorso_a.3D DATAFILE=MODELS\maletorso_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=maletorsom X=0 Y=0 Z=0 YAW=0 PITCH=0
#exec MESH SEQUENCE MESH=maletorsom SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=maletorsom SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=maletorsoT  FILE=MODELS\maletorso.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=maletorsom X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=maletorsom NUM=1 TEXTURE=maletorsoT

defaultproperties
{
     Mesh=Mesh'Botpack.maletorsom'
     CollisionRadius=25.000000
     CollisionHeight=6.000000
	 Mass=+50.000
}
