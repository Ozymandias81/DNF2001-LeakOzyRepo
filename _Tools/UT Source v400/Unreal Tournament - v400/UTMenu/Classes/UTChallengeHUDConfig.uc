class UTChallengeHUDConfig extends UMenuPageWindow;

#exec TEXTURE IMPORT NAME=HudPreview FILE=TEXTURES\HudPreview.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=HudPreviewBG FILE=TEXTURES\HudPreviewBG.PCX GROUP="Icons" MIPS=OFF FLAGS=2

var UWindowCheckbox ShowHUDCheck;
var localized string ShowHUDText;
var localized string ShowHUDHelp;

var UWindowCheckbox ShowWeaponsCheck;
var localized string ShowWeaponsText;
var localized string ShowWeaponsHelp;

var UWindowCheckbox ShowStatusCheck;
var localized string ShowStatusText;
var localized string ShowStatusHelp;

var UWindowCheckbox ShowAmmoCheck;
var localized string ShowAmmoText;
var localized string ShowAmmoHelp;

var UWindowCheckbox ShowTeamInfoCheck;
var localized string ShowTeamInfoText;
var localized string ShowTeamInfoHelp;

var UWindowCheckbox ShowFacesCheck;
var localized string ShowFacesText;
var localized string ShowFacesHelp;

var UWindowCheckbox ShowFragsCheck;
var localized string ShowFragsText;
var localized string ShowFragsHelp;

var UWindowCheckbox UseTeamColorCheck;
var localized string UseTeamColorText;
var localized string UseTeamColorHelp;

// HUD Color
var UWindowComboControl HUDColorCombo;
var localized string HUDColorText;
var localized string HUDColorHelp;
var localized string HUDColorNames[20];
var localized string HUDColorValues[20];

var UWindowHSliderControl HUDRSlider;
var localized string HUDRText;
var localized string HUDRHelp;

var UWindowHSliderControl HUDGSlider;
var localized string HUDGText;
var localized string HUDGHelp;

var UWindowHSliderControl HUDBSlider;
var localized string HUDBText;
var localized string HUDBHelp;

// Crosshair Color
var UWindowComboControl CrosshairColorCombo;
var localized string CrosshairColorText;
var localized string CrosshairColorHelp;

var UWindowHSliderControl CrosshairRSlider;
var localized string CrosshairRText;
var localized string CrosshairRHelp;

var UWindowHSliderControl CrosshairGSlider;
var localized string CrosshairGText;
var localized string CrosshairGHelp;

var UWindowHSliderControl CrosshairBSlider;
var localized string CrosshairBText;
var localized string CrosshairBHelp;

var UWindowHSliderControl OpacitySlider;
var localized string OpacityText;
var localized string OpacityHelp;

var UWindowHSliderControl HUDScaleSlider;
var localized string HUDScaleText;
var localized string HUDScaleHelp;

var UWindowHSliderControl WeaponScaleSlider;
var localized string WeaponScaleText;
var localized string WeaponScaleHelp;

var UWindowHSliderControl StatusScaleSlider;
var localized string StatusScaleText;
var localized string StatusScaleHelp;

// Crosshair
var UWindowHSliderControl CrosshairSlider;
var localized string CrosshairText;
var localized string CrosshairHelp;

var UWindowSmallButton DefaultsButton;
var localized string DefaultsText;
var localized string DefaultsHelp;

var bool bInitialized;
var int ControlOffset;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int I, S;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	DesiredWidth = 220;

	// Defaults Button
	DefaultsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 30, ControlOffset, 48, 16));
	DefaultsButton.SetText(DefaultsText);
	DefaultsButton.SetFont(F_Normal);
	DefaultsButton.SetHelpText(DefaultsHelp);
	ControlOffset += 25;

	ShowHUDCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	ShowHUDCheck.SetText(ShowHUDText);
	ShowHUDCheck.SetHelpText(ShowHUDHelp);
	ShowHUDCheck.SetFont(F_Normal);
	ShowHUDCheck.Align = TA_Left;
	ControlOffset += 20;

	ShowWeaponsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	ShowWeaponsCheck.SetText(ShowWeaponsText);
	ShowWeaponsCheck.SetHelpText(ShowWeaponsHelp);
	ShowWeaponsCheck.SetFont(F_Normal);
	ShowWeaponsCheck.Align = TA_Left;
	ControlOffset += 20;

	ShowStatusCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	ShowStatusCheck.SetText(ShowStatusText);
	ShowStatusCheck.SetHelpText(ShowStatusHelp);
	ShowStatusCheck.SetFont(F_Normal);
	ShowStatusCheck.Align = TA_Left;
	ControlOffset += 20;

	ShowAmmoCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	ShowAmmoCheck.SetText(ShowAmmoText);
	ShowAmmoCheck.SetHelpText(ShowAmmoHelp);
	ShowAmmoCheck.SetFont(F_Normal);
	ShowAmmoCheck.Align = TA_Left;
	ControlOffset += 20;

	ShowTeamInfoCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	ShowTeamInfoCheck.SetText(ShowTeamInfoText);
	ShowTeamInfoCheck.SetHelpText(ShowTeamInfoHelp);
	ShowTeamInfoCheck.SetFont(F_Normal);
	ShowTeamInfoCheck.Align = TA_Left;
	ControlOffset += 20;

	ShowFragsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	ShowFragsCheck.SetText(ShowFragsText);
	ShowFragsCheck.SetHelpText(ShowFragsHelp);
	ShowFragsCheck.SetFont(F_Normal);
	ShowFragsCheck.Align = TA_Left;
	ControlOffset += 20;

	ShowFacesCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	ShowFacesCheck.SetText(ShowFacesText);
	ShowFacesCheck.SetHelpText(ShowFacesHelp);
	ShowFacesCheck.SetFont(F_Normal);
	ShowFacesCheck.Align = TA_Left;
	ControlOffset += 20;

	UseTeamColorCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	UseTeamColorCheck.SetText(UseTeamColorText);
	UseTeamColorCheck.SetHelpText(UseTeamColorHelp);
	UseTeamColorCheck.SetFont(F_Normal);
	UseTeamColorCheck.Align = TA_Left;
	ControlOffset += 20;

	HUDColorCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	HUDColorCombo.SetText(HUDColorText);
	HUDColorCombo.SetHelpText(HUDColorHelp);
	HUDColorCombo.SetFont(F_Normal);
	HUDColorCombo.SetEditable(False);
	HUDColorCombo.Align = TA_Left;
	ControlOffset += 20;
	for(i=0;i<20 && HUDColorNames[i]!="";i++)
		HUDColorCombo.AddItem(HUDColorNames[i], HUDColorValues[i]);

	HUDRSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	HUDRSlider.SetRange(0, 16, 1);
	HUDRSlider.SetText(HUDRText);
	HUDRSlider.SetHelpText(HUDRHelp);
	HUDRSlider.SetFont(F_Normal);
	ControlOffset += 20;

	HUDGSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	HUDGSlider.SetRange(0, 16, 1);
	HUDGSlider.SetText(HUDGText);
	HUDGSlider.SetHelpText(HUDGHelp);
	HUDGSlider.SetFont(F_Normal);
	ControlOffset += 20;

	HUDBSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	HUDBSlider.SetRange(0, 16, 1);
	HUDBSlider.SetText(HUDBText);
	HUDBSlider.SetHelpText(HUDBHelp);
	HUDBSlider.SetFont(F_Normal);
	ControlOffset += 20;

	OpacitySlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	OpacitySlider.SetRange(1, 16, 1);
	OpacitySlider.SetText(OpacityText);
	OpacitySlider.SetHelpText(OpacityHelp);
	OpacitySlider.SetFont(F_Normal);
	ControlOffset += 105;

	HUDScaleSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	HUDScaleSlider.SetRange(1, 5, 1);
	HUDScaleSlider.SetText(HUDScaleText);
	HUDScaleSlider.SetHelpText(HUDScaleHelp);
	HUDScaleSlider.SetFont(F_Normal);
	ControlOffset += 25;

	WeaponScaleSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	WeaponScaleSlider.SetRange(1, 5, 1);
	WeaponScaleSlider.SetText(WeaponScaleText);
	WeaponScaleSlider.SetHelpText(WeaponScaleHelp);
	WeaponScaleSlider.SetFont(F_Normal);
	ControlOffset += 25;

	StatusScaleSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	StatusScaleSlider.SetRange(5, 15, 1);
	StatusScaleSlider.SetText(StatusScaleText);
	StatusScaleSlider.SetHelpText(StatusScaleHelp);
	StatusScaleSlider.SetFont(F_Normal);
	ControlOffset += 20;

	CrosshairColorCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	CrosshairColorCombo.SetText(CrosshairColorText);
	CrosshairColorCombo.SetHelpText(CrosshairColorHelp);
	CrosshairColorCombo.SetFont(F_Normal);
	CrosshairColorCombo.SetEditable(False);
	CrosshairColorCombo.Align = TA_Left;
	ControlOffset += 20;
	for(i=0;i<20 && HUDColorNames[i]!="";i++)
		CrosshairColorCombo.AddItem(HUDColorNames[i], HUDColorValues[i]);

	CrosshairRSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	CrosshairRSlider.SetRange(0, 16, 1);
	CrosshairRSlider.SetText(CrosshairRText);
	CrosshairRSlider.SetHelpText(CrosshairRHelp);
	CrosshairRSlider.SetFont(F_Normal);
	ControlOffset += 20;

	CrosshairGSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	CrosshairGSlider.SetRange(0, 16, 1);
	CrosshairGSlider.SetText(CrosshairGText);
	CrosshairGSlider.SetHelpText(CrosshairGHelp);
	CrosshairGSlider.SetFont(F_Normal);
	ControlOffset += 20;

	CrosshairBSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	CrosshairBSlider.SetRange(0, 16, 1);
	CrosshairBSlider.SetText(CrosshairBText);
	CrosshairBSlider.SetHelpText(CrosshairBHelp);
	CrosshairBSlider.SetFont(F_Normal);
	ControlOffset += 20;

	CrosshairSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	CrosshairSlider.SetText(CrosshairText);
	CrosshairSlider.SetHelpText(CrosshairHelp);
	CrosshairSlider.SetFont(F_Normal);
	ControlOffset += 30;

	DesiredHeight = ControlOffset + 70;
	
	LoadCurrentValues();
}

function LoadCurrentValues()
{ 
	local int i;
	local ChallengeHUD H;

	bInitialized = False;

	H = ChallengeHUD(GetPlayerOwner().MyHUD);

	ShowHUDCheck.bChecked = !H.bHideHUD;
	ShowWeaponsCheck.bChecked = !H.bHideAllWeapons;
	ShowStatusCheck.bChecked = !H.bHideStatus;
	ShowAmmoCheck.bChecked = !H.bHideAmmo;
	ShowTeamInfoCheck.bChecked = !H.bHideTeamInfo;
	ShowFragsCheck.bChecked = !H.bHideFrags;
	ShowFacesCheck.bChecked = !H.bHideFaces;
	UseTeamColorCheck.bChecked = H.bUseTeamColor;
	OpacitySlider.SetValue(H.Opacity);
	HUDScaleSlider.SetValue(H.HUDScale*5);
	WeaponScaleSlider.SetValue(H.WeaponScale*5);
	StatusScaleSlider.SetValue(H.StatusScale*10);
	CrosshairSlider.SetRange(0, H.CrosshairCount - 1, 1);
	CrosshairSlider.SetValue(GetPlayerOwner().myHUD.Crosshair);
	i = HUDColorCombo.FindItemIndex2(H.FavoriteHUDColor.R$","$H.FavoriteHUDColor.G$","$H.FavoriteHUDColor.B, False);
	if(i == -1)
		HUDColorCombo.SetSelectedIndex(Max(HUDColorCombo.FindItemIndex2("cust", False), 0));
	else
		HUDColorCombo.SetSelectedIndex(i);

	HUDRSlider.SetValue(H.FavoriteHUDColor.R);
	HUDGSlider.SetValue(H.FavoriteHUDColor.G);
	HUDBSlider.SetValue(H.FavoriteHUDColor.B);

	i = CrosshairColorCombo.FindItemIndex2(H.CrosshairColor.R$","$H.CrosshairColor.G$","$H.CrosshairColor.B, False);
	if(i == -1)
		CrosshairColorCombo.SetSelectedIndex(Max(CrosshairColorCombo.FindItemIndex2("cust", False), 0));
	else
		CrosshairColorCombo.SetSelectedIndex(i);

	CrosshairRSlider.SetValue(H.CrosshairColor.R);
	CrosshairGSlider.SetValue(H.CrosshairColor.G);
	CrosshairBSlider.SetValue(H.CrosshairColor.B);

	ShowWeaponsCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowStatusCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowAmmoCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowTeamInfoCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowFragsCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowFacesCheck.bDisabled = !ShowHUDCheck.bChecked;
	UseTeamColorCheck.bDisabled = !ShowHUDCheck.bChecked;

	bInitialized = True;
}

function LoadDefaultValues()
{
	local ChallengeHUD H;

	H = ChallengeHUD(GetPlayerOwner().MyHUD);

	H.Crosshair = class'HUD'.default.Crosshair;
	H.bHideHUD = class'ChallengeHUD'.default.bHideHUD;
	H.bHideAllWeapons = class'ChallengeHUD'.default.bHideAllWeapons;
	H.bHideStatus = class'ChallengeHUD'.default.bHideStatus;
	H.bHideAmmo = class'ChallengeHUD'.default.bHideAmmo;
	H.bHideTeamInfo = class'ChallengeHUD'.default.bHideTeamInfo;
	H.bHideFrags = class'ChallengeHUD'.default.bHideFrags;
	H.bHideFaces = class'ChallengeHUD'.default.bHideFaces;
	H.bUseTeamColor = class'ChallengeHUD'.default.bUseTeamColor;
	H.Opacity = class'ChallengeHUD'.default.Opacity;
	H.HUDScale = class'ChallengeHUD'.default.HUDScale;
	H.WeaponScale = class'ChallengeHUD'.default.WeaponScale;
	H.StatusScale = class'ChallengeHUD'.default.StatusScale;
	H.FavoriteHUDColor.R = class'ChallengeHUD'.default.FavoriteHUDColor.R;
	H.FavoriteHUDColor.G = class'ChallengeHUD'.default.FavoriteHUDColor.G;
	H.FavoriteHUDColor.B = class'ChallengeHUD'.default.FavoriteHUDColor.B; 
	H.CrosshairColor.R = class'ChallengeHUD'.default.CrosshairColor.R;
	H.CrosshairColor.G = class'ChallengeHUD'.default.CrosshairColor.G;
	H.CrosshairColor.B = class'ChallengeHUD'.default.CrosshairColor.B; 
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

	DefaultsButton.AutoWidth(C);
	DefaultsButton.WinLeft = CenterPos + CenterWidth - DefaultsButton.WinWidth;

	ShowHUDCheck.SetSize(CenterWidth, 1);
	ShowHUDCheck.WinLeft = CenterPos;
	ShowWeaponsCheck.SetSize(CenterWidth, 1);
	ShowWeaponsCheck.WinLeft = CenterPos;
	ShowStatusCheck.SetSize(CenterWidth, 1);
	ShowStatusCheck.WinLeft = CenterPos;
	ShowAmmoCheck.SetSize(CenterWidth, 1);
	ShowAmmoCheck.WinLeft = CenterPos;
	ShowTeamInfoCheck.SetSize(CenterWidth, 1);
	ShowTeamInfoCheck.WinLeft = CenterPos;
	ShowFragsCheck.SetSize(CenterWidth, 1);
	ShowFragsCheck.WinLeft = CenterPos;
	ShowFacesCheck.SetSize(CenterWidth, 1);
	ShowFacesCheck.WinLeft = CenterPos;
	OpacitySlider.SetSize(CenterWidth, 1);
	OpacitySlider.SliderWidth = 90;
	OpacitySlider.WinLeft = CenterPos;
	UseTeamColorCheck.SetSize(CenterWidth, 1);
	UseTeamColorCheck.WinLeft = CenterPos;
	HUDColorCombo.SetSize(CenterWidth, 1);
	HUDColorCombo.WinLeft = CenterPos;
	HUDColorCombo.EditBoxWidth = 90;
	HUDRSlider.SetSize(CenterWidth, 1);
	HUDRSlider.SliderWidth = 90;
	HUDRSlider.WinLeft = CenterPos;
	HUDGSlider.SetSize(CenterWidth, 1);
	HUDGSlider.SliderWidth = 90;
	HUDGSlider.WinLeft = CenterPos;
	HUDBSlider.SetSize(CenterWidth, 1);
	HUDBSlider.SliderWidth = 90;
	HUDBSlider.WinLeft = CenterPos;
	HUDScaleSlider.SetSize(CenterWidth, 1);
	HUDScaleSlider.SliderWidth = 90;
	HUDScaleSlider.WinLeft = CenterPos;
	WeaponScaleSlider.SetSize(CenterWidth, 1);
	WeaponScaleSlider.SliderWidth = 90;
	WeaponScaleSlider.WinLeft = CenterPos;
	StatusScaleSlider.SetSize(CenterWidth, 1);
	StatusScaleSlider.SliderWidth = 90;
	StatusScaleSlider.WinLeft = CenterPos;
	CrosshairSlider.SetSize(CenterWidth, 1);
	CrosshairSlider.SliderWidth = 90;
	CrosshairSlider.WinLeft = CenterPos;
	CrosshairColorCombo.SetSize(CenterWidth, 1);
	CrosshairColorCombo.WinLeft = CenterPos;
	CrosshairColorCombo.EditBoxWidth = 90;
	CrosshairRSlider.SetSize(CenterWidth, 1);
	CrosshairRSlider.SliderWidth = 90;
	CrosshairRSlider.WinLeft = CenterPos;
	CrosshairGSlider.SetSize(CenterWidth, 1);
	CrosshairGSlider.SliderWidth = 90;
	CrosshairGSlider.WinLeft = CenterPos;
	CrosshairBSlider.SetSize(CenterWidth, 1);
	CrosshairBSlider.SliderWidth = 90;
	CrosshairBSlider.WinLeft = CenterPos;
}

function Paint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, CrosshairX, HUDX;
	local ChallengeHUD H;
	local Texture CrossHair, T;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	Super.Paint(C, X, Y);

	H = ChallengeHUD(GetPlayerOwner().MyHUD);
	CrossHair = H.CrosshairTextures[H.Crosshair];
	if(CrossHair == None)
		CrossHair = H.LoadCrosshair(H.Crosshair);

	CrosshairX = (WinWidth - Crosshair.USize) / 2;
	T = GetLookAndFeelTexture();
	DrawUpBevel(C, CrosshairX - 3, CrosshairSlider.WinTop + 20 - 3, CrossHair.USize + 6, CrossHair.VSize + 6, T);
	DrawStretchedTexture(C, CrosshairX, CrosshairSlider.WinTop + 20, CrossHair.USize, CrossHair.VSize, Texture'BlackTexture');

	C.DrawColor.R = 15 * H.CrosshairColor.R;
	C.DrawColor.G = 15 * H.CrosshairColor.G;
	C.DrawColor.B = 15 * H.CrosshairColor.B;
	DrawClippedTexture(C, CrosshairX, CrosshairSlider.WinTop + 20, CrossHair);


	HUDX = (WinWidth - Texture'HudPreview'.USize) / 2;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	DrawUpBevel(C, HUDX - 3, OpacitySlider.WinTop + 20 - 3, Texture'HudPreview'.USize + 6, Texture'HudPreview'.VSize + 6, T);
	DrawClippedTexture(C, HUDX, OpacitySlider.WinTop + 20, Texture'HudPreviewBG');

	if ( H.Opacity == 16 )
	{
		C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;
		C.DrawColor.R = H.FavoriteHUDColor.R * 15.9;
		C.DrawColor.G = H.FavoriteHUDColor.G * 15.9;
		C.DrawColor.B = H.FavoriteHUDColor.B * 15.9;
	}
	else
	{
		C.Style = GetPlayerOwner().ERenderStyle.STY_Translucent;
		C.DrawColor.R = H.FavoriteHUDColor.R * (H.Opacity + 0.9);
		C.DrawColor.G = H.FavoriteHUDColor.G * (H.Opacity + 0.9);
		C.DrawColor.B = H.FavoriteHUDColor.B * (H.Opacity + 0.9);
	}

	DrawClippedTexture(C, HUDX, OpacitySlider.WinTop + 20, Texture'HudPreview');
}

function Notify(UWindowDialogControl C, byte E)
{
	if(C == DefaultsButton && E == DE_Click)
	{
		ResetHUD();
		return;
	} 

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case CrosshairSlider:
			CrosshairChanged();
			break;
		case HUDRSlider:
		case HUDGSlider:
		case HUDBSlider:
			ChangeToCustomColor();
			HUDLayoutChanged();
			break;
		case CrosshairRSlider:
		case CrosshairGSlider:
		case CrosshairBSlider:
			ChangeToCustomCrosshairColor();
			HUDLayoutChanged();
			break;
		case ShowHUDCheck:
		case ShowWeaponsCheck:
		case ShowStatusCheck:
		case ShowAmmoCheck:
		case ShowTeamInfoCheck:
		case ShowFragsCheck:
		case ShowFacesCheck:
		case OpacitySlider:
		case HUDScaleSlider:
		case WeaponScaleSlider:
		case StatusScaleSlider:
		case HUDColorCombo:
		case CrosshairColorCombo:
		case UseTeamColorCheck:
			HUDLayoutChanged();
			break;
		}
	}
	Super.Notify(C, E);
}

function ResetHUD()
{
	class'HUD'.static.ResetConfig();
	class'ChallengeHUD'.static.ResetConfig();
	class'ChallengeHUD'.static.StaticSaveConfig();
	LoadDefaultValues();
	LoadCurrentValues();
}

singular function ChangeToCustomColor()
{
	if(!bInitialized) return;

	bInitialized = False;
	HUDColorCombo.SetSelectedIndex(Max(HUDColorCombo.FindItemIndex2("cust", False), 0));
	bInitialized = True;
}

singular function ChangeToCustomCrosshairColor()
{
	if(!bInitialized) return;

	bInitialized = False;
	CrosshairColorCombo.SetSelectedIndex(Max(CrosshairColorCombo.FindItemIndex2("cust", False), 0));
	bInitialized = True;
}

singular function HUDLayoutChanged()
{
	local ChallengeHUD H;
	local string Temp;
	local int i;

	if(!bInitialized) return;

	H = ChallengeHUD(GetPlayerOwner().MyHUD);

	ShowWeaponsCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowStatusCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowAmmoCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowTeamInfoCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowFragsCheck.bDisabled = !ShowHUDCheck.bChecked;
	ShowFacesCheck.bDisabled = !ShowHUDCheck.bChecked;
	UseTeamColorCheck.bDisabled = !ShowHUDCheck.bChecked;

	H.bHideHUD = !ShowHUDCheck.bChecked;
	H.bHideAllWeapons = !ShowWeaponsCheck.bChecked;
	H.bHideStatus = !ShowStatusCheck.bChecked;
	H.bHideAmmo = !ShowAmmoCheck.bChecked;
	H.bHideTeamInfo = !ShowTeamInfoCheck.bChecked;
	H.bHideFrags = !ShowFragsCheck.bChecked;
	H.bHideFaces = !ShowFacesCheck.bChecked;
	H.bUseTeamColor = UseTeamColorCheck.bChecked;
	H.Opacity = OpacitySlider.GetValue();
	H.HUDScale = HUDScaleSlider.GetValue()/5;
	H.WeaponScale = WeaponScaleSlider.GetValue()/5;
	H.StatusScale = StatusScaleSlider.GetValue()/10;

	if(HUDColorCombo.GetValue2() == "cust")
	{
		H.FavoriteHUDColor.R = HUDRSlider.GetValue();
		H.FavoriteHUDColor.G = HUDGSlider.GetValue();
		H.FavoriteHUDColor.B = HUDBSlider.GetValue();
	}
	else
	{
		Temp = HUDColorCombo.GetValue2();
		i = InStr(Temp, ",");
		H.FavoriteHUDColor.R = Int(Left(Temp, i));
		Temp = Mid(Temp, i+1);
		i = InStr(Temp, ",");
		H.FavoriteHUDColor.G = Int(Left(Temp, i));
		Temp = Mid(Temp, i+1);
		H.FavoriteHUDColor.B = Int(Temp);

		bInitialized = False;
		HUDRSlider.SetValue(H.FavoriteHUDColor.R);
		HUDGSlider.SetValue(H.FavoriteHUDColor.G);
		HUDBSlider.SetValue(H.FavoriteHUDColor.B);
		bInitialized = True;
	}

	if(CrosshairColorCombo.GetValue2() == "cust")
	{
		H.CrosshairColor.R = CrosshairRSlider.GetValue();
		H.CrosshairColor.G = CrosshairGSlider.GetValue();
		H.CrosshairColor.B = CrosshairBSlider.GetValue();
	}
	else
	{
		Temp = CrosshairColorCombo.GetValue2();
		i = InStr(Temp, ",");
		H.CrosshairColor.R = Int(Left(Temp, i));
		Temp = Mid(Temp, i+1);
		i = InStr(Temp, ",");
		H.CrosshairColor.G = Int(Left(Temp, i));
		Temp = Mid(Temp, i+1);
		H.CrosshairColor.B = Int(Temp);

		bInitialized = False;
		CrosshairRSlider.SetValue(H.CrosshairColor.R);
		CrosshairGSlider.SetValue(H.CrosshairColor.G);
		CrosshairBSlider.SetValue(H.CrosshairColor.B);
		bInitialized = True;
	}
}

function CrosshairChanged()
{
	GetPlayerOwner().myHUD.Crosshair = int(CrosshairSlider.Value);
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	GetPlayerOwner().myHUD.SaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
	CrosshairText="Crosshair Style"
	CrosshairHelp="Choose the crosshair appearing at the center of your screen."
	ShowHUDText="Show HUD"
	ShowHUDHelp="Show the Heads-up Display (HUD)."
	ShowWeaponsText="Show Weapon Display"
	ShowWeaponsHelp="Show weapon displays on the HUD."
	ShowStatusText="Show Player Status"
	ShowStatusHelp="Shows the player status indicator (top right) on the HUD."
	ShowAmmoText="Show Ammo Count"
	ShowAmmoHelp="Show your current ammo count on the HUD."
	ShowTeamInfoText="Show Team Info"
	ShowTeamInfoHelp="Show team-related information on the HUD."
	ShowFragsText="Show Frags"
	ShowFragsHelp="Show your frag count on the HUD."
	ShowFacesText="Show Chat Area"
	ShowFacesHelp="Show the chat area in the top left corner, where chat messages and kills appear."
	OpacityText="HUD Transparency"
	OpacityHelp="Adjust the level of transparency in the HUD."
	HUDScaleText="HUD Size"
	HUDScaleHelp="Adjust the size of the elements on the HUD."
	WeaponScaleText="Weapon Icon Size"
	WeaponScaleHelp="Adjust the size of the weapon icons on the HUD."
	StatusScaleText="Status Size"
	StatusScaleHelp="Adjust the scale of the player status indicator (top right) on the HUD."
	UseTeamColorText="Use Team Color in Team Games"
	UseTeamColorHelp="In team games, this setting uses your team color as the color for your HUD."
	HUDColorText="HUD Color"
	HUDColorHelp="Change your prefered HUD color.  In team games your team color will be used instead."
	HUDColorNames(0)="Red"
	HUDColorValues(0)="16,0,0"
	HUDColorNames(1)="Purple"
	HUDColorValues(1)="16,0,16"
	HUDColorNames(2)="Light Blue"
	HUDColorValues(2)="0,8,16"
	HUDColorNames(3)="Turquoise"
	HUDColorValues(3)="0,16,16"
	HUDColorNames(4)="Green"
	HUDColorValues(4)="0,16,0"
	HUDColorNames(5)="Orange"
	HUDColorValues(5)="16,8,0"
	HUDColorNames(6)="Gold"
	HUDColorValues(6)="16,16,0"
	HUDColorNames(7)="Pink"
	HUDColorValues(7)="16,0,8"
	HUDColorNames(8)="White"
	HUDColorValues(8)="16,16,16"
	HUDColorNames(9)="Deep Blue"
	HUDColorValues(9)="0,0,16"
	HUDColorNames(10)="Custom"
	HUDColorValues(10)="cust"
	HUDRText="HUD Color Red"
	HUDRHelp="Use the RGB sliders to select a custom HUD color."
	HUDGText="HUD Color Green"
	HUDGHelp="Use the RGB sliders to select a custom HUD color."
	HUDBText="HUD Color Blue"
	HUDBHelp="Use the RGB sliders to select a custom HUD color."
	CrosshairRText="Crosshair Color Red"
	CrosshairRHelp="Use the RGB sliders to select a custom Crosshair color."
	CrosshairGText="Crosshair Color Green"
	CrosshairGHelp="Use the RGB sliders to select a custom Crosshair color."
	CrosshairBText="Crosshair Color Blue"
	CrosshairBHelp="Use the RGB sliders to select a custom Crosshair color."
	CrosshairColorText="Crosshair Color"
	CrosshairColorHelp="Change your prefered Crosshair color."
	ControlOffset=10
	DefaultsText="Reset"
	DefaultsHelp="Reset HUD settings to default values."
}