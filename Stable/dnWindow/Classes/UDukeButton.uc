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

var bool bDesktopIcon;
var bool bHighlightButton;

var bool CannotClick;

var int BlurType;

function PerformSelect()
{
}

function MouseEnter()
{
	if ( Root.FindChildWindow( class'UWindowFramedWindow' ) != None )
		return;
	LookAndFeel.PlayMenuSound(Self, MS_OptionHL );
	Super.MouseEnter();
}

function MouseLeave()
{
	bHighlightButton = false;
	Super.MouseLeave();		
}

function LMouseDown( float X, float Y )
{
	if ( CannotClick )
		return;
	Super.LMouseDown( X, Y );
}

function RMouseDown( float X, float Y )
{
	if ( CannotClick )
		return;
	Super.RMouseDown( X, Y );
}

function MMouseDown( float X, float Y ) 
{
	if ( CannotClick )
		return;
	Super.MMouseDown( X, Y );
}

simulated function Click(float X, float Y) 
{
	PerformSelect();
}

function bool UseOverTexture()
{
	if ( bHighlightButton )
		return true;

	return Super.UseOverTexture();
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float fTextWidth, fTextHeight;
	local int Length;
	local int i;
	local bool bTextPreviousState;
	local float ScaleX, ScaleY;

	ScaleX = UDukeRootWindow(Root).Desktop.WinScaleX;
	ScaleY = UDukeRootWindow(Root).Desktop.WinScaleY;

	Super.BeforePaint(C, X, Y);

	if ( bDesktopIcon && (Root.WinWidth > 640) )
		C.Font = font'mainmenufont';
	else
		C.Font = font'mainmenufontsmall';

	if ( IsValidString(Text) ) 
	{
		TextSize( C, Text, fTextWidth, fTextHeight );

		if ( bDesktopIcon )
		{
			TextX = (WinWidth - fTextWidth) / 2.0;
//			TextX = (UpTexture.USize*ScaleX - fTextWidth) * 0.5f;
			TextY = WinHeight * (1.0/1.5);
		}
		else
		{
			TextX = (WinWidth - fTextWidth) / 2.0;
			TextY = (WinHeight - UpTexture.VSize*ScaleY)/2.0 + UpTexture.VSize*ScaleY;
		}
	}
}

function Paint( Canvas C, float X, float Y )
{
	local float Delta, ScaleX, ScaleY, OffX, OffY;

	ScaleX = UDukeRootWindow(Root).Desktop.WinScaleX;
	ScaleY = UDukeRootWindow(Root).Desktop.WinScaleY;

	if ( bMouseDown && MouseIsOver() )
	{
		OffX = 2;
		OffY = 2;
	}

	if ( UDukeRootWindow(Root).Desktop.ThemeTranslucentIcons )
		C.Style = 3;
	else
		C.Style = 1;
	if ( UDukeRootWindow(Root).Desktop.ThemeColorizable )
	{
		C.DrawColor = LookAndFeel.colorGUIWindows;
	}
	else
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}

	if ( UpTexture != None )
	{
		if ( bDesktopIcon )
			ImageX = (WinWidth - UpTexture.USize*ScaleX) / 2.0;

		if ( bUseRegion )
			DrawStretchedTextureSegment(C, ImageX, ImageY, UpRegion.W*RegionScale, UpRegion.H*RegionScale, 
										UpRegion.X, UpRegion.Y, 
										UpRegion.W, UpRegion.H, UpTexture );
		else if ( bStretched )
			DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture );
		else
		{
			if ( bDesktopIcon )
			{
				if ( MouseIsOver() )
				{
					if ( bMouseDown )
						DrawStretchedTextureSegment( C, ImageX, ImageY, DownTexture.USize*ScaleX, WinHeight * (1.0/1.5), 0, 0, DownTexture.USize, DownTexture.VSize, DownTexture, 1.0f, true );
					else
						DrawStretchedTextureSegment( C, ImageX, ImageY, OverTexture.USize*ScaleX, WinHeight * (1.0/1.5), 0, 0, OverTexture.USize, OverTexture.VSize, OverTexture, 1.0f, true );
				}
				else
					DrawStretchedTextureSegment( C, ImageX, ImageY, UpTexture.USize*ScaleX, WinHeight * (1.0/1.5), 0, 0, UpTexture.USize, UpTexture.VSize, UpTexture, 1.0f, true );
			} else
				DrawStretchedTextureSegment( C, OffX + (WinWidth - UpTexture.USize*ScaleX)/2.0, OffY + (WinHeight - UpTexture.VSize*ScaleY)/2.0, UpTexture.USize * ScaleX, UpTexture.VSize * ScaleY, 0, 0, UpTexture.USize, UpTexture.VSize, UpTexture, 1.0f, true );
		}
	}

	if ( GlowTexture != None )
	{
		 C.Style = 3;
		if ( bDesktopIcon )
			DrawStretchedTextureSegment( C, ImageX, ImageY, UpTexture.USize*ScaleX, WinHeight * (1.0/1.5), 0, 0, GlowTexture.USize, GlowTexture.VSize, GlowTexture, 1.0f );
		else if ( MouseIsOver() )
			DrawStretchedTextureSegment( C, OffX + (WinWidth - GlowTexture.USize*ScaleX)/2.0, OffY + (WinHeight - GlowTexture.VSize*ScaleY)/2.0, UpTexture.USize * ScaleX, UpTexture.VSize * ScaleY, 0, 0, GlowTexture.USize, GlowTexture.VSize, GlowTexture, 1.0f, true );
	}

	DrawButtonText( C );
}

function DrawButtonText( Canvas C )
{
	local INT iColor[3];

	if ( bDesktopIcon && (Root.WinWidth > 640) )
		C.Font = font'mainmenufont';
	else
		C.Font = font'mainmenufontsmall';

	C.Style = 3;

	if ( UDukeRootWindow(Root).Desktop.ThemeColorizable )
	{
		C.DrawColor = LookAndFeel.DefaultTextColor;
	}
	else
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
	if ( IsValidString(Text) )
		WrapClipText( C, TextX, TextY, Text, true );
}

function bool MouseIsOver()
{
	if ( Root.FindChildWindow( class'UWindowFramedWindow' ) != None )
		return false;
	else
		return Super.MouseIsOver();
}
