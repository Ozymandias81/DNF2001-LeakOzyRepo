//=============================================================================
// VoiceMaleTwo.
//=============================================================================
class VoiceMaleTwo extends VoiceMale;

#exec OBJ LOAD FILE=..\Sounds\Male2Voice.uax PACKAGE=Male2Voice

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
	else if ( messageIndex == 5 )
	{
		if ( FRand() < 0.5 )
			messageIndex = 17;
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
	NameSound(0)=Male2Voice.M2RedLeader
	NameSound(1)=Male2Voice.M2BlueLeader
	NameSound(2)=Male2Voice.M2GreenLeader
	NameSound(3)=Male2Voice.M2GoldLeader
	NameTime(0)=0.96
	NameTime(1)=1.10
	NameTime(2)=1.02
	NameTime(3)=0.99

	numAcks=3
	AckSound(0)=Male2Voice.M2GotIt
	AckSound(1)=Male2Voice.M2Roger
	AckSound(2)=Male2Voice.M2OnMyWay
	AckTime(0)=0.78
	AckTime(1)=0.81
	AckTime(2)=0.98
	AckString(0)="Got it"
	AckString(1)="Roger"
	AckString(2)="On my way"

	numFFires=2
	FFireSound(0)=Male2Voice.M2SameTeam
	FFireSound(1)=Male2Voice.M2Idiot
	FFireString(0)="Hey! Same team!"
	FFireString(1)="I'm on your team, you idiot!"
	FFireAbbrev(1)="On your team!"

	numTaunts=25
	TauntSound(0)=Male2Voice.M2EatThat
	TauntSound(1)=Male2Voice.M2YaLikeThat
	TauntSound(2)=Male2Voice.M2Sucker
	TauntSound(3)=Male2Voice.M2Boom
	TauntSound(4)=Male2Voice.M2Burnbaby
	TauntSound(5)=Male2Voice.M2Yousuck
	TauntSound(6)=Male2Voice.M2DieBitch
	TauntSound(7)=Male2Voice.M2Loser
	TauntSound(8)=Male2Voice.M2Yeehaw
	TauntSound(9)=Male2Voice.M2OhYeah
	TauntSound(10)=Male2Voice.M2ThatHadToHurt
	TauntSound(11)=Male2Voice.M2Dirtbag
	TauntSound(12)=Male2Voice.M2myhouse
	TauntSound(13)=Male2Voice.M2BiteMe
	TauntSound(14)=Male2Voice.M2OnFire
	TauntSound(15)=Male2Voice.M2Useless
	TauntSound(16)=Male2Voice.M2Laugh
	TauntSound(17)=Male2Voice.M2Yoube
	TauntSound(18)=Male2Voice.M2Next
	TauntSound(19)=Male2Voice.M2Medic
	TauntSound(20)=Male2Voice.M2SeeYa
	TauntSound(21)=Male2Voice.M2Target
	TauntSound(22)=Male2Voice.M2WantSome
	TauntSound(23)=Male2Voice.M2Gotim
	TauntSound(24)=Male2Voice.M2Staydown
	TauntString(0)="Eat that!"
	TauntString(1)="You like that?"
	TauntString(2)="Sucker!"
	TauntString(3)="Boom!"
	TauntString(4)="Burn, baby"
	TauntString(5)="You suck!"
	TauntString(6)="Die, bitch."
	TauntString(7)="Loser."
	TauntString(8)="Yeehaw!"
	TauntString(9)="Oh, yeah!"
	TauntString(10)="That had to hurt."
	TauntString(11)="Dirt bag!"
	TauntString(12)="My house!"
	TauntString(13)="Bite me!"
	TauntString(14)="I'm on fire!"
	TauntString(15)="Useless."
	TauntString(16)="Ha ha ha!"
	TauntString(17)="You be dead!"
	TauntString(18)="Next!"
	TauntString(19)="Medic!"
	TauntString(20)="See ya!"
	TauntString(21)="Target eliminated."
	TauntString(22)="Anyone else want some?"
	TauntAbbrev(22)="Anyone else?"
	TauntString(23)="Got 'im!"
	TauntString(24)="And stay down!"
	MatureTaunt(6)=1
	MatureTaunt(13)=1

	OrderSound(0)=Male2Voice.M2Defend
	OrderSound(1)=Male2Voice.M2Hold
	OrderSound(2)=Male2Voice.M2Assault
	OrderSound(3)=Male2Voice.M2CoverMe
	OrderSound(4)=Male2Voice.M2Engage
	OrderSound(10)=Male2Voice.M2TakeFlag
	OrderSound(11)=Male2Voice.M2SearchDestroy
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

	OtherSound(0)=Male2Voice.M2uncovered
	OtherSound(1)=Male2Voice.M2GetFlagBack
	OtherSound(2)=Male2Voice.M2IGotFlag
	OtherSound(3)=Male2Voice.M2GotYourBack
	OtherSound(4)=Male2Voice.M2ImHit
	OtherSound(5)=Male2Voice.M2ManDown
	OtherSound(6)=Male2Voice.M2UnderAttack
	OtherSound(7)=Male2Voice.M2GotPoint
	OtherSound(8)=Male2Voice.M2OurFlag
	OtherSound(9)=Male2Voice.M2InPosition
	OtherSound(10)=Male2Voice.M2Hangin
	OtherSound(11)=Male2Voice.M2PointSecure
	OtherSound(12)=Male2Voice.M2EnemyCarrier
	OtherSound(13)=Male2Voice.M2Backup
	OtherSound(14)=Male2Voice.M2Incoming
	OtherSound(15)=Male2Voice.M2GotYourBack
	OtherSound(16)=Male2Voice.M2ObjectDestroy
	OtherSound(17)=Male2Voice.M2Medic
	OtherString(0)="Base is uncovered!"
	OtherString(1)="Somebody get our flag back!"
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
	OtherString(17)="Medic!"
}