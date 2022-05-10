//==========================================================================
// 
// FILE:			UDukeNetSC.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		necessary for setting clientclass to UDukeNetCW
// 
// NOTES:			
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeNetSC expands UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeNetCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
