//=============================================================================
// MinigunCannon.
//=============================================================================
class MinigunCannon extends TeamCannon;

#exec MESH IMPORT MESH=grfinalgunM ANIVFILE=MODELS\grfinalgun_a.3D DATAFILE=MODELS\grfinalgun_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=grfinalgunM X=0 Y=0 Z=0 PITCH=0 YAW=128 ROLL=-64
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=All    STARTFRAME=0    NUMFRAMES=20
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Activate STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire1  STARTFRAME=0	NUMFRAMES=3
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire2  STARTFRAME=3	NUMFRAMES=2
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire3  STARTFRAME=4	NUMFRAMES=3
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire4  STARTFRAME=6	NUMFRAMES=2
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire5  STARTFRAME=7	NUMFRAMES=3
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire6  STARTFRAME=10   NUMFRAMES=2
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire7  STARTFRAME=11   NUMFRAMES=3
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire8  STARTFRAME=14   NUMFRAMES=2
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire9  STARTFRAME=15   NUMFRAMES=3
#exec MESH SEQUENCE MESH=grfinalgunM SEQ=Fire10 STARTFRAME=18   NUMFRAMES=2
#exec TEXTURE IMPORT NAME=jgrfinalgun FILE=MODELS\grmain.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=grfinalgunM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=grfinalgunM NUM=1 TEXTURE=jgrfinalgun

#exec MESH IMPORT MESH=grmockgunM ANIVFILE=MODELS\aniv01.3D DATAFILE=MODELS\data01.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=grmockgunM X=0 Y=0 Z=0 PITCH=0 YAW=128 ROLL=-64
#exec MESH SEQUENCE MESH=grmockgunM SEQ=All    STARTFRAME=0	  NUMFRAMES=20
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Activate STARTFRAME=1 NUMFRAMES=20
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire1  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire2  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire3  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire4  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire5  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire6  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire7  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire8  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire9  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=grmockgunM SEQ=Fire10 STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jgrmockgun FILE=MODELS\grmain.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=grmockgunM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=grmockgunM NUM=1 TEXTURE=jgrfinalgun

var Actor MuzzFlash;
 
function PostBeginPlay()
{
	Super.PostBeginPlay();
	MuzzFlash = Spawn(class'CannonMuzzle');
	MuzzFlash.SetBase(self);
}

function Name PickAnim()
{
	Drop = 0;
	if (DesiredRotation.Pitch < -1000 )
	{
		if ( DesiredRotation.Pitch < -4000 )
			return 'Fire5';
		else 
			return 'Fire3';
	}
	else if (DesiredRotation.Pitch > 1000 ) 
	{
		if ( DesiredRotation.Pitch > 4000 )
			return 'Fire9';
		else 
			return 'Fire7';
	}
	else 
		return 'Fire1';
}

simulated function SpawnBase()
{
	GunBase = Spawn(class'GrBase', self);
	GunBase.bAnimByOwner = true;
}

function PlayDeactivate()
{
	TweenAnim('Activate', 1.5);
}

function StartDeactivate()
{
	PlaySound(ActivateSound, SLOT_None,5.0);
	Mesh = mesh'Botpack.GrMockGunM';
	AnimSequence = 'Fire1';
	AnimFrame = 0.0;
	SetPhysics(PHYS_Rotating);
	DesiredRotation = StartingRotation;
	PrePivot = vect(0,0,0);
}

function ActivateComplete()
{
	Mesh = mesh'Botpack.GrFinalGunM';
	PrePivot = vect(0,0,40);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int rndDam;
	local UT_Shellcase s;
	
	s = Spawn(class'UT_ShellCase',, '', PrePivot + Location + 20 * X + 10 * Y + 30 * Z);
	if ( s != None )
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);              
	if (Other == Level) 
		Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other!=self) && (Other != None) ) 
	{
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
		rndDam = 5 + Rand(4);
		if ( DeathMatchPlus(Level.Game).bNoviceMode )
			rnddam *= (0.4 + 0.15 * Level.game.Difficulty);
		Other.TakeDamage(rndDam, self, HitLocation, rndDam*500.0*X, 'shot');
	}
}

function Shoot()
{
	local Actor HitActor;
	local Vector HitLocation, HitNormal, EndTrace, ProjStart, X,Y,Z;
	local rotator ShootRot;
	if (DesiredRotation.Pitch < -10000) Return;
	if ( AmbientSound == None )
		PlaySound(FireSound, SLOT_None,5.0);

	GetAxes(Rotation,X,Y,Z);
	ProjStart = PrePivot + Location + X*20 + 12 * Y + 16 * Z;
	ShootRot = rotator(Enemy.Location - ProjStart);
	ShootRot.Yaw = ShootRot.Yaw + 1024 - Rand(2048);
	DesiredRotation = ShootRot;
	ShootRot.Pitch = ShootRot.Pitch + 256 - Rand(512);
	GetAxes(ShootRot,X,Y,Z);
	PlayAnim(PickAnim());
	MuzzFlash.SetLocation(ProjStart);
	if ( FRand() < 0.4 )
		Spawn(class'MTracer',,, ProjStart, ShootRot);
	HitActor = TraceShot(HitLocation,HitNormal,ProjStart + 10000 * X,ProjStart);
	ProcessTraceHit(HitActor, HitLocation, HitNormal, X,Y,Z);
	bShoot = false;
	ShootRot.Pitch = ShootRot.Pitch & 65535;
	if ( ShootRot.Pitch < 32768 )
		ShootRot.Pitch = Min(ShootRot.Pitch, 5000);
	else
		ShootRot.Pitch = Max(ShootRot.Pitch, 60535);
	MuzzFlash.SetRotation(ShootRot);
	ShootRot.Pitch = 0;
	SetRotation(ShootRot);
}

state ActiveCannon
{
	ignores SeePlayer;

	function Timer()
	{
		local Pawn P;

		DesiredRotation = rotator(Enemy.Location - Location - PrePivot);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		MuzzFlash.bHidden = false;
		if ( bShoot )
			Shoot();
		else 
		{
			TweenAnim(PickAnim(), 0.2);
			bShoot=True;			
			SetTimer(SampleTime,True);
		}

	}

	function BeginState()
	{
		Super.BeginState();
	}

	function EndState()
	{
		AmbientSound = None;
		MuzzFlash.bHidden = true;
	}

Begin:
	Disable('Timer');
	FinishAnim();
	PlayActivate();
	FinishAnim();
	ActivateComplete();
	Enable('Timer');
	SetTimer(SampleTime,True);
	RotationRate.Yaw = TrackingRate;
	SetPhysics(PHYS_Rotating);
	AmbientSound = Class'Minigun2'.Default.FireSound;
	bShoot=True;

FaceEnemy:
	TurnToward(Enemy);
	Goto('FaceEnemy');
}

defaultproperties
{
     Mesh=Botpack.GrMockGunM
	 AnimSequence=Activate
	 SampleTime=+00000.100000
     FireSound=Sound'UnrealI.Rifle.RifleShot'
     SoundRadius=96
     SoundVolume=255
     CollisionHeight=+00024.000000
}	