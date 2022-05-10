//==========================================================================
// 
// FILE:			UDukeLookAndFeel.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Items for ChannelListBox
// 
// NOTES:			TODO: strPassword is currently not used
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeNetChannelItem expands UWindowListBoxItem;

var string strName;
var string strPassword;

function int Compare(UWindowList T, UWindowList B)
{
	local string strT, strB;

	strT = Caps(UDukeNetChannelItem(T).strName);
	strB = Caps(UDukeNetChannelItem(B).strName); 

	if(strT == strB)
		return 0;

	if(strT < strB)
		return -1;

//	else
		return 1;
}

defaultproperties
{
}
