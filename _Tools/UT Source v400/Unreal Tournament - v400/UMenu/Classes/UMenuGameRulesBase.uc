class UMenuGameRulesBase extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;

// Frag Limit
var UWindowEditControl FragEdit;
var localized string FragText;
var localized string FragHelp;

// Time Limit
var UWindowEditControl TimeEdit;
var localized string TimeText;
var localized string TimeHelp;

// Max Players
var UWindowEditControl MaxPlayersEdit;
var localized string MaxPlayersText;
var localized string MaxPlayersHelp;

var UWindowEditControl MaxSpectatorsEdit;
var localized string MaxSpectatorsText;
var localized string MaxSpectatorsHelp;

// Weapons Stay
var UWindowCheckbox WeaponsCheck;
var localized string WeaponsText;
var localized string WeaponsHelp;

var float ControlOffset;
var bool bControlRight;

function Created()
{
	local int S;
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
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");

	// Frag Limit
	FragEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	FragEdit.SetText(FragText);
	FragEdit.SetHelpText(FragHelp);
	FragEdit.SetFont(F_Normal);
	FragEdit.SetNumericOnly(True);
	FragEdit.SetMaxLength(3);
	FragEdit.Align = TA_Right;

	// Time Limit
	TimeEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	TimeEdit.SetText(TimeText);
	TimeEdit.SetHelpText(TimeHelp);
	TimeEdit.SetFont(F_Normal);
	TimeEdit.SetNumericOnly(True);
	TimeEdit.SetMaxLength(3);
	TimeEdit.Align = TA_Right;
	ControlOffset += 25;

	// WeaponsStay
	WeaponsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	WeaponsCheck.SetText(WeaponsText);
	WeaponsCheck.SetHelpText(WeaponsHelp);
	WeaponsCheck.SetFont(F_Normal);
	WeaponsCheck.bChecked = BotmatchParent.GameClass.Default.bCoopWeaponMode;
	WeaponsCheck.Align = TA_Right;
	ControlOffset += 25;

	SetupNetworkOptions();
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 270;
	DesiredHeight = ControlOffset;

	LoadCurrentValues();
	Initialized = True;
}

function SetupNetworkOptions()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	if(BotmatchParent.bNetworkGame)
	{
		// Max Players
		MaxPlayersEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
		MaxPlayersEdit.SetText(MaxPlayersText);
		MaxPlayersEdit.SetHelpText(MaxPlayersHelp);
		MaxPlayersEdit.SetFont(F_Normal);
		MaxPlayersEdit.SetNumericOnly(True);
		MaxPlayersEdit.SetMaxLength(2);
		MaxPlayersEdit.Align = TA_Right;
		MaxPlayersEdit.SetDelayedNotify(True);

		// Max Spectators
		MaxSpectatorsEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
		MaxSpectatorsEdit.SetText(MaxSpectatorsText);
		MaxSpectatorsEdit.SetHelpText(MaxSpectatorsHelp);
		MaxSpectatorsEdit.SetFont(F_Normal);
		MaxSpectatorsEdit.SetNumericOnly(True);
		MaxSpectatorsEdit.SetMaxLength(2);
		MaxSpectatorsEdit.Align = TA_Right;
		MaxSpectatorsEdit.SetDelayedNotify(True);
		ControlOffset += 25;
	}
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

	FragEdit.SetSize(ControlWidth, 1);
	FragEdit.WinLeft = ControlLeft;
	FragEdit.EditBoxWidth = 25;

	TimeEdit.SetSize(ControlWidth, 1);
	TimeEdit.WinLeft = ControlRight;
	TimeEdit.EditBoxWidth = 25;

	if(MaxPlayersEdit != None)
	{
		MaxPlayersEdit.SetSize(ControlWidth, 1);
		MaxPlayersEdit.WinLeft = ControlLeft;
		MaxPlayersEdit.EditBoxWidth = 25;
	}

	if(MaxSpectatorsEdit != None)
	{
		MaxSpectatorsEdit.SetSize(ControlWidth, 1);
		MaxSpectatorsEdit.WinLeft = ControlRight;
		MaxSpectatorsEdit.EditBoxWidth = 25;
	}

	WeaponsCheck.SetSize(ControlWidth, 1);
	WeaponsCheck.WinLeft = ControlLeft;
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
			case FragEdit:
				FragChanged();
				break;
			case TimeEdit:
				TimeChanged();
				break;
			case MaxPlayersEdit:
				MaxPlayersChanged();
				break;
			case MaxSpectatorsEdit:
				MaxSpectatorsChanged();
				break;
			case WeaponsCheck:
				WeaponsChecked();
				break;
		}
	}
}

function FragChanged()
{
}

function TimeChanged()
{
}

function MaxPlayersChanged()
{
}

function MaxSpectatorsChanged()
{
}

function WeaponsChecked()
{
}

defaultproperties
{
	ControlOffset=20
	FragText="Frag Limit"
	FragHelp="The game will end if a player achieves this many frags. A value of 0 sets no frag limit."
	TimeText="Time Limit"
	TimeHelp="The game will end if after this many minutes. A value of 0 sets no time limit."
	MaxPlayersText="Max Connections"
	MaxPlayersHelp="Maximum number of human players allowed to connect to the game."
	MaxSpectatorsText="Max Spectators"
	MaxSpectatorsHelp="Maximum number of spectators allowed to connect to the game."
	WeaponsText="Weapons Stay"
	WeaponsHelp="If checked, weapons will stay at their pickup location after being picked up, instead of respawning."
}