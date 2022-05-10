class FocalPoint extends InfoActor
	native;

var() float NotifyFrequency			?( "How often this focal point checks for pawns that can see it." );
var() float PeripheryMod			?( "Temporarily modifies looking Pawn's peripheral vision." );
var() bool	bSleepUntilTriggered	?( "Defaults to on. It is best to let these sleep until you trigger them on." );
var	  bool	bOn;

native(499) final function NotifyObservers();

function Trigger( actor Other, pawn EventInstigator )
{
	if( bSleepUntilTriggered && !bOn )
	{
		bOn = true;
		Enable( 'Timer' );
		SetTimer( NotifyFrequency, true );
		bSleepUntilTriggered = false;
	}
	else if( !bSleepUntilTriggered && bOn )
	{
		bOn = false;
		Disable( 'Timer' );
		bSleepUntilTriggered = true;
	}
}

function PostBeginPlay()
{
	if( !bSleepUntilTriggered )
		SetTimer( NotifyFrequency, true );
}

function Timer( optional int TimerNum )
{
	NotifyObservers();
}


DefaultProperties
{
     NotifyFrequency=0.500000
     PeripheryMod=1.700000
     bSleepUntilTriggered=true
}