/*-----------------------------------------------------------------------------
	UDukeControlsCW
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeControlsCW extends UDukePageWindow;

// Header
var localized string ActionText;
var localized string AssignedText;

// Mouse Sensitivity
var UWindowLabelControl SensitivityLabel;
var UWindowHSliderControl SensitivitySlider;
var localized string SensitivityText;
var localized string SensitivityHelp;

// Invert Mouse
var UWindowLabelControl InvertMouseLabel;
var UWindowCheckbox InvertMouseCheck;
var localized string InvertMouseText;
var localized string InvertMouseHelp;

// JoyX
var UWindowLabelControl JoyXLabel;
var UWindowComboControl JoyXCombo;
var localized string JoyXText;
var localized string JoyXHelp;
var localized string JoyXOptions[2];
var string JoyXBinding[2];

// JoyY
var UWindowLabelControl JoyYLabel;
var UWindowComboControl JoyYCombo;
var localized string JoyYText;
var localized string JoyYHelp;
var localized string JoyYOptions[2];
var string JoyYBinding[2];

// Controls Binder
var UDukeControlsBinder ControlBinder;
var float ControlBinderHeight;
var int AliasCount, SpaceFiller;
var bool bLoadedExisting;
var localized string CustomizeHelp;

var float ControlOffset;

function Created()
{
	bIgnoreLDoubleClick = true;
	bIgnoreMDoubleClick = true;
	bIgnoreRDoubleClick = true;

	SetAcceptsFocus();

	Super.Created();

	// Controls binder.
	ControlBinder = UDukeControlsBinder( CreateWindow(class'UDukeControlsBinder', 1, 1, 1, 1) );

	// Invert Mouse
	InvertMouseLabel = UWindowLabelControl( CreateControl(class'UWindowLabelControl', 1, 1, 1, 1) );
	InvertMouseLabel.SetText( InvertMouseText );
	InvertMouseLabel.SetFont( F_Normal );
	InvertMouseLabel.Align = TA_Right;

	InvertMouseCheck = UWindowCheckbox( CreateControl(class'UWindowCheckbox', 1, 1, 1, 1) );
	if ( GetPlayerOwner().bInvertMouse )
		InvertMouseCheck.bChecked = true;
	InvertMouseCheck.SetHelpText( InvertMouseHelp );
	InvertMouseCheck.SetFont( F_Normal );
	InvertMouseCheck.bAcceptsFocus = false;
	InvertMouseCheck.Align = TA_Right;

	// Mouse Sensitivity
	SensitivityLabel = UWindowLabelControl( CreateControl(class'UWindowLabelControl', 1, 1, 1, 1) );
	SensitivityLabel.SetText( SensitivityText );
	SensitivityLabel.SetFont( F_Normal );
	SensitivityLabel.Align = TA_Right;

	SensitivitySlider = UWindowHSliderControl( CreateControl(class'UWindowHSliderControl', 1, 1, 1, 1) );
	SensitivitySlider.bNoSlidingNotify = true;
	SensitivitySlider.SetRange( 1, 30, 0.5 );
	SensitivitySlider.SetHelpText( SensitivityHelp );
	SensitivitySlider.SetFont( F_Normal );
	SensitivitySlider.SetValue( GetPlayerOwner().MouseSensitivity );
	SensitivitySlider.bAcceptsFocus = false;
	SensitivitySlider.bFloatValue = true;
	SensitivitySlider.Align = TA_Right;
	
	// JoyX
	JoyXLabel = UWindowLabelControl( CreateControl(class'UWindowLabelControl', 1, 1, 1, 1) );
	JoyXLabel.SetText( JoyXText );
	JoyXLabel.SetFont( F_Normal );
	JoyXLabel.Align = TA_Right;

	JoyXCombo = UWindowComboControl( CreateControl(class'UWindowComboControl', 1, 1, 1, 1) );
	JoyXCombo.CancelAcceptsFocus();
	JoyXCombo.SetHelpText( JoyXHelp );
	JoyXCombo.SetFont( F_Normal );
	JoyXCombo.SetEditable( false );
	JoyXCombo.AddItem( JoyXOptions[0] );
	JoyXCombo.AddItem( JoyXOptions[1] );
	JoyXCombo.Align = TA_Right;

	// JoyY
	JoyYLabel = UWindowLabelControl( CreateControl(class'UWindowLabelControl', 1, 1, 1, 1) );
	JoyYLabel.SetText( JoyYText );
	JoyYLabel.SetFont( F_Normal );
	JoyYLabel.Align = TA_Right;

	JoyYCombo = UWindowComboControl( CreateControl(class'UWindowComboControl', 1, 1, 1, 1) );
	JoyYCombo.CancelAcceptsFocus();
	JoyYCombo.SetHelpText( JoyYHelp );
	JoyYCombo.SetFont( F_Normal );
	JoyYCombo.SetEditable( false );
	JoyYCombo.AddItem( JoyYOptions[0] );
	JoyYCombo.AddItem( JoyYOptions[1] );
	JoyYCombo.Align = TA_Right;

	ResizeFrames = 3;
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
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint( C, X, Y );

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	ControlBinder.SetSize( WinWidth - 20, 210 );
	ControlBinder.WinTop = 10;
	ControlBinder.WinLeft = (WinWidth - ControlBinder.WinWidth) / 2;

	SensitivitySlider.SetSize( CenterWidth, SensitivitySlider.WinHeight );
	SensitivityLabel.AutoSize( C );

	SensitivitySlider.SliderWidth = 150;
	SensitivitySlider.WinLeft = CColRight;
	SensitivitySlider.WinTop = ControlBinder.WinTop + ControlBinder.WinHeight + ControlOffset;

	SensitivityLabel.WinLeft = CColLeft - SensitivityLabel.WinWidth;
	SensitivityLabel.WinTop = SensitivitySlider.WinTop + 4;

	InvertMouseCheck.SetSize( 32, InvertMouseCheck.WinHeight );
	InvertMouseLabel.AutoSize( C );

	InvertMouseCheck.WinLeft = CColRight;
	InvertMouseCheck.WinTop = SensitivitySlider.WinTop + SensitivitySlider.WinHeight + ControlOffset + InvertMouseCheck.GetHeightAdjust();

	InvertMouseLabel.WinLeft = CColLeft - InvertMouseLabel.WinWidth;
	InvertMouseLabel.WinTop = InvertMouseCheck.WinTop + 10;

	JoyXCombo.SetSize( 200, JoyXCombo.WinHeight );
	JoyXLabel.AutoSize( C );

	JoyXCombo.WinLeft = (WinWidth - (JoyXCombo.WinWidth + JoyXLabel.WinWidth + 10)) / 2 + 10 + JoyXLabel.WinWidth;
	JoyXCombo.EditBoxWidth = 200;
	JoyXCombo.WinTop = InvertMouseCheck.WinTop + InvertMouseCheck.WinHeight + ControlOffset;

	JoyXLabel.WinLeft = (WinWidth - (JoyXCombo.WinWidth + JoyXLabel.WinWidth + 10)) / 2;
	JoyXLabel.WinTop = JoyXCombo.WinTop + 8;

	JoyYCombo.SetSize( 200, JoyYCombo.WinHeight );
	JoyYLabel.AutoSize( C );

	JoyYCombo.WinLeft = (WinWidth - (JoyYCombo.WinWidth + JoyYLabel.WinWidth + 10)) / 2 + 10 + JoyYLabel.WinWidth;
	JoyYCombo.EditBoxWidth = 200;
	JoyYCombo.WinTop = JoyXCombo.WinTop + JoyXCombo.WinHeight + ControlOffset;

	JoyYLabel.WinLeft = (WinWidth - (JoyYCombo.WinWidth + JoyYLabel.WinWidth + 10)) / 2;
	JoyYLabel.WinTop = JoyYCombo.WinTop + 8;
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

	Super.ResetPressed();
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
	JoyXText="Joystick X Axis"
	JoyXHelp="Select the behavior for the left-right axis of your joystick."
	JoyXOptions(0)="Strafe Left/Right"
	JoyXOptions(1)="Turn Left/Right"
	JoyXBinding(0)="Axis aStrafe speed=2"
	JoyXBinding(1)="Axis aBaseX speed=0.7"
	JoyYText="Joystick Y Axis"
	JoyYHelp="Select the behavior for the up-down axis of your joystick."
	JoyYOptions(0)="Move Forward/Back"
	JoyYOptions(1)="Look Up/Down"
	JoyYBinding(0)="Axis aBaseY speed=2"
	JoyYBinding(1)="Axis aLookup speed=-0.4"
	ControlOffset=10
	SensitivityText="Mouse Sensitivity"
	SensitivityHelp="Adjust the mouse sensitivity."
	InvertMouseText="Invert Mouse"
	InvertMouseHelp="Invert the mouse X axis."
}