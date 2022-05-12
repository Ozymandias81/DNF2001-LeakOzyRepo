class UMenuOptionsClientWindow extends UWindowDialogClientWindow
	config;

var UMenuPageControl Pages;
var UWindowSmallCloseButton CloseButton;

var localized string GamePlayTab, InputTab, ControlsTab, AudioTab, VideoTab, NetworkTab, HUDTab;
var UWindowPageControlPage Network;

function Created() 
{
	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight - 48));
	Pages.SetMultiLine(True);
	Pages.AddPage(VideoTab, class'UMenuVideoScrollClient');
	Pages.AddPage(AudioTab, class'UMenuAudioScrollClient');
	Pages.AddPage(GamePlayTab, class'UMenuGameOptionsScrollClient');
	Pages.AddPage(ControlsTab, class'UMenuCustomizeScrollClient');
	Pages.AddPage(InputTab, class'UMenuInputOptionsScrollClient');
	Pages.AddPage(HUDTab, class'UMenuHUDConfigScrollClient');
	Network = Pages.AddPage(NetworkTab, class'UMenuNetworkScrollClient');
	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));
	Super.Created();
}

function ShowNetworkTab()
{
	Pages.GotoTab(Network, True);
}

function Resized()
{
	Pages.WinWidth = WinWidth;
	Pages.WinHeight = WinHeight - 24;	// OK, Cancel area
	CloseButton.WinLeft = WinWidth-52;
	CloseButton.WinTop = WinHeight-20;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight-LookAndFeel.TabUnselectedM.H, T);
}

function GetDesiredDimensions(out float W, out float H)
{	
	Super(UWindowWindow).GetDesiredDimensions(W, H);
	H += 30;
}

defaultproperties
{
	GamePlayTab="Game"
	InputTab="Input"
	ControlsTab="Controls"
	AudioTab="Audio"
	VideoTab="Video"
	NetworkTab="Network"
	HUDTab="HUD"
}