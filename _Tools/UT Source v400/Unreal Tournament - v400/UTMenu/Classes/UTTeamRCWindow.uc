class UTTeamRCWindow extends UTRulesCWindow;

// Team Score
var UWindowEditControl TeamScoreEdit;
var localized string TeamScoreText;
var localized string TeamScoreHelp;

// Max Teams
var UWindowEditControl MaxTeamsEdit;
var localized string MaxTeamsText;
var localized string MaxTeamsHelp;

// PlayersBalanceTeams
var UWindowCheckbox BalancePlayersCheck;
var localized string BalancePlayersText;
var localized string BalancePlayersHelp;

var int MaxAllowedTeams;

// Friendly Fire Scale
var UWindowHSliderControl FFSlider;
var localized string FFText;
var localized string FFHelp;

function Created()
{
	local int FFS;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;
	
	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	Initialized = False;

	// Team Score Limit
	TeamScoreEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, 20, ControlWidth, 1));
	TeamScoreEdit.SetText(TeamScoreText);
	TeamScoreEdit.SetHelpText(TeamScoreHelp);
	TeamScoreEdit.SetFont(F_Normal);
	TeamScoreEdit.SetNumericOnly(True);
	TeamScoreEdit.SetMaxLength(3);
	TeamScoreEdit.Align = TA_Right;

	Super.Created();

	if(MaxTeamsEdit != None)
		MaxTeamsEdit.SetValue(string(class<TeamGamePlus>(BotmatchParent.GameClass).Default.MaxTeams));
	MaxAllowedTeams = class<TeamGamePlus>(BotmatchParent.GameClass).Default.MaxAllowedTeams;
	if(BalancePlayersCheck != None)
	BalancePlayersCheck.bChecked = class<TeamGamePlus>(BotmatchParent.GameClass).Default.bPlayersBalanceTeams;

	DesiredWidth = 220;
	DesiredHeight = 165;

	Initialized = False;

	TeamScoreEdit.SetValue(string(int(Class<TeamGamePlus>(BotmatchParent.GameClass).Default.GoalTeamScore)));

	// Friendly Fire Scale
	FFSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	FFSlider.SetRange(0, 10, 1);
	FFS = Class<TeamGamePlus>(BotmatchParent.GameClass).Default.FriendlyFireScale * 10;
	FFSlider.SetValue(FFS);
	FFSlider.SetText(FFText$" ["$FFS*10$"%]:");
	FFSlider.SetHelpText(FFHelp);
	FFSlider.SetFont(F_Normal);

	FragEdit.HideWindow();

	Initialized = True;
}

function SetupNetworkOptions()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	// don't call UTRulesCWindow's version (force respawn)
	Super(UMenuGameRulesBase).SetupNetworkOptions();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	if(BotmatchParent.bNetworkGame)
	{
		BalancePlayersCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
		BalancePlayersCheck.SetText(BalancePlayersText);
		BalancePlayersCheck.SetHelpText(BalancePlayersHelp);
		BalancePlayersCheck.SetFont(F_Normal);
		BalancePlayersCheck.Align = TA_Right;
	}

	if(
		!ClassIsChildOf( BotmatchParent.GameClass, class'CTFGame' ) &&
		!ClassIsChildOf( BotmatchParent.GameClass, class'Assault' )
	)
	{
		MaxTeamsEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));

		MaxTeamsEdit.SetText(MaxTeamsText);
		MaxTeamsEdit.SetHelpText(MaxTeamsHelp);
		MaxTeamsEdit.SetFont(F_Normal);
		MaxTeamsEdit.SetNumericOnly(True);
		MaxTeamsEdit.SetMaxLength(3);
		MaxTeamsEdit.Align = TA_Right;
		MaxTeamsEdit.SetDelayedNotify(True);
	}
	ControlOffset += 25;

	if(BotmatchParent.bNetworkGame)
	{
		if(ClassIsChildOf(BotmatchParent.GameClass, class'CTFGame'))
			ControlOffset -= 25;

		ForceRespawnCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
		ForceRespawnCheck.SetText(ForceRespawnText);
		ForceRespawnCheck.SetHelpText(ForceRespawnHelp);
		ForceRespawnCheck.SetFont(F_Normal);
		ForceRespawnCheck.Align = TA_Right;	
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

	TeamScoreEdit.SetSize(ControlWidth, 1);
	TeamScoreEdit.WinLeft = ControlLeft;
	TeamScoreEdit.EditBoxWidth = 20;

	if( BalancePlayersCheck != None )
	{
		BalancePlayersCheck.SetSize(ControlWidth, 1);
		BalancePlayersCheck.WinLeft = ControlLeft;
	}

	if(MaxTeamsEdit != None)
	{
		MaxTeamsEdit.SetSize(ControlWidth, 1);
		if( BalancePlayersCheck != None )
			MaxTeamsEdit.WinLeft = ControlRight;
		else
			MaxTeamsEdit.WinLeft = ControlLeft;
		MaxTeamsEdit.EditBoxWidth = 20;
	}

	if(ForceRespawnCheck != None && ClassIsChildOf(BotmatchParent.GameClass, class'CTFGame'))
		ForceRespawnCheck.WinLeft = ControlRight;

	FFSlider.SetSize(CenterWidth, 1);
	FFSlider.SliderWidth = 90;
	FFSlider.WinLeft = CenterPos;
}


function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch (C)
		{
			case TeamScoreEdit:
				TeamScoreChanged();
				break;
			case FFSlider:
				FFChanged();
				break;
			case MaxTeamsEdit:
				MaxTeamsChanged();
				break;
			case BalancePlayersCheck:
				BalancePlayersChanged();
				break;
		}
	}
}

function BalancePlayersChanged()
{
	Class<TeamGamePlus>(BotmatchParent.GameClass).Default.bPlayersBalanceTeams = BalancePlayersCheck.bChecked;
}

singular function MaxTeamsChanged()
{
	if(Int(MaxTeamsEdit.GetValue()) > MaxAllowedTeams)
		MaxTeamsEdit.SetValue(string(MaxAllowedTeams));
	if(Int(MaxTeamsEdit.GetValue()) < 2)
		MaxTeamsEdit.SetValue("2");

	Class<TeamGamePlus>(BotmatchParent.GameClass).Default.MaxTeams = int(MaxTeamsEdit.GetValue());
}

function TeamScoreChanged()
{
	Class<TeamGamePlus>(BotmatchParent.GameClass).Default.GoalTeamScore = int(TeamScoreEdit.GetValue());
}

function FFChanged()
{
	Class<TeamGamePlus>(BotmatchParent.GameClass).Default.FriendlyFireScale = FFSlider.GetValue() / 10;
	FFSlider.SetText(FFText$" ["$int(FFSlider.GetValue()*10)$"%]:");
}

defaultproperties
{
	TeamScoreText="Max Team Score"
	TeamScoreHelp="When a team obtains this score, the game will end."
	MaxTeamsText="Max Teams"
	MaxTeamsHelp="The maximum number of different teams players are allowed to join, for this game."
	FFText="Friendly Fire:"
	FFHelp="Slide to adjust the amount of damage friendly fire imparts to other teammates."
	BalancePlayersText="Force Team Balance"
	BalancePlayersHelp="If checked, this option forces players joining the game to be placed on the team which best keeps teams balanced."
}