class UDukeControlsCW extends UDukePageWindow;

// Header
var localized string ActionText;
var localized string AssignedText;

var bool bLoadedExisting;
var localized string CustomizeHelp;

// Joystick heading.
var UDukeLabelControl JoystickHeading;
var localized string JoystickText;

// JoyX
var UWindowComboControl JoyXCombo;
var localized string JoyXText;
var localized string JoyXHelp;
var localized string JoyXOptions[2];
var string JoyXBinding[2];

// JoyY
var UWindowComboControl JoyYCombo;
var localized string JoyYText;
var localized string JoyYHelp;
var localized string JoyYOptions[2];
var string JoyYBinding[2];

var int AliasCount, SpaceFiller;

// Mouse heading.
var UDukeLabelControl MouseHeading;
var localized string MouseText;

// Mouse Sensitivity
var UWindowHSliderControl SensitivitySlider;
var localized string SensitivityText;
var localized string SensitivityHelp;

// Invert Mouse
var UWindowCheckbox InvertMouseCheck;
var localized string InvertMouseText;
var localized string InvertMouseHelp;

// Controls Binder
var UDukeControlsBinder ControlBinder;
var float ControlBinderHeight;

var float ControlOffset;

function Created()
{
	local int ButtonWidth, ButtonLeft, i, j, pos;
	local int LabelWidth, LabelLeft;
	local UDukeLabelControl Heading;
	local bool bTop;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/3;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;
	CenterWidth = (WinWidth/5)*3;
	CenterPos = (WinWidth - CenterWidth)/2;
	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;
	LabelWidth = WinWidth - 100;
	LabelLeft = 20;
	ControlBinderHeight = 150;

	bIgnoreLDoubleClick = true;
	bIgnoreMDoubleClick = true;
	bIgnoreRDoubleClick = true;

	SetAcceptsFocus();

	Super.Created();

	// Controls binder.
	ControlOffset += 20;
	ControlBinder = UDukeControlsBinder(CreateWindow(class'UDukeControlsBinder', WinWidth+10, ControlOffset, WinWidth-20, 1));
	ControlOffset += ControlBinderHeight + 20;

	// Mouse Heading
	MouseHeading = UDukeLabelControl(CreateControl(class'UDukeLabelControl', LabelLeft-10, ControlOffset, WinWidth, 1));
	MouseHeading.SetText(MouseText);
	MouseHeading.SetFont(F_Bold);
	ControlOffset += 20;

	// Invert Mouse
	InvertMouseCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	if (GetPlayerOwner().bInvertMouse)
		InvertMouseCheck.bChecked = true;
	InvertMouseCheck.SetText(InvertMouseText);
	InvertMouseCheck.SetHelpText(InvertMouseHelp);
	InvertMouseCheck.SetFont(F_Normal);
	InvertMouseCheck.bAcceptsFocus = false;
	InvertMouseCheck.Align = TA_Left;
	ControlOffset += 20;

	// Mouse Sensitivity
	SensitivitySlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	SensitivitySlider.bNoSlidingNotify = true;
	SensitivitySlider.SetRange(1, 30, 0.5);
	SensitivitySlider.SetText(SensitivityText);
	SensitivitySlider.SetHelpText(SensitivityHelp);
	SensitivitySlider.SetFont(F_Normal);
	SensitivitySlider.SetValue(GetPlayerOwner().MouseSensitivity);
	SensitivitySlider.bAcceptsFocus = false;
	SensitivitySlider.bFloatValue = true;
	ControlOffset += 20;
	
	// Joystick
	JoystickHeading = UDukeLabelControl(CreateControl(class'UDukeLabelControl', LabelLeft-10, ControlOffset, WinWidth, 1));
	JoystickHeading.SetText(JoystickText);
	JoystickHeading.SetFont(F_Bold);
	ControlOffset += 20;

	// JoyX
	JoyXCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 20, ControlOffset, WinWidth - 40, 1));
	JoyXCombo.CancelAcceptsFocus();
	JoyXCombo.SetText(JoyXText);
	JoyXCombo.SetHelpText(JoyXHelp);
	JoyXCombo.SetFont(F_Normal);
	JoyXCombo.SetEditable(False);
	JoyXCombo.AddItem(JoyXOptions[0]);
	JoyXCombo.AddItem(JoyXOptions[1]);
	JoyXCombo.EditBoxWidth = ButtonWidth;
	ControlOffset += 20;

	// JoyY
	JoyYCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 20, ControlOffset, WinWidth - 40, 1));
	JoyYCombo.CancelAcceptsFocus();
	JoyYCombo.SetText(JoyYText);
	JoyYCombo.SetHelpText(JoyYHelp);
	JoyYCombo.SetFont(F_Normal);
	JoyYCombo.SetEditable(False);
	JoyYCombo.AddItem(JoyYOptions[0]);
	JoyYCombo.AddItem(JoyYOptions[1]);
	JoyYCombo.EditBoxWidth = ButtonWidth;

	DesiredWidth = 220;
	DesiredHeight = WinHeight;
}

function LoadExistingKeys()
{
	local string Alias;

	Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING JoyX" );
	if(Alias ~= JoyXBinding[0])
		JoyXCombo.SetSelectedIndex(0);
	if(Alias ~= JoyXBinding[1])
		JoyXCombo.SetSelectedIndex(1);

	Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING JoyY" );
	if(Alias ~= JoyYBinding[0])
		JoyYCombo.SetSelectedIndex(0);
	if(Alias ~= JoyYBinding[1])
		JoyYCombo.SetSelectedIndex(1);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft, I;
	local int LabelWidth, LabelLeft;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/3;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/5)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	InvertMouseCheck.SetSize(ControlWidth, 1);
	InvertMouseCheck.WinLeft = 12;

	SensitivitySlider.SetSize(WinWidth - (ControlLeft*2) - 20, 1);
	SensitivitySlider.SliderWidth = 100;
	SensitivitySlider.WinLeft = 12;

	ControlBinder.SetSize(WinWidth - 20, ControlBinderHeight);
	ControlBinder.WinLeft = 10;

	ButtonWidth = WinWidth - 135;
	ButtonLeft = WinWidth - ButtonWidth - 20;

	LabelWidth = WinWidth - 100;
	LabelLeft = 20;

	JoyXCombo.SetSize(WinWidth - 40, 1);
	JoyXCombo.EditBoxWidth = ButtonWidth;

	JoyYCombo.SetSize(WinWidth - 40, 1);
	JoyYCombo.EditBoxWidth = ButtonWidth;
}

function Paint( Canvas C, float X, float Y )
{
	local float XL, YL;
	local float ActualWinWidth;
	local color OldDrawColor;
	local string FillerString;

	ActualWinWidth = ControlBinder.WinWidth - LookAndFeel.SBPosIndicator.W;

	DrawStretchedTexture( C, ControlBinder.WinLeft, ControlBinder.WinTop - 20, ActualWinWidth, 20, texture'WhiteTexture' );

	OldDrawColor = C.DrawColor;
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.Font = Root.Fonts[F_Bold];
	TextSize(C, ActionText, XL, YL);
	ClipText(C, ControlBinder.WinLeft + (ActualWinWidth/2 - XL)/2, ControlBinder.WinTop + (20-YL)/2 - 20, ActionText);
	TextSize(C, AssignedText, XL, YL);
	ClipText(C, ControlBinder.WinLeft + (ActualWinWidth/2 - XL)/2 + ActualWinWidth/2, ControlBinder.WinTop + (20-YL)/2 - 20, AssignedText);

	C.DrawColor = OldDrawColor;
	DrawUpBevel(C, ControlBinder.WinLeft, ControlBinder.WinTop - 20, ActualWinWidth/2, 20, GetLookAndFeelTexture());
	DrawUpBevel(C, ControlBinder.WinLeft + ActualWinWidth/2, ControlBinder.WinTop - 20, ActualWinWidth/2, 20, GetLookAndFeelTexture());
	DrawUpBevel(C, ControlBinder.WinLeft, ControlBinder.WinTop, ActualWinWidth/2, ControlBinder.WinHeight, GetLookAndFeelTexture());
	DrawUpBevel(C, ControlBinder.WinLeft + ActualWinWidth/2, ControlBinder.WinTop, ActualWinWidth/2, ControlBinder.WinHeight, GetLookAndFeelTexture());

	// Space filler thingy.
	FillerString = "0123456789012345678901234567890123456789BRANDONREINHARTISTHECODEMAGE012345678901234567890123456789";
	DrawUpBevel(C, ControlBinder.WinLeft + ActualWinWidth, ControlBinder.WinTop - 20, LookAndFeel.SBPosIndicator.W, 20, GetLookAndFeelTexture());
	TextSize(C, Left(Right(FillerString,SpaceFiller),1), XL, YL);
	ClipText(C, ControlBinder.WinLeft + ActualWinWidth + (LookAndFeel.SBPosIndicator.W - XL)/2, ControlBinder.WinTop + (20-YL)/2 - 20, Left(Right(FillerString,SpaceFiller),1));
	SpaceFiller++; if (SpaceFiller > Len(FillerString)) SpaceFiller = 0;

	Super.Paint(C, X, Y);
}

function Notify(UWindowDialogControl C, byte E)
{
	local int i;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case JoyXCombo:
			if(bLoadedExisting)
				GetPlayerOwner().ConsoleCommand("SET Input JoyX "$JoyXBinding[JoyXCombo.GetSelectedIndex()]);
			break;
		case JoyYCombo:
			if(bLoadedExisting)
				GetPlayerOwner().ConsoleCommand("SET Input JoyY "$JoyYBinding[JoyYCombo.GetSelectedIndex()]);
			break;
		case SensitivitySlider:
			SensitivityChanged();
			break;
		}
		break;
	case DE_Click:
		switch (C)
		{
		case InvertMouseCheck:
			InvertMouseChecked();
			break;
		}
		break;
	}
}

function ResetPressed()
{
	GetPlayerOwner().ResetKeyboard();
	ControlBinder.LoadExistingKeys();
}

function GetDesiredDimensions(out float W, out float H)
{	
	Super.GetDesiredDimensions(W, H);
	H = 200;
}

function InvertMouseChecked()
{
	GetPlayerOwner().bInvertMouse = InvertMouseCheck.bChecked;
}

function SensitivityChanged()
{
	GetPlayerOwner().SetSensitivity(SensitivitySlider.Value);
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
     ActionText="Action"
     AssignedText="Assigned Key"
     CustomizeHelp="Click the blue rectangle and then press the key to bind to this control."
     JoystickText="Joystick"
     JoyXText="X Axis"
     JoyXHelp="Select the behavior for the left-right axis of your joystick."
     JoyXOptions(0)="Strafe Left/Right"
     JoyXOptions(1)="Turn Left/Right"
     JoyXBinding(0)="Axis aStrafe speed=2"
     JoyXBinding(1)="Axis aBaseX speed=0.7"
     JoyYText="Y Axis"
     JoyYHelp="Select the behavior for the up-down axis of your joystick."
     JoyYOptions(0)="Move Forward/Back"
     JoyYOptions(1)="Look Up/Down"
     JoyYBinding(0)="Axis aBaseY speed=2"
     JoyYBinding(1)="Axis aLookup speed=-0.4"
     MouseText="Mouse"
     SensitivityText="Mouse Sensitivity"
     SensitivityHelp="Adjust the mouse sensitivity, or how far you have to move the mouse to produce a given motion in the game."
     InvertMouseText="Invert Mouse"
     InvertMouseHelp="Invert the mouse X axis.  When true, pushing the mouse forward causes you to look down rather than up."
     ControlOffset=20.000000
}
