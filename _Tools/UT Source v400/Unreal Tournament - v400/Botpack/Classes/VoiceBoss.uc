//=============================================================================
// VoiceBoss.
//=============================================================================
class VoiceBoss extends ChallengeVoicePack;

#exec OBJ LOAD FILE=..\Sounds\BossVoice.uax PACKAGE=BossVoice

function SetOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	if ( messageIndex == 3 )
	{
		if ( FRand() < 0.3 )
			messageIndex = 7;
		else if ( FRand() < 0.5 )
			messageIndex = 15;
	}
	else if ( messageIndex == 4 )
	{
		if ( FRand() < 0.3 )
			messageIndex = 6;
		else if ( FRand() < 0.5 )
			messageIndex = 13;
	}
	else if ( messageIndex == 10 )
	{
		SetTimer(3 + FRand(), false); // wait for initial request to be spoken
		if ( FRand() < 0.5 )
		{
			DelayedResponse = AckString[2]$","@GetCallSign(recipient);
			Phrase[0] = AckSound[2];
			PhraseTime[0] = AckTime[2];
			if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) )
			{
				Phrase[1] = NameSound[recipient.Team];
				PhraseTime[1] = NameTime[recipient.Team];
			}
			return;
		}
	}
	Super.SetOtherMessage(messageIndex, Recipient, MessageSound, MessageTime);
}

defaultproperties
{
	NameSound(0)=BossVoice.BRedLeader
	NameSound(1)=BossVoice.BBlueLeader
	NameSound(2)=BossVoice.BGreenLeader
	NameSound(3)=BossVoice.BGoldLeader
	NameTime(0)=0.96
	NameTime(1)=1.10
	NameTime(2)=1.02
	NameTime(3)=0.99

	numAcks=3
	AckSound(0)=BossVoice.BGotIt
	AckSound(1)=BossVoice.BRoger
	AckSound(2)=BossVoice.BOnMyWay
	AckTime(0)=0.78
	AckTime(1)=0.81
	AckTime(2)=0.98
	AckString(0)="Got it"
	AckString(1)="Roger"
	AckString(2)="On my way"

	numFFires=2
	FFireSound(0)=BossVoice.BOnYourTeam
	FFireSound(1)=BossVoice.BSameTeam
	FFireString(0)="I'm on your team!"
	FFireAbbrev(0)="On your team!"
	FFireString(1)="Same team!"

	numTaunts=20
	TauntSound(0)=BossVoice.BBowDown
	TauntSound(1)=BossVoice.BDieHuman
	TauntSound(2)=BossVoice.BEliminated
	TauntSound(3)=BossVoice.BYouDie
	TauntSound(4)=BossVoice.BUseless
	TauntSound(5)=BossVoice.BFearMe
	TauntSound(6)=BossVoice.BInferior
	TauntSound(7)=BossVoice.BObsolete
	TauntSound(8)=BossVoice.BOmega
	TauntSound(9)=BossVoice.BRunHuman
	TauntSound(10)=BossVoice.BStepAside
	TauntSound(11)=BossVoice.BSuperior
	TauntSound(12)=BossVoice.BPerfection
	TauntSound(13)=BossVoice.BBoom
	TauntSound(14)=BossVoice.BMyHouse
	TauntSound(15)=BossVoice.BNext
	TauntSound(16)=BossVoice.BBurnbaby
	TauntSound(17)=BossVoice.BWantSome
	TauntSound(18)=BossVoice.BHadtoHurt
	TauntSound(19)=BossVoice.BImOnFire
	TauntString(0)="Bow down!"
	TauntString(1)="Die, human."
	TauntString(2)="Target lifeform eliminated."
	TauntAbbrev(2)="Target lifeform."
	TauntString(3)="You die too easily."
	TauntString(4)="Useless."
	TauntString(5)="Fear me."
	TauntString(6)="You are inferior."
	TauntString(7)="You are obsolete."
	TauntString(8)="I am the alpha and the omega."
	TauntAbbrev(8)="Alpha/Omega"
	TauntString(9)="Run, human."
	TauntString(10)="Step aside."
	TauntString(11)="I am superior."
	TauntString(12)="Witness my perfection."
	TauntString(13)="Boom!"
	TauntString(14)="My house."
	TauntString(15)="Next."
	TauntString(16)="Burn, baby"
	TauntString(17)="Anyone else want some?"
	TauntString(18)="That had to hurt."
	TauntString(19)="I'm on fire"

	OrderSound(0)=BossVoice.BDefendTheBase
	OrderSound(1)=BossVoice.BHoldPosit
	OrderSound(2)=BossVoice.BAssaultBase
	OrderSound(3)=BossVoice.BCoverme
	OrderSound(4)=BossVoice.BEngage
	OrderSound(10)=BossVoice.BTakeTheirFlag
	OrderSound(11)=BossVoice.Bsandd
	OrderString(0)="Defend the base."
	OrderAbbrev(0)="Defend"
	OrderString(1)="Hold this position."
	OrderString(2)="Assault the base."
	OrderAbbrev(2)="Attack"
	OrderString(3)="Cover me."
	OrderString(4)="Engage according to operational parameters."
	OrderAbbrev(4)="Freelance."
	OrderString(10)="Take their flag."
	OrderString(11)="Search and destroy."

	OtherSound(0)=BossVoice.BBaseUnc
	OtherSound(1)=BossVoice.Bgetourflag
	OtherSound(2)=BossVoice.BGotTheFlag
	OtherSound(3)=BossVoice.Bgotyourback
	OtherSound(4)=BossVoice.BImHit
	OtherSound(5)=BossVoice.BManDown
	OtherSound(6)=BossVoice.BUnderAttack
	OtherSound(7)=BossVoice.BYouGotPoint
	OtherSound(8)=BossVoice.BGotOurFlag
	OtherSound(9)=BossVoice.BInPosition
	OtherSound(10)=BossVoice.BHangInThere
	OtherSound(11)=BossVoice.BConPointSecure
	OtherSound(12)=BossVoice.BFlagCarrierHer
	OtherSound(13)=BossVoice.BBackup
	OtherSound(14)=BossVoice.BIncoming
	OtherSound(15)=BossVoice.BGotYourBack
	OtherSound(16)=BossVoice.BObjectiveDest
	OtherString(0)="Base is uncovered!"
	OtherString(1)="Get our flag back!"
	OtherAbbrev(1)="Get our flag!"
	OtherString(2)="I've got the flag."
	OtherAbbrev(2)="Got the flag."
	OtherString(3)="I've got your back."
	OtherAbbrev(3)="Got your back."
	OtherString(4)="I'm hit!"
	OtherString(5)="Man down!"
	OtherString(6)="I'm under heavy attack!"
	OtherAbbrev(6)="Under attack!"
	OtherString(7)="You got point."
	OtherString(8)="I've got our flag."
	OtherAbbrev(8)="Got our flag."
	OtherString(9)="I'm in position."
	OtherAbbrev(9)="In position."
	OtherString(10)="Hang in there."
	OtherString(11)="Control point is secure."
	OtherAbbrev(11)="Point is secure."
	OtherString(12)="Enemy flag carrier is here."
	OtherAbbrev(12)="Enemy carrier here."
	OtherString(13)="I need some backup."
	OtherString(14)="Incoming!"
	OtherString(15)="I've got your back."
	OtherAbbrev(15)="Got your back."
	OtherString(16)="Objective destroyed."
}