//=============================================================================
// JumpBoots
//=============================================================================
class JumpBoots extends Pickup;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\BOOTSA1.WAV" NAME="BootSnd" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\BOOTJMP.WAV" NAME="BootJmp" GROUP="Pickups"

#exec TEXTURE IMPORT NAME=I_Boots FILE=TEXTURES\HUD\i_Boots.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=lboot ANIVFILE=MODELS\boot_a.3D DATAFILE=MODELS\boot_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=lboot STRENGTH=0.3 

#exec MESH ORIGIN MESH=lboot X=-70 Y=150 Z=-50 YAW=64
#exec MESH SEQUENCE MESH=lboot SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=lboot SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jlboot1 FILE=MODELS\boot.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=lboot X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=lboot NUM=1 TEXTURE=Jlboot1 TLOD=5

var int TimeCharge;

function PickupFunction(Pawn Other)
{
	TimeCharge = 0;
	SetTimer(1.0, True);
}

function OwnerJumped()
{
	TimeCharge=0;
	if ( Charge <= 0 ) 
	{
		if ( Owner != None )
		{
			Owner.PlaySound(DeActivateSound);						
			Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * Level.Game.PlayerJumpZScaling();	
		}		
		UsedUp();
	}
	else
		Owner.PlaySound(sound'BootJmp');						
	Charge -= 1;
}

function Timer()
{
	if ( !Pawn(Owner).bAutoActivate )
	{	
		TimeCharge++;
		if (TimeCharge>20) OwnerJumped();
	}
}

state Activated
{
	function endstate()
	{
		Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * Level.Game.PlayerJumpZScaling();
		Pawn(Owner).bCountJumps = False;
		bActive = false;		
	}
Begin:
	Pawn(Owner).bCountJumps = True;
	Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * 3;
	Owner.PlaySound(ActivateSound);		
}

state DeActivated
{
Begin:		
}

defaultproperties
{
     ExpireMessage="The Jump Boots have drained"
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You picked up the jump boots"
     RespawnTime=30.000000
     PickupViewMesh=Mesh'UnrealI.lboot'
     Charge=3
     PickupSound=Sound'UnrealI.Pickups.GenPickSnd'
     ActivateSound=Sound'UnrealI.Pickups.BootSnd'
     Icon=Texture'UnrealI.Icons.I_Boots'
     RemoteRole=ROLE_DumbProxy
     Mesh=Mesh'UnrealI.lboot'
     AmbientGlow=64
     bMeshCurvy=False
     CollisionRadius=22.000000
     CollisionHeight=7.000000
     MaxDesireability=0.5000
}
