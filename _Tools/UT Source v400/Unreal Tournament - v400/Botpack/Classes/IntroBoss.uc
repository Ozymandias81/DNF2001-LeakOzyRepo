//=============================================================================
// IntroBoss.
//=============================================================================
class IntroBoss expands Decoration;

#exec MESH IMPORT MESH=IntroBoss ANIVFILE=MODELS\IntroBoss_a.3d DATAFILE=MODELS\IntroBoss_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=IntroBoss X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=IntroBoss SEQ=All   STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=IntroBoss SEQ=wave  STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=IntroBoss SEQ=stand STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=IntroBoss MESH=IntroBoss
#exec MESHMAP SCALE MESHMAP=IntroBoss X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=IntroBoss1 FILE=Textures\IntroB1.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=IntroBoss2 FILE=Textures\IntroB2.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=IntroBoss3 FILE=Textures\IntroB3.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=IntroBoss4 FILE=Textures\IntroB4.PCX GROUP=Skins

#exec MESHMAP SETTEXTURE MESHMAP=IntroBoss NUM=0 TEXTURE=IntroBoss1
#exec MESHMAP SETTEXTURE MESHMAP=IntroBoss NUM=1 TEXTURE=IntroBoss2
#exec MESHMAP SETTEXTURE MESHMAP=IntroBoss NUM=2 TEXTURE=IntroBoss3
#exec MESHMAP SETTEXTURE MESHMAP=IntroBoss NUM=3 TEXTURE=IntroBoss4


Auto State IntroBoss
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (AnimSequence=='stand')
			GotoState( 'IntroBoss','wave');
		else
			GotoState( 'IntroBoss','stand');
	}

wave: 
	Disable('Trigger');
	PlayAnim('wave',0.5);
	FinishAnim();
	Enable('Trigger');	
	Stop;

stand:
	Disable('Trigger');
	PlayAnim('stand',1);
	FinishAnim();
	Sleep(1.0);
	Enable('Trigger');
	Stop;
	
Begin:
	PlayAnim('stand',0.4);
}

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.IntroBoss'
}
