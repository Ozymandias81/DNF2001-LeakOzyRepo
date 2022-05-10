//=============================================================================
// dnDecorationTrigger.
//=============================================================================
class dnDecorationTrigger expands Triggers;

struct PendingSequence
{
	var () name	PlaySequence;	// A pending sequence to be played once the current sequence completes.
	var () bool Loop;			// Whether to loop the pending sequence until further notice
	var () name Event;			// Event that's triggered when the pending sequence is triggered
	var () sound Noise;			// Sound to play when this pending sequence is triggered.
	var () bool NoiseIsAmbient; // Whether or not to play the noise as an ambient sound.
	var () float Radius;		// Radius of the sound to play.
};

var (PendingSequences) PendingSequence addPendingSequences[4];
var (PendingSequences) int numberPendingSequences;
var (PendingSequences) bool clearPendingSequences;
var (PendingSequences) bool snapFromCurrentSequence;
var () sound NewAmbientSound;
var () bool  SetAmbientSound;

function Trigger( actor Other, pawn EventInstigator )
{
	local dnDecoration A;
	local int i;
	local bool first;

	// Make sure event is valid 
	if( Event != '' )
		// Trigger all actors with matching triggers 
		foreach AllActors( class 'dnDecoration', A, Event )		
		{
			if(SetAmbientSound) A.ambientSound=newAmbientSound;
			if(clearPendingSequences) A.ClearPendingSequences();

			if(A.currentPendingSequence+numberPendingSequences>=ArrayCount(A.pendingSequences))
				continue;

			if(A.currentPendingSequence<0) first=true;
			else first=false;

			for(i=numberPendingSequences-1;i>=0;i--)
			{
				if((i==0)&&(first))
					A.pushPendingSequenceByComponent(addPendingSequences[i].PlaySequence,addPendingSequences[i].Loop,
						addPendingSequences[i].Event,addPendingSequences[i].Noise,addPendingSequences[i].NoiseIsAmbient,
						addPendingSequences[i].Radius,snapFromCurrentSequence);
				else
					A.pushPendingSequenceByComponent(addPendingSequences[i].PlaySequence,addPendingSequences[i].Loop,
						addPendingSequences[i].Event,addPendingSequences[i].Noise,addPendingSequences[i].NoiseIsAmbient,
						addPendingSequences[i].Radius,false);
			}
		}

}

defaultproperties
{
	snapFromCurrentSequence=True
}
