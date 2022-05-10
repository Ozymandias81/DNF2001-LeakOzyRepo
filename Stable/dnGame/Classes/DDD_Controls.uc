//=============================================================================
// DDD_Controls:
// Root class of the DDD machine system. Just needed to setup basic things used
// in all the actors
//
// Charlie Wiederhold - August 1st, 2001
//
//=============================================================================
class DDD_Controls extends Triggers;

//-----------------------------------------------------------------------------
// Dispatcher variables.

enum EMoves
{
	NoMove,
	Up,
	Down,
	Left,
	Right,
	LeftUp,
	LeftDown,
	LeftRight,
	RightUp,
	RightDown
};

defaultproperties
{
     Texture=Texture'DukeED_Gfx.dancedanceduke'
}
