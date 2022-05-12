//=============================================================================
// TrainingAS.
//=============================================================================
class TrainingAS extends Assault;

#exec OBJ LOAD FILE=..\Sounds\TutVoiceAS.uax PACKAGE=TutVoiceAS

var string AS[13];

var PlayerPawn Trainee;

var localized string TutMessage[25];

var int EventTimer, LastEvent, EventIndex;

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	local string InOpt;

	Super.InitGame(Options, Error);

	bRatedGame = True;
	bRequireReady = False;
	bTournament = False;
	EventTimer = 3;

	bDontRestart = True;
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
	//Trainee.PlayerReplicationInfo.TeamName = "Red";
	//Trainee.PlayerReplicationInfo.Team = 0;
	Trainee.ReducedDamageType = 'All';

	return Trainee;
}

function TutorialSound( string NewSound )
{
	local sound MySound;

	MySound = sound( DynamicLoadObject(NewSound, class'Sound') );
	EventTimer = GetSoundDuration( MySound ) + 2;
	Trainee.PlaySound(MySound, SLOT_Interface, 2.0);
}

function Timer()
{
	Super.Timer();

	if (EventTimer == 0)
		return;

	EventTimer--;
	if (EventTimer == 0)		// Event time is up, perform an event
	{
		if (EventIndex == LastEvent)	// No more events queued.
			return;
		if (EventIndex == 11)
			EventTimer = 4;

		// Call an event function appropriate for this event.
		switch (EventIndex)
		{
			case 0:
				ASTutEvent0();
				break;
			case 1:
				ASTutEvent1();
				break;
			case 2:
				ASTutEvent2();
				break;
			case 3:
				ASTutEvent3();
				break;
			case 4:
				ASTutEvent4();
				break;
			case 5:
				ASTutEvent5();
				break;
			case 6:
				ASTutEvent6();
				break;
			case 7:
				ASTutEvent7();
				break;
			case 8:
				ASTutEvent8();
				break;
			case 9:
				ASTutEvent9();
				break;
			case 10:
				ASTutEvent10();
				break;
			case 11:
				ASTutEvent11();
				break;
			case 12:
				ASTutEvent12();
				break;
		}
		EventIndex++;
	}
}

function ASTutEvent0()
{
	local FortStandard FS;

	Trainee.ProgressTimeOut = Level.TimeSeconds;
	foreach AllActors(class'FortStandard', FS)
	{
		if (FS.Tag == 'lickbird')
		{
			FS.bProjTarget = False;
			FS.bCollideWorld = False;
		}
	}

	TournamentConsole(Trainee.Player.Console).ShowMessage();
	TutorialSound(AS[0]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[0]);

	Trainee.Health = 100;
}

function ASTutEvent1()
{
	TutorialSound(AS[1]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[1]);
}

function ASTutEvent2()
{
	TutorialSound(AS[2]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[2]);
}

function ASTutEvent3()
{
	TutorialSound(AS[3]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[3]);
}

function ASTutEvent4()
{
	TutorialSound(AS[4]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[4]);
}

function ASTutEvent5()
{
	TutorialSound(AS[5]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[5]);
}

function ASTutEvent6()
{
	TutorialSound(AS[6]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[6]);
}

function ASTutEvent7()
{
	TutorialSound(AS[7]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[7]);
}

function ASTutEvent8()
{
	TutorialSound(AS[8]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[8]);
}

function ASTutEvent9()
{
	TutorialSound(AS[9]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[9]);
}

function ASTutEvent10()
{
	TutorialSound(AS[10]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[10]);
}

function ASTutEvent11()
{
	TutorialSound(AS[11]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[11]);
}

function ASTutEvent12()
{
	local FortStandard FS;

	foreach AllActors(class'FortStandard', FS)
	{
		if (FS.Tag == 'lickbird')
		{
			FS.bProjTarget = True;
			FS.bCollideWorld = True;
		}
	}

	bRatedGame = True;
	RemainingBots = RatedMatchConfig.NumBots; 

	TournamentConsole(Trainee.Player.Console).HideMessage();
}

function EndGame( string Reason )
{
	Super.EndGame(Reason);

	if (SuccessfulGame())
		TutorialSound(AS[12]);
	else
		Trainee.ClientPlaySound(sound'Announcer.LostMatch', True);

	if (RatedGameLadderObj != None)
	{
		RatedGameLadderObj.PendingChange = 0;
		RatedGameLadderObj.LastMatchType = LadderTypeIndex;
		if (RatedGameLadderObj.ASPosition < 1)
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
		SetTimer(10.0, true);
	}
}

defaultproperties
{
	bTutorialGame=True
	SingleWaitingMessage=""
	Difficulty=0
	BeaconName="AS-Tutorial"
	GameName="Combat Training: AS"
	MapPrefix="AS-Tutorial"
	StartUpMessage=""
	bLoggingGame=False
	AS(0)="TutVoiceAS.as00"
	AS(1)="TutVoiceAS.as01"
	AS(2)="TutVoiceAS.as02"
	AS(3)="TutVoiceAS.as03"
	AS(4)="TutVoiceAS.as04"
	AS(5)="TutVoiceAS.as05"
	AS(6)="TutVoiceAS.as06"
	AS(7)="TutVoiceAS.as07"
	AS(8)="TutVoiceAS.as08"
	AS(9)="TutVoiceAS.as09"
	AS(10)="TutVoiceAS.as10"
	AS(11)="TutVoiceAS.as11"
	AS(12)="TutVoiceAS.as12"
	TutMessage(0)="Welcome to Assault combat training. This tutorial will instruct you on the basic rules of AS. Tutorials on DeathMatch, Domination, and Capture the Flag are also available."
	TutMessage(1)="The first thing you'll notice upon entering an Assault game is the large digital time display to the left of your HUD. This timer counts away the seconds until the game ends. Time is critical in an Assault game."
	TutMessage(2)="The game consists of two teams, each with a unique goal. You are on the attacking team. Your job is to penetrate the enemy base and destroy several key locations. If you fail to succeed in the allotted time, you lose."
	TutMessage(3)="The opposing team are the defenders. The defender's job is to protect their base and key locations from the assaulting team."
	TutMessage(4)="If you succeed in taking the enemy base as an attacker, then you must play the role of the defender for the same length of time."
	TutMessage(5)="To clarify, if you have 20 minutes to take the enemy base and you succeed in 10, then the map will restart and you must defend the base for 10 minutes. The longer it takes you to succeed in attacking, the longer you must defend the base."
	TutMessage(6)="Each assault map is unique in design. It may take time to learn the layout and develop strategies to attack or defend successfully."
	TutMessage(7)="At the start of every match, you are in spectator mode. Feel free to fly around and explore the map before play begins, to familiarize yourself with the environment."
	TutMessage(8)="When playing Assault with bots, you can use the 'orders menu' to command bot behavior. By hitting the v key, you can access the orders menu and deploy bots as you see fit."
	TutMessage(9)="The goal of this tutorial map is to break into the enemy base and destroy a prototype plasma tank. I'm going to summon two enemy bots to try and stop you, but you'll have a buddy to assist."
	TutMessage(10)="Some explosive has been set on the cave wall near the enemy base. Use your weapon to light the fuse then get back! Use the breach the explosive creates to enter the enemy base and take out the tank!"
	TutMessage(11)="Watch out for the enemy bot guarding the base and plasma turrets. Good luck!"
	TutMessage(12)="Congratulations! You've succeeded in destroying the plasma tank. Now its time to enter the Assault Tournament Ladder."
	LastEvent=13
}
