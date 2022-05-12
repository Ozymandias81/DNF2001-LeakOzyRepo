//=============================================================================
// PulseGun.
//=============================================================================
class PulseGun extends TournamentWeapon;

#exec MESH IMPORT MESH=PulseGunL ANIVFILE=MODELS\PulseGun_a.3d DATAFILE=MODELS\PulseGun_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PulseGunL X=0 Y=0 Z=0 YAW=64 ROLL=0 PITCH=0

#exec MESH DROPFRAMES MESH=PulseGunL STARTFRAME=65    NUMFRAMES=50
#exec MESH DROPFRAMES MESH=PulseGunL STARTFRAME=86    NUMFRAMES=79

#exec MESH SEQUENCE MESH=PulseGunL SEQ=All          STARTFRAME=0     NUMFRAMES=126
#exec MESH SEQUENCE MESH=PulseGunL SEQ=Down		    STARTFRAME=8     NUMFRAMES=1
#exec MESH SEQUENCE MESH=PulseGunL SEQ=Select       STARTFRAME=9     NUMFRAMES=16 RATE=36 GROUP=Select
#exec MESH SEQUENCE MESH=PulseGunL SEQ=Still        STARTFRAME=25    NUMFRAMES=1
#exec MESH SEQUENCE MESH=PulseGunL SEQ=shoot1       STARTFRAME=25    NUMFRAMES=5
#exec MESH SEQUENCE MESH=PulseGunL SEQ=shoot2       STARTFRAME=30    NUMFRAMES=5
#exec MESH SEQUENCE MESH=PulseGunL SEQ=shoot3       STARTFRAME=35    NUMFRAMES=5
#exec MESH SEQUENCE MESH=PulseGunL SEQ=spindown     STARTFRAME=40    NUMFRAMES=25
#exec MESH SEQUENCE MESH=PulseGunL SEQ=bolt         STARTFRAME=65   NUMFRAMES=20
#exec MESH SEQUENCE MESH=PulseGunL SEQ=boltstart    STARTFRAME=65   NUMFRAMES=15
#exec MESH SEQUENCE MESH=PulseGunL SEQ=boltloop     STARTFRAME=70   NUMFRAMES=10
#exec MESH SEQUENCE MESH=PulseGunL SEQ=boltend      STARTFRAME=80   NUMFRAMES=5
#exec MESH SEQUENCE MESH=PulseGunL SEQ=idle         STARTFRAME=85   NUMFRAMES=1 
#exec MESH SEQUENCE MESH=PulseGunL SEQ=Shootloop    STARTFRAME=86   NUMFRAMES=40   

#exec MESHMAP NEW   MESHMAP=PulseGunL MESH=PulseGunL
#exec MESHMAP SCALE MESHMAP=PulseGunL X=0.013 Y=0.013 Z=0.026

#exec OBJ LOAD FILE=Textures\Ammocount.utx  PACKAGE=Botpack.Ammocount
#exec TEXTURE IMPORT NAME=JPulseGun_02 FILE=Textures\Pulse-tex.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JPulseGun_03 FILE=Textures\Hand.PCX GROUP=Skins LODSET=2

#exec MESHMAP SETTEXTURE MESHMAP=PulseGunL NUM=1 TEXTURE=Botpack.Ammocount.Ammoled
#exec MESHMAP SETTEXTURE MESHMAP=PulseGunL NUM=2 TEXTURE=JPulseGun_02
#exec MESHMAP SETTEXTURE MESHMAP=PulseGunL NUM=3 TEXTURE=JPulseGun_03

// right handed view version
#exec MESH IMPORT MESH=PulseGunR ANIVFILE=MODELS\PulseGun_a.3d DATAFILE=MODELS\PulseGun_d.3d unmirror=1 unmirrortex=1
#exec MESH ORIGIN MESH=PulseGunR X=0 Y=0 Z=0 YAW=64 ROLL=0 PITCH=0

#exec MESH DROPFRAMES MESH=PulseGunR STARTFRAME=65    NUMFRAMES=50
#exec MESH DROPFRAMES MESH=PulseGunR STARTFRAME=86    NUMFRAMES=79

#exec MESH SEQUENCE MESH=PulseGunR SEQ=All          STARTFRAME=0     NUMFRAMES=255
#exec MESH SEQUENCE MESH=PulseGunR SEQ=Down         STARTFRAME=8     NUMFRAMES=1
#exec MESH SEQUENCE MESH=PulseGunR SEQ=Select       STARTFRAME=9     NUMFRAMES=16 RATE=36 GROUP=Select
#exec MESH SEQUENCE MESH=PulseGunR SEQ=Still        STARTFRAME=25    NUMFRAMES=1
#exec MESH SEQUENCE MESH=PulseGunR SEQ=shoot1       STARTFRAME=25    NUMFRAMES=5
#exec MESH SEQUENCE MESH=PulseGunR SEQ=shoot2       STARTFRAME=30    NUMFRAMES=5
#exec MESH SEQUENCE MESH=PulseGunR SEQ=shoot3       STARTFRAME=35    NUMFRAMES=5
#exec MESH SEQUENCE MESH=PulseGunR SEQ=spindown     STARTFRAME=40    NUMFRAMES=25
#exec MESH SEQUENCE MESH=PulseGunR SEQ=bolt         STARTFRAME=65   NUMFRAMES=20
#exec MESH SEQUENCE MESH=PulseGunR SEQ=boltstart    STARTFRAME=65   NUMFRAMES=15
#exec MESH SEQUENCE MESH=PulseGunR SEQ=boltloop     STARTFRAME=70   NUMFRAMES=10
#exec MESH SEQUENCE MESH=PulseGunR SEQ=boltend      STARTFRAME=80   NUMFRAMES=5
#exec MESH SEQUENCE MESH=PulseGunR SEQ=idle         STARTFRAME=85   NUMFRAMES=1 
#exec MESH SEQUENCE MESH=PulseGunR SEQ=Shootloop    STARTFRAME=86   NUMFRAMES=40   

#exec MESHMAP NEW   MESHMAP=PulseGunR MESH=PulseGun
#exec MESHMAP SCALE MESHMAP=PulseGunR X=0.013 Y=0.013 Z=0.026

#exec MESHMAP SETTEXTURE MESHMAP=PulseGunR NUM=1 TEXTURE=Botpack.Ammocount.Ammoled
#exec MESHMAP SETTEXTURE MESHMAP=PulseGunR NUM=2 TEXTURE=JPulseGun_02
#exec MESHMAP SETTEXTURE MESHMAP=PulseGunR NUM=3 TEXTURE=JPulseGun_03


// 3rd person view
#exec MESH IMPORT MESH=PulseGun3rd ANIVFILE=MODELS\Pulse3rd_a.3d DATAFILE=MODELS\Pulse3rd_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PulseGun3rd X=0 Y=200 Z=-50 YAW=64 ROLL=0 PITCH=0
#exec MESH SEQUENCE MESH=PulseGun3rd SEQ=All                      STARTFRAME=0 NUMFRAMES=50
#exec MESH SEQUENCE MESH=PulseGun3rd SEQ=still                      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=PulseGun3rd SEQ=shootloop                  STARTFRAME=5 NUMFRAMES=20
#exec MESH SEQUENCE MESH=PulseGun3rd SEQ=spindown                   STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=PulseGun3rd MESH=PulseGun3rd
#exec MESHMAP SCALE MESHMAP=PulseGun3rd X=0.1 Y=0.1 Z=0.2
#exec TEXTURE IMPORT NAME=JPulse3rd_01 FILE=MODELS\Pulse-3rd.PCX GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=PulseGun3rd NUM=1 TEXTURE=JPulse3rd_01

// Pickup view
#exec MESH IMPORT MESH=PulsePickup ANIVFILE=MODELS\PulsePickup_a.3d DATAFILE=MODELS\PulsePickup_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PulsePickup X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=PulsePickup SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=PulsePickup MESH=PulsePickup
#exec MESHMAP SCALE MESHMAP=PulsePickup X=0.08 Y=0.08 Z=0.16
#exec TEXTURE IMPORT NAME=JPulsePickup_01 FILE=MODELS\P-pickup.pcx GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=PulsePickup NUM=1 TEXTURE=JPulsePickup_01

#exec AUDIO IMPORT FILE="Sounds\Pulsegun\PulseFire.WAV" NAME="PulseFire" GROUP="PulseGun"
#exec AUDIO IMPORT FILE="Sounds\Pulsegun\PulseBolt.WAV" NAME="PulseBolt" GROUP="PulseGun"
#exec AUDIO IMPORT FILE="Sounds\Pulsegun\PulseDown.WAV" NAME="PulseDown" GROUP="PulseGun"
#exec AUDIO IMPORT FILE="Sounds\Pulsegun\PulsePickup.WAV" NAME="PulsePickup" GROUP="PulseGun"

#exec TEXTURE IMPORT NAME=IconPulse FILE=TEXTURES\HUD\WpnPulse.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UsePulse FILE=TEXTURES\HUD\UsePulse.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=muzzPF3 ANIVFILE=MODELS\muzzle2_a.3d DATAFILE=MODELS\muzzle2_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=muzzPF3 MINVERTS=8 STRENGTH=0.7 ZDISP=800.0
#exec MESH ORIGIN MESH=muzzPF3 X=0 Y=890 Z=-10 YAW=64
#exec MESH SEQUENCE MESH=muzzPF3 SEQ=All                      STARTFRAME=0 NUMFRAMES=9
#exec MESHMAP NEW   MESHMAP=muzzPF3 MESH=muzzPF3
#exec MESHMAP SCALE MESHMAP=muzzPF3 X=0.08 Y=0.05 Z=0.16
#exec TEXTURE IMPORT NAME=MuzzyPulse FILE=MODELS\Pulseflash.PCX GROUP=Skins



var float Angle, Count;
var PBolt PlasmaBeam;
var() sound DownSound;

simulated event RenderOverlays( canvas Canvas )
{
	Texture'Ammoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'Ammoled'.NotifyActor = None;
}

simulated function Destroyed()
{
	if ( PlasmaBeam != None )
		PlasmaBeam.Destroy();

	Super.Destroyed();
}

simulated function AnimEnd()
{
	if ( (Level.NetMode == NM_Client) && (Mesh != PickupViewMesh) )
	{
		if ( AnimSequence == 'SpinDown' )
			AnimSequence = 'Idle';
		PlayIdleAnim();
	}
}
// set which hand is holding weapon
function setHand(float Hand)
{
	if ( Hand == 2 )
	{
		FireOffset.Y = 0;
		bHideWeapon = true;
		if ( PlasmaBeam != None )
			PlasmaBeam.bCenter = true;
		return;
	}
	else
		bHideWeapon = false;
	PlayerViewOffset = Default.PlayerViewOffset * 100;
	if ( Hand == 1 )
	{
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.bCenter = false;
			PlasmaBeam.bRight = false;
		}
		FireOffset.Y = Default.FireOffset.Y;
		Mesh = mesh(DynamicLoadObject("Botpack.PulseGunL", class'Mesh'));
	}
	else
	{
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.bCenter = false;
			PlasmaBeam.bRight = true;
		}
		FireOffset.Y = -1 * Default.FireOffset.Y;
		Mesh = mesh'PulseGunR';
	}
}

// return delta to combat style
function float SuggestAttackStyle()
{
	local float EnemyDist;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist < 1000 )
		return 0.4;
	else
		return 0;
}

function float RateSelf( out int bUseAltMode )
{
	local Pawn P;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	P = Pawn(Owner);
	if ( (P.Enemy == None) || (Owner.IsA('Bot') && Bot(Owner).bQuickFire) )
	{
		bUseAltMode = 0;
		return AIRating;
	}

	if ( P.Enemy.IsA('StationaryPawn') )
	{
		bUseAltMode = 0;
		return (AIRating + 0.4);
	}
	else
		bUseAltMode = int( 700 > VSize(P.Enemy.Location - Owner.Location) );

	AIRating *= FMin(Pawn(Owner).DamageScaling, 1.5);
	return AIRating;
}

simulated function PlayFiring()
{
	FlashCount++;
	AmbientSound = FireSound;
	SoundVolume = Pawn(Owner).SoundDampening*255;
	LoopAnim( 'shootLOOP', 1 + 0.5 * FireAdjust, 0.0);
	bWarnTarget = (FRand() < 0.2);
}

simulated function PlayAltFiring()
{
	
	AmbientSound = AltFireSound;
	if ( (AnimSequence == 'BoltLoop') || (AnimSequence == 'BoltStart') )		
		PlayAnim( 'boltloop');
	else
		PlayAnim( 'boltstart' );
}

function AltFire( float Value )
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		GotoState('AltFiring');
		bCanClientFire = true;
		bPointing=True;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ClientAltFire(value);
		if ( PlasmaBeam == None )
		{
			PlasmaBeam = PBolt(ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget));
			if ( FireOffset.Y == 0 )
				PlasmaBeam.bCenter = true;
			else if ( Mesh == mesh'PulseGunR' )
				PlasmaBeam.bRight = false;
		}
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;
	
	Temp = String(AmmoType.AmmoAmount);

	while(Len(Temp) < 3) Temp = "0"$Temp;

	Tex.DrawTile( 30, 100, (Min(AmmoType.AmmoAmount,AmmoType.Default.AmmoAmount)*196)/AmmoType.Default.AmmoAmount, 10, 0, 0, 1, 1, Texture'AmmoCountBar', False );

	if(AmmoType.AmmoAmount < 10)
	{
		C.R = 255;
		C.G = 0;
		C.B = 0;	
	}
	else
	{
		C.R = 0;
		C.G = 0;
		C.B = 255;
	}

	Tex.DrawColoredText( 56, 14, Temp, Font'LEDFont', C );	
}

///////////////////////////////////////////////////////
state NormalFire
{
	ignores AnimEnd;

	function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
	{
		local Vector Start, X,Y,Z;

		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
		AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);	
		Start = Start - Sin(Angle)*Y*4 + (Cos(Angle)*4 - 10.78)*Z;
		Angle += 1.8;
		return Spawn(ProjClass,,, Start,AdjustedAim);	
	}

	function Tick( float DeltaTime )
	{
		if (Owner==None) 
			GotoState('Pickup');
	}

	function BeginState()
	{
		Super.BeginState();
		Angle = 0;
		AmbientGlow = 200;
	}

	function EndState()
	{
		PlaySpinDown();
		AmbientSound = None;
		AmbientGlow = 0;	
		OldFlashCount = FlashCount;	
		Super.EndState();
	}

Begin:
	Sleep(0.18);
	Finish();
}

simulated function PlaySpinDown()
{
	if ( (Mesh != PickupViewMesh) && (Owner != None) )
	{
		PlayAnim('Spindown', 1.0, 0.0);
		Owner.PlayOwnedSound(DownSound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
	}
}	

state ClientFiring
{
	simulated function Tick( float DeltaTime )
	{
		if ( (Pawn(Owner) != None) && (Pawn(Owner).bFire != 0) )
			AmbientSound = FireSound;
		else
			AmbientSound = None;
	}

	simulated function AnimEnd()
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
		{
			PlaySpinDown();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlaySpinDown();
			GotoState('');
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlaySpinDown();
			GotoState('');
		}
	}
}

///////////////////////////////////////////////////////////////
state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( AmmoType.AmmoAmount <= 0 )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( Pawn(Owner).bAltFire != 0 )
			LoopAnim('BoltLoop');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

state AltFiring
{
	ignores AnimEnd;

	function Tick(float DeltaTime)
	{
		local Pawn P;

		P = Pawn(Owner);
		if ( P == None )
		{
			GotoState('Pickup');
			return;
		}
		if ( (P.bAltFire == 0) || (P.IsA('Bot')
					&& ((P.Enemy == None) || (Level.TimeSeconds - Bot(P).LastSeenTime > 5))) )
		{
			P.bAltFire = 0;
			Finish();
			return;
		}

		Count += Deltatime;
		if ( Count > 0.24 )
		{
			if ( Owner.IsA('PlayerPawn') )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash,InstFog);
			if ( Affector != None )
				Affector.FireEffect();
			Count -= 0.24;
			if ( !AmmoType.UseAmmo(1) )
				Finish();
		}
	}
	
	function EndState()
	{
		AmbientGlow = 0;
		AmbientSound = None;
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.Destroy();
			PlasmaBeam = None;
		}
		Super.EndState();
	}

Begin:
	AmbientGlow = 200;
	FinishAnim();	
	LoopAnim( 'boltloop');
}

state Idle
{
Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) ) 
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) AltFire(0.0);	

	Disable('AnimEnd');
	PlayIdleAnim();
}

///////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (AnimSequence == 'BoltLoop') || (AnimSequence == 'BoltStart') )
		PlayAnim('BoltEnd');		
	else if ( AnimSequence != 'SpinDown' )
		TweenAnim('Idle', 0.1);
}

simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		TweenAnim('Down', 0.26);
}


defaultproperties
{
	 InstFlash=-0.15
     InstFog=(X=139.00000,Y=218.00000,Z=72.00000)
     DownSound=Sound'Botpack.PulseGun.PulseDown'
     AmmoName=Class'Botpack.PAmmo'
     PickupAmmoCount=60
     bRapidFire=True
     FireOffset=(X=15.000000,Y=-15.000000,Z=2.000000)
     ProjectileClass=Class'Botpack.PlasmaSphere'
     AltProjectileClass=Class'Botpack.starterbolt'
     shakemag=135.000000
     shakevert=8.000000
     AIRating=0.700000
     RefireRate=0.950000
     AltRefireRate=0.990000
     FireSound=Sound'Botpack.PulseGun.PulseFire'
     AltFireSound=Sound'Botpack.PulseGun.PulseBolt'
     MessageNoAmmo=" has no Plasma."
     DeathMessage="%o ate %k's burning plasma death."
     FlashLength=0.020000
     AutoSwitchPriority=5
     InventoryGroup=5
     PickupMessage="You got a Pulse Gun"
     ItemName="Pulse Gun"
     PlayerViewOffset=(X=1.500000,Z=-2.000000)
     PlayerViewMesh=LodMesh'Botpack.PulseGunR'
     PickupViewMesh=LodMesh'Botpack.PulsePickup'
     ThirdPersonMesh=LodMesh'Botpack.PulseGun3rd'
     ThirdPersonScale=0.400000
     StatusIcon=Texture'Botpack.Icons.UsePulse'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzPF3'
     MuzzleFlashScale=0.40000
     MuzzleFlashTexture=Texture'Botpack.Skins.MuzzyPulse'
	 PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     SelectSound=Sound'Botpack.PulseGun.PulsePickup'
     Icon=Texture'Botpack.Icons.UsePulse'
     Mesh=LodMesh'Botpack.PulsePickup'
     bNoSmooth=False
     SoundRadius=64
     SoundVolume=255
	 CollisionRadius=32.0
	 WeaponDescription="Classification: Plasma Rifle\\n\\nPrimary Fire: Medium sized, fast moving plasma balls are fired at a fast rate of fire.\\n\\nSecondary Fire: A bolt of green lightning is expelled for 100 meters, which will shock all opponents.\\n\\nTechniques: Firing and keeping the secondary fire's lightning on an opponent will melt them in seconds."
	 NameColor=(R=128,G=255,B=128)
}
