class ngWorldSecretWindow extends UMenuFramedWindow;

function BeginPlay() 
{
	Super.BeginPlay();

	ClientClass = class'ngWorldSecretClient';
}

function Created() 
{
	bStatusBar = False;
	bSizable = False;

	Super.Created();

	if (Root.WinWidth < 640)
	{
		SetSize(310, 120);
	} else {
		SetSize(350, 120);
	}
	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
	WindowTitle="ngWorldStats Password";
}