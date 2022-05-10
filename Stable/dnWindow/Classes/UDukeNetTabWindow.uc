//==========================================================================
// 
// FILE:			UDukeNetTabWindow.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		The seperate pages, or windows that the tabs in DukeNet open up
// 
// NOTES:			Right now the abstract class nothing. It was originally 
//					planned to handle most of the common things to each page
//					or window, but that didn't happen.
// 
// MOD HISTORY: 
// 
//==========================================================================
class UDukeNetTabWindow expands UDukePageWindow
	  abstract;

const CONTROL_SPACING = 10;		//spacing used in sub-classes for control placement

defaultproperties
{
}
