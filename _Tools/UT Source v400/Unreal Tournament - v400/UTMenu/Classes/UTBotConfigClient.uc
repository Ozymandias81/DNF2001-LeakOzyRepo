class UTBotConfigClient extends UMenuBotConfigBase;

// Botconfig
var Class<ChallengeBotInfo> BotConfig;

var UWindowCheckbox BalanceTeamsCheck;
var localized string BalanceTeamsText;
var localized string BalanceTeamsHelp;

var UWindowCheckbox DumbDownCheck;
var localized string DumbDownText;
var localized string DumbDownHelp;

var localized string MinPlayersText;
var localized string MinPlayersHelp;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	if(BotmatchParent.bNetworkGame)
	{
		NumBotsEdit.SetText(MinPlayersText);
		NumBotsEdit.SetHelpText(MinPlayersHelp);
	}

	if(class<TeamGamePlus>(BotmatchParent.GameClass) != None)
	{
		// Balance Teams
		BalanceTeamsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
		BalanceTeamsCheck.SetText(BalanceTeamsText);
		BalanceTeamsCheck.SetHelpText(BalanceTeamsHelp);
		BalanceTeamsCheck.SetFont(F_Normal);
		BalanceTeamsCheck.Align = TA_Right;

		if(class<Domination>(BotmatchParent.GameClass) != None)
		{
			DumbDownCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
			DumbDownCheck.SetText(DumbDownText);
			DumbDownCheck.SetHelpText(DumbDownHelp);
			DumbDownCheck.SetFont(F_Normal);
			DumbDownCheck.Align = TA_Right;
		}

		ControlOffset += 25;
	}
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

	if(BalanceTeamsCheck != None)
	{
		BalanceTeamsCheck.SetSize(ControlWidth + 10, 1);
		BalanceTeamsCheck.WinLeft = ControlLeft - 5;
	}

	if(DumbDownCheck != None)
	{
		DumbDownCheck.SetSize(ControlWidth + 10, 1);
		DumbDownCheck.WinLeft = ControlRight - 5;
	}
}

function AutoAdjustChecked()
{
	BotConfig.Default.bAdjustSkill = AutoAdjustCheck.bChecked;
	BotConfig.static.StaticSaveConfig();
}

function RandomChecked()
{
	BotConfig.Default.bRandomOrder = RandomCheck.bChecked;
	BotConfig.static.StaticSaveConfig();
}

function ConfigureIndivBots()
{
	if(int(NumBotsEdit.GetValue()) == 0)
		MessageBox(AtLeastOneBotTitle, AtLeastOneBotText, MB_OK, MR_OK, MR_OK);
	else
		GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'UTConfigIndivBotsWindow', 100, 100, 200, 200, Self));
}

// replaces UMenuBotConfigClientWindow's version
function LoadCurrentValues()
{
	local int i;

	BotConfig = class'DeathMatchPlus'.default.BotConfigType;
	for(i=0;i<8;i++)
		Skills[i] = BotConfig.default.Skills[i];

	BaseCombo.SetSelectedIndex(Min(BotConfig.default.Difficulty, 7));

	TauntLabel.SetText(SkillTaunts[BaseCombo.GetSelectedIndex()]);

	AutoAdjustCheck.bChecked = BotConfig.Default.bAdjustSkill;
	RandomCheck.bChecked = BotConfig.Default.bRandomOrder;

	if(BotmatchParent.bNetworkGame)
		NumBotsEdit.SetValue(string(class'DeathMatchPlus'.Default.MinPlayers));
	else
		NumBotsEdit.SetValue(string(class'DeathMatchPlus'.Default.InitialBots));

	if(BalanceTeamsCheck != None)
		BalanceTeamsCheck.bChecked = class'TeamGamePlus'.Default.bBalanceTeams;

	if(DumbDownCheck != None)
		DumbDownCheck.bChecked = !class'Domination'.Default.bDumbDown;
}

// replaces UMenuBotConfigClientWindow's version
function BaseChanged()
{
	TauntLabel.SetText(SkillTaunts[BaseCombo.GetSelectedIndex()]);
	BotConfig.Default.Difficulty = BaseCombo.GetSelectedIndex();
	BotConfig.static.StaticSaveConfig();
}

// replaces UMenuBotConfigClientWindow's version
function NumBotsChanged()
{
	if (int(NumBotsEdit.GetValue()) > 16)
		NumBotsEdit.SetValue("16");

	if(BotmatchParent.bNetworkGame)
		class<DeathMatchPlus>(BotmatchParent.GameClass).default.MinPlayers = int(NumBotsEdit.GetValue());
	else
		class<DeathMatchPlus>(BotmatchParent.GameClass).default.InitialBots = int(NumBotsEdit.GetValue());
	BotmatchParent.GameClass.static.StaticSaveConfig();
}

function BalanceTeamsChanged()
{
	class'TeamGamePlus'.Default.bBalanceTeams = BalanceTeamsCheck.bChecked;
	Log("Set BalanceTeams to: "$class'TeamGamePlus'.Default.bBalanceTeams);
	class'TeamGamePlus'.static.StaticSaveConfig();
}

function DumbDownChanged()
{
	class'Domination'.Default.bDumbDown = !DumbDownCheck.bChecked;
	class'Domination'.static.StaticSaveConfig();
}

function SaveConfigs()
{
	Super.SaveConfigs();
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
		case BalanceTeamsCheck:
			BalanceTeamsChanged();
			break;
		case DumbDownCheck:
			DumbDownChanged();
			break;
		}
		break;
	}
}

defaultproperties
{
	Skills(0)="Novice"
	Skills(1)="Average"
	Skills(2)="Experienced"
	Skills(3)="Skilled"
	Skills(4)="Adept"
	Skills(5)="Masterful"
	Skills(6)="Inhuman"
	Skills(7)="Godlike"
	SkillTaunts(0)="They won't hurt you...much."
	SkillTaunts(1)="They know how to kill."
	SkillTaunts(2)="Don't get cocky."
	SkillTaunts(3)="You think you're tough?"
	SkillTaunts(4)="You'd better be good."
	SkillTaunts(5)="I hope you like to respawn."
	SkillTaunts(6)="You're already dead."
	SkillTaunts(7)="I am the Alpha and the Omega."
	BalanceTeamsText="Balance Teams"
	BalanceTeamsHelp="If this setting is checked, bots will automatically change teams to ensure there is a balanced number of members on each team."
	MinPlayersText="Min. Total Players"
	MinPlayersHelp="Bots will fill out the game to ensure there are always this many players.  Set this number to 0 to disable bots."
	DumbDownText="Enhanced Team AI"
	DumbDownHelp="Enable enhanced team artificial intelligence features for the bots in this game."
}

