class UMenuOptionsWindow extends UMenuFramedWindow;

function Created() 
{
	bStatusBar = False;
	bSizable = True;

	Super.Created();

	MinWinWidth = 200;
	MinWinHeight = 100;

	SetSizePos();
}

function SetSizePos()
{
	local float W, H;

	GetDesiredDimensions(W, H);

	if(Root.WinHeight < 400)
		SetSize(290, Min(Root.WinHeight - 32, H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)));
	else
		SetSize(290, Min(Root.WinHeight - 50, H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)));

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function Resized()
{
	if(WinWidth != 290)
		WinWidth = 290;

	Super.Resized();
}

defaultproperties
{
	WindowTitle="Preferences"
	ClientClass=class'UMenuOptionsClientWindow'
}