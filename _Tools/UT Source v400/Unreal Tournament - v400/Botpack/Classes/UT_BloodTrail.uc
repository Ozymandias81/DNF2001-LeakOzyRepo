//=============================================================================
// ut_BloodTrail.
//=============================================================================
class UT_BloodTrail extends ut_Blood2;

#exec MESH IMPORT MESH=UTBloodTrl ANIVFILE=MODELS\Blood2_a.3D DATAFILE=MODELS\Blood2_d.3D X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=UTBloodTrl X=0 Y=0 Z=0 YAW=128
#exec MESH SEQUENCE MESH=UTBloodTrl SEQ=All       STARTFRAME=0   NUMFRAMES=45
#exec MESH SEQUENCE MESH=UTBloodTrl SEQ=Spray     STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=UTBloodTrl SEQ=Still     STARTFRAME=6   NUMFRAMES=1
#exec MESH SEQUENCE MESH=UTBloodTrl SEQ=GravSpray STARTFRAME=7   NUMFRAMES=5
#exec MESH SEQUENCE MESH=UTBloodTrl SEQ=Stream    STARTFRAME=12  NUMFRAMES=11
#exec MESH SEQUENCE MESH=UTBloodTrl SEQ=Trail     STARTFRAME=23  NUMFRAMES=11
#exec MESH SEQUENCE MESH=UTBloodTrl SEQ=Burst     STARTFRAME=34  NUMFRAMES=2
#exec MESH SEQUENCE MESH=UTBloodTrl SEQ=GravSpray2 STARTFRAME=36 NUMFRAMES=7

#exec MESHMAP SCALE MESHMAP=UTBloodTrl X=0.11 Y=0.055 Z=0.11 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=UTBloodTrl NUM=0  TEXTURE=BloodSpot

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();	
	LoopAnim('Trail');
	bRandomFrame = !Level.bDropDetail;
}

function AnimEnd()
{
}

defaultproperties
{
	 AnimSequence=Trail
     Texture=Texture'Botpack.Blood.BD6'
     RemoteRole=ROLE_None
     Physics=PHYS_Trailer
     LifeSpan=5.000000
     AnimSequence=trail
     Mesh=LodMesh'Botpack.UTBloodTrl'
     DrawScale=0.200000
     AmbientGlow=0
}
