/*-----------------------------------------------------------------------------
	DoorMoverTrigger
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DoorMoverTrigger extends Triggers;

var() bool bRelock;

function Trigger( actor Other, pawn EventInstigator )
{
	local Actor A;
	
	foreach AllActors( class'Actor', A, Event )
	{
		if ( bRelock )
		{
			if ( A.IsA('KeyPad') )
				KeyPad(A).bLocked = true;
			if ( A.IsA('DoorMover') )
				DoorMover(A).bLocked = true;
		}
	}
}
