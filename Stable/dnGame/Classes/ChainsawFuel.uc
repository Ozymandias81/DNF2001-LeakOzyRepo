/*-----------------------------------------------------------------------------
	ChainsawFuel
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ChainsawFuel expands Ammo;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

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
	 MaxAmmoMode=3
     ModeAmount(0)=25
     MaxAmmo(0)=200
	 PickupIcon=texture'hud_effects.am_gascan'
     PickupViewMesh=Mesh'c_dnWeapon.a_gascan'
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
     Physics=PHYS_Falling
     Mesh=Mesh'c_dnWeapon.a_gascan'
     bMeshCurvy=False
     CollisionRadius=12.0
     CollisionHeight=12.0
     bCollideActors=true
	 LodMode=LOD_Disabled
	 ItemName="Fuel Can"
	 DrawScale=0.7
	 PickupViewScale=0.7
}
