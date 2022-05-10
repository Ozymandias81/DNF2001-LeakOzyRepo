//=============================================================================
// PeriodicTrigger. (NJS)
//
// When enabled, periodically pulses the 'Event' trigger.
//=============================================================================
class PeriodicTrigger expands Triggers;

var () float Interval;	// Interval (in seconds) at which this trigger will fire
var () bool  Enabled;	// Initial state of the trigger.
var () bool  TriggerImmediately; // Trigger immediately, then on the periodic rate

function SetPeriodicState()
{
	if(!Enabled) // Disable the trigger:
	{
		SetTimer(0,false);
		Disable('Timer');
	}
	else		// Enable the trigger
	{
		Enable('Timer');
		SetTimer(Interval,true);
	}
}

function PostBeginPlay()
{
	SetPeriodicState();	// Possibly start ticking.
}

// Trigger toggles the state of PeriodicTrigger.
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator=EventInstigator;
	
	if(Enabled) Enabled=false;
	else Enabled=true;
	
	SetPeriodicState();

    if ( TriggerImmediately )
        GlobalTrigger(Event,Instigator);
}

// Timer has expired, perform the trigger:
function Timer(optional int TimerNum)
{
	GlobalTrigger(Event,Instigator);
}

defaultproperties
{
}
