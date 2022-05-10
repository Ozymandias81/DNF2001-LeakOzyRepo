/*=============================================================================
	Birds
	Author: Jess Crable

=============================================================================*/
class Birds expands BonedCreature
	abstract;

/*
====================================================================
Vulture Animations:

Blink
Death1
DeathFlyingFall1
DeathFlyingHit1
DeathGround
DeathWingsOutGround
Fly
Glide
GlideLookAbout
GlideLTConst
GlideLTReturn
GlideLTTurn
GlideRTConst
GlideRTReturn
GlideRTTurn
IdleEat
IdlePick
IdleSit
Land
LookAroundBob
OpenWingsToWalk
OpenWingsWalk
OpenWingsWalkBawl
SitUp
Walk
WingsOpentStandIdle
WingsOpentStandIdleBawl
WingsOpentToStandIdle
====================================================================
*/
var actor MyTarget;

//var() name GoalTag;
var	actor GoalActor;
var( Birds ) float CircleRadius;
var float Angle;
var	vector CircleCenter;
var( Birds ) bool bCircle;
var( Birds ) name PerchTag;

var bool bLandDeath;
var rotator TempRotation;
var int EatCount;
var int Failures;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	CircleCenter = Location;
}

function PostBeginPlay()
{
	bCanFly = true;
	Super.PostBeginPlay();
}

function PlayCall()
{
	//if ( FRand() < 0.4 ) 
		//PlaySound(sound'call1m',,1 + FRand(),,, 1 + 0.7 * FRand());
	//else
		//PlaySound(sound'call2b',,1 + FRand(),,, 0.8 + 0.4 * FRand());
}

function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	if ( FRand() < 0.5 )
		TweenAnim('Hit1', 0.1);
	else
		TweenAnim('Hit2', 0.1);
	AirSpeed = 1.5 * Default.AirSpeed;	
	bCircle = false;
	SetPhysics(PHYS_Falling);
	GotoState('TakeHit');
	}
	
function PlayDeathHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	if ( FRand() < 0.5 )
		TweenAnim('Dead1', 0.2);
	else
		TweenAnim('Dead2', 0.2);	
}


function Died(pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	local Actor A;

	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
		A.Trigger( Self, Killer );
	
	if ( Region.Zone.bDestructive && (Region.Zone.ExitActor != None) )
	{
		Spawn(Region.Zone.ExitActor);
		Destroy();
		return;
	}
	GotoState('Dying');
}

function WhatToDoNext( name LikelyState, name LikelyLabel )
{
	if ( bCircle )
		GotoState('Circle');
	else if ( GoalActor != None )
		GotoState('MoveToGoal');
		else
		GotoState('Meander');
}
	
auto state startup
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( GoalActor != None )
			GotoState('MoveToGoal');
	}

Begin:
	if ( GoalActor == None )
		WhatToDoNext( '', '' );
}

state TakeHit
{
	ignores seeplayer, enemynotvisible;

Begin:
	FinishAnim();
	Sleep(0.3);
	TweenAnim('Flight', 0.1);
	WhatToDoNext( '','' );
}

state meander
{
	ignores seeplayer, enemynotvisible;

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
	if ( FRand() < 0.2 )
		PlayCall();
	Destination = CircleCenter + FRand() * CircleRadius * VRand();
	if ( Abs(Destination.Z - CircleCenter.Z) > 2 )
		Destination.Z = CircleCenter.Z; 
	if ( (Destination.Z >= Location.Z) || (FRand() < 0.5) )
	{
		//LoopAnim('Flight');
		PlayFlyAnim();
	}
	else
		TweenAnim('Fly', 1.0);
	MoveTo(Destination);
	Goto('Wander');
}

state movetogoal
{
	ignores seeplayer, enemynotvisible;
	
	function HitWall(vector HitNormal, actor Wall)
	{
		GoalActor = None;
		GotoState('Meander');
	}
 		
begin:
	SetPhysics(PHYS_Flying);
wander:
	if ( FRand() < 0.5 )
		PlayCall();
	//LoopAnim('Flight', 2.0);
	PlayFlyAnim();
	MoveTo(GoalActor.Location);
	If ( VSize(Location - GoalActor.Location) < 1 )
		Destroy();
	else
		Goto('Wander');
}

state circle
{
	ignores seeplayer, enemynotvisible;

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
	if ( FRand() < 0.2 )
	{
		//LoopAnim('Flight');
		PlayFlyAnim();
		PlayCall();
	}
	else
		PlayAnim('Fly');
	Angle += 1.0484; //2*3.1415/6;	
	Destination.X = CircleCenter.X - CircleRadius * Sin(Angle);
	Destination.Y = CircleCenter.Y + CircleRadius * Cos(Angle);
	Destination.Z = CircleCenter.Z + 30 * FRand() - 15;
	StrafeTo(Destination, Destination);
	Goto('Wander');
}
/*
State Dying
{
	ignores seeplayer, enemynotvisible;
	
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> DamageType)
	{
		destroy();
	}

	function Landed(vector HitNormal)
	{
		local rotator newRot;

		newRot = Rotation;
		newRot.Pitch = 0;
		newRot.Roll = 0;
		If ( FRand() < 0.5 )
			TweenAnim('Ground1', 0.2);
		else
			TweenAnim('Ground2', 0.2);
		SetRotation(newRot);
		SetPhysics(PHYS_None);
		SetTimer(2.0, True);
	}	

	function Timer( optional int TimerNum )
	{
		if ( !PlayerCanSeeMe() )
			Destroy();
	}
			
Begin:
	SetPhysics(PHYS_Falling);
	Sleep(10);
	Timer();
}			
*/
function PlayFlyAnim();

function Trigger( actor Other, pawn EventInstigator )
{
	local PerchPoint P;

	foreach allactors( class'PerchPoint', P )
	{
		//if( LineOfSightTo( P ) )
		//{
			if( P.Tag == PerchTag )
			{
				Destination = P.Location;
				GotoState( 'Landing' );
				break;
			}
		//}
	}
}

state Landing
{
	function BeginState()
	{
//		log( "-- Landing state entered" );
	}

	function SetCarcassDestination()
	{
		local PerchPoint D;

		foreach allactors( class'PerchPoint', D, 'Hell' )
		{
//			Destination = D.Location + ( 64 * vect( 0, -1, 0 ) ) * D.Location;
			Destination = D.Location;
//Destination = D.Location;
			break;
		}
	}

TakeOff:
	PlayAnim( 'WingsOpentToStandIdle' );
	FinishAnim();
	if( FRand() < 0.33 )
	{
		PlayAnim( 'WingsOpentStandIdleBawl' );
		FinishAnim();
	}
	EatCount = 0;
	GotoState( 'Meander' );

Begin:
	StrafeTo( Destination, Destination );
	bCanStrafe = true;
	if( VSize( Location - Destination ) > 2 )
	{

		Failures++;
		if( Failures > 15 )
		{
			//Failures = 0;
			bCanStrafe = true;
			//GotoState( 'Circle' );
		}

		Goto( 'Begin' );
	}
	StopMoving();
	//eep( 10 );
//
	TempRotation=Rotation;
	TempRotation.Pitch = 0;
	SetRotation( TempRotation );
	//bFlyingVehicle=true;
	DesiredRotation.Pitch = 0;
	PlayAnim( 'Land' );
	//eep( 0.2 );
	SetPhysics( PHYS_Falling );
	Sleep( 0.2 );
	StopMoving();
	FinishAnim();
	LoopAnim( 'IdleSit' );
	Sleep( 1.2 );
//	Sleep( 5.0 );
//	PlayAnim( 'WingsOpentToStandIdle' );
//	FinishAnim();
//	if( FRand() < 0.33 )
//	{
//		PlayAnim( 'WingsOpentStandIdleBawl' );
//		FinishAnim();
//	}
//	LoopAnim( 'Walk' );
	//SetCarcassDestination();
//	MoveTo( Destination, 0.06 );
//	LoopAnim( 'IdleSit' );
	//Sleep( 10.0 );
Eating:
	if( FRand() < 0.33 )
	{
		PlayAnim( 'IdleEat',, 0.14 );
		FinishAnim();
		LoopAnim( 'IdleSit',, 0.13 );
	}
	Sleep( 1.0 );
	EatCount++;
	if( EatCount > 2 )
		Goto( 'TakeOff' );
	else
		Goto( 'Eating' );
}

state Dying
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, Drowning;

	function BeginState()
	{
		//log( "Dying state entered" );
	}

	function Landed( vector HitNormal ) 
	{
		GotoState( 'Dying', 'Landed' );
	}

	function bool HighEnough()
	{
		local vector HitLocation, HitNormal;
		local actor HitActor;

		HitActor = Trace( HitLocation, HitNormal, Location + vect( 0, 0, -500 ), Location, true );

		if( HitActor != None )
		{
			if( VSize( Location - HitLocation ) > 96 )
				return true;
			else
				return false;
		}
		return true;
	}

Landed:
	if( bLandDeath )
		PlayAllAnim( 'DeathWingsOutGround',, 0.1, false );
	SpawnCarcass();
	Destroy();

Begin:
	if( HighEnough() )
	{
		bLandDeath = true;
		PlayAnim( 'DeathFlyingHit1' );
		SetPhysics( PHYS_Falling );
		FinishAnim();
		LoopAnim( 'DeathFlyingFall1' );
		WaitForLanding();
	}
	else
	{
		bLandDeath = false;
		SetPhysics( PHYS_Falling );
		PlayAllAnim( 'DeathAGround',, 0.1, false );
	}
}

defaultproperties
{
     bCanFly=True
     bCanStrafe=false
     CircleRadius=750.000000
     AirSpeed=600.000000
     AccelRate=400.0000000
     SightRadius=2000.000000
     Health=17
     Land=None
     DrawType=DT_Mesh
     RotationRate=(Pitch=12000,Yaw=20000,Roll=9500)
     CarcassType=class'VultureCarcass'
     VisibilityHeight=138000
     VisibilityRadius=138000
     bUseViewPortForZ=true
}

