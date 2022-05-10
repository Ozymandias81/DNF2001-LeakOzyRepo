/*-----------------------------------------------------------------------------
	AICoverController
	Author: Jess Crable

	Automatically spawned actor that determines when a camping Grunt should
	leave and hunt victim. Associated with the "MaxCoverDuration" property in
	CoverSpots.
-----------------------------------------------------------------------------*/
class AICoverController extends AIController;

var float MaxCampTime;

function PostBeginPlay()
{
	log( self$" Spawned.." );
	Super.PostBeginPlay();
}

auto state Startup
{
	function BeginState()
	{
		SetTimer( 0.1, true );
	}

	function Timer( optional int TimerNum )
	{
		if( Target != None )
		{
			GotoState( 'CountDown' );
			return;
		}
		else
			Attempt++;
	
		if( Attempt > 10 )
			Destroy();
	}
}

state CountDown
{
	function BeginState()
	{
		log( "Countdown state for "$self );
		log( "MaxCampTime is "$MaxCampTime );

		SetTimer( MaxCampTime, false );
	}

	function Timer( optional int TimerNum )
	{
		if( Grunt( Target ) != None )
		{
			log( "** TIME IS UP!" );
			Grunt( Target ).bCamping = false;
			Grunt( Target ).CurrentCoverSpot = None;
			Grunt( Target ).GotoState( 'Hunting' );
			Destroy();
		}
		else
			Destroy();
	}
}

DefaultProperties
{
     bIgnoreBList=false
     bHidden=true
}
    
