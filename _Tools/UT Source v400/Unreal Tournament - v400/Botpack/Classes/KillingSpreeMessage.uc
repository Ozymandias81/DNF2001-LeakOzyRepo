//
// Switch is the note.
// RelatedPRI_1 is the player on the spree.
//
class KillingSpreeMessage expands CriticalEventLowPlus;

var(Messages)	localized string EndSpreeNote, EndSelfSpree, EndFemaleSpree, MultiKillString;
var(Messages)	localized string SpreeNote[10];
var(Messages)	sound SpreeSound[10];
 
static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_2 == None)
	{
		if (RelatedPRI_1 == None)
			return "";

		if (RelatedPRI_1.PlayerName != "")
			return RelatedPRI_1.PlayerName@Default.SpreeNote[Switch];
	} 
	else 
	{
		if (RelatedPRI_1 == None)
		{
			if (RelatedPRI_2.PlayerName != "")
			{
				if ( RelatedPRI_2.bIsFemale )
					return RelatedPRI_2.PlayerName@Default.EndFemaleSpree;
				else
					return RelatedPRI_2.PlayerName@Default.EndSelfSpree;
			}
		} 
		else 
		{
			return RelatedPRI_1.PlayerName$Default.EndSpreeNote@RelatedPRI_2.PlayerName;
		}
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

	if (RelatedPRI_2 != None)
		return;

	if (RelatedPRI_1 != P.PlayerReplicationInfo)
	{
		P.PlaySound(sound'SpreeSound',, 4.0);
		return;
	}
	P.ClientPlaySound(Default.SpreeSound[Switch],, true);

}

defaultproperties
{
	 bBeep=False
	 EndSpreeNote="'s killing spree was ended by"
	 EndSelfSpree="was looking good till he killed himself!"
	 EndFemaleSpree="was looking good till she killed herself!"
	 SpreeNote(0)="is on a killing spree!"
	 SpreeNote(1)="is on a rampage!"
	 SpreeNote(2)="is dominating!"
	 SpreeNote(3)="is unstoppable!"
	 SpreeNote(4)="is Godlike!"
	 SpreeSound(0)=sound'Announcer.KillingSpree'
	 SpreeSound(1)=sound'Announcer.Rampage'
	 SpreeSound(2)=sound'Announcer.Dominating'
	 SpreeSound(3)=sound'Announcer.Unstoppable'
	 SpreeSound(4)=sound'Announcer.Godlike'
}