class UDukeBlueLookAndFeel extends UWindowLookAndFeel;

var() Region	FrameSBL;
var() Region	FrameSB;
var() Region	FrameSBR;

var() Region	CloseBoxUp;
var() Region	CloseBoxDown;
var() int		CloseBoxOffsetX;
var() int		CloseBoxOffsetY;

const SIZEBORDER = 3;
const BRSIZEBORDER = 15;

function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C, optional float fAnimAlpha)
{
	local Texture T;
	local Region R, Temp;

	C.DrawColor.r = 255;
	C.DrawColor.g = 255;
	C.DrawColor.b = 255;

	T = W.GetLookAndFeelTexture();

	DrawWindowFrameTop(W, C, T, fAnimAlpha);

	if(W.bStatusBar)
		Temp = FrameSBL;
	else
		Temp = FrameBL;
	
	R = FrameL;
	W.DrawStretchedTextureSegment( C, 0, FrameTL.H,
									R.W, W.WinHeight - FrameTL.H - Temp.H,
									R.X, R.Y, R.W, R.H, T, fAnimAlpha );

	R = FrameR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, FrameTL.H,
									R.W, W.WinHeight - FrameTL.H - Temp.H,
									R.X, R.Y, R.W, R.H, T, fAnimAlpha );

	if(W.bStatusBar)
		R = FrameSBL;
	else
		R = FrameBL;
	W.DrawStretchedTextureSegment( C, 0, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T, fAnimAlpha );

	if(W.bStatusBar)
	{
		R = FrameSB;
		W.DrawStretchedTextureSegment( C, FrameBL.W, W.WinHeight - R.H, 
										W.WinWidth - FrameSBL.W - FrameSBR.W,
										R.H, R.X, R.Y, R.W, R.H, T, fAnimAlpha );
	}
	else
	{
		R = FrameB;
		W.DrawStretchedTextureSegment( C, FrameBL.W, W.WinHeight - R.H, 
										W.WinWidth - FrameBL.W - FrameBR.W,
										R.H, R.X, R.Y, R.W, R.H, T, fAnimAlpha );
	}

	if(W.bStatusBar)
		R = FrameSBR;
	else
		R = FrameBR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, W.WinHeight - R.H, 
									R.W, R.H, R.X, R.Y, R.W, R.H, T, fAnimAlpha );

	DrawTitleAndStatus(W, C, fAnimAlpha);
}

function DrawTitleAndStatus(UWindowFramedWindow W, Canvas C, float fAnimAlpha)
{
	if(W.ParentWindow.ActiveWindow == W)
	{
		C.DrawColor = FrameActiveTitleColor;
		C.Font = W.Root.Fonts[W.F_Bold];
	}
	else
	{
		C.DrawColor = FrameInactiveTitleColor;
		C.Font = W.Root.Fonts[W.F_Normal];
	}
	W.ClipTextWidth(C, FrameTitleX, FrameTitleY, 
					W.WindowTitle, W.WinWidth - 22);

	if(W.bStatusBar) 
	{
		C.Font = W.Root.Fonts[W.F_Normal];
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 0;

		W.ClipTextWidth(C, 6, W.WinHeight - 13, W.StatusBarText, W.WinWidth - 22);

		C.DrawColor.r = 255;
		C.DrawColor.g = 255;
		C.DrawColor.b = 255;
	}
}

function DrawWindowFrameTop(UWindowFramedWindow W, Canvas C, Texture T, float fAnimAlpha)
{
	local Region R;
	
	R = FrameTL;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y-5, R.W, R.H, T );
	
	if(eFrameType == eWINDOW_FRAME_TYPE_TILE_TOP)  {
		//TLW: Added ability to tile one texture across the top of the frame
		W.DrawHorizTiledPieces( C, 
								FrameTL.W, 0, 
								W.WinWidth - FrameTL.W - FrameTR.W, FrameT.H, 
								FrameT, T,					//Texture to use
								fAnimAlpha	
		//						TexRegion(None), None, None, None, //Place holders for other textureRegions
		//						1.0 
		);

	}
	else  {
		W.DrawStretchedTextureSegment( 	C, 
										FrameTL.W, 0, 
										W.WinWidth - FrameTL.W - FrameTR.W, FrameT.H, 
										FrameT.X, FrameT.Y, 
										FrameT.W, FrameT.H, 
										T,
										fAnimAlpha 
		);
	}

	R = FrameTR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T, fAnimAlpha );
}
/*
function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C)
{
	local Texture T;

    // CDH... I don't know what happened, but ever since Tim W. was mucking with the windowing
    // system and user interface, we've been getting script warnings out the wazzoo for there
    // being accesses to None within this function.  This is probably a major "FIXME:" we're
    // talking about, but given that Tim W. decided to leave with all the stuff in a broken
    // state, I have no idea what's going on here, so I'm just going to shield it for now.
    // This broken interface has ruined its own homelands, it will not ruin mine... graar.
    if (W == None)
        return;
    if (W.CloseBox == None)
        return;
    // ...CDH

	T = W.GetLookAndFeelTexture();

	W.CloseBox.WinLeft = W.WinWidth - CloseBoxOffsetX - CloseBoxUp.W;
	W.CloseBox.WinTop = CloseBoxOffsetY;

	W.CloseBox.SetSize(CloseBoxUp.W, CloseBoxUp.H);
	W.CloseBox.bUseRegion = True;

	W.CloseBox.UpTexture = T;
	W.CloseBox.DownTexture = T;
	W.CloseBox.OverTexture = T;
	W.CloseBox.DisabledTexture = T;

	W.CloseBox.UpRegion = CloseBoxUp;
	W.CloseBox.DownRegion = CloseBoxDown;
	W.CloseBox.OverRegion = CloseBoxUp;
	W.CloseBox.DisabledRegion = CloseBoxUp;
}
*/
function Region FW_GetClientArea(UWindowFramedWindow W)
{
	local Region R;

	R.X = FrameL.W;
	R.Y	= FrameT.H;
	R.W = W.WinWidth - (FrameL.W + FrameR.W);
	if(W.bStatusBar) 
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

function Checkbox_SetupSizes(UWindowCheckbox W, Canvas C)
{
	Super.Checkbox_SetupSizes(W, C);

	if(W.bChecked) 
	{
		W.UpTexture = Texture'ChkChecked';
		W.DownTexture = Texture'ChkChecked';
		W.OverTexture = Texture'ChkChecked';
		W.DisabledTexture = Texture'ChkCheckedDisabled';
	}
	else 
	{
		W.UpTexture = Texture'ChkUnchecked';
		W.DownTexture = Texture'ChkUnchecked';
		W.OverTexture = Texture'ChkUnchecked';
		W.DisabledTexture = Texture'ChkUncheckedDisabled';
	}
}

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

function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0, W.EditBoxWidth, W.WinHeight, Misc, EditBoxBevel);
	Super.Editbox_Draw(W, C);
}

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

function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText)
{
	local Region R;
	local Texture T;
	local float TW, TH;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	T = Tab.GetLookAndFeelTexture();
	
	if(bActiveTab)
	{
		R = TabSelectedL;
		Tab.DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

		R = TabSelectedM;
		Tab.DrawStretchedTextureSegment( C, X+TabSelectedL.W, Y, 
										W - TabSelectedL.W
										- TabSelectedR.W,
										R.H, R.X, R.Y, R.W, R.H, T );

		R = TabSelectedR;
		Tab.DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

		C.Font = Tab.Root.Fonts[Tab.F_Bold];
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;

		if(bShowText)
		{
			Tab.TextSize(C, Text, TW, TH);
			Tab.ClipText(C, X + (W-TW)/2, Y + 3, Text, True);
		}
	}
	else
	{
		R = TabUnselectedL;
		Tab.DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

		R = TabUnselectedM;
		Tab.DrawStretchedTextureSegment( C, X+TabUnselectedL.W, Y, 
										W - TabUnselectedL.W
										- TabUnselectedR.W,
										R.H, R.X, R.Y, R.W, R.H, T );

		R = TabUnselectedR;
		Tab.DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

		C.Font = Tab.Root.Fonts[Tab.F_Normal];
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;

		if(bShowText)
		{
			Tab.TextSize(C, Text, TW, TH);
			Tab.ClipText(C, X + (W-TW)/2, Y + 4, Text, True);
		}
	}
}

function SB_SetupUpButton(UWindowSBUpButton W)
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

function SB_SetupDownButton(UWindowSBDownButton W)
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

function SB_SetupLeftButton(UWindowSBLeftButton W)
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

function SB_SetupRightButton(UWindowSBRightButton W)
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

function SB_VDraw(UWindowVScrollbar W, Canvas C)
{
	local Region R;
	local Texture T;

	T = W.GetLookAndFeelTexture();

	R = SBBackground;
	W.DrawStretchedTextureSegment( C, 0, 0, W.WinWidth, W.WinHeight, R.X, R.Y, R.W, R.H, T);
	
	if(!W.bDisabled)
	{
		W.DrawUpBevel( C, 0, W.ThumbStart, SBPosIndicator.W,	W.ThumbHeight, T);
	}
}

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

function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P)
{
	P.WinLeft = 2;
	P.WinTop = W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H) + 3;
	P.SetSize(W.WinWidth - 4, W.WinHeight-(W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H)) - 6);
}

function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P)
{
	W.DrawUpBevel( C, 0, W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H), W.WinWidth, W.WinHeight-(W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H)), W.GetLookAndFeelTexture());
}

function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H)
{
	local float TW, TH;

	C.Font = Tab.Root.Fonts[Tab.F_Bold];

	Tab.TextSize( C, Text, TW, TH );
	W = TW + Size_TabSpacing;
	H = Size_TabAreaHeight;
}

defaultproperties
{
     FrameSBL=(Y=112,W=2,h=16)
     FrameSB=(X=32,Y=112,W=1,h=16)
     FrameSBR=(X=112,Y=112,W=16,h=16)
     CloseBoxUp=(X=4,Y=32,W=11,h=11)
     CloseBoxDown=(X=4,Y=43,W=11,h=11)
     CloseBoxOffsetX=2
     CloseBoxOffsetY=2
     FrameTL=(W=2,h=16)
     FrameT=(X=32,W=1,h=16)
     FrameTR=(X=126,W=2,h=16)
     FrameL=(Y=32,W=2,h=1)
     FrameR=(X=126,Y=32,W=2,h=1)
     FrameBL=(Y=125,W=2,h=3)
     FrameB=(X=32,Y=125,W=1,h=3)
     FrameBR=(X=126,Y=125,W=2,h=3)
     FrameInactiveTitleColor=(R=255,G=255,B=255)
     HeadingInActiveTitleColor=(R=255,G=255,B=255)
     FrameTitleX=6
     FrameTitleY=2
     BevelUpTL=(X=4,Y=16,W=2,h=2)
     BevelUpT=(X=10,Y=16,W=1,h=2)
     BevelUpTR=(X=18,Y=16,W=2,h=2)
     BevelUpL=(X=4,Y=20,W=2,h=1)
     BevelUpR=(X=18,Y=20,W=2,h=1)
     BevelUpBL=(X=4,Y=30,W=2,h=2)
     BevelUpB=(X=10,Y=30,W=1,h=2)
     BevelUpBR=(X=18,Y=30,W=2,h=2)
     BevelUpArea=(X=8,Y=20,W=1,h=1)
     MiscBevelTL(0)=(Y=17,W=3,h=3)
     MiscBevelTL(1)=(W=3,h=3)
     MiscBevelTL(2)=(Y=33,W=2,h=2)
     MiscBevelT(0)=(X=3,Y=17,W=116,h=3)
     MiscBevelT(1)=(X=3,W=116,h=3)
     MiscBevelT(2)=(X=2,Y=33,W=1,h=2)
     MiscBevelTR(0)=(X=119,Y=17,W=3,h=3)
     MiscBevelTR(1)=(X=119,W=3,h=3)
     MiscBevelTR(2)=(X=11,Y=33,W=2,h=2)
     MiscBevelL(0)=(Y=20,W=3,h=10)
     MiscBevelL(1)=(Y=3,W=3,h=10)
     MiscBevelL(2)=(Y=36,W=2,h=1)
     MiscBevelR(0)=(X=119,Y=20,W=3,h=10)
     MiscBevelR(1)=(X=119,Y=3,W=3,h=10)
     MiscBevelR(2)=(X=11,Y=36,W=2,h=1)
     MiscBevelBL(0)=(Y=30,W=3,h=3)
     MiscBevelBL(1)=(Y=14,W=3,h=3)
     MiscBevelBL(2)=(Y=44,W=2,h=2)
     MiscBevelB(0)=(X=3,Y=30,W=116,h=3)
     MiscBevelB(1)=(X=3,Y=14,W=116,h=3)
     MiscBevelB(2)=(X=2,Y=44,W=1,h=2)
     MiscBevelBR(0)=(X=119,Y=30,W=3,h=3)
     MiscBevelBR(1)=(X=119,Y=14,W=3,h=3)
     MiscBevelBR(2)=(X=11,Y=44,W=2,h=2)
     MiscBevelArea(0)=(X=3,Y=20,W=116,h=10)
     MiscBevelArea(1)=(X=3,Y=3,W=116,h=10)
     MiscBevelArea(2)=(X=2,Y=35,W=9,h=9)
     ComboBtnUp=(X=20,Y=60,W=12,h=12)
     ComboBtnDown=(X=32,Y=60,W=12,h=12)
     ComboBtnDisabled=(X=44,Y=60,W=12,h=12)
     ColumnHeadingHeight=13
     HLine=(X=5,Y=78,W=1,h=2)
     TabSelectedL=(X=4,Y=80,W=3,h=17)
     TabSelectedM=(X=7,Y=80,W=1,h=17)
     TabSelectedR=(X=55,Y=80,W=2,h=17)
     TabUnselectedL=(X=57,Y=80,W=3,h=15)
     TabUnselectedM=(X=60,Y=80,W=1,h=15)
     TabUnselectedR=(X=109,Y=80,W=2,h=15)
     TabBackground=(X=4,Y=79,W=1,h=1)
     SliderBarBox=(X=4,Y=16,W=16,h=16)
     SBUpUp=(X=20,Y=16,W=12,h=10)
     SBUpDown=(X=32,Y=16,W=12,h=10)
     SBUpDisabled=(X=44,Y=16,W=12,h=10)
     SBDownUp=(X=20,Y=26,W=12,h=10)
     SBDownDown=(X=32,Y=26,W=12,h=10)
     SBDownDisabled=(X=44,Y=26,W=12,h=10)
     SBLeftUp=(X=20,Y=48,W=10,h=12)
     SBLeftDown=(X=30,Y=48,W=10,h=12)
     SBLeftDisabled=(X=40,Y=48,W=10,h=12)
     SBRightUp=(X=20,Y=36,W=10,h=12)
     SBRightDown=(X=30,Y=36,W=10,h=12)
     SBRightDisabled=(X=40,Y=36,W=10,h=12)
     SBBackground=(X=4,Y=79,W=1,h=1)
     Size_TabAreaHeight=15.000000
     Size_TabAreaOverhangHeight=2.000000
     Size_TabSpacing=20.000000
     Size_TabXOffset=1.000000
     Pulldown_ItemHeight=16.000000
     Pulldown_VBorder=4.000000
     Pulldown_HBorder=3.000000
     Pulldown_TextBorder=9.000000
}
