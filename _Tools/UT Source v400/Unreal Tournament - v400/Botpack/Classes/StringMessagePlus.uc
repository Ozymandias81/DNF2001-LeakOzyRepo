class StringMessagePlus expands LocalMessagePlus;

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	return MessageString;
}

defaultproperties
{
	DrawColor=(R=255,G=255,B=255)
}