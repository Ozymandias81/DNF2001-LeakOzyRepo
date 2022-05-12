class UMenuGameSettingsBase extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;
var float ControlOffset;

// Game Style
var UWindowComboControl StyleCombo;
var localized string StyleText;
var localized string Styles[3];
var localized string StyleHelp;

// Game Speed
var UWindowHSliderControl SpeedSlider;
var localized string SpeedText;
var localized string SpeedHelp;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuGameSettingsCWindow without UMenuBotmatchClientWindow parent.");

	// Game Style
	StyleCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	StyleCombo.SetText(StyleText);
	StyleCombo.SetHelpText(StyleHelp);
	StyleCombo.SetFont(F_Normal);
	StyleCombo.SetEditable(False);
	StyleCombo.AddItem(Styles[0]);
	StyleCombo.AddItem(Styles[1]);
	StyleCombo.AddItem(Styles[2]);
	ControlOffset += 25;

	// Game Speed
	SpeedSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	SpeedSlider.SetRange(50, 200, 5);
	SpeedSlider.SetHelpText(SpeedHelp);
	SpeedSlider.SetFont(F_Normal);
	ControlOffset += 25;
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 270;
	DesiredHeight = ControlOffset;

	LoadCurrentValues();
	Initialized = True;
}

function LoadCurrentValues()
{
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	StyleCombo.SetSize(CenterWidth, 1);
	StyleCombo.WinLeft = CenterPos;
	StyleCombo.EditBoxWidth = 110;

	SpeedSlider.SetSize(CenterWidth, 1);
	SpeedSlider.SliderWidth = 90;
	SpeedSlider.WinLeft = CenterPos;
}

function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
			case StyleCombo:
				StyleChanged();
				break;
			case SpeedSlider:
				SpeedChanged();
				break;
		}
	}
}

function StyleChanged()
{
}

function SpeedChanged()
{
}

defaultproperties
{
	StyleText="Game Style:"
	StyleHelp="Choose your game style. Hardcore is 10% faster with a 50% damage increase. Turbo also adds ultra fast player movement."
	SpeedText="Game Speed"
	SpeedHelp="Adjust the speed of the game."
	Styles(0)="Classic"
	Styles(1)="Hardcore"
	Styles(2)="Turbo"
	ControlOffset=20
}