/*-----------------------------------------------------------------------------
	UDukeLookAndFeel
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeLookAndFeel extends UWindowLookAndFeel;

var() Region	FrameSBL;
var() Region	FrameSB;
var() Region	FrameSBR;

var() Region	ClientArea;

var() Region	CloseBoxUp;
var() Region	CloseBoxDown;
var() int		CloseBoxOffsetX;
var() int		CloseBoxOffsetY;

var() Region	CheckBoxEmpty;
var() Region	CheckBoxChecked;

var() Region	EditBoxFill;
var() Region	EditBoxTL;
var() Region	EditBoxT;
var() Region	EditBoxTR;
var() Region	EditBoxL;
var() Region	EditBoxR;
var() Region	EditBoxBL;
var() Region	EditBoxB;
var() Region	EditBoxBR;

var() Region	EditBoxFocusFill;
var() Region	EditBoxFocusTL;
var() Region	EditBoxFocusT;
var() Region	EditBoxFocusTR;
var() Region	EditBoxFocusL;
var() Region	EditBoxFocusR;
var() Region	EditBoxFocusBL;
var() Region	EditBoxFocusB;
var() Region	EditBoxFocusBR;

var() Region	HSliderL;
var() Region	HSlider;
var() Region	HSliderR;
var() Region	HSliderThumb;

var() Region	ButtonDownTL;
var() Region	ButtonDownT;
var() Region	ButtonDownTR;
var() Region	ButtonDownBL;
var() Region	ButtonDownB;
var() Region	ButtonDownBR;

var() Region	ButtonUpTL;
var() Region	ButtonUpT;
var() Region	ButtonUpTR;
var() Region	ButtonUpBL;
var() Region	ButtonUpB;
var() Region	ButtonUpBR;

var() Region	ComboFill;

var() Region	ComboUpTL;
var() Region	ComboUpT;
var() Region	ComboUpTR;
var() Region	ComboUpBL;
var() Region	ComboUpB;
var() Region	ComboUpBR;

var() Region	ComboDownTR;
var() Region	ComboDownBR;
var() Region	ComboDownBL;

var() Region	ComboDropL;
var() Region	ComboDropR;
var() Region	ComboDropBL;
var() Region	ComboDropB;
var() Region	ComboDropBR;

var() Region	VSlideSmallTop;
var() Region	VSlideSmallMid;
var() Region	VSlideSmallBot;

var() Region	SBPosIndicatorSmallT;
var() Region	SBPosIndicatorSmallM;
var() Region	SBPosIndicatorSmallB;

var() Region	VSlideBevelTop;
var() Region	VSlideBevelMid;
var() Region	VSlideBevelBot;

var() Region	SBPosIndicatorBevelT;
var() Region	SBPosIndicatorBevelM;
var() Region	SBPosIndicatorBevelB;

var() Region	SimpleBevelFill;
var() Region	SimpleBevelTL;
var() Region	SimpleBevelT;
var() Region	SimpleBevelTR;
var() Region	SimpleBevelL;
var() Region	SimpleBevelR;
var() Region	SimpleBevelBL;
var() Region	SimpleBevelB;
var() Region	SimpleBevelBR;

var() Region	BevelHeaderTL;
var() Region	BevelHeaderT;
var() Region	BevelHeaderTR;
var() Region	BevelHeaderSplit;

var() Region	BevelTL;
var() Region	BevelT;
var() Region	BevelTR;
var() Region	BevelSplit;
var() Region	BevelSplitB;

var() Region	TabLeft;
var() Region	TabMid;
var() Region	TabRight;

var() Region	TabLeftUp;
var() Region	TabMidUp;
var() Region	TabRightUp;

var   int		CurrentSlot;

var() config color	 colorTextSelected;
var() config color	 colorTextUnselected;

const SIZEBORDER = 3;
const BRSIZEBORDER = 15;

var sound GameStartSound;

/*-----------------------------------------------------------------------------
	Colors
-----------------------------------------------------------------------------*/

function SetTextColors( color colorNew )
{
	Super.SetTextColors( colorNew );

	/*
	EditBoxTextColor.R = Clamp(EditBoxTextColor.R * 1.25, 0, 255); 

	colorTextSelected.R = Clamp(colorNew.R * 1.1, 0, 255); 
	colorTextSelected.G = Clamp(colorNew.G * 1.1, 0, 255); 
	colorTextSelected.B = Clamp(colorNew.B * 1.1, 0, 255); 
	FrameActiveTitleColor = colorTextSelected;
	
	colorTextUnselected.R = 255 ^ colorTextSelected.R; 
	colorTextUnselected.G = 255 ^ colorTextSelected.G; 
	colorTextUnselected.B = 255 ^ colorTextSelected.B; 
	FrameInActiveTitleColor = colorTextUnselected;

	HeadingActiveTitleColor.R = Clamp(colorNew.R * 0.666666, 0, 255); 
	HeadingActiveTitleColor.G = Clamp(colorNew.G * 0.666666, 0, 255); 
	HeadingActiveTitleColor.B = Clamp(colorNew.B * 0.666666, 0, 255); 

	HeadingInActiveTitleColor.R = Clamp(colorNew.R * 0.333333, 0, 255); 
	HeadingInActiveTitleColor.G = Clamp(colorNew.G * 0.333333, 0, 255); 
	HeadingInActiveTitleColor.B = Clamp(colorNew.B * 0.333333, 0, 255); 
	*/

	colorTextSelected.R = 255;
	colorTextSelected.G = 255;
	colorTextSelected.B = 255;
	FrameActiveTitleColor = colorTextSelected;
	HeadingActiveTitleColor = FrameActiveTitleColor;

	colorTextUnselected.R = 250;
	colorTextUnselected.G = 250;
	colorTextUnselected.B = 250; 
	FrameInActiveTitleColor = colorTextUnselected;
	HeadingInActiveTitleColor = FrameInActiveTitleColor;

	DefaultTextColor = colorTextSelected;
}

function color GetGUIColor( UWindowWindow W )
{
	if ( UDukeRootWindow(W.Root).Desktop.ThemeColorizable )
		return colorGUIWindows;
	else
		return W.WhiteColor;
}

function color GetTextColor( UWindowWindow W )
{
	if ( UDukeRootWindow(W.Root).Desktop.ThemeColorizable )
		return DefaultTextColor;
	else
		return W.WhiteColor;
}

/*-----------------------------------------------------------------------------
	Main Frame
-----------------------------------------------------------------------------*/

function FW_DrawWindowFrame( UWindowFramedWindow W, Canvas C )
{
	local Texture T, T3;

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Retrive the draw texture.
	T = W.GetLookAndFeelTexture();
	T3 = W.GetLookAndFeelTexture3();

	// Draw the main frame.
	C.DrawColor = GetGUIColor(W);
	Real_DrawWindowFrame( W, C, T, T3, false );

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Translucent;

	// Retrive the glow texture.
	T = W.GetLookAndFeelGlowTexture();
	T3 = W.GetLookAndFeelGlowTexture3();

	// Draw the frame glow.
	C.DrawColor = W.WhiteColor;
	Real_DrawWindowFrame( W, C, T, T3, true );

	DrawTitleAndStatus( W, C );
}

function Real_DrawWindowFrame( UWindowFramedWindow W, Canvas C, Texture T, Texture T3, bool bGlow )
{
	local Region R;
	local float XL, YL, TitleEnd, TitleOver, RestLength, TrueRestLength;
	local Texture UseT;

	if ( W.bMessageBoxFrame )
		UseT = T3;
	else
		UseT = T;

	// Draw the top left corner.
	R = FrameTL;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y, R.W, R.H, UseT, 1.0 );

	if ( bGlow )
	{
		// Draw the top middle stretch.
		R = FrameT;
		W.DrawStretchedTextureSegment( C, FrameTL.W, 0, W.WinWidth - FrameTL.W - FrameTR.W, FrameT.H, FrameT.X, FrameT.Y, FrameT.W, FrameT.H, UseT, 1.0 );
	}
	else
	{
		C.Font = font'mainmenufont';

		// Find out the size of the title.
		W.TextSize( C, W.WindowTitle, XL, YL );
		TitleEnd = XL + FrameTitleX;

		TitleOver = TitleEnd - 107;
		if ( TitleOver > 0 )
		{
			TitleOver += 5 - (TitleOver%5);

			// Draw the tiled part over the title.
			R = FrameT;
			W.DrawHorizTiledPieces( C, FrameTL.W, 0, TitleOver, FrameT.H, R, UseT, 1.0 );
		}
		else
			TitleOver = 0;

		// Draw the rest of the tiled part.
		TrueRestLength = W.WinWidth - FrameTL.W - FrameTR.W - TitleOver;
		RestLength = TrueRestLength;
		if ( RestLength > 0 )
		{
			RestLength -= RestLength % 5;

			R = FrameT2;
			W.DrawHorizTiledPieces( C, FrameTL.W + TitleOver, 0, RestLength, FrameT2.H, R, UseT, 1.0 );

			// Fill in the rest.
			if ( TrueRestLength - RestLength > 0 )
			{
				R = FrameT3;
				W.DrawStretchedTextureSegment( C, FrameTL.W + TitleOver + RestLength, 0, TrueRestLength-RestLength, R.H, R.X, R.Y, R.W, R.H, UseT, 1.0 );
			}
		}
	}

	// Draw the top right corner.
	R = FrameTR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, 0, R.W, R.H, R.X, R.Y, R.W, R.H, UseT, 1.0 );

	if ( W.bStatusBar )
	{
		// Draw the left side of the frame.
		R = FrameL;
		W.DrawStretchedTextureSegment( C, 0, FrameTL.H, R.W, W.WinHeight - FrameTL.H - FrameSBL.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		// Draw the right side of the frame.
		R = FrameR;
		W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, FrameTL.H, R.W, W.WinHeight - FrameTR.H - FrameSBR.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		// Draw the bottom left corner.
		R = FrameSBL;
		W.DrawStretchedTextureSegment( C, 0, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T3, 1.0 );

		// Draw the bottom middle stretch.
		R = FrameSB;
		W.DrawStretchedTextureSegment( C, FrameSBL.W, W.WinHeight - R.H, W.WinWidth - FrameSBL.W - FrameSBR.W, FrameSB.H, FrameSB.X, FrameSB.Y, FrameSB.W, FrameSB.H, T3, 1.0 );

		// Draw the bottom right corner.
		R = FrameSBR;
		W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T3, 1.0 );
	}
	else
	{
		// Draw the left side of the frame.
		R = FrameL;
		W.DrawStretchedTextureSegment( C, 0, FrameTL.H, R.W, W.WinHeight - FrameTL.H - FrameBL.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		// Draw the right side of the frame.
		R = FrameR;
		W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, FrameTL.H, R.W, W.WinHeight - FrameTR.H - FrameBR.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		// Draw the bottom left corner.
		R = FrameBL;
		W.DrawStretchedTextureSegment( C, 0, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		// Draw the bottom middle stretch.
		R = FrameB;
		W.DrawStretchedTextureSegment( C, FrameBL.W, W.WinHeight - R.H, W.WinWidth - FrameBL.W - FrameBR.W, FrameB.H, FrameB.X, FrameB.Y, FrameB.W, FrameB.H, T, 1.0 );

		// Draw the bottom right corner.
		R = FrameBR;
		W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}
}

function DrawClientArea( UWindowWindow W, Canvas C )
{
	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Draw the client area fill.
	W.DrawStretchedTextureSegment( C, 0, 0, W.WinWidth, W.WinHeight, ClientArea.X, ClientArea.Y, 
				    			   ClientArea.W, ClientArea.H, W.GetLookAndFeelTexture(), W.ClientAreaAlpha );
}

function DrawTitleAndStatus( UWindowFramedWindow W, Canvas C )
{
	C.DrawColor = GetTextColor(W);
	C.Font = W.Root.Fonts[W.F_Bold];
	W.ClipTextWidth( C, FrameTitleX, FrameTitleY, W.WindowTitle, W.WinWidth );

	if ( W.bStatusBar )
	{
		C.Font = W.Root.Fonts[W.F_Small];
		W.ClipTextWidth( C, 28, W.WinHeight - 43, W.StatusBarText, W.WinWidth - 22 );
	}
}

function Region FW_GetClientArea(UWindowFramedWindow W)
{
	local Region R;

	R.X = FrameL.W;
	R.Y	= FrameT.H;
	R.W = W.WinWidth - (FrameL.W + FrameR.W);
	if (W.bStatusBar)
		R.H = W.WinHeight - (FrameT.H + FrameSB.H);
	else
		R.H = W.WinHeight - (FrameT.H + FrameB.H);

	return R;
}

function FrameHitTest FW_HitTest(UWindowFramedWindow W, float X, float Y)
{
	if((X >= 3) && (X <= W.WinWidth-3) && (Y >= 3) && (Y <= 14))
		return HT_TitleBar;
	if((X < BRSIZEBORDER && Y < SIZEBORDER) || (X < SIZEBORDER && Y < BRSIZEBORDER)) 
		return HT_NW;
	if((X > W.WinWidth - SIZEBORDER && Y < BRSIZEBORDER) || (X > W.WinWidth - BRSIZEBORDER && Y < SIZEBORDER))
		return HT_NE;
	if((X < BRSIZEBORDER && Y > W.WinHeight - SIZEBORDER)|| (X < SIZEBORDER && Y > W.WinHeight - BRSIZEBORDER)) 
		return HT_SW;
	if((X > W.WinWidth - BRSIZEBORDER) && (Y > W.WinHeight - BRSIZEBORDER))
		return HT_SE;
	if(Y < SIZEBORDER)
		return HT_N;
	if(Y > W.WinHeight - SIZEBORDER)
		return HT_S;
	if(X < SIZEBORDER)
		return HT_W;
	if(X > W.WinWidth - SIZEBORDER)	
		return HT_E;

	return HT_None;	
}

/*-----------------------------------------------------------------------------
	Control Frame (?)
-----------------------------------------------------------------------------*/

function ControlFrame_SetupSizes(UWindowControlFrame W, Canvas C)
{
	local int B;

	B = EditBoxBevel;
		
	W.Framed.WinLeft = MiscBevelL[B].W;
	W.Framed.WinTop = MiscBevelT[B].H;
	W.Framed.SetSize(W.WinWidth - MiscBevelL[B].W - MiscBevelR[B].W, W.WinHeight - MiscBevelT[B].H - MiscBevelB[B].H);
}

function ControlFrame_Draw(UWindowControlFrame W, Canvas C)
{
	Super.ControlFrame_Draw(W, C);
	W.DrawMiscBevel(C, 0, 0, W.WinWidth, W.WinHeight, Misc, EditBoxBevel);
}

/*-----------------------------------------------------------------------------
	Tabbed Page
-----------------------------------------------------------------------------*/

function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H)
{
	local float TW, TH;

	C.Font = Tab.Root.Fonts[Tab.F_Normal];
	Tab.TextSize( C, Text, TW, TH );

	W = TW + 16;
	H = TabMid.H;
}

function Tab_DrawTab( UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText )
{
	local Region R;
	local Texture T;
	local float TW, TH;

	C.DrawColor = GetGUIColor(Tab);
	C.Font = Tab.Root.Fonts[Tab.F_Normal];

	T = Tab.GetLookAndFeelTexture();

	if ( bActiveTab )
	{
		R = TabLeft;
		Tab.DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		R = TabMid;
//		Tab.DrawHorizTiledPieces( C, X+TabLeft.W, Y, W - TabLeft.W - TabRight.W, R, T, 1.0 );
//		Tab.DrawStretchedTextureSegment( C, X+TabLeft.W, Y, W - TabLeft.W - TabRight.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		R = TabRight;
		Tab.DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
		
		C.DrawColor = GetTextColor(Tab);

		if ( bShowText )
		{
			Tab.TextSize( C, Text, TW, TH );
			Tab.ClipText( C, X + (W-TW)/2, Y + (TabMid.H - TH)/2, Text, true );
		}
	}
	else
	{
		R = TabLeftUp;
		Tab.DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		R = TabMidUp;
		Tab.DrawStretchedTextureSegment( C, X+TabLeftUp.W, Y, W - TabLeftUp.W - TabLeftUp.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		R = TabRightUp;
		Tab.DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		C.DrawColor = GetTextColor(Tab);
		C.DrawColor.R = 3 * (C.DrawColor.R / 4);
		C.DrawColor.G = 3 * (C.DrawColor.G / 4);
		C.DrawColor.B = 3 * (C.DrawColor.B / 4);

		if ( bShowText )
		{
			Tab.TextSize(C, Text, TW, TH);
			Tab.ClipText(C, X + (W-TW)/2, Y + (TabMid.H - TH)/2, Text, True);
		}
	}
}

function Tab_SetupLeftButton(UWindowTabControlLeftButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.WinWidth = SBPosIndicator.W;
	W.WinHeight = SBPosIndicator.H;
	W.WinTop = Size_TabAreaHeight - W.WinHeight;
	W.WinLeft = W.ParentWindow.WinWidth - 2*W.WinWidth;

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
}

function Tab_SetupRightButton(UWindowTabControlRightButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.WinWidth = SBPosIndicator.W;
	W.WinHeight = SBPosIndicator.H;
	W.WinTop = Size_TabAreaHeight - W.WinHeight;
	W.WinLeft = W.ParentWindow.WinWidth - W.WinWidth;

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
}

function Tab_SetTabPageSize( UWindowPageControl W, UWindowPageWindow P )
{
	P.WinLeft = 2;
	P.WinTop = W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H) + 3;
//	P.SetSize(W.WinWidth - 4, W.WinHeight-(W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H)) - 6);
	P.SetSize(W.WinWidth - 4, W.WinHeight-(W.TabArea.WinHeight-TabMid.H) - 6);
}

function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P)
{
//	W.DrawUpBevel( C, 0, W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H), W.WinWidth, W.WinHeight-(W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H)), W.GetLookAndFeelTexture());
}

/*-----------------------------------------------------------------------------
	Edit Box
-----------------------------------------------------------------------------*/

function Editbox_SetupSizes( UWindowEditControl W, Canvas C )
{
	local float TW, TH;

	C.Font = W.Root.Fonts[W.EditBox.Font];
	if ( W.Text == "" )
		W.TextSize( C, "TESTy", TW, TH );
	else
		W.TextSize( C, W.Text, TW, TH );

	switch( W.Align )
	{
	case TA_Left:
		W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
		W.TextX = 0;
		break;
	case TA_Right:
		W.EditAreaDrawX = 0;	
		W.TextX = W.WinWidth - TW - EditBoxTR.W;
		break;
	case TA_Center:
		W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth) / 2;
		W.TextX = (W.WinWidth - TW - EditBoxTR.W) / 2;
		break;
	}

	W.WinHeight = EditBoxTL.H + EditBoxBL.H + TH;

	W.EditAreaDrawY = (W.WinHeight - 2) / 2;
	W.TextY = (W.WinHeight - TH) / 2;

	W.EditBox.WinLeft   = W.EditAreaDrawX + EditBoxTL.W;
	W.EditBox.WinTop    = EditBoxT.H - 1;
	W.EditBox.WinWidth  = W.WinWidth - EditBoxTL.W - EditBoxTR.W;
	W.EditBox.WinHeight = W.WinHeight - EditBoxT.H - EditBoxB.H;
	W.EditBox.TextY		= (W.EditBox.WinHeight - TH) / 2;
	W.EditBox.bTextYSet = true;
}

function Editbox_Draw( UWindowEditControl W, Canvas C )
{
	local Region R;
	local Texture T;

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Draw the top left.
	if ( W.EditBox.bHasKeyboardFocus )
		R = EditBoxFocusTL;
	else
		R = EditBoxTL;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the top stretch.
	if ( W.EditBox.bHasKeyboardFocus )
		R = EditBoxFocusT;
	else
		R = EditBoxT;
	W.DrawStretchedTextureSegment( C, EditBoxTL.W, 0, W.WinWidth-EditBoxTL.W-EditBoxTR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the top right.
	if ( W.EditBox.bHasKeyboardFocus )
		R = EditBoxFocusTR;
	else
		R = EditBoxTR;
	W.DrawStretchedTextureSegment( C, W.WinWidth-R.W, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the left.
	if ( W.EditBox.bHasKeyboardFocus )
		R = EditBoxFocusL;
	else
		R = EditBoxL;
	W.DrawStretchedTextureSegment( C, 0, EditBoxTL.H, R.W, W.WinHeight-EditBoxTL.H-EditBoxBL.H-4, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the right.
	if ( W.EditBox.bHasKeyboardFocus )
		R = EditBoxFocusR;
	else
		R = EditBoxR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - EditBoxR.W, EditBoxTR.H, R.W, W.WinHeight-EditBoxTR.H-EditBoxBR.H-4, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom left.
	if ( W.EditBox.bHasKeyboardFocus )
		R = EditBoxFocusBL;
	else
		R = EditBoxBL;
	W.DrawStretchedTextureSegment( C, 0, W.WinHeight-R.H-4, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom stretch.
	if ( W.EditBox.bHasKeyboardFocus )
		R = EditBoxFocusB;
	else
		R = EditBoxB;
	W.DrawStretchedTextureSegment( C, EditBoxBL.W, W.WinHeight-R.H-4, W.WinWidth-EditBoxBL.W-EditBoxBR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom right.
	if ( W.EditBox.bHasKeyboardFocus )
		R = EditBoxFocusBR;
	else
		R = EditBoxBR;
	W.DrawStretchedTextureSegment( C, W.WinWidth-R.W, W.WinHeight-R.H-4, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the fill.
	R = EditBoxFill;
	W.DrawStretchedTextureSegment( C, EditBoxTL.W, EditBoxTL.H, W.WinWidth - EditBoxTL.W - EditBoxTR.W, W.WinHeight - EditBoxTL.H - EditBoxTL.H - 4, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the label.
	C.DrawColor = GetTextColor(W);
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Translucent;
	C.Font = W.Root.Fonts[W.Font];
	W.ClipText( C, W.TextX, W.TextY, W.Text );
}

/*-----------------------------------------------------------------------------
	Bevel
-----------------------------------------------------------------------------*/

function Bevel_DrawSimpleBevel( UWindowWindow W, Canvas C, int X, int Y, int Width, int Height )
{
	local Region R;
	local Texture T;

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Draw the top left corner.
	R = SimpleBevelTL;
	W.DrawStretchedTextureSegment( C, X - SimpleBevelTL.W, Y - SimpleBevelTL.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the top middle stretch.
	R = SimpleBevelT;
	W.DrawStretchedTextureSegment( C, X, Y - SimpleBevelTL.H, Width, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the top right corner.
	R = SimpleBevelTR;
	W.DrawStretchedTextureSegment( C, X + Width, Y - SimpleBevelTR.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the left side.
	R = SimpleBevelL;
	W.DrawStretchedTextureSegment( C, X - SimpleBevelL.W, Y, R.W, Height, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the right side.
	R = SimpleBevelR;
	W.DrawStretchedTextureSegment( C, X + Width, Y, R.W, Height, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom left corner.
	R = SimpleBevelBL;
	W.DrawStretchedTextureSegment( C, X - SimpleBevelBL.W, Y + Height, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom middle stretch.
	R = SimpleBevelB;
	W.DrawStretchedTextureSegment( C, X, Y + Height, Width, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom right corner.
	R = SimpleBevelBR;
	W.DrawStretchedTextureSegment( C, X + Width, Y + Height, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the fill.
	R = SimpleBevelFill;
	W.DrawStretchedTextureSegment( C, X, Y, Width, Height, R.X, R.Y, R.W, R.H, T, 1.0 );
}

function Bevel_DrawSplitHeaderedBevel( UWindowWindow W, Canvas C, int X, int Y, int Width, int Height, string Header1, string Header2 )
{
	local Region R;
	local Texture T;
	local float MiddleLen, XL, YL;

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Draw header left.
	R = BevelHeaderTL;
	W.DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw header left middle.
	MiddleLen = (Width - BevelHeaderSplit.W - BevelHeaderTL.W - BevelHeaderTR.W)/2;
	R = BevelHeaderT;
	W.DrawStretchedTextureSegment( C, X+BevelHeaderTL.W, Y, MiddleLen, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw header split.
	R = BevelHeaderSplit;
	W.DrawStretchedTextureSegment( C, X+BevelHeaderTL.W+MiddleLen, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw header right middle.
	R = BevelHeaderT;
	W.DrawStretchedTextureSegment( C, X+BevelHeaderTL.W+BevelHeaderSplit.W+MiddleLen, Y, MiddleLen, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the header right.
	R = BevelHeaderTR;
	W.DrawStretchedTextureSegment( C, X+Width - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bevel top left.
	R = BevelTL;
	W.DrawStretchedTextureSegment( C, X, Y+BevelHeaderTL.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	
	// Draw the stretch.
	R = BevelT;
	W.DrawStretchedTextureSegment( C, X+BevelTL.W, Y+BevelHeaderTL.H, Width-BevelTL.W-BevelTR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bevel top right.
	R = BevelTL;
	W.DrawStretchedTextureSegment( C, X+Width - R.W, Y+BevelHeaderTR.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the left side.
	R = SimpleBevelL;
	W.DrawStretchedTextureSegment( C, X, Y+BevelHeaderTL.H, R.W, Height-BevelHeaderT.H-SimpleBevelB.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the right side.
	R = SimpleBevelR;
	W.DrawStretchedTextureSegment( C, X+Width - R.W, Y+BevelHeaderTR.H, R.W, Height-BevelHeaderT.H-SimpleBevelB.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom left corner.
	R = SimpleBevelBL;
	W.DrawStretchedTextureSegment( C, X, Y+BevelHeaderTL.H+Height-BevelHeaderT.H-SimpleBevelB.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom middle stretch.
	R = SimpleBevelB;
	W.DrawStretchedTextureSegment( C, X+SimpleBevelBL.W, Y+BevelHeaderTL.H+Height-BevelHeaderT.H-SimpleBevelB.H, Width - SimpleBevelBL.W - SimpleBevelBR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom right corner.
	R = SimpleBevelBR;
	W.DrawStretchedTextureSegment( C, X+Width-R.W, Y+BevelHeaderTL.H+Height-BevelHeaderT.H-SimpleBevelB.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the fill.
	R = SimpleBevelFill;
	W.DrawStretchedTextureSegment( C, X+SimpleBevelL.W, Y+BevelHeaderTL.H, Width-SimpleBevelL.W-SimpleBevelR.W, Height-BevelHeaderT.H-SimpleBevelB.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the split.
	R = BevelSplit;
	W.DrawVertTiledPieces( C, X+1+SimpleBevelL.W+(Width-SimpleBevelL.W-SimpleBevelR.W-R.W)/2, Y+BevelHeaderTL.H, R.W, Height-BevelHeaderT.H-1, R, T, 1.0 );

	// Draw the left header.
	C.DrawColor = GetTextColor(W);
	C.Font = W.Root.Fonts[F_Small];
	W.TextSize( C, Header1, XL, YL );
	W.ClipText( C, X + BevelHeaderTL.W, Y + (BevelHeaderTL.H-YL)/2, Header1, true );

	// Draw the right header.
	C.Font = W.Root.Fonts[F_Small];
	W.TextSize( C, Header2, XL, YL );
	W.ClipText( C, X+BevelHeaderTL.W+BevelHeaderSplit.W+MiddleLen+BevelHeaderT.W, Y + (BevelHeaderTL.H-YL)/2, Header2, true );
}

function int Bevel_GetSplitLeft()
{
	return BevelHeaderTL.W;
}

function int Bevel_GetSplitRight( int Width )
{
	local float MiddleLen;

	MiddleLen = (Width - BevelHeaderSplit.W - BevelHeaderTL.W - BevelHeaderTR.W)/2;
	return BevelHeaderTL.W+BevelHeaderSplit.W+MiddleLen+BevelHeaderT.W;
}

function int Bevel_GetHeaderedTop()
{
	return BevelHeaderTL.H;
}

/*-----------------------------------------------------------------------------
	Grid
-----------------------------------------------------------------------------*/

function Grid_SizeGrid( UWindowGrid W )
{
	local float Offset;
	local UWindowGridColumn colColumn;
	local float TotalWidth;

	TotalWidth = 0;
	colColumn = W.FirstColumn;
	while ( colColumn != None )
	{
		TotalWidth += colColumn.WinWidth;
		colColumn = colColumn.NextColumn;
	}

	/*
	if ( !W.bSizingColumn )
		W.HorizSB.SetRange( 0, TotalWidth, W.WinWidth - SBPosIndicator.W, 10 );

	if ( !W.HorizSB.bDisabled )
	{
		W.HorizSB.ShowWindow();
		W.bShowHorizSB = true;
	}
	else
	{
		W.HorizSB.HideWindow();
		W.bShowHorizSB = False;
		W.HorizSB.Pos = 0;
	}
	*/
	W.HorizSB.HideWindow();

	W.ClientArea.WinTop = 0;
	W.ClientArea.WinLeft = 0;
	W.ClientArea.WinWidth = W.WinWidth - SBPosIndicator.W;
	if ( W.bShowHorizSB )
		W.ClientArea.WinHeight = W.WinHeight - SBPosIndicator.H;
	else
		W.ClientArea.WinHeight = W.WinHeight;

	/*
	if ( W.bShowHorizSB )
	{
		W.HorizSB.WinTop = W.WinHeight - SBPosIndicator.W;
		W.HorizSB.WinLeft = 0;
		W.HorizSB.WinWidth = W.WinWidth - SBPosIndicator.W;
		W.HorizSB.WinHeight = SBPosIndicator.H;
	}
	*/

	W.VertSB.WinTop = 2 + Bevel_GetHeaderedTop();
	W.VertSB.SetSize( SBPosIndicatorBevel.W, W.WinHeight - W.VertSB.WinTop - 4 );
	W.VertSB.WinLeft = W.WinWidth - SBPosIndicatorBevel.W - 4;
	/*
	if ( W.bShowHorizSB )
		Offset = 1 - W.HorizSB.Pos;
	else
		Offset = 1;
	*/

	Offset = 0;
	colColumn = W.FirstColumn;
	while ( colColumn != None )
	{
		colColumn.WinLeft = Offset;
		colColumn.WinTop = 0;
		colColumn.WinHeight = W.WinHeight;
		Offset += colColumn.WinWidth/*Offset + colColumn.WinWidth + BevelHeaderSplit.W*/;
		colColumn = colColumn.NextColumn;
	}
}

function Grid_DrawGrid( UWindowGrid W, Canvas C )
{
	local Region R;
	local Texture T;
	local float MiddleLen, XL, YL, Offset, DrawWidth;
	local UWindowGridColumn colColumn;

	W.WinHeight = int(W.WinHeight);
	W.WinWidth = int(W.WinWidth);

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Draw header left.
	R = BevelHeaderTL;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw header middle.
	Offset = BevelHeaderTL.W;
	colColumn = W.FirstColumn;
	DrawWidth = colColumn.WinWidth - BevelHeaderSplit.W;
	while ( colColumn != None )
	{
		if ( colColumn.NextColumn == None )
			DrawWidth = W.WinWidth - Offset - BevelHeaderTR.W;

		R = BevelHeaderT;
		W.DrawStretchedTextureSegment( C, Offset, 0, DrawWidth, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
		Offset += DrawWidth;

		if ( colColumn.NextColumn != None )
		{
			R = BevelHeaderSplit;
			W.DrawStretchedTextureSegment( C, Offset, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
			Offset += BevelHeaderSplit.W;
		}

		colColumn = colColumn.NextColumn;
		if ( colColumn != None )
			DrawWidth = colColumn.WinWidth - BevelHeaderSplit.W;
	}

	// Draw the header right.
	R = BevelHeaderTR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - BevelHeaderTR.W, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bevel top left.
	R = BevelTL;
	W.DrawStretchedTextureSegment( C, 0, BevelHeaderTL.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the stretch.
	R = BevelT;
	W.DrawStretchedTextureSegment( C, BevelTL.W, BevelHeaderTL.H, W.WinWidth-BevelTL.W-BevelTR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bevel top right.
	R = BevelTL;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, BevelHeaderTR.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the left side.
	R = SimpleBevelL;
	W.DrawStretchedTextureSegment( C, 0, BevelHeaderTL.H, R.W, W.WinHeight-BevelHeaderT.H-SimpleBevelB.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the right side.
	R = SimpleBevelR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, BevelHeaderTR.H, R.W, W.WinHeight-BevelHeaderT.H-SimpleBevelB.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom left corner.
	R = SimpleBevelBL;
	W.DrawStretchedTextureSegment( C, 0, BevelHeaderTL.H+W.WinHeight-BevelHeaderT.H-SimpleBevelB.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom middle stretch.
	R = SimpleBevelB;
	W.DrawStretchedTextureSegment( C, SimpleBevelBL.W, BevelHeaderTL.H+W.WinHeight-BevelHeaderT.H-SimpleBevelB.H, W.WinWidth - SimpleBevelBL.W - SimpleBevelBR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom right corner.
	R = SimpleBevelBR;
	W.DrawStretchedTextureSegment( C, W.WinWidth-R.W, BevelHeaderTL.H+W.WinHeight-BevelHeaderT.H-SimpleBevelB.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the fill.
	R = SimpleBevelFill;
	W.DrawStretchedTextureSegment( C, SimpleBevelL.W, BevelHeaderTL.H, W.WinWidth-SimpleBevelL.W-SimpleBevelR.W, W.WinHeight-BevelHeaderT.H-SimpleBevelB.H, R.X, R.Y, R.W, R.H, T, W.FillAlpha );

	// Draw header middle.
	colColumn = W.FirstColumn;
	Offset = colColumn.WinWidth;
	while ( colColumn != None )
	{
		if ( colColumn.NextColumn != None )
		{
			R = BevelSplit;
			W.DrawVertTiledPieces( C, Offset, BevelHeaderT.H, R.W, W.WinHeight-BevelHeaderT.H-BevelSplitB.H+1, R, T, 1.0 );

			R = BevelSplitB;
			W.DrawStretchedTextureSegment( C, Offset, BevelHeaderTL.H+W.WinHeight-BevelHeaderT.H-BevelSplitB.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
		}
		colColumn = colColumn.NextColumn;
		if ( colColumn != None )
			Offset += colColumn.WinWidth;
	}
}

/*-----------------------------------------------------------------------------
	Button
-----------------------------------------------------------------------------*/

function Button_AutoSize( UWindowSmallButton W, Canvas C )
{
	local float XL, YL;

	if ( W == None )
		return;

	C.Font = W.Root.Fonts[W.Font];
	W.TextSize( C, W.RemoveAmpersand(W.Text), XL, YL );

	W.WinWidth = ButtonUpTL.W + ButtonUpBL.W + XL;
	if ( W.WinWidth < 36 )
		W.WinWidth = 36;
	if ( W.Font == F_Small )
		W.WinHeight = ButtonUpTL.H + ButtonUpBL.H - 4;
	else
		W.WinHeight = ButtonUpTL.H + ButtonUpBL.H;
}

function Button_DrawSmallButton( UWindowSmallButton W, Canvas C )
{
	local Region R;
	local Texture T;
	local float Offset;

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Get offset.
	if ( W.Font == F_Small )
		Offset = 2;

	// Draw the top left corner.
	if ( W.bMouseDown )
		R = ButtonDownTL;
	else
		R = ButtonUpTL;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H - Offset, R.X, R.Y, R.W, R.H - Offset, T, 1.0 );

	// Draw the top middle stretch.
	if ( W.bMouseDown )
		R = ButtonDownT;
	else
		R = ButtonUpT;
	W.DrawStretchedTextureSegment( C, ButtonUpTL.W, 0, W.WinWidth - ButtonUpTL.W - ButtonUpTR.W, R.H - Offset, R.X, R.Y, R.W, R.H - Offset, T, 1.0 );

	// Draw the top right corner.
	if ( W.bMouseDown )
		R = ButtonDownTR;
	else
		R = ButtonUpTR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, 0, R.W, R.H - Offset, R.X, R.Y, R.W, R.H - Offset, T, 1.0 );

	// Draw the bottom left corner.
	if ( W.bMouseDown )
		R = ButtonDownBL;
	else
		R = ButtonUpBL;
	W.DrawStretchedTextureSegment( C, 0, W.WinHeight - R.H, R.W, R.H - Offset, R.X, R.Y + Offset, R.W, R.H, T, 1.0 );

	// Draw the bottom middle stretch.
	if ( W.bMouseDown )
		R = ButtonDownB;
	else
		R = ButtonUpB;
	W.DrawStretchedTextureSegment( C, ButtonUpBL.W, W.WinHeight - R.H, W.WinWidth - ButtonUpBL.W - ButtonUpBR.W, R.H - Offset, R.X, R.Y + Offset, R.W, R.H, T, 1.0 );

	// Draw the bottom right corner.
	if ( W.bMouseDown )
		R = ButtonDownBR;
	else
		R = ButtonUpBR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, W.WinHeight - R.H, R.W, R.H - Offset, R.X, R.Y + Offset, R.W, R.H, T, 1.0 );
}

/*-----------------------------------------------------------------------------
	Scrollbar Setup (Depricated?)
-----------------------------------------------------------------------------*/

function SB_SetupUpButton( UWindowSBUpButton W )
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBUpUp;
	W.DownRegion = SBUpDown;
	W.OverRegion = SBUpUp;
	W.DisabledRegion = SBUpDisabled;
}

function SB_SetupDownButton( UWindowSBDownButton W )
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBDownUp;
	W.DownRegion = SBDownDown;
	W.OverRegion = SBDownUp;
	W.DisabledRegion = SBDownDisabled;
}

function SB_SetupLeftButton( UWindowSBLeftButton W )
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
}

function SB_SetupRightButton( UWindowSBRightButton W )
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
}

/*-----------------------------------------------------------------------------
	Horizontal Scrollbar (Not Supported)
-----------------------------------------------------------------------------*/

function SB_HDraw(UWindowHScrollbar W, Canvas C)
{
	local Region R;
	local Texture T;

	T = W.GetLookAndFeelTexture();

	R = SBBackground;
	W.DrawStretchedTextureSegment( C, 0, 0, W.WinWidth, W.WinHeight, R.X, R.Y, R.W, R.H, T);
	
	if(!W.bDisabled) 
	{
		W.DrawUpBevel( C, W.ThumbStart, 0, W.ThumbWidth, SBPosIndicator.H, T);
	}
}

/*-----------------------------------------------------------------------------
	Vertical Scrollbar
-----------------------------------------------------------------------------*/

function SB_VDraw( UWindowVScrollbar W, Canvas C )
{
	local Region R;
	local Texture T;
	local float ThumbY, ScrollHeight, ThumbHeight;
	local float OldClipW, OldClipH;

	if ( !W.bFramedWindow )
	{
		if ( W.bInBevel )
			SB_VDrawBevel( W, C );
		else
			SB_VDrawSmall( W, C );
		return;
	}

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Draw the top part.
	R = VSlideTop;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the middle stretch.
	R = VSlideMid;
	W.DrawStretchedTextureSegment( C, 0, VSlideTop.H, R.W, W.WinHeight-VSlideBot.H-VSlideTop.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	
	// Draw the bottom part.
	R = VSlideBot;
	W.DrawStretchedTextureSegment( C, 0, W.WinHeight-R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the thumb.
	if ( !W.bDisabled )
	{
		ScrollHeight = W.WinHeight - 2*SBPosIndicatorT.H;
		ThumbY = (W.ThumbStart/ScrollHeight) * (ScrollHeight - 18.0) + 9.0;
		ThumbHeight = W.ThumbHeight - 9.0;

		// Draw the top part.
		R = SBPosIndicatorT;
		W.DrawStretchedTextureSegment( C, 0, ThumbY, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		// Draw the middle stretch.
		R = SBPosIndicatorM;
		W.DrawStretchedTextureSegment( C, 0, ThumbY + SBPosIndicatorT.H, R.W, ThumbHeight - SBPosIndicatorT.H - 2*SBPosIndicatorB.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	
		// Draw the bottom part.
		R = SBPosIndicatorB;
		W.DrawStretchedTextureSegment( C, 0, ThumbY + ThumbHeight - SBPosIndicatorT.H - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}

	// Draw the up button down.
	if ( W.UpButton.bMouseDown )
	{
		R = VScrollUpDown;
		W.DrawStretchedTextureSegment( C, 1, 1, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}

	// Draw the down button down.
	if ( W.DownButton.bMouseDown )
	{
		R = VScrollDownDown;
		W.DrawStretchedTextureSegment( C, 1, W.WinHeight-SBDownUp.H+1, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}
}

function SB_VDrawSmall( UWindowVScrollbar W, Canvas C )
{
	local Region R;
	local Texture T;
	local float ThumbY, ScrollHeight;
	local float OldClipW, OldClipH;

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Draw the top part.
	R = VSlideSmallTop;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the middle stretch.
	R = VSlideSmallMid;
	W.DrawStretchedTextureSegment( C, 0, VSlideSmallTop.H, R.W, W.WinHeight-VSlideSmallBot.H-VSlideSmallTop.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	
	// Draw the bottom part.
	R = VSlideSmallBot;
	W.DrawStretchedTextureSegment( C, 0, W.WinHeight-R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the thumb.
	if ( !W.bDisabled )
	{
		ScrollHeight = W.WinHeight - 2*SBPosIndicatorSmallT.H;
		ThumbY = (W.ThumbStart/ScrollHeight) * (ScrollHeight - 12.0) + 6.0;

		// Draw the top part.
		R = SBPosIndicatorSmallT;
		W.DrawStretchedTextureSegment( C, 0, ThumbY, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		// Draw the middle stretch.
		R = SBPosIndicatorSmallM;
		W.DrawStretchedTextureSegment( C, 0, ThumbY + SBPosIndicatorSmallT.H, R.W, W.ThumbHeight - SBPosIndicatorSmallT.H - 2*SBPosIndicatorSmallB.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	
		// Draw the bottom part.
		R = SBPosIndicatorSmallB;
		W.DrawStretchedTextureSegment( C, 0, ThumbY + W.ThumbHeight - SBPosIndicatorSmallT.H - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}

	// Draw the up button down.
	if ( W.UpButton.bMouseDown )
	{
		R = VScrollSmallUpDown;
		W.DrawStretchedTextureSegment( C, 1, 1, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}

	// Draw the down button down.
	if ( W.DownButton.bMouseDown )
	{
		R = VScrollSmallDownDown;
		W.DrawStretchedTextureSegment( C, 1, W.WinHeight-SBDownUp.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}
}

function SB_VDrawBevel( UWindowVScrollbar W, Canvas C )
{
	local Region R;
	local Texture T;
	local float ThumbY, ScrollHeight, ThumbHeight;
	local float OldClipW, OldClipH;

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Draw the top part.
	R = VSlideBevelTop;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the middle stretch.
	R = VSlideBevelMid;
	W.DrawStretchedTextureSegment( C, 0, VSlideBevelTop.H, R.W, W.WinHeight-VSlideBevelBot.H-VSlideBevelTop.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	
	// Draw the bottom part.
	R = VSlideBevelBot;
	W.DrawStretchedTextureSegment( C, 0, W.WinHeight-R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the thumb.
	if ( !W.bDisabled )
	{
		ScrollHeight = W.WinHeight - 2*SBPosIndicatorBevelT.H;
		ThumbY = (W.ThumbStart/ScrollHeight) * (ScrollHeight - 24.0) + 12.0;
		ThumbHeight = W.ThumbHeight - 11.0;

		// Draw the top part.
		R = SBPosIndicatorBevelT;
		W.DrawStretchedTextureSegment( C, 0, ThumbY, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

		// Draw the middle stretch.
		R = SBPosIndicatorBevelM;
		W.DrawStretchedTextureSegment( C, 0, ThumbY + SBPosIndicatorBevelT.H, R.W, ThumbHeight - SBPosIndicatorBevelT.H - 2*SBPosIndicatorBevelB.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	
		// Draw the bottom part.
		R = SBPosIndicatorBevelB;
		W.DrawStretchedTextureSegment( C, 0, ThumbY + ThumbHeight - SBPosIndicatorBevelT.H - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}

	// Draw the up button down.
	if ( W.UpButton.bMouseDown )
	{
		R = VScrollBevelUpDown;
		W.DrawStretchedTextureSegment( C, 4, 4, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}

	// Draw the down button down.
	if ( W.DownButton.bMouseDown )
	{
		R = VScrollBevelDownDown;
		W.DrawStretchedTextureSegment( C, 4, W.WinHeight-SBDownUp.H-2, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );
	}
}

/*-----------------------------------------------------------------------------
	Checkbox
-----------------------------------------------------------------------------*/

function bool Checkbox_Draw( UWindowCheckbox W, Canvas C )
{
	local Region R;
	local Texture T;

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	if ( W.bChecked )
		R = CheckBoxChecked;
	else
		R = CheckBoxEmpty;

	// Draw the check.
	W.DrawStretchedTextureSegment( C, W.ImageX, W.ImageY, R.W, R.H,	R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the label.
	C.DrawColor = GetTextColor(W);
	ClipText( W, C, W.TextX, W.TextY, W.Text, true );

	return true;
}

function Checkbox_ManualDraw( UWindowWindow Win, Canvas C, float X, float Y, float W, float H, bool bChecked )
{	
	local Region	R;
	local Texture	T;

	// Set our draw color.
	C.DrawColor = Win.WhiteColor;

	// Set our blending mode.
	C.Style = Win.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = Win.GetLookAndFeelTexture();

	if ( bChecked )
		R = CheckBoxChecked;
	else
		R = CheckBoxEmpty;

	// Draw the check.
	Win.DrawStretchedTextureSegment( C, X, Y, W, H, R.X, R.Y, R.W, R.H, T, 1.0 );	
}

/*-----------------------------------------------------------------------------
	Horizontal Slider
-----------------------------------------------------------------------------*/

function HSlider_AutoSize( UWindowHSliderControl W, Canvas C )
{
	W.WinHeight = HSliderL.H;
	W.TrackWidth = HSliderThumb.W;

	W.SliderTrackWidth = W.SliderWidth - W.TrackWidth - HSliderL.W - HSliderR.W;
	W.SliderTrackX = W.SliderDrawX + HSliderL.W;
	W.TrackStart = W.SliderTrackX + HSliderThumb.W/2 + (W.SliderWidth - W.TrackWidth - HSliderL.W - HSliderR.W) * ((W.Value - W.MinValue) / (W.MaxValue - W.MinValue));
}

function HSlider_Draw( UWindowHSliderControl W, Canvas C )
{
	local Texture T;
	local Region R;
	local float OldClipW, OldClipH, XL, YL;

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Retrive the draw texture.
	T = W.GetLookAndFeelTexture();

	// Draw the text.
	C.DrawColor = GetTextColor(W);
	ClipText( W, C, W.TextX, W.TextY, W.Text );

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Draw the left part.
	R = HSliderL;
	W.DrawStretchedTextureSegment( C, W.SliderDrawX, W.SliderDrawY, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the middle stretch.
	R = HSlider;
	W.DrawStretchedTextureSegment( C, W.SliderDrawX + HSliderL.W, W.SliderDrawY, W.SliderWidth - HSliderL.W - HSliderR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the right part.
	R = HSliderR;
	W.DrawStretchedTextureSegment( C, W.SliderDrawX + W.SliderWidth - R.W, W.SliderDrawY, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the thumb.
	R = HSliderThumb;
	W.DrawStretchedTextureSegment( C, W.TrackStart - (R.W/2), W.SliderDrawY, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the value.
	C.Font = W.Root.Fonts[F_Small];
	C.DrawColor = GetTextColor(W);
	W.TextSize( C, W.ValueString, XL, YL );
	OldClipW = W.ClippingRegion.W; OldClipH = W.ClippingRegion.H;
	W.ClippingRegion.W = 1000; W.ClippingRegion.H = 1000;
	W.ClipText( C, W.SliderDrawX + W.SliderWidth + 2, (W.WinHeight - YL)/2, W.ValueString );
	W.ClippingRegion.W = OldClipW; W.ClippingRegion.H = OldClipH;
}

/*-----------------------------------------------------------------------------
	Combo Control
-----------------------------------------------------------------------------*/

function Combo_GetButtonBitmaps(UWindowComboButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();
	
	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = ComboBtnUp;
	W.DownRegion = ComboBtnDown;
	W.OverRegion = ComboBtnUp;
	W.DisabledRegion = ComboBtnDisabled;
}

function Combo_SetupLeftButton(UWindowComboLeftButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBLeftUp;
	W.DownRegion = SBLeftDown;
	W.OverRegion = SBLeftUp;
	W.DisabledRegion = SBLeftDisabled;
}

function Combo_SetupRightButton(UWindowComboRightButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBRightUp;
	W.DownRegion = SBRightDown;
	W.OverRegion = SBRightUp;
	W.DisabledRegion = SBRightDisabled;
}

function Combo_SetupSizes( UWindowComboControl W, Canvas C )
{
	local float XL, YL;

	C.Font = W.Root.Fonts[W.Font];
	W.TextSize( C, W.Text, XL, YL );

	W.WinHeight = ComboUpTL.H + ComboUpBL.H;

	W.EditBoxWidth = W.WinWidth - ComboUpTR.W - 20;//8;

	switch( W.Align )
	{
	case TA_Left:
		W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
		W.TextX = 0;
		break;
	case TA_Right:
		W.EditAreaDrawX = 0;	
		W.TextX = W.WinWidth - XL;
		break;
	case TA_Center:
		W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth) / 2;
		W.TextX = (W.WinWidth - XL) / 2;
		break;
	}

	W.TextY = (W.WinHeight - YL) / 2;

	W.EditBox.bComboBox = true;
	W.EditBox.WinLeft = W.EditAreaDrawX + 8;
	W.EditBox.WinTop  =  1;
	W.EditBox.WinWidth = W.EditBoxWidth;
	W.EditBox.WinHeight = W.WinHeight;

	W.Button.WinLeft = W.WinWidth - ComboUpTR.W;
	W.Button.WinTop = 0;
	W.Button.WinHeight = W.WinHeight;
	W.Button.WinWidth = ComboUpTR.W;
}

function Combo_Draw( UWindowComboControl W, Canvas C )
{
	local Region R;
	local Texture T;

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Draw the top left corner.
	R = ComboUpTL;
	W.DrawStretchedTextureSegment( C, W.EditAreaDrawX, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the top middle stretch.
	R = ComboUpT;
	W.DrawStretchedTextureSegment( C, W.EditAreaDrawX + ButtonUpTL.W, 0, W.WinWidth - ButtonUpTL.W - ButtonUpTR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the top right corner.
	if ( W.bListVisible )
		R = ComboDownTR;
	else
		R = ComboUpTR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom left corner.
	if ( W.bListVisible )
		R = ComboDownBL;
	else
		R = ComboUpBL;
	W.DrawStretchedTextureSegment( C, W.EditAreaDrawX, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom middle stretch.
	R = ComboUpB;
	W.DrawStretchedTextureSegment( C, W.EditAreaDrawX + ButtonUpBL.W, W.WinHeight - R.H, W.WinWidth - ButtonUpBL.W - ButtonUpBR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom right corner.
	if ( W.bListVisible )
		R = ComboDownBR;
	else
		R = ComboUpBR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	C.DrawColor = GetTextColor(W);
	ClipText( W, C, W.TextX, W.TextY, W.Text );
}

function ComboList_PositionList( UWindowComboList W, Canvas C, out float ListX, out float ListY )
{
	W.WinHeight += ComboDropBL.H;
	W.WinWidth = W.Owner.WinWidth;//W.Owner.EditBoxWidth;
	ListX = W.Owner.EditAreaDrawX;
	ListY = 21;

	W.VertSB.WinLeft = W.WinWidth - SBPosIndicator.W - 8;
	W.VertSB.WinTop = 1;
	W.VertSB.WinWidth = SBPosIndicator.W;
	W.VertSB.WinHeight = W.WinHeight - ComboDropBR.H;
}

function ComboList_DrawBackground( UWindowComboList W, Canvas C )
{
	local Region R;
	local Texture T;

	// Set our draw color.
	C.DrawColor = GetGUIColor(W);

	// Set our blending mode.
	C.Style = W.GetPlayerOwner().ERenderStyle.STY_Normal;

	// Get the texture.
	T = W.GetLookAndFeelTexture();

	// Draw the left side of the control.
	R = ComboDropL;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, W.WinHeight - ComboDropBL.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the right side of the control.
	R = ComboDropR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, 0, R.W, W.WinHeight - ComboDropBR.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom left corner.
	R = ComboDropBL;
	W.DrawStretchedTextureSegment( C, 0, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom middle stretch.
	R = ComboDropB;
	W.DrawStretchedTextureSegment( C, ComboDropBL.W, W.WinHeight - R.H, W.WinWidth - ComboDropBL.W - ComboDropBR.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw the bottom right corner.
	R = ComboDropBR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, 1.0 );

	// Draw in the fill.
	R = ComboFill;
	W.DrawStretchedTextureSegment( C, ComboDropL.W, 0, W.WinWidth - ComboDropL.W - ComboDropR.W, W.WinHeight - ComboDropB.H, R.X, R.Y, R.W, R.H, T, 1.0 );
}

function ComboList_DrawItem( UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected )
{
	local Region OldClipReg;
	local float XL, YL, YOff;

	C.DrawColor = GetTextColor(Combo);
	if ( !bSelected )
	{
		C.DrawColor.R = 3 * (C.DrawColor.R / 4);
		C.DrawColor.G = 3 * (C.DrawColor.G / 4);
		C.DrawColor.B = 3 * (C.DrawColor.B / 4);
	}
	
	OldClipReg = Combo.ClippingRegion;
	Combo.ClippingRegion.X = ComboDropL.W;
	Combo.ClippingRegion.W = Combo.WinWidth - ComboDropL.W*2;

	C.Font = Combo.Root.Fonts[F_Normal];
	Combo.TextSize( C, Text, XL, YL );

//	if ( XL > Combo.ClippingRegion.W )
//	{
		C.Font = Combo.Root.Fonts[F_Small];
		YOff = 4;
//	}
//	else
//	{
//		C.Font = Combo.Root.Fonts[F_Normal];
//		YOff = 3;
//	}

	Combo.ClipText( C, X + ComboDropL.W, Y + YOff, Text );

	Combo.ClippingRegion = OldClipReg;
}

/*-----------------------------------------------------------------------------
	MessageBox
-----------------------------------------------------------------------------*/

function MessageBox_AutoSize( UWindowMessageBox W, Canvas C )
{
	local UWindowMessageBoxCW ClientBox;
	local float XL, YL, WinLen;
	local Region R;

	ClientBox = UWindowMessageBoxCW(W.ClientArea);

	C.Font = W.Root.Fonts[W.F_Normal];
	W.TextSize( C, ClientBox.MessageArea.Message, XL, YL );

	WinLen = XL + FrameL.W + FrameR.W;
	if ( WinLen > 400 )
		WinLen = 400;

	W.SetSize( WinLen, W.WinHeight );
	R = FW_GetClientArea( W );
	W.SetSize( WinLen, (W.WinHeight - R.H) + ClientBox.GetHeight(C) );
	W.WinLeft = int((W.Root.WinWidth  - W.WinWidth) / 2);
	W.WinTop  = int((W.Root.WinHeight - W.WinHeight) / 2);
}

/*-----------------------------------------------------------------------------
	Sound
-----------------------------------------------------------------------------*/

simulated function PlayMenuSound( UWindowWindow W, MenuSound S, optional float fVolume )
{
	local sound sndMenu;
	local int Slot;

	CurrentSlot++;
	if ( CurrentSlot > 4 )
		CurrentSlot = 0;

	switch ( CurrentSlot )
	{
		case 0:
			Slot = 1;//SLOT_Misc;
			break;
		case 1:
			Slot = 2;//SLOT_Pain;
			break;
		case 2:
			Slot = 3;//SLOT_Interact;
			break;
		case 3:
			Slot = 5;//SLOT_Talk;
			break;
		case 4:
			Slot = 6;//SLOT_Interface;
			break;
	}

	switch( S )
	{
		case MS_MenuUp:		// Played any time a window opens. (Currently clientwindow windowshown.)
//			W.GetPlayerOwner().BroadcastMessage("Played MS_MenuUp"@W);
			sndMenu = sound'a_generic.Menu.MenuUp';
			break;
		case MS_MenuDown:	// Played when the last window closes.
//			W.GetPlayerOwner().BroadcastMessage("Played MS_MenuDown"@W);
			sndMenu = sound'a_generic.Menu.MenuDown';
			break;
		case MS_MenuAction: // Currently played whenever a button object is clicked.
//			W.GetPlayerOwner().BroadcastMessage("Played MS_MenuAction"@W);
			sndMenu = sound'a_generic.Menu.MenuAction';
			break;
		case MS_MenuEntry:	// Played in StartSunglassesAnimation if quick key isn't enabled.
//			W.GetPlayerOwner().BroadcastMessage("Played MS_MenuEntry"@W);
			sndMenu = sound'a_generic.Menu.MenuEntry';
			break;
		case MS_OptionHL:	// Whenever a root menu icon is highlighted.
//			W.GetPlayerOwner().BroadcastMessage("Played MS_OptionHL"@W);
			sndMenu = sound'a_generic.Menu.OptionHL';
			break;
		case MS_GameStart:	// Played when a map is selected.
//			W.GetPlayerOwner().BroadcastMessage("Played MS_GameStart"@W);
			sndMenu = GameStartSound;
			break;
		case MS_ExitGame:	// Currently not used.
//			W.GetPlayerOwner().BroadcastMessage("Played MS_ExitGame"@W);
			sndMenu = sound'a_generic.Menu.ExitGame';
			break;
		case MS_SubMenuActivate:	// Played when a pulldown is opened.
//			W.GetPlayerOwner().BroadcastMessage("Played MS_SubMenuActivate"@W);
			sndMenu = sound'a_generic.Menu.SubMenuActivate';
			break;
	}
	
	if ( sndMenu != None )
	{
		// If a volume is passed in, pass it along, otherwise use the default.
		if ( fVolume > 0.0f )
			W.GetPlayerOwner().PlaySound( sndMenu, W.GetPlayerOwner().GetSlotForInt( Slot ), fVolume, true );
		else
			W.GetPlayerOwner().PlaySound( sndMenu, W.GetPlayerOwner().GetSlotForInt( Slot ), 1.0, true );
	}
}

function float GetGameStartDuration( UWindowWindow W )
{
	return W.GetPlayerOwner().GetSoundDuration( GameStartSound );
}

function Menu_DrawPulldownMenuBackground( UWindowPulldownMenu W, Canvas C )
{	
	Bevel_DrawSimpleBevel( W,C,Pulldown_HBorder,Pulldown_VBorder,W.WinWidth-(2*Pulldown_HBorder),W.WinHeight-(2*Pulldown_VBorder) );
}


function Menu_DrawPulldownMenuItem( UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected )
{
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	
	C.Style = M.GetPlayerOwner().ERenderStyle.STY_Normal;

	Item.ItemTop = Y + M.WinTop;

	if ( Item.Caption == "-" )
	{
		M.DrawStretchedTexture( C, X, Y+5, W, 2, Texture'UWindow.MenuDivider' );
		return;
	}

	C.Font = M.Root.Fonts[M.Font];

	if ( bSelected )
	{
		M.DrawStretchedTexture( C, X, Y, W, H, Texture'WhiteTexture', 0.5 );
	}

	if ( Item.bDisabled )  
	{
		// Black Shadow
		C.DrawColor.R = 96;
		C.DrawColor.G = 96;
		C.DrawColor.B = 96;
	}
	else
	{
		C.DrawColor = GetTextColor( M );
	}

	// DrawColor will render the tick black white or gray.
	if( Item.bChecked )
		M.DrawClippedTexture( C, X + 1, Y + 3, Texture'MenuTick' );

	if( Item.SubMenu != None )
		M.DrawClippedTexture(C, X + W - 9, Y + 3, Texture'MenuSubArrow');

	M.ClipText( C, X + M.TextBorder + 2, Y + 3, Item.Caption, True );
}

defaultproperties
{
	DefaultTextColor=(R=255,G=255,B=255)
	colorTextSelected=(R=255,G=255,B=255)
	colorTextUnselected=(R=150,G=150,B=150)

	CloseBoxUp=(X=4,Y=32,W=11,H=11)
	CloseBoxDown=(X=4,Y=43,W=11,H=11)
	CloseBoxOffsetX=2
	CloseBoxOffsetY=2

	CloseButtonRegion=(X=191,Y=152,W=18,H=18)
	ResetButtonRegion=(X=170,Y=152,W=18,H=18)

	ClientArea=(X=127,Y=112,W=2,H=2)

	FrameTL=(X=0,Y=0,W=106,H=53)
	FrameT=(X=107,Y=0,W=5,H=53)
	FrameT2=(X=127,Y=0,W=5,H=53)
	FrameT3=(X=111,Y=0,W=1,H=53)
	FrameTR=(X=133,Y=0,W=122,H=53)

	FrameL=(X=0,Y=54,W=26,H=1)
	FrameR=(X=210,Y=54,W=45,H=1)

	FrameBL=(X=0,Y=230,W=26,H=26)
	FrameB=(X=43,Y=230,W=1,H=26)
	FrameBR=(X=210,Y=230,W=45,H=26)

	FrameSBL=(X=0,Y=76,W=26,H=51)
	FrameSB=(X=43,Y=76,W=1,H=51)
	FrameSBR=(X=211,Y=76,W=44,H=51)

	FrameInactiveTitleColor=(R=255,G=255,B=255)
    HeadingInActiveTitleColor=(R=255,G=255,B=255)
	FrameTitleX=24
	FrameTitleY=33

	CheckBoxEmpty=(X=26,Y=106,W=32,H=32)
	CheckBoxChecked=(X=59,Y=106,W=32,H=32)

	EditBoxFill=(X=151,Y=69,W=1,H=1)
	EditBoxTL=(X=136,Y=54,W=9,H=9)
	EditBoxT=(X=146,Y=54,W=1,H=9)
	EditBoxTR=(X=164,Y=54,W=9,H=9)
	EditBoxL=(X=136,Y=69,W=9,H=1)
	EditBoxR=(X=164,Y=69,W=9,H=1)
	EditBoxBL=(X=136,Y=74,W=9,H=9)
	EditBoxB=(X=146,Y=74,W=1,H=9)
	EditBoxBR=(X=164,Y=74,W=9,H=9)

	EditBoxFocusFill=(X=151,Y=69,W=1,H=1)
	EditBoxFocusTL=(X=136,Y=87,W=9,H=9)
	EditBoxFocusT=(X=146,Y=87,W=1,H=9)
	EditBoxFocusTR=(X=164,Y=87,W=9,H=9)
	EditBoxFocusL=(X=136,Y=102,W=9,H=1)
	EditBoxFocusR=(X=164,Y=102,W=9,H=1)
	EditBoxFocusBL=(X=136,Y=107,W=9,H=9)
	EditBoxFocusB=(X=146,Y=107,W=1,H=9)
	EditBoxFocusBR=(X=164,Y=107,W=9,H=9)

	ButtonUpTL=(X=95,Y=105,W=10,H=20)
	ButtonUpT=(X=106,Y=105,W=1,H=20)
	ButtonUpTR=(X=113,Y=105,W=10,H=20)
	ButtonUpBL=(X=95,Y=126,W=10,H=16)
	ButtonUpB=(X=106,Y=126,W=1,H=16)
	ButtonUpBR=(X=113,Y=126,W=10,H=16)
	ButtonDownTL=(X=95,Y=144,W=10,H=20)
	ButtonDownT=(X=106,Y=144,W=1,H=20)
	ButtonDownTR=(X=113,Y=144,W=10,H=20)
	ButtonDownBL=(X=95,Y=165,W=10,H=16)
	ButtonDownB=(X=106,Y=165,W=1,H=16)
	ButtonDownBR=(X=113,Y=165,W=10,H=16)

	ComboFill=(X=101,Y=83,W=1,H=1)

	ComboUpTL=(X=27,Y=54,W=20,H=14)
	ComboUpT=(X=48,Y=54,W=1,H=14)
	ComboUpTR=(X=50,Y=54,W=28,H=14)
	ComboUpBL=(X=27,Y=68,W=20,H=15)
	ComboUpB=(X=48,Y=68,W=1,H=15)
	ComboUpBR=(X=50,Y=68,W=28,H=15)

	ComboDownTR=(X=105,Y=54,W=28,H=14)
	ComboDownBR=(X=105,Y=68,W=28,H=15)
	ComboDownBL=(X=82,Y=68,W=20,H=15)

	ComboDropL=(X=82,Y=77,W=10,H=1)
	ComboDropR=(X=105,Y=85,W=28,H=1)
	ComboDropBL=(X=82,Y=92,W=10,H=10)
	ComboDropB=(X=93,Y=92,W=1,H=10)
	ComboDropBR=(X=105,Y=92,W=28,H=10)

	HSliderL=(X=128,Y=119,W=11,H=20)
	HSlider=(X=179,Y=119,W=1,H=20)
	HSliderR=(X=180,Y=119,W=11,H=20)
	HSliderThumb=(X=150,Y=119,W=18,H=20)

	SliderBarBox=(X=4,Y=16,W=16,H=16)

	VSlideTop=(X=194,Y=53,W=15,H=19)
	VSlideMid=(X=194,Y=77,W=15,H=1)
	VSlideBot=(X=194,Y=113,W=15,H=19)
	SBUpUp=(W=13,H=13)
	SBDownUp=(W=13,H=13)

	VSlideSmallTop=(X=178,Y=53,W=13,H=19)
	VSlideSmallMid=(X=178,Y=86,W=13,H=0)
	VSlideSmallBot=(X=178,Y=87,W=13,H=19)

	VSlideBevelTop=(X=34,Y=159,W=19,H=22)
	VSlideBevelMid=(X=34,Y=182,W=19,H=0)
	VSlideBevelBot=(X=34,Y=199,W=19,H=22)

	SBPosIndicatorT=(X=194,Y=86,W=15,H=5)
	SBPosIndicatorM=(X=194,Y=91,W=15,H=1)
	SBPosIndicatorB=(X=194,Y=93,W=15,H=5)
	SBPosIndicator=(X=194,Y=86,W=15,H=11)

	SBPosIndicatorSmallT=(X=178,Y=73,W=13,H=5)
	SBPosIndicatorSmallM=(X=178,Y=78,W=13,H=1)
	SBPosIndicatorSmallB=(X=178,Y=80,W=13,H=5)
	SBPosIndicatorSmall=(X=178,Y=73,W=13,H=12)

	SBPosIndicatorBevelT=(X=34,Y=184,W=19,H=5)
	SBPosIndicatorBevelM=(X=34,Y=189,W=19,H=1)
	SBPosIndicatorBevelB=(X=34,Y=190,W=19,H=5)
	SBPosIndicatorBevel=(X=34,Y=184,W=19,H=12)

	VScrollUpDown=(X=65,Y=86,W=12,H=12)
	VScrollDownDown=(X=52,Y=86,W=12,H=12)

	VScrollSmallUpDown=(X=39,Y=86,W=12,H=12)
	VScrollSmallDownDown=(X=26,Y=86,W=12,H=12)

	VScrollBevelUpDown=(X=64,Y=141,W=12,H=12)
	VScrollBevelDownDown=(X=64,Y=158,W=12,H=12)

	SimpleBevelFill=(X=31,Y=200,W=1,H=1)
	SimpleBevelTL=(X=26,Y=99,W=6,H=6)
	SimpleBevelT=(X=39,Y=99,W=1,H=6)
	SimpleBevelTR=(X=56,Y=99,W=6,H=6)
	SimpleBevelL=(X=26,Y=157,W=6,H=1)
	SimpleBevelR=(X=56,Y=157,W=6,H=)
	SimpleBevelBL=(X=26,Y=221,W=6,H=6)
	SimpleBevelB=(X=32,Y=221,W=1,H=6)
	SimpleBevelBR=(X=56,Y=221,W=6,H=6)

	BevelHeaderTL=(X=26,Y=139,W=5,H=14)
	BevelHeaderT=(X=32,Y=139,W=1,H=14)
	BevelHeaderTR=(X=57,Y=139,W=5,H=14)
	BevelHeaderSplit=(X=41,Y=139,W=5,H=14)

	BevelTL=(X=26,Y=156,W=5,H=5)
	BevelT=(X=31,Y=156,W=1,H=5)
	BevelTR=(X=57,Y=156,W=5,H=5)
	BevelSplit=(X=41,Y=157,W=6,H=1)
	BevelSplitB=(X=40,Y=223,W=6,H=4)

	ArrowButtonRightUp=(X=38,Y=2,W=36,H=29)
	ArrowButtonRightDown=(X=38,Y=33,W=36,H=29)
	ArrowButtonLeftUp=(X=0,Y=2,W=36,H=29)
	ArrowButtonLeftDown=(X=0,Y=33,W=36,H=29)

	TabLeft=(X=79,Y=186,W=28,H=35)
	TabMid=(X=80,Y=186,W=2,H=35)
	TabRight=(X=114,Y=186,W=28,H=35)

	TabLeftUp=(X=146,Y=186,W=28,H=35)
	TabMidUp=(X=147,Y=186,W=2,H=35)
	TabRightUp=(X=181,Y=186,W=28,H=35)

	Size_TabAreaHeight=35.0
    Size_TabAreaOverhangHeight=2.0
	Size_TabSpacing=20.000000
	Size_TabXOffset=1.000000

	Pulldown_ItemHeight=16.000000
	Pulldown_VBorder=10.000000
	Pulldown_HBorder=10.000000
	Pulldown_TextBorder=9.000000
	TabSelectedL=(X=4,Y=80,W=3,H=17)
	TabSelectedM=(X=7,Y=80,W=1,H=17)
	TabSelectedR=(X=55,Y=80,W=2,H=17)
	TabUnselectedL=(X=57,Y=80,W=3,H=15)
	TabUnselectedM=(X=60,Y=80,W=1,H=15)
	TabUnselectedR=(X=109,Y=80,W=2,H=15)
	TabBackground=(X=4,Y=79,W=1,H=1)

	ColumnHeadingHeight=13

	GameStartSound=sound'a_generic.Menu.GameStart'
}
