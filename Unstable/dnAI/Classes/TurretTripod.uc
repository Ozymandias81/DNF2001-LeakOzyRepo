class TurretTripod extends Turrets;

// Bones: rotate, gun
// Anims:  
// Activate
// Deactivate
// Off
// On
// Turret_TripodCRPSE (Corpse )


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
			HeadTrackingActor = MyTarget;
			if( ( HeadTracking.Rotation.Yaw - HeadTracking.DesiredRotation.Yaw ) < 64 && ( HeadTracking.Rotation.Yaw - HeadTracking.DesiredRotation.Yaw ) > -64 )
			{
				bCanFire = true;
			}
			else
				bCanFire = false;
		}	
		minst = GetMeshInstance();
	    if (minst==None || GetStateName() == 'Dying' )
	        return(false);

		HeadTracking.Weight = 1.0;
		HeadTracking.DesiredWeight = 1.0;
		bone = minst.BoneFindNamed('Rotate');
		HeadLook = Normalize( ( Rotation ) - HeadTracking.Rotation );
		LastHeadLook = HeadLook;
		HeadLook = Slerp(HeadTracking.Weight, rot(0,0,0), HeadLook);
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
			r = rot( 0, r.Pitch, 0 );
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

		if (HeadTrackingActor!=None)
		{
			if( HeadTrackingActor.IsA( 'PlayerPawn' ) )
			{
				if( !bContinuingFire )
				{
					Minst = HeadTrackingActor.GetMeshInstance();
					Minst2 = GetMeshInstance();
			
					if(	FRand() < 0.25 )
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
						EnemyLastPOsition = HeadTrackingLocation;
						HeadTracking.DesiredRotation = rotator( Normal( HeadTrackingLocation - Minst2.MeshToWorldLocation( Minst2.BoneGetTranslate( bone2, true, false ) ) ) );
						HeadTracking.DesiredRotation.Roll = 0;
					}
				}
				else
				{
					HeadTrackingLocation = EnemyLastPosition;
					HeadTracking.DesiredRotation = rotator( Normal( HeadTrackingLocation - Location ) );
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

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local Carcass c;
	local CreaturePawnCarcass CPC;

	local SoftParticleSystem a;
	local Tentacle T;
	local meshinstance Minst, CMinst;

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

DefaultProperties
{
}

