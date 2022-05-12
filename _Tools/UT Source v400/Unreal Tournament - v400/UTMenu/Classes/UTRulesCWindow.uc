class UTRulesCWindow extends UMenuGameRulesBase;

// Tourney
var UWindowCheckbox TourneyCheck;
var localized string TourneyText;
var localized string TourneyHelp;

var UWindowCheckbox ForceRespawnCheck;
var localized string ForceRespawnText;
var localized string ForceRespawnHelp;

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

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	// Tourney
	TourneyCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, WeaponsCheck.WinTop, ControlWidth, 1));
	TourneyCheck.SetText(TourneyText);
	TourneyCheck.SetHelpText(TourneyHelp);
	TourneyCheck.SetFont(F_Normal);
	TourneyCheck.Align = TA_Right;
}

function SetupNetworkOptions()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.SetupNetworkOptions();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	if(BotmatchParent.bNetworkGame && !ClassIsChildOf( BotmatchParent.GameClass, class'LastManStanding'))
	{
		ForceRespawnCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
		ForceRespawnCheck.SetText(ForceRespawnText);
		ForceRespawnCheck.SetHelpText(ForceRespawnHelp);
		ForceRespawnCheck.SetFont(F_Normal);
		ForceRespawnCheck.Align = TA_Right;
		ControlOffset += 25;
	}
}


// replaces UMenuGameRulesCWindow's version
function LoadCurrentValues()
{
	FragEdit.SetValue(string(Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.FragLimit));

	TimeEdit.SetValue(string(Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.TimeLimit));

	if(MaxPlayersEdit != None)
		MaxPlayersEdit.SetValue(string(Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxPlayers));

	if(MaxSpectatorsEdit != None)
		MaxSpectatorsEdit.SetValue(string(Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxSpectators));

	if(BotmatchParent.bNetworkGame)
		WeaponsCheck.bChecked = Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bMultiWeaponStay;
	else
		WeaponsCheck.bChecked = Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bCoopWeaponMode;

	TourneyCheck.bChecked = Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bTournament;

	if(ForceRespawnCheck != None)
		ForceRespawnCheck.bChecked = Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bForceRespawn;
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

	TourneyCheck.SetSize(ControlWidth, 1);
	TourneyCheck.WinLeft = ControlRight;

	if(ForceRespawnCheck != None)
	{
		ForceRespawnCheck.SetSize(ControlWidth, 1);
		ForceRespawnCheck.WinLeft = ControlLeft;
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
		case TourneyCheck:
			TourneyChanged();
			break;
		case ForceRespawnCheck:
			ForceRespawnChanged();
			break;
		}
	}
}

function TourneyChanged()
{
	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bTournament = TourneyCheck.bChecked;
}

function ForceRespawnChanged()
{
	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bForceRespawn = ForceRespawnCheck.bChecked;
}

// replaces UMenuGameRulesCWindow's version
function FragChanged()
{
	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.FragLimit = int(FragEdit.GetValue());
}

// replaces UMenuGameRulesCWindow's version
function TimeChanged()
{
	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.TimeLimit = int(TimeEdit.GetValue());
}

// replaces UMenuGameRulesCWindow's version
function MaxPlayersChanged()
{
	if(int(MaxPlayersEdit.GetValue()) > 16)
		MaxPlayersEdit.SetValue("16");
	if(int(MaxPlayersEdit.GetValue()) < 1)
		MaxPlayersEdit.SetValue("1");

	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxPlayers = int(MaxPlayersEdit.GetValue());
}

function MaxSpectatorsChanged()
{
	if(int(MaxSpectatorsEdit.GetValue()) > 16)
		MaxSpectatorsEdit.SetValue("16");
	
	if(int(MaxSpectatorsEdit.GetValue()) < 0)
		MaxSpectatorsEdit.SetValue("0");

	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxSpectators = int(MaxSpectatorsEdit.GetValue());
}

// replaces UMenuGameRulesCWindow's version
function WeaponsChecked()
{
	if(BotmatchParent.bNetworkGame)
		Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bMultiWeaponStay = WeaponsCheck.bChecked;
	else
		Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bCoopWeaponMode = WeaponsCheck.bChecked;
}

function SaveConfigs()
{
	Super.SaveConfigs();
	BotmatchParent.GameClass.static.StaticSaveConfig();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	TourneyText="Tournament"
	TourneyHelp="If checked, each player must indicate they are ready by clicking their fire button before the match begins."
	ForceRespawnText="Force Respawn"
	ForceRespawnHelp="If checked, players will be automatically respawned when they die, without waiting for the user to press Fire."
}