class TurretCeiling extends Turrets;

// Bones: rotate, gun
// Anims:  
// Activate
// Deactivate
// Off
// On

// Turret_TripodCRPSE

function PostBeginPlay()
{
	local MeshInstance Minst;
	local int bone;
	local rotator StartRot;

	HeadTracking.RotationRate.Yaw = YawRate;
	Minst = GetMeshInstance();
	Bone = Minst.BoneFindNamed( 'Rotate' );
	StartRot = Minst.BoneGetRotate( Bone, false );
	Minst.BoneSetRotate( Bone, ( StartRot * -1 ), true, true );
	SetRotation( Rotation * -1 );
	MountExtremities();
	Super.PostBeginPlay();
}

simulated function bool EvalHeadLook()
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
	local float f;
	local rotator LookRotation, HeadLook;
	local float HeadFactor, ChestFactor, AbdomenFactor;
	local float PitchCompensation;
    
	local int RandHeadRot;

	if( bOn )
	{
		if( MyTarget != None )
		{
			if( ( HeadTracking.Rotation.Yaw - HeadTracking.DesiredRotation.Yaw ) < 64 && ( HeadTracking.Rotation.Yaw - HeadTracking.DesiredRotation.Yaw ) > -64 )
			{
				bCanFire = true;
			}
			else
				bCanFire = false;
		}
		if( MyTarget != None )
			HeadTrackingActor = MyTarget;
		minst = GetMeshInstance();
		if (minst==None || GetStateName() == 'Dying' )
	        return(false);
		HeadTracking.Weight = 1.0;
		HeadTracking.DesiredWeight = 1.0;
		bone = minst.BoneFindNamed('Rotate');
		HeadLook = Normalize( ( HeadTracking.Rotation ) - ( Rotation ) );
		LastHeadLook = HeadLook;
		HeadLook = Slerp(HeadTracking.Weight, rot( 0, 0, 0 ), HeadLook);
		LookRotation = HeadLook;
		bone = minst.BoneFindNamed('Rotate');
		if (bone!=0 )
		{
			r = LookRotation;
     		r = rot( 0 ,0,-r.Yaw ); //HeadFactor);
			Minst.BoneSetRotate(bone, R, true, true);
		}
		bone = minst.BoneFindNamed( 'Gun' );
		if( bone != 0 )
		{
			r = LookRotation;
			r = rot( 0, -r.Pitch, 0 );
			Minst.BoneSetRotate( bone, R, true, true );
		}
	}
	else if( bResetting )
	{
		Minst = GetMeshInstance();
		bone = minst.BoneFindNamed( 'Rotate' );
		HeadLook = Normalize( Rotation - HeadTracking.Rotation );
		HeadLook = Slerp( HeadTracking.Weight, rot( 0, 0, 0 ), HeadLook );
		if( bone != 0 )
		{
			r = HeadLook;
			r = rot( 0, 0, -r.Yaw );
			Minst.BoneSetRotate( bone, R, true, true );
		}
		bone = minst.BoneFindNamed( 'Gun' );
		if( bone != 0 )
		{
			r = LookRotation;
			Minst.BoneSetRotate( bone, R, true, true );
		}
	}
	return(true);
}

function TickTracking(float inDeltaTime)
{
	local rotator r;
	local int bone, bone2;
	local meshinstance minst, minst2;
	local vector BoneLocation;
	local name TargetBoneName;

	if( bOn )
	{
		if( HeadTrackingActor != None )
		{
			HeadTracking.DesiredWeight = 1.0;
		}
		else
		{
			HeadTracking.DesiredRotation = Rotation;
		}

		if (HeadTracking.TrackTimer > 0.0)
		{
			HeadTracking.TrackTimer -= inDeltaTime;
			if (HeadTracking.TrackTimer < 0.0)
				HeadTracking.TrackTimer = 0.0;
		}
		
		HeadTracking.Weight = UpdateRampingFloat(HeadTracking.Weight, HeadTracking.DesiredWeight, HeadTracking.WeightRate*inDeltaTime);
		r = ClampHeadRotation(HeadTracking.DesiredRotation);
		HeadTracking.Rotation.Pitch = FixedTurn(HeadTracking.Rotation.Pitch, r.Pitch, int(HeadTracking.RotationRate.Pitch * inDeltaTime));
		HeadTracking.Rotation.Yaw = FixedTurn(HeadTracking.Rotation.Yaw, r.Yaw, int(HeadTracking.RotationRate.Yaw * inDeltaTime));
		HeadTracking.Rotation.Roll = FixedTurn(HeadTracking.Rotation.Roll, r.Roll, int(HeadTracking.RotationRate.Roll * inDeltaTime));
		HeadTracking.Rotation = ClampHeadRotation(HeadTracking.Rotation);

		if(HeadTrackingActor!=None)
		{
			if( HeadTrackingActor.IsA( 'PlayerPawn' ) )
			{
				if( !bContinuingFire )
				{
					Minst = HeadTrackingActor.GetMeshInstance();
					Minst2 = GetMeshInstance();
					if( FRand() < 0.25 )
					{
						bone = Minst.BoneFindNamed( 'Head' );
					}
					else
						bone = Minst.bonefindnamed( 'chest' );
					bone2 = Minst2.bonefindnamed( 'Rotate' );
	
					if( bone != 0 )
					{
						BoneLocation = Minst.BoneGetTranslate( bone, true, false );
						BoneLocation = Minst.MeshToWorldLocation( BoneLocation );
						HeadTrackingLocation = BoneLocation;
						EnemyLastPosition = HeadTrackingLocation;
						HeadTracking.DesiredRotation = Normalize( Rotator( Minst2.MeshToWorldLocation( Minst2.BoneGetTranslate( bone2, true, false ) ) - HeadTrackingLocation ) );
						HeadTracking.DesiredRotation.Roll = 0;
					}
				}
				else
				{
					HeadTrackingLocation = EnemyLastPosition;
					HeadTracking.DesiredRotation = rotator( Normal(  Location - HeadTrackingLocation ) );
					HeadTracking.DesiredRotation.Roll = 0;
				}
			}
			else
			{
				HeadTrackingLocation = MyTarget.Location - vect( 0, 0, 24 );
				HeadTracking.DesiredRotation = rotator(Normal(HeadTrackingLocation - Location));
				HeadTracking.DesiredRotation.Roll = 0;
			}
		}
		else if( bResetting )
		{
			HeadTracking.DesiredRotation =  Normalize( Rotation );
			if( HeadTracking.Rotation == HeadTracking.DesiredRotation )
			{
				bCanTurnOff = true;
				GotoState( 'Turret', 'Deactivate' );
			}
		}
	}
}

simulated function DropShell()
{
	local vector realLoc, X, Y, Z;	
	local SoftParticleSystem.Particle p;
	local int pIndex;
	local meshinstance minst;
	local int bone;


	if (ShellMaster3rd==None)
	{
		ShellMaster3rd = spawn(class'dnShellCaseMaster', self, '', MyWeaponMount.Location, MyWeaponMount.Rotation);
	//	ShellMaster3rd.bOwnerSeeSpecial = true;
		ShellMaster3rd.Mesh = mesh'm16shell';
		ShellMaster3rd.DrawScale *= 5;
		ShellMaster3rd.bHidden = false;
		ShellMaster3rd.AttachActorToParent( self, true, true );
		ShellMaster3rd.MountMeshItem = 'Shells';
		ShellMaster3rd.MountType = MOUNT_MeshSurface;
		ShellMaster3rd.SetPhysics( PHYS_MovingBrush );
	}

	pIndex = ShellMaster3rd.SpawnParticle(1);
	if (pIndex!=-1)
	{
		ShellMaster3rd.GetParticle(pIndex, p);
		p.Rotation3d = MyWeaponMount.Rotation;
		p.Location = ShellMaster3rd.Location;
		Minst = GetMeshInstance();
		bone = Minst.bonefindnamed( 'Rotate' );

	//	p.Velocity = vector( MyWeaponMount.Rotation ) - vect( 0, -1, 0 ) ) * 350;	
		//	sideDir = Normal( Normal(Enemy.Location - Location) Cross vect(0,0,1) );
		p.velocity =  -1 * ( Normal( MyWeaponMount.Location - p.Location ) Cross vect( 0, 0, 1 ) * 500 );
		p.RotationVelocity3D = RotRand();
		p.RotationVelocity3D.Pitch = FRand()*200000.0 - 100000.0;
		p.RotationVelocity3D.Yaw = FRand()*200000.0 - 100000.0;
		p.RotationVelocity3D.Roll = FRand()*200000.0 - 100000.0;
		
		ShellMaster3rd.SetParticle(pIndex, p);
	}
}


function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local Carcass c;
	local CreaturePawnCarcass CPC;

	local SoftParticleSystem a;
	local Tentacle T;
	local meshinstance Minst, CMinst;

	//HurtRadius(10, CollisionRadius, 'exploded', 0, Location);
	//spawn(class'BallExplosion',,,Location);
	//return None;


	c = Spawn( CarcassType );
	c.Mesh = dukemesh'c_dnWeapon.Turret_TripodCrpse';
	
	if( FRand() < 0.5 )
	{
		c.PlayAnim( 'DeathB' );
	}
	else
		c.PlayAnim( 'deatha' );

	return c;
}

auto state Startup
{
	ignores SeePlayer;

	function Trigger( actor Other, Pawn EventInstigator )
	{
		GotoState( 'Turret' );
	}

Begin:
	SetPhysics( PHYS_None );
	if( bInitiallyOn )
		GotoState( 'Turret' );
}

DefaultProperties
{
    CollisionHeight=6
	Health=50
	CarcassType=Class'RobotPawnCarcass'
	bSteelSkin=true
	bUseTriggered=true
	DrawType=DT_Mesh
	Mesh=dukemesh'c_dnweapon.Turret_Ceiling'
    HeadTracking=(RotationRate=(Pitch=2000,Yaw=8500),RotationConstraints=(Pitch=6000, Yaw=500))
	PeripheralVision=-1.00
	YawRate=8500
	AggressionDistance=512
}

