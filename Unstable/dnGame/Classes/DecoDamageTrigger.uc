/*-----------------------------------------------------------------------------
	DecoDamageTrigger
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DecoDamageTrigger expands Trigger;

var() bool bToggleDamageOnTrigger;
var() bool bToggleDamageOnUntrigger;

function TriggerTarget( actor Other )
{
	local dnDecoration D;
	local int counter;
	
	if ( ReTriggerDelay > 0 )
	{
		if ((Level.TimeSeconds > ReTriggerDelay) && (Level.TimeSeconds - TriggerTime < ReTriggerDelay))
			return;
		TriggerTime = Level.TimeSeconds;
	}
		
	// Broadcast the Trigger message to all matching actors.
	if( (Event != '') && bToggleDamageOnTrigger )
		foreach AllActors( class 'dnDecoration', D, Event )
			D.bNoDamage = !D.bNoDamage;

	if ( Other.bIsPawn && (Pawn(Other).SpecialGoal == self) )
		Pawn(Other).SpecialGoal = None;
			
	if( Message != "" )
		// Send a string message to the toucher.
		Other.Instigator.ClientMessage( Message );

	if( bTriggerOnceOnly )
		// Ignore future touches.
		SetCollision(False);
	else if ( RepeatTriggerTime > 0 )
		SetTimer(RepeatTriggerTime, false);
}

function UntriggerTarget( actor Other )
{
	local dnDecoration D;
	local int i;
	
	// Untrigger all matching actors.
	if( (Event != '') && bToggleDamageOnUntrigger )
		foreach AllActors( class 'dnDecoration', D, Event )
			D.bNoDamage = !D.bNoDamage;

	// Fire the untrigger event:
	GlobalTrigger(UntriggerEvent,Other.Instigator);
}
