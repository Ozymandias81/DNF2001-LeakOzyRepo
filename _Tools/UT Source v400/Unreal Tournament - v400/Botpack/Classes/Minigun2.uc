//=============================================================================
// Minigun.
//=============================================================================
class Minigun2 extends TournamentWeapon;

#exec MESH IMPORT MESH=Minigun2m ANIVFILE=MODELS\minigun_a.3D DATAFILE=MODELS\minigun_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Minigun2m X=0 Y=0 Z=0 YAW=64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=Minigun2m SEQ=All     STARTFRAME=0   NUMFRAMES=152
#exec MESH SEQUENCE MESH=Minigun2m SEQ=Select  STARTFRAME=0   NUMFRAMES=20 RATE=36 GROUP=Select
#exec MESH SEQUENCE MESH=Minigun2m SEQ=Still   STARTFRAME=21  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Minigun2m SEQ=Wind    STARTFRAME=21  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2m SEQ=Wind2   STARTFRAME=40  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2m SEQ=Shoot1  STARTFRAME=61  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2m SEQ=Shoot2  STARTFRAME=61  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2m SEQ=Unwind  STARTFRAME=80  NUMFRAMES=39
#exec MESH SEQUENCE MESH=Minigun2m SEQ=Idle    STARTFRAME=121  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2m SEQ=Down    STARTFRAME=141  NUMFRAMES=10

#exec OBJ LOAD FILE=Textures\Ammocount.utx  PACKAGE=Botpack.Ammocount
#exec TEXTURE IMPORT NAME=Mini_t FILE=MODELS\Mini.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Mini_t1 FILE=MODELS\Mini1.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Mini_t2 FILE=MODELS\Mini2.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Mini_t3 FILE=MODELS\Mini3.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Mini_t4 FILE=MODELS\Mini4.PCX GROUP="Skins" LODSET=2

#exec MESHMAP SCALE MESHMAP=Minigun2m X=0.0035 Y=0.0017 Z=0.007
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2m NUM=0 TEXTURE=Mini_t1
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2m NUM=1 TEXTURE=Mini_t2
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2m NUM=2 TEXTURE=Mini_t3
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2m NUM=3 TEXTURE=Mini_t4
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2m NUM=4 TEXTURE=Botpack.Ammocount.MiniAmmoled

#exec MESH IMPORT MESH=Minigun2L ANIVFILE=MODELS\minigun_a.3D DATAFILE=MODELS\minigun_d.3D UnMirror=1  unmirrortex=4
#exec MESH ORIGIN MESH=Minigun2L X=0 Y=0 Z=0 YAW=64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=Minigun2L SEQ=All     STARTFRAME=0   NUMFRAMES=152
#exec MESH SEQUENCE MESH=Minigun2L SEQ=Select  STARTFRAME=0   NUMFRAMES=20 RATE=36 GROUP=Select
#exec MESH SEQUENCE MESH=Minigun2L SEQ=Still   STARTFRAME=21  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Minigun2L SEQ=Wind    STARTFRAME=21  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2L SEQ=Wind2   STARTFRAME=40  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2L SEQ=Shoot1  STARTFRAME=61  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2L SEQ=Shoot2  STARTFRAME=61  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2L SEQ=Unwind  STARTFRAME=80  NUMFRAMES=39
#exec MESH SEQUENCE MESH=Minigun2L SEQ=Idle    STARTFRAME=121  NUMFRAMES=19
#exec MESH SEQUENCE MESH=Minigun2L SEQ=Down    STARTFRAME=141  NUMFRAMES=10

#exec MESHMAP SCALE MESHMAP=Minigun2L X=0.0035 Y=0.0017 Z=0.007
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2L NUM=0 TEXTURE=Mini_t1
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2L NUM=1 TEXTURE=Mini_t2
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2L NUM=2 TEXTURE=Mini_t3
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2L NUM=3 TEXTURE=Mini_t4
#exec MESHMAP SETTEXTURE MESHMAP=Minigun2L NUM=4 TEXTURE=Botpack.Ammocount.MiniAmmoled

#exec TEXTURE IMPORT NAME=Muz1 FILE=MODELS\muz1.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Muz2 FILE=MODELS\muz2.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Muz3 FILE=MODELS\muz3.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Muz4 FILE=MODELS\muz4.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Muz5 FILE=MODELS\muz5.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Muz6 FILE=MODELS\muz6.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Muz7 FILE=MODELS\muz7.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Muz8 FILE=MODELS\muz8.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Muz9 FILE=MODELS\muz9.PCX GROUP="Skins" LODSET=2

#exec MESH IMPORT MESH=MinigunPick ANIVFILE=MODELS\minipick_a.3D DATAFILE=MODELS\minipick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MinigunPick X=0 Y=0 Z=0 YAW=64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=MinigunPick SEQ=All     STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=MinigunPick X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=MinigunPick NUM=1 TEXTURE=Mini_t

#exec MESH IMPORT MESH=MiniHand ANIVFILE=MODELS\minihand_a.3D DATAFILE=MODELS\minihand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MiniHand X=5 Y=270 Z=-20 YAW=64 PITCH=0
#exec MESH SEQUENCE MESH=MiniHand SEQ=All STARTFRAME=0  NUMFRAMES=11
#exec MESH SEQUENCE MESH=MiniHand SEQ=Shoot1  STARTFRAME=1  NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=MiniHand X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=MiniHand NUM=1 TEXTURE=Mini_t

#exec TEXTURE IMPORT NAME=IconMini FILE=TEXTURES\HUD\WpnMini.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseMini FILE=TEXTURES\HUD\UseMini.PCX GROUP="Icons" MIPS=OFF

#exec AUDIO IMPORT FILE="Sounds\Minigun\RegFire.Wav" NAME=M2RegFire GROUP="Minigun2"
#exec AUDIO IMPORT FILE="Sounds\Minigun\AltFire.Wav" NAME=M2AltFire GROUP="Minigun2"
#exec AUDIO IMPORT FILE="Sounds\Minigun\WindDown.Wav" NAME=M2WindDown GROUP="Minigun2"

#exec MESH IMPORT MESH=MuzzFlash3 ANIVFILE=MODELS\muzzle2_a.3d DATAFILE=MODELS\Muzzle2_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=muzzFlash3 MINVERTS=8 STRENGTH=0.7 ZDISP=800.0 

#exec MESH ORIGIN MESH=MuzzFlash3 X=0 Y=940 Z=0 YAW=64
#exec MESH SEQUENCE MESH=MuzzFlash3 SEQ=All                      STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=MuzzFlash3 SEQ=Shoot                   STARTFRAME=0 NUMFRAMES=9
#exec MESHMAP NEW    MESHMAP=MuzzFlash3 MESH=MuzzFlash3
#exec MESHMAP SCALE MESHMAP=MuzzFlash3 X=0.08 Y=0.08 Z=0.16
#exec TEXTURE IMPORT NAME=Muzzy FILE=MODELS\Muzzy.PCX GROUP=Skins

var float ShotAccuracy, LastShellSpawn;
var int Count;
var bool bOutOfAmmo, bFiredShot;
var() texture MuzzleFlashVariations[10];

// set which hand is holding weapon
function setHand(float Hand)
{
	if ( Hand == 2 )
	{
		FireOffset.Y = 0;
		bHideWeapon = true;
		return;
	}
	else
		bHideWeapon = false;
	PlayerViewOffset = Default.PlayerViewOffset * 100;
	FireOffset.Y = Hand * Default.FireOffset.Y;
	PlayerViewOffset.Y *= Hand;
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("Botpack.Minigun2L", class'Mesh'));
	else
	{
		Mesh = mesh'Minigun2m';
		if ( Hand == 0 )
		{
			PlayerViewOffset.X = Default.PlayerViewOffset.X * 95;
			PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 105;
		}
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;
	
	Temp = String(AmmoType.AmmoAmount);

	while(Len(Temp) < 3) Temp = "0"$Temp;

	C.R = 255;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 2, 10, Temp, Font'LEDFont2', C );	
}

function float RateSelf( out int bUseAltMode )
{
	local float dist;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}

	dist = VSize(Pawn(Owner).Enemy.Location - Owner.Location); 
	bUseAltMode = 1;
	if ( dist > 1200 )
	{
		if ( dist > 1700 )
			bUseAltMode = 0;
		return (AIRating * FMin(Pawn(Owner).DamageScaling, 1.5) + FMin(0.0001 * dist, 0.3)); 
	}
	AIRating *= FMin(Pawn(Owner).DamageScaling, 1.5);
	return AIRating;
}

simulated event RenderOverlays( canvas Canvas )
{
	local UT_Shellcase s;
	local vector X,Y,Z;
	local float dir;

	if ( bSteadyFlash3rd )
	{
		bMuzzleFlash = 1;
		bSetFlashTime = false;
		if ( !Level.bDropDetail )
			MFTexture = MuzzleFlashVariations[Rand(10)];
		else
			MFTexture = MuzzleFlashVariations[Rand(5)];
	}
	else
		bMuzzleFlash = 0;
	FlashY = Default.FlashY * (1.08 - 0.16 * FRand());
	if ( !Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Handedness == 0) )
		FlashO = Default.FlashO * (4 + 0.15 * FRand());
	else		
		FlashO = Default.FlashO * (1 + 0.15 * FRand());
	Texture'MiniAmmoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'MiniAmmoled'.NotifyActor = None;

	if ( bSteadyFlash3rd && Level.bHighDetailMode && (Level.TimeSeconds - LastShellSpawn > 0.125)
		&& (Level.Pauser=="") )
	{
		LastShellSpawn = Level.TimeSeconds;
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);

		if ( PlayerViewOffset.Y >= 0 )
			dir = 1;
		else 
			dir = -1;
		if ( Level.bHighDetailMode )
		{
			s = Spawn(class'MiniShellCase',Owner, '', Owner.Location + CalcDrawOffset() + 30 * X + (0.4 * PlayerViewOffset.Y+5.0) * Y - Z * 5);
			if ( s != None ) 
				s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.3+0.2)*dir*Y + (FRand()*0.3+1.0) * Z)*160);              
		}
	}
}

function GenerateBullet()
{
    LightType = LT_Steady;
	bFiredShot = true;
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
	if ( AmmoType.UseAmmo(1) ) 
		TraceFire(ShotAccuracy);
	else
		GotoState('FinishFire');
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, AimDir;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z; 
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);	
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	AimDir = vector(AdjustedAim);
	EndTrace += (10000 * AimDir); 
	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);

	Count++;
	if ( Count == 4 )
	{
		Count = 0;
		if ( VSize(HitLocation - StartTrace) > 250 )
			Spawn(class'MTracer',,, StartTrace + 96 * AimDir,rotator(EndTrace - StartTrace));
	}
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int rndDam;

	if (Other == Level) 
		Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other!=self) && (Other!=Owner) && (Other != None) ) 
	{
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9); 
		if ( Other.IsA('Bot') && (FRand() < 0.2) )
			Pawn(Other).WarnTarget(Pawn(Owner), 500, X);
		rndDam = 9 + Rand(6);
		if ( FRand() < 0.2 )
			X *= 2.5;
		Other.TakeDamage(rndDam, Pawn(Owner), HitLocation, rndDam*500.0*X, MyDamageType);
	}
}

function Fire( float Value )
{
	Enable('Tick');
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		SoundVolume = 255*Pawn(Owner).SoundDampening;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bCanClientFire = true;
		bPointing=True;
		ShotAccuracy = 0.2;
		ClientFire(value);
		GotoState('NormalFire');
	}
	else GoToState('Idle');
}

function AltFire( float Value )
{
	Enable('Tick');
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		bPointing=True;
		bCanClientFire = true;
		ShotAccuracy = 0.95;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		SoundVolume = 255*Pawn(Owner).SoundDampening;		
		ClientAltFire(value);	
		GoToState('AltFiring');		
	}
	else GoToState('Idle');	
}

simulated function PlayFiring()
{	
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	PlayAnim('Shoot1',1 + 0.6 * FireAdjust, 0.05);
	AmbientGlow = 250;
	AmbientSound = FireSound;
	bSteadyFlash3rd = true;
}

simulated function PlayAltFiring()
{
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	PlayAnim('Shoot1',1 + 0.3 * FireAdjust, 0.05);
	AmbientGlow = 250;
	AmbientSound = FireSound;
	bSteadyFlash3rd = true;
}

simulated function PlayUnwind()
{
	if ( Owner != None )
	{
		PlayOwnedSound(Misc1Sound, SLOT_Misc, 3.0*Pawn(Owner).SoundDampening);  //Finish firing, power down		
		PlayAnim('UnWind',1.5, 0.05);
	}
}

////////////////////////////////////////////////////////
state FinishFire
{
	function Fire(float F) {}
	function AltFire(float F) {}

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function BeginState()
	{
		PlayUnwind();
	}

Begin:
	FinishAnim();
	Finish();
}

///////////////////////////////////////////////////////
state NormalFire
{
	function Tick( float DeltaTime )
	{
		if (Owner==None) 
			AmbientSound = None;
	}

	function AnimEnd()
	{
		if (Pawn(Owner).Weapon != self) GotoState('');
		else if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0)
			Global.Fire(0);
		else if ( Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0)
			Global.AltFire(0);
		else 
			GotoState('FinishFire');
	}

	function BeginState()
	{
		AmbientGlow = 250;
		AmbientSound = FireSound;
		bSteadyFlash3rd = true;
		Super.BeginState();
	}	

	function EndState()
	{
		bSteadyFlash3rd = false;
		AmbientGlow = 0;
		LightType = LT_None;
		AmbientSound = None;
		Super.EndState();
	}

Begin:
	Sleep(0.13);
	GenerateBullet();
	Goto('Begin');
}

state ClientFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (AmmoType.AmmoAmount <= 0) )
		{
			PlayUnwind();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayUnwind();
			GotoState('ClientFinish');
		}
	}

	simulated function BeginState()
	{
		AmbientSound = FireSound;
		bSteadyFlash3rd = true;
	}

	simulated function EndState()
	{
		bSteadyFlash3rd = false;
		Super.EndState();
	}
}

////////////////////////////////////////////////////////

state ClientFinish
{
	simulated function bool ClientFire(float Value)
	{
		bForceFire = bForceFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		bForceAltFire = bForceAltFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceAltFire;
	}

	simulated function AnimEnd()
	{
		if ( bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0) )
		{
			if ( bForceFire || (Pawn(Owner).bFire != 0) )
			{
				Global.ClientFire(0);
				return;
			}
			else if ( bForceAltFire || (Pawn(Owner).bAltFire != 0) )
			{
				Global.ClientAltFire(0);
				return;
			}
		}			
		GotoState('');
		Global.AnimEnd();
	}

	simulated function EndState()
	{
		bSteadyFlash3rd = false;
		bForceFire = false;
		bForceAltFire = false;
		AmbientSound = None;
	}

	simulated function BeginState()
	{
		bSteadyFlash3rd = false;
		bForceFire = false;
		bForceAltFire = false;
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (AmmoType.AmmoAmount <= 0) )
		{
			PlayUnwind();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bAltFire != 0 )
		{
			if ( (AnimSequence != 'Shoot2') || !bAnimLoop )
			{	
				AmbientSound = AltFireSound;
				SoundVolume = 255*Pawn(Owner).SoundDampening;
				LoopAnim('Shoot2',1.9);
			}
			else if ( AmbientSound == None )
				AmbientSound = FireSound;

			if ( Affector != None )
				Affector.FireEffect();
			if ( PlayerPawn(Owner) != None )
				PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else
		{
			PlayUnwind();
			bSteadyFlash3rd = false;
			GotoState('ClientFinish');
		}
	}

	simulated function BeginState()
	{
		bSteadyFlash3rd = true;
		AmbientSound = FireSound;
	}

	simulated function EndState()
	{
		bSteadyFlash3rd = false;
		Super.EndState();
	}
}

state AltFiring
{
	function Tick( float DeltaTime )
	{
		if (Owner==None) 
		{
			AmbientSound = None;
			GotoState('Pickup');
		}			

		if	( bFiredShot && ((pawn(Owner).bAltFire==0) || bOutOfAmmo) ) 
			GoToState('FinishFire');
	}

	function AnimEnd()
	{
		if ( (AnimSequence != 'Shoot2') || !bAnimLoop )
		{	
			AmbientSound = AltFireSound;
			SoundVolume = 255*Pawn(Owner).SoundDampening;
			LoopAnim('Shoot2',1.9);
		}
		else if ( AmbientSound == None )
			AmbientSound = FireSound;
		if ( Affector != None )
			Affector.FireEffect();
	}

	function BeginState()
	{
		Super.BeginState();
		AmbientSound = FireSound;
		AmbientGlow = 250;
		bFiredShot = false;
		bSteadyFlash3rd = true;
	}	

	function EndState()
	{
		bSteadyFlash3rd = false;
		AmbientGlow = 0;
		LightType = LT_None;
		AmbientSound = None;
		Super.EndState();
	}

Begin:
	Sleep(0.13);
	GenerateBullet();
	if ( AnimSequence == 'Shoot2' )
		Goto('FastShoot');
	Goto('Begin');
FastShoot:
	Sleep(0.08);
	GenerateBullet();
	Goto('FastShoot');
}

///////////////////////////////////////////////////////////
state Idle
{

Begin:
	if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0) AltFire(0.0);	
	LoopAnim('Idle',0.2,0.9);
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) ) 
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	Disable('AnimEnd');	
}

defaultproperties
{
     MuzzleFlashMesh=Mesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
	 bMuzzleFlashParticles=true
	 MuzzleFlashStyle=STY_Translucent
	 MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
	 MyDamageType=shot
     MuzzleFlashVariations(0)=Texture'Botpack.Skins.Muz1'
     MuzzleFlashVariations(1)=Texture'Botpack.Skins.Muz2'
     MuzzleFlashVariations(2)=Texture'Botpack.Skins.Muz3'
     MuzzleFlashVariations(3)=Texture'Botpack.Skins.Muz4'
     MuzzleFlashVariations(4)=Texture'Botpack.Skins.Muz5'
     MuzzleFlashVariations(5)=Texture'Botpack.Skins.Muz6'
     MuzzleFlashVariations(6)=Texture'Botpack.Skins.Muz7'
     MuzzleFlashVariations(7)=Texture'Botpack.Skins.Muz8'
     MuzzleFlashVariations(8)=Texture'Botpack.Skins.Muz9'
     MuzzleFlashVariations(9)=Texture'Botpack.Skins.Muz9'
     AmmoName=Class'Botpack.miniammo'
	 FlashLength=+0.2
     PickupAmmoCount=50
     bInstantHit=True
     bAltInstantHit=True
	 bRapidFire=true
     FireOffset=(X=8.000000,Y=-5.000000,Z=-4.000000)
     shakemag=135.000000
     shakevert=8.000000
     AIRating=0.730000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'M2RegFire'
     AltFireSound=Sound'M2AltFire'
     SelectSound=Sound'MiniSelect'
     Misc1Sound=Sound'M2WindDown'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     bDrawMuzzleFlash=True
     MuzzleScale=2.000000
     FlashY=0.180000
     FlashO=0.022000
     FlashC=0.006000
     FlashS=128
     MFTexture=Texture'Botpack.Skins.Muz9'
     AutoSwitchPriority=7
     InventoryGroup=7
     PickupMessage="You got the Minigun."
     ItemName="Minigun"
     PlayerViewOffset=(X=2.100000,Y=-0.350000,Z=-1.700000)
     PlayerViewMesh=Mesh'Botpack.Minigun2m'
     BobDamping=0.975000
     PickupViewMesh=Mesh'Botpack.MinigunPick'
     ThirdPersonMesh=Mesh'Botpack.MiniHand'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=Mesh'Botpack.MinigunPick'
     bNoSmooth=False
     bMeshCurvy=False
     SoundRadius=96
     SoundVolume=255
     CollisionRadius=34.000000
     CollisionHeight=8.000000
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=28
     LightSaturation=32
     LightRadius=6
	 Icon=Texture'Botpack.UseMini'
	 StatusIcon=Texture'Botpack.UseMini'
	 WeaponDescription="Classification: Gatling Gun\\n\\nPrimary Fire: Bullets are sprayed forth at a medium to fast rate of fire and good accuracy.\\n\\nSecondary Fire: Minigun fires twice as fast and is half as accurate.\\n\\nTechniques: Secondary fire is much more useful at close range, but can eat up tons of ammunition."
	 NameColor=(R=255,G=255,B=0)
}
