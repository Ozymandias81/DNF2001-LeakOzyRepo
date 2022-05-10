class PodProtector extends BonedCreature;

#exec OBJ LOAD FILE=..\meshes\c_characters.dmx

/*================================================================
	Sequences:
	
	A_DormentIdle 
	A_DeathA
	A_DeathB
	A_ExtendA
	A_IdleA
	A_IdleB
	A_IdleC
	A_IdleD
	A_IdleE
	A_PainA
	A_PainB
	A_SlashA
	A_SlashB
	A_SlashC
	A_SpitA
	A_RobotFireTurnL45
	A_RobotFireTurnR45
================================================================*/

var()	float	ActivateRadius;

auto state Startup
{
	function BeginState()
	{
		Disable( 'SeePlayer' );
	}

	function SeePlayer( actor Seen )
	{
		if( VSize( Seen.Location - Location ) < ActivateRadius )
		{
			Enemy = Seen;
			Disable( 'SeePlayer' );
			GotoState( 'Startup', 'Rise' );
		}
	}

Rise:
	PlayAllAnim( 'A_ExtendA',, 0.1, false ); 
	FinishAnim( 0 );
	HeadTrackingActor = Enemy;
	PlayPodWaiting( 0.12 );
	GotoState( 'Attacking' );

Begin:
	PlayAllAnim( 'A_DormentIdle',, 0.1, true );
	SetPhysics( PHYS_Falling );
	WaitForLanding();
	Enable( 'SeePlayer' );
}

state Attacking
{
	function BeginState()
	{
		HeadTrackingActor = Enemy;
	}

	function Tick( float DeltaTime )
	{
		if( Pawn( Enemy ) != None && Pawn( Enemy ).Health > 0 )
		{
			if( VSize( Enemy.Location - Location ) < 128 && GetSequence( 0 ) != 'A_SlashA' && GetSequence( 0 ) != 'A_SlashB' 
					&& GetSequence( 0 ) != 'A_SlashC' )
				GotoState( 'Attacking', 'Attack' );
		}
		Super.Tick( DeltaTime );
	}

	function bool PodMeleeDamageTarget(int hitdamage, vector pushdir, class<DamageType> DamType )
	{
		local vector HitLocation, HitNormal, TargetPoint;
		local actor HitActor;
		local DukePlayer PlayerEnemy; 	
		
		// check if still in melee range
		If ( (VSize(Enemy.Location - Location) <= 64 * 1.4 + Enemy.CollisionRadius + CollisionRadius)
			&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || ( Physics == PHYS_Falling ) || (Abs(Location.Z - Enemy.Location.Z) 
				<= FMax(CollisionHeight, Enemy.CollisionHeight) + 0.5 * FMin(CollisionHeight, Enemy.CollisionHeight))) )
		{	
			HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location, true);
			if ( HitActor != Enemy )
				return false;
			Enemy.TakeDamage(8 + Rand( 4 ), Self,HitLocation, pushdir, DamType);
			if( Enemy.IsA( 'DukePlayer' ) )
			{
				PlayerEnemy = DukePlayer( Enemy );
				if( FRand() < 0.5 )
					PlayerEnemy.HitEffect( HitLocation, DamType, vect(0,0,0), false );
				else
					PlayerEnemy.HitEffect( HitLocation, DamType, vect(0,0,0), false );
			}		
			return true;
		}

		return false;
	}

	function TentacleSwipeLeft()
	{
		PodMeleeDamageTarget( 10, vector( Rotation ) * -1, class'WhippedLeftDamage' );
	}

	function TentacleSwipeRight()
	{
		PodMeleeDamageTarget( 10, vector( Rotation ) * -1, class'WhippedRightDamage' );
	}

	function TentacleSwipeDown()
	{
		PodMeleeDamageTarget( 10, vector( Rotation ) * -1, class'WhippedDownDamage' );
	}

Attack:
	PlaySlash( 0.12 );
	FinishAnim( 0 );
	PlayPodWaiting( 0.12 );
Begin:
	PlayPodWaiting( 0.12, true );
	FinishAniM( 0 );
	Goto( 'Begin' );
}

state TakeHit 
{
Begin:
	PlayPodPain( 0.12 );
	FinishAnim( 0 );
	PlayPodWaiting( 0.14 );
	GotoState( 'Attacking' );
}

function TakeDamage( int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	Momentum *= 0;

	if( ClassIsChildOf( DamageType, class'PoisonDamage' ) )
		return;
	else
	{
		if( Enemy == None )
			Enemy = InstigatedBy;
		Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
		if( Health > 0 && GetStateName() != 'TakeHit' )
			GotoState( 'TakeHit' );
	}
}

function PlayPodPain( optional float TweenTime )
{
	local int RandChoice;

	RandChoice = Rand( 2 );

	if( RandChoice == 0 )
		PlayAllAnim( 'A_PainA',, 0.1, false );
	else if( RandChoice == 1 )
		PlayAllAnim( 'A_PainB',, 0.1, false );
}

function bool IsAttacking()
{
	local name CurrentSeq;

	CurrentSeq = GetSequence( 0 );

	if( CurrentSeq == 'A_ExtendA' || CurrentSeq == 'A_SlashA' || CurrentSeq == 'A_SlashB' || CurrentSeq == 'A_SlashC' || CurrentSeq == 'A_IdleE' )
		return true;
	return false;
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
	
	if( HeadTrackingActor == None )
		return false;

	minst = GetMeshInstance();
	if( minst == None || GetStateName() == 'Dying' )
      return false;
	HeadTracking.Weight = 1.0;
	HeadTracking.DesiredWeight = 1.0;
	bone = minst.BoneFindNamed('Skeleton07');
	HeadLook = Normalize( ( Rotation ) - HeadTracking.Rotation );
	HeadLook = Slerp( HeadTracking.Weight, rot( 0, 0, 0 ), HeadLook );
	LookRotation = HeadLook;
	bone = minst.BoneFindNamed( 'Skeleton07' );
	if ( bone!=0 )
	{
		r = LookRotation;
    		r = rot( 0, 0, r.Yaw ); //HeadFactor);
		Minst.BoneSetRotate( bone, R, true, true );
	}
}

function TickTracking(float inDeltaTime)
{
	local rotator r;
	local int bone, bone2;
	local meshinstance minst, minst2;
	local vector BoneLocation;
	local name TargetBoneName;

	if( HeadTrackingActor != None && !IsAttacking() )
		HeadTracking.DesiredWeight = 1.0;

	if( HeadTracking.TrackTimer > 0.0 )
	{
		HeadTracking.TrackTimer -= inDeltaTime;
		if( HeadTracking.TrackTimer < 0.0 )
			HeadTracking.TrackTimer = 0.0;
	}
	HeadTracking.Weight = UpdateRampingFloat(HeadTracking.Weight, HeadTracking.DesiredWeight, HeadTracking.WeightRate*inDeltaTime);
	r = ClampHeadRotation(HeadTracking.DesiredRotation);
	HeadTracking.Rotation.Pitch = FixedTurn(HeadTracking.Rotation.Pitch, r.Pitch, int(HeadTracking.RotationRate.Pitch * inDeltaTime));
	HeadTracking.Rotation.Yaw = FixedTurn(HeadTracking.Rotation.Yaw, r.Yaw, int(HeadTracking.RotationRate.Yaw * inDeltaTime));
	HeadTracking.Rotation.Roll = FixedTurn(HeadTracking.Rotation.Roll, r.Roll, int(HeadTracking.RotationRate.Roll * inDeltaTime));
	HeadTracking.Rotation = ClampHeadRotation(HeadTracking.Rotation);
	if (HeadTrackingActor!=None)
	{
		if( HeadTrackingActor.IsA( 'PlayerPawn' ) )
		{
			Minst = HeadTrackingActor.GetMeshInstance();
			Minst2 = GetMeshInstance();
			bone = Minst.bonefindnamed( 'chest' );
			bone2 = Minst2.bonefindnamed( 'Skeleton07' );
			if( bone != 0 && !IsAttacking() )
			{
				BoneLocation = Minst.BoneGetTranslate( bone, true, false );
				BoneLocation = Minst.MeshToWorldLocation( BoneLocation );
				HeadTrackingLocation = BoneLocation;
				HeadTracking.DesiredRotation = rotator( Normal( HeadTrackingLocation - Minst2.MeshToWorldLocation( Minst2.BoneGetTranslate( bone2, true, false ) ) ) );
				HeadTracking.DesiredRotation.Roll = 0;
				HeadTracking.DesiredRotation.Pitch = 0;
			}
		}
	}
}

function PlayPodWaiting( optional float TweenTime, optional bool bNoLoop )
{
	local int RandChoice;

	if( TweenTime == 0.0 )
		TweenTime = 0.1;

	RandChoice = Rand( 4 );

	if( RandChoice == 0 )
		PlayAllAnim( 'A_IdleA',, TweenTime, !bNoLoop );
	else if( RandChoice == 1 )
		PlayAllAnim( 'A_IdleB',, TweenTime, !bNoLoop );
	else if( RandChoice == 2)
		PlayAllAnim( 'A_IdleC',, TweenTime, !bNoLoop );
	else if( RandChoice == 3)
		PlayAllAnim( 'A_IdleD',, TweenTime, !bNoLoop );
}

function PlaySlash( optional float TweenTime )
{
	local int RandChoice;

	if( TweenTime == 0.0 )
		TweenTime = 0.1;

	RandChoice = Rand( 3 );

	if( RandChoice == 0 )
		PlayAllAnim( 'A_SlashA',, 0.1, false );
	else if( RandChoice == 1 )
		PlayAllAnim( 'A_SlashB',, 0.1, false );
	else if( RandChoice == 2 )
		PlayAllAnim( 'A_SlashC',, 0.1, false );
}

function PlayDying( class<DamageType> DamageType, vector HitLocation)
{
	local int RandChoice;

	RandChoice = Rand( 2 );

	if( RandChoice == 0 )
		PlayAllAnim( 'A_DeathA',, 0.1, false );
	else if( RandChoice == 1 )
		PlayAllAnim( 'A_DeathB',, 0.1, false );
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc == None )
		return None;
	carc.Initfor(self);

	carc.MeshDecalLink = MeshDecalLink;
	return carc;
}

DefaultProperties
{
     PeripheralVision=-1.000000
	 Mesh=DukeMesh'c_characters.Pod_Protector'
     DrawType=DT_Mesh
     ActivateRadius=256.000000
	 HeadTracking=(RotationRate=(Pitch=0,Yaw=35000),RotationConstraints=(Pitch=0,Yaw=360000))
     CarcassType=class'PodProtectorCarcass'
     Health=30
     RotationRate=(Pitch=0,Roll=0,Yaw=0)
     EgoKillValue=3
	 ImmolationClass="dnGame.dnPawnImmolation_PodProtector"
}
