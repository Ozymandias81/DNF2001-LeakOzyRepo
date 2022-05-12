class FreeSlotsWindow extends UMenuFramedWindow;

function BeginPlay() 
{
	Super.BeginPlay();

        ClientClass = class'FreeSlotsClient';
}

function Created() 
{
	bStatusBar = False;
	bSizable = False;
	bLeaveOnScreen = True;

	Super.Created();

	if (Root.WinWidth < 640)
	{
		SetSize(200, 70);
	} else {
		SetSize(200, 70);
	}
	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
        WindowTitle="All Slots Full";
}
