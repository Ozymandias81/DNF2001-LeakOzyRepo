class SpeechBinderSC expands UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'SpeechBinderCW';

	FixedAreaClass = None;
	Super.Created();
}