//=============================================================================
// ut_ShieldBelt.
//=============================================================================
class UT_ShieldBelt extends TournamentPickup;

#exec MESH IMPORT MESH=ShieldBeltMeshM ANIVFILE=MODELS\shieldbelt_a.3D DATAFILE=MODELS\shieldbelt_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ShieldBeltMeshM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=ShieldBeltMeshM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=AUbelt1 FILE=MODELS\shieldbelt.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=ShieldBeltMeshM X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=ShieldBeltMeshM NUM=1 TEXTURE=AUbelt1

var UT_ShieldBeltEffect MyEffect;
var() string TeamFireTextureStrings[4];
var() string TeamTextureStrings[4];
var firetexture TeamFireTextures[4];
var texture TeamTextures[4];
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
	{
		Owner.SetDefaultDisplayProperties();
		if( Owner.Inventory != None )
			Owner.Inventory.SetOwnerDisplay();
	}
	if ( MyEffect != None )
		MyEffect.Destroy();
	Super.Destroyed();
}

function PickupFunction(Pawn Other)
{
	local Inventory I;

	MyEffect = Spawn(class'UT_ShieldBeltEffect', Other,,Other.Location, Other.Rotation); 
	MyEffect.Mesh = Owner.Mesh;
	MyEffect.DrawScale = Owner.Drawscale;

	if ( Level.Game.bTeamGame && (Other.PlayerReplicationInfo != None) )
		TeamNum = Other.PlayerReplicationInfo.Team;
	else
		TeamNum = 3;
	SetEffectTexture();

	I = Pawn(Owner).FindInventoryType(class'UT_Invisibility');
	if ( I != None )
		MyEffect.bHidden = true;
	
	// remove other armors
	for ( I=Owner.Inventory; I!=None; I=I.Inventory )
		if ( I.bIsAnArmor && (I != self) )
			I.Destroy();
}

function SetEffectTexture()
{
	if ( TeamNum != 3 )
		MyEffect.ScaleGlow = 0.5;
	else
		MyEffect.ScaleGlow = 1.0;
	MyEffect.ScaleGlow *= (0.25 + 0.75 * Charge/Default.Charge);
	if ( TeamFireTextures[TeamNum] == None )
		TeamFireTextures[TeamNum] =FireTexture(DynamicLoadObject(TeamFireTextureStrings[TeamNum], class'Texture'));
	MyEffect.Texture = TeamFireTextures[TeamNum];
	if ( TeamTextures[TeamNum] == None )
		TeamTextures[TeamNum] = Texture(DynamicLoadObject(TeamTextureStrings[TeamNum], class'Texture'));
	MyEffect.LowDetailTexture = TeamTextures[TeamNum];
}

defaultproperties
{
	 itemname="ShieldBelt"
     TeamFireTextureStrings(0)="UnrealShare.Belt_fx.ShieldBelt.RedShield"
     TeamFireTextureStrings(1)="UnrealShare.Belt_fx.ShieldBelt.BlueShield"
     TeamFireTextureStrings(2)="UnrealShare.Belt_fx.ShieldBelt.Greenshield"
     TeamFireTextureStrings(3)="UnrealShare.Belt_fx.ShieldBelt.N_Shield"
     TeamFireTextures(0)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.RedShield'
     TeamFireTextures(1)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.BlueShield'
     TeamFireTextures(2)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.Greenshield'
     TeamFireTextures(3)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.N_Shield'
     TeamTextureStrings(0)="UnrealShare.Belt_fx.ShieldBelt.newred"
     TeamTextureStrings(1)="UnrealShare.Belt_fx.ShieldBelt.newblue"
     TeamTextureStrings(2)="UnrealShare.Belt_fx.ShieldBelt.newgreen"
     TeamTextureStrings(3)="UnrealShare.Belt_fx.ShieldBelt.newgold"
     TeamTextures(0)=Texture'UnrealShare.Belt_fx.ShieldBelt.newred'
     TeamTextures(1)=Texture'UnrealShare.Belt_fx.ShieldBelt.newblue'
     TeamTextures(2)=Texture'UnrealShare.Belt_fx.ShieldBelt.newgreen'
     TeamTextures(3)=Texture'UnrealShare.Belt_fx.ShieldBelt.newgold'
     bDisplayableInv=True
     PickupMessage="You got the Shield Belt."
     RespawnTime=60.000000
     PickupViewMesh=Mesh'Botpack.ShieldBeltMeshM'
     ProtectionType1=ProtectNone
     ProtectionType2=ProtectNone
     Charge=150
     ArmorAbsorption=100
     bIsAnArmor=True
     AbsorptionPriority=10
     MaxDesireability=3.000000
     PickupSound=Sound'Botpack.Pickups.BeltSnd'
     DeActivateSound=Sound'Botpack.Pickups.Sbelthe2'
     Icon=Texture'Botpack.Icons.I_ShieldBelt'
     RemoteRole=ROLE_DumbProxy
     Mesh=Mesh'Botpack.ShieldBeltMeshM'
     bOwnerNoSee=True
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
