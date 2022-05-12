//=============================================================================
// VoiceFemaleOne.
//=============================================================================
class VoiceFemaleOne extends VoiceFemale;

#exec OBJ LOAD FILE=..\Sounds\Female1Voice.uax PACKAGE=Female1Voice

function SetOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	if ( messageIndex == 3 )
	{
		if ( FRand() < 0.4 )
			messageIndex = 7;
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
	NameSound(0)=Female1Voice.F1RedLeader
	NameSound(1)=Female1Voice.F1BlueLeader
	NameSound(2)=Female1Voice.F1GreenLeader
	NameSound(3)=Female1Voice.F1GoldLeader
	NameTime(0)=0.89
	NameTime(1)=0.94
	NameTime(2)=0.81
	NameTime(3)=0.93

	numAcks=3
	AckSound(0)=sound'Female1Voice.F1GotIt'
	AckSound(1)=sound'Female1Voice.F1Roger'
	AckSound(2)=sound'Female1Voice.F1OnMyWay'
	AckTime(0)=0.52
	AckTime(1)=0.75
	AckTime(2)=0.93
	AckString(0)="Got it"
	AckString(1)="Roger that"
	AckString(2)="On my way"

	numFFires=2
	FFireSound(0)=Female1Voice.F1SameTeam
	FFireSound(1)=Female1Voice.F1Idiot
	FFireString(0)="Same team!"
	FFireString(1)="I'm on your team, idiot!"
	FFireAbbrev(1)="On your team!"

	numTaunts=22
	TauntSound(0)=Female1Voice.F1EatThat
	TauntSound(1)=Female1Voice.F1Sucker
	TauntSound(2)=Female1Voice.F1Gotim
	TauntSound(3)=Female1Voice.F1HadtoHurt
	TauntSound(4)=Female1Voice.F1WantSome
	TauntSound(5)=Female1Voice.F1Boom
	TauntSound(6)=Female1Voice.F1BurnBaby
	TauntSound(7)=Female1Voice.F1DieBitch
	TauntSound(8)=Female1Voice.F1YouSuck
	TauntSound(9)=Female1Voice.F1LikeThat
	TauntSound(10)=Female1Voice.F1YeeHaw
	TauntSound(11)=Female1Voice.F1Loser
	TauntSound(12)=Female1Voice.F1OhYeah
	TauntSound(13)=Female1Voice.F1Tag
	TauntSound(14)=Female1Voice.F1SitDown
	TauntSound(15)=Female1Voice.F1Slaughter
	TauntSound(16)=Female1Voice.F1Sorry
	TauntSound(17)=Female1Voice.F1Squeel
	TauntSound(18)=Female1Voice.F1StayDown
	TauntSound(19)=Female1Voice.F1Sucker
	TauntSound(20)=Female1Voice.F1toasted
	TauntSound(21)=Female1Voice.F1letsrock
	TauntString(0)="Eat that!"
	TauntString(1)="Sucker!"
	TauntString(2)="Got him!"
	TauntString(3)="That had to hurt!"
	TauntAbbrev(3)="Had to hurt!"
	TauntString(4)="Anyone else want some?"
	TauntAbbrev(4)="Anyone else?"
	TauntString(5)="Boom!"
	TauntString(6)="Burn, baby!"
	TauntString(7)="Die, bitch."
	TauntString(8)="You suck!"
	TauntString(9)="You like that?"
	TauntString(10)="Yeehaw!"
	TauntString(11)="Loser!"
	TauntString(12)="Oh yeah!"
	TauntString(13)="Tag, you're it!"
	TauntString(14)="Sit down!"
	TauntString(15)="I just slaughtered that guy!"
	TauntAbbrev(15)="Slaughtered him."
	TauntString(16)="I'm sorry, did I blow your head apart?"
	TauntAbbrev(16)="I'm sorry."
	TauntString(17)="Squeal boy, squeal!"
	TauntString(18)="And stay down."
	TauntString(19)="Sucker!"
	TauntString(20)="Toasted!"
	TauntString(21)="Lets rock!"
	MatureTaunt(7)=1

	OrderSound(0)=Female1Voice.F1Defend
	OrderSound(1)=Female1Voice.F1Hold
	OrderSound(2)=Female1Voice.F1Assault
	OrderSound(3)=Female1Voice.F1Cover
	OrderSound(4)=Female1Voice.F1Engage
	OrderSound(10)=Female1Voice.F1TakeFlag
	OrderSound(11)=Female1Voice.F1Destroy
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

	OtherSound(0)=Female1Voice.F1BaseUnc
	OtherSound(1)=Female1Voice.F1GetFlag
	OtherSound(2)=Female1Voice.F1GotFlag
	OtherSound(3)=Female1Voice.F1gotyourb
	OtherSound(4)=Female1Voice.F1ImHit
	OtherSound(5)=Female1Voice.F1ManDown
	OtherSound(6)=Female1Voice.F1UnderAtt
	OtherSound(7)=Female1Voice.F1youGotPoint
	OtherSound(8)=Female1Voice.F1GotOurFlag
	OtherSound(9)=Female1Voice.F1InPosition
	OtherSound(10)=Female1Voice.F1HangInThere
	OtherSound(11)=Female1Voice.F1PointSecure
	OtherSound(12)=Female1Voice.F1EnemyHere
	OtherSound(13)=Female1Voice.F1Backup
	OtherSound(14)=Female1Voice.F1Incoming
	OtherSound(15)=Female1Voice.F1gotyourb
	OtherSound(16)=Female1Voice.F1ObjectiveDest
	OtherString(0)="Base is uncovered!"
	OtherString(1)="Somebody get our flag back!"
	OtherAbbrev(1)="Get our flag!"
	OtherString(2)="I've got the flag."
	OtherAbbrev(2)="Got the flag."
	OtherString(3)="I've got your back."
	OtherAbbrev(3)="Got your back."
	OtherString(4)="I'm hit! I'm hit!"
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