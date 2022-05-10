//=============================================================================
// EDFSniper.uc
//=============================================================================
class EDFSniper extends HumanNPC;

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
var SniperPoint MyPoint;
var float LaserOffTime;
var float XM, YM, ZM;
var SniperPoint TestDot;


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
		//DestinationActor.DrawType = DT_Mesh;
		//DestinationActor.Mesh = dukemesh'EDF1';
		//DestinationActor.DrawScale = 15;
		//DestinationActor.Style = STY_Normal;
		DestinationActor.SetCollision( false, false, false );
	}
	else {
			//if( HitActor == None )
			//	DestinationActor.SetLocation( Location + Vector( ViewRotation ) * 10000 );
			//else
		/*	DestinationActor.SetLocation( HitLocation ); */
				Weapon.Mesh = dukemesh'w_snipergun';
			Minst = Weapon.GetMeshInstance();
			bone = Minst.BoneFindNamed( 'MuzzleMount' );
			
			if( bone != 0 )
			{
			//	HitActor = Trace( HitLocation, HitNormal, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) ) + vector( Minst.MeshToWorldRotation( Minst.BoneGetRotate( bone ) ) ) * 10000, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) ), true );
				//broadcastmessage( "HITACTOR: "$HiTActor );
				//DestinationActor.SetLocation( Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, false ) ) + vector( Minst.MeshToWorldRotation( Minst.BoneGetRotate( bone ) ) ) * 10000  );
				//DestinationActor.SetLocation( TestDot.Location + vector( TestDot.Rotation ) * 10000 );
				DestinationActor.SetLocation( Weapon.Location + vector( ViewRotation ) * 10000 );
			}
				//	TestDot.Location + Vector( TestDot.Rotation ) * 10000 );
		//	else
		//	DestinationActor.SetLocation( HitLocation );
		//	MyPoint.SetLocation( DestinationActor.Location );
		//	MyPoint.SetRotation( rotator( HitNormal ) );
		//	MyPoint.SetLocation( DestinationActor.Location );
		//	MyPoint.SetRotation( rotator( HitNormal ) );
	}


//	if( HitActor == WatchTarget )
//	{
//		bTriggerDisabled = true;
//		//bROADCASTMESSAGE( "sniping" );
//		GotoState( 'Sniping', 'Fire' );
//		return;
//	}		


	//DesiredRotation = rotation + rotator( RandOffset * 5 );
	anAngle += 1.0484;

//	if( HitActor == WatchTarget )
//	{
//		log( "Going!" );
//		GotoState( 'Sniping', 'Fire' );
//		return;
//	}

	//RandOffset *= 0.98;

	if (LaserBeam == none)
	{
		TestDot = spawn( class'SniperPoint', Weapon );
		TestDot.AttachActorToParent( Weapon,true, true );
		TestDot.MountType = MOUNT_MeshBone;
		TestDot.MountMeshItem = 'MuzzleMount';
		TestDot.SetPhysics( PHYS_MovingBrush );
		TestDot.MountOrigin.Z = 6;

		LaserBeam = spawn(class'BeamSystem',Self,, Location + ( BaseEyeHeight * vect( 0, 0, 1 ) ) );
		LaserBeam.SetOwner( Weapon );
		LaserBeam.AttachActorToParent( Weapon, true, true );
		LaserBeam.MountMeshItem = 'MuzzleMount';
		LaserBeam.MountType = MOUNT_MeshBone;
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
        LaserBeam.BeamBrokenWhen = BBW_PlayerProximity;
        LaserBeam.BeamBrokenAction = BBA_TriggerOwner;
        LaserBeam.NumberDestinations = 1;
        LaserBeam.DestinationActor[0] = DestinationActor;
//		LaserBeam.DestinationOffset[0] = Offset;
		LaserBeam.RemoteRole = ROLE_None;
		LaserBeam.BeamBrokenWhenClass = class'Actor';
        LaserBeam.BeamBrokenIgnoreWorld = true;
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

auto state Sniping
{
	ignores SeePlayer, TakeDamage, SeeMonster, EnemyNotVisible, Bump;
}

state TestState
{
	function SeePlayer( actor SeenPlayer )
	{
		//broadcastmessage( "SEE PLAYER!" );
		if( SeenPlayer.IsA( 'PlayerPawn' ) )
		{
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
		if( /*!bTriggerDisabled &&*/ WatchTarget != None )// && CanSee( WatchTarget ) )
		{
			//if( FRand() < 0.33 )
			//	RotationRate.Yaw = RandRange( 850, 2300 );
			MakeLaserBeam();
		}
		if( !CanSee( WatchTarget ) )
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
		}
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
	PlayTopAnim( 'T_SniperIdle',, 0.1, true );
}

function Trigger( actor OTher, pawn EventInstigator )
{
	local actor HitActor;
	local int Bone, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTexture ;
	local MeshInstance Minst;
	local vector HitLocation, HitNormal, EndTrace, StartTrace;

	StartTrace = Location;
	EndTrace = Location /*+ ( BaseEyeHeight * vect( 0, 0, 1 ) )*/ + Vector( ViewRotation ) * 10000;
	HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , true );
//	broadcastMessage( "HITACTOR: "$HitActor );
	if( HitActor == WatchTarget )
	{
		if( !bTriggerDisabled )
		{
			bTriggerDisabled = true;
			GotoState( 'Sniping', 'Fire' );
		}
	}
}

defaultproperties
{
	bForcePeriphery=false
    VisibilityRadius=8000
	bNoRotConstraint=true
	//     bExplicitCover=True
	RotationRate=(Pitch=1,Yaw=999,Roll=2048)
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
	 SightRadius=30000
}
