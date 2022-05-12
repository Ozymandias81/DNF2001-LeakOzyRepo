class RatedTeamInfo expands Info;

var() localized string		TeamName;
var() texture		TeamSymbol;
var() localized string		TeamBio;

var() string		BotNames[8];
var() localized string		BotClassifications[8];
var() float			BotSkills[8];
var() float			BotAccuracy[8];
var() float			CombatStyle[8];
var() float			Camping[8];
var() string		FavoriteWeapon[8];
var() string		BotClasses[8];
var() string		BotSkins[8];
var() string		BotFaces[8];
var() localized string		BotBio[8];
var() byte			BotJumpy[8];

var() class<TournamentPlayer> MaleClass;
var() string		MaleSkin;

var() class<TournamentPlayer> FemaleClass;
var() string		FemaleSkin;

static function string GetBotName(int n)
{
	return Default.BotNames[n];
}

static function string GetBotDesc(int n)
{
	return Default.BotBio[n];
}

static function string GetBotClassification(int n)
{
	return Default.BotClassifications[n];
}

static function string GetBotSkin(int n)
{
	return Default.BotSkins[n];
}

static function string GetBotFace(int n)
{
	return Default.BotFaces[n];
}

static function string GetBotClassName(int n)
{
	return Default.BotClasses[n];
}

function class<bot> GetBotClass(int n)
{
	return class<bot>( DynamicLoadObject(BotClasses[n], class'Class') );
}

static function string GetTeamName()
{
	return Default.TeamName;
}

static function string GetTeamBio()
{
	return Default.TeamBio;
}

static function texture GetTeamSymbol()
{
	return Default.TeamSymbol;
}

function Individualize(bot NewBot, int n, int NumBots, bool bEnemy, float BaseDifficulty)
{
	if ( (n<0) || (n>7) )
	{
		log("Accessed RatedTeamInfo out of range!");
		return;
	}

	// Set bot's name.
	Level.Game.ChangeName( NewBot, BotNames[n], false );
	if ( BotNames[n] != NewBot.PlayerReplicationInfo.PlayerName )
		Level.Game.ChangeName( NewBot, "Bot", false);

	// Set Bot Team
	if ( bEnemy )
	{
		if (DeathMatchPlus(Level.Game).RatedPlayer.PlayerReplicationInfo.Team == 1)
			NewBot.PlayerReplicationInfo.Team = 0;
		else if (DeathMatchPlus(Level.Game).RatedPlayer.PlayerReplicationInfo.Team == 0)
			NewBot.PlayerReplicationInfo.Team = 1;
	} else {
		NewBot.PlayerReplicationInfo.Team = DeathMatchPlus(Level.Game).RatedPlayer.PlayerReplicationInfo.Team;
	}

	NewBot.Static.SetMultiSkin(NewBot, BotSkins[n], BotFaces[n], NewBot.PlayerReplicationInfo.Team);

	// adjust bot skill
	NewBot.InitializeSkill(BaseDifficulty + BotSkills[n]);

	if ( (FavoriteWeapon[n] != "") && (FavoriteWeapon[n] != "None") )
		NewBot.FavoriteWeapon = class<Weapon>(DynamicLoadObject(FavoriteWeapon[n],class'Class'));
	NewBot.CombatStyle = NewBot.Default.CombatStyle + 0.7 * CombatStyle[n];
	NewBot.BaseAggressiveness = 0.5 * (NewBot.Default.Aggressiveness + NewBot.CombatStyle);
	NewBot.CampingRate = Camping[n];
	NewBot.bJumpy = ( BotJumpy[n] != 0 );
	NewBot.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(NewBot.VoiceType, class'Class'));
}
