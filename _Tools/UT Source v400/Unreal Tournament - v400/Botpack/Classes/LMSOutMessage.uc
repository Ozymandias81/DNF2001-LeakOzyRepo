//
// RelatedPRI_1 is the player who is out.
//
class LMSOutMessage expands CriticalEventLowPlus;

var localized string OutMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == None)
		return "";
	return RelatedPRI_1.PlayerName@Default.OutMessage;
}

defaultproperties
{
	 OutMessage="is OUT!"
}
