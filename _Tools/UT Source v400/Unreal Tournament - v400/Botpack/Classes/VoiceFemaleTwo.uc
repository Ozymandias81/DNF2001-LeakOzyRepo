//=============================================================================
// VoiceFemaleTwo.
//=============================================================================
class VoiceFemaleTwo extends VoiceFemale;

#exec OBJ LOAD FILE=..\Sounds\Female2Voice.uax PACKAGE=Female2Voice

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
	NameSound(0)=Female2Voice.F2RedLeader
	NameSound(1)=Female2Voice.F2BlueLeader
	NameSound(2)=Female2Voice.F2GreenLeader
	NameSound(3)=Female2Voice.F2GoldLeader
	NameTime(0)=0.89
	NameTime(1)=0.94
	NameTime(2)=0.81
	NameTime(3)=0.93

	numAcks=3
	AckSound(0)=Female2Voice.F2GotIt
	AckSound(1)=Female2Voice.F2Roger
	AckSound(2)=Female2Voice.F2OnMyWay
	AckTime(0)=0.52
	AckTime(1)=0.75
	AckTime(2)=0.93
	AckString(0)="Got it"
	AckString(1)="Roger that"
	AckString(2)="On my way"

	numFFires=2
	FFireSound(0)=Female2Voice.F2SameTeam
	FFireSound(1)=Female2Voice.F2Idiot
	FFireString(0)="Same team!"
	FFireString(1)="I'm on your team!"
	FFireAbbrev(1)="On your team!"

	numTaunts=27
	TauntSound(0)=Female2Voice.F2EatThat
	TauntSound(1)=Female2Voice.F2Sucker
	TauntSound(2)=Female2Voice.F2Gotim
	TauntSound(3)=Female2Voice.F2hadtoHurt
	TauntSound(4)=Female2Voice.F2BiggerGun
	TauntSound(5)=Female2Voice.F2Boom
	TauntSound(6)=Female2Voice.F2BurnBaby
	TauntSound(7)=Female2Voice.F2DieBitch
	TauntSound(8)=Female2Voice.F2ToEasy
	TauntSound(9)=Female2Voice.F2youLikeThat
	TauntSound(10)=Female2Voice.F2YouSuck
	TauntSound(11)=Female2Voice.F2Loser
	TauntSound(12)=Female2Voice.F2OhYeah
	TauntSound(13)=Female2Voice.F2Safety
	TauntSound(14)=Female2Voice.F2YeeHaw
	TauntSound(15)=Female2Voice.F2Sweet
	TauntSound(16)=Female2Voice.F2WantSome
	TauntSound(17)=Female2Voice.F2Sucker
	TauntSound(18)=Female2Voice.F2StayDown
	TauntSound(19)=Female2Voice.F2Aim
	TauntSound(20)=Female2Voice.F2Die
	TauntSound(21)=Female2Voice.F2dirtbag
	TauntSound(22)=Female2Voice.F2next
	TauntSound(23)=Female2Voice.F2Seeya
	TauntSound(24)=Female2Voice.F2myhouse
	TauntSound(25)=Female2Voice.F2target
	TauntSound(26)=Female2Voice.F2useless
	TauntString(0)="Eat that!"
	TauntString(1)="Sucker!"
	TauntString(2)="Got him!"
	TauntString(3)="That had to hurt!"
	TauntString(4)="Try a bigger gun."
	TauntString(5)="Boom!"
	TauntString(6)="Burn, baby!"
	TauntString(7)="Die, bitch."
	TauntString(8)="Too easy!"
	TauntString(9)="You like that?"
	TauntString(10)="You suck!"
	TauntString(11)="Loser!"
	TauntString(12)="Oh yeah!"
	TauntString(13)="Try turning the safety off."
	TauntAbbrev(13)="Turn the safety off."
	TauntString(14)="Yeehaw!"
	TauntString(15)="Sweet!"
	TauntString(16)="Anyone else want some?"
	TauntAbbrev(16)="Anyone else?"
	TauntString(17)="Sucker!"
	TauntString(18)="And stay down!"
	TauntString(19)="Learn how to aim!"
	TauntString(20)="Die!"
	TauntString(21)="Dirt bag!"
	TauntString(22)="Next!"
	TauntString(23)="See ya!"
	TauntString(24)="My house!"
	TauntString(25)="Target eliminated."
	TauntString(26)="Useless!"
	MatureTaunt(7)=1

	OrderSound(0)=Female2Voice.F2Defend
	OrderSound(1)=Female2Voice.F2Hold
	OrderSound(2)=Female2Voice.F2Assault
	OrderSound(3)=Female2Voice.F2Coverme
	OrderSound(4)=Female2Voice.F2Engage
	OrderSound(10)=Female2Voice.F2TakeFlag
	OrderSound(11)=Female2Voice.F2Destroy
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

	OtherSound(0)=Female2Voice.F2BaseUnc
	OtherSound(1)=Female2Voice.F2GetFlag
	OtherSound(2)=Female2Voice.F2GotFlag
	OtherSound(3)=Female2Voice.F2gotyourb
	OtherSound(4)=Female2Voice.F2ImHit
	OtherSound(5)=Female2Voice.F2ManDown
	OtherSound(6)=Female2Voice.F2UnderAtt
	OtherSound(7)=Female2Voice.F2youGotPoint
	OtherSound(8)=Female2Voice.F2GotOurFlag
	OtherSound(9)=Female2Voice.F2InPosition
	OtherSound(10)=Female2Voice.F2HangInThere
	OtherSound(11)=Female2Voice.F2PointSecure
	OtherSound(12)=Female2Voice.F2EnemyHere
	OtherSound(13)=Female2Voice.F2backup
	OtherSound(14)=Female2Voice.F2Incoming
	OtherSound(15)=Female2Voice.F2gotyourb
	OtherSound(16)=Female2Voice.F2ObjectiveDest
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
	OtherString(16)="Objective is destroyed."
}