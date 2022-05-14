//=============================================================================
//
// FILE:			UDukeFakeExplorerSC.uc
//
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Override so UDukeFakeExplorerCW is used as clientclass
// 
// NOTES:			Base class for new Duke windowing system's scrolling
//					Dialog Client window (to provide scollbars to all window frames)
//  
// MOD HISTORY: 
//
//=============================================================================
class UDukeFakeExplorerSC expands UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeFakeExplorerCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
