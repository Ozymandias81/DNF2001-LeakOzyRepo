class dnFirstBloodMessage expands CriticalEventMessage;

#exec OBJ LOAD FILE=..\sounds\a_npcvoice.dfx

var localized string FirstBloodString;
var sound			 FirstBloodSound;

static function string GetString
(
	optional int					Switch,
	optional PlayerReplicationInfo	RelatedPRI_1, 
	optional PlayerReplicationInfo	RelatedPRI_2,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
)
{
	if (RelatedPRI_1 == None)
		return "";
	if (RelatedPRI_1.PlayerName == "")
		return "";

	return RelatedPRI_1.PlayerName@Default.FirstBloodString;
}

static simulated function ClientReceive
( 
	PlayerPawn						P,
	optional int					Switch,
	optional PlayerReplicationInfo	RelatedPRI_1, 
	optional PlayerReplicationInfo	RelatedPRI_2,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	// Only play first blood for the person that drew it
	if ( RelatedPRI_1 != P.PlayerReplicationInfo )
		return;

	P.ClientPlaySound( default.FirstBloodSound,, true );
}

defaultproperties
{
	bBeep=False
	DrawColor=(R=255,G=0,B=0)
	FirstBloodString="drew first blood!"
	FirstBloodSound=sound'a_npcvoice.Announcer.FirstBlood01'
}