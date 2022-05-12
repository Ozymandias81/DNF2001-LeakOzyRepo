class UMenuPlayerWindow extends UMenuFramedWindow;

var UWindowSmallCloseButton CloseButton;

function Created() 
{
	bStatusBar = False;
	bSizable = True;

	Super.Created();

	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));

	SetSizePos();
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function SetSizePos()
{
	if(Root.WinHeight < 400)
		SetSize(Root.WinWidth - 10, Root.WinHeight - 32);
	else
		SetSize(Max(450, Root.WinWidth - 150), Root.WinHeight - 50);

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
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	WindowTitle="Player Setup";
	ClientClass=class'UMenuPlayerClientWindow'
}