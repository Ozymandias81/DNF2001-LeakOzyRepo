//=============================================================================
// TriggerPinballBumper. (NJS)
// Triggers a pinball bumper, event is bumper to trigger
//=============================================================================
class TriggerPinballBumper expands Triggers;

var () enum EBumperState
{
	BS_Set,
	BS_Clear,
	BS_Toggle
} BumperState;

function Trigger( actor Other, pawn EventInstigator )
{
	local dnPinballBumper pb;
	
	foreach AllActors( class 'dnPinballBumper', pb )		
		/* Does this object's tag match */
		if(Event==pb.tag)
		{
			switch(BumperState)
			{
				case BS_Set:	pb.enabled=true;  break;
				case BS_Clear:	pb.enabled=false; break;
				case BS_Toggle: 
					if(pb.enabled) pb.enabled=false;
					else pb.enabled=true;
					break;
			}
		}

}

defaultproperties
{
}
