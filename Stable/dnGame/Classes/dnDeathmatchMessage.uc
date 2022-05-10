//
// Messages common to dnDeathMatchGame derivatives.
//
// Switch 0: OverTime
//
// Switch 1: Entered game.
//	RelatedPRI_1 is the player.
//
// Switch 2: Name change.
//	RelatedPRI_1 is the player.
//
// Switch 3: Team change.
//	RelatedPRI_1 is the player.
//	OptionalObject is a TeamInfo.
//
// Switch 4: Left game.
//	RelatedPRI_1 is the player.


class dnDeathMatchMessage expands LocalMessage;

var localized string OvertimeMessage;
var localized string GlobalNameChange;
var localized string NewTeamMessage;
var localized string NewTeamMessageTrailer;

static function string GetString
	(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject,
	optional class<Actor> OptionalClass
	)
{
	switch (Switch)
	{
		case 0:
			return Default.OverTimeMessage;
			break;
		case 1: // Entered the game
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.PlayerName$class'GameInfo'.Default.EnteredMessage;
			break;
		case 2: // Name change
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.OldName@Default.GlobalNameChange@RelatedPRI_1.PlayerName;
			break;
		case 3: // Team change
			if (RelatedPRI_1 == None)
				return "";
			if (OptionalObject == None)
				return "";

			return RelatedPRI_1.PlayerName@Default.NewTeamMessage@dnTeamInfo(OptionalObject).TeamName$Default.NewTeamMessageTrailer;
			break;
		case 4: // Left the game
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.PlayerName$class'GameInfo'.Default.LeftMessage;
			break;
	}
	return "";
}


defaultproperties
{
	OverTimeMessage="Score tied at the end of regulation. Sudden Death Overtime!!!"
	GlobalNameChange="changed name to"
	NewTeamMessage="is now a"
	NewTeamMessageTrailer="."
}