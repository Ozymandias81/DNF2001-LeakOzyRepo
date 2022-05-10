class UDukeMultiRulesCW expands UDukeMultiRulesBase;

function LoadCurrentValues()
{
	FragEdit.SetValue( string( Class<dnDeathMatchGame>(myParent.GameClass).Default.FragLimit ) );
	TimeEdit.SetValue( string( Class<dnDeathMatchGame>(myParent.GameClass).Default.TimeLimit ) );

	if(MaxPlayersEdit != None)
		MaxPlayersEdit.SetValue( string( Class<dnDeathMatchGame>(myParent.GameClass).Default.MaxPlayers ) );
	
	if( MaxSpectatorsEdit != None )
		MaxSpectatorsEdit.SetValue( string( Class<dnDeathMatchGame>(myParent.GameClass).Default.MaxSpectators ) );

	WeaponsCheck.bChecked = Class<dnDeathMatchGame>(myParent.GameClass).Default.bCoopWeaponMode;
	TourneyCheck.bChecked = Class<dnDeathMatchGame>(myParent.GameClass).Default.bTournament;
	ForceRespawnCheck.bChecked = Class<dnDeathMatchGame>(myParent.GameClass).Default.bForceRespawn;
}

function FragChanged()
{
	Class<dnDeathMatchGame>(myParent.GameClass).Default.FragLimit = int(FragEdit.GetValue());
}

function TimeChanged()
{
	Class<dnDeathMatchGame>(myParent.GameClass).Default.TimeLimit = int(TimeEdit.GetValue());
}

function MaxPlayersChanged()
{
	if(int(MaxPlayersEdit.GetValue()) > 16)
		MaxPlayersEdit.SetValue("16");

	if(int(MaxPlayersEdit.GetValue()) < 1)
		MaxPlayersEdit.SetValue("1");

	Class<dnDeathMatchGame>(myParent.GameClass).Default.MaxPlayers = int(MaxPlayersEdit.GetValue());
}

function MaxSpectatorsChanged()
{
	if(int(MaxSpectatorsEdit.GetValue()) > 16)
		MaxSpectatorsEdit.SetValue("16");

	if(int(MaxSpectatorsEdit.GetValue()) < 0)
		MaxSpectatorsEdit.SetValue("0");

	Class<dnDeathMatchGame>(myParent.GameClass).Default.MaxSpectators = int(MaxSpectatorsEdit.GetValue());
}

function WeaponsChecked()
{
	Class<dnDeathMatchGame>(myParent.GameClass).Default.bCoopWeaponMode = WeaponsCheck.bChecked;
}

function TourneyChecked()
{
	Class<dnDeathMatchGame>(myParent.GameClass).Default.bTournament = TourneyCheck.bChecked;
}

function ForceRespawnChecked()
{
	Class<dnDeathMatchGame>(myParent.GameClass).Default.bForceRespawn = ForceRespawnCheck.bChecked;
}

