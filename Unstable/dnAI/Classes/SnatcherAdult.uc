class SnatcherAdult extends Creature;

#exec OBJ LOAD FILE=..\meshes\c_characters.dmx
#exec OBJ LOAD FILE=..\sounds\a_ambient.dfx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

/*================================================================
	Sequences:
	
	BlastA
	BurrowDn
	BurrowIdle
	BurrowUp
	DeathA
	DeathB
	DeathC
	IdleA
	IdleB
	JumpSlashAir
	JumpSlashLand
	JumpSlashStart
	PainA
	PainB
	PainC
	Run
	SlashA
	SlashB
	TurnL35
	TurnR35
	Walk
================================================================*/
var class<DamageType> TempDam;
var vector TempMomentum, TempHitLocation;

var() bool		bBurrowAmbush			?( "Have creature burrowing at start for an ambush." );
var() float		AmbushRadius			?( "Distance enemy must be before rising for ambush." );
var() float		CheckAmbushFrequency	?( "How often to check the AmbushRadius for a player enemy." );

var byte	MoveDir;
var bool	bCanBurrow;
var bool	bCanPlayPain;
var bool	bWaitForEnemyMove;
var vector	LastEnemyLocation;
var SnatcherRubble MyMound;
var byte	RunMode;
var bool	bRunShiftDisabled;
var class<Material> CurrentMaterial;

function SpawnMound()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	if( CanSpawnMound() )
	{
		HitActor = Trace( HitLocation, HitNormal, Location + vect( 0, 0, -1024 ), Location, true );
		MyMound = Spawn( class'SnatcherRubble', self,, HitLocation );
		MyMound.Mesh = CurrentMaterial.Default.BurrowMesh;
	}
}

function bool CanSpawnMound()
{
	local Texture T;
	local class<Material> M;
	
	T = TraceTexture( Location + vect( 0, 0, -CollisionHeight - 20 ), Location );

	M = T.GetMaterial();

	if( M != None )
	{
		/*if( M.Default.bBurrowableStone )
		{
			CurrentMaterial = M;
			return true;
		}
		if( M.Default.bBurrowableDirt )
		{
			CurrentMaterial = M;
			return true;
		}*/

		CurrentMaterial = M;
		if( CurrentMaterial.Default.BurrowParticlesDown != None || CurrentMaterial.Default.BurrowParticlesUp != None ||
			CurrentMaterial.Default.BurrowMesh != None )
		return true;
	}
	else
	{
		broadcastmessage( "NO MATERIAL SET FOR THIS SURFACE. PLEASE FIX FOR TEXTURE: "$T );
		return false;
	}
}

function PostBeginPlay()
{
	RotationRate.Pitch = 0;
	bCanBurrow =	 true;
	bCanPlayPain =	 true;
	RotationRate.Yaw = 75000;
	Super.PostBeginPlay();
}

function ToggleBurrow()
{
	bCanBurrow = !bCanBurrow;
}

function BurrowTimer()
{
	ToggleBurrow();
//	SetCallbackTimer( 10.0, false, 'BurrowTimer' );
}

function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
	local rotator FireRotation;
	local vector FireSpot;
	local actor HitActor;
	local vector HitLocation, HitNormal, FireDir;
	local float TargetDist, TossSpeed, TossTime;
	local int realYaw;
	local float Skill;
	local float Accuracy;	

	Skill = 5;
	if ( projSpeed == 0 )
		return AdjustAim(projSpeed, projStart, aimerror, leadTarget, warnTarget);
	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
		return Rotation;
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
		viewRotation = Rotator(FireSpot - ProjStart);
		return viewRotation;
	}					
	aimerror = aimerror * (11 - 10 *  
		((Target.Location - Location)/TargetDist 
			Dot Normal((Target.Location + 1.2 * Target.Velocity) - (ProjStart + Velocity)))); 
		aimerror = aimerror * (1.5 - 0.35 * (skill + FRand()));
	if ( !leadTarget || (accuracy < 0) )
		aimerror -= aimerror * accuracy;

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
			bFire = 0;
			bAltFire = 0;
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
		}
	}

	// adjust for toss distance (assume 200 z velocity add & 60 init height)
//	if ( FRand() < 0.75 )
//	{
		TossSpeed = projSpeed + 0.4 * VSize(Velocity); 
		if ( (Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z) 
			|| (TargetDist > TossSpeed) )
		{
			TossTime = TargetDist/TossSpeed;
			FireSpot.Z -= ((0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200) * TossTime + 60);	
		}
//	}

	FireRotation = Rotator(FireSpot - ProjStart);
	realYaw = FireRotation.Yaw;
	aimerror = Rand(2 * aimerror) - aimerror;

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

	//viewRotation = FireRotation;			
	return FireRotation;
}

function BrainBlastNotify()
{
//	Spawn( class'dnRocket_BrainBlastB', self,, Location, Rotation );
	local vector X,Y,Z;
	local dnRocket_BrainBlastB P;
	local vector Start;
	local rotator AdjustedAim;

	GetAxes( ViewRotation, X, Y, Z );
	//Start = Location;// + Weapon.CalcDrawOffset();
	Start = Location; 

	AdjustedAim = AdjustToss( 550, Start, 0.0, true, false );
	P = Spawn( class'dnRocket_BrainBlastB', self,, Start + vector( Rotation ) * 32, AdjustedAim );
	P.SetPhysics( PHYS_Falling );
	P.Velocity = Vector(P.Rotation) * 550;     
	P.Velocity.z += 200; 
}

function TentacleSwipeLeft()
{
	if( PodMeleeDamageTarget( 8, vector( Rotation ) * -1, class'TentacleDamage' ) )
	{
		DukeHUD( DukePlayer( Enemy ).MyHUD ).RegisterBloodSlash( 0 );
		DukePlayer( Enemy ).AddRotationShake( FRand()*0.5 + 0.15, 'Right' );
	}
}

function TentacleSwipeRight()
{
	if( PodMeleeDamageTarget( 8, vector( Rotation ) * -1, class'TentacleDamage' ) )
	{
		DukeHUD( DukePlayer( Enemy ).MyHUD ).RegisterBloodSlash( 7 );
		DukePlayer( Enemy ).AddRotationShake( FRand()*0.5 + 0.15, 'Left' );
	}
}

function bool PodMeleeDamageTarget(int hitdamage, vector pushdir, class<DamageType> DamType )
{
	local vector HitLocation, HitNormal, TargetPoint;
	local actor HitActor;
	local DukePlayer PlayerEnemy; 	
	
	// check if still in melee range
	if ( (VSize(Enemy.Location - Location) <= 64 * 1.4 + Enemy.CollisionRadius + CollisionRadius)
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
			PlayerEnemy.HitEffect( HitLocation, DamType, vect(0,0,0), false );
		}		
		return true;
	}
	return false;
}

function bool CanBurrowMove()
{
	local float Dist;

	if( !bCanBurrow )
		return false;

	Dist = VSize( Location - Enemy.Location );

	if( Dist > 180 )
		return true;

	return false;
}

function bool CanSpitAttack()
{
	local float Dist;

	Dist = VSize( Location - Enemy.Location );
	
	if( Dist > 180 )
		return true;

	return false;
}

function bool CanJumpAttack()
{
	local float Dist;

	Dist = VSize( Location - Enemy.Location );

	if( Dist < 360 && Dist > 180 )
		return true;
	
	return false;
}

function vector GetBurrowDestination()
{
	local vector X, Y, Z;

	GetAxes( Pawn( Enemy ).Rotation, X, Y, Z );

	//Destination = Enemy.Location; // + ( X * -64 );
	if( MoveDir == 1 )
		return Enemy.Location + ( Y * -128 );
	else
		return Enemy.Location - ( Y * -128 );
}

state BurrowMove
{
	ignores SeePlayer, EnemyNotVisible, Bump, Touch;

	function BeginState()
	{
		if( FRand() < 0.5 )
			MoveDir = 1;
		else
			MoveDir = 0;
	}

	function bool CanRise()
	{
		local renderactor A;

		ForEach RadiusActors( class'RenderActor', A, CollisionRadius * 1.2 )
		{
			if( A != self )
			{
				if( A.bCollideActors || A.bBlockActors || A.bBlockPlayers )
					return false;
			}
		}
		return true;
	}

	function Timer( optional int TimerNum )
	{
		if( CanRise() )
		{
			StopMoving();
			GotoState( 'BurrowMove', 'Reached' );
		}
		else SetTimer( 5.0, false );
	}

	function EndState()
	{
		GroundSpeed = Default.GroundSpeed;
		AccelRate = Default.AccelRate;
		//RotationRate = Default.RotationRate;
	}
	
	function Quake()
	{
		local Pawn P;	

		P = Level.PawnList;
		while( P != None )
		{
			if( ( PlayerPawn( P ) != None ) && ( VSize( Location - P.Location ) < 350 ) )
			{
				PlayerPawn( P ).ShakeView( 0.5, 350, 0.015 * 350 );
			}
			P = P.nextPawn;
		}
	}

Reached:
	EndCallbackTimer( 'Quake' );
	StopMoving();
	AmbientSound = None;
	SetTimer( 0.0, false );
	TurnToward( Enemy );
	bHidden = false;
	PlayAllAnim( 'BurrowUp',, 0.1, false );
	FinishAnim( 0 );
	SetCollision( Default.bCollideActors, Default.bBlockActors, Default.bBlockPlayers );
	PlayAllAnim( 'IdleA',, 0.12, true );
	GotoState( 'Attacking' );

Begin:
	//RotationRate.Yaw = 90000;
	ToggleBurrow();
	SetCallbackTimer( 10.0, false, 'BurrowTimer' );
	SetCollision( false, false, false );
	PlayAllAnim( 'BurrowDn',, 0.12, false );
	FinishAnim( 0 );
	SetCallbackTimer( 0.5, true, 'Quake' );
	PlayAllAnim( 'BurrowIdle',, 0.1, true );
	bHidden = true;
	SetTimer( 5.0, false );
	AmbientSound = sound'A_Ambient.EQuake01';
	SoundVolume = 250;
	SoundRadius = 1200;

Moving:
	GetBurrowDestination();
	GroundSpeed *= 3.5;
	AccelRate = 2200.0;
	if( !CanDirectlyReach( Enemy ) )
	{
		if( !FindBestPathToward( Enemy, true ) )
			Goto( 'Reached' );
		else
		{
			MoveTo( Destination, 0.6 );
			if( VSize( Enemy.Location - Location ) <= 64 && CanSee( Enemy ) )
				Goto( 'Rise' );
			else
				Goto( 'Moving' );
		}		
	}
	else
		MoveTo( Location - ( 128 * Normal( Location - GetBurrowDestination() ) ), 8.45 );
	
	if( VSize( GetBurrowDestination() - Location ) < 64 )
		Goto( 'Reached' );
	else
	{
		Sleep( 0.0 );
		Goto( 'Moving' );
	}
}

function bool CanDirectlyReach( actor ReachActor )
{
	local vector HitLocation,HitNormal;
	local actor HitActor;
	local vector TestDir;

	TestDir = Location + ( ( Enemy.Location - Location ) * 5000 );
	TestDir.Z = Location.Z;

	HitActor = Trace( HitLocation, HitNormal, TestDir, Location, true );
	if( ( HitActor == ReachActor && LineOfSightTo( ReachActor ) ) || HitActor.IsA( 'SnatcherAdult' ) )
	{
		return true;
	}
	return false;
}

function ToggleRunShift()
{
	bRunShiftDisabled = false;
}

function PlayToRunning()
{
	//if( RunMode == 1 )
	//	PlayAllAnim( 'RunB', 2,, true );
	//else
	if( GetSequence( 0 ) != 'Run' )
		PlayAllAnim( 'Run', 2,, true );
}
/*
AdjustFromWall:
01838		StrafeTo(Destination, Focus); 
01839		Destination = Focus; 
01840		Goto('Moving');
*/


state Attacking
{/*
	function HitWall(vector HitNormal, actor Wall)
	{
		broadcastmessage(" ** HITWALL" );
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
		Destination = Enemy.Location;
		Focus = Destination;

		if (PickWallAdjust())
		{
			broadcastmessage( "*** PICKWALL ADJUST" );
			GotoState('Attacking', 'AdjustFromWall');
		}
		else
		{
			broadcastmessage( "PICK WALL FAILED" );
			MoveTimer = -1.0;
			PlayAllAnim( 'IdleA',, 0.1, true );
		}
	}
	*/

	function AnimEnd()
	{
	/*	if( !bRunShiftDisabled && FRand() < 0.5 )
		{
			if( GetSequence( 0 ) == 'Run' && FRand() < 0.25 )
			{
				RunMode = 1;
				PlayAllAnim( 'RunB', 2,, true );
			}
			else if( GetSequence( 0 ) == 'RunB' )
			{
				RunMode = 0;
				PlayAllAnim( 'Run', 2,, true );
			}
	
			bRunShiftDisabled = true;
			SetCallbackTimer( 1.5, false, 'ToggleRunShift' );
		}*/
	}

	function BeginState()
	{
		bBlockPlayers=true;
		bAvoidLedges=false;
	}


	function Timer( optional int TimerNum )
	{
		Enable( 'Bump' );
	}

/*	function HitWall( vector HitNormal, actor Wall )
	{
		if( !Wall.IsA( 'dnDecoration' ) )
		{
			if( !ActorReachable( Enemy ) )
			{
				PlayToWaiting();
				MoveTimer = -1.0;
				StopMoving();
				LastEnemyLocation = Enemy.Location;
				bWaitForEnemyMove = true;
				GotoState( 'Ambush', 'Burrow' );
				Disable( 'HitWall' );
			}
		}
	}*/

	function Bump( actor Other )
	{
		if( Other == Enemy && ( GetSequence( 0 ) != 'JumpSlashAir' && GetSequence( 0 ) != 'JumpSlashLand' ) )
		{
			if( Other == Enemy && (!Enemy.bIsRenderActor || !Pawn(Enemy).bSnatched) )
			{
				if( GetSequence( 0 ) != 'SlashA' && GetSequence( 0 ) != 'SlashB' ) 
				{
					if( FRand() < 0.5 )
						PlayAllAnim( 'SlashA',, 0.1, false );
					else
						PlayAllAnim( 'SlashB',, 0.1, false );
				}
			}
		}
		else
			Super.Bump( Other );
	}

	function PlayTurnLeft()
	{
		PlayAllAnim( 'TurnL35', 1.75 , 0.1, true );
	}

	function PlayTurnRight()
	{
		PlayAllAnim( 'TurnR35', 1.75, 0.1, true );
	}

	function PlayTurn( vector TurnLocation )
	{
		local vector LookDir, OffDir;

		LookDir = vector( Rotation );

		OffDir = Normal( LookDir cross vect( 0, 0, 1 ) );

		if( ( OffDir dot( Location - TurnLocation ) ) > 0 )
			PlayTurnRight();
		
		else PlayTurnLeft();
	}

	function vector EnemyBoneLocation()
	{
		local MeshInstance Minst;
		local int bone;

		Minst = Enemy.GetMeshInstance();

		Bone = Minst.BoneFindNamed( 'Lip_U' );

		return Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) );
	}

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Moving');

JumpAttack:
	Enable( 'Hitwall' );
	if( NeedToTurn( Enemy.Location ) )
	{
		PlayTurn( Enemy.Location );
		TurnToward( Enemy );
		FinishAnim( 0 );
	}

	PlayTestAnim( 'JumpSlashStart',, 0.1, false );
	AmbientSound = sound'c_characters.SnatcherFlyLp01';
	FinishAnim( 0 );
	SetPhysics( PHYS_Falling );
	Velocity = Vector( rotator( Enemy.Location - Location ) ) * ( VSize( Enemy.Location - Location ) * 2.15 );//* 750;
	Acceleration = vector( Rotation ) * 25;
	SetRotation( rotator( Enemy.Location - Location ) );
	PlayTestAnim( 'JumpSlashAir',, -1.0,, true );
	if( FRand() < 0.33 )
	{
		if( FRand() < 0.5 )
			Velocity += VRand() * 0.1;
		else Velocity -= VRand() * 0.1;
	}
	if( Enemy.IsA( 'PlayerPawn' ) && Pawn( Enemy ).bDuck != 0 )
		Velocity.Z += 80;
	else
		Velocity.Z += 225;
	WaitForLanding();
	PlayTestAnim( 'JumpSlashLand',, -1.0,, true );
	FinishAnim(0);
	StopMoving();
	PlayAllAnim( 'IdleA',, 0.1, true );
	if( CanBurrowMove() && FRand() < 0.25 )
		GotoState( 'BurrowMove' );

	if( CanJumpAttack() && FRand() < 0.2 )
		Goto( 'JumpAttack' );
	else
		Goto( 'Begin' );

AttackSpit:
	StopMoving();
	if( NeedToTurn( Enemy.Location ) )
	{
		PlayTurn( Enemy.Location );
		TurnToward( Enemy );
		FinishAnim( 0 );
		//RotationRate.Yaw = Default.RotationRate.Yaw;
	}
	PlayAllAnim( 'BlastA',, 0.1, false );
	FinishAnim( 0 );
	Goto( 'Begin' );

Attacking:
	if( FRand() < 0.5 )
		PlayAllAnim( 'SlashA',, 0.1, false );
	else
		PlayAllAnim( 'SlashB',, 0.1, false );
	FinishAnim( 0 );
	Goto( 'Begin' );

Begin:
	if( NeedToTurn( Enemy.Location ) )
	{
		PlayTurn( Enemy.Location );
		TurnToward( Enemy );
		FinishAnim( 0 );
		//RotationRate.Yaw = Default.RotationRate.Yaw;
	}
Moving:
	if( VSize( Enemy.Location - Location ) > 32 && /*CanDirectlyReach( Enemy )*/ !ActorReachable( Enemy ) )
	{
		if( /*!ActorReachable( Enemy ) ||*/ !FindBestPathToward( Enemy, true ) )
		{
			PlayAllAnim( 'IdleA',, 0.1, true );
			//GotoState( 'Snatcher' );
			Sleep( 0.5 );
			bWaitForEnemyMove = true;
			LastEnemyLocation = Enemy.Location;
			////GotoState( 'Ambush', 'Burrow' );
			Goto( 'Moving' );
		}
		else
		{
			//if( PointReachable( Enemy.Location ) )
			//	broadcastmessage( "REACHABLE" );
			//else
			//{
			//	broadcastmessage( "NOT REACHABLE" );
			//	StopMoving();
			//	GotoState( 'Ambush', 'Burrow' );
			//}

			//PlayAllAnim( 'Run', 2, 0.1, true );
			PlayToRunning();
			Enable( 'AnimEnd' );
			MoveTo( Destination, 0.6 );
			Disable( 'AnimEnd' );
		//	if( VSize( Enemy.Location - Location ) <= 72 && CanSee( Enemy ) )
			//{
				//broadcastmessage( "GOING TO ATTACKING" );
				//log( "." );
		//		Goto( 'Attacking' );
			//}
			//else 
			if( CanSee( Enemy ) )
			{
//	log( "Move 6" );
				if( FRand() < 0.25 && CanBurrowMove() )
					GotoState( 'BurrowMove' );
			}
/*
				else if( FRand() < 0.22 && CanSpitAttack() )
					Goto( 'AttackSpit' );
				else if( CanJumpAttack() && FRand() < 0.22 )
					Goto( 'JumpAttack' );
			}
			else*/
			//{
				Goto( 'Moving' );
			//}
		}
	}
	else if( ActorReachable( Enemy ) /*CanDirectlyReach( Enemy )*/ && VSize( Enemy.Location - Location ) > 64 )
	{
		//if( FRand() < 0.25 && CanBurrowMove() )
		//	GotoState( 'BurrowMove' );
		//else
		if( CanSpitAttack() && CanSee( Enemy ) && FRand() < 0.22 )
			Goto( 'AttackSpit' );
		else if( CanJumpAttack() && FRand() < 0.22 )
			Goto( 'JumpAttack' );
		//PlayAllAnim( 'Run',2, 0.1, true );
		PlayToRunning();
		Enable( 'AnimEnd' );
		MoveTo( Location - 64 * Normal( Location - Enemy.Location), 0.6 );
		Disable( 'AnimEnd' );

	}
	if( VSize( Enemy.Location - Location ) <= 64 && CanSee( Enemy ) )
	{
		Goto( 'Attacking' );
	}
	else
	{
		Sleep( 0.0 );
		Goto( 'Moving' );
	}
	Sleep( 0.0 );
	Goto( 'Moving' );
}

state Ambush
{
	ignores SeePlayer, EnemyNotVisible, Bump, Touch;

	function BeginState()
	{
		SetTimer( CheckAmbushFrequency, true );
	}

	function Timer( optional int TimerNum )
	{
		local Pawn P;

		if( Enemy != None && bWaitForEnemyMove )
		{
			if( ( Enemy.Location == LastEnemyLocation ) || VSize( Enemy.Location - LastEnemyLocation ) < 48 )
			{
				return;
			}
			else
				bWaitForEnemyMove = false;
		}

		for( P = Level.PawnList; P != None; P = P.NextPawn )
		{
			if( P.IsA( 'PlayerPawn' ) )
			{
				Enemy = P;
		
				SetCollision( Default.bCollideActors, Default.bBlockActors, Default.bBlockPlayers );

				if( VSize( P.Location - Location ) < 1024 )
				{
					bBurrowAmbush = false;
					GotoState( 'Ambush', 'Rise' );
					SetTimer( 0.0, false );
				}
				SetCollision( false, false, false );
			}
		}
	}

Burrow:
	PlayAllAnim( 'BurrowDn',, 0.12, false );
	FinishAnim( 0 );
	PlayAllAnim( 'BurrowIdle',, 0.1, true );
	bHidden = true;
	Goto( 'Begin' );

Rise:
	TurnToward( Enemy );
	bHidden = false;
	PlayAllAnim( 'BurrowUp',, 0.1, false );
	FinishAnim( 0 );
	PlayAllAnim( 'IdleA',, 0.12, true );
	GotoState( 'Attacking' );

Begin:
	PlayAllAnim( 'BurrowIdle',, 0.1, true );
	bHidden = true;
}
				
auto state Startup
{
	function Bump( actor Other )
	{
		if( Other.IsA( 'PlayerPawn' ) && Other != None )
		{
			Enemy = Other;
			GotoState( 'Attacking' );
		}
	}

	function BeginState()
	{
		Enable( 'SeePlayer' );
	}

	function SeePlayer( actor Seen )
	{
		Enemy = Seen;
		GotoState( 'Attacking' );
	}

	function Timer( optional int TimerNum )
	{
	}

	function AnimEnd()
	{
		if( GetSequence( 0 ) == 'IdleB' )
		{
			PlayAllAnim( 'IdleA',, 0.1, true );
		}
	}

Rise:
	TurnToward( Enemy );
	Mesh = Default.Mesh;
	bHidden = false;
	PlayAllAnim( 'BurrowUp',, 0.1, false );
	FinishAnim( 0 );
	PlayAllAnim( 'IdleA',, 0.12, true );
	GotoState( 'Attacking' );
	
Begin:
	SetPhysics( PHYS_Falling );
	WaitForLanding();
	SetPhysics( PHYS_Walking );
	if( bBurrowAmbush )
		GotoState( 'Ambush' );
WaitLoop:	
	Enable( 'AnimEnd' );
	PlayToWaiting();
	Sleep( 10.0 + Rand( 20 ) );
	Goto( 'WaitLoop' );
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
		if( bCanPlayPain && Physics != PHYS_Falling && ( Health > 0 && Health < ( Default.Health * 0.5 ) ) && GetStateName() != 'TakeHit' )
			GotoState( 'TakeHit' );
	}
}

function PlayTempPain( optional float TweenTime )
{
	local int RandChoice;

	RandChoice = Rand( 3 );

	Switch( RandChoice )
	{
		Case 0: 
			PlayAllAnim( 'PainA',, 0.1, false );
			break;
		Case 1:
			PlayAllAnim( 'PainB',, 0.1, false );
			break;
		Case 2:
			PlayAllAnim( 'PainC',, 0.1, false );
			break;
	}
}

function NSpawnDirtDN()
{
	SpawnMound();
	//if( CurrentMaterial == 'Dirt' )
	//	Spawn( class'dnCharacterFX_BurrowDN_Dirt',,, Location + vect( 0, 0, -16 ) );
	//else
	//	Spawn( class'dnCharacterFX_BurrowDN_Rocks',,, Location + vect( 0, 0, -16 ) );
	Spawn( CurrentMaterial.Default.BurrowParticlesDown,,, Location + vect( 0, 0, -32 ) );

	//Spawn( class'dnParticles.dnCharacterFX_BurrowSpawnDN',,, Location + vect( 0, 0, -32 ) );

}

function NSnatchCollisionOff()
{
	SetCollision( false, false, false );
}
		 
function NSnatchCollisionOn()
{
	SetCollision( Default.bCollideActors, Default.bBlockActors, Default.bBlockPlayers );
}

function NSpawnDirtUP()
{
	SpawnMound();
	//Spawn( class'dnParticles.dnCharacterFX_BurrowSpawnUP',,, Location + vect( 0, 0, -16 ) );
//	if( CurrentMaterial == 'Dirt' )
//		Spawn( class'dnCharacterFX_BurrowUP_Dirt',,, Location + vect( 0, 0, -16 ) );
//	else
//		Spawn( class'dnCharacterFX_BurrowUP_Rocks',,, Location + vect( 0, 0, -16 ) );


	Spawn( CurrentMaterial.Default.BurrowParticlesUp,,, Location + vect( 0, 0, -32 ) );

	PlaySound( sound'RockBrk03', SLOT_None, SoundDampening * 0.99 );
}

function PainTimer()
{
	bCanPlayPain = true;
}

function SetPainDisabled()
{
	bCanPlayPain = false;

	SetCallbackTimer( 2.0, false, 'PainTimer' );
}

state TakeHit 
{
Burrow:
	PlayAllAnim( 'BurrowDn',, 0.12, false );
	FinishAnim( 0 );
	PlayAllAnim( 'BurrowIdle',, 0.1, true );
	bHidden = true;
	Sleep( 5.0 );
	TurnToward( Enemy );
	bHidden = false;
	PlayAllAnim( 'BurrowUp',, 0.12, false );
	FinishAnim( 0 );
	PlayAllAnim( 'IdleA',, 0.12, false );
	Sleep( 0.12 );
	GotoState( 'Attacking' );

Begin:
	StopMoving();
	PlayTempPain( 0.12 );
	FinishAnim( 0 );
	PlayAllAnim( 'IdleA',, 0.1, true );
	SetPainDisabled();
	if( CanBurrowMove() && FRand() < 0.5 )
		GotoState( 'BurrowMove' );
	else
		GotoState( 'Attacking' );
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;

	carc = Spawn( CarcassType );
	if( carc == None )
		return None;
	carc.Initfor( self );
	carc.MeshDecalLink = MeshDecalLink;
	return carc;
}

function PlayDying( class<DamageType> DamageType, vector HitLocation)
{
	local int RandChoice;

	TempDam = DamageType;
	TempHitLocation = HitLocation;

	RandChoice = Rand( 3 );
	
//	RandChoice = 0;
	Switch( RandChoice )
	{
		Case 0:
//			PlayAllAnim( 'DeathA',, 0.1, false );
			PlayAllAnim( 'DeathB',, 0.1, false );
			break;
		Case 1:
			PlayAllAnim( 'DeathB',, 0.1, false );
			break;
		Case 2:
			PlayAllAnim( 'DeathC',, 0.1, false );
			break;
	}
}
function Died( Pawn Killer, class<DamageType> DamageType, vector HitLocation, optional Vector Momentum )
{
	local pawn OtherPawn;
	local actor A;
	local EPawnBodyPart BodyPart;

	TempMomentum = Momentum;

	if ( bDeleteMe )
		return; // Already destroyed...

	// No DOT.
	WipeDOTList();

	// Set our health to zero...unless we're already negative...
	Health = Min(0, Health);

	// Send a killed notification!
	for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
		OtherPawn.Killed( Killer, Self, DamageType );

	// Notify the game that a player was killed
	Level.Game.Killed( Killer, Self, DamageType );

	// Drop anything we might be carrying.
	if ( CarriedDecoration != None )
	{
		DropDecoration(,true);
		CarriedDecoration = None; 
	}

	// Trigger any death events.
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Killer );

	// Play the dying animation and effects...
	PlayDying( DamageType, HitLocation );

	// If the game is over, that's it.
	if ( Level.Game.bGameEnded )
	{
		Weapon = None;
		Level.Game.DiscardInventory(Self);
		HidePlayer();
		return;
	}

	// Otherwise, notify the client.
	if ( RemoteRole == ROLE_AutonomousProxy )
	{
		ClientDying( DamageType, HitLocation );
	}

	// Move us to the dead state.
	//SetControlState( CS_Dead );

	if( GetSequence( 0 ) == 'DeathA' ) 
	{
		GotoState( 'Dying' );
		return;
	}
	SetControlState( CS_Dead );
	// Destroy us if we should be gibbed.
	if ( ShouldBeGibbed( TempDam ) )
		SpawnGibbedCarcass( TempDam, TempHitLocation, TempMomentum );
	else
		SpawnCarcass( TempDam, TempHitLocation, TempMomentum );

	// Remove effects actors.
	RemoveEffects();

	// Remove our weapon reference.
	Weapon = None;

	// Destroy the inventory;
	Level.Game.DiscardInventory(Self);

	Destroy();
}

state Dying
{
Begin:
	FinishAnim( 0 );
	// Destroy us if we should be gibbed.
	SpawnCarcass( TempDam, TempHitLocation, TempMomentum );

	// Remove effects actors.
	RemoveEffects();

	// Remove our weapon reference.
	Weapon = None;

	// Destroy the inventory;
	Level.Game.DiscardInventory(Self);

	Destroy();
}

function PlayTestAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping, optional bool bInterrupt )
{
	GetMeshInstance();
	if (MeshInstance==None)
		return;

	if ((MeshInstance.MeshChannels[0].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(0) && !bInterrupt)))
	{
		return; // already playing
	}
	
	if (Rate == 0.0) 
		Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime);
	else
		PlayAnim(Sequence, Rate, TweenTime);
}

function PlayToWaiting( optional float TweenTime )
{
	local int RandChoice;

	if( TweenTime == 0 )
		TweenTime = 0.1;

	RandChoice = Rand( 2 );

	if( RandChoice == 0 )
		PlayAllAnim( 'IdleA',, TweenTime, true );
	else
		PlayAllAnim( 'IdleB',, TweenTime,	false );
}

event MayFall()
{
	bCanJump = true;
}


DefaultProperties
{
     Health=115
     Mesh=dukemesh'c_characters.alien_AdultSnatcher'
     DrawType=DT_Mesh
     GroundSpeed=495
     PathingCollisionHeight=39
     PathingCollisionRadius=17
     bModifyCollisionToPath=true
	 CollisionHeight=+00020.000000
     CollisionRadius=+00022.000000
	 //CollisionHeight=39
	 //CollisionRadius=17
	 CarcassType=class'SnatcherAdultCarcass'
     AmbushRadius=256.000000
     CheckAmbushFrequency=0.500000
	 MaxStepHeight=30
	 bIsPlayer=true
	 jumpz=-1.0
	 //bCanJump=true
	 bCanJump=false
	 //SpecialHeight=20
     bFlammable=true
	 ImmolationClass="dngame.dnPawnImmolation_SnatcherAdult"
	 //MinHitWall=400
	 BaseEyeheight=20
}
