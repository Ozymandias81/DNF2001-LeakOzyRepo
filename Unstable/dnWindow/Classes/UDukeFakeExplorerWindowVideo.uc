//==========================================================================
// 
// FILE:			UDukeFakeExplorerWindowVideo.uc
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
class UDukeFakeExplorerWindowVideo expands UDukeFakeExplorerWindow; 

function Created() 
{
	ClientClass=class'UDukeVideoSC';
	WindowTitle="Video";

	Super.Created();
}

defaultproperties
{
}
