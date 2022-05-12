class UMenuGameSettingsCWindow extends UMenuGameSettingsBase;

function LoadCurrentValues()
{
	local int S;

	if ( Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bMegaSpeed )
		StyleCombo.SetSelectedIndex(2);
	else if ( Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bHardcoreMode )
		StyleCombo.SetSelectedIndex(1);
	else
		StyleCombo.SetSelectedIndex(0);

	S = Class<DeathMatchGame>(BotmatchParent.GameClass).Default.GameSpeed * 100.0;
	SpeedSlider.SetValue(S);
	SpeedSlider.SetText(SpeedText$" ["$S$"%]:");
}

function StyleChanged()
{
	switch (StyleCombo.GetSelectedIndex())
	{
		case 0:
			Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bMegaSpeed = false;
			Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bHardCoreMode = false;
			break;
		case 1:
			Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bMegaSpeed = false;
			Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bHardCoreMode = true;
			break;
		case 2:
			Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bMegaSpeed = true;
			Class<DeathMatchGame>(BotmatchParent.GameClass).Default.bHardCoreMode = true;
			break;
	}
}

function SpeedChanged()
{
	local int S;

	S = SpeedSlider.GetValue();
	SpeedSlider.SetText(SpeedText$" ["$S$"%]:");
	Class<DeathMatchGame>(BotmatchParent.GameClass).Default.GameSpeed = float(S) / 100.0;
}
