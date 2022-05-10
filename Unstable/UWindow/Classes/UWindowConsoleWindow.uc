class UWindowConsoleWindow extends UWindowFramedWindow;

var float OldParentWidth, OldParentHeight;

function Created() 
{
	Super.Created();
	bSizable = False;
	bStatusBar = False;
	bLeaveOnScreen = True;

	OldParentWidth = ParentWindow.WinWidth;
	OldParentHeight = ParentWindow.WinHeight;

	SetDimensions();

	SetAcceptsFocus();
}

function ShowWindow()
{
	Super.ShowWindow();

	if(ParentWindow.WinWidth != OldParentWidth || ParentWindow.WinHeight != OldParentHeight)
	{
		SetDimensions();
		OldParentWidth = ParentWindow.WinWidth;
		OldParentHeight = ParentWindow.WinHeight;
	}
}

function ResolutionChanged(float W, float H)
{
	SetDimensions();
}

function SetDimensions()
{
	if (ParentWindow.WinWidth < 1024)
	{
		SetSize(410, 310);
	} else {
		SetSize(510, 410);
	}
	WinLeft = ParentWindow.WinWidth/2 - WinWidth/2;
	WinTop = ParentWindow.WinHeight/2 - WinHeight/2;
}

function Close(optional bool bByParent)
{
	ClientArea.Close(True);
	Root.Console.HideConsole();
}

defaultproperties
{
	WindowTitle="Shades OS Console ";
	ClientClass=class'UWindowConsoleClientWindow'
}