//
// Switch is the note.
// RelatedPRI_1 is the player on the spree.
//
class dnKillingSpreeMessage expands CriticalEventMessage;

var(Messages) localized string EndSpreeNote, EndSelfSpree, EndFemaleSpree;
var(Messages) localized string SpreeNote[10];
var(Messages) sound SpreeSound[10];
var(Messages) sound SpreeNotifySound;
var(Messages) localized string EndSpreeNoteTrailer;
 
static function string GetString
(
	optional int					Switch,
	optional PlayerReplicationInfo	RelatedPRI_1, 
	optional PlayerReplicationInfo	RelatedPRI_2,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
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
			return RelatedPRI_1.PlayerName$Default.EndSpreeNote@RelatedPRI_2.PlayerName@Default.EndSpreeNoteTrailer;
		}
	}
	return "";
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

	if ( RelatedPRI_2 != None )
		return;

	if ( RelatedPRI_1 != P.PlayerReplicationInfo )
	{
		// Someone is on a killing spree
		P.PlaySound( Default.SpreeNotifySound,, 4.0);
		return;
	}
	P.ClientPlaySound( Default.SpreeSound[Switch],, true );

}

defaultproperties
{
	bBeep=False
	EndSpreeNote="'s killing spree was ended by"
	EndSpreeNoteTrailer=""
	EndSelfSpree="was looking good till he killed himself!"
	EndFemaleSpree="was looking good till she killed herself!"
	SpreeNote(0)="is on a killing spree!"
	SpreeNote(1)="is on a rampage!"
	SpreeNote(2)="is dominating!"
	SpreeNote(3)="is unstoppable!"
	SpreeNote(4)="is Godlike!"	
	SpreeNotifySound=sound'a_dukevoice.DukeLines.DSeenNothin'
	SpreeSound(0)=sound'a_dukevoice.Mirror.DukeMirror3'
	SpreeSound(1)=sound'a_dukevoice.Mirror.DukeMirror3'
	SpreeSound(2)=sound'a_dukevoice.Mirror.DukeMirror3'
	SpreeSound(3)=sound'a_dukevoice.Mirror.DukeMirror3'
	SpreeSound(4)=sound'a_dukevoice.Mirror.DukeMirror3'	
	DrawColor=(R=255,G=0,B=0)
	//SpreeSound(0)=sound'Announcer.KillingSpree'
	//SpreeSound(1)=sound'Announcer.Rampage'
	//SpreeSound(2)=sound'Announcer.Dominating'
	//SpreeSound(3)=sound'Announcer.Unstoppable'
	//SpreeSound(4)=sound'Announcer.Godlike'
}
