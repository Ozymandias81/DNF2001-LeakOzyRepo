//==========================================================================
// 
// FILE:			UDukeProfileWindow.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		Login screen for the player
// 
//==========================================================================
class UDukeProfileWindow expands UWindowFramedWindow;

var bool				bInNotify;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	ClientClass = class'UDukeProfileWindowCW';
	WindowTitle = "Select Player Profile";
	
	StatusBarText = "Use this window to select your player profile.";

	Super.Created();
}

defaultproperties
{
}
