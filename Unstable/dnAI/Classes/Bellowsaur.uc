class Bellowsaur extends BonedCreature;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

/*================================================================
	Sequences:
		
	BiteA
	BiteB
	DeathA
	DeathB
	DeathC
	IdleA
	IdleB
	IdleC
	PainA
	PainB
	PainC
	Run
	ScreamIdle
	ScreamStart
	ScreamStop
	ScreamTurnL30
	ScreamTurnR30
	TailSlashA
	TurnL45
	TurnR45
	Walk
===============================================================*/

var bool bIsTurning;
var bool bTailSmack;

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if ( ClassIsChildOf(DamageType, class'CrushingDamage') )
		return;
	else
	{
		Super.TakeDamage( Damage, instigatedBy, HitLocation, Momentum, DamageType );
		if( Health > 0 )
		{
			NextState = GetStateName();
			GotoState( 'TakeHit' );
		}
	}
}

state TakeHit
{
	function PlayPainAnim()
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

Begin:
	StopMoving();
	PlayPainAnim();
	FinishAnim( 0 );
	PlayToWaiting();
	GotoState( 'ApproachingEnemy' );
}

function PlayToRunning()
{
	PlayAllAnim( 'Run',, 0.12, true );
}

function PlayToWalking()
{
	PlayAllAnim( 'Walk',, 0.12, true );
}

auto state Startup
{
	function SeePlayer( actor Seen )
	{
		Enemy = Seen;
		GotoState( 'ApproachingEnemy' );
	}


Begin:
	Enable( 'AnimEnd' );
	SetPhysics( PHYS_Falling );
	WaitForLanding();
WaitLoop:	
	PlayToWaiting();
	Sleep( 10.0 + Rand( 20 ) );
	Goto( 'WaitLoop' );
}

function AnimEnd()
{
	if( GetSequence( 0 ) == 'IdleB' || GetSequence( 0 ) == 'IdleC' )
		PlayAllAnim( 'IdleA',, 0.1, true );
}

function PlayToWaiting( optional float TweenTime )
{
	local int RandChoice;

	RandChoice = Rand( 3 );

	Switch( RandChoice )
	{
		Case 0:
			PlayAllAnim( 'IdleA',, 0.1, true );
			break;
		Case 1:
			PlayAllAnim( 'IdleB',, 0.1, false );
			break;
		Case 2:
			PlayAllAnim( 'IdleC',, 0.1, false );
	}
}

state ApproachingEnemy
{
	function Bump( actor Other )
	{
		if( Other.IsA( 'dnDecoration' ) && !Other.IsA( 'InputDecoration' ) && !Other.IsA( 'ControllableTurret' ) )
			dnDecoration( Other ).Topple( self, Other.Location, vector( Rotation ) * 27550 + vect( 0, 0, 1350 ), 20 );
		else if( Other == Enemy )
			GotoState( 'ApproachingEnemy', 'Attacking' );
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
		HeadTrackingActor = None;
	}

	function PlayAttackAnim()
	{
		local int RandChoice;

		RandChoice = Rand( 3 );

		Switch( RandChoice )
		{
			Case 0:
				PlayAllAnim( 'TailSlashA',, 0.1, false );
				break;
			Case 1:
				PlayAllAnim( 'BiteA',, 0.1, false );
				break;
			Case 2:
				PlayAllAnim( 'BiteB',, 0.1, false );
				break;
		}
	}


Attacking:
	StopMoving();
	PlayAttackAnim();
	FinishAnim( 0 );
	PlayToWaiting( 0.12 );
	Goto( 'Begin' );

Begin:
	RotationRate.yaw = 14000;
	if( NeedToTurn( Enemy.Location ) )
	{
		StopMoving();
		PlayTurn( Enemy.Location );
		TurnToward( Enemy );
	}
Moving:
	//GroundSpeed = 115;
	log( "Moving 1" ); 
	RunSpeed: GroundSpeed = 200;
	if( VSize( Enemy.Location - Location ) > 128 && !CanDirectlyReach( Enemy ) )
	{
	log( "Moving 2" );
		if( !FindBestPathToward( Enemy, true ) )
		{
	log( "Moving 3" );
			broadcastmessage( "CANNOT FIND PATH" );
			PlayAllAnim( 'IdleA',, 0.13, true );
			Sleep( 2.0 );
			Goto( 'MOving' );
		}
		else
		{
	log( "Moving 4" );
			broadcastmessage( "FOUND PATH" );
			PlayAllAnim( 'Run', 1.22, 0.12, true );
			//PlayAllAnim( 'Walk', 1.25, 0.12, true );
			MoveTo( Destination, 1.0 ); //Location - 64 * Normal( Location - Destination ), 1.0 );
			if( VSize( Enemy.Location - Location ) <= 172 && CanSee( Enemy ) )
			{
					log( "Moving 5" );
				Goto( 'Attacking' );
			}
			else 
			{
				log( "Moving 6" );
				Goto( 'Moving' );
			}
		}
	}
	else if( CanDirectlyReach( Enemy ) && VSize( Enemy.Location - Location ) > 64 )
	{
		log( "Moving 7" );
		PlayAllAnim( 'Run', 1.22, 0.12, true );
		//PlayAllAnim( 'Walk', 1.25, 0.12, true );
		AmbientSound = sound'SnatcherRoamLp02';
		MoveTo( Location - 64 * Normal( Location - Enemy.Location), 1.0 );
		AmbientSound = None;
	}
	if( VSize( Enemy.Location - Location ) <= 164 && CanSee( Enemy ) )
	{
				log( "Moving 8" );
		Goto( 'Attacking' );
	}
	else
	{
				log( "Moving 9" );
		Goto( 'Moving' );
	}
}

function bool CanDirectlyReach( actor ReachActor )
{
	local vector HitLocation,HitNormal;
	local vector X, Y, Z;
	local vector Loc1, Loc2, Loc3, Loc4;

	local actor HitActor;

	GetAxes( rotator( normal( Enemy.Location - Location ) ), X,Y,Z );

	Loc1 = Location + ( ( 128 ) * Y );
	Loc2 = Location - ( ( 128 ) * Y );
	Loc3 = Location + ( ( 128 ) * Z );
	Loc4 = Location - ( ( 128 ) * Z );
	
	HitActor = Trace( HitLocation, HitNormal, Enemy.Location, Loc1, true );


	HitActor = Trace( HitLocation, HitNormal, Enemy.Location + vect( 0, 0, -19 ), Location + vect( 0, 0, -19 ), true );
	
	if( HitActor.IsA( 'dnDecoration' ) && LineOfSightTo( Enemy ) )
		return true;

	if( HitActor == Enemy && LineOfSightTo( Enemy ) )
		return true;
	
	return false;
}

function PlayTurnLeft()
{
	PlayAllAnim( 'TurnL45', 1.1, 0.13, true );
}

function PlayTurnRight()
{
	PlayAllAnim( 'TurnR45', 1.1, 0.13, true );
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

function PlayDying( class<DamageType> DamageType, vector HitLocation)
{
	local int RandChoice;

	RandChoice = Rand( 3 );
	
	Switch( RandChoice )
	{
		Case 0:
			PlayAllAnim( 'DeathA',, 0.1, false );
			break;
		Case 1:
			PlayAllAnim( 'DeathB',, 0.1, false );
			break;
		Case 2:
			PlayAllAnim( 'DeathC',, 0.1, false );
			break;
	}
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

function BellowBiteNotify()
{
	MeleeDamageTarget( 5 + Rand( 5 ), vector( Rotation ) * 150 );
	DukeHUD( DukePlayer( Enemy ).MyHUD ).RegisterBloodSlash( 5 );
}

function TailSmackNotify()
{
	bTailSmack = true;
	MeleeDamageTarget( 10 + Rand( 5 ), vector( Rotation ) * 150 );
	DukeHUD( DukePlayer( Enemy ).MyHUD ).RegisterBloodSlash( 6 );
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal, TargetPoint;
	local actor HitActor;
	local DukePlayer PlayerEnemy; 	
	local class< DamageType > TempDamage;
	
	// check if still in melee range
	If ( (VSize(Enemy.Location - Location) <= 48 * 1.4 + Enemy.CollisionRadius + CollisionRadius)
		&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || ( Physics == PHYS_Falling ) || (Abs(Location.Z - Enemy.Location.Z) 
			<= FMax(CollisionHeight, Enemy.CollisionHeight) + 0.5 * FMin(CollisionHeight, Enemy.CollisionHeight))) )
	{	
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location, true);
		if ( HitActor != Enemy )
			return false;
		if( bTailSmack )
		{
			TempDamage = class'WhippedRightDamage';
			bTailSmack = false;
		}
		else
		{
			TempDamage = class'WhippedDownDamage';
		}
		Enemy.TakeDamage(2 + Rand( 3 ), Self,HitLocation, pushdir, TempDamage );
		//DukeHUD( DukePlayer( Enemy ).MyHUD ).RegisterBloodSlash(  );

		/*if( Enemy.IsA( 'DukePlayer' ) )
		{
			PlayerEnemy = DukePlayer( Enemy );
			if( FRand() < 0.5 )
				PlayerEnemy.HitEffect( HitLocation, class'WhippedLeftDamage', vect(0,0,0), false );
			else
				PlayerEnemy.HitEffect( HitLocation, class'WhippedRightDamage', vect(0,0,0), false );
		}	*/
		return true;
	}
	return false;
}

DefaultProperties
{
	Mesh=dukemesh'c_characters.alien_bellowsaur'
	DrawType=DT_Mesh
	GroundSpeed=150
	WalkingSpeed=0.21
	RunSpeed=0.7
    CollisionHeight=38.000000
	CollisionRadius=40.000000
    PathingCollisionHeight=39
    PathingCollisionRadius=24
    bModifyCollisionToPath=true
    CarcassType=class'BellowsaurCarcass'
	SpecialHeight=38
	bCanJump=false
	Jumpheight=0
}
