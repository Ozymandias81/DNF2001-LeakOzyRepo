//==========================================================================
// 
// FILE:			UDukeHTTPClient.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Doctored up version of UBrowserUpdateServerLink
// 
// NOTES:			suits DukeNets needs better than UBrowserUpdateServerLink 
//					would have
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeHTTPClient expands UBrowserHTTPClient;

var UDukeHTMLTextHandler winHTMLforHTTPData;

function BrowseMOTD(string strURLforMOTD)
{
	local INT iIndex;
	local string strAddress;

	iIndex = InStr(strURLforMOTD, "http://");
	if(iIndex >= 0)  {
		strURLforMOTD = Mid(strURLforMOTD, iIndex + 7);
		iIndex = InStr(strURLforMOTD, "/");
	
	//	Log("TIM: Parsing remainder of string - " $ strURLforMOTD);
		if(iIndex >= 0)  {
			strAddress = Left(strUrlforMOTD, iIndex);
			Log("TIM: Surfing to Address=" $ strAddress $ ", " $ Mid(strURLforMOTD, iIndex));

			Browse(strAddress, Mid(strURLforMOTD, iIndex));		//, UpdateServerPort, UpdateServerTimeout);			
		}
	}
}

function ProcessData(string Data)
{
//	switch(CurrentURI)
//	{
//	case GetMOTD:
//	case GetFallback:
		winHTMLforHTTPData.SetHTML(Data);
//		break;
//	case GetMaster:
//		UpdateWindow.SetMasterServer(Data);
//		break;
//	case GetIRC:
//		UpdateWindow.SetIRCServer(Data);
//		break;
//	}
}

function string GetLocalIPAddress()
{
	local IpAddr ipAddress;
	GetLocalIP(ipAddress);
	
	return IpAddrToString(ipAddress);
}

//////////////////////////////////////////////////////////////////
// HTTPClient functions
//////////////////////////////////////////////////////////////////

function HTTPError(int ErrorCode)
{	
/*	if(ErrorCode == 404 && CurrentURI == GetMOTD)
	{
		CurrentURI = GetFallback;
		BrowseCurrentURI();
	}
	else
		Failure();
*/
}

function HTTPReceivedData(string Data)
{
	ProcessData(Data);

//	if(CurrentURI == MaxURI)
//		CurrentURI--;

//	if(CurrentURI == 0)
//		Success();
//	else
//	{
//		CurrentURI--;
//		BrowseCurrentURI();
//	}
}

defaultproperties
{
}
