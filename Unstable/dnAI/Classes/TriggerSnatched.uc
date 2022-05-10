class TriggerSnatched extends Trigger;

var actor TouchActor;
var() bool bHeadTrackInstigator;

function Touch( actor Other )
{
	local HumanNPC Victim;

	if( Other.IsA( 'PlayerPawn' ) )
	{
		foreach allactors( class'HumanNPC', Victim, Event )
		{
			if( bHeadTrackInstigator )
			{
				Victim.EnableHeadTracking( true );
				Victim.HeadTrackingActor = Other;
			}
			Victim.bVisiblySnatched = true;
			Victim.GotoState( 'SnatchedEffects' );
		}
		TouchActor = Other;
		Disable( 'Touch' );
	}
}

function UnTouch( actor Other )
{
	if( Other == TouchActor )
		Enable( 'Touch' );
}

DefaultProperties
{
     bHeadTrackInstigator=true
}
