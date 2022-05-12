class UMenuBotConfigBase extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;

// Base Skill
var UWindowComboControl BaseCombo;
var localized string BaseText;
var localized string BaseHelp;

// Taunt Label
var UMenuLabelControl TauntLabel;
var localized string Skills[8];
var localized string SkillTaunts[8];

// # of Bots
var UWindowEditControl NumBotsEdit;
var localized string NumBotsText;
var localized string NumBotsHelp;

// Auto Adjust
var UWindowCheckbox AutoAdjustCheck;
var localized string AutoAdjustText;
var localized string AutoAdjustHelp;

// Random Order
var UWindowCheckbox RandomCheck;
var localized string RandomText;
var localized string RandomHelp;

// Configure Indiv Bots
var UWindowSmallButton ConfigBots;
var localized string ConfigBotsText;
var localized string ConfigBotsHelp;

var localized string AtLeastOneBotTitle;
var localized string AtLeastOneBotText;

var float ControlOffset;

function Created()
{
	local int i;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	SetBotmatchParent();

	// Base Skill
	BaseCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	BaseCombo.SetText(BaseText);
	BaseCombo.SetHelpText(BaseHelp);
	BaseCombo.SetFont(F_Normal);
	BaseCombo.SetEditable(False);
	for (i=0; i<8; i++)
	{
		if (Skills[i] != "")
			BaseCombo.AddItem(Skills[i]);
	}
	ControlOffset += 25;

	// Taunt Label
	TauntLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	TauntLabel.Align = TA_Center;
	ControlOffset += 25;

	// # of Bots
	NumBotsEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	NumBotsEdit.SetText(NumBotsText);
	NumBotsEdit.SetHelpText(NumBotsHelp);
	NumBotsEdit.SetFont(F_Normal);
	NumBotsEdit.SetNumericOnly(True);
	NumBotsEdit.SetMaxLength(2);
	NumBotsEdit.Align = TA_Right;

	ConfigBots = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ControlRight, ControlOffset, 48, 16));
	ConfigBots.SetText(ConfigBotsText);
	ConfigBots.SetFont(F_Normal);
	ConfigBots.SetHelpText(ConfigBotsHelp);
	ControlOffset += 25;

	// Auto Adjust
	AutoAdjustCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	AutoAdjustCheck.SetText(AutoAdjustText);
	AutoAdjustCheck.SetHelpText(AutoAdjustHelp);
	AutoAdjustCheck.SetFont(F_Normal);
	AutoAdjustCheck.Align = TA_Right;

	// Random Order
	RandomCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	RandomCheck.SetText(RandomText);
	RandomCheck.SetHelpText(RandomHelp);
	RandomCheck.SetFont(F_Normal);
	RandomCheck.Align = TA_Right;
	ControlOffset += 25;

}

function AfterCreate()
{
	Super.AfterCreate();
	LoadCurrentValues();
	Initialized = True;

	DesiredWidth = 270;
	DesiredHeight = ControlOffset;
}

function LoadCurrentValues()
{
}

function SetBotmatchParent()
{
	if(BotmatchParent != None)
		return;

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	BaseCombo.SetSize(CenterWidth, 1);
	BaseCombo.WinLeft = CenterPos;
	BaseCombo.EditBoxWidth = 120;

	TauntLabel.SetSize(CenterWidth, 1);
	TauntLabel.WinLeft = CenterPos;

	NumBotsEdit.SetSize(ControlWidth + 10, 1);
	NumBotsEdit.WinLeft = ControlLeft - 5;
	NumBotsEdit.EditBoxWidth = 20;

	ConfigBots.AutoWidth(C);
	ConfigBots.WinLeft = ControlRight - 5;

	AutoAdjustCheck.SetSize(ControlWidth + 10, 1);
	AutoAdjustCheck.WinLeft = ControlLeft - 5;

	RandomCheck.SetSize(ControlWidth + 10, 1);
	RandomCheck.WinLeft = ControlRight - 5;
}

function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case BaseCombo:
			BaseChanged();
			break;
		case NumBotsEdit:
			NumBotsChanged();
			break;
		case AutoAdjustCheck:
			AutoAdjustChecked();
			break;
		case RandomCheck:
			RandomChecked();
			break;
		}
	case DE_Click:
		switch(C)
		{
		case ConfigBots:
			ConfigureIndivBots();
			break;
		}
	}
}

function BaseChanged()
{
}

function NumBotsChanged()
{
}

function AutoAdjustChecked()
{
}

function RandomChecked()
{
}

function ConfigureIndivBots()
{
}

defaultproperties
{
	BaseText="Base Skill:"
	BaseHelp="This is the base skill level of the bots."
	NumBotsText="Number of Bots"
	NumBotsHelp="This is the number of bots that you will play against."
	AutoAdjustText="Auto Adjust Skill"
	AutoAdjustHelp="If checked, bots will increase or decrease their skill to match your skill level."
	RandomText="Random Order"
	RandomHelp="If checked, bots will chosen at random from the list of bot configurations."
	ConfigBotsText="Configure"
	ConfigBotsHelp="Configure the names, appearance and other attributes of individual bots."
	Skills(0)="Novice"
	Skills(1)="Average"
	Skills(2)="Skilled"
	Skills(3)="Masterful"
	Skills(4)=""
	Skills(5)=""
	Skills(6)=""
	SkillTaunts(0)="They won't hurt you...much."
	SkillTaunts(1)="Don't get cocky."
	SkillTaunts(2)="You think you're tough?"
	SkillTaunts(3)="You're already dead."
	SkillTaunts(4)=""
	SkillTaunts(5)=""
	SkillTaunts(6)=""
	ControlOffset=20
	AtLeastOneBotTitle="Configure Bots"
	AtLeastOneBotText="You must choose at least one bot in order to use the configure bots screen."
}