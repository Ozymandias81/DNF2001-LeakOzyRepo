//=============================================================================
// Translator.
//=============================================================================
class Translator extends Pickup;

#exec AUDIO IMPORT FILE="Sounds\Pickups\HEALTH1.WAV" NAME="HEALTH1" GROUP="Pickups"

#exec TEXTURE IMPORT NAME=I_Tran FILE=TEXTURES\HUD\i_TRAN.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=TranslatorMesh ANIVFILE=MODELS\tran_a.3D DATAFILE=MODELS\tran_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TranslatorMesh X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=TranslatorMesh SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JTranslator1 FILE=MODELS\tran.PCX GROUP="Skins" 
#exec MESHMAP SCALE MESHMAP=TranslatorMesh X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=TranslatorMesh NUM=1 TEXTURE=JTranslator1

var() localized string NewMessage;
var localized string Hint;
var bool bNewMessage, bNotNewMessage, bShowHint, bCurrentlyActivated;

replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority && bNetOwner )
		NewMessage, bNewMessage, bNotNewMessage, bCurrentlyActivated;
}

function TravelPreAccept()
{
	if ( Pawn(Owner).FindInventoryType(class) == None )
		Super.TravelPreAccept();
}
		
state Activated
{
	function BeginState()
	{
		bActive = true;
		bCurrentlyActivated = true;
	}

	function EndState()
	{
		bActive = false;
		bCurrentlyActivated = false;
	} 
}

state Deactivated
{
Begin:
	bShowHint = False;
	bNewMessage = False;
	bNotNewMessage = False;
}

function ActivateTranslator(bool bHint)
{
	if (bHint && Hint=="")
	{
		bHint=False;
		Return;
	}
	bShowHint = bHint;
	Activate();
}

defaultproperties
{
     NewMessage="Universal Translator"
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="Press F2 to activate the Translator"
     PickupViewMesh=Mesh'UnrealShare.TranslatorMesh'
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     Icon=Texture'UnrealShare.Icons.I_Tran'
     Mesh=Mesh'UnrealShare.TranslatorMesh'
     bMeshCurvy=False
     CollisionHeight=5.000000
}
