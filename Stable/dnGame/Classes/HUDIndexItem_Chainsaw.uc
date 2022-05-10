/*-----------------------------------------------------------------------------
	HUDIndexItem_Chainsaw
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_Chainsaw extends HUDIndexItem_Ammo;

simulated function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local dnWeapon DukeWeapon;

	DukeWeapon = dnWeapon(HUD.PawnOwner.Weapon);
	if (DukeWeapon == None)
		return;

	Value = DukeWeapon.AmmoType.GetModeAmmo();
	MaxValue = DukeWeapon.AmmoType.MaxAmmo[0];

	Super(HUDIndexItem).DrawItem(C, HUD, YPos);
}


defaultproperties
{
	Text="FUEL"
}