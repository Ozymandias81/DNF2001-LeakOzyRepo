/*-----------------------------------------------------------------------------
	UWindowButton
-----------------------------------------------------------------------------*/
class UWindowButton extends UWindowDialogControl;

var bool		bDisabled;
var bool		bStretched;
var bool		bSolid;
var texture		UpTexture, DownTexture, DisabledTexture, OverTexture, GlowTexture;
var Region		UpRegion,  DownRegion,  DisabledRegion,  OverRegion;
var bool		bUseRegion;
var float		RegionScale;
var string		ToolTipString;
var float		ImageX, ImageY;
var sound		OverSound, DownSound;
var bool		bNoClickSound;

function Created()
{
	Super.Created();

	ImageX = 0;
	ImageY = 0;
	TextX = 0;
	TextY = 0;
	RegionScale = 1;
}

function Paint( Canvas C, float X, float Y )
{
	local float fAlpha;
	local bool bOldSmooth;

	if ( bSolid )
	{
		C.DrawColor = LookAndFeel.GetGUIColor( Self );
		C.Style = 1;
		bOldSmooth = C.bNoSmooth;
		C.bNoSmooth = false;
		fAlpha = 1;
	}

	if ( GlowTexture != None )
	{
		if ( bStretched )
			DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, GlowTexture, fAlpha );
		else
			DrawClippedTexture( C, ImageX, ImageY, GlowTexture, fAlpha );
	}

	if ( bDisabled )
	{
		if ( DisabledTexture != None )
		{
			if ( bUseRegion )
				DrawStretchedTextureSegment( C, ImageX, ImageY, DisabledRegion.W*RegionScale, DisabledRegion.H*RegionScale, 
											DisabledRegion.X, DisabledRegion.Y, 
											DisabledRegion.W, DisabledRegion.H, DisabledTexture, fAlpha, bSolid, bSolid );
			else if ( bStretched )
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture, fAlpha, bSolid, bSolid );
			else
				DrawClippedTexture( C, ImageX, ImageY, DisabledTexture, fAlpha, bSolid, bSolid );
		}
	}
	else
	{
		if ( bMouseDown )
		{
			if ( DownTexture != None )
			{
				if ( bUseRegion )
					DrawStretchedTextureSegment( C, ImageX, ImageY, DownRegion.W*RegionScale, DownRegion.H*RegionScale, 
												DownRegion.X, DownRegion.Y, 
												DownRegion.W, DownRegion.H, DownTexture, fAlpha, bSolid, bSolid );
				else if ( bStretched )
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DownTexture, fAlpha, bSolid, bSolid );
				else
					DrawClippedTexture( C, ImageX, ImageY, DownTexture, fAlpha, bSolid, bSolid );
			}
		}
		else 
		{
			if ( UseOverTexture() ) 
				DrawHighlightedButton(C, fAlpha);
			else if (UpTexture != None)
			{
				if ( bUseRegion )
					DrawStretchedTextureSegment(C, ImageX, ImageY, UpRegion.W*RegionScale, UpRegion.H*RegionScale, 
												UpRegion.X, UpRegion.Y, 
												UpRegion.W, UpRegion.H, UpTexture, fAlpha, bSolid, bSolid );
				else if ( bStretched )
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture, fAlpha, bSolid, bSolid );
				else
					DrawClippedTexture( C, ImageX, ImageY, UpTexture, fAlpha, bSolid, bSolid );
			}
		}
	}

	if ( bSolid )
		C.bNoSmooth = bOldSmooth;

	DrawButtonText(C);
}

function DrawHighlightedButton( Canvas C, optional float fAlpha )
{
	if ( OverTexture != None )
	{
		if ( bUseRegion )
			DrawStretchedTextureSegment( C, ImageX, ImageY, OverRegion.W*RegionScale, OverRegion.H*RegionScale, 
										OverRegion.X, OverRegion.Y, 
										OverRegion.W, OverRegion.H, 
										OverTexture,
										fAlpha, bSolid, bSolid
			);
		else if ( bStretched )
		{
			if ( bSolid )
				DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight, 
					0, 0, OverTexture.USize, OverTexture.VSize, 
					OverTexture, fAlpha, bSolid, bSolid );
			else
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, OverTexture, fAlpha );
		}
		else
			DrawClippedTexture( C, ImageX, ImageY, OverTexture, fAlpha, bSolid, bSolid );
	}
} 

function DrawButtonText( Canvas C )
{
	C.DrawColor = LookAndFeel.GetTextColor( Self );
	LookAndFeel.ClipText( Self, C, TextX, TextY, Text, True );
}

function bool UseOverTexture()
{
	return MouseIsOver();
}

function MouseLeave()
{
	Super.MouseLeave();
	if(ToolTipString != "") ToolTip("");
}

simulated function MouseEnter()
{
	Super.MouseEnter();
	if(ToolTipString != "") ToolTip(ToolTipString);
	if (!bDisabled && (OverSound != None))
		GetPlayerOwner().PlaySound(OverSound, SLOT_Interface);
}

simulated function Click(float X, float Y) 
{
	Notify(DE_Click);
	if ( !bDisabled && !bNoClickSound )
		LookAndFeel.PlayMenuSound( Self, MS_MenuAction );
//	if (!bDisabled && (DownSound != None))
//		GetPlayerOwner().PlaySound(DownSound, SLOT_Interact);
}

function DoubleClick(float X, float Y) 
{
	Notify(DE_DoubleClick);
}

function RClick(float X, float Y) 
{
	Notify(DE_RClick);
}

function MClick(float X, float Y) 
{
	Notify(DE_MClick);
}

function KeyDown(int Key, float X, float Y)
{
	local PlayerPawn P;

	P = Root.GetPlayerOwner();

	switch (Key)
	{
	case P.EInputKey.IK_Space:
		LMouseDown(X, Y);
		LMouseUp(X, Y);
		break;
	default:
		Super.KeyDown(Key, X, Y);
		break;
	}
}

defaultproperties
{
     bIgnoreLDoubleClick=True
     bIgnoreMDoubleClick=True
     bIgnoreRDoubleClick=True
}
