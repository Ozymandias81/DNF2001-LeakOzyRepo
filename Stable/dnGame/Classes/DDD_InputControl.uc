//=============================================================================
// DDD_InputControl:
// Designed to handle the input from a player playing the DDD game
// Checks for valid moves, invalid moves, etc.
// 
// Charlie Wiederhold - August 1st, 2001
//
// Assumptions and rules for DancerControls
// - The move names will be <PlayerName>_CallMove_LeftArrow
//
//=============================================================================
class DDD_InputControl extends DDD_Controls;

//-----------------------------------------------------------------------------
// Dispatcher variables.

var(DDD_Main) name		PlayerName;			// Name of the player playing this machine
var(DDD_Main) name		UpPressedTag;			// Tag triggered when up is pressed
var(DDD_Main) name		DownPressedTag;		// Tag triggered when down is pressed
var(DDD_Main) name		LeftPressedTag;		// Tag triggered when left is pressed
var(DDD_Main) name		RightPressedTag;		// Tag triggered when right is pressed
var(DDD_Main) name		MachineRemapper;		// Name of the control remapper that is hooked into this machine

var name					PlayerFinalScore;		// Used to call the event which will update the Player's final score

var EMoves					MovesDB[256]; 		// Downbeat dance move
var EMoves					MovesUB[256]; 		// Upbeat dance move

var name					HitMoveEvent_Up;		// Event to call when an up move is hit;
var name					HitMoveEvent_Down;	// Event to call when a down move is hit;
var name					HitMoveEvent_Left;	// Event to call when a left move is hit;
var name					HitMoveEvent_Right;	// Event to call when a right move is hit;

var name					WrongMoveEvent_Up;	// Event to call when an up move is wrong;
var name					WrongMoveEvent_Down;	// Event to call when a down move is wrong;
var name					WrongMoveEvent_Left;	// Event to call when a left move is wrong;
var name					WrongMoveEvent_Right;// Event to call when a right move is wrong;

var int					IntroLength;			// Number of beats to wait before first dance move is valid (must be 8 or higher)
var int					DanceLength;			// Number of beats in the song. Does not count Intro or Outro
var float					DanceMoveDelay;		// Default time to delay between calling each event
var float					NextMoveTime;			// Real amount of time to delay before making the next move
var float					TargetTime;			// Time that the next move *should* happen

var int 					i;                	// Internal counter.
var TriggerSelfForward 	UpPressedTrigger;
var TriggerSelfForward 	DownPressedTrigger;
var TriggerSelfForward 	LeftPressedTrigger;
var TriggerSelfForward 	RightPressedTrigger;
var TriggerSelfForward 	ResetTrigger;

var name					UpPressedEvent;		// Event to call when up is pressed
var name					DownPressedEvent;		// Event to call when down is pressed
var name					LeftPressedEvent;		// Event to call when left is pressed
var name					RightPressedEvent;	// Event to call when right is pressed

var bool					UpIsValid;				// When true, up is a valid move the player can make
var bool					DownIsValid;			// When true, down is a valid move the player can make
var bool					LeftIsValid;			// When true, left is a valid move the player can make
var bool					RightIsValid;			// When true, right is a valid move the player can make

var bool					Playing;				// Determines whether a current game is playing or not

//=============================================================================
// Machine logic.

function PostBeginPlay()
{
	super.PostBeginPlay();

	PlayerFinalScore = NameForString (""$PlayerName$"_PlayerScore_ToCurrentScore");

	UpPressedEvent = NameForString (""$PlayerName$"_CallMove_UpArrow");
	DownPressedEvent = NameForString (""$PlayerName$"_CallMove_DownArrow");
	LeftPressedEvent = NameForString (""$PlayerName$"_CallMove_LeftArrow");
	RightPressedEvent = NameForString (""$PlayerName$"_CallMove_RightArrow");

	UpPressedTrigger = Spawn(class'Engine.TriggerSelfForward',self);
	UpPressedTrigger.tag=UpPressedTag;
	UpPressedTrigger.event=Tag;

	DownPressedTrigger = Spawn(class'Engine.TriggerSelfForward',self);
	DownPressedTrigger.tag=DownPressedTag;
	DownPressedTrigger.event=Tag;

	LeftPressedTrigger = Spawn(class'Engine.TriggerSelfForward',self);
	LeftPressedTrigger.tag=LeftPressedTag;
	LeftPressedTrigger.event=Tag;

	RightPressedTrigger = Spawn(class'Engine.TriggerSelfForward',self);
	RightPressedTrigger.tag=RightPressedTag;
	RightPressedTrigger.event=Tag;
}

//=============================================================================
// Assign a move to the Machine
//
function AssignMove(int MoveIndex, EMoves MoveDBType, EMoves MoveUBType)
{
	MovesDB[MoveIndex] = MoveDBType;
	MovesUB[MoveIndex] = MoveUBType;
}

//=============================================================================
// Assign dance segment lengths
//
function AssignDanceInfo(int NewIntroLength, int NewDanceLength, float NewDanceMoveDelay, float NewTargetTime, name MachineTitle)
{
	IntroLength = NewIntroLength;
	DanceLength = NewDanceLength;
	DanceMoveDelay = NewDanceMoveDelay;
	TargetTime = NewTargetTime;

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
// Pauses for a quarter of a beat
//
function WaitQuarterBeat()
{
	TargetTime += DanceMoveDelay / 4;
	NextMoveTime = TargetTime - Level.TimeSeconds;
	Sleep(NextMoveTime);
}

//=============================================================================
// Figures out which moves are valid
//
function EstablishValidMoves(EMoves MoveName)
{
	switch (MoveName)
	{
	case Up:
		UpIsValid = True;
		break;
	case Down:
		DownIsValid = True;
		break;
	case Left:
		LeftIsValid = True;
		break;
	case Right:
		RightIsValid = True;
		break;
	case LeftUp:
		LeftIsValid = True;
		UpIsValid = True;
		break;
	case LeftDown:
		LeftIsValid = True;
		DownIsValid = True;
		break;
	case LeftRight:
		LeftIsValid = True;
		RightIsValid = True;
		break;
	case RightUp:
		RightIsValid = True;
		UpIsValid = True;
		break;
	case RightDown:
		RightIsValid = True;
		DownIsValid = True;
		break;
	}
}

//=============================================================================
// Makes it so no moves are valid
//
function EmptyValidMoves()
{
	UpIsValid = False;
	DownIsValid = False;
	LeftIsValid = False;
	RightIsValid = False;
}

//=============================================================================
// When input controller is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	if ((Other != UpPressedTrigger) && (Other != DownPressedTrigger) && (Other != LeftPressedTrigger) && (Other != RightPressedTrigger))
	{	
		Instigator = EventInstigator;
		gotostate('Dispatch');
	}
}

//=============================================================================
// Dispatch events.
//
state Dispatch
{

	function Trigger( actor Other, pawn EventInstigator )
	{
		if (!Playing)
			return;

		switch (Other)
		{
		case UpPressedTrigger:
			GlobalTrigger (UpPressedEvent);
			if (UpIsValid)
			{
				GlobalTrigger (HitMoveEvent_Up);
				UpIsValid = False;
			}
			else GlobalTrigger (WrongMoveEvent_Up);
			break;
		case DownPressedTrigger:
			GlobalTrigger (DownPressedEvent);
			if (DownIsValid) 
			{
				GlobalTrigger (HitMoveEvent_Down);
				DownIsValid = False;
			}
			else GlobalTrigger (WrongMoveEvent_Down);
			break;
		case LeftPressedTrigger:
			GlobalTrigger (LeftPressedEvent);
			if (LeftIsValid)
			{
				GlobalTrigger (HitMoveEvent_Left);
				LeftIsValid = False;
			}
			else GlobalTrigger (WrongMoveEvent_Left);
			break;
		case RightPressedTrigger:
			GlobalTrigger (RightPressedEvent);
			if (RightIsValid)
			{
				GlobalTrigger (HitMoveEvent_Right);
				RightIsValid = False;
			}
			else GlobalTrigger (WrongMoveEvent_Right);
			break;
		}
	}

Begin:

	GlobalTrigger (MachineRemapper);
	// Temporary until bug fixed
	GlobalTrigger (MachineRemapper);
	EmptyValidMoves();
	
	TargetTime += DanceMoveDelay * IntroLength;
	TargetTime -= DanceMoveDelay;
	NextMoveTime = TargetTime - Level.TimeSeconds;
	Sleep(NextMoveTime);

	WaitHalfBeat();
	WaitQuarterBeat();
	Playing = True;

	// Main dance section
	for( i=0; i<DanceLength; i++ )
	{
		// Downbeat
		if (MovesDB[i] != NoMove) 
			EstablishValidMoves(MovesDB[i]);
		else EmptyValidMoves();
		WaitHalfBeat();

		// Upbeat
		if (MovesUB[i] != NoMove) 
			EstablishValidMoves(MovesUB[i]);
		else EmptyValidMoves();
		WaitHalfBeat();

	}

	WaitQuarterBeat();
	Playing = False;
	EmptyValidMoves();
	GlobalTrigger (PlayerFinalScore);
	GlobalTrigger (MachineRemapper);
	GotoState( '' );
}

defaultproperties
{
}