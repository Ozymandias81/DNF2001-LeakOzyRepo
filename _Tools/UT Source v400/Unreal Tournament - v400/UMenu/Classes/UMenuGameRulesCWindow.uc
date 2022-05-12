class UMenuGameRulesCWindow extends UMenuGameRulesBase;

function LoadCurrentValues()
{
	FragEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.FragLimit));

	TimeEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.TimeLimit));

	if(MaxPlayersEdit != None)
		MaxPlayersEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.MaxPlayers));
	
	if(MaxSpectatorsEdit != None)
		MaxSpectatorsEdit.SetValue(string(Class<DeathMatchGame>(BotmatchParent.GameClass).Default.MaxSpectators));

	WeaponsCheck.bChecked = Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bCoopWeaponMode;
}


function FragChanged()
{
	Class<DeathMatchGame>(BotmatchParent.GameClass).Default.FragLimit = int(FragEdit.GetValue());
}

function TimeChanged()
{
	Class<DeathMatchGame>(BotmatchParent.GameClass).Default.TimeLimit = int(TimeEdit.GetValue());
}

function MaxPlayersChanged()
{
	if(int(MaxPlayersEdit.GetValue()) > 16)
		MaxPlayersEdit.SetValue("16");

	if(int(MaxPlayersEdit.GetValue()) < 1)
		MaxPlayersEdit.SetValue("1");

	Class<DeathMatchGame>(BotmatchParent.GameClass).Default.MaxPlayers = int(MaxPlayersEdit.GetValue());
}

function MaxSpectatorsChanged()
{
	if(int(MaxSpectatorsEdit.GetValue()) > 16)
		MaxSpectatorsEdit.SetValue("16");

	if(int(MaxSpectatorsEdit.GetValue()) < 0)
		MaxSpectatorsEdit.SetValue("0");

	Class<DeathMatchGame>(BotmatchParent.GameClass).Default.MaxSpectators = int(MaxSpectatorsEdit.GetValue());
}

function WeaponsChecked()
{
	Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bCoopWeaponMode = WeaponsCheck.bChecked;
}
