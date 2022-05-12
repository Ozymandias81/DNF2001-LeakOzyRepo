class KillerMessagePlus expands LocalMessagePlus;

var localized string YouKilled;
var localized string ScoreString;


static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY - YL;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	if (RelatedPRI_1 == None)
		return "";
	if (RelatedPRI_2 == None)
		return "";

	if (RelatedPRI_2.PlayerName != "")
		return Default.YouKilled@RelatedPRI_2.PlayerName;
}

defaultproperties
{
	bFadeMessage=True
	bIsSpecial=True
	bIsUnique=True
	Lifetime=3

	DrawColor=(R=0,G=128,B=255)
	bCenter=True
	FontSize=1
	YPos=196

	ScoreString="Your Score:"
	YouKilled="You killed"
}
