//==========================================================================
// 
// FILE:			UDukeParentLockWindowCW.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		ParentLock main menu
// 
//==========================================================================
class UDukeParentLockWindowCW extends UDukeDialogClientWindow;

var	UWindowComboControl		PlayerCombo;

var UWindowSmallButton		ChangePasswordButton;
var UWindowCheckbox			KidModeCheck;
var UWindowCheckbox			AdultModeCheck;
var UWindowSmallButton		OkButton;
var bool					bSelectionWindowsCreated;

var UWindowEditControl		PWSelectEditBox;
var UWindowSmallButton		PWSelectCancelButton;
var UWindowSmallButton		PWSelectOkButton;
var bool					bPWSelectWindowsCreated;

var UWindowEditControl		PWChange1EditBox;
var UWindowEditControl		PWChange2EditBox;
var UWindowEditControl		PWChange3EditBox;
var UWindowSmallButton		PWChangeOkButton;
var UWindowSmallButton		PWChangeCancelButton;
var bool					bPasswrdChangeWindowsCreated;

var UWindowMessageBox		ConfirmInvalidPW;

var bool					bInNotify;

enum EWindowMode
{
	WMode_Default,
	WMode_PWSelect,
	WMode_PWChange
};

var EWindowMode				CurrentMode;

const	MainWidth		= 200;
const	MainHeight		= 180;

const	PWSelectWidth	= 290;
const	PWSelectHeight	= 120;

const	PWChangeWidth	= 280;
const	PWChangeHeight	= 180;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	bInNotify = false;

	Super.Created();
}

//==========================================================================================
//	AfterCreate
//==========================================================================================
function AfterCreate()
{
	ChangeWindowModes(WMode_Default);
	UpdateParentalLockCheckBoxes();
}


//==========================================================================================
//	ShowSelectionWindows
//==========================================================================================
function ShowSelectionWindows()
{
	local float		ControlPosX, ControlPosY;

	UDukeParentLockWindow(ParentWindow).WindowTitle = "Parental Lock";

	WinWidth = MainWidth;
	WinHeight = MainHeight;

	if (bSelectionWindowsCreated)
	{
		ChangePasswordButton.ShowWindow();
		KidModeCheck.ShowWindow();
		AdultModeCheck.ShowWindow();
		OkButton.ShowWindow();
		UpdateParentalLockCheckBoxes();
		return;
	}

	ControlPosY = 20.0f;
	ControlPosX = (WinWidth-128)*0.5f-10.0f;

	// Kid Mode
	KidModeCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlPosX, ControlPosY, 128, 1));
	KidModeCheck.bChecked = true;
	KidModeCheck.SetText("Kid Mode");
	KidModeCheck.SetHelpText("Check this to DISABLE adult mode.");
	KidModeCheck.SetFont(F_Normal);
	KidModeCheck.bAcceptsFocus = false;
	KidModeCheck.Align = TA_Left;

	// Adult Mode
	ControlPosY += 30.0f;

	AdultModeCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlPosX, ControlPosY, 128, 1));
	AdultModeCheck.bChecked = false;
	AdultModeCheck.SetText("Adult Mode");
	AdultModeCheck.SetHelpText("Check this to ENABLE adult mode.");
	AdultModeCheck.SetFont(F_Normal);
	AdultModeCheck.bAcceptsFocus = false;
	AdultModeCheck.Align = TA_Left;

	// Build Change Password Button
	ControlPosX = (WinWidth-100)*0.5f-10;//15.0f;
	ControlPosY += 30.0f;
	ChangePasswordButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', ControlPosX, ControlPosY, 100, 16 ) );
	ChangePasswordButton.SetText("Change Password");
	ChangePasswordButton.SetHelpText("Change the current parental control password.");

	// Build Ok Button
	ControlPosY += 35.0f;
	ControlPosX = (WinWidth-64)*0.5f-10;//15.0f;

	OkButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', ControlPosX, ControlPosY, 64, 16 ) );
	OkButton.SetText("Ok");
	OkButton.SetHelpText("Return to the main menu.");

	UpdateParentalLockCheckBoxes();

	bSelectionWindowsCreated = true;
}

//==========================================================================================
//	HideSelectionWindows
//==========================================================================================
function HideSelectionWindows()
{
	ChangePasswordButton.HideWindow();
	KidModeCheck.HideWindow();
	AdultModeCheck.HideWindow();
	OkButton.HideWindow();
}

//==========================================================================================
//	ShowPWSelectWindows
//==========================================================================================
function ShowPWSelectWindows()
{
	local float		ControlPosX, ControlPosY;

	UDukeParentLockWindow(ParentWindow).WindowTitle = "Please Enter Password";

	WinWidth = PWSelectWidth;
	WinHeight = PWSelectHeight;

	if (bPWSelectWindowsCreated)
	{
		PWSelectEditBox.ShowWindow();
		PWSelectEditBox.SetValue("");
		PWSelectCancelButton.ShowWindow();
		PWSelectOkButton.ShowWindow();
		return;
	}

	ControlPosX = (WinWidth-200)*0.5f;//15.0f;
	ControlPosY = 20.0f;

	PWSelectEditBox = UWindowEditControl(	CreateControl(class'UWindowEditControl', 
											ControlPosX, 
											ControlPosY, 
											200, 
											1));

	PWSelectEditBox.SetText("Enter Password:");
	PWSelectEditBox.SetMaxLength(40);
	PWSelectEditBox.SetHelpText("Type the parental lock password here.");
	PWSelectEditBox.SetNumericOnly( false );
	PWSelectEditBox.SetValueProtection(true);		// Hide password from viewer

	// Ok button
	ControlPosY += 35.0f;
	ControlPosX = (WinWidth-(64+64+20))*0.5f;//15.0f;

	PWSelectCancelButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', ControlPosX, ControlPosY, 64, 16 ) );
	PWSelectCancelButton.SetText("Cancel");
	PWSelectCancelButton.SetHelpText("Return to the Parental Lock main menu.");

	ControlPosX += (64+10);

	PWSelectOkButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', ControlPosX, ControlPosY, 64, 16 ) );
	PWSelectOkButton.SetText("Ok");
	PWSelectOkButton.SetHelpText("Select this password.");

	bPWSelectWindowsCreated = true;
}

//==========================================================================================
//	HidePWSelectWindows
//==========================================================================================
function HidePWSelectWindows()
{
	PWSelectEditBox.HideWindow();
	PWSelectCancelButton.HideWindow();
	PWSelectOkButton.HideWindow();
}

//==========================================================================================
//	ShowPasswordChangeWindows
//==========================================================================================
function ShowPasswordChangeWindows()
{
	local float		ControlPosX, ControlPosY;

	UDukeParentLockWindow(ParentWindow).WindowTitle = "Change Password";

	WinWidth = PWChangeWidth;
	WinHeight = PWChangeHeight;

	if (bPasswrdChangeWindowsCreated)
	{
		PWChange1EditBox.ShowWindow();
		PWChange1EditBox.SetValue("");
		PWChange2EditBox.ShowWindow();
		PWChange2EditBox.SetValue("");
		PWChange3EditBox.ShowWindow();
		PWChange3EditBox.SetValue("");
		PWChangeOkButton.ShowWindow();
		PWChangeCancelButton.ShowWindow();
		PWChange1EditBox.BringToFront();
		return;
	}

	ControlPosX = 15.0f;
	ControlPosY = 25.0f;

	// Old passord
	PWChange1EditBox = UWindowEditControl(	CreateControl(class'UWindowEditControl', 
											ControlPosX, 
											ControlPosY, 
											230, 
											1));

	PWChange1EditBox.SetText("Enter Original Password:");
	PWChange1EditBox.SetMaxLength(40);
	PWChange1EditBox.SetHelpText("Enter Original Password here.");
	PWChange1EditBox.SetNumericOnly( false );
	PWChange1EditBox.SetValueProtection(true);		// Hide password from viewer

	// New password
	ControlPosY += 25;

	PWChange2EditBox = UWindowEditControl(	CreateControl(class'UWindowEditControl', 
											ControlPosX, 
											ControlPosY, 
											230, 
											1));

	PWChange2EditBox.SetText("Enter New Password:");
	PWChange2EditBox.SetMaxLength(40);
	PWChange2EditBox.SetHelpText("Enter New Password here.");
	PWChange2EditBox.SetNumericOnly( false );
	PWChange2EditBox.SetValueProtection(true);		// Hide password from viewer

	// Confirm new password
	ControlPosY += 25;

	PWChange3EditBox = UWindowEditControl(	CreateControl(class'UWindowEditControl', 
											ControlPosX, 
											ControlPosY, 
											230, 
											1));

	PWChange3EditBox.SetText("Confirm New Password:");
	PWChange3EditBox.SetMaxLength(40);
	PWChange3EditBox.SetHelpText("Confirm New Password here.");
	PWChange3EditBox.SetNumericOnly( false );
	PWChange3EditBox.SetValueProtection(true);		// Hide password from viewer

	// Build Ok Button
	ControlPosY += 40.0f;
	ControlPosX = (WinWidth-(64+64+20))*0.5f;//15.0f;

	PWChangeCancelButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', ControlPosX, ControlPosY, 64, 16 ) );
	PWChangeCancelButton.SetText("Cancel");
	PWChangeCancelButton.SetHelpText("Go back to the parental selection menu.");

	ControlPosX += (64+10);

	PWChangeOkButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', ControlPosX, ControlPosY, 64, 16 ) );
	PWChangeOkButton.SetText("Ok");
	PWChangeOkButton.SetHelpText("Change to the new password.");

	PWChange1EditBox.BringToFront();

	bPasswrdChangeWindowsCreated = true;
}

//==========================================================================================
//	HidePasswordChangeWindows
//==========================================================================================
function HidePasswordChangeWindows()
{
	PWChange1EditBox.HideWindow();
	PWChange2EditBox.HideWindow();
	PWChange3EditBox.HideWindow();
	PWChangeOkButton.HideWindow();
	PWChangeCancelButton.HideWindow();
}

//==========================================================================================
//	UpdateParentalLockCheckBoxes
//==========================================================================================
function UpdateParentalLockCheckBoxes()
{
	if (bSelectionWindowsCreated)
	{
		if (GetPlayerOwner().ParentalLockIsOn())
		{
			KidModeCheck.bChecked = true;
			AdultModeCheck.bChecked = false;
		}
		else
		{
			KidModeCheck.bChecked = false;
			AdultModeCheck.bChecked = true;
		}
	}
}

//==========================================================================================
//	ChangeWindowModes
//==========================================================================================
function ChangeWindowModes(EWindowMode Mode)
{
	if (Mode == WMode_Default)
	{
		HidePasswordChangeWindows();
		HidePWSelectWindows();
		ShowSelectionWindows();
	}
	else if (Mode == WMode_PWSelect)
	{
		HidePasswordChangeWindows();
		HideSelectionWindows();
		ShowPWSelectWindows();
	}
	else if (Mode == WMode_PWChange)
	{
		HidePWSelectWindows();
		HideSelectionWindows();
		ShowPasswordChangeWindows();
	}

	CurrentMode = Mode;
}

//==========================================================================================
//	BeforePaint
//==========================================================================================
function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	
	if (CurrentMode == WMode_Default)
	{
		ParentWindow.WinWidth = MainWidth;
		ParentWindow.WinHeight = MainHeight;
	}
	else if (CurrentMode == WMode_PWSelect)
	{
		ParentWindow.WinWidth = PWSelectWidth;
		ParentWindow.WinHeight = PWSelectHeight;
	}
	else if (CurrentMode == WMode_PWChange)
	{
		ParentWindow.WinWidth = PWChangeWidth;
		ParentWindow.WinHeight = PWChangeHeight;
	}
	
	WinWidth = ParentWindow.WinWidth;
	WinHeight = ParentWindow.WinHeight;
	
	ParentWindow.WinLeft = (OwnerWindow.OwnerWindow.WinWidth - ParentWindow.WinWidth)*0.5f;
	ParentWindow.WinTop = (OwnerWindow.OwnerWindow.WinHeight - ParentWindow.WinHeight)*0.5f;
}

//==========================================================================================
//	MessageBoxDone
//==========================================================================================
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	ParentWindow.ShowWindow();

	if(W == ConfirmInvalidPW && Result == MR_OK)
	{
		ChangeWindowModes(WMode_PWSelect);
		UpdateParentalLockCheckBoxes();
	}
}

//==========================================================================================
//	ChangePasswords
//==========================================================================================
function ChangePasswords()
{
	if (PWChange2EditBox.GetValue() == PWChange3EditBox.GetValue())
	{
		if (GetPlayerOwner().SetParentalLockPassword(PWChange1EditBox.GetValue(), PWChange2EditBox.GetValue()))
		{
			ChangeWindowModes(WMode_Default);
		}
		else
		{
			ParentWindow.HideWindow();
			MessageBox("Invalid Password", "Invalid Password", MB_OK, MR_OK, MR_OK);
		}
	}
	else
	{
		ParentWindow.HideWindow();
		MessageBox("Invalid Password", "Passwords do not match", MB_OK, MR_OK, MR_OK);
	}
}

//==========================================================================================
//	TurnParentLockOffStep1
//==========================================================================================
function TurnParentLockOffStep1()
{
	if (GetPlayerOwner().ParentalLockIsOn())
	{
		if (GetPlayerOwner().ValidateParentalLockPassword(""))
			TurnParentLockOffStep2();		// Go straight to step 2
		else
		{
			// Trigger step windows that will eventually trugger step 2
			ChangeWindowModes(WMode_PWSelect);
		}
	}
	
	UpdateParentalLockCheckBoxes();
}

//==========================================================================================
//	TurnParentLockOffStep2
//==========================================================================================
function TurnParentLockOffStep2()
{
	local string	PW;

	if (GetPlayerOwner().ValidateParentalLockPassword(""))
		PW = "";
	else
		PW = PWSelectEditBox.GetValue();

	if (GetPlayerOwner().SetParentalLockStatus(false, PW))
	{
		ChangeWindowModes(WMode_Default);
	}
	else
	{
		ParentWindow.HideWindow();
		ConfirmInvalidPW = MessageBox("Invalid Password", "Invalid Password", MB_OK, MR_OK, MR_OK);
	}

	UpdateParentalLockCheckBoxes();
}

//==========================================================================================
//	TurnParentLockOn
//==========================================================================================
function TurnParentLockOn()
{
	GetPlayerOwner().SetParentalLockStatus(true, "");
	UpdateParentalLockCheckBoxes();
}

//==========================================================================================
//	Notify
//==========================================================================================
function Notify( UWindowDialogControl C, byte E )
{
	Super.Notify( C, E );
    
    if (bInNotify == true)
        return;

    bInNotify = true;

	if (E == DE_Click && C == ChangePasswordButton)
		ChangeWindowModes(WMode_PWChange);
	else if (E == DE_Click && C == OkButton)
		Close();
	else if (E == DE_Change && C == KidModeCheck)
		TurnParentLockOn();
	else if (E == DE_Change && C == AdultModeCheck)
		TurnParentLockOffStep1();
	else if (E == DE_EnterPressed && C == PWSelectEditBox)
		TurnParentLockOffStep2();
	else if (E == DE_Click && C == PWChangeOkButton)
		ChangePasswords();
	else if (E == DE_EnterPressed && C == PWChange1EditBox)
		PWChange2EditBox.BringToFront();
	else if (E == DE_EnterPressed && C == PWChange2EditBox)
		PWChange3EditBox.BringToFront();
	else if (E == DE_EnterPressed && C == PWChange3EditBox)
		ChangePasswords();
	else if (E == DE_Click && C == PWChangeCancelButton)
		ChangeWindowModes(WMode_Default);
	else if (E == DE_Click && C == PWSelectCancelButton)
		ChangeWindowModes(WMode_Default);
	else if (E == DE_Click && C == PWSelectOkButton)
		TurnParentLockOffStep2();

	UpdateParentalLockCheckBoxes();

    bInNotify = false;
}

defaultproperties
{
}
