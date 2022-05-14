class UDukeAudioCW expands UDukePageWindow;

// 3D Hardware Check
var UWindowCheckbox Use3DHardwareCheck;
var localized string Use3DHardwareText;
var localized string Use3DHardwareHelp;

// Surround Sound
var UWindowCheckbox UseSurroundSoundCheck;
var localized string UseSurroundSoundText;
var localized string UseSurroundSoundHelp;

// Hardware
var UWindowMessageBox ConfirmHardware;
var localized string ConfirmHardwareTitle;
var localized string ConfirmHardwareText;

// Surround
var UWindowMessageBox ConfirmSurround;
var localized string ConfirmSurroundTitle;
var localized string ConfirmSurroundText;

// Sound Quality
var UWindowComboControl SoundQualityCombo;
var localized string SoundQualityText;
var localized string SoundQualityHelp;
var localized string Details[2];

// Music Volume
var UWindowHSliderControl MusicVolumeSlider;
var localized string MusicVolumeText;
var localized string MusicVolumeHelp;

// Sound Volume
var UWindowHSliderControl SoundVolumeSlider;
var localized string SoundVolumeText;
var localized string SoundVolumeHelp;

var float ControlOffset;

function Created()
{
	local bool bLowSoundQuality;
	local int MusicVolume, SoundVolume;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Sound Quality
	SoundQualityCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	SoundQualityCombo.SetText(SoundQualityText);
	SoundQualityCombo.SetHelpText(SoundQualityHelp);
	SoundQualityCombo.SetFont(F_Normal);
	SoundQualityCombo.SetEditable(False);
	SoundQualityCombo.AddItem(Details[0]);
	SoundQualityCombo.AddItem(Details[1]);
	bLowSoundQuality = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice LowSoundQuality"));
	if (bLowSoundQuality)
		SoundQualityCombo.SetSelectedIndex(0);
	else
		SoundQualityCombo.SetSelectedIndex(1);
	ControlOffset += 25;

	// Music Volume
	MusicVolumeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	MusicVolumeSlider.SetRange(0, 255, 32);
	MusicVolume = int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume"));
	MusicVolumeSlider.SetValue(MusicVolume);
	MusicVolumeSlider.SetText(MusicVolumeText);
	MusicVolumeSlider.SetHelpText(MusicVolumeHelp);
	MusicVolumeSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// Sound Volume
	SoundVolumeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	SoundVolumeSlider.SetRange(0, 255, 32);
	SoundVolume = int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice SoundVolume"));
	SoundVolumeSlider.SetValue(SoundVolume);
	SoundVolumeSlider.SetText(SoundVolumeText);
	SoundVolumeSlider.SetHelpText(SoundVolumeHelp);
	SoundVolumeSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// 3DHardware.
	Use3DHardwareCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	Use3DHardwareCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice Use3dHardware"));
	Use3DHardwareCheck.SetText(Use3DHardwareText);
	Use3DHardwareCheck.SetHelpText(Use3DHardwareHelp);
	Use3DHardwareCheck.SetFont(F_Normal);
	Use3DHardwareCheck.Align = TA_Left;
	ControlOffset += 25;

	// Surround Sound.
	UseSurroundSoundCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	UseSurroundSoundCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice UseSurround"));
	UseSurroundSoundCheck.SetText(UseSurroundSoundText);
	UseSurroundSoundCheck.SetHelpText(UseSurroundSoundHelp);
	UseSurroundSoundCheck.SetFont(F_Normal);
	UseSurroundSoundCheck.Align = TA_Left;
	ControlOffset += 25;
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	SoundQualityCombo.SetSize(CenterWidth, 1);
	SoundQualityCombo.WinLeft = CenterPos;
	SoundQualityCombo.EditBoxWidth = 90;

	MusicVolumeSlider.SetSize(CenterWidth, 1);
	MusicVolumeSlider.SliderWidth = 90;
	MusicVolumeSlider.WinLeft = CenterPos;

	SoundVolumeSlider.SetSize(CenterWidth, 1);
	SoundVolumeSlider.SliderWidth = 90;
	SoundVolumeSlider.WinLeft = CenterPos;

	Use3DHardwareCheck.SetSize(CenterWidth-90+16, 1);
	Use3DHardwareCheck.WinLeft = CenterPos;

	UseSurroundSoundCheck.SetSize(CenterWidth-90+16, 1);
	UseSurroundSoundCheck.WinLeft = CenterPos;
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
     Use3DHardwareText="Use Hardware 3D Sound"
     Use3DHardwareHelp="If checked, UT will use your 3D audio hardware for richer environmental effects."
     UseSurroundSoundText="Use Surround Sound"
     UseSurroundSoundHelp="If checked, UT will use your digital receiver for better surround sound."
     ConfirmHardwareTitle="Confirm Change"
     ConfirmHardwareText="The hardware 3D sound feature requires you have a 3D sound card supporting A3D or EAX.  Enabling this option can also cause your performance to degrade severely in some cases.\n\nAre you sure you want to enable this feature?"
     ConfirmSurroundTitle="Confirm Change"
     ConfirmSurroundText="The surround sound feature requires you have a compatible surround sound receiver connected to your sound card.  Enabling this option without the appropriate receiver can cause anomalies in sound performance.\n\nAre you sure you want to enable this feature?"
     SoundQualityText="Sound Quality"
     SoundQualityHelp="Use low sound quality to improve game performance on machines with less than 32 Mb memory."
     Details(0)="Low"
     Details(1)="High"
     MusicVolumeText="Music Volume"
     MusicVolumeHelp="Increase or decrease music volume."
     SoundVolumeText="Sound Volume"
     SoundVolumeHelp="Increase or decrease sound effects volume."
     ControlOffset=20.000000
}
