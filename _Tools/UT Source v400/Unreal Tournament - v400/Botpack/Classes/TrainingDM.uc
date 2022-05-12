class TrainingDM extends DeathMatchPlus;

#exec OBJ LOAD FILE=..\Sounds\TutVoiceDM.uax PACKAGE=TutVoiceDM

var string DM[24];

var bool bReadyToSpawn;

var localized string TutMessage[24];
var localized string TutMessage4Parts[5];
var localized string TutMessage6Parts[2];
var localized string TutMessage14Parts[2];
var localized string TutMessage15Parts[2];

var string KeyNames[255];
var string KeyAlias[255];

var PlayerPawn Trainee;
var rotator LastRotation;
var vector LastLocation;

var int EventTimer, LastEvent, EventIndex, SoundIndex;
var bool bPause;

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);

	bRatedGame = True;
	TimeLimit = 0;
	RemainingTime = 0;
	FragLimit = 3;
	bRequireReady = False;
	EventTimer = 3;
}

function InitRatedGame(LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
	Super.InitRatedGame(LadderObj, LadderPlayer);
	
	RemainingBots = 0;
	bRequireReady = False;
}

function PostBeginPlay()
{
	local Barrel B;

	Super.PostBeginPlay();

	foreach AllActors(class'Barrel', B)
	{
		B.bHidden = True;
		B.SetCollision(False, False, False);
	}
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

function AddDefaultInventory( pawn PlayerPawn )
{
	local Weapon NewWeapon;

	if (bReadyToSpawn)
	{
		if (!PlayerPawn.PlayerReplicationInfo.bIsABot)
			newWeapon = Spawn(class'ShockRifle');
		else
			newWeapon = Spawn(class'Enforcer');

		if( newWeapon != None )
		{
			newWeapon.BecomeItem();
			newWeapon.bHeldItem = true;
			PlayerPawn.AddInventory(newWeapon);
			newWeapon.Instigator = PlayerPawn;
			newWeapon.GiveAmmo(PlayerPawn);
			newWeapon.SetSwitchPriority(PlayerPawn);
			newWeapon.WeaponSet(PlayerPawn);
			if ( !PlayerPawn.IsA('PlayerPawn') )
				newWeapon.GotoState('Idle');
			PlayerPawn.Weapon.GotoState('DownWeapon');
			PlayerPawn.PendingWeapon = None;
			PlayerPawn.Weapon = newWeapon;
			newWeapon.AmmoType.AmmoAmount = 400;
			newWeapon.AmmoType.MaxAmmo = 400;
		}
	}
}

function LoadKeyBindings(PlayerPawn P)
{
	local int i;

	for (i=0; i<255; i++)
	{
		KeyNames[i] = P.ConsoleCommand( "KEYNAME "$i );
		KeyAlias[i] = P.ConsoleCommand( "KEYBINDING "$KeyNames[i] );
	}
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
				DMTutEvent0();
				break;
			case 1:
				DMTutEvent1();
				break;
			case 2:
				DMTutEvent2();
				break;
			case 3:
				DMTutEvent3();
				break;
			case 4:
				DMTutEvent4();
				break;
			case 5:
				DMTutEvent5();
				break;
			case 6:
				DMTutEvent6();
				break;
			case 7:
				DMTutEvent7();
				break;
			case 8:
				DMTutEvent8();
				break;
			case 9:
				DMTutEvent9();
				break;
			case 10:
				DMTutEvent10();
				break;
			case 11:
				DMTutEvent11();
				break;
			case 12:
				DMTutEvent12();
				break;
			case 13:
				DMTutEvent13();
				break;
			case 14:
				DMTutEvent14();
				break;
			case 15:
				DMTutEvent15();
				break;
			case 16:
				DMTutEvent16();
				break;
			case 17:
				DMTutEvent17();
				break;
			case 18:
				DMTutEvent18();
				break;
			case 19:
				DMTutEvent19();
				break;
			case 20:
				DMTutEvent20();
				break;
			case 21:
				DMTutEvent21();
				break;
			case 22:
				DMTutEvent22();
				break;
			case 23:
				DMTutEvent23();
				break;
		}
		EventIndex++;
	}
}

function DMTutEvent0()
{
	Trainee.ProgressTimeOut = Level.TimeSeconds;
	LoadKeyBindings(Trainee);
	TournamentConsole(Trainee.Player.Console).ShowMessage();
	TutorialSound(DM[0]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[0]);
	SoundIndex++;

	Trainee.Health = 100;
}

function DMTutEvent1()
{
	TutorialSound(DM[1]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[1]);
	SoundIndex++;
}

function DMTutEvent2()
{
	TutorialSound(DM[2]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[2]);
	SoundIndex++;
}

function DMTutEvent3()
{
	TutorialSound(DM[3]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[3]);
	SoundIndex++;
}

function DMTutEvent4()
{
	local int i;
	local string Message;
	local string ForwardKey, BackKey, LeftStrafeKey, RightStrafeKey;

	for (i=0; i<255; i++)
	{
		if (KeyAlias[i] ~= "MoveForward")
		{
			if (ForwardKey != "")
				ForwardKey = ForwardKey$","@KeyNames[i];
			else
				ForwardKey = KeyNames[i];
		}
		if (KeyAlias[i] ~= "MoveBackward")
		{
			if (BackKey != "")
				BackKey = BackKey$","@KeyNames[i];
			else
				BackKey = KeyNames[i];
		}
		if (KeyAlias[i] ~= "StrafeLeft")
		{
			if (LeftStrafeKey != "")
				LeftStrafeKey = LeftStrafeKey$","@KeyNames[i];
			else
				LeftStrafeKey = KeyNames[i];
		}
		if (KeyAlias[i] ~= "StrafeRight")
		{
			if (RightStrafeKey != "")
				RightStrafeKey = RightStrafeKey$","@KeyNames[i];
			else
				RightStrafeKey = KeyNames[i];
		}
	}

	TutorialSound(DM[4]);
	Message = TutMessage4Parts[0]@"["$ForwardKey$"]"@TutMessage4Parts[1]@"["$BackKey$"]"@TutMessage4Parts[2]@"["$LeftStrafeKey$"]"@TutMessage4Parts[3]@"["$RightStrafeKey$"]"$TutMessage4Parts[4];
	TournamentConsole(Trainee.Player.Console).AddMessage(Message);
	SoundIndex++;
}

function DMTutEvent5()
{
	TutorialSound(DM[5]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[5]);
	SoundIndex++;
}

function DMTutEvent6()
{
	bPause = True;
	GoToState('FreeRunning1');
}

state FreeRunning1
{
	function Tick(float DeltaTime)
	{
		local int i;
		local string Message;
		local string JumpKey;

		Super.Tick(DeltaTime);

		// Test for strafing and goto next state if true.
		if (Trainee.bWasLeft || Trainee.bWasRight)
		{
			for (i=0; i<255; i++)
			{
				if (KeyAlias[i] ~= "Jump")
				{
					if (JumpKey != "")
						JumpKey = JumpKey$","@KeyNames[i];
					else
						JumpKey = KeyNames[i];
				}
			}

			bPause = False;

			TutorialSound(DM[6]);
			Message = TutMessage6Parts[0]@"["$JumpKey$"]"@TutMessage6Parts[1];
			TournamentConsole(Trainee.Player.Console).AddMessage(Message);
			SoundIndex++;

			GotoState('');
		}
	}
}

function DMTutEvent7()
{
	bPause = True;
	GoToState('FreeRunning2');
}

state FreeRunning2
{
	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		// Test for jumping.
		if (Trainee.Location.Z != LastLocation.Z)
		{
			bPause = False;

			TutorialSound(DM[7]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[7]);
			SoundIndex++;

			GotoState('');
		}
	}

	function BeginState()
	{
		LastLocation = Trainee.Location;
	}
}

function DMTutEvent8()
{
	TutorialSound(DM[8]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[8]);
	SoundIndex++;
}

function DMTutEvent9()
{
	TutorialSound(DM[9]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[9]);
	SoundIndex++;
}

function DMTutEvent10()
{
	bPause = True;
	GoToState('FreeRunning3');
}

state FreeRunning3
{
	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		// Test for mouselook and goto next state if true.
		if (Trainee.Rotation != LastRotation)
		{
			bPause = False;

			TutorialSound(DM[10]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[10]);
			SoundIndex++;

			GotoState('');
		}
	}

	function BeginState()
	{
		LastRotation = Trainee.Rotation;
	}
}

function DMTutEvent11()
{
	TutorialSound(DM[11]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[11]);
	SoundIndex++;
}

function DMTutEvent12()
{
	TutorialSound(DM[12]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[12]);
	SoundIndex++;
}

function DMTutEvent13()
{
	local Mover m;
	foreach AllActors(class'Mover', m)
		m.Trigger(Trainee, Trainee);

	TutorialSound(DM[13]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[13]);
	SoundIndex++;
}

function DMTutEvent14()
{
	bPause = True;
	GoToState('FreeRunning4');
}

state FreeRunning4
{
	function Tick(float DeltaTime)
	{
		local int i;
		local string Message;
		local string FireKey;

		Super.Tick(DeltaTime);

		// Test for weapon pickup and move on.
		if (Trainee.Weapon != None)
		{
			for (i=0; i<255; i++)
			{
				if (KeyAlias[i] ~= "Fire")
				{
					if (FireKey != "")
						FireKey = FireKey$","@KeyNames[i];
					else
						FireKey = KeyNames[i];
				}
			}

			bPause = False;

			TutorialSound(DM[14]);
			Message = TutMessage14Parts[0]@"["$FireKey$"]"@TutMessage14Parts[1];
			TournamentConsole(Trainee.Player.Console).AddMessage(Message);
			SoundIndex++;

			GotoState('');
		}
	}
}

function DMTutEvent15()
{
	bPause = True;
	GoToState('FreeRunning5');
}

state FreeRunning5
{
	function Tick(float DeltaTime)
	{
		local int i;
		local string Message;
		local string FireKey;

		Super.Tick(DeltaTime);

		// Test for weapon fire and move on.
		if (Trainee.bFire != 0)
		{
			for (i=0; i<255; i++)
			{
				if (KeyAlias[i] ~= "AltFire")
				{
					if (FireKey != "")
						FireKey = FireKey$","@KeyNames[i];
					else
						FireKey = KeyNames[i];
				}
			}

			bPause = False;

			TutorialSound(DM[15]);
			Message = TutMessage15Parts[0]@"["$FireKey$"]"@TutMessage15Parts[1];
			TournamentConsole(Trainee.Player.Console).AddMessage(Message);
			SoundIndex++;

			GotoState('');
		}
	}
}

function DMTutEvent16()
{
	bPause = True;
	GoToState('FreeRunning6');
}

state FreeRunning6
{
	function Tick(float DeltaTime)
	{
		local Weapon newWeapon;

		Super.Tick(DeltaTime);

		// Test for weapon altfire and move on.
		if (Trainee.bAltFire != 0)
		{
			bPause = False;

			TutorialSound(DM[16]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[16]);
			SoundIndex++;

			// Give player an enforcer.
			newWeapon = Spawn(class'Enforcer');
			if( newWeapon != None )
			{
				newWeapon.BecomeItem();
				newWeapon.bHeldItem = true;
				Trainee.AddInventory(newWeapon);
				newWeapon.Instigator = Trainee;
				newWeapon.GiveAmmo(Trainee);
				newWeapon.GoToState('DownWeapon');
			}

			GotoState('');
		}
	}
}

function DMTutEvent17()
{
	bPause = True;
	GoToState('FreeRunning7');
}

state FreeRunning7
{
	function Tick(float DeltaTime)
	{
		local Weapon newWeapon;

		Super.Tick(DeltaTime);

		// Test for switch to enforcer.
		if ((Trainee.Weapon != None) && (Trainee.Weapon.IsA('Enforcer')))
		{
			bPause = False;

			TutorialSound(DM[17]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[17]);
			SoundIndex++;

			// Give player an impact hammer.
			newWeapon = Spawn(class'ImpactHammer');
			if( newWeapon != None )
			{
				newWeapon.BecomeItem();
				newWeapon.bHeldItem = true;
				Trainee.AddInventory(newWeapon);
				newWeapon.Instigator = Trainee;
				newWeapon.GiveAmmo(Trainee);
				newWeapon.GoToState('DownWeapon');
			}

			GotoState('');
		}
	}
}

function DMTutEvent18()
{
	bPause = True;
	GoToState('FreeRunning8');
}

state FreeRunning8
{
	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		// Test for switch to impact hammer.
		if ((Trainee.Weapon != None) && (Trainee.Weapon.IsA('ImpactHammer')))
		{
			bPause = False;

			TutorialSound(DM[18]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[18]);
			SoundIndex++;

			GotoState('');
		}
	}
}

function DMTutEvent19()
{
	bPause = True;
	GoToState('FreeRunning9');
}

state FreeRunning9
{
	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		// Test for weapon fire and move on.
		if (Trainee.bFire != 0)
		{
			bPause = False;

			TutorialSound(DM[19]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[19]);
			SoundIndex++;

			GotoState('');
		}
	}
}

function DMTutEvent20()
{
	local Barrel B;
	local string NaliClassString;
	local Nali MyNali;

	bNoMonsters = False;
	// Spawn a Nali
	foreach AllActors(class'Barrel', B)
	{
		MyNali = Spawn(class'Nali',,,B.Location + vect(0,0,100));
		MyNali.Health = 1;
		break;
	}
	bPause = True;
	GoToState('ChunkTheNali');
}

state ChunkTheNali
{
	function Tick(float DeltaTime)
	{
		local Nali N;
		local int NaliCount;

		Super.Tick(DeltaTime);

		// Test for chunked Nali and move on.
		foreach AllActors(class'Nali', N)
		{
			NaliCount++;
		}
		if (NaliCount == 0)
		{
			Trainee.PlayerReplicationInfo.Score = 0;
			bPause = False;

			TutorialSound(DM[20]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[20]);
			SoundIndex++;

			GotoState('');
		}
	}
}

function DMTutEvent21()
{
	local Barrel B;

	foreach AllActors(class'Barrel', B)
	{
		Spawn(class'EnhancedRespawn', B, , B.Location, B.Rotation);
		B.bHidden = False;
		B.SetCollision(True, True, True);
	}

	TutorialSound(DM[21]);
	TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[21]);
	SoundIndex++;
}

function DMTutEvent22()
{

	bPause = True;
	GoToState('FreeRunning10');
}

state FreeRunning10
{
	function Tick(float DeltaTime)
	{
		local int i;
		local Barrel B;

		Super.Tick(DeltaTime);

		// Test for barrel destroy and move on.
		foreach AllActors(class'Barrel', B)
			i++;
		if (i==0)
		{
			bPause = False;

			TutorialSound(DM[22]);
			TournamentConsole(Trainee.Player.Console).AddMessage(TutMessage[22]);
			SoundIndex++;

			GotoState('');
		}
	}
}

function DMTutEvent23()
{
	TournamentConsole(Trainee.Player.Console).HideMessage();

	FragLimit = 3;

	bReadyToSpawn = True;
	bRatedGame = True;

	RemainingBots = 1;
}

function bool SuccessfulGame()
{
	local Pawn P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.bIsPlayer && (P != RatedPlayer) )
			if ( P.PlayerReplicationInfo.Score >= RatedPlayer.PlayerReplicationInfo.Score )
				return false;

	return true;
}

function EndGame( string Reason )
{
	Super.EndGame(Reason);

	if (SuccessfulGame())
		TutorialSound(DM[23]);
	else
		Trainee.ClientPlaySound(sound'Announcer.LostMatch', True);

	if (RatedGameLadderObj != None)
	{
		RatedGameLadderObj.PendingChange = 0;
		RatedGameLadderObj.LastMatchType = LadderTypeIndex;
		if (RatedGameLadderObj.DMPosition < 1)
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
	BeaconName="DM-Tutorial"
	GameName="Combat Training: DM"
	MapPrefix="DM-Tutorial"
	StartUpMessage=""
	bLoggingGame=False
	DM(0)="TutVoicedm.dm00"
	DM(1)="TutVoicedm.dm01"
	DM(2)="TutVoicedm.dm02"
	DM(3)="TutVoicedm.dm03"
	DM(4)="TutVoicedm.dm04"
	DM(5)="TutVoicedm.dm05"
	DM(6)="TutVoicedm.dm06"
	DM(7)="TutVoicedm.dm07"
	DM(8)="TutVoicedm.dm08"
	DM(9)="TutVoicedm.dm09"
	DM(10)="TutVoicedm.dm10"
	DM(11)="TutVoicedm.dm11"
	DM(12)="TutVoicedm.dm12"
	DM(13)="TutVoicedm.dm13"
	DM(14)="TutVoicedm.dm14"
	DM(15)="TutVoicedm.dm15"
	DM(16)="TutVoicedm.dm16"
	DM(17)="TutVoicedm.dm17"
	DM(18)="TutVoicedm.dm18"
	DM(19)="TutVoicedm.dm19"
	DM(20)="TutVoicedm.dm20"
	DM(21)="TutVoicedm.dm21"
	DM(22)="TutVoicedm.dm22"
	DM(23)="TutVoicedm.dm23"
	TutMessage(0)="Welcome to Deathmatch combat training. Deathmatch is a sport in which you compete against other gun-wielding players in a fast paced free-for-all. The object is to destroy all of your enemies by any means necessary."
	TutMessage(1)="Every time you take an enemy out you get a point, called a 'frag' in gaming lingo. You can see your frag count on the left side of the screen. At the end of the game the player with the most frags wins the match."
	TutMessage(2)="Remember, if you accidentally blow yourself up or fall into lava you will lose a frag!"
	TutMessage(3)="Let's learn some basics about moving around. A good deathmatch player is always moving, because a moving target is harder to hit than a stationary one."
	TutMessage(4)="The forward key moves you forward while the backward key makes you backpedal. The left key causes you to strafe left, while the right key, you guessed it, strafes right."
	TutMessage4Parts(0)="The forward key"
	TutMessage4Parts(1)="moves you forward while the backward key"
	TutMessage4Parts(2)="makes you backpedal. The left key"
	TutMessage4Parts(3)="causes you to strafe left, while the right key"
	TutMessage4Parts(4)=", you guessed it, strafes right."
	TutMessage(5)="Strafing is extremely important in deathmatch because it allows you to move from side to side without turning and losing sight or aim of your foe. Let's try strafing left and right now."
	TutMessage(6)="Another important element of moving around is jumping. Jumping allows you to reach areas of the map that are too high to walk to normally and to cross dangerous pits. Try pressing the jump button and jump around the map."
	TutMessage6Parts(0)="Another important element of moving around is jumping. Jumping allows you to reach areas of the map that are too high to walk to normally and to cross dangerous pits. Try pressing the jump button"
	TutMessage6Parts(1)="and jump around the map."
	TutMessage(7)="Excellent."
	TutMessage(8)="Now we're going to learn about Mouselooking. Move your mouse around and notice how your view shifts. This is how you look around and turn, known as Mouselook."
	TutMessage(9)="Try turning around several times by moving the mouse left to right to see the lovely battle arena."
	TutMessage(10)="Excellent. You can also look vertically to see what's occuring above and below you. In deathmatch your enemies will be attacking from above and below, so remember to always keep your eyes peeled."
	TutMessage(11)="If you feel like you are looking around too quickly you can easily adjust the sensitivity of the mouse in the OPTIONS menu."
	TutMessage(12)="Let's learn about offense. Remember, the only way to win at deathmatch is to destroy your foes with weaponry that you collect."
	TutMessage(13)="I'm going to open the weapons locker and allow access to some guns, let's pick them up and get ready for some target practice."
	TutMessage(14)="Great, now we're armed. The gun you're carrying is commonly called the 'Shock Rifle'. It, like all the weapons in the Tournament, has two firing modes. Let's try shooting the gun now. Press the fire button to emit a lethal electric beam."
	TutMessage14Parts(0)="Great, now we're armed. The gun you're carrying is commonly called the 'Shock Rifle'. It, like all the weapons in the Tournament, has two firing modes. Let's try shooting the gun now. Press the fire button"
	TutMessage14Parts(1)="to emit a lethal electric beam."
	TutMessage(15)="Very good. The Shock Rifle's primary fire will instantly hit the person you shoot at. In Unreal Tournament, every weapon also has an alternate firing mode. Press the alt fire button to shoot a ball of plasma at your enemy."
	TutMessage15Parts(0)="Very good. The Shock Rifle's primary fire will instantly hit the person you shoot at. In Unreal Tournament, every weapon also has an alternate firing mode. Press the alt fire button"
	TutMessage15Parts(1)="to shoot a ball of plasma at your enemy."
	TutMessage(16)="Great! The alt fire on the Shock Rifle is slower moving than the primary fire, but does more damage. Its up to you to decide which attack is right for the situation. Sometimes you might be carrying more than one weapon. I've just put an 'Enforcer' sidearm in your pack. Each weapon has an associated number, as you can see at the bottom of your screen. The Enforcer is weapon number 2. Press 2 and switch to the enforcer. You can switch back to the Shock Rifle by pressing its number."
	TutMessage(17)="Good, now you know how to switch weapons in battle. Every weapon in Unreal Tournament is a projectile weapon except one, the 'Impact Hammer'. Press 1 now to switch to the Impact Hammer."
	TutMessage(18)="The Impact Hammer is a melee, or close combat, weapon. It requires you to be standing very close to the target to do damage. The tradeoff is that a hit will almost always kill your enemy. Press and hold the primary fire button now to charge up the impact hammer."
	TutMessage(19)="Now, run up to the Nali I just spawned. When you get close enough, the Impact Hammer will release blowing him into pieces."
	TutMessage(20)="Look at those gibs fly!  Great job."
	TutMessage(21)="Good job. Now we're going to take out some stationary targets. Shoot all three barrels to proceed."
	TutMessage(22)="Nice shootin' Tex. It's about to get harder. I'm going to release a training human opponent for you to practice on. You'll have to frag him three times to complete the tutorial. Good luck!"
	TutMessage(23)="Congratulations! You have proven yourself to be a worthy Deathmatch player. Now its time to enter the Deathmatch Tournament Ladder."
	LastEvent=24
}
