//=============================================================================
// TriggerCamp.uc
//=============================================================================
class TriggerCamp extends Triggers;

var() float CampingTime ?("Time before trigger occurs. If player leaves the radius, the\n timer is reset.");			// Time before trigger occurs. If Player leaves radius timer is reset.
var() bool bOnceOnly ?("Destroy myself after one occurance (trigger)");				// Destroy self after one occurance.
var() bool bForceRetouch ?("Always recur- even if the player doesn't untouch and retouch.");	// Always recur- even if the player doesn't untouch and retouch.

var float CampTimer;
var bool bActive;

function PostBeginPlay()
{
	Disable( 'Tick' );

	Super.PostBeginPlay();
}

function Touch( actor Other )
{
	if( Other.IsA( 'PlayerPawn' ) )
	{
		//log( "* "$self$" touched "$Other );
		bActive = true;
		Instigator = Pawn( Other );
		Enable( 'Tick' );
	}
}

function UnTouch( actor Other )
{
	if( Other.IsA( 'PlayerPawn' ) && bActive )
	{
		//log( "* "$self$" untouched "$Other );
		bActive = false;
		CampTimer = 0;
		Disable( 'Tick' );
	}
}

function Tick( float DeltaSeconds )
{
	if( bActive )
	{
		CampTimer += DeltaSeconds;

		if( CampTimer >= CampingTime )
		{
			bActive = false;
			UnTouch( Instigator );
			CampTimer = 0;
			Disable( 'Tick' );
			TriggerTarget();
		}
	}
}

function TriggerTarget()
{
	local actor A;

	//log( "* "$self$" TriggerTarget : "$Tag );

	if( Event != '' )
	{
		foreach allactors( class'Actor', A, Event )
		{
			//log( "* "$self$" found and triggering actor "$A );
			A.Trigger( self, Instigator );
		}
	}
	if( bForceRetouch && StillTouching() )
	{
		//log( "* StillTouching returned true." );
		Touch( Instigator );
	}
	if( bOnceOnly )
		Destroy();
}

function bool StillTouching()
{
	local PlayerPawn P;

	foreach TouchingActors( class'PlayerPawn', P )
	{
		if( P != None )
			return true;
	}

	return false;
}

		
defaultproperties
{ 
     CollisionRadius=10.000000
     CollisionHeight=10.000000
	 CampingTime=10.000000
}