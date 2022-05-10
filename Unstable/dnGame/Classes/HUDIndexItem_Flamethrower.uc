/*-----------------------------------------------------------------------------
	HUDIndexItem_Flamethrower
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_Flamethrower extends HUDIndexItem_Ammo;

simulated function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local dnWeapon DukeWeapon;

	DukeWeapon = dnWeapon(HUD.PawnOwner.Weapon);
	if (DukeWeapon == None)
		return;

	Value = DukeWeapon.AmmoType.GetModeAmount(0);
	MaxValue = DukeWeapon.AmmoType.MaxAmmo[0];

	Super(HUDIndexItem).DrawItem( C, HUD, YPos );
}