class UMenuHUDConfigCW extends UMenuPageWindow;

// HUD Config
var UWindowHSliderControl HUDConfigSlider;
var localized string HUDConfigText;
var localized string HUDConfigHelp;

// Crosshair
var UWindowHSliderControl CrosshairSlider;
var localized string CrosshairText;
var localized string CrosshairHelp;

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
	DesiredHeight = 70;


	// HUD Config
	HUDConfigSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, 20, ControlWidth, 1));
	HUDConfigSlider.SetRange(0, 5, 1);
	HUDConfigSlider.SetValue(GetPlayerOwner().myHUD.HUDMode);
	HUDConfigSlider.SetText(HUDConfigText);
	HUDConfigSlider.SetHelpText(HUDConfigHelp);
	HUDConfigSlider.SetFont(F_Normal);

	// Crosshair
	CrosshairSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, 45, CenterWidth, 1));
	CrosshairSlider.SetRange(0, 5, 1);
	CrosshairSlider.SetValue(GetPlayerOwner().myHUD.Crosshair);
	CrosshairSlider.SetText(CrosshairText);
	CrosshairSlider.SetHelpText(CrosshairHelp);
	CrosshairSlider.SetFont(F_Normal);


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

	HUDConfigSlider.SetSize(CenterWidth, 1);
	HUDConfigSlider.SliderWidth = 90;
	HUDConfigSlider.WinLeft = CenterPos;

	CrosshairSlider.SetSize(CenterWidth, 1);
	CrosshairSlider.SliderWidth = 90;
	CrosshairSlider.WinLeft = CenterPos;
}

function Paint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, CrosshairX;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	Super.Paint(C, X, Y);

	CrosshairX = CenterPos + CenterWidth + 5;

	// DrawCrosshair
	if (GetPlayerOwner().myHUD.Crosshair==0)
		DrawClippedTexture(C, CrosshairX, 45, Texture'Crosshair1');
	else if (GetPlayerOwner().myHUD.Crosshair==1)
		DrawClippedTexture(C, CrosshairX, 45, Texture'Crosshair2');
	else if (GetPlayerOwner().myHUD.Crosshair==2)
		DrawClippedTexture(C, CrosshairX, 45, Texture'Crosshair3');
	else if (GetPlayerOwner().myHUD.Crosshair==3)
		DrawClippedTexture(C, CrosshairX, 45, Texture'Crosshair4');
	else if (GetPlayerOwner().myHUD.Crosshair==4)
		DrawClippedTexture(C, CrosshairX, 45, Texture'Crosshair5');	
	else if (GetPlayerOwner().myHUD.Crosshair==5)
		DrawClippedTexture(C, CrosshairX, 45, Texture'Crosshair7');
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case CrosshairSlider:
			CrosshairChanged();
			break;
		case HUDConfigSlider:
			HUDConfigChanged();
			break;
		}
	}
}


function CrosshairChanged()
{
	GetPlayerOwner().myHUD.Crosshair = int(CrosshairSlider.Value);
}

function HUDConfigChanged()
{
	GetPlayerOwner().myHUD.HudMode = int(HUDConfigSlider.Value);
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	GetPlayerOwner().myHUD.SaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
	HUDConfigText="HUD Layout"
	HUDConfigHelp="Use the left and right arrow keys to select a Heads Up Display configuration."
	CrosshairText="Crosshair Style"
	CrosshairHelp="Choose the crosshair appearing at the center of your screen."
}