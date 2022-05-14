//=============================================================================
// FILE:			UDukeVideoCW.uc
//==========================================================================
class UDukeVideoCW expands UDukePageWindow;

// Driver
var bool bInitialized;
var UWindowLabelControl DriverLabel;
var UWindowLabelControl DriverDesc;
var UWindowSmallButton DriverButton;
var localized string DriverText;
var localized string DriverHelp;
var localized string DriverButtonText;
var localized string DriverButtonHelp;

// Resolution
var UWindowComboControl ResolutionCombo;
var localized string ResolutionText;
var localized string ResolutionHelp;
var string OldSettings;

// Color Depth
var UWindowComboControl ColorDepthCombo;
var localized string ColorDepthText;
var localized string ColorDepthHelp;
var localized string BitsText;

// Texture Detail
var UWindowComboControl TextureDetailCombo;
var localized string TextureDetailText;
var localized string TextureDetailHelp;
var localized string Details[3];
var int OldTextureDetail;

// Skin Detail
var UWindowComboControl SkinDetailCombo;
var localized string SkinDetailText;
var localized string SkinDetailHelp;
var int OldSkinDetail;

// Brightness
var UWindowHSliderControl BrightnessSlider;
var localized string BrightnessText;
var localized string BrightnessHelp;

// Specular
var UWindowCheckbox UseSpecular;
var localized string UseSpecText;
var localized string UseSpecHelp;

// Detail Texture Range
var UWindowHSliderControl DetailTextureRangeSlider;
var localized string DetailTextureRangeText;
var localized string DetailTextureRangeHelp;

// Particle LOD:

// Particle Density:
var UWindowHSliderControl ParticleDensitySlider;
var localized string ParticleDensityText;
var localized string ParticleDensityHelp;

var float ControlOffset;

var UWindowMessageBox ConfirmSettings, ConfirmDriver;
var localized string ConfirmTitle;
var localized string ConfirmSettingsText;
var localized string ConfirmSettingsCancelText;
var localized string ConfirmDriverText;

function Created()
{
	local bool bLowSoundQuality;
	local int MusicVolume, SoundVolume;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int i, MinRate;
	local string NextLook, NextDesc;
	local string VideoDriverClassName, ClassLeft, ClassRight, VideoDriverDesc;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;
	
	VideoDriverClassName = GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.GameRenderDevice Class");
	i = InStr(VideoDriverClassName, "'");
	// Get class name from class'...'
	if(i != -1)
	{
		VideoDriverClassName = Mid(VideoDriverClassName, i+1);
		i = InStr(VideoDriverClassName, "'");
		VideoDriverClassName = Left(VideoDriverClassName, i);
		ClassLeft = Left(VideoDriverClassName, InStr(VideoDriverClassName, "."));
		ClassRight = Mid(VideoDriverClassName, InStr(VideoDriverClassName, ".") + 1);
		VideoDriverDesc = Localize(ClassRight, "ClassCaption", ClassLeft);
	}
	else
		VideoDriverDesc = "VideoDriverClassName";

	// Driver
	DriverLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	DriverLabel.SetText(DriverText);
	DriverLabel.SetHelpText(DriverHelp);
	DriverLabel.SetFont(F_Normal);

	DriverDesc = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlRight, ControlOffset, ControlWidth, 1));
	DriverDesc.SetText(VideoDriverDesc);
	DriverDesc.SetHelpText(DriverHelp);
	DriverDesc.SetFont(F_Normal);
	ControlOffset += 17;

	DriverButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ControlRight, ControlOffset, 48, 16));
	DriverButton.SetText(DriverButtonText);
	DriverButton.SetFont(F_Normal);
	DriverButton.SetHelpText(DriverButtonHelp);
	ControlOffset += 25;

	// Resolution
	ResolutionCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ResolutionCombo.SetText(ResolutionText);
	ResolutionCombo.SetHelpText(ResolutionHelp);
	ResolutionCombo.SetFont(F_Normal);
	ResolutionCombo.SetEditable(False);
	ControlOffset += 25;

	ColorDepthCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ColorDepthCombo.SetText(ColorDepthText);
	ColorDepthCombo.SetHelpText(ColorDepthHelp);
	ColorDepthCombo.SetFont(F_Normal);
	ColorDepthCombo.SetEditable(False);
	ControlOffset += 25;

	// Texture Detail
	TextureDetailCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	TextureDetailCombo.SetText(TextureDetailText);
	TextureDetailCombo.SetHelpText(TextureDetailHelp);
	TextureDetailCombo.SetFont(F_Normal);
	TextureDetailCombo.SetEditable(False);
	ControlOffset += 25;

	// The display names are localized.  These strings match the enums in UnCamMgr.cpp.
	TextureDetailCombo.AddItem(Details[0], "High");
	TextureDetailCombo.AddItem(Details[1], "Medium");
	TextureDetailCombo.AddItem(Details[2], "Low");

	// Skin Detail
	SkinDetailCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	SkinDetailCombo.SetText(SkinDetailText);
	SkinDetailCombo.SetHelpText(SkinDetailHelp);
	SkinDetailCombo.SetFont(F_Normal);
	SkinDetailCombo.SetEditable(False);
	SkinDetailCombo.AddItem(Details[0], "High");
	SkinDetailCombo.AddItem(Details[1], "Medium");
	SkinDetailCombo.AddItem(Details[2], "Low");
	ControlOffset += 25;

	// DetailTextureRange
	DetailTextureRangeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	DetailTextureRangeSlider.bNoSlidingNotify = True;
	DetailTextureRangeSlider.SetRange(0, 1000, 50);
	DetailTextureRangeSlider.SetText(DetailTextureRangeText);
	DetailTextureRangeSlider.SetHelpText(DetailTextureRangeHelp);
	DetailTextureRangeSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// ParticleDensity
	ParticleDensitySlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	ParticleDensitySlider.bNoSlidingNotify = True;
	ParticleDensitySlider.SetRange(0, 100, 100);
	ParticleDensitySlider.SetText(ParticleDensityText);
	ParticleDensitySlider.SetHelpText(ParticleDensityHelp);
	ParticleDensitySlider.SetFont(F_Normal);
	ControlOffset += 25;

	// Brightness
	BrightnessSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	BrightnessSlider.bNoSlidingNotify = True;
	BrightnessSlider.SetRange(0, 100, 50);
	BrightnessSlider.SetText(BrightnessText);
	BrightnessSlider.SetHelpText(BrightnessHelp);
	BrightnessSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// Specular
	UseSpecular = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	Log(GetPlayerOwner().ConsoleCommand("GetSpecular"));
	UseSpecular.bChecked = bool(GetPlayerOwner().ConsoleCommand("GetSpecular"));
	UseSpecular.SetText(UseSpecText);
	UseSpecular.SetHelpText(UseSpecHelp);
	UseSpecular.SetFont(F_Normal);
	UseSpecular.Align = TA_Left;

	LoadAvailableSettings();
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset;
}

function LoadAvailableSettings()
{
	local float Brightness, NearZ;
	local int P;
	local string CurrentDepth;
	local string ParseString;

	bInitialized = False;

	// Load available video drivers and current video driver here.

	ResolutionCombo.Clear();
	ParseString = GetPlayerOwner().ConsoleCommand("GetRes");
	P = InStr(ParseString, " ");
	while (P != -1) 
	{
		ResolutionCombo.AddItem(Left(ParseString, P));
		ParseString = Mid(ParseString, P+1);
		P = InStr(ParseString, " ");
	}
	ResolutionCombo.AddItem(ParseString);
	ResolutionCombo.SetValue(GetPlayerOwner().ConsoleCommand("GetCurrentRes"));

	ColorDepthCombo.Clear();
	ParseString = GetPlayerOwner().ConsoleCommand("GetColorDepths");
	P = InStr(ParseString, " ");
	while (P != -1) 
	{
		ColorDepthCombo.AddItem(Left(ParseString, P)@BitsText, Left(ParseString, P));
		ParseString = Mid(ParseString, P+1);
		P = InStr(ParseString, " ");
	}
	ColorDepthCombo.AddItem(ParseString@BitsText, ParseString);
	CurrentDepth = GetPlayerOwner().ConsoleCommand("GetCurrentColorDepth");
	ColorDepthCombo.SetValue(CurrentDepth@BitsText, CurrentDepth);

	OldTextureDetail = Max(0, TextureDetailCombo.FindItemIndex2(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.ViewportManager TextureDetail")));
	TextureDetailCombo.SetSelectedIndex(OldTextureDetail);
	OldSkinDetail = Max(0, SkinDetailCombo.FindItemIndex2(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.ViewportManager SkinDetail")));
	SkinDetailCombo.SetSelectedIndex(OldSkinDetail);

	// Brightness
	//Brightness = int(float(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness")) * 100.0);
	Brightness = int((float(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"))-0.25)*2* 100.0);
	BrightnessSlider.SetValue(Brightness);

	// Detail texture range.
	NearZ = float(GetPlayerOwner().ConsoleCommand("GetNearZ"));
	DetailTextureRangeSlider.SetValue(NearZ);

	// Particle density slider:
	ParticleDensitySlider.SetValue(float(GetPlayerOwner().ConsoleCommand("ParticleDensity"))*100.0);

	bInitialized = true;
}

function ResolutionChanged(float W, float H)
{
	Super.ResolutionChanged(H, H);
	if(GetPlayerOwner().ConsoleCommand("GetCurrentRes") != ResolutionCombo.GetValue())
		LoadAvailableSettings();
}

function SaveConfigs()
{
	LookAndFeel.SaveConfig();
	GetPlayerOwner().SaveConfig();
	Root.Console.SaveConfig();

	Super.SaveConfigs();
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

	DriverLabel.SetSize(CenterWidth-100, 1);
	DriverLabel.WinLeft = CenterPos;

	DriverDesc.SetSize(200, 1);
	DriverDesc.WinLeft = CenterPos + CenterWidth - 100;

	DriverButton.AutoWidth(C);
	DriverButton.WinLeft = CenterPos + CenterWidth - 100;

	ResolutionCombo.SetSize(CenterWidth, 1);
	ResolutionCombo.WinLeft = CenterPos;
	ResolutionCombo.EditBoxWidth = 100;

	ColorDepthCombo.SetSize(CenterWidth, 1);
	ColorDepthCombo.WinLeft = CenterPos;
	ColorDepthCombo.EditBoxWidth = 100;

	TextureDetailCombo.SetSize(CenterWidth, 1);
	TextureDetailCombo.WinLeft = CenterPos;
	TextureDetailCombo.EditBoxWidth = 100;

	SkinDetailCombo.SetSize(CenterWidth, 1);
	SkinDetailCombo.WinLeft = CenterPos;
	SkinDetailCombo.EditBoxWidth = 100;

	BrightnessSlider.SetSize(CenterWidth, 1);
	BrightnessSlider.SliderWidth = 100;
	BrightnessSlider.WinLeft = CenterPos;

	UseSpecular.SetSize(CenterWidth-90+16, 1);
	UseSpecular.WinLeft = CenterPos;

	DetailTextureRangeSlider.SetSize(CenterWidth, 1);
	DetailTextureRangeSlider.SliderWidth = 100;
	DetailTextureRangeSlider.WinLeft = CenterPos;

	ParticleDensitySlider.SetSize(CenterWidth, 1);
	ParticleDensitySlider.SliderWidth = 100;
	ParticleDensitySlider.WinLeft = CenterPos;

}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)  
	{
		case DE_Click:
			switch(C)
			{
				case DriverButton:
					DriverChange();
					break;
			}
			break;
		case DE_Change:
			switch(C)  
			{
				case ResolutionCombo:
				case ColorDepthCombo:
					SettingsChanged();
					break;
				case TextureDetailCombo:
					TextureDetailChanged();
					break;
				case SkinDetailCombo:
					SkinDetailChanged();
					break;
				case BrightnessSlider:
					BrightnessChanged();
					break;
				case UseSpecular:
					SpecularChanged();
					break;
				case DetailTextureRangeSlider:
					DetailTextureRangeChanged();
					break;
				case ParticleDensitySlider:
					ParticleDensityChanged();
					break;
			}
	}
	Super.Notify(C, E);
}

/*
 * Message Crackers
 */

function DriverChange()
{
	ParentWindow.ParentWindow.HideWindow();
	ConfirmDriver = MessageBox(ConfirmTitle, ConfirmDriverText, MB_YesNo, MR_No);
}

function SettingsChanged()
{
	local string NewSettings;

	if(bInitialized)
	{
		OldSettings = GetPlayerOwner().ConsoleCommand("GetCurrentRes")$"x"$GetPlayerOwner().ConsoleCommand("GetCurrentColorDepth");
		NewSettings = ResolutionCombo.GetValue()$"x"$ColorDepthCombo.GetValue2();

		if(NewSettings != OldSettings)
		{
			GetPlayerOwner().ConsoleCommand("SetRes "$NewSettings);
			LoadAvailableSettings();
			ParentWindow.ParentWindow.HideWindow();
			ConfirmSettings = MessageBox(ConfirmTitle, ConfirmSettingsText, MB_YesNo, MR_No, MR_None, 10);
		}
	}
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(W == ConfirmSettings)
	{
		ConfirmSettings = None;
		if(Result != MR_Yes)
		{
			GetPlayerOwner().ConsoleCommand("SetRes "$OldSettings);
			LoadAvailableSettings();			
			MessageBox(ConfirmTitle, ConfirmSettingsCancelText, MB_OK, MR_OK, MR_OK);
		}
		return;
	}
	else if(W == ConfirmDriver)
	{
		ConfirmDriver = None;
		if(Result == MR_Yes)
		{
			GetParent(class'UWindowFramedWindow').Close();
			Root.Console.CloseUWindow();
			GetPlayerOwner().ConsoleCommand("RELAUNCH -changevideo");
		}
	}
	ParentWindow.ParentWindow.ShowWindow();
}

function TextureDetailChanged()
{
	if(bInitialized)
	{
		TextureDetailSet();
		OldTextureDetail = TextureDetailCombo.GetSelectedIndex();
	}
}

function TextureDetailSet()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail "$TextureDetailCombo.GetValue2());
}

function SkinDetailChanged()
{
	local int D;
	if(bInitialized)
	{
		SkinDetailSet();
		OldSkinDetail = SkinDetailCombo.GetSelectedIndex();
	}
}

function SkinDetailSet()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager SkinDetail "$SkinDetailCombo.GetValue2());
}

function BrightnessChanged()
{
	if(bInitialized)
	{
		//GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$(BrightnessSlider.Value / 100.0));
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$(BrightnessSlider.Value / 100.0/2.0+0.25));
		GetPlayerOwner().ConsoleCommand("FLUSH");
	}
}

function SpecularChanged()
{
	if (UseSpecular.bChecked)
		GetPlayerOwner().ConsoleCommand("mesh_nospecular 0");
	else
		GetPlayerOwner().ConsoleCommand("mesh_nospecular 1");
}

function DetailTextureRangeChanged()
{
	if(bInitialized)
		GetPlayerOwner().ConsoleCommand("NearZ "$DetailTextureRangeSlider.Value);
}

function ParticleDensityChanged()
{
	if(bInitialized)
		GetPlayerOwner().ConsoleCommand("ParticleDensity "$(ParticleDensitySlider.Value)/100.0);
}

defaultproperties
{
     DriverText="Video Driver"
     DriverHelp="This is the current video driver.  Use the Change button to change video drivers."
     DriverButtonText="Change"
     DriverButtonHelp="Press this button to change your video driver."
     ResolutionText="Resolution"
     ResolutionHelp="Select a new screen resolution."
     ColorDepthText="Color Depth"
     ColorDepthHelp="Select a new color depth."
     BitsText="bit"
     TextureDetailText="World Texture Detail"
     TextureDetailHelp="Change the texture detail of world geometry.  Use a lower texture detail to improve game performance."
     Details(0)="High - Slower"
     Details(1)="Medium"
     Details(2)="Low - Faster"
     SkinDetailText="Object Texture Detail"
     SkinDetailHelp="Change the detail of player skins.  Use a lower skin detail to improve game performance."
     BrightnessText="Brightness"
     BrightnessHelp="Adjust display brightness."
     UseSpecText="Specular Highlights"
     UseSpecHelp="This options will enable specular highlights on meshes."
     DetailTextureRangeText="Detail Texture Range"
     DetailTextureRangeHelp="Use this control when detail textures become visible."
     ParticleDensityText="Particle Density"
     ParticleDensityHelp="This controls reduces the number of visible particles."
     ControlOffset=20.000000
     ConfirmTitle="Confirm Change"
     ConfirmSettingsText="Are you sure you wish to keep these new video settings?"
     ConfirmSettingsCancelText="Your previous video settings have been restored."
     ConfirmDriverText="This option will restart Unreal now, and enable you to change your video driver.  Do you want to do this?"
}
