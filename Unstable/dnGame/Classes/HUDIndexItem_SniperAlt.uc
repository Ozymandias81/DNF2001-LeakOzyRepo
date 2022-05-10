/*-----------------------------------------------------------------------------
	HUDIndexItem_SniperAlt
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_SniperAlt extends HUDIndexItem_AltAmmo;

var localized string AmmoNames[2];
var localized string ZoomLevels[3];

simulated function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local float XL, YL, YLa;
	local float sX, sY;
	local int i;
	local SniperRifle DukeWeapon;

	DukeWeapon = SniperRifle(HUD.PawnOwner.Weapon);
	if (DukeWeapon == None)
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
	C.TextSize( AmmoNames[0], XL, YLa, FontScaleX, FontScaleY );
	C.SetPos( HUD.BarPos, YPos );
	C.DrawText( AmmoNames[0],,,, FontScaleX, FontScaleY );
	C.TextSize( DukeWeapon.AmmoType.ModeAmount[0], XL, YL, FontScaleX, FontScaleY );
	C.SetPos( HUD.BarPos+128.0*sX-XL, YPos );
	C.DrawText( DukeWeapon.AmmoType.ModeAmount[0],,,, FontScaleX, FontScaleY );
	YPos += YLa + HUD.ItemSpace-2;

	// Draw zoom level.
	C.TextSize( AmmoNames[1], XL, YLa, FontScaleX, FontScaleY );
	C.SetPos( HUD.BarPos, YPos );
	C.DrawText( AmmoNames[1],,,, FontScaleX, FontScaleY  );
	C.TextSize( ZoomLevels[DukeWeapon.ZoomPower], XL, YL, FontScaleX, FontScaleY );
	C.SetPos( HUD.BarPos+128.0*sX-XL, YPos );
	C.DrawText( ZoomLevels[DukeWeapon.ZoomPower],,,, FontScaleX, FontScaleY );

	C.DrawColor = HUD.WhiteColor;
}

simulated function GetSize( canvas C, DukeHUD HUD, out float XL, out float YL )
{
	local float YLa;

	if ( HUD.PawnOwner.Weapon == None )
	{
		XL = 0;
		YL = 0;
		return;
	}

	SetTextFont( C, HUD );
	C.TextSize( AmmoNames[0], XL, YLa, FontScaleX, FontScaleY );
	YL = YLa*2+HUD.ItemSpace-2;
}

defaultproperties
{
	Text="STATE"
	AmmoNames(0)="Energy"
	AmmoNames(1)="Zoom"
	ZoomLevels(0)="1x"
	ZoomLevels(1)="10x"
	ZoomLevels(2)="40x"
}