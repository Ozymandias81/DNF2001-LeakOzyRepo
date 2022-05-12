//=============================================================================
// ShieldBelt.
//=============================================================================
class ShieldBelt extends Pickup;

#exec AUDIO IMPORT FILE="Sounds\Pickups\SBELTA1.WAV"  NAME="BeltSnd"       GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\pSBELTA2.WAV"  NAME="PSbelta2"       GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\SBELThe2.WAV"  NAME="Sbelthe2"       GROUP="Pickups"

#exec TEXTURE IMPORT NAME=I_ShieldBelt FILE=TEXTURES\HUD\i_belt.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=GoldSkin FILE=models\gold.PCX GROUP="None"
#exec TEXTURE IMPORT NAME=RedSkin FILE=MODELS\ChromR.PCX GROUP=Skins FLAGS=2 // skin
#exec TEXTURE IMPORT NAME=BlueSkin FILE=MODELS\ChromB.PCX GROUP=Skins FLAGS=2 // skin

#exec MESH IMPORT MESH=ShieldBeltMesh ANIVFILE=MODELS\belt_a.3D DATAFILE=MODELS\belt_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ShieldBeltMesh X=0 Y=120 Z=110 YAW=64
#exec MESH SEQUENCE MESH=ShieldBeltMesh SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Abelt1 FILE=MODELS\belt.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=ShieldBeltMesh X=0.025 Y=0.025 Z=0.05
#exec MESHMAP SETTEXTURE MESHMAP=ShieldBeltMesh NUM=1 TEXTURE=Abelt1

#exec OBJ LOAD FILE=..\Textures\Belt_fx.utx PACKAGE=Unrealshare.Belt_fx

var ShieldBeltEffect MyEffect;
var() firetexture TeamFireTextures[4];
var() texture TeamTextures[4];
var int TeamNum;

function ArmorImpactEffect(vector HitLocation)
{ 
	if ( Owner.IsA('PlayerPawn') )
	{
		PlayerPawn(Owner).ClientFlash(-0.05,vect(400,400,400));
		PlayerPawn(Owner).PlaySound(DeActivateSound, SLOT_None, 2.7*PlayerPawn(Owner).SoundDampening);
	}
	if ( MyEffect != None )
	{
		//MyEffect.Texture = MyEffect.LowDetailTexture;
		MyEffect.ScaleGlow = 4.0;
		MyEffect.Fatness = 255;
		SetTimer(0.8, false);
	}
}

function Timer()
{
	if ( MyEffect != None )
	{
		MyEffect.Fatness = MyEffect.Default.Fatness;
		SetEffectTexture();
	}
}

function Destroyed()
{
	if ( Owner != None )
		Owner.SetDefaultDisplayProperties();
	if ( MyEffect != None )
		MyEffect.Destroy();
	Super.Destroyed();
}

function PickupFunction(Pawn Other)
{
	MyEffect = Spawn(class'ShieldBeltEffect', Owner,,Owner.Location, Owner.Rotation); 
	MyEffect.Mesh = Owner.Mesh;
	MyEffect.DrawScale = Owner.Drawscale;

	if ( Level.Game.bTeamGame && (Other.PlayerReplicationInfo != None) )
		TeamNum = Other.PlayerReplicationInfo.Team;
	else
		TeamNum = 3;
	SetEffectTexture();
}

function SetEffectTexture()
{
	if ( TeamNum != 3 )
		MyEffect.ScaleGlow = 0.5;
	else
		MyEffect.ScaleGlow = 1.0;
	MyEffect.Texture = TeamFireTextures[TeamNum];
	MyEffect.LowDetailTexture = TeamTextures[TeamNum];
}

defaultproperties
{
	 TeamFireTextures(0)=Unrealshare.Belt_fx.Redshield
	 TeamFireTextures(1)=Unrealshare.Belt_fx.Blueshield
	 TeamFireTextures(2)=Unrealshare.Belt_fx.Greenshield
	 TeamFireTextures(3)=Unrealshare.Belt_fx.N_shield
	 TeamTextures(0)=Unrealshare.Belt_fx.NewRed
	 TeamTextures(1)=Unrealshare.Belt_fx.NewBlue
	 TeamTextures(2)=Unrealshare.Belt_fx.NewGreen
	 TeamTextures(3)=Unrealshare.Belt_fx.NewGold
	 bOwnerNoSee=True
     bDisplayableInv=True
     PickupMessage="You got the Shield Belt."
     RespawnTime=60.000000
     PickupViewMesh=Mesh'UnrealShare.ShieldBeltMesh'
     ProtectionType1=ProtectNone
     ProtectionType2=ProtectNone
     Charge=100
     ArmorAbsorption=100
     bIsAnArmor=True
     AbsorptionPriority=10
     PickupSound=Sound'UnrealShare.Pickups.BeltSnd'
     DeActivateSound=Sound'UnrealShare.Pickups.Sbelthe2'
     Icon=Texture'UnrealShare.Icons.I_ShieldBelt'
     RemoteRole=ROLE_DumbProxy
     Mesh=Mesh'UnrealShare.ShieldBeltMesh'
     bMeshCurvy=False
     CollisionRadius=20.000000
     CollisionHeight=5.000000
     MaxDesireability=2.0000
}
