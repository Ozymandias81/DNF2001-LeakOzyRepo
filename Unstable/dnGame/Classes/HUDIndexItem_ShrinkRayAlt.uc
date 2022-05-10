/*-----------------------------------------------------------------------------
	HUDIndexItem_ShrinkRayAlt
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_ShrinkRayAlt extends HUDIndexItem_AltAmmo;

var localized string AmmoName;

simulated function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local float XL, YL, YLa;
	local float sX, sY;
	local int i;
	local Shrinkray DukeWeapon;

	DukeWeapon = Shrinkray(HUD.PawnOwner.Weapon);
	if ( DukeWeapon == None )
		return;

	YPos = int(YPos);
	sX = HUD.HUDScaleX;
	sY = HUD.HUDScaleY;
	C.DrawColor = BarColor;
	BarColor = HUD.TextColor;

	// Draw Index entry.
	SetTextFont( C, HUD );
	C.TextSize( Text, XL, YL, FontScaleX, FontScaleY );
	C.SetPos( HUD.TextRightAdjust-XL, YPos );
	C.DrawText( Text,,,, FontScaleX, FontScaleY );

	// Draw primary ammo count.
	C.TextSize( AmmoName, XL, YLa, FontScaleX, FontScaleY );
	C.SetPos( HUD.BarPos, YPos );
	C.DrawText( AmmoName,,,, FontScaleX, FontScaleY );
	C.TextSize( DukeWeapon.AmmoType.ModeAmount[0], XL, YL, FontScaleX, FontScaleY );
	C.SetPos( HUD.BarPos+128.0*sX-XL, YPos );
	C.DrawText( DukeWeapon.AmmoType.ModeAmount[0],,,, FontScaleX, FontScaleY );

	C.DrawColor = HUD.WhiteColor;
}

simulated function GetSize( canvas C, DukeHUD HUD, out float XL, out float YL )
{
	if ( HUD.PawnOwner.Weapon == None )
	{
		XL = 0;
		YL = 0;
		return;
	}

	SetTextFont( C, HUD );
	C.TextSize( AmmoName, XL, YL, FontScaleX, FontScaleY );
}

defaultproperties
{
	Text="STATE"
	AmmoName="Energy"
}