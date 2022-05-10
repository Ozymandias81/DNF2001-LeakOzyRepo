/*-----------------------------------------------------------------------------
	RainPuddleTrigger
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class RainPuddleTrigger extends Triggers;

function Touch( actor Other )
{
	if ( Other.bIsPawn )
		Pawn(Other).bPuddleArea = true;
}

function UnTouch( actor Other )
{
	if ( Other.bIsPawn )
		Pawn(Other).bPuddleArea = false;
}

defaultproperties
{
}