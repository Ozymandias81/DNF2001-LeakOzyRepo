/*-----------------------------------------------------------------------------
	HUDIndexItem_RPG
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_RPG extends HUDIndexItem_Ammo;

simulated function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local dnWeapon DukeWeapon;

	DukeWeapon = dnWeapon(HUD.PawnOwner.Weapon);
	if (DukeWeapon == None)
		return;

	Value = DukeWeapon.AmmoType.GetModeAmmo();
	MaxValue = DukeWeapon.AmmoType.MaxAmmo[DukeWeapon.AmmoType.AmmoMode];

	Super(HUDIndexItem).DrawItem( C, HUD, YPos );
}