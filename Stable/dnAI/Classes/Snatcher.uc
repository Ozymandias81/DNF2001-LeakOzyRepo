class Snatcher expands Creature;

var SnatchActor MySnatchActor;
var bool bRunning;
var float WanderRadius;
var vector StartLocation;
var() bool bWallMounted;
var() float FallFromWallDist;
var() bool bForceCanHoverLand;
var bool bCanHoverLand;
var bool bChunky;
var bool bRolledOver;
var vector SurfaceNormal;
var bool bStuckOnWall;
var EggPod MasterPod;

state Birth
{
	function vector GetLaunchDestination()
	{
		local vector X, Y, Z;

		GetAxes( Rotation, X, Y, Z );

		return Location + ( 256 * X );
	}

/*	function Tick( float DeltaTime )
	{
		if( Physics == PHYS_Falling && Velocity.Z < -120 )
			Velocity.Z *= 0.5;

		broadcastmessage( "ROTATION PITCH: "$Rotation.Pitch );
		broadcastmessage( "Z VELOC: "$Velocity.Z );
	}
*/
Begin:
	PlayAnim( 'PodBirthA' );
	FinishAnim();
	//Destination = GetLaunchDestination();
	MountParent = None;
	SetCollision( true, true, true );
	LoopAnim( 'Hover' );
	SetPhysics( PHYS_Falling );
	Velocity = vector( Rotation ) * 150 + vect( 0, 0, 450 );
	SetCollisionSize( Default.CollisionRadius, Default.CollisionHeight );
	GotoState( 'Landing' );
	//WaitForLanding();
	//DesiredRotation.Pitch = 0;
	//SetPhysics( PHYS_Walking );
//	Sleep( 10.0 );
//	GotoState( 'Roaming' );
}

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	GotoState( 'Snatcher' );
}

function PostBeginPlay()
{
	local rotator NewRot;
/*		local actor HitActor;
		local vector NormalHit, HitLocation, StartTrace, EndTrace, X,Y,Z, EndTrace2;
		local vector Offset;
		local info MyTest;

		SetPhysics( PHYS_None );
		GetAxes( Rotation, X,Y,Z );

		Offset = vect( 0, 1, 0 );
		Offset = Normal( Offset );

		StartTrace = Location + ( ( CollisionRadius * 0.5 ) * Y );
		EndTrace = Location - ( ( CollisionRadius * 0.5 ) * Y );
		EndTrace2 = StartTrace + vector( Rotation ) * 64;
		
		//	EndTrace = StartTrace + vector( Rotation ) * 10;
		MyTest = Spawn( class'HUDIndexItem',,, StartTrace );
		MyTest.bHidden = false;
		MyTest.DrawScale = 0.25;
		MyTest.DrawType = DT_Mesh;
		MyTest.Mesh = mesh'EDF1';
		MyTest = Spawn( class'HUDIndexItem',,, EndTrace2 );
		MyTest.bHidden = false;
		MyTest.DrawScale = 0.25;
		MyTest.DrawType = DT_Mesh;
		MyTest.Mesh = mesh'EDF1';

		MyTest = Spawn( class'HUDIndexItem',,, EndTrace );
		MyTest.bHidden = false;
		MyTest.DrawScale = 0.25;
		MyTest.DrawType = DT_Mesh;
		MyTest.Mesh = mesh'EDF1';
		
		Sleep( 30 );
		GotoState( 'Wait' );
		return;
*/
	Super.PostBeginPlay();
	if( !bForceCanHoverLand )
	{
		if( FRand() < 0.5 )
		{
			bCanHoverLand = true;
		}
	}
	else
		bCanHoverLand = true;

	if( bWallMounted )
		SetPhysics( PHYS_Spider );

}

state Landing
{
	ignores SeePlayer;
	
	function Tick( float DeltaTime )
	{
		if( Velocity.Z <= 0 && bCanHoverLand )
		{
			Velocity.Z *= 0.97;
		}
	}

Begin:
	bBlockPlayers = true;
	SetPhysics( PHYS_Falling );
	if( bCanHoverLand )
	{
		AmbientSound = sound'SnatcherRoamLp02';
		LoopAnim( 'Hover' );
	}
	WaitForLanding();
	AmbientSound = none;
	DesiredRotation.Pitch = 0;
	if( Enemy != None )
		GotoState( 'Attacking' );
	else
		GotoState( 'Roaming' );
}

auto state Snatcher
{
	function BeginState()
	{
		Disable( 'SeePlayer' );
	}

	function SeePlayer( actor SeenPlayer )
	{
		local vector TempLocation, TempSeenPlayerLocation;

		if( !SeenPlayer.bIsRenderActor || !Pawn(SeenPlayer).bSnatched )
		{
			TempLocation = Location;
			TempLocation.Z = 0;
			TempSeenPlayerLocation = SeenPlayer.Location;
			TempSeenPlayerLocation.Z = 0;

			if( bWallMounted && FallFromWallDist > 0 && ( ( VSize( TempSeenPlayerLocation - TempLocation ) - CollisionRadius - SeenPlayer.CollisionRadius ) <  FallFromWallDist ) )
			{
				//log( "Distance passed. Going to Landing." );
				Enemy = SeenPlayer;
				bWallMounted = false;
				GotoState( 'Landing' );
				return;
			}
			else if( bWallMounted && FallFromWallDist <= 0 )
			{
				Enemy = SeenPlayer;
				bWallMounted = false;
				GotoState( 'Landing' );
				return;
			}
			if( !bWallMounted )
			{
				bBlockPlayers = true;
				PlaySound( sound'SnatcherRec03a', SLOT_Misc, SoundDampening * 0.9, true );
				Enemy = SeenPlayer;
				Disable( 'SeePlayer' );
				GotoState( 'Attacking' );
			}
		}
	}
Begin:
	if( !bStuckOnWall )
		LoopAnim( 'IdleA' );
	else
		LoopAnim( 'StuckWallIdleA' );

	if( !bWallMounted )
	{
		SetPhysics( PHYS_Falling );
		WaitForLanding();
		bBlockPlayers = true;
	}
	Enable( 'SeePlayer' );
}

state Attacking
{
	function BeginState()
	{
		bBlockPlayers=true;
		bAvoidLedges=false;
	}

	function Landed( vector HitNormal )
	{
		StopMoving();
		if( !bStuckOnWall )
			LoopAnim( 'IdleA' );
		else
			LoopAnim( 'StuckWallIdleA' );
	}

	simulated function SetWall(vector HitNormal, Actor Wall)
	{
		local vector TraceNorm, TraceLoc, Extent;
		local actor HitActor;
		local rotator RandRot;
	//		DesiredRotation = Floor.Rotation();
	//DesiredRotation.Pitch -= 16384;
	//DesiredRotation.Roll = 0;

	//	SurfaceNormal = HitNormal;
		//RandRot = rotator(HitNormal);
		//RandRot.Yaw -=16500;
	//	RandRot.Roll -= 16500;
	//	RandRot.Pitch += 32500; 
		//RandRot.Roll += 32768;
	//	RandRot.Yaw -= 13000;
	//	RandRot.Roll += 16250;
	//	RandRot.Pitch = 13000;
	//	RandRot.Yaw = 34218;
	//	RandRot.Roll = 18667;
	//	SetRotation( rotator( SurfaceNormal ) );
	//	SetPhysics( PHYS_None );
	//	Sleep( 10.0 );
	//	SetPhysics( PHYS_Spider );
		//SetRotation( Rotation + RandRot );

		//SetRotation( Rotation + rot( 16000, 0, 0 ) );
	//	SetRotation( RandROt );
	//	RandRot.Pitch += 16250;
//    	SetRotation(RandRot);	
		//SetRotation( RandRot );
	//	SetPhysics( PHYS_SPider );
	//	GotoState( '' );
	//	return;
		if ( Mover(Wall) != None )
			SetBase(Wall);
	}

	function HitWall( vector HitNormal, actor Wall )
	{
		local rotator NewRot;
		local actor HitActor;
		local vector NormalHit, HitLocation, StartTrace, EndTrace, X,Y,Z;
		local vector Offset;
		local info MyTest;

		GetAxes( Rotation, X,Y,Z );

		Offset = vect( 0, 1, 0 );
		Offset = Normal( Offset );

		StartTrace = Location + ( ( CollisionRadius * 0.5 ) * Y );
		EndTrace = StartTrace + vector( Rotation ) * 64;

		HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
		if( HitActor.IsA( 'LevelInfo' ) )
		{
			StartTrace = Location - ( ( CollisionRadius * 0.5 ) * Y );
			EndTrace = StartTrace + vector( Rotation ) * 64;
			HitActor = Trace( HitLocation, NormalHit, EndTrace, StartTrace, true );
			if( !HitActor.IsA( 'LevelInfo' ) )
				return;
		}
		else
			return;

		bStuckOnWall = true;
		//	SetPhysics( PHYS_None );
//		SetWall(HitNormal, Wall);
//		NewRot.Pitch = Rotation.Pitch + 5000;
//		SetRotation( NewRot );
//		DesiredRotation.Pitch += 24000;
		SetPhysics( PHYS_None );		
		LoopAnim( 'StuckWallIdleA' );
	//	SetPhysics( PHYS_Spider );
	//	NewRot = Rotation;
	//	NewRot.Pitch = 32500;
	//	SetRotation( rotator( HitNormal ) );
	//	DesiredRotation = ( Rotation + rot( 32500, 0, 0 ) );
	//	SetPhysics( PHYS_None );
	//	log( "PHYS_None" );
		Disable( 'Hitwall' );
	//	GotoState( '' );
	}


	function Timer( optional int TimerNum )
	{
		Enable( 'Bump' );
	}

	function Bump( actor Other )
	{

		if( Other == ENemy )
		{
		if( Physics == PHYS_Falling )
		{
			//if( Enemy.Location + Enemy.EyeHeight 
			if( ( FRand() < 0.22 || Enemy.IsA( 'NPC' ) ) && Pawn( Enemy ).CanSee( self ) )
			{
				if( Enemy.IsA( 'PlayerPawn' ) )
				{
					if( !PlayerPawn(Enemy).bSnatched )
						SetupSnatcher();
				}
				else
					GotoState( 'Attacking', 'EnterMouth' );
			}
			else if( Other == Enemy && (!Enemy.bIsRenderActor || !Pawn(Enemy).bSnatched) )
			{
				if( MeleeDamageTarget( 2 + Rand( 5 ), vector( Rotation ) * 150 ) )
				{
					Disable( 'Bump' );
					SetTimer( 0.5, false );
				}
			}
		}
		}
		else
			Super.Bump( Other );
	}

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		local vector HitLocation, HitNormal, TargetPoint;
		local actor HitActor;
		local DukePlayer PlayerEnemy; 	
		
		// check if still in melee range
		If ( (VSize(Enemy.Location - Location) <= 48 * 1.4 + Enemy.CollisionRadius + CollisionRadius)
			&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || ( Physics == PHYS_Falling ) || (Abs(Location.Z - Enemy.Location.Z) 
				<= FMax(CollisionHeight, Enemy.CollisionHeight) + 0.5 * FMin(CollisionHeight, Enemy.CollisionHeight))) )
		{	
			HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location, true);
			if ( HitActor != Enemy )
				return false;
			Enemy.TakeDamage(2 + Rand( 3 ), Self,HitLocation, pushdir, class'WhippedLeftDamage');
			if( Enemy.IsA( 'DukePlayer' ) )
			{
				PlayerEnemy = DukePlayer( Enemy );
				if( FRand() < 0.5 )
					PlayerEnemy.HitEffect( HitLocation, class'WhippedLeftDamage', vect(0,0,0), false );
				else
					PlayerEnemy.HitEffect( HitLocation, class'WhippedRightDamage', vect(0,0,0), false );
			}		
			return true;
		}

		return false;
	}

	function Tick( float DeltaTime )
	{
		if( Physics == PHYS_Falling )
		{

		/*	if( VSize( Enemy.Location - Location ) <= 128 && Enemy.IsA( 'DukePlayer' ) && DukePlayer( Enemy ).Weapon.IsA( 'MightyFoot' ) && DukePlayer( Enemy ).bFire != 0 && MightyFoot( DukePlayer( Enemy ).Weapon ).AnimSequence == 'FireA' )
			{
				Velocity *= 0;
				SetPhysics( PHYS_Falling );
				Health = 0;
				Died( Pawn( Enemy ), 'Booted', Location );
				Disable( 'Tick' );
				return;
			}*/
			if( VSize( Enemy.Location - Location ) <= 164 && AnimSequence != 'FlySlash' )
			{
				LoopAnim( 'FlySlash' );
			}
		}
//		if( Velocity.Z < 0 )
//		{
//			Velocity.Z *= 0.95;
//		}
	}

	function PlayTurnLeft()
	{
		PlayAllAnim( 'TurnLeft', 0.4, 0.1, true );
	}

	function PlayTurnRight()
	{
		PlayAllAnim( 'TurnRight', 0.4, 0.1, true );
	}

	function PlayTurn( vector TurnLocation )
	{
		local vector LookDir, OffDir;

		LookDir = vector( Rotation );

		OffDir = Normal( LookDir cross vect( 0, 0, 1 ) );

		if( ( OffDir dot( Location - TurnLocation ) ) > 0 )
		{
			PlayTurnRight();
		}

		else
		{
			PlayTurnLeft();
		}
	}

	function SnatchActor CreateMountedSnatcher( vector MountOrigin, rotator MountAngles, name MountMeshItem, optional actor Target )
	{
		MySnatchActor = Spawn( class'SnatchACtor', Enemy );
		MySnatchActor.AttachActorToParent( Enemy, true, true );
		MySnatchActor.MountOrigin = vect( -4, 0.5, -8.5 );
	//	MySnatchActor.MountAngles = MountAngles;
		MySnatchActor.MountAngles = rot( 16384, 0, -32740 );
		MySnatchActor.MountMeshItem = 'Lip_U';
		MySnatchActor.MountType = MOUNT_MeshBone;
		MySnatchActor.SetPhysics( PHYS_MovingBrush );
		MySnatchActor.PlayAnim( 'Snatch' );
		if( MySnatchActor != None )
		{
			return MySnatchACtor;
		}
	}
	
	function bool CanDirectlyReach( actor ReachActor )
	{
		local vector HitLocation,HitNormal;
		local actor HitActor;

		HitActor = Trace( HitLocation, HitNormal, ReachActor.Location + vect( 0, 0, -19 ), Location, true );
		
		if( HitActor == ReachActor && LineOfSightTo( ReachActor ) )
		{
			return true;
		}
		
		return false;
	}

	function vector EnemyBoneLocation()
	{
		local MeshInstance Minst;
		local int bone;

		Minst = Enemy.GetMeshInstance();

		Bone = Minst.BoneFindNamed( 'Lip_U' );

		return Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) );
	}

EnterMouth:
	TurnToward( Enemy );
	SetCollisionSize( 0.5, 0.5 );
	if( Enemy.bIsPawn )
		SetPhysics( PHYS_Flying );
	else
		SetPhysics( PHYS_Walking );

	if( Enemy.IsA( 'dnCarcass' ) )
	{
		PlayAllAnim( 'Run',1.25, 0.1, true );
		AmbientSound = sound'SnatcherRoamLp02';
		MoveTo( EnemyBoneLocation() );
		AmbientSound = none;
	}
	else
		MoveTo( EnemyBoneLocation() );
	CreateMountedSnatcher( vect( 0.5, 0, 6.0 ), rot( -16384, 0, 0 ), 'Lip_U', Enemy );
	if (Enemy.bIsRenderActor && Enemy.bIsPawn )
		Pawn(Enemy).bSnatched = true;
	if( Enemy.IsA( 'HumanNPC' ) )
	{
		HumanNPC( Enemy ).bSnatchedAtStartup = true;
		HumanNPC( Enemy ).bVisiblySnatched = true;
		HumanNPC( Enemy ).bAggressiveToPlayer = true;
		HumanNPC( Enemy ).bHateWhenSnatched = true;
		Enemy.GotoState( 'SnatchedEffects' );
	}
	//log( self$" Destroyed" );
	bHidden = true;
	Destroy();

Begin:
//	LoopAnim( 'IdleA' );
	if( Enemy == None || ( Enemy.bIsPawn && Pawn(Enemy).Health <= 0 ) )
	{
		Enemy = FoundCarcassNearby();
		if( Enemy == None )
			GotoState( 'Snatched' );
		else
			Goto( 'EnterMouth' );
	}

	if( NeedToTurn( Enemy.Location ) && !bStuckOnWall )
	{
		RotationRate.Yaw = 25000;
		PlayTurn( Enemy.Location );
		TurnToward( Enemy );
		FinishAnim( 0 );
		RotationRate.Yaw = Default.RotationRate.Yaw;
	}
Moving:
	if( bStuckOnWall )
	{
		SetPhysics( PHYS_falling );
		WaitForLanding();
		bStuckOnWall = false;
	}
	if( VSize( Enemy.Location - Location ) > 256 && !CanDirectlyReach( Enemy ) )
	{
		if( !FindBestPathToward( Enemy, true ) )
		{
			PlayAllAnim( 'IdleA',, 0.1, true );
			GotoState( 'Snatcher' );
		}
		else
		{
			PlayAllAnim( 'Run',1.25, 0.1, true );
			AmbientSound = sound'SnatcherRoamLp02';
			MoveTo( Destination, RunSpeed );
			AmbientSound = none;
			if( VSize( Enemy.Location - Location ) <= 256 && CanSee( Enemy ) )
			{
				Goto( 'JumpAttack' );
			}
			else
			{
				Goto( 'Begin' );
			}
		}
	}
	else if( CanDirectlyReach( Enemy ) && VSize( Enemy.Location - Location ) > 256 )
	{
		PlayAllAnim( 'Run',1.25, 0.1, true );
		AmbientSound = sound'SnatcherRoamLp02';
		MoveTo( Location - 64 * Normal( Location - Enemy.Location), RunSpeed );
		AmbientSound = None;
	}
	else if( VSize( Enemy.Location - Location ) <= 256 && CanSee( Enemy ) ) 
	{
		Goto( 'JumpAttack' );
	}
	else
		GotoState( 'Snatching' );
	Goto( 'Moving' );
/*
	PlayAllAnim( 'Run',1.25, 0.1, true );
	log( "PlayRunAnim called seq is :"$AnimSequence );
	MoveTo( Location - 24 * Normal( Location - Enemy.Location), RunSpeed );
	log( "Finished moving seq is "$AnimSequence );
	if( VSize( Enemy.Location - Location ) < 256 )
		Goto( 'JumpAttack' );
	else
		Goto( 'Begin' );
*/
JumpAttack:
	Enable( 'Hitwall' );
	PlayAllAnim( 'IdleA',, 0.1, true );
	if( NeedToTurn( Enemy.Location ) && !bStuckOnWall )
	{
		PlayTurn( Enemy.Location );
		TurnToward( Enemy );
		FinishAnim( 0 );
	}

	if( !bStuckOnWall )
	{
		PlayAnim( 'PreLeap' );
		AmbientSound = sound'c_characters.SnatcherFlyLp01';
//	Sleep( FRand() );
		FinishAnim();
	}

	SetPhysics( PHYS_Falling );
	//	SoundVolume = SoundDampening * 0.8;
	Velocity = Vector( rotator( Enemy.Location - Location ) ) * ( VSize( Enemy.Location - Location ) * 2.15 );//* 750;
	Acceleration = vector( Rotation ) * 25;
	bStuckOnWall = false;
	SetRotation( rotator( Enemy.Location - Location ) );
	LoopAnim( 'Hover' );
	PlaySound( sound'SnatcherAttack1', SLOT_Misc, SoundDampening * 0.9, true );

	if( FRand() < 0.33 )
	{
		if( FRand() < 0.5 )
			Velocity += VRand() * 0.1;
		else Velocity -= VRand() * 0.1;
	}
	if( Enemy.IsA( 'PlayerPawn' ) && Pawn( Enemy ).bDuck != 0 )
	{
		Velocity.Z += 80;
	}
	else
		Velocity.Z += 225;
	WaitForLanding();
	if( bStuckOnWall )
	{
		Sleep( 0.5 + FRand() );
	}
	AmbientSound = none;

	if( NeedToTurn( Enemy.Location ) && !bStuckOnWall )
	{
		PlayTurn( Enemy.Location );
		TurnToward( Enemy );
		FinishAnim( 0 );
	}
	if( Enemy == None || ( Enemy.bIsPawn && Pawn(Enemy).Health <= 0 ) )
	{ 
		Enemy = FoundCarcassNearby();
		if( Enemy == None )
			GotoState( 'Snatched' );
		else
			Goto( 'EnterMouth' );
	}
	else
	if( VSize( Enemy.Location - Location ) < 256 )
	{
		Goto( 'JumpAttack' );
	}
	else
	{
		Goto( 'Begin' );
	}
}

function dnCarcass FoundCarcassNearby()
{
	local dnCarcass Husk;

	foreach radiusactors( class'dnCarcass', Husk, 512 )
	{
		if( LineOfSightTo( Husk ) )
		{
			return Husk;
		}
	}
}

function PlayDying( class<DamageType> DamageType, vector HitLocation)
{
	//if( FRand() < 0.2 )
	//	PlayAnim( 'DeathA' );
	//else
	if( AnimSequence == 'FlipBack' )
	{
		PlayAnim( 'DeathBack' );
		return;
	}

	if( DamageType == class'SnatcherDeLeggedDamage' )
	{
		if( FRand() < 0.15 )
			PlayAnim( 'DeathANoLegs' );
		else
			PlayAnim( 'DeathBNoLegs' );
	}
	else if( DamageType == class'SnatcherDeLeggedRDamage' )
	{
		if( FRand() < 0.15 )
			PlayAnim( 'DeathARLeg' );
		else
			PlayAnim( 'DeathBRLeg' );
	}
	else if( DamageType == class'SnatcherDeLeggedLDamage' )
	{
		if( FRand() < 0.15 )
			PlayAnim( 'DeathALLeg' );
		else
			PlayAnim( 'DeathBLLeg' );
	}
	else
	{
		if( FRand() < 0.1 )
			PlayAnim( 'DeathA' );
		else
			PlayAnim( 'DeathB' );
	}
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc == None )
		return None;
	carc.Initfor(self);
	if( bChunky )
	{
		carc.ChunkCarcass();
		carc.ChunkDamageType	= class'KungFuDamage';
	}
	carc.MeshDecalLink = MeshDecalLink;
	return carc;
}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	if( MasterPod != None )
		MasterPod.RemoveSnatcher( self );

	PlaySound( sound'SnatcherDie1', SLOT_None, SoundDampening * 0.9, true );

	if( Killer != None && Killer.IsA( 'PlayerPawn' ) )
	{
		PlayerPawn( Killer ).AddEgo( 3 );
	}
	if( ClassIsChildOf(DamageType, class'KungFuDamage') )
		bChunky = true;
		
	Super.Died( Killer, DamageType, HitLocation );
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local rotator Dir;
	local sound PainSound;

	if( ClassIsChildOf( DamageType, class'PoisonDamage' ) )
		return;

	if( DamageType == class'SnatcherRollDamage' )
		bRolledOver = true;

	if( FRand() < 0.5 )
		PainSound = sound'SnatcherPain2';
	else
		PainSound = sound'SnatcherPain1';
	
	PlaySound( sound'SnatcherPain1', SLOT_Misc, SoundDampening * 0.9, false );

	if( PHysics != PHYS_Falling )
	{
		SetPhysics( PHYS_Falling );
		Momentum *= 0.1;
		AddVelocity( Momentum );
		Velocity.Z = 16;
	}
	Enemy = instigatedBy;
	Super.TakeDamage( Damage, instigatedBy, HitLocation, Momentum, DamageType );
	if( AnimSequence != 'FlipBack' )
	{
		if( NextState != 'TakeHit' )
			NextState = GetStateName();
		GotoState( 'TakeHit' );
	}
}

function PlayHit( float Damage, vector HitLocation, name damageType, vector Momentum )
{
	NextState = GetStateName();
	GotoState( 'TakeHit' );
}
// SnatcherRip01

state TakeHit
{
	function PlayDamage()
	{
		if( FRand() < 0.35 || bRolledOver )
		{
			PlaySound( sound'SnatcherFlip3', SLOT_None, SoundDampening * 0.9, true );
			PlayAnim( 'FlipBack' );
		}
		else if( FRand() < 0.5 )
			PlayAnim( 'PainA' );
		else
			PlayAnim( 'PainB' );
	}

Begin:
	bBlockPlayers=true;
	WaitForLanding();
	AmbientSound = None;
	PlayDamage();	
	bRolledOver = false;
	FinishAnim();
	if( Enemy == None )
	{
		if( NextState == '' )
			GotoState( 'Snatcher' );
		else
			GotoState( NextState );
	}
	else
		GotoState( 'Attacking' );
}

function SetupSnatcher()
{
	local PlayerPawn P;
	local inventory Inv;

	/*
	Inv = P.FindInventoryType( class'SnatcherFace' );
	log( "Found: "$Inv );
	if( Inv != None )
	{
		log( "Found: "$Inv );
		P.Weapon.PutDown();
		//P.Weapon = Weapon( Inv );
		//P.Weapon.BringUp();
		//SnatcherFace( Inv ).GotoState( 'Activated' );
	}*/
	if ( Pawn( Enemy ) != None && ( ( Pawn( Enemy ).UsedItem == None ) || !Pawn( Enemy ).UsedItem.IsA( 'Rebreather' ) ) )
	{
		if ( ( Pawn( Enemy ).UsedItem != None ) && Pawn( Enemy ).UsedItem.IsA( 'RiotShield' ) )
		{
			if ( RiotShield( Pawn( Enemy ).UsedItem ).GetStateName() == 'ShieldUp' )
				return;
		}

		Pawn( Enemy ).bSnatched = true;
		Pawn( Enemy ).bFire = 0;
		Pawn( Enemy ).bAltFire = 0;
//		Pawn( Enemy ).PendingWeapon = Pawn( Enemy ).Weapon;
//		Pawn( Enemy ).LastWeapon = Pawn( Enemy ).Weapon;
		Pawn( Enemy ).LastWeaponClass = Pawn( Enemy ).Weapon.Class;
		Level.Game.GiveWeaponTo( Pawn( Enemy ), class'SnatcherFace' );
		DukePlayer( Enemy ).bWeaponsActive = false;	
		Destroy();
	}
}

state ActivityControl
{
	function Initialize()
	{
		if( MyAE.TagToSnatch != '' )
		{
			//if( !SetEnemy( GetSnatchVictim( MyAE.TagToSnatch ) ) )
			//{
			//	Super.BeginState();
			//}
		}
		else
			Super.BeginState();
	}
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

	function SeePlayer( actor SeenPlayer )
	{
		if( SeenPlayer.bIsRenderActor && !Pawn(SeenPlayer).bSnatched )
		{
			StopMoving();
			Enemy = SeenPlayer;
			Disable( 'SeePlayer' );
			GotoState( 'Attacking' );
		}
	}

	function BeginState()
	{
		bAvoidLedges = false;
//		MinHitWall = -0.2;
		Enemy = None;
		Disable('AnimEnd');
		JumpZ = -1;
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
		JumpZ = Default.JumpZ;
		bAvoidLedges = false;
//		MinHitWall = Default.MinHitWall;
	}

Begin:

Wander: 
	SetRunMode( true );
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

	PickDestination();
	if( Destination.Z > Location.Z && bCanFly  )
	{
		SetPhysics( PHYS_Flying );
		PlayHovering();
	}
	else
	{
		SetPhysics( PHYS_Walking );
		PlayToWalking();
	}
	
Moving:
	Enable('Bump');
	AmbientSound = sound'SnatcherRoamLp02';
	TurnTo( Destination );
	MoveTo(Destination, WalkingSpeed );
	AmbientSound = none;
	if( Physics != PHYS_Walking )
	{
		SetPhysics( PHYS_Falling );
		WaitForLanding();
		Acceleration = vect( 0, 0, 0 );
		PlayToWaiting();
		TurnTo( Location );
	}

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
//		** WaitForLanding" );
//		WaitForLanding();
//		SetPhysics( PHYS_Walking );
	}
*/
	StopMoving();
	PlayToWaiting();
	Acceleration = vect( 0,0,0 );
	Sleep(2 + 1 * FRand());
	Goto('Wander');

ContinueWander:
	FinishAnim();
	PlayWalking();
	Goto('Wander');

Turn:
	Acceleration = vect( 0,0,0 );
	SetTurn();
	TurnTo( Destination );
	Goto( 'Pausing');
}

/*-----------------------------------------------------------------------------
	SetRunMode toggles creature between walking and running. Any movement
	speed adjustments should be handled here.
-----------------------------------------------------------------------------*/
function SetRunMode( bool bRunMode )
{
	if( bRunMode )
	{
		GroundSpeed = Default.GroundSpeed;
		WalkingSpeed = 0.4;
		bRunning = true;
	}
	else
	{
		GroundSpeed = 150;
		WalkingSpeed = 0.25;
		bRunning = false;
	}
}
/*-----------------------------------------------------------------------------
	Animation functions.
-----------------------------------------------------------------------------*/
function PlayMeleeAttack()
{
	PlayAllAnim( 'FlySlash',, 0.1, false );
}

function PlaySnatching()
{
	PlayAllAnim( 'Snatch',, 0.1, false );
}

function PlayToWalking()
{
	if( Physics == PHYS_Flying )
	{
		PlayAllAnim( 'Hover',, 0.1, true );
	}
	else
	if( bRunning )
	{
		PlayAllAnim( 'Run',1.25, 0.1, true );
	}
	else
	{
		PlayAllAnim( 'Walk',, 0.1, true );
	}
}

function PlayRunning()
{
	if( Physics == PHYS_Flying )
	{
		PlayAllAnim( 'Hover',, 0.1, true );
	}
	else
		PlayAllAnim( 'Run',1.25, 0.1, true );
}

function PlayToWaiting( optional float TweenTime )
{
	PlayAllAnim( 'IdleA',, 0.1, true );
}

function PlayHovering()
{
	PlayAllAnim( 'Hover',, 0.1, true );
}

function Destroyed()
{
	if( MasterPod != None )
		MasterPod.RemoveSnatcher( self );
	Super.Destroyed();
}

defaultproperties
{
     bRotateToDesired=True
     RotationRate=(Pitch=3072,Yaw=17000,Roll=2048)
     DrawScale=1.1
     bBlockPlayers=false
	 LodMode=LOD_StopMinimum
     DrawType=DT_Mesh
     Mesh=DukeMesh'c_characters.alien_snatcher'
     CollisionRadius=16.000000
     CollisionHeight=5.0000000
     bHeated=True
     HeatIntensity=128.000000
     HeatRadius=8.000000
	 GroundSpeed=350
	 //WanderRadius=96
     AirSpeed=+00300.000000
     Health=0014.000000
     WalkingSpeed=0.4
     PathingCollisionHeight=39
     PathingCollisionRadius=17
     bModifyCollisionToPath=true
	 bAggressiveToPlayer=true
	 MeleeRange=96
	 RunSpeed=0.7
     CarcassType=class'SnatcherCarcass'
     bAggressiveToPlayer=true
	 CreatureOrders=ORDERS_Roaming
	 AccelRate=2048
	 bSnatched=true
	 SoundRadius=128
	 SoundVolume=255
	 FallFromWallDist=96
	 bCanHoverLand=true
	 MinHitWall=400
	 bForceHitWall=true
     BloodHitDecalName="dnGame.dnAlienBloodHit"
	 HitPackageClass=class'HitPackage_AlienFlesh'
	 ImmolationClass="dnGame.dnMeshImmolation"
}
