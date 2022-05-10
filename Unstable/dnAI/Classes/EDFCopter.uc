class EDFCopter extends AIPawn;

#exec OBJ LOAD FILE=..\Meshes\c_Vehicles.dmx

var EDFCopterCollisionActor CollisionMiddle, CollisionFront, CollisionRear;
var ProtonMonitorPoint CurrentPoint;
// Have copter move in small increments, and when  close to destination have him begin strafing to his points rather than 
// moving?
var bool bBobDown;

function Destroyed()
{
	if( CollisionMiddle != None )
		CollisionMiddle.Destroy();

	if( CollisionFront != None )
		CollisionFront.Destroy();
	
	if( CollisionRear != None )
		CollisionRear.Destroy();
	
	Super.Destroyed();
}

function PostBeginPlay()
{
	CollisionMiddle = Spawn( class'EDFCopterCollisionActor', self );
	CollisionMiddle.AttachActorToParent( self, true, true );
	CollisionMiddle.MountType = MOUNT_Actor;
	CollisionMiddle.MountOrigin.X = 30;
	CollisionMiddle.MountOrigin.Y = 0;
	CollisionMiddle.MountOrigin.Z = 85;
	CollisionMiddle.MountAngles = rot( 0, 0, 0 );
	CollisionMiddle.SetPhysics( PHYS_MovingBrush );

	CollisionFront = Spawn( class'EDFCopterCollisionActor', self );
	CollisionFront.AttachActorToParent( self, true, true );
	CollisionFront.MountType = MOUNT_Actor;
	CollisionFront.MountOrigin.X = 220;
	CollisionFront.MountOrigin.Y = 0;
	CollisionFront.MountOrigin.Z = 85;
	CollisionFront.MountAngles = rot( 0, 0, 0 );
	CollisionFront.SetCollisionSize( CollisionFront.Default.CollisionRadius * 0.6, CollisionFront.Default.CollisionHeight );
	CollisionFront.SetPhysics( PHYS_MovingBrush );

	CollisionRear = Spawn( class'EDFCopterCollisionActor', self );
	CollisionRear.AttachActorToParent( self, true, true );
	CollisionRear.MountType = MOUNT_Actor;
	CollisionRear.MountOrigin.X = -220;
	CollisionRear.MountOrigin.Y = 0;
	CollisionRear.MountOrigin.Z = 85;
	CollisionRear.MountAngles = rot( 0, 0, 0 );
	CollisionRear.SetCollisionSize( CollisionRear.Default.CollisionRadius * 0.6, CollisionRear.Default.CollisionHeight * 0.5 );
	CollisionRear.SetPhysics( PHYS_MovingBrush );
	
	Super.PostBeginPlay();
}

auto state Idling
{
	function actor FindEnemy()
	{
		local PlayerPawn P;
		foreach allactors( class'PlayerPawn', P )
		{
			return P;
		}
	}		

	function BeginState()
	{
		if( Enemy == None )Enemy = FindEnemy();
		SetPhysics( PHYS_Flying );
	}

/*	function EnemyNotVisible()
	{
		broadcastmessage( "CANNOT SEE ENEMY" );
		GotoState( 'Idling', 'Moving' );
		Disable( 'EnemyNotVisible' );
	}
*/		
	function PickDest()
	{
		local ProtonMonitorPoint PMP;

		local int i;
		local bool bSuccess;

		if( CurrentPoint != None )
		{
			for( i = 0; i <= 15; i++ )
			{
				if( CurrentPoint.AccessiblePoints[ i ] != None && CurrentPoint.AccessiblePoints[ i ] != CurrentPoint )
				{
					if( CanSeeEnemyFrom( CurrentPoint.AccessiblePoints[ i ].Location ) )
					{
						//broadcastmessage( "Can see enemy from "$CurrentPoint.AccessiblePoints[ i ]$".. point selected." );
						CurrentPoint = ProtonMonitorPoint( CurrentPoint.AccessiblePoints[ i ] );
						Destination = CurrentPoint.Location;
						return;
					}
				}
			}
			CurrentPoint = ProtonMonitorPoint( CurrentPoint.GetRandomReachablePoint() );
			//broadcastmessage( "Choosing random accessible point: "$CurrentPoint );
			Destination = CurrentPoint.Location;
		}
		else
		{
		foreach allactors( class'ProtonMonitorPoint', PMP )
		{
			///broadcastmessage( "FOUND "$JSP );
			if( Destination != PMP.Location && PMP != CurrentPoint && CanSeeEnemyFrom( PMP.Location ) )
			{
				CurrentPoint = PMP;
				Destination = PMP.Location;
				break;
			}
		}
		}
	}

	function bool CanSeeEnemyFrom( vector aLocation, optional float NewEyeHeight, optional bool bUseNewEyeHeight )
	{
		local actor HitActor;
		local vector HitNormal, HitLocation, HeightAdjust;

		if( bUseNewEyeHeight )
		{
			HeightAdjust.Z = NewEyeHeight;
		}
		else
			HeightAdjust.Z = BaseEyeHeight;
		HitActor = Trace( HitLocation, HitNormal, Enemy.Location, aLocation + HeightAdjust, true );
		if( HitActor == Enemy )
		{
			return true;
		}
		return false;
	}


	function Timer( optional int TimerNum )
	{
		if( VSize( Location - Destination ) < 512 )
		{
			log( "TIMER CALLED 1" );
			//MoveTimer = -1.0;
			GotoState( 'Idling', 'StrafeToPoint' );
		}

		//if( CanSee( Enemy )
		//{
			//GunMountL.InstantFire();
			//LeftGun.MuzzleFlash();
		//}
	}

StrafeToPoint:
	log( "StrafeToPoint" );
	//StopMoving();
	StrafeTo( Destination, Enemy.Location, 0.75 );
	Goto( 'Stopping' );

Begin: 
	log( "Idling begin label" );
	Disable( 'EnemyNotVisible' );
	Disable( 'Timer' );
	if( Enemy == None )
		Enemy = FindEnemy();
	else
		Goto( 'Moving' );
	Sleep( 0.5 );
	Goto( 'Begin' );

Moving:	
	log( "Moving Begin label" );
	Sleep( 0.5 );
	log( "Moving Begin label 1" );

	log( "PICKDEST CALLED" );
	log( "Moving Begin label 2" );

	PickDest();
	if( Destination != vect( 0, 0, 0 ) )
	{
		Focus = vector( Rotation );
		bRotateToDesired = true;
//		if( FRand() < 0.25 )
			//StrafeTo( Destination, Enemy.Location + vect( 0, 0, -128 ) );
		//broadcastmessage( "MOVING" );
		Enable( 'Timer' );
		SetTimer( 0.1, true );

		MoveTo( Destination );
//		else
			//MoveTo( Destination );
//			StrafeTo( Destination, Destination + vect( 0, 0, -128 ) );

		//MoveTo( Destination );
		//TurnToward( Enemy );
	}
Stopping:
	Disable( 'Timer' );
	log( "STOPPING" );
	StopMoving();
	GotoState( 'Firing' );
}

state Firing
{
	function EnemyNotVisible()
	{
		Disable( 'Timer' );
		GotoState( 'Idling', 'Begin' );
		//Disable( 'EnemyNotVisible' );
	}

	function Timer( optional int TimerNum )
	{
		MuzzleFlash();
		if( FRand() < 0.15 )
			GotoState( 'Idling', 'Begin' );
	}

Begin:
	SetTimer( 0.2, true );
	Enable( 'EnemyNotVisible' );
	log( "FIRING" );
//	TurnTo( Enemy.Location );
/*	if( TopGun != None )
	{
		TurretMountProton( GunMountT ).NewEnemy = Pawn( Enemy );
		GunMountT.InstantFire();
		TopGun.MuzzleFlash();
		Sleep( 0.13 );
	}
	if( LeftGun != None )
	{
		TurretMountProton( GunMountL ).NewEnemy = Pawn( Enemy );
		GunMountL.InstantFire();
		LeftGun.MuzzleFlash();
		Sleep( 0.13 );
	}
	if( RightGun != None )
	{
		TurretMountProton( GunMountR ).NewEnemy = Pawn( Enemy );
		GunMountR.InstantFire();
		RightGun.MuzzleFlash();
	}*/
	StrafeTo( Location + ( VRand() * FMax( Rand( 24 ), 16 ) ), Enemy.Location );
//	Sleep( 0.13 );
	Goto( 'Begin' );
}
function Tick( float DeltaTime )
{
	if( FRand() < 0.5 && ( Velocity.X < -100 || Velocity.X > 100 ) )
	{
		if( FRand() < 0.55 )
		{
			Velocity.Z += 32;
		}
		else
			Velocity.Z -= 32;
	}

	Super.Tick( DeltaTime );
}

simulated function MuzzleFlash()
{
	local actor S;
	local float RandRot;

//	MuzzleFlashClass=class'M16Flash';

	S = Spawn(class'M16Flash');
	S.DrawScale *= 3;
	S.AttachActorToParent( Self, true, true );
	S.MountOrigin = vect( 325, 0, 45 );
	S.MountType = MOUNT_Actor;
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
DefaultProperties
{
    DrawType=DT_Mesh
    Mesh=DukeMesh'c_vehicles.EDFHoverCopter'
    CollisionHeight=0.000000
    CollisionRadius=0.000000
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bBlockPlayers=false
	AirSpeed=700.000000
	RotationRate=(Pitch=1500,Yaw=5000,Roll=1100)
	bCanStrafe=true
	AccelRate=300
    VisibilityRadius=8000
	bNoRotConstraint=true
    bFlyingVehicle=true
}