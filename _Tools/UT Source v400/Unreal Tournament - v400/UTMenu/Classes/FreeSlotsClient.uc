class FreeSlotsClient extends UMenuDialogClientWindow;

// Window
var UMenuLabelControl QueryLabel;

var UWindowSmallButton DoneButton;

var localized string QueryText;
var localized string DoneText;

function Created()
{
	QueryLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', WinWidth+20, 0, WinWidth-40, 12));
	QueryLabel.SetText(QueryText);

	DoneButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', (WinWidth - 48)/2, WinHeight-24, 48, 16));
	DoneButton.SetText(DoneText);

	Super.Created();
}

function Resized()
{
	local int CenterWidth, CenterPos;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	QueryLabel.WinLeft = CenterPos;
	QueryLabel.SetSize(CenterWidth, QueryLabel.WinHeight);
	QueryLabel.WinTop = (WinHeight - QueryLabel.WinHeight)/2 - 11;

	DoneButton.WinLeft = (WinWidth - 48)/2;
	DoneButton.WinTop = WinHeight-20;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();

	DrawUpBevel( C, 0, WinHeight-22, WinWidth, 22, T);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
			case DoneButton:
				DonePressed();
				break;
		}
	}
}

function DonePressed()
{
	Close();

	GetPlayerOwner().SetPause( False );

	if (DeathMatchPlus(GetLevel().Game) != None)
		DeathMatchPlus(GetLevel().Game).bDontRestart = False;

	Root.Console.bQuickKeyEnable = False;
	Root.Console.CloseUWindow();
}

defaultproperties
{
        QueryText="Free a save slot first!"
        DoneText="OK"
}
