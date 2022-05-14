//==========================================================================
// 
// FILE:			UDukeWindowFrameClassicGame.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Unique windowframe class required by UT's UI
// 
// NOTES:			
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeWindowFrameClassicGame expands UDukeFakeExplorerWindow;

function Created()
{
	ClientClass=class'UDukeWindowClassicGame';
	Super.Created();
}

defaultproperties
{
}
