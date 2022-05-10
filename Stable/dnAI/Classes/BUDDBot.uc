/*=============================================================================
	BUDDBot
	Author: Jess Crable

=============================================================================*/
class BUDDBot expands Dogs;

#exec OBJ LOAD FILE=..\sounds\a_creatures.dfx
#exec OBJ LOAD FILE=..\sounds\a_npcvoice.dfx
// Anims:
// BUDD_IdleA
// BUDD_Asleep
// BUDD_Wakeup
// BUDD_Armout
// BUDD_ArmIn
// BUDD_ArmFix

var SoftParticleSystem MyTrail1, MyTrail2, MyTrail3;
var float InterestTime;
var() float MaxShieldTime;
var float ShieldTime;
var() float DamEventThreshold;
var() float MaxDamEventThresholdTime;
var float DamEventThresholdTime;
var float AccumulatedDamage;
var() name RetreatTag;
var() bool bDamageEventEnabled;

var NavigationPoint MyRetreatPoint;

const TIMER_DestroyShield = 5;

function DamageEvent()
{
	bDamageEventEnabled = false;
	StopMoving();
	NextState = GetStateName();
	GotoState( 'Retreating' );
}

state Retreating
{
	function BeginState();

	function EndState()
	{
		bDamageEventEnabled = true;
	}

	function NavigationPoint GetRetreatPoint()
	{
		local NavigationPoint NP;

		for( NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint )
		{
			if( NP.Tag == RetreatTag )
			{
				return NP;
			}
		}
	}

	function bool CanDirectlyReach( actor ReachActor )
	{
		local vector HitLocation,HitNormal;
		local actor HitActor;

		HitActor = Trace( HitLocation, HitNormal, ReachActor.Location + vect( 0, 0, -19 ), Location + vect( 0, 0, -19 ), true );
		
		if( HitActor == ReachActor && LineOfSightTo( ReachActor ) )
		{
			return true;
		}
		
		return false;
	}

Begin:
	MyRetreatPoint = GetRetreatPoint();

	if( MyRetreatPoint == None )
		GotoState( NextState );

	if( MyRetreatPoint != None )
	{
		Destination = MyRetreatPoint.Location;
	}
	if( !CanDirectlyReach( MyRetreatPoint ) )
	{
		if( !FindBestPathToward( MyRetreatPoint, true ) )
		{
			PlayToWaiting();
			Goto( 'Waiting' );
		}
		else
		{
			HeadTrackingActor = MoveTarget;
			MoveTo( Destination, GetRunSpeed());
			if( VSize( MyRetreatPoint.Location - Location ) <= 128 )
			{
				Goto( 'RetreatReached' );
			}
			else
			{
				Goto( 'Begin' );
			}
		}
	}
	else if( CanDirectlyReach( MyRetreatPoint ) && VSize( MyRetreatPoint.Location - Location ) > 128 )
	{
		PlayToRunning();
		HeadTrackingActor = MoveTarget;
		MoveTo( Location - 64 * Normal( Location - MyRetreatPoint.Location), GetRunSpeed() );
	}
	else if( VSize( MyRetreatPoint.Location - Location ) <= 128 ) 
	{
		Goto( 'RetreatReached' );
	}
	Goto( 'Moving' );

RetreatReached:
	StopMoving();
	PlayToWaiting();
}

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	AccumulatedDamage += Damage;
	BroadcastMessage( "Accumulated Damage: "$AccumulatedDamage );
	if( bDamageEventEnabled && AccumulatedDamage >= DamEventThreshold )
	{
		BroadcastMessage( "Going to Retreating state." );
		DamageEvent();
	}

	if( bShielded )
	{
		CreateShield();
	}
	else
		Super.TakeDamage( Damage, instigatedBy, HitLocation, Momentum, DamageType );
}

state ActivityControl
{
	function AlertNPC( actor WarningActor, optional name WarningType )
	{
		SuspiciousActor = WarningActor;
		GotoState( 'ActivityControl', 'Wait' );
	}

Wait:
	StopMoving();
	if( SuspiciousActor != None )
	{
		Sleep( 0.5 );
		Goto( 'Wait' );
	}
	else
	{
		Goto( 'Moving' );
	}
}


simulated function DestroyShield()
{
    if (Shield != none)
    {
        Shield.Destroy();
        Shield = none;
    }
}

function Timer( optional int TimerNum )
{
	if( TimerNum == TIMER_DestroyShield )
	{
		DestroyShield();
	}
}

simulated function CreateShield()
{
    if (Shield == none)
    {
        Shield = spawn(class'Effects',self,,Location,Rotation);
        Shield.SetCollisionSize(CollisionRadius, CollisionHeight);
        Shield.SetCollision(false, false, false);
        Shield.bProjTarget = false;
        //Shield.SetPhysics(PHYS_Rotation);
        Shield.DrawType = DT_Mesh;
		Shield.Style = STY_Translucent;
        Shield.Mesh = Mesh;
		Shield.Texture = texture'ShieldFX.ShieldLightning';
		Shield.bMeshEnviroMap = true;
        Shield.DrawScale = 1.3;
		Shield.ScaleGlow = 2.0;
        Shield.bMeshLowerByCollision=true;
        Shield.MeshLowerHeight=0.0;
		Shield.RemoteRole = ROLE_None;
    }
}


function PlayDamage()
{
	PlaySound( sound'BUDDNoise103', SLOT_Misc, SoundDampening * 0.9 );

/*	if( FRand() < 0.5 )
		PlayAllAnim( 'A_PainA',, 0.1, false );
	else
		PlayAllAnim( 'A_PainB',, 0.1, false );
*/
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

function bool EvalBlink()
{
	return false;
}


function Tick( float DeltaTime )
{
	DamEventThresholdTime += DeltaTime;

	if( AccumulatedDamage > 0 && DamEventThresholdTime >= MaxDamEventThresholdTime )
	{
		BroadcastMessage( "AccumulatedDamage reset." );
		AccumulatedDamage = 0;
		DamEventThresholdTime = 0;
	}

	if( bShielded && Shield != None )
	{
		Shield.SetLocation( Location );
		Shield.SetRotation( Rotation );
		Shield.ScaleGlow -= 0.1;
		if( Shield.ScaleGlow <= 0.0 )
		{
			DestroyShield();
		}
	}
	if( HeadTrackingActor != None )
	{
		InterestTime += DeltaTime;

		if( InterestTime > 5.0 && Enemy == None )
		{
			HeadTrackingActor = None;
			InterestTime = 0.0;
		}
	}
	Super.Tick( DeltaTime );
}


function Used( actor Other, Pawn EventInstigator )
{
	local int i;

	i = Rand( 3 );

	if( i == 0 )
		PlaySound( sound'BUDDNoise003', SLOT_None, SoundDampening * 0.6 );
	else if( i == 1 )
		PlaySound( sound'BUDDNoise015', SLOT_None, SoundDampening * 0.6 );
	else if( i == 2 )
		PlaySound( sound'BUDDNoise021', SLOT_None, SoundDampening * 0.6 );
	else if( i == 3 )
		PlaySound( sound'BUDDNoise029', SLOT_None, SoundDampening * 0.6 );

	HeadTrackingActor = Other;
}

function PlayToWalking()
{
	if( MyTrail1 == None )
	{
		CreateTrail();
	}

	PlayAllAnim( 'BUDD_IdleA',, 0.2, true );
}

function PlayWaiting()
{
	if( MyTrail1 == None )
	{
		CreateTrail();
	}

	PlayAllAnim( 'BUDD_IdleA',, 0.2, true );
}

function PlayToWaiting( optional float TweenTime )
{
	if( MyTrail1 == None )
	{
		CreateTrail();
	}

	PlayAllAnim( 'BUDD_IdleA',, 0.2, true );
}


function PlayToRunning()
{
	if( MyTrail1 == None )
	{
		CreateTrail();
	}
	PlayAllAnim( 'BUDD_IdleA',1.2, 0.2, true );
}

auto state Powerup
{
	function BeginState()
	{
		SetPhysics( PHYS_Falling );
		//log( "BUDDBot "$self$" powering up." );
	}
Begin:
	WaitForLanding();
	PlayAllAnim( 'BUDD_Asleep',, 0.1, true );
	Sleep( FRand() );
	PlayAllAnim( 'BUDD_Wakeup',, 0.1, false );
	Sleep( 0.1 );
	CreateTrail();
	FinishAnim( 0 );
	PlayAllAnim( 'BUDD_IdleA',, 0.1, true );
	Sleep( FRand() );
	GotoState( 'Roaming' );
}

state Idling
{
begin:
	GotoState( 'Roaming' );
}


function PlayerPawn FindPlayer()
{
	local PlayerPawn P;

	foreach allactors( class'PlayerPawn', P )
	{
		return P;
	}
}

function CreateTrail()
{
	MyTrail1 = Spawn( class'dnBUDDBotFX_HoverHaze', self );
	MyTrail1.AttachActorToParent( self, true, true );
	MyTrail1.MountMeshItem = 'BUDDHover1';
	MyTrail1.MountType = MOUNT_MeshSurface;
	MyTrail1.SetPhysics( PHYS_MovingBrush );

	MyTrail2 = Spawn( class'dnBUDDBotFX_HoverHaze', self );
	MyTrail2.AttachActorToParent( self, true, true );
	MyTrail2.MountMeshItem = 'BUDDHover2';
	MyTrail2.MountType = MOUNT_MeshSurface;
	MyTrail2.SetPhysics( PHYS_MovingBrush );

	MyTrail3 = Spawn( class'dnBUDDBotFX_HoverHaze', self );
	MyTrail3.AttachActorToParent( self, true, true );
	MyTrail3.MountMeshItem = 'BUDDHover3';
	MyTrail3.MountType = MOUNT_MeshSurface;
	MyTrail3.SetPhysics( PHYS_MovingBrush );
}

function PostBeginPlay()
{

	EnableHeadTracking( true );
	Super.PostBeginPlay();
	//GotoState( 'Roaming' );
}

simulated function bool EvalHeadLook()
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
	local float f;
	
	local rotator EyeLook, HeadLook, BodyLook;
	local rotator LookRotation;
	local float HeadFactor, ChestFactor, AbdomenFactor;
	local float PitchCompensation;
    
	local int RandHeadRot;

	if( HeadTrackingActor != None )
	{
		HeadTracking.DesiredWeight = 1.0;
	}
	else
	{
		HeadTracking.DesiredWeight = 0.5;
	}

	minst = GetMeshInstance();
    if (minst==None)
        return(false);

	if( HeadTrackingActor == None && FRand() < 0.75 )
	{
		HeadTracking.DesiredRotation = Rotation;
	}
	//HeadLook = minst.WorldToMeshRotation(HeadTracking.Rotation);
//	if( HeadTrackingActor != None )
//	{
//	if( bHeadInitialized )
//	{
//		HeadLook = rot( 0, 0, 0 ) - Rotation;
//		bHeadInitialized = false;
//	}
//	else
	HeadLook = HeadTracking.Rotation - Rotation;
	//HeadLook = rotator( VRand() ) - Rotation;
	HeadLook = Normalize(HeadLook);
	
	HeadLook = Slerp(HeadTracking.Weight, rot(0,0,0), HeadLook);

//	}
//	else
	//r = Normalize(minst.WorldToMeshRotation(ClampHeadRotation(HeadTracking.DesiredRotation)));
	r = Normalize(ClampHeadRotation(HeadTracking.DesiredRotation) - Rotation);
	//BroadcastMessage("RenderDesired: "$r$" RenderCurrent: "$HeadLook);
	
	//EyeLook = minst.WorldToMeshRotation(EyeTracking.Rotation);
	//EyeLook = EyeTracking.Rotation - Rotation;
	
//	if( HeadTrackingActor == None )
//	{
//		EyeTracking.DesiredWeight = 0.0;
//		EyeTracking.WeightRate = 0.0;
//	}
//	else
//		EnableEyeTracking( true );

	// Move the eyes to follow an item of interest.
//	if( HeadTrackingActor == None )
//	{
//	}
//	else
//	{
	//EyeLook = Normalize( HeadTracking.DesiredRotation - Rotation );
	//EyeLook = Normalize(EyeLook - HeadLook);
//	EyeLook.Yaw *= 0.125; // minimal eye movements cover large ground, so scale back rotation
//	EyeLook = Slerp(EyeTracking.Weight, rot(0,0,0), EyeLook);
//}

//	if (true ) // full body head look
//	{
		LookRotation = HeadLook;
		HeadFactor = 1.00;
				ChestFactor = 0.45;
			AbdomenFactor = 0.35;
			PitchCompensation = 0.0;

		/*HeadFactor = 0.15;
		ChestFactor = 0.45;
		AbdomenFactor = 0.40;
		PitchCompensation = 0.25;//0.25;*/

		bone = minst.BoneFindNamed('Head');
		if (bone!=0)
		{
			r = LookRotation;
//			if( FRand() < 0.5 )
			r = rot( 0 ,0,-r.Yaw);
//			r = rot( r.pitch * 0.5, 0, -r.Yaw*HeadFactor );
			if( bHeadTrackTimer )
			{
				minst.BoneSetRotate(bone, r, true, true);
			}
		}
//	}
//	else // head-only head look
//	{
//		LookRotation = HeadLook;
//		bone = minst.BoneFindNamed('Head');
//		if (bone!=0)
//		{
//			r = LookRotation;
//			r = rot(r.Pitch,0,-r.Yaw);
//			minst.BoneSetRotate(bone, r, false, true);
//		}
//	}
	// eye look

	return(true);
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
			HeadTrackingActor = Other;
			if( FRand() < 0.33 )
			{
				Disable( 'Bump' );
				GotoState( 'Roaming', 'BumpReaction' );
			}
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
	
	function BeginState()
	{
		//SetTimer( PulseFrequency, true );
	//	EnableHeadTracking( true );
		bAvoidLedges = true;
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
		bAvoidLedges = true;
		MinHitWall = Default.MinHitWall;
	}

BumpReaction:
	StopMoving();
	TurnToward( HeadTrackingActor );
	PlayAllAnim( 'BUDD_ArmOut',, 0.1, false );
	if( FRand() < 0.33 )
		PlaySound( sound'BUDDNoise068', SLOT_None, SoundDampening * 0.6 );
	FinishAnim( 0 );
	PlayAllAnim( 'BUDD_ArmFix',, 0.1, true );
	if( FRand() < 0.33 )
		PlaySound( sound'BUDDNoise170', SLOT_None, SoundDampening * 0.6 );
	TurnToward( HeadTrackingActor );
	Sleep( 2 + FRand() );
	Enable( 'Bump' );
	Goto( 'Wander' );

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
/*	if( FRand() < 0.25 )
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
*/
	if( FRand() < 0.25 )
		PlayRandomSound();
	if( FRand() < 0.35 )
		Sleep( 1 + Rand( 5 ) );
	Goto('Wander');

ContinueWander:
	FinishAnim();
	Goto('Wander');

Turn:
	Acceleration = vect( 0,0,0 );
	SetTurn();
	TurnTo( Destination );
	Goto( 'Pausing');

}

function PlayRandomSound()
{
	local int i;

	i = Rand( 7 );

	Switch( i ) 
	{
		Case 0:
			PlaySound( sound'BUDDNoise094', SLOT_None, SoundDampening * 0.55 );
			break;
		Case 1:
			PlaySound( sound'BUDDNoise069', SLOT_None, SoundDampening * 0.55 );
			break;
		Case 2:
			PlaySound( sound'BUDDNoise068', SLOT_None, SoundDampening * 0.55 );
			break;
		Case 3:
			PlaySound( sound'BUDDNoise067', SLOT_None, SoundDampening * 0.55 );
			break;
		Case 4:
			PlaySound( sound'BUDDNoise057', SLOT_None, SoundDampening * 0.55 );
			break;
		Case 5:
			PlaySound( sound'BUDDNoise050', SLOT_None, SoundDampening * 0.55 );
			break;
		Case 6:
			PlaySound( sound'BUDDNoise134', SLOT_None, SoundDampening * 0.55 );
			break;
		Default:
			PlaySound( sound'BUDDNoise134', SLOT_None, SoundDampening * 0.55 );
	}
}

function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	PlayAllAnim( 'BUDD_Asleep',, 0.1, true );
}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	MyTrail1.Destroy();
	MyTrail2.Destroy();
	MyTrail3.Destroy();
	Super.Died( Killer, DamageType, HitLocation );
}

defaultproperties
{
	bShielded=false
	Health=40
	Mesh=DukeMesh'c_characters.BUDDBot'
	CarcassType=Class'RobotPawnCarcass'
	bSteelSkin=true
	bAggressiveToPlayer=false
	GroundSpeed=650
	AccelRate=50
	HeadTracking=(RotationRate=(Pitch=0,Yaw=35000),RotationConstraints=(Pitch=0,Yaw=360000))
	MaxShieldTime=1.0
	DamEventThreshold=15.0
	MaxDamEventThresholdTime=5.0
	bDamageEventEnabled=false
    BloodPuffName="dnParticles.dnWallSpark"
    BloodHitDecalName="DNGAme.DNOilHit"
    HitPackageClass=class'HitPackage_Steel'
	HitPackageLevelClass=class'HitPackage_DukeLevel'
}

