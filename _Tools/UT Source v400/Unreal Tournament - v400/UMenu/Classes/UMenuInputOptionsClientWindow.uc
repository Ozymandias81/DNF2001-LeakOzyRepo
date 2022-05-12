class UMenuInputOptionsClientWindow extends UMenuPageWindow;

// Auto Aim
var UWindowCheckbox AutoAimCheck;
var localized string AutoAimText;
var localized string AutoAimHelp;

// Joystick
var UWindowCheckbox JoystickCheck;
var localized string JoystickText;
var localized string JoystickHelp;

// DirectInput
var UWindowCheckbox DirectInputCheck;
var localized string DirectInputText;
var localized string DirectInputHelp;

// Mouse Sensitivity
var UWindowEditControl SensitivityEdit;
var localized string SensitivityText;
var localized string SensitivityHelp;

// Invert Mouse
var UWindowCheckbox InvertMouseCheck;
var localized string InvertMouseText;
var localized string InvertMouseHelp;

// Look Spring
var UWindowCheckbox LookSpringCheck;
var localized string LookSpringText;
var localized string LookSpringHelp;

// Always Mouselook
var UWindowCheckbox MouselookCheck;
var localized string MouselookText;
var localized string MouselookHelp;

var UWindowCheckbox MouseSmoothCheck;
var localized string MouseSmoothText;
var localized string MouseSmoothHelp;

// Auto Slope
var UWindowCheckbox AutoSlopeCheck;
var localized string AutoSlopeText;
var localized string AutoSlopeHelp;

var float ControlOffset;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, i;
	local string Sens;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Joystick
	JoystickCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	JoystickCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get windrv.windowsclient usejoystick"));
	JoystickCheck.SetText(JoystickText);
	JoystickCheck.SetHelpText(JoystickHelp);
	JoystickCheck.SetFont(F_Normal);
	JoystickCheck.Align = TA_Right;

	// Auto Aim
	AutoAimCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	if (GetPlayerOwner().MyAutoAim < 1.0)
		AutoAimCheck.bChecked = true;
	AutoAimCheck.SetText(AutoAimText);
	AutoAimCheck.SetHelpText(AutoAimHelp);
	AutoAimCheck.SetFont(F_Normal);
	AutoAimCheck.Align = TA_Right;
	ControlOffset += 25;

	// DirectInput
	DirectInputCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	DirectInputCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get windrv.windowsclient UseDirectInput"));
	DirectInputCheck.SetText(DirectInputText);
	DirectInputCheck.SetHelpText(DirectInputHelp);
	DirectInputCheck.SetFont(F_Normal);
	DirectInputCheck.Align = TA_Right;

	// Look Spring
	LookSpringCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	if (GetPlayerOwner().bSnapToLevel)
		LookSpringCheck.bChecked = true;
	LookSpringCheck.SetText(LookSpringText);
	LookSpringCheck.SetHelpText(LookSpringHelp);
	LookSpringCheck.SetFont(F_Normal);
	LookSpringCheck.Align = TA_Right;
	ControlOffset += 25;

	// Always Mouselook
	MouselookCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	if (GetPlayerOwner().bAlwaysMouselook)
		MouselookCheck.bChecked = true;
	MouselookCheck.SetText(MouselookText);
	MouselookCheck.SetHelpText(MouselookHelp);
	MouselookCheck.SetFont(F_Normal);
	MouselookCheck.Align = TA_Right;

	// Auto Slope
	AutoSlopeCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	if (GetPlayerOwner().bLookUpStairs)
		AutoSlopeCheck.bChecked = true;
	AutoSlopeCheck.SetText(AutoSlopeText);
	AutoSlopeCheck.SetHelpText(AutoSlopeHelp);
	AutoSlopeCheck.SetFont(F_Normal);
	AutoSlopeCheck.Align = TA_Right;
	ControlOffset += 25;

	// Mouse Smoothing
	MouseSmoothCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	MouseSmoothCheck.bChecked = GetPlayerOwner().bMaxMouseSmoothing;
	MouseSmoothCheck.SetText(MouseSmoothText);
	MouseSmoothCheck.SetHelpText(MouseSmoothHelp);
	MouseSmoothCheck.SetFont(F_Normal);
	MouseSmoothCheck.Align = TA_Right;

	// Mouse Sensitivity
	SensitivityEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	SensitivityEdit.SetText(SensitivityText);
	SensitivityEdit.SetHelpText(SensitivityHelp);
	SensitivityEdit.SetFont(F_Normal);
	SensitivityEdit.SetNumericOnly(True);
	SensitivityEdit.SetNumericFloat(True);
	SensitivityEdit.SetMaxLength(4);
	SensitivityEdit.Align = TA_Right;
	Sens = string(GetPlayerOwner().MouseSensitivity);
	i = InStr(Sens, ".");
	SensitivityEdit.SetValue(Left(Sens, i+3));
	ControlOffset += 25;

	// Invert Mouse
	InvertMouseCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	if (GetPlayerOwner().bInvertMouse)
		InvertMouseCheck.bChecked = true;
	InvertMouseCheck.SetText(InvertMouseText);
	InvertMouseCheck.SetHelpText(InvertMouseHelp);
	InvertMouseCheck.SetFont(F_Normal);
	InvertMouseCheck.Align = TA_Right;
}

function AfterCreate()
{
	DesiredWidth = 220;
	DesiredHeight = ControlOffset;
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

	AutoAimCheck.SetSize(ControlWidth, 1);
	AutoAimCheck.WinLeft = ControlRight;

	JoystickCheck.SetSize(ControlWidth, 1);
	JoystickCheck.WinLeft = ControlLeft;

	InvertMouseCheck.SetSize(ControlWidth, 1);
	InvertMouseCheck.WinLeft = ControlLeft;

	DirectInputCheck.SetSize(ControlWidth, 1);
	DirectInputCheck.WinLeft = ControlLeft;

	LookSpringCheck.SetSize(ControlWidth, 1);
	LookSpringCheck.WinLeft = ControlRight;

	MouselookCheck.SetSize(ControlWidth, 1);
	MouselookCheck.WinLeft = ControlLeft;

	AutoSlopeCheck.SetSize(ControlWidth, 1);
	AutoSlopeCheck.WinLeft = ControlRight;

	MouseSmoothCheck.SetSize(ControlWidth, 1);
	MouseSmoothCheck.WinLeft = ControlLeft;

	SensitivityEdit.SetSize(ControlWidth, 1);
	SensitivityEdit.WinLeft = ControlRight;
	SensitivityEdit.EditBoxWidth = 30;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case AutoAimCheck:
			AutoAimChecked();
			break;
		case JoystickCheck:
			JoystickChecked();
			break;
		case DirectInputCheck:
			DirectInputChecked();
			break;
		case InvertMouseCheck:
			InvertMouseChecked();
			break;
		case LookSpringCheck:
			LookSpringChecked();
			break;
		case MouselookCheck:
			MouselookChecked();
			break;
		case AutoSlopeCheck:
			AutoSlopeChecked();
			break;
		case SensitivityEdit:
			SensitivityChanged();
			break;
		case MouseSmoothCheck:
			MouseSmoothChanged();
			break;
		}
	}
}

/*
 * Message Crackers
 */

function AutoAimChecked()
{
	if(AutoAimCheck.bChecked)
	{
		GetPlayerOwner().ChangeAutoAim(0.93);
	} else {
		GetPlayerOwner().ChangeAutoAim(1.0);
	}
}

function JoystickChecked()
{
	if(JoystickCheck.bChecked)
	{
		GetPlayerOwner().ConsoleCommand("set windrv.windowsclient usejoystick 1");
	} else {
		GetPlayerOwner().ConsoleCommand("set windrv.windowsclient usejoystick 0");
	}
}

function DirectInputChecked()
{
	if(DirectInputCheck.bChecked)
	{
		GetPlayerOwner().ConsoleCommand("set windrv.windowsclient UseDirectInput 1");
	} else {
		GetPlayerOwner().ConsoleCommand("set windrv.windowsclient UseDirectInput 0");
	}
}

function InvertMouseChecked()
{
	GetPlayerOwner().bInvertMouse = InvertMouseCheck.bChecked;
}

function LookSpringChecked()
{
	GetPlayerOwner().bSnapToLevel = LookSpringCheck.bChecked;
}

function MouselookChecked()
{
	GetPlayerOwner().bAlwaysMouseLook = MouselookCheck.bChecked;
}

function AutoSlopeChecked()
{
	GetPlayerOwner().bLookUpStairs = AutoSlopeCheck.bChecked;
}

function SensitivityChanged()
{
	GetPlayerOwner().MouseSensitivity = float(SensitivityEdit.EditBox.Value);
}

function MouseSmoothChanged()
{
	GetPlayerOwner().bMaxMouseSmoothing = MouseSmoothCheck.bChecked;
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
	AutoAimText="Auto Aim"
	AutoAimHelp="Enable or disable vertical aiming help."
	JoystickText="Joystick"
	JoystickHelp="Enable or disable joystick."
	DirectInputText="DirectInput"
	DirectInputHelp="Enabling DirectInput on Windows 9x machines will improve mouse smoothness.  You must restart the game for this setting to take effect."
	SensitivityText="Mouse Sensitivity"
	SensitivityHelp="Adjust the mouse sensitivity, or how far you have to move the mouse to produce a given motion in the game."
	InvertMouseText="Invert Mouse"
	InvertMouseHelp="Invert the mouse X axis.  When true, pushing the mouse forward causes you to look down rather than up."
	LookSpringText="Look Spring"
	LookSpringHelp="If checked, releasing the mouselook key will automatically center the view. Only valid if Mouselook is disabled."
	MouselookText="Mouselook"
	MouselookHelp="If checked, the mouse is always used for controlling your view direction."
	AutoSlopeText="Auto Slope"
	AutoSlopeHelp="If checked, your view will automatically adjust to look up and down slopes and stairs. Only valid if Mouselook is disabled."
	MouseSmoothText="Mouse Smoothing"
	MouseSmoothHelp="If checked, mouse input will be smoothed to improve Mouselook smoothness."
	ControlOffset=20;
}
