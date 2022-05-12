class KillGameQueryWindow extends UMenuFramedWindow;

function BeginPlay() 
{
	Super.BeginPlay();

        ClientClass = class'KillGameQueryClient';
}

function Created() 
{
	bStatusBar = False;
	bSizable = False;
	bAlwaysOnTop = True;

	Super.Created();

	if (Root.WinWidth < 640)
	{
		SetSize(310, 70);
	} else {
		SetSize(310, 70);
	}
	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
        WindowTitle="Verify Delete Game";
}
