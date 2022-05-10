/*-----------------------------------------------------------------------------
	HUDIndexItem_Ammo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_Ammo extends HUDIndexItem;

simulated function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local dnWeapon DukeWeapon;

	DukeWeapon = dnWeapon(HUD.PawnOwner.Weapon);
	if (DukeWeapon == None)
		return;

	Value = DukeWeapon.AmmoLoaded;
	MaxValue = DukeWeapon.ReloadCount;

	Super.DrawItem(C, HUD, YPos);
}

defaultproperties
{
	Text="AMMO"
	ItemSize=IS_Small
}