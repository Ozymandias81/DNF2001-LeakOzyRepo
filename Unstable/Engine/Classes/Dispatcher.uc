	//=============================================================================
// Dispatcher: receives one trigger (corresponding to its name) as input, 
// then triggers a set of specifid events with optional delays.
//=============================================================================
class Dispatcher extends Triggers;

#exec Texture Import File=Textures\Dispatch.pcx Name=S_Dispatcher Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Dispatcher variables.

var() name  OutEvents[16]; // Events to generate.
var() float OutDelays[16]; // Relative delays before generating events.
var int i;                // Internal counter.
var() name ResetTag;	  // If non none, then triggering this tag will reset this dispatcher
var TriggerSelfForward ResetTrigger;
var() bool bLoop;               // Loop the dispatcher automatically
var() bool bInterruptable;		// Dispatcher can be interrupted by retriggering
//=============================================================================
// Dispatcher logic.

function PostBeginPlay()
{
	super.PostBeginPlay();

	if ( ResetTag!='' )
	{
		ResetTrigger = Spawn(class'Engine.TriggerSelfForward',self);
		ResetTrigger.tag=ResetTag;
		ResetTrigger.event=Tag;
	}
}

//
// When dispatcher is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	if ( (Other == None) || (Other != ResetTrigger) )
	{
		Instigator = EventInstigator;
		gotostate('Dispatch');
	}
}

//
// Dispatch events.
//
state Dispatch
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( ( ResetTag!='') && (Other==ResetTrigger) )
			GotoState( '' );
		else GotoState ('Dispatch');
	}

Begin:
	if((ResetTag=='') && (!bInterruptable))
	{
		disable('Trigger');
	}
	for( i=0; i<ArrayCount(OutEvents); i++ )
	{
		if( OutEvents[i] != '' )
		{
			if(bool(OutDelays[i])) Sleep( OutDelays[i] );	// NJS: Only sleep on non-zero

			GlobalTrigger( outEvents[i], Instigator, Self );
			//foreach AllActors( class 'Actor', Target, OutEvents[i] )
			//	Target.Trigger( Self, Instigator );
		}
	}

    if (bLoop) // auto loop
    {
        GotoState( 'Dispatch' );
    }
    else
    {
    	enable('Trigger');
	    GotoState( '' );
    }
}

defaultproperties
{
     Texture=Texture'Engine.S_Dispatcher'
}
