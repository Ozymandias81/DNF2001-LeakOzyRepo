//==========================================================================
// 
// FILE:			UDukeHTMLTextHandler.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		filters out additional HTML tags HTMLTextArea can't handle
// 
// NOTES:			The current MOTD has some tags UWindowHTMLTextArea didn't
//					handle properly. Was originally planned to extend UWindowHTMLTextArea
//					even further, given time and go ahead to do so.
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeHTMLTextHandler expands UWindowHTMLTextArea;

var bool bSkipToToken;		//Token used to skip unreadable text that UWindowHTMLTextArea can't handle
var bool bSkippingForm;		//flag to skip over forms... forms not supported yet (if ever?)

var string strTokenToStartProcessing;	//this is set in UDukeNetTabWindowNews

function DecodeHTMLTag(	string strHTML, 
						out string strOutput, out string strLeft,
						out UWindowDynamicTextRow rowText,
						out HTMLStyle StartStyle, out HTMLStyle CurrentStyle)
{
	local bool bNegative;
	local string strTag;

	if(bSkipToToken)  {
		if(InStr(strLeft, strTokenToStartProcessing) >= 0)  {
			Log("TIM: Found token, starting HTML processing.");
			bSkipToToken = false;	//start processing HTML			
		}
		else  {
		//	Log("TIM: String did not contain token, continueing to scan...");
		}
		return;	//keep scanning until we hit the token
	}

	strTag = GetTag(strHTML);
	if(Left(strTag, 1) == "/")  {
		strTag = Mid(strTag, 1);
		bNegative = true;
	}

	switch(strTag)
	{
		case "HEAD":	if(bNegative || (strOutput $ strLeft) != "")  {
							rowText = Super(UWindowDynamicTextArea).AddText(strOutput $ strLeft);
							strOutput = "";
							UWindowHTMLTextRow(rowText).StartStyle = StartStyle;
							UWindowHTMLTextRow(rowText).EndStyle = CurrentStyle;
						}
					
						CurrentStyle.bHeading = !bNegative;
						StartStyle = CurrentStyle;
						break;
		case "TR"	  :	
		case "TD"	  : if(bNegative || (strOutput $ strLeft) != "")  {
							rowText = Super(UWindowDynamicTextArea).AddText(strOutput $ strLeft);
							strOutput = "";
							UWindowHTMLTextRow(rowText).StartStyle = StartStyle;
							UWindowHTMLTextRow(rowText).EndStyle = CurrentStyle;
						}

						StartStyle = CurrentStyle;
						break;
		case "STRONG" :	strOutput = strOutput $ strLeft $ strHTML;
						CurrentStyle.bBold = !bNegative;
						break;
		case "FORM" : 	bSkippingForm = !bNegative;			//not supported right now
					//	Log("TIM: SkippingForm now = " $ bSkippingForm); 
						break;
		case "TABLE":/*	bSkippingTable = !bNegative;		//not supported right now
						Log("TIM: SkippingTable now = " $ bSkippingTable); 
						break;
					 */
		case "DIV"  :
		case "TR"	:
		case "HTML" : 
		case "SYTLE":
		case "BASE" :
		case "SCRIPT" :
		case "!--"  :
		case "!DOCTYPE" :	
		case "META"	: 	//Log("TIM: " $ strHTML $ " tag");
						break;
		//All else fails, let Super handle it
		default		:	if(!bSkippingForm)  {
						//	Log("TIM: Passing " $ strHTML $ " to Parent");
							Super.DecodeHTMLTag(strHTML, 
												strOutput, strLeft,
												rowText,
												StartStyle, CurrentStyle	
							);
						}
						break;
	}

} 

defaultproperties
{
}
