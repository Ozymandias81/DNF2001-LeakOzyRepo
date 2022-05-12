//=============================================================================
// TrainingCTF.
//=============================================================================
class TrainingCTF extends CTFGame;

#exec OBJ LOAD FILE=..\Sounds\TutVoiceCTF.uax PACKAGE=TutVoiceCTF

var bool bOldAutoTaunt;

var string CTF[27];

var localized string TutMessage[30];

var PlayerPawn Trainee;

var int EventTimer, LastEvent, EventIndex, SoundIndex;
var bool bPause;

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	local string InOpt;

	Super.InitGame(Options, Error);

	bRatedGame = True;
	TimeLimit = 0;
	RemainingTime = 0;
	GoalTeamScore = 3;
	FragLimit = 0;
	bRequireReady = False;
	bTournament = False;
	EventTimer = 3;
}

function InitRatedGame(LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
	Super.InitRatedGame(LadderObj, LadderPlayer);
	
	RemainingBots = 0;
	bRequireReady = False;
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	Trainee = Super.Login(Portal, Options, Error, SpawnClass);
	Trainee.PlayerReplicationInfo.TeamName = "Red";
	Trainee.PlayerReplicationInfo.Team = 0;
	Trainee.ReducedDamageType = 'All';

	return Trainee;
}

function TutorialSound( string NewSound )
{
	local sound MySound;

	MySound = sound(DynamicLoadObject( NewSound, class'Sound' ));
	EventTimer = GetSoundDuration( MySound ) + 2;
	Trainee.PlaySound( MySound, SLOT_Interface, 2.0 );
}


function Timer()
{
	Super.Timer();

	if ((EventTimer == 0) || bPause)
		return;

	EventTimer--;
	if (EventTimer == 0)		// Event time is up, perform an event
	{
		if (EventIndex == LastEvent)	// No more events queued.
			return;

		// Call an event function appropriate for this event.
		// Is messy.  Would be nicer with function references.
		switch (EventIndex)
		{
			case 0:
				CTFTutEvent0();
				break;
			case 1:
				CTFTutEvent1();
				break;
			case 2:
				CTFTutEvent2();
				break;
			case 3:
				CTFTutEvent3();
				break;
			case 4:
				CTFTutEvent4();
				break;
			case 5:
				CTFTutEvent5();
				break;
			case 6:
				CTFTutEvent6();
				break;
			case 7:
				CTFTutEvent7();
				break;
			case 8:
				CTFTutEvent8();
				break;
			case 9:
				CTFTutEvent9();
				break;
			case 10:
				CTFTutEvent10();
				break;
			case 11:
				CTFTutEvent11();
				break;
			case 12:
				CTFTutEvent12();
				break;
			case 13:
				CTFTutEvent13();
				break;
			case 14:
				CTFTutEvent14();
				break;
			case 15:
				CTFTutEvent15();
				break;
			case 16:
				CTFTutEvent16();
				break;
			case 17:
				CTFTutEvent17();
				break;
			case 18:
				CTFTutEvent18();
				break;
			case 19:
				CTFTutEvent19();
				break;
			case 20:
				CTFTutEvent20();
				break;
			case 21:
				CTFTutEvent21();
				break;
			case 22:
				CTFTutEvent22();
				break;
			case 23:
				CTFTutEvent23();
				break;
			case 24:
				CTFTutEvent24();
				break;
		}
		EventIndex++;
	}
}

function CTFTutEvent0()
{
	Trainee.ProgressTimeOut = Level.TimeSeconds;
	if (Trainee.IsA('TournamentPlayer'))
	{
		bOldAutoTaunt = TournamentPlayer(Trainee).bAutoTaunt;
		TournamentPlayer(Trainee).bAutoTaunt = False;
	}
	TournamentConsole(Trainee.Player.Console).ShowMessage();
	TutorialSound(CTF[0]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[0]);
	SoundIndex++;

	Trainee.Health = 100;
}

function CTFTutEvent1()
{
	TutorialSound(CTF[1]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[1]);
	SoundIndex++;
}

function CTFTutEvent2()
{
	TutorialSound(CTF[2]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[2]);
	SoundIndex++;
}

function CTFTutEvent3()
{
	TutorialSound(CTF[3]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[3]);
	SoundIndex++;
}

function CTFTutEvent4()
{
	local int X, Y;
	X = -150;
	Y = -350;

	TutorialSound(CTF[4]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[4]);
	SoundIndex++;
}

function CTFTutEvent5()
{
	TutorialSound(CTF[5]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[5]);
	SoundIndex++;
}

function CTFTutEvent6()
{
	TutorialSound(CTF[6]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[6]);
	SoundIndex++;
}

function CTFTutEvent7()
{
	ChallengeHUD(Trainee.myHUD).bForceScores = True;

	TutorialSound(CTF[7]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[7]);
	SoundIndex++;
}

function CTFTutEvent8()
{
	TutorialSound(CTF[8]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[8]);
	SoundIndex++;
}

function CTFTutEvent9()
{
	TutorialSound(CTF[9]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[9]);
	SoundIndex++;
}

function CTFTutEvent10()
{
	TutorialSound(CTF[10]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[10]);
	SoundIndex++;
}

function CTFTutEvent11()
{
	// Show carrying the flag dot!

	TutorialSound(CTF[11]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[11]);
	SoundIndex++;
}

function CTFTutEvent12()
{
	TutorialSound(CTF[12]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[12]);
	SoundIndex++;
}

function CTFTutEvent13()
{
	ChallengeHUD(Trainee.myHUD).bForceScores = False;

	TutorialSound(CTF[13]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[13]);
	SoundIndex++;
}

function CTFTutEvent14()
{
	ChallengeHUD(Trainee.myHUD).bForceScores = False;

	TutorialSound(CTF[14]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[14]);
	SoundIndex++;
}

function CTFTutEvent15()
{
	local Mover m;
	foreach AllActors(class'Mover', m)
		m.Trigger(Trainee, Trainee);

	Trainee.SetLocation(vect(138, 1327, -84));
	Trainee.SetRotation(rot(62611, 42295, 0));
	Trainee.ViewRotation = rot(62611, 42295, 0);
	PlayTeleportEffect(Trainee, true, true);
	TutorialSound(CTF[15]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[15]);
	SoundIndex++;
}

function CTFTutEvent16()
{
	TutorialSound(CTF[16]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[16]);
	SoundIndex++;
}

function CTFTutEvent17()
{
	TutorialSound(CTF[17]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[17]);
	SoundIndex++;

	bPause = True;
	GoToState('FreeRunning1');
}

state FreeRunning1
{
	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		if (Trainee.PlayerReplicationInfo.HasFlag != None) 
		{
			bPause = False;

			TutorialSound(CTF[18]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[18]);
			SoundIndex++;

			GotoState('');
		}
	}
}

function CTFTutEvent18()
{
	// Point to flag status icons.

	TutorialSound(CTF[19]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[19]);
	SoundIndex++;
}

function CTFTutEvent19()
{
	// Stop pointing.

	TutorialSound(CTF[20]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[20]);
	SoundIndex++;

	bPause = True;
	GoToState('FreeRunning2');
}

state FreeRunning2
{
	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		if (Teams[Trainee.PlayerReplicationInfo.Team].Score > 0) 
		{
			bPause = False;

			TutorialSound(CTF[21]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[21]);
			SoundIndex++;

			GoToState('');
		}
	}
}

function CTFTutEvent20()
{
	TutorialSound(CTF[22]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[22]);
	SoundIndex++;
}

function CTFTutEvent21()
{
	TutorialSound(CTF[23]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[23]);
	SoundIndex++;
}

function CTFTutEvent22()
{
	TutorialSound(CTF[24]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[24]);
	SoundIndex++;
}

function CTFTutEvent23()
{
	TutorialSound(CTF[25]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[25]);
	SoundIndex++;
}

function CTFTutEvent24()
{
	local int i;

	for (i = 0; i < 2; i++)
		Teams[i].Score = 0;

	GoalTeamScore = 3;

	bRatedGame = True;
	RemainingBots = RatedMatchConfig.NumBots;

	TournamentConsole(Trainee.Player.Console).HideMessage();
}

function bool SuccessfulGame()
{
	local TeamInfo BestTeam;
	local int i;
	BestTeam = Teams[0];
	for ( i=1; i<MaxTeams; i++ )
		if ( Teams[i].Score > BestTeam.Score )
			BestTeam = Teams[i];

	if (BestTeam.TeamIndex == Trainee.PlayerReplicationInfo.Team)
		return (BestTeam.Score >= GoalTeamScore);
	else
		return false;
}

function EndGame( string Reason )
{
	Super.EndGame(Reason);

	if (Trainee.IsA('TournamentPlayer'))
		TournamentPlayer(Trainee).bAutoTaunt = bOldAutoTaunt;

	if (SuccessfulGame())
		TutorialSound(CTF[26]);
	else
		Trainee.ClientPlaySound(sound'Announcer.LostMatch', True);

	if (RatedGameLadderObj != None)
	{
		RatedGameLadderObj.PendingChange = 0;
		RatedGameLadderObj.LastMatchType = LadderTypeIndex;
		if (RatedGameLadderObj.CTFPosition < 1)
		{
			RatedGameLadderObj.PendingChange = LadderTypeIndex;
			RatedGameLadderObj.PendingRank = 1;
			RatedGameLadderObj.PendingPosition = 1;
		}
	}
	GoToState('ServerTravel');
}

state ServerTravel
{
	function Timer()
	{
		local string StartMap;

		StartMap = "UT-Logo-Map.unr"
			$"?Game=Botpack.LadderTransition";

		Trainee.ClientTravel(StartMap, TRAVEL_Absolute, True);
	}

	function BeginState()
	{
		SetTimer(9.0, true);
	}
}

defaultproperties
{
	bTutorialGame=True
	SingleWaitingMessage=""
	Difficulty=0
	BeaconName="CTF-Tutorial"
	GameName="Combat Training: CTF"
	MapPrefix="CTF-Tutorial"
	StartUpMessage=""
	bLoggingGame=False
	CTF(0)="TutVoiceCTF.ctf00"
	CTF(1)="TutVoiceCTF.ctf01"
	CTF(2)="TutVoiceCTF.ctf02"
	CTF(3)="TutVoiceCTF.ctf03"
	CTF(4)="TutVoiceCTF.ctf04"
	CTF(5)="TutVoiceCTF.ctf05"
	CTF(6)="TutVoiceCTF.ctf06"
	CTF(7)="TutVoiceCTF.ctf07"
	CTF(8)="TutVoiceCTF.ctf08"
	CTF(9)="TutVoiceCTF.ctf09"
	CTF(10)="TutVoiceCTF.ctf10"
	CTF(11)="TutVoiceCTF.ctf11"
	CTF(12)="TutVoiceCTF.ctf12"
	CTF(13)="TutVoiceCTF.ctf13"
	CTF(14)="TutVoiceCTF.ctf26"
	CTF(15)="TutVoiceCTF.ctf14"
	CTF(16)="TutVoiceCTF.ctf15"
	CTF(17)="TutVoiceCTF.ctf16"
	CTF(18)="TutVoiceCTF.ctf17"
	CTF(19)="TutVoiceCTF.ctf18"
	CTF(20)="TutVoiceCTF.ctf19"
	CTF(21)="TutVoiceCTF.ctf20"
	CTF(22)="TutVoiceCTF.ctf21"
	CTF(23)="TutVoiceCTF.ctf22"
	CTF(24)="TutVoiceCTF.ctf23"
	CTF(25)="TutVoiceCTF.ctf24"
	CTF(26)="TutVoiceCTF.ctf25"
	TutMessage(0)="Welcome to Capture the Flag combat training. This tutorial will instruct you on the basic rules of CTF. Tutorials on DeathMatch, Domination, and Assault are also available."
	TutMessage(1)="Let's start by learning about the Heads Up Display (HUD). CTF adds a few new elements to the HUD you should be aware of."
	TutMessage(2)="Your HUD color indicates your team affiliation. Your HUD is red, indicating you are on the red team."
	TutMessage(3)="A blue HUD would indicate that you were on the blue team."
	TutMessage(4)="The two flag icons indicate the status of the red and blue flags. This allows you to obtain a quick overview of battlefield conditions."
	TutMessage(5)="We'll discuss the meaning of each flag status icon in a bit."
	TutMessage(6)="Just to the left of each flag status icon, is that team's score."
	TutMessage(7)="Now lets look at the elements CTF adds to the scoreboard..."
	TutMessage(8)="Capture the Flag uses the standard Unreal teamplay scoreboard configuration."
	TutMessage(9)="The left column lists the red team players and scores and the right column lists the blue team players and scores."
	TutMessage(10)="Notice your name and current score of 0 listed to the left. Above your name is the name of your team. Your team's current score is listed to the right of the team's name."
	TutMessage(11)="When a player in a CTF game is carrying the flag, a small dot will appear next to their name in the scoreboard."
	TutMessage(12)="This can be used to quickly determine which teammate to protect or which enemy to hunt down."
	TutMessage(13)="Now its time to learn the rules of Capture the Flag."
	TutMessage(14)="In Capture the Flag you can use the translocator. It works the same way as in Domination, with one minor change. You are not allowed to translocate and carry the flag at the same time. If you translocate while holding the enemy flag, you will successfully translocate, but will drop the flag on the ground. This prevents you from translocating back to your base after having captured the enemy flag."
	TutMessage(15)="Each CTF map has a red and a blue base. This is red base. Blue base is just down the hallway. Each base contains a flag."
	TutMessage(16)="In front of you is the red flag. The object of CTF is to capture the enemy team's flag while defending your own."
	TutMessage(17)="Let's give it a try. Run to the blue base and touch their flag to pick it up. Grab any equipment you find along the way."
	TutMessage(18)="Great! Now you have the enemy flag. The flashing yellow message is to remind you that once you have the flag, you need to return it to your base to score."
	TutMessage(19)="Notice the blue team flag status icon changed. Now it indicates that a red team player is in possession of the flag. Blue team is in trouble!"
	TutMessage(20)="Take the flag back to your base and touch the red flag to capture the blue flag and score."
	TutMessage(21)="Great job! You captured the enemy flag and scored a point for your team. Wasn't so hard, now, was it?"
	TutMessage(22)="Its about to get harder. In a few seconds, I'm going to spawn two blue team bots and a red teammate you can practice with."
	TutMessage(23)="There is one last status icon to tell you about. If a player drops the flag while carrying it, his team's flag status icon will change to a flag icon containing a downward arrow."
	TutMessage(24)="If you find your flag lying on the ground after you kill an enemy who was carrying it, touch it to automatically return it to your base."
	TutMessage(25)="This concludes the CTF tutorial. Let me spawn those practice bots for you. Good hunting!"
	TutMessage(26)="Congratulations! You have proven yourself to be a worthy CTF player. Now its time to enter the Capture the Flag Tournament Ladder."
	LastEvent=25
}
