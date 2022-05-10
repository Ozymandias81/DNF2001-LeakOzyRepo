class DoorMover extends Mover
	native;
/*-----------------------------------------------------------------------------
	DoorMover
	Author: Brandon Reinhart

 How to use this class:
 
 Create a door mover in your map.  The dimensions of an average Duke door are 
 DoorMovers have "sticky pivots."  The pivot will always be the brush "center."
 
	General Variables
 
 	PivotLocation:			The door will rotate around this side of the door.
 	PivotInset:				If you want your pivot to be set more into the door set this to be a positive value.
 	DegreesOffset:			The door opens 90 + DegreesOffset degrees away from the player.
 	bLocked:				If true, the door cannot be opened.
 	bKickable:				If true, Duke will kick the door open.
 	bNoPlayerTrigger:		If true, the player cannot trigger this door.
 	bNeverClose:			If true, the door will never close.
 	FrontDoorHandleClass:	Set this to be the class of the front side door handle.
 	FrontDoorHandleOffset:	If you make a door with abnormal dimensions, set this to offset the handle.
 	BackDoorHandleClass:	Set this to be the class of the back side door handle.
 	BackDoorHandleOffset:	If you make a door with abnormal dimensions, set this to offset the handle.
 	DoorOpenDirection:		Set this to Inward or Outward if you want to force the direction a door opens in.
	AlmostClosedDegrees:	Number of degrees apart when closing to play almost closed sound (swing doors).
	AlmostClosedDist:		Number of units apart when closing to play almost closed sound (sliding doors).
 
	Force Variables - Only values of Yaw are legal at this time.
 
 	OpenForce:				An amount of force to put on the door when it is opened by hand.
	KickOpenForce:			An amount of force to put on the door when it is kicked open.
 	BumpForce:				An amount of force to put on the door when it encroaches something.
 	BaseRadialFriction:		An amount of frictional force applied opposite the direction of movement.
 	ImpactBounce:			A scaling factor applied to force and velocity when the door rebounds off the frame.
 	KickImpactBounce:		A scaling factor applied to force and velocity when the door rebounds off the frame when kicked.
 
 	Sliding Door Variables
 
 	DoorSlideDirection:		Whether to open to the right or left.
 	SlideDistance:			The distance to open before hitting the door frame.
 	SlideOpenForce:			The amount of force to apply when opening the door.
 	BaseSlideFriction:		The amount of friction to apply opposite the door's motion.
 
 	Sounds Variables
 
 	DoorType:				The type of door determines the base door sound scheme.
 	LockedSound:			Sound to play if the door is locked.
 	FrameImpact:			Sound to play when the door hits the doorframe.
 	FrameImpactKicked:		A more forceful frame impact to play when the door hits the frame.
	KickOpenSound:			An impact sound to play when the door is kicked.
	DoorSqueekSounds:		Three sounds to choose from in a 1/5 chance the door will squeek when opened by hand.

  Level Designer Notes: 
 		When creating a DoorMover you must do the following or the door will NOT work:
 			-  Reset the construction brush, create your door and texture it.
 			-  A typical DNF door is 112 Height x 4 Width x 64 Breadth 
 				(door width should run horizontal in the top down view).  
 			-  Use "Brush Intersection" to assign the door to the construction brush.
 				(Do NOT use "Copy polygons to brush")  
 			-  Set mover to "DoorMover" and press "Add movable brush."
 			-  You can then rotate the door to the desired angle and position.
 		You should now have a functioning door.
-----------------------------------------------------------------------------*/


var() enum EPivotLocation
{
	PL_Right,
	PL_Left,
}						PivotLocation;
var() float				PivotInset;
var() class<DoorHandle> FrontDoorHandleClass;
var() vector			FrontDoorHandleOffset;
var() class<DoorHandle> BackDoorHandleClass;
var() vector			BackDoorHandleOffset;
var() float				DegreesOffset;
var() bool				bLocked;
var() bool				bKickable;
var() float				OpenForce;
var() float				KickOpenForce;
var() float				BumpForce;
var() rotator			BaseRadialFriction;
var() bool				bNoPlayerTrigger;
var() bool				bNeverClose;
var() float				KickImpactBounce;
var() float				ImpactBounce;
var() enum EDoorOpenDirection
{
	DOD_Dynamic,
	DOD_Outward,
	DOD_Inward
}						DoorOpenDirection;
var() enum EDoorType
{
	DOOR_Custom,
	DOOR_Wood,
	DOOR_Metal,
}						DoorType;

var(MoverSounds) sound	LockedSound;
var(MoverSounds) sound	KickOpenSound;
var(MoverSounds) sound	DoorSqueekSounds[3];
var(MoverSounds) sound	FrameImpact;
var(MoverSounds) sound	FrameImpactKicked;
var(MoverSounds) sound	AlmostClosedSound;

var   DoorHandle		FrontHandle, BackHandle;
var   int				PivotBias;
var   int				BaseYaw;
var   int				DoorNumKeys;
var   bool				bKickedOpen;
var   bool				bPlayClosed;
var   int				OpenDirection;
var   bool				DontOpen;

// Radial Force
var	  rotator			RadialForce;
var   rotator			RadialVelocity;
var   rotator			AppliedRadialFriction;
var   bool				MoveByForce;

// Sliding Force
var() enum EDoorSlideDirection
{
	DSD_Left,
	DSD_Right
}						DoorSlideDirection;
var() float				SlideDistance;
var() float				SlideOpenForce;
var   float				SlideForce;
var	  float				SlideVelocity;
var() float				BaseSlideFriction;
var	  float				AppliedSlideFriction;
var   bool				MoveBySlide;
var   bool				CloseBySlide;
var	  bool				SlidingForward;
var   vector			InitialLocation;

var   unbound bool		Encroached;

var   unbound bool		bClosed;
var   DoorMover			FriendDoorMover;
var() unbound name		FriendDoor;
var() unbound bool		bDontOpenUntilFriendClosed;
var() unbound bool		bOpenFriendOnTrigger;

var   unbound bool		bTriggerByUse;

var	  bool				bTriggerByFriend;

var() float				AlmostClosedDegrees;
var() float				AlmostClosedDist;

simulated function BeginPlay()
{
	local vector TargetLoc, HandleLoc, FLoc, BLoc;
	local rotator TargetRot, TempRot, HandleRot;
	local vector Min, Max, Size;
	local vector X,Y,Z;
	local float PivotOffset;
	local DoorMover DM;

	// Set move type.
	MoveByForce = true;

	// Timer updates real position every second in network play.
	if ( Level.NetMode != NM_Standalone )
	{
		if ( Level.NetMode == NM_Client )
			SetTimer(4.0, true);
		else
			SetTimer(1.0, true);
		if ( Role < ROLE_Authority )
			return;
	}
	HandleLoc = Location;
	bClosed = true;

	// Find friend door.
	foreach AllActors( class'DoorMover', DM, FriendDoor )
	{
		FriendDoorMover = DM;
	}

	// Find movers in same group.
	if ( ReturnGroup == '' )
		ReturnGroup = tag;

	// Determine pivot bias.
	switch (PivotLocation)
	{
	case PL_Right:
		PivotBias = 1;
		break;
	case PL_Left:
		PivotBias = -1;
		break;
	}

	// Find pivot offset and set our location.
	TempRot = Rotation;
	SetRotation(TargetRot);
	GetMoverCollisionBox(Min, Max);
	SetRotation(TempRot);
	Size = Max - Min;
	PivotOffset = (Size.x/2) - PivotInset;
	PrePivot.X -= PivotOffset * PivotBias;
	GetAxes(Rotation,X,Y,Z);
	TargetLoc.X -= PivotOffset*X.x*PivotBias;
	TargetLoc.Y += PivotOffset*Y.x*PivotBias;
	BasePos = Location + TargetLoc;
	Move(TargetLoc);

	// Set base for integration.
	OldRot = Rotation;
	OldPos = TargetLoc;

	// Add handles.
	AddHandle(FrontDoorHandleClass, HandleLoc, true);
	AddHandle(BackDoorHandleClass, HandleLoc, false);

	// Reset target location and rotation.
	TargetLoc.X = 0;
	TargetLoc.Y = 0;
	TargetLoc.Z = 0;

	// Set keynum 0 to be our base location.
	SetKeyframe( 0, TargetLoc, TargetRot );

	// Set our real offsets.
	if ( Level.NetMode != NM_Client )
	{
		RealPosition = Location;
		RealRotation = Rotation;
	}

	// Init key info.
	Super(Brush).BeginPlay();
	PhysAlpha	= 0.0;
	KeyNum		= 0;
	DoorNumKeys	= 2;
}

function AddHandle(class<DoorHandle> HandleClass, vector HandleLoc, bool Front)
{
	local DoorHandle Handle;
	local rotator TempRot;
	local vector TempLoc, X, Y, Z, HandleOffset;
	local int fRot;

	if (HandleClass == None)
		return;

	if (Front) 
		fRot = 1; 
	else 
		fRot = -1;

	// Spawn the handle.
	Handle = spawn(HandleClass);

	// Get the offset.
	if (Front)
	{
		HandleOffset = FrontDoorHandleOffset;
		if (Handle.bSideSpecific)
			Handle.SetSide(PivotBias);
	} else {
		HandleOffset = BackDoorHandleOffset;
		if (Handle.bSideSpecific)
			Handle.SetSide(-PivotBias);
	}

	// Find the right location.
	GetAxes(Rotation,X,Y,Z);
	TempLoc = HandleLoc;
	TempLoc.X += (Handle.HandleOffset.X + HandleOffset.X) * X.x * -PivotBias;
	TempLoc.Y += (Handle.HandleOffset.X + HandleOffset.X) * X.y * -PivotBias;
	TempLoc.X += (Handle.HandleOffset.Y + HandleOffset.Y) * Y.x * fRot;
	TempLoc.Y += (Handle.HandleOffset.Y + HandleOffset.Y) * Y.y * fRot;
	TempLoc.Z = HandleLoc.Z + (Handle.HandleOffset.Z + HandleOffset.Z);

	// And the right rotation.
	TempRot = Rotation + Handle.RotationOffset;
	if (!Front)
		TempRot.Yaw += 32768;

	// Set the values.
	Handle.SetLocation(TempLoc);
	Handle.SetRotation(TempRot);
	Handle.MountType = EMountType.MOUNT_Actor;
	Handle.AttachActorToParent(self);

	if (Front)
		FrontHandle = Handle;
	else
		BackHandle = Handle;
}

function Used( actor Other, Pawn EventInstigator )
{
	if (bDontOpenUntilFriendClosed)
	{
		if (!FriendDoorMover.bClosed)
			return;
	}

	if ( bKickable && (PlayerPawn(EventInstigator) != None) )
	{
		if (FRand() < 0.5)
			bKickedOpen = true;
	}

	bTriggerByUse = true;
	Trigger( Other, EventInstigator );
	bTriggerByUse = false;
}

event AlmostClosed()
{
	if (bPlayClosed)
	{
		PlaySound( AlmostClosedSound, SLOT_Interact );
		AmbientSound = None;
		bPlayClosed = false;
	}
}

function ApplyForce( float Force, Actor Other )
{
	local vector DeltaPos;
	local vector X, Y, Z;
	local rotator TargetRot, ZeroRot;
	local float xFactor;

	// Determine open direction.
	if (DoorOpenDirection == DOD_Dynamic)
	{
		DeltaPos = Location - Other.Location;
		GetAxes(Rotation,X,Y,Z);
		xFactor = Y.x * DeltaPos.x + Y.y * DeltaPos.y;
		TargetRot.Pitch = 0;
		TargetRot.Roll = 0;
		if (xFactor > 0)
		{
			TargetRot.Yaw = Force * PivotBias;
			OpenDirection = 1*PivotBias;
		} else {
			TargetRot.Yaw = -Force * PivotBias;
			OpenDirection = -1*PivotBias;
		}
	} else if (DoorOpenDirection == DOD_Outward)
		OpenDirection = PivotBias;
	else if (DoorOpenDirection == DOD_Inward)
		OpenDirection = -PivotBias;
	TargetRot.Yaw = Force * OpenDirection;

	// Determine the rebound point.
	BaseYaw = BaseRot.Yaw + ((65536/4) + DegreesOffset*(65536/360))*OpenDirection;

	RadialVelocity += TargetRot;
}

event DoorframeImpact()
{
}

event StoppedMoving()
{
}

function InterpolateEnd( actor Other )
{
	local byte OldKeyNum;

	OldKeyNum  = PrevKeyNum;
	PrevKeyNum = KeyNum;
	PhysAlpha  = 0;
	ClientUpdate--;

	// If more than two keyframes, chain them.
	if( KeyNum>0 && KeyNum<OldKeyNum )
	{
		// Chain to previous.
		InterpolateTo(KeyNum-1,MoveTime);
	}
	else if( KeyNum<DoorNumKeys-1 && KeyNum>OldKeyNum )
	{
		// Chain to next.
		InterpolateTo(KeyNum+1,MoveTime);
	}
	else
	{
		// Finished interpolating.
		AmbientSound = None;
		if ( (ClientUpdate == 0) && (Level.NetMode != NM_Client) )
		{
			RealPosition = Location;
			RealRotation = Rotation;
		}
	}
}

state() SwingDoor
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		// Open friend.
		if ( bOpenFriendOnTrigger && !bTriggerByFriend && (FriendDoorMover != None) )
		{
			FriendDoorMover.bKickedOpen = bKickedOpen;
			FriendDoorMover.bTriggerByUse = bTriggerByUse;
			FriendDoorMover.bTriggerByFriend = true;
			FriendDoorMover.Trigger( Other, EventInstigator );
			FriendDoorMover.bTriggerByFriend = false;
			FriendDoorMover.bTriggerByUse = false;
		}

		// Don't open.
		if ( DontOpen && bTriggerByUse )
			return;

		if ( bTriggerByUse && bNoPlayerTrigger )
			return;

		// Set values.
		if (EventInstigator != None)
			Instigator = EventInstigator;

		// Force open if the opener isn't our open trigger.
		if ( bLocked && !bTriggerByUse )
			bLocked = false;

		// Determine our opening force.
		if ( bKickable && bKickedOpen && !bLocked )
			PlayerPawn(Instigator).QuickKick( true );

		// Determine sounds.
		if ( bKickedOpen )
		{
			// Ambient.
			switch ( DoorType )
			{
			case DOOR_Wood:
			case DOOR_Metal:
				MoveAmbientSound = None;
				break;
			}
		}
		else
		{
			// Ambient sound.
			switch ( DoorType )
			{
			case DOOR_Wood:
			case DOOR_Metal:
				if (FRand() < 0.2)
					MoveAmbientSound = DoorSqueekSounds[Rand(3)];
				else
					MoveAmbientSound = None;
				break;
			}
		}

		// Open the door or show we are locked.
		DontOpen = true;
		SetTimer(0.5, true);
		if (bLocked)
		{
			if ( !bKickedOpen )
				GotoState( 'SwingDoor', 'Locked' );
		} else
			GotoState( 'SwingDoor', 'Open' );
	}

	function BeginState()
	{
		bOpening = false;

		// Load sounds.
		DoorSqueekSounds[0] = sound( DynamicLoadObject( "a_doors.wood.DoorOpLpX11", class'Sound' ) );
		DoorSqueekSounds[1] = sound( DynamicLoadObject( "a_doors.wood.DoorOpLpX12", class'Sound' ) );
		DoorSqueekSounds[2] = sound( DynamicLoadObject( "a_doors.wood.DoorOpLpX13", class'Sound' ) );
		switch (DoorType)
		{
		case DOOR_Wood:
			LockedSound = sound( DynamicLoadObject( "a_doors.wood.DoorJiggle02", class'Sound' ) );
			KickOpenSound = sound( DynamicLoadObject( "a_doors.wood.DoorImpGen11", class'Sound' ) );
			OpeningSound = sound( DynamicLoadObject( "a_doors.wood.DoorOpStrt02", class'Sound' ) );
			AlmostClosedSound = sound( DynamicLoadObject( "a_doors.wood.DoorClStop24", class'Sound' ) );
			FrameImpactKicked = sound( DynamicLoadObject( "a_doors.wood.DoorOpStop02", class'Sound' ) );
			FrameImpact = sound( DynamicLoadObject( "a_doors.wood.DoorOpStop01", class'Sound' ) );
			break;
		case DOOR_Metal:
			LockedSound = sound( DynamicLoadObject( "a_doors.metal.DoorJiggle02", class'Sound' ) );
			KickOpenSound = sound( DynamicLoadObject( "a_doors.metal.DoorImpGen02", class'Sound' ) );
			OpeningSound = sound( DynamicLoadObject( "a_doors.metal.DoorOpStrt20", class'Sound' ) );
			AlmostClosedSound = sound( DynamicLoadObject( "a_doors.metal.DoorClStop10", class'Sound' ) );
			FrameImpactKicked = sound( DynamicLoadObject( "a_doors.metal.DoorOpStop07", class'Sound' ) );
			FrameImpact = sound( DynamicLoadObject( "a_doors.metal.DoorOpStop01", class'Sound' ) );
			break;
		}
	}

	function Timer(optional int TimerNum)
	{
		DontOpen = false;
		SetTimer(0.0, false);
	}

	function DoOpen()
	{
		local float ActiveForce;
		local rotator ZeroRot;

		// Zero out forces.
		AppliedRadialFriction	= ZeroRot;
		RadialForce				= ZeroRot;
		RadialVelocity			= ZeroRot;
		if (bKickedOpen)
			ActiveForce = KickOpenForce;
		else
			ActiveForce = OpenForce;

		// Reset physics baseline.
		OldRot					= BaseRot;
		MoveByForce				= true;
		bClosed					= false;

		// Apply the force.
		ApplyForce(ActiveForce, Instigator);

		// Play relevant sounds.
		if (bKickedOpen)
			PlaySound( KickOpenSound, SLOT_Interact );
		PlaySound( OpeningSound, SLOT_None );
		AmbientSound = MoveAmbientSound;
	}

	function DoClose()
	{
		local rotator ZeroRot;
		local vector ZeroLoc;

		// Zero out the forces.
		AppliedRadialFriction	= ZeroRot;
		RadialForce				= ZeroRot;
		RadialVelocity			= ZeroRot;
		Encroached				= false;

		// Reset the physics baseline.
		OldRot					= BaseRot;
		OldPos					= BasePos;
		MoveByForce				= false;

		// Set AI bools.
		bOpening				= false;
		bDelaying				= false;
		bKickedOpen				= false;

		// Set sound bools.
		bPlayClosed				= true;

		// Set faux keyframe.
		SetKeyframe( 1, ZeroLoc, Rotation - BaseRot );

		// Interpolate to base.
		PhysAlpha				= 1.0;
		KeyNum					= 1;
		InterpolateTo( 0, MoveTime );
	}

	function bool EncroachingOn( actor Other )
	{
		local vector DeltaPos;
		local vector X, Y, Z;
		local rotator TargetRot, ZeroRot;
		local float xFactor;
		local int OpenDirection;

		if (Encroached)
			return false;

		// Zero out forces.
		AppliedRadialFriction	= ZeroRot;
		RadialForce				= ZeroRot;
		RadialVelocity			= ZeroRot;
		OldRot					= Rotation;
		MoveByForce				= true;
		Encroached				= true;

		GotoState( , 'CloseFromEncroach' );

		return false;
	}

	event DoorframeImpact()
	{
		if (Encroached)
			return;

		if (bKickedOpen)
		{
			RadialVelocity.Yaw *= KickImpactBounce;
			RadialForce.Yaw *= KickImpactBounce;
			PlaySound( FrameImpactKicked, SLOT_None );
		} else {
			RadialVelocity.Yaw *= ImpactBounce;
			RadialForce.Yaw *= ImpactBounce;
			PlaySound( FrameImpact, SLOT_None );
		}

		AmbientSound = None;
	}

	function Bump( Actor Other )
	{
		local rotator ZeroRot;

		if (!Encroached)
			return;

		// Zero out forces.
		AppliedRadialFriction	= ZeroRot;
		RadialForce				= ZeroRot;
		RadialVelocity			= ZeroRot;
		OldRot					= Rotation;
		MoveByForce				= true;

		// Apply the force.
		ApplyForce(10000, Other);
	}

Open:
	Disable( 'Trigger' );
	if (!bKickedOpen)
	{
		if (FrontHandle != None)
			FrontHandle.PlayOpenDoor();
		if (BackHandle != None)
			BackHandle.PlayOpenDoor();
		if ( DelayTime > 0 )
		{
			bDelaying = true;
			Sleep(DelayTime);
		}
	}
	DoOpen();
	Sleep( StayOpenTime );
	if (bNeverClose)
	{
		SetPhysics(PHYS_None);
		Stop;
	}

Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Trigger' );
	bClosed = true;
	Stop;

CloseFromEncroach:
	Disable( 'Trigger' );
	Sleep( StayOpenTime );
	GotoState( 'SwingDoor', 'Close' );

Locked:
	if (FrontHandle != None)
		FrontHandle.PlayLockedDoor();
	if (BackHandle != None)
		BackHandle.PlayLockedDoor();
	PlaySound( LockedSound, SLOT_None );
}

state() SlidingDoor
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		// Open friend.
		if ( bOpenFriendOnTrigger && !bTriggerByFriend && (FriendDoorMover != None) )
		{
			FriendDoorMover.bKickedOpen = bKickedOpen;
			FriendDoorMover.bTriggerByUse = bTriggerByUse;
			FriendDoorMover.bTriggerByFriend = true;
			FriendDoorMover.Trigger( Other, EventInstigator );
			FriendDoorMover.bTriggerByFriend = false;
			FriendDoorMover.bTriggerByUse = false;
		}

		// Don't open.
		if ( DontOpen && bTriggerByUse )
			return;

		if ( bTriggerByUse && bNoPlayerTrigger )
			return;

		// Set values.
		if (EventInstigator != None)
			Instigator = EventInstigator;

		// Force open if the opener isn't our open trigger.
		if ( bLocked && !bTriggerByUse )
			bLocked = false;

		// Open the door or show we are locked.
		DontOpen = true;
		SetTimer(0.5, true);
		if (bLocked)
		{
			GotoState( 'SlidingDoor', 'Locked' );
		} else
			GotoState( 'SlidingDoor', 'Open' );
	}

	function BeginState()
	{
		CloseBySlide = true;
		bOpening = false;
		bKickable = false;

		// Load sounds.
		switch (DoorType)
		{
		case DOOR_Wood:
//			OpeningSound = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorOpStrt44", class'Sound') );
//			OpenedSound = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorSlStop45", class'Sound') );
			MoveAmbientSound = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorSlMove45", class'Sound') );
//			ClosingSound = OpeningSound;
			AlmostClosedSound = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorSlStop45", class'Sound') );
			FrameImpact = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorSlStop45", class'Sound') );
			break;
		case DOOR_Metal:
//			OpeningSound = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorOpStrt44", class'Sound') );
//			OpenedSound = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorSlStop45", class'Sound') );
			MoveAmbientSound = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorSlMove45", class'Sound') );
//			ClosingSound = OpeningSound;
			AlmostClosedSound = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorSlStop45", class'Sound') );
			FrameImpact = sound( DynamicLoadObject( "a_doors.slidingmetal.DoorSlStop45", class'Sound') );
			break;
		}
	}

	function Timer(optional int TimerNum)
	{
		DontOpen = false;
		SetTimer(0.0, false);
	}

	function DoOpen()
	{
		// Zero out forces.
		SlideVelocity			= 0;

		// Reset the physics baseline.
		SetPhysics(PHYS_MovingBrush);
		MoveByForce = false;
		MoveBySlide = true;
		SlidingForward = true;
		InitialLocation = Location;
		BaseSlideFriction = default.BaseSlideFriction;
		bClosed	= false;

		// Apply the force.
		SlideVelocity += SlideOpenForce;

		// Play relevant sounds.
		PlaySound( OpeningSound, SLOT_None );
		AmbientSound = MoveAmbientSound;
	}

	function DoClose()
	{
		local rotator ZeroRot;

		// Zero out the forces.
		AppliedSlideFriction	= 0;
		SlideForce				= 0;
		SlideVelocity			= 0;

		// Reset the physics baseline.
		MoveByForce				= false;
		MoveBySlide				= false;

		// Set AI bools.
		bOpening				= false;
		bDelaying				= false;
		bKickedOpen				= false;

		// Set sound bools.
		bPlayClosed				= true;

		// Set faux keyframe.
		SetKeyframe( 1, Location - InitialLocation, ZeroRot );

		// Interpolate to base.
		PhysAlpha				= 1.0;
		KeyNum					= 1;
		InterpolateTo( 0, MoveTime );
		AmbientSound			= MoveAmbientSound;
	}

	function bool EncroachingOn( actor Other )
	{
		MoveByForce				= false;
		MoveBySlide				= true;
		SlidingForward			= true;
		SlideVelocity			= 0;

		GotoState( , 'CloseFromEncroach' );

		return false;
	}

	event DoorframeImpact()
	{
		if ( SlidingForward )
		{
			SlidingForward = false;
			BaseSlideFriction *= 0.7;
			PlaySound( FrameImpact, SLOT_None );
		}
	}

	event StoppedMoving()
	{
		AmbientSound = None;
		PlaySound( OpenedSound, SLOT_None );
	}

//	event AlmostClosed()
//	{
//	}

Open:
	Disable( 'Trigger' );
	if (FrontHandle != None)
		FrontHandle.PlayOpenDoor();
	if (BackHandle != None)
		BackHandle.PlayOpenDoor();
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	Sleep( StayOpenTime );
	if (bNeverClose)
	{
		SetPhysics(PHYS_None);
		Stop;
	}

Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Trigger' );
	bClosed = true;
	Stop;

CloseFromEncroach:
	Disable( 'Trigger' );
	Sleep( StayOpenTime );
	GotoState( 'SlidingDoor', 'Close' );

Locked:
	if (FrontHandle != None)
		FrontHandle.PlayLockedDoor();
	if (BackHandle != None)
		BackHandle.PlayLockedDoor();
	PlaySound( LockedSound, SLOT_None );
}

defaultproperties
{
	MoverGlideType=MV_GlideByTime
	MoverEncroachType=ME_ReturnWhenEncroach
	InitialState=SwingDoor
	StayOpenTime=3
	MoveTime=1
	DelayTime=0.1
	OpenForce=24000
	KickOpenForce=50000
	BumpForce=10000
	BaseRadialFriction=(Pitch=0,Yaw=10000,Roll=0)
	PivotInset=0
	DegreesOffset=20
	KickImpactBounce=-0.2
	ImpactBounce=-0.4
	BaseSlideFriction=100
	SlideOpenForce=100
	SlideDistance=50
	bDontDuckOnEncroach=true
	bUseTriggered=true
	AlmostClosedDegrees=15.0
	AlmostClosedDist=5.0
}