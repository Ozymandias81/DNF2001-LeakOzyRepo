//=============================================================================
// TriggerFOV. (NJS, screwed up by Chucko)
//
// Sets the instigator's FOV when triggered.
//=============================================================================
class TriggerFOV expands Triggers;

var () float NewFOV;	// The new FOV that will be set when this is triggered.
var () bool bForceEventFOV;

function Trigger( actor Other, pawn EventInstigator )
{
	local PlayerPawn FOVActor;

	// CTW - Used to modify the player's FOV specifically (via DukePlayer)
	if (bForceEventFOV) {
		foreach allactors(class'PlayerPawn',FOVActor) {
			if (FOVActor.Tag==Event)
				FOVActor.DesiredFOV = NewFOV;
			// log(FOVActor.Tag$" is changing FOV to "$NewFOV);
			}
		return;
	}

	if(EventInstigator==none) return;	/* Make sure I've got a valid instigator. */

	if(EventInstigator.bIsPlayer && !EventInstigator.IsA( 'HumanNPC' ) )
		PlayerPawn(EventInstigator).DesiredFOV = NewFOV;
}

defaultproperties
{
}
