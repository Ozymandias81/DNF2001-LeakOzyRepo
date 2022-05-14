class UDukeAudioSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeAudioCW';
		
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
