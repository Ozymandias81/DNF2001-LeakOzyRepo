//==========================================================================
// 
// FILE:			UDukeNewGameWindow.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		New Game selections
// 
//==========================================================================
class UDukeNewGameWindow expands UDukeFakeExplorerWindow;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	ClientClass = class'UDukeNewGameWindowCW';
	WindowTitle = "Select a map";
	
	Super.Created();
}

defaultproperties
{
}
