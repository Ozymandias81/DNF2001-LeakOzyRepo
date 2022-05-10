class LethalDecoration extends AIPawn;

var vector CircleCenter;
var float Angle;
var float CircleRadius;
var vector StartLocation;
var bool bVerticleCircle;
var float SpeedModifier;
var dnDecoration TargetDecoration;
var float CountTime;
var bool bTossed;
var rotator FixedRot;
var int PitchMod, YawMod, RollMod;
var float VelocitySize;
var bool bCanToss;
var dnOctabrainFX_ChargeDecorationA MyCharge;

function PostBeginPlay()
{
	MyCharge = Spawn( class'dnOctabrainFX_ChargeDecorationA', self );
	MyCharge.AttachActorToParent( self, true, true );
	MyCharge.MountType = MOUNT_Actor;
	MyCharge.SetPhysics( PHYS_MovingBrush );
//	if( !MyCharge.Enabled )
//		MyCharge.Trigger( self, self );

	SpeedModifier = 1.0;
	CircleCenter = Owner.Location + vect( 0, 0, 128 );
	CircleRadius = 96;
	StartLocation = Location;
}

function Destroyed()
{
	//Octabrain( Owner ).KillEffects();
	MyCharge.Destroy();
	Super.Destroyed();
}

function InitFor( RenderActor Other )
{
	local MeshInstance Minst;

	Minst = GetMeshInstance();

	Other.AttachActorToParent( self, false, false );
	Other.MountType = MOUNT_Actor;
	bCanFly = true;
}

function AbortTelekinesis()
{
	TargetDecoration.SetPhysics( PHYS_Falling );
	TargetDecoration.MountParent = None;
	TargetDecoration = None;
	Octabrain( Owner ).MyLethalDecoration = None;
	Octabrain( Owner ).TargetDecoration = None;
	//Octabrain( Owner ).KillEffects();
	Octabrain( Owner ).NewTarget();
	Destroy();
}

function Timer( optional int TimerNum )
{
	local rotator r;
	local dnOctabrainBrainLightningA  A;

	if( TargetDecoration == None ) //|| TargetDecoration.Health <= 0 )
	{
		TargetDecoration = None;
		Octabrain( Owner ).MyLethalDecoration = None;
		Octabrain( Owner ).TargetDecoration = None;
		//Octabrain( Owner ).KillEffects();
		Octabrain( Owner ).NewTarget();
		Destroy();
		return;
	}
	TargetDecoration.RotationRate.Pitch *= 4.25;
	TargetDecoration.RotationRate.Yaw *= 4.25;
	if( TargetDecoration.RotationRate.Pitch > 4000 )
	{
		Disable( 'Timer' );
		GotoState( 'Startup', 'Moving' );
	}
	//Rotating();
/*
	r.Pitch = Rand( 63000 ) * -1;
	r.Yaw = Rand( 63000 ) * -1;
	r.Roll = Rand( 63000 ) * -1;

	RotateTo( R, false, 0.2 );*/
//	Rotating();
}


auto state Startup
{
	ignores TakeDamage;

Moving:
	//Sleep( 0.5 );
	Disable( 'Timer' );
	
	TargetDecoration.AttachActorToParent( none, false, false ); 
	TargetDecoration.MountParent = None;
	TargetDecoration.SetPhysics( PHYS_Falling );
	TargetDecoration.Velocity = Normal( Enemy.Location - TargetDecoration.Location ) * 750;
	TargetDecoration.Velocity.Z += 200;

	MyCharge.Destroy();
	MyCharge = None;
	
	Octabrain( Owner ).PlayToWaiting();
	Octabrain( Owner ).KillEffects();
	TargetDecoration.Tossed();
	TargetDecoration.bTakeImpactDamage = true;
	Octabrain( Owner ).MyLethalDecoration = None;
	Octabrain( Owner ).TargetDecoration = None;
	Sleep( 2.0 );
	Octabrain( Owner ).NewTarget();	
	TargetDecoration = None;
	Destroy();

Begin:
	SetPhysics( PHYS_Flying );
	Rotating();
	if( CanSeeEnemyFrom( StartLocation + vect( 0, 0, 72 ) ) )
		MoveTo( StartLocation + vect( 0, 0, 72 ) );
	SetTimer( 0.15, true );
	Sleep( 5.0 ); 
	AccelRate *= 10;
	AirSpeed *= 5;
	MyCharge.Destroy();
	bTossed = true;

Vibrating:
	AccelRate = Default.AccelRate * 10;
	AirSpeed = Default.AirSpeed * 5;
	StrafeTo( StartLocation + vect( 0, 0, 64 ), vector( Rotation ), 5.0 );
	Angle += 1.0484;
	Destination.X = Location.X - 32 * Sin(Angle);
	Destination.Y = Location.Y + 32 * Cos(Angle);
	Destination.Z = Location.Z + 30 * FRand() - 15;
	StrafeTo( Destination, vector( Rotation ) );
	Sleep( 0.0 );
	Goto( 'Vibrating' );
}

state Circle
{
	ignores seeplayer, enemynotvisible;
	
	function Tick( float DeltaTime )
	{
		//broadcastmessage( "VEL: "$VSize( Velocity ) );

		CountTime += DeltaTime;
		if( CountTime > 8 )
		{
		//	GotoState( 'Circle', 'Drop' );
		//	Disable( 'Tick' );
		}
			
	}

	singular function ZoneChange( ZoneInfo NewZone )
	{
		if ( NewZone.bWaterZone )
		{
			SetLocation(OldLocation);
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			MoveTimer = -1.0;
		}
	}
	 		
begin:
	SetPhysics(PHYS_Flying);
wander:
	CircleCenter = Octabrain( Owner ).Location + ( vect( 0,0,1 ) * 96 );
	Angle += 1.0484; //2*3.1415/6;	
	bRotateToDesired = false;
	if( !bVerticleCircle )
	{
		Destination.X = CircleCenter.X - CircleRadius * Sin(Angle);
		Destination.Y = CircleCenter.Y + CircleRadius * Cos(Angle);
		Destination.Z = CircleCenter.Z + 30 * FRand() - 15;
	}
	else
	{
		Destination.Z = CircleCenter.Z - CircleRadius * Sin( Angle );
		Destination.Y = CircleCenter.Y + CircleRadius * Cos( Angle );
		Destination.X = CircleCenter.X + 30 * FRand() - 15;
	}
	StrafeTo( Destination, Focus, SpeedModifier );
	SpeedModifier += 1.5;
	Goto('Wander');

Drop:
	StrafeTo( CircleCenter + vect( 0, 0, 128 ), Focus, SpeedModifier );
	StopMoving();
	TargetDecoration.AttachActorToParent( none, false, false );
	TargetDecoration.MountParent = None;
	TargetDecoration.SetPhysics( PHYS_Falling );
	TargetDecoration.Velocity.Z -= 512;
	Destroy();

Toss:
	StrafeTo( Enemy.Location, Focus, SpeedModifier );
	TargetDecoration.AttachActorToParent( none, false, false );
	TargetDecoration.MountParent = None;
	Octabrain( Owner ).NewTarget();
	TargetDecoration.Destroy();
}


	function Rotating( optional bool bTest )
	{
		local float Temp;
		local rotator r;
		
		//IndependentRotation = false;
		VelocitySize += 30;
		TargetDecoration.bRotateByQuat = false;
		TargetDecoration.bRotateToDesired = false;
		TargetDecoration.bFixedRotationDir = true;
		//message( "SIZE: "$VelocitySize );
		if( PitchMod == 0 )
			PitchMod = Rand( 120000 ) - 60000;
		if( YawMod == 0 )
			YawMod = Rand( 120000 ) - 60000;
		if( RollMod == 0 )
			RollMod = Rand( 120000 ) - 60000;
	

		TargetDecoration.RotationRate.Pitch = 5000; //(PitchMod) * (VelocitySize / (400 + TargetDecoration.Mass));
		TargetDecoration.RotationRate.Yaw = 5000; //(YawMod) * (VelocitySize / (400 + TargetDecoration.Mass)); 
		TargetDecoration.RotationRate.Roll = 5000; //(RollMod) * (VelocitySize / (400 + TargetDecoration.Mass));
		//Velocity.X += ((Rand(VelocitySize / 3.0)) * (Rand(3) - 1));
				//Velocity.Y += ((Rand(VelocitySize / 3.0)) * (Rand(3) - 1));
	//	IndependentRotation = true;
	}

DefaultProperties
{
	bCollideActors=false
	bBlockActors=false
	JumpZ=100
    CollisionHeight=0
    CollisionRadius=0
	AirSpeed=400
	AccelRate=100
	bCanStrafe=true
	RotationRate=(Pitch=0,Yaw=0,Roll=250)
	bHidden=true
}

	