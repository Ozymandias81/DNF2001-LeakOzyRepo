class KillGameQueryClient extends UMenuDialogClientWindow;

// Window
var UMenuLabelControl QueryLabel;

var UWindowSmallButton YesButton;
var UWindowSmallButton NoButton;

var localized string QueryText;
var localized string YesText, NoText;

var SlotWindow SlotWindow;
var int SlotIndex;

function Created()
{
	GetPlayerOwner().SetPause( True );

	QueryLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', WinWidth+20, 0, WinWidth-40, 12));
	QueryLabel.SetText(QueryText);

	NoButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 16));
	NoButton.SetText(NoText);
	YesButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-106, WinHeight-24, 48, 16));
	YesButton.SetText(YesText);

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

	NoButton.WinLeft = WinWidth-52;
	NoButton.WinTop = WinHeight-20;
	YesButton.WinLeft = WinWidth-102;
	YesButton.WinTop = WinHeight-20;
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
			case YesButton:
				YesPressed();
				break;
			case NoButton:
				NoPressed();
				break;
		}
	}
}

function YesPressed()
{
	if (SlotWindow != None)
	{
		SlotWindow.Saves[SlotIndex] = "";
		SlotWindow.SaveConfig();
		SlotWindow.SlotButton[SlotIndex].Text = class'SlotWindow'.Default.EmptyText;
		class'ManagerWindow'.Default.DOMDoorOpen[SlotIndex] = 0;
		class'ManagerWindow'.Default.CTFDoorOpen[SlotIndex] = 0;
		class'ManagerWindow'.Default.ASDoorOpen[SlotIndex] = 0;
		class'ManagerWindow'.Default.ChalDoorOpen[SlotIndex] = 0;
		class'ManagerWindow'.Default.TrophyDoorOpen[SlotIndex] = 0;
		class'ManagerWindow'.Static.StaticSaveConfig();
	}

	Close();
}

function NoPressed()
{
	Close();
}

defaultproperties
{
	QueryText="Are you sure you want to remove this save game?"
	YesText="Yes"
	NoText="No"
}
