//==========================================================================
// 
// FILE:			UDukeFakeExplorerWindowAudio.uc
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
class UDukeFakeExplorerWindowAudio expands UDukeFakeExplorerWindow; 

function Created() 
{
	ClientClass=class'UDukeAudioSC';
	WindowTitle="Audio";

	Super.Created();
}

defaultproperties
{
}
