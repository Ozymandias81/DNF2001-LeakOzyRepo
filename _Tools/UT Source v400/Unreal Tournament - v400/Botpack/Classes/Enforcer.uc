//=============================================================================
// Enforcer
//=============================================================================
class Enforcer extends TournamentWeapon;

#exec TEXTURE IMPORT NAME=IconAutoM FILE=TEXTURES\HUD\WpnAutoM.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseAutoM FILE=TEXTURES\HUD\UseAutoM.PCX GROUP="Icons" MIPS=OFF

#exec TEXTURE IMPORT NAME=Muz1 FILE=MODELS\muz1.PCX GROUP="Skins"  LODSET=2
#exec TEXTURE IMPORT NAME=Muz2 FILE=MODELS\muz2.PCX GROUP="Skins"  LODSET=2
#exec TEXTURE IMPORT NAME=Muz3 FILE=MODELS\muz3.PCX GROUP="Skins"  LODSET=2
#exec TEXTURE IMPORT NAME=Muz4 FILE=MODELS\muz4.PCX GROUP="Skins"  LODSET=2
#exec TEXTURE IMPORT NAME=Muz5 FILE=MODELS\muz5.PCX GROUP="Skins"  LODSET=2

// pickup version
#exec MESH IMPORT MESH=MagPick ANIVFILE=MODELS\autopick_a.3D DATAFILE=MODELS\autopick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MagPick X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=MagPick SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jautot1 FILE=MODELS\mag0.PCX GROUP="Skins"  LODSET=2
#exec MESHMAP SCALE MESHMAP=MagPick X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=MagPick NUM=1 TEXTURE=Jautot1

// 3rd person perspective version 
#exec MESH IMPORT MESH=AutoHand ANIVFILE=MODELS\autopick_a.3D DATAFILE=MODELS\autopick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=AutoHand X=0 Y=250 Z=-60 YAW=64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=AutoHand SEQ=All  STARTFRAME=0    NUMFRAMES=6
#exec MESH SEQUENCE MESH=AutoHand SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=AutoHand SEQ=Shoot  STARTFRAME=1  NUMFRAMES=6
#exec MESH SEQUENCE MESH=AutoHand SEQ=Shot2  STARTFRAME=1  NUMFRAMES=6
#exec MESHMAP SCALE MESHMAP=AutoHand X=0.025 Y=0.025 Z=0.05
#exec MESHMAP SETTEXTURE MESHMAP=AutoHand NUM=1 TEXTURE=Jautot1

//  player view version
#exec MESH IMPORT MESH=AutoML ANIVFILE=MODELS\mag_a.3D DATAFILE=MODELS\mag_d.3D unmirror=1
#exec MESH ORIGIN MESH=AutoML X=0 Y=0 Z=0 YAW=64 ROLL=0

#exec MESH DROPFRAMES MESH=AutoML STARTFRAME=130    NUMFRAMES=35
#exec MESH DROPFRAMES MESH=AutoML STARTFRAME=144    NUMFRAMES=10

#exec MESH SEQUENCE MESH=AutoML SEQ=All     STARTFRAME=0  NUMFRAMES=151
#exec MESH SEQUENCE MESH=AutoML SEQ=Still   STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=AutoML SEQ=Shoot   STARTFRAME=6  NUMFRAMES=10
#exec MESH SEQUENCE MESH=AutoML SEQ=Eject   STARTFRAME=22  NUMFRAMES=28
#exec MESH SEQUENCE MESH=AutoML SEQ=Select  STARTFRAME=60  NUMFRAMES=28 RATE=36 GROUP=Select
#exec MESH SEQUENCE MESH=AutoML SEQ=Twiddle STARTFRAME=87  NUMFRAMES=25
#exec MESH SEQUENCE MESH=AutoML SEQ=Sway    STARTFRAME=86  NUMFRAMES=2 RATE=3
#exec MESH SEQUENCE MESH=AutoML SEQ=Down    STARTFRAME=115  NUMFRAMES=12 RATE=45
#exec MESH SEQUENCE MESH=AutoML SEQ=T1      STARTFRAME=130  NUMFRAMES=6
#exec MESH SEQUENCE MESH=AutoML SEQ=Shot2   STARTFRAME=136  NUMFRAMES=8
#exec MESH SEQUENCE MESH=AutoML SEQ=T2      STARTFRAME=144  NUMFRAMES=7
#exec TEXTURE IMPORT NAME=Jtutot1 FILE=MODELS\mag1.PCX GROUP="Skins"   LODSET=2
#exec TEXTURE IMPORT NAME=Jtutot2 FILE=MODELS\mag2.PCX GROUP="Skins"   LODSET=2
#exec TEXTURE IMPORT NAME=Jtutot3 FILE=MODELS\mag3.PCX GROUP="Skins"   LODSET=2
#exec TEXTURE IMPORT NAME=Jtutot4 FILE=MODELS\mag4.PCX GROUP="Skins"   LODSET=2
#exec MESHMAP SCALE MESHMAP=AutoML X=0.007 Y=0.0045 Z=0.012
#exec MESHMAP SETTEXTURE MESHMAP=AutoML NUM=0 TEXTURE=Jtutot1
#exec MESHMAP SETTEXTURE MESHMAP=AutoML NUM=1 TEXTURE=Jtutot2
#exec MESHMAP SETTEXTURE MESHMAP=AutoML NUM=2 TEXTURE=Jtutot3
#exec MESHMAP SETTEXTURE MESHMAP=AutoML NUM=3 TEXTURE=Jtutot4

// right handed player view version
#exec MESH IMPORT MESH=AutoMR ANIVFILE=MODELS\mag_a.3D DATAFILE=MODELS\mag_d.3D
#exec MESH ORIGIN MESH=AutoMR X=0 Y=0 Z=0 YAW=64 ROLL=0

#exec MESH DROPFRAMES MESH=AutoMR STARTFRAME=130    NUMFRAMES=35
#exec MESH DROPFRAMES MESH=AutoMR STARTFRAME=144    NUMFRAMES=10

#exec MESH SEQUENCE MESH=AutoMR SEQ=All     STARTFRAME=0  NUMFRAMES=151
#exec MESH SEQUENCE MESH=AutoMR SEQ=Still   STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=AutoMR SEQ=Shoot   STARTFRAME=6  NUMFRAMES=10
#exec MESH SEQUENCE MESH=AutoMR SEQ=Eject   STARTFRAME=22  NUMFRAMES=28
#exec MESH SEQUENCE MESH=AutoMR SEQ=Select  STARTFRAME=60  NUMFRAMES=28 RATE=36 GROUP=Select
#exec MESH SEQUENCE MESH=AutoMR SEQ=Twiddle STARTFRAME=87  NUMFRAMES=25
#exec MESH SEQUENCE MESH=AutoMR SEQ=Sway   STARTFRAME=86  NUMFRAMES=2   RATE=3
#exec MESH SEQUENCE MESH=AutoMR SEQ=Down    STARTFRAME=115  NUMFRAMES=12 RATE=45
#exec MESH SEQUENCE MESH=AutoMR SEQ=T1      STARTFRAME=130  NUMFRAMES=6
#exec MESH SEQUENCE MESH=AutoMR SEQ=Shot2   STARTFRAME=136  NUMFRAMES=8
#exec MESH SEQUENCE MESH=AutoMR SEQ=T2      STARTFRAME=144  NUMFRAMES=7
#exec MESHMAP SCALE MESHMAP=AutoMR X=0.007 Y=0.0045 Z=0.012
#exec MESHMAP SETTEXTURE MESHMAP=AutoMR NUM=0 TEXTURE=Jtutot1
#exec MESHMAP SETTEXTURE MESHMAP=AutoMR NUM=1 TEXTURE=Jtutot2
#exec MESHMAP SETTEXTURE MESHMAP=AutoMR NUM=2 TEXTURE=Jtutot3
#exec MESHMAP SETTEXTURE MESHMAP=AutoMR NUM=3 TEXTURE=Jtutot4

#exec TEXTURE IMPORT NAME=EMuz1 FILE=MODELS\muz1.PCX GROUP="Skins"

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\automag\cocking.WAV" NAME="Cocking" GROUP="enforcer"
#exec AUDIO IMPORT FILE="Sounds\Enforcer\enforcershot.WAV" NAME="E_Shot" GROUP="enforcer"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\flak\click.WAV" NAME="click" GROUP="flak"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\automag\reload1.WAV" NAME="Reload" GROUP="enforcer"

#exec MESH IMPORT MESH=muzzEF3 ANIVFILE=MODELS\muzzle2_a.3d DATAFILE=MODELS\Muzzle2_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=muzzEF3 MINVERTS=8 STRENGTH=0.7 ZDISP=800.0

#exec MESH ORIGIN MESH=muzzEF3 X=0 Y=740 Z=-90 YAW=64
#exec MESH SEQUENCE MESH=muzzEF3 SEQ=All                      STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=muzzEF3 SEQ=Shoot                   STARTFRAME=0 NUMFRAMES=3
#exec MESHMAP NEW   MESHMAP=muzzEF3 MESH=muzzEF3
#exec MESHMAP SCALE MESHMAP=muzzEF3 X=0.02 Y=0.05 Z=0.04
#exec TEXTURE IMPORT NAME=Muzzy2 FILE=MODELS\Muzzy2.PCX GROUP=Skins

var() int hitdamage;
var  float AltAccuracy;
var Enforcer SlaveEnforcer;		// The left (second) Enforcer is a slave to the right.
var bool bIsSlave;
var bool bSetup;				// used for setting display properties
var bool bFirstFire, bBringingUp;
var() localized string DoubleName;
var() texture MuzzleFlashVariations[5];
var int DoubleSwitchPriority;

replication
{
	reliable if ( Role == ROLE_Authority )
		SlaveEnforcer, bIsSlave, bBringingUp;
}

function Destroyed()
{
	Super.Destroyed();
	if ( SlaveEnforcer != None )
		SlaveEnforcer.Destroy();
}

simulated function AnimEnd()
{
	if ( (Level.NetMode == NM_Client) && bBringingUp  && (Mesh != PickupViewMesh) )
	{
		bBringingUp = false;
		PlaySelect();
	}
	else
		Super.AnimEnd();
}

function bool WeaponSet(Pawn Other)
{
	if ( bIsSlave )
		return false;
	else
		Super.WeaponSet(Other);
}

function SetSwitchPriority(pawn Other)
{
	local int i;
	local name temp, carried;

	if ( PlayerPawn(Other) != None )
	{
		Super.SetSwitchPriority(Other);

		// also set double switch priority

		for ( i=0; i<20; i++)
			if ( PlayerPawn(Other).WeaponPriority[i] == 'doubleenforcer' )
			{
				DoubleSwitchPriority = i;
				return;
			}
	}		
}

// Return the switch priority of the weapon (normally AutoSwitchPriority, but may be
// modified by environment (or by other factors for bots)
function float SwitchPriority() 
{
	local float temp;
	local int bTemp;

	if ( bIsSlave )
		return -10;
	if ( !Owner.IsA('PlayerPawn') )
		return RateSelf(bTemp);
	else if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
	{
		if ( Pawn(Owner).Weapon == self )
			return -0.5;
		else
			return -1;
	}
	else if ( SlaveEnforcer != None )
		return DoubleSwitchPriority;
	else
		return AutoSwitchPriority;
}

function DropFrom(vector StartLocation)
{
	if ( !SetLocation(StartLocation) )
		return; 
	if ( SlaveEnforcer != None )
		SlaveEnforcer.Destroy();
	AIRating = Default.AIRating;
	SlaveEnforcer = None;
	Super.DropFrom(StartLocation);
}

function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap )
{
	if ( !bSetup )
	{
		bSetup = true;
		if ( SlaveEnforcer != None )
			SlaveEnforcer.SetDisplayProperties(NewStyle, NewTexture, bLighting, bEnviromap);
		bSetup = false;
	}			
	Super.SetDisplayProperties(NewStyle, NewTexture, bLighting, bEnviromap);
}

function SetDefaultDisplayProperties()
{
	if ( !bSetup )
	{
		bSetup = true;
		if ( SlaveEnforcer != None )
			SlaveEnforcer.SetDefaultDisplayProperties();
		bSetup = false;
	}			
	Super.SetDefaultDisplayProperties();
}

event float BotDesireability(Pawn Bot)
{
	local Enforcer AlreadyHas;
	local float desire;

	desire = MaxDesireability + Bot.AdjustDesireFor(self);
	AlreadyHas = Enforcer(Bot.FindInventoryType(class));
	if ( AlreadyHas != None )
	{
		if ( (!bHeldItem || bTossedOut) && bWeaponStay )
			return 0;
		if ( AlreadyHas.SlaveEnforcer != None )
		{
			if ( (RespawnTime < 10)
				&& ( bHidden || (AlreadyHas.AmmoType == None)
					|| (AlreadyHas.AmmoType.AmmoAmount < AlreadyHas.AmmoType.MaxAmmo)) )
				return 0;
			if ( AlreadyHas.AmmoType == None )
				return 0.25 * desire;

			if ( AlreadyHas.AmmoType.AmmoAmount > 0 )
				return FMax( 0.25 * desire, 
						AlreadyHas.AmmoType.MaxDesireability
						 * FMin(1, 0.15 * AlreadyHas.AmmoType.MaxAmmo/AlreadyHas.AmmoType.AmmoAmount) ); 
		}
	}
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating <= 0.4) )
		return 2*desire;

	return desire;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_Shellcase s;
	local vector realLoc;

	realLoc = Owner.Location + CalcDrawOffset();
	s = Spawn(class'UT_ShellCase',, '', realLoc + 20 * X + FireOffset.Y * Y + Z);
	if ( s != None )
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);              
	if (Other == Level) 
	{
		if ( bIsSlave || (SlaveEnforcer != None) )
			Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
		else
			Spawn(class'UT_WallHit',,, HitLocation+HitNormal, Rotator(HitNormal));
	}
	else if ((Other != self) && (Other != Owner) && (Other != None) ) 
	{
		if ( FRand() < 0.2 )
			X *= 5;
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 3000.0*X, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}		
}

function bool HandlePickupQuery( inventory Item )
{
	local Pawn P;
	local Inventory Copy;

	if ( (Item.class == class) && (SlaveEnforcer == None) ) 
	{
		P = Pawn(Owner);
		// spawn a double
		Copy = Spawn(class, P);
		Copy.BecomeItem();
		ItemName = DoubleName;
		SlaveEnforcer = Enforcer(Copy);
		SetTwoHands();
		AIRating = 0.4;
		SlaveEnforcer.SetUpSlave( Pawn(Owner).Weapon == self );
		SlaveEnforcer.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
		SetTwoHands();
		P.ReceiveLocalizedMessage( class'PickupMessagePlus', 0, None, None, Self.Class );
		Item.PlaySound(Item.PickupSound);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		Item.SetRespawn();
		return true;
	}
	return Super.HandlePickupQuery(Item);
}

function SetUpSlave(bool bBringUp)
{
	bIsSlave = true;
	ItemName = DoubleName;
	GiveAmmo(Pawn(Owner));
	AmbientGlow = 0;
	if ( bBringUp )
		BringUp();
	else
		GotoState('Idle2');
}

function SetTwoHands()
{
	if ( SlaveEnforcer == None )
		return;

	if ( (PlayerPawn(Owner) != None) && (PlayerPawn(Owner).Handedness == 2) )
	{
		SetHand(2);
		return;
	}

	if ( Mesh == mesh'AutoML' )
		SetHand(1);
	else
		SetHand(-1);
}

function setHand(float Hand)
{
	local rotator newRot;

	if ( Hand == 2 )
	{
		bHideWeapon = true;
		Super.SetHand(Hand);
		return;
	}

	if ( SlaveEnforcer != None )
	{
		if ( Hand == 0 )
			Hand = -1;
		SlaveEnforcer.SetHand(-1 * Hand);
	}
	bHideWeapon = false;
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'AutoML';
	else
		Mesh = mesh'AutoMR';
}

function BringUp()
{
	if (SlaveEnforcer != none ) 
	{
		SetTwoHands();
		SlaveEnforcer.BringUp();
	}
	bBringingUp = true;
	Super.BringUp();
}

function TraceFire( float Accuracy )
{
	local vector RealOffset;

	RealOffset = FireOffset;
	FireOffset *= 0.35;
	if ( (SlaveEnforcer != None) || bIsSlave )
		Accuracy = FClamp(3*Accuracy,0.75,3);
	else if ( Owner.IsA('Bot') && !Bot(Owner).bNovice )
		Accuracy = FMax(Accuracy, 0.45);

	Super.TraceFire(Accuracy);
	FireOffset = RealOffset;
}

function Fire(float Value)
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		GotoState('NormalFire');
		bCanClientFire = true;
		bPointing=True;
		ClientFire(value);
		if ( SlaveEnforcer != None )
			Pawn(Owner).PlayRecoil(2 * FiringSpeed);
		else if ( !bIsSlave )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		TraceFire(0.2);
	}
}

simulated function PlayFiring()
{
	PlayOwnedSound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
	bMuzzleFlash++;
	PlayAnim('Shoot',0.5 + 0.31 * FireAdjust, 0.02);
}

simulated function PlayAltFiring()
{
	PlayAnim('T1', 1.3, 0.05);
	bFirstFire = true;
}

simulated function PlayRepeatFiring()
{
	if ( Affector != None )
		Affector.FireEffect();
	if ( PlayerPawn(Owner) != None )
	{
		PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	}
	bMuzzleFlash++;
	PlayOwnedSound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
	PlayAnim('Shot2', 0.7 + 0.3 * FireAdjust, 0.05);
}

function AltFire( float Value )
{
	bPointing=True;
	bCanClientFire = true;
	AltAccuracy = 0.4;
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.AmmoAmount>0)
	{
		if ( SlaveEnforcer != None )
			Pawn(Owner).PlayRecoil(3 * FiringSpeed);
		else if ( !bIsSlave )
			Pawn(Owner).PlayRecoil(1.5 * FiringSpeed);
		ClientAltFire(value);
		GotoState('AltFiring');
	}
}

state Active
{
	function bool PutDown()
	{
		if ( bWeaponUp || (AnimFrame < 0.75) ) 
			GotoState('DownWeapon');
		else
			bChangeWeapon = true;
		return True;
	}

	function BeginState()
	{
		bChangeWeapon = false;
	}

	function EndState()
	{
		Super.EndState();
		bBringingUp = false;
	}

Begin:
	FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	bWeaponUp = True;
	bCanClientFire = true;
	if ( !bIsSlave && (Level.Netmode != NM_Standalone) && (Owner != None)
		&& Owner.IsA('TournamentPlayer')
		&& (PlayerPawn(Owner).Player != None)
		&& !PlayerPawn(Owner).Player.IsA('ViewPort') )
	{
		if ( Pawn(Owner).bFire != 0 )
			TournamentPlayer(Owner).SendFire(self);
		else if ( Pawn(Owner).bAltFire != 0 )
			TournamentPlayer(Owner).SendAltFire(self);
		else if ( !bChangeWeapon )
			TournamentPlayer(Owner).UpdateRealWeapon(self);
	} 
	Finish();
}

State DownWeapon
{
ignores Fire, AltFire, Animend;

	function BeginState()
	{
		Super.BeginState();
		if ( Slaveenforcer != none )
			Slaveenforcer.GoToState('DownWeapon');
	}
}

////////////////////////////////////////////////////////
state NormalFire
{
ignores Fire, AltFire, AnimEnd;

	function Timer()
	{
		if ( SlaveEnforcer != none )
			SlaveEnforcer.Fire(0);
	}

	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

Begin:
	FlashCount++;
	if ( SlaveEnforcer != none )
		SetTimer(0.20, false);
	FinishAnim();
	if ( bIsSlave )
		GotoState('Idle');
	else 
		Finish();
}

state ClientFiring
{
	simulated function bool ClientAltFire(float Value)
	{
		if ( bIsSlave )
			Global.ClientAltFire(Value);
		return false;
	}

	simulated function Timer()
	{
		if ( (SlaveEnforcer != none) && SlaveEnforcer.ClientFire(0) )
			return;
		SetTimer(0.5, false);
	}

	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bIsSlave && !bCanClientFire )
			GotoState('');
		else if ( bFirstFire || (Pawn(Owner).bAltFire != 0) )
		{
			PlayRepeatFiring();
			bFirstFire = false;
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}

	simulated function BeginState()
	{
		Super.BeginState();
		if ( SlaveEnforcer != None )
			SetTimer(0.2, false);
		else 
			SetTimer(0.5, false);
	}

	simulated function EndState()
	{
		Super.EndState();
		if ( SlaveEnforcer != None )
			SlaveEnforcer.GotoState('');
	}
}

state ClientAltFiring
{
	simulated function bool ClientFire(float Value)
	{
		if ( bIsSlave )
			Global.ClientFire(Value);
		return false;
	}

	simulated function Timer()
	{
		if ( (SlaveEnforcer != none) && SlaveEnforcer.ClientAltFire(0) )
			return;
		SetTimer(0.5, false);
	}

	simulated function AnimEnd()
	{
		if ( Pawn(Owner) == None )
			GotoState('');
		else if ( Ammotype.AmmoAmount <= 0 )
		{
			PlayAnim('T2', 0.9, 0.05);	
			GotoState('');
		}
		else if ( !bIsSlave && !bCanClientFire )
			GotoState('');
		else if ( bFirstFire || (Pawn(Owner).bAltFire != 0) )
		{
			PlayRepeatFiring();
			bFirstFire = false;
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else
		{
			PlayAnim('T2', 0.9, 0.05);	
			GotoState('');
		}
	}

	simulated function BeginState()
	{
		Super.BeginState();
		if ( SlaveEnforcer != None )
			SetTimer(0.2, false);
		else 
			SetTimer(0.5, false);
	}

	simulated function EndState()
	{
		Super.EndState();
		if ( SlaveEnforcer != None )
			SlaveEnforcer.GotoState('');
	}
}

state AltFiring
{
ignores Fire, AltFire, AnimEnd;

	function Timer()
	{
		if ( Slaveenforcer != none )
			Slaveenforcer.AltFire(0);
	}

	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

Begin:
	if ( SlaveEnforcer != none )
		SetTimer(0.20, false);
	FinishAnim();
Repeater:	
	if (AmmoType.UseAmmo(1)) 
	{
		FlashCount++;
		if ( SlaveEnforcer != None )
			Pawn(Owner).PlayRecoil(3 * FiringSpeed);
		else if ( !bIsSlave )
			Pawn(Owner).PlayRecoil(1.5 * FiringSpeed);
		TraceFire(AltAccuracy);
		PlayRepeatFiring();
		FinishAnim();
	}

	if ( AltAccuracy < 3 ) 
		AltAccuracy += 0.5;
	if ( bIsSlave )
	{
		if ( (Pawn(Owner).bAltFire!=0) 
			&& AmmoType.AmmoAmount>0 )
			Goto('Repeater');
	}
	else if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( (Pawn(Owner).bAltFire!=0) 
		&& AmmoType.AmmoAmount>0 )
	{
		if ( PlayerPawn(Owner) == None )
			Pawn(Owner).bAltFire = int( FRand() < AltReFireRate );
		Goto('Repeater');	
	}
	PlayAnim('T2', 0.9, 0.05);	
	FinishAnim();
	Finish();
}

simulated event RenderOverlays(canvas Canvas)
{
	local PlayerPawn PlayerOwner;
	local int realhand;

	if ( (bMuzzleFlash > 0) && !Level.bDropDetail )
		MFTexture = MuzzleFlashVariations[Rand(5)];
	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
	{
		if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
			return;
		realhand = PlayerOwner.Handedness;
		if (  (Level.NetMode == NM_Client) && (realHand == 2) )
		{
			bHideWeapon = true;
			return;
		}
		if ( !bHideWeapon )
		{
			if ( Mesh == mesh'AutoML' )
				PlayerOwner.Handedness = 1;
			else if ( bIsSlave || (SlaveEnforcer != None) )
				PlayerOwner.Handedness = -1;
		}
	}
	if ( (PlayerOwner == None) || (PlayerOwner.Handedness == 0) )
	{
		if ( AnimSequence == 'Shot2' )
		{
			FlashO = -2 * Default.FlashO;
			FlashY = Default.FlashY * 2.5;
		}
		else
		{
			FlashO = 1.9 * Default.FlashO;
			FlashY = Default.FlashY;
		}
	}
	else if ( AnimSequence == 'Shot2' )
	{
		FlashO = Default.FlashO * 0.3;
		FlashY = Default.FlashY * 2.5;
	}
	else
	{
		FlashO = Default.FlashO;
		FlashY = Default.FlashY;
	}
	if ( !bHideWeapon && ( (SlaveEnforcer != None) || bIsSlave ) )
	{
		if ( PlayerOwner == None )
			bMuzzleFlash = 0;

		Super.RenderOverlays(Canvas);
		if ( SlaveEnforcer != None )
		{
			if ( SlaveEnforcer.bBringingUp )
			{
				SlaveEnforcer.bBringingUp = false;
				SlaveEnforcer.PlaySelect();
			}
			SlaveEnforcer.RenderOverlays(Canvas);
		}
	}
	else
		Super.RenderOverlays(Canvas);

	if ( PlayerOwner != None )
		PlayerOwner.Handedness = realhand;
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if ( (FRand()>0.96) && (AnimSequence != 'Twiddle') ) 
		PlayAnim('Twiddle',0.6,0.3);
	else 
		LoopAnim('Sway',0.2, 0.3);
}


state Idle
{
	function AnimEnd()
	{
		PlayIdleAnim();
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}
	
Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) ) 
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	LoopAnim('Sway',0.2, 0.1);
	if ( Pawn(Owner).bFire!=0 ) Global.Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) Global.AltFire(0.0);	
}

State ClientActive
{
	simulated function AnimEnd()
	{
		bBringingUp = false;
		if ( !bIsSlave )
		{
			Super.AnimEnd();
			if ( (SlaveEnforcer != None) && !IsInState('ClientActive') )
			{
				if ( GetStateName() == 'None' )
					SlaveEnforcer.GotoState('');
				else
					SlaveEnforcer.GotoState(GetStateName());
			}
		}
	}

	simulated function BeginState()
	{
		Super.BeginState();
		bBringingUp = false;
		if ( SlaveEnforcer != None )
			SlaveEnforcer.GotoState('ClientActive');
	}
}

State ClientDown
{
	simulated function AnimEnd()
	{
		if ( !bIsSlave )
			Super.AnimEnd();
	}

	simulated function EndState()
	{
		if ( SlaveEnforcer != None )
			SlaveEnforcer.GotoState('');
	}
}

// End Class
//=============================================================================

defaultproperties
{
	 InstFlash=-0.2
     InstFog=(X=325.00000,Y=225.00000,Z=95.00000)
     MuzzleFlashMesh=Mesh'Botpack.MuzzEF3'
     MuzzleFlashScale=0.080000
	 bMuzzleFlashParticles=true
	 MuzzleFlashStyle=STY_Translucent
	 MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy2'
     hitdamage=17
     DoubleName="Double Enforcer"
     MuzzleFlashVariations(0)=Texture'Botpack.Skins.MUZ1'
     MuzzleFlashVariations(1)=Texture'Botpack.Skins.MUZ2'
     MuzzleFlashVariations(2)=Texture'Botpack.Skins.MUZ3'
     MuzzleFlashVariations(3)=Texture'Botpack.Skins.MUZ4'
     MuzzleFlashVariations(4)=Texture'Botpack.Skins.MUZ5'
     AmmoName=Class'Botpack.miniammo'
     PickupAmmoCount=30
     bInstantHit=True
     bAltInstantHit=True
     FiringSpeed=1.500000
     FireOffset=(X=0.0,Y=-10.000000,Z=-4.000000)
     MyDamageType=shot
     shakemag=200.000000
     shakevert=4.000000
     AIRating=0.250000
     RefireRate=0.800000
     AltRefireRate=0.870000
     FireSound=Sound'Botpack.enforcer.E_Shot'
     AltFireSound=Sound'UnrealShare.AutoMag.shot'
     CockingSound=Sound'Botpack.enforcer.Cocking'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k riddled %o full of holes with the %w."
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.100000
     FlashO=0.020000
     FlashC=0.035000
     FlashLength=0.020000
     FlashS=128
     MFTexture=Texture'Botpack.Skins.MUZ1'
     AutoSwitchPriority=2
     DoubleSwitchPriority=2
     InventoryGroup=2
     PickupMessage="You picked up another Enforcer!"
     ItemName="Enforcer"
     PlayerViewOffset=(X=3.300000,Y=-2.000000,Z=-3.000000)
     PlayerViewMesh=Mesh'Botpack.AutoML'
     PickupViewMesh=Mesh'Botpack.MagPick'
     ThirdPersonMesh=Mesh'Botpack.AutoHand'
     StatusIcon=Texture'Botpack.Icons.UseAutoM'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseAutoM'
     bHidden=True
     Mesh=Mesh'Botpack.MagPick'
     bNoSmooth=False
     CollisionRadius=24.000000
     CollisionHeight=12.000000
     Mass=15.000000
	 WeaponDescription="Classification: Light Pistol\\n\\nPrimary Fire: Accurate but slow firing instant hit.\\n\\nSecondary Fire: Sideways, or 'Gangsta' firing mode, shoots twice as fast and half as accurate as the primary fire.\\n\\nTechniques: Collect two for twice the damage."
	 NameColor=(R=200,G=200,B=255)
}
