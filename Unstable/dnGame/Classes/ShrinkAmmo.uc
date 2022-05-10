/*-----------------------------------------------------------------------------
	ShrinkAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ShrinkAmmo extends Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

function bool UseAmmo(int AmountNeeded)
{
	ModeAmount[0] -= AmountNeeded;
	return true;
}

simulated function int GetModeAmount(int Mode)
{
	return ModeAmount[0];
}

function SetModeAmount(int Mode, int Amount)
{
}

simulated function int GetModeAmmo()
{
	return ModeAmount[0];
}

function SetModeAmmo(int Amount)
{
}

simulated function NextAmmoMode()
{
	AmmoMode++;
	if (AmmoMode >= MaxAmmoMode)
		AmmoMode = 0;
}

defaultproperties
{
	 MaxAmmoMode=2
	 ModeAmount(0)=40
     MaxAmmo(0)=400
     PickupViewMesh=Mesh'c_dnWeapon.a_shrinkbrain'
	 PickupIcon=texture'hud_effects.am_shrinkraybrain'
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
     Physics=PHYS_Falling
     Mesh=Mesh'c_dnWeapon.a_shrinkbrain'
     CollisionRadius=12.0
     CollisionHeight=5.0
     bCollideActors=true
	 ItemName="Alien Brain"
}