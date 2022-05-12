class UMenuPageWindow extends UWindowPageWindow;

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
	LookAndFeel.DrawClientArea(Self, C);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if(E == DE_MouseMove)
	{
		if(UMenuRootWindow(Root) != None)
			if(UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.SetHelp(C.HelpText);		
	}

	if(E == DE_MouseLeave)
	{
		if(UMenuRootWindow(Root) != None)
			if(UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.SetHelp("");		
	}
}
