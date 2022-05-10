/*-----------------------------------------------------------------------------
	HUDIndexItem_DecoHealth
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_DecoHealth extends HUDIndexItem;

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local float OldOrgX, OldOrgY, XPos;
	local float XL, YL, YL2, iXL;
	local float sX, sY, BarScale;
	local int i;

	YPos = int(YPos);
	sX = HUD.HUDScaleX;
	sY = HUD.HUDScaleY;

	BarColor = HUD.HUDColor;
	TextColor = HUD.TextColor;

	// Draw the bar title.
	GetSize( C, HUD, XL, YL );
	C.DrawColor = GetTextColor();
	C.SetPos( HUD.BarPos, YPos );
	C.DrawText( Text,,,, FontScaleX, FontScaleY );

	// Draw the bar outline area and tip, if we have one.
	C.DrawColor = HUD.HUDColor;
	C.SetPos( HUD.BarPos + 4.0*sX + XL, YPos );
	C.DrawScaledIcon( BarTex[ItemSize], sX, sY, true );

	// Find out how much of the bar is filled.
	SetTextFont( C, HUD );
	BarScale = FClamp( float(Value) / float(MaxValue), 0.0, 1.0 );
	MaxLength = GradientTipOffset[ItemSize] * sX;
	Length = MaxLength * BarScale;

	// Start flashing if we dropped below the threshold.
	if ( FlashingBar && (Value < FlashThreshold) && !Flashing )
	{
		Enable( 'Tick' );
		Flashing = true;
		FlashTime = 1.0;
		FlashUp = false;
	}

	// Draw the gradient.
	C.SetPos( HUD.BarPos + 4.0*sX + XL, YPos );
	XL = GradientTipOffset[ItemSize] * sX * BarScale;
	YL = BarHeights[ItemSize] * sY;
	if ( StopLightingBar && ((float(Value)/float(MaxValue)) < 0.5) )
		C.DrawTile( GSGradientTexture, XL, YL, 0, 0, BarTex[ItemSize].USize * sX, GradientTexture.VSize,,,,false );
	else
		C.DrawTile( GradientTexture, XL, YL, 0, 0, BarTex[ItemSize].USize * sX, GradientTexture.VSize,,,,false );

	C.DrawColor = HUD.WhiteColor;
}

defaultproperties
{
	Text="HEALTH"
	StopLightingBar=true
	FlashingBar=false
}