/*-----------------------------------------------------------------------------
	DOTTrigger
	Author: Brandon Reinhart

	Attaches a damage over time to the player when triggered.
	If untriggered, it will first try to attach any zone DOT of the same type,
	then it will try to attach an exit DOT.
-----------------------------------------------------------------------------*/
class DOTTrigger extends Trigger;

var() EDamageOverTime DOT_Type;
var() float DOT_Duration;				// Total duration of DOT. (-1 for infinity)
var() float DOT_ExitDuration;			// Total duration of DOT when the player leaves the zone.
var() float DOT_Time;					// Frequency of a DOT ping.
var() float DOT_Damage;					// Damage to inflict on a DOT ping.
var() bool bNoExitDOT;

function TriggerTarget( actor Other )
{
	if ( Pawn(Other) != None )
	{
		if ( DOT_Type != DOT_None )
			Pawn(Other).AddDOT( DOT_Type, DOT_Duration, DOT_Time, DOT_Damage, None, Self );
	}
}

defaultproperties
{
	TriggerType=TT_PlayerProximity
	DOT_Type=DOT_None
	DOT_Duration=-100
	DOT_ExitDuration=0
	DOT_Damage=1
}