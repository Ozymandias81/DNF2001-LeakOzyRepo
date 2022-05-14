//==========================================================================
// 
// FILE:			UDukeParentLockWindow.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		Parental lock window
// 
//==========================================================================
class UDukeParentLockWindow expands UDukeFakeExplorerWindow;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	ClientClass = class'UDukeParentLockWindowCW';
	WindowTitle = "Parental Lock";
	
	Super.Created();
}

defaultproperties
{
}
