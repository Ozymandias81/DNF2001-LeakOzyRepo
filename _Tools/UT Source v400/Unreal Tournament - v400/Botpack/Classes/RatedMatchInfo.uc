//=============================================================================
// RatedMatchInfo.
// used in single player game - cannot modify
// player team (bots 0 to 7) are set up in default properties of this base class
// enemy teams are set up in default properties of sub-classes
//=============================================================================
class RatedMatchInfo extends Info;

var() int						NumBots;			// total number of bots
var() int						NumAllies;			// number of allied bots

var() float						ModifiedDifficulty;	// how much to modify base difficulty for this match (0 to 5)

var() class<RatedTeamInfo>		EnemyTeam;

var() string					BotNames[8];
var() localized string			BotClassifications[8];
var() int						BotTeams[8];
var() float						BotSkills[8];
var() float						BotAccuracy[8];
var() float						CombatStyle[8];
var() float						Camping[8];
var() string					FavoriteWeapon[8];
var() string 					BotClasses[8];
var() string 					BotSkins[8];
var() string 					BotFaces[8];
var() localized string			Bio[8];
var() byte						BotJumpy[8];
var() float						StrafingAbility[8];

var int							CurrentNum;
var int							CurrentAlly;

function string GetTeamName(optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (bEnemy)
	{
		LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

		if (EnemyTeam == LadderObj.Team)
			return class'RatedTeamInfoS'.Default.TeamName;
		else
			return EnemyTeam.Default.TeamName;
	} else {
		LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
		return LadderObj.Team.Default.TeamName;
	}
}

function string GetTeamBio(optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (bEnemy)
	{
		LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

		if (EnemyTeam == LadderObj.Team)
			return class'RatedTeamInfoS'.Default.TeamBio;
		else
			return EnemyTeam.Default.TeamBio;
	} else {
		LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
		return LadderObj.Team.Default.TeamBio;
	}
}

function texture GetTeamSymbol(optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (bEnemy)
	{
		LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

		if (EnemyTeam == LadderObj.Team)
			return class'RatedTeamInfoS'.Default.TeamSymbol;
		else
			return EnemyTeam.Default.TeamSymbol;
	} else {
		LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
		return LadderObj.Team.Default.TeamSymbol;
	}
}

function string GetBotName(int n, optional bool bTeamGame, optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (!bTeamGame)
		return Default.BotNames[n];
	else {
		if (bEnemy)
		{
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

			if (EnemyTeam == LadderObj.Team)
				return class'RatedTeamInfoS'.Default.BotNames[n];
			else
				return EnemyTeam.Default.BotNames[n];
		} else {
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
			return LadderObj.Team.Default.BotNames[n];
		}
	}
}

function string GetBotDesc(int n, optional bool bTeamGame, optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (!bTeamGame)
		return Default.Bio[n];
	else {
		if (bEnemy)
		{
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

			if (EnemyTeam == LadderObj.Team)
				return class'RatedTeamInfoS'.Default.BotBio[n];
			else
				return EnemyTeam.Default.BotBio[n];
		} else {
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
			return LadderObj.Team.Default.BotBio[n];
		}
	}
}

function string GetBotClassification(int n, optional bool bTeamGame, optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (!bTeamGame)
		return Default.BotClassifications[n];
	else {
		if (bEnemy)
		{
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

			if (EnemyTeam == LadderObj.Team)
				return class'RatedTeamInfoS'.Default.BotClassifications[n];
			else
				return EnemyTeam.Default.BotClassifications[n];
		} else {
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
			return LadderObj.Team.Default.BotClassifications[n];
		}
	}
}

function int GetBotTeam(int n, optional bool bTeamGame, optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	return Default.BotTeams[n];
}

function string GetBotSkin(int n, optional bool bTeamGame, optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (!bTeamGame)
		return Default.BotSkins[n];
	else {
		if (bEnemy)
		{
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

			if (EnemyTeam == LadderObj.Team)
				return class'RatedTeamInfoS'.Default.BotSkins[n];
			else
				return EnemyTeam.Default.BotSkins[n];
		} else {
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
			return LadderObj.Team.Default.BotSkins[n];
		}
	}
}

function string GetBotFace(int n, optional bool bTeamGame, optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (!bTeamGame)
		return Default.BotFaces[n];
	else {
		if (bEnemy)
		{
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

			if (EnemyTeam == LadderObj.Team)
				return class'RatedTeamInfoS'.Default.BotFaces[n];
			else
				return EnemyTeam.Default.BotFaces[n];
		} else {
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
			return LadderObj.Team.Default.BotFaces[n];			
		}
	}
}

function string GetBotClassName(int n, optional bool bTeamGame, optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (!bTeamGame)
		return Default.BotClasses[n];
	else {
		if (bEnemy)
		{
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
		
			if (EnemyTeam == LadderObj.Team)
				return class'RatedTeamInfoS'.Default.BotClasses[n];
			else
				return EnemyTeam.Default.BotClasses[n];
		} else {
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
			return LadderObj.Team.Default.BotClasses[n];
		}
	}
}

function class<bot> GetBotClass(int n, optional bool bTeamGame, optional bool bEnemy, optional PlayerPawn RatedPlayer)
{
	local LadderInventory LadderObj;

	if (!bTeamGame)
		return class<bot>( DynamicLoadObject(BotClasses[n], class'Class') );
	else {
		if (bEnemy)
		{
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

			if (EnemyTeam == LadderObj.Team)
				return class<bot>( DynamicLoadObject(class'RatedTeamInfoS'.Default.BotClasses[n], class'Class') );
			else
				return class<bot>( DynamicLoadObject(EnemyTeam.Default.BotClasses[n], class'Class') );
		} else {
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

			return class<bot>( DynamicLoadObject(LadderObj.Team.Default.BotClasses[n], class'Class') );
		}
	}
}

function int ChooseBotInfo(optional bool bTeamGame, optional bool bEnemy)
{
	if (!bTeamGame)
	{
		return CurrentNum++;
	} else {
		if (bEnemy)
			return CurrentNum++;
		else
			return CurrentAlly++;
	}
}

function Individualize(bot NewBot, int n, int NumBots, optional bool bTeamGame, optional bool bEnemy)
{
	local LadderInventory LadderObj;
	local PlayerPawn RatedPlayer;
	local RatedTeamInfo RTI;

	if ( (n<0) || (n>7) )
	{
		log("Accessed RatedMatchInfo out of range!");
		return;
	}

	if (!bTeamGame)
	{
		NewBot.Static.SetMultiSkin(NewBot, BotSkins[n], BotFaces[n], BotTeams[n]);

		// Set bot's name.
		Level.Game.ChangeName( NewBot, BotNames[n], false );
		if ( BotNames[n] != NewBot.PlayerReplicationInfo.PlayerName )
			Level.Game.ChangeName( NewBot, "Bot", false);

		// Set Bot Team
		if ( BotTeams[n] == 0 )
			NewBot.PlayerReplicationInfo.Team = DeathMatchPlus(Level.Game).RatedPlayer.PlayerReplicationInfo.Team;
		else if ( DeathMatchPlus(Level.Game).RatedPlayer.PlayerReplicationInfo.Team == 0 )
			NewBot.PlayerReplicationInfo.Team = 1;
		else
			NewBot.PlayerReplicationInfo.Team = 1;

		// adjust bot skill
		RatedPlayer = DeathMatchPlus(Level.Game).RatedPlayer;
		LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
		NewBot.InitializeSkill(LadderObj.TournamentDifficulty + ModifiedDifficulty + BotSkills[n]);

		if ( (FavoriteWeapon[n] != "") && (FavoriteWeapon[n] != "None") )
			NewBot.FavoriteWeapon = class<Weapon>(DynamicLoadObject(FavoriteWeapon[n],class'Class'));
		NewBot.CombatStyle = NewBot.Default.CombatStyle + 0.7 * CombatStyle[n];
		NewBot.BaseAggressiveness = 0.5 * (NewBot.Default.Aggressiveness + NewBot.CombatStyle);
		NewBot.CampingRate = Camping[n];
		NewBot.bJumpy = ( BotJumpy[n] != 0 );
		NewBot.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(NewBot.VoiceType, class'Class'));
		NewBot.StrafingAbility = StrafingAbility[n];
	} 
	else 
	{
		if ( bEnemy )
		{
			RatedPlayer = DeathMatchPlus(Level.Game).RatedPlayer;
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));

			if (EnemyTeam == LadderObj.Team)
				RTI = Spawn(class'RatedTeamInfoS');
			else
				RTI = Spawn(EnemyTeam);
			RTI.Individualize(NewBot, n, NumBots, bEnemy, LadderObj.TournamentDifficulty + ModifiedDifficulty);
		} 
		else 
		{
			RatedPlayer = DeathMatchPlus(Level.Game).RatedPlayer;
			LadderObj = LadderInventory(RatedPlayer.FindInventoryType(class'LadderInventory'));
			RTI = Spawn(LadderObj.Team);
			RTI.Individualize(NewBot, n, NumBots, bEnemy, LadderObj.TournamentDifficulty + ModifiedDifficulty);
		}
	}
}
