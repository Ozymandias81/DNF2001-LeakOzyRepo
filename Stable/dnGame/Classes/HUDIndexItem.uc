/*-----------------------------------------------------------------------------
	HUDIndexItem
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem extends Info;

var localized string	Text;
var enum EItemSize
{
	IS_Large,
	IS_Medium,
	IS_Small,
	IS_VerySmall,
}						ItemSize;
var float				FontScaleX, FontScaleY;

// Bar textures.
var texture				BarTex[4];
var texture				BarTexTips[4];
var texture				BarTexTipHighlights[4];
var texture				GradientTexture;
var texture				GSGradientTexture;
var texture				SolidTexture;

// Positioning values.  In scale to a 1024x768 resolution.  They need to be scaled by the current ratio to that baseline.
var float				BarHeights[4];				// Full height of the bar, including outline.
var float				BarTipInsets[4];			// Amount of inset to draw the outline bar tip, if it has one.
var float				ValueXPos[4];				// Where to draw the numerical value at the end of the bar.
var float				GradientTipOffset[4];		// Where to draw the gradient tip.
var float				FontAdjust[4];

// Bar.
var int					Value, MaxValue, LastValue;
var float				ValueDelta, ValueLenX, ValueLenY, OldBarPos;
var float				SizeX, SizeY, OldsX, OldsY, OldYPos;
var bool				bDrawForSpectator; // Set to true if you want to draw the index for a spectator viewing you

// Stop lighting bars.
var color				BarColor, BarRedColor, BarYellowColor, TextColor;
var bool				StopLightingBar, bUpdateSizes;

// Low value pulse.
var bool Flashing, FlashingBar, FlashUp;
var float FlashTime, FlashThreshold;

// Length values.  Valid after a call to DrawItem.
var float Length, OldLength, MaxLength, ScaledLength, OldScaledLength, ScaledMaxLength;

// Fading segments.
struct FadeSegment
{
	var float SegLen;
	var float SegPos;
	var float FadeTime;
};
var FadeSegment FadeSegments[16];
var bool FadeBarHint, FadeTip;
var float FadeTipTime;

function PostBeginPlay()
{
	Disable('Tick');
}

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local float OldOrgX, OldOrgY, XPos;
	local float XL, YL, YL2, iXL;
	local float sX, sY, BarScale;
	local int i;

	YPos = Round(YPos);
	sX = HUD.HUDScaleX;
	sY = HUD.HUDScaleY;

	BarColor = HUD.HUDColor;
	TextColor = HUD.TextColor;

	// Draw the bar title.
	GetSize( C, HUD, XL, YL );
	C.DrawColor = GetTextColor();
	C.SetPos( HUD.TextRightAdjust-XL, YPos - (YL-BarTex[ItemSize].VSize*sY)/2.0 - FontAdjust[ItemSize]*sY );
	C.DrawText( Text,,,, FontScaleX, FontScaleY );

	// Draw the bar outline area and tip, if we have one.
	C.DrawColor = HUD.HUDColor;
	C.SetPos( HUD.BarPos, YPos );
	C.DrawScaledIcon( BarTex[ItemSize], sX, sY, true );
	if ( BarTexTips[ItemSize] != None )
	{
		XPos = HUD.BarPos+BarTex[ItemSize].USize*sX;
		OldOrgX = C.OrgX; OldOrgY = C.OrgY;
		C.SetOrigin( XPos, YPos );

		C.SetPos( -BarTipInsets[ItemSize]*sX, 0 );
		C.DrawScaledIconClipped( BarTexTips[ItemSize], sX, sY, true );

		C.SetOrigin( OldOrgX, OldOrgY );
	}

	// Draw the value on the opposite end.
	SetValueFont( C, HUD );
	C.SetPos( HUD.BarPos + ValueXPos[ItemSize]*sX, YPos - (YL-BarTex[ItemSize].VSize*sY)/2.0 - FontAdjust[ItemSize]*sY );
	C.DrawText( Value,,,, FontScaleX, FontScaleY );
	SetTextFont( C, HUD );

	// Find out how much of the bar is filled.
	BarScale = FClamp( float(Value) / float(MaxValue), 0.0, 1.0 );
	MaxLength = GradientTipOffset[ItemSize] * sX;
	Length = MaxLength * BarScale;

	// Determine if we need to add a new fading segment.
	if ( (Value < LastValue) && (LastValue <= MaxValue) )
	{
		AddFadeSegment( C, HUD );
		if ( (LastValue >= MaxValue) && (Value < MaxValue) )
		{
			Enable('Tick');
			FadeTip = true;
			FadeTipTime = 1.0;
			FadeBarHint = true;
		}
	}
	if ( Value >= MaxValue )
		FadeTip = false;
	LastValue = Value;

	// Start flashing if we dropped below the threshold.
	if ( FlashingBar && (Value < FlashThreshold) && !Flashing )
	{
		Enable( 'Tick' );
		Flashing = true;
		FlashTime = 1.0;
		FlashUp = false;
	}

	// Draw the gradient.
	C.SetPos( HUD.BarPos, YPos );
	XL = GradientTipOffset[ItemSize] * sX * BarScale;
	YL = BarHeights[ItemSize] * sY;
	if ( StopLightingBar && ((float(Value)/float(MaxValue)) < 0.5) )
		C.DrawTile( GSGradientTexture, XL, YL, 0, 0, BarTex[ItemSize].USize/* * sX*/, GradientTexture.VSize,,,,false );
	else
		C.DrawTile( GradientTexture, XL, YL, 0, 0, BarTex[ItemSize].USize/* * sX*/, GradientTexture.VSize,,,,false );

	// Draw the gradient tip.
	if ( (BarTexTips[ItemSize] != None) && ((BarScale == 1.0) || FadeTip) )
	{
		if ( FadeTip )
		{
			C.DrawColor.R = 150 * FadeTipTime;
			C.DrawColor.G = 150 * FadeTipTime;
			C.DrawColor.B = 150 * FadeTipTime;
		}
		C.SetPos( HUD.BarPos + GradientTipOffset[ItemSize]*sX, YPos );
		C.DrawScaledIcon( BarTexTipHighlights[ItemSize], sX, sY, true );
	}

	// Draw the fade bars.
	for ( i=0; i<16; i++ )
	{
		if ( FadeSegments[i].FadeTime > 0.0 )
		{
			C.DrawColor = HUD.HUDColor;
			C.SetPos( HUD.BarPos + FadeSegments[i].SegPos, YPos );
			C.DrawColor = GetBarFadeColor( FadeSegments[i].FadeTime );
			C.DrawTile( SolidTexture, FadeSegments[i].SegLen, YL, FadeSegments[i].SegPos*sX, 0, BarTex[ItemSize].USize * sX * BarScale/*FadeSegments[i].SegLen*sX*/, YL );
		}
	}

	C.DrawColor = HUD.WhiteColor;
}

function AddFadeSegment( canvas C, DukeHUD HUD )
{
	local int i;
	local float SegScale;

	Enable( 'Tick' );
	FadeBarHint = true;
	ValueDelta = LastValue - Value;
	SegScale = FClamp( ValueDelta / MaxValue, 0.0, 1.0 );
	for ( i=0; i<16; i++ )
	{
		if ( FadeSegments[i].FadeTime <= 0.0 )
		{
			FadeSegments[i].FadeTime = 1.0;
			FadeSegments[i].SegLen = MaxLength * SegScale;
			FadeSegments[i].SegPos = Length;
			return;
		}
	}
}

function GetSize( canvas C, DukeHUD HUD, out float XL, out float YL )
{
	SetTextFont( C, HUD );
	C.TextSize( Text, XL, YL, FontScaleX, FontScaleY );

	YL = Round(BarHeights[ItemSize] * HUD.HUDScaleY);
}

function SetTextFont( canvas C, DukeHUD HUD )
{
	if ( ItemSize == IS_Large )
	{
		FontScaleX = 1.0;
		FontScaleY = 1.0;
	}
	else
	{
		if ( C.ClipX > 640 )
		{
			FontScaleX = 0.7;
			FontScaleY = 0.7;
		}
		else
		{
			FontScaleX = 0.6;
			FontScaleY = 0.6;
		}
	}

	C.DrawColor = GetBarColor();
	if ( C.ClipX > 640 )
	{
		FontScaleX *= HUD.HUDScaleX;
		FontScaleY *= HUD.HUDScaleY;
		C.Font = font'hudfont';
	}
	else
	{
		C.Font = font'hudfontsmall';
	}
}

function SetValueFont( canvas C, DukeHUD HUD )
{
	SetTextFont( C, HUD );
	/*
	if ( ItemSize == IS_Large )
	{
		FontScaleX = 1.0;
		FontScaleY = 1.0;
	}
	else
	{
		FontScaleX = 0.7;
		FontScaleY = 0.7;
	}

	C.DrawColor = GetTextColor();
	if ( C.ClipX > 640 )
	{
		FontScaleX *= HUD.HUDScaleX;
		FontScaleY *= HUD.HUDScaleY;
		C.Font = font'eurosewidesmall';
	}
	else
		C.Font = font'eurosewidesmallsmall';
	*/
}

function color GetBarColor()
{
	local Color rColor;

	if ( StopLightingBar )
	{
		if ( (float(Value)/float(MaxValue)) < 0.25 )
			rColor = BarRedColor;
		else if ( (float(Value)/float(MaxValue)) < 0.5 )
			rColor = BarYellowColor;
		else
			rColor = BarColor;
	} else
		rColor = BarColor;

	if ( Flashing )
	{
		rColor.R = rColor.R * FlashTime;
		rColor.G = rColor.G * FlashTime;
		rColor.B = rColor.B * FlashTime;
	}

	return rColor;
}

function color GetTextColor()
{
	local Color rColor;

	if ( StopLightingBar )
	{
		if ( (float(Value)/float(MaxValue)) < 0.25 )
			rColor = BarRedColor;
		else if ( (float(Value)/float(MaxValue)) < 0.5 )
			rColor = BarYellowColor;
		else
			rColor = TextColor;
	} else
		rColor = TextColor;

	if ( Flashing )
	{
		rColor.R = rColor.R * FlashTime;
		rColor.G = rColor.G * FlashTime;
		rColor.B = rColor.B * FlashTime;
	}

	return rColor;
}

function color GetBarFadeColor( float FadeScale )
{
	local Color rColor;

	rColor.R = 150*FadeScale;
	rColor.G = 150*FadeScale;
	rColor.B = 150*FadeScale;

	return rColor;
}

// Updates color scales.
simulated function Tick( float Delta )
{
	local int i, FadeCount;

	if ( Flashing )
	{
		if ( FlashUp )
		{
			FlashTime += Delta*1.5;
			if ( FlashTime >= 1.0 )
			{
				FlashUp = false;
				FlashTime = 1.0;
				if ( Value >= FlashThreshold )
				{
					if ( !FadeBarHint )
						Disable( 'Tick' );
					Flashing = false;
				}
			}
		}
		else
		{
			FlashTime -= Delta*1.5;
			if ( FlashTime <= 0.0 )
			{
				FlashUp = true;
				FlashTime = 0.0;
			}
		}
	}

	if ( FadeBarHint )
	{
		for ( i=0; i<16; i++ )
		{
			if ( FadeSegments[i].FadeTime > 0.0 )
			{
				FadeSegments[i].FadeTime -= Delta;
				if ( FadeSegments[i].FadeTime < 0.0 )
					FadeSegments[i].FadeTime = 0.0;
				FadeCount++;
			}
		}
		if ( FadeTipTime > 0.0 )
		{
			FadeTipTime -= Delta;
			if ( FadeTipTime < 0.0 )
			{
				FadeTipTime = 0.0;
				FadeTip = false;
			}
		}
		if ( (FadeCount == 0) && (FadeTipTime == 0.0) )
		{
			if ( !Flashing )
				Disable( 'Tick' );
			FadeBarHint = false;
		}
	}
}

defaultproperties
{
	Text="Item"
	ItemSize=IS_VerySmall
	Value=50.0
	MaxValue=100.0
	BarColor=(R=95,G=255,B=213)
	BarRedColor=(R=255,G=0,B=0)
	BarYellowColor=(R=255,G=255,B=0)
	Flashing=false
	FlashTime=1
	FlashUp=false
	FlashThreshold=15
	RemoteRole=ROLE_None
	BarTex(0)=texture'hud_effects.ingame_hud.ingame_statusbox1bc'
	BarTex(1)=texture'hud_effects.ingame_hud.ingame_statusbox3bc'
	BarTex(2)=texture'hud_effects.ingame_hud.ingame_statusbox3bc'
	BarTex(3)=texture'hud_effects.ingame_hud.ingame_statusbox6bc'
	BarTexTips(0)=texture'hud_effects.ingame_hud.ingame_statusbox2bc'
	BarTexTips(1)=texture'hud_effects.ingame_hud.ingame_statusbox4bc'
	BarTexTips(2)=texture'hud_effects.ingame_hud.ingame_statusbox4bc'
	BarTexTipHighlights(0)=texture'hud_effects.ingame_hud.ingame_statusbox_fill1bc'
	BarTexTipHighlights(1)=texture'hud_effects.ingame_hud.ingame_statusbox_fill2bc'
	BarTexTipHighlights(2)=texture'hud_effects.ingame_hud.ingame_statusbox_fill2bc'
	BarHeights(0)=16
	BarHeights(1)=10
	BarHeights(2)=10
	BarHeights(3)=10
	BarTipInsets(0)=1
	BarTipInsets(1)=1
	BarTipInsets(2)=7
	ValueXPos(0)=153	// 148+5
	ValueXPos(1)=143	// 138+5
	ValueXPos(2)=136	// 131+5
	ValueXPos(3)=114
	GradientTipOffset(0)=141
	GradientTipOffset(1)=134
	GradientTipOffset(2)=128
	GradientTipOffset(3)=112
	GradientTexture=texture'hud_effects.ingame_hud.ingame_statusgradientbc'
	GSGradientTexture=texture'hud_effects.ingame_hud.ingame_statusgradient2bc'
	SolidTexture=texture'hud_effects.ingame_hud.ingame_solidfillbc'
	FontAdjust(0)=0
	FontAdjust(1)=4
	FontAdjust(2)=4
	FontAdjust(3)=4
}
