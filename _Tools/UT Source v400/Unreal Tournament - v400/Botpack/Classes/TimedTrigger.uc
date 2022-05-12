//=============================================================================
// TimedTrigger: causes an event after X seconds.
//=============================================================================
class TimedTrigger extends Trigger;

var() float DelaySeconds;
var() bool bRepeating;

function PostBeginPlay()
{
	if ( !Level.Game.IsA('DeathMatchPlus') || !DeathMatchPlus(Level.Game).bRequireReady )
		SetTimer(DelaySeconds, bRepeating);
	Super.PostBeginPlay();
}

function Timer()
{
	local Actor A;

	if ( event != '' )
		ForEach AllActors(class'Actor', A, Event )
			A.Trigger(self, None);

	if ( !bRepeating )
		Destroy();
}

defaultproperties
{
	bCollideActors=false
	DelaySeconds=1.0
}