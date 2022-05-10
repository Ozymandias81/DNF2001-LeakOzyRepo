/*-----------------------------------------------------------------------------
	HUDIndexItem_AltMultiAmmo
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_AltMultiAmmo extends HUDIndexItem_AltAmmo;

var localized string AmmoNames[4];
var int OldModeAmount[4];
var float AmmoNamesX[4], AmmoNamesY[4];
var float ModeAmountX[4], ModeAmountY[4];
var float TextSizeX, TextSizeY;
var float GlowScale;
var int OldMode;
var bool bModesOnly, bAlwaysDraw;
var Ammo ma;

simulated function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local float XL, YL;
	local dnWeapon DukeWeapon;
	local int i, Amount;
	local float sX, sY;

	if ( HUD.PawnOwner.Weapon == None )
		return;
	DukeWeapon = dnWeapon(HUD.PawnOwner.Weapon);
	if ( DukeWeapon == none )
		return;

	BarColor = HUD.TextColor;

	sX = HUD.HUDScaleX;
	sY = HUD.HUDScaleY;
	ma = DukeWeapon.AmmoType;

	if ( ma == None )
	{
		Log("Tried to draw"@Self@"but"@DukeWeapon@"has no AmmoType.");
		return;
	}

	if ( ma.AmmoMode != OldMode )
	{
		Enable( 'Tick' );
		GlowScale = 1.0;
		OldMode = ma.AmmoMode;
		bUpdateSizes = true;
	}
	if ( (OldsX != sX) || (OldsY != sY) )
		bUpdateSizes = true;
	if ( (ScaledMaxLength == 0) || bUpdateSizes )
		ScaledMaxLength = 114.0 * sX;

	// Draw text label.
	GetSize( C, HUD, XL, YL );
	C.SetPos( HUD.TextRightAdjust-XL, YPos );
	C.DrawText( Text,,,, FontScaleX, FontScaleY );

	// Draw multi entries.
	for (i=0; i<ma.MaxAmmoMode; i++)
	{
		if ( (ma.GetModeAmount(i) > 0) || (ma.AmmoMode == i) || bAlwaysDraw )
		{
			// Set the font.  Large if highlighted, otherwise small.
			SetSpecialFontColor( C, HUD, ma, i );

			// Get the size of the entry's name.  Only do this if we need to.
			if ( bUpdateSizes || (AmmoNamesX[i] == 0) )
				C.TextSize( AmmoNames[i], AmmoNamesX[i], AmmoNamesY[i], FontScaleX, FontScaleY );

			// Draw the entry's name.
			C.SetPos( HUD.BarPos, YPos );
			C.DrawText( AmmoNames[i],,,, FontScaleX, FontScaleY );

			SetValueFont( C, HUD );
			// Get the size of the ammo amount entry.  Again, only do this if we need to.
			Amount = ma.GetModeAmount(i);
			if ( bUpdateSizes || (ModeAmountX[i] == 0) || (OldModeAmount[i] != Amount) )
			{
				OldModeAmount[i] = Amount;
				C.TextSize( Amount, ModeAmountX[i], ModeAmountY[i], FontScaleX, FontScaleY );
			}

			// Draw the ammo amount entry.
			C.SetPos( HUD.BarPos+ScaledMaxLength, YPos );
        	if ( !bModesOnly )
            {
                if ( PlayerPawn(ma.Owner).bInfiniteAmmo )
                    C.DrawTile( InfiniteAmmoTexture, 
                                InfiniteAmmoTexture.USize,InfiniteAmmoTexture.VSize,
                                0,0,
                                InfiniteAmmoTexture.USize,InfiniteAmmoTexture.VSize
                              );
                else
				{
					SetSpecialFontColor( C, HUD, ma, i );
    		        C.DrawText( Amount,,,, FontScaleX, FontScaleY );
				}
            }
			SetTextFont( C, HUD );

			// Update our Y position.
			YPos += AmmoNamesY[i];
		}
	}

	OldsX = sX; OldsY = sY;
	C.DrawColor = HUD.WhiteColor;
	bUpdateSizes = false;
}

// Returns a large font if this mode selected, otherwise small.
simulated function SetSpecialFontColor( canvas C, DukeHUD HUD, Ammo ma, int Mode )
{
	if ( ma.AmmoMode == Mode )
	{
		if ( GlowScale == 1.0 )
			C.DrawColor = BarColor;
		else
		{
			C.DrawColor.R = BarColor.R + (255 - BarColor.R)*GlowScale;
			C.DrawColor.G = BarColor.G + (255 - BarColor.G)*GlowScale;
			C.DrawColor.B = BarColor.B + (255 - BarColor.B)*GlowScale;
		}
	}
	else
	{
		C.DrawColor.R = BarColor.R / 2.0;
		C.DrawColor.G = BarColor.G / 2.0;
		C.DrawColor.B = BarColor.B / 2.0;
	}
}

// Returns the overall size of the control.
simulated function GetSize( canvas C, DukeHUD HUD, out float XL, out float YL )
{
	local float YLa, YLb;
	local int i;
	local bool AtLeastOneRow;

	if ( HUD.PawnOwner.Weapon == None )
	{
		XL = 0;
		YL = 0;
		return;
	}

	if ( ma == none )
		return;
/*
	if ( ItemSize == IS_Large )
	{
		FontScaleX = 0.7 * HUD.HUDScaleX;
		FontScaleY = 0.7 * HUD.HUDScaleY;
	}
	else
	{
		FontScaleX = 0.4 * HUD.HUDScaleX;
		FontScaleY = 0.4 * HUD.HUDScaleY;
	}
*/
	SetTextFont( C, HUD );

	// Accumulate the control's height.
	YL = 0;
	for ( i=0; i<ma.MaxAmmoMode; i++ )
	{
		if ( (ma.GetModeAmount(i) > 0) || (ma.AmmoMode == i) || bAlwaysDraw )
		{
			if ( (OldsX != HUD.HUDScaleX) || (AmmoNamesY[i] == 0) )
				C.TextSize( AmmoNames[i], AmmoNamesX[i], AmmoNamesY[i], FontScaleX, FontScaleY );
			YL += AmmoNamesY[i];
			AtLeastOneRow = true;
		}
	}

	// Compensate for the spacing the HUD will add.
	if ( AtLeastOneRow )
		YL -= HUD.ItemSpace-2;

	// Get a valid length for the label.
	if ( (OldsX != HUD.HUDScaleX) || (OldsY != HUD.HUDScaleY) || (TextSizeY == 0) )
		C.TextSize( Text, TextSizeX, TextSizeY, FontScaleX, FontScaleY );
	XL = TextSizeX;
}

// Scales the glow for selection.
simulated event Tick( float Delta )
{
	if ( GlowScale > 0.0 )
	{
		GlowScale -= Delta*2;
		if ( GlowScale < 0.0 )
		{
			GlowScale = 0.0;
			Disable( 'Tick' );
		}
	}
}

defaultproperties
{
	Text="TYPE"
	AmmoNames(0)="Type 1"
	AmmoNames(1)="Type 2"
	AmmoNames(2)="Type 3"
	AmmoNames(3)="Type 4"
	GlowScale=0
}
