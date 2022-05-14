//==========================================================================
// 
// FILE:			UDukeSaveGameWindow.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		Parental lock window
// 
//==========================================================================
class UDukeSaveGameWindow expands UDukeFakeExplorerWindow;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	ClientClass = class'UDukeSaveGameWindowCW';
	WindowTitle = "Save Game";
	
	Super.Created();
}

defaultproperties
{
}
