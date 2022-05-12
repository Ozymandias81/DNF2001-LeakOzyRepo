//=============================================================================
// TrainingDOM.
//=============================================================================
class TrainingDOM extends Domination;

#exec OBJ LOAD FILE=..\Sounds\TutVoiceDOM.uax PACKAGE=TutVoiceDOM

var bool bOldAutoTaunt;

var string DOM[21];

var localized string TutMessage[21];

var PlayerPawn Trainee;

var int EventTimer, LastEvent, EventIndex, SoundIndex;
var bool bPause;

var string TranslocatorClass;

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	local string InOpt;

	Super.InitGame(Options, Error);

	bRatedGame = True;
	TimeLimit = 0;
	RemainingTime = 0;
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
	GoalTeamScore = 0;
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

	MySound = sound( DynamicLoadObject(NewSound, class'Sound') );
	EventTimer = GetSoundDuration( MySound ) + 2;
	Trainee.PlaySound(MySound, SLOT_Interface, 2.0);
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
		switch (EventIndex)
		{
			case 0:
				DOMTutEvent0();
				break;
			case 1:
				DOMTutEvent1();
				break;
			case 2:
				DOMTutEvent2();
				break;
			case 3:
				DOMTutEvent3();
				break;
			case 4:
				DOMTutEvent4();
				break;
			case 5:
				DOMTutEvent5();
				break;
			case 6:
				DOMTutEvent6();
				break;
			case 7:
				DOMTutEvent7();
				break;
			case 8:
				DOMTutEvent8();
				break;
			case 9:
				DOMTutEvent9();
				break;
			case 10:
				DOMTutEvent10();
				break;
			case 11:
				DOMTutEvent11();
				break;
			case 12:
				DOMTutEvent12();
				break;
			case 13:
				DOMTutEvent13();
				break;
			case 14:
				DOMTutEvent14();
				break;
			case 15:
				DOMTutEvent15();
				break;
			case 16:
				DOMTutEvent16();
				break;
			case 17:
				DOMTutEvent17();
				break;
			case 18:
				DOMTutEvent18();
				break;
		}
		EventIndex++;
	}
}

function DOMTutEvent0()
{
	local ControlPoint CP;

	Trainee.ProgressTimeOut = Level.TimeSeconds;
	if (Trainee.IsA('TournamentPlayer'))
	{
		bOldAutoTaunt = TournamentPlayer(Trainee).bAutoTaunt;
		TournamentPlayer(Trainee).bAutoTaunt = False;
	}
	foreach AllActors(class'ControlPoint', CP)
	{
		CP.SetCollision(False, False, False);
	}
	TournamentConsole(Trainee.Player.Console).ShowMessage();
	TutorialSound(DOM[0]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[0]);
	SoundIndex++;

	Trainee.Health = 100;
}

function DOMTutEvent1()
{
	TutorialSound(DOM[1]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[1]);
	SoundIndex++;
}

function DOMTutEvent2()
{
	local int X, Y;
	X = -128;
	Y = -128;

	TutorialSound(DOM[2]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[2]);
	SoundIndex++;
}

function DOMTutEvent3()
{
	TutorialSound(DOM[3]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[3]);
	SoundIndex++;
}

function DOMTutEvent4()
{
	TutorialSound(DOM[4]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[4]);
	SoundIndex++;
}

function DOMTutEvent5()
{
	TutorialSound(DOM[5]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[5]);
	SoundIndex++;
}

function DOMTutEvent6()
{
	TutorialSound(DOM[6]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[6]);
	SoundIndex++;
}

function DOMTutEvent7()
{
	TutorialSound(DOM[7]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[7]);
	SoundIndex++;
}

function DOMTutEvent8()
{
	TutorialSound(DOM[8]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[8]);
	SoundIndex++;
}

function DOMTutEvent9()
{
	Trainee.SetLocation(vect(-6, 347, -84));
	Trainee.SetRotation(rot(62680, 15916, 0));
	Trainee.ViewRotation = rot(62680, 15916, 0);
	PlayTeleportEffect(Trainee, true, true);

	TutorialSound(DOM[9]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[9]);
	SoundIndex++;
}

function DOMTutEvent10()
{
	local ControlPoint CP;
	local PlayerPawn P;
	local vector Loc;

	foreach AllActors(class'ControlPoint', CP)
	{
		if (CP.Tag == 'ControlPointGamma')
		{
			CP.SetCollision(True, False, False);
			foreach RadiusActors(class'PlayerPawn', P, CP.CollisionRadius, CP.Location)
			{
				CP.Touch(P);
			}
		}
	}

	bPause = True;
	GotoState('FreeRunning1');
}

state FreeRunning1
{
	function Tick(float DeltaTime)
	{
		local ControlPoint CP;

		Super.Tick(DeltaTime);

		foreach AllActors(class'ControlPoint', CP)
		{
			if (CP.Controller == Trainee)
			{
				bPause = False;

				TutorialSound(DOM[10]);
				TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[10]);
				SoundIndex++;
				
				GotoState('');
			}
		}
	}
}

function DOMTutEvent11()
{
	local int X, Y;
	X = -128;
	Y = -160;

	TutorialSound(DOM[11]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[11]);
	SoundIndex++;
}

function DOMTutEvent12()
{
	local ControlPoint CP;
	local PlayerPawn P;
	local vector Loc;

	TutorialSound(DOM[12]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[12]);
	SoundIndex++;
	foreach AllActors(class'ControlPoint', CP)
	{
		if (CP.Tag == 'ControlPointAlpha')
		{
			CP.SetCollision(True, False, False);
			foreach RadiusActors(class'PlayerPawn', P, CP.CollisionRadius, CP.Location)
			{
				CP.Touch(P);
			}
		}
	}

	bPause = True;
	GoToState('FreeRunning2');
}

state FreeRunning2
{
	function Tick(float DeltaTime)
	{
		local ControlPoint CP;
		local int ControlSum;

		Super.Tick(DeltaTime);

		foreach AllActors(class'ControlPoint', CP)
		{
			if (CP.Controller == Trainee)
				ControlSum++;
			if (ControlSum == 2)
			{
				bPause = False;

				TutorialSound(DOM[13]);
				TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[13]);
				SoundIndex++;

				GoToState('');
			}
		}
	}
}

function DOMTutEvent13()
{
	TutorialSound(DOM[14]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[14]);
	SoundIndex++;
}

function DOMTutEvent14()
{
	// Select the translocator.
	Trainee.GetWeapon(Class<Weapon>(DynamicLoadObject(TranslocatorClass, class'Class')));

	TutorialSound(DOM[15]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[15]);
	SoundIndex++;

	bPause = True;
	GoToState('FreeRunning3');
}

state FreeRunning3
{
	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		if ((Trainee.bFire != 0) && (Trainee.Weapon.IsA('Translocator')))
		{
			bPause = False;

			TutorialSound(DOM[16]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[16]);
			SoundIndex++;

			GoToState('');
		}
	}
}

function DOMTutEvent15()
{
	bPause = True;
	GoToState('FreeRunning4');
}

state FreeRunning4
{
	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		if ((Trainee.bAltFire != 0) && (Trainee.Weapon.IsA('Translocator')))
		{
			bPause = False;

			TutorialSound(DOM[17]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[17]);
			SoundIndex++;

			GotoState('');
		}
	}
}

function DOMTutEvent16()
{
	TutorialSound(DOM[18]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[18]);
	SoundIndex++;	
}

function DOMTutEvent17()
{
	TutorialSound(DOM[19]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[19]);
	SoundIndex++;	
}

function DOMTutEvent18()
{
	local ControlPoint CP;
	local int i;

	foreach AllActors(class'ControlPoint', CP)
	{
		CP.Controller = None;
	}

	for (i = 0; i < 2; i++)
		Teams[i].Score = 0;

	GoalTeamScore = 20;

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
		TutorialSound(DOM[20]);
	else
		Trainee.ClientPlaySound(sound'Announcer.LostMatch', True);

	if (RatedGameLadderObj != None)
	{
		RatedGameLadderObj.PendingChange = 0;
		RatedGameLadderObj.LastMatchType = LadderTypeIndex;
		if (RatedGameLadderObj.DOMPosition < 1)
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
	BeaconName="DOM-Tutorial"
	GameName="Combat Training: DOM"
	MapPrefix="DOM-Tutorial"
	StartUpMessage=""
	bLoggingGame=False
	DOM(0)="TutVoiceDOM.dom00"
	DOM(1)="TutVoiceDOM.dom01"
	DOM(2)="TutVoiceDOM.dom02"
	DOM(3)="TutVoiceDOM.dom03"
	DOM(4)="TutVoiceDOM.dom04"
	DOM(5)="TutVoiceDOM.dom05"
	DOM(6)="TutVoiceDOM.dom06"
	DOM(7)="TutVoiceDOM.dom07"
	DOM(8)="TutVoiceDOM.dom08"
	DOM(9)="TutVoiceDOM.dom09"
	DOM(10)="TutVoiceDOM.dom10"
	DOM(11)="TutVoiceDOM.dom11"
	DOM(12)="TutVoiceDOM.dom12"
	DOM(13)="TutVoiceDOM.dom13"
	DOM(14)="TutVoiceDOM.dom14"
	DOM(15)="TutVoiceDOM.dom15"
	DOM(16)="TutVoiceDOM.dom16"
	DOM(17)="TutVoiceDOM.dom17"
	DOM(18)="TutVoiceDOM.dom18"
	DOM(19)="TutVoiceDOM.dom19"
	DOM(20)="TutVoiceDOM.dom20"
	TutMessage(0)="Welcome to Domination combat training. This tutorial will instruct you on the basic gameplay rules of Domination. Tutorials on Deathmatch, Capture the Flag, and Assault are also available."
	TutMessage(1)="Let's start by learning about the elements Domination adds to the Heads Up Display (HUD)."
	TutMessage(2)="Domination enhances the basic teamplay HUD by adding control point status indicators to the left side of your screen."
	TutMessage(3)="As you can see, there are two control points in this tutorial map. We'll discuss the function of control points shortly."
	TutMessage(4)="Each indicator shows the name of a control point and that control point's current status."
	TutMessage(5)="Every control point in a domination map has a unique name. These controls points are named Alpha and Gamma."
	TutMessage(6)="The icon next to the control point name displays the status of that location. Before I explain how these icons work, let's discuss the rules of Domination."
	TutMessage(7)="In Domination each team is trying to control and hold the level's control points."
	TutMessage(8)="A team is given 1 point every 5 seconds for each location they control."
	TutMessage(9)="This is a control point. The grey X symbol indicates that no team is in control of this location. To take control of a location, touch it. Do this now."
	TutMessage(10)="Good. Your team now controls this location. Notice that the shape and color of the control point has changed to reflect your team symbol and color."
	TutMessage(11)="Look at the control point status icon. Notice that the Gamma point icon has changed to indicate your team is in control. You can use these icons to quickly assess the state of a Domination game."
	TutMessage(12)="Now find and control the Alpha point to secure your Domination of this map."
	TutMessage(13)="Excellent, you control all of the points on this map."
	TutMessage(14)="In summary, each team must locate and capture certain points in a Domination map. The more locations a team controls the faster their score increases."
	TutMessage(15)="This device is called a 'Translocator.' You use it to transport from one location to another instantly. Hit the fire button to launch the translocator destination module."
	TutMessage(16)="The module is now on the floor. If you hit the alt-fire button you will be teleported to the module. Run away from the module and hit the alt-fire button."
	TutMessage(17)="Good now you are back at the module. If you fire the module out, you can switch to a weapon and later switch back to the translocator to activate it anytime you want."
	TutMessage(18)="If you see an enemy translocator module on the ground, you can shoot it to disrupt it. Translocating to a disrupted module causes instant death."
	TutMessage(19)="Its time for a test. I'm going to spawn two bots on the enemy team and one bot to assist you. The first team to gain 20 points wins. Good luck!"
	TutMessage(20)="Congratulations! You have proven yourself to be a worthy Domination player. Now its time to enter the Domination Tournament Ladder."
	LastEvent=19
	TranslocatorClass="Botpack.Translocator"
}
