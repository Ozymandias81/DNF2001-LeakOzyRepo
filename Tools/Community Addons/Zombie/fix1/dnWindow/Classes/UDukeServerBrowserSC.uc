class UDukeServerBrowserSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UDukeServerBrowserCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
