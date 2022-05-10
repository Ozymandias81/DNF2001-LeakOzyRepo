/*-----------------------------------------------------------------------------
	HUDIndexItem_WeaponAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_WeaponAmmo extends HUDIndexItem;

var PlayerPawn PlayerOwner;

function PostBeginPlay()
{
	PlayerOwner = PlayerPawn(Owner);
}

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local dnWeapon DukeWeapon;

	if ( PlayerOwner == None )
		return;
	if ( PlayerOwner.Weapon == None )
		return;
	
	DukeWeapon = dnWeapon(PlayerOwner.Weapon);

	if ( DukeWeapon.AmmoItem != None )
		DukeWeapon.AmmoItem.DrawItem( C, HUD, YPos );
}

function GetSize( canvas C, DukeHUD HUD, out float XL, out float YL )
{
	local dnWeapon DukeWeapon;

	XL = 0; YL = 0;
	if ( PlayerOwner == None )
		return;
	if ( PlayerOwner.Weapon == None )
		return;

	DukeWeapon = dnWeapon(PlayerOwner.Weapon);
	if ( DukeWeapon.AmmoItem != None )
		DukeWeapon.AmmoItem.GetSize( C, HUD, XL, YL );
}