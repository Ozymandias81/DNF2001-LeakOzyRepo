/*-----------------------------------------------------------------------------
	ControllableTurret
	Author: Brandon Reinhart

	It's Roll not Yaw, because it "rolls" relative to the base.
	(Don't ask me, that's how the bones are set up.)
-----------------------------------------------------------------------------*/
class ControllableTurret extends dnDecoration
	abstract;

#exec OBJ LOAD FILE=..\Textures\m_turretfx.dtx
#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx

// Bone manipulation.
var int RotateBone, BaseBone, GunBone;
var int RotateRoll, SimRotateRoll;
var int RotatePitch, SimRotatePitch;
var() int MaxPitch, MinPitch;
var() int MaxRoll, MinRoll;
var int AnimMaxPitch, AnimMinPitch;
var int AnimMaxRoll, AnimMinRoll;
var() bool bClampRoll;

// Controller
var PlayerPawn InputActor, OldInputActor;
var CTViewActor ViewMapper;
var bool bInterlock, bLocalControl, bServerControl;

// Rotation lerping.
var rotator ViewRotation;
var bool bLerpingRot;
var rotator ViewRotationRate;

// Location lerping.
var vector ViewLocation;
var bool bLerpingLot, bLerpingDownX, bLerpingDownY, bLerpingDownZ;
var vector MoveRate;

// Animation blending.
var float AnimBlendFactor;

// Fire detection.
var byte OldbFire, bFiring;
var bool bSavedFire;

// Witty comments.
var sound SomethingWitty[3];

// Player usage control.
var() sound StayInYourSeatSound[3];
var() int NumStayInSeatSounds;
var() bool bLockPlayerOnUse;
var bool bPlayerLockedIn;

// Alt fire is an event.
var() name AltFireEvent;
var byte OldbAltFire, bAltFiring;

// Video screen.
var TextureCanvas CanvasTop;
var TextureCanvas CanvasBot;
var SmackerTexture IntroBot;
var SmackerTexture IntroTop;
var SmackerTexture CropMarksLeft, CropMarksRight;
var SmackerTexture TemperatureGauge;
var Texture Background, Overheat;
var bool bInterpolating, bPlayingIntro, bDirtyTop, bDirtyBot, bOverheated;
var int LastIntroFrameTop, LastIntroFrameBot, CropFrame;
var float OverheatTime, MaxOverheatTime;

// Sticky bomb blast check.
var bool bBlowUpStickies;

replication
{
	reliable if ( Role == ROLE_Authority )
		InputActor, SimRotateRoll, SimRotatePitch, bFiring, bAltFiring, MinRoll, MaxRoll;
	reliable if ( Role < ROLE_Authority )
		bBlowUpStickies;
}

simulated function PostBeginPlay()
{
	local vector t;
	local rotator r;

	Super.PostBeginPlay();

	// Get the mesh instance.
	GetMeshInstance();
	if ( MeshInstance == None )
		return;

	// Find the bones so we don't have to do it later.
	BaseBone	= MeshInstance.BoneFindNamed( 'Base' );
	RotateBone	= MeshInstance.BoneFindNamed( 'Rotate' );
	GunBone		= MeshInstance.BoneFindNamed( 'Gun' );

	// Mount a view target.
	ViewMapper = spawn(class'CTViewActor');
	ViewMapper.MountType = MOUNT_MeshBone;
	ViewMapper.MountMeshItem = 'Gun';
	ViewMapper.MountOrigin.Z = 10;
	ViewMapper.MountOrigin.X = 23;
	ViewMapper.SetPhysics( PHYS_MovingBrush );
	ViewMapper.AttachActorToParent( Self, false, false );
	ViewMapper.DrawScale = 0.1;
	ViewMapper.RemoteRole = ROLE_None;

	// Clamp min/max pitch/roll to be at least the animation requirements.
	if ( MaxPitch > AnimMaxPitch )	MaxPitch = AnimMaxPitch;
	if ( MinPitch < AnimMinPitch )	MinPitch = AnimMinPitch;
	if ( MaxRoll > AnimMaxRoll )	MaxRoll = AnimMaxRoll;
	if ( MinRoll < AnimMinRoll )	MinRoll = AnimMinRoll;

	if ( Role == ROLE_Authority )
	{
		// Add our actor rotation to the min/max roll.
		MinRoll += Rotation.Yaw;
		MaxRoll += Rotation.Yaw;

		SimRotateRoll = Rotation.Yaw;
		RotateRoll = Rotation.Yaw;
	}

	CanvasTop = TextureCanvas( MeshGetTexture( 6 ) );
	CanvasBot = TextureCanvas( MeshGetTexture( 7 ) );

	SetCallbackTimer( 0.2, true, 'CheckStickies' );
}

simulated function Destroyed()
{
	EndCallbackTimer( 'CheckStickies' );
	ViewMapper.Destroy();

	Super.Destroyed();
}

// Periodically check to see if there are proximity bombs that might blow up due to our motion.
simulated function CheckStickies()
{
	local StickyBomb B;

	if ( !bBlowUpStickies )
		return;

	foreach VisibleActors( class'StickyBomb', B, 150 )
	{
		B.Explode( B.Location );
	}

	bBlowUpStickies = false;
}

// Server / Singleplayer Stuff
event Used( Actor Other, Pawn EventInstigator )
{
	local vector t;

	if ( !Other.IsA('PlayerPawn') )
		return;

	if ( PlayerPawn(Other).Shrunken() )
		return;

	if ( (InputActor == Other) && bServerControl )
	{
		// Relinquish control if used again by our controller.
		if ( !bPlayerLockedIn )
			Relinquish();
		return;
	}
	else if ( (InputActor != None) && (InputActor != Other) )
	{
		// Prevent others from using us when we are in use.
		return;
	}

	// Acquire the player.
	bInterlock = true;
	InputActor = PlayerPawn(Other);
	bPlayerLockedIn = bLockPlayerOnUse;

	// Say something witty.
	if ( Level.NetMode == NM_Standalone )
	{
		if ( FRand() > 0.7 )
			InputActor.DukeVoice.DukeSay( SomethingWitty[Rand(3)] );
	}

	// Mount the player.
	bServerControl = true;
	InputActor.MountType = MOUNT_MeshBone;
	InputActor.MountMeshItem = 'Rotate';
	InputActor.MountOrigin.Z = 0;
	InputActor.MountOrigin.Y = 0;
	InputActor.MountOrigin.Z = 63;
	InputActor.MountAngles.Pitch = -16384;
	InputActor.MountAngles.Yaw = 0;
	InputActor.MountAngles.Roll = 0;
	InputActor.AttachActorToParent( Self, false, false );
	InputActor.bSimFall = true;
	InputActor.bCanFly = true;
	InputActor.bOnTurret = true;
	InputActor.SetPhysics( PHYS_MovingBrush );
	InputActor.SetCollision( InputActor.bCollideActors, false, false );
	InputActor.SetPostureState( PS_Turret );
	InputActor.SetUpperBodyState( UB_Turret );
	InputActor.bLaissezFaireBlending = true;
	InputActor.ViewMapper = Self;
	ViewMapper.bUseViewportForZ = true;

	// Put the weapon down.
	InputActor.WeaponDown( false, true );

	// Set the animations we'll blend between.
	InputActor.PlayAllAnim( 'none' );
	InputActor.PlayTopAnim( 'none' );
	InputActor.PlayBottomAnim( 'none' );

	// Make sure we are drawn.
	bUseViewportForZ = true;

	// Make sure nothing plays on screen.
	bInterpolating = true;
}

// Client stuff / Singleplayer stuff.
simulated event ClientUsed( Actor Other, Pawn EventInstigator )
{
	if ( !Other.IsA('PlayerPawn') )
		return;

	if ( PlayerPawn(Other).Shrunken() )
		return;

	if ( (InputActor == Other) )
	{
		// Remove control if used again by our user.
		if ( !bPlayerLockedIn && (Level.NetMode == NM_Client) )
			Relinquish();
		if ( bPlayerLockedIn )
			PlaySound( StayInYourSeatSound[Rand(NumStayInSeatSounds)], SLOT_Interact, 1.0, true );
		return;
	}
	
	// Don't let someone use us while we are in use.
	if ( InputActor != None )
		return;

	// Acquire the player.
	bInterlock = true;
	InputActor = PlayerPawn(Other);
	bPlayerLockedIn = bLockPlayerOnUse;
	ViewMapper.bUseViewportForZ = true;
	bLocalControl = true;

	// Setup our input hook.
	InputActor.ViewMapper = Self;
	InputActor.VehicleRoll  = RotateRoll;
	InputActor.VehiclePitch = RotatePitch;

	// Set the animations we'll blend between.
	InputActor.SetPostureState( PS_Turret );
	InputActor.SetUpperBodyState( UB_Turret );
	InputActor.bLaissezFaireBlending = true;
	InputActor.PlayAllAnim( 'none' );
	InputActor.PlayTopAnim( 'none' );
	InputActor.PlayBottomAnim( 'none' );

	// Make sure we are drawn.
	bUseViewportForZ = true;

	// Interpolation interrupt timer.
	SetCallbackTimer( 1.0, false, 'InterpolationInterrupt' );

	// Prepare to lerp rotation.
	bLerpingRot = true;
	ViewRotation = Normalize( InputActor.ViewRotation );
	RotateViewTo();

	// Prepare to lerp location.
	bLerpingLot = true;
	ViewLocation = InputActor.Location + InputActor.EyeHeight*vect(0,0,1);
	if ( ViewMapper.Location.X > ViewLocation.X )
		bLerpingDownX = false;
	else
		bLerpingDownX = true;
	MoveRate.X = (ViewMapper.Location.X - ViewLocation.X) * 3;
	if ( ViewMapper.Location.Y > ViewLocation.Y )
		bLerpingDownY = false;
	else
		bLerpingDownY = true;
	MoveRate.Y = (ViewMapper.Location.Y - ViewLocation.Y) * 3;
	if ( ViewMapper.Location.Z > ViewLocation.Z )
		bLerpingDownZ = false;
	else
		bLerpingDownZ = true;
	MoveRate.Z = (ViewMapper.Location.Z - ViewLocation.Z) * 3;

	// Make sure nothing plays on screen.
	bInterpolating = true;
}

simulated function Relinquish()
{
	// Stop firing.
	FireEnd();
	bFiring = 0;
	OldbFire = 0;
	bAltFiring = 0;
	OldbAltFire = 0;

	// Remove our input hook.
	ViewMapper.bUseViewportForZ = false;
	bUseViewportForZ = false;
	bServerControl = false;
	bLocalControl = false;
	bInterlock = false;
	if ( InputActor != None )
		InputActor.ViewMapper = None;

	// Only do this if the player hasn't been deleted while using us.
	// This will prevent us from accidentally rehashing the actor's collision and so forth.
	if ( !bDeletedOwner && (InputActor != None) )
	{
		// Unmount.
		InputActor.MountParent = None;
		InputActor.MountMeshItem = '';
		InputActor.MountOrigin = vect(0,0,0);
		InputActor.MountAngles = rot(0,0,0);
		InputActor.SetPhysics( PHYS_Walking );
		InputActor.SetPostureState( PS_Standing );
		InputActor.SetUpperBodyState( UB_Alert );
		InputActor.SetCollision( true, true, true );
		InputActor.bSimFall = false;
		InputActor.bCanFly = false;
		InputActor.bOnTurret = false;
		ViewMapper.bUseViewportForZ = false;

		// Reset the player.
		InputActor.ViewRotation.Pitch = 0;
		InputActor.ViewRotation.Yaw = RotateRoll;
		InputActor.SetRotation( rot(0,RotateRoll,0) );
		InputActor.bLaissezFaireBlending = false;
		InputActor.AnimBlend = 0;
		InputActor.HeadYaw = 0;
		InputActor.AbdomenYaw = 0;
		InputActor.bIsTurning = false;
		InputActor.StartSmoothRotationTime = 0.0;

		// Bring the weapon up.
		InputActor.WeaponUp();

		// Release the player.
		InputActor.SetDesiredFOV(90);
		InputActor.bLockRotation = false;
	}
	bDeletedOwner = false;

	InputActor = None;

	// Turn off lerping.
	bLerpingRot = false;
	bLerpingLot = false;

	// Restore drawing state.
	bUseViewportForZ = false;

	// Clear the screen.
	ClearScreen();
}

simulated function Fire()
{
}

simulated function FireEnd()
{
}

simulated function AltFire()
{
	if ( AltFireEvent != '' )
		GlobalTrigger( AltFireEvent );
	else
		InputActor.SetDesiredFOV(25);
}

simulated function AltFireEnd()
{
	if ( AltFireEvent == '' )
		InputActor.SetDesiredFOV(90);
}

// Interface for mulitplayer viewmapper's that can interdict bFire messages to server.
simulated function bool CanSendFire()
{
	if ( bInterlock || bOverheated )
		return false;
	else
		return true;
}

simulated event CalcView( out vector CameraLocation, out rotator CameraRotation )
{
	local vector t,X,Y,Z;
	local rotator r;

	// Rotation (ROLL)
	r = MeshInstance.BoneGetRotate( RotateBone, false, false );
	r.Roll = -RotateRoll + Rotation.Yaw;
	MeshInstance.BoneSetRotate( RotateBone, r, false, false );

	// Rotation (PITCH)
	r = MeshInstance.BoneGetRotate( GunBone, false, false );
	r.Pitch = RotatePitch;
	MeshInstance.BoneSetRotate( GunBone, r, false, false );

	// Start hack.
	// Framerate death?
	ForcedGetFrame();
	ViewMapper.AutonomousPhysics( 0.3 );
	// End hack.

	if ( bLerpingLot )
		CameraLocation = ViewLocation;
	else
		CameraLocation = ViewMapper.Location;

	if ( bLerpingRot )
	{
		CameraRotation = ViewRotation;
		CameraRotation.Pitch += 65535;
		CameraRotation.Yaw += 65535;
	}
	else
	{
		CameraRotation.Pitch = RotatePitch + 65535;
		CameraRotation.Yaw = RotateRoll + 65535;
	}
	CameraRotation.Roll = 65535;
}

simulated function InterpolationInterrupt()
{
	// Auto finish interpolation if not already finished.
	EndCallbackTimer( 'InterpolationInterrupt' );

	bLerpingRot = false;
	ViewRotation.Pitch = RotatePitch;
	ViewRotation.Yaw = RotateRoll;

	bLerpingLot = false;
	ViewLocation = ViewMapper.Location;

	InterpolationFinished();
}

simulated function LimitRotation()
{
	// Make sure rotation is bound.
	if ( RotatePitch < MinPitch )
		RotatePitch = MinPitch;
	else if ( RotatePitch > MaxPitch )
		RotatePitch = MaxPitch;

	if ( bClampRoll )
	{
		if ( RotateRoll < MinRoll )
			RotateRoll = MinRoll;
		else if ( RotateRoll > MaxRoll )
			RotateRoll = MaxRoll;
	}
}

simulated function InputHook( out float aForward, out float aLookUp, out float aTurn, out float aStrafe, optional float DeltaTime )
{
	if ( Viewport(InputActor.Player) == None )
		return;

	if ( !bInterlock )
	{
		if ( (aTurn != 0) || (aLookUp != 0) )
			bBlowUpStickies = true;

		RotateRoll  += aTurn / 10;
		RotatePitch += aLookUp / 10;

		LimitRotation();

		InputActor.VehicleRoll  = RotateRoll;
		InputActor.VehiclePitch = RotatePitch;

		CropFrame = int(float(MaxPitch-RotatePitch)/100.0)%10;
		bDirtyTop = true;
	}
}

simulated function Tick( float Delta )
{
	local vector LocDelta, AdjustVector, t;
	local rotator r1, r2;
	local bool Adjust;
	local PlayerPawn P;
	local rotator r;

	// Get the mesh instance.
	GetMeshInstance();
	if ( MeshInstance == None )
		return;

	// Call super.
	Super.Tick( Delta );

	if ( InputActor != None )
	{
		UpdateScreen( Delta );

		InputActor.ViewRotation.Pitch = RotatePitch;
		InputActor.ViewRotation.Yaw   = RotateRoll;
		InputActor.ViewRotation.Roll  = 0;
		if ( (Role == ROLE_Authority) || bLocalControl )
		{
			// Handle fire detection for the server or controlling client.
			if ( (InputActor.bFire>0) && (OldbFire==0) )
			{
				bFiring = 1;
				Fire();
			}
			else if ( (InputActor.bFire==0) && (OldbFire>0) )
			{
				bFiring = 0;
				FireEnd();
			}
			OldbFire = InputActor.bFire;

			// Handle fire detection for the server or controlling client.
			if ( (InputActor.bAltFire>0) && (OldbAltFire==0) )
			{
				bAltFiring = 1;
				AltFire();
			}
			else if ( (InputActor.bAltFire==0) && (OldbAltFire>0) )
			{
				bAltFiring = 0;
				AltFireEnd();
			}
			OldbAltFire = InputActor.bAltFire;
		}

		// Handle animation blending and net updates on server.
		if ( Role == ROLE_Authority )
		{
			if ( (InputActor.Health <= 0) || InputActor.Shrunken() )
			{
				// Our user died or is shrunken.
				InputActor.ClientRemoveViewMapper();
				Relinquish();
				return;
			}

			RotatePitch = InputActor.VehiclePitch;
			RotateRoll = InputActor.VehicleRoll;
			LimitRotation();
			SimRotatePitch = RotatePitch;
			SimRotateRoll = RotateRoll;

			InputActor.GetMeshInstance();
			if ( RotatePitch >= 0 )
			{
				AnimBlendFactor = float(RotatePitch) / float(AnimMaxPitch);
				if ( InputActor.MeshInstance.MeshChannels[0].AnimSequence != 'A_Turret_AimUp' )
					InputActor.PlayAnim( 'A_Turret_AimUp', 1.0, -1.0, 0 );
				if ( InputActor.MeshInstance.MeshChannels[1].AnimSequence != 'A_Turret_AimMid' )
					InputActor.PlayAnim( 'A_Turret_AimMid', 1.0, -1.0, 1 );
				InputActor.AnimBlend = 1.0 - AnimBlendFactor;
				InputActor.MeshInstance.MeshChannels[0].AnimBlend = 1.0 - AnimBlendFactor;
				InputActor.MeshInstance.MeshChannels[1].AnimBlend = AnimBlendFactor;
			}
			else
			{
				AnimBlendFactor = Abs( float(RotatePitch) / float(AnimMinPitch) );
				if ( InputActor.MeshInstance.MeshChannels[0].AnimSequence != 'A_Turret_AimDown' )
					InputActor.PlayAnim( 'A_Turret_AimDown', 1.0, -1.0, 0 );
				if ( InputActor.MeshInstance.MeshChannels[1].AnimSequence != 'A_Turret_AimMid' )
					InputActor.PlayAnim( 'A_Turret_AimMid', 1.0, -1.0, 1 );
				InputActor.AnimBlend = 1.0 - AnimBlendFactor;
				InputActor.MeshInstance.MeshChannels[0].AnimBlend = 1.0 - AnimBlendFactor;
				InputActor.MeshInstance.MeshChannels[1].AnimBlend = AnimBlendFactor;
			}
		}
	}

	if ( (Role < ROLE_Authority) && !bLocalControl ) 
	{
		// Non controlling client rotation update.
		RotatePitch = SimRotatePitch;
		RotateRoll = SimRotateRoll;

		// Non controlling client firing detection.
		if ( (bFiring>0) && (OldbFire==0) )
			Fire();
		else if ( (bFiring==0) && (OldbFire>0) )
			FireEnd();
		OldbFire = bFiring;

		// Non controlling client altfiring detection.
		if ( (bAltFiring>0) && (OldbAltFire==0) )
			AltFire();
		else if ( (bAltFiring==0) && (OldbAltFire>0) )
			AltFireEnd();
		OldbAltFire = bAltFiring;
	}

	// Rotation (ROLL)
	r = MeshInstance.BoneGetRotate( RotateBone, false, false );
	r.Roll = -RotateRoll + Rotation.Yaw;
	MeshInstance.BoneSetRotate( RotateBone, r, false, false );

	// Rotation (PITCH)
	r = MeshInstance.BoneGetRotate( GunBone, false, false );
	r.Pitch = RotatePitch;
	MeshInstance.BoneSetRotate( GunBone, r, false, false );

	if ( (Role == ROLE_Authority) && !bLocalControl && (InputActor != None) )
	{
		// Update the controller's physics.
		// This is so the controller's position is update to date with the new bone locations
		// on the server.  Improves visual quality on listen servers.
		InputActor.AutonomousPhysics( Delta );
	}

	if ( !bInterlock )
		return;

	// Rest of this is controlling client behavior.
	if ( (InputActor == None) || Viewport(InputActor.Player) == None )
		return;

	if ( bLerpingRot )
	{
		r1 = ViewRotation;
		r2.Pitch = RotatePitch;
		r2.Yaw = RotateRoll;

		if ( r1.Pitch != r2.Pitch )
			ViewRotation.Pitch = FixedTurn( r1.Pitch, r2.Pitch, ViewRotationRate.Pitch * Delta );
		if ( r1.Yaw != r2.Yaw )
			ViewRotation.Yaw = FixedTurn( r1.Yaw, r2.Yaw, ViewRotationRate.Yaw * Delta );

		r1 = Normalize(ViewRotation);
		r2 = Normalize(rot(RotatePitch,RotateRoll,0));
		if ( (r1.Pitch == r2.Pitch) && (r1.Yaw == r2.Yaw) )
			bLerpingRot = false;
	}

	if ( bLerpingLot )
	{
		// Find the move increments.
		if ( ViewLocation.X != ViewMapper.Location.X )
			LocDelta.X = MoveRate.X * Delta;
		if ( ViewLocation.Y != ViewMapper.Location.Y )
			LocDelta.Y = MoveRate.Y * Delta;
		if ( ViewLocation.Z != ViewMapper.Location.Z )
			LocDelta.Z = MoveRate.Z * Delta;

		// Set location.
		ViewLocation = ViewLocation + LocDelta;

		// Check for too much movement.
		AdjustVector = ViewLocation;
		if (bLerpingDownX && (ViewLocation.X < ViewMapper.Location.X))
		{
			Adjust = true;
			AdjustVector.X = ViewMapper.Location.X;
		} 
		else if (!bLerpingDownX && (ViewLocation.X > ViewMapper.Location.X))
		{
			Adjust = true;
			AdjustVector.X = ViewMapper.Location.X;
		}

		if (bLerpingDownY && (ViewLocation.Y < ViewMapper.Location.Y))
		{
			Adjust = true;
			AdjustVector.Y = ViewMapper.Location.Y;
		}
		else if (!bLerpingDownY && (ViewLocation.Y > ViewMapper.Location.Y))
		{
			Adjust = true;
			AdjustVector.Y = ViewMapper.Location.Y;
		}

		if (bLerpingDownZ && (ViewLocation.Z < ViewMapper.Location.Z))
		{
			Adjust = true;
			AdjustVector.Z = ViewMapper.Location.Z;
		}
		else if (!bLerpingDownZ && (ViewLocation.Z > ViewMapper.Location.Z))
		{
			Adjust = true;
			AdjustVector.Z = ViewMapper.Location.Z;
		}

		if ( Adjust )
			ViewLocation = AdjustVector;

		if ( (ViewLocation.X == ViewMapper.Location.X) && 
			 (ViewLocation.Y == ViewMapper.Location.Y) &&
			 (ViewLocation.Z == ViewMapper.Location.Z) )
			bLerpingLot = false;
	}

	if ( !bLerpingLot && !bLerpingRot )
	{
		EndCallbackTimer( 'InterpolationInterrupt' );
		InterpolationFinished();
	}

	// Relinquish for remote clients.
	if ( !bLocalControl && (InputActor == None) && (OldInputActor != None) )
	{
		// This might be unreachable.
		//BroadcastMessage("Remote relinquish due to input actor rep none.");
		bLocalControl = false;
		bServerControl = false;
		FireEnd();
		ClearScreen();
	}
	OldInputActor = InputActor;
}

simulated function RotateViewTo()
{
	local float Seconds;
	local rotator r1, r2;

	Seconds = 0.3;
	r1 = ViewRotation;
	r2.Pitch = RotatePitch;
	r2.Yaw = RotateRoll;
	if ( r1 != r2 )
	{
		ViewRotationRate.Yaw   = Abs(RotationDistance(r1.Yaw,   r2.Yaw))/Seconds;
		ViewRotationRate.Pitch = Abs(RotationDistance(r1.Pitch, r2.Pitch))/Seconds;
	}
}

simulated function InterpolationFinished()
{
	// Start up the smack.
	MultiSkins[6] = IntroTop;
	IntroTop.pause = false;
	MultiSkins[7] = IntroBot;
	IntroBot.pause = false;
	bPlayingIntro = true;
	bInterpolating = false;
}

simulated function ClearScreen()
{
	CanvasTop.DrawClear(1);
	CanvasBot.DrawClear(1);
	MultiSkins[6] = None;
	MultiSkins[7] = None;
	IntroTop.pause = true;
	IntroTop.CurrentFrame = 0;
	IntroBot.pause = true;
	IntroBot.CurrentFrame = 0;
}

simulated function UpdateScreen( float DeltaSeconds )
{
	if ( bInterpolating || !bLocalControl )
		return;

	if ( bPlayingIntro )
	{
		// Check to see if the intro is still playing.
		if ( (IntroTop.currentFrame == LastIntroFrameTop) && (IntroBot.currentFrame == LastIntroFrameBot) )
		{
			// Smacks are done, stop playing intro.
			bPlayingIntro = false;
			MultiSkins[6] = None;
			MultiSkins[7] = None;
			bDirtyTop = true;
			bDirtyBot = true;

			// Allow the turret to move.
			bInterlock = false;

			if ( bSavedFire )
				Fire();
		}
	}

	if ( bPlayingIntro )
		return;

	// If we are dirty, redraw the screen.
	if ( bDirtyTop )
	{
		// Clear up.
		CanvasTop.DrawClear(1);

		// Draw the top background.
		CropMarksLeft.CurrentFrame = CropFrame;
		CropMarksLeft.ForceTick( DeltaSeconds );
		CropMarksRight.CurrentFrame = CropFrame;
		CropMarksRight.ForceTick( DeltaSeconds );
		CanvasTop.Palette = Background.Palette;
		CanvasTop.DrawBitmap( 0, 0, 0, 0, 0, 0, Background, true );
		CanvasTop.DrawBitmap( 36, 86, 0, 0, 0, 0, CropMarksLeft, true );
		CanvasTop.DrawBitmap( 203, 86, 0, 0, 0, 0, CropMarksRight, true );
		if ( bOverheated )
			CanvasTop.DrawBitmap( 84, 231, 0, 0, 0, 0, Overheat, true );

		bDirtyTop = false;
	}
	if ( bDirtyBot )
	{
		// Clear up.
		CanvasBot.DrawClear(1);

		// Ask the specific turret subclass to handle the bottom section.
		UpdateBottomScreen( DeltaSeconds );

		bDirtyBot = false;
	}
}

simulated function UpdateBottomScreen( float DeltaSeconds );

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     Mesh=DukeMesh'c_dnWeapon.Turret_Manned'
     ItemName="Unnamed Turret"
     CollisionRadius=50.000000
     CollisionHeight=40.000000
     bDontReplicateSkin=True
     bDontReplicateMesh=True
     LightDetail=LTD_Normal
     bUseTriggered=True
     bTakeMomentum=False
	 AnimMaxPitch=4291
	 AnimMinPitch=-4020
	 bClientUse=true
	 RemoteRole=ROLE_SimulatedProxy
	 SomethingWitty(0)=sound'a_dukevoice.dukelines.DOpenACan'
	 SomethingWitty(1)=sound'a_dukevoice.dukelines.DYouDieNow'
	 SomethingWitty(2)=sound'a_dukevoice.dukelines.DLetsDance'
	 SpriteProjForward=-20
	 MinRoll=-16384
	 MaxRoll=16384
	 AnimMinRoll=-16384
	 AnimMaxRoll=16384
	 LastIntroFrameTop=8
	 LastIntroFrameBot=8
	 CropMarksLeft=smackertexture'm_turretfx.smacks.cropmarks_loop'
	 CropMarksRight=smackertexture'm_turretfx.smacks.cropmarks_loop2'
	 Overheat=texture'm_turretfx.pieces.turret_top_overheatbc'
	 TemperatureGauge=texture'm_turretfx.smacks.gat_bot_temp1'
	 MaxOverheatTime=7.0
	 HitPackageLevelClass=class'HitPackage_DukeLevel'
}
