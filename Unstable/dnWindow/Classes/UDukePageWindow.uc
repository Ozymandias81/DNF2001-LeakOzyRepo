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

	/* 
    if ( bBuildDefaultButtons )
    {
        // Add the close button.
	    CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 92, WinHeight - 20, 48, 16));
	    CloseButton.SetText(CloseText);

	    // Add the reset button.
	    ResetButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 144, WinHeight - 20, 48, 16));
	    ResetButton.SetText(ResetText);
    }
	*/
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
	LookAndFeel.DrawClientArea(Self, C);
}

function Notify(UWindowDialogControl C, byte E)
{
	local UWindowFramedWindow FramedParent;

	Super.Notify( C, E );

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

	if ( ParentWindow != None )
	{
		FramedParent = UWindowFramedWindow(ParentWindow);
		if ( (FramedParent == None) && (ParentWindow.ParentWindow != None) )
			FramedParent = UWindowFramedWindow(ParentWindow.ParentWindow);
	}

	if ( FramedParent == None )
		return;

	if ( E == DE_MouseMove )
		FramedParent.StatusBarText = C.HelpText;

	if ( E == DE_HelpChanged && C.MouseIsOver() )
		FramedParent.StatusBarText = C.HelpText;

	if ( E == DE_MouseLeave )
		FramedParent.StatusBarText = "";
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
	ResetText="Reset"
	CloseText="Close"
    bBuildDefaultButtons=true
}