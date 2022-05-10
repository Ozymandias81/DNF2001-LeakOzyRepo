class dnTeamGameMessage expands CriticalEventMessage;

var localized string HumansWinString;
var localized string BugsWinString;
var localized string TieGameString;
var localized string CantChangeClass_Time;
var localized string CantChangeClass_Credits;
var localized string CantChangeClass_Unknown;

static function string GetString
(
	optional int					Switch,
	optional PlayerReplicationInfo	RelatedPRI_1, 
	optional PlayerReplicationInfo	RelatedPRI_2,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
)
{
	switch ( Switch )
	{
	case -1:
		return default.TieGameString;
		break;
	case 0:
		return default.HumansWinString;
		break;
	case 1:
		return default.BugsWinString;
		break;
	case 2:
		return default.CantChangeClass_Time;
		break;
	case 3:
		return default.CantChangeClass_Credits;
		break;
	case 4:
		return default.CantChangeClass_Unknown;
		break;
	default:
		return "";
		break;
	}
}

defaultproperties
{
	bBeep=False
	DrawColor=(R=255,G=255,B=255)
	bIsConsoleMessage=true
	HumansWinString="Humans win the round."
	BugsWinString="Bugs win the round."
	TieGameString="Nobody wins the round."
	CantChangeClass_Time="It is too late to change your class"
	CantChangeClass_Credits="You don't have enough credits to change to that class"
	CantChangeClass_Unknown="Can't change to that class - It is unknown."
}

