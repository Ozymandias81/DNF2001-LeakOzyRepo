//==========================================================================
// 
// FILE:			UDukeGameOptionsSC.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Necessary to override, to set ClientClass = UDukeGameOptionsCW
// 
// NOTES:			
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeGameOptionsSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeGameOptionsCW';
	Super.Created();
}

defaultproperties
{
}
