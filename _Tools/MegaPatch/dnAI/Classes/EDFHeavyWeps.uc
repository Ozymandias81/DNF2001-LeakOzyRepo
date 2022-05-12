//=============================================================================
// EDFHeavyWeps.uc
//=============================================================================
class EDFHeavyWeps extends HumanNPC;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsweapn.dfx
#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

/*================================================================
	EDFRobot Specific Sequences:
	
	A_Robot2HShockLoop
	A_Robot2HShockStart
	A_Robot2HShockStop
	A_RobotActiveTurnL45
	A_RobotActiveTurnR45
	A_RobotAsleep
	A_RobotCrawlActivate
	A_RobotCrawlDeath
	A_RobotCrawlGround
	A_RobotCrawlIdleA
	A_RobotCrawlShock
	A_RobotCrawlShockLoop
	A_RobotCrawlShockStart
	A_RobotCrawlShockStop
	A_RobotDeathA
	A_RobotDeathB
	A_RobotDeathCrawl
	A_RobotDeathEMP
	A_RobotEMPed
	A_RobotFire
	A_RobotFireStart
	A_RobotFireStop
	A_RobotFireTurnL45
	A_RobotFireTurnR45
	A_RobotHitGround
	A_RobotIdleActive
	A_RobotKnockBack
	A_RobotWakeUp
	A_RobotWalk
	A_RobotWalkGuns
	A_RobotWalkRPG
	T_RobotFire
================================================================*/

var EDFMiniGun			MinigunRight, MinigunLeft;
var bool				bIsTurning;
var byte				bFire;
var SoftParticleSystem	MySmoke;
var name				LastDamageBone;
var int					EMPCount;
var actor				OldHeadTrackingActor;
var TurretMountProton	 GunMountL, GunMountR;
var ProtonCollisionActor GeneralCollisionLeft, GeneralCollisionRight;
var vector LastSeenSpot;
var bool bContinueFire;
var bool bGunsDown;


// Old obsolete vars.
var BeamSystem			LaserBeam1, LaserBeam2;
var actor				LaserDestination1, LaserDestination2;
var bool				bShocking;
var() float				ShockTime;
var float				CurrentShockTime;
var actor				ShockedTarget;
var bool				bPlayerStunned;
var float				CurrentStunTime;
var float				MaxStunTime;
var float				MaxEyeBeamTime;
var float				CurrentEyeBeamTime;
var RobotEye			Dot1, Dot2;
var StunLeech			MyStunLeech;
var() bool				bFirstAttackPound;
var bool				bEyelessLeft, bEyelessRight;
var dnRobotShockFX_Spawner1		MySpawnerA, MySpawnerB, MySpawnerC;
var dnRobotShockFX_SparkBeamA	MyBeamA, MyBeamB;

function Destroyed()
{
	DestroyMountedActors();
	Super.Destroyed();
}

function DestroyMountedActors()
{
	if( GeneralCollisionLeft != None )
		GeneralCollisionLeft.Destroy();
	if( GeneralCollisionRight != None )
		GeneralCollisionRight.Destroy();
	if( GunMountL != None )
		GunMountL.Destroy();
	if( GunMountR != None )
		GunMountR.Destroy();
	if( MinigunLeft != None )
		MinigunLeft.Destroy();
	if( MinigunRight != None )
		MinigunRight.Destroy();
}

function PostBeginPlay()
{
	MaxStunTime = 5.0;
	MaxEyeBeamTime = 5.0;
	MountSpecialActors();
	Super.PostBeginPlay();
}

simulated function MuzzleFlash()
{
	local actor S;
	local float RandRot;

	S = Spawn(class'M16Flash');
	S.DrawScale *= 5;
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
}

function MountSpecialActors()
{
	MinigunLeft = Spawn( class'EDFMiniGun', self );
	MinigunLeft.AttachActorToParent( self, true, true );
	MinigunLeft.MountType = MOUNT_MeshSurface;
	MinigunLeft.MountMeshItem = 'MinigunL';
	MinigunLeft.SetPhysics( PHYS_MovingBrush );
		
	MinigunRight = Spawn( class'EDFMiniGun', self );
	MinigunRight.Mesh = DukeMesh'MiniGun_R';
	MinigunRight.AttachActorToParent( self, true, true );
	MinigunRight.MountType = MOUNT_MeshSurface;
	MinigunRight.MountMeshItem = 'MinigunR';
	MinigunRight.SetPhysics( PHYS_MovingBrush );

	MiniGunLeft.LoopAnim( 'OffIdle' );
	MiniGunRight.LoopAnim( 'OffIdle' );		
	
	GunMountL = spawn( class'TurretMountProton', MiniGunLeft );
	GunMountL.AttachActorToParent( MiniGunLeft, true, true );
	GunMountL.MountType = MOUNT_MeshSurface;
	GunMountL.MountMeshItem = 'MuzzleMount';
	GunMountL.SetPhysics( PHYS_MovingBrush );

	GunMountR = spawn( class'TurretMountProton', MiniGunRight );
	GunMountR.AttachActorToParent( MiniGunRight, true, true );
	GunMountR.MountType = MOUNT_MeshSurface;
	GunMountR.MountMeshItem = 'MuzzleMount';
	GunMountR.SetPhysics( PHYS_MovingBrush );

	GeneralCollisionLeft = Spawn( class'ProtonCollisionActor', self );
	GeneralCollisionLeft.AttachActorToParent( self, true, true );
	GeneralCollisionLeft.MountType = MOUNT_MeshSurface;
	GeneralCollisionLeft.MountOrigin.X = 3;
	GeneralCollisionLeft.MountMeshItem = 'MiniGunL';
	GeneralCollisionLeft.SetPhysics( PHYS_MovingBrush );
	GeneralCollisionLeft.MyGun = MinigunLeft;

	GeneralCollisionRight = Spawn( class'ProtonCollisionActor', self );
	GeneralCollisionRight.AttachActorToParent( self, true, true );
	GeneralCollisionRight.MountType = MOUNT_MeshSurface;
	GeneralCollisionRight.MountOrigin.X = 3;
	GeneralCollisionRight.MountMeshItem = 'MiniGunR';
	GeneralCollisionRight.SetPhysics( PHYS_MovingBrush );
	GeneralCollisionRight.MyGun = MinigunRight;
}

function DisableContinueFire()
{
	HeadTrackingActor = OldHeadTrackingActor;
	if( CanSee( Enemy ) )
		Enable( 'EnemyNotVisible' );
	else
	{
		bFire = 0;
		EndCallbackTimer( 'FireGuns' );
	}
	bContinueFire = false;
	GotoState( 'ApproachingEnemy' );
}

state Firing
{
	ignores Bump;

	function BeginState()
	{
		Disable( 'SeePlayer' );
	}

	function EnemyNotVisible()
	{
		OldHeadTrackingActor = HeadTrackingActor;
		HeadTrackingActor = None;
		bContinueFire = true;
		Disable( 'EnemyNotVisible' );
		Enable( 'SeePlayer' );
		SetCallbackTimer( ( Rand( 2 ) + 2 ), true, 'DisableContinueFire' );
	}

	function SeePlayer( actor Seen )
	{
		if( bContinueFire )
		{
			bContinueFire = false;
			Disable( 'SeePlayer' );
			EndCallbackTimer( 'DisableContinueFire' );
			HeadTrackingActor = OldHeadTrackingActor;
			Enable( 'EnemyNotVisible' );
		}
	}

Turning:
	HeadTrackingActor = Enemy;
	if(  MustTurn() )
	{
		Destination = Enemy.Location;
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Turning' );
	}	
	Goto( NextLabel );

Seen:
	NextLabel = 'Seen';
	if( MustTurn() )

	{
		Destination = Enemy.Location;
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Seen' );
	}

	if( bFire == 0 || GetSequence( 0 ) == 'A_RobotIdleActive' )
	{
		//if( GetSequence( 1 ) != 'T_RobotFire' )
		//{
		//	PlayRobotFireStart();
		//	//PlaySound( sound'VStartSpinLp07', SLOT_Talk );
		//	FinishAnim( 0 );
		//	PlayAllAnim( 'A_RobotIdleActiveFire',, 0.1, true );
		//}
		if( MinigunLeft != None )
			MinigunLeft.PlayFireStart();
		if( MinigunRight != None )
			MinigunRight.PlayFireStart();

FireLoop:
		SetCallbackTimer( 0.1, true, 'FireGuns' );
	}
TurnFire:
	if( !bContinueFire && ( ( Rotator( Enemy.Location - Location ) - Rotation ).Yaw != 0 && ( Rotator( Enemy.Location - Location ) - rotation ).Yaw != -65536 ) )
	{
		Destination = Enemy.Location;
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'TurnFire' );
	}
	Sleep( 0.1 );
	Goto( 'TurnFire' );

Begin:
	PlayTopAnim( 'None' );
	PlayToWaiting( 0.12 );
	if( bFire == 0 )
	{
		Goto( 'Seen' );
	}
	else
		Goto( 'TurnFire' );
}

function FireGuns()
{
	local vector TargetVector;
	local rotator OldGunMountRotLeft, OldGunMountRotRight;
	local bool bShotSoundPlayed;

	if( bContinueFire )
		TargetVector = LastSeenSpot;
	else
		TargetVector = Enemy.Location;

	if( GetStateName() != 'GunLost' && !MustTurn() )
	{
		bFire = 1;
		LastSeenSpot = TargetVector;
		if( MinigunLeft != None )
		{
			if( MinigunLeft.bReadyToFire )
			{
				GunMountL.NewEnemy = Pawn( Enemy );
				OldGunMountRotLeft = GunMountL.Rotation;
				GunMountL.SetRotation( Rotator( TargetVector - GunMountL.Location ) );
				GunMountL.TraceFire( None );
				GunMountL.SetRotation( OldGunMountRotLeft );
				GunMountL.MuzzleFlash();
				PlaySound( sound'VShot01' );
				bShotSoundPlayed = true;
				PlayRobotFireLoop();

			}
			else if( MinigunLeft.AnimSequence != 'FireStart' )
				MiniGunLeft.PlayFireStart();
		}
		if( MinigunRight != None )
		{
			if( MinigunRight.bReadyToFire )
			{
				GunMountR.NewEnemy = Pawn( Enemy );
				OldGunMountRotRight = GunMountL.Rotation;
				GunMountR.SetRotation( Rotator( TargetVector - GunMountR.Location ) );
				GunMountR.TraceFire( None );
				GunMountR.SetRotation( OldGunMountRotRight );
				GunMountR.MuzzleFlash();
				if( !bShotSoundPlayed )
					PlaySound( sound'VShot01' );
				PlayRobotFireLoop();
			}
			else if( MinigunRight.AnimSequence != 'FireStart' )
				MinigunRight.PlayFireStart();
		}
	}
	else
	{
		MinigunLeft.PlayFireStop();
		MinigunRight.PlayFireStop();
	}
	if( VSize( Location - TargetVector ) >= AIMeleeRange )
		GotoState( 'ApproachingEnemy' );
}

function KillGun( EDFMiniGun GunToKill )
{
	if( GunToKill == MiniGunLeft )
	{
        MiniGunLeft.StopSound(SLOT_Talk);
		MiniGunLeft.SetCollision( true, true, true );
		MinigunLeft.bCollideWorld = true;
		MiniGunLeft.SetCollisionSize( 8, 8 );
		MinigunLeft.AttachActorToParent( none, true, true );
		MinigunLeft.MountParent = None;
		MinigunLeft.SetPhysics( PHYS_Falling );
		MinigunLeft.Tossed();
		MiniGunLeft.LoopAnim( 'OffIdle' );
		GeneralCollisionLeft.Destroy();
	}
	else
	{
        MiniGunRight.StopSound(SLOT_Talk);
		MiniGunRight.SetCollision( true, true, true );
		MiniGunRight.bCollideWorld = true;
		MiniGunRight.SetCollisionSize( 8, 8 );
		MinigunRight.AttachActorToParent( none, true, true );
		MinigunRight.MountParent = None;
		MinigunRight.SetPhysics( PHYS_Falling );
		MinigunRight.Tossed();
		MiniGunRight.LoopAnim( 'OffIdle' );		
		GeneralCollisionRight.Destroy();
	}
	if( MinigunLeft == None && MinigunRight == None )
		AIMeleeRange = 196;
	GotoState( 'GunLost' );

	//GotoState( '' );
}

state GunLost
{
	function PlayRobotGunLost()
	{
		if( MinigunLeft != None && MinigunLeft.Health <= 0 )
		{
			if( MinigunRight != None && MinigunRight.Health >= 0 )
				PlayAllAnim( 'A_RobotLoseLGunA',, 0.13, false );
			else
				PlayAllAnim( 'A_RobotLoseLGunB',, 0.13, false );
			MinigunLeft = None;
		}
		else
		if( MinigunRight != None && MinigunRight.Health <= 0 )
		{
			if( MinigunLeft != None && MinigunLeft.Health >= 0 )
				PlayAllAnim( 'A_RobotLoseRGunA',, 0.13, false );
			else
				PlayAllAnim( 'A_RobotLoseRGunB',, 0.13, false );
			MinigunRight = None;
		}
	}
	
Begin:
	StopMoving();
	PlayRobotGunLost();
	FinishAnim( 0 );
	if( MinigunLeft != None || MinigunRight != None )
		GotoState( 'Firing' );
	else
		GotoState( 'Attacking' );
}

function FootStepL()
{
	PlaySound( sound'EDFRobotStep08L', SLOT_None, SoundDampening * 0.94, false );
}

function FootStepR()
{
	PlaySound( sound'EDFRobotStep08R', SLOT_None, SoundDampening * 0.94, false );
}

function StepCheck()
{
	if( GetStateName() == 'Charging' && VSize( Location - Enemy.Location ) <= AIMeleeRange )
		GotoState( 'Shocking' );
}

function bool EvalHeadLook()
{
	if( bEMPed || bSleeping || bLegless || bShocking || bContinueFire )
		return false;
	else
		Super.EvalHeadLook();
}

simulated event bool OnEvalBones(int Channel)
{
	if( Channel == 8 )
	{
		if (!PlayerCanSeeMe())
		{
			return false;
		}	
		else
		{
			if( bLegless )
				EvalMissingLegs();
			return Super.OnEvalBones( Channel );
		}
	}
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local Carcass c;
	local RobotPawnCarcass CPC;

	local SoftParticleSystem a;
	local Tentacle T;
	local meshinstance Minst, CMinst;
	local SnatchActor SA;
	
	KillEyeBeams();
	KillShockActors();

	c = Spawn( CarcassType );
	
	c.SetCollisionSize( CollisionRadius, CollisionHeight );
	
	MinigunLeft.AttachActorToParent( C, true, true );
	MinigunLeft.MountType = MOUNT_MeshSurface;
	MinigunLeft.MountMeshItem = 'MinigunL';
	MinigunLeft.SetPhysics( PHYS_MovingBrush );
		
	MinigunRight.Mesh = DukeMesh'MiniGun_R';
	MinigunRight.AttachActorToParent( C, true, true );
	MinigunRight.MountType = MOUNT_MeshSurface;
	MinigunRight.MountMeshItem = 'MinigunR';
	MinigunRight.SetPhysics( PHYS_MovingBrush );

	MiniGunLeft.LoopAnim( 'OffIdle' );
	MiniGunRight.LoopAnim( 'OffIdle' );		
	
	if( C.IsA( 'dnCarcass' ) )
	{
		dnCarcass( c ).bCanHaveCash = bCanHaveCash;
	}

	if( C != None && C.IsA( 'RobotPawnCarcass' ) )
		CPC = RobotPawnCarcass( C );

	if( CPC != None )
	{
		CPC.bLegless = bLegless;
		cpc.bHeadBlownOff = bHeadBlownOff;
		cpc.bArmless = bArmless;
		cpc.bEyesShut = bEyesShut;
		cpc.Initfor(self);
		cpc.PrePivot = PrePivot;

		if( bSnatched || bSteelSkin )
		{
			CPC.bNoPupils = true;
		}

		if( bDamagedByShotgun )
		{
			cpc.SetPhysics( PHYS_Falling );
			cpc.Acceleration = 2500 * Normal( Location - ShotgunInstigator.Location );
			cpc.Velocity.Z += 96;
		}
			cpc.MeshDecalLink = MeshDecalLink;
	}
	cpc.bAnimNotify = true;
	Minst = GetMeshInstance();
	CMinst = CPC.GetMeshInstance();
	CMinst.MeshChannels[ 5 ].bAnimFinished = Minst.MeshChannels[ 5 ].bAnimFinished;
	CMinst.MeshChannels[ 5 ].bAnimLoop = false;
	CMinst.MeshChannels[ 5 ].bAnimNotify = true;
	CMinst.MeshChannels[ 5 ].bAnimBlendAdditive = Minst.MeshChannels[ 5 ].bAnimBlendAdditive;
	CMinst.MeshChannels[ 5 ].AnimSequence = Minst.MeshChannels[ 5 ].AniMSequence;
	CMinst.MeshChannels[ 5 ].AnimFrame = Minst.MeshChannels[ 5 ].AnimFrame;
	CMinst.MeshChannels[ 5 ].AnimRate = Minst.MeshChannels[ 5 ].AnimRate;
	CMinst.MeshChannels[ 5 ].AnimBlend = Minst.MeshChannels[ 5 ].AnimBlend;
	CMinst.MeshChannels[ 5 ].TweenRate = Minst.MeshChannels[ 5 ].TweenRate;
	CMinst.MeshChannels[ 5 ].AnimLast = Minst.MeshChannels[ 5 ].AnimLast;
	CMinst.MeshChannels[ 5 ].AnimMinRate = Minst.MeshChannels[ 5 ].AnimMinRate;
	CMinst.MeshChannels[ 5 ].OldAnimRate = Minst.MeshChannels[ 5 ].OldAnimRate;
	CMinst.MeshChannels[ 5 ].SimAnim = Minst.MeshChannels[ 5 ].SimAnim;
	CMinst.MeshChannels[ 5 ].MeshEffect = Minst.MeshChannels[ 5 ].MeshEffect;
	return cpc;
}

simulated function bool EvalMissingLegs()
{
	local meshinstance minst;
	local int bone;

    if( bLegless )
	{
		Minst = GetMeshInstance();
		bone = minst.BoneFindNamed('Shin_L');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		bone = minst.BoneFindNamed('Shin_R');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		bone = minst.BoneFindNamed('Knee_L');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		bone = minst.BoneFindNamed('Knee_R');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		bone = minst.BoneFindNamed('Thigh_L');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		bone = minst.BoneFindNamed('Thigh_R');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		return true;
	}
	return false;
}

function CreateDamageSmoke( EPawnBodyPart BodyPart )
{
	local int bone;
	local MeshInstance Minst;

	MySmoke = Spawn( class'dnSmokeEffect_RobotDmgA', self,, Location, Rotation );
	MySmoke.AttachActorToParent( self, false, false );
	
	if( LastDamageBone == '' )
		MySmoke.MountMeshItem = 'Chest';
	else
		MySmoke.MountMeshItem = LastDamageBone;
	MySmoke.MountType = MOUNT_MeshBone;
	MySmoke.SetPhysics( PHYS_MovingBrush );
}

function SetDamageBone(name BoneName)
{
	if (BoneName=='None')
		return;
	LastDamageBone = BoneName;
	DamageBone = BoneName;
}

function LeftEyeDamageEvent()
{ 
}

function RightEyeDamageEvent()
{
}

function Trigger( actor Other, pawn EventInstigator )
{
	local actor HitActor;
	local int Bone, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTexture ;
	local MeshInstance Minst;
	local vector HitLocation, HitNormal, EndTrace, StartTrace;

	StartTrace = Location;
	EndTrace = Location /*+ ( BaseEyeHeight * vect( 0, 0, 1 ) )*/ + Vector( ViewRotation ) * 10000;
	HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , true );
	if( MyStunLeech == None && DukePlayer( Enemy ) != None && HitActor == Enemy && !bPlayerStunned )
	{
		MyStunLeech = spawn( class'StunLeech', Self );
		MyStunLeech.AttachTo( Pawn( Enemy ) );
	}
}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	DestroyMountedActors();

	if( MyStunLeech != None )
		MyStunLeech.DetachLeech();

	if( LaserDestination1 != None )
		LaserDestination1.Destroy();

	if( LaserDestination2 != None )
		LaserDestination2.Destroy();

	if( MySmoke != None )
		MySmoke.Destroy();
	KillShockActors();
	KillEyeBeams();
	Super.Died( Killer, DamageType, HitLocation );
}

function KillEyeBeams()
{
	if( Dot1 != None )
	{
		Dot1.Destroy();
		Dot1 = None;
	}
	if( Dot2 != None )
	{
		Dot2.Destroy();
		Dot2 = None;
	}

	if( LaserBeam1 != None )
	{
		LaserBeam1.Destroy();
		LaserBeam1 = None;
	}
	if( LaserBeam2 != None )
	{
		LaserBeam2.Destroy();
		LaserBeam2 = None;
	}
	if( MyStunLeech != None )
		MyStunLeech.DetachLeech();

	CurrentEyeBeamTime = 0;
}

function RobotStop()
{
	if( GetStateName() != 'MeleeCombat' )
	{
		StopMoving();
		Acceleration *= 0;
		MoveTimer = -1.0;
		Sleep( 10 );
	}
}

function float GetRunSpeed()
{
	if( bLegless )
		return 0.13;
	return WalkingSpeed * 1;
}

function float GetWalkingSpeed()
{
	if( bLegless )
		return 0.13;
	else
		return Super.GetWalkingSpeed();
}

function RobotStart()
{
	PlaySound( sound'EDFRobotServo01', SLOT_None, SoundDampening * 0.94, false );
	if( GetStateName() != 'MeleeCombat' )
	{
		if( MoveTarget == None || GetStateName() == 'ApproachingEnemy' )
			MoveTo( Destination, WalkingSpeed * 1 );
		else
			MoveToward( MoveTarget, WalkingSpeed * 1 );
	}
}

function PlayToRunning()
{
	local float TweenTime;
	local MeshInstance Minst;

	Minst = GetMeshInstance();

	if( GetSequence( 0 ) == 'A_RobotKnockBack' || bKnockedBack )
	{
		TweenTime = 0.16;
		bKnockedBack = false;
	}
	else
		TweenTime = 0.1;

	if( MinigunLeft != None || MinigunRight != None )
	{
		PlayAllAnim( 'A_RobotWalkGuns', 1.1, TweenTime, true );
	}
	else
	{
		PlayAllAnim( 'A_RobotWalk', 1.1, TweenTime, true );
	}

	if( bFire != 0 )
	{
		PlayRobotFireLoopTop();
		DesiredTopAnimBlend = 0;
		TopAnimBlend = 0;
	}
}

function PlayAllAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping)
{
	GetMeshInstance();
	if (MeshInstance==None)
		return;

	if ((MeshInstance.MeshChannels[0].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(0))))
		return; // already playing
	
	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime);
	else
		PlayAnim(Sequence, Rate, TweenTime);
}

function PlayToWalking()
{
	PlayTopAnim( 'None');
	if( bLegless )
		PlayAllAnim( 'A_RobotCrawlGround',, 0.1, true );
	else
		PlayAllAnim( 'A_RobotWalkGuns', 1.1, 0.1, true );
}

function bool ShouldBeGibbed(class<DamageType> DamageType)
{
	if( !bLegless || ( bLegless && ClassIsChildOf(damageType, class'EMPDamage') ) )//&& FRand() < 0.5 ) 
		return false;
	else
		return Super.ShouldBeGibbed( damageType );
}

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	Momentum = vect( 0, 0, 0 );

	if ( DamageType.default.bGibDamage )
		PlaySound( sound'EDFRobotHit01', SLOT_Misc, 1 );
	if( FRand() < 0.5 && ( Health - Damage <= 0 ) && !bLegless && DamageType.default.bGibDamage )
	{
		Health =  5;
		GotoState( 'RobotCrawling' );
		return;
	}
	Super.TakeDamage( Damage, instigatedBy, HitLocation, Momentum, DamageType );
}



state RobotCrawling
{
	function EMPBlast( float EMPTime, optional Pawn Instigator )
	{
		bShocking = false;
		spawn(class'dnEMPFX_Spawner1',self,, Location, Rotation );
		if( Enemy == None )
			Enemy = Instigator;
		TakeDamage( 6, Instigator, Location, vect( 0, 0, 0 ), class'EMPDamage' );
	}

	function BeginState()
	{
		bLegless = true;
		bEyeless = true;
	}

Begin:
	StopMoving();
	PlayAllAnim( 'A_RobotDeathCrawl',, 0.1, false );
	FinishAnim( 0 );
	Sleep( 3 + FRand() );
	PlaySound( Sound'a_edf.Robot.EDFRobotWakeUp02', SLOT_Talk, SoundDampening * 0.97 );
	PlayAllAnim( 'A_RobotCrawlActivate',, 0.1, false );
	Sleep( 0.1 );
	bEyeless = false;
	FinishAnim( 0 );
	GotoState( 'ApproachingEnemy' );
}

state EMPEffect
{
	ignores SeePlayer, EnemyNotVisible, Bump;

	function EMPBlast( float EMPtime, optional Pawn Instigator )
	{	
		spawn(class'dnEMPFX_Spawner1',self,, Location, Rotation );

		if( Enemy == None )
			Enemy = Instigator;
		if( !bEMPulsed && !bSleeping )
		{
			SpawnRandomSpark();
			bEMPulsed = true;
			if( HeadTrackingActor != None )
			{
				OldHeadTrackingActor = HeadTrackingActor;
				HeadTrackingActor = None;
			}
			if( GetStateName() != 'EMPEffect' )
				NextState = GetStateName();
			bEMPed = true;
			RotationRate = rot( 0, 0, 0 );
			bSleeping = true;
			EMPCount++;
			GotoState( 'EMPEffect', 'Begin' );
		}
	/*	else if( !bEMPulsed )
		{
			log( "EMPulsed was false. Going" );
			GotoState( 'EMPEffect', 'Begin' );
		}*/
	}

Begin:
	bShocking=false;
	PlayBottomAnim( 'None' );
	PlayTopAnim( 'None' );
	StopMoving();
	Sleep( 0.25 );
	PlaySound( Sound'a_edf.Robot.EDFRobotSlump01', SLOT_Talk, SoundDampening * 0.97 );
	PlayAllAnim( 'A_RobotEMPed',, 0.1, false );
	FinishAnim( 0 );
	PlayAllAnim( 'A_RobotAsleep',, 0.1, true );
	Sleep( 5.0 );
WakeUp:
	if( !bSleeping )
	{
		PlaySound( Sound'a_edf.Robot.EDFRobotWakeUp02', SLOT_Talk, SoundDampening * 0.97 );
		PlayAllAnim( 'A_RobotWakeUp',, 0.1, false );
		FinishAnim( 0 );
	}
	bEMPed = false;
	RotationRate = Default.RotationRate;
	if( !bSleeping )
	{
		if( OldHeadTrackingActor != None )
			HeadTrackingActor = OldHeadTrackingActor;

		if( NextState != 'EMPEffect' && NextState != '' )
			GotoState( NextState );
		else
			GotoState( 'Attacking' );
	}
	else
	{
		Health = 1;
		GotoState( 'Sleeping' );
	}
}

state Sleeping
{
	ignores SeePlayer, EnemyNotVisible, Bump;

	function NotifyFriends()
	{}
	
	function BeginState()
	{
		//log( "-- Sleeping state entered" );
	}
Begin:
	StopMoving();
}

	function KillShockActors()
	{
		AmbientSound = None;

		if( MySpawnerA != None )
			MySpawnerA.Destroy();

		if( MySpawnerB != None )
			MySpawnerB.Destroy();

		if( MySpawnerC != None )
			MySpawnerC.Destroy();

		if( MyBeamA != None )
			MyBeamA.Destroy();

		if( MyBeamB != None )
			MyBeamB.Destroy();

		MyBeamA = None;
		MyBeamB = None;
		MySpawnerA = None;
		MySpawnerB = None;
		MySpawnerC = None;
	}

	function Actor ShockTarget()
	{
		local MeshInstance MinstA, MinstB;
		local int BoneA, BoneB;
		local actor HitActor;
		local vector HitNormal, HitLocation;
		local bool bHitEnemy;
		local vector ZDiff, EndTrace;

		MinstA = GetMeshInstance();
		MinstB = Enemy.GetMeshInstance();

		BoneA = MinstA.BoneFindNamed( 'Hand_L' );
		BoneB = MinstB.BoneFindNamed( 'Head' );

		ZDiff = Enemy.Location - Location;
		ZDiff.X = 0;
		ZDiff.Y = 0;
	//	if( ZDiff.Z < 0 )
	//		ZDiff.Z *= -1;
		EndTrace = Location /*+ ZDiff*/ + Vector( Rotation ) * 750;
	//	EndTrace = Enemy.Location - Location;
	//	EndTrace.X = 0;
	//	EndTrace.Y = 0;
	//	EndTrace *= 750;

///		EndTrace.Z += ZDiff.Z;
	//	if( ZDiff.Z > 0 )
			HitActor = Trace( HitLocation, HitNormal, EndTrace, Location + ZDiff, true );
	//	else
	//		HitActor = Trace( HitLocation, HitNormal, EndTrace + ZDiff, Location, true );

		if( HitActor == Enemy )
		{
			bHitEnemy = true;
			MySpawnerC = Spawn( class'dnRobotShockFX_Spawner1', Enemy );
			MySpawnerC.Tag = 'HitMe';
			MySpawnerC.AttachActorToParent( Enemy, true, true );
			MySpawnerC.MountType = MOUNT_MeshBone;
			MySpawnerC.SetPhysics( PHYS_MovingBrush );
			MySpawnerC.MountMeshItem = 'Chest';
			ShockTime = 3;
			if( !bLegless )
				MyBeamA = Spawn( class'dnRobotShockFX_SparkBeamA_Hit', self );
			MyBeamB = Spawn( class'dnRobotShockFX_SparkBeamA_Hit', self );
//			AmbientSound = Sound'a_edf.Robot.EDFRobotEZapLp3';
		}
		else if( HitActor != None )
		{
			MySpawnerC = Spawn( class'dnRobotShockFX_Spawner1', Self,, HitLocation );
			MySpawnerC.Tag = 'HitMe';
			MySpawnerC.SetPhysics( PHYS_None );
			ShockTime = 1;
			if( !bLegless )
				MyBeamA = Spawn( class'dnRobotShockFX_SparkBeamA_Hit', self );
			MyBeamB = Spawn( class'dnRobotShockFX_SparkBeamA_Hit', self );
//			AmbientSound = Sound'a_edf.Robot.EDFRobotEZapLp3';
		}
		else
		{
			MySpawnerC = Spawn( class'dnRobotShockFX_Spawner1', Self,, Location + vector( Rotation ) * 750 );
			MySpawnerC.SetPhysics( PHYS_None );
			MySpawnerC.Tag = 'HitMe';
			MySpawnerC.SetPhysics( PHYS_None );
			ShockTime = 1;
			if( !bLegless )
				MyBeamA = Spawn( class'dnRobotShockFX_SparkBeamA_Miss', self );
			MyBeamB = Spawn( class'dnRobotShockFX_SparkBeamA_Miss', self );
//			PlaySound( sound'EDFRobotEZapMiss01', SLOT_None, SoundDampening * 0.96 );
		}
		bShocking = true;
		
//		MyBeamA = Spawn( class'dnRobotShockFX_SparkBeamA', self );
		if( !bLegless )
		{
			MyBeamA.DestinationActor[ 0 ] = MySpawnerC;
			MyBeamA.Event = 'HitMe';
			MyBeamA.AttachActorToParent( self, true, true );
			MyBeamA.MountType = MOUNT_MeshBone;
			MyBeamA.SetPhysics( PHYS_MovingBrush );
			MyBeamA.MountMeshItem = 'Hand_L';
		}

//		MyBeamB = Spawn( class'dnRobotShockFX_SparkBeamA', self );
		MyBeamB.DestinationActor[ 0 ] = MySpawnerC;
		MyBeamB.Event = 'HitMe';
		MyBeamB.AttachActorToParent( self, true, true );
		MyBeamB.MountType = MOUNT_MeshBone;
		MyBeamB.SetPhysics( PHYS_MovingBrush );
		MyBeamB.MountMeshItem = 'Hand_R';

		SoundRadius=128;
	    SoundVolume=255;
		return HitActor;
	}	

// NJS: Called by the animation sequence to indicate that a footfall has landed.
simulated function FootStep()
{
	local sound step;
	local int SurfaceIndex;

	if ( FootRegion.Zone.bWaterZone )
	{
		return;
	}
    
    if ( Role == ROLE_SimulatedProxy )
    {
        // If this is a simulated proxy, we need to find out what type of surface they are walking on
        // in order to play a footstep
        LastWalkMaterial = TraceMaterial( Location-vect(0,0,200), Location, SurfaceIndex );
    }
	
	if( (LastWalkMaterial != none) && (LastWalkMaterial.default.FootstepSoundsCount > 0) )
		step = LastWalkMaterial.default.FootstepSounds[Rand(LastWalkMaterial.default.FootstepSoundsCount)];

    // FIXME: If we want to change this to a PlayOwnedSound, it would cause a RPC for every footstep (Might be slow?)

	if ( step != none )
//		PlaySound(step, SLOT_Interact, 2.2, false, 1000.0, 1.0);
		PlaySound( sound'EDFRobotStep08L', SLOT_None, SoundDampening * 0.94, false );
}

/*-----------------------------------------------------------------------------
	EDF Robot Melee Combat state.
-----------------------------------------------------------------------------*/
/*
state MeleeCombat
{
	function PlayMeleeCombatPunch()
	{
		local float Decision;
		local float TweenTime;

		MouthExpression = MOUTH_Frown;
		BrowExpression = BROW_Lowered;
		
		Decision = Rand( 3 );
		HeadTrackingActor = Enemy;

		if( Physics == PHYS_Swimming )
		{
			TweenTime = 0.22;
		}
		else
		{
			TweenTime = 0.1;
		}
		if( bLegless )
		{
			PlayAllAnim( 'A_RobotCrawlShockLoop',, 0.1, false );
		}
		else
			PlayAllAnim( 'A_Robot2HShockLoop',, 0.2, true );

// punch 2: 6
//	punch 4		: 5
		// punch 5: 6

		if( bShieldUser )
		{
			PlayTopAnim( 'A_ShieldBash',, TweenTime, false );
			return;
		}
		
		if( Decision == 0 )
		{
			PlayTopAnim( 'T_Punch1',, TweenTime, false );
		}
		else if( Decision == 1 )
		{
			PlayTopAnim( 'T_Punch2',, TweenTime, false );
		}
		else if( Decision == 2 )
		{
			PlayTopAnim( 'T_Punch4',, TweenTime, false );
		}
		else 
		{
			PlayTopAnim( 'T_Punch1',, TweenTime, false );
		}
		if( Physics == PHYS_Swimming )
		{
			PlayBottomAnim( 'B_SwimKickWade',, 0.22, true );
		}
	}

	function PlayMeleeCombatKick()
	{
		HeadTrackingActor = Enemy;
//	PlayBottomAnim( 'B_Kick',, 0.1, false );
//		if( FRand() < 0.5 )
//		{
			PlayAllAnim( 'A_Kick_Front',, 0.2, false );
//		}
//		else
//			PlayAllAnim( 'A_Kick_Side',, 0.2, false );
	}
	
	function bool EnemyWithinRange()
	{
		local float Dist;

		Dist = VSize( Location - Enemy.Location );

		if( Dist <= 196 )
		{
			return true;
		}
		
		return false;
	}

	function PickDestination(bool bNoCharge)
	{
		local vector pickdir, enemydir, enemyPart, Y, minDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, optDist;
		local bool success, bNoReach;
	
		if (Region.Zone.bWaterZone && !bCanSwim && bCanFly)
		{
			Destination = Location + 64 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}
		if ( Enemy.Region.Zone.bWaterZone )
			bNoCharge = bNoCharge || !bCanSwim;
		else 
			bNoCharge = bNoCharge || (!bCanFly && !bCanWalk);
		
		success = false;
		enemyDist = VSize(Location - Enemy.Location);
		Aggression = 2 * (CombatStyle + FRand()) - 1.1;
		Aggression = 2.0;
		if ( Pawn( Enemy ) != None && Pawn( Enemy ).bIsPlayer && (AttitudeToPlayer == ATTITUDE_Fear) && (CombatStyle > 0) )
			Aggression = Aggression - 2 - 2 * CombatStyle;
		if ( Weapon != None )
			Aggression += 2 * Weapon.SuggestAttackStyle();
		if ( Pawn( Enemy ).Weapon != None )
			Aggression += 2 * Pawn( Enemy ).Weapon.SuggestDefenseStyle();
		if ( enemyDist > 250 )
			Aggression += 1;
		if ( bIsPlayer && !bNoCharge )
			bNoCharge = ( Aggression < FRand() );

		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		{
			if (Location.Z > Enemy.Location.Z + 140) //tactical height advantage
				Aggression = FMax(0.0, Aggression - 1.0 + CombatStyle);
			else if (Location.Z < Enemy.Location.Z - CollisionHeight) // below enemy
			{
				if ( !bNoCharge && (Aggression > 0) && (FRand() < 0.6) )
				{
			if( bSteelSkin || ( self.IsA( 'NPC' ) && bSnatched ) )
			{
				GotoState( 'ApproachingEnemy' );
			}
			else
				GotoState('Charging');
			return;
		}
		else if ( (enemyDist < 1.1 * (Enemy.Location.Z - Location.Z)) 
			&& !actorReachable(Enemy) ) 
		{
			bNoReach = true;
			aggression = -1.5 * FRand();
		}
			}
		}
	
		if (!bNoCharge && (Aggression > 2 * FRand()))
		{
			if ( bNoReach && (Physics != PHYS_Falling) )
			{
				GotoState('Charging', 'NoReach');
			}
			else
			{
				if( bSteelSkin || ( self.IsA( 'NPC' ) && bSnatched ) )
				{
					GotoState( 'ApproachingEnemy' );
				}
				else
				GotoState('Charging');
			return;
			}
		}

		if (enemyDist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression += 0.4 * FRand();
			 
		enemydir = (Enemy.Location - Location)/enemyDist;
		minDist = FMin(32.0, 2*CollisionRadius);
		if ( bIsPlayer )
			optDist = 15 + FMin(EnemyDist, 64 * (FRand() + FRand()));  
		else 
			optDist = 15 + FMin(EnemyDist, 96 * FRand());
		Y = (enemydir Cross vect(0,0,1));
		if ( Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else 
			enemydir.Z = FMax(0,enemydir.Z);
			
		strafeSize = FMax(-0.7, FMin(0.85, (2 * Aggression * FRand() - 0.3)));
		enemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		bStrafeDir = !bStrafeDir;
		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);
		
		minDest = Location + minDist * (pickdir + enemyPart);
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				success = (HitActor != None);
			}
			if (success)
				Destination = minDest + (pickdir + enemyPart) * optDist;
		}
	
		if ( !success )
		{					
			collSpec.X = CollisionRadius;
			collSpec.Y = CollisionRadius;
			minDest = Location + minDist * (enemyPart - pickdir); 
			HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
			if (HitActor == None)
			{
				success = (Physics != PHYS_Walking);
				if ( !success )
				{
					collSpec.X = FMin(14, 0.5 * CollisionRadius);
					collSpec.Y = collSpec.X;
					HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
					success = (HitActor != None);
				}
				if (success)
					Destination = minDest + (enemyPart - pickdir) * optDist;
			}
			else 
			{
				if ( (enemydir Dot enemyPart) < 0 )
					enemyPart = -1 * enemyPart;
				pickDir = Normal(enemyPart - pickdir + HitNormal);
				minDest = Location + minDist * pickDir;
				collSpec.X = CollisionRadius;
				collSpec.Y = CollisionRadius;
				HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
				if (HitActor == None)
				{
					success = (Physics != PHYS_Walking);
					if ( !success )
					{
						collSpec.X = FMin(14, 0.5 * CollisionRadius);
						collSpec.Y = collSpec.X;
						HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
						success = (HitActor != None);
					}
					if (success)
						Destination = minDest + pickDir * optDist;
				}
			}	
		}
					
		if ( !success )
			GiveUpTactical(bNoCharge);
		else 
		{
			pickDir = (Destination - Location);
			enemyDist = VSize(pickDir);
			if ( enemyDist > minDist + 2 * CollisionRadius )
			{
				pickDir = pickDir/enemyDist;
				HitActor = Trace(HitLocation, HitNormal, Destination + 2 * CollisionRadius * pickdir, Location, false);
				if ( (HitActor != None) && ((HitNormal Dot pickDir) < -0.6) )
					Destination = HitLocation - 2 * CollisionRadius * pickdir;
			}
		}
	}
	
	function EndState()
	{
		bRotateToEnemy = False;
	}

// T_Punch1
// T_Punch2
// T_Punch3
// T_Punch4
Begin:
	if( GetPostureState() == PS_Crouching )
	{
		Goto( 'GetUp' );
	}
	StopMoving();
	StopFiring();
	PlayToWaiting();
	if( NeedToTurn( Enemy.Location ) && Physics != PHYS_Swimming  )
	{

		StopMoving();
//		if ((rotator(Enemy.Location - Location) - Rotation).Yaw < 0)
//			PlayTurnLeft();
//		else
//			PlayTurnRight();
		TurnTo(Enemy.Location);
		PlayToWAiting();
	}
	if( EnemyWithinRange() )
	{	
		StopMoving();
		if( !bLegless && ( bFirstAttackPound ) || ( FRand() < 0.22 && PlayerPawn( Enemy ) != None && !PlayerPawn( Enemy ).bEMPulsed ) )
		{
			bFirstAttackPound = false;
			GotoState( 'GroundPound' );
		}
		else
			GotoState( 'Shocking' );
	}
		PlayAllAnim( 'A_Robot2HShockStart',, 0.1, false );
		FinishAnim( 0 );
		PlayMeleeCombatPunch();
//		FinishAnim( 0 );
		Sleep( 1 + FRand() );
		FinishAnim( 0 );
		KillShockActors();
		PlayerPawn( Enemy ).RemoveDOT( DOT_Electrical );
		PlayAllAnim( 'A_Robot2HShockStop',, 0.1, false );
		FinishAnim( 0 );
		PlayToWaiting();
		if( FRand() < 0.5 )
		{
			Goto( 'BackOff' );
		}
		else
		{
			Sleep( FRand() );
			Goto( 'Backoff' );
		}
	//}
	else
	{
		StopMoving();
		PlayToWaiting();
		if( NextState == '' || NextState == 'ActivityControl' )
			NextState = 'Attacking';
		GotoState( NextState );
	}
// 6 6 6 7
BackOff:
//	log( "BackOff" );
//	bRotateToEnemy = false;
//	PickDestination( false );
//	NotifyMovementStateChange( MS_Running, MS_Waiting );
//
//	MoveTo( Destination );
	Goto( 'Begin' );

GetUp:
	bCrouching = false;
//	FinishAnim( 0 );
	bNoPain = true;
//	PlayBottomAnim( 'None' );
	PlayBottomAnim( 'B_KneelUp',, 0.1, false );
	FinishAnim( 2 );

	//	PlayRise();
//	FinishAnim( 0 );
	//bCrouchingDisabled = true;
	SetPostureState( PS_Standing );
	bCrouchShiftingDisabled = true;
	Goto( 'Begin' );
}

// A_RobotKnockBack
// A_RobotHitGround

state GroundPound
{
	ignores Bump;

	function PunchGround()
	{
		local MeshInstance Minst;
		local int Bone;
		local vector EndTrace, StartTrace;
		local Texture T;
		local class<Material> m;

		//Minst = GetMeshInstance();
		//Bone = Minst.BoneFindNamed( 'Hand_R' );

		if( Bone != 0 )
		{
			StartTrace = Minst.BoneGetTranslate( Bone, true, false );
			StartTrace = Minst.MeshToWorldLocation( StartTrace );
			EndTrace = StartTrace + vect( 0, 0, -256 );

			T = TraceTexture( EndTrace, StartTrace );
			log( "T: "$T );
			m = t.GetMaterial();
			log( "M: "$M );
			HitMaterial( m, 0, StartTrace, StartTrace);
		}
		//	PlaySound( Sound'dnsWeapn.EMP.EMPulse1', SLOT_None, SoundDampening * 0.9 );
		spawn(class'EMPulse', self, , Location);
	}

Begin:
	StopMoving();
	PlayAllAnim( 'A_RobotHitGround',, 0.1, false );
	FinishAnim( 0 );
	GotoState( 'ApproachingEnemy' );
}
*/

state GroundPound
{
	ignores Bump;

	function CreateFistShock()
	{
		MySpawnerA = Spawn( class'dnRobotShockFX_Spawner1', self );
		MySpawnerA.AttachActorToParent( self, true, true );
		MySpawnerA.MountType = MOUNT_MeshBone;
		MySpawnerA.SetPhysics( PHYS_MovingBrush );
		MySpawnerA.MountMeshItem = 'Hand_R';
	}

	function EndState()
	{
		MySpawnerA.Destroy();
		MySpawnerA = None;
	}

	function SparkOff()
	{
		MySpawnerA.Destroy();
		MySpawnerA = None;
	}

	function PunchGround()
	{
		local MeshInstance Minst;
		local int Bone, SurfaceIndex;
		local vector EndTrace, StartTrace;
		local Texture T;
		local class<Material> m;
		local actor Hitactor;
		local vector HitLocation, HitNormal;
		local dnWeaponFX_EMPSphere MySphere;
		local dnRobotShockFX_SparkBeamA MyBeam;
		local PlayerPawn aPlayer;
		local Earthquake EQ;

		Minst = GetMeshInstance();
		Bone = Minst.BoneFindNamed( 'Hand_R' );

		if( Bone != 0 )
		{
			StartTrace = Minst.BoneGetTranslate( Bone, true, false );
			StartTrace = Minst.MeshToWorldLocation( StartTrace );
			EndTrace = StartTrace + vect( 0, 0, -256 );
			HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
			T = TraceTexture( EndTrace,StartTrace,,,,,,,SurfaceIndex );
			m = t.GetMaterial();
			HitMaterial( m, 0, HitLocation, HitNormal, true, SurfaceIndex );
		}
		//Sound'dnsWeapn.EMP.EMPPulse1'
		Spawn( class'EMPulse', self,,HitLocation );
//		foreach radiusactors( class'PlayerPawn', aPlayer, 256 )
//		{
//			aPlayer.AddRotationShake( 0.33 );
//			Spawn( cl
			//bCombo = true;
			//ThrowOther( aPlayer );
//		}
		EQ = Spawn( class'Earthquake',,, Location, Rotation );
		EQ.Magnitude = 1000;
		EQ.Duration = 0.12;
		EQ.bThrowPlayer = true;
		EQ.ImpactForce = 1500;
		EQ.Radius = 256;
		EQ.Trigger( self, self );

//		MyBeam = Spawn( class'dnRobotShockFX_SparkBeamA', self,, HitLocation );
//		MySphere = spawn(class'dnWeaponFX_EMPSphere', self, NameForString( ""$Name$"Sphere" ), HitLocation );
//		log( "MySphere.Tag = "$MySphere.Tag );
		//	MyBeam.Event = NameForString( ""$MySphere.Name$"SphereTargets" );
//		MyBeam.Event = 'dnWeaponFX_EMPSphereTargets';
//		MyBeam.Tag = Name;
//		MyBeam.ResetDestinationActors();
	}

Begin:
	StopMoving();
	CreateFistShock();
	PlayAllAnim( 'A_RobotHitGround',, 0.1, false );
	FinishAnim( 0 );
	MySpawnerA.Destroy();
	MySpawnerA = None;
	if( VSize( Location - Enemy.location ) < 160 )
		GotoState( 'Shocking' );
	else
	GotoState( 'ApproachingEnemy' );
}

function MeleePunchTarget()
{
	MeleeDamageTarget( PunchDamage, (15 * 1000.0 * Normal( Enemy.Location - Location )));
	PlayMeleeImpactSound();
}

function MeleeKickTarget()
{
	MeleeDamageTarget( KickDamage, (15 * 1000.0 * Normal( Enemy.Location - Location )));
	PlayMeleeImpactSound();
}

function FearThisSpot( actor aSpot, optional Pawn Instigator );

function PlayMeleeImpactSound()
{
	local float Decision;

	Decision = FRand();

	if( Decision < 0.5 )
	{
		PlaySound( Sound'A_Impact.Body.ImpactMelee1', SLOT_Talk,,,,, false );
	}
	else
		PlaySound( Sound'A_Impact.Body.ImpactMelee2', SLOT_Talk,,,,, false );
}

function PlayToWaiting( optional float TweenTime )
{
	local float f;
	
	if( bLegless )
	{
		PlayAllAnim( 'A_RobotCrawlIdleA',, TweenTime, true );
		return;
	}
	if( bFire != 0 && ( MiniGunLeft.bReadyToFire || MinigunRight.bReadyToFire ) )
	{
		PlayRobotFireLoop();
	}
	else if( Enemy != None && bFire != 0 )
	{
	//	oadcastmessage( "PLAY TO WAIT 3" );
		PlayAllAnim( 'A_RobotIdleActiveFire',, TweenTime, true );
	}
	else
	{
		if( MinigunLeft != None && MinigunRight != None )
		{
			PlayAllAnim( 'A_RobotIdleActive',, TweenTime, true );
		}
		else if( MinigunLeft == None && MinigunRight != None )
			PlayAllAnim( 'A_RobotIdleActiveR',, TweenTime, true );
		else if( MinigunRight == None && MinigunLeft != None )
			PlayAllAnim( 'A_RobotIdleActiveL',, TweenTime, true );
		else PlayAllAnim( 'A_RobotIdleActiveNG',, TweenTime, true );
	}
}

function PlayRobotFireStart()
{
	if( MinigunLeft != None && MinigunRight != None )
		PlayAllAnim( 'A_RobotFireStart',, 0.1, false );
	else if( MinigunLeft == None && MinigunRight != None )
		PlayAllAnim( 'A_RobotFireStartR',, 0.1, false );
	else if( MinigunRight == None && MinigunLeft != None )
		PlayAllAnim( 'A_RobotFireStartL',, 0.1, false );
}

function PlayRobotFireLoopTop()
{
	if( MinigunLeft != None && MinigunRight != None )
		PlayTopAnim( 'T_RobotFire',, 0.1, true );
	else if( MinigunLeft == None && MinigunRight != None )
		PlayTopAnim( 'T_RobotFireR',, 0.1, true );
	else if( MinigunRight == None && MinigunLeft != None )
		PlayTopAnim( 'T_RobotFireL',, 0.1, true );
}

function PlayRobotFireLoop()
{
	if( GetStateName() == 'ApproachingEnemy' )
	{
		PlayRobotFireLoopTop();
		return;
	}
	else if( GetSequence( 1 ) != '' )
	{
		PlayTopAnim( 'None' );
		DesiredTopAnimBlend = 1;
		TopAnimBlend = 1;
	}
	if( MinigunLeft != None && MinigunRight != None )
		PlayAllAnim( 'A_RobotFire',, 0.1, true );
	else if( MinigunLeft == None && MinigunRight != None )
		PlayAllAnim( 'A_RobotFireR',, 0.1, true );
	else if( MinigunRight == None && MinigunLeft != None )
		PlayAllAnim( 'A_RobotFireL',, 0.1, true );
}

function PlayRobotFireStop()
{
	if( MinigunLeft != None && MinigunRight != None )
		PlayAllAnim( 'A_RobotFireStop',, 0.1, false );
	else if( MinigunLeft == None && MinigunRight != None )
		PlayAllAnim( 'A_RobotFireStopR',, 0.1, false );
	else if( MinigunRight == None && MinigunLeft != None )
		PlayAllAnim( 'A_RobotFireStopL',, 0.1, false );
}

state ApproachingEnemy
{
	function Bump( actor Other )
	{
		if( Other == Enemy )
		{
			MoveTimer = -1.0;
			StopMoving();
			GotoState( 'Attacking' );
		}
		else
			Super.Bump( Other );
	}

	function HitWall( vector HitNormal, actor HitWall )
	{
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('ApproachingEnemy', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function BeginState()
	{
		//log( "---- Approaching enemy state entered" );
	}

Begin:
	
Moving:
	if( Enemy == None || !Enemy.bIsRenderActor || RenderActor(Enemy).Health <= 0 )
		GotoState( 'Idling' );
	else if( ( !LineOfSightTo( Enemy ) || VSize( Enemy.Location - Location ) > AIMeleeRange ) && !CanDirectlyReach( Enemy ) )
	{
		if( !FindBestPathToward( Enemy, true ) )
		{
			PlayToWaiting();
			GotoState( 'WaitingForEnemy' );
		}
		else
		{
			PlayToRunning();
			MoveTo( Destination, GetRunSpeed());
			if( VSize( Enemy.Location - Location ) <= AIMeleeRange && LineOfSightTo( Enemy ) )
			{
				Goto( 'FollowReached' );
			}
			else
			{
				Goto( 'Moving' );
			}
		}
	}
	else if( CanDirectlyReach( Enemy ) && VSize( Enemy.Location - Location ) > AIMeleeRange )
	{
		PlayToRunning();
		Destination = Location - 64 * Normal( Location - Enemy.Location );
		MoveTo( Destination, GetRunSpeed() );
	}
	else if( VSize( Enemy.Location - Location ) <= AIMeleeRange && LineOfSightTo( Enemy ) ) 
		Goto( 'FollowReached' );

	Goto( 'Moving' );

FollowReached:
	StopMoving();
//	PlayToWaiting( 0.12 );
//	PlayTopAnim( 'None' );
	DesiredTopAnimBlend = 1;
	TopAnimBlend = 1;
	
	if( MinigunLeft != None || MinigunRight != None )
		GotoState( 'Firing' );
	else
		GotoState( 'Attacking' );

AdjustFromWall:
	//Enable('AnimEnd');
	TurnTo( Destination );
	StrafeTo(Destination, Focus, GetRunSpeed() ); 
	Destination = Focus; 
	Goto('Begin');
}

state Idling
{
	function SeePlayer( actor SeenPlayer )
	{
		local float Dist;

		if( Pawn( SeenPlayer ).Visibility <= 0 )
			return;

		if( bFixedEnemy )
			return;

		if( bAggressiveToPlayer && ( SeenPlayer.IsA( 'PlayerPawn' ) || SeenPlayer.IsA( 'NPC' ) ) )
		{
			if( AggressionDistance > 0.0 )
			{
				Dist = VSize( Location - SeenPlayer.Location );
				if( Dist > AggressionDistance )
				{
					return;
				}
			}
			HeadTrackingActor = SeenPlayer;
			Enemy = SeenPlayer;
			if( Enemy == OldEnemy )
				GotoState( 'Attacking' );
			else
				GotoState( 'Acquisition' );
			Disable( 'SeePlayer' );
		}
		else if( bSnatched && !bAggressiveToPlayer && SeenPlayer.IsA( 'PlayerPawn' ) )
		{
			Dist = VSize( SeenPlayer.Location - Location );
	
			if( Dist <= AggroSnatchDistance )
			{
				if( !PlayerCanSeeMe()  )
				{
					Disable( 'SeePlayer' );
					Enemy = SeenPlayer;
					NextState = 'Attacking';
					bAggressiveToPlayer = true;
					NextState = 'Attacking';
					GotoState( 'SnatchedEffects' );
					//SetTimer( ), false, 8 );
				}
			}
		}
	}
}

simulated function bool EvalBlinking()
{
    local int bone;
    local MeshInstance minst;
    local vector t;
	local float deltaTime;

	if( bEyesShut )
	{
		CloseEyes();
		return false;
	}
	
	if( bEyelessRight )
	{
		Minst = GetMeshInstance();
		bone = minst.BoneFindNamed( 'Pupil_R' );
		if( bone!=0 )
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		

	}
	if( bEyelessLeft )
	{
		Minst = GetMeshInstance();
		bone = minst.BoneFindNamed('Pupil_L');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
	}

    if( bVisiblySnatched || bSleeping || bEMPed || bEyeless )
	{
		Minst = GetMeshInstance();
		bone = minst.BoneFindNamed('Pupil_L');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		bone = minst.BoneFindNamed('Pupil_R');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		return false;
	}

	minst = GetMeshInstance();
    if( minst==None )
        return( false );

	if( BlinkDurationBase <= 0.0 )
		return( false );

	deltaTime = Level.TimeSeconds - LastBlinkTime;
	LastBlinkTime = Level.TimeSeconds;

	BlinkTimer -= deltaTime;
	if( BlinkTimer <= 0.0 )
	{
		if( !bBlinked )
		{
			bBlinked = true;
			BlinkTimer = BlinkDurationBase + FRand() * BlinkDurationRandom;
		}
		else
		{
			bBlinked = false;
			BlinkTimer = BlinkRateBase + FRand() * BlinkRateRandom;
		}
	}

	if( BlinkChangeTime <= 0.0 )
	{
		if( bBlinked )
			CurrentBlinkAlpha = 1.0;
		else
			CurrentBlinkAlpha = 0.0;
	}
	else
	{
		if( bBlinked )
		{
			CurrentBlinkAlpha += deltaTime / BlinkChangeTime;
			if( CurrentBlinkAlpha > 1.0 )
				CurrentBlinkAlpha = 1.0;
		}
		else
		{
			CurrentBlinkAlpha -= deltaTime / BlinkChangeTime;
			if( CurrentBlinkAlpha < 0.0 )
				CurrentBlinkAlpha = 0.0;
		}
	}

	// blink the left eye
	bone = minst.BoneFindNamed('Eyelid_L');
	if( bone!=0 )
	{
		t = minst.BoneGetTranslate( bone, false, true );
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate( bone, t, false );
	}

	// blink the right eye
	bone = minst.BoneFindNamed( 'Eyelid_R' );
	if( bone!=0 )
	{
		t = minst.BoneGetTranslate( bone, false, true );
		t -= BlinkEyelidPosition * CurrentBlinkAlpha;
		minst.BoneSetTranslate( bone, t, false );
	}

	return( true );
}

state Attacking
{
	function ChooseAttackMode()
	{
		local float DistFromEnemy;

		DistFromEnemy = VSize( Location - Enemy.Location );

		if( MinigunLeft == None && MinigunRight == None )
		{
			if( !PlayerPawn( Enemy ).bEMPulsed && FRand() <= 0.3 )
				GotoState( 'GroundPound' );
			else
				GotoState( 'Shocking' );
		}
		else
		{
			GotoState( 'Firing' );
		}
	}
				
Begin:
	//if( VSize( Enemy.Location - Location ) <= 196 )
		ChooseAttackMode();
	//else
	//	GotoState( 'ApproachingEnemy' );
}

state Acquisition
{
	ignores SeePlayer, SawEnemy;

	function BeginState()
	{
		HeadTrackingActor = Enemy;
		if( !bSteelSkin )
			SpeechCoordinator.RequestSound( self, 'Acquisition' );
	}

	function Timer( optional int TimerNum )
	{
		GotoState( 'Attacking' );
	}

Begin:
	EnableHeadTracking( true );
	EnableEyeTracking( true );
	HeadTrackingActor = Enemy;
Turning:
	if(  MustTurn() )
	{
		Destination = Enemy.Location;
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Turning' );
	}

	if( !bGunsDown )
	{
		PlayRobotFireStart();
		FinishAnim( 0 );
		bGunsDown = true;
	}
	PlayAllAnim( 'A_RobotIdleActiveFire',, 0.1, true );

	Sleep( PreAcquisitionDelay );	
	if( AcquisitionSound != None )
	{
		PlaySound( AcquisitionSound, SLOT_Talk,,,,,true );
	}
	else
	{
		GotoState( 'Attacking' );
	}
	SetTimer( GetSoundDuration( AcquisitionSound )+ 0.25, false );
	if( AcquisitionTopAnim != 'None' )
	{
		PlayTopAnim( AcquisitionTopAnim,, 0.1, false );
	}
	if( AcquisitionBottomAnim != 'None' )
		PlayBottomAnim( AcquisitionBottomAnim,, 0.1, false );
	if( AcquisitionAllAnim != 'None' )
		PlayAllAnim( AcquisitionAllAnim,, 0.1, bLoopAcquisitionAnim );
}

function TakeHitDamage( vector HitLocation, vector HitNormal,
						int HitMeshTri, vector HitMeshBarys, name HitMeshBone, 
						texture HitMeshTex, float HitDamage, Actor HitInstigator,
						class<DamageType> HitDamageType, vector HitMomentum )
{
	local bool bArmorPiercing;
	local meshInstance Minst;
	local int Bone;
	local float EyeDist1, EyeDist2;
	local dnSmokeEffect_RobotDmgA SmokeEffect;

	// Create a metal spark effect.
	spawn( class'dnBulletFX_MetalSpawners',,,HitLocation, Rotator(HitNormal) );

	if ( HitInstigator.bIsPawn &&
		 (Pawn(HitInstigator).Weapon.AmmoType != None) &&
		 Pawn(HitInstigator).Weapon.AmmoType.ArmorPiercing()
		)
		bArmorPiercing = true;

	if ( bArmorPiercing )
	{
		SmokeEffect = spawn( class'dnSmokeEffect_RobotDmgA', Self,, HitLocation );
		SmokeEffect.AttachActorToParent( Self, true, false );
		SmokeEffect.SetPhysics( PHYS_MovingBrush );
		SmokeEffect.MountType = MOUNT_MeshBone;
		SmokeEffect.MountMeshItem = HitMeshBone;
	}
		
	// Handle destruction of Robot eyes- it's almost 100% impossible to hit the pupil bones without the
	// code below providing some extra room for a successful hit. This might be completely temporary.
	Minst = GetMeshInstance();
	Bone = Minst.BoneFindNamed( 'Pupil_L' );
	EyeDist1 = VSize( HitLocation - Minst.MeshToWorldLocation( Minst.BoneGetTranslate( Bone, true, false ) ) );
	Bone = Minst.BoneFindNamed( 'Pupil_R' );
	EyeDist2 = VSize( HitLocation - Minst.MeshToWorldLocation( Minst.BoneGetTranslate( Bone, true, false ) ) );

	if (EyeDist1 < 4.5 && EyeDist1 < EyeDist2) 
		LeftEyeDamageEvent();
	else if(EyeDist2 < 4.5 && EyeDist2 < EyeDist1)
		RightEyeDamageEvent();

	// Change the damage based on the type of ammunition.
	if ( !bArmorPiercing )
	{
		if ( GetStateName() != 'Sleeping' )
			HitDamage *= 0.25;
		else
			HitDamage /= 5;
	}

	if ( Hitdamage > 0 )
		Super.TakeHitDamage( HitLocation, HitNormal, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitDamage, HitInstigator, HitDamageType, HitMomentum );
}

function bool MustTurn()
{
	local float TempRot;

	TempRot = ( Rotator( Destination - Location ) - Rotation ).Yaw;

	if( TempRot != 0 && TempRot != -65536
		&& ( TempRot > 100 || TempRot < -100 ) && ( TempRot < -65636 || TempRot > -65374 ) )
		return true;
	else
		return false;
}

function Tick( float DeltaTime )
{
	local vector LookDir, OffDir;
	local float TempRot;

	if( bIsTurning && !bContinueFire && GetStateName() != 'ApproachingEnemy' )
	{
		if( bFire != 0 )
			RotationRate.Yaw = 19000;
		else
			RotationRate.Yaw = 17000;
		TempRot = ( Rotator( Destination - Location ) - Rotation ).Yaw;
		if( TempRot != 0 && TempRot != -65536
			&& ( TempRot > 100 || TempRot < -100 ) && ( TempRot < -65636 || TempRot > -65374 ) )
		{
			DesiredRotation = rotator( Destination - Location );
			LookDir = vector( Rotation );
	
			OffDir = Normal( LookDir cross vect( 0, 0, 1 ) );

			if( ( OffDir dot( Location - Enemy.Location ) ) > 0 )
			{
				if( !IsTurningRight())
				{
					if( bFire != 0 )
						PlayRobotTurnRight( true );
					else
						PlayRobotTurnRight( false );
				}
			}
			else
			{
				if( !IsTurningLeft() )
				{	
					if( bFire != 0 )
						PlayRobotTurnLeft( true );
					else
						PlayRobotTurnLeft( false );
				}
			}
		}
		else if( IsTurningLeft() || IsTurningRight() )
		{
			if( bFire != 0 && ( MinigunLeft.bReadyToFire || MinigunRight.bReadyToFire ) )
				PlayRobotFireLoop();
			else
				PlayToWaiting( 0.12 );
			bIsTurning = false;
			RotationRate.Yaw = Default.RotationRate.Yaw;
		}
	}

	Super.Tick( DeltaTime );
}

function bool IsTurningLeft()
{
	local name CurrentSeq;

	CurrentSeq = GetSequence( 0 );

	if( CurrentSeq == 'A_RobotFireTurnL45' || CurrentSeq == 'A_RobotFireTurnL45R' || CurrentSeq == 'A_RobotFireTurnL45L' )
		return true;

	if( CurrentSeq == 'A_RobotFireTurnL45NG' || CurrentSeq == 'A_RobotActiveTurnL45' || CurrentSeq == 'A_RobotActiveTurnL45R' || CurrentSeq == 'A_RobotActiveTurnL45L' )
		return true;

	return false;
}

function bool IsTurningRight()
{
	local name CurrentSeq;

	CurrentSeq = GetSequence( 0 );

	if( CurrentSeq == 'A_RobotFireTurnR45NG' || CurrentSeq == 'A_RobotFireTurnR45' || CurrentSeq == 'A_RobotFireTurnR45R' || CurrentSeq == 'A_RobotFireTurnR45L' )
		return true;

	if( CurrentSeq == 'A_RobotFireTurnR45NG' || CurrentSeq == 'A_RobotActiveTurnR45' || CurrentSeq == 'A_RobotActiveTurnR45R' || CurrentSeq == 'A_RobotActiveTurnR45L' )
		return true;

	return false;
}

function PlayRobotTurnLeft( optional bool bFiring )
{
	if( bFiring || bGunsDown )
	{
		if( MinigunLeft != None && MinigunRight != None )
			PlayAllAnim( 'A_RobotFireTurnL45',, 0.13, true );
		else if( MinigunLeft == None && MinigunRight != None )
			PlayAllAnim( 'A_RobotFireTurnL45R',, 0.13, true );
		else if( MinigunRight == None && MinigunLeft != None )
			PlayAllAnim( 'A_RobotFireTurnL45L',, 0.13, true );
		else
			PlayAllAnim( 'A_RobotFireTurnL45NG',, 0.13, true );
	}
	else 
	{
		if( MinigunLeft != None && MinigunRight != None )
			PlayAllAnim( 'A_RobotActiveTurnL45',, 0.13, true );
		else if( MinigunLeft == None && MinigunRight != None )
			PlayAllAnim( 'A_RobotActiveTurnL45R',, 0.13, true );
		else if( MinigunRight == None && MinigunLeft != None )
			PlayAllAnim( 'A_RobotActiveTurnL45L',, 0.13, true );
		else
			PlayAllAnim( 'A_RobotActiveTurnL45NG',, 0.13, true );
	}
}

function PlayRobotTurnRight( optional bool bFiring )
{
	if( bFiring || bGunsDown )
	{
		if( MinigunLeft != None && MinigunRight != None )
			PlayAllAnim( 'A_RobotFireTurnR45',, 0.13, true );
		else if( MinigunLeft == None && MinigunRight != None )
			PlayAllAnim( 'A_RobotFireTurnR45R',, 0.13, true );
		else if( MinigunRight == None && MinigunLeft != None )
			PlayAllAnim( 'A_RobotFireTurnR45L',, 0.13, true );
		else
			PlayAllAnim( 'A_RobotFireTurnR45NG',, 0.13, true );
	}
	else
	{
		if( MinigunLeft != None && MinigunRight != None )
			PlayAllAnim( 'A_RobotActiveTurnR45',, 0.13, true );
		else if( MinigunLeft == None && MinigunRight != None )
			PlayAllAnim( 'A_RobotActiveTurnR45R',, 0.13, true );
		else if( MinigunRight == None && MinigunLeft != None )
			PlayAllAnim( 'A_RobotActiveTurnR45L',, 0.13, true );
		else
			PlayAllAnim( 'A_RobotActiveTurnR45NG',, 0.13, true );
	}
}

// Old things:
state Eyebeam
{
	ignores Bump;

Begin:
	SpawnEyeDots();
	Sleep( 0.5 );
	if( NeedToTurn( Enemy.Location ) )
		TurnToward( Enemy );
	SpawnEyeBeam();
	GotoState( 'ApproachingEnemy' );
}


/*function Tick( float DeltaTime )
{	
	local MeshInstance Minst;
	local rotator HeadRot;
	local int Bone;
	local vector HitLocation, HitNormal, StartLocation, EndLocation;
	
	Super.Tick( DeltaTime );

	if( bPlayerStunned )
	{
		if( CurrentStunTime >= MaxStunTime )
		{
			KillEyeBeams();
		}
		else
			CurrentStunTime += DeltaTime;
	}

	if( LaserBeam1 != None && LaserDestination1.Physics != PHYS_MovingBrush )
	{
		Minst = GetMeshInstance();
		Bone = Minst.BoneFindNamed( 'Head' );
		
		LaserDestination1.SetLocation( Location + ( 14 * vect( 0, 0, 1 ) ) + vector( Minst.MeshToWorldRotation( Minst.BoneGetRotate( Bone ) ) ) * 400 );
	}
	if( LaserBeam2 != None && LaserDestination2.Physics != PHYS_MovingBrush )
	{
		Minst = GetMeshInstance();
		Bone = Minst.BoneFindNamed( 'Head' );
		LaserDestination2.SetLocation( Location + ( 14 * vect( 0, 0, 1 ) ) + vector( Minst.MeshToWorldRotation( Minst.BoneGetRotate( Bone ) ) ) * 400 );
	}
	if( LaserBeam1 != None || LaserBeam2 != None )
	{
		if( CurrentEyeBeamTime >= MaxEyeBeamTime )
		{
			KillEyeBeams();
		}
		else
			CurrentEyeBeamTime += DeltaTime;
	}

	if( ( bEMPed || bSleeping || bLegless ) && FRand() < 0.2 )
	{
		SpawnRandomSpark();
	}
	
	if( bShocking )
	{
		if( Enemy.IsA( 'HumanNPC' ) && Pawn( Enemy ).GetSequence( 0 ) != 'A_PainShake' )
		{
			Pawn( Enemy ).PlayTopAnim( 'None' );
			Pawn( Enemy ).PlayAllAnim( 'A_PainShake', 1.7, 0.1, true );
		}

		if( ShockedTarget == Enemy && PlayerPawn( ShockedTarget ) != None )
			PlayerPawn( Enemy ).AddRotationShake( 0.05 );
		bForcePeriphery = true;
		if( !CanSee( Enemy ) )
			CurrentShockTime = ShockTime;
		bForcePeriphery = false;

		if( CurrentShockTime < ShockTime )
			CurrentShockTime += DeltaTime;
		else
		//if(  VSize( Location - MyThing.Location ) > AIMeleeRange * 1.25 )
		{
			if( ShockedTarget.IsA( 'NPC' ) )
			{
				if( FRand() < 0.5 )
					ShockedTarget.TakeDamage( Pawn( ShockedTarget ).Health, self, ShockedTarget.Location, vector( Rotation ) * 250, class'ElectricalDamage' );
				else
					ShockedTarget.TakeDamage( 50, self, ShockedTarget.Location, vector( Rotation ) * 250, class'ElectricalDamage' );
				ShockedTarget = None;
				Enemy = None;
			}

			CurrentShockTime = 0;
			bShocking = false;
			if( Pawn( Enemy ).GetSequence( 0 ) == 'A_PainShake' ) 
				Pawn( Enemy ).PlayToWaiting();
			GotoState( 'Shocking', 'StopShocking' );
		}
	}
}
*/

function EMPBlast( float EMPtime, optional Pawn Instigator )
{
	Spawn(class'dnEMPFX_Spawner1',self,, Location, Rotation );

	PlaySound( sound'EDFRobotEZapHit01', SLOT_None, SoundDampening * 0.97 );
	if( Enemy == None )
		Enemy = Instigator;

	if( bLegless )
	{
		bShocking = false;
		TakeDamage( 6, Instigator, Location, vect( 0, 0, 0 ), class'EMPDamage' );
		return;
	}

	if( !bEMPulsed && !bSleeping )
	{
		bEMPulsed = true;
		if( HeadTrackingActor != None )
		{
			OldHeadTrackingActor = HeadTrackingActor;
			HeadTrackingActor = None;
		}
		if( GetStateName() != 'EMPEffect' )
			NextState = GetStateName();
		bEMPed = true;
		RotationRate = rot( 0, 0, 0 );
		TakeDamage( Health * 0.5, Instigator, Location, vect( 0, 0, 0 ), class'EMPDamage' );
		EMPCount++;
		if( EMPCount > 1 )
		{
			bSleeping = true;
		}
		GotoState( 'EMPEffect' );
	}
}

function SpawnRandomSpark()
{
	local MeshInstance Minst;
	local int bone, RandBone, Decision;
	local name BoneName;
	local SoftParticleSystem SparkEffect;

	if( bLegless && bEyeless )
		return;

	Minst = GetMeshInstance();

	if( bLegless )
	{
		if( Frand() < 0.5 )
			Bone = Minst.BoneFindNamed( 'Thigh_L' );
		else Bone = Minst.BoneFindNamed( 'Thigh_R' );
	}
	else
	{
		RandBone = Rand( 12 );

		Switch( RandBone )
		{
			Case 0:
				Bone = Minst.BoneFindNamed( 'Pelvis' );
				break;
			Case 1:
				Bone = Minst.BoneFindNamed( 'Thigh_L' );
				break;
			Case 2:
				Bone = Minst.BoneFindNamed( 'Thigh_R' );
				break;
			Case 3:
				Bone = Minst.BoneFindNamed( 'Bicep_R' );
				break;
			Case 4:
				Bone = Minst.BoneFindNamed( 'Bicep_L' );
				break;
			Case 5:
				Bone = Minst.BoneFindNamed( 'Pupil_L' );
				break;
			Case 6:
				Bone = Minst.BoneFindNamed( 'Pupil_R' );
				break;
			Case 7:
				Bone = Minst.BoneFindNamed( 'Lip_U' );
				break;
			Case 8:
				Bone = Minst.BoneFindNamed( 'Jaw' );
				break;
			Case 9:
				Bone = Minst.BoneFindNamed( 'Abdomen' );
				break;
			Case 10:
				Bone = Minst.BoneFindNamed( 'Shin_L' );
				break;
			Case 11:
				Bone = Minst.BoneFindNamed( 'Shin_R' );
				break;
			Default:
				Bone = Minst.BoneFindNamed( 'Chest' );
				break;
		}
	}
	if( FRand() < 0.15 )
	{
		Decision = Rand( 3 );

		if( Decision == 0 )
			PlaySound( Sound'a_edf.Robot.EDFRobotESpark1', SLOT_None, SoundDampening * 0.15 );
		else if( Decision == 1 )
			PlaySound( sound'a_edf.Robot.EDFRobotESpark2', SLOT_None, SoundDampening * 0.15 );
		else if( Decision == 2 )
			PlaySound( sound'a_edf.Robot.EDFRobotESpark3', SLOT_None, SoundDampening * 0.15 );
	}
	SparkEffect = spawn( class'dnRobotSpark', self,, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) ) );
	SparkEffect.AttachActorToParent( self, false, false );
	SparkEffect.MountType = MOUNT_MeshBone;
	SparkEffect.MountMeshItem = BoneName;
	SparkEffect.SetPhysics( PHYS_MovingBrush );
}

function SpawnEyeBeam()
{
	local MeshInstance Minst;
	local int Bone;
	
	Minst = GetMeshInstance();
	Bone = Minst.BoneFindNamed( 'Pupil_L' );

	if (LaserBeam1 == none && !bEyelessRight)
	{
		LaserDestination1 = spawn( class'SniperPoint', self,, Location + vector( Rotation ) * 400 );
		LaserDestination1.DrawType = DT_Mesh;
		LaserDestination1.Mesh = dukemesh'EDF1';
		LaserDestination1.Style = STY_Normal;
		LaserDestination1.DrawScale = 2;

		//
		LaserBeam1 = spawn(class'BeamSystem',Self,, Location + ( BaseEyeHeight * vect( 0, 0, 1 ) ) );
		LaserBeam1.AttachActorToParent( self, true, true );
		Laserbeam1.SetOwner( self );
		LaserBeam1.MountOrigin.Y = 1.15;
		LaserBeam1.MountOrigin.Z = -4.5;
		LaserBeam1.MountType = MOUNT_MeshBone;
		LaserBeam1.MountMeshItem = 'Pupil_R';
		LaserBeam1.SetPhysics( PHYS_MovingBrush );
		LaserBeam1.BeamTexture = texture't_generic.beam12ARC';
		LaserBeam1.BeamReversePanPass = true;
		LaserBeam1.BeamTexturePanX = 0.2;
		LaserBeam1.BeamTexturePanY = 0.0;
		LaserBeam1.BeamTextureScaleX = 5.0;
		LaserBeam1.BeamTextureScaleY = 1.0;
		LaserBeam1.FlipHorizontal = false;
		LaserBeam1.FlipVertical = false;
		LaserBeam1.SubTextureCount = 1;
		LaserBeam1.Style = STY_Translucent;
        LaserBeam1.TesselationLevel = 5;
        LaserBeam1.MaxAmplitude = 100.0;
        LaserBeam1.MaxFrequency = 50.0;
        LaserBeam1.Noise = 0.0;
        LaserBeam1.BeamColor.R = 255;
        LaserBeam1.BeamColor.G = 0;
        LaserBeam1.BeamColor.B = 0;
        LaserBeam1.BeamEndColor.R = 255;
        LaserBeam1.BeamEndColor.G = 0;
        LaserBeam1.BeamEndColor.B = 0;
        LaserBeam1.BeamStartWidth = 1.1;
        LaserBeam1.BeamEndWidth = 1.1;
        LaserBeam1.BeamType = BST_Straight;
        LaserBeam1.DepthCued = true;
		LaserBeam1.Enabled = true;
        LaserBeam1.TriggerType = BSTT_None;
        LaserBeam1.BeamBrokenWhen = BBW_PlayerProximity;
        LaserBeam1.BeamBrokenAction = BBA_TriggerOwner;
        LaserBeam1.NumberDestinations = 1;
        LaserBeam1.DestinationActor[0] = LaserDestination1;
//		LaserBeam1.DestinationOffset[0] = Offset;
		LaserBeam1.RemoteRole = ROLE_None;
		LaserBeam1.BeamBrokenWhenClass = class'Actor';
        LaserBeam1.BeamBrokenIgnoreWorld = true;
		LaserBeam1.bIgnoreBList = true;
	}
	if (LaserBeam2 == none && !bEyelessLeft)
	{
		LaserDestination2 = spawn( class'SniperPoint', self,, Location + vector( Rotation ) * 256 );
		LaserDestination2.Mesh = None;
		LaserBeam2 = spawn(class'BeamSystem',Self,, Location + ( BaseEyeHeight * vect( 0, 0, 1 ) ) );
		LaserBeam2.AttachActorToParent( self, true, true );
		LaserBeam2.MountType = MOUNT_MeshBone;
		LaserBeam2.MountMeshItem = 'Pupil_L';
		LaserBeam2.SetPhysics( PHYS_MovingBrush );
		//serBeam.MountOrigin.X = 26;
	//	LaserBeam2.MountOrigin.X = 10;
	//	LaserBeam2.MountOrigin.X = 20;
	//	LaserBeam2.MountOrigin.X = 20;
		LaserBeam2.MountOrigin.Y = -1.15;
		LaserBeam2.MountOrigin.Z = -4.5;
		LaserBeam2.SetOwner( self );
		LaserBeam2.BeamTexture = texture't_generic.beam12ARC';
		LaserBeam2.BeamReversePanPass = true;
		LaserBeam2.BeamTexturePanX = 0.2;
		LaserBeam2.BeamTexturePanY = 0.0;
		LaserBeam2.BeamTextureScaleX = 5.0;
		LaserBeam2.BeamTextureScaleY = 1.0;
		LaserBeam2.FlipHorizontal = false;
		LaserBeam2.FlipVertical = false;
		LaserBeam2.SubTextureCount = 1;
		LaserBeam2.Style = STY_Translucent;
        LaserBeam2.TesselationLevel = 5;
        LaserBeam2.MaxAmplitude = 100.0;
        LaserBeam2.MaxFrequency = 50.0;
        LaserBeam2.Noise = 0.0;
        LaserBeam2.BeamColor.R = 255;
        LaserBeam2.BeamColor.G = 0;
        LaserBeam2.BeamColor.B = 0;
        LaserBeam2.BeamEndColor.R = 255;
        LaserBeam2.BeamEndColor.G = 0;
        LaserBeam2.BeamEndColor.B = 0;
        LaserBeam2.BeamStartWidth = 1.1;
        LaserBeam2.BeamEndWidth = 1.1;
        LaserBeam2.BeamType = BST_Straight;
        LaserBeam2.DepthCued = true;
		LaserBeam2.Enabled = true;
        LaserBeam2.TriggerType = BSTT_None;
        LaserBeam2.BeamBrokenWhen = BBW_PlayerProximity;
        LaserBeam2.BeamBrokenAction = BBA_TriggerOwner;
        LaserBeam2.NumberDestinations = 1;
        LaserBeam2.DestinationActor[0] = LaserDestination2;
//		LaserBeam2.DestinationOffset[0] = Offset;
		LaserBeam2.RemoteRole = ROLE_None;
		LaserBeam2.BeamBrokenWhenClass = class'Actor';
        LaserBeam2.BeamBrokenIgnoreWorld = true;
		LaserBeam2.bIgnoreBList = true;
	}
}

function SpawnEyeDots()
{
	local MeshInstance Minst;
	local int Bone;

	Minst = GetMeshInstance();
	Bone = Minst.BoneFindNamed( 'Pupil_L' );
	if( !bEyelessRight )
	{
		Dot1 = Spawn( class'RobotEye', self,, Location );
		Dot1.AttachActorToParent( self, true, true );
		Dot1.MountType = MOUNT_MeshBone;
		Dot1.MountMeshItem = 'Pupil_R';
		Dot1.MountOrigin.Y = 1.15;
		Dot1.MountOrigin.Z = -4.5;
		Dot1.SetPhysics( PHYS_MovingBrush );
		Dot1.SetRotation( rot( 32500, 0, 0 ) );
	}
	if( !bEyelessLeft )
	{
		Dot2 = Spawn( class'RobotEye', self,, Location );
		Dot2.AttachActorToParent( self, true, true );
		Dot2.MountType = MOUNT_MeshBone;
		Dot2.MountMeshItem = 'Pupil_L';
		Dot2.MountOrigin.Y = -1.15;
		Dot2.MountOrigin.Z = -4.5;
		Dot2.SetPhysics( PHYS_MovingBrush );
		Dot2.SetRotation( rot( 32500, 0, 0 ) );
	}
}

state Shocking
{
	ignores Bump;

	function BeginState()
	{
		//log( self$"== Shocking state entered" );
	}
	
	function EndState()
	{
		KillShockActors();
	}


StopShocking:
	FinishAnim( 0 );
	KillShockActors();
	PlayerPawn( Enemy ).RemoveDOT( DOT_Electrical );
	if( !bLegless )
		PlayAllAnim( 'A_Robot2HShockStop',, 0.1, false );
	else PlayAllAnim( 'A_RobotCrawlShockStop',, 0.1, false );
	FinishAnim( 0 );
	PlayToWaiting();
	bShocking = false;
	GotoState( 'ApproachingEnemy' );

Begin:
	if( !bLegless )
		PlayAllAnim( 'A_Robot2HShockStart', 1.5, 0.1, false );
	else
		PlayAllAnim( 'A_RobotCrawlShockStart', 1.3, 0.1, false );
	if( !bLegless )
	{
		MySpawnerA = Spawn( class'dnRobotShockFX_Spawner1', self );
		MySpawnerA.AttachActorToParent( self, true, true );
		MySpawnerA.MountType = MOUNT_MeshBone;
		MySpawnerA.SetPhysics( PHYS_MovingBrush );
		MySpawnerA.MountMeshItem = 'Hand_L';
	}

	MySpawnerB = Spawn( class'dnRobotShockFX_Spawner1', self );
	MySpawnerB.AttachActorToParent( self, true, true );
	MySpawnerB.MountType = MOUNT_MeshBone;
	MySpawnerB.SetPhysics( PHYS_MovingBrush );
	MySpawnerB.MountMeshItem = 'Hand_R';

	FinishAnim( 0 );
	if( bLegless )
	{
		PlayAllAnim( 'A_RobotCrawlShockLoop',, 0.1, false );
	}
	else
		PlayAllAnim( 'A_Robot2HShockLoop',, 0.2, true );
	ShockedTarget = ShockTarget();

	if( PlayerPawn( Enemy ) != None && ShockedTarget == Enemy )
		PlayerPawn( Enemy ).AddDOT( DOT_Electrical, ShockTime, 0.25, 2.0, Self );
	else if( ShockedTarget.IsA( 'dnDecoration' ) )
		ShockedTarget.TakeDamage( 50, self, ShockedTarget.Location, vector( Rotation ) * 250, class'ElectricalDamage' );
}

function PlayTopAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping, optional bool bNoCallAnimEx, optional bool bCanInterrupt )
{
	GetMeshInstance();
	if (MeshInstance==None)
		return;
	
	if ((MeshInstance.MeshChannels[2].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(2))))

	if ((MeshInstance.MeshChannels[ 1 ].AnimSequence == Sequence) && ((Sequence == 'None') || (IsAnimating( 1 ))) && !bCanInterrupt)
		return; // already playing
	
	if (Sequence=='None')
	{
		if ( bLaissezFaireBlending )
		{
			MeshInstance.MeshChannels[1].AnimSequence	= 'None';
			MeshInstance.MeshChannels[1].AnimBlend		= 1.0;

		}
		else
		{
			DesiredTopAnimBlend = 1.0;
			TopAnimBlend = 0.0;
			if (TweenTime == 0.0)
				TopAnimBlendRate = 5.0;
			else
				TopAnimBlendRate = 0.5 / TweenTime;
        
		}
		return; // don't actually play the none anim, we want to shut off the channel gradually, the ticking will set it to none later
	}
	else if (MeshInstance.MeshChannels[1].AnimSequence=='None')
	{
		DesiredTopAnimBlend = 0.0;
		TopAnimBlend = 1.0;
		if (TweenTime == 0.0)
			TopAnimBlendRate = 5.0;
		else
			TopAnimBlendRate = 0.5 / TweenTime;
	}
	else
	{
		TopAnimBlend = 0.0;
		DesiredTopAnimBlend = 0.0;
		TopAnimBlendRate = 1.0;
	}

	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime, , 1);
	else
		PlayAnim(Sequence, Rate, TweenTime, 1);
}

defaultproperties
{
	CarcassType=Class'RobotPawnCarcass'
    WalkingSpeed=0.3
	Texture=Texture'm_characters.edf_hweponchrmRC'
	bAggressiveToPlayer=true
	EgoKillValue=8
    RotationRate=(Pitch=3072,Yaw=32000,Roll=2048)
    Mesh=DukeMesh'c_characters.EDF_heavyweps'
    WeaponInfo(0)=None
    Health=200
    BaseEyeHeight=26.000000
    EyeHeight=26.000000
    GroundSpeed=420.000000
    bIsHuman=True
    CollisionRadius=17.000000
    CollisionHeight=39.000000
    bSnatched=false
	//BloodHitDecalName="DNGAme.DNBloodHit"
	BloodPuffName="dnParticles.dnRobotSpark"
	BloodHitDecalName="DNGAme.DNOilHit"
	bSteelSkin=true
    PunchDamage=10
    KickDamage=16
	AIMeleeRange=512
	ShockTime=5
    HeatIntensity=0
    bFirstAttackPound=true
	HitPackageClass=class'HitPackage_Steel'
	HitPackageLevelClass=class'HitPackage_DukeLevel'
    VisibilityRadius=8000
}
