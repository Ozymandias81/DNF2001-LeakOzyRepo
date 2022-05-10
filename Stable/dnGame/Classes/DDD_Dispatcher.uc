//=============================================================================
// DDD_Dispatcher:
// Designed to handle the DDD machine and remove the slight hitches and pauses
// causing the game to get out of synch as well as a few special functions.
//
// Charlie Wiederhold - August 1st, 2001
//
//**Things that machines assume are true/rules to follow when using a machine**
// - Arrow Spawners will be named <MachineTitle>_LeftArrowSpawner_Downbeat
//   or <MachineTitle>_LeftArrowSpawner_Upbeat, and on and on
// - To use the dancer instead of the player, the event called will be <Tag>_UseDancer
// - Event that is called to start your music will be <MachineTitle>_<DanceBPM>BPM
// - The give and take events will be <MachineTitle>_GivePoint_Left
// - Move Events called on beats are assumed to be named <MachineName>_CallMove_LeftArrow_Downbeat
//
//=============================================================================
class DDD_Dispatcher extends DDD_Controls;

//-----------------------------------------------------------------------------
// Dispatcher variables.

var(DDD_Main)  name		MachineTitle;		// Title of the specific DDD machine this one works with
var(DDD_Main)  name		DancerControl;	// Name of the dancer who will be dancing to this song (assumes there is a DancerUsedTag)
var(DDD_Main)  name		InputControl;		// Name of the input controller to detect all input for this machine
var(DDD_Main)  int		DanceBPM; 			// Speed of this specific dance

var(DDD_Moves) EMoves	MovesDB[256]; 	// Downbeat dance move
var(DDD_Moves) EMoves	MovesUB[256]; 	// Upbeat dance move

var(DDD_Intro) int		IntroLength;		// Number of beats to wait before first dance move is valid (must be 8 or higher)
var(DDD_Intro) name		IntroStartEvent;	// Event to call at the start of the intro
var(DDD_Intro) name		IntroGetSetEvent;	// Event to call 4 beats before dance starts
var(DDD_Intro) name		IntroEndEvent;	// Event to call at the end of the intro
var(DDD_Intro) name		IntroDBEvent;		// Event to call on each downbeat during the intro
var(DDD_Intro) name		IntroUBEvent;		// Event to call on each downbeat during the intro

var(DDD_Dance) int		DanceLength;		// Number of beats in the song. Does not count Intro or Outro
var(DDD_Dance) name		DanceStartEvent;	// Event to call at the start of the dance
var(DDD_Dance) name		DanceEndEvent;	// Event to call at the end of the dance
var(DDD_Dance) name		DanceDBEvent;		// Event to call on each downbeat, used for displays of tempo
var(DDD_Dance) name		DanceUBEvent;		// Event to call on each upbeat, used for displays of tempo

var(DDD_Outro) int		OutroLength;		// Number of beats to wait after last dance move is valid (can be anything)
var(DDD_Outro) name		OutroStartEvent;	// Event to call at the start of the outro
var(DDD_Outro) name		OutroEndEvent;	// Event to call at the end of the outro
var(DDD_Outro) name		OutroDBEvent;		// Event to call on each downbeat during the intro
var(DDD_Outro) name		OutroUBEvent;		// Event to call on each downbeat during the intro

var 			 name		SongEvent;			// Event to call, specifically designed to start the music

var int 					i;                // Internal counter.
var TriggerSelfForward 	ResetTrigger;
var TriggerSelfForward 	DancerUsedTrigger;
var bool					DancerUsed;
var name					DancerUsedTag;	// When called with *this* name, the dancer will be used, never otherwise

var float					DanceMoveDelay;	// Default time to delay between calling each event
var float					NextMoveTime;		// Real amount of time to delay before making the next move
var float					TargetTime;		// Time that the next move *should* happen
var float					ArrowLifetime;	// Amount of time for the arrow to live in the world
var vector					ArrowVelocity;	// Speed at which the arrows and detectors move

//=============================================================================
// Dispatcher logic.

function PostBeginPlay()
{
	super.PostBeginPlay();

	DanceMoveDelay = 60 / DanceBPM;
	NextMoveTime = DanceMoveDelay;

	ArrowVelocity.Z = (Float(DanceBPM) / 60.0) * 8.0;
	ArrowLifetime = 80.0 / ArrowVelocity.Z;
	
	SongEvent = NameForString (""$MachineTitle$"_"$DanceBPM$"BPM");

	if (IntroLength < 8)
		IntroLength = 8;

	DancerUsedTag = NameForString (""$Tag$"_UseDancer");
	DancerUsedTrigger = Spawn(class'Engine.TriggerSelfForward',self);
	DancerUsedTrigger.tag=DancerUsedTag;
	DancerUsedTrigger.event=Tag;
}

//=============================================================================
// Assign DancerControl information
//
function StartDancerControl()
{

local DDD_DancerControl	DancerController;

	// Start all the DancerControls
	foreach AllActors( class 'DDD_DancerControl', DancerController, DancerControl )
		DancerController.AssignDanceInfo( IntroLength, DanceLength, OutroLength, DanceMoveDelay, TargetTime, MachineTitle );
	GlobalTrigger (DancerControl);
}

//=============================================================================
// Assign InputControl information
//
function StartInputControl()
{

local DDD_InputControl	InputController;

	// Start all the InputControls
	foreach AllActors( class 'DDD_InputControl', InputController, InputControl )
		InputController.AssignDanceInfo( IntroLength, DanceLength, DanceMoveDelay, TargetTime, MachineTitle );
	GlobalTrigger (InputControl);
}

//=============================================================================
// Initializes an arrow spawner
//
function InitializeArrowSpawner (name ArrowSpawnerName)
{
local SoftParticleSystem		ArrowSpawner;

	foreach AllActors( class 'SoftParticleSystem', ArrowSpawner, ArrowSpawnerName )
	{
		ArrowSpawner.Lifetime = ArrowLifetime;
		ArrowSpawner.InitialVelocity = ArrowVelocity;
	}
}

//=============================================================================
// Pauses for half a beat
//
function WaitHalfBeat()
{
	TargetTime += DanceMoveDelay / 2;
	NextMoveTime = TargetTime - Level.TimeSeconds;
	Sleep(NextMoveTime);
}

//=============================================================================
// Executes a beat
//
function ExecuteBeat(EMoves BeatStyle, name BeatType)
{
	switch (BeatStyle)
	{
	case NoMove:
		return;
	case Up:
		GlobalTrigger (NameForString(""$MachineTitle$"_CallMove_UpArrow_"$BeatType));
		break;
	case Down:
		GlobalTrigger (NameForString(""$MachineTitle$"_CallMove_DownArrow_"$BeatType));
		break;
	case Left:
		GlobalTrigger (NameForString(""$MachineTitle$"_CallMove_LeftArrow_"$BeatType));
		break;
	case Right:
		GlobalTrigger (NameForString(""$MachineTitle$"_CallMove_RightArrow_"$BeatType));
		break;
	case LeftUp:
		GlobalTrigger (NameForString(""$MachineTitle$"_CallMove_LeftUpArrow_"$BeatType));
		break;
	case LeftDown:
		GlobalTrigger (NameForString(""$MachineTitle$"_CallMove_LeftDownArrow_"$BeatType));
		break;
	case LeftRight:
		GlobalTrigger (NameForString(""$MachineTitle$"_CallMove_LeftRightArrow_"$BeatType));
		break;
	case RightUp:
		GlobalTrigger (NameForString(""$MachineTitle$"_CallMove_RightUpArrow_"$BeatType));
		break;
	case RightDown:
		GlobalTrigger (NameForString(""$MachineTitle$"_CallMove_RightDownArrow_"$BeatType));
		break;
	}
}

//=============================================================================
// When dispatcher is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{

local DDD_DancerControl		DancerController;
local DDD_InputControl		InputController;
local TriggerSpawn			DetectorSpawner;

	if (Other == DancerUsedTrigger)
	{
		for (i=0; i<DanceLength; i++)
			foreach AllActors( class 'DDD_DancerControl', DancerController, DancerControl )
				DancerController.AssignMove( i, MovesDB[i], MovesUB[i] );
		DancerUsed = True;
	}
	else
	{
		foreach AllActors( class 'DDD_InputControl', InputController, InputControl )
			for (i=0; i<DanceLength; i++)
				InputController.AssignMove( i, MovesDB[i], MovesUB[i] );
		DancerUsed = False;
	}
	
	// Setup all the visible arrow spawners
	InitializeArrowSpawner (NameForString (""$MachineTitle$"_UpArrowSpawner_Downbeat"));
	InitializeArrowSpawner (NameForString (""$MachineTitle$"_DownArrowSpawner_Downbeat"));
	InitializeArrowSpawner (NameForString (""$MachineTitle$"_LeftArrowSpawner_Downbeat"));
	InitializeArrowSpawner (NameForString (""$MachineTitle$"_RightArrowSpawner_Downbeat"));
	InitializeArrowSpawner (NameForString (""$MachineTitle$"_UpArrowSpawner_Upbeat"));
	InitializeArrowSpawner (NameForString (""$MachineTitle$"_DownArrowSpawner_Upbeat"));
	InitializeArrowSpawner (NameForString (""$MachineTitle$"_LeftArrowSpawner_Upbeat"));
	InitializeArrowSpawner (NameForString (""$MachineTitle$"_RightArrowSpawner_Upbeat"));

	Instigator = EventInstigator;
	gotostate('Dispatch');
}

//=============================================================================
// Dispatch events.
//
state Dispatch
{

Begin:

	// Get the start of this entire thing
	TargetTime = Level.TimeSeconds;
	if (DancerUsed)
		StartDancerControl();
	else StartInputControl();
	GlobalTrigger (SongEvent);
	GlobalTrigger (IntroStartEvent);

	// Intro section, prior to dance moves being triggered
	for( i=0; i<(IntroLength - 8); i++ )
	{
		// Downbeat
		GlobalTrigger (IntroDBEvent);
		WaitHalfBeat();

		// Upbeat
		GlobalTrigger (IntroUBEvent);
		WaitHalfBeat();
	}

	// Intro section, with dance moves being triggered
	for( i=0; i<8; i++ )
	{
		// Downbeat
		if (i==4)
			GlobalTrigger (IntroGetSetEvent);
		GlobalTrigger (IntroDBEvent);
		ExecuteBeat (MovesDB[i],'Downbeat');
		WaitHalfBeat();

		// Upbeat
		GlobalTrigger (IntroUBEvent);
		ExecuteBeat (MovesUB[i],'Upbeat');
		WaitHalfBeat();
	}

	GlobalTrigger (IntroEndEvent);
	GlobalTrigger (DanceStartEvent);

	// Main dance section
	for( i=8; i<DanceLength; i++ )
	{
		// Downbeat
		GlobalTrigger (DanceDBEvent);
		ExecuteBeat (MovesDB[i],'Downbeat');
		WaitHalfBeat();

		// Upbeat
		GlobalTrigger (DanceUBEvent);
		ExecuteBeat (MovesUB[i],'Upbeat');
		WaitHalfBeat();
	}

	// Dance section, finishing the left over arrows
	for( i=0; i<8; i++ )
	{
		// Downbeat
		GlobalTrigger (DanceDBEvent);
		WaitHalfBeat();

		// Upbeat
		GlobalTrigger (DanceUBEvent);
		WaitHalfBeat();
	}

	GlobalTrigger (DanceEndEvent);
	GlobalTrigger (OutroStartEvent);

	// Outtro section
	for( i=0; i<OutroLength; i++ )
	{
		// Downbeat
		GlobalTrigger (OutroDBEvent);
		WaitHalfBeat();

		// Upbeat
		GlobalTrigger (OutroUBEvent);
		WaitHalfBeat();
	}

	GlobalTrigger (OutroEndEvent);
	GlobalTrigger (SongEvent);
	GotoState( '' );
}

defaultproperties
{
}