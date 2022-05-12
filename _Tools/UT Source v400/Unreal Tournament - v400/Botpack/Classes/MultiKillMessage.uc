class MultiKillMessage extends LocalMessagePlus;

var(Messages)	localized string 	DoubleKillString;
var(Messages)	localized string 	TripleKillString;
var(Messages)	localized string 	MultiKillString;
var(Messages)	localized string 	UltraKillString;
var(Messages)	localized string 	MonsterKillString;


static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY + YL;
}

static function int GetFontSize( int Switch )
{
	if ( Switch == 1 )
		return Default.FontSize;
	else
		return 2;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	switch (Switch)
	{
		case 1:
			return Default.DoubleKillString;
			break;
		case 2:
			return Default.MultiKillString;
			break;
		case 3:
			return Default.UltraKillString;
			break;
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
			return Default.MonsterKillString;
			break;
	}
	return "";
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

	switch (Switch)
	{
		case 1:
			P.ClientPlaySound(sound'Announcer.DoubleKill',, true);
			break;
		case 2:
			P.ClientPlaySound(sound'Announcer.MultiKill',, true);
			break;
		case 3:
			P.ClientPlaySound(sound'Announcer.UltraKill',, true);
			break;
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
			P.ClientPlaySound(sound'Announcer.MonsterKill',, true);
			break;
	}
}

defaultproperties
{
	bFadeMessage=True
	bIsSpecial=True
	bIsUnique=True
	Lifetime=3
	bBeep=False

	DrawColor=(R=255,G=0,B=0)
	bCenter=True
	FontSize=1
	YPos=196

	DoubleKillString="Double Kill!"
	TripleKillString="Triple Kill!" // No triple kill.
	MultiKillString="Multi Kill!"
	UltraKillString="ULTRA KILL!!"
	MonsterKillString="M O N S T E R  K I L L !!!"
}