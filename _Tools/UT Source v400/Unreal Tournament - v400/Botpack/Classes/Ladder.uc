//=============================================================================
// Ladder
// A ladder game ladder.
//=============================================================================
class Ladder extends Info
	abstract
	config(user);

var() int			Matches;						// # of matches in ladder.
var() bool			bTeamGame;						// TeamGame ladder?
var() localized string	    Titles[9];						// Ranking titles.
var() string		MapPrefix;						// Match map prefix.

// 32 Matches
var() string	    Maps[32];						// Match map.
var() string	    MapAuthors[32];					// Map authors.
var() localized string	    MapTitle[32];					// Map title.
var() localized string	    MapDescription[32];				// Map description.
var() int			RankedGame[32];					// Rank to award upon completion.
var() int			GoalTeamScore[32];				// Match goalteamscore.
var() int			FragLimits[32];					// Match fraglimit.
var() int			TimeLimits[32];					// Match timelimit.
var() string		MatchInfo[32];					// BotConfig to use for each game
													// The botconfig has all the info about
													// individual bots in this match
var() int			DemoDisplay[32];				// This match is for demo display only.

var() class<RatedTeamInfo> LadderTeams[32];			// Teams that can be fought in this ladder
var() int			NumTeams;						// Number of LadderTeams

var   globalconfig bool	HasBeatenGame;

static function Class<RatedMatchInfo> GetMatchConfigType(int Index)
{
	return Class<RatedMatchInfo>(DynamicLoadObject(Default.MatchInfo[Index], class'Class'));
}

static function string GetMap( int Index )
{
	return Default.Maps[Index];
}

static function string GetAuthor( int Index )
{
	return Default.MapAuthors[Index];
}

static function string GetMapTitle( int Index )
{
	return Default.MapTitle[Index];
}

static function string GetDesc( int Index )
{
	return Default.MapDescription[Index];
}

static function string GetRank( int Index )
{
	return Default.Titles[Index];
}

static function int GetFragLimit( int Index )
{
	return Default.FragLimits[Index];
}

static function int GetGoalTeamScore( int Index )
{
	return Default.GoalTeamScore[Index];
}

defaultproperties
{
	Titles(0)="Untrained"
	Titles(1)="Contender"
	Titles(2)="Light Weight"
	Titles(3)="Heavy Weight"
	Titles(4)="Warlord"
	Titles(5)="Battle Master"
	Titles(6)="Champion"
	LadderTeams(0)=class'Botpack.RatedTeamInfo1'
	LadderTeams(1)=class'Botpack.RatedTeamInfo2'
	LadderTeams(2)=class'Botpack.RatedTeamInfo3'
	LadderTeams(3)=class'Botpack.RatedTeamInfo4'
	LadderTeams(4)=class'Botpack.RatedTeamInfo5'
	LadderTeams(5)=class'Botpack.RatedTeamInfo6'
	LadderTeams(6)=class'Botpack.RatedTeamInfoS'
	LadderTeams(7)=class'Botpack.RatedTeamInfoDemo1'
	LadderTeams(8)=class'Botpack.RatedTeamInfoDemo2'
	NumTeams=7
}
