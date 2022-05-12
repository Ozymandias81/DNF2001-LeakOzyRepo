//=============================================================================
// ChallengeVoicePack.
//=============================================================================
class ChallengeVoicePack extends VoicePack
	abstract;

var() Sound NameSound[4]; // leader names
var() localized float NameTime[4];

var() Sound AckSound[16]; // acknowledgement sounds
var() localized string AckString[16];
var() localized string AckAbbrev[16];
var() localized float AckTime[16];
var() int numAcks;

var() Sound FFireSound[16];
var() localized string FFireString[16];
var() localized string FFireAbbrev[16];
var() int numFFires;

var() Sound TauntSound[32];
var() localized string TauntString[32];
var() localized string TauntAbbrev[32];
var() int numTaunts;
var() byte MatureTaunt[32];
var   name SendType[5];

var localized String LeaderSign[4];

/* Orders (in same order as in Orders Menu 
	0 = Defend, 
	1 = Hold, 
	2 = Attack, 
	3 = Follow, 
	4 = FreeLance
*/
var() Sound OrderSound[16];
var() localized string OrderString[16];
var() localized string OrderAbbrev[16];

/* Other messages - use passed messageIndex
	0 = Base Undefended
	1 = Get Flag
	2 = Got Flag
	3 = Back up
	4 = Im Hit
	5 = Under Attack
	6 = Man Down
*/
var() Sound OtherSound[32];
var() localized string OtherString[32];
var() localized string OtherAbbrev[32];

var Sound Phrase[8];
var float PhraseTime[8];
var int PhraseNum;
var string DelayedResponse;
var bool bDelayedResponse;
var PlayerReplicationInfo DelayedSender;

function string GetCallSign( PlayerReplicationInfo P )
{
	if ( P == None )
		return "";
	if ( (Level.NetMode == NM_Standalone) && (P.TeamID == 0) )
		return LeaderSign[P.Team];
	else
		return P.PlayerName;
}

function BotInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	local int m;
	local Sound MessageSound;
	local float MessageTime;

	if ( messagetype == 'ACK' )
		SetAckMessage(messageIndex, Recipient, MessageSound, MessageTime);
	else
	{
		SetTimer(0.1, false);
		if ( recipient != None )
		{
			if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) )
			{
				Phrase[0] = NameSound[recipient.Team];
				PhraseTime[0] = NameTime[recipient.Team];
				m = 1;
			}
			DelayedResponse = GetCallSign(Recipient)$", ";
		}	
		else
			m = 0;
		if ( messagetype == 'FRIENDLYFIRE' )
			SetFFireMessage(messageIndex, Recipient, MessageSound, MessageTime);
		else if ( (messagetype == 'AUTOTAUNT') || (messagetype == 'TAUNT') )
			SetTauntMessage(messageIndex, Recipient, MessageSound, MessageTime);
		else if ( messagetype == 'ORDER' )
			SetOrderMessage(messageIndex, Recipient, MessageSound, MessageTime);
		else // messagetype == Other
			SetOtherMessage(messageIndex, Recipient, MessageSound, MessageTime);

		Phrase[m] = MessageSound;
		PhraseTime[m] = MessageTime;
	}
}

function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	local int m;
	local Sound MessageSound;
	local float MessageTime;

	DelayedSender = Sender;
	bDelayedResponse = true;

	if ( Sender.bIsABot )
	{
		BotInitialize(Sender, Recipient, messagetype, messageIndex);
		return;
	}

	SetTimer(0.1, false);

	if ( messagetype == 'ACK' )
		SetClientAckMessage(messageIndex, Recipient, MessageSound, MessageTime);
	else
	{
		if ( recipient != None )
		{
			if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) )
			{
				Phrase[0] = NameSound[recipient.Team];
				PhraseTime[0] = NameTime[recipient.Team];
				m = 1;
			}
			DelayedResponse = GetCallSign(Recipient)$", ";
		}
		else if ( (messageType == 'OTHER') && (messageIndex == 9) )
		{
			Phrase[0] = NameSound[Sender.Team];
			PhraseTime[0] = NameTime[Sender.Team];
			m = 1;
		}
		else
			m = 0;
		if ( messagetype == 'FRIENDLYFIRE' )
			SetClientFFireMessage(messageIndex, Recipient, MessageSound, MessageTime);
		else if ( messagetype == 'TAUNT' )
			SetClientTauntMessage(messageIndex, Recipient, MessageSound, MessageTime);
		else if ( messagetype == 'AUTOTAUNT' )
		{
			SetClientTauntMessage(messageIndex, Recipient, MessageSound, MessageTime);
			SetTimer(0.8, false);
		}
		else if ( messagetype == 'ORDER' )
			SetClientOrderMessage(messageIndex, Recipient, MessageSound, MessageTime);
		else // messagetype == Other
			SetClientOtherMessage(messageIndex, Recipient, MessageSound, MessageTime);
	}
	Phrase[m] = MessageSound;
	PhraseTime[m] = MessageTime;
}

function SetClientAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	messageIndex = Clamp(messageIndex, 0, numAcks-1);

	if (Recipient != None)
		DelayedResponse = AckString[messageIndex]$","@GetCallsign(Recipient);
	else
		DelayedResponse = AckString[messageIndex];

	MessageSound = AckSound[messageIndex];
	MessageTime = AckTime[messageIndex];

	if ( (Recipient != None) && (Level.NetMode == NM_Standalone) 
		&& (recipient.TeamID == 0) && PlayerPawn(Owner).GameReplicationInfo.bTeamGame )
	{
		Phrase[1] = NameSound[Recipient.Team];
		PhraseTime[1] = NameTime[Recipient.Team];
	}
}

function SetAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	DelayedResponse = AckString[messageIndex]$","@GetCallSign(recipient);
	SetTimer(3 + FRand(), false); // wait for initial order to be spoken
	Phrase[0] = AckSound[messageIndex];
	PhraseTime[0] = AckTime[messageIndex];
	if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) && PlayerPawn(Owner).GameReplicationInfo.bTeamGame )
	{
		Phrase[1] = NameSound[recipient.Team];
		PhraseTime[1] = NameTime[recipient.Team];
	}
}

function SetClientFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	messageIndex = Clamp(messageIndex, 0, numFFires-1);

	DelayedResponse = DelayedResponse$FFireString[messageIndex];
	MessageSound = FFireSound[messageIndex];
}

function SetFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	DelayedResponse = DelayedResponse$FFireString[messageIndex];
	MessageSound = FFireSound[messageIndex];
}

function SetClientTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	messageIndex = Clamp(messageIndex, 0, numTaunts-1);

	// check if need to avoid a mature taunt
	if ( class'TournamentPlayer'.Default.bNoMatureLanguage || class'DeathMatchPlus'.Default.bLowGore )
	{
		while ( MatureTaunt[messageIndex] > 0 )
			messageIndex--;

		if ( messageIndex < 0 )
		{
			SetTimer(0.0, false);
			Destroy();
			return;
		}
	}
	DelayedResponse = DelayedResponse$TauntString[messageIndex];
	MessageSound = TauntSound[messageIndex];
}

function SetTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	// check if need to avoid a mature taunt
	if ( class'TournamentPlayer'.Default.bNoMatureLanguage || class'DeathMatchPlus'.Default.bLowGore )
	{
		while ( MatureTaunt[messageIndex] > 0 )
			messageIndex--;

		if ( messageIndex < 0 )
		{
			SetTimer(0.0, false);
			Destroy();
			return;
		}
	}
	DelayedResponse = DelayedResponse$TauntString[messageIndex];
	MessageSound = TauntSound[messageIndex];
	SetTimer(1.0, false);
}

function SetClientOrderMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	DelayedResponse = DelayedResponse$OrderString[messageIndex];
	MessageSound = OrderSound[messageIndex];
}

function SetOrderMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	if ( messageIndex == 2 )
	{
		if ( Level.Game.IsA('CTFGame') )
			messageIndex = 10;
	}
	else if ( messageIndex == 4 )
	{
		if ( FRand() < 0.4 )
			messageIndex = 11;
	}
	DelayedResponse = DelayedResponse$OrderString[messageIndex];
	MessageSound = OrderSound[messageIndex];
}

// for Voice message popup menu - since order names may be replaced for some game types
static function string GetOrderString(int i, string GameType )
{
	if ( i > 9 )
		return ""; //high index order strings are alternates to the base orders 
	if (i == 2)
	{
		if (GameType == "Capture the Flag")
		{
			if ( Default.OrderAbbrev[10] != "" )
				return Default.OrderAbbrev[10];
			else
				return Default.OrderString[10];
		} else if (GameType == "Domination") {
			if ( Default.OrderAbbrev[11] != "" )
				return Default.OrderAbbrev[11];
			else
				return Default.OrderString[11];
		}
	}

	if ( Default.OrderAbbrev[i] != "" )
		return Default.OrderAbbrev[i];

	return Default.OrderString[i];
}

function SetClientOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	DelayedResponse = DelayedResponse$OtherString[messageIndex];
	MessageSound = OtherSound[messageIndex];
}

function SetOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	DelayedResponse = DelayedResponse$OtherString[messageIndex];
	MessageSound = OtherSound[messageIndex];
}

function Timer()
{
	local name MessageType;

	if ( bDelayedResponse )
	{
		bDelayedResponse = false;
		if ( Owner.IsA('PlayerPawn') )
		{
			if ( PlayerPawn(Owner).GameReplicationInfo.bTeamGame 
				 && (PlayerPawn(Owner).PlayerReplicationInfo.Team == DelayedSender.Team) )
				MessageType = 'TeamSay';
			else
				MessageType = 'Say';
			PlayerPawn(Owner).TeamMessage(DelayedSender, DelayedResponse, MessageType, false);
		}
	}
	if ( Phrase[PhraseNum] != None )
	{
		if ( Owner.IsA('PlayerPawn') && !PlayerPawn(Owner).bNoVoices 
			&& (Level.TimeSeconds - PlayerPawn(Owner).LastPlaySound > 2)  ) 
		{
			if ( (PlayerPawn(Owner).ViewTarget != None) && !PlayerPawn(Owner).ViewTarget.IsA('Carcass') )
			{
				PlayerPawn(Owner).ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Interface, 16.0);
				PlayerPawn(Owner).ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Misc, 16.0);
			}
			else
			{
				PlayerPawn(Owner).PlaySound(Phrase[PhraseNum], SLOT_Interface, 16.0);
				PlayerPawn(Owner).PlaySound(Phrase[PhraseNum], SLOT_Misc, 16.0);
			}
		}
		if ( PhraseTime[PhraseNum] == 0 )
			Destroy();
		else
		{
			SetTimer(PhraseTime[PhraseNum], false);
			PhraseNum++;
		}
	}
	else 
		Destroy();
}

function PlayerSpeech( int Type, int Index, int Callsign )
{
	local name SendMode;
	local PlayerReplicationInfo Recipient;
	local Pawn P;

	switch (Type)
	{
		case 0:			// Acknowledgements
			SendMode = 'TEAM';		// Only send to team.
			Recipient = None;		// Send to everyone.
			break;
		case 1:			// Friendly Fire
			SendMode = 'TEAM';		// Only send to team.
			Recipient = None;		// Send to everyone.
			break;
		case 2:			// Orders
			SendMode = 'TEAM';		// Only send to team.
			if (Index == 2)
			{
				if (Level.Game.IsA('CTFGame'))
					Index = 10;
				if (Level.Game.IsA('Domination'))
					Index = 11;
			}
			if ( PlayerPawn(Owner).GameReplicationInfo.bTeamGame )
			{
				if ( Callsign == -1 )
					Recipient = None;
				else {
					for ( P=Level.PawnList; P!=None; P=P.NextPawn )
						//if ( P.bIsPlayer && (P.PlayerReplicationInfo.TeamId == Callsign)
						if ( (P.PlayerReplicationInfo.TeamId == Callsign)
							&& (P.PlayerReplicationInfo.Team == PlayerPawn(Owner).PlayerReplicationInfo.Team) )
						{
							Recipient = P.PlayerReplicationInfo;
							break;
						}
				}
			}
			break;
		case 3:			// Taunts
			SendMode = 'GLOBAL';	// Send to all teams.
			Recipient = None;		// Send to everyone.
			break;
		case 4:			// Other
			SendMode = 'TEAM';		// Only send to team.
			Recipient = None;		// Send to everyone.
			break;
	}
	if (!PlayerPawn(Owner).GameReplicationInfo.bTeamGame)
		SendMode = 'GLOBAL';  // Not a team game? Send to everyone.

	Pawn(Owner).SendVoiceMessage( Pawn(Owner).PlayerReplicationInfo, Recipient, SendType[Type], Index, SendMode );
}

static function string GetAckString(int i)
{
	if ( Default.AckAbbrev[i] != "" )
		return Default.AckAbbrev[i];

	return default.AckString[i];
}

static function string GetFFireString(int i)
{
	if ( default.FFireAbbrev[i] != "" )
		return default.FFireAbbrev[i];

	return default.FFireString[i];
}

static function string GetTauntString(int i)
{
	if ( default.TauntAbbrev[i] != "" )
		return default.TauntAbbrev[i];
	
	return default.TauntString[i];
}

static function string GetOtherString(int i)
{
	if ( Default.OtherAbbrev[i] != "" )
		return default.OtherAbbrev[i];
	
	return default.OtherString[i];
}

DefaultProperties
{
	LeaderSign(0)="Red Leader"
	LeaderSign(1)="Blue Leader"
	LeaderSign(2)="Green Leader"
	LeaderSign(3)="Gold Leader"
	LifeSpan=10.0
	SendType(0)=ACK
	SendType(1)=FRIENDLYFIRE
	SendType(2)=ORDER
	SendType(3)=TAUNT
	SendType(4)=OTHER
}