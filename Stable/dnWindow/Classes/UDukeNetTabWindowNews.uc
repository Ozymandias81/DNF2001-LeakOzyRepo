//=============================================================================
// 
// FILE:			UDukeNetTabWindowNews.uc
// 
// AUTHOR:			Scott Alden
// 
// DESCRIPTION:		The MOTD handler for DukeNet
//
//==========================================================================
class UDukeNetTabWindowNews expands UDukeNetTabWindow;

var string strURLBanner;

const MAX_BANNER_HEIGHT = 64;

var UDukeBannerAd winBannerAd;
var UDukeHTTPClient httpClient;

function Created() 
{
	Super.Created();

	winBannerAd = UDukeBannerAd(CreateWindow(class'UDukeBannerAd', 
											 0, WinHeight - MAX_BANNER_HEIGHT, 
											 WinWidth, MAX_BANNER_HEIGHT
								)
	);
	httpClient = GetPlayerOwner().Spawn(class'UDukeHTTPClient');		

	httpClient.winHTMLforHTTPData = UDukeHTMLTextHandler(CreateWindow(class'UDukeHTMLTextHandler', 
																	0, 0, 
																	WinWidth, WinHeight - winBannerAd.WinHeight, 
																	Self
											 			)
	);
	httpClient.winHTMLforHTTPData.AddText("Connecting...");
	httpClient.winHTMLforHTTPData.bSkipToToken = true;
	httpClient.winHTMLforHTTPData.strTokenToStartProcessing = "----------";
}

function SetMOTD(string strURL)
{
	httpClient.BrowseMOTD(strURL);
}

defaultproperties
{
    bBuildDefaultButtons=false
    bNoScanLines=true
    bNoClientTexture=true
}
