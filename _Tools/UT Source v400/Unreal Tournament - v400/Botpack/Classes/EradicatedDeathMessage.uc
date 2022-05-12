class EradicatedDeathMessage expands DeathMessagePlus;

var localized string EradicatedMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	if (RelatedPRI_1 == None)
		return "";
	if (RelatedPRI_1.PlayerName == "")
		return "";
	if (RelatedPRI_2 == None)
		return "";
	if (RelatedPRI_2.PlayerName == "")
		return "";
	return RelatedPRI_2.PlayerName@Default.EradicatedMessage@RelatedPRI_1.PlayerName$"!!";
}

defaultproperties
{
	EradicatedMessage="was eradicated by the unholy power of"
}