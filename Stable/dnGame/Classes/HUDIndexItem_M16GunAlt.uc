/*-----------------------------------------------------------------------------
	HUDIndexItem_M16GunAlt
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_M16GunAlt extends HUDIndexItem_AltAmmo;

var localized string AmmoNames[2];

simulated function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local float XL, YL, YLa;
	local dnWeapon DukeWeapon;
	local int i;
	local float sX, sY;

	if (HUD.PawnOwner.Weapon == None)
		return;
	DukeWeapon = dnWeapon(HUD.PawnOwner.Weapon);
	if (DukeWeapon == None)
		return;

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
	if ( PlayerPawn(DukeWeapon.AmmoType.Owner).bInfiniteAmmo )
    {
        C.DrawTile( InfiniteAmmoTexture, 
                    InfiniteAmmoTexture.USize,InfiniteAmmoTexture.VSize,
                    0,0,
                    InfiniteAmmoTexture.USize,InfiniteAmmoTexture.VSize
                  );
    }
    else
    {
        C.DrawText( DukeWeapon.AmmoType.ModeAmount[0],,,, FontScaleX, FontScaleY );
    }
	YPos += YLa + HUD.ItemSpace-2;

	// Draw secondary ammo count.
	C.TextSize( AmmoNames[1], XL, YLa, FontScaleX, FontScaleY );
	C.SetPos( HUD.BarPos, YPos );
	C.DrawText( AmmoNames[1],,,, FontScaleX, FontScaleY );
	C.TextSize( DukeWeapon.AltAmmoType.ModeAmount[0], XL, YL, FontScaleX, FontScaleY );
	C.SetPos( HUD.BarPos+128.0*sX-XL, YPos );
	if ( PlayerPawn(DukeWeapon.AmmoType.Owner).bInfiniteAmmo )
    {
        C.DrawTile( InfiniteAmmoTexture, 
                    InfiniteAmmoTexture.USize,InfiniteAmmoTexture.VSize,
                    0,0,
                    InfiniteAmmoTexture.USize,InfiniteAmmoTexture.VSize
                  );
    }
    else
    {
        C.DrawText( DukeWeapon.AltAmmoType.ModeAmount[0],,,, FontScaleX, FontScaleY );
    }

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
	Text="TYPE"
	AmmoNames(0)="7.62"
	AmmoNames(1)="40mm"
}