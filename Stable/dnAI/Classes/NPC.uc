//=============================================================================
// NPC.
//=============================================================================
class NPC expands HumanNPC abstract;

#exec OBJ LOAD FILE=..\sounds\TEMPVOICE.dfx PACKAGE=TEMPVOICE
#exec OBJ LOAD FILE=..\sounds\a_doors.dfx

var bool bCowerOnce;
var() bool bOneShotSuffer;
var HidePoint OldFollowActor;
var Actor MyOldFollowActor;
var() bool bForceDrawscale;

var( AISpecial ) bool			bUseFlashlight;
var/*( AISpecial )*/ dnDecoration	MyHeldItem;

/*
var( AISpecial ) name			UseMountMeshItem;
var( AISpecial ) vector			UseMountAngles;
var( AISpecial ) rotator		Use*/

var bool bDisabled;
var float LastSkinChange;

var int SnatchWalk;

function ChooseAttackState(  optional name NextLabel, optional bool bWounded  );

function PostBeginPlay()
{
	local bool bMounted;
	//local int DrawScaleMod;

	///DrawScaleMod = Rand( 10 );
	
	SnatchWalk = Rand( 3 );
	
	if( bSnatched )
	{
		bJumpCower = false;
	}
	//if( !bForceDrawScale )
	//	DrawScale += ( DrawScaleMod * 0.01 );

	if( bUseFlashlight )
	{
		bOneShotSuffer = false;
		SetFlashlightUserRotation( true );

		MyHeldItem = spawn( class'G_Flashlight', self );
		MyHeldItem.bNotTargetable = true;
		MyHeldItem.bCollideWorld = false;
		MyHeldItem.SetCollision( false, false, false );
		MyHeldItem.MountMeshItem		= 'Hand_R';
		MyHeldItem.MountAngles.Pitch	= -8192;
		MyHeldItem.MountAngles.Yaw		= 14000;
		MyHeldItem.MountAngles.Roll		= 0;
		MyHeldItem.MountOrigin.X		= -2.5;
		MyHeldItem.MountOrigin.Y		= 5;
		MyHeldItem.MountOrigin.Z		= -10.5;
		MyHeldItem.MountType			= MOUNT_MeshBone;
		MyHeldItem.SetPhysics( PHYS_MovingBrush );
		bMounted = AddMountable( MyHeldItem, false, false );

	}
	Super.PostBeginPlay();
}


/*=============================================================================
	NPC Behavior States.
=============================================================================*/

/*-----------------------------------------------------------------------------
	NPC state for when an NPC is being snatched.
-----------------------------------------------------------------------------*/
state Snatched
{
	ignores SeePlayer;

	function Used( actor Other, Pawn EventInstigator );
	function ReactToJump();

	function BeginState()
	{
		//// log( ""--- Snatched state entered." );
	}

Begin:
	PlayAllAnim( 'A_Suffer_ChestFall',, 0.1, false );
	FinishAnim( 0 );
	PlayAllAnim( 'A_Suffer_Chest',, 0.1, false );
	Sleep( 5.0 );
	Health = 50;
	PlayToWaiting( 0.4 );
	bAggressiveToPlayer = true;
	bSnatched = true;
	GotoState( 'Idling' );
}


/*-----------------------------------------------------------------------------
	NPC Cowering State for non snatched, non aggressive NPCs.
-----------------------------------------------------------------------------*/
state Cowering
{
	ignores SeePlayer, EnemyNotVisible;

function Used( actor Other, Pawn EventInstigator );

function BeginState()
{
	//// log( ""---- Cowering state entered" );
}

function PlayCowering()
{
	local float Decision;

	Decision = FRand();

	if( Decision < 0.3 )
		PlayAllAnim( 'A_NPCCowerA',, 0.1, false );
	else if( Decision < 0.6 )
		PlayAllAnim( 'A_NPCCowerB',, 0.1, false );
	else 
		PlayAllAnim( 'A_NPCCowerC',, 0.1, false );
}

Begin:
	TurnToward( Enemy );
	HeadTrackingActor = Enemy;
	Enemy = None;
	PlayCowering();
	FinishAnim( 0 );
	// log( ""IdleStandINactive 3" );
	PlayAllAnim( 'A_IdleStandInactive',, 0.5, true );
}

state Hunting
{
	function BeginState()
	{
		log( self$" with "$bSleepAttack$" Going to ApproachingEnemy 5" );
		GotoState( 'ApproachingEnemy' );
	}
}

/*-----------------------------------------------------------------------------
	NPC Approaching Enemy State. 
-----------------------------------------------------------------------------*/
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
		{
			MoveTimer = -1.0;
			StopMoving();
		}
		Super.Bump( Other );
	}

	function SeePlayer( actor Other )
	{
		if( Other == Enemy )
		{
			MoveTimer = -1.0;
						log( self$" with "$bSleepAttack$" Going to ApproachingEnemy 6" );
			GotoState( 'ApproachingEnemy', 'SeenEnemy' );
			Disable( 'SeePlayer' );
		}
	}

	function HitWall( vector HitNormal, actor HitWall )
	{
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
			{
				log( self$" with "$bSleepAttack$" Going to ApproachingEnemy 7" );
				GotoState('ApproachingEnemy', 'AdjustFromWall');
			}
		}
		else
			MoveTimer = -1.0;
	}

	function BeginState()
	{
		if( bSnatched && bAggressiveToPlayer )
		{
			bVisiblySnatched = true;
		}
		if( Enemy != None )
			HeadTrackingActor = Enemy;

		//// log( ""---- Approaching enemy state entered" );
	}

SeenEnemy:
	Sleep( 0.25 );
	if( CanDirectlyReach( Enemy ) )
		Goto( 'DirectlyReach' );
Begin:
	PeripheralVision = -1.0;
	RotationRate.Yaw = 55000;
Moving:
	if( VSize( Enemy.Location - Location ) > 64 && /*!CanDirectlyReach( Enemy )*/ !CanSee( Enemy ) )
	{
		if( !FindBestPathToward( Enemy, true ) )
		{
			PlayToWaiting();
			GotoState( 'WaitingForEnemy' );
		}
		else
		{
			PlayToRunning();
			Enable( 'SeePlayer' );
			MoveTo( Destination, GetRunSpeed());
			Disable( 'SeePlayer' );
			// log( ""Test: "$VSize( Enemy.Location - Location ) );
			if( VSize( Enemy.Location - Location ) <= 64 )
				Goto( 'FollowReached' );
			else
				Goto( 'Moving' );
		}
	}
	else 
DirectlyReach:	
	if( /*CanDirectlyReach( Enemy )*/ CanSee( Enemy ) && VSize( Enemy.Location - Location ) > 64 )
	{
		PlayToRunning();
		MoveTo( Location - 64 * Normal( Location - Enemy.Location), GetRunSpeed() );
	}
	else if( VSize( Enemy.Location - Location ) <= 64 ) 
		Goto( 'FollowReached' );
	Goto( 'Moving' );

FollowReached:
	GotoState( 'TentacleThrust' );

AdjustFromWall:
	StrafeTo(Destination, Focus, GetRunSpeed() ); 
	Destination = Focus; 
	Goto('Begin');
}


/*-----------------------------------------------------------------------------
	Idling state.
-----------------------------------------------------------------------------*/
state Idling
{
	ignores HitWall, EnemyNotVisible;

	//function Tick( float DeltaTime )
	//{
	//	if( PlayerCanSeeMe() && HeadTrackingActor == None )
	//	{
	//		Enable( 'SeePlayer' );
	//		Disable( 'EnemyNotVisible' );
	//	}
	//	Super.Tick( DeltaTime );
	//}
	
	function BeginState()
	{
		////if( bIdleSeeFriendlyMonsters )
		//	Enable( 'SeeMonster' );
		//if( bIdleSeeFriendlyPlayer )
		Enable( 'SeePlayer' );
	}

	function SeeMonster( actor Seen )
	{
	//	HeadTrackingActor = Seen;
	//	Enemy = Seen;
	//	Disable( 'SeeMonster' );
	//	Enable( 'EnemyNotVisible' );
	}

	function EndState()
	{
		SightRadius = Default.SightRadius;
		//Disable( 'SeeMonster' );
	}

	function PlayIdlingAnimation()
	{
		PlayAllAnim( InitialIdlingAnim,, 0.1, true );
	}

	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		local vector OldLastSeenPos;
		
		if( NoiseMaker.IsA( 'LaserMine' ) && !LaserMine( NoiseMaker ).bNPCsIgnoreMe && Loudness == 0.5 && !LineOfSightTo( NoiseMaker ) )
		{
			SuspiciousActor = NoiseMaker;
			GotoState( 'Investigating' );
			return;
		}

		if( bAggressiveToPlayer && NoiseMaker.IsA( 'PlayerPawn' ) || ( bAggressiveToPlayer && NoiseMaker.Instigator.IsA( 'PlayerPawn' ) ) )
		{
			Enemy = NoiseMaker.Instigator;
			if( Enemy != None )
			{
				GotoState( 'Attacking' );
			}
		}
	}

	function SeePlayer( actor SeenPlayer )
	{
		local float Dist;

		if( bAggressiveToPlayer )
		{
			if( AggressionDistance > 0.0 )
			{
				if( Dist > AggressionDistance )
					return;
			}
			HeadTrackingActor = SeenPlayer;
			Enemy = SeenPlayer;
			if( Enemy == OldEnemy )
				GotoState( 'Attacking' );
			else
				GotoState( 'Acquisition' );
		}
		// Sneaky attacks (only if they cannot be seen). Necessary for Grunts, or not?
		else if( bSneakAttack && bSnatched && !bAggressiveToPlayer )
		{
			if( Dist <= AggroSnatchDistance )
			{
				if( !PlayerCanSeeMe()  )
				{
					Disable( 'SeePlayer' );
					Enemy = SeenPlayer;
					NextState = 'Attacking';
					bAggressiveToPlayer = true;
					GotoState( 'SnatchedEffects' );
				}
			}
		}
		// Friendly
		else if( bIdleSeeFriendlyPlayer )
		{
			//Enemy = SeenPlayer;
			HeadTrackingActor = SeenPlayer;
			Disable( 'SeePlayer' );
			//Enable( 'EnemyNotVisible' );
		}
	}

Begin:
	StopMoving();
	PlayToWaiting( 0.2 );
	//Enable( 'SeeMonster' );
	if( InitialIdlingAnim != '' )
	{	
		PlayIdlingAnimation();
		if( !bReuseIdlingAnim )
			InitialIdlingAnim = '';
	}
	if( bPanicOnFire )
	{
		bPanicking = true;
		ImmolationActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ImmolationClass, class'Class' )), Self );
		ImmolationActor.Initialize();
		if( NPCOrders != ORDERS_Patrol )
			GotoState( 'Wandering' );
	}

	if( bFixedEnemy )
	{
		Sleep( 0.15 );
		GotoState( 'Attacking' );
	}
	if( !bPatrolled )
	{
		if( NPCOrders == ORDERS_Patrol )
		{
			// log( ""Going to patrolling state" );
			GotoState( 'Patrolling' );
			bPatrolled = true;
		}
	}
}

function Used( actor Other, Pawn EventInstigator )
{
	if( bUseFlashlight )
	{
		if( GetStateName() != 'Following' )
		{
			SetFlashlightUserRotation( true );
			DesiredRotation = rotator( normal( Other.Location - Location ) );
			DesiredRotation.Pitch = 0;
			TriggerFollow( Other );
		}
		else
		{
			SetFlashlightUserRotation( false );
			FollowActor = None;
			GotoState( 'Wandering' );
		}
	}
	else
		Super.Used( Other, EventInstigator );
}

simulated function bool EvalBlinking()
{
	local int bone;
	local MeshInstance minst;
	local vector t;
	local float deltatime;
	local rotator r;

	Minst = GetMeshInstance();

	if( bEyesShut )
	{
		CloseEyes();
		return false;
	}

     if( bSleepAttack || bVisiblySnatched || bSleeping || bEMPed || bEyeless )
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

	bone = minst.BoneFindNamed('Eyelid_L');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	bone = minst.BoneFindNamed('Eyelid_R');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	return(true);
}

function SetFlashlightUserRotation( bool bDefault )
{
	if( !bDefault )
	{
		RotationRate.Pitch	= 3072;
		RotationRate.Yaw	= 20000;
		RotationRate.Roll	= 2048;
	}
	else
	{
		RotationRate		= Default.RotationRate;
	}
}

function float GetWalkingSpeed()
{
	if( bPanicking )
		return GetRunSpeed();
	else if( bVisiblySnatched )
		return WalkingSpeed + 0.15;
	else
		return WalkingSpeed;
}

function Died(pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	if( MyHeldItem != None )
	{
		RemoveMountable( MyHeldItem );
		MyHeldItem.AttachActorToParent( none, false, false );
		MyHeldItem.SetPhysics( PHYS_Falling );
		MyHeldItem.bCollideWorld = true;
		MyHeldItem.SetCollision( true, true, true );
		MyHeldItem.SetOwner( None );
		MyHeldItem.bNotTargetable = false;
	}
	
	if( MyGiveItem != None )
	{
		MyGiveItem.Destroy();
	}
	Super.Died( Killer, DamageType, HitLocation );
}

function PlayToRunning()
{
	if( bUseFlashlight )
	{
		if( IsAnimating( 1 ) )
			PlayTopAnim( 'None' );
		PlayAllAnim( 'A_Run_Flashlight',, 0.1, true );
		return;
	}
	else if( bVisiblySnatched )
	{
		if( bPanicOnFire )
		{
			PlayAllAnim('A_Run',, 0.3,true);
			PlayTopAnim( 'T_ImOnFire',, 0.1, true );
		}
		else
		{
			if( SnatchWalk == 0 )
				PlayAllAnim( 'A_SnatchedRunA',, 0.1, true );
			else if( SnatchWalk == 1 )
				PlayAllAnim( 'A_SnatchedRunB',, 0.1, true );
			else if( SnatchWalk == 2 )
				PlayAllAnim( 'A_SnatchedRunC',, 0.1, true );
			else if( SnatchWalk == 3 )
				PlayAllAnim( 'A_SnatchedRunD',, 0.1, true );
		}
	}
	else
		Super.PlayToRunning();
}

function PlayDeath( EPawnBodyPart BodyPart, class<DamageType> DamageType )
{
	local name DeathSequence;
	local MeshInstance minst;

	PlayTopAnim( 'None' );
	PlayBottomAnim( 'None' );

	if( bSuffering )
		return;

	if( ClassIsChildOf(DamageType, class'FallingDamage') )
	{
		PlayAllAnim( 'A_Dead_DownB',, 0.25, true );
		return;
	}
	if( bUseFlashlight )
	{
		PlayAllAnim( 'A_Death_FallStraightDown',, 0.25, false );
		return;
	}

	if( GetSequence( 0 ) == 'A_KnockDownF_All' )
	{
		PlayAllAnim( 'A_Death_FallOnGround',, 0.25, false );
		return;
	}

	if( ClassIsChildOf(DamageType, class'DrowningDamage') )
	{
		DeathSequence = 'A_Death_Choke';
		return;
	}
	
	if( InFrontOfWall() )
	{
		if( FRand() < 0.5 )
			PlayAllAnim( 'A_Death_HitWall1',, 0.1, false );
		else 
			PlayAllAnim( 'A_Death_HitWall2',, 0.1, false );
		return;
	}
	if( FacingWall() )
	{
		PlayAllAnim( 'A_Death_HitWall_F',, 0.1, false );
		return;
	}
	
	if( ClassIsChildOf(DamageType, class'FallingDamage') && bOneShotSuffer && Health > -100 && BodyPart != BODYPART_Head )
	{
		switch(BodyPart)
		{
			Case BODYPART_Chest: 		
				PlayAllAnim( 'A_Suffer_ChestFall',, 0.1, false );
				bSuffering = true;
				break;
			Case BODYPART_KneeRight:
				bSuffering = true;
				PlayAllAnim( 'A_Suffer_RLegFall',, 0.1, false );
				break;
			Case BODYPART_FootRight:
				bSuffering = true;
				PlayAllAnim( 'A_Suffer_RLegFall',, 0.1, false );
				break;
			Default:
				bSuffering = true;
				PlayAllAnim( 'A_Suffer_ChestFall',, 0.1, false );
				break;
		}
		return;
	}
	switch(BodyPart)
	{
		case BODYPART_Head:
			if ( ClassIsChildOf(DamageType, class'DecapitationDamage') )
				bHeadBlownOff = true;
			DeathSequence = 'A_Death_HitHead';
			break;
		case BODYPART_Chest:
			//DeathSequence = 'A_Death_HitChest';			break;
			if( FRand() < SufferFrequency && Health > -100 )
			{
				DeathSequence = 'A_Suffer_ChestFall';
				bSuffering = true;
			}
			else
				DeathSequence = 'A_Death_HitChest';	
			break;

		case BODYPART_Stomach:		DeathSequence = 'A_Death_HitStomach';		break;
		case BODYPART_Crotch:		DeathSequence = 'A_Death_Fallstraightdown';	break;
		case BODYPART_ShoulderLeft: DeathSequence = 'A_Death_HitLShoulder';		break;
		case BODYPART_ShoulderRight:DeathSequence = 'A_Death_HitRShoulder';		break;			
		case BODYPART_HandLeft:		DeathSequence = 'A_Death_HitLShoulder';		break;
		case BODYPART_HandRight:	DeathSequence = 'A_Death_HitRShoulder';		break;
		case BODYPART_KneeLeft:		DeathSequence = 'A_Death_Hitback1';			break;
		case BODYPART_KneeRight:
			if( FRand() < SufferFrequency && Health > -100 )
			{
				DeathSEquence = 'A_Suffer_RLegFall';
				bSuffering = true;
			}
			else
			{
				DeathSequence = 'A_Death_Hitback1';
			}
			break;
		case BODYPART_FootLeft:		DeathSequence = 'A_Death_Hitback2';			break;
		case BODYPART_FootRight:
			if( FRand() < SufferFrequency && Health > -100 )
			{
				bSuffering = true;
				DeathSEquence = 'A_Suffer_RLegFall';
			}
			else
			{
				bSuffering = true;
				DeathSequence = 'A_Death_Hitback1';
			}
			break;

		case BODYPART_Default:		DeathSequence = 'A_Death_HitStomach';		break;
	}

	PlayAllAnim(DeathSequence,,0.1,false);
}



state NPCSuffering
{
	ignores Bump, SeePlayer;

	function BeginState()
	{
		Health = 1;
	}

	function ReactToJump()
	{
	}

	function Used( actor Other, Pawn EventInstigator )
	{
	}

	function JumpCower()
	{
	}

Begin:
}

function ReactToJump()
{
	if( !IsInState( 'ActivityControl' ) && bJumpCower && !bCoweringDisabled )
	{
		bCowerOnce = true;
		NextState = GetStateName();
		GotoState( 'Cowering' );
	}
}

function PlayCowering()
{
	local float Decision;

	Decision = FRand();

	if( Decision < 0.3 )
		PlayAllAnim( 'A_NPCCowerA',, 0.1, false );
	else if( Decision < 0.6 )
		PlayAllAnim( 'A_NPCCowerB',, 0.1, false );
	else 
		PlayAllAnim( 'A_NPCCowerC',, 0.1, false );
}


function Tick( float inDeltaTime )
{	
	InterpolateCollisionHeight();
	// Shrinking tick.
	TickShrinking( inDeltaTime );
	if( !bPlayerCanSeeMe )
		return;
	
	TickTracking( inDeltaTime );
	if( bNoLookAround )
	{
		LastLookTime += inDeltaTime;
		if( LastLookTime > LookInterval )
		{
			LastLookTime = 0;
			bNoLookAround = false;
		}
	}
}

/*-----------------------------------------------------------------------------
	NPC Takehit (Damage) State. 
-----------------------------------------------------------------------------*/
function EnableEyeTracking( bool bEnable )
{
	EyeTracking.DesiredWeight = 0.12;
	EyeTracking.WeightRate = 1.0;
}

function bool EvalHeadLook()
{
	local int bone;
	local MeshInstance minst;
	local rotator r;

	if( !bPlayerCanSeeMe )
		return false;

	if( GetSequence( 0 ) == 'A_CowerKneelSG' )
		return false;
	else if( bVisiblySnatched )
	{
		Minst = GetMeshInstance();
		bone = minst.BoneFindNamed('Pupil_L');
		if (bone!=0)
		{			
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		}
		bone = minst.BoneFindNamed('Pupil_R');
		if (bone!=0)
		{
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		}
	}
	else
		Super.EvalHeadLook();
}

function TickTracking(float inDeltaTime)
{
	local rotator r;

	if( HeadTrackingActor != None )
		HeadTracking.DesiredWeight = 0.85;
	else
		HeadTracking.DesiredWeight = 0.5;
	if( bUseFlashlight )
		HeadTracking.DesiredWeight = 0.1;

	if (HeadTracking.TrackTimer <= 0.0 && FRand() < 0.25 && HeadTrackingActor == None && Enemy == None && GetStateName() != 'ActivityControl' )
	{
		HeadTracking.TrackTimer = 2.5 + FRand()*1.5;
		HeadTracking.DesiredRotation = Normalize(Rotation + rot(0, int(FRand()*19384.0 - 8192.0), 0));
		HeadTracking.DesiredRotation.Pitch = 0;
		HeadTracking.DesiredRotation.Roll = 0;
	}
	if (HeadTracking.TrackTimer > 0.0)
	{
		HeadTracking.TrackTimer -= inDeltaTime;
		if (HeadTracking.TrackTimer < 0.0)
			HeadTracking.TrackTimer = 0.0;
	}
	HeadTracking.Weight = UpdateRampingFloat(HeadTracking.Weight, HeadTracking.DesiredWeight, HeadTracking.WeightRate*inDeltaTime);
	r = ClampHeadRotation(HeadTracking.DesiredRotation);
	HeadTracking.Rotation.Pitch = FixedTurn(HeadTracking.Rotation.Pitch, r.Pitch, int(HeadTracking.RotationRate.Pitch * inDeltaTime));
	HeadTracking.Rotation.Yaw = FixedTurn(HeadTracking.Rotation.Yaw, r.Yaw, int(HeadTracking.RotationRate.Yaw * inDeltaTime));
	HeadTracking.Rotation.Roll = FixedTurn(HeadTracking.Rotation.Roll, r.Roll, int(HeadTracking.RotationRate.Roll * inDeltaTime));
	HeadTracking.Rotation = ClampHeadRotation(HeadTracking.Rotation);
	// update eye tracking
	if (EyeTracking.TrackTimer > 0.0)
	{
		if( !bLookingAround && HeadTrackingActor != None && EyeTracking.DesiredRotation != Normalize( rotator( normal( HeadTrackingLocation - Location ) ) ) )
			EyeTracking.TrackTimer = 0.0;

		EyeTracking.TrackTimer -= inDeltaTime;
		if (EyeTracking.TrackTimer < 0.0)
			EyeTracking.TrackTimer = 0.0;
	}
	EyeTracking.Weight = UpdateRampingFloat(EyeTracking.Weight, EyeTracking.DesiredWeight, EyeTracking.WeightRate*inDeltaTime);
	r = EyeTracking.DesiredRotation;
	EyeTracking.Rotation.Pitch = FixedTurn(EyeTracking.Rotation.Pitch, r.Pitch, int(EyeTracking.RotationRate.Pitch * inDeltaTime));
	EyeTracking.Rotation.Yaw = FixedTurn(EyeTracking.Rotation.Yaw, r.Yaw, int(EyeTracking.RotationRate.Yaw * inDeltaTime));
	EyeTracking.Rotation.Roll = FixedTurn(EyeTracking.Rotation.Roll, r.Roll, int(EyeTracking.RotationRate.Roll * inDeltaTime));
	EyeTracking.Rotation = ClampEyeRotation(EyeTracking.Rotation);
	if (EyeTracking.TrackTimer <= 0.0 )
	{
		EyeTracking.TrackTimer = 0.3 + FRand()*1.5;
		if( HeadTrackingActor == None )
		{
			EyeTracking.DesiredWeight = 0.3;
			EyeTracking.DesiredRotation = Normalize(Rotation + rot(0, int(FRand()*20384.0 - 8192.0), 0));
		}
		else
		{
			if( FRand() < 0.25 && !bNoLookAround && !bForceNoLookAround )
			{
				if( FRand() < 0.5 )
					EyeTracking.DesiredRotation = Normalize( Rotation + rot( 0, -12000, 0 ) );
				else
					EyeTracking.DesiredRotation = Normalize( Rotation + rot( 0, 12000, 0 ) );
				EyeTracking.DesiredWeight = 0.35;
				bLookingAround = true;
				bNoLookAround = true;
			}
			else
			{
				EyeTracking.DesiredWeight = 0.2;
				if( HeadTrackingActor != None )
				{
					if( bNoLookAround )
					{
						if( Pawn( HeadTrackingActor ) != None )
							EyeTracking.DesiredRotation = Normalize( rotator( normal( ( HeadTrackingLocation + ( vect( 0, 0, 1 ) * Pawn( HeadTrackingActor ).BaseEyeHeight ) ) - Location ) ) ) ;//+ rot(0, int(FRand()*20384.0 - 8192.0), 0);
						else EyeTracking.DesiredRotation = Normalize( rotator( normal( ( HeadTrackingLocation  ) ) ) );

					}

					else
					{
						if( Pawn( HeadTrackingActor ) != None )
							EyeTracking.DesiredRotation = Normalize( rotator( normal( ( HeadTrackingLocation + ( vect( 0, 0, 1 ) * Pawn( HeadTrackingActor ).BaseEyeHeight ) ) - Location ) ) ) + rot(0, int(FRand()*20384.0 - 8192.0), 0);
						else EyeTracking.DesiredRotation = Normalize( rotator( normal( ( HeadTrackingLocation  ) ) ) );
					}
				}
				bLookingAround = false;
			}
		}
		EyeTracking.DesiredRotation.Roll = 0;
	}
	if (HeadTrackingActor!=None)
	{
		HeadTrackingLocation = HeadTrackingActor.Location;
		HeadTracking.DesiredRotation = Normalize(rotator(Normal(HeadTrackingLocation - Location)));
		HeadTracking.DesiredRotation.Roll = 0;

	}
}

state TakeHit 
{
	ignores seeplayer, hearnoise, bump, hitwall;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

	function Landed(vector HitNormal)
	{
		if (Velocity.Z < -1.4 * JumpZ)
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		bJustLanded = true;
	}

	function Timer( optional int TimerNum )
	{
		bReadyToAttack = true;
	}

	function BeginState()
	{
		LastPainTime = Level.TimeSeconds;
		if ( (NextState == 'TacticalTest') && (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) )
			Destination = location;
	}
		
Begin:
	NextState = 'Attacking';

	FinishAnim( 0 );

	if (NextState != '')
		GotoState(NextState, NextLabel);
	else
		GotoState('Attacking');
}

function PlayToWaiting( optional float TweenTime )
{
	local float f;

	if( bUseFlashlight )
	{
		PlayAllAnim( 'A_IdleFlashLightA',, 0.16, true );
		return;
	}
	if( bReloading )
		return;

	if( GetSequence( 0 ) != 'A_Run' && GetStateName() != 'Idling' )
	{
		PlayBottomAnim('None');

		if( TweenTime == 0.0 )
			TweenTime = 0.1;

		if( Enemy == None )
			bWalkMode = true;
		else
			bWalkMode = false;
	
		if( Physics == PHYS_Swimming )
		{
			PlayAllAnim( 'A_SwimStroke',, TweenTime, true );
			PlayBottomAnim( 'B_SwimKickFwrd',, TweenTime, true );
		}
		else 
		{
			if( InitialIdlingAnim != '' && bReuseIdlingAnim )
			{
				if( GetSequence( 0 ) != InitialIdlingAnim )
					PlayAllAnim( InitialIdlingANim,, TweenTime, true );
			}
			else if( GetSequence( 0 ) != 'A_IdleStandInactive' ) 
				PlayAllAnim( 'A_IdleStandINactive',, TweenTime, true );
		}
	}
	else
	{
		if( InitialIdlingAnim != '' && bReuseIdlingAnim )
		{
			if( GetSequence( 0 ) != InitialIdlingAnim )
				PlayAllAnim( InitialIdlingAnim,, TweenTime, true );
		}
		else
			if( GetSequence( 0 ) != 'A_IdleStandInactive' )
				PlayAllAnim( 'A_IdleStandInactive',, TweenTime, true );
	}

	if( InitialTopIdlingAnim != '' )
		PlayTopAnim( InitialTopIdlingAnim,, 0.1, true );
	if( GetPostureState() == PS_Crouching )
		PlayCrouching();
}

/*-----------------------------------------------------------------------------
	Following State. 
-----------------------------------------------------------------------------*/
state Following
{
	function MayFall()
	{
//		// log( ""Following MayFall" );
	}

	function Bump( actor Other )
	{
		local vector VelDir, OtherDir;
		local float speed, dist;
		local Pawn P,M;
		local bool bDestinationObstructed, bAmLeader;
		local int num;

		P = Pawn(Other);
		if( P != None )
		{
			Disable( 'Bump' );
			GotoState( 'Following', 'GetOutOfWay' );
		}

		if ( TimerRate[ 0 ] <= 0 )
			setTimer( 0.2, false );
	}

	function HitWall( vector HitNormal, actor HitWall )
	{
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Following', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function BeginState()
	{
//		// log( ""--- Following state entered by "$self );
//		// log( ""--- Follow actor is:" $FollowActor );
	}

	function bool CloseEnough()
	{
		if( VSize( Location - FollowActor.Location ) <= FollowOffset )
			return true;

		return false;
	}

	function Timer( optional int TimerNum )
	{
		local actor HitActor;
		local vector HitLocation, HitNormal;
		local AIPawn P;
		local bool bFound;
		
		if( TimerNum == 3 )
		{
			Enable( 'Bump' );
			return;
		}

		if( !PlayerCanSeeMe() )
		{
			SetFlashlightUserRotation( false );
			DesiredRotation = Pawn( FollowActor ).ViewRotation;
			DesiredRotation.Pitch = 0;
		}
		else
		{
			SetFlashlightUserRotation( true );
			if( EnemyNearby() )
				CowerEvent();
		}
		if( !CloseEnough() )
			GotoState( 'Following', 'Begin' );
	}

	function CowerEvent()
	{
		Disable( 'Timer' );
		GotoState( 'Following', 'CowerEvent' );
	}

	function bool EnemyNearby()
	{
		local Pawn P;

		foreach radiusactors( class'Pawn', P, 256 )
		{
			if( P.IsA( 'AIPawn' ) && AIPawn( P ).bSnatched && CanSee( P ) )
				return true;
		}
	}

	function HidePoint FindHidePoint()
	{
		local HidePoint Spot, BestSpot;
		
		foreach radiusactors( class'HidePoint', Spot, 1024 )
		{
			if( HidePointClear( Spot ) )
				return Spot;
		}
	}

	function bool HidePointClear( HidePoint Spot )
	{
		local Pawn P;

		foreach Spot.RadiusActors( class'Pawn', P, 72 )
		{
			if( !EvaluateHIdePoint( Spot, P ) )
				return false;
			if( CanSeePawnFrom( Spot.Location, P ) || VSize( Spot.Location - Location ) < 48 )
				return false;
		}
		return true;
	}


	function bool CanDirectlyReach( actor ReachActor )
	{
		local vector HitLocation,HitNormal;
		local actor HitActor;

		HitActor = Trace( HitLocation, HitNormal, FollowActor.Location + vect( 0, 0, -19 ), Location + vect( 0, 0, -19 ), true );
		
		if( HitActor == FollowActor && LineOfSightTo( FollowActor ) )
			return true;
		
		return false;
	}

	function bool CanSeePawnFrom( vector aLocation, Pawn CheckPawn, optional float NewEyeHeight, optional bool bUseNewEyeHeight )
	{
		local actor HitActor;
		local vector HitNormal, HitLocation, HeightAdjust;

		if( bUseNewEyeHeight )
			HeightAdjust.Z = NewEyeHeight;
		else
			HeightAdjust.Z = BaseEyeHeight;
		HitActor = Trace( HitLocation, HitNormal, CheckPawn.Location, aLocation + HeightAdjust, true );
		if( HitActor == CheckPawn )
			return true;
		return false;
	}

	function bool EvaluateHIdePoint( HIdePoint NP, Pawn aPawn )
	{
		local float CosAngle, MinCosAngle;
		local vector VectorFromNPCToNP, VectorFromNPCToaPawn;

		if( NP == None || aPawn == None )
			return false;

		VectorFromNPCToNP = NP.Location - Location;
		VectorFromNPCToaPawn = aPawn.Location - Location;

		CosAngle = Normal( Location ) dot Normal( VectorFromNPCToaPawn );

		if( CosAngle < MinCosAngle )
			return true;

		return false;
	}

GetOutOfWay:

	if( FollowActor.bIsPawn )
	{
		SetTimer( 0.25, false, 3 );

		if( FRand() < 0.5 )
			Destination = FollowActor.Location + ( 96 * vect( 0, -1, 0 ) ) * vector( Pawn( FollowActor ).ViewRotation );
		else
			Destination = FollowActor.Location + ( 96 * vect( 0, 1, 0 ) ) * vector( Pawn( FollowActor ).ViewRotation );

		if( !PointReachable( Destination ) )
			Destination *= -1;

		PlayToWalking();
		MoveTo( Destination );
		PlayToWaiting();
	} 
	
AdjustFromWall:
	TurnTo( Destination );
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Begin');

Waiting:
	StopMoving();
	PlayToWaiting();
	Sleep( 1.0 );
	if( FollowTag == '' )
	{
		if( NextState == '' || NextState == 'Following' )
			NextState = 'Idling';
		if( bWanderAfterFollow )
			NextState = 'Wandering';
		GotoState( NextState );
	}
	Goto( 'Begin' );

Begin:
	if( GetSequence( 2 ) != '' )
		PlayBottomAnim( 'None' );
	Enable( 'Timer' );
	if( FollowTag == '' )
	{
		if( NextState == '' || NextState == 'Following' )
			NextState = 'Idling';
		if( bWanderAfterFollow )
			NextState = 'Wandering';
		GotoState( NextState );
	}
Moving:
	if( VSize( FollowActor.Location - Location ) > 128 && !CanDirectlyReach( FollowActor ) )
	{
		if( !FindBestPathToward( FollowActor, true ) )
		{
			PlayToWaiting();
			Goto( 'Waiting' );
		}
		else
		{
			PlayToRunning();
			HeadTrackingActor = MoveTarget;
			MoveTo( Destination, GetRunSpeed());
			if( VSize( FollowActor.Location - Location ) <= 128 )
				Goto( 'FollowReached' );
			else
				Goto( 'Moving' );
		}
	}
	else if( CanDirectlyReach( FollowActor ) && VSize( FollowActor.Location - Location ) > 128 )
	{
		PlayToRunning();
		HeadTrackingActor = MoveTarget;
		MoveTo( Location - 64 * Normal( Location - FollowActor.Location), GetRunSpeed() );
	}
	else if( VSize( FollowActor.Location - Location ) <= 128 ) 
		Goto( 'FollowReached' );

	Goto( 'Moving' );

FollowReached:
	StopMoving();
	PlayToWaiting();
	if( bStopWhenReached )
	{
		if( bWanderAfterFollow )
			NextState = 'Wandering';
		GotoState( NextState );
	}
	else
	{
		if( FRand() < 0.22 )
		{
			PlayTopAnim( 'None' );
			PlayAllAnim( 'A_IdleNervousFlashlightA',, 0.1, false );
			FinishAnim( 0 );
			PlayToWaiting();
		}
		SetTimer( 0.5, true );
	}
}

function PlayToWalking()
{
	if( bPanicOnFire )
	{
		PlayAllAnim('A_Run',, 0.3,true);
		PlayTopAnim( 'T_ImOnFire',, 0.1, true );
		return;
	}
	if( bUseFlashlight )
	{
		PlayTopAnim( 'None' );
		PlayAllAnim( 'A_WalkFlashlight',, 0.1, true );
	}
	else
		if( bVisiblySnatched )
		{
			if( SnatchWalk == 0 )
				PlayAllAnim( 'A_SnatchedRunA',, 0.1, true );
			else if( SnatchWalk == 1 )
				PlayAllAnim( 'A_SnatchedRunB',, 0.1, true );
			else if( SnatchWalk == 2 )
				PlayAllAnim( 'A_SnatchedRunC',, 0.1, true );
			else if( SnatchWalk == 3 )
				PlayAllAnim( 'A_SnatchedRunD',, 0.1, true );
		}
		else
			Super.PlayToWalking();
}

function DoorBashA()
{
	PlaySound( sound'a_doors.DoorBash18', SLOT_Misc, SoundDampening * 0.95 );
}

function DoorBashB()
{
	PlaySound( sound'a_doors.DoorBash14', SLOT_Misc, SoundDampening * 0.95 );
}

function WindowKnock()
{
	PlaySound( sound'a_doors.WindowKnock03', SLOT_Misc, SoundDampening * 0.95 );
}

state Wandering
{
	ignores EnemyNotVisible;
	function Bump( actor Other )
	{
		if( bPanicking && Other.IsA( 'dnDecoration' ) && !Other.IsA( 'ControllableTurret' )  )
			dnDecoration( Other ).Topple( self, Other.Location, vector( Rotation ) * 750 );
		else
			Super.Bump( Other );
	}

	function Timer( optional int TimerNum )
	{
		Enable( 'Bump' );
	}

	function SeePlayer( actor SeenPlayer )
	{
		local float Dist;

		if( bFixedEnemy )
			return;

		if( bAggressiveToPlayer && SeenPlayer.IsA( 'PlayerPawn' ) )
		{
			HeadTrackingActor = SeenPlayer;
			Enemy = SeenPlayer;
			GotoState( 'Attacking' );
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
				}
			}
		}
	}

	function TurnToDestination()
	{
	    local int bone;
		local MeshInstance minst;
		local rotator r;
		local float f;
	
		local rotator EyeLook, HeadLook, BodyLook;
		local rotator LookRotation;
		local float HeadFactor, ChestFactor, AbdomenFactor;
		local float PitchCompensation;
		
		bone = minst.BoneFindNamed('Head');
		if (bone!=0)
		{
			r = rotator( Location - Destination );
			minst.BoneSetRotate(bone, r, true, true);
		}
	}

	function SetFall()
	{
		NextState = 'Wandering'; 
		NextLabel = 'ContinueWander';
		GotoState('FallingState'); 
	}

	function EnemyAcquired()
	{
		//GotoState('Acquisition');
	}

	function AnimEndEx(int Channel)
	{
		if (Channel==1  && GetSequence( 1 ) == 'T_IdleCough' )
		{
			GetMeshInstance();
			if (!MeshInstance.MeshChannels[Channel].bAnimLoop)
			{
				PlayTopAnim('None');
				HeadTracking.Weight = 0.0;
				EyeTracking.Weight = 0.0;
			}
		}
	}
		
	function HitWall(vector HitNormal, actor Wall)
	{
		if( GetSequence( 2 ) != '' )
			PlayBottomAnim( 'None' );
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
		if ( PickWallAdjust() && (FRand() < 0.7) )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Wandering', 'AdjustFromWall');
		}
		else
		{
			StopMoving();
			PlayToWaiting();
		}
	}
	
	function bool TestDirection(vector dir, out vector pick)
	{	
		local vector HitLocation, HitNormal, dist;
		local float minDist;
		local actor HitActor;

		minDist = FMin(150.0, 4*CollisionRadius);
		if ( (Orders == 'Follow') && (VSize(Location - OrderObject.Location) < 500) )
			pick = dir * (minDist + (200 + 6 * CollisionRadius) * FRand());
		else
			pick = dir * (minDist + (450 + 12 * CollisionRadius) * FRand());

		HitActor = Trace(HitLocation, HitNormal, Location + pick + 1.5 * CollisionRadius * dir , Location + vect( 0, 0, -24 ), false);
		if (HitActor != None)
		{
			pick = HitLocation + (HitNormal - dir) * 2 * CollisionRadius;
			if ( !FastTrace(pick, Location) )
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
		local bool success, bMustWander;
		local float XY;

		//Favor XY alignment
		XY = FRand();
		if ( WanderDir != vect(0,0,0) )
		{
			pickdir = WanderDir;
			XY = 1;
			bMustWander = true;
		}
		else if (XY < 0.3)
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
		else if ( bMustWander )
		{
			WanderDir = Normal(WanderDir + VRand());
			WanderDir.Z = 0;
			Destination = Location + 100 * WanderDir;
		}
		else
			GotoState('Wandering', 'Turn');

		WanderDir = vect(0,0,0);
	}

	function BeginState()
	{
		if( !self.IsA( 'NPC' ) )
		{
			PlayTopAnim( 'None' );
		}
		Enemy = None;
		HeadTrackingActor = None;
		SetAlertness(0.2);
		bReadyToAttack = false;
		bCanJump = false;
	}
	
	function EndState()
	{
		if (JumpZ > 0)
			bCanJump = true;
	}


Begin:
	if( bPanicking )
		NoDecorationPain = true;
	Disable( 'AnimEnd' );
Wander: 
	Enable( 'AnimEnd' );
	WaitForLanding();
	PickDestination();
	if( FRand() < 0.3 && bUseFlashlight )
	{
		PlayTopAnim( 'A_IdleNervousFlashlightA',,, false );
		FinishAnim( 0 );
	}
	
Moving:
	Enable('HitWall');
	
	if( GetSequence( 2 ) != '' )
		PlayBottomAnim( 'None' );

	TurnTo( Destination );
	if( !bPanicking )
		PlayToWalking();
	else
		PlayToRunning();
	MoveTo(Destination, GetWalkingSpeed() );
	Disable( 'AnimEnd' );
	
Pausing:
	if( !bPanicking )
	{
		StopMoving();
		if ( NearWall( CollisionRadius + 12) )
			TurnTo(Focus);
		Enable('AnimEnd');
		PlayToWaiting();
		Sleep(1.0);
		Disable('AnimEnd');
	}
	Goto('Wander');
	
ContinueWander:
	if (FRand() < 0.2)
		Goto('Turn');
	Goto('Wander');

Turn:
	if( !bPanicking )
	{
		StopMoving();
		Destination = Location + 20 * VRand();
	}
	TurnTo( Destination );
	if( !bPanicking )
		Goto('Pausing');
	else
		Goto( 'ContinueWander' );

AdjustFromWall:
	Enable( 'AnimEnd' );
	StrafeTo(Destination, Focus, GetWalkingSpeed() ); 
	Disable( 'AnimEnd' );
	Destination = Focus; 
	Goto('Moving');
}

function AnimEndEx(int Channel)
{
	if (Channel==1)
	{
		GetMeshInstance();
		if (!MeshInstance.MeshChannels[Channel].bAnimLoop)
			PlayTopAnim('None'); // smear top channel
	}
	else if (Channel==2)
	{
		GetMeshInstance();
		if (!MeshInstance.MeshChannels[Channel].bAnimLoop)
			PlayBottomAnim('None'); // smear bottom channel
	}
}

defaultproperties
{
     HeadTracking=(RotationRate=(Pitch=40000,Yaw=20000),RotationConstraints=(Pitch=8000,Yaw=16000))
     //DrawScale=0.95
     Health=5
     SufferFrequency=0.6
     EgoKillValue=-25
     bJumpCower=true
     bAggressiveToPlayer=False
     IdleSpeech(0)=(Sound=Sound'TEMPVOICE.TEMPVOICE.Grunt01',SoundVolume=200.000000,PauseBeforeAnim=0.200000)
     IdleSpeech(1)=(Sound=Sound'TEMPVOICE.TEMPVOICE.Grunt02',SoundVolume=200.000000,PauseBeforeAnim=0.200000)
     IdleSpeech(2)=(Sound=Sound'TEMPVOICE.TEMPVOICE.Grunt03',SoundVolume=200.000000,PauseBeforeAnim=0.200000)
	 CollisionRadius=17.000000
     CollisionHeight=39.000000
     SoundSyncScale_Jaw=1.050000
     SoundSyncScale_MouthCorner=0.070000
     SoundSyncScale_Lip_U=0.750000
     SoundSyncScale_Lip_L=0.500000
     bSnatched=false
	 PainInterval=0.0
	 Lookinterval=7.5
	 bOneShotSuffer=true
     bIdleSeeFriendlyPlayer=true
}

