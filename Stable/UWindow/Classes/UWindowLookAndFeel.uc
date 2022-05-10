class UWindowLookAndFeel extends UWindowBase
	config(user);

#exec AUDIO IMPORT FILE="Sounds\bigselect.wav" NAME=BigSelect
#exec AUDIO IMPORT FILE="Sounds\littleselect.wav" NAME=LittleSelect
#exec AUDIO IMPORT FILE="Sounds\windowopen.wav" NAME=WindowOpen
#exec AUDIO IMPORT FILE="Sounds\windowclose.wav" NAME=WindowClose

//TLW: new type for choosing different window frame's top drawing routine
enum eWindowFrameTypes
{
	eWINDOW_FRAME_TYPE_DEFAULT,
	
	eWINDOW_FRAME_TYPE_TILE_TOP,
	eWINDOW_FRAME_TYPE_SINGLE_TEXTURE,
	
	eWINDOW_FRAME_TYPE_MAX
};


var() Texture	Active;			// Active widgets, window frames, etc.
var() Texture	Active2;
var() Texture	Active3;
var() Texture	Glow;
var() Texture	Glow2;
var() Texture	Glow3;

var() Texture	Misc;			// Miscellaneous: backgrounds, bevels, etc.

var(LookAndFeelFrame) Region	FrameTL;
var(LookAndFeelFrame) Region	FrameT;
var(LookAndFeelFrame) Region	FrameT2;
var(LookAndFeelFrame) Region	FrameT3;
var(LookAndFeelFrame) Region	FrameTR;

var(LookAndFeelFrame) Region	FrameL;
var(LookAndFeelFrame) Region	FrameR;
	
var(LookAndFeelFrame) Region	FrameBL;
var(LookAndFeelFrame) Region	FrameB;
var(LookAndFeelFrame) Region	FrameBR;

var(LookAndFeelFrame) Region	CloseButtonRegion;
var(LookAndFeelFrame) Region	ResetButtonRegion;

var(LookAndFeelFrame) eWindowFrameTypes eFrameType;

var() config 	  	  Color		FrameActiveTitleColor;
var() config 	  	  Color		FrameInactiveTitleColor;
var() config 		  Color		HeadingActiveTitleColor;
var() config	 	  Color		HeadingInActiveTitleColor;

var() config	 	  Color 	colorGUIWindows;

var(LookAndFeelFrame) int		FrameTitleX;
var(LookAndFeelFrame) int		FrameTitleY;

var(LookAndFeelBevel) Region	BevelUpTL;
var(LookAndFeelBevel) Region	BevelUpT;
var(LookAndFeelBevel) Region	BevelUpTR;

var(LookAndFeelBevel) Region	BevelUpL;
var(LookAndFeelBevel) Region	BevelUpR;
	
var(LookAndFeelBevel) Region	BevelUpBL;
var(LookAndFeelBevel) Region	BevelUpB;
var(LookAndFeelBevel) Region	BevelUpBR;
var(LookAndFeelBevel) Region	BevelUpArea;


var(LookAndFeelBevel) Region	MiscBevelTL[5];
var(LookAndFeelBevel) Region	MiscBevelT[5];
var(LookAndFeelBevel) Region	MiscBevelTR[5];
var(LookAndFeelBevel) Region	MiscBevelL[5];
var(LookAndFeelBevel) Region	MiscBevelR[5];
var(LookAndFeelBevel) Region	MiscBevelBL[5];
var(LookAndFeelBevel) Region	MiscBevelB[5];
var(LookAndFeelBevel) Region	MiscBevelBR[5];
var(LookAndFeelBevel) Region	MiscBevelArea[5];

var() Region	ComboBtnUp;
var() Region	ComboBtnDown;
var() Region	ComboBtnDisabled;

var() int		ColumnHeadingHeight;
var() Region	HLine;

var() config	Color		DefaultTextColor;
var() config	Color		EditBoxTextColor;
var() int		EditBoxBevel;

var(LookAndFeelTab) Region	TabSelectedL;
var(LookAndFeelTab) Region	TabSelectedM;
var(LookAndFeelTab) Region	TabSelectedR;

var(LookAndFeelTab) Region	TabUnselectedL;
var(LookAndFeelTab) Region	TabUnselectedM;
var(LookAndFeelTab) Region	TabUnselectedR;

var(LookAndFeelTab) Region	TabBackground;

var() Region	VSlideTop;
var() Region	VSlideMid;
var() Region	VSlideBot;

var(LookAndFeelSlider) int		SliderBarBoxOffset;
var(LookAndFeelSlider) Region	SliderBarBox;

var(LookAndFeelSlider) Region	SBUpUp;
var(LookAndFeelSlider) Region	SBUpDown;
var(LookAndFeelSlider) Region	SBUpDisabled;

var(LookAndFeelSlider) Region	SBDownUp;
var(LookAndFeelSlider) Region	SBDownDown;
var(LookAndFeelSlider) Region	SBDownDisabled;

var(LookAndFeelSlider) Region	SBLeftUp;
var(LookAndFeelSlider) Region	SBLeftDown;
var(LookAndFeelSlider) Region	SBLeftDisabled;

var(LookAndFeelSlider) Region	SBRightUp;
var(LookAndFeelSlider) Region	SBRightDown;
var(LookAndFeelSlider) Region	SBRightDisabled;

var(LookAndFeelSlider) Region	VScrollUpDown;
var(LookAndFeelSlider) Region	VScrollDownDown;

var(LookAndFeelSlider) Region	VScrollSmallUpDown;
var(LookAndFeelSlider) Region	VScrollSmallDownDown;

var(LookAndFeelSlider) Region	VScrollBevelUpDown;
var(LookAndFeelSlider) Region	VScrollBevelDownDown;

var(LookAndFeelSlider) Region	SBBackground;
var(LookAndFeelSlider) Region	SBPosIndicatorT;
var(LookAndFeelSlider) Region	SBPosIndicatorM;
var(LookAndFeelSlider) Region	SBPosIndicatorB;
var(LookAndFeelSlider) Region	SBPosIndicator;
var(LookAndFeelSlider) Region	SBPosIndicatorSmall;
var(LookAndFeelSlider) Region	SBPosIndicatorBevel;
	
var() Region	ArrowButtonRightUp;
var() Region	ArrowButtonRightDown;
var() Region	ArrowButtonLeftUp;
var() Region	ArrowButtonLeftDown;

var(LookAndFeelTab) float		Size_TabAreaHeight;			// The height of the clickable tab area
var(LookAndFeelTab) float		Size_TabAreaOverhangHeight;	// The height of the tab area overhang
var(LookAndFeelTab) float		Size_TabSpacing;
var(LookAndFeelTab) float		Size_TabXOffset;

var() float		Pulldown_ItemHeight;
var() float		Pulldown_VBorder;
var() float		Pulldown_HBorder;
var() float		Pulldown_TextBorder;

function Texture GetTexture( UWindowFramedWindow W )
{
	return Active;
}

function color GetGUIColor( UWindowWindow W )
{
	local color c;
	return c;
}

function color GetTextColor( UWindowWindow W )
{
	local color c;
	return c;
}

/* Setup Functions */
function Setup();
function FW_DrawWindowFrame( UWindowFramedWindow W, Canvas C );
function Region FW_GetClientArea(UWindowFramedWindow W);
function FrameHitTest FW_HitTest(UWindowFramedWindow W, float X, float Y);
function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C);
function DrawClientArea(UWindowWindow W, Canvas C);
function Combo_GetButtonBitmaps(UWindowComboButton W);
function Combo_SetupLeftButton(UWindowComboLeftButton W);
function Combo_SetupRightButton(UWindowComboRightButton W);
function ComboList_PositionList( UWindowComboList W, Canvas C, out float ListX, out float ListY );
function ComboList_DrawBackground(UWindowComboList W, Canvas C);
function ComboList_DrawItem(UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected);
function SB_SetupUpButton(UWindowSBUpButton W);
function SB_SetupDownButton(UWindowSBDownButton W);
function SB_SetupLeftButton(UWindowSBLeftButton W);
function SB_SetupRightButton(UWindowSBRightButton W);
function SB_VDraw(UWindowVScrollbar W, Canvas C);
function SB_HDraw(UWindowHScrollbar W, Canvas C);
function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText);
function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H);
function Tab_SetupLeftButton(UWindowTabControlLeftButton W);
function Tab_SetupRightButton(UWindowTabControlRightButton W);
function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P);
function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P);
function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C);
function Menu_DrawMenuBarItem(UWindowMenuBar B, UWindowMenuBarItem I, float X, float Y, float W, float H, Canvas C);
function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C);
function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected);
function Button_AutoSize(UWindowSmallButton B, Canvas C);
function Button_DrawSmallButton(UWindowSmallButton B, Canvas C);
function ControlFrame_SetupSizes(UWindowControlFrame W, Canvas C);
function Bevel_DrawSimpleBevel( UWindowWindow W, Canvas C, int X, int Y, int Width, int Height );
function Bevel_DrawSplitHeaderedBevel( UWindowWindow W, Canvas C, int X, int Y, int Width, int Height, string Header1, string Header2 );
function int Bevel_GetSplitLeft();
function int Bevel_GetSplitRight( int Width );
function int Bevel_GetHeaderedTop();
function Grid_DrawGrid( UWindowGrid W, Canvas C );
function Grid_SizeGrid( UWindowGrid W );

simulated function PlayMenuSound(UWindowWindow W, MenuSound S, optional float fVolume);

function SetTextColors(color colorNew)
{
	DefaultTextColor = colorNew;
	EditBoxTextColor = colorNew;
}

final function ClipText(UWindowDialogControl W, Canvas C, float fTextX, float fTextY, out string outText, optional bool bCheckHotkey)
{
	C.DrawColor = GetTextColor(W);
	W.ClipText(C, fTextX, fTextY, outText, bCheckHotkey);
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

function bool Checkbox_Draw(UWindowCheckbox W, Canvas C)
{	return false;	}	//just to make sure the right value is being returned

function Checkbox_ManualDraw( UWindowWindow Win, Canvas C, float X, float Y, float W, float H, bool bChecked );

function ControlFrame_Draw(UWindowControlFrame W, Canvas C)
{
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	
	W.DrawStretchedTexture(C, 0, 0, W.WinWidth, W.WinHeight, Texture'WhiteTexture');
}

//TLW: Added funtion to render bevels, but tiling the middle bits rather than 
//		stretching them horizontally
function DrawBevelByTilingHor(	UWindowWindow W, 
								Canvas C, 
								float DestX, float DestY,
								float DestWidth, float DestHeight,
								Region R, Texture T,
								INT iBevelSizeLeft, INT iBevelSizeRight
)
{
	local Region regRemainder;

	//draw the left side of the beveled area
	W.DrawStretchedTextureSegment(	C, 
									DestX, DestY,  
									iBevelSizeLeft, DestHeight, 
									R.X, R.Y, 
									iBevelSizeLeft, R.H, 
									T
	);

	//draw the right side of the beveled area
	W.DrawStretchedTextureSegment(	C, 
									(DestX + DestWidth) - iBevelSizeRight, DestY, 
									iBevelSizeRight, DestHeight, 
									R.X + R.W - iBevelSizeRight, R.Y, 
									iBevelSizeRight, R.H, 
									T
	);

	//then draw the rest of the beveled area by tiling across
	regRemainder.X = R.X + iBevelSizeLeft;
	regRemainder.Y = R.Y;
	regRemainder.W = R.W - (iBevelSizeLeft + iBevelSizeRight);
	regRemainder.H = R.H;

	W.DrawHorizTiledPieces(	C, 
							DestX + iBevelSizeLeft, DestY, 
							DestWidth - (iBevelSizeLeft + iBevelSizeRight), DestHeight, 
							regRemainder, 
							T
	);
}

function DrawBevelByTilingVert(	UWindowWindow W, 
								Canvas C, 
								float DestX, float DestY,
								float DestWidth, float DestHeight,
								Region R, Texture T,
								INT iBevelSizeTop, INT iBevelSizeBottom
)
{
	local Region regRemainder;

	//draw the top side of the beveled area
	W.DrawStretchedTextureSegment(	C, 
									DestX, DestY,  
									DestWidth, iBevelSizeTop, 
									R.X, R.Y, 
									R.W, iBevelSizeTop, 
									T
	);

	//draw the right side of the beveled area
	W.DrawStretchedTextureSegment(	C, 
									DestX, DestY + DestHeight - iBevelSizeBottom, 
									DestWidth, iBevelSizeBottom, 
									R.X, R.Y + R.H - iBevelSizeBottom, 
									R.W, iBevelSizeBottom, 
									T
	);

	regRemainder.X = R.X;
	regRemainder.Y = R.Y + iBevelSizeTop;
	regRemainder.W = R.W;
	regRemainder.H = R.H - (iBevelSizeTop + iBevelSizeBottom);

	W.DrawVertTiledPieces(	C, 
							DestX, DestY + iBevelSizeTop, 
							DestWidth, DestHeight - (iBevelSizeTop + iBevelSizeBottom), 
							regRemainder, 
							T
	);

}

//TLW: Moved base functionality here
function Checkbox_SetupSizes(UWindowCheckbox W, Canvas C)
{
	local float TW, TH;

	W.TextSize(C, W.Text, TW, TH);
	W.WinHeight = Max(TH+1, 32);
	
	switch(W.Align)
	{
	case TA_Left:
		W.ImageX = W.WinWidth - 32;
		W.TextX = 0;
		break;
	case TA_Right:
		W.ImageX = 0;	
		W.TextX = W.WinWidth - TW;
		break;
	case TA_Center:
		W.ImageX = (W.WinWidth - 32) / 2;
		W.TextX = (W.WinWidth - TW) / 2;
		break;
	}

	W.ImageY = (W.WinHeight - 32) / 2;
	W.TextY = (W.WinHeight - TH) / 2;
}

function Editbox_SetupSizes(UWindowEditControl W, Canvas C)
{
	local float TW, TH;
	local int B;

	B = EditBoxBevel;
		
	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, TW, TH);
	
	W.WinHeight = 12 + MiscBevelT[B].H + MiscBevelB[B].H;
	
	switch(W.Align)
	{
	case TA_Left:
		W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
		W.TextX = 0;
		break;
	case TA_Right:
		W.EditAreaDrawX = 0;	
		W.TextX = W.WinWidth - TW;
		break;
	case TA_Center:
		W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth) / 2;
		W.TextX = (W.WinWidth - TW) / 2;
		break;
	}

	W.EditAreaDrawY = (W.WinHeight - 2) / 2;
	W.TextY = (W.WinHeight - TH) / 2;

	W.EditBox.WinLeft = W.EditAreaDrawX + MiscBevelL[B].W;
	W.EditBox.WinTop = MiscBevelT[B].H;
	W.EditBox.WinWidth = W.EditBoxWidth - MiscBevelL[B].W - MiscBevelR[B].W;
	W.EditBox.WinHeight = W.WinHeight - MiscBevelT[B].H - MiscBevelB[B].H;

}
function Combo_SetupSizes(UWindowComboControl W, Canvas C)
{
	local float TW, TH;

	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, TW, TH);
	
	W.WinHeight = ComboBtnUp.H + MiscBevelT[2].H + MiscBevelB[2].H;
	
	switch(W.Align)
	{
	case TA_Left:
		W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
		W.TextX = 0;
		break;
	case TA_Right:
		W.EditAreaDrawX = 0;	
		W.TextX = W.WinWidth - TW;
		break;
	case TA_Center:
		W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth) / 2;
		W.TextX = (W.WinWidth - TW) / 2;
		break;
	}

	W.EditAreaDrawY = (W.WinHeight - 2) / 2;
	W.TextY = (W.WinHeight - TH) / 2;

	W.EditBox.WinLeft = W.EditAreaDrawX + MiscBevelL[2].W;
	W.EditBox.WinTop = MiscBevelT[2].H;
	W.Button.WinWidth = ComboBtnUp.W;

	if(W.bButtons)
	{
		W.EditBox.WinWidth = W.EditBoxWidth - MiscBevelL[2].W - MiscBevelR[2].W - ComboBtnUp.W - SBLeftUp.W - SBRightUp.W;
		W.EditBox.WinHeight = W.WinHeight - MiscBevelT[2].H - MiscBevelB[2].H;
		W.Button.WinLeft = W.WinWidth - ComboBtnUp.W - MiscBevelR[2].W - SBLeftUp.W - SBRightUp.W;
		W.Button.WinTop = W.EditBox.WinTop;

		W.LeftButton.WinLeft = W.WinWidth - MiscBevelR[2].W - SBLeftUp.W - SBRightUp.W;
		W.LeftButton.WinTop = W.EditBox.WinTop;
		W.RightButton.WinLeft = W.WinWidth - MiscBevelR[2].W - SBRightUp.W;
		W.RightButton.WinTop = W.EditBox.WinTop;

		W.LeftButton.WinWidth = SBLeftUp.W;
		W.LeftButton.WinHeight = SBLeftUp.H;
		W.RightButton.WinWidth = SBRightUp.W;
		W.RightButton.WinHeight = SBRightUp.H;
	}
	else
	{
		W.EditBox.WinWidth = W.EditBoxWidth - MiscBevelL[2].W - MiscBevelR[2].W - ComboBtnUp.W;
		W.EditBox.WinHeight = W.WinHeight - MiscBevelT[2].H - MiscBevelB[2].H;
		W.Button.WinLeft = W.WinWidth - ComboBtnUp.W - MiscBevelR[2].W;
		W.Button.WinTop = W.EditBox.WinTop;
	}
	W.Button.WinHeight = W.EditBox.WinHeight;
}


function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	ClipText(W, C, W.TextX, W.TextY, W.Text);
}
function Combo_Draw(UWindowComboControl W, Canvas C)
{
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0, W.EditBoxWidth, W.WinHeight, Misc, 2);

	ClipText(W, C, W.TextX, W.TextY, W.Text);
}

function HSlider_Draw( UWindowHSliderControl W, Canvas C )
{
}

function HSlider_AutoSize( UWindowHSliderControl W, Canvas C )
{
}

function MessageBox_AutoSize( UWindowMessageBox W, Canvas C )
{
}

defaultproperties
{
     colorGUIWindows=(R=255)
     DefaultTextColor=(G=255)
     EditBoxBevel=2
     SliderBarBoxOffset=-4
     SBPosIndicator=(X=79,Y=55,W=12,H=10)
}
