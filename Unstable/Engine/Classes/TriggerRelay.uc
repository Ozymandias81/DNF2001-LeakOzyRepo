//=============================================================================
// TriggerRelay. (NJS)
// 	The trigger relay passes all incoming triggers directed to it's tag name 
// to it's Event, when it is enabled.  Look at the 'Public Variables' section 
// below for a description of each of the parameters.
//
// 	The TriggerRelay is often used in conjunction with a KillTrigger for 
// setting/resetting/toggling the enabled status of the trigger.  See the 
// documentation for KillTrigger for more information.
//=============================================================================
class TriggerRelay expands Triggers;

#exec Texture Import File=Textures\RelayTrigger.pcx Name=S_TriggerRelay Mips=Off Flags=2

// Public Variables:
var () bool bEnabled;	 // Whether this trigger is enabled or not.
var () bool bOneShot;	 // Whether the state can only be toggled once.

// Private Variables:
var bool bTriggeredOnce; // Set to true when the trigger has been triggered at least once.		
 
function RelayToggleState()
{
	// Invert state of trigger:
	if(bEnabled) RelaySetState(false);
	else         RelaySetState(true);
	
}

function RelaySetState(bool s)
{
	// If I'm a one shot and have already been triggered:
	if(bOneShot&&bTriggeredOnce) return; 	// I've already been triggered

	bEnabled=s;				// Set my enabled state
	bTriggeredOnce=true;	// Note that I've been triggered at least once
}

function RelayReset()
{
	bTriggeredOnce=false;
}

// Trigger passes on the event to my targets. (when enabled)
function Trigger( actor Other, pawn EventInstigator )
{
	if(bEnabled && !(bOneShot && bTriggeredOnce))
		GlobalTrigger(Event,EventInstigator,Other);
	bTriggeredOnce=True;
}

// Untrigger passes on this event to my targets. (when enabled)
function UnTrigger( actor Other, pawn EventInstigator )
{
	if(bEnabled && !(bOneShot && bTriggeredOnce)) 
		GlobalUntrigger(Event,EventInstigator);
	bTriggeredOnce=True;
}

defaultproperties
{
     bEnabled=True
     Texture=Texture'Engine.S_TriggerRelay'
}
