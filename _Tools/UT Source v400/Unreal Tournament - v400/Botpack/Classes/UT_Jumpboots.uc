//=============================================================================
// UT_jumpBoots
//=============================================================================
class UT_JumpBoots extends TournamentPickup;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\BOOTSA1.WAV" NAME="BootSnd" GROUP="Pickups"

#exec TEXTURE IMPORT NAME=I_Boots FILE=TEXTURES\HUD\i_Boots.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=jboot ANIVFILE=MODELS\boots_a.3D DATAFILE=MODELS\boots_d.3D
#exec MESH ORIGIN MESH=jboot X=0 Y=0 Z=-70 YAW=64
#exec MESH SEQUENCE MESH=jboot SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=jboot SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jlboot2 FILE=MODELS\boots.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=jboot X=0.045 Y=0.045 Z=0.09
#exec MESHMAP SETTEXTURE MESHMAP=jboot NUM=1 TEXTURE=Jlboot2

var int TimeCharge;

function PickupFunction(Pawn Other)
{
	TimeCharge = 0;
	SetTimer(1.0, True);
}

function ResetOwner()
{
	local pawn P;

	P = Pawn(Owner);
	P.JumpZ = P.Default.JumpZ * Level.Game.PlayerJumpZScaling();
	if ( Level.Game.IsA('DeathMatchPlus') )
		P.AirControl = DeathMatchPlus(Level.Game).AirControl;
	else
		P.AirControl = P.Default.AirControl;
	P.bCountJumps = False;
}

function OwnerJumped()
{
	if ( !Pawn(Owner).bIsWalking )
	{
		TimeCharge=0;
		if ( Charge <= 0 ) 
		{
			if ( Owner != None )
			{
				Owner.PlaySound(DeActivateSound);
				ResetOwner();						
			}		
			UsedUp();
		}
		else
			Owner.PlaySound(sound'BootJmp');						
		Charge -= 1;
	}
	if( Inventory != None )
		Inventory.OwnerJumped();

}

function Timer()
{
	if ( Charge <= 0 ) 
	{
		if ( Owner != None )
		{
			if ( Owner.Physics == PHYS_Falling )
			{
				SetTimer(0.3, true);
				return;
			}
			Owner.PlaySound(DeActivateSound);
			ResetOwner();						
		}		
		UsedUp();
		return;
	}

	if ( !Pawn(Owner).bAutoActivate )
	{	
		TimeCharge++;
		if (TimeCharge>20)
		{
			OwnerJumped();
			TimeCharge = 0;
		}
	}
}

state Activated
{
	function endstate()
	{
		ResetOwner();
		bActive = false;		
	}
Begin:
	Pawn(Owner).bCountJumps = True;
	Pawn(Owner).AirControl = 1.0;
	Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * 3;
	Owner.PlaySound(ActivateSound);		
}

state DeActivated
{
Begin:		
}

defaultproperties
{
     ExpireMessage="The AntiGrav Boots have drained."
     bActivatable=True
	 bAutoActivate=True
     bDisplayableInv=True
     PickupMessage="You picked up the AntiGrav boots."
     RespawnTime=30.000000
     PickupViewMesh=Mesh'Botpack.jboot'
     Charge=3
     PickupSound=Sound'Unrealshare.Pickups.GenPickSnd'
     ActivateSound=Sound'Botpack.Pickups.BootSnd'
     Icon=Texture'UnrealI.Icons.I_Boots'
     RemoteRole=ROLE_DumbProxy
     Mesh=Mesh'Botpack.jboot'
     AmbientGlow=64
     bMeshCurvy=False
     CollisionRadius=22.000000
     CollisionHeight=14.000000
     MaxDesireability=0.5000
	 ItemName="AntiGrav Boots"
}
