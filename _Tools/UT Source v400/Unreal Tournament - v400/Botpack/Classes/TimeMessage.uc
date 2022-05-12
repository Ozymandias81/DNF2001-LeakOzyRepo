class TimeMessage extends CriticalEventPlus;

var localized string TimeMessage[16];
var Sound TimeSound[16];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.TimeMessage[Switch];
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

	P.PlaySound(Default.TimeSound[Switch],,4.0);
}

defaultproperties
{
	 bBeep=False
	 TimeMessage(0)="5 minutes left in the game!"
	 TimeMessage(1)=""
	 TimeMessage(2)="3 minutes left in the game!"
	 TimeMessage(3)="2 minutes left in the game!"
	 TimeMessage(4)="1 minute left in the game!"
	 TimeMessage(5)="30 seconds left!"
	 TimeMessage(6)="10 seconds left!"
	 TimeMessage(7)="9..."
	 TimeMessage(8)="8..."
	 TimeMessage(9)="7..."
	 TimeMessage(10)="6..."
	 TimeMessage(11)="5 seconds and counting..."
	 TimeMessage(12)="4..."
	 TimeMessage(13)="3..."
	 TimeMessage(14)="2..."
	 TimeMessage(15)="1..."
	 TimeSound(0)=sound'Announcer.CD5Min'
	 TimeSound(1)=None
	 TimeSound(2)=sound'Announcer.CD3Min'
	 TimeSound(3)=None
	 TimeSound(4)=sound'Announcer.CD1Min'
	 TimeSound(5)=sound'Announcer.CD3Sec'
	 TimeSound(6)=sound'Announcer.CD10'
	 TimeSound(7)=sound'Announcer.CD9'
	 TimeSound(8)=sound'Announcer.CD8'
	 TimeSound(9)=sound'Announcer.CD7'
	 TimeSound(10)=sound'Announcer.CD6'
	 TimeSound(11)=sound'Announcer.CD5'
	 TimeSound(12)=sound'Announcer.CD4'
	 TimeSound(13)=sound'Announcer.CD3'
	 TimeSound(14)=sound'Announcer.CD2'
	 TimeSound(15)=sound'Announcer.CD1'
}