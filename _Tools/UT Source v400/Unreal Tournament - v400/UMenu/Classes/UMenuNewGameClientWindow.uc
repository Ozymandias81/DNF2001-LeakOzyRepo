class UMenuNewGameClientWindow extends UMenuPageWindow;

var string StartMap;

// Skill Level
var UWindowComboControl SkillCombo;
var UMenuLabelControl SkillLabel;
var localized string SkillText;
var localized string Skills[4];
var localized string SkillStrings[4];
var localized string SkillHelp;

var UWindowSmallButton OKButton;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int I, S;

	Super.Created();

	DesiredWidth = 220;
	DesiredHeight = 330;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Skill Level
	SkillCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 25, CenterWidth, 1));
	SkillCombo.SetText(SkillText);
	SkillCombo.SetHelpText(SkillHelp);
	SkillCombo.SetFont(F_Normal);
	SkillCombo.SetEditable(False);
	for (I=0; I<4; I++)
		SkillCombo.AddItem(Skills[I]);
	SkillCombo.SetSelectedIndex(GetLevel().Game.Difficulty + 1);
	SkillLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, 45, CenterWidth, 1));
	SkillLabel.SetText(SkillStrings[GetLevel().Game.Difficulty + 1]);
	SkillLabel.Align = TA_Center;

	// OKButton
	OKButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 70, 64, 32));
	OKButton.SetText("OK");
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

	SkillCombo.SetSize(CenterWidth, 1);
	SkillCombo.WinLeft = CenterPos;
	SkillCombo.EditBoxWidth = 90;

	SkillLabel.SetSize(CenterWidth, 1);
	SkillLabel.WinLeft = CenterPos;

	OKButton.Winleft = (WinWidth - OKButton.WinWidth) / 2;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
			case SkillCombo:
				SkillChanged();
				break;
		}
	case DE_Click:
		switch(C)
		{
			case OKButton:
				OKClicked();
				break;
		}
	}
}

function OKClicked()
{
	GetPlayerOwner().ClientTravel(StartMap, TRAVEL_Absolute, false);

	Close();
	Root.Console.CloseUWindow();
}

function SkillChanged()
{
	SkillLabel.SetText(SkillStrings[SkillCombo.GetSelectedIndex()]);	
}

defaultproperties
{
	StartMap="..\\maps\\Vortex2.unr"
	SkillText="Skill Level:"
	SkillHelp="Select the difficulty you wish to play at."
	Skills(0)="Easy"
	Skills(1)="Medium"
	Skills(2)="Hard"
	Skills(3)="Unreal"
    SkillStrings(0)="Tourist mode."
    SkillStrings(1)="Ready for some action!"
    SkillStrings(2)="Not for the faint of heart."
    SkillStrings(3)="Death wish."
}