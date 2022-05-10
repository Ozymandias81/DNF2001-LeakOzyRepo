class ProtonMonitor extends BonedCreature;

#exec OBJ LOAD FILE=..\Meshes\c_Characters.dmx

var actor LeftGunShield, RightGunShield, TopGunShield;
/*
========================================================
				Proton Monitor Animations:
========================================================
B_Down
B_HoverIdleA
B_HoverIdleB
B_Left
B_Right
B_Up

H_IdleA
H_IdleB
H_IdleC
H_Laugh
H_LookAround
H_PainA
H_PainB
========================================================
*/
var float NewDeltaTime;
var int Counter;
var int TempRoll;
var rotator TestingRot, TestingRot2, TGunRotation, LGunRotation, RGunRotation;

var bool bFlapsRIght, bFlapsBack;
var int RollUpdate;
var dnLight_ProtonMonitor MyLightA, MyLightB;
var BeamSystem MyBeamA, MyBeamB;
var SoftParticleSystem JetA, JetB, JetC, JetD;
var TurretMounts GunMountL, GunMountR, GunMountT;

var ProtonGun LeftGun, RightGun, TopGun;
var ProtonCollisionActor RightGunCollision, LeftGunCollision, TopGunCollision, GeneralCollision1, GeneralCollision2;

var ProtonCollisionActor LeftGunCol, LeftGunCol2, LeftGunCol3, LeftGunCol4, LeftGunCol5, RightGunCol, LeftGunCol6, LeftGunCol7, LeftGunCol8,
RightGunCol2, RightGunCol3, RightGunCol4, RightGunCol5, RightGunCol6, RightGunCol7, RightGunCol8, TopGunCol, TopGunCol2, TopGunCol3, TopGunCol4, 
TopGunCol5, TopGunCol6, TopGunCol7, TopGunCol8;

var ProtonMonitorPoint CurrentPoint;
var() int LeftGunHealth, RightGunHealth, TopGunHealth;

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> damageType )
{
	Super.TakeDamage( Damage, instigatedBy, hitLocation, Momentum, damageType );

	if( Health > 0 )
	{
		if( GetStateName() != 'TakeHit' )
			GotoState( 'TakeHit' );
	}
}

state TakeHit
{
Begin:
	StopMoving();
	if( FRand() < 0.5 )
		PlayFaceAnim( 'H_PainA',, 0.14, false );
	else
		PlayFaceAnim( 'H_PainB',, 0.14, false );
	FinishAnim( 5 );
	PlayFaceAnim( 'H_IdleC',, 0.14, true );
	GotoState( 'Idling' );
}

simulated function rotator ClampHeadRotation(rotator r)
{
	local rotator adj;
	adj = Rotation;
	r = Normalize(r - adj);
	r.Pitch = Clamp(r.Pitch, -HeadTracking.RotationConstraints.Pitch, HeadTracking.RotationConstraints.Pitch);
	r.Yaw = Clamp(r.Yaw, -HeadTracking.RotationConstraints.Yaw, HeadTracking.RotationConstraints.Yaw);
	r.Roll = Clamp(r.Roll, -HeadTracking.RotationConstraints.Roll, HeadTracking.RotationConstraints.Roll);
	r = Normalize(r + adj);
	return r;
}

function EvalGuns( float inDeltaTime )
{
	local MeshInstance Minst, Minst2;
	local int bone1, bone2, bone3, bone4;
	local rotator TempLGunRot, TempRGunRot, TempTGunRot, DesiredLGunRot, DesiredRGunRot, DesiredTGunRot;
	local vector BoneLocation;
	local rotator TempRot;

	Minst = GetMeshInstance();
	bone1 = Minst.BoneFindNamed( 'GunL' );
	bone2 = Minst.BoneFindNamed( 'GunR' );
	bone3 = Minst.BoneFindNamed( 'GunT' );

	Minst2 = Enemy.GetMeshInstance();
	bone4 = Minst2.BoneFindNamed( 'Chest' );
	BoneLocation = Minst2.BoneGetTranslate( bone4, true, false );
	BoneLocation = Minst2.MeshToWorldLocation( BoneLocation );
	
	DesiredLGunRot = rotator( Normal(  BoneLocation - Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone1, true, false ) ) ) );
//	DesiredLGunRot = Minst.WorldToMeshRotation( rotator( Normal(  BoneLocation - Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone1, true, false ) ) ) ) );

	//DesiredLGunRot = rotator( Normal( BoneLocation - LeftGun.Location ) );
	//DesiredLGunRot = rotator( Normal( Enemy.Location - Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone1, true, false ) ) ) ) ;
		
	DesiredRGunRot = rotator( Normal( BoneLocation - Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone2, true, true ) ) ) );
	//DesiredRGunRot = rotator( Normal( Minst.WorldToMeshLocation( Enemy.Location ) - Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone2, true, false ) ) ) ) ;
	//DesiredTGunRot = rotator( Normal( Enemy.Location - Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone3, true, false ) ) ) ) ;
	DesiredTGunRot = rotator( Normal( BoneLocation - Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone3, true, false ) ) ) ) ;

	//DesiredLGunRot.Pitch *= 0.17;
	//DesiredRGunRot.Pitch *= 0.17;
//	TempLGunRot.Pitch = FixedTurn( LGunRotation.Pitch, DesiredLGunRot.Yaw * -1, int( 1000 * inDeltaTime ));
	TempLGunRot.Roll = FixedTurn( LGunRotation.Roll, DesiredLGunRot.Pitch * -1, int(1000 * inDeltaTime));


//	TempLGunRot = Minst.WorldToMeshRotation( TempLGunRot );

	TempRGunRot.Roll = FixedTurn(RGunRotation.Roll, DesiredRGunRot.Pitch, int(1000 * inDeltaTime));
//	TempRGunRot.Pitch = FixedTurn( RGunRotation.Pitch, DesiredRGunRot.Yaw, int( 1000 * inDeltaTime ));
//	TempRGunRot = Minst.WorldToMeshRotation( TempRGunRot );

//	TempRGunRot = Minst.WorldToMeshRotation( TempRGunRot );
	
	TempTGunRot.Pitch = FixedTurn(TGunRotation.Pitch, DesiredTGunRot.Pitch, int(1000 * inDeltaTime));
//	TempTGunRot.Roll = FixedTurn( TGunRotation.Roll,  DesiredTGunRot.Yaw * -1, int( 1000 * inDeltaTime ) );

	//TempLGunRot.Pitch = 0;
	//TempRGunRot.Pitch = 0;
	//broadcastmessage( "TEST: "$TempLGunRot.Roll );

	TempLGunRot.Yaw = 0;
	TempTGunRot.Yaw = 0;
//	TempTGunRot.Roll = 0;
//	log( "PRE: "$TempRGunRot );
//	TempRGunRot = Minst.WorldToMeshRotation( TempRGunRot );
//	TempLGunRot = Minst.WorldToMeshRotation( TempLGunRot );
//	log( "POST: "$TempRGunRot );
//	log( "*** TEST: "$TempRGunRot.Roll );
//	log( "*** TEST1: "$TempLGunRot.Roll );
//	TempLGunRot.Roll *= 0.77;
//	TempRGunRot.Roll += TempRGunRot.Roll * 0.77;
//	TempTGunRot.Pitch *= 0.77;
//	TempRGunRot.Roll = 0;
//	TempRGunRot.Yaw = 0;
//	TempLGunRot.Roll = 0;
//	TempLGunRot.Yaw = 0;
//	TEmpLGunRot = Minst.WorldToMeshRotation( TempLGunRot );

	//broadcastmessage( "RGunRotation: "$TempRGunRot );
	Minst.BoneSetRotate( bone1, TempLGunRot, true, true );
	TempRot.Yaw = 0;
	TempRot.Pitch = TempRGunRot.Pitch;
	TempRot.Roll = TempRGunRot.Roll;
	Minst.BoneSetRotate( bone2, TempRot, true, true );
	Minst.BoneSetRotate( bone3, TempTGunRot, true, true );
	
	LGunRotation = TempLGunRot;
	RGunRotation = TempRGunRot;
	TGunRotation = TempTGunRot;
}



function ResetFlaps( float inDeltaTime )
{
	local int bone1,bone2,bone3,bone4, bone5, bone6;
	local MeshInstance Minst;
	local rotator TempRot;
	local bool bCancel;

	Minst = GetMeshInstance();

	bone1 = Minst.BoneFindNamed( 'RudderLB' );
	bone2 = Minst.BoneFindNamed( 'RudderRA' );
	bone3 = Minst.BoneFindNamed( 'RudderRB' );
	bone4 = Minst.BoneFindNamed( 'RudderLA' );
	bone5 = Minst.BoneFindNamed( 'ThrustBR' );
	bone6 = Minst.BoneFindNamed( 'ThrustBL' );

	if( bone1 != 0 )
	{
		if( Minst.MeshToWorldRotation( TestingRot ).Roll > 0 || Minst.MeshToWorldRotation( TestingRot ).Pitch > 0 ) 
		{
			TempRot.Roll = FixedTurn(TestingRot.Roll, 0, int(1000 * inDeltaTime));
			TempRot.Pitch = FixedTurn( TestingRot.Pitch, 0, int( 1000 * inDeltaTime ) );

			Minst.BoneSetRotate( bone1, TempRot, true, true );
			Minst.BoneSetRotate( bone2, TempRot, true, true );
			Minst.BoneSetRotate( bone3, TempRot, true, true );
			Minst.BoneSetRotate( bone4, TempRot, true, true );
			Minst.BoneSetRotate( bone5, TempRot, true, true );
			Minst.BoneSetRotate( bone6, TempRot, true, true );

		}
		else if( Minst.MeshToWorldRotation( TestingRot ).Roll < 0 || Minst.MeshToWorldRotation( TestingRot ).Pitch < 0 )
		{
			TempRot.Roll = FixedTurn(TestingRot.Roll, 0, int(1000 * inDeltaTime));
			TempRot.Pitch = FixedTurn( TestingRot.Pitch, 0, int( 1000 * inDeltaTime ) );

			Minst.BoneSetRotate( bone1, TempRot, true, true );
			Minst.BoneSetRotate( bone2, TempRot, true, true );
			Minst.BoneSetRotate( bone3, TempRot, true, true );
			Minst.BoneSetRotate( bone4, TempRot, true, true );
			Minst.BoneSetRotate( bone5, TempRot, true, true );
			Minst.BoneSetRotate( bone6, TempRot, true, true );
		}
	}
	TestingRot = TempRot;
}

function EvalFlaps( float inDeltaTime )
{
	local int bone1, bone2, bone3, bone4, bone5, bone6;
	local MeshInstance Minst;
	local rotator TempRot;
	local bool bCancel;
	local vector X, Y, Z;
	local int Restrict;
	local int RestrictBack;

	Minst = GetMeshInstance();
	if( ( Velocity.Y * vector( Rotation ) ).X > 0 )
	{
		bFlapsRight = true;
	}
	else if( ( Velocity.Y * vector( Rotation ) ).X < 0 )
		bFlapsRight = false;
	
	if( ( Velocity.X * vector( Rotation ) ).X > 0 )
	{
		bFlapsBack = true;
	}
	else if( ( Velocity.X * vector( Rotation ) ).X < 0 )
	{
		bFlapsBack = false;
	}

	bone1 = Minst.BoneFindNamed( 'RudderLB' );
	bone2 = Minst.BoneFindNamed( 'RudderRA' );
	bone3 = Minst.BoneFindNamed( 'RudderRB' );
	bone4 = Minst.BoneFindNamed( 'RudderLA' );
	bone5 = Minst.BoneFindNamed( 'ThrustBR' );
	bone6 = Minst.BoneFindNamed( 'ThrustBL' );

	if( bFlapsBack )
	{
		RestrictBack = -10000;
	}
	else
		RestrictBack = 10000;

	if( bone1 != 0 )
	{
		//	TempRot.Yaw = RollUpdate;
		if( bFlapsRight )
			TempRot.Roll= FixedTurn( TestingRot.Roll, 3000, int(3000 * inDeltaTime));
		else
			TempRot.Roll= FixedTurn( TestingRot.Roll, -3000, int(3000 * inDeltaTime));
		
	//	if( bFlapsBack ) 
	//		TempRot.Pitch = FixedTurn( TestingRot.Pitch, -7000, int( 5000 * inDeltaTime ) );
	//	else
	//		TempRot.Pitch = FixedTurn( TestingRot.Pitch, 7000, int( 5000 * inDeltaTime ) );

		//	broadcastmessage( "TEMPROT: "$TempRot.Pitch );
		//if( !bFlapsRight )
		//	TempRot *= -1;
		Minst.BoneSetRotate( bone1, TempRot, true, true );
		Minst.BoneSetRotate( bone2, TempRot, true, true );
		Minst.BoneSetRotate( bone3, TempRot, true, true );
		Minst.BoneSetRotate( bone4, TempRot, true, true );
		if( bFlapsBack ) 
			TempRot.Pitch = FixedTurn( TestingRot.Pitch, -3000, int( 3000 * inDeltaTime ) );
		else
			TempRot.Pitch = FixedTurn( TestingRot.Pitch, 3000, int( 3000 * inDeltaTime ) );

		Minst.BoneSetRotate( bone5, TempRot, true, true );
		Minst.BoneSetRotate( bone6, TempRot, true, true );
		//TestingRot = Minst.BoneGetRotate( bone1 ).Roll;
		TestingRot = TempRot;
		Counter += 100;
	}
	return;
}

function ProcessDamage( ProtonCollisionActor DamagedActor )
{
	if( DamagedActor == LeftGunCollision )
	{
		CreateShield( LeftGun );
		if( LeftGunCollision.Health <= 0 )
		{
			Spawn( class'dnExplosion1',,, LeftGunCollision.Location, LeftGunCollision.Rotation );
		//	LeftGun.Destroy();
			LeftGun.AttachActorToParent( none, true, true );
			LeftGun.MountParent = None;
			LeftGun.SetPhysics( PHYS_Falling );
			LeftGun.Tossed();
			LeftGunCollision.Destroy();
		}
	}
	else if( DamagedActor == RightGunCollision )
	{
		CreateShield( RightGun );
		if( RightGunCollision.Health <= 0 )
		{
			Spawn( class'dnExplosion1',,, RightGunCollision.Location, RightGunCollision.Rotation );
			RightGun.AttachActorToParent( none, true, true );
			RightGun.MountParent = None;
			RightGun.SetPhysics( PHYS_Falling );
			RightGun.Tossed();
			RightGunCollision.Destroy();
		}
	}
	else if( DamagedActor == TopGunCollision )
	{
		CreateShield( TopGun );
		if( TopGunCollision.Health <= 0 )
		{
			Spawn( class'dnExplosion1',,, TopGunCollision.Location, TopGunCollision.Rotation );
			TopGun.AttachActorToParent( none, true, true );
			TopGun.MountParent = None;
			TopGun.SetPhysics( PHYS_Falling );
			TopGun.Tossed();
			TopGunCollision.Destroy();
		}
	}
}

simulated function CreateShield( ProtonGun DamagedGun )
{
	local MeshInstance Minst;
	local int bone;

	if( DamagedGun == LeftGun && LeftGunShield != None )
		return;
	else if( DamagedGun == RightGun && RightGunShield != None )
		return;
	else if( DamagedGun == TopGun && TopGunShield != None )
		return;

	Shield = spawn(class'Effects',DamagedGun,,DamagedGun.Location,DamagedGun.Rotation);
	Shield.SetCollisionSize(CollisionRadius, CollisionHeight);
	Shield.SetCollision(false, false, false);
	Shield.bProjTarget = false;
	Shield.SetPhysics(PHYS_Rotating);
	Shield.DrawType = DT_Mesh;
	Shield.Style = STY_Translucent;
	Shield.Mesh = DamagedGun.Mesh;
	Shield.Texture = texture'ShieldFX.ShieldLightning';
	Shield.bMeshEnviroMap = true;
	Shield.DrawScale = DamagedGun.DrawScale * 1.2;
	Shield.ScaleGlow = 2.0;
	Shield.bMeshLowerByCollision=true;
	Shield.MeshLowerHeight=0.0;
	Shield.RemoteRole = ROLE_None;
	Minst = DamagedGun.GetMeshInstance();
		
	if( DamagedGun == LeftGun )
	{
		LeftGunShield = Shield;
		bone = Minst.bonefindNamed( 'GunL' );
	}
	else if( DamagedGun == RightGun )
	{
		RightGunShield = Shield;
		bone = Minst.boneFindNamed( 'GunR' );
	}
	else if( DamagedGun == TopGun )
	{
		TopGunShield = Shield;
		bone = Minst.bonefindnamed( 'GunT' );
	}
	Shield.AttachActorToParent( self, true, true );
	Shield.MountType = MOUNT_MeshBone;
	if( DamagedGun == LeftGun )
	{
		Shield.MountAngles = rot( -16384, 0, 0 );
		Shield.MountMeshItem = 'GunL';
	}
	else if( DamagedGun == RightGun )
	{
		Shield.MountAngles = rot( -16384, 0, 0 );
		Shield.MountMeshItem = 'GunR';
	}
	else if( DamagedGun == TopGun )
	{
		Shield.MountAngles = rot( -16384, 0, 0 );
		Shield.MountMeshItem = 'GunT';
	}
	Shield.SetPhysics( PHYS_MovingBrush );
}

function PostBeginPlay()
{
	SpawnMountedActors();
/*	TopGunCol = Spawn( class'ProtonCollisionActor', self );
	TopGunCol.AttachActorToParent( self, true, true );
	TopGunCol.MountType = MOUNT_MeshBone;
//	TopGunCol.MountOrigin.X = -128;
	TopGunCol.MountOrigin.X = -40;
	TopGunCol.MountOrigin.Y = -30;
	TopGunCol.MountOrigin.Z = 0;
	//TopGunCol.MountOrigin.Y = 128;
	TopGunCol.MountAngles = rot( -16384, 0, 0 );
	TopGunCol.MountMeshItem = 'GunL';
	TopGunCol.SetPhysics( PHYS_MovingBrush );
*/
	PlayBottomAnim( 'B_HoverIdleA',, 0.1, true );
	PlayFaceAnim( 'H_LookAround',, 0.1, true );
	Super.PostBeginPlay();
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = true;
	MinHitWall = -0.6;
}

simulated event bool OnEvalBones(int Channel)
{
//	if (!bHumanSkeleton)
//		return false;

//	if( !PlayerCanSeeMe() )
//		return false;
	if( Channel == 8 )
	{
		if( Enemy != None )
			EvalGuns( NewDeltaTime );
		if( ( Velocity.Y * vector( Rotation ) ).X < 0 || ( Velocity.Y * vector( Rotation ) ).X > 0 )
			EvalFlaps( NewDeltaTime );
		else
			ResetFlaps( NewDeltaTime );
	}

	return true;
}


function bool EvalHeadLook()
{
	
}

function Tick(float inDeltaTime)
{	
	local MeshInstance Minst;
	local int bone;

	if( LeftGunShield != None )
	{
		LeftGunShield.ScaleGlow -= 0.05;
		if( LeftGunShield.ScaleGlow <= 0.0 )
		{
			LeftGunShield.Destroy();
			LeftGunShield = None;
		}
	}
	if( RightGunShield != None )
	{
		RightGunShield.ScaleGlow -= 0.05;
		if( RightGunShield.ScaleGlow <= 0.0 )
		{
			RightGunShield.Destroy();
			RightGunShield = None;
		}
	}
	if( TopGunShield != None )
	{
		TopGunShield.ScaleGlow -= 0.05;
		if( TopGunShield.ScaleGlow <= 0.0 )
		{
			TopGunShield.Destroy();
			TopGunShield = None;
		}
	}
	Minst = GetMeshInstance();
	Bone = Minst.BoneFindNamed( 'RudderLB' );
	//broadcastmessage( "Acceleration Yaw: "$Acceleration.Y );
	//broadcastmessage( "Veloc: "$Velocity.Y * vector( Rotation ) );
	//TestingRot = Minst.MeshToWorldRotation( Minst.BoneGetRotate( bone, true, true ) );	
	NEwDeltaTime = inDeltaTime;

	Super.Tick( inDeltaTime );
}

auto state Idling
{
	function actor FindEnemy()
	{
		local PlayerPawn P;
		foreach allactors( class'PlayerPawn', P )
		{
			return P;
		}
	}		

	function BeginState()
	{
		Enemy = FindEnemy();
		SetPhysics( PHYS_Flying );
	}

	function EnemyNotVisible()
	{
		GotoState( 'Idling', 'Moving' );
		Disable( 'EnemyNotVisible' );
	}
		
	function PickDest()
	{
		local ProtonMonitorPoint PMP;

		local int i;
		local bool bSuccess;

		if( CurrentPoint != None )
		{
			for( i = 0; i <= 15; i++ )
			{
				if( CurrentPoint.AccessiblePoints[ i ] != None && CurrentPoint.AccessiblePoints[ i ] != CurrentPoint )
				{
					if( CanSeeEnemyFrom( CurrentPoint.AccessiblePoints[ i ].Location ) )
					{
						broadcastmessage( "Can see enemy from "$CurrentPoint.AccessiblePoints[ i ]$".. point selected." );
						CurrentPoint = ProtonMonitorPoint( CurrentPoint.AccessiblePoints[ i ] );
						Destination = CurrentPoint.Location;
						return;
					}
				}
			}
			CurrentPoint = ProtonMonitorPoint( CurrentPoint.GetRandomReachablePoint() );
			broadcastmessage( "Choosing random accessible point: "$CurrentPoint );
			Destination = CurrentPoint.Location;
		}
		else
		{
		foreach allactors( class'ProtonMonitorPoint', PMP )
		{
			//broadcastmessage( "FOUND "$JSP );
			if( Destination != PMP.Location && PMP != CurrentPoint && CanSeeEnemyFrom( PMP.Location ) )
			{
				CurrentPoint = PMP;
				Destination = PMP.Location;
				break;
			}
		}
		}
	}

	function bool CanSeeEnemyFrom( vector aLocation, optional float NewEyeHeight, optional bool bUseNewEyeHeight )
	{
		local actor HitActor;
		local vector HitNormal, HitLocation, HeightAdjust;

		if( bUseNewEyeHeight )
		{
			HeightAdjust.Z = NewEyeHeight;
		}
		else
			HeightAdjust.Z = BaseEyeHeight;
		HitActor = Trace( HitLocation, HitNormal, Enemy.Location, aLocation + HeightAdjust, true );
		if( HitActor == Enemy )
		{
			return true;
		}
		return false;
	}


	function Timer( optional int TimerNum )
	{
		//if( CanSee( Enemy )
		//{
			GunMountL.TraceFire( None );
			LeftGun.MuzzleFlash();
		//}
	}

Begin: 
	if( Enemy == None )
		Enemy = FindEnemy();
	else
		Goto( 'Moving' );
	Sleep( 0.5 );
	Goto( 'Begin' );

Moving:	
	Sleep( 0.5 );
	PickDest();
	if( Destination != vect( 0, 0, 0 ) )
	{
		Focus = vector( Rotation );
		bRotateToDesired = false;
		StrafeTo( Destination, Enemy.Location );
	}
	Enable( 'EnemyNotVisible' );
	StopMoving();
//	Sleep( 0.5 );
//	Disable( 'EnemyNotVisible' );
//	GotoState( 'Idling', 'Moving' );
	
Firing:
	TurnTo( Enemy.Location );
	if( TopGun != None )
	{
		TurretMountProton( GunMountT ).NewEnemy = Pawn( Enemy );
		GunMountT.TraceFire( None );
		TopGun.MuzzleFlash();
		Sleep( 0.13 );
	}
	if( LeftGun != None )
	{
		TurretMountProton( GunMountL ).NewEnemy = Pawn( Enemy );
		GunMountL.TraceFire( None );
		LeftGun.MuzzleFlash();
		Sleep( 0.13 );
	}
	if( RightGun != None )
	{
		TurretMountProton( GunMountR ).NewEnemy = Pawn( Enemy );
		GunMountR.TraceFire( None );
		RightGun.MuzzleFlash();
	}	
	Sleep( 0.13 );
	Goto( 'Firing' );
	//Goto( 'Begin' );

	//	Goto( 'Begin' );

}

state Wandering
{
	ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( Enemy != None )
			LastSeenPos = Enemy.Location;
	
		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else
			GotoState('Attacking');
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
		SetPhysics( PHYS_Flying );
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
	PickDestination();
Moving:
	Enable('HitWall');
/*	if( ( Rotator( Destination - Location ) - Rotation ).Yaw != 0 && ( Rotator( Destination - Location ) - rotation ).Yaw != -65536)
	{
		Sleep( 0.1 );
		Goto( 'Moving' );
	}
	PlayToWalking();*/
	MoveTo(Destination);
Pausing:
/*	if ( NearWall(2 * CollisionRadius + 50) )
	{
		//PlayTurning();
		TurnTo(Focus);
	}*/
	StopMoving();
	Sleep(1.0);
	Goto('Wander');
ContinueWander:
	if (FRand() < 0.2)
		Goto('Turn');
		Goto('Wander');
	
Turn:
	//PlayTurning();
	TurnTo( Location + 96 * VRand());
	Goto('Pausing');

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Moving');

Acquisition:
	if( ( Rotator( Enemy.Location - Location ) - Rotation ).Yaw != 0 && ( Rotator( Enemy.Location - Location ) - rotation ).Yaw != -65536)
	{
		Destination = Enemy.Location;
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

// Nasty function to arrange the 13 (13!) actors mounted to the monitor.
function SpawnMountedActors()
{
	// Spawn and attach the jet flames.
	JetA = Spawn( class'dnCharacterFX_ProtonMonitor_JetB', self );
	JetA.AttachActorToParent( self, true, true );
	JetA.MountType = MOUNT_MeshBone;
	JetA.MountMeshItem = 'thrustBR';
	JetA.MountAngles.Pitch = 32768;
	JetA.MountOrigin.Z = -14;

	JetB = Spawn( class'dnCharacterFX_ProtonMonitor_JetA', self );
	JetB.AttachActorToParent( self, true, true );
	JetB.MountType = MOUNT_MeshBone;
	JetB.MountMeshItem = 'thrustrR';
	JetB.MountOrigin.Z = 42;
	
	JetC = Spawn( class'dnCharacterFX_ProtonMonitor_JetA', self );
	JetC.AttachActorToParent( self, true, true );
	JetC.MountType = MOUNT_MeshBone;
	JetC.MountMeshItem = 'thrustrL';
	JetC.MountOrigin.Z = 42;

	JetD = Spawn( class'dnCharacterFX_ProtonMonitor_JetB', self );
	JetD.AttachActorToParent( self, true, true );
	JetD.MountType = MOUNT_MeshBone;
	JetD.MountAngles.Pitch = 32768;
	JetD.MountOrigin.Z = -14;
	JetD.MountMeshItem = 'thrustBL';

	// Light effects at Proton Monitor's beam impact points.
	MyLightA = spawn( class'dnLight_ProtonMonitor', self );
	MyLightA.AttachActorToParent( self, true, true );
	MyLightA.MountType = MOUNT_MeshSurface;
	MyLightA.MountMeshItem = 'Mount1';

	MyLightB = spawn( class'dnLight_ProtonMonitor', self );
	MyLightB.AttachActorToParent( self, true, true );
	MyLightB.MountType = MOUNT_MeshSurface;
	MyLightB.MountMeshItem = 'Mount2';

	// Create and turn on the beams.
	MyBeamA = spawn( class'dnProtonMonitor_HoloBeamA', self, 'BeamL' );
	MyBeamA.Event = 'BeamR';
	MyBeamA.AttachActorToParent( self, true, true );
	MyBeamA.MountType = MOUNT_MeshSurface;
	MyBeamA.MountMeshItem = 'Mount2';
	MyBeamA.VisibilityRadius=8000;

	MyBeamB = spawn( class'dnProtonMonitor_HoloBeamA', self, 'BeamR' );
	MyBeamB.Event = 'BeamL';
	MyBeamB.AttachActorToParent( self, true, true );
	MyBeamB.MountType = MOUNT_MeshSurface;
	MyBeamB.VisibilityRadius=8000;
	MyBeamB.MountMeshItem = 'Mount1';

	MyBeamA.Trigger( self, self );
	MyBeamB.Trigger( self, self );

	// Invisible collision actors oriented around the monitor.
	GeneralCollision1 = Spawn( class'ProtonCollisionActor', self );
	GeneralCollision1.AttachActorToParent( self, true, true );
	GeneralCollision1.MountType = MOUNT_MeshBone;
	GeneralCollision1.MountOrigin.X = -40;
	GeneralCollision1.MountOrigin.Y = 3;
	GeneralCollision1.MountOrigin.Z = 0;
	GeneralCollision1.MountAngles = rot( -16384, 0, 0 );
	GeneralCollision1.MountMeshItem = 'GunL';
	GeneralCollision1.SetPhysics( PHYS_MovingBrush );
	GeneralCollision1.SetCollisionSize( GeneralCollision1.CollisionRadius, GeneralCollision1.CollisionHeight * 1.75 );

	GeneralCollision2 = Spawn( class'ProtonCollisionActor', self );
	GeneralCollision2.AttachActorToParent( self, true, true );
	GeneralCollision2.MountType = MOUNT_MeshBone;
	GeneralCollision2.MountOrigin.X = -40;
	GeneralCollision2.MountOrigin.Y = -3;
	GeneralCollision2.MountOrigin.Z = 0;
	GeneralCollision2.MountAngles = rot( -16384, 0, 0 );
	GeneralCollision2.MountMeshItem = 'GunR';
	GeneralCollision2.SetPhysics( PHYS_MovingBrush );
	GeneralCollision2.SetCollisionSize( GeneralCollision2.CollisionRadius, GeneralCollision2.CollisionHeight * 3.75 );
	// Invisible collision actors centered on the three guns.
	RightGunCollision = Spawn( class'ProtonCollisionActor', self );
	RightGunCollision.AttachActorToParent( self, true, true );
	RightGunCollision.MountType = MOUNT_MeshBone;
	RightGunCollision.MountOrigin.X = 30;
	RightGunCollision.MountOrigin.Y = 0;
	RightGunCollision.MountOrigin.Z = -128;
	RightGunCollision.MountAngles = rot( -16384, 0, 0 );
	RightGunCollision.MountMeshItem = 'GunR';
	RightGunCollision.SetPhysics( PHYS_MovingBrush );
	RightGunCollision.SetCollisionSize( RightGunCollision.CollisionRadius * 1.15, RightGunCollision.CollisionHeight );
	RightGunCollision.Health = RightGunHealth;

	LeftGunCollision = Spawn( class'ProtonCollisionActor', self );
	LeftGunCollision.AttachActorToParent( self, true, true );
	LeftGunCollision.MountType = MOUNT_MeshBone;
	LeftGunCollision.MountOrigin.X = 30;
	LeftGunCollision.MountOrigin.Y = 0;
	LeftGunCollision.MountOrigin.Z = -100;
	LeftGunCollision.MountAngles = rot( -16384, 0, 0 );
	LeftGunCollision.MountMeshItem = 'GunL';
	LeftGunCollision.SetPhysics( PHYS_MovingBrush );
	LeftGunCollision.SetCollisionSize( LeftGunCollision.CollisionRadius * 1.15, LeftGunCollision.CollisionHeight );
	LeftGunCollision.Health = LeftGunHealth;

	TopGunCollision = Spawn( class'ProtonCollisionActor', self );
	TopGunCollision.AttachActorToParent( self, true, true );
	TopGunCollision.MountType = MOUNT_MeshBone;
	TopGunCollision.MountOrigin.X = 30;
	TopGunCollision.MountOrigin.Y = 0;
	TopGunCollision.MountOrigin.Z = -128;
	TopGunCollision.MountAngles = rot( -16384, 0, 0 );
	TopGunCollision.MountMeshItem = 'GunT';
	TopGunCollision.SetPhysics( PHYS_MovingBrush );
	TopGunCollision.SetCollisionSize( TopGunCollision.CollisionRadius * 1.15, TopGunCollision.CollisionHeight );
	TopGunCollision.Health = TopGunHealth;

	// Mount the guns and the corresponding Turret Mounts.
	LeftGun = Spawn( class'ProtonGun', self );
	LeftGun.AttachActorToParent( self, true, true );
	LeftGun.MountType = MOUNT_MeshBone;
	LeftGun.MountAngles = rot( -16384, 0, 0 );
	LeftGun.MountMeshItem = 'GunL';
	LeftGun.SetPhysics( PHYS_MovingBrush );

	GunMountL = spawn( class'TurretMountProton', self,,, LeftGun.Rotation );
	GunMountL.AttachActorToParent( LeftGun, true, true );
	GunMountL.MountType = MOUNT_MeshSurface;
	GunMountL.MountMeshItem = 'MuzzleMount';
	GunMountL.SetPhysics( PHYS_MovingBrush );

	RightGun = Spawn( class'ProtonGun', self );
	RightGun.AttachActorToParent( self, true, true );
	RightGun.MountType = MOUNT_MeshBone;
	RightGun.MountAngles = rot( -16384, 0, 0 );
	RightGun.MountMeshItem = 'GunR';
	RightGun.SetPhysics( PHYS_MovingBrush );
	
	GunMountR = spawn( class'TurretMountProton', self,,, RightGun.Rotation );
	GunMountR.AttachActorToParent( RightGun, true, true );
	GunMountR.MountType = MOUNT_MeshSurface;
	GunMountR.MountMeshItem = 'MuzzleMount';
	GunMountR.SetPhysics( PHYS_MovingBrush );

	TopGun = Spawn( class'ProtonGun', self );
	TopGun.AttachActorToParent( self, true, true );
	TopGun.MountType = MOUNT_MeshBone;
	TopGun.MountAngles = rot( -16384, 0, 0 );
	TopGun.MountMeshItem = 'GunT';
	TopGun.SetPhysics( PHYS_MovingBrush );

	GunMountT = spawn( class'TurretMountProton', self,,, TopGun.Rotation );
	GunMountT.AttachActorToParent( TopGun, true, true );
	GunMountT.MountType = MOUNT_MeshSurface;
	GunMountT.MountMeshItem = 'MuzzleMount';
	GunMountT.SetPhysics( PHYS_MovingBrush );
}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	DestroyMountedActors();
}

function DestroyMountedActors()
{
	
	// Destroy guns.
	if( LeftGun != None )
		LeftGun.Destroy();
	if( RightGun != None )
		RightGun.Destroy();
	if( TopGun != None )
		TopGun.Destroy();
	
	if( GunMountL != None )
		GunMountL.Destroy();
	if( GunMountR != None )
		GunMountR.Destroy();
	if( GunMountT != None )
		GunMountT.Destroy();

	// Destroy invisible collision actors.
	if( GeneralCollision1 != None )
		GeneralCollision1.Destroy();
	if( GeneralCollision2 != None )
		GeneralCollision2.Destroy();
	if( RightGunCollision != None )
		RightGunCollision.Destroy();
	if( LeftGunCollision != None )
		LeftGunCollision.Destroy();
	if( TopGunCollision != None )
		TopGunCollision.Destroy();

	// Destroy miscellaneous effects.
	if( JetA != None )
		JetA.Destroy();
	if( JetB != None )
		JetB.Destroy();
	if( JetC != None )
		JetC.Destroy();
	if( JetD != None )
		JetD.Destroy();
	if( MyBeamA != None )
		MyBeamA.Destroy();
	if( MyBeamB != None )
		MyBeamB.Destroy();
	if( MyLightA != None )
		MyLightA.Destroy();
	if( MyLightB != None )
		MyLightB.Destroy();
}

function Destroyed()
{
	DestroyMountedActors();
	Super.Destroyed();
}

DefaultProperties
{
    Health=2000
	Mesh=DukeMesh'c_Characters.Proton_Monitor'
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bBlockPlayers=false
	CollisionHeight=0
	CollisionRadius=0
    Drawscale=10.000000
	AirSpeed=700.000000
	RotationRate=(Pitch=0,Yaw=11000,Roll=0)
	bCanStrafe=true
	AccelRate=500
	HeadTracking=(RotationRate=(Pitch=2000,Yaw=8500),RotationConstraints=(Pitch=65000,Yaw=500,Roll=16000))
    VisibilityRadius=8000
    LeftGunHealth=200
    RightGunHealth=200
    TopGunHealth=200
}
