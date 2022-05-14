//==========================================================================
// 
// FILE:			UDukeLookAndFeel.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Extensive revision of LookAndFeel
// 
// NOTES:			Based off of UDukeBlueLookAndFeel initially to see if 
//					the existing UT's UI could be overridden easily. Could 
//					be broken off as a sub-class of UWindowLookAndFeel for
//					conformity but kept it like this for simplicity.
//
//					TLW: TODO: The sounds in here are just placeholders til the new
//					ones are provided.
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeLookAndFeel expands UDukeBlueLookAndFeel
	config(user);

// Since they are small, load them with DukeLookAndFeel to keep them around.
#exec AUDIO IMPORT FILE="Sounds\a_generic\MenuItemA005.wav" GROUP="LookAndFeel" NAME=MenuItemSelect
#exec AUDIO IMPORT FILE="Sounds\a_generic\MenuItemA010.wav" GROUP="LookAndFeel" NAME=MenuItemHighlight
#exec AUDIO IMPORT FILE="Sounds\a_generic\MenuVarA223.wav"  GROUP="LookAndFeel" NAME=SubMenuOpen
#exec AUDIO IMPORT FILE="Sounds\a_generic\MenuSel0158.wav"  GROUP="LookAndFeel" NAME=SubMenuClose
#exec AUDIO IMPORT FILE="Sounds\a_generic\MenuVarA215.wav"  GROUP="LookAndFeel" NAME=SubMenuHighlight
#exec AUDIO IMPORT FILE="Sounds\a_generic\MenuType04.wav"   GROUP="LookAndFeel" NAME=ValidTextTyped
#exec AUDIO IMPORT FILE="Sounds\a_generic\MenuVar0005.wav" GROUP="LookAndFeel" NAME=SystemActivated


const iBevelNormal  	 	= 0;		//	0 = an "outie"
const iBevelInverted 	 	= 1;		//	1 = an "innie"
const iBevelFlushRight 	 	= 2;		//	2 = bevel with right side not rounded 
const iBevelTextBoxSelected	= 3;		//	3 = Edit Text Selected 
const iBevelTextBox			= 4;		//	4 = Edit Text

const TEX_TOP_MAX			= 30;		//	should only be 25 textures max for this effect

const NUM_SCAN_LINES		= 7;		//  Number of fake computer scan line fade to draw in client areas

var() Region ClientArea;				//	New region that defines the Window Frame Textures client area
var() Region ItemSelectedColor;			//								ComboList, itemselected background

var() Region CheckBox_Empty;			//	checkbox is drawn differently than buttons, like supers are
var() Region CheckBox_Checked;			//		"

//var() Region EditTextBox;
//var() Region EditTextBox_Selected;

var() config color	 colorTextSelected;		//	Setable text selected color
var() config color	 colorTextUnselected;	//	  "          unselected

var(LookAndFeelFrame) int iHeightOfTitleBar;	//Height of title bar, inside FrameT/TL/TR
var() String strWindowTopTexture[30];	//TEX_TOP_MAX];	
var	  Texture texWindowTop[30];			//TEX_TOP_MAX];
var   Texture texWindowSprite;			//"thing" to draw around the edges of the frame	
var() String strSpriteFrameTexture;		//and the name of the edge thingy

/* Framed Window Drawing Function */
function FW_DrawWindowFrame(UWindowFramedWindow winFramedWindow, Canvas C, optional float fAnimAlpha)
{
	local float fAnimPercentage;
	local float fFadeDist;
	local bool bFrameWindowAnim;
	local vector P1, P2;
	local color LineColor, OrigColor;

	bFrameWindowAnim = (winFramedWindow.iAnimationFrameNum != 0);
	if (bFrameWindowAnim)  
	{
		winFramedWindow.iAnimationFrameNum--;

		// Quick fade in animation for the frame.
		fAnimPercentage = winFramedWindow.iAnimationFrameNum / 
						  float(winFramedWindow.default.iAnimationFrameNum);
		fFadeDist = 1.0 - Sin( (Pi * 0.5) * fAnimPercentage);
		Super.FW_DrawWindowFrame(winFramedWindow, C, fFadeDist * vecGUIWindowsHSV.z);
	}
	else
		Super.FW_DrawWindowFrame(winFramedWindow, C, fAnimAlpha);

	if (bFrameWindowAnim)
	{
		LineColor.R = colorGUIWindows.R * (1.0 - fAnimPercentage);
		LineColor.G = colorGUIWindows.G * (1.0 - fAnimPercentage);
		LineColor.B = colorGUIWindows.B * (1.0 - fAnimPercentage);
	
		// Draw the sprites that trace the edges of the windowframe.
		if(texWindowSprite == None)
			texWindowSprite = Texture( DynamicLoadObject(strSpriteFrameTexture, class'Texture') );
					
		P2.X = winFramedWindow.Root.WinWidth;
		P2.Y = winFramedWindow.Root.WinHeight;
		OrigColor = C.DrawColor;
		C.DrawColor = LineColor;

		/*
		// Draw the one that runs along the top of the frame.
		P1.X = C.OrgX + fAnimPercentage * winFramedWindow.WinWidth;
		P1.Y = C.OrgY;
		C.DrawLine(P1, P2);
		
		// Draw the one that runs along the bottom of the frame.
		P1.X = C.OrgX + ((1.0f - fAnimPercentage) * winFramedWindow.WinWidth);
		P1.Y = C.OrgY + winFramedWindow.WinHeight;
		C.DrawLine(P1, P2);

		// Draw the one that runs along the left side of the frame.
		P1.X = C.OrgX;
		P1.Y = C.OrgY + ((1.0f - fAnimPercentage) * winFramedWindow.WinHeight);
		C.DrawLine(P1, P2);

		// Draw the one that runs along the right side of the frame.
		P1.X = C.OrgX + winFramedWindow.WinWidth;
		P1.Y = C.OrgY + fAnimPercentage * winFramedWindow.WinHeight;
		C.DrawLine(P1, P2);
		*/

		C.DrawColor = OrigColor;
	}
}

function SetTextColors(color colorNew)
{
	Super.SetTextColors(colorNew);

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
}

function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C)
{
	//Do nothing
}

simulated function PlayMenuSound(UWindowWindow W, MenuSound S, optional float fVolume)
{
	local sound sndMenu;	//defaults to None
	
//	Log("TIM: Attempting to play MenuSound #" $ S);
	switch(S)
	{
		case MS_MenuPullDown:	sndMenu = sound'SubMenuOpen';		break;
		case MS_WindowClose:										
		case MS_MenuCloseUp: 	sndMenu = sound'SubMenuClose';	break;
		case MS_MenuItem:		sndMenu = sound'MenuItemHighlight';	break;
	//	case MS_WindowOpen:		sndMenu = sound'MenuItemSelect';	break;
		case MS_ChangeTab:		sndMenu = sound'SubMenuHighlight';	break;

		case MS_WindowSystemActivated :		sndMenu = sound'SystemActivated';	break;
		case MS_WindowSystemDeActivated :	sndMenu = sound'SystemActivated';	break;

		case MS_SubMenuOpen:	sndMenu = sound'SubMenuOpen';		break;
		case MS_SubMenuClose: 	sndMenu = sound'SubMenuClose';	break;
		case MS_SubMenuItem:	sndMenu = sound'SubMenuHighlight';	break;

		case MS_SliderItem:		sndMenu = sound'SubMenuHighlight';	break;

		case MS_KeyPress :		sndMenu = sound'ValidTextTyped';	break;	
	}
	
	if(sndMenu != None)  {

		//If a volume is passed in, pass it along, otherwise use the default
		if(fVolume > 0.0f)
			W.GetPlayerOwner().PlaySound(sndMenu, SLOT_Interface, fVolume);	
		else
			W.GetPlayerOwner().PlaySound(sndMenu);
	}
}


function DrawTitleAndStatus(UWindowFramedWindow W, Canvas C, float fAnimAlpha)
{
	C.DrawColor = FrameActiveTitleColor;
	C.Font = W.Root.Fonts[W.F_LargeBold];
	C.Style = 3;
	
	if(fAnimAlpha > 0.0f)  {
		C.DrawColor.R = BYTE(C.DrawColor.R * fAnimAlpha);
		C.DrawColor.G = BYTE(C.DrawColor.G * fAnimAlpha);
		C.DrawColor.B = BYTE(C.DrawColor.B * fAnimAlpha);
	}
	W.ClipTextWidth(C, 
					FrameTitleX, FrameTitleY, 
					W.WindowTitle, W.WinWidth - FrameTitleX
	);

	if(W.bStatusBar) 
	{
		C.Font = W.Root.Fonts[W.F_Normal];
		C.DrawColor = DefaultTextColor;
		if(fAnimAlpha > 0.0f)  {
			C.DrawColor.R = BYTE(C.DrawColor.R * fAnimAlpha);
			C.DrawColor.G = BYTE(C.DrawColor.G * fAnimAlpha);
			C.DrawColor.B = BYTE(C.DrawColor.B * fAnimAlpha);
		}

		W.ClipTextWidth(C, 
						FrameTitleX, W.WinHeight - iHeightOfTitleBar + FrameTitleY, 
						W.StatusBarText, W.WinWidth - FrameTitleX
		);

		C.DrawColor.r = 255;
		C.DrawColor.g = 255;
		C.DrawColor.b = 255;
	}
}

function DrawClientArea(UWindowClientWindow W, Canvas C)
{
	local float fAnimAlpha;
	local UWindowWindow winToCheck;
	local UWindowFramedWindow winFramedWindow;

	// Keep walking the window heirarchy until we find the UWindowFramedWindow, for the scanline drawing.
	winToCheck = W;
	do  {

		winFramedWindow = UWindowFramedWindow(winToCheck.ParentWindow);

		if ( winFramedWindow != None)
		{ 
			if (winFramedWindow.iAnimationFrameNum != 0)  
			{
				fAnimAlpha = 0.45 - (0.45 * (winFramedWindow.iAnimationFrameNum / float(winFramedWindow.default.iAnimationFrameNum)));
//				fAnimAlpha *= vecGUIWindowsHSV.z;
			}
			break;	//found the winFrame, kick out
		}
			
		winToCheck = winToCheck.ParentWindow;
	}  until(winToCheck == None);

	if (fAnimAlpha == 0.0) fAnimAlpha = 0.45;

	//Fill in the client area, with the appropriate fanimalpha, or 0.0 the default
	if ( !W.bNoClientTexture )
        W.DrawStretchedTextureSegment(	C, 
	    								0, 0, 
		    							W.WinWidth, W.WinHeight, 
			    						ClientArea.X, ClientArea.Y, 
				    					ClientArea.W, ClientArea.H, 
					    				W.GetLookAndFeelTexture(),
						    			fAnimAlpha
	    );

	// Draw the computer scanlines.
	if ((winFramedWindow != None) && (!W.bNoScanLines))
		DrawScanLines(winFramedWindow, C, fAnimAlpha);
}

function DrawScanLines(UWindowFramedWindow winFrameWin, Canvas C, float fAnimAlpha)
{
	local INT i;
	local float fX,	fWidth;
	local float fY,	fYMax;
	local float fLineAlpha,	fAlphaIncrement;
	local float OldOrgY;

	fX = 0;	//FrameL.W;
	fWidth = winFrameWin.WinWidth - FrameR.W - FrameL.W;
	
	OldOrgY = C.OrgY;
	fY = winFrameWin.fScanlineFrame;	// + FrameT.H;
	fYMax = winFrameWin.WinHeight - FrameT.H - FrameB.H;
	if (winFrameWin.ClientArea.IsA('UWindowScrollingDialogClient'))
		C.SetOrigin(C.OrgX, OldOrgY + UWindowScrollingDialogClient(winFrameWin.ClientArea).VertSB.Pos);

	fAlphaIncrement = Pi / (NUM_SCAN_LINES * 2.05f);
	fLineAlpha = Sin(fAlphaIncrement) * 0.333333f;
	for(i = 0; i < NUM_SCAN_LINES; i++)  
	{
		// Draw a scanline.. this should be done through Draw2Dline..
		// but if done with DrawStretchedTextureSegment() it gets colored, gets 
		// coords translated and alpha effects.
		winFrameWin.DrawStretchedTextureSegment(
			C, fX, fY, fWidth, 1, BevelUpArea.X, BevelUpArea.Y, BevelUpArea.W, 1, 
			winFrameWin.GetLookAndFeelTexture(), fLineAlpha
		);	

		// Increment by three, (two was too small) to create an interlacing look.
		fY += 3;
		fAlphaIncrement += Pi / (NUM_SCAN_LINES * 2.05f);
		fLineAlpha = Sin(fAlphaIncrement) * 0.333333f;

		if(	fY >= fYMax )
		 	fY = 0;
	}
	
	winFrameWin.fScanlineFrame += (winFrameWin.GetLevel().TimeSeconds - winFrameWin.fLastDrawTime) * 64.0f;
	winFrameWin.fLastDrawTime = winFrameWin.GetLevel().TimeSeconds;
	if(winFrameWin.fScanlineFrame >= winFrameWin.WinHeight - FrameB.H - FrameT.H)
		 winFrameWin.fScanlineFrame = 0;

	C.SetOrigin(C.OrgX, OldOrgY);
}

function DrawWindowFrameTop(UWindowFramedWindow W, Canvas C, Texture T, float fAnimAlpha)
{
	local int i;
	local Region R;

	if(eFrameType == eWINDOW_FRAME_TYPE_TILE_TOP)  {
		R = FrameTL;
		W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y+1, R.W, R.H, T, fAnimAlpha );
	
		//TLW: Added ability to tile one texture across the top of the frame
		W.DrawHorizTiledPieces( C, 
								FrameTL.W, 0, 
								W.WinWidth - FrameTL.W - FrameTR.W, FrameT.H, 
								FrameT, T,					//Texture to use	
								fAnimAlpha
		//						TexRegion(None), None, None, None, //Place holders for other textureRegions
		);

		R = FrameTR;
		W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, 0, R.W, R.H, R.X, R.Y+1, R.W, R.H, T, fAnimAlpha );
	}
	else  {
		//check to see if texture is loaded
		if(texWindowTop[0] == None)  {
		
			for(i = 0; i < TEX_TOP_MAX; i++)  {
				if(IsValidString(strWindowTopTexture[i]))
					texWindowTop[i] = Texture( DynamicLoadObject(strWindowTopTexture[i], class'Texture') );
			}
		}
	
		R.X = 0;
		R.Y = 0;
		R.W = texWindowTop[0].USize;
		R.H = texWindowTop[0].VSize;
		W.DrawHorizTiledPieces( C, 
								0, 0, 
								W.WinWidth, iHeightOfTitleBar, 
								R, 
								texWindowTop[0],
								fAnimAlpha 
		);
	
		//Draw the top of the frame that isn't in the header/title bar
		W.DrawStretchedTextureSegment( 	C, 
										0, iHeightOfTitleBar, 
										FrameTL.W, FrameTL.H - iHeightOfTitleBar, 
										FrameTL.X, FrameTL.Y + iHeightOfTitleBar, 
										FrameTL.W, FrameTL.H - iHeightOfTitleBar, 
										T,
										fAnimAlpha 
		);
		W.DrawStretchedTextureSegment( 	C, 
										FrameTL.W, iHeightOfTitleBar, 
										W.WinWidth - FrameTL.W - FrameTR.W, FrameT.H - iHeightOfTitleBar, 
										FrameT.X, FrameT.Y + iHeightOfTitleBar, 
										FrameT.W, FrameT.H - iHeightOfTitleBar, 
										T,
										fAnimAlpha 
		);
		W.DrawStretchedTextureSegment( 	C, 
										W.WinWidth - FrameTR.W, iHeightOfTitleBar, 
										FrameTR.W, FrameTR.H - iHeightOfTitleBar, 
										FrameTR.X, FrameTR.Y + iHeightOfTitleBar, 
										FrameTR.W, FrameTR.H - iHeightOfTitleBar, 
										T,
										fAnimAlpha 
		);
	}
}


function Checkbox_SetupSizes(UWindowCheckbox W, Canvas C)
{
	//TLW: Call super's super, so we don't bother changing textures and the like.. 
	Super(UWindowLookAndFeel).Checkbox_SetupSizes(W, C);
}

function bool Checkbox_Draw(UWindowCheckbox W, Canvas C)
{
	local Region R;
	local Color colorOld;
	local float fDeltaX,
				fDeltaY;
	
	if(W.bChecked)
		R = CheckBox_Checked;
	else
		R = CheckBox_Empty;

	if(W.bStretched)  {
		fDeltaX = W.WinWidth;
		fDeltaY = W.WinHeight;
	}
	else  {
		fDeltaX = R.W;
		fDeltaY = R.H;
	}

	W.DrawStretchedTextureSegment(  C, 
									W.ImageX, W.ImageY, 
									fDeltaX, fDeltaY, 
									R.X, R.Y, 
									R.W, R.H, 
									W.GetLookAndFeelTexture()
	);

	ClipText(W, C, W.TextX, W.TextY, W.Text, true);
	return true;	//handled the draw, don't call UWindowCheckbox super's paint 
}

function Combo_SetupSizes(UWindowComboControl W, Canvas C)
{
	local float TW, TH,
				fButtonsWidth;

	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, TW, TH);
	
	W.WinHeight = ComboBtnUp.H;	// + MiscBevelT[2].H + MiscBevelB[2].H;
	
	W.TextX = 2;
	W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
	switch(W.Align)  {
		case TA_Left:	break;
		case TA_Right:	W.EditAreaDrawX = 0;	
						W.TextX = W.WinWidth - TW;
						break;
		case TA_Center: W.EditAreaDrawX /= 2;
						W.TextX = (W.WinWidth - TW) / 2;
						break;
	}

	W.EditAreaDrawY = (W.WinHeight - 2) / 2;
	W.TextY = (W.WinHeight - TH) / 2;

	W.EditBox.WinLeft = W.EditAreaDrawX + 2;	// + MiscBevelL[2].W;
	W.EditBox.WinTop =  0;					// MiscBevelT[2].H;
	W.Button.WinWidth = ComboBtnUp.W;

	//Setup default sizes
	W.EditBox.WinWidth = W.EditBoxWidth -	//	 MiscBevelL[2].W - MiscBevelR[2].W - 
						 ComboBtnUp.W;
	W.EditBox.WinHeight = W.WinHeight;		// - MiscBevelT[2].H - MiscBevelB[2].H;
	W.Button.WinLeft = W.EditBox.WinLeft - 2 + W.EditBox.WinWidth;	// - MiscBevelR[2].W;
	W.Button.WinTop = W.EditBox.WinTop;

	if(W.bButtons)
	{
		fButtonsWidth  = SBLeftUp.W + SBRightUp.W;
	
		W.EditBox.WinWidth 	-= fButtonsWidth; 	//	 MiscBevelL[2].W - MiscBevelR[2].W - 
		W.Button.WinLeft 	-= fButtonsWidth;  	// MiscBevelR[2].W - 

		W.LeftButton.WinLeft = 	W.WinWidth - fButtonsWidth;		//	MiscBevelR[2].W - 
		W.RightButton.WinLeft = W.WinWidth - SBRightUp.W;		//	MiscBevelR[2].W - 

		W.LeftButton.WinTop = W.EditBox.WinTop;
		W.RightButton.WinTop = W.EditBox.WinTop;

		W.LeftButton.WinWidth = SBLeftUp.W;
		W.LeftButton.WinHeight = SBLeftUp.H;

		W.RightButton.WinWidth = SBRightUp.W;
		W.RightButton.WinHeight = SBRightUp.H;
	}

	W.Button.WinHeight = W.EditBox.WinHeight;

}

function Combo_Draw(UWindowComboControl W, Canvas C)
{
	W.DrawMiscBevel(C, 
					W.EditAreaDrawX, 0, 
					W.EditBox.WinWidth, W.WinHeight, 
					W.GetLookAndFeelTexture(), 
					iBevelFlushRight
	);
	ClipText(W, C, W.TextX, W.TextY, W.Text);
}

function ComboList_DrawBackground(UWindowComboList W, Canvas C)
{
	local color colorOld;
	
	//TLW: Replaced hard coded texture used for drawing of ComboList's background
	colorOld = 	C.DrawColor;
	C.DrawColor = colorGUIWindows;	
	W.DrawUpBevel(	C, 
					0, -1, //move up one outside the window, so the frame overlaps
					W.WinWidth, W.WinHeight, 
					W.GetLookAndFeelTexture(),
					1.0f,
					true
	);
	C.DrawColor = colorOld;
}

function List_DrawItem(UWindowListBox List, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected)
{
	local Color colorOld;
	colorOld = C.DrawColor;
		
	if(bSelected)  {
		List.DrawStretchedTextureSegment( 	C, 
											X, Y, 
											W, H, 
											ItemSelectedColor.X, ItemSelectedColor.Y, 
											ItemSelectedColor.W, ItemSelectedColor.H, 
											List.GetLookAndFeelTexture(),
											1.0f
		);
		C.DrawColor = colorTextSelected;
	}
	else
		C.DrawColor = colorTextSelected;
	
	List.ClipText(C, X, Y, Text);
	
	C.DrawColor = colorOld;
}

function ComboList_DrawItem(UWindowComboList Combo, Canvas C, float X, float Y, float W, float H, string Text, bool bSelected)
{
	local Color colorOld;
	colorOld = C.DrawColor;
		
	//TLW: Replaced hard coded texture used for drawing of ComboList's items
	if(bSelected)  {
		//Combo.DrawMiscBevel(C, X, Y, W, H, Combo.GetLookAndFeelTexture(), iBevelInverted);
		Combo.DrawStretchedTextureSegment( 	C, 
											X, Y, 
											W, H, 
											ItemSelectedColor.X, ItemSelectedColor.Y, 
											ItemSelectedColor.W, ItemSelectedColor.H, 
											Combo.GetLookAndFeelTexture()
		);
		C.DrawColor = colorTextSelected;
	}
	else
		C.DrawColor = colorTextUnselected;
	
	Combo.ClipText(C, X + Combo.TextBorder + 2, Y + 3, Text);
	
	C.DrawColor = colorOld;
}

function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	local int iBevelType;
	
	if(W.EditBox.bHasKeyboardFocus)
		iBevelType = iBevelTextBoxSelected;
	else
		iBevelType = iBevelTextBox;

	//Skip up to super's.Super drawing of EditBox, so we don't draw the miscbevel done below
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0, W.EditBoxWidth, W.WinHeight, W.GetLookAndFeelTexture(), iBevelType);	//, 1.0f);
	Super(UWindowLookAndFeel).Editbox_Draw(W, C);
}

function DrawOutline( UWindowControlFrame W, Canvas C, int width, int height, int border, float alpha )
{
	// Top
    W.DrawStretchedTexture(C, border, 0, width-2*border, border, Texture'WhiteTexture', alpha ); 
	// Left
    W.DrawStretchedTexture(C, 0, 0, border, height, Texture'WhiteTexture', alpha ); 
	// Right
    W.DrawStretchedTexture(C, width-border, 0, width, height, Texture'WhiteTexture', alpha ); 
	// Bottom
    W.DrawStretchedTexture(C, width, height-border, width-2*border, border, Texture'WhiteTexture', alpha );
}

function ControlFrame_Draw( UWindowControlFrame W, Canvas C )
{
//	local int iBevelType;

//	if(W.bHasKeyboardFocus)
//		iBevelType = iBevelTextBoxSelected;
//	else
//		iBevelType = iBevelTextBox;

	//Call super's.super for background draw
//	Super(UWindowLookAndFeel).ControlFrame_Draw(W, C);
	W.DrawMiscBevel(C, 0, 0, W.WinWidth, W.WinHeight, W.GetLookAndFeelTexture(), iBevelInverted);

//	DrawOutline( W,C,W.WinWidth,W.WinHeight,1,1.0 );
}

function SB_VDraw(UWindowVScrollbar W, Canvas C)
{
	local Region R;
	local Texture T;

	T = W.GetLookAndFeelTexture();

	//Draw background of vertical slider first
	R = SBBackground;
	W.DrawStretchedTextureSegment( 	C, 
									1, -1,		//Overlap a pixel with the bevel of the frame 
									W.WinWidth, W.WinHeight + 2, 
									R.X, R.Y, 
									R.W, R.H, 
									T
	);

	//then if not disabled(???), draw the pos indicator	
	if(!W.bDisabled)  
		DrawBevelByTilingVert(W, 
							  C, 
							  1, W.ThumbStart - 2,	//Overlap up and down button
							  SBPosIndicator.W, W.ThumbHeight + 4,
							  SBPosIndicator, T,
							  5, 5		//size of top and bottom bits
		);
/*		W.DrawStretchedTextureSegment( 	C, 
										0, W.ThumbStart,
										SBPosIndicator.W, W.ThumbHeight,
										SBPosIndicator.X, SBPosIndicator.Y,
										SBPosIndicator.W, SBPosIndicator.H,
										T
		); 	
*/
	//	W.DrawUpBevel( C, 0, W.ThumbStart, SBPosIndicator.W,	W.ThumbHeight, T);
	
}

function SB_HDraw(UWindowHScrollbar W, Canvas C)
{
	local Region R;
	local Texture T;

	T = W.GetLookAndFeelTexture();

	//Draw background of horizontal slider first
	R = SBBackground;
	W.DrawStretchedTextureSegment( 	C, 
									-1, 1, 		//Overlap a pixel with the bevel of the frame
									W.WinWidth + 2, W.WinHeight, 
									R.X, R.Y, 
									R.W, R.H, 
									T
	);
	
	//then if not disabled(???), draw the pos indicator	
	if(!W.bDisabled) 
		DrawBevelByTilingHor(W, 
							 C, 
							 W.ThumbStart - 2, 1,	//Overlap left and right button
							 W.ThumbWidth + 4, SBPosIndicator.H,
							 SBPosIndicator, T,
							 5, 5		//size of left and right bits
		);
/*		W.DrawStretchedTextureSegment( 	C, 
										W.ThumbStart, 0,
										W.ThumbWidth, SBPosIndicator.H,
										SBPosIndicator.X, SBPosIndicator.Y,
										SBPosIndicator.W, SBPosIndicator.H,
										T
		); 	
*/
	//	W.DrawUpBevel( C, W.ThumbStart, 0, W.ThumbWidth, SBPosIndicator.H, T);
	
}


function Button_DrawSmallButton(UWindowSmallButton B, Canvas C)
{
	local int iButtonState;

	if(B.bMouseDown)  		iButtonState = iBevelInverted;	
//	else if(B.bDisabled)	iButtonState = iBevelDisabled;
	else  					iButtonState = iBevelNormal;	
	
	B.DrawMiscBevel(C, 0, 0, B.WinWidth, B.WinHeight, B.GetLookAndFeelTexture(), iButtonState);
}

function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C)
{
    C.Style = 1;
    W.DrawStretchedTexture(C, 4,            0,             W.WinWidth-8,  4,           Texture'WhiteTexture',0.9 ); //Top
    W.DrawStretchedTexture(C, 0,            0,             4,           W.WinHeight, Texture'WhiteTexture',0.9 ); //Left
    W.DrawStretchedTexture(C, W.WinWidth-4, 0,             W.WinWidth,  W.WinHeight, Texture'WhiteTexture',0.8 ); //Right
    W.DrawStretchedTexture(C, 4,            W.WinHeight-4, W.WinWidth-8,  4,           Texture'WhiteTexture',0.8 ); //Bottom
}

function Menu_DrawPulldownMenuItem( UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected )
{ 
    local Color colorOld;

    if( Item.Caption == "-" )
	{
		M.DrawStretchedTexture(C, X, Y+5, W, 2, Texture'WhiteTexture');
		return;
	}

    if( bSelected )
	{
		M.DrawStretchedTexture( C, X,     Y,     W    , 16,     Texture'WhiteTexture', 0.5 );
        M.DrawStretchedTexture( C, X + 4, Y + 4, W - 4, 16 - 4, Texture'BlackTexture' );
	}

	colorOld = C.DrawColor;

    if ( Item.bDisabled )
    {
        C.DrawColor = colorTextUnselected;
	}    

    M.ClipText( C, X + M.TextBorder + 2, Y + 3, Item.Caption, True );	

    C.DrawColor = colorOld;
}

function Tab_DrawTab( UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, float X, float Y, float W, float H, string Text, bool bShowText )
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
		C.DrawColor = colorTextSelected;

		if(bShowText)
		{
			Tab.TextSize(C, Text, TW, TH);
			Tab.ClipText(C, X + (W-TW)/2, Y + 4, Text, True);
		}
	}
}

defaultproperties
{
     ClientArea=(X=6,Y=24,W=2,h=2)
     ItemSelectedColor=(X=49,Y=86,W=4,h=4)
     CheckBox_Empty=(X=23,Y=38,W=12,h=12)
     CheckBox_Checked=(X=36,Y=38,W=12,h=12)
     colorTextSelected=(R=181,G=181,B=181)
     colorTextUnselected=(R=74,G=74,B=74)
     iHeightOfTitleBar=18
     strWindowTopTexture(0)="DukeLookAndFeel.TitleBar.submbar00"
     strWindowTopTexture(1)="DukeLookAndFeel.TitleBar.submbar01"
     strWindowTopTexture(2)="DukeLookAndFeel.TitleBar.submbar02"
     strWindowTopTexture(3)="DukeLookAndFeel.TitleBar.submbar03"
     strWindowTopTexture(4)="DukeLookAndFeel.TitleBar.submbar04"
     strWindowTopTexture(5)="DukeLookAndFeel.TitleBar.submbar05"
     strWindowTopTexture(6)="DukeLookAndFeel.TitleBar.submbar06"
     strWindowTopTexture(7)="DukeLookAndFeel.TitleBar.submbar07"
     strWindowTopTexture(8)="DukeLookAndFeel.TitleBar.submbar08"
     strWindowTopTexture(9)="DukeLookAndFeel.TitleBar.submbar09"
     strWindowTopTexture(10)="DukeLookAndFeel.TitleBar.submbar10"
     strWindowTopTexture(11)="DukeLookAndFeel.TitleBar.submbar11"
     strWindowTopTexture(12)="DukeLookAndFeel.TitleBar.submbar12"
     strWindowTopTexture(13)="DukeLookAndFeel.TitleBar.submbar13"
     strWindowTopTexture(14)="DukeLookAndFeel.TitleBar.submbar14"
     strWindowTopTexture(15)="DukeLookAndFeel.TitleBar.submbar15"
     strWindowTopTexture(16)="DukeLookAndFeel.TitleBar.submbar16"
     strWindowTopTexture(17)="DukeLookAndFeel.TitleBar.submbar17"
     strWindowTopTexture(18)="DukeLookAndFeel.TitleBar.submbar18"
     strWindowTopTexture(19)="DukeLookAndFeel.TitleBar.submbar19"
     strWindowTopTexture(20)="DukeLookAndFeel.TitleBar.submbar20"
     strWindowTopTexture(21)="DukeLookAndFeel.TitleBar.submbar21"
     strWindowTopTexture(22)="DukeLookAndFeel.TitleBar.submbar22"
     strWindowTopTexture(23)="DukeLookAndFeel.TitleBar.submbar23"
     strWindowTopTexture(24)="DukeLookAndFeel.TitleBar.submbar24"
     strWindowTopTexture(25)="DukeLookAndFeel.TitleBar.submbar25"
     strWindowTopTexture(26)="DukeLookAndFeel.TitleBar.submbar26"
     strWindowTopTexture(27)="DukeLookAndFeel.TitleBar.submbar27"
     strWindowTopTexture(28)="DukeLookAndFeel.TitleBar.submbar28"
     strWindowTopTexture(29)="DukeLookAndFeel.TitleBar.submbar29"
     strSpriteFrameTexture="DukeLookAndFeel.WinFrameEffects.Ball"
     FrameSBL=(Y=122,W=6,h=6)
     FrameSB=(Y=122,h=6)
     FrameSBR=(X=103,Y=108,W=25,h=20)
     CloseBoxUp=(X=8,Y=77,W=12,h=12)
     CloseBoxDown=(X=21,Y=77,W=12,h=12)
     CloseBoxOffsetX=20
     CloseBoxOffsetY=5
     FrameTL=(W=16,h=24)
     FrameT=(X=73,W=4,h=24)
     FrameTR=(X=112,W=16,h=24)
     eFrameType=eWINDOW_FRAME_TYPE_TILE_TOP
     FrameL=(W=7)
     FrameR=(X=117,W=11)
     FrameBL=(Y=122,W=6,h=6)
     FrameB=(Y=122,h=6)
     FrameBR=(X=122,Y=122,W=6,h=6)
     FrameActiveTitleColor=(R=181,G=181,B=181)
     FrameInactiveTitleColor=(R=74,G=74,B=74)
     HeadingActiveTitleColor=(R=109,G=109,B=109)
     HeadingInActiveTitleColor=(R=54,G=54,B=54)
     colorGUIWindows=(R=121,G=206,B=125)
     vecGUIWindowsHSV=(X=0.341176,Y=0.407843,Z=0.807843)
     FrameTitleX=16
     FrameTitleY=4
     BevelUpTL=(X=8,Y=38)
     BevelUpT=(Y=38)
     BevelUpTR=(X=13,Y=38)
     BevelUpL=(X=8,Y=42)
     BevelUpR=(X=13,Y=42)
     BevelUpBL=(X=8,Y=48)
     BevelUpB=(Y=48)
     BevelUpBR=(X=13,Y=48)
     BevelUpArea=(X=10,Y=40,W=2,h=8)
     MiscBevelTL(0)=(X=8,Y=26)
     MiscBevelTL(1)=(X=28,Y=26)
     MiscBevelTL(2)=(X=94,Y=62)
     MiscBevelTL(3)=(X=94,Y=43,W=3,h=3)
     MiscBevelTL(4)=(X=95,Y=26,W=2,h=2)
     MiscBevelT(0)=(X=16,Y=26,W=1)
     MiscBevelT(1)=(X=32,Y=26,W=1)
     MiscBevelT(2)=(X=96,Y=62)
     MiscBevelT(3)=(X=98,Y=43,W=1,h=3)
     MiscBevelT(4)=(X=98,Y=26,W=1,h=2)
     MiscBevelTR(0)=(X=24,Y=26)
     MiscBevelTR(1)=(X=44,Y=26)
     MiscBevelTR(2)=(X=100,Y=62)
     MiscBevelTR(3)=(X=112,Y=43,W=3,h=3)
     MiscBevelTR(4)=(X=112,Y=26,W=2,h=2)
     MiscBevelL(0)=(X=8,Y=32,h=1)
     MiscBevelL(1)=(X=28,Y=32,h=1)
     MiscBevelL(2)=(X=94,Y=64)
     MiscBevelL(3)=(X=94,Y=46,W=3,h=1)
     MiscBevelL(4)=(X=95,Y=28,W=2,h=1)
     MiscBevelR(0)=(X=24,Y=32,h=1)
     MiscBevelR(1)=(X=44,Y=32,h=1)
     MiscBevelR(2)=(X=100,Y=64)
     MiscBevelR(3)=(X=112,Y=46,W=3,h=1)
     MiscBevelR(4)=(X=112,Y=28,W=2,h=1)
     MiscBevelBL(0)=(X=8,Y=34)
     MiscBevelBL(1)=(X=28,Y=34)
     MiscBevelBL(2)=(X=94,Y=74)
     MiscBevelBL(3)=(X=94,Y=58,W=3,h=3)
     MiscBevelBL(4)=(X=95,Y=40,W=2,h=2)
     MiscBevelB(0)=(X=16,Y=34,W=1)
     MiscBevelB(1)=(X=32,Y=34,W=1)
     MiscBevelB(2)=(X=96,Y=74)
     MiscBevelB(3)=(X=98,Y=58,W=1,h=3)
     MiscBevelB(4)=(X=98,Y=40,W=1,h=2)
     MiscBevelBR(0)=(X=24,Y=34)
     MiscBevelBR(1)=(X=44,Y=34)
     MiscBevelBR(2)=(X=100,Y=74)
     MiscBevelBR(3)=(X=112,Y=58,W=3,h=3)
     MiscBevelBR(4)=(X=112,Y=40,W=2,h=2)
     MiscBevelArea(0)=(X=11,Y=29,W=13,h=5)
     MiscBevelArea(1)=(X=31,Y=29,W=13,h=5)
     MiscBevelArea(2)=(X=96,Y=64,W=4,h=10)
     MiscBevelArea(3)=(X=97,Y=46,W=15,h=12)
     MiscBevelArea(4)=(X=97,Y=28,W=15,h=12)
     ComboBtnUp=(X=101,Y=62,W=14,h=14)
     ComboBtnDown=(X=101,Y=77,W=14,h=14)
     ComboBtnDisabled=(X=79,Y=40,W=14,h=14)
     HLine=(X=34,Y=81,W=14,h=5)
     DefaultTextColor=(R=165,G=165,B=165)
     EditBoxTextColor=(R=206,G=165,B=165)
     TabSelectedL=(X=8,Y=92,W=4)
     TabSelectedM=(X=16,Y=92)
     TabSelectedR=(X=56,Y=92,W=4)
     TabUnselectedL=(X=62,Y=92,W=2,h=14)
     TabUnselectedM=(X=92,Y=92,h=14)
     TabUnselectedR=(X=111,Y=92,W=3,h=14)
     TabBackground=(X=6)
     SliderBarBoxOffset=-7
     SliderBarBox=(X=79,Y=70,W=9,h=13)
     SBUpUp=(X=49,Y=26,W=14,h=14)
     SBUpDown=(X=64,Y=26,W=14,h=14)
     SBUpDisabled=(X=79,Y=40,W=14,h=14)
     SBDownUp=(X=49,Y=41,W=14,h=14)
     SBDownDown=(X=64,Y=41,W=14,h=14)
     SBDownDisabled=(X=79,Y=40,W=14,h=14)
     SBLeftUp=(X=49,Y=71,W=14,h=14)
     SBLeftDown=(X=64,Y=71,W=14,h=14)
     SBLeftDisabled=(X=79,Y=40,W=14,h=14)
     SBRightUp=(X=49,Y=56,W=14,h=14)
     SBRightDown=(X=64,Y=56,W=14,h=14)
     SBRightDisabled=(X=79,Y=40,W=14,h=14)
     SBBackground=(X=80,Y=41)
     SBPosIndicator=(W=14,h=14)
}
