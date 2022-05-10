//=============================================================================
// KillTrigger. (NJS)
//
// When triggered, KillTrigger changes the enabled state of the TriggerRelays 
// referred to by 'Event'.
// See the description of the variables under 'Public Variables' for a 
// description of each of the possible actions the KillTrigger can take when 
// triggered.
//=============================================================================
class KillTrigger expands Triggers;

#exec Texture Import File=Textures\KillTrigger.pcx Name=S_KillTrigger Mips=Off Flags=2

var() bool PrintDebug;

// Public Variables:
var() enum EKillTriggerType
{
	KT_Enable,	// Enable the target relay.
	KT_Disable,	// Disable the target relay.
	KT_Toggle,	// Toggle the target relay between enabled/disabled.
	KT_Random,	// Randomly enable or disable the trigger relay.
	KT_Reset	// Reset the OneShot setting on the trigger
} KillTriggerType;

// Toggle any trigger relays:
function Trigger( actor Other, pawn EventInstigator )
{
	local TriggerRelay A; 
	
	/* Make sure event is valid */
	if( Event != '' )
		/* Trigger all actors with matching triggers */
		foreach AllActors( class 'TriggerRelay', A, Event )		
		{
				switch(KillTriggerType)
				{
					case KT_Enable:  if(PrintDebug) BroadcastMessage("KillTrigger:"$Tag$" Enable:"$Event);
									 A.RelaySetState(true);  		
									 break;

					case KT_Disable: if(PrintDebug) BroadcastMessage("KillTrigger:"$Tag$" Disable:"$Event);
									 A.RelaySetState(false); 		
									 break;

					case KT_Toggle:  if(PrintDebug) BroadcastMessage("KillTrigger:"$Tag$" Toggle:"$Event);
									 A.RelayToggleState();   		
									 break;

					case KT_Random:  if(PrintDebug) BroadcastMessage("KillTrigger:"$Tag$" Random:"$Event);
									 A.RelaySetState(bool(Rand(2))); 
									 break;

					case KT_Reset:	 if(PrintDebug) BroadcastMessage("KillTrigger:"$Tag$" Reset:"$Event);
									 A.RelayReset();				
									 break;
					default: 
						if(PrintDebug) BroadcastMessage("KillTrigger:"$Tag$" Invalid trigger type");
						Log("Invalid trigger type.");   	 	
						break;
				}			
		}
}

defaultproperties
{
     KillTriggerType=KT_Toggle
     Texture=Texture'Engine.S_KillTrigger'
}
