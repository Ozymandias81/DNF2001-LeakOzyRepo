class UTInputOptionsCW expands UMenuInputOptionsClientWindow;

// Instant Rocket
var UWindowCheckbox	InstantRocketCheck;
var localized string InstantRocketText;
var localized string InstantRocketHelp;

// Speech Binder Button
var UWindowSmallButton SpeechBinderButton;
var localized string SpeechBinderText;
var localized string SpeechBinderHelp;

function Created()
{
	local bool bJoystick;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.Created();

	DesiredWidth = 220;
	DesiredHeight = 180;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	InstantRocketCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	InstantRocketCheck.bChecked = TournamentPlayer(GetPlayerOwner()).bInstantRocket;
	InstantRocketCheck.SetText(InstantRocketText);
	InstantRocketCheck.SetHelpText(InstantRocketHelp);
	InstantRocketCheck.SetFont(F_Normal);
	InstantRocketCheck.Align = TA_Right;

	ControlOffset += 25;
	SpeechBinderButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ControlLeft, ControlOffset, 48, 16));
	SpeechBinderButton.SetText(SpeechBinderText);
	SpeechBinderButton.SetHelpText(SpeechBinderHelp);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	InstantRocketCheck.SetSize(ControlWidth, 1);
	InstantRocketCheck.WinLeft = ControlRight;

	SpeechBinderButton.AutoWidth(C);
	SpeechBinderButton.WinLeft = (WinWidth - SpeechBinderButton.WinWidth) / 2;

	Super.BeforePaint(C, X, Y);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
	{
	case DE_Change:
		switch(C)
		{
			case InstantRocketCheck:
				InstantRocketChanged();
				break;
		}
		break;
	case DE_Click:
		switch (C)
		{
			case SpeechBinderButton:
				Root.CreateWindow(class'SpeechBinderWindow', 100, 100, 100, 100);
				break;
		}
		break;
	}
}

function InstantRocketChanged()
{
	TournamentPlayer(GetPlayerOwner()).SetInstantRocket(InstantRocketCheck.bChecked);
}


defaultproperties
{
	InstantRocketText="Instant Rocket Fire"
	InstantRocketHelp="Make the Rocket Launcher fire rockets instantly, rather than charging up multiple rockets."
	SpeechBinderText="Speech Binder"
	SpeechBinderHelp="Use this special window to bind taunts and orders to keys."
}