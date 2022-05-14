//==========================================================================
// 
// FILE:			UDukeLoadGameWindow.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		Load Game Menu
// 
//==========================================================================
class UDukeLoadGameWindow expands UDukeFakeExplorerWindow;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	ClientClass = class'UDukeLoadGameWindowCW';
	WindowTitle = "Load Game";
	
	Super.Created();
}

defaultproperties
{
}
