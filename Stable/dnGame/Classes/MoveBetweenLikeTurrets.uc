/*-----------------------------------------------------------------------------
	MoveBetweenLikeTurrets
	Author: Brandon Reinhart

    A trigger for smoothly moving a player from one turret to another
	as well as copying the turret's properties.
-----------------------------------------------------------------------------*/
class MoveBetweenLikeTurrets extends Triggers;

var() name FromTurretTag;
var() name ToTurretTag;
var() bool bCopyAltFireEvent;

function Trigger( actor Other, pawn EventInstigator )
{
	local ControllableTurret FromTurret;
	local ControllableTurret ToTurret;
	local ControllableTurret t;
	local int i;

	// Find the turrets.
	foreach AllActors(class'ControllableTurret', t)
	{
		if (t.Tag == FromTurretTag)
			FromTurret = t;
		else if (t.Tag == ToTurretTag)
			ToTurret = t;
	}

	// Copy the turret properties.
	ToTurret.RotateRoll			= FromTurret.RotateRoll;
	ToTurret.SimRotateRoll		= FromTurret.SimRotateRoll;
	ToTurret.RotatePitch		= FromTurret.RotatePitch;
	ToTurret.SimRotatePitch		= FromTurret.SimRotatePitch;
	ToTurret.MaxPitch			= FromTurret.MaxPitch;
	ToTurret.MinPitch			= FromTurret.MinPitch;
	ToTurret.AnimMaxPitch		= FromTurret.AnimMaxPitch;
	ToTurret.AnimMinPitch		= FromTurret.AnimMinPitch;
	ToTurret.ViewRotation		= FromTurret.ViewRotation;
	ToTurret.bLerpingRot		= FromTurret.bLerpingRot;
	ToTurret.ViewRotationRate	= FromTurret.ViewRotationRate;
	ToTurret.ViewLocation		= FromTurret.ViewLocation;
	ToTurret.bLerpingLot		= FromTurret.bLerpingLot;
	ToTurret.bLerpingDownX		= FromTurret.bLerpingDownX;
	ToTurret.bLerpingDownY		= FromTurret.bLerpingDownY;
	ToTurret.bLerpingDownZ		= FromTurret.bLerpingDownZ;
	ToTurret.MoveRate			= FromTurret.MoveRate;
	ToTurret.AnimBlendFactor	= FromTurret.AnimBlendFactor;
	ToTurret.OldbFire			= FromTurret.OldbFire;
	ToTurret.bFiring			= FromTurret.bFiring;
	ToTurret.OldbAltFire		= FromTurret.OldbAltFire;
	ToTurret.bAltFiring			= FromTurret.bAltFiring;
	if (bCopyAltFireEvent)
		ToTurret.AltFireEvent		= FromTurret.AltFireEvent;
	ToTurret.bInterlock			= FromTurret.bInterlock;
	ToTurret.bLocalControl		= FromTurret.bLocalControl;

	// Copy timers.
	ToTurret.MaxTimers			= FromTurret.MaxTimers;
	for ( i=0; i<6; i++ )
	{
		ToTurret.TimerRate[i]	= FromTurret.TimerRate[i];
		ToTurret.TimerLoop[i]	= FromTurret.TimerLoop[i];
		ToTurret.SetTimerCounter( i, FromTurret.TimerCounter[i] );
	}

	// Setup the player also if needed.
	if ( FromTurret.InputActor != None )
	{
		ToTurret.InputActor	= FromTurret.InputActor;
		ToTurret.SetOwner( FromTurret.Owner );
		ToTurret.InputActor.MountParent = None;
		ToTurret.InputActor.ViewMapper	= ToTurret;
		ToTurret.InputActor.SetLocation( ToTurret.Location );
		ToTurret.InputActor.MountOrigin.Z = 0;
		ToTurret.InputActor.MountOrigin.Y = 0;
		ToTurret.InputActor.MountOrigin.Z = 63;
		ToTurret.InputActor.MountAngles.Pitch = -16384;
		ToTurret.InputActor.MountAngles.Yaw = 0;
		ToTurret.InputActor.MountAngles.Roll = 0;
		ToTurret.InputActor.AttachActorToParent( ToTurret );
		ToTurret.InputActor.MountPreviousLocation=ToTurret.InputActor.Location;
		ToTurret.InputActor.MountPreviousRotation=ToTurret.InputActor.Rotation;
	} else
		ToTurret.InputActor		= None;

	// Close the old turret down.
	FromTurret.bInterlock = true;
	FromTurret.bLocalControl = false;
	FromTurret.InputActor = None;
	FromTurret.SetOwner( None );
	FromTurret.bLerpingRot = false;
	FromTurret.bLerpingLot = false;
	FromTurret.bFiring = 0;
	FromTurret.OldbFire = 0;
	FromTurret.FireEnd();
}