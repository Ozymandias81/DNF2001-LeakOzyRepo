class UDukeDialogClientWindow extends UWindowDialogClientWindow;

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if(E == DE_MouseMove)
	{
		if(UDukeRootWindow(Root) != None)
			if(UDukeRootWindow(Root).StatusBar != None)
				UDukeRootWindow(Root).StatusBar.SetHelp(C.HelpText);		
	}

	if(E == DE_HelpChanged && C.MouseIsOver())
	{
		if(UDukeRootWindow(Root) != None)
			if(UDukeRootWindow(Root).StatusBar != None)
				UDukeRootWindow(Root).StatusBar.SetHelp(C.HelpText);		
	}

	if(E == DE_MouseLeave)
	{
		if(UDukeRootWindow(Root) != None)
			if(UDukeRootWindow(Root).StatusBar != None)
				UDukeRootWindow(Root).StatusBar.SetHelp("");		
	}
}

defaultproperties
{
}
