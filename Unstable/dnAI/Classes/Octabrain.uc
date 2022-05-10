class Octabrain expands BonedCreature;

#exec obj load file=..\meshes\c_characters.dmx
#exec OBJ LOAD FILE=..\Sounds\a_creatures.dfx

var name LastDamageBone;
var() bool bProtectOthers;
var SnatcherAdult HealTarget;
var bool bDirectReach;
var() float FleeDistance;
var bool bEnableStop;
var bool bDodgeLeft, bDodgeUp;
var rotator r;
var int counter;
var() bool bTelekinetic;
var int PitchMod, RollMod, yawMod;
var byte DeathMode;
var() bool bGuardOthers;
//var dnOctabrainFX_BrainChargeA MyCharge;
var dnOctabrainBrainLightningA  MyCharge;
//var dnRobotShockFX_SparkBeamA_Hit MyCharge;

//var dnOctabrainBrainLightningA MyCharge;
var Actor LaserDestination;
var dnOctabrainFX_BrainChargeA MyEyebrow;
/*
========================================================
			   	Octabrain Animations:
========================================================
BiteA
Pain_TentL
Pain_TentR
PainA
PainB
Run_F
IdleA
IdleB
Roar
Strafe_L
Strafe_R
DeathA
DeathAFalling
DeathALand

DeathAGround
DeathBFalling
DeathBGround
DeathBLand
DeathB
========================================================
*/

var name TentacleList[ 17 ];
var bool bLandDeath;
var dndecoration TargetDecoration;
var int BobCounter;
var bool bMoving;
var LethalDecoration MyLethalDecoration;

function ThrowAttack( Pawn Victim )
{
	Victim.SetPhysics( PHYS_Falling );
	Victim.AddVelocity( Vector( Rotation ) * 475 );
	Victim.Velocity.Z += 475;
}

function ChooseAttackState()
{
	if( bProtectOthers )
		GotoState( 'AvoidingEnemy' );
	else
		GotoSTate( 'ApproachingEnemy' );
}

state AvoidingEnemy
{
	ignores EnemyNotVisible;

	function BeginState()
	{
		log( self$" entered AvoidingEnemy state." );
		SetCallbackTImer( 0.25, true, 'PingEnemyAndFriends' );
	}


	function PingEnemyAndFriends()
	{
		local float Dist;

		Dist = VSize( Enemy.Location - Location );

		// Saving himself is first priority.
		if( Dist < FleeDistance )
		{
			// Send to retreat movement code here
		}
		else  // Save others
		{
		}
	}

OctaResurrect:

OctaHeal:
	if( HealTarget != None )
	{
		TurnToward( HealTarget );
		PlayAllAnim( 'A_Roar',, 0.1, false );
		HealTarget.GotoState( 'Healed' );
	}

Dodging:
	if( GetSequence( 0 ) != 'IdleA' )
	{
		PlayAllAnim( 'IdleA',, 0.13, true );
	}

	if( bDodgeLeft )
	{
		if( bDodgeUp )
			Destination = GetStrafeDestination( true );
		else
			Destination = GetStrafeDestination( true, true );

		bDodgeUp = false;
		bDodgeLeft = false;
	//	PlayAllAnim( 'Strafe_L',, 0.2, true );
	}
	else
	{
		if( bDodgeUp )
		{
			Destination = GetStrafeDestination( false );
		}
		else
			Destination = GetStrafeDestination( false, true );
		bDodgeUp = false;
		bDodgeLeft = false;
	//	PlayAllAnim( 'Strafe_R',, 0.2, true );
	}
	StrafeTo( Destination, Focus, 3.0 );
	Goto( 'Moving' );
}

function BlastBackNot()
{
	PlayerPawn( Enemy ).AddRotationShake( 0.15, 'Up' );
	PlaySound( sound'TentacleAtk2', SLOT_misc, SoundDampening * 0.99 );
	ThrowAttack( Pawn( Enemy ) );
}

state ThrowBack
{
Begin:
	StopMoving();
	TurnToward( Enemy );
	PlayAllAnim( 'BlastBack',, 0.1, false );	
	//Sleep( 0.25 );
	FinishAnim( 0 );
	//GotoState( 'ApproachingEnemy' );
	ChooseAttackState();
}
//'dnOctabrainFX_ChargeDecorationA'
function NewTarget()
{
	TargetDecoration = None;
	GotoState( 'Telekinesis' );
}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	GotoState( 'Dying' );
}

state Dying
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, Drowning;

	function BeginState()
	{
		//// log( "Dying state entered" );
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
	{
		if( DeathMode == 0 )
			PlayAllAnim( 'DeathALand',, 0.1, false );
		else
			PlayAllAnim( 'DeathBLand',, 0.1, false );
	}
	SpawnCarcass();
	Destroy();

Begin:
	if( HighEnough() )
	{
		bLandDeath = true;
		if( DeathMode == 0 )
			PlayAllAnim( 'DeathA',, 0.1, false );
		else
			PlayAllAnim( 'DeathB',, 0.1, false );

		SetPhysics( PHYS_Falling );
		FinishAnim( 0 );
		if( DeathMode == 0 )
			PlayAllAnim( 'DeathAFalling',, 0.1, true );
		else
			PlayAllAnim( 'DeathBFalling',, 0.1, true );
		WaitForLanding();
	}
	else
	{
		bLandDeath = false;
		SetPhysics( PHYS_Falling );
		if( DeathMode == 0 )
			PlayAllAnim( 'DeathAGround',, 0.1, false );
		else
			PlayAllAnim( 'DeathBGround',, 0.1, false );
	}
}
	
function AddDamagedTentacle( name BoneName )
{
	local int i;

	for( i = 0; i <= 17; i++ )
	{
		if( TentacleList[ i ] == '' )
		{
			TentacleList[ i ] = BoneName;
			break;
		}
	}
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

		if( Health < Default.Health )
			EvalDamagedTentacles();

		if( Health > 0 )
		{
			EvalHeadLook();
		}	
	}

	return true;
}

function NotifyDodge( optional vector TestVector )
{
	local vector X, Y, Z, FinalOne, FinalTwo, STart;
	local vector Loc1, Loc2, Loc3, Loc4;

	GetAxes( Rotation, X,Y,Z );

	Loc1 = Location + ( ( CollisionRadius * 0.5 ) * Y );
	Loc2 = Location - ( ( CollisionRadius * 0.5 ) * Y );
	Loc3 = Location + ( ( CollisionRadius * 0.5 ) * Z );
	Loc4 = Location - ( ( CollisionRadius * 0.5 ) * Z );

	if( VSize( Loc3 - TestVector ) < VSize( Loc4 - TestVector ) )
	{
		bDodgeUp = true;
	}
	else
		bDodgeUp = false;

	if( VSize( Loc1 - TestVector ) < VSize( Loc2 - TestVector ) )
	{
		bDodgeLeft = true;
	}
	else
		bDodgeLeft = false;
	
	if( bProtectOthers )
		GotoState( 'AvoidingEnemy', 'Dodging' );
	else
		GotoState( 'ApproachingEnemy', 'Dodging' );

}

function bool EvalDamagedTentacles()
{
	local int i, bone;
	local MeshInstance Minst;

	for( i = 0; i <= 15; i++ )
	{
		if( TentacleList[ i ] != '' )
		{
			Minst = GetMeshInstance();

			bone = Minst.BoneFindNamed( TentacleList[ i ] );

			if( bone != 0 )
			{
				MeshInstance.BoneSetScale(bone, vect(0,0,0), true);
			}
		}
		else
			break;
	}
}

function PlayToRunning()
{
	if( GetSequence( 0 ) != 'Run_F' )
	{
		PlayAllAnim( 'Run_F',, 0.16, true );
	}
}

function EnterControlState_Dead()
{
//	bHidden = true;
//	if ( bIsPlayer )
//		HidePlayer();
//	else
//		Destroy();
}

function KillEffects()
{
//	MyEyebrow.Trigger( self, self );
//	MyEyebrow = None;
	
	MyEyebrow.Enabled = false;
	MyEyebrow.LightType = LT_None;

	MyCharge.Enabled = false;
	MyCharge.LightType = LT_None;

	if( MyCharge != None )
	{
	//	MyCharge.Destroy();
	//	MyCharge = None;
	}
}

state Testo
{
	ignores SeePlayer;

	function BeginState()
	{
		local PlayerPawn P;

		foreach allactors( class'PlayerPawn', P )
		{
			Enemy = P;
		}
	}

	function TestIt()
	{
		local float CosAngle, MinCosAngle;
		local vector VectorFromNPCToNP, VectorFromNPCToEnemy, LookDir, OffDir;
		local float TempDist;

		MinCosAngle = 0.1;
	
		LookDir = vector( Rotation );

	//	OffDir = Normal( LookDir cross vect( 0, 0, 1 ) );

	//	CosAngle = ( OffDir dot( Location - Enemy.Location ) );
		
			
		VectorFromNPCToNP = Enemy.Location - Location;
	
//		if( VSize( VectorFromNPCToNP ) > MaxCoverDistance )
//			return false;

		VectorFromNPCToEnemy = Enemy.Location - Location;
	
		CosAngle = Normal( vector( Rotation ) ) dot Normal( VectorFromNPCToNP );
	}

Begin:
	TestIt();
	Sleep( 1.0 );
	Goto( 'Begin' );
}

function CreateCharge()
{
	MyEyebrow = Spawn( class'dnOctabrainFX_BrainChargeA', self );
	MyEyebrow.Tag = Name;
	MyEyebrow.AttachActorToParent( self, true, true );
	MyEyebrow.MountType = MOUNT_MeshBone;
	MyEyebrow.MountMeshItem = 'Eyebrow_M';
	MyEyebrow.SetPhysics( PHYS_MovingBrush );

	MyCharge = Spawn( class'dnOctabrainBrainLightningA', self );
	MyCharge.AttachActorToParent( self, true, true );
	MyCharge.Event = Name;
	MyCharge.MountType = MOUNT_MeshBone;
	MyCharge.MountMeshItem = 'BrainTail';
	MyCharge.SetPhysics( PHYS_MovingBrush );
	MyCharge.ResetDestinationActors();
	MyCharge.DestinationActor[ 0 ] = MyEyebrow;
}

function PostBeginPlay()
{
	Counter = 1;

	if( FRand() < 0.5 )
		DeathMode = 1;

	Super.PostBeginPlay();
}

function bool CreatePawnDecoration()
{
	if( TargetDecoration != None )
	{
		MyLethalDecoration = Spawn( class'LethalDecoration', self,, TargetDecoration.Location, TargetDecoration.Rotation );
		MyLethalDecoration.Enemy = Enemy;
		MyLethalDecoration.TargetDecoration = TargetDecoration;
		MyLethalDecoration.CircleCenter = Enemy.Location + ( vect( 0, 0, 1 ) * 128 );
		TargetDecoration.SetOwner( MyLethalDecoration );
		TargetDecoration.AttachActorToParent( MyLethalDecoration, false, false );
		TargetDecoration.MountType = MOUNT_Actor;
		TargetDecoration.SetPhysics( PHYS_MovingBrush );

		if( MyLethalDecoration == None || TargetDecoration == None )
		{
			ChooseAttackState();
			return false;
			//KillEffects();
		}
		return true;
	}
}

function Timer( optional int TimerNum )
{
	GotoState( 'Telekinesis', 'Rotating' );
}

function Tick( float DeltaTime )   
{
	local vector Extent, HitLocation, HitNormal;
	local actor HitActor;
	local rotator TempRot;

	if( bEnableStop && VSize( Location - Enemy.Location ) < 80 )
		GotoState( 'ApproachingEnemy', 'FollowReached' );
	Super.Tick( DeltaTime );
}

function SetDamageBone(name BoneName)
{
	if (BoneName=='None')
		return;
	LastDamageBone = BoneName;
	DamageBone = BoneName;
}

function PlayToWaiting( optional float TweenTime )
{
	PlayAllAnim( 'IdleA',, 0.1, true );
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitLocation, vector Momentum, class<DamageType> damageType )
{
	if( instigatedBy != self )
	{
		if( Enemy == None || !Enemy.IsA( 'PlayerPawn' ) )
			Enemy = instigatedBy;
		if( Health - Damage <= 0 )
		{
			Died( instigatedBy, DamageType, HitLocation );
			return;
		}
		Super.TakeDamage( Damage, instigatedBy, HitLocation, Momentum, damageType );
		if( AnimSequence != 'PainA' && AnimSequence != 'PainB' && Health > 0 )
		{
			if( NextState != 'TakeHit' )
				NextState = GetStateName();

			if( NextState =='Telekinesis' && MyLethalDecoration != None )
			{
				MyLethalDecoration.AbortTelekinesis();
				MyLethalDecoration = None;
				NextState = 'ApproachingEnemy';
				GotoState( 'TakeHit' );
			}
		}
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

function vector GetStrafeDestination( optional bool bLeft, optional bool bUp )
{
	local vector X, Y, Z;
	local vector TempDest;

	GetAxes( Rotation, X, Y, Z );
	if( !bLeft )
		TempDest = Location + Y * 96;
	else
		TempDest = Location + Y * -96;

	if( bUp )
		TempDest.Z += ( 24 + Rand( 30 ) );
	else
		TempDest.Z -= ( 24 + Rand( 30 ) );
	return TempDest;
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = true;
	MinHitWall = -0.6;
}

state ApproachingEnemy
{
	function Bump( actor Other )
	{
		if( Other.IsA( 'dnDecoration' ) && !Other.IsA( 'ControllableTurret' ) )
		{
			dnDecoration( Other ).Topple( self, Other.Location, vector( Rotation ) * 650, 20 );
		}
	}

	function HitWall( vector HitNormal, actor HitWall )
	{
		Focus = Destination;
		if( HitWall.IsA( 'dnDecoration' ) && !HitWall.IsA( 'InputDecoration' ) && !HitWall.IsA( 'ControllableTurret' ) )
			dnDecoration( HitWall ).Topple( self, HitWall.Location, vector( Rotation ) * 27550 + vect( 0, 0, 1350 ), 20 );
		if (PickWallAdjust() && !HitWall.IsA( 'dnDecoration' ) )
			GotoState('ApproachingEnemy', 'AdjustFromWall');
		else if( !HitWall.IsA( 'dnDecoration' ) )
			MoveTimer = -1.0;
	}

	function BeginState()
	{
		EnableHeadTracking( true );
		HeadTrackingActor = Enemy;
	}

Begin:
	if( Enemy != None )
	{
		Destination = Enemy.Location;
		HeadTrackingActor = Enemy;
	}
	else if( Enemy == None || RenderActor( Enemy ).Health <= 0 )
	{
		Enemy = None;
		StopMoving();
		GotoState( 'Idling' );
	}
Moving:
	if( Enemy == None || !Enemy.bIsRenderActor || (RenderActor(Enemy).Health <= 0) )
		GotoState( 'Idling' );
	else if( VSize( Enemy.Location - Location ) > 96 && !CanDirectlyReach( Enemy ) )
	{
		bDirectReach = false;
		if( !FindBestPathToward( Enemy, true ) )
		{
			PlayToWaiting();
			Sleep( 1.0 );
			GotoState( 'ApproachingEnemy' );
		}
		else
		{
			PlayToRunning();
			TurnTo( Destination );
			MoveTo( Destination + vect( 0, 0, 64 ), GetRunSpeed());
			if( VSize( Enemy.Location - Location ) <= 96 )
				Goto( 'FollowReached' );
			else
				Goto( 'Moving' );
		}
	}
	else if( CanDirectlyReach( Enemy ) && VSize( Enemy.Location - Location ) > 96 )
	{
		if( FRand() < 0.9 && VSize( Location - Enemy.Location ) < 96 )
			GotoState( 'ThrowBack' );
		else
		if( FRand() < 0.5 && bTelekinetic && VSize( Enemy.Location - Location ) > 400 )
			GotoState( 'Telekinesis' );
		else
		{
			bDirectReach = true;
			PlayToRunning();
			bEnableStop = true;
			MoveTo( Enemy.Location + ( vect( 0, 0, 24 ) ) );
			bEnableStop = false;
		}
	}
	else if( VSize( Enemy.Location - Location ) <= 96 ) 
		Goto( 'FollowReached' );
	if( LineOfSightTo( Enemy ) && FRand() < 0.33 && SafeToFire() )
		GotoState( 'BrainBlast' );
	else Goto( 'Moving' );

Dodging:
	if( GetSequence( 0 ) != 'IdleA' )
		PlayAllAnim( 'IdleA',, 0.13, true );

	if( bDodgeLeft )
	{
		if( bDodgeUp )
			Destination = GetStrafeDestination( true );
		else
			Destination = GetStrafeDestination( true, true );

		bDodgeUp = false;
		bDodgeLeft = false;
	}
	else
	{
		if( bDodgeUp )
			Destination = GetStrafeDestination( false );
		else
			Destination = GetStrafeDestination( false, true );
		bDodgeUp = false;
		bDodgeLeft = false;
	}
	StrafeTo( Destination, Focus, 3.0 );
	Goto( 'Moving' );

Strafing:
	if( GetSequence( 0 ) != 'IdleA' )
		PlayAllAnim( 'IdleA',, 0.13, true );
	if( FRand() < 0.5 )
		Destination = GetStrafeDestination( true );
	else
		Destination = GetStrafeDestination( false );
	StrafeTo( Destination, Focus, 3.0 );
	Goto( 'Moving' );

FollowReached:
	bEnableStop = false;
	StopMoving();
	if( VSize( Location - Enemy.Location ) < 96 )
		GotoState( 'BiteAttack' );
	else
		Gotostate( 'ApproachingEnemy' );

AdjustFromWall:
	StrafeTo(Destination, Focus, GetRunSpeed() ); 
	Goto('Begin');
}

state Telekinesis
{
	function BeginState()
	{
		TargetDecoration = GetTargetDecoration();
	}

	function EndState()
	{
		KillEffects();
	}

	function dnDecoration GetTargetDecoration()
	{
		local dnDecoration D;
		local int i, f;
		local dnDecoration AcceptableTargets[ 16 ];
		local float CosAngle, MinCosAngle, CosAngleB;
		local vector VectorFromNPCToNP, VectorFromNPCToEnemy, LookDir, OffDir;
		local float TempDist;
		local float Dist;

		MinCosAngle = 0.1;
	
		LookDir = vector( Rotation );

	//	OffDir = Normal( LookDir cross vect( 0, 0, 1 ) );

	//	CosAngle = ( OffDir dot( Location - Enemy.Location ) );
		
			
		VectorFromNPCToNP = Enemy.Location - Location;
	
//		if( VSize( VectorFromNPCToNP ) > MaxCoverDistance )
//			return false;

		VectorFromNPCToEnemy = Enemy.Location - Location;
		
		foreach allactors( class'dnDecoration', D )
		{
			Dist = VSize( Enemy.Location - D.Location );
			CosAngle = Normal( vector( Rotation ) ) dot Normal( VectorFromNPCToNP );
			CosAngleB = Normal( vector( Rotation ) ) dot Normal( Location - D.Location );
			
			if( (Dist < 3700) && ( CosAngle > 0.0 && CosAngleB < 0.0 ) || ( CosAngle < 0.0 && CosAngleB > 0.0 ) )
			{
				if( D.Owner == None && D.bTelekineticable && !D.bHidden && !D.IsA( 'ControllableTurret' ) && !D.IsA( 'dnThirdPersonShield' ) && !D.IsA( 'InputDecoration' ) )
				{
					if( CanSeeEnemyFrom( D.Location ) && PointReachable( D.Location + vect( 0, 0, 1 ) * 72 ) && CanSeeEnemyFrom( D.Location + ( vect( 0, 0, 1 ) * 72 ) ) )
					{
						AcceptableTargets[ i ] = D;
						if( i < 15 )
							i++;
						else
							break;
					}
				}
			}
		}
		
		f = Rand( i );
		
		if( AcceptableTargets[ f ] != None )
		{
			broadcastmessage( "DIST: "$DIST );
			return AcceptableTargets[ f ];
		}
		else
			return none;
	}


Begin:
	if( TargetDecoration != None )
	{
		StopMoving();
		//TurnToward( TargetDecoration );
		PlayAllAnim( 'Telek_Pickup',, 0.1, false );
		
		if( MyCharge == None )
			CreateCharge();
		else
		{
			MyEyebrow.Enabled = true;
			MyCharge.Enabled = true;
			MyEyebrow.LightType = MyEyebrow.Default.LightType;
			MyCharge.LightType = MyCharge.Default.LightType;
		}

		if( CreatePawnDecoration() )
			TurnToward( TargetDecoration );
	}
	else
	{
		TargetDecoration = GetTargetDecoration();

		if( TargetDecoration == None )
			GotoState( 'ApproachingEnemy' );
		else
		{
			if( MyCharge == None )
				CreateCharge();
			else
			{
				MyEyebrow.Enabled = true;
				MyCharge.Enabled = true;
				MyEyebrow.LightType = MyEyebrow.Default.LightType;
				MyCharge.LightType = MyCharge.Default.LightType;
			}
			StopMoving();
			TurnToward( TargetDecoration );
			PlayAllAnim( 'Telek_Pickup',, 0.1, false );
			if( CreatePawnDecoration() )
				TurnToward( TargetDecoration );
		}
	}
	if( GetSequence( 0 ) == 'Telek_Pickup' )
	{
		FinishAnim( 0 );
		PlayAllAnim( 'Telek_Idle',, 0.1, true );
	}
Rotating:	
	if( !MyLethalDecoration.bTossed )
	{
		r.Pitch = -32767;
		r.Yaw = Rand(65535);
		r.Roll = 20000;
	}
	if( FRand() < 0.33 )
		TurnToward( Enemy );
	if( !MyLethalDecoration.bTossed )
	{
		r.Pitch = Rand( 63000 ) * -1;
		r.Yaw = Rand( 63000 ) * -1;
		R.Roll = Rand( 63000 ) * -1;
	}
	else
	{
		r.Pitch = Rand( 63000 ) * -1;
		r.Yaw = Rand( 63000 ) * -1;
		R.Roll = Rand( 63000 ) * -1;
	}
}

function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
	local rotator FireRotation;
	local vector FireSpot;
	local actor HitActor;
	local vector HitLocation, HitNormal, FireDir;
	local float TargetDist, TossSpeed, TossTime;
	local int realYaw;
	local rotator TempRotation;

	Skill = 3;
	if ( projSpeed == 0 )
		return AdjustAim(projSpeed, projStart, aimerror, leadTarget, warnTarget);
	Target = Enemy;
	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - ProjStart);
 
	if ( !Target.bIsPawn )
	{
		if ( (Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z) 
			|| (TargetDist > projSpeed) )
		{
			TossTime = TargetDist/projSpeed;
			FireSpot.Z -= ((0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200) * TossTime + 60);	
		}
		TempRotation = Rotator( Normal(FireSpot - ProjStart) );
		return TempRotation;
	}					
	aimerror = 0.0;

	if ( leadTarget )
	{
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * (Target.Velocity * TargetDist/projSpeed);
		if ( !FastTrace(FireSpot, ProjStart) )
			FireSpot = 0.5 * (FireSpot + Target.Location);
	}

	//try middle
	FireSpot.Z = Target.Location.Z;

	if ( (Target == Enemy) && !FastTrace(FireSpot, ProjStart) )
	{
		FireSpot = LastSeenPos;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
		}
	}

	// adjust for toss distance (assume 200 z velocity add & 60 init height)
	if ( FRand() < 0.75 )
	{
		TossSpeed = projSpeed + 0.4 * VSize(Velocity); 
		if ( (Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z) 
			|| (TargetDist > TossSpeed) )
		{
			TossTime = TargetDist/TossSpeed;
			FireSpot.Z -= ((0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200) * TossTime + 60);	
		}
	}

	FireRotation = Rotator(FireSpot - ProjStart);
	realYaw = FireRotation.Yaw;
	aimerror = 0.0;

	FireRotation.Yaw = (FireRotation.Yaw + aimerror) & 65535;

	if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
		&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
	{
		if ( (FireRotation.Yaw > Rotation.Yaw + 32768) || 
			((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
			FireRotation.Yaw = Rotation.Yaw - 8192;
		else
			FireRotation.Yaw = Rotation.Yaw + 8192;
	}
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	HitActor = Trace(HitLocation, HitNormal, ProjStart + FMin(VSize(FireSpot-ProjStart), 400) * FireDir, ProjStart, false); 
	if ( (HitActor != None) && (HitNormal.Z < 0.7) )
	{
		FireRotation.Yaw = (realYaw - aimerror) & 65535;
		if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
			&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
		{
			if ( (FireRotation.Yaw > Rotation.Yaw + 32768) || 
				((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
				FireRotation.Yaw = Rotation.Yaw - 8192;
			else
				FireRotation.Yaw = Rotation.Yaw + 8192;
		}
		FireDir = vector(FireRotation);
	}

	if ( warnTarget && (Pawn(Target) != None) ) 
		Pawn(Target).WarnTarget(self, projSpeed, FireDir); 

	TempRotation = FireRotation;			
	return FireRotation;
}

function TossTargetDecoration( optional actor DestActor )
{
	local vector X,Y,Z;
	local PipeBomb P;
	local vector Start;
	local rotator AdjustedAim;

	GetAxes( TargetDecoration.Rotation, X, Y, Z );
	Start = TargetDecoration.Location;// + Weapon.CalcDrawOffset();
	AdjustedAim = AdjustToss( 350, Start, 0.0, true, false );
	TargetDecoration.SetPhysics( PHYS_Falling );	
	TargetDecoration.RotationRate.Pitch = TargetDecoration.BaseTumbleRate;
	TargetDecoration.SetOwner( self );
	TargetDecoration.Velocity = Normal( Enemy.Location - TargetDecoration.Location  ) * 650;     
	TargetDecoration.Velocity.Z += 250; 
	TargetDecoration.Tossed();
}

state BrainBlast
{
	function bool CanFire()
	{
		local actor HitActor;
		local vector HitNormal, HitLocation;

		HitActor = Trace( HitLocation, HitNormal, Enemy.Location, Location, true );

		if( HitActor == Enemy )
			return true;
		else
			return false;
	}

	function BeginState()
	{
	}

Begin:
	if( CanFire() )
	{
		StopMoving();
		TurnToward( Enemy );
		PlayAllAnim( 'Roar', 0.86, 0.1, false );
		Sleep( 0.15 );
		Spawn( class'dnRocket_BrainBlast', self,, Location, Rotation );
		FinishAnim( 0 );
	}
	if( FRand() < 0.33 )
		GotoState( 'ApproachingEnemy', 'Strafing' );
	else
		GotoState( 'ApproachingEnemy' );
}

// Temp (Testing)
function bool SafeToFire()
{
	local vector X, Y, Z, Loc1, Loc2, Loc3, Loc4, HitLocation, HitNormal;
	local actor HitActor;

	GetAxes( Rotation, X,Y,Z );

	Loc1 = Location + ( ( 24 ) * Y );
	Loc2 = Location - ( ( 24 ) * Y );
	Loc3 = Location + ( ( 24 ) * Z );
	Loc4 = Location - ( ( 24 ) * Z );

	HitActor = Trace( HitLocation, HitNormal, Loc1 + vector( Rotation ) * 256, Loc1, true );
	if( HitActor == None )
		HitActor = Trace( HitLocation, HitNormal, Loc2 + vector( Rotation ) * 256, Loc2, true );
	else return false;

	if( HitActor == None )
		HitActor = Trace( HitLocation, HitNormal, Loc3 + vector( Rotation ) * 256, Loc3, true );
	else
		return false;

	if( HitActor == None )
		Trace( HitLocation, HitNormal, Loc4 + vector( Rotation ) * 256, Loc4, true );
	else return false;

	if( HitActor == None )
		return true;

	else return false;

	return false;
}


state BiteAttack
{
	function BeginState()
	{
	}

	function Bite()
	{
		if( MeleeDamageTarget( 15, vector( Rotation ) ) && Enemy.IsA( 'DukePlayer' ) )
		{
			Pawn( Enemy ).PeripheralVision = 1.0;
			Pawn( Enemy ).bForcePeriphery = true;
			if( DukePlayer( Enemy ).LineOfSightTo( Self ) )
				DukeHUD( DukePlayer( Enemy ).MyHUD ).RegisterBloodSlash( 4 );
			Pawn( Enemy ).bForcePeriphery = Pawn( Enemy ).Default.bForcePeriphery;
			Pawn( Enemy ).PeripheralVision = Pawn( Enemy ).Default.PeripheralVision;
		}
	}

Begin:
	TurnToward( Enemy );
	PlayAllAnim( 'BiteA',, 0.1, false );
	FinishAnim( 0 );
	if( FRand() < 0.25 )
		GotoState( 'ApproachingEnemy', 'Strafing' );
	else if( FRand() < 0.86 && VSize( Location - Enemy.Location ) < 128 )
		GotoState( 'ThrowBack' );
	else
		GotoState( 'ApproachingEnemy' );
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal, TargetPoint;
	local actor HitActor;
	
	// check if still in melee range
	If ( (VSize(Enemy.Location - Location) <= 64 * 1.4 + Enemy.CollisionRadius + CollisionRadius)
		&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Enemy.Location.Z) 
			<= FMax(CollisionHeight, Enemy.CollisionHeight) + 0.5 * FMin(CollisionHeight, Enemy.CollisionHeight))) )
	{	
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location, false);
		if ( HitActor != None )
			return false;
		Enemy.TakeDamage(hitdamage, Self,HitLocation, pushdir, class'CrushingDamage');
		return true;
	}
	return false;
}

function TriggerHate()
{
	local actor NewEnemy;

	foreach allactors( class'Actor', NewEnemy, HateTag )
	{
		if( !Enemy.bHidden )
		{
			Enemy = NewEnemy;
			HeadTrackingActor = Enemy;
			EnableHeadTracking( true );
			Enemy = NewEnemy;
			GotoState( 'ApproachingEnemy' );
			break;
		}
	}
}

auto state Idling
{
	//ignores SeePlayer;
	function SeePlayer( actor SeenPlayer )
	{
		if( bAggressiveToPlayer && SeenPlayer.IsA( 'PlayerPawn' ) )
		{
			Enemy = SeenPlayer;
			GotoState( 'Idling', 'Acquisition' );
			Disable( 'SeePlayer' );
		}
	}
	
	function BeginState()
	{
	}

Acquisition:
	TurnToward( Enemy );
	if( FRand() < 0.5 )
	{
		PlayAllAnim( 'Roar',, 0.1, false );
		FinishAnim( 0 );
		PlayAllAnim( 'IdleA',, 0.1, true );
	}
	GotoState( 'ApproachingEnemy' );

Begin:
	SetPhysics( PHYS_Flying );
	PlayAllAnim( 'IdleA',, 0.1, true );
}

state TakeHit
{
	function PlayDamage()
	{
		local string Test, Test2;

		Test = Left( String( LastDamageBone ), 4 );
		if( Test == "Tent" || Test == "Tusk" )
		{
			AddDamagedTentacle( LastDamageBone );
			Test2 = Left( String( LastDamageBone ), 5 );
			if( Test2 == "TentL" || Test2 == "TuskL" )
				PlayAllAnim( 'Pain_TentL',, 0.1, false );
			else if( Test2 == "TentR" || Test2 == "TuskR" )
				PlayAllAnim( 'Pain_TentR',, 0.1, false );

		}
		else
		{
			if( FRand() < 0.5 )
				PlayAllAnim( 'PainA',, 0.1, false );
			else
				PlayAllAnim( 'PainB',, 0.1, false );
		}
	}

Begin:
	Velocity *= 0.35;
	Acceleration *= 0.35;
	PlayDamage();	
	FinishAnim( 0 );
	if( Enemy == None )
	{
		if( NextState == '' )
			GotoState( 'Idling' );
		else
			GotoState( NextState );
	}
	else
		GotoState( 'ApproachingEnemy' );
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;
	local int i;

	carc = Spawn(CarcassType);
	if ( carc == None )
		return None;
	carc.Initfor(self);
	for( i = 0; i <= 17; i++ )
	{
		OctabrainCarcass( carc ).TentacleList[ i ] = TentacleList[ i ];
	}
	return carc;
}

function PlayDying( class<DamageType> DamageType, vector HitLocation)
{
	PlayAllAnim( 'None' );
}

simulated function bool EvalHeadLook()
{
    local int bone;
    local MeshInstance minst;
	local float f;
	local rotator EyeLook, HeadLook, BodyLook, r, LookRotation;
	local float HeadFactor, ChestFactor, AbdomenFactor;
	local float PitchCompensation;
	local int RandHeadRot;

	if( HeadTrackingActor != None )
		HeadTracking.DesiredWeight = 1.0;
	else
		HeadTracking.DesiredWeight = 0.5;
	minst = GetMeshInstance();
    if (minst==None)
        return(false);

	HeadLook = HeadTracking.Rotation - Rotation;
	HeadLook = Normalize(HeadLook);
	
	HeadLook = Slerp(HeadTracking.Weight, rot(0,0,0), HeadLook);

	r = Normalize(ClampHeadRotation(HeadTracking.DesiredRotation) - Rotation);

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
	LookRotation = HeadLook;
	HeadFactor = 0.65;
	ChestFactor = 0.45;
	AbdomenFactor = 0.35;
	PitchCompensation = 0.0;

	bone = minst.BoneFindNamed('Head');
	if (bone!=0)
	{
		r = LookRotation;
		r = rot( -r.Yaw*HeadFactor , 0, 0);
		if( bHeadTrackTimer )
			minst.BoneSetRotate(bone, r, true, true);
	}
	return(true);
}

DefaultProperties
{
    bTelekinetic=true
    bAggressiveToPlayer=true
    CollisionHeight=50.000000
	CollisionRadius=32.000000
	Mesh=DukeMesh'c_characters.Octobrain'
    bCanFly=true
	AirSpeed=900
	AccelRate=300
    RunSpeed=0.3
	bCanStrafe=true
    CarcassType=class'OctabrainCarcass'
    PathingCollisionHeight=39
    PathingCollisionRadius=17
    bModifyCollisionToPath=true
	RotationRate=(Pitch=25000,Yaw=85000,Roll=2000)
    HeadTracking=(RotationRate=(Pitch=1524,Yaw=50000),RotationConstraints=(Pitch=00000,Yaw=9000))
    EgoKillValue=8
	ImmolationClass="dnGame.dnPawnImmolation_Octabrain"
    Health=360
}