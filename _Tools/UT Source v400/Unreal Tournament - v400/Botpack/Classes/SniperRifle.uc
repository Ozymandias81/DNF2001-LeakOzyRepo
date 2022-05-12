//=============================================================================
// SniperRifle
// A military redesign of the rifle.
//=============================================================================
class SniperRifle extends TournamentWeapon;

#exec MESH IMPORT MESH=Rifle2m ANIVFILE=MODELS\Rifle2_a.3D DATAFILE=MODELS\Rifle2_d.3D 
#exec MESH ORIGIN MESH=Rifle2m X=0 Y=0 Z=0 YAW=64 PITCH=0 ROLL=0

#exec MESH SEQUENCE MESH=Rifle2m SEQ=All         STARTFRAME=0   NUMFRAMES=75
#exec MESH SEQUENCE MESH=Rifle2m SEQ=Select      STARTFRAME=0   NUMFRAMES=17 RATE=28 GROUP=Select
#exec MESH SEQUENCE MESH=Rifle2m SEQ=Still       STARTFRAME=17  NUMFRAMES=1 
#exec MESH SEQUENCE MESH=Rifle2m SEQ=Fire        STARTFRAME=17  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2m SEQ=Fire2       STARTFRAME=27  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2m SEQ=Fire3       STARTFRAME=37  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2m SEQ=Fire4       STARTFRAME=47  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2m SEQ=Fire5       STARTFRAME=57  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2m SEQ=Down        STARTFRAME=67  NUMFRAMES=7

#exec TEXTURE IMPORT NAME=Rifle2a FILE=MODELS\Rifle1.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=Rifle2b FILE=MODELS\Rifle2.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=Rifle2c FILE=MODELS\Rifle3.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=Rifle2d FILE=MODELS\Rifle4.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=Rifle2m X=0.008 Y=0.004 Z=0.016
#exec MESHMAP SETTEXTURE MESHMAP=Rifle2m NUM=0 TEXTURE=Rifle2a
#exec MESHMAP SETTEXTURE MESHMAP=Rifle2m NUM=1 TEXTURE=Rifle2b
#exec MESHMAP SETTEXTURE MESHMAP=Rifle2m NUM=2 TEXTURE=Rifle2c
#exec MESHMAP SETTEXTURE MESHMAP=Rifle2m NUM=3 TEXTURE=Rifle2d

#exec MESH IMPORT MESH=Rifle2mL ANIVFILE=MODELS\Rifle2_a.3D DATAFILE=MODELS\Rifle2_d.3D UnMirror=1
#exec MESH ORIGIN MESH=Rifle2mL X=0 Y=0 Z=0 YAW=64 PITCH=0 ROLL=0

#exec MESH SEQUENCE MESH=Rifle2mL SEQ=All         STARTFRAME=0   NUMFRAMES=75
#exec MESH SEQUENCE MESH=Rifle2mL SEQ=Select      STARTFRAME=0   NUMFRAMES=17 RATE=28 GROUP=Select
#exec MESH SEQUENCE MESH=Rifle2mL SEQ=Still       STARTFRAME=17  NUMFRAMES=1 
#exec MESH SEQUENCE MESH=Rifle2mL SEQ=Fire        STARTFRAME=17  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2mL SEQ=Fire2       STARTFRAME=27  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2mL SEQ=Fire3       STARTFRAME=37  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2mL SEQ=Fire4       STARTFRAME=47  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2mL SEQ=Fire5       STARTFRAME=57  NUMFRAMES=10 RATE=15
#exec MESH SEQUENCE MESH=Rifle2mL SEQ=Down        STARTFRAME=67  NUMFRAMES=7

#exec MESHMAP SCALE MESHMAP=Rifle2mL X=0.008 Y=0.004 Z=0.016
#exec MESHMAP SETTEXTURE MESHMAP=Rifle2mL NUM=0 TEXTURE=Rifle2a
#exec MESHMAP SETTEXTURE MESHMAP=Rifle2mL NUM=1 TEXTURE=Rifle2b
#exec MESHMAP SETTEXTURE MESHMAP=Rifle2mL NUM=2 TEXTURE=Rifle2c
#exec MESHMAP SETTEXTURE MESHMAP=Rifle2mL NUM=3 TEXTURE=Rifle2d

#exec MESH IMPORT MESH=RiflePick ANIVFILE=MODELS\Riflehand_a.3D DATAFILE=MODELS\Riflehand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RiflePick X=0 Y=0 Z=0 YAW=64 
#exec MESH SEQUENCE MESH=RiflePick SEQ=All         STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=RiflePick SEQ=Still        STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JRifle2 FILE=MODELS\Rifle.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=RiflePick X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=RiflePick NUM=2 TEXTURE=JRifle2

#exec MESH IMPORT MESH=RifleHand ANIVFILE=MODELS\Riflehand_a.3D DATAFILE=MODELS\Riflehand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RifleHand X=15 Y=170 Z=-30 YAW=64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=RifleHand SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=RifleHand X=0.07 Y=0.07 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=RifleHand NUM=2 TEXTURE=JRifle2

#exec TEXTURE IMPORT NAME=MuzzleFlash2 FILE=TEXTURES\NewMuz2.PCX GROUP="Rifle" MIPS=OFF LODSET=2
#exec TEXTURE IMPORT NAME=IconRifle FILE=TEXTURES\HUD\WpnRifle.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseRifle FILE=TEXTURES\HUD\UseRifle.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=RReticle FILE=TEXTURES\rifleret.PCX GROUP="Icons" MIPS=OFF FLAGS=2 LODSET=2

#exec AUDIO IMPORT FILE="Sounds\SniperRifle\SniperFire.wav" NAME="SniperFire" GROUP="SniperRifle"

#exec MESH IMPORT MESH=muzzsr3 ANIVFILE=MODELS\muzzle2_a.3d DATAFILE=MODELS\Muzzle2_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=muzzsr3 MINVERTS=8 STRENGTH=0.7 ZDISP=800.0
#exec MESH ORIGIN MESH=muzzsr3 X=0 Y=980 Z=-75 YAW=64
#exec MESH SEQUENCE MESH=muzzsr3 SEQ=All                      STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=muzzsr3 SEQ=Shoot                   STARTFRAME=0 NUMFRAMES=3
#exec MESHMAP NEW   MESHMAP=muzzsr3 MESH=muzzsr3
#exec MESHMAP SCALE MESHMAP=muzzsr3 X=0.04 Y=0.1 Z=0.08
#exec TEXTURE IMPORT NAME=Muzzy3 FILE=MODELS\Muzzy3.PCX GROUP=Skins

var int NumFire;
var name FireAnims[5];
var vector OwnerLocation;
var float StillTime, StillStart;

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn P;
	local float Scale;

	Super.PostRender(Canvas);
	P = PlayerPawn(Owner);
	if ( (P != None) && (P.DesiredFOV != P.DefaultFOV) ) 
	{
		bOwnsCrossHair = true;
		Scale = Canvas.ClipX/640;
		Canvas.SetPos(0.5 * Canvas.ClipX - 128 * Scale, 0.5 * Canvas.ClipY - 128 * Scale );
		if ( Level.bHighDetailMode )
			Canvas.Style = ERenderStyle.STY_Translucent;
		else
			Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawIcon(Texture'RReticle', Scale);
		Canvas.SetPos(0.5 * Canvas.ClipX + 64 * Scale, 0.5 * Canvas.ClipY + 96 * Scale);
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
		Scale = P.DefaultFOV/P.DesiredFOV;
		Canvas.DrawText("X"$int(Scale)$"."$int(10 * Scale - 10 * int(Scale)));
	}
	else
		bOwnsCrossHair = false;
}

function float RateSelf( out int bUseAltMode )
{
	local float dist;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	bUseAltMode = 0;
	if ( (Bot(Owner) != None) && Bot(Owner).bSniping )
		return AIRating + 1.15;
	if (  Pawn(Owner).Enemy != None )
	{
		dist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
		if ( dist > 1200 )
		{
			if ( dist > 2000 )
				return (AIRating + 0.75);
			return (AIRating + FMin(0.0001 * dist, 0.45)); 
		}
	}
	return AIRating;
}

// set which hand is holding weapon
function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("Botpack.Rifle2mL", class'Mesh'));
	else
		Mesh = mesh'Rifle2m';
}

simulated function PlayFiring()
{
	local int r;

	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
	PlayAnim(FireAnims[Rand(5)],0.5 + 0.5 * FireAdjust, 0.05);

	if ( (PlayerPawn(Owner) != None) 
		&& (PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV) )
		bMuzzleFlash++;
}


simulated function bool ClientAltFire( float Value )
{
	GotoState('Zooming');
	return true;
}

function AltFire( float Value )
{
	ClientAltFire(Value);
}

///////////////////////////////////////////////////////
state NormalFire
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}
		
Begin:
	FlashCount++;
}

function Timer()
{
	local actor targ;
	local float bestAim, bestDist;
	local vector FireDir;
	local Pawn P;

	bestAim = 0.95;
	P = Pawn(Owner);
	if ( P == None )
	{
		GotoState('');
		return;
	}
	if ( VSize(P.Location - OwnerLocation) < 6 )
		StillTime += FMin(2.0, Level.TimeSeconds - StillStart);

	else
		StillTime = 0;
	StillStart = Level.TimeSeconds;
	OwnerLocation = P.Location;
	FireDir = vector(P.ViewRotation);
	targ = P.PickTarget(bestAim, bestDist, FireDir, Owner.Location);
	if ( Pawn(targ) != None )
	{
		SetTimer(1 + 4 * FRand(), false);
		bPointing = true;
		Pawn(targ).WarnTarget(P, 200, FireDir);
	}
	else 
	{
		SetTimer(0.4 + 1.6 * FRand(), false);
		if ( (P.bFire == 0) && (P.bAltFire == 0) )
			bPointing = false;
	}
}	

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_Shellcase s;

	s = Spawn(class'UT_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
	if ( s != None ) 
	{
		s.DrawScale = 2.0;
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);              
	}
	if (Other == Level) 
		Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other != self) && (Other != Owner) && (Other != None) ) 
	{
		if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight) 
			&& (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice)) )
			Other.TakeDamage(100, Pawn(Owner), HitLocation, 35000 * X, AltDamageType);
		else
			Other.TakeDamage(45,  Pawn(Owner), HitLocation, 30000.0*X, MyDamageType);	
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);	
	}
}

function Finish()
{
	if ( (Pawn(Owner).bFire!=0) && (FRand() < 0.6) )
		Timer();
	Super.Finish();
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + PawnOwner.Eyeheight * Z; 
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2*AimError, False, False);	
	X = vector(AdjustedAim);
	EndTrace = StartTrace + 10000 * X; 
	Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}


state Idle
{
	function Fire( float Value )
	{
		if ( AmmoType == None )
		{
			// ammocheck
			GiveAmmo(Pawn(Owner));
		}
		if (AmmoType.UseAmmo(1))
		{
			GotoState('NormalFire');
			bCanClientFire = true;
			bPointing=True;
			if ( Owner.IsA('Bot') )
			{
				// simulate bot using zoom
				if ( Bot(Owner).bSniping && (FRand() < 0.65) )
					AimError = AimError/FClamp(StillTime, 1.0, 8.0);
				else if ( VSize(Owner.Location - OwnerLocation) < 6 )
					AimError = AimError/FClamp(0.5 * StillTime, 1.0, 3.0);
				else
					StillTime = 0;
			}
			Pawn(Owner).PlayRecoil(FiringSpeed);
			TraceFire(0.0);
			AimError = Default.AimError;
			ClientFire(Value);
		}
	}


	function BeginState()
	{
		bPointing = false;
		SetTimer(0.4 + 1.6 * FRand(), false);
		Super.BeginState();
	}

	function EndState()
	{	
		SetTimer(0.0, false);
		Super.EndState();
	}
	
Begin:
	bPointing=False;
	if ( AmmoType.AmmoAmount<=0 ) 
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	Disable('AnimEnd');
	PlayIdleAnim();
}

///////////////////////////////////////////////////////
state Zooming
{
	simulated function Tick(float DeltaTime)
	{
		if ( Pawn(Owner).bAltFire == 0 )
		{
			if ( (PlayerPawn(Owner) != None) && PlayerPawn(Owner).Player.IsA('ViewPort') )
				PlayerPawn(Owner).StopZoom();
			SetTimer(0.0,False);
			GoToState('Idle');
		}
	}

	simulated function BeginState()
	{
		if ( Owner.IsA('PlayerPawn') )
		{
			if ( PlayerPawn(Owner).Player.IsA('ViewPort') )
				PlayerPawn(Owner).ToggleZoom();
			SetTimer(0.2,True);
		}
		else
		{
			Pawn(Owner).bFire = 1;
			Pawn(Owner).bAltFire = 0;
			Global.Fire(0);
		}
	}
}

///////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		PlayAnim('Still',1.0, 0.05);
}

defaultproperties
{
     MuzzleFlashMesh=Mesh'Botpack.MuzzSR3'
     MuzzleFlashScale=0.10000
	 bMuzzleFlashParticles=true
	 MuzzleFlashStyle=STY_Translucent
	 MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
	 MyDamageType=shot
	 AltDamageType=decapitated
	 FireAnims(0)=Fire
	 FireAnims(1)=Fire2
	 FireAnims(2)=Fire3
	 FireAnims(3)=Fire4
	 FireAnims(4)=Fire5
     AmmoName=Class'Botpack.BulletBox'
     PickupAmmoCount=8
     bInstantHit=True
     bAltInstantHit=True
     FireOffset=(X=0.0,Y=-5.000000,Z=-2.000000)
     shakemag=400.000000
     shaketime=0.150000
     shakevert=8.000000
     AIRating=0.540000
     RefireRate=0.600000
     AltRefireRate=0.300000
     FireSound=Sound'SniperFire'
     SelectSound=Sound'UnrealI.Rifle.RiflePickup'
     AutoSwitchPriority=5
     InventoryGroup=10
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     bNoSmooth=False
     bMeshCurvy=False
     CollisionRadius=32.000000
     CollisionHeight=8.000000
	 FiringSpeed=1.8
	 DeathMessage="%k put a bullet through %o's head."
    PlayerViewOffset=(X=5.000000,Y=-1.600000,Z=-1.700000)
    PlayerViewScale=2.000000
    PlayerViewMesh=Mesh'BotPack.Rifle2m'
    PickupViewMesh=Mesh'BotPack.RiflePick'
    ThirdPersonMesh=Mesh'BotPack.RifleHand'
    Rotation=(Pitch=0,Yaw=0,Roll=-1536)
    Mesh=Mesh'BotPack.RiflePick'
 	MFTexture=Texture'MuzzleFlash2'
	bDrawMuzzleFlash=true
	FlashS=256
	FlashY=0.11
	FlashO=0.014
	FlashC=0.031
	MuzzleScale=1
	FlashLength=+0.013
	Icon=Texture'Botpack.UseRifle'
	StatusIcon=Texture'Botpack.UseRifle'
	ItemName="Sniper Rifle"
	PickupMessage="You got a Sniper Rifle."
	BobDamping=0.975000
	WeaponDescription="Classification: Long Range Ballistic\\n\\nRegular Fire: Fires a high powered bullet. Can kill instantly when applied to the cranium of opposing forces. \\n\\nSecondary Fire: Zooms the rifle in, up to eight times normal vision. Allows for extreme precision from hundreds of yards away.\\n\\nTechniques: Great for long distance headshots!"
	NameColor=(R=0,G=0,B=255)
}
