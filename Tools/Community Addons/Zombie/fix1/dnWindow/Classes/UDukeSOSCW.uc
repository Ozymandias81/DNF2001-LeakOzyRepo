class UDukeSOSCW expands UDukePageWindow;

// Labels
var UDukeLabelControl MenuHeading;
var localized string MenuText;

// Mouse Speed
var UWindowHSliderControl MouseSlider;
var localized string MouseText;
var localized string MouseHelp;

// Window Hue
var UWindowHSliderControl GUIHueSlider;
var() localized string GUIHueText;
var() localized string GUIHueHelp;

// Window Sat
var UWindowHSliderControl GUISatSlider;
var() localized string GUISatText;
var() localized string GUISatHelp;

// Window Bright
var UWindowHSliderControl GUILuminSlider;
var() localized string GUILuminText;
var() localized string GUILuminHelp;

// Text Hue
var UWindowHSliderControl GUITextHueSlider;
var() localized string GUITextHueText;
var() localized string GUITextHueHelp;

// Text Sat
var UWindowHSliderControl GUITextSatSlider;
var() localized string GUITextSatText;
var() localized string GUITextSatHelp;

// Text Bright
var UWindowHSliderControl GUITextLuminSlider;
var() localized string GUITextLuminText;
var() localized string GUITextLuminHelp;

// HUD Opacity
var UWindowHSliderControl HUDOpacitySlider;
var localized string HUDOpacityText;
var localized string HUDOpacityHelp;

var bool bInitialized;
var float ControlOffset;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int LabelWidth, LabelLeft;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;
	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;
	LabelWidth = WinWidth - 100;
	LabelLeft = 20;
	
	// Menu Heading
	MenuHeading = UDukeLabelControl(CreateControl(class'UDukeLabelControl', LabelLeft-10, ControlOffset, WinWidth, 1));
	MenuHeading.SetText(MenuText);
	MenuHeading.SetFont(F_Bold);
	ControlOffset += 25;

	// GUI Mouse speed
	MouseSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	MouseSlider.bNoSlidingNotify = True;
	MouseSlider.SetRange(40, 500, 5);
	MouseSlider.SetText(MouseText);
	MouseSlider.SetHelpText(MouseHelp);
	MouseSlider.SetFont(F_Normal);
	ControlOffset += 25;

	CreateGUISliders(CenterWidth, CenterPos);

	// HUD Opacity
	HUDOpacitySlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	HUDOpacitySlider.bNoSlidingNotify = True;
	HUDOpacitySlider.SetRange(10, 100, 5);
	HUDOpacitySlider.SetText(HUDOpacityText);
	HUDOpacitySlider.SetHelpText(HUDOpacityHelp);
	HUDOpacitySlider.SetFont(F_Normal);
	ControlOffset += 25;

	LoadAvailableSettings();
}

function LoadAvailableSettings()
{
	MouseSlider.SetValue(Root.Console.MouseScale * 100);
	HUDOpacitySlider.SetValue(class'DukeHUD'.default.Opacity * 100);

	bInitialized = true;
}

function CreateGUISliders(int CenterWidth, int CenterPos)
{
	GUIHueSlider = UWindowHSliderControl(CreateControl(	class'UWindowHSliderControl', 
														CenterPos, ControlOffset, 
														CenterWidth, 1
										)
	);
	GUIHueSlider.SetRange(0, 255, 1);
	GUIHueSlider.SetText(GUIHueText);
	GUIHueSlider.SetHelpText(GUIHueHelp);
	GUIHueSlider.SetFont(F_Normal);
	ControlOffset += 15;

	GUISatSlider = UWindowHSliderControl(CreateControl(	class'UWindowHSliderControl', 
														CenterPos, ControlOffset, 
														CenterWidth, 1
										)
	);
	GUISatSlider.SetRange(0, 255, 1);
	GUISatSlider.SetText(GUISatText);
	GUISatSlider.SetHelpText(GUISatHelp);
	GUISatSlider.SetFont(F_Normal);
	ControlOffset += 15;
	
	GUILuminSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 
														CenterPos, ControlOffset, 
														CenterWidth, 1
										)
	);
	GUILuminSlider.SetRange(64, 254, 1);
	GUILuminSlider.SetText(GUILuminText);
	GUILuminSlider.SetHelpText(GUILuminHelp);
	GUILuminSlider.SetFont(F_Normal);
	ControlOffset += 25;
	
	//Text HSV sliders
	GUITextHueSlider = UWindowHSliderControl(CreateControl(	class'UWindowHSliderControl', 
														CenterPos, ControlOffset, 
														CenterWidth, 1
										)
	);
	GUITextHueSlider.SetRange(0, 255, 1);
	GUITextHueSlider.SetText(GUITextHueText);
	GUITextHueSlider.SetHelpText(GUITextHueHelp);
	GUITextHueSlider.SetFont(F_Normal);
	ControlOffset += 15;
	
	GUITextSatSlider = UWindowHSliderControl(CreateControl(	class'UWindowHSliderControl', 
														CenterPos, ControlOffset, 
														CenterWidth, 1
										)
	);
	GUITextSatSlider.SetRange(0, 255, 1);
	GUITextSatSlider.SetText(GUITextSatText);
	GUITextSatSlider.SetHelpText(GUITextSatHelp);
	GUITextSatSlider.SetFont(F_Normal);
	ControlOffset += 15;
	
	GUITextLuminSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 
														CenterPos, ControlOffset, 
														CenterWidth, 1
										)
	);
	GUITextLuminSlider.SetRange(64, 255, 1);
	GUITextLuminSlider.SetText(GUITextLuminText);
	GUITextLuminSlider.SetHelpText(GUITextLuminHelp);
	GUITextLuminSlider.SetFont(F_Normal);
	ControlOffset += 25;

	ResetGUISliderValues(false);	
}

function ResetGUISliderValues(optional bool bNotify)
{
	local color colorToConvert;
	local Vector vecHSVfromRGB;
	
	vecHSVfromRGB = LookAndFeel.vecGUIWindowsHSV;
	GUIHueSlider.SetValue(vecHSVfromRGB.X * 255, bNotify);		//Set Hue
	GUISatSlider.SetValue(vecHSVfromRGB.Y * 255, bNotify);		//Set Sat	
	GUILuminSlider.SetValue(vecHSVfromRGB.Z * 255, bNotify);	//Set Lum

	colorToConvert = LookAndFeel.DefaultTextColor;
	vecHSVfromRGB = VEC_RGBToHSV(colorToConvert);
	GUITextHueSlider.SetValue(vecHSVfromRGB.X * 255, bNotify);		//Set Hue
	GUITextSatSlider.SetValue(vecHSVfromRGB.Y * 255, bNotify);		//Set Sat
	GUITextLuminSlider.SetValue(vecHSVfromRGB.Z * 255, bNotify);		//Set Lum	
	
	LookAndFeel.SetTextColors(colorToConvert);		//Reset other text colors
}	

function SaveConfigs()
{
	LookAndFeel.SaveConfig();
	GetPlayerOwner().SaveConfig();
	class'DukeHUD'.static.StaticSaveConfig();
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

	MouseSlider.SetSize(CenterWidth, 1);
	MouseSlider.SliderWidth = 100;
	MouseSlider.WinLeft = CenterPos;

	GUIHueSlider.SetSize(CenterWidth, 1);
	GUIHueSlider.SliderWidth = 100;
	GUIHueSlider.WinLeft = CenterPos;	

	GUISatSlider.SetSize(CenterWidth, 1);
	GUISatSlider.SliderWidth = 100;
	GUISatSlider.WinLeft = CenterPos;

	GUILuminSlider.SetSize(CenterWidth, 1);
	GUILuminSlider.SliderWidth = 100;
	GUILuminSlider.WinLeft = CenterPos;	
	
	GUITextHueSlider.SetSize(CenterWidth, 1);
	GUITextHueSlider.SliderWidth = 100;
	GUITextHueSlider.WinLeft = CenterPos;	

	GUITextSatSlider.SetSize(CenterWidth, 1);
	GUITextSatSlider.SliderWidth = 100;
	GUITextSatSlider.WinLeft = CenterPos;

	GUITextLuminSlider.SetSize(CenterWidth, 1);
	GUITextLuminSlider.SliderWidth = 100;
	GUITextLuminSlider.WinLeft = CenterPos;	

	HUDOpacitySlider.SetSize(CenterWidth, 1);
	HUDOpacitySlider.SliderWidth = 100;
	HUDOpacitySlider.WinLeft = CenterPos;
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)  
	{
		case DE_Change:
			switch(C)  
			{
				case MouseSlider:
					MouseChanged();
					break;
				case GUIHueSlider:
				case GUISatSlider:
				case GUILuminSlider:
					ChangeGUIToCustomColor();
					break;
				case GUITextHueSlider:
				case GUITextSatSlider:
				case GUITextLuminSlider:
					ChangeGUITextToCustomColor();
					break;
				case HUDOpacitySlider:
					HUDOpacityChanged();
					break;
			}
	}
	Super.Notify(C, E);
}

function ChangeGUIToCustomColor()
{	
	LookAndFeel.vecGUIWindowsHSV.X = GUIHueSlider.GetValue() / 255.0;
	LookAndFeel.vecGUIWindowsHSV.Y = GUISatSlider.GetValue() / 255.0;
	LookAndFeel.vecGUIWindowsHSV.Z = GUILuminSlider.GetValue() / 255.0;		
	LookAndFeel.colorGUIWindows = VEC_HSVToRGB(LookAndFeel.vecGUIWindowsHSV);
	class'DukeHUD'.default.HUDColor = VEC_HSVToRGB(LookAndFeel.vecGUIWindowsHSV);
}

function ChangeGUITextToCustomColor()
{
	local Vector vecHSV;

	vecHSV.X = GUITextHueSlider.GetValue() / 255.0;
	vecHSV.Y = GUITextSatSlider.GetValue() / 255.0;
	vecHSV.Z = GUITextLuminSlider.GetValue() / 255.0;		
	LookAndFeel.SetTextColors( VEC_HSVToRGB(vecHSV) );
	class'DukeHUD'.default.TextColor = VEC_HSVToRGB(vecHSV);
}

function HUDOpacityChanged()
{
	if (bInitialized)
	{
		class'DukeHUD'.default.Opacity = HUDOpacitySlider.Value / 100;
		if (GetPlayerOwner().MyHUD.IsA('DukeHUD'))
			DukeHUD(GetPlayerOwner().MyHUD).Opacity = HUDOpacitySlider.Value / 100;
	}
}

function MouseChanged()
{
	if (bInitialized)
	{
		Root.Console.MouseScale = (MouseSlider.Value / 100);
		Root.Console.SaveConfig();
	}
}

defaultproperties
{
     MenuText="Menu / HUD"
     MouseText="GUI Mouse Speed"
     MouseHelp="Adjust the speed of the mouse in the User Interface."
     GUIHueText="Window Hue"
     GUIHueHelp="Use the Window Hue slider to select a custom GUI color."
     GUISatText="Window Sat"
     GUISatHelp="Use the Window Saturation slider to select a custom GUI saturation of color."
     GUILuminText="Window Light"
     GUILuminHelp="Use the Window Luminance slider to select a custom GUI brightness."
     GUITextHueText="Text Hue"
     GUITextHueHelp="Use the Text Hue slider to select a custom GUI text color."
     GUITextSatText="Text Sat"
     GUITextSatHelp="Use the Text Saturation slider to select a custom GUI text saturation of color."
     GUITextLuminText="Text Light"
     GUITextLuminHelp="Use the Text Luminance slider to select a custom GUI text brightness."
     HUDOpacityText="HUD Opacity"
     HUDOpacityHelp="Adjust this to reduce the amount of transparency on the HUD."
     ControlOffset=20.000000
}
