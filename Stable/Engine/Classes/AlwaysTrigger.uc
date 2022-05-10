//=============================================================================
// AlwaysTrigger. (NJS)
//
// Automatically triggers it's 'Event' immedietely after creation.
//=============================================================================
class AlwaysTrigger expands Triggers;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Enable( 'Tick' );
}

function Tick( float DeltaSeconds )
{
	Super.Tick( DeltaSeconds );
	
	// Broadcast the Trigger message to all matching actors.
	GlobalTrigger( Event,Instigator );
			
	Disable( 'Tick' ); // Don't call again
	Destroy();
}

defaultproperties
{
}
