class UDukePageWindow extends UWindowPageWindow;

var bool                bBuildDefaultButtons;   
var UWindowSmallButton  ResetButton;
var localized string    ResetText;
var UWindowSmallButton  CloseButton;
var localized string    CloseText;

function SelectedThisTab( UDukeTabControl tabSelected )
{}

function Created()
{
	Super.Created();

    if ( bBuildDefaultButtons )
    {
        // Add the close button.
	    CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 92, WinHeight - 20, 48, 16));
	    CloseButton.SetText(CloseText);

	    // Add the reset button.
	    ResetButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 144, WinHeight - 20, 48, 16));
	    ResetButton.SetText(ResetText);
    }
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
	LookAndFeel.DrawClientArea(Self, C);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if(E == DE_Click)
	{
		switch (C)
		{
			case CloseButton:
				ClosePressed();
				break;
			case ResetButton:
				ResetPressed();
				break;
		}
	}

	if(E == DE_MouseMove)
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

function ClosePressed()
{
	Close();
}

function ResetPressed()
{
}

defaultproperties
{
     bBuildDefaultButtons=True
     ResetText="Reset"
     CloseText="Close"
}
