/*-----------------------------------------------------------------------------
	UDukeVideoCW
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
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
var UWindowLabelControl ResolutionLabel;
var UWindowComboControl ResolutionCombo;
var localized string ResolutionText;
var localized string ResolutionHelp;
var string OldSettings;

// Color Depth
var UWindowLabelControl ColorDepthLabel;
var UWindowComboControl ColorDepthCombo;
var localized string ColorDepthText;
var localized string ColorDepthHelp;
var localized string BitsText;

// Texture Detail
var UWindowLabelControl TextureDetailLabel;
var UWindowComboControl TextureDetailCombo;
var localized string TextureDetailText;
var localized string TextureDetailHelp;
var localized string Details[3];
var int OldTextureDetail;

// Skin Detail
var UWindowLabelControl SkinDetailLabel;
var UWindowComboControl SkinDetailCombo;
var localized string SkinDetailText;
var localized string SkinDetailHelp;
var int OldSkinDetail;

// Brightness
var UWindowLabelControl BrightnessLabel;
var UWindowHSliderControl BrightnessSlider;
var localized string BrightnessText;
var localized string BrightnessHelp;

// Shadow Detail
var UWindowLabelControl ShadowDetailLabel;
var UWindowComboControl ShadowDetailCombo;
var localized string ShadowDetailText;
var localized string ShadowDetailHelp;
var localized string ShadowDetails[4];
var int OldShadowDetail;

// Specular
var UWindowLabelControl SpecularLabel;
var UWindowCheckbox UseSpecular;
var localized string UseSpecText;
var localized string UseSpecHelp;

// Detail Texture Range
var UWindowLabelControl DetailTextureRangeLabel;
var UWindowHSliderControl DetailTextureRangeSlider;
var localized string DetailTextureRangeText;
var localized string DetailTextureRangeHelp;

// Particle LOD:

// Particle Density:
var UWindowLabelControl ParticleDensityLabel;
var UWindowHSliderControl ParticleDensitySlider;
var localized string ParticleDensityText;
var localized string ParticleDensityHelp;

var float ControlOffset;
var int ResizeFrames;

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
	DriverLabel.SetFont(F_Normal);
	DriverLabel.Align = TA_Right;

	DriverDesc = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlRight, ControlOffset, ControlWidth, 1));
	DriverDesc.SetText(VideoDriverDesc);
	DriverDesc.SetFont(F_Normal);

	DriverButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ControlRight, ControlOffset, 48, 16));
	DriverButton.SetText(DriverButtonText);
	DriverButton.SetFont(F_Normal);
	DriverButton.SetHelpText(DriverButtonHelp);

	// Resolution
	ResolutionLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ResolutionLabel.SetText(ResolutionText);
	ResolutionLabel.SetFont(F_Normal);
	ResolutionLabel.Align = TA_Right;

	ResolutionCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ResolutionCombo.SetHelpText(ResolutionHelp);
	ResolutionCombo.SetFont( F_Normal );
	ResolutionCombo.SetEditable( false );
	ResolutionCombo.Align = TA_Right;

	// Color Depth
	ColorDepthLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ColorDepthLabel.SetText(ColorDepthText);
	ColorDepthLabel.SetFont(F_Normal);
	ColorDepthLabel.Align = TA_Right;

	ColorDepthCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ColorDepthCombo.SetHelpText(ColorDepthHelp);
	ColorDepthCombo.SetFont(F_Normal);
	ColorDepthCombo.SetEditable(False);
	ColorDepthCombo.Align = TA_Right;

	// Texture Detail
	TextureDetailLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	TextureDetailLabel.SetText(TextureDetailText);
	TextureDetailLabel.SetFont(F_Normal);
	TextureDetailLabel.Align = TA_Right;

	TextureDetailCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	TextureDetailCombo.SetHelpText(TextureDetailHelp);
	TextureDetailCombo.SetFont(F_Normal);
	TextureDetailCombo.SetEditable(False);
	TextureDetailCombo.Align = TA_Right;

	// The display names are localized.  These strings match the enums in UnCamMgr.cpp.
	TextureDetailCombo.AddItem(Details[0], "High");
	TextureDetailCombo.AddItem(Details[1], "Medium");
	TextureDetailCombo.AddItem(Details[2], "Low");

	// Skin Detail
	SkinDetailLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	SkinDetailLabel.SetText(SkinDetailText);
	SkinDetailLabel.SetFont(F_Normal);
	SkinDetailLabel.Align = TA_Right;

	SkinDetailCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	SkinDetailCombo.SetHelpText(SkinDetailHelp);
	SkinDetailCombo.SetFont(F_Normal);
	SkinDetailCombo.SetEditable(False);
	SkinDetailCombo.AddItem(Details[0], "High");
	SkinDetailCombo.AddItem(Details[1], "Medium");
	SkinDetailCombo.AddItem(Details[2], "Low");
	SkinDetailCombo.Align = TA_Right;

	// Shadow detail
	ShadowDetailLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ShadowDetailLabel.SetText(ShadowDetailText);
	ShadowDetailLabel.SetFont(F_Normal);
	ShadowDetailLabel.Align = TA_Right;

	ShadowDetailCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ShadowDetailCombo.SetHelpText(ShadowDetailHelp);
	ShadowDetailCombo.SetFont(F_Normal);
	ShadowDetailCombo.SetEditable(False);
	ShadowDetailCombo.AddItem(ShadowDetails[0], "0");
	ShadowDetailCombo.AddItem(ShadowDetails[1], "1");
	ShadowDetailCombo.AddItem(ShadowDetails[2], "2");
	ShadowDetailCombo.AddItem(ShadowDetails[3], "3");
	ShadowDetailCombo.Align = TA_Right;

	// DetailTextureRange
	DetailTextureRangeLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	DetailTextureRangeLabel.SetText(DetailTextureRangeText);
	DetailTextureRangeLabel.SetFont(F_Normal);
	DetailTextureRangeLabel.Align = TA_Right;

	DetailTextureRangeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	DetailTextureRangeSlider.bNoSlidingNotify = True;
	DetailTextureRangeSlider.SetRange(0, 1000, 50);
	DetailTextureRangeSlider.SetHelpText(DetailTextureRangeHelp);
	DetailTextureRangeSlider.SetFont(F_Normal);
	DetailTextureRangeSlider.Align = TA_Right;

	// ParticleDensity
	ParticleDensityLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ParticleDensityLabel.SetText(ParticleDensityText);
	ParticleDensityLabel.SetFont(F_Normal);
	ParticleDensityLabel.Align = TA_Right;

	ParticleDensitySlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	ParticleDensitySlider.bNoSlidingNotify = True;
	ParticleDensitySlider.SetRange(0, 100, 100);
	ParticleDensitySlider.SetHelpText(ParticleDensityHelp);
	ParticleDensitySlider.SetFont(F_Normal);
	ParticleDensitySlider.Align = TA_Right;

	// Brightness
	BrightnessLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	BrightnessLabel.SetText(BrightnessText);
	BrightnessLabel.SetFont(F_Normal);
	BrightnessLabel.Align = TA_Right;

	BrightnessSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	BrightnessSlider.bNoSlidingNotify = True;
	BrightnessSlider.SetRange(0, 100, 50);
	BrightnessSlider.SetHelpText(BrightnessHelp);
	BrightnessSlider.SetFont(F_Normal);
	BrightnessSlider.Align = TA_Right;

	// Specular
	SpecularLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', ControlLeft, ControlOffset, ControlWidth, 1));
	SpecularLabel.SetText(UseSpecText);
	SpecularLabel.SetFont(F_Normal);
	SpecularLabel.Align = TA_Right;

	UseSpecular = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	UseSpecular.bChecked = bool(GetPlayerOwner().ConsoleCommand("GetSpecular"));
	UseSpecular.SetHelpText(UseSpecHelp);
	UseSpecular.SetFont(F_Normal);
	UseSpecular.Align = TA_Right;

	LoadAvailableSettings();
	ResizeFrames = 3;
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

	// Shadow detail
	OldShadowDetail = Max(0, ShadowDetailCombo.FindItemIndex2(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.ViewportManager ShadowDetail")));
	ShadowDetailCombo.SetSelectedIndex(OldShadowDetail);

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

function BeforePaint( Canvas C, float X, float Y )
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

	DriverLabel.AutoSize( C );
	DriverLabel.WinLeft = CColLeft - DriverLabel.WinWidth;

	DriverDesc.AutoSize( C );
	DriverDesc.WinLeft = CColRight;

	DriverButton.AutoSize( C );
	DriverButton.WinLeft = CColRight;
	DriverButton.WinTop = DriverLabel.WinTop + DriverLabel.WinHeight + ControlOffset/2;

	ResolutionCombo.SetSize( 200, ResolutionCombo.WinHeight );
	ResolutionCombo.WinLeft = CColRight;
	ResolutionCombo.WinTop = DriverButton.WinTop + DriverButton.WinHeight + ControlOffset;

	ResolutionLabel.AutoSize( C );
	ResolutionLabel.WinLeft = CColLeft - ResolutionLabel.WinWidth;
	ResolutionLabel.WinTop = ResolutionCombo.WinTop + 8;

	ColorDepthCombo.SetSize( 200, ColorDepthCombo.WinHeight );
	ColorDepthCombo.WinLeft = CColRight;
	ColorDepthCombo.WinTop = ResolutionCombo.WinTop + ResolutionCombo.WinHeight + ControlOffset;

	ColorDepthLabel.AutoSize( C );
	ColorDepthLabel.WinLeft = CColLeft - ColorDepthLabel.WinWidth;
	ColorDepthLabel.WinTop = ColorDepthCombo.WinTop + 8;

	TextureDetailCombo.SetSize( 200, TextureDetailCombo.WinHeight );
	TextureDetailCombo.WinLeft = CColRight;
	TextureDetailCombo.WinTop = ColorDepthCombo.WinTop + ColorDepthCombo.WinHeight + ControlOffset;

	TextureDetailLabel.AutoSize( C );
	TextureDetailLabel.WinLeft = CColLeft - TextureDetailLabel.WinWidth;
	TextureDetailLabel.WinTop = TextureDetailCombo.WinTop + 8;

	SkinDetailCombo.SetSize( 200, SkinDetailCombo.WinHeight );
	SkinDetailCombo.WinLeft = CColRight;
	SkinDetailCombo.WinTop = TextureDetailCombo.WinTop + TextureDetailCombo.WinHeight + ControlOffset;

	SkinDetailLabel.AutoSize( C );
	SkinDetailLabel.WinLeft = CColLeft - SkinDetailLabel.WinWidth;
	SkinDetailLabel.WinTop = SkinDetailCombo.WinTop + 8;

	ShadowDetailCombo.SetSize( 200, ShadowDetailCombo.WinHeight );
	ShadowDetailCombo.WinLeft = CColRight;
	ShadowDetailCombo.WinTop = SkinDetailCombo.WinTop + SkinDetailCombo.WinHeight + ControlOffset;

	ShadowDetailLabel.AutoSize( C );
	ShadowDetailLabel.WinLeft = CColLeft - ShadowDetailLabel.WinWidth;
	ShadowDetailLabel.WinTop = ShadowDetailCombo.WinTop + 8;

	BrightnessSlider.SetSize( CenterWidth, BrightnessSlider.WinHeight );
	BrightnessSlider.SliderWidth = 150;
	BrightnessSlider.WinLeft = CColRight;
	BrightnessSlider.WinTop = ShadowDetailCombo.WinTop + ShadowDetailCombo.WinHeight + ControlOffset;

	BrightnessLabel.AutoSize( C );
	BrightnessLabel.WinLeft = CColLeft - BrightnessLabel.WinWidth;
	BrightnessLabel.WinTop = BrightnessSlider.WinTop + 4;

	DetailTextureRangeSlider.SetSize( CenterWidth, DetailTextureRangeSlider.WinHeight );
	DetailTextureRangeSlider.SliderWidth = 150;
	DetailTextureRangeSlider.WinLeft = CColRight;
	DetailTextureRangeSlider.WinTop = BrightnessSlider.WinTop + BrightnessSlider.WinHeight + ControlOffset;

	DetailTextureRangeLabel.AutoSize( C );
	DetailTextureRangeLabel.WinLeft = CColLeft - DetailTextureRangeLabel.WinWidth;
	DetailTextureRangeLabel.WinTop = DetailTextureRangeSlider.WinTop + 4;

	ParticleDensitySlider.SetSize( CenterWidth, ParticleDensitySlider.WinHeight );
	ParticleDensitySlider.SliderWidth = 150;
	ParticleDensitySlider.WinLeft = CColRight;
	ParticleDensitySlider.WinTop = DetailTextureRangeSlider.WinTop + DetailTextureRangeSlider.WinHeight + ControlOffset;

	ParticleDensityLabel.AutoSize( C );
	ParticleDensityLabel.WinLeft = CColLeft - ParticleDensityLabel.WinWidth;
	ParticleDensityLabel.WinTop = ParticleDensitySlider.WinTop + 4;

	UseSpecular.SetSize( CenterWidth-90+16, UseSpecular.WinHeight );
	UseSpecular.WinLeft = CColRight;
	UseSpecular.WinTop = ParticleDensitySlider.WinTop + ParticleDensitySlider.WinHeight + ControlOffset + UseSpecular.GetHeightAdjust();

	SpecularLabel.AutoSize( C );
	SpecularLabel.WinLeft = CColLeft - SpecularLabel.WinWidth;
	SpecularLabel.WinTop = UseSpecular.WinTop + 10;

	DesiredWidth = 220;
	DesiredHeight = SpecularLabel.WinTop + SpecularLabel.WinHeight + ControlOffset;
}

function Resized()
{
	ResizeFrames = 3;

	Super.Resized();
}

function Notify( UWindowDialogControl C, byte E )
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
				case ShadowDetailCombo:
					ShadowDetailChanged();
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

	Super.Notify( C, E );
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
			ConfirmSettings = MessageBox( ConfirmTitle, ConfirmSettingsText, MB_YesNo, MR_No, MR_None, 10 );
			//CloseFromEscape(27);
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
			//CloseFromEscape(27);

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

function ShadowDetailChanged()
{
	if(bInitialized)
	{
		ShadowDetailSet();
		OldShadowDetail = ShadowDetailCombo.GetSelectedIndex();
	}
}

function ShadowDetailSet()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager ShadowDetail "$ShadowDetailCombo.GetSelectedIndex());
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
     DriverHelp="This is the current video driver."
     DriverButtonText="Change"
     DriverButtonHelp="Press this button to change your video driver."
     ResolutionText="Resolution"
     ResolutionHelp="Select a new screen resolution."
     ColorDepthText="Color Depth"
     ColorDepthHelp="Select a new color depth."
     BitsText="bit"
     TextureDetailText="World Texture Detail"
     TextureDetailHelp="Set the texture detail of world geometry.  Lower is faster."
     Details(0)="High - Slower"
     Details(1)="Medium"
     Details(2)="Low - Faster"
     SkinDetailText="Object Texture Detail"
     SkinDetailHelp="Change the detail of player skins.  Lower is faster."
     BrightnessText="Brightness"
     BrightnessHelp="Adjust display brightness."
     ControlOffset=10.0
     ConfirmTitle="Confirm Change "
     ConfirmSettingsText="Are you sure you wish to keep these new video settings?"
     ConfirmSettingsCancelText="Your previous video settings have been restored."
     ConfirmDriverText="This option will restart Duke Nukem now, and enable you to change your video driver.  Do you want to do this?"
	 UseSpecText="Specular Highlights"
	 UseSpecHelp="Enable specular highlights on meshes."
	 DetailTextureRangeText="Detail Texture Range"
	 DetailTextureRangeHelp="Set the distance that detail textures become visible."
	 ParticleDensityText="Particle Density"
	 ParticleDensityHelp="Set the percentage of visible particles in special effects."

     ShadowDetailText="Shadow Detail"
     ShadowDetailHelp="Change the quality of shadows.  Lower is faster."
     ShadowDetails(0)="Off"
     ShadowDetails(1)="Low - Faster"
     ShadowDetails(2)="Med"
     ShadowDetails(3)="High - Slower"
}
