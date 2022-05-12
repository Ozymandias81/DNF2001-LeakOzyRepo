class UMenuSaveGameWindow extends UMenuFramedWindow;

function Created() 
{
	bStatusBar = False;
	bSizable = False;

	Super.Created();

	if (Root.WinWidth < 640)
	{
		SetSize(220, 200);
		//UMenuLoadGameClientWindow(ClientArea).SetScrollable(true);
	} else {
		SetSize(220, 340);
	}
	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
	WindowTitle="Save Game"
	ClientClass=class'UMenuSaveGameScrollClient'
}