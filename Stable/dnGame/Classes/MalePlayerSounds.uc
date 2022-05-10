class MalePlayerSounds extends dnVoicePack;

#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx

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
			DelayedResponse = AckString[2]$CommaText$GetCallSign(recipient);
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
	TestSound=sound'a_npcvoice.Dennis.KOMLine01_09'
/*
	NameSound(0)=Male1Voice.M1RedLeader
	NameSound(1)=Male1Voice.M1BlueLeader
	NameSound(2)=Male1Voice.M1GreenLeader
	NameSound(3)=Male1Voice.M1GoldLeader
	NameTime(0)=0.96
	NameTime(1)=1.10
	NameTime(2)=1.02
	NameTime(3)=0.99
*/
	numAcks=4
//	AckSound(0)=Male1Voice.M1GotIt
//	AckSound(1)=Male1Voice.M1Roger
//	AckSound(2)=Male1Voice.M1OnMyWay
//	AckSound(3)=Male1Voice.M1ImOnIt
	AckTime(0)=0.78
	AckTime(1)=0.81
	AckTime(2)=0.98
	AckTime(3)=0.98
	AckString(0)="Got it"
	AckString(1)="Roger"
	AckString(2)="On my way"
	AckString(3)="I'm on it."

	numFFires=2
//	FFireSound(0)=Male1Voice.M1SameTeam
//	FFireSound(1)=Male1Voice.M1Idiot
	FFireString(0)="Hey! Same team!"
	FFireString(1)="I'm on your team, you idiot!"
	FFireAbbrev(1)="On your team!"

	numTaunts=23

	TauntSound(0)=sound'a_dukevoice.DukeLines.DBleeder'
	TauntSound(1)=sound'a_dukevoice.DukeLines.DBullseye'
	TauntSound(2)=sound'a_dukevoice.DukeLines.DForTheLord'
	TauntSound(3)=sound'a_dukevoice.DukeLines.DGetStarted'
	TauntSound(4)=sound'a_dukevoice.DukeLines.DGutsLook'
	TauntSound(5)=sound'a_dukevoice.DukeLines.DHastaAHole'
	TauntSound(6)=sound'a_dukevoice.DukeLines.DHastaBaby'
	TauntSound(7)=sound'a_dukevoice.DukeLines.DHavingABlast'
	TauntSound(8)=sound'a_dukevoice.DukeLines.DLadyLuck'
	TauntSound(9)=sound'a_dukevoice.DukeLines.DLetsDance'
	TauntSound(10)=sound'a_dukevoice.DukeLines.DLookGood'
	TauntSound(11)=sound'a_dukevoice.DukeLines.DMoreWhere'
	TauntSound(12)=sound'a_dukevoice.DukeLines.DMyKungFu'
	TauntSound(13)=sound'a_dukevoice.DukeLines.DOpenACan'
	TauntSound(14)=sound'a_dukevoice.DukeLines.DPopACap'
	TauntSound(15)=sound'a_dukevoice.DukeLines.DRatBastard'
	TauntSound(16)=sound'a_dukevoice.DukeLines.DRemKids'
	TauntSound(17)=sound'a_dukevoice.DukeLines.DSeenNothin'
	TauntSound(18)=sound'a_dukevoice.DukeLines.DStepRightUp'
	TauntSound(19)=sound'a_dukevoice.DukeLines.DThatABitch'
	TauntSound(20)=sound'a_dukevoice.DukeLines.DTimeToDial'
	TauntSound(21)=sound'a_dukevoice.DukeLines.DWhosNext'
	TauntSound(22)=sound'a_dukevoice.DukeLines.DYouDieNow'

	TauntString(0)="What are you, a bleeder?!"
	TauntString(1)="Bullseye!"
	TauntString(2)="I kick ass for the Lord!"
	TauntString(3)="I'm just gettin started!"
	TauntString(4)="You got a lot of guts.  Let's see what they look like."
	TauntAbbrev(4)="You got a lot of guts."
	TauntString(5)="Hasta La Vista...Asshole!"
	TauntString(6)="Hasta La Vista...Baby!"
	TauntString(7)="I'm havin a blast!"
	TauntString(8)="Looks like Lady Luck just gave you the finger!"
	TauntString(9)="Let's Dance!"
	TauntString(10)="Damn, I make this look good!"
	TauntString(11)="Oh yeah?  There's more where that came from!"
	TauntAbbrev(11)="There's more where that came from!"
	TauntString(12)="My kung fu's the best!"
	TauntString(13)="Time to open a can of WhoopAss!"
	TauntString(14)="I'll pop a cap in your ass!"
	TauntString(15)="Die, you rat bastard!"
	TauntString(16)="Remember kids, I'm a professional.  Don't try this at school."
	TauntAbbrev(16)="Remember kids, I'm a professional."
	TauntString(17)="You ain't seen nothin yet!"
	TauntString(18)="Step right up and get some!"
	TauntString(19)="Ain't that a bitch?!"
	TauntString(20)="Time to dial 911!"
	TauntString(21)="Who's Next?!"
	TauntString(22)="You Die Now!"

	//MatureTaunt(2)=1
	//MatureTaunt(6)=1

//	OrderSound(0)=Male1Voice.M1Defend
//	OrderSound(1)=Male1Voice.M1Hold
//	OrderSound(2)=Male1Voice.M1Assault
//	OrderSound(3)=Male1Voice.M1Coverme
//	OrderSound(4)=Male1Voice.M1Engage
//	OrderSound(10)=Male1Voice.M1TakeFlag
//	OrderSound(11)=Male1Voice.M1searchDestroy
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

//	OtherSound(0)=Male1Voice.M1uncovered
//	OtherSound(1)=Male1Voice.M1getflagback
//	OtherSound(2)=Male1Voice.M1IGotFlag
//	OtherSound(3)=Male1Voice.M1gotyourback
//	OtherSound(4)=Male1Voice.M1ImHit
//	OtherSound(5)=Male1Voice.M1ManDown
//	OtherSound(6)=Male1Voice.M1UnderAttack
//	OtherSound(7)=Male1Voice.M1YouGotPoint
//	OtherSound(8)=Male1Voice.M1IGotFlag
//	OtherSound(9)=Male1Voice.M1InPosition
//	OtherSound(10)=Male1Voice.M1OnMyWay
//	OtherSound(11)=Male1Voice.M1PointSecure
//	OtherSound(12)=Male1Voice.M1EnemyCarrier
//	OtherSound(13)=Male1Voice.M1Backup
//	OtherSound(14)=Male1Voice.M1TakeDown
//	OtherSound(15)=Male1Voice.M1GotYouCovered
//	OtherSound(16)=Male1Voice.M1ObjectDestroy
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

	TestSound=sound'a_dukevoice.DukeLines.DForTheLord'

    LandGrunt=MaleSounds.land10
	UnderWaterPain=sound'a_generic.water.uwdrown1'

    MirrorSounds(0)=sound'a_dukevoice.mirror.DukeMirror1'
    MirrorSounds(1)=sound'a_dukevoice.mirror.DukeMirror5'
    MirrorSounds(2)=sound'a_dukevoice.mirror.DukeMirror3'
    MirrorSounds(3)=sound'a_dukevoice.mirror.DukeMirror2'
    MirrorSounds(4)=sound'a_dukevoice.mirror.DukeMirror4'
	numMirrorSounds=5;

	DeathSounds(0)=sounds'a_dukevoice.mirror.DukeMirror4'
	DeathSounds(1)=sounds'a_dukevoice.mirror.DukeMirror4'
	DeathSounds(2)=sounds'a_dukevoice.mirror.DukeMirror4'
	DeathSounds(3)=sounds'a_dukevoice.mirror.DukeMirror4'
	DeathSounds(4)=sounds'a_dukevoice.mirror.DukeMirror4'
	DeathSounds(5)=sounds'a_dukevoice.mirror.DukeMirror4'
	numDeathSounds=6;

    KillSounds(0)=sound'a_dukevoice.DukeLines.DGetStarted'
    KillSounds(1)=sound'a_dukevoice.DukeLines.DGutsLook'
    KillSounds(2)=sound'a_dukevoice.DukeLines.DHastaAHole'
    KillSounds(3)=sound'a_dukevoice.DukeLines.DHastaBaby'
    KillSounds(4)=sound'a_dukevoice.DukeLines.DLadyLuck'
    KillSounds(5)=sound'a_dukevoice.DukeLines.DLetsDance'
    KillSounds(6)=sound'a_dukevoice.DukeLines.DMoreWhere'
    KillSounds(7)=sound'a_dukevoice.DukeLines.DRatBastard'
    KillSounds(8)=sound'a_dukevoice.DukeLines.DRemKids'
    KillSounds(9)=sound'a_dukevoice.DukeLines.DSeenNothin'
    KillSounds(10)=sound'a_dukevoice.DukeLines.DStepRightUp'
    KillSounds(11)=sound'a_dukevoice.DukeLines.DWhosNext'
    NumKillSounds=12

	KungFuKill=sound'a_dukevoice.dukelines.DMyKungFu'

	MessyKillSounds(0)=sound'a_dukevoice.DukeLines.DBullseye'
	MessyKillSounds(1)=sound'a_dukevoice.DukeLines.DGutsLook'
	MessyKillSounds(2)=sound'a_dukevoice.DukeLines.DHavingABlast'
	MessyKillSounds(3)=sound'a_dukevoice.DukeLines.DLookGood'
	MessyKillSounds(4)=sound'a_dukevoice.DukeLines.DThatABitch'
	MessyKillSounds(5)=sound'a_dukevoice.DukeLines.DTimeToDial'
	NumMessyKillSounds=6

	Falling_MajorPainSounds(0)=sound'a_dukevoice.Pain.DukePain1'
	Falling_MajorPainSounds(1)=sound'a_dukevoice.Pain.DukePain5'
	Falling_MajorPainSounds(2)=sound'a_dukevoice.Pain.DukePain6'
	Falling_MajorPainSounds(3)=sound'a_dukevoice.Pain.DukePain7'
	NumFallingMajorPainSounds=4

	Falling_PainSounds(0)=sound'a_dukevoice.Pain.DukePain2'
	Falling_PainSounds(1)=sound'a_dukevoice.Pain.DukePain3'
	Falling_PainSounds(2)=sound'a_dukevoice.Pain.DukePain4'
	Falling_PainSounds(3)=sound'a_dukevoice.Pain.DukePain8'
	NumFallingPainSounds=4

	PainSounds(0)=sound'a_dukevoice.Pain.DukePain2'
	PainSounds(1)=sound'a_dukevoice.Pain.DukePain3'
	PainSounds(2)=sound'a_dukevoice.Pain.DukePain4'
	PainSounds(3)=sound'a_dukevoice.Pain.DukePain8'
	NumPainSounds=4
}
