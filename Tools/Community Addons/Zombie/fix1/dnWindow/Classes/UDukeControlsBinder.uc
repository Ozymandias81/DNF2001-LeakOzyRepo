class UDukeControlsBinder extends UWindowScrollingDialogClient;

function Created() 
{
	ClientClass = class'UDukeControlsBinderSC';
	FixedAreaClass = None;

	Super.Created();
}

function LoadExistingKeys()
{
	UDukeControlsBinderSC(ClientArea).LoadExistingKeys();
}

defaultproperties
{
     bNoScanLines=True
}
