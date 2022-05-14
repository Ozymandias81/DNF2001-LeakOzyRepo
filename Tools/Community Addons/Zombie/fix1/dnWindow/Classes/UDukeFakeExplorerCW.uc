//==========================================================================
//
// FILE:			UDukeFakeExplorerCW.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Base class for new Duke windowing system's client window
// 
// NOTES:			
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeFakeExplorerCW expands UWindowDialogClientWindow;

//#exec TEXTURE IMPORT NAME=WindowGrey FILE=Textures\Desktop\WindowGrey.pcx GROUP="Window" MIPS=OFF
//#exec TEXTURE IMPORT NAME=WindowWhite FILE=Textures\Desktop\WindowWhite.pcx GROUP="Window" MIPS=OFF

var() int iIconOffsetX;
var() int iIconOffsetY;

function Created()
{
	//TLW: for testing, can just double real dimenstions  so that the bars always appear.

	//Set the original width/height as desired, for later resizing and scrolling
	DesiredWidth = WinWidth;	//  * 2.0;
	DesiredHeight= WinHeight;	// * 2.0;
	
	Super.Created();
}

function ResolutionChanged(float W, float H)
{
	Super.ResolutionChanged(W, H);

	WinWidth  = FMin(W, DesiredWidth);
	WinHeight = FMin(H, DesiredHeight);

	WinLeft = Root.WinLeft + (Root.WinWidth - WinWidth) / 2;
	WinTop = Root.WinTop  + (Root.WinHeight - WinHeight) / 2;
}

function CreateButtonAndIncrementPosition(out UDukeFakeIcon buttonNew, 
										  out float fLocX, out float fLocY,
										  String strTextForbutton,
										  bool bTextureToUse,
										  optional Region regSizeOfNewWin)	
//TLW: Should change the last parameter to bigger value for all button textures
{
	local Texture texIconToUse; 
	texIconToUse = Texture(DynamicLoadObject("DukeLookAndFeel.generic", class'Texture'));
	
	//Log("TIM: Passing in ClientArea=" $ self $ " to CreateControl");
	buttonNew = UDukeFakeIcon(CreateControl(class'UDukeFakeIcon', 
											  fLocX, fLocY, 
											  texIconToUse.USize * UDukeRootWindow(Root).Desktop.fOversizeFactor,	//to avoid clipping words 
											  texIconToUse.VSize * UDukeRootWindow(Root).Desktop.fOversizeFactor,
											  self
								)
	);
	
//	if(bTextureToUse)  {
//		buttonNew.UpTexture   = Texture(DynamicLoadObject("DukeLookAndFeel.tempicon13", class'Texture'));
//		buttonNew.DownTexture = Texture(DynamicLoadObject("DukeLookAndFeel.tempicon13_HL", class'Texture'));
//	}
//	else  {
	buttonNew.UpTexture   = texIconToUse;
	buttonNew.DownTexture = Texture(DynamicLoadObject("DukeLookAndFeel.generic_Flipped", class'Texture'));
//	}
	buttonNew.OverTexture = buttonNew.DownTexture;

	buttonNew.SetText(strTextForbutton);
	buttonNew.TextY = texIconToUse.VSize;	//put at the bottom of icon texture
	buttonNew.fLocationDesired_X = buttonNew.WinLeft;	//setup desired location used for icon move animation

	//Only if a valid region is passed in, set the new buttons winoffset and size member
	if(regSizeOfNewWin.W != 0 && regSizeOfNewWin.H != 0)  
		buttonNew.WindowOffsetAndSize = regSizeOfNewWin;
	
	fLocX += buttonNew.WinWidth + iIconOffsetX;
	if(fLocX > (WinWidth - buttonNew.WinWidth))  {
		fLocY += buttonNew.WinHeight + iIconOffsetY;
		fLocX = WinWidth / 10.0;		//This number should match Created()s initial value 
	}
}

function LaunchClassicGame( String strNameOfGame, Region regWinLocation )
{
	local UWindowFramedWindow winOpened;
	winOpened = UWindowFramedWindow( Root.CreateWindow(	class'UDukeWindowFrameClassicGame', 
														regWinLocation.X, regWinLocation.Y, 
														regWinLocation.W, regWinLocation.H, 
														self
									 )
	);

	winOpened.WindowTitle = strNameOfGame;
}

/*
function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
//	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'WindowWhite');
//	Tile(C, Texture'DesktopGreen');
}
*/

defaultproperties
{
     iIconOffsetX=16
     iIconOffsetY=32
}
