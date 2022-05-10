/*-----------------------------------------------------------------------------
	HUDIndexItem_EGO
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_DMFrags extends HUDIndexItem;
/*
function color GetValueBarColor( int Lead )
{
	local Color rColor;

	if ( Lead < 0 ) // Losing = red
		rColor = LightBarRedColor;
	else if ( Lead > 0 ) // Leading = normal
		rColor = LightBarColor;
	else  // Tied = yellow
		rColor = LightBarYellowColor;

	return rColor;
}

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local float			XL, YL, YL2, LeaderLength, LeaderScaledLength;
	local float			sX, sY;
	local int			i, Lead, HighScore;
	local bool			bTiedScore;
	local PlayerPawn	PlayerOwner;
	local string        ValueString;

	PlayerOwner	= PlayerPawn( HUD.PawnOwner );

	Value		= dnDeathmatchGameHUD( HUD ).Score;
	MaxValue	= dnDeathmatchGameHUD( HUD ).FragLimit;
	HighScore   = dnDeathmatchGameHUD( HUD ).HighScore;
	Lead        = dnDeathmatchGameHUD( HUD ).Lead;
	bTiedScore  = dnDeathmatchGameHUD( HUD ).bTiedScore;	

	// Draw bar index entry.
	YPos = int(YPos);
	
	sX = HUD.HUDScaleX;
	sY = HUD.HUDScaleY;
	
	if ( ( OldsX != sX ) || ( OldsY != sY ) || ( Value != LastValue ) )
		bUpdateSizes = true;

	// Set the color if it has changed.
	if ( LightBarColor != HUD.HUDColorBright )
	{
		LightBarColor	= HUD.HUDColorBright;
		DarkBarColor	= LightBarColor;
		DarkBarColor.R /= 4;
		DarkBarColor.G /= 4;
		DarkBarColor.B /= 4;
	}

	C.DrawColor = HUD.TextColor;
	
	// Draw the text value of the bar
	GetSize(C, HUD, XL, YL);
	C.SetPos( HUD.TextRightAdjust-XL, YPos );
	C.DrawText( Text, false );

	// Setup basic values.
	if ( ( MaxLength != 192.0 ) || bUpdateSizes )
	{
		MaxLength		= 192.0;
		ScaledMaxLength = MaxLength * sX;
	}
	
	if ( MaxValue != 0 )
	{
		if ( ( Value != LastValue ) || ( Length==0 ) || bUpdateSizes )
		{
			Length		 = MaxLength * FClamp(float(Value) / float(MaxValue), 0.0, 1.0 );
			ScaledLength = Length * sX;
		}
		else
		{
			Length		= OldLength;
			ScaledLength= OldScaledLength;
		}
	}
	else // No Fraglimit set
	{
		Length		 = 0;
		ScaledLength = 0;
	}

	OldLength		= Length;
	OldScaledLength = ScaledLength;

	// Determine if we need to add a new fading segment.
	if ( ( Value < LastValue ) && ( LastValue <= MaxValue ) )
		AddFadeSegment(C);

	LastValue = Value;

	// Start flashing if we dropped below the threshold.
	if ( FlashingBar && ( Value < FlashThreshold ) && !Flashing )
	{
		Enable( 'Tick' );
		Flashing	= true;
		FlashTime	= 1.0;
		FlashUp		= false;
	}

	if ( MaxValue != 0 )
	{
		// Draw the score bar.
		C.SetPos( HUD.BarPos, YPos );
		C.DrawColor = GetValueBarColor( Lead );
		C.DrawTile( HUD.GradientTexture, ScaledLength, YL, 0, 0, ScaledLength, YL );

		// Draw the leader's bar
		if ( Lead < 0 )
		{
			LeaderLength		= MaxLength * FClamp(float(-Lead) / float(MaxValue), 0.0, 1.0 );
			LeaderScaledLength  = LeaderLength * sX;

			C.DrawColor			= LightBarYellowColor;
			C.SetPos( HUD.BarPos + ScaledLength, YPos );
			C.DrawTile( HUD.GradientTexture, LeaderScaledLength, YL, 0, 0, LeaderScaledLength, YL );
		}
	}

	// Draw the background bar.
	if ( Length < MaxLength )
	{
		C.SetPos( HUD.BarPos + ScaledLength, YPos );
		C.DrawColor = GetDarkBarColor();
		C.DrawTile( HUD.GradientTexture, ScaledMaxLength - ScaledLength, YL, ScaledLength, 0, ScaledMaxLength - ScaledLength, YL );
	}

	// Draw the fade bars.
	for (i=0; i<16; i++)
	{
		if (FadeSegments[i].FadeTime > 0.0)
		{
			C.SetPos( HUD.BarPos + FadeSegments[i].SegPos*sX, YPos );
			C.DrawColor = GetBarFadeColor( FadeSegments[i].FadeTime );
			C.DrawTile( HUD.GradientTexture, FadeSegments[i].SegLen*sX, YL, FadeSegments[i].SegPos*sX, 0, FadeSegments[i].SegLen*sX, YL );
		}
	}

	// Draw the value on top.
	C.DrawColor = HUD.TextColor;
	if ( Lead > 0 )
		ValueString = Value @ "(+" $ Lead $ ")";
	else
		ValueString = Value @ "(" $ Lead $ ")";

	if ( bUpdateSizes || (ValueLenX == 0) || (HUD.BarPos != OldBarPos) || (YPos != OldYPos) )
	{
		OldBarPos = HUD.BarPos;
		C.TextSize( ValueString, XL, YL2 );
		ValueLenX = HUD.BarPos + ( ScaledMaxLength - XL ) / 2;
		ValueLenY = YPos + (YL - YL2)/2;
	}
	C.SetPos( ValueLenX, ValueLenY );
	C.DrawText( ValueString, false );

	if ( MaxValue != 0 )
	{
		C.SetPos( HUD.BarPos + ScaledMaxLength + 5, ValueLenY );
		C.DrawText( MaxValue, false );
	}

	OldYPos			= YPos;
	OldsX			= sX; OldsY = sY;
	C.DrawColor		= HUD.WhiteColor;
	bUpdateSizes	= false;
}
*/
defaultproperties
{
	Text="Frags"
}
