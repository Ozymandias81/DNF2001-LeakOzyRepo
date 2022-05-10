/*-----------------------------------------------------------------------------
	dnWeaponNoMesh
	Author: Brandon Reinhart

	A meshless weapon for certain kinds of mod.
-----------------------------------------------------------------------------*/
class dnWeaponNoMesh expands dnWeapon;

var() float RefireDelay;

/*-----------------------------------------------------------------------------
	Anim functions do nothing.
-----------------------------------------------------------------------------*/

simulated function WpnActivate()
{
	ThirdPersonScale = 1.0;
}

simulated function WpnDeactivated()
{
}

simulated function WpnFireStart( optional bool noWait )
{
}

simulated function WpnFire( optional bool noWait )
{
}

simulated function WpnFireStop( optional bool noWait )
{
}

simulated function WpnAltFireStart()
{
}

simulated function WpnAltFire()
{
}

simulated function WpnAltFireStop()
{
}

simulated function WpnReloadStart()
{
}

simulated function WpnReload( optional bool noWait )
{
}

simulated function WpnReloadStop()
{
}

simulated function WpnIdle()
{
}

/*-----------------------------------------------------------------------------
	States.
-----------------------------------------------------------------------------*/

state Active
{
	// Called when the state is entered.
	// We reset any variables that need reset, install the hud, and play the activate anim.
	simulated function BeginState()
	{
		// Set our instigator.
		Instigator = Pawn(Owner);

		// Reset relevant variables.
		bChangeWeapon = false;
		bCantSendFire = false;
		bDontAllowFire = false;
		Instigator.LastWeaponClass = Class;

		// Tag us as being up.
		bWeaponUp = true;

		GotoState('Idle');
	}
}

state DownWeapon
{
	simulated function BeginState()
	{
		// In this case, we change weapons when done animating.
		if ( !bClientDown && (Instigator.Weapon == Self) )
			Instigator.FinishWeaponChange();
		bClientDown = false;

		// Go to the waiting state.
		GotoState('Waiting');
	}
}

state Firing
{
	ignores Fire, AltFire;

	simulated function bool ClientFire()
	{
		return false;
	}

	simulated function bool ClientAltFire()
	{
		return false;
	}

	simulated function StartFiring()
	{
		if ( RefireDelay > 0 )
			SetTimer( RefireDelay, false );
		else
			GotoState('Idle');
	}

	simulated function Timer( optional int TimerNum )
	{
		GotoState('Idle');
	}
}

state Reloading
{
	simulated function BeginState()
	{
		ReloadAll( TempLoadCount );
		Pawn(Owner).ServerSetLoadCount( TempLoadCount );

		GotoState('Idle');
	}
}

defaultproperties
{
	RefireDelay=0.2
}