//=============================================================================
// SavedMove is used during network play to buffer recent client moves,
// for use when the server modifies the clients actual position, etc.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class SavedMove extends Info;

// also stores info in Acceleration attribute
var SavedMove NextMove;		// Next move in linked list.
var float TimeStamp;		// Time of this move.
var float Delta;			// Distance moved.
var bool	bRun;
var bool	bDuck;
var bool	bPressedJump;
var bool	bFire;
var bool	bAltFire;
var byte    moveButtons;

final function Clear()
{
	TimeStamp = 0;
	Delta = 0;
	Acceleration = vect(0,0,0);
	bFire = false;
	bRun = false;
	bDuck = false;
	bAltFire = false;
	bPressedJump = false;
    moveButtons = 0;
}

defaultproperties
{
     bHidden=True
}
