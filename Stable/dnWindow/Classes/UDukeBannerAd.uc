//==========================================================================
// 
// FILE:				UDukeBannerAd.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Was to be a texture canvas wrapper for a GIF or other kind
//					of file passed in from DukeNet
// 
// NOTES:			
//
// MOD HISTORY:		
// 
//==========================================================================

class UDukeBannerAd expands UWindowWindow;

var string strURLBanner;
var Texture texBanner_LeftHalf;
var Texture texBanner_RightHalf;

function Created()
{
	strURLBanner = "http://www.3drealms.com";
	Cursor = Root.HandCursor;

	//TLW: TODO: Need to get the banner graphic from the URL into a texture canvas
	texBanner_LeftHalf = Texture(DynamicLoadObject("DukeLookAndFeel.DNBanner", class'Texture'));
	texBanner_RightHalf = texBanner_LeftHalf;
}

function Paint(Canvas C, float X, float Y)
{
	//Banner, that should be a texture canvas of 2 256x64s or some such
	//	quick and cheesy texpan for now
	DrawStretchedTexture(C, 
						 0, 0, 
						 WinWidth / 2, WinHeight, 
						 texBanner_LeftHalf
	);
	DrawStretchedTexture(C, 
						 WinWidth / 2, 0, 
						 WinWidth / 2, WinHeight, 
						 texBanner_RightHalf
	);
}

function Click(float X, float Y)
{
	Root.Console.ViewPort.Actor.ConsoleCommand("start " $ strURLBanner);
}

function MouseLeave()
{
	Super.MouseLeave();
	ToolTip("");
}

function MouseEnter()
{
	Super.MouseLeave();
	ToolTip(strURLBanner);
}

defaultproperties
{
}
