class UMenuLoadGameScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuLoadGameClientWindow';
	//FixedAreaClass = class'UMenuScrollWindowOKArea';
	Super.Created();
}