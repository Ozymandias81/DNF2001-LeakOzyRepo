class UMenuLoadGameClientWindow extends UMenuSlotClientWindow;

var UMenuRaisedButton RestartButton;
var localized string RestartText;
var localized string RestartHelp;

function Created()
{
	local int ButtonWidth, ButtonLeft, ButtonTop, I;

	Super.Created();

	ButtonWidth = WinWidth - 60;
	ButtonLeft = (WinWidth - ButtonWidth)/2;

	ButtonTop = 25 + 25*10;
	RestartButton = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop, ButtonWidth, 1));
	RestartButton.SetText(RestartText@GetLevel().Title);
	RestartButton.SetHelpText(RestartHelp);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft, I;

	Super.BeforePaint(C, X, Y);

	ButtonWidth = WinWidth - 60;
	ButtonLeft = (WinWidth - ButtonWidth)/2;

	RestartButton.SetSize(ButtonWidth, 1);
	RestartButton.WinLeft = ButtonLeft;
}

function Notify(UWindowDialogControl C, byte E)
{
	local int I;
	local int Selection;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		if ( C == RestartButton )
		{
			Root.GetPlayerOwner().ReStartLevel();
			Close();
			return;
		}

		if ( UMenuRaisedButton(C).Text ~= "..Empty.." )
		{
			return;
		}

		for (I=0; I<9; I++)
		{
			if (C == Slots[I])
			{
				Selection = I;
			}
		}

		if ( Left(UMenuRaisedButton(C).Text, 4) == "Net:" )
			GetLevel().ServerTravel( "?load="$Selection, false);
		else
			GetPlayerOwner().ClientTravel( "?load="$Selection, TRAVEL_Absolute, false);
		Close();
		break;
	}
}

defaultproperties
{
	RestartText="Restart"
	RestartHelp="Press to restart the current level."
}