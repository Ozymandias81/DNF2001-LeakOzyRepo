class UMenuNewGameWindow extends UMenuFramedWindow;

function Created() 
{
	bStatusBar = False;
	bSizable = False;

	Super.Created();

	if (Root.WinWidth < 640)
	{
		SetSize(260, 140);
	} else {
		SetSize(260, 140);
	}
	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
	WindowTitle="New Game"
	ClientClass=class'UMenuNewGameClientWindow'
}