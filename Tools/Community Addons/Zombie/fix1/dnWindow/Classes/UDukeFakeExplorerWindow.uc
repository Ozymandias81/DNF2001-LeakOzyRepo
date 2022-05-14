//==========================================================================
// 
// FILE:			UDukeFakeExplorerWindow.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Base class for new Duke windowing system
// 
// NOTES:			This started as a fake Windows Explorer overlapping
//					Windows style, that later changed to just single windows
//					with clickable icons
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeFakeExplorerWindow expands UWindowFramedWindow;

//#exec TEXTURE IMPORT NAME=tempicon3 FILE=Textures\Desktop\tempicon3.pcx GROUP="Desktop" MIPS=OFF  MASK=ON
//#exec TEXTURE IMPORT NAME=tempicon3_HL FILE=Textures\Desktop\tempicon3_HL.pcx GROUP="Desktop" MIPS=OFF  MASK=ON

//#exec TEXTURE IMPORT NAME=tempicon13 FILE=Textures\Desktop\tempicon13.pcx GROUP="Desktop" MIPS=OFF  MASK=ON
//#exec TEXTURE IMPORT NAME=tempicon13_HL FILE=Textures\Desktop\tempicon13_HL.pcx GROUP="Desktop" MIPS=OFF  MASK=ON

var UDukeFakeIcon arrayIcons[4]; 
var float fInitialWidth;
var float fInitialHeight;

function Created()
{
	Super.Created();

	fInitialWidth = WinWidth;
	fInitialHeight = WinHeight;

	if(	UDukeRootWindow(Root).StatusBar != None && 
		UDukeRootWindow(Root).StatusBar.WindowIsVisible() )
		SetSizeAndPos(Root.WinWidth, Root.WinHeight, UDukeRootWindow(Root).StatusBar.WinHeight);
	else
		SetSizeAndPos(Root.WinWidth, Root.WinHeight);
}

function ResolutionChanged(float W, float H)
{
	ClientArea.ResolutionChanged(W, H);

	if( UDukeRootWindow(Root).StatusBar != None && 
		UDukeRootWindow(Root).StatusBar.WindowIsVisible() )
		SetSizeAndPos(W, H, UDukeRootWindow(Root).StatusBar.WinHeight);
	else
		SetSizeAndPos(W, H);
}

function SetSizeAndPos(float fNewWidth, float fNewHeight, optional float fStatusBarHeight)
{
	SetSize(FMin(fNewWidth, fInitialWidth), FMin(fNewHeight - fStatusBarHeight, fInitialHeight));

	WinLeft = (Root.WinWidth -  WinWidth)  / 2;
	WinTop = ((Root.WinHeight - WinHeight) / 2) - fStatusBarHeight;
}

function CreateIconsForFunstuffWindow()
{
	local float fLocationX,
				fLocationY;
	local UDukeFakeExplorerCW ClientAreaWin;
	ClientAreaWin = UDukeFakeExplorerCW(UWindowScrollingDialogClient(ClientArea).ClientArea);

	//TLW: Was supposed to be some simple arcade games and URLs in this window. 
	//		so far there are just stubs for something to be added.
	WindowTitle="Fun Stuff";
	
	//Start in the TL corner, and tile across and down
	fLocationX = WinWidth / 10.0;
	fLocationY = WinHeight / 10.0;

	//setup button/icons
	ClientAreaWin.CreateButtonAndIncrementPosition(arrayIcons[0],
													fLocationX, fLocationY,
													"Space Invaders", 
													true
	);
	arrayIcons[0].eWindowCommand = eWINDOW_COMMAND_LaunchSpaceInvaders;

	ClientAreaWin.CreateButtonAndIncrementPosition(arrayIcons[1],
													fLocationX, fLocationY,
													"Missile Command", 
													true
	);
	arrayIcons[1].eWindowCommand = eWINDOW_COMMAND_LaunchMissileCommand;

	ClientAreaWin.CreateButtonAndIncrementPosition(arrayIcons[2],
													fLocationX, fLocationY,
													"Breakout",
													true
	);
	arrayIcons[2].eWindowCommand = eWINDOW_COMMAND_LaunchBreakOut;	
	
	ClientAreaWin.CreateButtonAndIncrementPosition(arrayIcons[3],
													fLocationX, fLocationY,
													"Naughty Stuff",
													false
	);
	arrayIcons[3].eWindowCommand = eWINDOW_COMMAND_NaughtyLink;	
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	
	//If no more explorerwindows above me, i.e. opened by a fakeicon,
	//	then show the icons again
	if( UDukeFakeIcon(OwnerWindow) != None &&
		UDukeRootWindow(Root) != None && 
		UDukeRootWindow(Root).Desktop != None
	)
		UDukeRootWindow(Root).Desktop.ShowIcons();
}

defaultproperties
{
     ClientClass=Class'dnWindow.UDukeFakeExplorerSC'
     WindowTitle="Shades OS v.103"
}
