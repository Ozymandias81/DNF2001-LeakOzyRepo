/*-----------------------------------------------------------------------------
	UDukeAudioCW
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeAudioCW expands UDukePageWindow;

// 3D Hardware Check
var UWindowLabelControl Use3DHardwareLabel;
var UWindowCheckbox Use3DHardwareCheck;
var localized string Use3DHardwareText;
var localized string Use3DHardwareHelp;

// Surround Sound
var UWindowLabelControl UseSurroundSoundLabel;
var UWindowCheckbox UseSurroundSoundCheck;
var localized string UseSurroundSoundText;
var localized string UseSurroundSoundHelp;

// Hardware
var UWindowLabelControl ConfirmHardwareLabel;
var UWindowMessageBox ConfirmHardware;
var localized string ConfirmHardwareTitle;
var localized string ConfirmHardwareText;

// Surround
var UWindowLabelControl ConfirmSurroundLabel;
var UWindowMessageBox ConfirmSurround;
var localized string ConfirmSurroundTitle;
var localized string ConfirmSurroundText;

// Sound Quality
var UWindowLabelControl SoundQualityLabel;
var UWindowComboControl SoundQualityCombo;
var localized string SoundQualityText;
var localized string SoundQualityHelp;
var localized string Details[2];

// Music Volume
var UWindowLabelControl MusicVolumeLabel;
var UWindowHSliderControl MusicVolumeSlider;
var localized string MusicVolumeText;
var localized string MusicVolumeHelp;

// Sound Volume
var UWindowLabelControl SoundVolumeLabel;
var UWindowHSliderControl SoundVolumeSlider;
var localized string SoundVolumeText;
var localized string SoundVolumeHelp;

var float ControlOffset;

function Created()
{
	local bool bLowSoundQuality;
	local int MusicVolume, SoundVolume;
	local int CenterWidth;

	Super.Created();

	CenterWidth = (WinWidth/4)*3;

	// Sound Quality
	SoundQualityLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	SoundQualityLabel.SetText(SoundQualityText);
	SoundQualityLabel.SetFont(F_Normal);
	SoundQualityLabel.Align = TA_Right;

	SoundQualityCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, CenterWidth, 1));
	SoundQualityCombo.SetHelpText(SoundQualityHelp);
	SoundQualityCombo.SetFont(F_Normal);
	SoundQualityCombo.SetEditable(False);
	SoundQualityCombo.AddItem(Details[0]);
	SoundQualityCombo.AddItem(Details[1]);
	SoundQualityCombo.Align = TA_Right;
	bLowSoundQuality = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice LowSoundQuality"));
	if (bLowSoundQuality)
		SoundQualityCombo.SetSelectedIndex(0);
	else
		SoundQualityCombo.SetSelectedIndex(1);

	// Music Volume
	MusicVolumeLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MusicVolumeLabel.SetText(MusicVolumeText);
	MusicVolumeLabel.SetFont(F_Normal);
	MusicVolumeLabel.Align = TA_Right;

	MusicVolumeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 1, 1, 1, 1));
	MusicVolumeSlider.SetRange(0, 255, 32);
	MusicVolume = int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume"));
	MusicVolumeSlider.SetValue(MusicVolume);
	MusicVolumeSlider.SetHelpText(MusicVolumeHelp);
	MusicVolumeSlider.SetFont(F_Normal);
	MusicVolumeSlider.Align = TA_Right;

	// Sound Volume
	SoundVolumeLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	SoundVolumeLabel.SetText(SoundVolumeText);
	SoundVolumeLabel.SetFont(F_Normal);
	SoundVolumeLabel.Align = TA_Right;

	SoundVolumeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 1, 1, 1, 1));
	SoundVolumeSlider.SetRange(0, 255, 32);
	SoundVolume = int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice SoundVolume"));
	SoundVolumeSlider.SetValue(SoundVolume);
	SoundVolumeSlider.SetHelpText(SoundVolumeHelp);
	SoundVolumeSlider.SetFont(F_Normal);
	SoundVolumeSlider.Align = TA_Right;

	// 3DHardware.
	Use3DHardwareLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	Use3DHardwareLabel.SetText(Use3DHardwareText);
	Use3DHardwareLabel.SetFont(F_Normal);
	Use3DHardwareLabel.Align = TA_Right;

	Use3DHardwareCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 1, 1, 1, 1));
	Use3DHardwareCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice Use3dHardware"));
	Use3DHardwareCheck.SetHelpText(Use3DHardwareHelp);
	Use3DHardwareCheck.SetFont(F_Normal);
	Use3DHardwareCheck.Align = TA_Right;

	// Surround Sound.
	UseSurroundSoundLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	UseSurroundSoundLabel.SetText(UseSurroundSoundText);
	UseSurroundSoundLabel.SetFont(F_Normal);
	UseSurroundSoundLabel.Align = TA_Right;

	UseSurroundSoundCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 1, 1, 1, 1));
	UseSurroundSoundCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice UseSurround"));
	UseSurroundSoundCheck.SetHelpText(UseSurroundSoundHelp);
	UseSurroundSoundCheck.SetFont(F_Normal);
	UseSurroundSoundCheck.Align = TA_Right;

	ResizeFrames = 3;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint(C, X, Y);

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	SoundQualityCombo.SetSize( 200, SoundQualityCombo.WinHeight );
	SoundQualityCombo.WinLeft = CColRight;
	SoundQualityCombo.WinTop = ControlOffset;

	SoundQualityLabel.AutoSize( C );
	SoundQualityLabel.WinLeft = CColLeft - SoundQualityLabel.WinWidth;
	SoundQualityLabel.WinTop = SoundQualityCombo.WinTop + 8;

	MusicVolumeSlider.SetSize( CenterWidth, MusicVolumeSlider.WinHeight );
	MusicVolumeSlider.SliderWidth = 150;
	MusicVolumeSlider.WinLeft = CColRight;
	MusicVolumeSlider.WinTop = SoundQualityCombo.WinTop + SoundQualityCombo.WinHeight + ControlOffset;

	MusicVolumeLabel.AutoSize( C );
	MusicVolumeLabel.WinLeft = CColLeft - MusicVolumeLabel.WinWidth;
	MusicVolumeLabel.WinTop = MusicVolumeSlider.WinTop + 4;

	SoundVolumeSlider.SetSize( CenterWidth, SoundVolumeSlider.WinHeight );
	SoundVolumeSlider.SliderWidth = 150;
	SoundVolumeSlider.WinLeft = CColRight;
	SoundVolumeSlider.WinTop = MusicVolumeSlider.WinTop + MusicVolumeSlider.WinHeight + ControlOffset;

	SoundVolumeLabel.AutoSize( C );
	SoundVolumeLabel.WinLeft = CColLeft - SoundVolumeLabel.WinWidth;
	SoundVolumeLabel.WinTop = SoundVolumeSlider.WinTop + 4;

	Use3DHardwareCheck.SetSize( CenterWidth-90+16, Use3DHardwareCheck.WinHeight );
	Use3DHardwareCheck.WinLeft = CColRight;
	Use3DHardwareCheck.WinTop = SoundVolumeSlider.WinTop + SoundVolumeSlider.WinHeight + ControlOffset + Use3DHardwareCheck.GetHeightAdjust();

	Use3DHardwareLabel.AutoSize( C );
	Use3DHardwareLabel.WinLeft = CColLeft - Use3DHardwareLabel.WinWidth;
	Use3DHardwareLabel.WinTop = Use3DHardwareCheck.WinTop + 10;

	UseSurroundSoundCheck.SetSize( CenterWidth-90+16, UseSurroundSoundCheck.WinHeight );
	UseSurroundSoundCheck.WinLeft = CColRight;
	UseSurroundSoundCheck.WinTop = Use3DHardwareCheck.WinTop + Use3DHardwareCheck.WinHeight + ControlOffset + Use3DHardwareCheck.GetHeightAdjust()*2;

	UseSurroundSoundLabel.AutoSize( C );
	UseSurroundSoundLabel.WinLeft = CColLeft - UseSurroundSoundLabel.WinWidth;
	UseSurroundSoundLabel.WinTop = UseSurroundSoundCheck.WinTop + 10;

	DesiredWidth = 220;
	DesiredHeight = UseSurroundSoundCheck.WinTop + UseSurroundSoundCheck.WinHeight + ControlOffset;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case SoundQualityCombo:
			SoundQualityChanged();
			break;
		case MusicVolumeSlider:
			MusicVolumeChanged();
			break;
		case SoundVolumeSlider:
			SoundVolumeChanged();
			break;
		case Use3DHardwareCheck:
			Hardware3DChecked();
			break;
		case UseSurroundSoundCheck:
			SurroundSoundChecked();
			break;
		}
	}
}

function Hardware3DChecked()
{
	Hardware3DSet();

	if(Use3DHardwareCheck.bChecked)
	{
		ParentWindow.ParentWindow.HideWindow();
		ConfirmHardware = MessageBox(ConfirmHardwareTitle, ConfirmHardwareText, MB_YesNo, MR_No, MR_None);
	}
}

function Hardware3DSet()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice Use3dHardware "$Use3DHardwareCheck.bChecked);
}

function SurroundSoundChecked()
{
	SurroundSoundSet();
	if(UseSurroundSoundCheck.bChecked)
	{
		ParentWindow.ParentWindow.HideWindow();
		ConfirmSurround = MessageBox(ConfirmSurroundTitle, ConfirmSurroundText, MB_YesNo, MR_No, MR_None);
	}
}

function SurroundSoundSet()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice UseSurround "$UseSurroundSoundCheck.bChecked);
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(Result != MR_Yes)
	{
		switch(W)
		{
		case ConfirmHardware:
			Use3DHardwareCheck.bChecked = False;
			Hardware3DSet();
			ConfirmHardware = None;
			break;
		case ConfirmSurround:
			UseSurroundSoundCheck.bChecked = False;
			SurroundSoundSet();
			ConfirmSurround = None;
			break;
		}
	}
	ParentWindow.ParentWindow.ShowWindow();
}

function SoundQualityChanged()
{
	local bool bLowSoundQuality;
	bLowSoundQuality = bool(SoundQualityCombo.GetSelectedIndex());
	bLowSoundQuality = !bLowSoundQuality;
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice LowSoundQuality "$bLowSoundQuality);
}

function MusicVolumeChanged()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume "$MusicVolumeSlider.Value);
}

function SoundVolumeChanged()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume "$SoundVolumeSlider.Value);
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
	MusicVolumeText="Music Volume"
	MusicVolumeHelp="Increase or decrease music volume."
	SoundVolumeText="Sound Volume"
	SoundVolumeHelp="Increase or decrease sound effects volume."
	SoundQualityText="Sound Quality"
	SoundQualityHelp="Set sound quality.  Lower is faster on old machines."
	Details(0)="Low"
	Details(1)="High"
	ControlOffset=10.0
	Use3DHardwareText="Hardware 3D Sound"
	Use3DHardwareHelp="Set to use 3D sound hardware.  May affect performance."
	UseSurroundSoundText="Surround Sound"
	UseSurroundSoundHelp="Set to use surround sound."
	ConfirmHardwareTitle="Confirm Change"
	ConfirmHardwareText="The hardware 3D sound feature requires you have a 3D sound card supporting A3D or EAX.  Enabling this option can also cause your performance to degrade severely in some cases.\\n\\nAre you sure you want to enable this feature?"
	ConfirmSurroundTitle="Confirm Change"
	ConfirmSurroundText="The surround sound feature requires you have a compatible surround sound receiver connected to your sound card.  Enabling this option without the appropriate receiver can cause anomalies in sound performance.\\n\\nAre you sure you want to enable this feature?"
}

