//=============================================================================
// ImpactHammer.
//=============================================================================
class ImpactHammer extends TournamentWeapon;

#exec MESH IMPORT  MESH=ImpactHammer ANIVFILE=MODELS\impact_a.3D DATAFILE=MODELS\impact_d.3D X=0 Y=0 Z=0 
#exec MESH ORIGIN MESH=ImpactHammer X=0 Y=0 Z=0 YAW=64 PITCH=0 ROLL=-56
#exec MESH SEQUENCE MESH=ImpactHammer SEQ=All         STARTFRAME=0   NUMFRAMES=56
#exec MESH SEQUENCE MESH=ImpactHammer SEQ=Select      STARTFRAME=0   NUMFRAMES=17
#exec MESH SEQUENCE MESH=ImpactHammer SEQ=Still       STARTFRAME=17  NUMFRAMES=1
#exec MESH SEQUENCE MESH=ImpactHammer SEQ=Pull        STARTFRAME=17  NUMFRAMES=5
#exec MESH SEQUENCE MESH=ImpactHammer SEQ=Shake       STARTFRAME=22  NUMFRAMES=10
#exec MESH SEQUENCE MESH=ImpactHammer SEQ=Fire        STARTFRAME=35  NUMFRAMES=16
#exec MESH SEQUENCE MESH=ImpactHammer SEQ=Down        STARTFRAME=51  NUMFRAMES=5
#exec TEXTURE IMPORT NAME=JImpactHammer1 FILE=MODELS\imp1.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JImpactHammer2 FILE=MODELS\imp2.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JImpactHammer3 FILE=MODELS\imp3.pCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JImpactHammer4 FILE=MODELS\imp4.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=ImpactHammer X=0.006 Y=0.006 Z=0.007
#exec MESHMAP SETTEXTURE MESHMAP=ImpactHammer NUM=0 TEXTURE=JImpactHammer1
#exec MESHMAP SETTEXTURE MESHMAP=ImpactHammer NUM=1 TEXTURE=JImpactHammer2
#exec MESHMAP SETTEXTURE MESHMAP=ImpactHammer NUM=2 TEXTURE=JImpactHammer3
#exec MESHMAP SETTEXTURE MESHMAP=ImpactHammer NUM=3 TEXTURE=JImpactHammer4

#exec MESH IMPORT MESH=ImpPick ANIVFILE=MODELS\imppick_a.3D DATAFILE=MODELS\imppick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ImpPick X=0 Y=0 Z=0 YAW=0 ROLL=-64
#exec MESH SEQUENCE MESH=ImpPick SEQ=All         STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=ImpPick SEQ=Still       STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JImpPick1 FILE=MODELS\imp0.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=ImpPick X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=ImpPick NUM=1 TEXTURE=JImpPick1

#exec MESH IMPORT MESH=ImpactHandm ANIVFILE=MODELS\impacthand_a.3D DATAFILE=MODELS\impacthand_d.3D
#exec MESH ORIGIN MESH=ImpactHandm X=30 Y=-130 Z=-157 YAW=64 ROLL=-64 
#exec MESH SEQUENCE MESH=ImpactHandm SEQ=All  STARTFRAME=0   NUMFRAMES=13
#exec MESH SEQUENCE MESH=ImpactHandm SEQ=Pull  STARTFRAME=1   NUMFRAMES=10 
#exec MESH SEQUENCE MESH=ImpactHandm SEQ=Shake STARTFRAME=12   NUMFRAMES=1 
#exec MESH SEQUENCE MESH=ImpactHandm SEQ=Still STARTFRAME=0   NUMFRAMES=1 
#exec MESHMAP SCALE MESHMAP=ImpactHandm X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=ImpactHandm NUM=1 TEXTURE=JImpPick1

#exec TEXTURE IMPORT NAME=IconHammer FILE=TEXTURES\HUD\WpnMpact.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseHammer FILE=TEXTURES\HUD\UseMpact.PCX GROUP="Icons" MIPS=OFF

#exec AUDIO IMPORT FILE="Sounds\ImpactHammer\impact-regularfire.WAV" NAME="ImpactFire" GROUP="ASMD"
#exec AUDIO IMPORT FILE="Sounds\ImpactHammer\impact-altfireSTART.WAV" NAME="ImpactAltFireStart" GROUP="ASMD"
#exec AUDIO IMPORT FILE="Sounds\ImpactHammer\impact-altfireRELEASE.WAV" NAME="ImpactAltFireRelease" GROUP="ASMD"
#exec AUDIO IMPORT FILE="Sounds\ImpactHammer\impacthammerloop.WAV" NAME="ImpactLoop" GROUP="ASMD"
#exec AUDIO IMPORT FILE="Sounds\ImpactHammer\impactpickup.WAV" NAME="ImpactPickup" GROUP="ASMD"

var float ChargeSize, Count;
var() sound AltFireSound;
var() sound TensionSound;


function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local Pawn P;

	bUseAltMode = 0;
	P = Pawn(Owner);

	if ( (P == None) || (P.Enemy == None) )
		return 0;

	EnemyDist = VSize(P.Enemy.Location - Owner.Location);
	if ( (EnemyDist < 750) && P.IsA('Bot') && Bot(P).bNovice && (P.Skill <= 2) && !P.Enemy.IsA('Bot') && (ImpactHammer(P.Enemy.Weapon) != None) )
		return FClamp(300/(EnemyDist + 1), 0.6, 0.75);

	if ( EnemyDist > 400 )
		return 0.1;
	if ( (P.Weapon != self) && (EnemyDist < 120) )
		return 0.25;

	return ( FMin(0.8, 81/(EnemyDist + 1)) );
}

function float SuggestAttackStyle()
{
	return 10.0;
}

function float SuggestDefenseStyle()
{
	return -2.0;
}

simulated function PlayPostSelect()
{
	local Bot B;

	if ( Level.NetMode == NM_Client )
	{
		Super.PlayPostSelect();
		return;
	}

	B = Bot(Owner);

	if ( (B != None) && (B.Enemy != None) )
	{
		B.PlayFiring();
		B.bFire = 1;
		B.bAltFire = 0;
		Fire(1.0);
	}
}

simulated function bool ClientFire( float Value )
{
	if ( bCanClientFire )
	{
		if ( (PlayerPawn(Owner) != None) 
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			if ( InstFlash != 0.0 )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		if ( Affector != None )
			Affector.FireEffect();
		Owner.PlayOwnedSound(Misc1Sound, SLOT_Misc, 1.3*Pawn(Owner).SoundDampening);
		PlayAnim('Pull', 0.2, 0.05);
		if ( Role < ROLE_Authority )
			GotoState('ClientFiring');
		return true;
	}
	return false;
}		

function Fire( float Value )
{
	bPointing=True;
	bCanClientFire = true;
	ClientFire(Value);
	Pawn(Owner).PlayRecoil(FiringSpeed);
	GoToState('Firing');
}

function AltFire( float Value )
{
	bPointing=True;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);
	TraceAltFire();
	ClientAltFire(value);
	GoToState('AltFiring');
}

simulated function ClientWeaponEvent(name EventType)
{
	if ( EventType == 'FireBlast' )
	{
		PlayFiring();
		GotoState('ClientFireBlast');
	}
}

simulated function PlayFiring()
{
	if (Owner != None)
	{
		if ( Affector != None )
			Affector.FireEffect();
		Owner.PlayOwnedSound(FireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening,,,);
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		PlayAnim( 'Fire', 0.65 );
	}
}

simulated function PlayAltFiring()
{
	if (Owner != None)
	{
		if ( Affector != None )
			Affector.FireEffect();
		PlayOwnedSound(AltFireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening,,,);
		LoopAnim( 'Fire', 0.65);
	}
}

state Firing
{
	function AltFire(float F) 
	{
	}

	function Tick( float DeltaTime )
	{
		local Pawn P;
		local Rotator EnemyRot;
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
		local actor HitActor;

		if ( bChangeWeapon )
			GotoState('DownWeapon');

		if (  Bot(Owner) != None )
		{
			if ( Bot(Owner).Enemy == None )
				Bot(Owner).bFire = 0;
			else
				Bot(Owner).bFire = 1;
		}
		P = Pawn(Owner);
		if ( P == None ) 
		{
			AmbientSound = None;
			GotoState('');
			return;
		}
		else if( P.bFire==0 ) 
		{
			TraceFire(0);
			PlayFiring();
			GoToState('FireBlast');
			return;
		}

		ChargeSize += 0.75 * DeltaTime;

		Count += DeltaTime;
		if ( Count > 0.2 )
		{
			Count = 0;
			Owner.MakeNoise(1.0);
		}
		if (ChargeSize > 1) 
		{
			if ( !P.IsA('PlayerPawn') && (P.Enemy != None) )
			{
				EnemyRot = Rotator(P.Enemy.Location - P.Location);
				EnemyRot.Yaw = EnemyRot.Yaw & 65535;
				if ( (abs(EnemyRot.Yaw - (P.Rotation.Yaw & 65535)) > 8000)
					&& (abs(EnemyRot.Yaw - (P.Rotation.Yaw & 65535)) < 57535) )
					return;
				GetAxes(EnemyRot,X,Y,Z);
			}
			else
				GetAxes(P.ViewRotation, X, Y, Z);
			StartTrace = P.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
			if ( (Level.NetMode == NM_Standalone) && P.IsA('PlayerPawn') )
				EndTrace = StartTrace + 25 * X; 
			else
				EndTrace = StartTrace + 60 * X; 
			HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
			if ( (HitActor != None) && (HitActor.DrawType == DT_Mesh) )
			{
				ProcessTraceHit(HitActor, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
				PlayFiring();
				GoToState('FireBlast');
			}
		}
	}

	function BeginState()
	{
		ChargeSize = 0.0;
		Count = 0.0;
	}

	function EndState()
	{
		Super.EndState();
		AmbientSound = None;
	}

Begin:
	FinishAnim();
	AmbientSound = TensionSound;
	SoundVolume = 255*Pawn(Owner).SoundDampening;		
	LoopAnim('Shake', 0.9);
}

state ClientFiring
{
	simulated function AnimEnd()
	{
		AmbientSound = TensionSound;
		SoundVolume = 255*Pawn(Owner).SoundDampening;		
		LoopAnim('Shake', 0.9);
		Disable('AnimEnd');
	}
}

state FireBlast
{
	function Fire(float F) 
	{
	}
	function AltFire(float F) 
	{
	}

Begin:
	if ( (Level.NetMode != NM_Standalone) && Owner.IsA('PlayerPawn') 
		&& (ViewPort(PlayerPawn(Owner).Player) == None) )
		PlayerPawn(Owner).ClientWeaponEvent('FireBlast');
	FinishAnim();
	Finish();
}

state ClientFireBlast
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function AnimEnd()
	{
		if ( Pawn(Owner) == None )
		{
			PlayIdleAnim();
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
			PlayIdleAnim();
			GotoState('');
		}
	}
}

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z; 
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, AimError, False, False);	
	EndTrace = StartTrace + 120.0 * vector(AdjustedAim); 
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	if ( (Other == None) || (Other == Owner) || (Other == self) || (Owner == None))
		return;

	ChargeSize = FMin(ChargeSize, 1.5);
	if ( (Other == Level) || Other.IsA('Mover') )
	{
		ChargeSize = FMax(ChargeSize, 1.0);
		if ( VSize(HitLocation - Owner.Location) < 80 )
			Spawn(class'ImpactMark',,, HitLocation+HitNormal, Rotator(HitNormal));
		Owner.TakeDamage(36.0, Pawn(Owner), HitLocation, -69000.0 * ChargeSize * X, MyDamageType);
	}
	if ( Other != Level )
	{
		if ( Other.bIsPawn && (VSize(HitLocation - Owner.Location) > 90) )
			return;
		Other.TakeDamage(60.0 * ChargeSize, Pawn(Owner), HitLocation, 66000.0 * ChargeSize * X, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
}

function TraceAltFire()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;
	local Projectile P;
	local float speed;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, AimError, False, False);	
	EndTrace = StartTrace + 180 * vector(AdjustedAim); 
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	ProcessAltTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);

	// push aside projectiles
	ForEach VisibleCollidingActors(class'Projectile', P, 550, Owner.Location)
		if ( ((P.Physics == PHYS_Projectile) || (P.Physics == PHYS_Falling))
			&& (Normal(P.Location - Owner.Location) Dot X) > 0.9 )
		{
			P.speed = VSize(P.Velocity);
			if ( P.Velocity Dot Y > 0 )
				P.Velocity = P.Speed * Normal(P.Velocity + (750 - VSize(P.Location - Owner.Location)) * Y);
			else	
				P.Velocity = P.Speed * Normal(P.Velocity - (750 - VSize(P.Location - Owner.Location)) * Y);
		}
}

function ProcessAltTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector realLoc;
	local float scale;

	if ( (Other == None) || (Other == Owner) || (Other == self) || (Owner == None) )
		return;

	realLoc = Owner.Location + CalcDrawOffset();
	scale = VSize(realLoc - HitLocation)/180;
	if ( (Other == Level) || Other.IsA('Mover') )
	{
		Owner.TakeDamage(24.0 * scale, Pawn(Owner), HitLocation, -40000.0 * X * scale, MyDamageType);
	}
	else
	{
		Other.TakeDamage(20 * scale, Pawn(Owner), HitLocation, 30000.0 * X * scale, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
}

simulated function PlayIdleAnim()
{
	local Bot B;

	B = Bot(Owner);

	if ( (B != None) && (B.Enemy != None) )
	{
		B.PlayFiring();
		B.bFire = 1;
		B.bAltFire = 0;
		Fire(1.0);
	}
	else if ( Mesh != PickupViewMesh )
		TweenAnim( 'Still', 1.0);
}

defaultproperties
{
	 InstFlash=0.0
     InstFog=(X=475.00000,Y=325.00000,Z=145.00000)
	 MyDamageType=Impact
     InventoryGroup=1
     AltFireSound=Sound'Botpack.ImpactFire'
     TensionSound=Sound'Botpack.ImpactLoop'
     bMeleeWeapon=True
	 bRapidFire=true
     RefireRate=1.000000
     AltRefireRate=1.000000
     FireSound=Sound'Botpack.ImpactAltFireRelease'
     Misc1Sound=Sound'Botpack.ImpactAltFireStart'
     DeathMessage="%o got smeared by %k's piston."
     PickupMessage="You got the Impact Hammer."
     ItemName="Impact Hammer"
     PlayerViewOffset=(X=3.800000,Y=-1.600000,Z=-1.800000)
     PlayerViewMesh=Mesh'Botpack.ImpactHammer'
     PickupViewMesh=Mesh'Botpack.ImpPick'
     Mesh=Mesh'Botpack.ImpPick'
     ThirdPersonMesh=Mesh'Botpack.ImpactHandm'
     StatusIcon=Texture'Botpack.Icons.UseHammer'
	 PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'     
	 SelectSound=Sound'Botpack.ImpactPickup'
     Icon=Texture'Botpack.Icons.UseHammer'
     bMeshCurvy=False
	 bNoSmooth=False
	 SoundRadius=50
	 SoundVolume=200
     WeaponDescription="Classification: Melee Piston\\n\\nPrimary Fire: When trigger is held down, touch opponents with this piston to inflict massive damage.\\n\\nSecondary Fire: Damages opponents at close range and has the ability to deflect projectiles.\\n\\nTechniques: Shoot at the ground while jumping to jump extra high."
	 NameColor=(R=255,G=192,B=0)
}
