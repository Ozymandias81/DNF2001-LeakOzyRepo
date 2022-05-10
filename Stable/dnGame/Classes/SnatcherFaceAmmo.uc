/*-----------------------------------------------------------------------------
	SnatcherFaceAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class SnatcherFaceAmmo extends Ammo;

function bool UseAmmo( int AmountNeeded )
{
	return true;
}

simulated function int GetModeAmount( int Mode )
{
	return 1;
}

function SetModeAmount(int Mode, int Amount)
{
}

simulated function int GetModeAmmo()
{
	return 1;
}

function SetModeAmmo(int Amount)
{
}

simulated function NextAmmoMode()
{
}

defaultproperties
{
}