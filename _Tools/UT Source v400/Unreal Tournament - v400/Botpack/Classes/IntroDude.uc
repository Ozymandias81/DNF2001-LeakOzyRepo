//=============================================================================
// IntroDude.
//=============================================================================
class IntroDude expands decoration;

#exec MESH IMPORT MESH=IntroDude ANIVFILE=MODELS\IntroDude_a.3d DATAFILE=MODELS\IntroDude_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=IntroDude X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=IntroDude SEQ=All   STARTFRAME=0 NUMFRAMES=200
#exec MESH SEQUENCE MESH=IntroDude SEQ=stand STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=IntroDude SEQ=shake STARTFRAME=0 NUMFRAMES=200

#exec MESHMAP NEW   MESHMAP=IntroDude MESH=IntroDude
#exec MESHMAP SCALE MESHMAP=IntroDude X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=IntroDude1 FILE=Textures\IntroD1.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=IntroDude2 FILE=Textures\IntroD2.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=IntroDude3 FILE=Textures\IntroD3.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=IntroDude4 FILE=Textures\IntroD4.PCX GROUP=Skins

#exec MESHMAP SETTEXTURE MESHMAP=IntroDude NUM=0 TEXTURE=IntroDude1
#exec MESHMAP SETTEXTURE MESHMAP=IntroDude NUM=1 TEXTURE=IntroDude2
#exec MESHMAP SETTEXTURE MESHMAP=IntroDude NUM=2 TEXTURE=IntroDude3
#exec MESHMAP SETTEXTURE MESHMAP=IntroDude NUM=3 TEXTURE=IntroDude4


Auto State IntroDude
{

function Trigger( actor Other, pawn EventInstigator )
{
	if (AnimSequence=='stand')
		GotoState( 'IntroDude','shake');
	else
		GotoState( 'IntroDude','stand');
}

shake: 
	Disable('Trigger');
	PlayAnim('shake',1);
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
	bStatic=False
	DrawType=DT_Mesh
	Mesh=IntroDude
}

