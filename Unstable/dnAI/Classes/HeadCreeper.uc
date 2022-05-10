class HeadCreeper extends BonedCreature;

/*================================================================
	Sequences:
	
	DeathA
	Expand
	IdleA
	JumpAir
	JumpLand
	JumpSlashAir
	JumpStart
	PainA
	PainB
	SlashA
	TurnL45
	TurnR45
	Walk
================================================================*/

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

var CreaturePawnCarcass InfectedCarcass;
var dnDecoration MyHead;
var float WanderRadius;
var bool bDodgeUp, bDodgeLeft;

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc == None )
		return None;
	carc.Initfor(self);

	carc.MeshDecalLink = MeshDecalLink;
	Carc.SetCollision( false, false, false );
	MyHead.SetOwner( Carc );
	MyHead.AttachActorToParent( Carc, true, true );
	MyHead.MountMeshItem = 'Mount1';
	MyHead.MountType = MOUNT_MeshSurface;
	MyHead.SetPhysics( PHYS_MovingBrush );
//	MyHead.AttachActorToParent( none, true, true );
//	MyHead.MountParent = None;
//	MyHead.SetPhysics( PHYS_Falling );
	return carc;
}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	if( Killer != None && Killer.IsA( 'PlayerPawn' ) )
	{
		PlayerPawn( Killer ).AddEgo( EgoKillValue );
	}
	Super.Died( Killer, DamageType, HitLocation, Momentum );
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local rotator Dir;
	local sound PainSound;

	if( ClassIsChildOf( DamageType, class'PoisonDamage' ) )
		return;

	SetPhysics( PHYS_Falling );
	Momentum *= 0.1;
	AddVelocity( Momentum );
	Velocity.Z = 16;

	Enemy = instigatedBy;
	Super.TakeDamage( Damage, instigatedBy, HitLocation, Momentum, DamageType );
	if( Health > 0 )
		GotoState( 'TakeHit' );
}

state TakeHit
{
Begin:
	StopMoving();
	if( FRand() < 0.5 )
		PlayAllAnim( 'PainA',, 0.1, false );
	else
		PlayAllAnim( 'PainB',, 0.1, false );

	FinishAnim( 0 );
	GotoState( 'Roaming' );
}

function PlayDying( class<DamageType> DamageType, vector HitLocation)
{
	CreeperHead( MyHead ).LoopAnim( 'None',,, 5 );
	CreeperHead( MyHead ).LoopAnim( 'None',,, 0 );
	PlayAllAnim( 'DeathA',, 0.1, false );
}

function ShakeRandomBone()
{
	local int RandChoice;
	local name RandomDamageBone;

	if( !InfectedCarcass.bHeadBlownOff && InfectedCarcass != None )
	{
		InfectedCarcass.SetDamageBone( 'Head' );
	}
}

auto state Startup
{
	function ShakeHead()
	{
		if( InfectedCarcass != None )
		{
			InfectedCarcass.DamageBoneShakeFactor = 2.0;
			ShakeRandomBone();
		}
	}

	function EndState()
	{
		EndCallbackTimer( 'ShakeRandomBone' );
	}
	
	function bool CanGrow()
	{
		if( InfectedCarcass.bHeadBlownOff )
			return false;

		return true;
	}

Begin:
//	SetTimer( 0.2, true );
	bHidden = true;
	Sleep( 2.0 );
	SetPhysics( PHYS_Falling );
	WaitForLanding();
WaitLoop:
	Sleep( 5 );
	if( !CanGrow() )
		Destroy();

	if( InfectedCarcass != None )
	{	
		if( InfectedCarcass.bSuffering )
			Goto( 'WaitLoop' );
	}
	SetCallbackTimer( 0.5, true, 'ShakeHead' );
	Sleep( 1.5 );
	Timer();
	bHidden = false;
	
	if( SetLocation( GetHeadLocation() ) )
		log( "SetLocation success" );
	else
		log( "SetLocation failure" );

	PlayAllAnim( 'Expand',, 0.1, false );
	FinishAnim( 0 );
	PlayToWaiting();
    GotoState( 'Roaming' );
}

function vector GetHeadLocation()
{
	local int bone;
	local MeshInstance Minst;

	Minst = InfectedCarcass.GetMeshInstance();
	bone = Minst.BoneFindNamed( 'Head' );

	if( bone != 0 )
		return Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) );
	else
		Destroy();
}

function SpawnHead()
{
	local vector HeadLocation;
	local rotator HeadRotation;
	local int bone;
	local MeshInstance Minst;

	MyHead = Spawn( class'CreeperHead', self );

//	MyHead.LoopAnim( 'A_HeadCreepIdleA', 1.0, 0.12,, 0 );
	MyHead.Mesh = InfectedCarcass.Mesh;
	if( InfectedCarcass.MultiSkins[ 0 ] != None )
		MyHead.MultiSkins[ 0 ] = InfectedCarcass.MultiSkins[ 0 ];
	MyHead.Texture = InfectedCarcass.Texture;

//	MyHead = CPC.GetMeshInstance();
	
	Minst = InfectedCarcass.GetMeshInstance();

	MyHead.AttachActorToParent( self, true, true );
	
	MyHead.MountType = MOUNT_MeshSurface;
	MyHead.MountMeshItem = 'Mount1';
	MyHead.SetPhysics( PHYS_MovingBrush );
	
	SetCollision( true, true, true );
	//MyHead.MountOrigin = vect( -7, 0, -40 );
}

function Timer( optional int TimerNum )
{
	local MeshInstance Minst;
	local int bone;
	local vector HeadLocation;
	local rotator HeadRotation;
	local vector TempHeadLocation;

	if( InfectedCarcass != None )
	{
	//	HeadLocation = Minst.BoneGetTranslate( bone, true, false );
	//	HeadRotation = Minst.BoneGetRotate( bone, true, false );
	//	bHidden = false;
	//	SetLocation( Minst.MeshToWorldLocation( HeadLocation ) );
	//	SetRotation( Minst.MeshToWorldRotation( HeadRotation ) );
		InfectedCarcass.bHeadBlownOff = true;
		TempHeadLocation = GetHeadLocation();
		Spawn( class'dnBloodFX_BloodHaze',,, GetHeadLocation() );
		Spawn( class'dnBloodFX_BloodHazeEKG',,, GetHeadLocation() );
		Spawn( class'dnBloodFX_BloodHaze',,, GetHeadLocation() );

		InfectedCarcass.SetDamageBone('Head');
		InfectedCarcass.ChunkUpMore();
		SpawnHead();
	}
	else
		SpawnHead();
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
		Enemy = SeenPlayer;
		GotoState( 'ApproachingEnemy' );
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
	SetPhysics( PHYS_Walking );
	
Moving:
	Enable('Bump');
	PlayToWalking();
	AmbientSound = sound'SnatcherRoamLp02';
	TurnTo( Destination );
	PlayToWalking();
	MoveTo(Destination, WalkingSpeed );
	AmbientSound = None;
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
	if( FRand() < 0.25 )
	{
		StopMoving();
		PlayToWaiting();
		Acceleration = vect( 0,0,0 );
		Sleep(2 + 1 * FRand());
	}
	Goto('Wander');
ContinueWander:
	FinishAnim( 0 );
	PlayToWalking();
	Goto('Wander');

Turn:
	Acceleration = vect( 0,0,0 );
//	SetTurn();
	TurnTo( Destination );
	Goto( 'Pausing');
}

function PlayToWalking()
{
	PlayAllAnim( 'Walk',, 0.12, true );
}

function PlayToWaiting( optional float TweenTime )
{
	PlayAllAnim( 'IdleA',, 0.12, true );
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
	
	GotoState( 'ApproachingEnemy', 'Dodging' );
}

state ApproachingEnemy
{

	function Landed( vector HitNormal )
	{
		GotoState( 'ApproachingEnemy', 'Landed' );
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

	function vector GetStrafeDestination( optional bool bLeft, optional bool bUp )
	{
		local vector X, Y, Z;
		local vector TempDest;

		GetAxes( Rotation, X, Y, Z );

		if( !bLeft )
		{
			PlayAllAnim( 'TurnL45',, 0.12, true );
			TempDest = Location + Y * 72;
		}
			//return Location + Y * Rand( 15 + 64 ) + X * -32;
			//return Location + Y * 96;
		else
		{
			PlayAllAnim( 'TurnR45',, 0.12, true );
			//return Location + Y * -96;
			TempDest = Location + Y * -72;
		}


		return TempDest;
//		else return Location + Y * -Rand( 15 + 64 ) + X * -32;
	}


	function BeginState()
	{
		//log( "---- Approaching enemy state entered" );
		HeadTrackingActor = None;
	}

	function Bump( actor Other )
	{
		if( Other.IsA( 'dnDecoration' ) && !Other.IsA( 'InputDecoration' ) && !Other.IsA( 'ControllableTurret' ) )
		{
			dnDecoration( Other ).Topple( self, Other.Location, vector( Rotation ) * 27550 + vect( 0, 0, 1350 ), 20 );
		}
		else
		if( Other == Enemy )
		{
			if( Physics == PHYS_Falling )
			{
				if( Other == Enemy && (!Enemy.bIsRenderActor || !Pawn(Enemy).bSnatched) )
				{
				}
			}
		}
		else
			Super.Bump( Other );
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
			if( VSize( Enemy.Location - Location ) <= 164 && AnimSequence != 'JumpSlashAir' )
			{
				PlayAllANim( 'JumpSlashAir',, 0.1, false );
			}
		}
//		if( Velocity.Z < 0 )
//		{
//			Velocity.Z *= 0.95;
//		}
		Super.Tick( DeltaTime );
	}

Landed:
	StopMoving();
	PlayAllAnim( 'JumpLand',, 0.1, false );
	FinishAnim( 0 );
	PlayToWaiting();
	Sleep( FRand() );
	Goto( 'Moving' );

Dodging:
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
	
	StrafeTo( Destination, Focus, 2.0 );
	Goto( 'Moving' );

Begin:
	Destination = Enemy.Location;
	HeadTrackingActor = None;
Moving:
	if( Enemy == None || (Enemy.bIsRenderActor && (RenderActor(Enemy).Health <= 0)) )
	{
		GotoState( 'Idling' );
	}
	else if( VSize( Enemy.Location - Location ) > AIMeleeRange && !CanDirectlyReach( Enemy ) )
	{
		if( !FindBestPathToward( Enemy, true ) )
		{
			PlayToWaiting();
			Sleep( 1.0 );
			GotoState( 'ApproachingEnemy' );
//			GotoState( 'WaitingForEnemy' );
		}
		else
		{
			PlayToWalking();
			MoveTo( Destination, WalkingSpeed);
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
		PlayToWalking();
		Destination = Location - 64 * Normal( Location - Enemy.Location );
		MoveTo( Destination, WalkingSpeed );
		if( VSize( Enemy.Location - Location ) > 275 && FRand() < 0.25 )
		{
//			if( bPreferClawAttack )
//				ToggleClawAttack();
//			GotoState( 'Charging' );
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


	//GotoState( 'MeleeCombat' );

AdjustFromWall:
	//Enable('AnimEnd');
//	TurnTo( Destination );
//	StrafeTo(Destination, Focus, GetRunSpeed() ); 
//	Destination = Focus; 
	Goto('Begin');
FollowReached:
//	if( !bPreferClawAttack && VSize( Location - Enemy.Location ) > 120 )
//		GotoState( 'Charging' );
//	else
//		GotoState( 'ClawAttack' );
	if( NeedToTurn( Enemy.Location ) )
	{
		RotationRate.Yaw = 55000;
		PlayTurn( Enemy.Location );
		TurnToward( Enemy );
		//FinishAnim( 0 );
		RotationRate.Yaw = Default.RotationRate.Yaw;
	}
	PlayAllAnim( 'JumpStart',, 0.1, false );
	FinishAnim( 0 );
	SetPhysics( PHYS_Falling );
	Velocity = Vector( rotator( Enemy.Location - Location ) ) * ( VSize( Enemy.Location - Location ) * 2.15 );//* 750;
	Acceleration = vector( Rotation ) * 25;
	Velocity.Z += 256;
	PlayAllAnim( 'JumpAir',, 0.1, true );

}

	function PlayTurnLeft()
	{
		PlayAllAnim( 'TurnL45', 0.4, 0.1, true );
	}

	function PlayTurnRight()
	{
		PlayAllAnim( 'TurnR45', 0.4, 0.1, true );
	}

	function PlayTurn( vector TurnLocation )
	{
		local vector LookDir, OffDir;

		LookDir = vector( Rotation );
	
		OffDir = Normal( LookDir cross vect( 0, 0, 1 ) );

		if( ( OffDir dot( Location - Enemy.Location ) ) > 0 )
			PlayTurnRight();

		else
			PlayTurnLeft();
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

function TentacleSwipeDown()
{
	MeleeDamageTarget( 2 + Rand( 5 ), vector( Rotation ) * 150 );
}

function TentacleSwipeLeft()
{
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
		Enemy.TakeDamage(2 + Rand( 3 ), Self,HitLocation, pushdir, class'WhippedDownDamage' );
		//if( Enemy.IsA( 'DukePlayer' ) )
		//{
		//	PlayerEnemy = DukePlayer( Enemy );
		//	PlayerEnemy.HitEffect( HitLocation, class'WhippedDownDamage', vect(0,0,0), false );
		//}		
		return true;
	}
	return false;
}

DefaultProperties
{
    Mesh=dukemesh'c_characters.HeadCreeper'
    DrawType=DT_Mesh
    bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false

    WalkingSpeed=0.21
    GroundSpeed=350
    CollisionRadius=24.000000
    CollisionHeight=14.0000000
	Health=20
	CarcassType=class'SnatcherCarcass'
	AIMeleeRange=212
    PathingCollisionHeight=39
    PathingCollisionRadius=17
    bModifyCollisionToPath=true
    EgoKillValue=5
}
