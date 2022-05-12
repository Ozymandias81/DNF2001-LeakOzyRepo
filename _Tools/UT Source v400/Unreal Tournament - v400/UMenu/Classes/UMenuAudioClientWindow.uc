class UMenuAudioClientWindow extends UMenuPageWindow;

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

// Voice Messages
var UWindowCheckbox VoiceMessagesCheck;
var localized string VoiceMessagesText;
var localized string VoiceMessagesHelp;

// Message Beep
var UWindowCheckbox MessageBeepCheck;
var localized string MessageBeepText;
var localized string MessageBeepHelp;

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

	// Voice Messages
	VoiceMessagesCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	VoiceMessagesCheck.bChecked = !GetPlayerOwner().bNoVoices;
	VoiceMessagesCheck.SetText(VoiceMessagesText);
	VoiceMessagesCheck.SetHelpText(VoiceMessagesHelp);
	VoiceMessagesCheck.SetFont(F_Normal);
	VoiceMessagesCheck.Align = TA_Left;
	ControlOffset += 25;

	// Message Beep
	MessageBeepCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	MessageBeepCheck.bChecked = GetPlayerOwner().bMessageBeep;
	MessageBeepCheck.SetText(MessageBeepText);
	MessageBeepCheck.SetHelpText(MessageBeepHelp);
	MessageBeepCheck.SetFont(F_Normal);
	MessageBeepCheck.Align = TA_Left;
	ControlOffset += 25;

	ExtraMessageOptions();

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
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset;
}

function ExtraMessageOptions()
{
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

	VoiceMessagesCheck.SetSize(CenterWidth-90+16, 1);
	VoiceMessagesCheck.WinLeft = CenterPos;

	MessageBeepCheck.SetSize(CenterWidth-90+16, 1);
	MessageBeepCheck.WinLeft = CenterPos;

	SoundQualityCombo.SetSize(CenterWidth, 1);
	SoundQualityCombo.WinLeft = CenterPos;
	SoundQualityCombo.EditBoxWidth = 90;

	MusicVolumeSlider.SetSize(CenterWidth, 1);
	MusicVolumeSlider.SliderWidth = 90;
	MusicVolumeSlider.WinLeft = CenterPos;

	SoundVolumeSlider.SetSize(CenterWidth, 1);
	SoundVolumeSlider.SliderWidth = 90;
	SoundVolumeSlider.WinLeft = CenterPos;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case VoiceMessagesCheck:
			VoiceMessagesChecked();
			break;
		case MessageBeepCheck:
			MessageBeepChecked();
			break;
		case SoundQualityCombo:
			SoundQualityChanged();
			break;
		case MusicVolumeSlider:
			MusicVolumeChanged();
			break;
		case SoundVolumeSlider:
			SoundVolumeChanged();
			break;
		}
	}
}

/*
 * Message Crackers
 */

function SoundQualityChanged()
{
	local bool bLowSoundQuality;
	bLowSoundQuality = bool(SoundQualityCombo.GetSelectedIndex());
	bLowSoundQuality = !bLowSoundQuality;
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice LowSoundQuality "$bLowSoundQuality);
}

function VoiceMessagesChecked()
{
	GetPlayerOwner().bNoVoices = !VoiceMessagesCheck.bChecked;
}

function MessageBeepChecked()
{
	GetPlayerOwner().bMessageBeep = MessageBeepCheck.bChecked;
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
	SoundQualityHelp="Use low sound quality to improve game performance on machines with less than 32 Mb memory."
	Details(0)="Low"
	Details(1)="High"
	VoiceMessagesText="Voice Messages"
	VoiceMessagesHelp="If checked, you will hear voice messages and commands from other players."
	MessageBeepText="Message Beep"
	MessageBeepHelp="If checked, you will hear a beep sound when chat message received."
	ControlOffset=25
}