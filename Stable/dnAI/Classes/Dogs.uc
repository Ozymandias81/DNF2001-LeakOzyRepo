//=============================================================================
// Dogs.
//=============================================================================
class Dogs expands BonedCreature;

#exec OBJ LOAD FILE=..\sounds\a_creatures.dfx

// DogGrowl03
// DogGrowl04
// DogGrowl05
// DogGrowl06
// DogSniff01
// DogWhine02
// DogWhine05
// DogWhine07

var Tentacle MyTentacle;

/* 
Dog Anims:
	A_PainB
	A_PainA
	A_BarkA
	A_Run
	A_DeathSideA
	A_Walk
	A_IdleStandA
	A_Situp
	T_BiteA
	T_BiteB
	A_Jump
	A_JumpAir
	A_JumpLand
	A_IdleSitA
	A_InLickFloor
	A_LickFloor
	A_OutLickFloor
	A_IdleStandSniff
	T_PainA
	A_JumpLand
	A_JumpAir
	A_Jump
	A_BiteA
	A_BiteB


*/
var bool bSitting; 
var vector StartLocation;
var float WanderRadius;
var actor InterestActor;
var Pawn User;

var() bool bCanFetch;
var() name MasterTag;
var HumanNPC Master;
var() float PulseFrequency;
var() float PulseRadius;
var() bool bBloodSeeker;
var() bool bStayIdle;
	
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation,
					vector Momentum, class<DamageType> DamageType)
{
	Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	PlayDamage();
}

function PlayDamage()
{
	if( FRand() < 0.7 )
		PlaySound( sound'DogWhine05', SLOT_Misc, SoundDampening * 0.6 );
	else
		PlaySound( sound'DogWhine07', SLOT_Misc, 0.85 );

	if( FRand() < 0.5 )
		PlayAllAnim( 'A_PainA',, 0.1, false );
	else
		PlayAllAnim( 'A_PainB',, 0.1, false );

	if( GetStateName() != 'TakeHit' ) 
		NextState = GetStateName();
	else
		if( Enemy != None )
			NextState = 'Hunting';
		else
			NextState = 'Roaming';
	if( Health > 0 )
		GotoState( 'TakeHit' );
}

function EnterControlState_Dead()
{
	bHidden = true;
	Destroy();
}

function PostBeginPlay()
{
	bCanOpenDoors = true;
	Super.PostBeginPlay();
}

function PreSetMovement()
{
	Super.PreSetMovement();
	bCanOpenDoors = true;
}


function TriggerHate()
{
	local actor NewEnemy;

	foreach allactors( class'Actor', NewEnemy, HateTag )
	{
		Enemy = NewEnemy;
		HeadTrackingActor = Enemy;
		EnableHeadTracking( true );
		SetEnemy( NewEnemy );
		GotoState( 'Hunting' );
		break;
	}
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc == None )
		return None;
	carc.Initfor(self);
	return carc;
}

	function SeePlayer( actor SeenPlayer )
	{
		if( bAggressiveToPlayer && SeenPlayer.IsA( 'PlayerPawn' ) && !bFixedEnemy )
		{
			SetEnemy( SeenPlayer );
		}
	}

state Pursuit
{
	function BeginState()
	{
		//log( self$" Pursuit state entered." );
	}

Begin:
	TurnToward( Enemy );
	if( LineOfSightTo( Enemy ) )
	{
		PlayToRunning();
		if( VSize( Enemy.Location - Location ) > 96 )
			MoveTo(Enemy.Location + 96 * normal( Location - Enemy.Location ), RunSpeed );
		GotoState( 'MeleeCombat' );
	}
	else
		if( !FindBestPathToward( Enemy, true ) )
		{
			GotoState( 'Roaming' );
		}
		else
		{
			PlayToRunning();
			MoveTo( Destination, RunSpeed );
			if( VSize( Enemy.Location - Location ) < 96 && LineOfSightTo( Enemy ) )
			{
				GotoState( 'MeleeCombat' );
			}
			else
				Goto( 'Begin' );
		}
}

function PlayRunning()
{
	PlayAllAnim( 'A_Run', 1.2, 0.11, true );
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal, TargetPoint;
	local actor HitActor;
	
	// check if still in melee range
	If ( (VSize(Enemy.Location - Location) <= 32 * 1.4 + Enemy.CollisionRadius + CollisionRadius)
		&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Enemy.Location.Z) 
			<= FMax(CollisionHeight, Enemy.CollisionHeight) + 0.5 * FMin(CollisionHeight, Enemy.CollisionHeight))) )
	{	
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location, false);
		if ( HitActor != None )
		{
			return false;
		}

		Enemy.TakeDamage(hitdamage, Self,HitLocation, pushdir, class'CrushingDamage');
		return true;
	}
	return false;
}

state MeleeCombat
{
	ignores SeePlayer;

	function BeginState()
	{
		//log( self$" entered meleecombat state" );
	}

	function HitWall( vector HitNormal, actor Wall )
	{
		Focus = Destination;
		if( PickWallAdjust() )
		{
			GotoState( 'MeleeCombat', 'AdjustFromWall' );
		}
	}

	function Bump( Actor Other )
	{
		local vector Momentum;

		if( Physics == PHYS_Falling )
		{
			Momentum = 30000 * Normal( Velocity );
			Momentum.Z = 0;
			MeleeDamageTarget( 10, Momentum );
		}
	}

Begin:
	//HeadTrackingActor = Enemy;
	TurnToward( Enemy );
	if( VSize( Enemy.Location - Location ) > 96 && VSize( Enemy.Location - Location ) < 164 && FRand() < 0.12 )
	{
		PlayAllAnim( 'A_Jump', 2.3, 0.1, false );
		FinishAnim( 0 );
		bNoLipSync = true;
		if( FRand() < 0.33 )
			PlaySound( sound'DogGrowl04', SLOT_Misc, SoundDampening * 0.85 );

		PlayAllAnim( 'A_JumpAirBite',, 0.1, true );
		SetPhysics( PHYS_Falling );
		Velocity = Normal( Enemy.Location - Location ) * 450;
		Velocity.Z += 220;
		WaitForLanding();
		bNoLipSync = false;
		PlayAllAnim( 'A_JumpLand',1.5, 0.1, false );
		FinishAnim( 0 );
	}
	else
	{
		if( VSize( Enemy.Location - Location ) > 64 )
		{
			PlayRunning();
			MoveTo(Enemy.Location + 64 * normal( Location - Enemy.Location ), RunSpeed );
		}
	}

	if( VSize( Enemy.Location - Location ) > 72 )
		Gotostate( 'Hunting' );

Fighting:
	if( Enemy == None )
	{
		GotoState( 'Roaming' );
	}
	Acceleration = vect( 0, 0, 0 );
	TurnToward( Enemy );
	PlayToWaiting();
	if( VSize( Location - Enemy.Location ) < 128 && FRand() < 0.4 )
	{
		bRotateToEnemy = true;
		MyTentacle = CreateTentacle( vect( 0, 0, 0 ), rot( -16384, 0, 0 ), 'tail_3' );
		MyTentacle.GotoState( 'DogTentacle' );
		PlayAllAnim( 'A_TentTailAttacK1',, 0.1, false );
		FinishAnim( 0 );
		bRotateToEnemy = False;
	}
	else
	if( MeleeDamageTarget( 5, 10 * Normal( Velocity ) ) )
	{
		if( FRand() < 0.5 )
			PlaySound( sound'DogGrowl04', SLOT_Misc, SoundDampening * 0.95 );
		else
			PlaySound( sound'DogGrowl03', SLOT_Misc, SoundDampening * 0.95 );
		PlayAllAnim( 'A_Growl',, 0.1, true );
		if( FRand() < 0.5 )
		{
			PlayTopAnim( 'T_BiteB',, 0.1, false );
		}
		else
		{
			PlayTopAnim( 'T_BiteA',, 0.1, false );
		}
		//Self.PlaySound( sound'DogGrowl04',, SoundDampening );

		FinishAnim( 1 );
	}
	else
	if( FRand() < 0.07 )
	{
		TurnToward( Enemy );
		PlayAllAnim( 'A_Growl',, 0.1, true );
		Sleep( 0.25 );
		FinishAnim( 0 );
	}
	PlayAllAnim( 'A_GrowlBarkA',, 0.1, true );
	Sleep( FRand() );
	if( VSize( Enemy.Location - Location ) > 64 )
		GotoState( 'Hunting' );
	else
		Goto( 'Fighting' );

SpecialNavig:
	if (MoveTarget == None)
	{
		MoveTo(Destination, RunSpeed );
	}
	else
	{
		MoveToward(MoveTarget, RunSpeed );
	}
	Goto('Begin');

AdjustFromWall:
	PlayToRunning();
//	StrafeTo(Destination, Focus, GetRunSpeed() ); 
	MoveTo( Destination, RunSpeed );
	Destination = Focus; 
	if( MoveTarget != None )
		Goto( 'SpecialNavig' );
	else
	//	MoveTo(Destination, GetRunSpeed() );
	Goto('Begin');
}
		
function Actor FindPawn()
{
	local actor a;

	foreach allactors( class'Actor', A )
	{
		if( A.IsA( 'PlayerPawn' ) )
			return A;
	}
}

function bool SetEnemy(Actor NewEnemy)
{
	Enemy = NewEnemy;
	if( Enemy != none )
		GotoState( 'Acquisition' );
	else return false;
}

state Acquisition
{
	ignores SeePlayer, Bump;

	function Timer( optional int TimerNum )
	{
		GotoState( 'Hunting' );
	}
	
Begin:
	StopMoving();
	HeadTrackingActor = Enemy;
	EnableHeadTracking( true );
	PlayToWaiting();
	TurnToward( Enemy );
	Sleep( 0.2 );
	if( FRand() < 0.5 )
	{
		PlayAllAnim( 'A_Growl',, 0.1, true );
		PlaySound( sound'doggrowl05', SLOT_Misc, SoundDampening * 0.87 );
		SetTimer( GetSoundDuration( sound'DogGrowl05' ), false );
	}
	else
		GotoState( 'Hunting' );
//	Sleep( 0.5 );
//	GotoState( 'Hunting' );
	
FaceEnemy:
	TurnToward( Enemy );
	Sleep( 0.2 );
	Goto( 'FaceEnemy' );
}

state Attacking
{
	function BeginState()
	{
		log( self$" Attacking state entered. My enemy is now: "$Enemy );
		GotoState( 'Hunting' ); 
	}
}


function Used( actor Other, Pawn EventInstigator )
{
	User = EventInstigator;
	GotoState( 'Roaming', 'Used' );
}

function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	// A_PainA
	PlaySound( sound'DogWhine02', SLOT_Misc, 1.0, true );

	if( FRand() < 0.5 )
		PlayAllAnim( 'A_DeathSideA',, 0.1, false );
	else
		PlayAllAnim( 'A_DeathSideB',, 0.1, false );
}


function actor GetInterestPoint()
{
	local actor A;

	foreach radiusactors( class'Actor', A, PulseRadius )
	{
		if( A.IsA( 'CreatureChunks' ) )
		{
			return A;
		}
		else
		if( A.IsA( 'dnBloodPool' ) && A.DrawScale > 0.3 )
		{
			return A;
		}
		break;
	}
}

function PlayToSit()
{
	bSitting = true;
	PlayAllAnim( 'A_SitDown',, 0.2, false );
}

function PlaySitting()
{
	bSitting = true;
	PlayAllAnim( 'A_IdleSitA',, 0.2, true );
}

function PlayToStand()
{
	bSitting = false;
	PlayAllAnim( 'A_SitUp',, 0.2, false );
}

function PlayWaiting()
{
	bSitting = false;
	PlayAllAnim( 'A_IdleStandA',, 0.2, true );
}

function PlayToWaiting( optional float TweenTime )
{
	bSitting = false;
	PlayAllAnim( 'A_IdleStandA',, 0.2, true );
}

function PlayToWalking()
{
	PlayAllAnim( 'A_Walk',, 0.2, true );
}

function PlayToRunning()
{
	PlayAllAnim( 'A_Run',1.2, 0.2, true );
}

function StopMoving()
{
	Acceleration *= 0;
	Velocity *= 0;
}

state TakeHit
{
Begin:
//	StopMoving();	
	if( FRand() < 0.5 )
		PlayTopAnim( 'T_PainA',, 0.1, false );
	else PlayTopAnim( 'T_PainB',, 0.1, false );
	FinishAnim( 0 );
	GotoState( NextState );
}

simulated function bool EvalBlinking()
{
    local int bone;
    local MeshInstance minst;
    local vector t;
	local float deltaTime;
    
	minst = GetMeshInstance();
    if (minst==None)
        return(false);

	if (BlinkDurationBase <= 0.0)
		return(false);

	deltaTime = Level.TimeSeconds - LastBlinkTime;
	LastBlinkTime = Level.TimeSeconds;

	BlinkTimer -= deltaTime;
	if (BlinkTimer <= 0.0)
	{
		if (!bBlinked)
		{
			bBlinked = true;
			BlinkTimer = BlinkDurationBase + FRand()*BlinkDurationRandom;
		}
		else
		{
			bBlinked = false;
			BlinkTimer = BlinkRateBase + FRand()*BlinkRateRandom;
		}
	}

	if (BlinkChangeTime <= 0.0)
	{
		if (bBlinked)
			CurrentBlinkAlpha = 1.0;
		else
			CurrentBlinkAlpha = 0.0;
	}
	else
	{
		if (bBlinked)
		{
			CurrentBlinkAlpha += deltaTime/BlinkChangeTime;
			if (CurrentBlinkAlpha > 1.0)
				CurrentBlinkAlpha = 1.0;
		}
		else
		{
			CurrentBlinkAlpha -= deltaTime/BlinkChangeTime;
			if (CurrentBlinkAlpha < 0.0)
				CurrentBlinkAlpha = 0.0;
		}
	}

	// blink the left eye
	bone = minst.BoneFindNamed('Eyelid_L');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	// blink the right eye
	bone = minst.BoneFindNamed('Eyelid_R');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	return(true);
}

function bool ReactToSniff()
{
	local PlayerPawn P;

	foreach radiusactors( class'PlayerPawn', P, 750 )
	{
		if( bAggressiveToPlayer && ActorReachable( P ) )
		{
			SetEnemy( P );
			return true;
		}
	}
	return false;
}

state Idling
{
begin:
	PlayToWaiting();
	if( bStayIdle )
	{
		if( FRand() < 0.4 )
		{
			PlayAllAnim( 'A_IdleStandSniff',, 0.1, false );
			Sleep( 0.12 );
			PlaySound( sound'DogSniff01', SLOT_Misc, 100.0, true );
			FinishAnim( 0 );
			if( !ReactToSniff() )
			{
				if( FRand() < 0.24 )
				{
					PlaySound( sound'doggrowl05', SLOT_Misc, SoundDampening * 0.67 );
				}
			}
		}
	}
	PlayToWaiting();
	Sleep( 2 + Rand( 5 ) );
	Goto( 'Begin' );
}

state Roaming
{
	function Bump( actor Other )
	{
		if( InterestActor != None )
		{
			Acceleration = vect( 0, 0, 0 );
			Velocity *= 0;
			PlayToWaiting();
			if( FRand() < 0.25 )
			{
				InterestActor = None;
				GotoState( 'Roaming' );
			}
			return;
		}
		else

		if( Other.IsA( 'PlayerPawn' ) )
		{
			//HeadTrackingActor = Other;
			GotoState( 'Roaming', 'Barking' );
		}
		else
			Super.Bump( Other );
	}

	function bool TestDirection(vector dir, out vector pick)
	{	
		local vector HitLocation, HitNormal, dist;
		local float minDist;
		local actor HitActor;

		minDist = FMin( 150.0, 4 * CollisionRadius );
		pick = dir * ( minDist + ( 450 + 12 * CollisionRadius ) * FRand());

		HitActor = Trace( HitLocation, HitNormal, Location + pick + 1.5 * CollisionRadius * dir , Location, false );
		
		if( HitActor != None )
		{
			pick = HitLocation + ( HitNormal - dir ) * 2 * CollisionRadius;
			HitActor = Trace( HitLocation, HitNormal, pick , Location, false );
			if ( HitActor != None )
			{
				return false;
			}
		}
		else
		{
			pick = Location + pick;
		}

		dist = pick - Location;
		if( Physics == PHYS_Walking )
		{
			dist.Z = 0;
		}
		return ( VSize( dist ) > minDist ); 
	}
			
	function PickDestination( optional bool bSortie )
	{
		local vector pick, pickdir;
		local bool success;
		local float XY, Dist;
	
		if ( WanderRadius > 0 )
		{
			pickDir = StartLocation - Location;
			dist = VSize(pickDir);
			if ( dist > WanderRadius )
			{
				pickdir = pickDir/dist;
				if ( TestDirection(pickdir, Destination ) )
				{
					return;
				}
			}
		}

		XY = FRand();
		if( XY < 0.3 )
		{
			pickdir.X = 1;
			pickdir.Y = 0;
		}
		else if( XY < 0.6 )
		{
			pickdir.X = 0;
			pickdir.Y = 1;
		}
		else
		{
			pickdir.X = 2 * FRand() - 1;
			pickdir.Y = 2 * FRand() - 1;
		}

		pickdir.Z = 0;
		if( XY >= 0.6 )
		{
			pickdir = Normal( pickdir );
		}

		success = TestDirection( pickdir, pick );
		if( !success )
		{
			success = TestDirection(-1 * pickdir, pick);
		}
		if( success )	
		{
			Destination = pick;
		}
		else
			GotoState('Roaming', 'Turn');
	}

	function bool FoundSomethingToLookAt()
	{
		local Pawn P;

		foreach radiusactors( class'pawn', p, 3500 )
		{
			HeadTrackingActor = P;
			return true;
		}
		return false;
	}

	function SetTurn()
	{
		local float YawErr;

		Destination = Location + 20 * VRand();

		DesiredRotation = rotator(Destination - Location);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		YawErr = (DesiredRotation.Yaw - (Rotation.Yaw & 65535)) & 65535;
		if ( (YawErr > 16384) && (YawErr < 49151) )
		{
			if ( YawErr > 32768 )
				DesiredRotation.Yaw = DesiredRotation.Yaw + 16384;
			else
				DesiredRotation.Yaw = DesiredRotation.Yaw - 16384;
			Destination = Location + 20 * vector(DesiredRotation);
		}
	}
	
	function Timer( optional int TimerNum )
	{
		local actor A;

		if( TimerNum == 3 )
		{
			GotoState( 'Roaming', 'Growling' );
		}
		else
		{
			InterestActor = None;
			InterestActor = GetInterestPoint();

			if( InterestActor != None && Health > 0 )
			{
				GotoState( 'Roaming', 'MoveToInterestPoint' );
				SetTimer( 0.0, false );
			}
		}
	}

	function BeginState()
	{
		//SetTimer( PulseFrequency, true );
	//	EnableHeadTracking( true );
		bAvoidLedges = false;
		MinHitWall = -0.2;
		Enemy = None;
		Disable('AnimEnd');
		//JumpZ = -1;
		StartLocation = Location;
		if (Enemy == None)
		{
			Disable('EnemyNotVisible');
			Enable('SeePlayer');
		}
		else
		{
			Enable('EnemyNotVisible');
			Disable('SeePlayer');
		}
	}


	function EndState()
	{
		//if ( Enemy.bIsPlayer )
		//	MakeNoise(1.0);
	//	JumpZ = Default.JumpZ;
		bAvoidLedges = false;
		MinHitWall = Default.MinHitWall;
	}

Begin:
Wander: 
	WaitForLanding();

/*
	if( InterestActor != None && InterestActor.IsA( 'Decoration' ) )
	{
		PlayCrawling();
	    MoveTo( InterestActor.Location, 0.4 ); //+ VRand() * 16 );
		TurnTo( InterestActor.Location );
		InterestActor.AttachActorToParent( self, false, false );
		InterestActor.MountType = MOUNT_Actor;
		InterestActor.SetPhysics( PHYS_MovingBrush );
		bCanFly = true;
		if( MyNest != None )
		{
			MoveToward( MyNest );
			InterestActor.AttachActorToParent( none, false, false );
			InterestActor = None;
			PulseFrequency = Default.PulseFrequency;
			WanderRadius = Default.WanderRadius;
		}
	}
*/
	bCanFly = False;
	SetPhysics( PHYS_Walking );
	PickDestination();
Moving:
	Enable('Bump');
//	PlayToSit();
//	FinishAnim( 0 );
	PlayToRunning();
	MoveTo(Destination, RunSpeed );

Pausing:
/*
	Acceleration = vect(0,0,0);
//	TweenAnim('Breath', 0.3);
	if (FRand() < 0.5)
	{
		FinishAnim( 0 );
//		SetPhysics( PHYS_Flying );
		//Velocity.Z += 650;
		PickDestination();
		PlayAllAnim('Hover',, 0.1, true );
		MoveTo( Destination );
		SetPhysics( PHYS_Falling );
		Sleep( 1.25 );
		Goto( 'Wander' );
//		SetPhysics( PHYS_Falling );
//		log( "** WaitForLanding" );
//		WaitForLanding();
//		SetPhysics( PHYS_Walking );
	}
*/
	if( FRand() < 0.25 )
	{
		if( FRand() < 0.35 && !bSitting )
		{
			PlayToSit();
			FinishAnim( 0 );
			PlaySitting();
		}
		if( !bSitting )
			PlayToWaiting();
		if( FoundSomethingToLookAt() )
		{
			Sleep( 8.0 );
		}
		else
			Sleep( 2.5 );
		if( bSitting )
		{
			PlayToStand();
			FinishAnim( 0 );
			PlayToWaiting();
		}
		Sleep( 3.0 );
		if( FRand() < 0.3 )
			GotoState( 'Idling' );
	}

	Goto('Wander');

ContinueWander:
	FinishAnim();
	Goto('Wander');

Turn:
	Acceleration = vect( 0,0,0 );
	SetTurn();
	TurnTo( Destination );
	Goto( 'Pausing');

Barking:

	Disable( 'Bump' );
	StopMoving();
	PlayAllAnim( 'A_BarkA',, 0.2, false );
	FinishAnim( 0 );
	Enable( 'Bump' );
	Goto( 'Wander' );

Growling:
	if( bSitting )
	{
		PlayToStand();
		FinishAnim( 0 );
		PlayToWaiting();
		Sleep( 0.1 );
		PlayAllAnim( 'A_Growl',, 0.2, true );
		Sleep( 4.2 );
		PlayToWaiting();
	}
	GotoState( 'Roaming' );

MoveToInterestPoint:
	if( LineOfSightTo( InterestActor ) && ActorReachable( InterestActor ) )
	{
		if( bSitting )
		{
			PlayToStand();
			FinishAnim( 0 );
		}
		StopMoving();
		PlaySound( sound'DogSniff01', SLOT_Misc, 1.0, true );
		PlayAllAnim( 'A_IdleStandSniff',, 0.1, false );
		FinishAnim( 0 );

		PlayAllAnim( 'A_Walk',, 0.2, true );
		Destination = InterestActor.Location + ( VRand() * 32 );
		Destination.Z = 0;
		MoveTo( Destination, 0.075 );

		PlayAllAnim( 'A_InLickFloor',, 0.2, false );
		FinishAnim( 0 );
		PlayAllAnim( 'A_LickFloor',, 0.2, true );
		Sleep( 4 + Rand( 6 ) );
		InterestActor = None;
		GotoState( 'Roaming' );
	}
	else if( !FindBestPathToward( InterestActor, false ) )
	{
		InterestActor = None;
		GotoState( 'Roaming' );
	}
	else 
	{
		if( bSitting )
			PlayToStand();
		FinishAnim( 0 );
		PlayAllAnim( 'A_Walk',, 0.2, true );
		MoveTo( Destination, 0.075 );
		if( VSize( Location - InterestActor.Location ) > 32 )
		{
			Goto( 'MoveToInterestPoint' );
		}
		PlayAllAnim( 'A_InLickFloor',, 0.2, false );
		FinishAnim( 0 );
		PlayAllAnim( 'A_LickFloor',, 0.2, true );
		Sleep( 4 + Rand( 6 ) );
		InterestActor = None;
		GotoState( 'Roaming' );
	}
Used:
	HeadTrackingActor = User;
	TurnToward( User );
	Acceleration *= 0;
	MoveTimer = -1.0;
	if( !bSitting )
	{
		PlayToSit();
		FinishAnim( 0 );
		PlaySitting();
	}
	
	SetTimer( 0.5, false );
}

function FollowMaster()
{
	GotoState( 'Obeying', 'Wander' );
}

state Obeying
{
	function BeginState()
	{
		//HeadTrackingActor = Master;
	//	log( "NewHeadTrackingActor: "$HeadTrackingActor );
		if( Master == None || MasterTag == '' )
		{
			GotoState( 'Roaming' );
		}
	}

	function PickDestination()
	{
		if ( !LineOfSightTo( Master ) )
		{
			MoveTarget = FindPathToward( Master, false );
			if ( MoveTarget != None )
			{
				Destination = MoveTarget.Location;
				return;
			}
		}		
		Destination = Master.Location + ( VRand() * 128 );
		Destination.Z = 0;
	//	Destination = Master.Destination;
	}

	function HumanNPC GetMaster()
	{
		local HumanNPC NPC;

		foreach allactors( class'HumanNPC', NPC, MasterTag )
		{
			return NPC;
		}
	}
Begin:
	Goto( 'Wander' );
Wander: 
	WaitForLanding();
	SetPhysics( PHYS_Walking );
	PickDestination();
	
	if( bSitting )
	{
		PlayToStand();
		FinishAnim( 0 );
		PlayToWaiting();
		FinishAnim( 0 );
	}
	PlayAllAnim( 'A_Walk',, 0.1, true );
	Enable('HitWall');
	Enable('Bump');
	MoveTo(Destination, 0.2);
	Acceleration = vect(0,0,0);
ContinueWander:
	/*if( FRand() < 0.15 )
	{
		HeadTrackingActor = Master;
		PlayToSit();
		FinishAnim( 0 );
		PlaySitting();
		FinishAnim( 0 );
		Sleep( Rand( 6 ) );
		PlayToStand();
		FinishAnim( 0 );
	}*/
	PlayToWaiting();
	Sleep( FRand() );
	Goto('Wander');

}

function NotifyInterest( actor AnInterestActor )
{
	if( AnInterestActor.IsA( 'dnBloodPool' ) && bBloodSeeker )
	{
		HeadTrackingActor = AnInterestActor;
		InterestActor = AnInterestActor;
		GotoState( 'Roaming', 'MoveTointerestPoint' );
	}
}

function EnableHeadTracking(bool bEnable)
{
//	if (bEnable)
//	{
		Super.EnableHeadTracking( bEnable );
		HeadTracking.DesiredWeight = 1.1;
		HeadTracking.WeightRate = 1.0;
//	}
//	else
//	{
		//HeadTracking.DesiredWeight = 0.0;
		//HeadTracking.WeightRate = 2.0;
//	}
}


defaultproperties
{
     bStayIdle=false
	bBloodSeeker=false
	 AccelRate=600.000000
     RunSpeed=2.0
     CollisionHeight=20
     CollisionRadius=17.5
     PulseFrequency=0.25
     PulseRadius=3000
     LodMode=LOD_StopMinimum
     Mesh=DukeMesh'c_characters.EDF_dog'
     bHeated=True
     HeatIntensity=128.000000
     HeatRadius=8.000000
	 Health=33
     BlinkRateBase=0.6
     BlinkRateRandom=1.0
     BlinkDurationBase=0.300000
     BlinkDurationRandom=0.050000
     BlinkEyelidPosition=(X=1.000000,Y=-0.100000,Z=0.000000)
     BlinkChangeTime=0.150000
     bUseTriggered=True
	 PathingCollisionHeight=39
	 PathingCollisionRadius=17
     bModifyCollisionToPath=true
     bAggressiveToPlayer=true
	 GroundSpeed=750
	 JumpZ=350
	 bSnatched=true
	 MeleeRange=128
	 WalkingSpeed=0.075
	 CarcassType=class'DogCarcass'
	 bIsPlayer=true
	 RotationRate=(Pitch=3072,Yaw=130000,Roll=2048)
}

