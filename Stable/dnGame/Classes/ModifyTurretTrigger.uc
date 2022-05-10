/*-----------------------------------------------------------------------------
	ModifyTurretTrigger
	Author: Brandon Reinhart

    A trigger for functionality that the level designers can change on the fly.
-----------------------------------------------------------------------------*/
class ModifyTurretTrigger extends Triggers;

var() name TurretTag;
var() bool UnlockTurret;
var() bool LockTurret;

function Trigger( actor Other, pawn EventInstigator )
{
	local ControllableTurret ModTurret;
	local ControllableTurret t;

	// Find the turret.
	foreach AllActors(class'ControllableTurret', t)
	{
		if (t.Tag == TurretTag)
		{
			ModTurret = t;
			break;
		}
	}

	// Unlock.
	if ( UnlockTurret )
	{
		t.bPlayerLockedIn = false;
		t.bLockPlayerOnUse = false;
	}

	// Lock.
	if ( LockTurret )
	{
		t.bLockPlayerOnUse = true;
		if ( t.InputActor != None )
			t.bPlayerLockedIn = true;
	}
}