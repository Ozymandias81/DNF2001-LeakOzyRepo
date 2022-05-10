class SpeechTrigger expands Triggers;

var() Sound SoundToPlay;
var() bool bLipSync;
var EFacialExpression FacialExpression;

function Trigger( actor Other, pawn EventInstigator )
{
	local Actor A;

	foreach allactors( class'Actor', A, Event )
	{
		
		A.PlaySound( SoundToPlay, SLOT_Talk, 200, false,,, bLipSync );
	}
}

defaultproperties
{
	bLipSync=true
}
