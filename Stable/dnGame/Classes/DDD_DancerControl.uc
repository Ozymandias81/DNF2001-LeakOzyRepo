//=============================================================================
// DDD_DancerControl:
// Designed to handle the events of an NPC playing the DDD machine. Including
// their skill level, etc.
// 
// Charlie Wiederhold - August 1st, 2001
//
// Assumptions and rules for DancerControls
// - The move names will be <DancerName>_CallMove_LeftArrow
// - The dancer's most recent score updater will be <DancerName>_DancerScore_ToCurrentScore
//=============================================================================
class DDD_DancerControl extends DDD_Controls;

//-----------------------------------------------------------------------------
// Dispatcher variables.

var(DDD_Main) name		DancerName;			// Appends the name of the dancer to the moves, so they will be unique
var(DDD_Main) float		DancerSkillLevel;		// 0 - 1 Skill level. 0 never hits, 1 always hits
var(DDD_Main) float		DancerPanicLevel;		// 0 - 1 Higher the number, the more likely to hit the wrong pad

var EMoves					MovesDB[256]; 		// Downbeat dance move
var EMoves					MovesUB[256]; 		// Upbeat dance move

var name					DancerFinalScore;	// Used to call the event which will update the Dancer's final score

var name					HitMoveEvent_Up;		// Event to call when an up move is hit;
var name					HitMoveEvent_Down;	// Event to call when a down move is hit;
var name					HitMoveEvent_Left;	// Event to call when a left move is hit;
var name					HitMoveEvent_Right;	// Event to call when a right move is hit;
var name					WrongMoveEvent_Up;	// Event to call when an up move is wrong;
var name					WrongMoveEvent_Down;	// Event to call when a down move is wrong;
var name					WrongMoveEvent_Left;	// Event to call when a left move is wrong;
var name					WrongMoveEvent_Right;// Event to call when a right move is wrong;

var int					IntroLength;			// Number of beats to wait before first dance move is valid (must be 8 or higher)
var(DDD_Intro) name		IntroStartEvent;		// Event to call at the start of the intro
var(DDD_Intro) name		IntroGetSetEvent;		// Event to call 4 beats before dance starts
var(DDD_Intro) name		IntroEndEvent;		// Event to call at the end of the intro
var(DDD_Intro) name		IntroDBEvent;			// Event to call on each downbeat during the intro
var(DDD_Intro) name		IntroUBEvent;			// Event to call on each downbeat during the intro

var int					DanceLength;			// Number of beats in the song. Does not count Intro or Outro
var(DDD_Dance) name		DanceStartEvent;		// Event to call at the start of the dance
var(DDD_Dance) name		DanceEndEvent;		// Event to call at the end of the dance
var(DDD_Dance) name		DanceDBEvent;			// Event to call on each downbeat, used for displays of tempo
var(DDD_Dance) name		DanceUBEvent;			// Event to call on each upbeat, used for displays of tempo

var int					OutroLength;			// Number of beats to wait after last dance move is valid (can be anything)
var(DDD_Outro) name		OutroStartEvent;		// Event to call at the start of the outro
var(DDD_Outro) name		OutroEndEvent;		// Event to call at the end of the outro
var(DDD_Outro) name		OutroDBEvent;			// Event to call on each downbeat during the intro
var(DDD_Outro) name		OutroUBEvent;			// Event to call on each downbeat during the intro

var int 					i;                	// Internal counter.
var TriggerSelfForward 	ResetTrigger;

var float					DanceMoveDelay;		// Default time to delay between calling each event
var float					NextMoveTime;			// Real amount of time to delay before making the next move
var float					TargetTime;			// Time that the next move *should* happen

//=============================================================================
// Dispatcher logic.

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	DancerFinalScore = NameForString (""$DancerName$"_DancerScore_ToCurrentScore");

}

//=============================================================================
// Assign a move to the dancer
//
function AssignMove(int MoveIndex, EMoves MoveDBType, EMoves MoveUBType)
{
	MovesDB[MoveIndex] = MoveDBType;
	MovesUB[MoveIndex] = MoveUBType;
}

//=============================================================================
// Assign dance information
//
function AssignDanceInfo(int NewIntroLength, int NewDanceLength, int NewOutroLength, float NewDanceMoveDelay, float NewTargetTime, name MachineTitle)
{
	IntroLength = NewIntroLength;
	DanceLength = NewDanceLength;
	OutroLength = NewOutroLength;
	DanceMoveDelay = NewDanceMoveDelay;
	TargetTime = NewTargetTime;
	TargetTime -= 0.1;

	HitMoveEvent_Up = NameForString (""$MachineTitle$"_GivePoint_Up");
	HitMoveEvent_Down = NameForString (""$MachineTitle$"_GivePoint_Down");
	HitMoveEvent_Left = NameForString (""$MachineTitle$"_GivePoint_Left");
	HitMoveEvent_Right = NameForString (""$MachineTitle$"_GivePoint_Right");
	
	WrongMoveEvent_Up = NameForString (""$MachineTitle$"_TakePoint_Up");
	WrongMoveEvent_Down = NameForString (""$MachineTitle$"_TakePoint_Down");
	WrongMoveEvent_Left = NameForString (""$MachineTitle$"_TakePoint_Left");
	WrongMoveEvent_Right = NameForString (""$MachineTitle$"_TakePoint_Right");
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
function ExecuteBeat(EMoves BeatStyle, bool ValidMove)
{
	switch (BeatStyle)
	{
	case NoMove:
		return;
	case Up:
		GlobalTrigger (NameForString(""$DancerName$"_CallMove_UpArrow"));
		if (ValidMove)
			GlobalTrigger (HitMoveEvent_Up);
		else GlobalTrigger (WrongMoveEvent_Up);
		break;
	case Down:
		GlobalTrigger (NameForString(""$DancerName$"_CallMove_DownArrow"));
		if (ValidMove)
			GlobalTrigger (HitMoveEvent_Down);
		else GlobalTrigger (WrongMoveEvent_Down);
		break;
	case Left:
		GlobalTrigger (NameForString(""$DancerName$"_CallMove_LeftArrow"));
		if (ValidMove)
			GlobalTrigger (HitMoveEvent_Left);
		else GlobalTrigger (WrongMoveEvent_Left);
		break;
	case Right:
		GlobalTrigger (NameForString(""$DancerName$"_CallMove_RightArrow"));
		if (ValidMove)
			GlobalTrigger (HitMoveEvent_Right);
		else GlobalTrigger (WrongMoveEvent_Right);
		break;
	case LeftUp:
		GlobalTrigger (NameForString(""$DancerName$"_CallMove_LeftUpArrow"));
		if (ValidMove)
		{
			GlobalTrigger (HitMoveEvent_Left);
			GlobalTrigger (HitMoveEvent_Up);
		}
		else GlobalTrigger (WrongMoveEvent_Up);
		break;
	case LeftDown:
		GlobalTrigger (NameForString(""$DancerName$"_CallMove_LeftDownArrow"));
		if (ValidMove)
		{
			GlobalTrigger (HitMoveEvent_Left);
			GlobalTrigger (HitMoveEvent_Down);
		}
		else GlobalTrigger (WrongMoveEvent_Down);
		break;
	case LeftRight:
		GlobalTrigger (NameForString(""$DancerName$"_CallMove_LeftRightArrow"));
		if (ValidMove)
		{
			GlobalTrigger (HitMoveEvent_Left);
			GlobalTrigger (HitMoveEvent_Right);
		}
		else GlobalTrigger (WrongMoveEvent_Left);
		break;
	case RightUp:
		GlobalTrigger (NameForString(""$DancerName$"_CallMove_RightUpArrow"));
		if (ValidMove)
		{
			GlobalTrigger (HitMoveEvent_Right);
			GlobalTrigger (HitMoveEvent_Up);
		}	
		else GlobalTrigger (WrongMoveEvent_Up);
		break;
	case RightDown:
		GlobalTrigger (NameForString(""$DancerName$"_CallMove_RightDownArrow"));
		if (ValidMove)
		{
			GlobalTrigger (HitMoveEvent_Right);
			GlobalTrigger (HitMoveEvent_Down);
		}
		else GlobalTrigger (WrongMoveEvent_Down);
		break;
	}
}

//=============================================================================
// Determines what step to make
//
function PerformDanceMove(EMoves CorrectMove)
{
local float	DanceMoveChance;
local int		TestMove;

	DanceMoveChance = FRand();
	if (DanceMoveChance <= DancerSkillLevel)
		ExecuteBeat (CorrectMove,True);
	else
		if (FRand() > DancerPanicLevel)
		{
			do
			{
				TestMove = Rand(DanceLength);
			}
			until ((MovesDB[TestMove] != NoMove) && (MovesDB[TestMove] != CorrectMove))
			ExecuteBeat (MovesDB[TestMove],False);
		}
	else 
	{
		return;
	}
}

//=============================================================================
// When dispatcher is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('Dispatch');
}

//=============================================================================
// Dispatch events.
//
state Dispatch
{

Begin:

	GlobalTrigger (IntroStartEvent);

	// Intro section, prior to dance moves being triggered
	for( i=0; i<(IntroLength-8); i++ )
	{
		// Downbeat
		GlobalTrigger (IntroDBEvent);
		WaitHalfBeat();

		// Upbeat
		GlobalTrigger (IntroUBEvent);
		WaitHalfBeat();
	}

	for( i=0; i<8; i++ )
	{
		// Downbeat
		if (i==4)
			GlobalTrigger (IntroGetSetEvent);
		GlobalTrigger (IntroDBEvent);
		WaitHalfBeat();

		// Upbeat
		GlobalTrigger (IntroUBEvent);
		WaitHalfBeat();
	}

	GlobalTrigger (IntroEndEvent);
	GlobalTrigger (DanceStartEvent);

	for( i=0; i<DanceLength; i++ )
	{
		// Downbeat
		GlobalTrigger (DanceDBEvent);
		if (MovesDB[i] != NoMove) PerformDanceMove (MovesDB[i]);
		WaitHalfBeat();

		// Upbeat
		GlobalTrigger (DanceUBEvent);
		if (MovesUB[i] != NoMove) PerformDanceMove (MovesUB[i]);
		WaitHalfBeat();
	}

	GlobalTrigger (DancerFinalScore);
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
	GotoState( '' );
}

defaultproperties
{
}