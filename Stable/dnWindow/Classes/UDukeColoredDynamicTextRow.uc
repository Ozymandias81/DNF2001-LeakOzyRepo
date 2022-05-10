//==========================================================================
// 
// FILE:			UDukeColoredDynamicTextRow.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		DynamicTextRow that can be broken up into two parts and
//					colored differently 
// 
// NOTES:			
//
// MOD HISTORY:		
// 
//==========================================================================

class UDukeColoredDynamicTextRow expands UWindowDynamicTextRow;

//TLW: Used primarily for IRC chat. label is the first sub-part of a string that is a different 
//		color from the second part. Could be re-used for any other two part text color scheme

var color colorLabelText;		//color of two-part dynamic text's label
var color colorBodyText;		//color of two-part dynamic text's body

var INT iLengthOfLabel;			//length of text's label in UWindowDynamicTextRow.Text

defaultproperties
{
     colorLabelText=(R=255,G=255,B=255)
     colorBodyText=(R=255,G=255,B=128)
}
