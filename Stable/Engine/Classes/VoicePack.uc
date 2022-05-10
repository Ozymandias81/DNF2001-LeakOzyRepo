//=============================================================================
// VoicePack.
//=============================================================================
class VoicePack extends Info
	abstract;

var()		sound 					Drown;
var()		sound					BreathAgain;
var()		sound					GaspSound;
var()		sound					PainSounds[4];
var()		sound					MajorPainSounds[4];
var()		sound					Falling_PainSounds[4];
var()		sound					Falling_MajorPainSounds[4];
var()		sound					UnderWaterPain;
var()		sound					DeathSounds[6];
var()		sound					LandGrunt;
var()		sound					SwallowSound;
var()		sound					MirrorSounds[5];
var()		sound					KillSounds[12];
var()		sound					MessyKillSounds[12];
var()		sound					KungFuKill;
var()		sound					TestSound;
									
var()		int						NumMirrorSounds;
var()		int						NumDeathSounds;
var()		int						NumKillSounds;
var()		int						NumMessyKillSounds;
var()		int						NumFallingMajorPainSounds;
var()		int						NumFallingPainSounds;
var()       int                     NumPainSounds;

var()		Sound					NameSound[4]; // leader names
var()		localized float			NameTime[4];
									
var()		Sound					AckSound[16]; // acknowledgement sounds
var()		localized string		AckString[16];
var()		localized string		AckAbbrev[16];
var()		localized float			AckTime[16];
var()		int						numAcks;
									
var()		Sound					FFireSound[16]; // Friendly fire messages
var()		localized string		FFireString[16];
var()		localized string		FFireAbbrev[16];
var()		int						numFFires;
			
var()		Sound					TauntSound[32];	// Taunts
var()		localized string		TauntString[32];
var()		localized string		TauntAbbrev[32];
var()		int						numTaunts;
			
var()		byte					MatureTaunt[32]; // Mark true for all mature level taunts
var			name					SendType[5];


/* Orders (in same order as in Orders Menu 
	0 = Defend, 
	1 = Hold, 
	2 = Attack, 
	3 = Follow, 
	4 = FreeLance
*/
var()		Sound					OrderSound[16];
var()		localized string		OrderString[16];
var()		localized string		OrderAbbrev[16];

var			localized string		CommaText;

/* Other messages - use passed messageIndex
	0 = Base Undefended
	1 = Get Flag
	2 = Got Flag
	3 = Back up
	4 = Im Hit
	5 = Under Attack
	6 = Man Down
*/
var()		Sound					OtherSound[32];
var()		localized string		OtherString[32];
var()		localized string		OtherAbbrev[32];

var			Sound					Phrase[8];
var			float					PhraseTime[8];
var			int						PhraseNum;
var			string					DelayedResponse;
var			bool					bDelayedResponse;
var			PlayerReplicationInfo	DelayedSender;

function ClientInitialize( PlayerReplicationInfo Sender, 
						   PlayerReplicationInfo Recipient,
						   name messagetype,
						   byte messageIndex );

function PlayerSpeech(int Type, int Index, int Callsign);

defaultproperties
{	
	bStatic=false
	LifeSpan=10.0

	SendType(0)=ACK
	SendType(1)=FRIENDLYFIRE
	SendType(2)=ORDER
	SendType(3)=TAUNT
	SendType(4)=OTHER
	
	CommaText=", "
	
    RemoteRole=ROLE_None
}	
