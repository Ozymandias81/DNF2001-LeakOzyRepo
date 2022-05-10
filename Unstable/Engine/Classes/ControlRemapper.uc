//=============================================================================
// Control Remapper
// The control remapper also triggers it's event after it has been deactivated.
// !z2l3_4
//=============================================================================
class ControlRemapper expands Triggers;

#exec Texture Import File=Textures\ControlRemap.pcx Name=S_ControlRemapper Mips=Off Flags=2

// Input capturing for control panels: (NJS)
var () name TurnLeftEvent;
var () name TurnRightEvent;
var () name StrafeLeftEvent;
var () name StrafeRightEvent;
var () name MoveForwardEvent;
var () name MoveBackwardEvent; 

var () name FireEvent;
var () name AltFireEvent;
var () name JumpEvent;
var () name DuckEvent;

// Whether or not the given events should continuiously trigger.
var () bool bTurnLeftContinuous;
var () bool bTurnRightContinuous;
var () bool bStrafeLeftContinuous;
var () bool bStrafeRightContinuous;
var () bool bMoveForwardContinuous;
var () bool bMoveBackwardContinuous;
var () bool bAltFireContinuous;
var () bool bFireContinuous;
var () bool bJumpContinuous;
var () bool bDuckContinuous;
var () bool bDontUnRemap;
var () bool bNoZMove;

// Event end hooks: (Triggered after user lets go of the corresponding key)
var () name TurnLeftEventEnd;
var () name TurnRightEventEnd;
var () name StrafeLeftEventEnd;
var () name StrafeRightEventEnd;
var () name MoveForwardEventEnd;
var () name MoveBackwardEventEnd;
var () name AltFireEventEnd;
var () name FireEventEnd;
var () name JumpEventEnd;
var () name DuckEventEnd;

var () bool  bOneKeyAtATime;	// When true, only one key at a time may be held down.
var () bool  bLockPosition;		// When true, lock location to the same location as the control panel remapper.
var () bool  bLockRotation;		// When true, lock rotation to the same direction this control panel remapper is facing.
var () bool  bLockFOV;			// When true, lock the fov to the value below for the course of time the control remapping is valid.
var () float FOVLockTo;			// The fov to lock to when the above is set.
var () bool  bHideWeapon;		// If true, hide the players weapon when control panel is activated.

var (HookTurn) name   HookTurnActorName;
var (HookTurn) float  TurnScale;
var (HookTurn) bool   MapTurnToYaw;
var (HookTurn) bool   MapTurnToPitch;
var (HookTurn) bool   MapTurnToRoll;
var (HookTurn) bool   MapTurnToVector;
var (HookTurn) vector TurnMapVector;

var (HookLookUp) name    HookLookUpActorName;
var (HookLookUp) float   LookUpScale;
var (HookLookUp) bool    MapLookUpToYaw;
var (HookLookUp) bool    MapLookUpToPitch;
var (HookLookUp) bool    MapLookUpToRoll;
var (HookLookUp) bool    MapLookUpToVector;
var (HookLookUp) vector  LookUpMapVector;

var (HookForward) name	 HookForwardActorName;
var (HookForward) float	 ForwardScale;
var (HookForward) bool	 MapForwardToYaw;
var (HookForward) bool	 MapForwardToPitch;
var (HookForward) bool	 MapForwardToRoll;
var (HookForward) bool	 MapForwardToVector;
var (HookForward) vector ForwardMapVector;

var (HookStrafe) name	HookStrafeActorName;
var (HookStrafe) float	StrafeScale;
var (HookStrafe) bool	MapStrafeToYaw;
var (HookStrafe) bool	MapStrafeToPitch;
var (HookStrafe) bool	MapStrafeToRoll;
var (HookStrafe) bool	MapStrafeToVector;
var (HookStrafe) vector	StrafeMapVector;

// Rotation lerping.
var PlayerPawn RemapActor;
var () bool bLerpRotation;
var bool bLerpingRot;
var rotator ViewRotationRate;

// Location lerping.
var () bool bLerpLocation;
var bool bLerpingLot, bLerpingDownX, bLerpingDownY, bLerpingDownZ;
var vector MoveRate;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	TurnMapVector=Normal(TurnMapVector);
	LookUpMapVector=Normal(LookUpMapVector);
}

function InputHook(out float aForward,out float aLookUp,out float aTurn,out float aStrafe,optional float DeltaTime)
{
	local actor a;
	local rotator r;
	local float f;
	local vector v;

	if(HookTurnActorName!='')
		foreach allactors(class'actor',a,HookTurnActorName)
		{
			f=aTurn*TurnScale;
			r=a.Rotation;
			if(MapTurnToYaw)	r.Yaw+=f;
			if(MapTurnToPitch)	r.Pitch+=f;
			if(MapTurnToRoll)	r.Roll+=f;
			a.SetRotation(r);

			if(MapTurnToVector) a.SetLocation(a.Location+(TurnMapVector*f));
		}

	if(HookLookUpActorName!='')
		foreach allactors(class'actor',a,HookLookUpActorName)
		{
			f=aLookUp*LookUpScale;
			r=a.Rotation;
			if(MapLookUpToYaw)	 r.Yaw+=f;
			if(MapLookUpToPitch) r.Pitch+=f;
			if(MapLookUpToRoll)	 r.Roll+=f;
			a.SetRotation(r);

			if(MapLookUpToVector) a.SetLocation(a.Location+(LookUpMapVector*f));
		}

	if(HookForwardActorName!='')
		foreach allactors(class'actor',a,HookForwardActorName)
		{
			f=aForward*ForwardScale;
			r=a.Rotation;
			if(MapForwardToYaw)	 r.Yaw+=f;
			if(MapForwardToPitch) r.Pitch+=f;
			if(MapForwardToRoll)	 r.Roll+=f;
			a.SetRotation(r);

			if(MapForwardToVector) a.SetLocation(a.Location+(ForwardMapVector*f));
		}

	if(HookStrafeActorName!='')
		foreach allactors(class'actor',a,HookStrafeActorName)
		{
			f=aStrafe*StrafeScale;
			r=a.Rotation;
			if(MapStrafeToYaw)	 r.Yaw+=f;
			if(MapStrafeToPitch) r.Pitch+=f;
			if(MapStrafeToRoll)	 r.Roll+=f;
			a.SetRotation(r);

			if(MapStrafeToVector) a.SetLocation(a.Location+(StrafeMapVector*f));
		}
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	local PlayerPawn p;
	local Weapon w;
	local vector NewLoc;


	// If the instigator isn't a player, then exit quickly:
	if ((EventInstigator == None) || !EventInstigator.IsA('PlayerPawn'))
		return;

	p=PlayerPawn(EventInstigator);

	if(p.bUseRemappedEvents)
	{
		p.GlobalTrigger( p.RelinquishControlEvent );
		p.StopRemappingInput();
		return;
	}

	RemapActor = p;
	p.bUse=0;							// Annoying but necessecary to debounce
	
	p.bUseRemappedEvents=true;
	p.bDontUnRemap=bDontUnRemap;

	if (bLerpLocation && bLockPosition)
	{
		Enable( 'Tick' );

		bLerpingLot = true;
		if (Location.X > RemapActor.Location.X)
			bLerpingDownX = false;
		else
			bLerpingDownX = true;
		MoveRate.X = (Location.X - RemapActor.Location.X) * 0.1;
		if (Location.Y > RemapActor.Location.Y)
			bLerpingDownY = false;
		else
			bLerpingDownY = true;
		MoveRate.Y = (Location.Y - RemapActor.Location.Y) * 0.1;
	}
	else if (bLockPosition)
	{
		NewLoc = Location;
		if ( bNoZMove )
			NewLoc.Z = EventInstigator.Location.Z;
		p.SetLocation(NewLoc);
	}

	p.InputHookActor=self;

	if (bLerpRotation && bDontUnRemap)
	{
		Enable( 'Tick' );

		bLerpingRot = true;
		RotateViewTo();
	} else {
		p.bLockRotation=bLockRotation;
		p.RotationLockDirection=Rotation;
	}
	
	p.bLockFOV=bLockFOV;
	p.FOVLockTo=FOVLockTo;

	if ( bLockFOV )
	{
		p.OriginalFOV=p.DesiredFOV;
//		p.SetDesiredFOV(p.FOVLockTo);
		p.DesiredFOV = p.FOVLockTo;
		p.FOVLockTo=p.DesiredFOV;
	}

	p.bOneKeyAtATime = bOneKeyAtATime;
	p.bControlPanelHideWeapon = bHideWeapon;
	if ( bHideWeapon )
		p.WeaponDown( false, true );

	p.TurnLeftEvent=TurnLeftEvent;
	p.TurnRightEvent=TurnRightEvent;
	p.StrafeLeftEvent=StrafeLeftEvent;
	p.StrafeRightEvent=StrafeRightEvent;
	p.MoveForwardEvent=MoveForwardEvent;
	p.MoveBackwardEvent=MoveBackwardEvent;
	p.FireEvent=FireEvent;
	p.AltFireEvent=AltFireEvent;
	p.JumpEvent=JumpEvent;
	p.DuckEvent=DuckEvent;
	p.RelinquishControlEvent=Event;

	p.bTurnLeftContinuous=bTurnLeftContinuous;
	p.bTurnRightContinuous=bTurnRightContinuous;
	p.bStrafeLeftContinuous=bStrafeLeftContinuous;
	p.bStrafeRightContinuous=bStrafeRightContinuous;
	p.bMoveForwardContinuous=bMoveForwardContinuous; 
	p.bMoveBackwardContinuous=bMoveBackwardContinuous;
	p.bAltFireContinuous=bAltFireContinuous;
	p.bFireContinuous=bFireContinuous;
	p.bJumpContinuous=bJumpContinuous;
	p.bDuckContinuous=bDuckContinuous;

	p.TurnLeftEventEnd=TurnLeftEventEnd;
	p.TurnRightEventEnd=TurnRightEventEnd;
	p.StrafeLeftEventEnd=StrafeLeftEventEnd;
	p.StrafeRightEventEnd=StrafeRightEventEnd;
	p.MoveForwardEventEnd=MoveForwardEventEnd;
	p.MoveBackwardEventEnd=MoveBackwardEventEnd;
	p.AltFireEventEnd=AltFireEventEnd;
	p.FireEventEnd=FireEventEnd;
	p.JumpEventEnd=JumpEventEnd;
	p.DuckEventEnd=DuckEventEnd;
	//p.ActiveTerminal=ActiveTerminal;
}

function Tick(float Delta)
{
	local vector LocDelta, AdjustVector;
	local bool Adjust;

	Super.Tick(Delta);

	if ( (RemapActor == None) && bDontUnRemap )
		return;

	if ( bLerpRotation && bLerpingRot )
	{
		if (RemapActor.ViewRotation.Pitch != Rotation.Pitch)
			RemapActor.ViewRotation.Pitch = 
				FixedTurn( RemapActor.ViewRotation.Pitch, Rotation.Pitch, ViewRotationRate.Pitch * Delta );
		if (RemapActor.ViewRotation.Yaw != Rotation.Yaw)
			RemapActor.ViewRotation.Yaw = 
				FixedTurn( RemapActor.ViewRotation.Yaw, Rotation.Yaw, ViewRotationRate.Yaw * Delta );
		if (RemapActor.ViewRotation.Roll != Rotation.Roll)
			RemapActor.ViewRotation.Roll = 
				FixedTurn( RemapActor.ViewRotation.Roll, Rotation.Roll, ViewRotationRate.Roll * Delta );

		RemapActor.bLockRotation = true;
		RemapActor.RotationLockDirection = RemapActor.ViewRotation;
		if ((RemapActor.ViewRotation.Pitch == Rotation.Pitch) && (RemapActor.ViewRotation.Yaw == Rotation.Yaw))
		{
			bLerpingRot = false;
			RemapActor.RotationLockDirection = Rotation;
		}
	}

	if ( bLerpLocation && bLerpingLot )
	{
		// Find the move increments.
		if (RemapActor.Location.X != Location.X)
			LocDelta.X = MoveRate.X;
		if (RemapActor.Location.Y != Location.Y)
			LocDelta.Y = MoveRate.Y;

		// Set location.
		RemapActor.SetLocation( RemapActor.Location + LocDelta );

		// Check for too much movement.
		AdjustVector = RemapActor.Location;
		if (bLerpingDownX && (RemapActor.Location.X < Location.X))
		{
			Adjust = true;
			AdjustVector.X = Location.X;
		} 
		else if (!bLerpingDownX && (RemapActor.Location.X > Location.X))
		{
			Adjust = true;
			AdjustVector.X = Location.X;
		}

		if (bLerpingDownY && (RemapActor.Location.Y < Location.Y))
		{
			Adjust = true;
			AdjustVector.Y = Location.Y;
		}
		else if (!bLerpingDownY && (RemapActor.Location.Y > Location.Y))
		{
			Adjust = true;
			AdjustVector.Y = Location.Y;
		}

		if (Adjust)
			RemapActor.SetLocation( AdjustVector );

		if ((RemapActor.Location.X == Location.X) && (RemapActor.Location.Y == Location.Y))
			bLerpingLot = false;
	}

	if ( !bLerpingLot && !bLerpingRot )
		Disable( 'Tick' );
}

function bool Lerping()
{
	return bLerpingLot || bLerpingRot;
}

function RotateViewTo()
{
	local float Seconds;

	Seconds = 0.2;

	if (Rotation != RemapActor.ViewRotation)
	{
		ViewRotationRate.Yaw   = Abs(RotationDistance(RemapActor.ViewRotation.Yaw,   Rotation.yaw))/Seconds;
		ViewRotationRate.Pitch = Abs(RotationDistance(RemapActor.ViewRotation.Pitch, Rotation.pitch))/Seconds;
		ViewRotationRate.Roll  = Abs(RotationDistance(RemapActor.ViewRotation.Roll,  Rotation.roll))/Seconds;
	}
}

defaultproperties
{
	 bLockPosition=True
	 bDirectional=True
     Texture=Texture'Engine.S_ControlRemapper'
	 bHideWeapon=True
	 TurnScale=1.0
	 LookUpScale=1.0
	 ForwardScale=1.0
	 StrafeScale=1.0

}
