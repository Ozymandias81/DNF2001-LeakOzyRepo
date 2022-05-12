//=============================================================================
// ArenaCam.
//=============================================================================
class ArenaCam expands Decoration;

#exec MESH IMPORT MESH=ArenaCam ANIVFILE=MODELS\ArenaCam_a.3d DATAFILE=MODELS\ArenaCam_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ArenaCam X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=ArenaCam SEQ=All   STARTFRAME=0 NUMFRAMES=300
#exec MESH SEQUENCE MESH=ArenaCam SEQ=down  STARTFRAME=0 NUMFRAMES=99
#exec MESH SEQUENCE MESH=ArenaCam SEQ=loop  STARTFRAME=100 NUMFRAMES=200
#exec MESH SEQUENCE MESH=ArenaCam SEQ=sit   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ArenaCam SEQ=Close STARTFRAME=0 NUMFRAMES=300

#exec MESHMAP NEW   MESHMAP=ArenaCam MESH=ArenaCam
#exec MESHMAP SCALE MESHMAP=ArenaCam X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=JArenaCam_01 FILE=Textures\Arenacam.PCX GROUP=Skins FLAGS=2	//Material #2

#exec MESHMAP SETTEXTURE MESHMAP=ArenaCam NUM=1 TEXTURE=JArenaCam_01


var() Sound ArmDown;
var() Sound ArmLoop;

Auto State Camarm
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (AnimSequence=='sit')
			GotoState( 'Camarm','down');
		else
			GotoState( 'Camarm','sit');
	}

Down: 
	Disable('Trigger');
	PlayAnim('down',1.2);
	PlaySound(ArmDown,SLOT_Misc,1.0);
	FinishAnim();
	LoopAnim('loop',1.2);
	PlaySound(ArmLoop,SLOT_Misc,1.0);

//	Enable('Trigger');
	Stop;	
	

Loop:
	Disable('Trigger');
	LoopAnim('loop',1.2);
	PlaySound(ArmLoop,SLOT_Misc,1.0);
	
Begin:
	PlayAnim('sit',1.2);
}

defaultproperties
{
     bStatic=False
     DrawType=DT_Mesh
     Mesh=Mesh'Botpack.ArenaCam'
     DrawScale=9.500000
}
