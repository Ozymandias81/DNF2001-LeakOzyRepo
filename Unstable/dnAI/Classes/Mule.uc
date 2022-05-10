class Mule extends BonedCreature;

/*
Mule Anims:
Walk
TurnR
TurnL
Run
Pain_Rear
Pain_Head
Pain_Body
Kick
Idle5
Idle4
Idle3
Idle2
Idle1
Die
BuckKick
*/

#exec obj load file=..\meshes\c_zone3_canyon.dmx

var Actor KickTarget;
var() bool bAutoWalk;

auto state Testo
{
	ignores Bump, SeePlayer, Touch;

Begin:
	if( bAutoWalk )
		LoopAnim( 'Walk' );
}

function PostBeginPlay()
{
//	log( "Mesh: "$Mesh );
}

state Roaming
{
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
		local float WanderRadius;
		
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
	

	function BeginState()
	{
		//SetTimer( PulseFrequency, true );
	//	EnableHeadTracking( true );
		bAvoidLedges = false;
		MinHitWall = -5.2;
		Enemy = None;
		Disable('AnimEnd');
		//JumpZ = -1;
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
//	log( "* 1" );
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
	LoopAnim( 'Run',1.2, 0.2 );
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
		//if( FRand() < 0.35 && !bSitting )
		//{
		//	PlayToSit();
		//	FinishAnim( 0 );
		//	PlaySitting();
		//}
		//if( !bSitting )
		//	PlayToWaiting();
		//if( FoundSomethingToLookAt() )
		//{
		//	Sleep( 8.0 );
		//}
		//else
		LoopAnim( 'Idle1' );
			Sleep( 2.5 );
		//if( bSitting )
		//{
		//	PlayToStand();
		//	FinishAnim( 0 );
		//	PlayToWaiting();
		//}
		//Sleep( 3.0 );
		//if( FRand() < 0.3 )
		//	GotoState( 'Idling' );
	}

	Goto('Wander');

ContinueWander:
	//FinishAnim();
	Goto('Wander');

Turn:
	StopMoving();
	Acceleration = vect( 0,0,0 );
	SetTurn();
	TurnTo( Destination );
	Goto( 'Pausing');

}

state Idling
{
	function Timer( optional int TimerNum )
	{
		Enable( 'Bump' );
	}

	function Bump( actor Other )
	{
		local vector HitLocation, HitNormal;
		local actor HitActor;
		
		if( Other.IsA( 'PlayerPawn' ) )
		{
			HitActor = Trace( HitLocation, HitNormal, Location - ( 128 * vector( Rotation ) ), Location );
	
			if( HitActor == Other )
			{
				Disable( 'Bump' );
				KickTarget = Other;
				GotoState( 'Idling', 'Kicking' );
			}
		}
	}

	function PlayAlternateIdleAnim()
	{
		local int i;

		i = Rand( 3 );

		if( i == 0 )
		{
			PlayAnim( 'Idle2' );
			return;
		}
		else if( i == 1 )
		{
			PlayAnim( 'Idle3' );
			return;
		}
		else if( i == 2 )
		{
			PlayAnim( 'Idle4' );
			return;
		}
		else if( I == 3 )
		{
			PlayAnim( 'Idle5' );
			return;
		}
	}

Kicking:
	PlayAnim( 'BuckKick' );
	Sleep( 0.33 );
	KickTarget.SetPhysics( PHYS_Falling );
	KickTarget.Velocity.Z += 8000;
	KickTarget.TakeDamage( 5, self, KickTarget.Location, -100000 * vector( Rotation ), class'KungFuDamage' );
	Disable( 'Bump' );
	SetTimer( 2.0, false );
	FinishAnim();

Begin:
	LoopAnim( 'Walk' );
/*	Sleep( 4 + Rand( 3 ) );
	if( FRand() < 0.22 )
	{
		PlayAlternateIdleAnim();
		FinishAnim();
	}
	Goto( 'Begin' );*/
}


DefaultProperties
{
	Mesh=DukeMesh'c_zone3_canyon.Mule'
    CollisionHeight=20
    CollisionRadius=17.5
	  RunSpeed=1.5
	  GroundSpeed=450
	  WalkingSpeed=0.075
	  bRotateToDesired=false
	  RotationRate=(Pitch=0,Yaw=0,Roll=0)
}
