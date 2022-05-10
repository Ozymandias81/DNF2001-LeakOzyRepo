//=============================================================================
// EDFSniper.uc ** TEMPORARY CLASS FOR VIDEO ** 
//=============================================================================
class HackSniper extends HumanNPC;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

var BeamSystem LaserBeam;
var actor DestinationActor;
var Pawn WatchTarget;
var vector RandOffset;
var float ZOFfset, YOFfset, XOffset;
var float RangeMod;
var vector CurrentRandOffset;
var bool bUp;
var float anAngle;
var bool bTriggerDisabled;
var SniperPoint MyPoint, TestDot2;
var float LaserOffTime;
var float XM, YM, ZM;
var sniperpoint TestDot;
var pawn TempPawn;
var int PitchMod;
var  bool bPitchUp;
var bool bIsTurning;
var rotator AYaw1, AYaw2;
var bool bCanTrack;
var Pawn TestPawn;
var() float MyAbdomenFactor;

function PostBeginPlay()
{
	bCanTorsoTrack = true;
	Super.PostBeginPlay();
}

function MakeLaserBeam()
{
	local vector HitLocation, HitNormal, EndPos;
	local actor HitActor;
	local vector ZAdjust;
	local float f, Dist;
	local MeshInstance Minst;
	local int Bone;

//	DesiredRotation = rotator( ( WatchTarget.Location + vect( 0, 0, 24 ) ) - Location );
	
	Minst = WatchTarget.GetMeshInstance();
	Bone = Minst.BoneFindNamed( 'Head' );
	DesiredRotation = rotator( ( vect( 0, 0, 1 ) * -32 )+ Minst.MeshToWorldLocation( Minst.BoneGetTranslate( Bone, true, false ) ) - Location );

	//	if( RandOffset.Z < 2 && RandOffset.Z > -2 )
//		RandOffset.Z = RandRange( RangeMod * -1, RangeMod );
//	if( RandOffset.X < 2 && RandOffset.X > -2 )
//	RandOffset.X = RandRange( RangeMod * -1, RangeMod );
//	if( RandOffset.Y < 2 && RandOffset.Y > -2 )

//	RandOffset.Y = RandRange( RangeMod * -1, RangeMod );
//	RangeMod *= 0.75;
//	DesiredRotation = rotator( Normal( ( WatchTarget.Location - Location ) + RandOffset ) );

	if( FRand() < 0.33 )
	{
/*	if( !bUp && CurrentRandOffset.Z < RandOffset.Z )
	{
		if( RandOffset.Z > 0 )
			CurrentRandOffset.Z += 0.5;
		else
			CurrentRandOffset.Z -= 0.5;
	}
	else
		if( bUp && CurrentRandOffset.Z > RandOffset.Z )
		{
			if( RandOffset.Z > 0 )
				CurrentRandOffset.Z += 0.5;
			else
				CurrentRandOffset.Z -= 0.5;
		}
	else
	{
		if( !bUp )
		{
			bUp = true;
			//RandOffset.Z = -15;
			RandOffset.Z = RandRange( 0, -25 );
		}
		else
		{
			bUp = false;
			//RandOffset.Z = 15;
			RandOffset.Z = RandRange( 0, 25 );
		}
	}*/
	}
	if( WatchTarget != None )
	{
		ZAdjust = ( WatchTarget.Location - Location );
		ZAdjust.X = 0;
		ZAdjust.Y = 0;
	}

	HitActor = Trace( HitLocation, HitNormal, Location /*+ ( BaseEyeHeight * vect( 0, 0, 1 ) )*/ + Vector( ViewRotation ) * 10000, Location, false);
	//broadcastmessage( "HITACTOR: "$HitActor );
	if( HitActor == None )
		HitActor = Trace( HitLocation, HitNormal, Location + Vector( Rotation ) * 10000, Location, false );
	/*	if( HitActor == WatchTarget )
	{
		bTriggerDisabled = true;
		bROADCASTMESSAGE( "sniping" );
		GotoState( 'Sniping', 'Fire' );
		return;
	}*/
//	broadcastMessage( "ZADJUST: "$ZAdjust );
//	RandOffset *= 0;
//	if( VSize( DestinationActor.Location - Enemy.Location ) > 96 )
//	{
////	f = Level.TimeSeconds * pi * 0.25;
//	if( FRand() < 0.25 )
////	RandOffset = vect(cos(f)*XM, -sin(f)*YM, cos(f)*ZM);
//	XM *= 0.9;
//	YM *= 0.9;
//	ZM *= 0.9;

	//	}
//		CamRot = rotator(Normal(WatchTarget.Location - CamLoc));
	

//
//	RandOffset.Z = Sin( anAngle );
	//RandOffset.Y = Cos( anAngle );
		//if( HitActor == None )
	//{
	//	DestinationActor = Spawn( class'dnRobotShockFX_SparkBeamA_Hit', self,, Location + Vector( Rotation ) * 5000 );
	//	DestinationActor.SetPhysics( PHYS_None );
	//}
	//else
		//DestinationActor = Spawn( class'dnRobotShockFX_SparkBeamA_Hit', self,, HitLocation + ZAdjust + CurrentRandOffset );
//	RandOffset *= 0;
	if( DestinationActor == None )	
	{
	//	MyPoint = Spawn( class'SniperPoint', self,, HitLocation + RandOffset, Rotator( HitNormal ) );
	//	MyPoint.DrawScale *= 10;
		DestinationActor = Spawn( class'SniperPoint', self,, Normal( HitLocation ) ); //+ ZAdjust ); // + ( RandOffset * 10 ) );
		DestinationActor.DrawType = DT_None;
	//	DestinationActor.Mesh = dukemesh'EDF1';
	//	DestinationActor.DrawScale = 2;
	//	DestinationActor.Style = STY_Normal;
		DestinationActor.SetCollision( false, false, false );
	}
	else {
		//	if( HitActor == None )
			//	HitActor = Trace( HitLocation, HitNormal, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) ) + vector( Minst.MeshToWorldRotation( Minst.BoneGetRotate( bone ) ) ) * 10000, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) ), true );
				//broadcastmessage( "HITACTOR: "$HiTActor );
				//DestinationActor.SetLocation( Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) ) + vector( Minst.MeshToWorldRotation( Minst.BoneGetRotate( bone ) ) ) * 10000  );
				//DestinationActor.SetLocation( TestDot.Location + vector( TestDot.Rotation ) * 10000 );
				//broadcastmessage( "MOVING!!" );
				DestinationActor.SetLocation( Weapon.Location + vector( TestDot.Rotation ) * 10000 );
				//DestinationActor.SetLocation( TestPawn.Location );
	}
		//	else
		//		log( "Bone not found" );
				//	TestDot.Location + Vector( TestDot.Rotation ) * 10000 );
		//	else
		//	DestinationActor.SetLocation( HitLocation );
		//	MyPoint.SetLocation( DestinationActor.Location );
		//	MyPoint.SetRotation( rotator( HitNormal ) );
//	}


//	if( HitActor == WatchTarget )
//	{
//		bTriggerDisabled = true;
//		//bROADCASTMESSAGE( "sniping" );
//		GotoState( 'Sniping', 'Fire' );
//		return;
//	}		


	//DesiredRotation = rotation + rotator( RandOffset * 5 );
//	anAngle += 1.0484;

//	if( HitActor == WatchTarget )
//	{
//		log( "Going!" );
//		GotoState( 'Sniping', 'Fire' );
//		return;
//	}

	//RandOffset *= 0.98;

	if (LaserBeam == none)
	{
		LaserBeam = spawn(class'BeamSystem',Self,, Location + ( BaseEyeHeight * vect( 0, 0, 1 ) ) );
		Weapon.Mesh = dukemesh'w_SniperGun';
		TestDot = spawn( class'SniperPoint', Weapon );
		TestDot.AttachActorToParent( Weapon,true, true );
		TestDot.MountType = MOUNT_MeshBone;
		TestDot.MountMeshItem = 'MuzzleMount';
		TestDot.SetPhysics( PHYS_MovingBrush );
		TestDot.MountOrigin.Z = 6;

		LaserBeam.SetOwner( self );
		LaserBeam.AttachActorToParent( Weapon, true, true );
		LaserBeam.MountMeshItem = 'MuzzleMount';
		LaserBeam.MountType = MOUNT_MeshSurface;
		LaserBeam.SetPhysics( PHYS_MovingBrush );
		//LaserBeam.MountOrigin.X = 25;
		LaserBeam.MountOrigin.Z = 6;
		LaserBeam.BeamTexture = texture'a_generic.beam15arc';
		LaserBeam.BeamReversePanPass = true;
		LaserBeam.BeamTexturePanX = 0.2;
		LaserBeam.BeamTexturePanY = 0.0;
		LaserBeam.BeamTextureScaleX = 1.0;
		LaserBeam.BeamTextureScaleY = 1.0;
		LaserBeam.FlipHorizontal = false;
		LaserBeam.FlipVertical = false;
		LaserBeam.SubTextureCount = 1;
		LaserBeam.Style = STY_Translucent;
        LaserBeam.TesselationLevel = 5;
        LaserBeam.MaxAmplitude = 100.0;
        LaserBeam.MaxFrequency = 50.0;
        LaserBeam.Noise = 0.0;
        LaserBeam.BeamColor.R = 255;
        LaserBeam.BeamColor.G = 0;
        LaserBeam.BeamColor.B = 0;
        LaserBeam.BeamEndColor.R = 255;
        LaserBeam.BeamEndColor.G = 0;
        LaserBeam.BeamEndColor.B = 0;
        LaserBeam.BeamStartWidth = 1.1;
        LaserBeam.BeamEndWidth = 1.1;
        LaserBeam.BeamType = BST_Straight;
        LaserBeam.DepthCued = true;
		LaserBeam.Enabled = true;
        LaserBeam.TriggerType = BSTT_None;
        LaserBeam.BeamBrokenWhen = BBW_Never;
        LaserBeam.BeamBrokenAction = BBA_TriggerOwner;
        LaserBeam.NumberDestinations = 1;
        LaserBeam.DestinationActor[0] = DestinationActor;
		LaserBeam.DestinationOffset[0] = vect( 0, 0, 0 );
		LaserBeam.RemoteRole = ROLE_None;
		LaserBeam.BeamBrokenWhenClass = class'PlayerPawn';
        LaserBeam.BeamBrokenIgnoreWorld = false;
		LaserBeam.VisibilityRadius=30000;
		LaserBeam.bUseViewPortForZ = true;
		LaserBeam.bIgnoreBList = true;

	}
}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	if( LaserBeam != None )
		LaserBeam.Destroy();
	if( DestinationActor != None )
		DestinationActor.Destroy();

	Super.Died( Killer, DamageType, HitLocation );
}

state Sniping
{
	function SeePlayer( actor SeenPlayer )
	{
		if( SeenPlayer.IsA( 'PlayerPawn' ) )
		{
			TestDot2 = Spawn( class'SniperPoint', SeenPlayer );
			TestDot2.AttachActorToParent( SeenPlayer, true, true );
			TestDot2.MountType = Mount_MeshBone;
			TestDot2.SetPhysics(  PHYS_MovingBrush  );
			TestDot2.MountMeshItem = 'Chest';
			EnableHeadTracking( true );
			HeadTrackingActor = TestDot2;
			WatchTarget = Pawn( SeenPlayer );
			Enemy = WatchTarget;
			Disable( 'SeePlayer' );
			Disable( 'Timer' );
//		Enable( 'EnemyNotVisible' );
		}
	}

	function Timer( optional int TimerNum )
	{
		local PlayerPawn P;

		//foreach radiusactors( class'PlayerPawn', P, 10000 )
		//{
		//	WatchTarget = P;
		//	Disable( 'Timer' );
		//	break;
		//}
	}

	function Tick( float DeltaTime )
	{
	
		if( bIsTurning )
		{
			//broadcastmessage( "TURNING" );
			Destination = HeadTrackingActor.Location;
			RotationRate.Yaw = 22000;
		if( ( Rotator( Destination - Location ) - Rotation ).Yaw != 0 && ( Rotator( Destination - Location ) - rotation ).Yaw != -65536)
		{
			DesiredRotation = rotator( Destination - Location );
			if ((rotator(Destination - Location) - Rotation).Yaw < 0)
			{
				if( GetSequence( 2 ) != 'B_StepLeft' )
				{	
					PlayBottomAnim( 'B_StepLeft',, 0.13, true );
				}
			}
			else
			{
				if( GetSequence( 2 ) != 'B_StepRight' )
				{
					PlayBottomAnim( 'B_StepRight',, 0.13, true );
				}
			}
		}
		else if( GetSequence( 2 ) == 'B_StepLeft' || GetSequence( 2 ) == 'B_StepRight' )
		{
			PlayToWaiting( 0.22 );
			bIsTurning = false;
			RotationRate.Yaw = Default.RotationRate.Yaw;
		}
	}

		if( /*!bTriggerDisabled &&*/ WatchTarget != None )// && CanSee( WatchTarget ) )
		{
			//if( FRand() < 0.33 )
			//	RotationRate.Yaw = RandRange( 850, 2300 );
			MakeLaserBeam();
		}
/*		if( !CanSee( WatchTarget ) )
		{
			SetTimer( 2.0, true );
			Enable( 'SeePlayer' );
			if( LaserBeam != None )
			{
				if( LaserOffTime > 5.0 )
				{
					LaserBeam.Destroy();
					LaserBeam = None;
					DestinationActor.Destroy();
					DestinationActor = None;
					LaserOffTime = 0;
				}
				else
					LaserOffTime += DeltaTime;
			}
		}*/
		Super.Tick( DeltaTime );
	}
	
	function PlayerPawn FindPlayer()
	{
		local PlayerPawn P;

		foreach allactors( class'PlayerPawn', P )
		{
			return P;
		}
	}

	function BeginState()
	{
		Enable( 'Seeplayer' );
		Disable( 'EnemyNotVisible' );
		SetTimer( 2.0, true );
		RangeMod = 600;
		//RandOffset.Z = RandRange( 0, 15 );
		//RandOffset.Z = RandRange( -600, 600 );
		//	RandOffset.X = RandRange( -600, 600 );
	//	RandOffset.Y = RandRange( -600, 600 );

//		log( "---- "$self$" entered Sniping state" );
	}
//		MoveTo( Location - 64 * Normal( Location - FollowActor.Location), GetRunSpeed() );

Fire:
	Enemy = WatchTarget;
//	LaserBeam.Destroy();
//	LaserBeam = None;
	PlaySound( sound'SGCocking1', SLOT_None, SoundDampening * 0.97 );
	Sleep( 0.65 );
	bFire = 1;
	Weapon.TraceFire( Self );
	Weapon.GotoState('Firing');
	bFire = 0;
	Sleep( 2.0 );
	bTriggerDisabled = false;
	Goto( 'Waiting' );

Begin:

//	WatchTarget = FindPlayer();
	SetPhysics( PHYS_Falling );
	WaitForLanding();
	PlayToWaiting();

Waiting:

	//	TurnTo( ( Location + Normal( WatchTarget.Location - Location ) ) * 0.1 );
//	TurnTo( WatchTarget.Location + ( RandOffset * 0.2 ) );
	//TurnTo( WatchTarget.Location );
//	DesiredRotation.Pitch = 0;
	Sleep( 0.2 );
	Goto( 'Waiting' );
}

function PlayToWaiting( optional float TweenTime )
{
	Super.PlayToWaiting( TweenTime );
	//log( "PlayToWaiting called" );
	PlayTopAnim( 'T_SniperIdle',, 0.1, true );
}

function Trigger( actor OTher, pawn EventInstigator )
{
	local actor HitActor;
	local int Bone, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTexture ;
	local MeshInstance Minst;
	local vector HitLocation, HitNormal, EndTrace, StartTrace;
	local pawn p;

	//broadcastmessage( "SNIPER TRIGGERED!" );
	StartTrace = TestDot.Location;
	EndTrace = TestDot.Location /*+ ( BaseEyeHeight * vect( 0, 0, 1 ) )*/ + Vector( Weapon.Rotation ) * 10000;
	HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , true );
	//TestPawn = EventInstigator;

	foreach allactors( class'Pawn', P )
	{
		if( P.IsA( 'PlayerPawn' ) )
			TestPawn = P;
	}
	//Broadcastmessage( "TESTPAWN: "$TestPawn );

	//	broadcastMessage( "HITACTOR: "$HitActor );
	if( !HitActor.IsA( 'LevelInfo' ) )
	{
		if( !bTriggerDisabled )
		{
			bTriggerDisabled = true;
			GotoState( 'Sniping', 'Fire' );
		}
	}
}


auto state Waiting
{
		function Tick( float DeltaTime )
		{
			local Rotator Yaw1, Yaw2;
			if( bCanTrack )
			TickTracking( DeltaTime );

		if( bIsTurning )
		{
			//broadcastmessage( "TURNING" );
			//log( "TURNING" );
			Destination = HeadTrackingActor.Location;
			RotationRate.Yaw = 22000;
			Yaw1 = DesiredRotation;
			Yaw2 = Rotation;
			Yaw1.Pitch = 0;
			Yaw2.Pitch = 0;
			//log( "YAW1: "$Yaw1 );
			//log( "YAW2: "$Yaw2 );

		if( VSize( vector( Yaw1 ) - vector( Yaw2 ) ) != 0 )
		{
			DesiredRotation = rotator( Destination - Location );

			//log( "NOT EQUAL "$DesiredRotation.Yaw$" "$Rotation.Yaw );
			if ((rotator(Destination - Location) - Rotation).Yaw < 0)
			{
				if( GetSequence( 2 ) != 'B_StepLeft' )
				{	
					PlayBottomAnim( 'B_StepLeft',, 0.13, true );
				}
			}
			else
			{
				if( GetSequence( 2 ) != 'B_StepRight' )
				{
					PlayBottomAnim( 'B_StepRight',, 0.13, true );
				}
			}
		}
		else if( GetSequence( 2 ) == 'B_StepLeft' || GetSequence( 2 ) == 'B_StepRight' )
		{
//			log( "Calling PlayToWaiting" );
			PlayToWaiting( 0.22 );
			//log( "Setting bIsTurning to false" );
			bIsTurning = false;
			RotationRate.Yaw = Default.RotationRate.Yaw;
		}
	}


		//	if( PlayercanSeeMe() )
			if( /*!bTriggerDisabled &&*/ WatchTarget != None )// && CanSee( WatchTarget ) )
		{
			//if( FRand() < 0.33 )
			//	RotationRate.Yaw = RandRange( 850, 2300 );
			MakeLaserBeam();
		}
//		if( !CanSee( WatchTarget ) )
//		{
	//		SetTimer( 2.0, true );
	//		Enable( 'SeePlayer' );
	//		if( LaserBeam != None )
	//		{
	//			if( LaserOffTime > 5.0 )
	//			{
	//				LaserBeam.Destroy();
	//				LaserBeam = None;
	//				DestinationActor.Destroy();
	//				DestinationActor = None;
	//				LaserOffTime = 0;
	//			}
	//			else
	//				LaserOffTime += DeltaTime;
//			}
//		}
//		Super.Tick( DeltaTime );
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		local Pawn P;

		//broadcastmessage( "SEE PLAYER!" );
		if( EventInstigator.IsA( 'PlayerPawn' ) )
		{
			WatchTarget = EventInstigator;
			TestDot2 = Spawn( class'SniperPoint', EventInstigator );
			TestDot2.AttachActorToParent( EventInstigator, true, true );
			//TestDot2.DrawType = DT_Mesh;
		//TestDot2.Mesh = dukemesh'EDF1';
//		TestDot2.DrawScale = 15;
//		TestDot2.Style = STY_Normal;
			TestPawn = EventInstigator;
			TestDot2.MountType = Mount_MeshBone;
			TestDot2.SetPhysics(  PHYS_MovingBrush  );
			TestDot2.MountMeshItem = 'Chest';
			EnableHeadTracking( true );
			HeadTrackingActor = TestDot2;
			WatchTarget = EventInstigator;
			Enemy = WatchTarget;
			Disable( 'SeePlayer' );
			Disable( 'Timer' );
//		Enable( 'EnemyNotVisible' );
		}

		foreach allactors( class'Pawn', P )
		{
			if( P.IsA( 'PlayerPawn' ) )
			TempPawn = P;
		}
		//TempPawn = EventInstigator;
		GotoState( 'Waiting', 'Triggered' );
	}

	function AnimEndEx( int channel )
	{
		if( Channel == 2 && GetSequence( 2 ) == 'B_KneelDown' )
		{
			PlayBottomAnim( 'B_KneelIdle',, 0.1, true );
		}
	}

Triggered:
	Sleep( FMin( 0.2, FRand() ) );
	HeadTrackingActor = TempPawn;

Turning:
	AYaw1 = DesiredRotation;
	AYaw2 = Rotation;
	AYaw1.Pitch = 0;
	AYaw2.Pitch = 0;
	if( VSize( vector( AYaw1 ) - vector( AYaw2 ) ) != 0 )
	{
		//log( "Loop Turn" );
		bIsTurning = true;
		Sleep( 0.1 );
		Goto( 'Turning' );
	}
	//log( "DONE TURNING" );
	Enable( 'AnimEnd' );
	bRotateToDesired = false;
	PlayBottomAnim( 'B_KneelDown',, 0.1, false );
	SetCollisionSize( CollisionRadius, Default.CollisionHeight * 0.6 );
	SetPostureState( PS_Crouching, true );
	//log( "Out of crouch" );
	//bIsTurning = false;
	RotationRate.Yaw = 0;
	Disable( 'AnimEnd' );
	bCanTrack = true;
	Goto( 'End' );
	
Begin:
	//log( "Begin playToWaiting" );
	PlayToWaiting();

End:


}

simulated function bool EvalHeadLook()
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
	local float f;
	   local vector t;
	local rotator EyeLook, HeadLook, BodyLook;
	local rotator LookRotation;
	local float HeadFactor, ChestFactor, AbdomenFactor;
	local float PitchCompensation;
    
	local int RandHeadRot;

	if( !bCanTrack )
		return true;

	//log( "Eval HeadLook for "$self );

	minst = GetMeshInstance();
    if (minst==None || GetStateName() == 'Dying' )
        return(false);
	if( HeadTrackingActor == None )
	{
		//HeadTracking.DesiredRotation = Rotation;
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
	
	HeadLook = Normalize(HeadLook);
	
	HeadLook = Slerp(HeadTracking.Weight, rot(0,0,0), HeadLook);
//	}
//	else
	//r = Normalize(minst.WorldToMeshRotation(ClampHeadRotation(HeadTracking.DesiredRotation)));
	r = Normalize(ClampHeadRotation(HeadTracking.DesiredRotation) - Rotation);
	//BroadcastMessage("RenderDesired: "$r$" RenderCurrent: "$HeadLook);

	// blink the left eye
	EyeLook = minst.WorldToMeshRotation(EyeTracking.Rotation);
	//EyeLook = EyeTracking.Rotation - Rotation;
//	EyeLook = HeadLook - Rotation;
//	EyeLook = Normalize(EyeLook - HeadLook);
	if( bForceNoLookAround )
		EyeLook.yaw *= 0.2;
	else
		EyeLook.Yaw *= 0.125; // minimal eye movements cover large ground, so scale back rotation
	EyeLook = Slerp(EyeTracking.Weight, rot(0,0,0), EyeLook);

	if ( bCanTorsoTrack && ( Enemy != None || SpeechTarget != None || HeadTrackingActor != None ) ) // full body head look
	{
		LookRotation = HeadLook;

		HeadFactor = 0.45;
//		else
//		{
			HeadFactor = 0.25;
			ChestFactor = 1.0;
			AbdomenFactor = MyAbdomenFactor;
			PitchCompensation = 0.0;//0.25;
//		}

		bone = minst.BoneFindNamed('Abdomen');

		if (bone!=0 && bCanTorsoTrack )
		{
			if( TempAbdomenFactor > 0.0 )
				AbdomenFactor = TempAbdomenFactor;

			r = LookRotation;
		//	r = rot( r.Pitch*AbdomenFactor /*+ Abs(r.Yaw)*PitchCompensation*/, 0 + r.Yaw*PitchCompensation,-r.Yaw*AbdomenFactor);
			//= rot( r.Pitch * AbdomenFactor, 0, -r.Yaw * AbdomenFactor );
			r = rot( r.Pitch*AbdomenFactor + Abs(r.Yaw)*PitchCompensation,/* 0 + r.Yaw*PitchCompensation*/ 0,-r.Yaw*AbdomenFactor);
			minst.BoneSetRotate(bone, r, true, true);
		}
		bone = minst.BoneFindNamed('Chest');
		if (bone!=0 && bCanTorsoTrack )
		{
			//broadcastmessage( "ROTATING CHEST "$HeadTrackingActor );
			if( TempChestFactor > 0.0 )
				ChestFactor = TempChestFactor;
			r = LookRotation;
			r = rot(r.Pitch*ChestFactor, 0, 0/*-r.Yaw * ChestFactor*/);
	//		minst.BoneSetRotate(bone, r, true, true);
		}
		bone = minst.BoneFindNamed('Head');
		//if( !bCanTorsoTrack )
			//HeadFactor = 0.65;

		if( TempHeadFactor > 0.0 )
			HeadFactor = TempHeadFactor;

		if (bone!=0 )
		{
			r = LookRotation;
			r = rot( r.Pitch *HeadFactor ,0,-r.Yaw*HeadFactor);
			//r = rot( r.pitch, 0, -r.Yaw*HeadFactor );
			minst.BoneSetRotate(bone, r, true, true);
		}
	}
	else // head-only head look
	{
		LookRotation = HeadLook;
		bone = minst.BoneFindNamed('Head');
		if (bone!=0)
		{
			r = LookRotation;
			r = rot(r.Pitch,0,-r.Yaw);
			minst.BoneSetRotate(bone, r, false, true);
		}
	}
	// eye look
	//LookRotation = ClampEyeRotation( EyeLook );
	//return true;

	LookRotation = EyeLook;
	bone = minst.BoneFindNamed('Pupil_L');
	if (bone!=0)
	{			
		r = LookRotation;
		//r = Normalize(ClampEyeRotation(LookRotation) - Rotation);
		r = rot(r.pitch,0,-r.Yaw);
		//r = rot(r.Pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}
	bone = minst.BoneFindNamed('Pupil_R');
	if (bone!=0)
	{
		r = LookRotation;
		//r = Normalize(ClampEyeRotation(LookRotation) - Rotation);

		//r = rot(r.Pitch,0,-r.Yaw);
		r = rot(r.pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}
	return(true);
}

simulated event bool OnEvalBones(int Channel)
{
	//Log("ON EVAL BONES ROLE:"@Role@"RemoteRole:"@RemoteRole);

	if (!bHumanSkeleton)
		return false;

	// Update head.
    if (Channel == 8)
	{
		EvalBlinking();
		if( MonitorSoundLevel > 0.0 )
			EvalLipSync();
		EvalHeadLook();
		EvalShrinkRay();
	}

	// Update pelvis.
	if (Channel == 8)
	{
		if ( (GetPostureState() != PS_None) &&
			 (GetPostureState() != PS_Swimming) &&
			 (GetPostureState() != PS_Crouching) &&
             (GetPostureState() != PS_Rope) &&
             (GetPostureState() != PS_Ladder) &&
			 (GetPostureState() != PS_Jumping) &&
			 (GetPostureState() != PS_Turret) ) 
			 EvalPelvis();
	}

	return true;
}

event AnimTick(float DeltaTime)
{
	local int i;

	if ( bLaissezFaireBlending )
		return;

	// Update all the blending.
	TopAnimBlend     = UpdateRampingFloat(TopAnimBlend,     DesiredTopAnimBlend,     TopAnimBlendRate*DeltaTime);
	BottomAnimBlend  = UpdateRampingFloat(BottomAnimBlend,  DesiredBottomAnimBlend,  BottomAnimBlendRate*DeltaTime);
	SpecialAnimBlend = UpdateRampingFloat(SpecialAnimBlend, DesiredSpecialAnimBlend, SpecialAnimBlendRate*DeltaTime);

	GetMeshInstance();
	if (MeshInstance != None)
	{
		MeshInstance.MeshChannels[1].AnimBlend = TopAnimBlend;
		MeshInstance.MeshChannels[2].AnimBlend = BottomAnimBlend;
		MeshInstance.MeshChannels[3].AnimBlend = SpecialAnimBlend;

        // If we have reached a blending >= 1.0 then set the animsequence to 'None'
		if ( DesiredTopAnimBlend>=1.0 && TopAnimBlend>=1.0 )
        {
            MeshInstance.MeshChannels[1].AnimSequence = 'None';
        }
		if ( DesiredBottomAnimBlend>=1.0 && BottomAnimBlend>=1.0 )
        {
            MeshInstance.MeshChannels[2].AnimSequence = 'None';
        }
		if ( DesiredSpecialAnimBlend>=1.0 && SpecialAnimBlend>=1.0 )
        {
            MeshInstance.MeshChannels[3].AnimSequence = 'None';
        }
	}

	// Update alert status.
	if ((AlertTimer > 0.0) && (GetUpperBodyState() == UB_Alert) && (Weapon != None) && (!Weapon.StayAlert))
	{
		AlertTimer -= DeltaTime;
		if (AlertTimer < 0.0)
		{
			AlertTimer = 0.0;
			SetUpperBodyState(UB_Relaxed);
		}
	}
}

function TickTracking(float inDeltaTime)
{
	local rotator r;
	//EvalHeadLook();
	// update head tracking
	//log( "TICK TRACKING FOR "$self );
	if( HeadTrackingActor != None )
		TorsoTracking.DesiredRotation = rotator( Location - HeadTrackingActor.Location );

	TorsoTracking.Weight = UpdateRampingFloat(TorsoTracking.Weight, TorsoTracking.DesiredWeight, TorsoTracking.WeightRate*inDeltaTime);
	TorsoTracking.Weight = 0;

	if( HeadTrackingActor != None )
	{
		HeadTracking.DesiredWeight = 1.0;
	}
	else
	{
		HeadTracking.DesiredWeight = 1.0;
	}
	if (HeadTracking.TrackTimer <= 0.0 && FRand() < 0.25 && HeadTrackingActor == None && Enemy == None && GetStateName() != 'ActivityControl' )
	{
		HeadTracking.TrackTimer = 2.5 + FRand()*1.5;
		//HeadTracking.DesiredRotation = Normalize(Rotation + rot(0, int(FRand()*16384.0 - 8192.0), 0));

		HeadTracking.DesiredRotation = RotRand();
		HeadTracking.DesiredRotation.Pitch *= 0.05;
		HeadTracking.DesiredRotation.Roll = 0;
	}

	if (HeadTracking.TrackTimer > 0.0)
	{
		HeadTracking.TrackTimer -= inDeltaTime;
		if (HeadTracking.TrackTimer < 0.0)
			HeadTracking.TrackTimer = 0.0;
	}
/*
	if( HeadTracking.TrackTimer <= 0.0 )
	{
		log( "Initializing" );
		HeadTracking.TrackTimer = 0.5 + FRand() * 1.5;
		HeadTracking.DesiredRotation = RotRand();
		//HeadTracking.DesiredRotation.Pitch = 0;
		HeadTracking.DesiredRotation.Roll = 0;
	}
*/
	HeadTracking.Weight = UpdateRampingFloat(HeadTracking.Weight, HeadTracking.DesiredWeight, HeadTracking.WeightRate*inDeltaTime);
	r = ClampHeadRotation(HeadTracking.DesiredRotation);
	HeadTracking.Rotation.Pitch = FixedTurn(HeadTracking.Rotation.Pitch, r.Pitch, int(HeadTracking.RotationRate.Pitch * inDeltaTime));
	HeadTracking.Rotation.Yaw = FixedTurn(HeadTracking.Rotation.Yaw, r.Yaw, int(HeadTracking.RotationRate.Yaw * inDeltaTime));
	HeadTracking.Rotation.Roll = FixedTurn(HeadTracking.Rotation.Roll, r.Roll, int(HeadTracking.RotationRate.Roll * inDeltaTime));
	HeadTracking.Rotation = ClampHeadRotation(HeadTracking.Rotation);

	// update eye tracking
	if (EyeTracking.TrackTimer > 0.0)
	{
		if( HeadTrackingActor != None && EyeTracking.DesiredRotation != Normalize( rotator( normal( HeadTrackingLocation - Location ) ) ) )
		{
			EyeTracking.TrackTimer = 0.0;
		}

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

	// temporary - random target testing


	
	if (EyeTracking.TrackTimer <= 0.0 )
	{
		EyeTracking.TrackTimer = 0.5 + FRand()*1.5;
		if( HeadTrackingActor == None )
		{	
			EyeTracking.DesiredRotation = Normalize(Rotation + rot(0, int(FRand()*20384.0 - 8192.0), 0));
		}
		else
		{
			EyeTracking.DesiredRotation = Normalize( rotator( normal( HeadTrackingLocation - Location ) ) ) + rot( 0, int( FRand()* 140384.0 - 8192.0), 0);
		}
	//	EyeTracking.DesiredRotation = Normalize( RotRand() );
	//	EyeTracking.DesiredRotation.Pitch = 0;
		EyeTracking.DesiredRotation.Roll = 0;
	}

	if (HeadTrackingActor!=None)
	{
		HeadTrackingLocation = HeadTrackingActor.Location; //* PitchMod );
		//broadcastmessage( "PITCHMOD: "$Pitchmod );
		if( bPitchUp )
		{
			PitchMod += 1;
			if( PitchMod > 80 )
			{
				bPitchUp = false;
				PitchMod = 80;
			}
		}

		else if( !bPitchUp )
		{
			PitchMod -= 1;
			if( PitchMod <= 50 )
			{
				bPitchUp = true;
				PitchMod = 50;
			}
		}
		
		Weapon.Mesh = dukemesh'w_snipergun';
		HeadTracking.DesiredRotation = Normalize(rotator(Normal(HeadTrackingLocation - TestDot.Location)));

		//HeadTracking.DesiredRotation.Pitch = 0;
		HeadTracking.DesiredRotation.Roll = 0;

	}
	//EyeTracking.DesiredRotation.Yaw = HeadTracking.DesiredRotation.Yaw;
//	EyeTracking.DesiredRotation.Yaw = Rand( 256 );
	//EyeTracking.DesiredRotation = RotRand();
	//log( "EyeTracking desired rotation yaw: "$EyeTracking.DesiredRotation.yaw );
	//EyeTracking.DesiredRotation.Pitch = 0;
	//EyeTracking.DesiredRotation.Roll = 0;
}


defaultproperties
{
	bForcePeriphery=false
    VisibilityRadius=108000
	bNoRotConstraint=true
	//     bExplicitCover=True
	RotationRate=(Pitch=1,Yaw=8000,Roll=2048)
    PeripheralVision=-1.0
	bAggressiveToPlayer=true
	bSniper=true
     EgoKillValue=8
     Mesh=DukeMesh'c_characters.EDF_Sniper'
     WeaponInfo(0)=(WeaponClass="dnGame.SniperRifle",PrimaryAmmoCount=500,altAmmoCount=50)
	 WeaponInfo(1)=(WeaponClass="")
	 WeaponInfo(2)=(WeaponClass="")
	 WeaponInfo(3)=(WeaponClass="")
     Health=50
     BaseEyeHeight=27.000000
     EyeHeight=27.000000
     GroundSpeed=420.000000
     bIsHuman=True
     CollisionRadius=17.000000
     CollisionHeight=39.000000
     bSnatched=false
	 bUseViewPortForZ=true
	 SightRadius=230000
	 MyAbdomenFactor=0.75
}
