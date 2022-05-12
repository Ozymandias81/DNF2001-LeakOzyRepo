//=============================================================================
// UT_BioRifle.
//=============================================================================
class UT_BioRifle extends TournamentWeapon;

#exec MESH IMPORT MESH=BRifle2 ANIVFILE=MODELS\Biorifle2_a.3D DATAFILE=MODELS\BioRifle2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BRifle2 X=0 Y=0 Z=0 YAW=67 ROLL=6 PITCH=0
#exec MESH SEQUENCE MESH=BRifle2 SEQ=All       STARTFRAME=0   NUMFRAMES=90
#exec MESH SEQUENCE MESH=BRifle2 SEQ=Select    STARTFRAME=0   NUMFRAMES=22 RATE=45 GROUP=Select
#exec MESH SEQUENCE MESH=BRifle2 SEQ=Still     STARTFRAME=22  NUMFRAMES=1
#exec MESH SEQUENCE MESH=BRifle2 SEQ=Walking   STARTFRAME=23  NUMFRAMES=18
#exec MESH SEQUENCE MESH=BRifle2 SEQ=Charging  STARTFRAME=41  NUMFRAMES=30
#exec MESH SEQUENCE MESH=BRifle2 SEQ=Loaded    STARTFRAME=70  NUMFRAMES=1
#exec MESH SEQUENCE MESH=BRifle2 SEQ=UnLoading STARTFRAME=71  NUMFRAMES=1
#exec MESH SEQUENCE MESH=BRifle2 SEQ=Fire      STARTFRAME=72  NUMFRAMES=9
#exec MESH SEQUENCE MESH=BRifle2 SEQ=Down      STARTFRAME=80  NUMFRAMES=10
#exec TEXTURE IMPORT NAME=JBRifle2 FILE=MODELS\Bio.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JBRifle21 FILE=MODELS\Bio1.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JBRifle22 FILE=MODELS\Bio2.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JBRifle23 FILE=MODELS\Bio3.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JBRifle24 FILE=MODELS\Bio4.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=BRifle2  X=0.0025 Y=0.0018 Z=0.005
#exec MESHMAP SETTEXTURE MESHMAP=BRifle2 NUM=0 TEXTURE=JBRifle21
#exec MESHMAP SETTEXTURE MESHMAP=BRifle2 NUM=1 TEXTURE=JBRifle22
#exec MESHMAP SETTEXTURE MESHMAP=BRifle2 NUM=2 TEXTURE=JBRifle23
#exec MESHMAP SETTEXTURE MESHMAP=BRifle2 NUM=3 TEXTURE=JBRifle24

#exec MESH IMPORT MESH=BRifle2Pick ANIVFILE=MODELS\Biopick_a.3D DATAFILE=MODELS\Biopick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BRifle2Pick X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=BRifle2pick SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BRifle2pick SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=BRifle2pick X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=BRifle2pick NUM=1 TEXTURE=JBRifle2

#exec MESH IMPORT MESH=BRifle23 ANIVFILE=MODELS\Biohand_a.3D DATAFILE=MODELS\Biohand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BRifle23 X=15 Y=280 Z=-80 YAW=64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=BRifle23 SEQ=All  STARTFRAME=0  NUMFRAMES=11
#exec MESH SEQUENCE MESH=BRifle23 SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=BRifle23 SEQ=Fire  STARTFRAME=1  NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=BRifle23 X=0.035 Y=0.035 Z=0.07
#exec MESHMAP SETTEXTURE MESHMAP=BRifle23 NUM=1 TEXTURE=JBRifle2

#exec TEXTURE IMPORT NAME=IconBio FILE=TEXTURES\HUD\WpnBio.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseBio FILE=TEXTURES\HUD\UseBio.PCX GROUP="Icons" MIPS=OFF

#exec AUDIO IMPORT FILE="Sounds\biorifle\biopowerupmix1.WAV" NAME="BioAltRep" GROUP="BioRifle"

var float ChargeSize, Count;
var bool bBurst;

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if ( (Owner != None) && (VSize(Owner.Velocity) > 10) )
		PlayAnim('Walking',0.3,0.3);
	else 
		TweenAnim('Still', 1.0);
	Enable('AnimEnd');
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local vector EnemyDir;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	bUseAltMode = 0;
	if ( Pawn(Owner).Enemy == None )
		return AIRating;

	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	if ( EnemyDist > 1400 )
		return 0;

	bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.6 );
	if ( (EnemyDist > 600) && (EnemyDir.Z > -0.4 * EnemyDist) )
	{
		// only use if enemy not too far and retreating
		if ( !bRetreating )
			return 0;

		return AIRating;
	}

	bUseAltMode = int( FRand() < 0.3 );

	if ( bRetreating || (EnemyDir.Z < -0.7 * EnemyDist) )
		return (AIRating + 0.18);
	return AIRating;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	return -0.3;
}

function float SuggestDefenseStyle()
{
	return -0.4;
}

function AltFire( float Value )
{
	bPointing=True;
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) ) 
	{
		GoToState('AltFiring');
		bCanClientFire = true;
		ClientAltFire(Value);
	}
}

simulated function bool ClientAltFire( float Value )
{
	local bool bResult;

	InstFlash = 0.0;
	bResult = Super.ClientAltFire(value);
	InstFlash = Default.InstFlash;
	return bResult;
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
	AdjustedAim = pawn(owner).AdjustToss(ProjSpeed, Start, 0, True, (bWarn || (FRand() < 0.4)));	
	return Spawn(ProjClass,,, Start,AdjustedAim);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(Sound'Botpack.BioRifle.BioAltRep', SLOT_Misc, 1.3*Pawn(Owner).SoundDampening);	 //loading goop	
	PlayAnim('Charging',0.24,0.05);
}

///////////////////////////////////////////////////////
state ClientAltFiring
{
	simulated function Tick(float DeltaTime)
	{
		if ( bBurst )
			return;
		if ( !bCanClientFire || (Pawn(Owner) == None) )
			GotoState('');
		else if ( Pawn(Owner).bAltFire == 0 )
		{
			PlayAltBurst();
			bBurst = true;
		}
	}

	simulated function AnimEnd()
	{
		if ( bBurst )
		{
			bBurst = false;
			Super.AnimEnd();
		}
		else
			TweenAnim('Loaded', 0.5);
	}
}

state AltFiring
{
	ignores AnimEnd;

	function Tick( float DeltaTime )
	{
		//SetLocation(Owner.Location);
		if ( ChargeSize < 4.1 )
		{
			Count += DeltaTime;
			if ( (Count > 0.5) && AmmoType.UseAmmo(1) )
			{
				ChargeSize += Count;
				Count = 0;
				if ( (PlayerPawn(Owner) == None) && (FRand() < 0.2) )
					GoToState('ShootLoad');
			}
		}
		if( (pawn(Owner).bAltFire==0) ) 
			GoToState('ShootLoad');
	}

	function BeginState()
	{
		ChargeSize = 0.0;
		Count = 0.0;
	}

	function EndState()
	{
		ChargeSize = FMin(ChargeSize, 4.1);
	}

Begin:
	FinishAnim();
}

state ShootLoad
{
	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function Fire(float F) 
	{
	}

	function AltFire(float F) 
	{
	}

	function Timer()
	{
		local rotator R;
		local vector start, X,Y,Z;

		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		R = Owner.Rotation;
		R.Yaw = R.Yaw + Rand(8000) - 4000;
		R.Pitch = R.Pitch + Rand(1000) - 500;
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
		Spawn(AltProjectileClass,,, Start,R);

		R = Owner.Rotation;
		R.Yaw = R.Yaw + Rand(8000) - 4000;
		R.Pitch = R.Pitch + Rand(1000) - 500;
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
		Spawn(AltProjectileClass,,, Start,R);
	}

	function AnimEnd()
	{
		Finish();
	}

	function BeginState()
	{
		Local Projectile Gel;

		Gel = ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
		Gel.DrawScale = 1.0 + 0.8 * ChargeSize;
		PlayAltBurst();
	}

Begin:
}


// Finish a firing sequence
function Finish()
{
	local bool bForce, bForceAlt;

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( PlayerPawn(Owner) == None )
	{
		Pawn(Owner).bAltFire = 0;
		Super.Finish();
	}
	else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
		GotoState('Idle');
	else if ( (Pawn(Owner).bFire!=0) || bForce )
		Global.Fire(0);
	else if ( (Pawn(Owner).bAltFire!=0) || bForceAlt )
		Global.AltFire(0);
	else 
		GotoState('Idle');
}

simulated function PlayAltBurst()
{
	if ( Owner.IsA('PlayerPawn') )
		PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
	PlayOwnedSound(FireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening);	//shoot goop
	PlayAnim('Fire',0.4, 0.05);
}

simulated function PlayFiring()
{
	PlayOwnedSound(AltFireSound, SLOT_None, 1.7*Pawn(Owner).SoundDampening);	//fast fire goop
	LoopAnim('Fire',0.65 + 0.4 * FireAdjust, 0.05);
}

defaultproperties
{
	 InstFlash=-0.15
     InstFog=(X=139.00000,Y=218.00000,Z=72.00000)
     AmmoName=Class'Botpack.bioammo'
     PickupAmmoCount=25
     bAltWarnTarget=True
     bRapidFire=True
     FiringSpeed=1.000000
     FireOffset=(X=12.000000,Y=-11.000000,Z=-6.000000)
     ProjectileClass=Class'Botpack.ut_biogel'
     AltProjectileClass=Class'Botpack.BioGlob'
     AIRating=0.600000
     RefireRate=0.900000
     AltRefireRate=0.700000
     FireSound=Sound'UnrealI.BioRifle.GelShot'
     AltFireSound=Sound'UnrealI.BioRifle.GelShot'
     CockingSound=Sound'UnrealI.BioRifle.GelLoad'
     SelectSound=Sound'UnrealI.BioRifle.GelSelect'
     DeathMessage="%o drank a glass of %k's dripping green load."
     AutoSwitchPriority=3
     InventoryGroup=3
     PickupMessage="You got the GES BioRifle."
     ItemName="GES Bio Rifle"
     PlayerViewOffset=(X=1.700000,Y=-0.850000,Z=-0.950000)
     PlayerViewMesh=Mesh'Botpack.BRifle2'
     BobDamping=0.972000
     PickupViewMesh=Mesh'Botpack.BRifle2Pick'
     ThirdPersonMesh=Mesh'Botpack.BRifle23'
     StatusIcon=Texture'Botpack.Icons.UseBio'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseBio'
     Mesh=Mesh'Botpack.BRifle2Pick'
     bNoSmooth=False
     CollisionRadius=30.000000
     CollisionHeight=19.000000
	 WeaponDescription="Classification: Toxic Rifle\\n\\nPrimary Fire: Wads of Tarydium byproduct are lobbed at a medium rate of fire.\\n\\nSecondary Fire: When trigger is held down, the BioRifle will create a much larger wad of byproduct. When this wad is launched, it will burst into smaller wads which will adhere to any surfaces.\\n\\nTechniques: Byproducts will adhere to walls, floors, or ceilings. Chain reactions can be caused by covering entryways with this lethal green waste."
	 NameColor=(R=0,G=255,B=0)
}
