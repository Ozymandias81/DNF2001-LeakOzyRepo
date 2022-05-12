class UTConsole extends TournamentConsole;

// Speech
var SpeechWindow		SpeechWindow;
var globalconfig byte	SpeechKey;

// Timedemo
var bool				bTimeDemoIsEntry;

// Message
var bool				bShowMessage, bWasShowingMessage;
var MessageWindow		MessageWindow;

var string ManagerWindowClass;
var string UTLadderDMClass;
var string UTLadderCTFClass;
var string UTLadderDOMClass;
var string UTLadderASClass;
var string UTLadderChalClass;

var string UTLadderDMTestClass;
var string UTLadderDOMTestClass;

var string InterimObjectType;
var string SlotWindowType;

var config string SavedPasswords[10];

event PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);

	if(bShowSpeech || bShowMessage)
		RenderUWindow( Canvas );
}

event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	local ManagerWindowStub ManagerMenu;

	if( Action!=IST_Press )
		return false;

	if( Key==SpeechKey )
	{
		if ( !bShowSpeech && !bTyping )
		{
			ShowSpeech();
			bQuickKeyEnable = True;
			LaunchUWindow();
		}
		return true;
	}

	if( Key == IK_Escape )
	{
		if ( (Viewport.Actor.Level.NetMode == NM_Standalone)
			 && Viewport.Actor.Level.Game.IsA('TrophyGame') )
		{
			bQuickKeyEnable = False;
			LaunchUWindow();
			bLocked = True;
			UMenuRootWindow(Root).MenuBar.HideWindow();
			ManagerMenu = ManagerWindowStub(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject(ManagerWindowClass, Class'Class')), 100, 100, 200, 200, Root, True));
			return true;
		}
	}
	return Super.KeyEvent(Key, Action, Delta );
}

event Tick( float Delta )
{
	Super.Tick( Delta );

	if ( (Root != None) && bShowMessage )
		Root.DoTick( Delta );
}

state UWindow
{
	event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		if(Action==IST_Release && Key==SpeechKey)
		{
			if (bShowSpeech)
				HideSpeech();
			return True;
		}

		return Super.KeyEvent(Key, Action, Delta);
	}

	event Tick( float Delta )
	{
		local Music MenuSong;

		Super.Tick( Delta );

		if (Root == None)
			return;
		if (Root.GetPlayerOwner().Song == None)
		{
			MenuSong = Music(DynamicLoadObject("utmenu23.utmenu23", class'Music'));
			Root.GetPlayerOwner().ClientSetMusic( MenuSong, 0, 0, MTRAN_Fade );
		}
	}
	exec function MenuCmd(int Menu, int Item)
	{
	}
}

state Typing
{
	exec function MenuCmd(int Menu, int Item)
	{
	}
}

function LaunchUWindow()
{
	Super.LaunchUWindow();

	if( !bQuickKeyEnable && 
	    ( Left(Viewport.Actor.Level.GetLocalURL(), 9) ~= "cityintro" || 
	      Left(Viewport.Actor.Level.GetLocalURL(), 9) ~= "utcredits") )
		Viewport.Actor.ClientTravel( "?entry", TRAVEL_Absolute, False );

	if (bShowMessage)
	{
		bWasShowingMessage = True;
		HideMessage();
	}
}

function CloseUWindow()
{
	Super.CloseUWindow();

	if (bWasShowingMessage)
		ShowMessage();
}

function CreateRootWindow(Canvas Canvas)
{
	Super.CreateRootWindow(Canvas);

	// Create the speech window.
	CreateSpeech();

	// Create the message window.
	CreateMessage();
}

function EvaluateMatch(int PendingChange, bool Evaluate)
{
	local UTLadderStub LadderMenu;
	local ManagerWindowStub ManagerMenu;

	LaunchUWindow();
	bNoDrawWorld = True;
	bLocked = True;
	UMenuRootWindow(Root).MenuBar.HideWindow();

	switch (PendingChange)
	{
		case 0:
			ManagerMenu = ManagerWindowStub(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject(ManagerWindowClass, Class'Class')), 100, 100, 200, 200, Root, True));
			break;
		case 1:
			LadderMenu = UTLadderStub(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject(UTLadderDMClass, Class'Class')), 100, 100, 200, 200, Root, True));
			if (Evaluate)
				LadderMenu.EvaluateMatch();
			break;
		case 2:
			LadderMenu = UTLadderStub(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject(UTLadderCTFClass, Class'Class')), 100, 100, 200, 200, Root, True));
			if (Evaluate)
				LadderMenu.EvaluateMatch();
			break;
		case 3:
			LadderMenu = UTLadderStub(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject(UTLadderDOMClass, Class'Class')), 100, 100, 200, 200, Root, True));
			if (Evaluate)
				LadderMenu.EvaluateMatch();
			break;
		case 4:
			LadderMenu = UTLadderStub(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject(UTLadderASClass, Class'Class')), 100, 100, 200, 200, Root, True));
			if (Evaluate)
				LadderMenu.EvaluateMatch();
			break;
		case 5:
			LadderMenu = UTLadderStub(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject(UTLadderChalClass, Class'Class')), 100, 100, 200, 200, Root, True));
			if (Evaluate)
				LadderMenu.EvaluateMatch();
			break;
		case 6:
			LadderMenu = UTLadderStub(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject(UTLadderDMTestClass, Class'Class')), 100, 100, 200, 200, Root, True));
			if (Evaluate)
				LadderMenu.EvaluateMatch();
			break;
		case 7:
			LadderMenu = UTLadderStub(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject(UTLadderDOMTestClass, Class'Class')), 100, 100, 200, 200, Root, True));
			if (Evaluate)
				LadderMenu.EvaluateMatch();
			break;
	}
}

function StartNewGame()
{
	local class<Info> InterimObjectClass;
	local Info InterimObject;

	Log("Starting a new game...");
	InterimObjectClass = Class<Info>(DynamicLoadObject(InterimObjectType, Class'Class'));
	InterimObject = Root.GetPlayerOwner().Spawn(InterimObjectClass, Root.GetPlayerOwner());
}

function LoadGame()
{
	// Clear all slots.
	Root.GetPlayerOwner().PlaySound(sound'LadderSounds.ladvance', SLOT_None, 0.1);
	Root.GetPlayerOwner().PlaySound(sound'LadderSounds.ladvance', SLOT_Misc, 0.1);
	Root.GetPlayerOwner().PlaySound(sound'LadderSounds.ladvance', SLOT_Pain, 0.1);
	Root.GetPlayerOwner().PlaySound(sound'LadderSounds.ladvance', SLOT_Interact, 0.1);
	Root.GetPlayerOwner().PlaySound(sound'LadderSounds.ladvance', SLOT_Talk, 0.1);
	Root.GetPlayerOwner().PlaySound(sound'LadderSounds.ladvance', SLOT_Interface, 0.1);

	// Create load game dialog.
	bNoDrawWorld = True;
	bLocked = True;
	UMenuRootWindow(Root).MenuBar.HideWindow();

	// Go to the slot window.
	Root.CreateWindow(Class<UWindowWindow>(DynamicLoadObject(SlotWindowType, class'Class')), 100, 100, 200, 200, Root, True);
}

function NotifyLevelChange()
{
	Super.NotifyLevelChange();

	bWasShowingMessage = False;
	HideMessage();
}

/*
 * Speech
 */

function CreateSpeech()
{
	SpeechWindow = SpeechWindow(Root.CreateWindow(Class'SpeechWindow', 100, 100, 200, 200));
	SpeechWindow.bLeaveOnScreen = True;
	if(bShowSpeech)
	{
		Root.SetMousePos(0, 132.0/768 * Root.WinWidth);
		SpeechWindow.SlideInWindow();
	} else
		SpeechWindow.HideWindow();
}

function ShowSpeech()
{
	if (bUWindowActive)
		return;

	bShowSpeech = True;
	if (bCreatedRoot)
	{
		Root.SetMousePos(0, 132.0/768 * Root.WinWidth);
		SpeechWindow.SlideInWindow();
		if ( ChallengeHUD(Viewport.Actor.myHUD) != None )
			ChallengeHUD(Viewport.Actor.myHUD).bHideCenterMessages = true;
	}
}

function HideSpeech()
{
	bShowSpeech = False;
	if ( ChallengeHUD(Viewport.Actor.myHUD) != None )
		ChallengeHUD(Viewport.Actor.myHUD).bHideCenterMessages = false;

	if (SpeechWindow != None)
		SpeechWindow.SlideOutWindow();
}

/*
 * Tutorial Message Interface
 */

function CreateMessage()
{
	MessageWindow = MessageWindow(Root.CreateWindow(Class'MessageWindow', 100, 100, 200, 200));
	MessageWindow.bLeaveOnScreen = True;
	MessageWindow.HideWindow();
}

function ShowMessage()
{
	if (MessageWindow != None)
	{
		bWasShowingMessage = False;
		bShowMessage = True;
		MessageWindow.ShowWindow();
	}
}

function HideMessage()
{
	if (MessageWindow != None)
	{
		bShowMessage = False;
		MessageWindow.HideWindow();
	}
}

function AddMessage( string NewMessage )
{
	MessageWindow.AddMessage( NewMessage );
}

exec function ShowObjectives()
{
	local GameReplicationInfo GRI;

	if(!bCreatedRoot)
		CreateRootWindow(None);
	foreach Root.GetPlayerOwner().AllActors(class'GameReplicationInfo', GRI)
	{
		if (GRI.GameClass == "Botpack.Assault")
		{
			bLocked = True;
			bNoDrawWorld = True;
			UMenuRootWindow(Root).MenuBar.HideWindow();
			LaunchUWindow();
			Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject("UTMenu.InGameObjectives", class'Class')), 100, 100, 100, 100);
		}
	}
}

event ConnectFailure( string FailCode, string URL )
{
	local int i, j;
	local string Server;
	local UTPasswordWindow W;

	if(FailCode == "NEEDPW")
	{
		Server = Left(URL, InStr(URL, "/"));
		for(i=0; i<10; i++)
		{
			j = InStr(SavedPasswords[i], "=");
			if(Left(SavedPasswords[i], j) == Server)
			{
				Viewport.Actor.ClearProgressMessages();
				Viewport.Actor.ClientTravel(URL$"?password="$Mid(SavedPasswords[i], j+1), TRAVEL_Absolute, false);
				return;
			}
		}
	}

	if(FailCode == "NEEDPW" || FailCode == "WRONGPW")
	{
		Viewport.Actor.ClearProgressMessages();
		CloseUWindow();
		bQuickKeyEnable = True;
		LaunchUWindow();
		W = UTPasswordWindow(Root.CreateWindow(class'UTPasswordWindow', 100, 100, 100, 100));
		UTPasswordCW(W.ClientArea).URL = URL;
	}
}

function ConnectWithPassword(string URL, string Password)
{
	local int i;
	local string Server;
	local bool bFound;

	if(Password == "")
	{
		Viewport.Actor.ClientTravel(URL, TRAVEL_Absolute, false);
		return;
	}

	bFound = False;
	Server = Left(URL, InStr(URL, "/"));
	for(i=0; i<10; i++)
	{
		if(Left(SavedPasswords[i], InStr(SavedPasswords[i], "=")) == Server)
		{
			SavedPasswords[i] = Server$"="$Password;
			bFound = True;
			break;
		}
	}
	if(!bFound)
	{
		for(i=9; i>0; i--)
			SavedPasswords[i] = SavedPasswords[i-1];
		SavedPasswords[0] = Server$"="$Password;	
	}
	SaveConfig();
	Viewport.Actor.ClientTravel(URL$"?password="$Password, TRAVEL_Absolute, false);
}

exec function MenuCmd(int Menu, int Item)
{
	if (bLocked)
		return;

	bQuickKeyEnable = False;
	LaunchUWindow();
	if(!bCreatedRoot) 
		CreateRootWindow(None);
	UMenuRootWindow(Root).MenuBar.MenuCmd(Menu, Item);
}

function StartTimeDemo()
{
	TimeDemoFont = None;
	Super.StartTimeDemo();
	bTimeDemoIsEntry =		Viewport.Actor.Level.Game != None
						&&	Viewport.Actor.Level.Game.IsA('UTIntro') 
						&&	!(Left(Viewport.Actor.Level.GetLocalURL(), 9) ~= "cityintro");
}

function TimeDemoRender( Canvas C )
{
	if(	TimeDemoFont == None )
		TimeDemoFont = class'FontInfo'.Static.GetStaticSmallFont(C.ClipX);

	if( !bTimeDemoIsEntry )
		Super.TimeDemoRender(C);
	else
	{
		if( Viewport.Actor.Level.Game == None ||
			!Viewport.Actor.Level.Game.IsA('UTIntro') ||
			(Left(Viewport.Actor.Level.GetLocalURL(), 9) ~= "cityintro")
		)
		{
			bTimeDemoIsEntry = False;
			Super.TimeDemoRender(C);
		}
	}
}

function PrintTimeDemoResult()
{
	if( !bTimeDemoIsEntry )
		Super.PrintTimeDemoResult();
}

defaultproperties
{
	ManagerWindowClass="UTMenu.ManagerWindow"
	UTLadderDMClass="UTMenu.UTLadderDM"
	UTLadderCTFClass="UTMenu.UTLadderCTF"
	UTLadderDOMClass="UTMenu.UTLadderDOM"
	UTLadderASClass="UTMenu.UTLadderAS"
	UTLadderChalClass="UTMenu.UTLadderChal"
	UTLadderDMTestClass="UTMenu.UTLadderDMTest"
	UTLadderDOMTestClass="UTMenu.UTLadderDOMTest"
	// IK_V
	SpeechKey=86

	InterimObjectType="UTMenu.NewGameInterimObject"
	SlotWindowType="UTMenu.SlotWindow"
}