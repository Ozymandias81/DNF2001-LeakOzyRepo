class DecapitationMessage expands LocalMessagePlus;

var(Messages)	localized string 	DecapitationString;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY - 2*YL;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	return Default.DecapitationString;
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

	P.ClientPlaySound(sound'Announcer.HeadShot',, true);
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

	DecapitationString="Head Shot!!"
}