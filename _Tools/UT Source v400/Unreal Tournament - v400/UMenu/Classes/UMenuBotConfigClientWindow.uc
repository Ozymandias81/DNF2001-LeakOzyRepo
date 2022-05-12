class UMenuBotConfigClientWindow extends UMenuBotConfigBase;

// Botconfig
var Class<BotInfo> BotConfig;

var UWindowCheckbox BIMCheck;
var localized string BIMText;
var localized string BIMHelp;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	SetBotmatchParent();

	if(BotmatchParent.bNetworkGame)
	{
		BIMCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
		BIMCheck.SetText(BIMText);
		BIMCheck.SetHelpText(BIMHelp);
		BIMCheck.SetFont(F_Normal);
		BIMCheck.Align = TA_Right;

		ControlOffset += 25;
	}

	Super.Created();
}

function BeforePaint(Canvas C, float x, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	if(BIMCheck != None)
	{
		
		BIMCheck.SetSize(CenterWidth - 90, 1);
		BIMCheck.WinLeft = CenterPos + 45;
	}
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
		case BIMCheck:
			BIMChanged();
			break;
		}
	}
}

function LoadCurrentValues()
{
	BotConfig = Class<DeathMatchGame>(BotmatchParent.GameClass).Default.BotConfigType;

	TauntLabel.SetText(SkillTaunts[BotConfig.Default.Difficulty]);
	BaseCombo.SetSelectedIndex(BotConfig.Default.Difficulty);
	AutoAdjustCheck.bChecked = BotConfig.Default.bAdjustSkill;
	RandomCheck.bChecked = BotConfig.Default.bRandomOrder;
	NumBotsEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.InitialBots));
	if(BIMCheck != None)
		BIMCheck.bChecked = Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bMultiPlayerBots;
}

function BaseChanged()
{
	TauntLabel.SetText(SkillTaunts[BaseCombo.GetSelectedIndex()]);
	BotConfig.Default.Difficulty = BaseCombo.GetSelectedIndex();
}

function NumBotsChanged()
{
	if (int(NumBotsEdit.GetValue()) > 15)
		NumBotsEdit.SetValue("15");
	Class<DeathMatchGame>(BotmatchParent.GameClass).Default.InitialBots = int(NumBotsEdit.GetValue());
}

function BIMChanged()
{
	if(BIMCheck != None)
		Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bMultiPlayerBots = BIMCheck.bChecked;		
}

function AutoAdjustChecked()
{
	BotConfig.Default.bAdjustSkill = AutoAdjustCheck.bChecked;
}

function RandomChecked()
{
	BotConfig.Default.bRandomOrder = RandomCheck.bChecked;
}

function ConfigureIndivBots()
{
	if(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.InitialBots == 0)
		MessageBox(AtLeastOneBotTitle, AtLeastOneBotText, MB_OK, MR_OK, MR_OK);
	else
		GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'UMenuConfigIndivBotsWindow', 100, 100, 200, 200, Self));
}

function SaveConfigs()
{
	Super.SaveConfigs();
	BotConfig.static.StaticSaveConfig();
	Class<DeathMatchGame>(BotmatchParent.GameClass).static.StaticSaveConfig();
}

defaultproperties
{
	BIMText="Enable Bots"
	BIMHelp="If checked, bots will be present in your new multiplayer game."
}