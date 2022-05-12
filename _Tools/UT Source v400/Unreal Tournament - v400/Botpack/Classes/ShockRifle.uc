//=============================================================================
// ShockRifle.
//=============================================================================
class ShockRifle extends TournamentWeapon;

#exec MESH IMPORT MESH=ASMD2M ANIVFILE=MODELS\ASMD2_a.3D DATAFILE=MODELS\ASMD2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ASMD2M X=0 Y=0 Z=0 YAW=64 PITCH=0
#exec MESH SEQUENCE MESH=ASMD2M SEQ=All       STARTFRAME=0  NUMFRAMES=52
#exec MESH SEQUENCE MESH=ASMD2M SEQ=Select    STARTFRAME=0  NUMFRAMES=15 RATE=30 GROUP=Select
#exec MESH SEQUENCE MESH=ASMD2M SEQ=Still     STARTFRAME=15 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ASMD2M SEQ=Down      STARTFRAME=17 NUMFRAMES=7  RATE=27
#exec MESH SEQUENCE MESH=ASMD2M SEQ=Still2    STARTFRAME=28 NUMFRAMES=2
#exec MESH SEQUENCE MESH=ASMD2M SEQ=Fire1     STARTFRAME=30 NUMFRAMES=10  RATE=21
#exec MESH SEQUENCE MESH=ASMD2M SEQ=Fire2     STARTFRAME=40 NUMFRAMES=10  RATE=24
#exec TEXTURE IMPORT NAME=ASMD_t FILE=MODELS\ASMD.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=ASMD_t1 FILE=MODELS\ASMD1.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=ASMD_t2 FILE=MODELS\ASMD2.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=ASMD_t3 FILE=MODELS\ASMD3.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=ASMD_t4 FILE=MODELS\ASMD4.PCX GROUP="Skins" LODSET=2
#exec MESHMAP SCALE MESHMAP=ASMD2M X=0.004 Y=0.003 Z=0.008
#exec MESHMAP SETTEXTURE MESHMAP=ASMD2M NUM=0 TEXTURE=ASMD_t1
#exec MESHMAP SETTEXTURE MESHMAP=ASMD2M NUM=1 TEXTURE=ASMD_t2
#exec MESHMAP SETTEXTURE MESHMAP=ASMD2M NUM=2 TEXTURE=ASMD_t3
#exec MESHMAP SETTEXTURE MESHMAP=ASMD2M NUM=3 TEXTURE=ASMD_t4

#exec MESH IMPORT MESH=ASMD2pick ANIVFILE=MODELS\ASMDpick_a.3D DATAFILE=MODELS\ASMDpick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ASMD2pick X=0 Y=0 Z=0 YAW=64 
#exec MESH SEQUENCE MESH=ASMD2pick SEQ=All   STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=ASMD2pick SEQ=Still STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=ASMD2pick X=0.07 Y=0.07 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=ASMD2pick NUM=1 TEXTURE=ASMD_t

#exec MESH IMPORT MESH=ASMD2hand ANIVFILE=MODELS\ASMDhand_a.3D DATAFILE=MODELS\asmdhand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ASMD2hand X=25 Y=600 Z=-40 YAW=64 PITCH=0
#exec MESH SEQUENCE MESH=ASMD2hand SEQ=All   STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=ASMD2hand SEQ=Still STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=ASMD2hand SEQ=Fire1 STARTFRAME=1  NUMFRAMES=9  RATE=24
#exec MESH SEQUENCE MESH=ASMD2hand SEQ=Fire2 STARTFRAME=1  NUMFRAMES=9  RATE=24
#exec MESHMAP SCALE MESHMAP=ASMD2hand X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=ASMD2hand NUM=1 TEXTURE=ASMD_t

#exec TEXTURE IMPORT NAME=IconASMD FILE=TEXTURES\HUD\WpnASMD.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseASMD FILE=TEXTURES\HUD\UseASMD.PCX GROUP="Icons" MIPS=OFF

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Tazer\TSHOTA6.WAV" NAME="TazerFire" GROUP="ASMD"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Tazer\TSHOTB1.WAV" NAME="TazerAltFire" GROUP="ASMD"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Tazer\TPICKUP3.WAV" NAME="TazerSelect" GROUP="ASMD"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Tazer\Vapour1.WAV" NAME="Vapour" GROUP="ASMD"

var() int HitDamage;
var Projectile Tracked;
var bool bBotSpecialMove;
var float TapTime;

function AltFire( float Value )
{
	local actor HitActor;
	local vector HitLocation, HitNormal, Start; 

	if ( Owner == None )
		return;

	if ( Owner.IsA('Bot') ) //make sure won't blow self up
	{
		Start = Owner.Location + CalcDrawOffset() + FireOffset.Z * vect(0,0,1); 
		if ( Pawn(Owner).Enemy != None )
			HitActor = Trace(HitLocation, HitNormal, Start + 250 * Normal(Pawn(Owner).Enemy.Location - Start), Start, false, vect(12,12,12));
		else
			HitActor = self;
		if ( HitActor != None )
		{
			Global.Fire(Value);
			return;
		}
	}	
	if ( AmmoType.UseAmmo(1) )
	{
		GotoState('AltFiring');
		bCanClientFire = true;
		if ( Owner.IsA('Bot') )
		{
			if ( Owner.IsInState('TacticalMove') && (Owner.Target == Pawn(Owner).Enemy)
			 && (Owner.Physics == PHYS_Walking) && !Bot(Owner).bNovice
			 && (FRand() * 6 < Pawn(Owner).Skill) )
				Pawn(Owner).SpecialFire();
		}
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bPointing=True;
		ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
		ClientAltFire(value);
	}
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z; 
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000 ;

	if ( bBotSpecialMove && (Tracked != None)
		&& (((Owner.Acceleration == vect(0,0,0)) && (VSize(Owner.Velocity) < 40)) ||
			(Normal(Owner.Velocity) Dot Normal(Tracked.Velocity) > 0.95)) )
		EndTrace += 10000 * Normal(Tracked.Location - StartTrace);
	else
	{
		AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);	
		EndTrace += (10000 * vector(AdjustedAim)); 
	}

	Tracked = None;
	bBotSpecialMove = false;

	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
}

function float RateSelf( out int bUseAltMode )
{
	local Pawn P;
	local bool bNovice;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	P = Pawn(Owner);
	bNovice = ( (Bot(Owner) == None) || Bot(Owner).bNovice );
	if ( P.Enemy == None )
		bUseAltMode = 0;
	else if ( P.Enemy.IsA('StationaryPawn') )
	{
		bUseAltMode = 1;
		return (AIRating + 0.4);
	}
	else if ( !bNovice && (P.IsInState('Hunting') || P.IsInState('StakeOut')
		|| P.IsInState('RangedAttack')
		|| (Level.TimeSeconds - P.LastSeenTime > 0.8)) )
	{
		bUseAltMode = 1;
		return (AIRating + 0.3);
	}
	else if ( !bNovice && (P.Acceleration == vect(0,0,0)) )
		bUseAltMode = 1;
	else if ( !bNovice && (VSize(P.Enemy.Location - P.Location) > 1200) )
	{
		bUseAltMode = 0;
		return (AIRating + 0.05 + FMin(0.00009 * VSize(P.Enemy.Location - P.Location), 0.3)); 
	}
	else if ( P.Enemy.Location.Z > P.Location.Z + 200 )
	{
		bUseAltMode = int( FRand() < 0.6 );
		return (AIRating + 0.15);
	} 
	else
		bUseAltMode = int( FRand() < 0.4 );

	return AIRating;
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
	FireDir = vector(P.ViewRotation);
	targ = P.PickTarget(bestAim, bestDist, FireDir, Owner.Location);
	if ( Pawn(targ) != None )
	{
		bPointing = true;
		Pawn(targ).WarnTarget(P, 300, FireDir);
		SetTimer(1 + 4 * FRand(), false);
	}
	else 
	{
		SetTimer(0.5 + 2 * FRand(), false);
		if ( (P.bFire == 0) && (P.bAltFire == 0) )
			bPointing = false;
	}
}	

function Finish()
{
	if ( (Pawn(Owner).bFire!=0) && (FRand() < 0.6) )
		Timer();
	if ( !bChangeWeapon && (Tracked != None) && !Tracked.bDeleteMe && (Owner != None) 
		&& (Owner.IsA('Bot')) && (Pawn(Owner).Enemy != None) && (FRand() < 0.3 + 0.35 * Pawn(Owner).skill)
		&& (AmmoType.AmmoAmount > 0) ) 
	{
		if ( (Owner.Acceleration == vect(0,0,0)) ||
			(Abs(Normal(Owner.Velocity) dot Normal(Tracked.Velocity)) > 0.95) )
		{
			bBotSpecialMove = true;
			GotoState('ComboMove');
			return;
		}
	}

	bBotSpecialMove = false;
	Tracked = None;
	Super.Finish();
}

///////////////////////////////////////////////////////
simulated function PlayFiring()
{
	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.30 + 0.30 * FireAdjust,0.05);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;
	local PlayerPawn PlayerOwner;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);	

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
	Tracked = Spawn(ProjClass,,, Start,AdjustedAim);
	if ( Level.Game.IsA('DeathMatchPlus') && DeathmatchPlus(Level.Game).bNoviceMode )
		Tracked = None; //no combo move
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int i;
	local PlayerPawn PlayerOwner;

	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
	SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);

	if ( ShockProj(Other)!=None )
	{ 
		AmmoType.UseAmmo(2);
		ShockProj(Other).SuperExplosion();
	}
	else
		Spawn(class'ut_RingExplosion5',,, HitLocation+HitNormal*8,rotator(HitNormal));

	if ( (Other != self) && (Other != Owner) && (Other != None) ) 
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType);
}


function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local ShockBeam Smoke,shock;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);
	
	Smoke = Spawn(class'ShockBeam',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;	
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(AltFireSound, SLOT_None,Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire2',0.4 + 0.4 * FireAdjust,0.05);
}


simulated function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		LoopAnim('Still',0.04,0.3);
}

state Idle
{

	function BeginState()
	{
		bPointing = false;
		SetTimer(0.5 + 2 * FRand(), false);
		Super.BeginState();
		if (Pawn(Owner).bFire!=0) Fire(0.0);
		if (Pawn(Owner).bAltFire!=0) AltFire(0.0);		
	}

	function EndState()
	{
		SetTimer(0.0, false);
		Super.EndState();
	}
}

state ComboMove
{
	function Fire(float F); 
	function AltFire(float F); 

	function Tick(float DeltaTime)
	{
		if ( (Owner == None) || (Pawn(Owner).Enemy == None) )
		{
			Tracked = None;
			bBotSpecialMove = false;
			Finish();
			return;
		}
		if ( (Tracked == None) || Tracked.bDeleteMe 
			|| (((Tracked.Location - Owner.Location) 
				dot (Tracked.Location - Pawn(Owner).Enemy.Location)) >= 0)
			|| (VSize(Tracked.Location - Pawn(Owner).Enemy.Location) < 100) )
			Global.Fire(0);
	}

Begin:
	Sleep(7.0);
	Tracked = None;
	bBotSpecialMove = false;
	Global.Fire(0);
}

state ClientFiring
{
	simulated function bool ClientFire(float Value)
	{
		if ( Level.TimeSeconds - TapTime < 0.2 )
			return false;
		bForceFire = bForceFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		if ( Level.TimeSeconds - TapTime < 0.2 )
			return false;
		bForceAltFire = bForceAltFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceAltFire;
	}

	simulated function AnimEnd()
	{
		local bool bForce, bForceAlt;

		bForce = bForceFire;
		bForceAlt = bForceAltFire;
		bForceFire = false;
		bForceAltFire = false;

		if ( bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0) )
		{
			if ( bForce || (Pawn(Owner).bFire != 0) )
			{
				Global.ClientFire(0);
				return;
			}
			else if ( bForceAlt || (Pawn(Owner).bAltFire != 0) )
			{
				Global.ClientAltFire(0);
				return;
			}
		}			
		Super.AnimEnd();
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}

	simulated function BeginState()
	{
		TapTime = Level.TimeSeconds;
		bForceFire = false;
		bForceAltFire = false;
	}
}

defaultproperties
{
	 InstFlash=-0.4
     InstFog=(X=0.00000,Y=0.00000,Z=800.00000)
	 MyDamageType=Jolted
     hitdamage=40
     AmmoName=Class'Botpack.ShockCore'
     PickupAmmoCount=20
     bInstantHit=True
     bAltWarnTarget=True
     bSplashDamage=True
     FireOffset=(X=10.000000,Y=-5.000000,Z=-8.000000)
     AltProjectileClass=Class'Botpack.ShockProj'
     AIRating=0.630000
     AltRefireRate=0.700000
	 FiringSpeed=2.0
     FireSound=Sound'UnrealShare.ASMD.TazerFire'
     AltFireSound=Sound'UnrealShare.ASMD.TazerAltFire'
     SelectSound=Sound'UnrealShare.ASMD.TazerSelect'
     DeathMessage="%k inflicted mortal damage upon %o with the %w."
     AutoSwitchPriority=4
     InventoryGroup=4
     PickupMessage="You got the ASMD Shock Rifle."
     ItemName="Shock Rifle"
     PlayerViewOffset=(X=4.400000,Y=-1.700000,Z=-1.600000)
     PlayerViewScale=2.000000
     PlayerViewMesh=Mesh'Botpack.ASMD2M'
     BobDamping=0.975000
     PickupViewMesh=Mesh'Botpack.ASMD2pick'
     ThirdPersonMesh=Mesh'Botpack.ASMD2hand'
     StatusIcon=Texture'Botpack.Icons.UseASMD'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseASMD'
     Mesh=Mesh'Botpack.ASMD2pick'
     bNoSmooth=False
     bMeshCurvy=False
     CollisionRadius=34.000000
     CollisionHeight=8.000000
     Mass=50.000000
	 WeaponDescription="Classification: Energy Rifle\\n\\nPrimary Fire: Instant hit laser beam.\\n\\nSecondary Fire: Large, slow moving plasma balls.\\n\\nTechniques: Hitting the secondary fire plasma balls with the regular fire's laser beam will cause an immensely powerful explosion."
	 NameColor=(R=128,G=0,B=255)
}
