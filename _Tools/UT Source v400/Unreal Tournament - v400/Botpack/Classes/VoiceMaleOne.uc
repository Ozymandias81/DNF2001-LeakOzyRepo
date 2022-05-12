//=============================================================================
// VoiceMaleOne.
//=============================================================================
class VoiceMaleOne extends VoiceMale;

#exec OBJ LOAD FILE=..\Sounds\Male1Voice.uax PACKAGE=Male1Voice

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
	NameSound(0)=Male1Voice.M1RedLeader
	NameSound(1)=Male1Voice.M1BlueLeader
	NameSound(2)=Male1Voice.M1GreenLeader
	NameSound(3)=Male1Voice.M1GoldLeader
	NameTime(0)=0.96
	NameTime(1)=1.10
	NameTime(2)=1.02
	NameTime(3)=0.99

	numAcks=4
	AckSound(0)=Male1Voice.M1GotIt
	AckSound(1)=Male1Voice.M1Roger
	AckSound(2)=Male1Voice.M1OnMyWay
	AckSound(3)=Male1Voice.M1ImOnIt
	AckTime(0)=0.78
	AckTime(1)=0.81
	AckTime(2)=0.98
	AckTime(3)=0.98
	AckString(0)="Got it"
	AckString(1)="Roger"
	AckString(2)="On my way"
	AckString(3)="I'm on it."

	numFFires=2
	FFireSound(0)=Male1Voice.M1SameTeam
	FFireSound(1)=Male1Voice.M1Idiot
	FFireString(0)="Hey! Same team!"
	FFireString(1)="I'm on your team, you idiot!"
	FFireAbbrev(1)="On your team!"

	numTaunts=16
	TauntSound(0)=Male1Voice.M1EatThat
	TauntSound(1)=Male1Voice.M1LikeThat
	TauntSound(2)=Male1Voice.M1YeahBitch
	TauntSound(3)=Male1Voice.M1Boom
	TauntSound(4)=Male1Voice.M1Burnbaby
	TauntSound(5)=Male1Voice.M1LetsRock
	TauntSound(6)=Male1Voice.M1DieBitch
	TauntSound(7)=Male1Voice.M1Loser
	TauntSound(8)=Male1Voice.M1NailedEm
	TauntSound(9)=Male1Voice.M1Nasty
	TauntSound(10)=Male1Voice.M1Nice
	TauntSound(11)=Male1Voice.M1OhYeah
	TauntSound(12)=Male1Voice.M1Slaughter
	TauntSound(13)=Male1Voice.M1Sucker
	TauntSound(14)=Male1Voice.M1Yeehaw
	TauntSound(15)=Male1Voice.M1Yousuck
	TauntString(0)="Eat that!"
	TauntString(1)="You like that?"
	TauntString(2)="Yeah, bitch!"
	TauntString(3)="Boom!"
	TauntString(4)="Burn, baby"
	TauntString(5)="Lets Rock!"
	TauntString(6)="Die, bitch."
	TauntString(7)="Loser."
	TauntString(8)="Nailed 'im."
	TauntString(9)="That was nasty."
	TauntString(10)="Nice."
	TauntString(11)="Oh, yeah!"
	TauntString(12)="I just slaughtered that guy."
	TauntAbbrev(12)="Slaughtered him."
	TauntString(13)="Sucker!"
	TauntString(14)="Yeehaw!"
	TauntString(15)="You suck!"
	MatureTaunt(2)=1
	MatureTaunt(6)=1

	OrderSound(0)=Male1Voice.M1Defend
	OrderSound(1)=Male1Voice.M1Hold
	OrderSound(2)=Male1Voice.M1Assault
	OrderSound(3)=Male1Voice.M1Coverme
	OrderSound(4)=Male1Voice.M1Engage
	OrderSound(10)=Male1Voice.M1TakeFlag
	OrderSound(11)=Male1Voice.M1searchDestroy
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

	OtherSound(0)=Male1Voice.M1uncovered
	OtherSound(1)=Male1Voice.M1getflagback
	OtherSound(2)=Male1Voice.M1IGotFlag
	OtherSound(3)=Male1Voice.M1gotyourback
	OtherSound(4)=Male1Voice.M1ImHit
	OtherSound(5)=Male1Voice.M1ManDown
	OtherSound(6)=Male1Voice.M1UnderAttack
	OtherSound(7)=Male1Voice.M1YouGotPoint
	OtherSound(8)=Male1Voice.M1IGotFlag
	OtherSound(9)=Male1Voice.M1InPosition
	OtherSound(10)=Male1Voice.M1OnMyWay
	OtherSound(11)=Male1Voice.M1PointSecure
	OtherSound(12)=Male1Voice.M1EnemyCarrier
	OtherSound(13)=Male1Voice.M1Backup
	OtherSound(14)=Male1Voice.M1TakeDown
	OtherSound(15)=Male1Voice.M1GotYouCovered
	OtherSound(16)=Male1Voice.M1ObjectDestroy
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
	OtherString(10)="On my way."
	OtherString(11)="Control point is secure."
	OtherAbbrev(11)="Point is secure."
	OtherString(12)="Enemy flag carrier is here."
	OtherAbbrev(12)="Enemy carrier here."
	OtherString(13)="I need some backup."
	OtherString(14)="Take them down."
	OtherString(15)="I've got you covered."
	OtherAbbrev(15)="Got you covered."
	OtherString(16)="Objective destroyed."
}