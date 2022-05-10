/*=============================================================================
	AIJetski
	Author: Jess Crable

	Jetski Pawn actor.
=============================================================================*/
class AIJetSki extends AIPawn;

#exec OBJ LOAD FILE=..\Meshes\c_Characters.dmx
#exec OBJ LOAD FILE=..\Meshes\c_vehicles.dmx
#exec OBJ LOAD FILE=..\Sounds\a_transport.dfx

var bool bAlreadySplashed;
var JetSkiPoint MyTarget;
var JetskiDude Dude;
var bool bTrailOn;
var JetSkiTorpedo MyTorpedo;
var bool bReset;
var int ResetCount;
var M16Flash S;
var TurretMounts MyWeaponMount;
var JetSkiPoint MyJetSkiPoints[ 16 ];
var int Counter;
var dnJetski_Trail1 MyTrail;
var dnExplosion1 TempExplosion;
var int CurrentJetskiPoint;
var bool bOscillatingDown;
var vector CarcassVelocity;
var int DestroyTime;
var bool bReverse;
var int JetskiPointCount;
var dnBloodFX_SmokeTrail MySmokeTrail;

enum EJetskiPointCycle
{
	CYCLE_Random,
	CYCLE_Linear,
	CYCLE_Oscillating
};

var() EJetskiPointCycle JetskiPointCycle;

function SetJetskiPointcycle( int CycleNum )
{
	switch ( CycleNum )
	{
		Case 0:
			JetskiPointCycle = CYCLE_Random;
			break;
		Case 1:
			JetskiPointCycle = CYCLE_Linear;
			break;
		Case 2:
			JetskiPointCycle = CYCLE_Oscillating;
			break;
		Default:
			JetskiPointCycle = CYCLE_Random;
			break;
	}
}

function JetskiPoint GetNextJetskiPoint()
{
	switch ( JetskiPointCycle )
	{
		Case CYCLE_Random:
			return GetRandomJetskiPoint();
			break;
		Case CYCLE_Linear:
			return GetNextLinearJetskiPoint();
			break;
		Case CYCLE_Oscillating:
			return GetNextOscillatingJetskiPoint();
			break;
		Default:
			return GetRandomJetskiPoint();
			break;
	}
}

function JetskiPoint GetRandomJetskiPoint()
{
	local int i;

	i = Rand( 1 );
	i = Counter;
	
	if( MyJetSkiPoints[ i ] == None )
	{
		Counter = 0;
		if( GetJetSkiCount() > 0 )
			return GetRandomJetSkiPoint();
	}
	//broadcastmessage( "Returning "$MyJetSkiPoints[ i ] );
	CurrentJetskiPoint = i;
	return MyJetskiPoints[ i ];
}

function JetskiPoint GetNextLinearJetskiPoint()
{
	local int i, x;

	if( GetJetskiCount() > 0 )
	{
		if( MyJetskiPoints[ CurrentJetskiPoint + 1 ] != None )
		{
			CurrentJetskiPoint += 1;
			return MyJetskiPoints[ CurrentJetskiPoint + 1 ];
		}
		else	
		{
			CurrentJetskiPoint = 0;
			return MyJetskiPoints[ 0 ];
		}
	}
}

function JetskiPoint GetNextOscillatingJetskiPoint()
{
	local int i, x;

	if( GetJetskiCount() > 0 )
	{
		if( bOscillatingDown )
		{
			if( ( CurrentJetskiPoint - 1 ) > 0 )
			{
				if( MyJetskiPoints[ CurrentJetskiPoint - 1 ] != None )
				{
					CurrentJetskiPoint -= 1;
					return MyJetskiPoints[ CurrentJetskiPoint - 1 ];
				}
				else
				{
					CurrentJetskiPoint = 0;
					bOscillatingDown = false;
					return MyJetskiPoints[ 0 ];
				}
			}
		}
		else
		{
			if( ( CurrentJetskiPoint + 1 ) <= 15 )
			{
				if( MyJetskiPoints[ CurrentJetskiPoint + 1 ] != None )
				{
					CurrentJetskiPoint += 1;
					return MyJetskiPoints[ CurrentJetskiPoint + 1 ];
				}
				else
				{
					CurrentJetskiPoint = 14;
					bOscillatingDown = true;
					return MyJetskiPoints[ 14 ];
				}
			}
		}
	}
}


function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	Health -= Damage;

	if( Health <= 0 && instigatedBy.IsA( 'PlayerPawn' ) )
	{
		if( EgoKillValue > 0 )
			PlayerPawn( Instigator ).AddEgo( EgoKillValue );
		else
			PlayerPawn( Instigator ).SubtractEgo( EgoKillValue );
	}
	if( Health <= 0 && Dude.GetStateName() != 'Dying' )
	{
		/*if( Region.Zone.bWaterZone )
			Spawn( class'WaterTracer', self,, Location + vect( 0, 0, -64 )  );
		else
		{
		log( "Spawning Explosion" );

		TempExplosion =	Spawn( class'dnExplosion1', self,, Location );
		TempExplosion.VisibilityRadius=8000;
		}*/
		WaterLocation();
	}
		Dude.GotoState( 'Dying' );
//	}
}

function bool WaterLocation()
{
	local vector WaterPoint;

	WaterPoint = TraceWaterPoint( Location, Location + vect( 0, 0, 400 ) );
	//if( Region.Zone.bWaterZone )
	//Spawn( class'WaterTracer',,, Location + vect( 0, 0, 64 )  );
	Spawn( class'dnExplosion1',,, WaterPoint + vect( 0, 0, 22 ) );
	return true;
}

// dnExplosion2_Spawner1
function PostBeginPlay()
{

	MyWeaponMount = Spawn( class'TurretMountM16', self,,, Rotation );
	MyWeaponMount.bHidden = true;
	MyWeaponMount.AttachActorToParent( self, true, true );
	MyWeaponMount.MountMeshItem = 'Mount2';
	MyWeaponMount.MountType = MOUNT_MeshSurface;
	MyWeaponMount.SetPhysics( PHYS_MovingBrush );
	MyWeaponMount.MountAngles = rot( 16000, 0, 0 );
	MyWeaponMount.MountOrigin = vect( 0, -3, 5 );
//	log( "Calling setup jetski points" );
//	SetupJetskiPoints();
}

function SetupJetskiPoints()
{
	local int i;
	local JetskiPoint JSP;

	foreach allactors( class'JetskiPoint', JSP  )
	{
		if( JSP.Tag == Tag )
		{
			MyJetSkiPoints[ i ] = JSP;
			JetskiPointCount = i;
			i++;
		}
	}
}		

function JetskiPoint FindRandomJetskiPoint()
{
	local int i;

	i = Rand( GetJetskiCount() );


	if( MyJetskiPoints[ i ] != None && MyJetskiPoints[ i ] != MyTarget )
		return MyJetskiPoints[ i ];
}

function int GetJetskiCount()
{
	local int i;
	local int j;

	for( i = 0; i <= 15; i++ )
	{
		if( MyJetskiPoints[ i ] != None )
		{
			j++;	
		}
		else
		{
			return j;
		}
	}
}

function MuzzleFlash()
{
	local M16Flash S;

	S = Spawn( class'M16Flash', self );
	S.MountType = MOUNT_MeshSurface;
	S.MountMeshItem = 'Mount2';
	S.AttachActorToParent( Self, true, true );
	S.SetPhysics( PHYS_MovingBrush );
	S.MountAngles = rot( 16000, 0, 0 );
	S.MountOrigin = vect( 0, -3, 5 );
}

function Tick( float DeltaTime )
{
	
	if( Dude != None  )
	{
		Dude.AttachActorToParent( self, true, true );
		Dude.MountOrigin.Z = 32;
		Dude.MountType = MOUNT_MeshSurface;
		Dude.SetPhysics( PHYS_MovingBrush );
		Dude.MountMeshItem='Mount1';
		//Dude.SetCollision( false, false, false );
		ResetCount++;
		//broadcastmessage( "RESETCOUNT: "$ResetCount );
		//if( ResetCount >= 300 )
		//	bReset = true;
	}
	Super.Tick( DeltaTime );
}

//auto
state Testing
{
	function BeginState()
	{
	}
Begin:
SetPhysics( PHYS_Falling );
WaitForLanding();

Firing:
MyWeaponMount.TraceFire( Self );
MuzzleFlash();
Sleep( 0.2 );
Goto( 'Firing' );

}

state Crashing
{
	function BeginState()
	{
		broadcastmessage( "SPAWNING SMOKE" );
		//log( "--- Crashing state entered" );
	}

	function Bump( actor Other )
	{
		if( Other.IsA( 'LevelInfo' ) )
			Destroy();
	}

	function HitWall( vector HitNormal, actor HitWall )
	{
		Destroy();
	}

	function TriggerDeathEvent()
	{
		local actor A;

		// Trigger any death events.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( Self, Self );
	}

Begin:
	PlayAnim( 'Into_HighJump' );
//	if( FRand() < 0.5 )
//	{
/*		if( Region.Zone.bWaterZone )
			Spawn( class'WaterTracer', self,, Location + vect( 0, 0, -64 )  );
		else
		{
		log( "Spawning Explosion" );

		TempExplosion =	Spawn( class'dnExplosion1', self,, Location );
		TempExplosion.VisibilityRadius=8000;
		}*/
	WaterLocation();
//	}
	Sleep( 0.1 );
	TriggerDeathEvent();
	JetskiFactory( Owner ).SetPathUnoccupied( MyJetskiPoints[ CurrentJetskiPoint ].Tag );
	SpawnCarcass();
	Destroy();
//	GotoState( 'Dead' );
}


function Trigger( actor Other, Pawn EventInstigator )
{
	Dude.Destroy();
	Destroy();
}

state Dead
{
	ignores SeePlayer, TakeDamage, Bump, Touch, Trigger;

Begin:
//	StopMoving();
/*	if( FRand() < 0.33 )
	{
		if( Region.Zone.bWaterZone )
			Spawn( class'WaterTracer', self,, Location + vect( 0, 0, -64 )  );
		else
		{
		log( "Spawning Explosion" );

		TempExplosion =	Spawn( class'dnExplosion1', self,, Location );
		TempExplosion.VisibilityRadius=8000;
		}
			//}
	}*/
	WaterLocation();
	WaterSpeed = 0;
	bRotateToDesired = true;
	RotationRate.Roll = 32000;
	Destroy();
}

function CreateTorpedo()
{
	MyTorpedo = spawn( class'JetSkiTorpedo', self );
	MyTorpedo.AttachActorToParent( self, true, true );
	MyTorpedo.MountType = MOUNT_MeshSurface;
	MyTorpedo.MountMeshItem = 'Mount2';
	MyTorpedo.MountAngles = rot( 16000, 0, 0 );
	MyTorpedo.MountOrigin = vect( -18, 0, -8 );
}

auto state Startup
{
	function Bump( actor Other )
	{
		if( Other.IsA( 'AIJetskiCarcass' ) )
		{
			TakeDamage( 30, self, Location, vect( 0, 0, 0 ), class'CrushingDamage' );
		}
	}

	function BeginState()
	{
		PlaySound( sound'a_transport.JetskiRevUp06', SLOT_Misc, SoundDampening * 0.85 );
		SetTimer( GetSoundDuration( sound'a_transport.JetskiRevUp06' ), false, 10 );
		CreateTorpedo();
		//RotationRate.Yaw = 15000;
		Dude = Spawn( class'JetSkiDude', self );
		Dude.AttachActorToParent( self, true, true );
		Dude.MountOrigin.Z = 32;
		Dude.MountType = MOUNT_MeshSurface;
		Dude.SetPhysics( PHYS_MovingBrush );
		Dude.MountMeshItem='Mount1';
		LoopAnim( 'Roll_Forward' );
		//Dude.SetCollision( false, false, false );
//		Disable( 'Tick' );
	//	Dude.LoopAnim( 'Ride_Idle' );
		Prepivot.Z += 30;
	}

	function Tick( float DeltaTime )
	{
		if( Velocity.X > 50 && AnimSequence != 'TurnRight_Idle' )
		{
			Dude.LoopAnim( 'TurnRight_Idle' );
			LoopAnim( 'TurnRight_Idle' );
		}
		else if( Velocity.X < -50 && AnimSequence != 'TurnLeft_Idle' )
		{
			Dude.LoopAnim( 'TurnLeft_Idle' );
			LoopAnim( 'TurnLeft_Idle' );
		}
		else
		{
			LoopAnim( 'None' );
			Dude.LoopAnim( 'Ride_Idle' );
		}

		if( Region.Zone.bWaterZone )
		{
			if( Buoyancy < 160 )
				Buoyancy += 5;
			else
			{
			
			}
		}
		Super.Tick( DeltaTime );
	}

	function ZoneChange( ZoneInfo NewZone )
	{
		local JetSkiPoint P;

		if( !bAlreadySplashed && NewZone.bWaterZone )
		{
			bAlreadySplashed = true;
			SetCollision( true, true, true );
			bCanStrafe = true;
			AmbientSound = Sound'a_transport.JetSkiRunLp04';
			GotoState( 'Startup', 'Bobup' );
		}

		if( NewZone.bWaterZone )
		{
			Enable( 'Tick' );
			if( Velocity.Z < -450 )
			{
				if( FRand() < 0.5 )
					PlaySound( sound'a_Transport.JetskiSplash1', SLOT_None,,, SoundDampening * 0.95 );
				else
					PlaySound( sound'a_Transport.JetskiSplash2', SLOT_None,,, SoundDampening * 0.95 );
				Spawn( class'dnJetski_Splash1' );
			}
			SetPhysics( PHYS_Swimming );
			if( !bTrailOn )
			{
				MyTrail = Spawn( class'dnJetski_Trail1', self );
				MyTrail.AttachActorToParent( self, true, true );
				MyTrail.MountMeshItem = 'Mount2';
				MyTrail.MountType = MOUNT_MeshSurface;
				MyTrail.SetPhysics( PHYS_MovingBrush );
				MyTrail.MountAngles = rot( 16000, 0, 0 );
				MyTrail.MountOrigin = vect( 0, 0, -5 );
				MyTrail.Trigger( self, self );
				bTrailOn = true;
			}
		}
	}

	function Actor GetEnemy()
	{
		local Mover M;

		foreach allactors( class'Mover', M )
			return M;
	}

	
	function PlayerPawn GetPlayer()
	{
		local PlayerPawn P;

		foreach allactors( class'PlayerPawn', P )
		{
			return P;
		}
	}

	function bool ShouldFire()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal;

		HitActor = Trace( HitLocation, HitNormal, Location + vect( 0, 0, 30 ) + vector( Rotation ) * 8000, Location + vect( 0, 0, 16 ), true );
	//	broadcastmessage( "HITACTOR: "$HitActor );
		if( HitActor != None && !HitActor.IsA( 'LevelInfo' ) && !HitActor.IsA( 'JetSkiDude' ) && !HitActor.IsA( 'AIJetSki' ) )
		{
			return true;
		}
	}

	function Timer( optional int TimerNum )
	{
		if( ShouldFire() )
		{
			MyWeaponMount.TraceFire( Self );
			MuzzleFlash();
			//broadcastmessage( "DAMAGING ENEMY: "$Enemy );
			Enemy.TakeDamage( 90, self, Enemy.Location, vect( 0, 0, 0 ), class'BulletDamage' );
		}
	}

	function vector GetFocusLocation()
	{
		local ProtonMonitorPoint P;

		foreach allactors( class'ProtonMonitorPoint', P )
			return P.location;
	}

BobUp:
//	MoveSmooth( Location + vect( 0, 0, 64 ) );
//	Sleep( 30.0 );
	MyTarget = FindRandomJetskiPoint();
	//Enemy = GetEnemy();
	Counter += 1;
	//bRotateToEnemy = true;
	if( MyTarget != None )
	{
//		broadcastmessage( "MYTARGET: "$MyTarget );
	//	bRotateToDesired = false;
		DesiredRotation = rotator( Enemy.Location - Location );
		DesiredLocation = MyTarget.Location;

		if( DesiredLocation.Y > Location.Y )
		{
			bReverse = true;
			//broadcastmessage( "GOING TO "$MyTarget$" BACKING UP" );
		}
		else
		{
			bReverse = false;
			//broadcastmessage( "GOInG TO "$MyTarget$" Forward" );
		}
	/*	if( Destination.X > Location.X )
		{
			PlayAnim( 'TurnRight' );
			Dude.PlayAnim( 'TurnRight' );
			FinishAnim();
			Dude.LoopAnim( 'TurnRight_Idle' );
			LoopAnim( 'TurnRight_Idle' );
			//broadcastmessage( "RIGHT: "$GetSequence( 0 )$" Dude: "$Dude.AnimSequence );
			
		}
		else
		{
//			broadcastmessage( "LEFT" );
			PlayAnim( 'TurnLeft' );
			Dude.PlayAnim( 'TurnLeft' );
			FinishAnim();
			LoopAnim( 'TurnLeft_Idle' );
			Dude.LoopAnim( 'TurnLeft_Idle' );
			//broadcastmessage( "Left: "$GetSequence( 0 )$" Dude: "$Dude.AnimSequence );
			
		}
		*/
		//bRotateToEnemy = true;
		SetTimer( 0.2, true );
		//MoveTo( DesiredLocation );
		if( bReverse )
			StrafeTo( DesiredLocation, GetFocusLocation() );
		else
			StrafeTo( DesiredLocation, GetFocusLocation() );
//		MoveTo( DesiredLocation );
		MyTarget.bTaken = true;
//		broadcastmessage( "DONE MOVING" );
		//	Disable( 'ZoneChange' );
		StopMoving();
		//TurnTo( Enemy.Location );
		if( MyTarget.bTorpedoSpot && FRand() < 0.75 )
		{
			MyTorpedo.GotoState( 'Firing' );
			sleep( 1.5 );
			CreateTorpedo();
		}

		Sleep( Rand( 2 ) + 0.12 + FRand() );
		Goto( 'Bobup' );
		//Goto( 'MoveAround' );
		//	MoveSmooth( Location - 1 * Normal( MyTarget.Location - Location ) );
	}
MoveAround:
	//Enemy = GetEnemy();
	Sleep( 0.2 );
	Goto( 'Bobup' );
	DesiredLocation = FindRandomJetskiPoint().Location;
	StrafeFacing( DesiredLocation, Enemy );

//	MoveTo( DesiredLocation );
	Sleep( Rand( 3 ) + 0.25 + FRand() );
	Goto( 'MoveAround' );

Begin:
	SetCollision( false, false, false );
	SetPhysics( PHYS_Falling );
/*	WaitForLanding();
	SetPhysics( PHYS_Falling );
	WaitForLanding();

	bCanStrafe = true;
	broadcastmessage( "LANDED" );
	AmbientSound = Sound'a_transport.JetSkiRunLp04';
	Goto( 'Bobup' );*/
}

function Destroyed()
{
	if( MyTorpedo != None )
		MyTorpedo.Destroy();
	if( MyTrail != None )
		MyTrail.Destroy();
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass c;

	c = Spawn( CarcassType );
	c.InitFor( self );
	c.LoopAnim( 'Idle_HighJump' );
	AIJetskiCarcass( C ).SoundDampening = SoundDampening;
	c.SetPhysics( PHYS_Falling );
	AIJetskiCarcass( c ).AddVelocity( CarcassVelocity );
	AIJetskiCarcass( C ).MyTorpedo = MyTorpedo;
	if( DestroyTime > 0.0 )
	{
		AIJetskiCarcass( C ).DestroyTime = DestroyTime;
		Dude.DestroyTime = DestroyTime;
	}

	MyTorpedo.SetOwner( C );
	MyTorpedo.AttachActorToParent( c, true, true );
	MyTorpedo.MountType = MOUNT_MeshSurface;
	MyTorpedo.MountMeshItem = 'Mount2';
	MyTorpedo.MountAngles = rot( 16000, 0, 0 );
	MyTorpedo.MountOrigin = vect( -18, 0, -8 );
	MyTrail.AttachActorToParent( c, true, true );

	if( FRand() < 0.5 )
		c.Velocity.Z += 450;
}

DefaultProperties
{
    RotationRate=(Pitch=0,Yaw=8000,Roll=3072)
	Mesh=DukeMesh'c_vehicles.jetski'
	DrawType=DT_Mesh
	AccelRate=1600
	VisibilityRadius=8000
	WaterSpeed=380
	CarcassType=class'dnai.AIJetskiCarcass'
	Health=50
    EgoKillValue=8
	SoundRadius=255
	SoundVolume=175
	bCanStrafe=false
	//	Buoyancy=-175
	//	Buoyancy=201
}
