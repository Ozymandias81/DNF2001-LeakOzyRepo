class FirstBloodMessage expands CriticalEventPlus;

var localized string FirstBloodString;

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
	return RelatedPRI_1.PlayerName@Default.FirstBloodString;
}

static simulated function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (RelatedPRI_1 != P.PlayerReplicationInfo)
		return;

	P.ClientPlaySound(sound'Announcer.FirstBlood',, true);
}

defaultproperties
{
	bBeep=False
	DrawColor=(R=255,G=0,B=0)
	FirstBloodString="drew first blood!"
}