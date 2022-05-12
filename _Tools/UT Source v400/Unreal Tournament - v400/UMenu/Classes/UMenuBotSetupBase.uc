class UMenuBotSetupBase extends UMenuPlayerSetupClient;

var int ConfigureBot;

var UWindowComboControl BotCombo;
var localized string BotText;
var localized string BotHelp;
var localized string BotWord;

var UWindowSmallButton DefaultsButton;
var localized string DefaultsText;
var localized string DefaultsHelp;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int i;

	ControlWidth = WinWidth/3;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Defaults Button
	DefaultsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 30, 10, 48, 16));
	DefaultsButton.SetText(DefaultsText);
	DefaultsButton.SetFont(F_Normal);
	DefaultsButton.SetHelpText(DefaultsHelp);

	BotCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	BotCombo.SetButtons(True);
	BotCombo.SetText(BotText);
	BotCombo.SetHelpText(BotHelp);
	BotCombo.SetFont(F_Normal);
	BotCombo.SetEditable(False);
	LoadBots();
	BotCombo.SetSelectedIndex(0);
	ConfigureBot = 0;
	ControlOffset += 25;

	Super.Created();
}

function LoadBots()
{
}

function ResetBots()
{
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local float W;

	W = Min(WinWidth, 220);

	ControlWidth = W/3;
	ControlLeft = (W/2 - ControlWidth)/2;
	ControlRight = W/2 + ControlLeft;

	CenterWidth = (W/7)*6;
	CenterPos = (W - CenterWidth)/2;

	DefaultsButton.AutoWidth(C);
	DefaultsButton.WinLeft = CenterPos + CenterWidth - DefaultsButton.WinWidth;

	Super.BeforePaint(C, X, Y);
	BotCombo.SetSize(CenterWidth, 1);
	BotCombo.WinLeft = CenterPos;
	BotCombo.EditBoxWidth = 105;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		switch(C)
		{
			case DefaultsButton:
				ResetBots();
				break;
		}
		break;
	case DE_Change:
		switch(C)
		{
			case BotCombo:
				BotChanged();
				break;
		}
		break;
	}
}

function BotChanged()
{
	if (Initialized)
	{
		Initialized = False;
		ConfigureBot = BotCombo.GetSelectedIndex();
		LoadCurrent();
		UseSelected();
		Initialized = True;
	}
}
defaultproperties
{
	PlayerBaseClass="Bots"
	BotWord="Bot"
	BotText="Bot:"
	BotHelp="Select the bot you wish to configure."
	TeamText="Color:"
	TeamHelp="Select the team color for this bot."
	NameText="Name:"
	NameHelp="Set this bot's name."
	SkinText="Skin:"
	SkinHelp="Choose a skin for this bot."
	FaceText="Face:"
	FaceHelp="Choose a face for this bot."
	ClassText="Class:"
	ClassHelp="Select this bot's class."
	ControlOffset=35
	DefaultsText="Reset"
	DefaultsHelp="Reset all bot configurations to their default settings."
}