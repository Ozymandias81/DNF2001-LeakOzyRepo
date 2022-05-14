//==========================================================================
// 
// FILE:			UDukeButton.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		A UWindowButton that has some simple animation capabilities
//					(sliding one direction on X, spinning, and "throbbing")
// 
// NOTES:			
//
// MOD HISTORY:		
//
//
//
//
// Brandon says "MY GOD THIS CODE IS BEAUTIFUL!!!!!!"
// 
//==========================================================================
class UDukeButton expands UWindowButton;

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

var bool bDesktopIcon;			//If this is one of the main icons on the screen at all times, treat it differently
var bool bHighlightButton;		//If the button should be drawn highlighted (Necessary since it can happen without mouse over)

var float fAnimState;			//current state or amount used for animation
var() float fVelocity_X;		//amount used to move sub-icons out from under desktop icons
var float fLocationDesired_X;	//destination of sub-icon "slide"

var texture SelectionBubbleHighlight;
var texture SelectionRing;
var texture SelectionBubble;

var float RingRotation, BubbleRotation, LastRotUpdate, LastUpdate;
var float HighlightFade;

function PerformSelect()
{
	//actual command is defined in subclasses, this just plays the sound
	LookAndFeel.PlayMenuSound(Self, MS_SubMenuOpen);
}

simulated function MouseEnter()
{
	//play the selection sound if its one of the sub-icons
	if( !bHighlightButton && !bDesktopIcon )
		LookAndFeel.PlayMenuSound(Self, MS_SubMenuItem);
	fAnimState = 0.0;
}

function MouseLeave()
{
	//reset highlight state, regardless of how it was set
	bHighlightButton = false;
	Super.MouseLeave();		
}

simulated function Click(float X, float Y) 
{
	PerformSelect();
}

function HighlightButton()
{
	//play different selection sound for sub-icons than desktop ones
	if(bDesktopIcon)
		LookAndFeel.PlayMenuSound(Self, MS_MenuItem);
	else
		LookAndFeel.PlayMenuSound(Self, MS_SubMenuItem);

	bHighlightButton = true;
}	

function bool UseOverTexture()
{
	if(bHighlightButton)
		return true;
//	else

	return Super.UseOverTexture();
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float fTextWidth, fTextHeight;
	local int Length;
	local int i;
	local bool bTextPreviousState;

	Super.BeforePaint(C, X, Y);

	if(bDesktopIcon)
		C.Font = Root.Fonts[F_Bold];
	else
	{
		// TLW: Only horizontal, single direction movement supported for this simple animation.
		if ( fLocationDesired_X != WinLeft )
		{
			WinLeft += fVelocity_X;
				
			if( WinLeft > fLocationDesired_X)
				WinLeft = fLocationDesired_X;
		}
	}

	// Check to see if strings are equivalent, and if not increment the chars of strCurrentText .
	if ( IsValidString(Text) ) 
	{
		TextSize(C, RemoveAmpersand(Text), fTextWidth, fTextHeight);
		Length = Max(2, WrapClipText(C, 0, 0, Text,,,, True));
//		SetSize(WinWidth, Max(WinHeight, WinHeight + fTextHeight * Length));

		//if either ext string was valid, and fTextWidth was set, align the text output
		if (bDesktopIcon && fTextWidth > 0.0f)
		{
			TextY = WinHeight * (1.0/1.5);
			switch ( Align )
			{
				case TA_Left:	TextX = 2;								break;
				case TA_Right:	TextX = WinWidth - fTextWidth - 2;		break;
				case TA_Center:	TextX = (WinWidth - fTextWidth) * 0.5f;	break;
			}
		}
	}
}

function Paint(Canvas C, float X, float Y)
{
	local float Delta;
//	C.Font = Root.Fonts[Font];

	if(bDisabled) {
		if(DisabledTexture != None)
		{
			if(bUseRegion)
				DrawStretchedTextureSegment( C, ImageX, ImageY, DisabledRegion.W*RegionScale, DisabledRegion.H*RegionScale, 
											DisabledRegion.X, DisabledRegion.Y, 
											DisabledRegion.W, DisabledRegion.H, DisabledTexture );
			else if(bStretched)
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture );
			else
				DrawClippedTexture( C, ImageX, ImageY, DisabledTexture);
		}
	} else {
		if(bMouseDown)
		{
			if(DownTexture != None)
			{
				if(bUseRegion)
					DrawStretchedTextureSegment( C, ImageX, ImageY, DownRegion.W*RegionScale, DownRegion.H*RegionScale, 
												DownRegion.X, DownRegion.Y, 
												DownRegion.W, DownRegion.H, DownTexture );
				else if(bStretched)
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DownTexture );
				else
					DrawClippedTexture( C, ImageX, ImageY, DownTexture);
			}
		} else {
			if(UseOverTexture()) 
				DrawHighlightedButton(C);
			else if(UpTexture != None)  {
				if(bUseRegion)
					DrawStretchedTextureSegment(C, ImageX, ImageY, UpRegion.W*RegionScale, UpRegion.H*RegionScale, 
												UpRegion.X, UpRegion.Y, 
												UpRegion.W, UpRegion.H, UpTexture );
				else if(bStretched)
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture );
				else {
					if (bDesktopIcon)
					{
						Delta = GetLevel().TimeSeconds - LastUpdate;
						LastUpdate = GetLevel().TimeSeconds;
						if (HighlightFade > 0.0)
						{
							HighlightFade -= Delta;
							if (HighlightFade < 0.0)
								HighlightFade = 0.0;
						}
						C.Style = 3;
						C.DrawColor = LookAndFeel.colorGUIWindows;
						DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight * (1.0/1.5), 0, 0,
							 UpTexture.USize, UpTexture.VSize, UpTexture, 1.0f, true );
						DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight * (1.0/1.5), 0, 0,
							 SelectionRing.USize, SelectionRing.VSize, SelectionRing, 1.0f, true, , RingRotation );
						C.DrawColor.R = LookAndFeel.colorGUIWindows.R * HighlightFade;
						C.DrawColor.G = LookAndFeel.colorGUIWindows.G * HighlightFade;
						C.DrawColor.B = LookAndFeel.colorGUIWindows.B * HighlightFade;
						DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight * (1.0/1.5), 0, 0,
							SelectionBubble.USize, SelectionBubble.VSize, SelectionBubble, 1.0f, true );
						DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight * (1.0/1.5), 0, 0,
							SelectionBubbleHighlight.USize, SelectionBubbleHighlight.VSize, SelectionBubbleHighlight, 1.0f, true, , BubbleRotation );
						C.Style = 1;
					} else
						DrawClippedTexture( C, ImageX, ImageY, UpTexture);
				}
			}
		}
	}

	DrawButtonText(C);
}

function DrawButtonText(Canvas C)
{
	local INT iColor[3];

	C.DrawColor = LookAndFeel.DefaultTextColor;
	if ( IsValidString(Text) )
		WrapClipText(C, TextX, TextY, Text, True);
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

function DrawHighlightedButton(Canvas C, optional float fAlpha)
{
	local Texture texToUse;
	local Region reg;
	local float fValue, Delta;

	//set default values
	texToUse = UpTexture;
	reg.X = ImageX;
	reg.Y = ImageY;
	reg.W = texToUse.USize;
	reg.H = texToUse.VSize;

	C.Style = 3;
	//want smooth bell-curve of animation from steady increments
	if ( bDesktopIcon )
	{
		Delta = GetLevel().TimeSeconds - LastUpdate;
		LastUpdate = GetLevel().TimeSeconds;
		if (HighlightFade < 1.0)
			HighlightFade += Delta;
		if (HighlightFade > 1.0)
			HighlightFade = 1.0;
		Delta = GetLevel().TimeSeconds - LastRotUpdate;
		LastRotUpdate = GetLevel().TimeSeconds;
		RingRotation -= Delta;
		if (RingRotation < 0.0)
			RingRotation = 3.14*2;
		BubbleRotation += Delta;
		if (BubbleRotation > 3.14*2)
			BubbleRotation = 0.0;

		fValue = Sin(fAnimState * 0.875f);
//		reg.W = reg.W * (1.0f + (fValue * 0.0275f));
//		reg.H = reg.H * (1.0f + (fValue * 0.0275f));
		reg.W = WinWidth;
		reg.H = WinHeight * (1.0/1.5);

		C.DrawColor.R = Clamp(LookAndFeel.colorGUIWindows.R * (fValue + 1.0f), 0, 255);	
		C.DrawColor.G = Clamp(LookAndFeel.colorGUIWindows.G * (fValue + 1.0f), 0, 255);	
		C.DrawColor.B = Clamp(LookAndFeel.colorGUIWindows.B * (fValue + 1.0f), 0, 255);	

		//already set color
		DrawStretchedTextureSegment( C, 
									 0, 0, 
									 reg.W, reg.H, 
									 0, 0,
									 texToUse.USize, texToUse.VSize,
									 texToUse, 
									 1.0f, 
									 true 
		);
		// Draw the bubble.
		C.DrawColor = LookAndFeel.colorGUIWindows;
		DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight * (1.0/1.5), 0, 0,
			 SelectionRing.USize, SelectionRing.VSize, SelectionRing, 1.0f, true, , RingRotation );
		C.DrawColor.R = LookAndFeel.colorGUIWindows.R * HighlightFade;
		C.DrawColor.G = LookAndFeel.colorGUIWindows.G * HighlightFade;
		C.DrawColor.B = LookAndFeel.colorGUIWindows.B * HighlightFade;
		DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight * (1.0/1.5), 0, 0,
			 SelectionBubble.USize, SelectionBubble.VSize, SelectionBubble, 1.0f, true );
		DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight * (1.0/1.5), 0, 0,
			 SelectionBubbleHighlight.USize, SelectionBubbleHighlight.VSize, SelectionBubbleHighlight, 1.0f, true, , BubbleRotation );
	}
	else {
		fValue = Sin(fAnimState);
	
		//  When fValue is on the downsloping side of the sine wave (pi/2 -> 3*pi/2), 
		//	want the normal/Up texture, otherwise want the Over/highlighted texture
		//	to give a smooth spinning look to the anim	
		if ( Cos(fAnimState) < 0.0 )
		{
			texToUse = OverTexture;
			reg.W = texToUse.USize;
			reg.H = texToUse.VSize;
		}
	//	reg.W *= 1.25;	//only enlarge non-desktop icons, since they are fairly large to start
	//	reg.H *= 1.25;
	
		// A little more than 0.5 and 1.0, so you always see just a little bit of the graphic
		fValue = Abs(fValue);
		reg.X += (fValue * texToUse.USize * 0.505);
		reg.W *= (1.01 - fValue);
	
		DrawStretchedTexture( C, reg.X, reg.Y, reg.W, reg.H, texToUse, 1.0f );	//make opaque
	}

	fAnimState += GetLevel().TimeDeltaSeconds * 5;
	C.Style = 1;
}

defaultproperties
{
}
