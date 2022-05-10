/*-----------------------------------------------------------------------------
	HUDIndexItem_AltAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_AltAmmo extends HUDIndexItem;

var texture InfiniteAmmoTexture;

simulated function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local dnWeapon DukeWeapon;

	DukeWeapon = dnWeapon(HUD.PawnOwner.Weapon);
	if (DukeWeapon == None)
		return;

	Value = DukeWeapon.AltAmmoLoaded;
	MaxValue = DukeWeapon.AltReloadCount;

	Super.DrawItem( C, HUD, YPos );
}

function GetSize( canvas C, DukeHUD HUD, out float XL, out float YL )
{
	if ( HUD.PawnOwner.Weapon != None )
		Super.GetSize( C, HUD, XL, YL );
	else
	{
		XL = 0;
		YL = 0;
	}
}

defaultproperties
{
	Text="Alt"
    InfiniteAmmoTexture=texture'hud_effects.ingame_hud.crosshair1BC'    
}