//=============================================================================
// StochasticSpawner. 		    October 19th, 2001 - Charlie Wiederhold
//=============================================================================
class StochasticSpawner extends Triggers;

// Works like a Stochastic trigger, except specifically designed for being spawned
// when a light is broken and spawning the spark effects.

var()	float 			triggerProbability;	// The chance of sparks fly
var()	float 			minReCheckTime;		// Try to re-trigger the event after (min amount)
var()	float 			maxReCheckTime;		// Try to re-trigger the event after (max amount)
var()	bool			bIsActive;				// These sparks are activated/deactivated
var()	class<actor>	SpawnActor;
var		float			reTriggerTime;
var		int  			numEvents;				// The number of events available
var		actor 			triggerInstigator;	// Who enabled this actor to dispach?

function BeginPlay () 
{
	reTriggerTime = (maxReCheckTime-minReCheckTime)*FRand() + minReCheckTime;
	SetTimer(reTriggerTime, False);

}

state() TriggeredActive
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		// StochasticTrigger is active
		if ( triggerInstigator == None )
			triggerInstigator = EventInstigator;
		else
			triggerInstigator = Other;
		Instigator = EventInstigator;
		bIsActive = true;
	}

	function UnTrigger( actor Other, pawn EventInstigator )
	{
		// StochasticTrigger is inactive
		if ( triggerInstigator == None )
			triggerInstigator = EventInstigator;
		else
			triggerInstigator = Other;
		Instigator = EventInstigator;
		bIsActive = false;
	}
Begin:
	bIsActive = false; 		// initially the trigger dispacher is inactive
}

// NJS: TriggeredToggle state
state() TriggeredToggle
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		// StochasticTrigger is active
		if ( triggerInstigator == None ) triggerInstigator = EventInstigator;
		else							 triggerInstigator = Other;
		Instigator = EventInstigator;
		bIsActive = !bIsActive;
	}
}

state() AlwaysActive
{
Begin:
	bIsActive = true;
}

function Timer (optional int TimerNum) 
{
	local int 	i;
	local actor 	A;

	if (FRand() <= triggerProbability && bIsActive == true) 
	{
		// Trigger the spark system
		Spawn(SpawnActor);	// Spawn the desired object
	}

	reTriggerTime = (maxReCheckTime-minReCheckTime)*FRand() + minReCheckTime;
	SetTimer(reTriggerTime, False);
}

defaultproperties
{
     Texture=Texture'Engine.S_TrigStochastic'
     bIsActive=True
     triggerProbability=0.5
     minReCheckTime=1.0
     maxReCheckTime=2.0
     SpawnActor=class'dnParticles.dnSparkFX_BrokenLight_Flash'
}
