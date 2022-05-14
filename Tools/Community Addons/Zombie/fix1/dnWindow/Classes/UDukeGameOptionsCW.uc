class UDukeGameOptionsCW extends UDukePageWindow;

// Weapon Stuff
var UWindowLabelControl WeaponLabel;
var localized string WeaponLabelText;

// Weapon Hand
var UWindowComboControl WeaponHandCombo;
var localized string WeaponHandText;
var localized string WeaponHandHelp;

var localized string LeftName;
var localized string CenterName;
var localized string RightName;
var localized string HiddenName;

// View Bob
var UWindowHSliderControl ViewBobSlider;
var localized string ViewBobText;
var localized string ViewBobHelp;

// Shield Control
var UWindowComboControl ShieldControlCombo;
var localized string ShieldControlText;
var localized string ShieldControlHelp;
var localized string ShieldMode[2];

// LOD
var UWindowLabelControl LODLabel;
var localized string LODLabelText;

// LOD On/Off
var UWindowCheckbox UseLODCheck;
var localized string UseLODText;
var localized string UseLODHelp;

var float ControlOffset;

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

	// Weapon Label
	WeaponLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	WeaponLabel.SetText(WeaponLabelText);
	WeaponLabel.SetFont(F_Bold);
	ControlOffset += 25;

	// Weapon Hand
	WeaponHandCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	WeaponHandCombo.SetText(WeaponHandText);
	WeaponHandCombo.SetHelpText(WeaponHandHelp);
	WeaponHandCombo.SetFont(F_Normal);
	WeaponHandCombo.SetEditable(False);
	WeaponHandCombo.AddItem(LeftName, "Left");
	WeaponHandCombo.AddItem(CenterName, "Center");
	WeaponHandCombo.AddItem(RightName, "Right");
	WeaponHandCombo.AddItem(HiddenName, "Hidden");
	switch(GetPlayerOwner().Handedness)
	{
		case -1: WeaponHandCombo.SetSelectedIndex(2); break;
		case 0: WeaponHandCombo.SetSelectedIndex(1); break;
		case 1: WeaponHandCombo.SetSelectedIndex(0); break;
		case 2: WeaponHandCombo.SetSelectedIndex(3); break;
		default: WeaponHandCombo.SetSelectedIndex(2); break;
	}
	ControlOffset += 25;

	// Shield Control
	ShieldControlCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ShieldControlCombo.SetText(ShieldControlText);
	ShieldControlCombo.SetHelpText(ShieldControlHelp);
	ShieldControlCombo.SetFont(F_Normal);
	ShieldControlCombo.SetEditable(False);
	ShieldControlCombo.AddItem(ShieldMode[0], "Hold");
	ShieldControlCombo.AddItem(ShieldMode[1], "Toggle");
	switch(GetPlayerOwner().ShieldMode)
	{
		case SM_Hold:
			ShieldControlCombo.SetSelectedIndex(0);
			break;
		case SM_Toggle:
			ShieldControlCombo.SetSelectedIndex(1);
			break;
	}
	ControlOffset += 25;

	// View Bob
	ViewBobSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlRight, ControlOffset, ControlWidth, 1));
	ViewBobSlider.SetRange(0, 8, 1);
	ViewBobSlider.SetValue((GetPlayerOwner().Bob*1000) / 4);
	ViewBobSlider.SetText(ViewBobText);
	ViewBobSlider.SetHelpText(ViewBobHelp);
	ViewBobSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// LOD Label
	LODLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	LODLabel.SetText(LODLabelText);
	LODLabel.SetFont(F_Bold);
	ControlOffset += 25;

	// LOD Enable
	UseLODCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	Log(GetPlayerOwner().ConsoleCommand("GetLodActive"));
	UseLODCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("GetLodActive"));
	UseLODCheck.SetText(UseLODText);
	UseLODCheck.SetHelpText(UseLODHelp);
	UseLODCheck.SetFont(F_Normal);
	UseLODCheck.Align = TA_Left;
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

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	WeaponLabel.SetSize(ControlWidth, 1);
	WeaponLabel.WinLeft = ControlLeft;

	WeaponHandCombo.SetSize(CenterWidth, 1);
	WeaponHandCombo.WinLeft = CenterPos;
	WeaponHandCombo.EditBoxWidth = 90;

	ShieldControlCombo.SetSize(CenterWidth, 1);
	ShieldControlCombo.WinLeft = CenterPos;
	ShieldControlCombo.EditBoxWidth = 90;

	ViewBobSlider.SetSize(CenterWidth, 1);
	ViewBobSlider.WinLeft = CenterPos;
	ViewBobSlider.SliderWidth = 90;

	LODLabel.SetSize(ControlWidth, 1);
	LODLabel.WinLeft = ControlLeft;

	UseLODCheck.SetSize(CenterWidth-90+16, 1);
	UseLODCheck.WinLeft = CenterPos;
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case WeaponHandCombo:
			WeaponHandChanged();
			break;
		case ShieldControlCombo:
			ShieldControlChanged();
			break;
		case ViewBobSlider:
			ViewBobChanged();
			break;
		case UseLODCheck:
			LODChanged();
			break;
		}
	}
	Super.Notify(C, E);
}

function WeaponHandChanged()
{
//	GetPlayerOwner().ChangeSetHand(WeaponHandCombo.GetValue2());
}

function ShieldControlChanged()
{
	switch (ShieldControlCombo.GetValue2())
	{
		case "Hold":
			GetPlayerOwner().ShieldMode = SM_Hold;
			break;
		case "Toggle":
			GetPlayerOwner().ShieldMode = SM_Toggle;
			break;
	}
}

function ViewBobChanged()
{
	GetPlayerOwner().UpdateBob((ViewBobSlider.Value) / 1000);
}

function LODChanged()
{
	if (UseLODCheck.bChecked)
		GetPlayerOwner().ConsoleCommand("mesh_lodactive 1");
	else
		GetPlayerOwner().ConsoleCommand("mesh_lodactive 0");
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	if ( GetLevel().Game != None )
	{
		GetLevel().Game.SaveConfig();
		GetLevel().Game.GameReplicationInfo.SaveConfig();
	}
	class'GameInfo'.static.StaticSaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
     WeaponLabelText="Weapon"
     WeaponHandText="Weapon Hand"
     WeaponHandHelp="Select where your weapon will appear."
     LeftName="Left"
     CenterName="Center"
     RightName="Right"
     HiddenName="Hidden"
     ViewBobText="View Bob"
     ViewBobHelp="Use the slider to adjust the amount your view will bob when moving."
     ShieldControlText="Riot Shield Control"
     ShieldControlHelp="Select how the use key affects Riot Shield functionality."
     ShieldMode(0)="Hold"
     ShieldMode(1)="Toggle"
     LODLabelText="LOD"
     UseLODText="LOD Enabled"
     UseLODHelp="Toggles mesh level of detail.  If you don't know what this is, keep it on."
     ControlOffset=20.000000
}
