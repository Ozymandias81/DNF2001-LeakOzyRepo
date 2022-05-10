class dnVictimMessage expands LocalMessage;

var localized string YouWereKilledBy, KilledByTrailer;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY + 2*YL;
}

static function string GetString
(
	optional int					Switch,
	optional PlayerReplicationInfo	KillerPRI, 
	optional PlayerReplicationInfo	VictimPRI,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
)
{
	if ( KillerPRI == None )
		return "";

	if ( KillerPRI.PlayerName != "" )
	{
		return Default.YouWereKilledBy @ KillerPRI.PlayerName $ Default.KilledByTrailer;
	}
}

defaultproperties
{
	Lifetime=3

	DrawColor=(R=255,G=0,B=0)
	bCenter=True
	FontSize=1
	YPos=100

	YouWereKilledBy="You were killed by"
	KilledByTrailer="!"
	bIsConsoleMessage=true
}
