/*=============================================================================
	AlienPig
	Author: Jess Crable

=============================================================================*/
class AlienPig expands BonedCreature;


/* AlienPig animations:
 Charge
 ChargeHit
 ChargeHitWall
 ChargeMiss
 DeathA
 IdleA
 PainArm_L
 PainArm_R
 PainChest
 PainHead
 Roar_long
 Run
 SlashA
 Walk
*/
var() float AIMeleeRange;
var() float ChargeSpeed;
var vector CollisionOffset;
var name LastDamageBone;

var bool bDirectReach;
var bool bPreferClawAttack;
var float TimeBetweenPain;
var bool bCanShowPain;
var bool bBraking;
var vector PivotRot;
var bool bResetPrepivot;
var float PivotAdjust;
var bool bIsTurning;
var dnCharacterFX_AlienPigNoseSmoke NoseSmokeLeft, NoseSmokeRight;

function NotifyDodge( optional vector TestVector )
{
	local vector X, Y, Z, FinalOne, FinalTwo, STart;
	local vector Loc1, Loc2, Loc3, Loc4;

	if( FRand() < 0.65 )
		return;

	GetAxes( Rotation, X,Y,Z );

	Loc1 = Location + ( ( CollisionRadius * 0.5 ) * Y );
	Loc2 = Location - ( ( CollisionRadius * 0.5 ) * Y );
	Loc3 = Location + ( ( CollisionRadius * 0.5 ) * Z );
	Loc4 = Location - ( ( CollisionRadius * 0.5 ) * Z );

	if( ( VSize( Loc1 - TestVector ) < 54 || VSize( Loc2 - TestVector ) < 54 ) && 
		( VSize( Loc3 - TestVector ) < 54 || VSize( Loc4 - TestVector ) < 54 ) )
	{
		if( GetStateName() != 'Swatting' )
		{
			NextState = GetStateName();
			GotoState( 'Swatting' );
		}
		//broadcastmessage( "DEAD ON" );
	}

//	GotoState( 'ApproachingEnemy', 'Dodging' );
}

state Swatting
{
Begin:
	StopMoving();
	PlayAllAnim( 'SlashA1',, 0.1, false );
	FinishAnim( 0 );
	GotoState( NextState );
}

function NoseSmoke()
{
	NoseSmokeLeft = spawn( class'dnCharacterFX_alienPigNoseSmoke', self );
	NoseSmokeLeft.AttachActorToParent( self, true, true );
	NoseSmokeLeft.SetPhysics( PHYS_MovingBrush );
	NoseSmokeLeft.MountMeshItem = 'NoseL';
	NoseSmokeLeft.MountType = MOUNT_MeshSurface;

	NoseSmokeRight = spawn( class'dnCharacterFX_alienPigNoseSmoke', self );
	NoseSmokeRight.AttachActorToParent( self, true, true );
	NoseSmokeRight.SetPhysics( PHYS_MovingBrush );
	NoseSmokeRight.MountMeshItem = 'NoseR';
	NoseSmokeRight.MountType = MOUNT_MeshSurface;
}
	
function Tick( float DeltaTime )
{
	local vector LookDir, OffDir;

	if( bIsTurning )
	{
		RotationRate.Yaw = 22000;
		if( ( Rotator( Destination - Location ) - Rotation ).Yaw != 0 && ( Rotator( Destination - Location ) - rotation ).Yaw != -65536)
		{
			DesiredRotation = rotator( Destination - Location );
			LookDir = vector( Rotation );
	
			OffDir = Normal( LookDir cross vect( 0, 0, 1 ) );

			if( ( OffDir dot( Location - Enemy.Location ) ) > 0 )
			{
				if( GetSequence( 0 ) != 'StepRight45' )
				{
					PlayAllAnim( 'StepRight45',, 0.13, true );
				}
			}
			else
			{
				if( GetSequence( 0 ) != 'StepLeft45' )
				{	
					PlayAllAnim( 'StepLeft45',, 0.13, true );
				}
			}
		}
		else if( GetSequence( 0 ) == 'StepLeft45' || GetSequence( 0 ) == 'StepRight45' )
		{
			PlayToWaiting( 0.22 );
			bIsTurning = false;
			RotationRate.Yaw = Default.RotationRate.Yaw;
		}
	}

	Super.Tick( DeltaTime );
	if( bResetPrepivot )
	{
		PrePivot = PivotRot * PivotAdjust;
		PrePivot.Z = Default.Prepivot.Z;
		PivotAdjust += 1;
		if( PivotAdjust >= 0 )
			bResetPrepivot = false;
	}

	if( bBraking )
	{
		Acceleration *= 0.5;
		if( VSize( Acceleration ) < 5 )
			bBraking = false;
	}
}

function PlayInAir()
{
}


//function MayFall()
//{
//	PlayAllAnim( 'Jump_Start',, 0.1, false );
//	if( GetStateName() != 'FallingState' )
//		NextState = GetStateName();
//	GotoState( 'FallingState' );
//	bcanjump = true;
//}

singular function Falling()
{
 	if (health > 0)
		SetFall();
}

function SetFall()
{
	if (Enemy != None)
	{
		if( GetStateName() != 'FallingState' ) 
			NextState = GetStateName(); //default
		PlayAllAnim( 'Jump_Air',, 0.1, true );
		//PlayAllAnim( 'Jump_Start',, 0.1, false );
		GotoState('FallingState');
	}
}


function PlayDying( class<DamageType> DamageType, vector HitLoc )
{
	// A_PainA
	PlayAllAnim( 'DeathA',, 0.1, false );
}

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	switch( CreatureOrders )
	{
		Case ORDERS_Idling:
			GotoState( 'Idling' );
			break;
		Case ORDERS_Roaming:
			GotoState( 'Wandering' );
			break;
		Default:
			GotoState( 'Idling' );
			break;
	}
}


function PlayToWaiting( optional float TweenTime )
{
	local float TweenT;

	if( TweenTime > 0.0 )
		TweenT = TweenTime;
	else
		TweenT = 0.1;

	if( GetSequence( 0 ) != 'IdleA' )
		PlayAllAnim( 'IdleA',, TweenT, true );
}
	
function PreSetMovement()
{
	if (JumpZ > 0)
		bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = false;
	MinHitWall = 1.6;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

state FallingState {

//	function Landed( vector HitNormal )
//	{
//		StopMoving();
//		PlayAllAnim( 'Jump_Land',, 0.1, false );
//		GotoState( 'FallingState', 'Landed' );
//	}

Landed:
	FinishAnim( 0 );
	PlayAllAnim( 'Jump_Air',, 0.2, true );
	GotoState( NextState );

Begin:
//	FinishAnim( 0 );
	WaitForLanding();
	StopMoving();
	PlayAllAnim( 'Jump_Land',, 0.1, false );
	FinishAnim( 0 );
	if( NextState != 'FallingState' )
	{
		GotoState( NextState );
	}
	else if( Enemy != None )
		GotoState( 'ApproachingEnemy' );
	else
		GotoState( 'Idling' );
}

function bool NeedToTurn(vector targ)
{
	local int YawErr;

	DesiredRotation = Rotator(targ - location);
	DesiredRotation.Pitch = 0;
	DesiredRotation.Yaw = DesiredRotation.Yaw & 16383;
	YawErr = (DesiredRotation.Yaw - (Rotation.Yaw & 16383)) & 16383;
	if ( (YawErr < 4000) || (YawErr > 16383) )
		return false;

	return true;
}


state Idling
{
	function SeePlayer( actor SeenPlayer )
	{
		if( bAggressiveToPlayer && PlayerPawn( SeenPlayer ) != None )
		{
			Enemy = SeenPlayer;
			GotoState( 'Idling', 'Acquisition' );
		}
		Disable( 'SeePlayer' );
	}

	function BeginState()
	{
		//log( "--- Idling BeginState for "$self );
	}

	//function Tick( float DeltaTime )
	//{
	//	if( Rotation.Yaw != DesiredRotation.Yaw && GetSequence( 0 ) != 'StepLeft45' )
	//		PlayAllAnim( 'StepLeft45',, 0.1, true );
	//	Super.Tick( DeltaTime );
	//}

Acquisition:
	if( ( Rotator( Enemy.Location - Location ) - Rotation ).Yaw != 0 && ( Rotator( Enemy.Location - Location ) - rotation ).Yaw != -65536)
	{
		Destination = Enemy.Location;
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Acquisition' );
	}
	//TurnTo( Enemy.Location );
/*
	if ((rotator(Enemy.Location - Location) - Rotation).Yaw != 0 )
	{
		DesiredRotation = rotator( Enemy.Location - Location );
		broadcastmessage( "DESIRED ROTATION YAW: "$(rotator( Enemy.Location - Location ) - Rotation ).Yaw );
		if ((rotator(Enemy.Location - Location) - Rotation).Yaw < 0)
			PlayAllAnim( 'StepLeft45',, 0.1, false );
		else
			PlayAllAnim( 'StepRight45',, 0.1, false );
		FinishAnim( 0 );
		DesiredRotation = Rotation;
		PlayToWaiting();
		if ((rotator(Enemy.Location - Location) - Rotation).Yaw != 0 )
		{
			Goto( 'Acquisition' );
		}
	}*/

//	Sleep( 2.0 );
//	Goto( 'Acquisition' );
	//	DesiredRotation = rotator( Enemy.Location - Location );
//	DesiredRotation.Yaw = DesiredRotation.Yaw & 32000;
//	broadcastmessage( "DESIREDROTATION YAW: "$DesiredRotation.Yaw );

//	Sleep( 0.1 );
//	Goto( 'Acquisition' );
	//PlayToWaiting();

		//		CrPlayTurnLeft();
//	else
//		CrPlayTurnRight();
	//TurnToward( Enemy );
	//PlayAllAnim( 'Roar_Long',, 0.1, false );
	//FinishAnim( 0 );
	PlayToWaiting();
	if( FRand() < 0.7 )
	{
		PlayAllAnim( 'Roar_Long',, 0.1, false );
		FinishAnim( 0 );	
	}
	EnableHeadTracking( true );
	HeadTrackingActor = Enemy;
	GotoState( 'ApproachingEnemy' );

Begin:
	PlayToWaiting();
//	PrePivot.X = 30;
//	Sleep( 5.0 );
//	Prepivot.X = -30;
//	Sleep( 5.0 );
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

	if( HeadTrackingActor == None )
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
	EyeLook = EyeTracking.Rotation - Rotation;
	EyeLook = Normalize(EyeLook - HeadLook);
	EyeLook.Yaw *= 0.125; // Minimal eye movements cover large ground, so scale back rotation.
	EyeLook = Slerp(EyeTracking.Weight, rot(0,0,0), EyeLook);
//	}
//	else
//	{
	//EyeLook = Normalize( HeadTracking.DesiredRotation - Rotation );
	//EyeLook = Normalize(EyeLook - HeadLook);
//	EyeLook.Yaw *= 0.125; // minimal eye movements cover large ground, so scale back rotation
//	EyeLook = Slerp(EyeTracking.Weight, rot(0,0,0), EyeLook);
//}

	LookRotation = EyeLook;
	bone = minst.BoneFindNamed('Pupil_L');
	if (bone!=0)
	{			
		r = LookRotation;
		r = rot(r.Pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}
	bone = minst.BoneFindNamed('Pupil_R');
	if (bone!=0)
	{
		r = LookRotation;
		r = rot(r.Pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}

//	if (true ) // full body head look
//	{
		LookRotation = HeadLook;
		HeadFactor = 0.8;
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
			r = rot( r.Pitch * HeadFactor ,0,-r.Yaw*HeadFactor);
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
	LookRotation = EyeLook;

	bone = minst.BoneFindNamed('Pupil_L');
	if (bone!=0)
	{			
		r = LookRotation;
	//	r = rot(r.Pitch,0,-r.Yaw);
		r = rot(0,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, false, true);
	}
	bone = minst.BoneFindNamed('Pupil_R');
	if (bone!=0)
	{
		r = LookRotation;
		//r = rot(r.Pitch,0,-r.Yaw);
		r = rot(0,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, false, true);
	}
	return(true);
}

function ChargeHit()
{
	if( Enemy != None )
	{
		if( Enemy.IsA( 'DukePlayer' ) && Pawn( Enemy ).UsedItem != None && Pawn( Enemy ).UsedItem.IsA( 'RiotShield' ) && RiotShield( Pawn( Enemy ).UsedItem ).GetStateName() == 'ShieldUp' )
			RiotShield( Pawn( Enemy ).UsedItem ).TakeDamage( 100, self, Pawn( Enemy ).Location, vect( 0, 0, 0 ), class'CrushingDamage' );
		if( DukePlayer( Enemy ) != None )
		{
			DukeHUD( DukePlayer( Enemy ).MyHUD ).RegisterBloodSlash( 3 );
			DukePlayer( Enemy ).AddRotationShake( 0.35, 'Up' );
		}
		Enemy.TakeDamage( 10, self, Enemy.Location, vect( 0, 0, 0 ), class'CrushingDamage' );
		Enemy.Velocity.Z = 350;
		Enemy.SetPhysics( PHYS_Falling );
	}
	bBraking = true;
}

function PlayToWalking()
{
	if( GetSequence( 0 ) != 'Walk' )
	{
		PlayAllAnim( 'Walk',, 0.17, true );
	}
}

function PlayToRunning()
{
	if( GetSequence( 0 ) != 'Run' )
		PlayAllAnim( 'Run',, 0.13, true );
}

function PlayToCharging()
{
	if( GetSequence( 0 ) != 'Charge' )
		PlayAllAnim( 'Charge', 1.13, 0.2, true );
}

state ApproachingEnemy
{
	function Bump( actor Other )
	{
		if( Other.IsA( 'dnDecoration' ) && !Other.IsA( 'InputDecoration' ) && !Other.IsA( 'ControllableTurret' ) )
		{
			dnDecoration( Other ).Topple( self, Other.Location, vector( Rotation ) * 27550 + vect( 0, 0, 1350 ), 20 );
		}
	}

	function HitWall( vector HitNormal, actor HitWall )
	{
		Focus = Destination;
		if( HitWall.IsA( 'dnDecoration' ) && !HitWall.IsA( 'InputDecoration' ) && !HitWall.IsA( 'ControllableTurret' ) )
		{
			dnDecoration( HitWall ).Topple( self, HitWall.Location, vector( Rotation ) * 27550 + vect( 0, 0, 1350 ), 20 );
		}
		if (PickWallAdjust() && !HitWall.IsA( 'dnDecoration' ) )
		{
//			if ( Physics == PHYS_Falling )
//				SetFall();
//			else
				GotoState('ApproachingEnemy', 'AdjustFromWall');
		}
		else if( !HitWall.IsA( 'dnDecoration' ) )
			MoveTimer = -1.0;
	}

	function BeginState()
	{
		//log( "---- Approaching enemy state entered" );
		HeadTrackingActor = None;
		if( bPreferClawAttack && FRand() < 0.75 )
			ToggleClawAttack();
		else if( !bPreferClawAttack && FRand() < 0.15 )
			ToggleClawAttack();
	}

Begin:
	Destination = Enemy.Location;
	if( ( Rotator( Enemy.Location - Location ) - Rotation ).Yaw != 0 && ( Rotator( Enemy.Location - Location ) - rotation ).Yaw != -65536)
	{
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Begin' );
	}

	HeadTrackingActor = None;
Moving:
	if( Enemy == None || (Enemy.bIsRenderActor && (RenderActor(Enemy).Health <= 0)) )
	{
		GotoState( 'Idling' );
	}
	else
	if( VSize( Enemy.Location - Location ) > AIMeleeRange && !CanDirectlyReach( Enemy ) )
	{
		bDirectReach = false;
		if( !FindBestPathToward( Enemy, true ) )
		{
			PlayToWaiting();
			Sleep( 1.0 );
			GotoState( 'ApproachingEnemy' );
//			GotoState( 'WaitingForEnemy' );
		}
		else
		{
			PlayToRunning();
			MoveTo( Destination, GetRunSpeed());
			if( VSize( Enemy.Location - Location ) <= AIMeleeRange )
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
		bDirectReach = true;
		PlayToRunning();
		Destination = Location - 64 * Normal( Location - Enemy.Location );
		MoveTo( Destination, GetRunSpeed() );
		if( VSize( Enemy.Location - Location ) > 275 && FRand() < 0.25 )
		{
			if( bPreferClawAttack )
				ToggleClawAttack();
			GotoState( 'Charging' );
		}
//		if( VSize( Enemy.Location - Location ) < Default.MeleeRange && !bPreferClawAttack && FRand() < 0.44 )
//		{
//			ToggleClawAttack();
//			GotoState( 'Charging' );
//		}
	}
	else if( VSize( Enemy.Location - Location ) <= AIMeleeRange ) 
	{
		Goto( 'FollowReached' );
	}
	Goto( 'Moving' );

FollowReached:
	bDirectReach = false;
	if( !bPreferClawAttack && VSize( Location - Enemy.Location ) > 120 )
		GotoState( 'Charging' );
	else
		GotoState( 'ClawAttack' );
	//GotoState( 'MeleeCombat' );

AdjustFromWall:
	//Enable('AnimEnd');
//	TurnTo( Destination );
//	StrafeTo(Destination, Focus, GetRunSpeed() ); 
//	Destination = Focus; 
	Goto('Begin');
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

function SlashLeft()
{
	if( MeleeDamageTarget( 10, vector( Rotation ) ) )
	{
		if( DukePlayer( Enemy ) != None && Pawn( Enemy ).UsedItem.IsA( 'RiotShield' ) )
		{
			if( RiotShield( Pawn( Enemy ).UsedItem ).GetStateName() == 'ShieldUp' )
				return;
		}
		DukeHUD( DukePlayer( Enemy ).MyHUD ).RegisterBloodSlash( 1 );
		DukePlayer( Enemy ).AddRotationShake( FRand()*0.5 + 0.25, 'Right' );
	}
}

function SlashRight()
{
	if( MeleeDamageTarget( 10, vector( Rotation ) ) )
	{
		if( DukePlayer( Enemy ) != None && Pawn( Enemy ).UsedItem.IsA( 'RiotShield' ) )
		{
			if( RiotShield( Pawn( Enemy ).UsedItem ).GetStateName() == 'ShieldUp' )
				return;
		}
		DukeHUD( DukePlayer( Enemy ).MyHUD ).RegisterBloodSlash( 2 );
		DukePlayer( Enemy ).AddRotationShake( FRand()*0.5 + 0.25, 'Left' );
	}
}

state ClawAttack
{
Begin:
	StopMoving();
//	MeleeDamageTarget( 20, vector( Rotation ) );
	TurnToward( Enemy );
	//PlayAllAnim( 'SlashA',, 0.1, false );
	if( FRand() < 0.5 )
		PlayAllAnim( 'SlashA1',, 0.1, false );
	else
		PlayAllAnim( 'SlashA2',, 0.1, false );
//	PlayTopAnim( 'T_SlashA',, 0.1, false );
	FinishAnim( 0 );
	GotoState( 'ApproachingEnemy' );
}

function ToggleClawAttack()
{
	bPreferClawAttack = !bPreferClawAttack;
	if( bPreferClawAttack )
		AIMeleeRange = 32 * 1.5 + Enemy.CollisionRadius + CollisionRadius;
	else
		AIMeleeRange = Default.AIMeleeRange;
}

state Charging
{
	function Bump( actor Other )
	{
		if( Other == Enemy )
		{
			bForcePeriphery = true;
			if( CanSee( Enemy ) )
			{
				Pawn( Enemy ).AddVelocity( Vector( Rotation ) * 200 );
				GotoState( 'Charging', 'ChargeHit' );
			}
			bForcePeriphery = false;
			Disable( 'Bump' );
		}
	}

	function BeginState()
	{
		HeadTrackingActor = None;
		//PrePivot.X = -34;
		//bForceHitWall = true;
	}

	function EndState()
	{
		//PrePivot.X = Default.PrePivot.X;
		HeadTrackingActor = Enemy;
		//bForceHitWall = false;
	}
		// actor location - prepivot
	function HitWall( vector HitNormal, actor HitWall )
	{
		local actor HitActor;
		local vector HitLocation, HitNorm, StartTrace, EndTrace, NormalHit;
		local vector X,Y,Z;
		local rotator AdjustedRot;

		if( HitWall.IsA( 'LevelInfo' ) )
		{
			GetAxes( ViewRotation, X, Y, Z );
			StartTrace = Location + ( ( CollisionRadius * 0.5 ) * Y );
			EndTrace = StartTrace + vector( Rotation ) * 64;

			HitActor = Trace( HitLocation, HitNorm, EndTrace, StartTrace, true );
			if( HitActor.IsA( 'LevelInfo' ) )
			{
				StartTrace = Location - ( ( CollisionRadius * 0.5 ) * Y );
				EndTrace = StartTrace + vector( Rotation ) * 64;
				HitActor = Trace( HitLocation, NormalHit, EndTrace, StartTrace, true );
				if( !HitActor.IsA( 'LevelInfo' ) )
					return;
				else
				{
					//PrePivot = ( Location - PrePivot );
					//PrePivot = ( Location - HitNormal ) * 2;
					bResetPrepivot = false;
					AdjustedRot = Rotation;
					AdjustedRot.Pitch = 0;
					PrePivot = vector( AdjustedRot ) * -25;
					PivotRot = vector( AdjustedRot );
					PivotAdjust = -25;
					PrePivot.Z = Default.PrePivot.Z;
					GotoState( 'Charging', 'WallHit' );
					return;
				}
			}
		}
		else
		if( HitWall.IsA( 'dnDecoration' ) && !HitWall.IsA( 'InputDecoration' ) && !Hitwall.IsA( 'ControllableTurret' )  )
		{
			dnDecoration( HitWall ).Topple( self, HitWall.Location, vector( Rotation ) * 27550 + vect( 0, 0, 350 ), 20 );
			return;
		}
		StopMoving();
		PlayToWaiting();
		GotoState( 'ApproachingEnemy' );
	}

WallHit:
//	PrePivot.X = -30;
	HeadTrackingActor = None;
	StopMoving();
	PlayAllAnim( 'ChargeHitWall',, 0.1, false );
	DesiredRotation.Pitch = 0;
	FinishAnim( 0 );
	if( VSize( Enemy.Location - Location ) > 750 || !CanDirectlyReach( Enemy ) )
	{
		GotoState( 'ApproachingEnemy' );
	}
	else
	{
TurnAfterWallHit:
	Destination = Enemy.Location;
	if( ( Rotator( Enemy.Location - Location ) - Rotation ).Yaw != 0 && ( Rotator( Enemy.Location - Location ) - rotation ).Yaw != -65536)
	{
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'TurnAfterWallHit' );
	}
	bResetPrePivot = true;
//	PrePivot = Default.PrePivot;
	GotoState( 'ApproachingEnemy' );
	}
ChargeHit:
	PlayAllAnim( 'ChargeHit',, 0.12 );
	FinishAnim( 0 );
	StopMoving();
	PlayToWaiting();
	Enable( 'Bump' );
	GotoState( 'ApproachingEnemy' );

Begin:
	if( VSize( Enemy.Location - Location ) > 100 && FRand() < 0.25 )
	{
		PlayAllAnim( 'Roar_Charge',, 0.1, false );
		Sleep( 0.1 );
		FinishAnim( 0 );
	}
	HeadTrackingActor = None;
	PlayToCharging();
Moving:
	MoveToward( Enemy, ChargeSpeed );
	if( !WallAhead() )
	{
		Goto( 'Moving' );
	}
	else
	{
	//	StopMoving();
		//PlayToWaiting();
		GotoState( 'ApproachingEnemy', 'Moving' );
	}
}

function bool WallAhead()
{
	if( !FastTrace( Location + vector( Rotation ) * 650, Location ) ) 
	{
		return true;
	}
	else
	{
		return false;
	}
}

function SetDamageBone(name BoneName)
{
	if (BoneName=='None')
		return;
	LastDamageBone = BoneName;
	DamageBone = BoneName;
}

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if ( ClassIsChildOf(DamageType, class'CrushingDamage') )
		return;
	else
	{
		Super.TakeDamage( Damage, instigatedBy, HitLocation, Momentum, DamageType );
		NextState = GetStateName();
		
		if( Damage > 50 || ( FRand() < 0.25 && Health < ( Default.Health * 0.33 ) ) )
		{
			NextState = GetStateName();
			GotoState( 'TakeHit' );
		}
		else if( ( GetStateName() == 'Idling' || GetStateName() == 'Wandering' ) && Enemy == None ) 
		{
			Enemy = instigatedBy;
			GotoState( 'Idling', 'Acquisition' );
		}
	}
}

state TakeHit
{
	function PlayPainAnim()
	{
		local Pawn.EPawnBodyPart BodyPart;
		local float Dmg;
    		
	    BodyPart = BODYPART_Default;

		BodyPart = GetPartForBone( LastDamageBone );
		
		Switch( BodyPart )
		{
			case BODYPART_Head:
				PlayAllAnim( 'PainHead',, 0.1, false );
				break;
			
			case BODYPART_Chest:
				PlayAllAnim( 'PainChest',, 0.1, false );
				break;

			case BODYPART_ShoulderRight:
				PlayAllAnim( 'PainArm_R',, 0.1, false );
				break;

			case BODYPART_HandRight:
				PlayAllAnim( 'PainArm_R',, 0.1, false );
				break;
			
			case BODYPART_ShoulderLeft:
				PlayAllAnim( 'PainArm_L',, 0.1, false );
				break;

			case BODYPART_HandLeft:
				PlayAllAnim( 'PainArm_L',, 0.1, false );
				break;

			default:
				PlayAllAnim( 'PainChest',, 0.1, false );
				break;
		}
		TimeBetweenPain = 0;
	}

Begin:
	StopMoving();
	PlayPainAnim();
	FinishAnim();
	if( NextState == 'TakeHit' || NextState == 'Swatting' )
		GotoState( 'ApproachingEnemy' );
	else
	{
		GotoState( NextState );
	}
}

function bool CanDirectlyReach( actor ReachActor )
{
	local vector HitLocation,HitNormal;
	local actor HitActor;

	HitActor = Trace( HitLocation, HitNormal, Enemy.Location + vect( 0, 0, -19 ), Location + vect( 0, 0, -19 ), true );
	
	if( HitActor.IsA( 'dnDecoration' ) && LineOfSightTo( Enemy ) )
		return true;

	if( HitActor == Enemy && LineOfSightTo( Enemy ) )
	{
		return true;
	}
	
	return false;
}

simulated event bool OnEvalBones(int Channel)
{
	if (!bHumanSkeleton)
		return false;
	// Update head.
    if (Channel == 8)
	{
		if( !PlayerCanSeeMe() )
			return false;

		if( Health > 0 )
		{
			EvalHeadLook();
		}	
	}
	return true;
}

state Wandering
{
	ignores EnemyNotVisible;

	function SeePlayer( actor SeenPlayer )
	{
		if( bAggressiveToPlayer && PlayerPawn( SeenPlayer ) != None )
		{
			Enemy = SeenPlayer;
			StopMoving();
			GotoState( 'Wandering', 'Acquisition' );
		}
		Disable( 'SeePlayer' );
	}
	
	function Timer( optional int TimerNum )
	{
		Enable('Bump');
	}
	
	function SetFall()
	{
		NextState = 'Wandering'; 
		NextLabel = 'ContinueWander';
		GotoState('FallingState'); 
	}
	
	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Wandering', 'Pausing');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
			GotoState('Wandering', 'AdjustFromWall');
		else
			MoveTimer = -1.0;
	}
		
	function bool TestDirection(vector dir, out vector pick)
	{	
		local vector HitLocation, HitNormal, dist;
		local float minDist;
		local actor HitActor;
	
		minDist = FMin(150.0, 4*CollisionRadius);
		pick = dir * (minDist + (450 + 12 * CollisionRadius) * FRand());
	
		HitActor = Trace(HitLocation, HitNormal, Location + pick + 1.5 * CollisionRadius * dir , Location, false);
		if (HitActor != None)
		{
			pick = HitLocation + (HitNormal - dir) * 2 * CollisionRadius;
			HitActor = Trace(HitLocation, HitNormal, pick , Location, false);
			if (HitActor != None)
				return false;
		}
		else
			pick = Location + pick;
		 
		dist = pick - Location;
		if (Physics == PHYS_Walking)
			dist.Z = 0;
		
		return (VSize(dist) > minDist); 
	}
			
	function PickDestination()
	{
		local vector pick, pickdir;
		local bool success;
		local float XY;
		//Favor XY alignment
		XY = FRand();
		if (XY < 0.3)
		{
			pickdir.X = 1;
			pickdir.Y = 0;
		}
		else if (XY < 0.6)
		{
			pickdir.X = 0;
			pickdir.Y = 1;
		}
		else
		{
			pickdir.X = 2 * FRand() - 1;
			pickdir.Y = 2 * FRand() - 1;
		}
		if (Physics != PHYS_Walking)
		{
			pickdir.Z = 2 * FRand() - 1;
			pickdir = Normal(pickdir);
		}
		else
		{
			pickdir.Z = 0;
			if (XY >= 0.6)
				pickdir = Normal(pickdir);
		}	
	
		success = TestDirection(pickdir, pick);
		if (!success)
			success = TestDirection(-1 * pickdir, pick);
			
		if (success)	
			Destination = pick;
		else
			GotoState('Wandering', 'Turn');
	}
	
	function AnimEnd()
	{
		PlayPatrolStop();
	}

	function FearThisSpot(Actor aSpot, optional Pawn Instigator )
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
	}

	function BeginState()
	{
		Enemy = None;
		Disable('AnimEnd');
		bCanJump = false;
	}
	
	function EndState()
	{
		if (JumpZ > 0)
			bCanJump = true;
	}
	
Begin:
	//log(class$" Wandering");
	
Wander: 
	WaitForLanding();
	PickDestination();
	FinishAnim( 0 );
Moving:
	Enable('HitWall');
	if( ( Rotator( Destination - Location ) - Rotation ).Yaw != 0 && ( Rotator( Destination - Location ) - rotation ).Yaw != -65536)
	{
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Moving' );
	}
	PlayToWalking();
	MoveTo(Destination, WalkingSpeed * 0.33 );
Pausing:
	Acceleration = vect(0,0,0);
/*	if ( NearWall(2 * CollisionRadius + 50) )
	{
		//PlayTurning();
		TurnTo(Focus);
	}*/
	PlayToWaiting( 0.13 );
	Sleep(1.0);
	FinishAnim( 0 );
	Goto('Wander');
ContinueWander:
	FinishAnim( 0 );
	PlayToWalking();
	if (FRand() < 0.2)
		Goto('Turn');
	Goto('Wander');
	
Turn:
	Acceleration = vect(0,0,0);
	//PlayTurning();
	TurnTo(Location + 20 * VRand());
	Goto('Pausing');

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Moving');

Acquisition:
	if( ( Rotator( Enemy.Location - Location ) - Rotation ).Yaw != 0 && ( Rotator( Enemy.Location - Location ) - rotation ).Yaw != -65536)
	{
		Destination = Enemy.Location;
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Acquisition' );
	}
	PlayToWaiting();
	if( FRand() < 0.7 )
	{
		PlayAllAnim( 'Roar_Long',, 0.1, false );
		FinishAnim( 0 );	
	}
	EnableHeadTracking( true );
	HeadTrackingActor = Enemy;
	GotoState( 'ApproachingEnemy' );

}

function bool NearWall(float walldist)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

	LookDir = vector(Rotation);
	ViewSpot = Location + BaseEyeHeight * vect(0,0,1);
	ViewDist = LookDir * walldist; 
	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
		return false;
	
	ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
	if (FRand() < 0.5)
		ViewDist *= -1;
	
	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
	{
		Focus = Location + ViewDist;
		return true;
	}
	
	ViewDist *= -1;
	
	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
	{
		Focus = Location + ViewDist;
		return true;
	}
	
	Focus = Location - LookDir * 300;
	return true;
}

DefaultProperties
{
     CreatureOrders=ORDERS_Roaming   
	 bAggressiveToPlayer=true
	 Mesh=mesh'c_characters.alien_pig'  
     CollisionHeight=33
     CollisionRadius=32
	 PathingCollisionHeight=39
	 GroundSpeed=750
	 PathingCollisionRadius=17
     bModifyCollisionToPath=true
     RunSpeed=0.3
     ChargeSpeed=1.14
     AIMeleeRange=200
	 WalkingSpeed=0.25
     CarcassType=class'AlienPigCarcass'
     Health=850
//     RotationRate=(Pitch=0,Yaw=22000,Roll=2572)
	 ImmolationClass="dnGame.dnPawnImmolation_AlienPig"
}
