class UMenuWeaponPriorityWindow expands UMenuFramedWindow;

var UWindowSmallCloseButton CloseButton;

function Created() 
{
	bStatusBar = False;
	bSizable = True;

	Super.Created();

	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));

	SetSizePos();

	MinWinWidth = 300;
	MinWinHeight = 170;
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function SetSizePos()
{
	SetSize(Min(480, Root.WinWidth - 50), Min(360, Root.WinHeight - 50));
	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

function Resized()
{
	Super.Resized();
	ClientArea.SetSize(ClientArea.WinWidth, ClientArea.WinHeight-24);
	CloseButton.WinLeft = ClientArea.WinLeft+ClientArea.WinWidth-52;
	CloseButton.WinTop = ClientArea.WinTop+ClientArea.WinHeight+4;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, ClientArea.WinLeft, ClientArea.WinTop + ClientArea.WinHeight, ClientArea.WinWidth, 24, T);

	Super.Paint(C, X, Y);
}

function SaveConfigs()
{
	Super.SaveConfigs();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	WindowTitle="Weapons";
	ClientClass=class'UMenuWeaponPriorityCW'
}