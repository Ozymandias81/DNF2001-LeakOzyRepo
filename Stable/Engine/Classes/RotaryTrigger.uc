//=============================================================================
// RotaryTrigger. (NJS) Charlie Wiederhold - August 2nd, 2001
//
// When triggered, rotary trigger will trigger the OutEvent indexed by 
// CurrentEventIndex, and then move CurrentEventIndex to the next valid 
// (nonempty) event. 
// 
// Note: After I had written this, I realized that it pretty much did the same 
// thing as RoundRobin (doh). You should use RoundRobin instead of this trigger 
// wherever appropriate.
// 
// Note: This has been changed to be different from RoundRobin. Now you have a
// reverse event which, when called will step backwards through the event list
// instead of forwards like the normal trigger event. Rotary makes sense now.
//
// This is yet again another comment that has absolutely nothing to do with
// McKenna... McKenna... well, ok maybe a little bit to do with McKenna. Gonna
// find this one too Scott? :P
//=============================================================================
class RotaryTrigger expands Triggers;

var()	name	OutEvents[8];
var()	name	AltEvents[8];					// Events that get called when AltEvent happens
var()	int		CurrentEventIndex;
var()	name	ReverseEvent;
var()	name	AltEvent;						// Makes the trigger call Index AltEvent (doesn't advance count)
var()	name 	ResetEvent;					// Resets the trigger back to the initial EventIndex

var		int		OriginalEventIndex;
var		TriggerSelfForward ReverseTrigger;
var		TriggerSelfForward AltTrigger;
var		TriggerSelfForward ResetTrigger;
var		bool	TriggeredFirstEvent;

function PostBeginPlay()
{
	super.PostBeginPlay();

	OriginalEventIndex = CurrentEventIndex;

	if ( ReverseEvent!='' )
	{
		ReverseTrigger = Spawn(class'Engine.TriggerSelfForward',self);
		ReverseTrigger.tag=ReverseEvent;
		ReverseTrigger.event=Tag;
	}

	if ( AltEvent!='' )
	{
		AltTrigger = Spawn(class'Engine.TriggerSelfForward',self);
		AltTrigger.tag=AltEvent;
		AltTrigger.event=Tag;
	}

	if ( ResetEvent!='' )
	{
		ResetTrigger = Spawn(class'Engine.TriggerSelfForward',self);
		ResetTrigger.tag=ResetEvent;
		ResetTrigger.event=Tag;
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	local actor A;
	local int RunawayCounter;

	// Reset the Rotary
	if (Other==ResetTrigger)
	{
		CurrentEventIndex = OriginalEventIndex;
		TriggeredFirstEvent = False;
		return;
	}

	// Fire off the alt event
	if (Other==AltTrigger)
	{
		if (AltEvents[CurrentEventIndex]!='')
			foreach AllActors( class 'Actor', A, AltEvents[CurrentEventIndex] )		
				A.Trigger( Other, EventInstigator );
		return;
	}

	RunawayCounter=0; // Counter to detect when OutEvents is empty.
	do
	{
		// Check to make sure we aren't looping forever
		RunawayCounter++;
		if (RunawayCounter>=(ArrayCount(OutEvents) + 1))
			return;
		
		// Update the status of CurrentEventIndex
		if ((ReverseEvent!='') && (Other==ReverseTrigger))
			CurrentEventIndex--;
		else
			CurrentEventIndex++;

		// Check to see if CurrentEventIndex is in valid	range
		if (CurrentEventIndex >= ArrayCount(OutEvents))
			CurrentEventIndex = 0;
		if (CurrentEventIndex < 0)
			CurrentEventIndex = ArrayCount(OutEvents) - 1;

	} until (OutEvents[CurrentEventIndex]!='');

	// Trigger all matching events
	foreach AllActors( class 'Actor', A, OutEvents[CurrentEventIndex] )		
		A.Trigger( Other, EventInstigator );
}

defaultproperties
{
}
