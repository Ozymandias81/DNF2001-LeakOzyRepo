//=============================================================================
// ut_Blood2.
//=============================================================================
class UT_Blood2 extends Effects;

#exec MESH IMPORT MESH=BloodUTm ANIVFILE=MODELS\blood_a.3D DATAFILE=MODELS\blood_d.3D X=0 Y=0 Z=0 ZEROTEX=1 mlod=0

#exec MESH ORIGIN MESH=BloodUTm X=0 Y=0 Z=0 YAW=128  PITCH=0
#exec MESH SEQUENCE MESH=BloodUTm SEQ=All       STARTFRAME=0   NUMFRAMES=10
#exec MESH SEQUENCE MESH=BloodUTm SEQ=Spray     STARTFRAME=0   NUMFRAMES=10
#exec MESH SEQUENCE MESH=BloodUTm SEQ=Still     STARTFRAME=0   NUMFRAMES=10
#exec MESH SEQUENCE MESH=BloodUTm SEQ=GravSpray STARTFRAME=0   NUMFRAMES=10
#exec MESH SEQUENCE MESH=BloodUTm SEQ=Stream    STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=BloodUTm SEQ=Trail     STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=BloodUTm SEQ=Burst     STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=BloodUTm SEQ=GravSpray2 STARTFRAME=0 NUMFRAMES=10

#exec TEXTURE IMPORT NAME=BD3 FILE=MODELS\bd3.pcx GROUP=Blood FLAGS=2
#exec TEXTURE IMPORT NAME=BD4 FILE=MODELS\bd4.pcx GROUP=Blood FLAGS=2
#exec TEXTURE IMPORT NAME=BD6 FILE=MODELS\bd6.pcx GROUP=Blood FLAGS=2
#exec TEXTURE IMPORT NAME=BD9 FILE=MODELS\bd9.pcx GROUP=Blood FLAGS=2
#exec TEXTURE IMPORT NAME=BD10 FILE=MODELS\bd10.pcx GROUP=Blood FLAGS=2

#exec MESHMAP SCALE MESHMAP=BloodUTm X=0.09 Y=0.09 Z=0.19 YAW=128

var bool bGreenBlood;

simulated function GreenBlood()
{
	bGreenBlood = true;
	bHidden = true;
}

simulated function PreBeginPlay()
{
	if( class'GameInfo'.Default.bVeryLowGore )
		GreenBlood();
}

simulated function AnimEnd()
{
  	Destroy();
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Style=STY_Masked
     Texture=Texture'Botpack.Blood.BD3'
     Mesh=Mesh'Botpack.BloodUTm'
     DrawScale=0.250000
     AmbientGlow=56
     bUnlit=True
     bRandomFrame=True
     bParticles=True
	 bNetTemporary=true
     MultiSkins(0)=Texture'Botpack.Blood.BD3'
     MultiSkins(1)=Texture'Botpack.Blood.BD4'
     MultiSkins(2)=Texture'Botpack.Blood.BD6'
     MultiSkins(3)=Texture'Botpack.Blood.BD9'
     MultiSkins(4)=Texture'Botpack.Blood.BD10'
     MultiSkins(5)=Texture'Botpack.Blood.BD3'
     MultiSkins(6)=Texture'Botpack.Blood.BD4'
     MultiSkins(7)=Texture'Botpack.Blood.BD6'
}
