//=============================================================================
// RoundRobin: Each time it's triggered, it advances through a list of
// outgoing events.
//=============================================================================
class RoundRobin extends Triggers;

var() name OutEvents[16]; // Events to generate.
var() name ResetTag;	  // If non none, then triggering this tag will reset this round robin
var() bool bLoop;         // Whether to loop when get to end.
var int i;                // Internal counter.
var TriggerSelfForward ResetTrigger;

function PostBeginPlay()
{
	
	super.PostBeginPlay();

	if(ResetTag!='')
	{
		ResetTrigger=Spawn(class'Engine.TriggerSelfForward',self);
		ResetTrigger.tag=ResetTag;
		ResetTrigger.event=Tag;
	}
}

//
// When RoundRobin is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	local actor A;

	if((ResetTrigger!=none)&&(Other==ResetTrigger))
	{
		i=0;
		return;
	}

	if( OutEvents[i] != '' )
	{
		foreach AllActors( class 'Actor', A, OutEvents[i] )		
		{
			A.Trigger( Self, EventInstigator );
		}
		if( ++i>=ArrayCount(OutEvents) || OutEvents[i]=='' )
		{
			if( bLoop ) i=0;
			else
				SetCollision(false,false,false);
		}
	}
}

defaultproperties
{
}
