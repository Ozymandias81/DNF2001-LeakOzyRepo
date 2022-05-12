class ngWorldSecretClient extends UMenuDialogClientWindow;

// Description Labels
var UMenuLabelControl SecretLabel;
var localized string SecretDesc;

// Secret Combo
var UWindowComboControl SecretCombo;
var localized string SecretText;

var UWindowSmallButton OKButton;
var localized string OKText;

var UWindowMessageBox ConfirmChange;
var localized string QuitHelp;
var localized string QuitTitle;
var localized string QuitText;
var localized string EmptyTitle;
var localized string EmptyText;

function Created()
{
	local int XOffset, Num;
	local int CenterWidth, CenterPos;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Description
	XOffset = 20;
	SecretLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos - 10, XOffset, CenterWidth + 20, 1));
	SecretLabel.SetText(SecretDesc);

	// Secret
	SecretCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, XOffset + 20, CenterWidth, 1));
	SecretCombo.SetText(SecretText);
	//SecretCombo.SetHelpText(SecretHelp);
	SecretCombo.SetFont(F_Normal);
	SecretCombo.SetEditable(True);
	SecretCombo.AddItem(GetPlayerOwner().ngWorldSecret);
	SecretCombo.SetSelectedIndex(0);

	OKButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 16));
	OKButton.SetText(OKText);

	Super.Created();
}

function Resized()
{
	local int CenterWidth, CenterPos;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	SecretLabel.SetSize(CenterWidth + 60, 1);
	SecretLabel.WinLeft = CenterPos - 30;

	SecretCombo.SetSize(CenterWidth, 1);
	SecretCombo.WinLeft = CenterPos;
	SecretCombo.EditBoxWidth = 110;

	OKButton.WinLeft = WinWidth-52;
	OKButton.WinTop = WinHeight-20;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();

	DrawUpBevel( C, 0, WinHeight-22, WinWidth, 22, T);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
			case OKButton:
				OKPressed();
				break;
		}
	}
}

function Close(optional bool bByParent)
{
	// Store the new secret.
	GetPlayerOwner().ngWorldSecret = SecretCombo.GetValue();
	GetPlayerOwner().ngSecretSet = True;
	GetPlayerOwner().SaveConfig();

	Super.Close(bByParent);
}

function OKPressed()
{
	if (SecretCombo.GetValue() == GetPlayerOwner().ngWorldSecret)
		Close();
	else if (SecretCombo.GetValue() == "")
		ConfirmChange = MessageBox(QuitTitle, EmptyText, MB_YesNo, MR_Yes, MR_No);
	else
		ConfirmChange = MessageBox(QuitTitle, QuitText, MB_YesNo, MR_Yes, MR_No);
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(W == ConfirmChange)
	{
		switch(Result)
		{
		case MR_Yes:
			Close();
			break;
		case MR_No:
			SecretCombo.SetValue(GetPlayerOwner().ngWorldSecret);
			break;
		}				
	}
}

defaultproperties
{
	SecretDesc="Pick your own password to keep your online ngWorldStats unique."
	SecretText="ngWorldStats Password:"
	OKText="OK"
	QuitHelp="Select [Yes] to save your new password."
	QuitTitle="Confirm Password Change"
	QuitText="Warning! If you play with this new password, a new ngWorldStats account will be created for you the next time you join a ngWorldStats game server. Are you sure you want to do this?"
	EmptyTitle="Confirm Password Removal"
	EmptyText="Note: You have chosen not to have an ngWorldStats password. Your online game statistics will not be accumulated. Are you sure this is what you want?"
}
