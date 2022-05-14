//==========================================================================
// 
// FILE:			UDukeFakeExplorerWindowControls.uc
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
class UDukeFakeExplorerWindowControls expands UDukeFakeExplorerWindow; 

function Created() 
{
	ClientClass=class'UDukeControlsSC';
	WindowTitle="Controls";

	Super.Created();
}

defaultproperties
{
}
