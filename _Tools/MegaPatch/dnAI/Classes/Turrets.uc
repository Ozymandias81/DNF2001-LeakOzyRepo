class Turrets expands BonedCreature 
	abstract;

var( Turret ) class<Actor>			MuzzleFlashClass	?("Turret muzzleflash class.");
var( Turret ) class<TurretMounts>	WeaponMountClass	?("Class that controls what this turret fires.");
var( Turret ) bool					bRestrictRotation	?("Restricts rotation to 180 degrees.");
var( Turret ) int					YawRate				?("Turret yaw rotation speed.");
var( Turret ) float					AggressionDistance	?("Distance player needs to be away (in units) before wake-up.");
var( Turret ) float					ActivateAnimRate	?("Change to speed up or slow down activation anim sequence.");
var( Turret ) bool					bInitiallyOn		?("I'm initially on." );

var bool	bOn;
var Actor	MyTarget;
var rotator LastHeadLook;
var bool	bCanFire;
var bool	bResetting, bCanTurnOff;
var TurretMounts MyWeaponMount;
var dnShellCaseMaster ShellMaster3rd;
var vector EnemyLastPosition;
var float ContinueFireTime;
var() float MaxContinueFireTime;
var bool bContinuingFire;

const Continue_Fire = 8;

#exec OBJ LOAD FILE=..\Meshes\c_dnweapon.dmx

function TriggerHate()
{
	local actor NewEnemy;

	foreach allactors( class'Actor', NewEnemy, HateTag )
	{
		Enemy = NewEnemy;
		GotoState( 'Turrets', 'Activate' );
		break;
	}
}


function Activate( optional Actor NewTarget )
{
	if( !bOn )
	{
		if( NewTarget != None )
		{
			Enable( 'SeePlayer' );
			Disable( 'EnemyNotVisible' );
			bContinuingFire = false;
			MaxContinueFireTime = 0;
			MyTarget = NewTarget;
			Enemy = MyTarget;
		}
		GotoState( 'Turret', 'Activate' );
	}
}

function Tick(float inDeltaTime)
{	
	if( bContinuingFire )
	{
		ContinueFireTime += inDeltaTime;
		if( ContinueFireTime >= MaxContinueFireTime )
		{
			bContinuingFire = false;
			ContinueFireTime = 0;
			GotoState( 'Turret', 'Waiting' );
		}
	}

	if ( !PlayerCanSeeMe() )
	{
		return;
	}

	TopAnimBlend = UpdateRampingFloat(TopAnimBlend, DesiredTopAnimBlend, TopAnimBlendRate*inDeltaTime);
	BottomAnimBlend = UpdateRampingFloat(BottomAnimBlend, DesiredBottomAnimBlend, BottomAnimBlendRate*inDeltaTime);
	SpecialAnimBlend = UpdateRampingFloat( SpecialAnimBlend, DesiredSpecialAnimBlend, SpecialAnimBlendRate*inDeltaTime);
	GetMeshInstance();
	if (MeshInstance!=None)
	{
		MeshInstance.MeshChannels[1].AnimBlend = TopAnimBlend;
		MeshInstance.MeshChannels[2].AnimBlend = BottomAnimBlend;
		MeshInstance.MeshChannels[4].AnimBlend = SpecialAnimBlend;

		if (DesiredTopAnimBlend>=1.0 && TopAnimBlend>=1.0)
		{
			MeshInstance.MeshChannels[1].AnimSequence = 'None';
		}
		if (DesiredBottomAnimBlend>=1.0 && BottomAnimBlend>=1.0)
			MeshInstance.MeshChannels[2].AnimSequence = 'None';
		if( DesiredSpecialAnimBlend>=1.0 && SpecialAnimBlend>=1.0)
			MeshInstance.MeshChannels[4].AnimSequence = 'None';
	}
	TickTracking( inDeltaTime );	
}

simulated function DropShell()
{
	local vector realLoc, X, Y, Z;	
	local SoftParticleSystem.Particle p;
	local int pIndex;
	local meshinstance minst;
	local int bone;


	if (ShellMaster3rd==None)
	{
		ShellMaster3rd = spawn(class'dnShellCaseMaster', self, '', MyWeaponMount.Location, MyWeaponMount.Rotation);
	//	ShellMaster3rd.bOwnerSeeSpecial = true;
		ShellMaster3rd.Mesh = mesh'm16shell';
		ShellMaster3rd.DrawScale *= 5;
		ShellMaster3rd.bHidden = false;
		ShellMaster3rd.AttachActorToParent( self, true, true );
		ShellMaster3rd.MountMeshItem = 'Shells';
		ShellMaster3rd.MountType = MOUNT_MeshSurface;
		ShellMaster3rd.SetPhysics( PHYS_MovingBrush );
	}

	pIndex = ShellMaster3rd.SpawnParticle(1);
	if (pIndex!=-1)
	{
		ShellMaster3rd.GetParticle(pIndex, p);
		p.Rotation3d = MyWeaponMount.Rotation;
		p.Location = ShellMaster3rd.Location;
		Minst = GetMeshInstance();
		bone = Minst.bonefindnamed( 'Rotate' );

	//	p.Velocity = vector( MyWeaponMount.Rotation ) - vect( 0, -1, 0 ) ) * 350;	
		//	sideDir = Normal( Normal(Enemy.Location - Location) Cross vect(0,0,1) );
		p.velocity =  Normal( MyWeaponMount.Location - p.Location ) Cross vect( 0, 0, 1 ) * 150;
		p.RotationVelocity3D = RotRand();
		p.RotationVelocity3D.Pitch = FRand()*200000.0 - 100000.0;
		p.RotationVelocity3D.Yaw = FRand()*200000.0 - 100000.0;
		p.RotationVelocity3D.Roll = FRand()*200000.0 - 100000.0;
		
		ShellMaster3rd.SetParticle(pIndex, p);
	}
}

function PostBeginPlay()
{
	local MeshInstance Minst;
	local int bone;

	HeadTracking.RotationRate.Yaw = YawRate;
	MountExtremities();
	Super.PostBeginPlay();
}

function MountExtremities()
{
	if( WeaponMountClass != None )
	{
		MyWeaponMount = Spawn( WeaponMountClass, self,,, Rotation );
		MyWeaponMount.bHidden = true;
		MyWeaponMount.AttachActorToParent( self, true, true );
		MyWeaponMount.MountMeshItem = 'MuzzleMount';
		MyWeaponMount.MountType = MOUNT_MeshSurface;
		MyWeaponMount.SetPhysics( PHYS_MovingBrush );
	}
}

simulated event bool OnEvalBones(int Channel)
{
	if (Channel == 8)
	{
		if( Health > 0 )
		{
			EvalHeadLook();
		}	
	}
	return true;
}

simulated function MuzzleFlash()
{
	local actor S;
	local float RandRot;

//	MuzzleFlashClass=class'M16Flash';

	if (MuzzleFlashClass != None)
	{
		S = Spawn(MuzzleFlashClass);
		S.MountMeshItem = 'MuzzleMount';
		S.AttachActorToParent( Self, true, true );
		S.MountOrigin = vect( 3, 0, 0 );
		S.MountType = MOUNT_MeshSurface;
		S.bOwnerSeeSpecial = true;
		S.SetOwner( Owner );
		S.SetPhysics( PHYS_MovingBrush );
		RandRot = FRand();
		if (RandRot < 0.3)
			S.SetRotation(rot(S.Rotation.Pitch,S.Rotation.Yaw,S.Rotation.Roll+16384));
		else if (RandRot < 0.6)
			S.SetRotation(rot(S.Rotation.Pitch,S.Rotation.Yaw,S.Rotation.Roll+32768));
//		MuzzleLocation = S.Location;
	}
}
/*
function Tick(float inDeltaTime)
{	
	TopAnimBlend = UpdateRampingFloat(TopAnimBlend, DesiredTopAnimBlend, TopAnimBlendRate*inDeltaTime);
	BottomAnimBlend = UpdateRampingFloat(BottomAnimBlend, DesiredBottomAnimBlend, BottomAnimBlendRate*inDeltaTime);
	SpecialAnimBlend = UpdateRampingFloat( SpecialAnimBlend, DesiredSpecialAnimBlend, SpecialAnimBlendRate*inDeltaTime);
	GetMeshInstance();
	if (MeshInstance!=None)
	{
		MeshInstance.MeshChannels[1].AnimBlend = TopAnimBlend;
		MeshInstance.MeshChannels[2].AnimBlend = BottomAnimBlend;
		MeshInstance.MeshChannels[4].AnimBlend = SpecialAnimBlend;

		if (DesiredTopAnimBlend>=1.0 && TopAnimBlend>=1.0)
		{
			MeshInstance.MeshChannels[1].AnimSequence = 'None';
		}
		if (DesiredBottomAnimBlend>=1.0 && BottomAnimBlend>=1.0)
			MeshInstance.MeshChannels[2].AnimSequence = 'None';
		if( DesiredSpecialAnimBlend>=1.0 && SpecialAnimBlend>=1.0)
			MeshInstance.MeshChannels[4].AnimSequence = 'None';
	}
	TickTracking( inDeltaTime );	
}
*/

auto state Startup
{
	ignores SeePlayer;

	function Trigger( actor Other, Pawn EventInstigator )
	{
		GotoState( 'Turret' );
	}

Begin:
	SetPhysics( PHYS_Falling );
	WaitForLanding();
	PlayAllAnim( 'Off',, 0.1, true );
	if( bInitiallyOn )
		GotoState( 'Turret' );
}



state Turret
{ 
	function BeginState()
	{
		Disable( 'EnemyNotVisible' );
		Enable( 'SeePlayer' );
	}

	function SeePlayer( actor SeenPlayer )
	{	
		bContinuingFire = false;
		if( VSize( SeenPlayer.Location - Location ) <= AggressionDistance )
		{
			if( !bOn && SeenPlayer.IsA( 'PlayerPawn' )  ) //&& !SeenPlayer.IsA( 'PlayerPawn' ) )
			{
				MyTarget = Pawn( SeenPlayer );
				Enemy = MyTarget;
				GotoState( 'Turret', 'Activate' );
				Disable( 'SeePlayer' );
				Disable( 'Timer' );
				Enable( 'EnemyNotVisible' );
			}
			else
			if( bOn && SeenPlayer.IsA( 'PlayerPawn' ) )// && !SeenPlayer.IsA( 'PlayerPawn' ) )
			{
				MyTarget = Pawn( seenPlayer );
				Enemy = MyTarget;
				GotoState( 'Turret', 'Attacking' );
				Disable( 'SeePlayer' );
				Disable( 'Timer' );
				Enable( 'EnemyNotVisible' );
			}	
			//Disable( 'Timer' );
		/*	if( SeenPlayer.IsA( 'PlayerPawn' ) )
			{
				log( "Disabling timer" );
				Disable( 'Timer' );
			}*/
		}
	}

	function EnemyNotVisible()
	{
		bContinuingFire = true;
		MaxContinueFireTime = RandRange( 0.1, Default.MaxContinueFireTime );
		Disable( 'EnemyNotVisible' );
	}
	/*	function EnemyNotVisible()
	{
		log(" Enemy not vis" );
		SetTimer( 10.0, false );
		Disable( 'EnemyNotVisible' );
		Enable( 'SeePlayer' );
		GotoState( 'Turret', 'Waiting' );
	}
*/
	function Timer( optional int TimerNum )
	{
		if( TimerNum == Continue_Fire )
		{
			bCanFire = false;
			GotoState( 'Turret', 'Waiting' );
		}
	}

	function Used( actor Other, Pawn EventInstigator )
	{
		if( !bOn )
		{
			MyTarget = EventInstigator;
			Enemy = MyTarget;
			GotoState( 'Turret', 'Activate' );
		}
		else
			GotoState( 'Turret', 'Deactivate' );
	}


Deactivate:
	bOn = false;
	bFire = 0;
	PlayAllAnim( 'Deactivate' );
	FinishAnim( 0 );
	PlayAllAnim( 'Off' );
	Goto( 'Waiting' );
Activate:
	if( !Enemy.bIsPawn )
		Disable( 'SeePlayer' );
	bResetting = false;
	bCanTurnOff = false;
	PlayAllAnim( 'Activate', ActivateAnimRate, 0.1, false );
	FinishAnim( 0 );
	HeadTracking.Rotation = Rotation;
	bOn = true;
	PlayAllAnim( 'On' );	
	Goto( 'Attacking' );
	
Begin:
	EnableHeadTracking( true );
//	SetPhysics( PHYS_Falling );
//	WaitForLanding();
	PlayAllAnim( 'Off',, 0.1, true );

Waiting:
	Enable( 'SeePlayer' );
/*	if( MyTarget != None && MyTarget.Health <= 0 && bOn )
	{
		Goto( 'Deactivate' );
		MyTarget = None;
		HeadTrackingActor = None;
		Enable( 'Timer' );
		SetTimer( 2.0, false );
	//	GotoState( 'Turret', 'Deactivate' );
	}*/
	Sleep( 0.3 );
	Goto( 'Waiting' );

Attacking:
	if( bCanFire && ( CanSee( MyTarget ) || bContinuingFire ) ) //&& CanSee( MyTarget ) )
	{
		PlaySound( sound'dnsWeapn.m16.GunFire053', SLOT_None, SoundDampening * 0.98, false,, RandRange( 0.8, 1.1 ), false );
		MyWeaponMount.TraceFire( None );
		MuzzleFlash();
		DropShell();
	}
	if( ( MyTarget.bIsPawn && Pawn(MyTarget).Health <= 0 ) && bOn )
	{
		bResetting = true;
		HeadTrackingActor = None;
		MyTarget = None;
		Enable( 'Timer' );
		SetTimer( 4.0, false );
		Goto( 'Waiting' );
	}
	Sleep( MyWeaponMount.TimeBetweenShots );
	Goto( 'Attacking' );
}

function rotator ClampHeadRotation(rotator r)
{
	local rotator adj;
	adj = Rotation;
	r = Normalize(r - adj);
	r.Pitch = Clamp(r.Pitch, -HeadTracking.RotationConstraints.Pitch, HeadTracking.RotationConstraints.Pitch);
	if( bRestrictRotation )
		r.Yaw = Clamp(r.Yaw, -HeadTracking.RotationConstraints.Yaw, HeadTracking.RotationConstraints.Yaw);
	r.Roll = Clamp(r.Roll, -HeadTracking.RotationConstraints.Roll, HeadTracking.RotationConstraints.Roll);
	r = Normalize(r + adj);
	return(r);
}

DefaultProperties
{
    BloodPuffName="dnParticles.dnRobotSpark"
	BloodHitDecalName="DNGame.DNOilHit"
    HitPackageClass=class'HitPackage_Steel'
	HitPackageLevelClass=class'HitPackage_DukeLevel'
	MuzzleFlashClass=class'dnai.M16Flash'
	WeaponMountClass=class'dnai.TurretMountM16'
	Health=50
	CarcassType=Class'RobotPawnCarcass'
	bSteelSkin=true
	bUseTriggered=true
	DrawType=DT_Mesh
	Mesh=dukemesh'c_dnweapon.Turret_Tripod'
    HeadTracking=(RotationRate=(Pitch=2000,Yaw=8500),RotationConstraints=(Pitch=6000, Yaw=500))
	PeripheralVision=-1.00
	YawRate=8500
	AggressionDistance=512
	ActivateAnimRate=0.75
	MaxContinueFireTime=3.0
    bInitiallyOn=true
}
