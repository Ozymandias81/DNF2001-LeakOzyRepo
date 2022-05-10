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

var bool					bSelectionWindowsCreated;
var UWindowCheckbox			AdultModeCheck;
var localized string		AdultModeText;
var localized string		AdultModeHelp;
var UWindowSmallButton		ChangePasswordButton;

var bool					bPasswrdChangeWindowsCreated;
var UWindowLabelControl		PWChange1Label;
var UWindowEditControl		PWChange1EditBox;
var localized string		PWChange1Text;
var localized string		PWChange1Help;

var UWindowLabelControl		PWChange2Label;
var UWindowEditControl		PWChange2EditBox;
var localized string		PWChange2Text;
var localized string		PWChange2Help;

var UWindowLabelControl		PWChange3Label;
var UWindowEditControl		PWChange3EditBox;
var localized string		PWChange3Text;
var localized string		PWChange3Help;

var UWindowSmallButton		PWChangeOkButton;
var UWindowSmallButton		PWChangeCancelButton;

var bool					bPWSelectWindowsCreated;
var UWindowLabelControl		PWSelectLabel;
var UWindowEditControl		PWSelectEditBox;
var localized string		PWSelectText;
var localized string		PWSelectHelp;
var UWindowSmallButton		PWSelectCancelButton;
var UWindowSmallButton		PWSelectOkButton;

var UWindowMessageBox		ConfirmInvalidPW;

var bool					bInNotify;

enum EWindowMode
{
	WMode_Default,
	WMode_PWSelect,
	WMode_PWChange
};

var EWindowMode				CurrentMode;

const	MainWidth		= 400;
const	MainHeight		= 190;

const	PWSelectWidth	= 400;
const	PWSelectHeight	= 190;

const	PWChangeWidth	= 470;
const	PWChangeHeight	= 264;

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
	ChangeWindowModes( WMode_Default );
	UpdateParentalLockCheckBoxes();
}


//==========================================================================================
//	ShowSelectionWindows
//==========================================================================================
function ShowSelectionWindows()
{
	UDukeParentLockWindow(ParentWindow.ParentWindow).WindowTitle = "Parental Lock ";

	if (bSelectionWindowsCreated)
	{
		ChangePasswordButton.ShowWindow();
		AdultModeCheck.ShowWindow();
		UpdateParentalLockCheckBoxes();
		return;
	}

	// Adult Mode
	AdultModeCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 1, 1, 1, 1));
	AdultModeCheck.bChecked = false;
	AdultModeCheck.SetText(AdultModeText);
	AdultModeCheck.SetHelpText(AdultModeHelp);
	AdultModeCheck.SetFont(F_Normal);
	AdultModeCheck.bAcceptsFocus = false;
	AdultModeCheck.Align = TA_Left;

	// Build Change Password Button
	ChangePasswordButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	ChangePasswordButton.SetText("Change Password");
	ChangePasswordButton.SetHelpText("Change the current parental control password.");

	UpdateParentalLockCheckBoxes();

	bSelectionWindowsCreated = true;
}

//==========================================================================================
//	HideSelectionWindows
//==========================================================================================
function HideSelectionWindows()
{
	ChangePasswordButton.HideWindow();
	AdultModeCheck.HideWindow();
}

//==========================================================================================
//	ShowPWSelectWindows
//==========================================================================================
function ShowPWSelectWindows()
{
	UDukeParentLockWindow(ParentWindow.ParentWindow).WindowTitle = "Enter Password ";

	if ( bPWSelectWindowsCreated )
	{
		PWSelectLabel.ShowWindow();
		PWSelectEditBox.ShowWindow();
		PWSelectEditBox.SetValue( "" );
		PWSelectCancelButton.ShowWindow();
		PWSelectOkButton.ShowWindow();
		return;
	}

	// Password enter
	PWSelectLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	PWSelectLabel.SetText(PWSelectText);
	PWSelectLabel.SetHelpText(PWSelectHelp);
	PWSelectLabel.SetFont(F_Normal);
	PWSelectLabel.Align = TA_Right;

	PWSelectEditBox = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1) );
	PWSelectEditBox.SetMaxLength(40);
	PWSelectEditBox.SetHelpText(PWSelectHelp);
	PWSelectEditBox.SetNumericOnly( false );
	PWSelectEditBox.SetValueProtection( true );

	// Cancel button
	PWSelectCancelButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	PWSelectCancelButton.SetText("Cancel");
	PWSelectCancelButton.SetHelpText("Return to the Parental Lock main menu.");

	// OK button
	PWSelectOkButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	PWSelectOkButton.SetText("Ok");
	PWSelectOkButton.SetHelpText("Select this password.");

	bPWSelectWindowsCreated = true;
}

//==========================================================================================
//	HidePWSelectWindows
//==========================================================================================
function HidePWSelectWindows()
{
	PWSelectLabel.HideWindow();
	PWSelectEditBox.HideWindow();
	PWSelectCancelButton.HideWindow();
	PWSelectOkButton.HideWindow();
}

//==========================================================================================
//	ShowPasswordChangeWindows
//==========================================================================================
function ShowPasswordChangeWindows()
{
	UDukeParentLockWindow(ParentWindow.ParentWindow).WindowTitle = "Change Password ";

	if ( bPasswrdChangeWindowsCreated )
	{
		PWChange1Label.ShowWindow();
		PWChange1EditBox.ShowWindow();
		PWChange1EditBox.SetValue( "" );
		PWChange2Label.ShowWindow();
		PWChange2EditBox.ShowWindow();
		PWChange2EditBox.SetValue( "" );
		PWChange3Label.ShowWindow();
		PWChange3EditBox.ShowWindow();
		PWChange3EditBox.SetValue( "" );
		PWChangeOkButton.ShowWindow();
		PWChangeCancelButton.ShowWindow();
		PWChange1EditBox.BringToFront();
		return;
	}

	// Old passord
	PWChange1Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	PWChange1Label.SetText(PWChange1Text);
	PWChange1Label.SetHelpText(PWChange1Help);
	PWChange1Label.SetFont(F_Normal);
	PWChange1Label.Align = TA_Right;

	PWChange1EditBox = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1) );
	PWChange1EditBox.SetHelpText(PWChange1Help);
	PWChange1EditBox.SetMaxLength(40);
	PWChange1EditBox.SetNumericOnly( false );
	PWChange1EditBox.SetValueProtection( true );

	// New password
	PWChange2Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	PWChange2Label.SetText(PWChange2Text);
	PWChange2Label.SetHelpText(PWChange2Help);
	PWChange2Label.SetFont(F_Normal);
	PWChange2Label.Align = TA_Right;

	PWChange2EditBox = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1) );
	PWChange2EditBox.SetHelpText(PWChange2Help);
	PWChange2EditBox.SetMaxLength(40);
	PWChange2EditBox.SetNumericOnly( false );
	PWChange2EditBox.SetValueProtection( true );

	// Confirm new password
	PWChange3Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	PWChange3Label.SetText(PWChange3Text);
	PWChange3Label.SetHelpText(PWChange3Help);
	PWChange3Label.SetFont(F_Normal);
	PWChange3Label.Align = TA_Right;

	PWChange3EditBox = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1) );
	PWChange3EditBox.SetHelpText(PWChange3Help);
	PWChange3EditBox.SetMaxLength(40);
	PWChange3EditBox.SetNumericOnly( false );
	PWChange3EditBox.SetValueProtection( true );

	// Cancel button
	PWChangeCancelButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	PWChangeCancelButton.SetText("Cancel");
	PWChangeCancelButton.SetHelpText("Go back to the parental selection menu.");

	// Ok button
	PWChangeOkButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	PWChangeOkButton.SetText("OK");
	PWChangeOkButton.SetHelpText("Change to the new password.");

	PWChange1EditBox.BringToFront();

	bPasswrdChangeWindowsCreated = true;
}

//==========================================================================================
//	HidePasswordChangeWindows
//==========================================================================================
function HidePasswordChangeWindows()
{
	PWChange1Label.HideWindow();
	PWChange1EditBox.HideWindow();
	PWChange2Label.HideWindow();
	PWChange2EditBox.HideWindow();
	PWChange3Label.HideWindow();
	PWChange3EditBox.HideWindow();
	PWChangeOkButton.HideWindow();
	PWChangeCancelButton.HideWindow();
}

//==========================================================================================
//	UpdateParentalLockCheckBoxes
//==========================================================================================
function UpdateParentalLockCheckBoxes()
{
	if ( bSelectionWindowsCreated )
		AdultModeCheck.bChecked = !GetPlayerOwner().ParentalLockIsOn();
}

//==========================================================================================
//	ChangeWindowModes
//==========================================================================================
function ChangeWindowModes( EWindowMode Mode )
{
	if ( Mode == WMode_Default )
	{
		HidePasswordChangeWindows();
		HidePWSelectWindows();
		ShowSelectionWindows();
		ParentWindow.ParentWindow.SetSize( MainWidth, MainHeight );
	}
	else if ( Mode == WMode_PWSelect )
	{
		HidePasswordChangeWindows();
		HideSelectionWindows();
		ShowPWSelectWindows();
		ParentWindow.ParentWindow.SetSize( PWSelectWidth, PWSelectHeight );
	}
	else if ( Mode == WMode_PWChange )
	{
		HidePWSelectWindows();
		HideSelectionWindows();
		ShowPasswordChangeWindows();
		ParentWindow.ParentWindow.SetSize( PWChangeWidth, PWChangeHeight );
	}

	ParentWindow.ParentWindow.WinLeft = (Root.WinWidth - ParentWindow.ParentWindow.WinWidth) / 2;
	ParentWindow.ParentWindow.WinTop = (Root.WinHeight - ParentWindow.ParentWindow.WinHeight) / 2;

	CurrentMode = Mode;
}

//==========================================================================================
//	BeforePaint
//==========================================================================================
function BeforePaint( Canvas C, float X, float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint( C, X, Y );

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	if ( CurrentMode == WMode_Default )
	{
		ChangePasswordButton.AutoSize( C );

		AdultModeCheck.SetSize( ChangePasswordButton.WinWidth - 20, AdultModeCheck.WinHeight );
		AdultModeCheck.WinLeft = (WinWidth - AdultModeCheck.WinWidth) / 2;
		AdultModeCheck.WinTop = 10;

		ChangePasswordButton.WinLeft = (WinWidth - ChangePasswordButton.WinWidth) / 2;
		ChangePasswordButton.WinTop = AdultModeCheck.WinTop + AdultModeCheck.WinHeight + 10;
	}
	else if ( CurrentMode == WMode_PWSelect )
	{
		PWSelectEditBox.SetSize( 180, PWSelectEditBox.WinHeight );
		PWSelectLabel.SetSize( CenterWidth-140, PWSelectLabel.WinWidth );

		PWSelectEditBox.WinLeft = (WinWidth - (PWSelectEditBox.WinWidth + PWSelectLabel.WinWidth + 10)) / 2 + 10 + PWSelectLabel.WinWidth;
		PWSelectEditBox.WinTop = 10;
		PWSelectEditBox.EditBoxWidth = PWSelectEditBox.WinWidth;

		PWSelectLabel.WinLeft = (WinWidth - (PWSelectEditBox.WinWidth + PWSelectLabel.WinWidth + 10)) / 2;
		PWSelectLabel.WinTop = PWSelectEditBox.WinTop + 8;

		PWSelectOKButton.AutoSize( C );
		PWSelectCancelButton.AutoSize( C );

		PWSelectOKButton.WinLeft = (WinWidth - (PWSelectOKButton.WinWidth + PWSelectCancelButton.WinWidth + 10)) / 2;
		PWSelectOKButton.WinTop = PWSelectEditBox.WinTop + PWSelectEditBox.WinHeight + 10;

		PWSelectCancelButton.WinLeft = (WinWidth - (PWSelectOKButton.WinWidth + PWSelectCancelButton.WinWidth + 10)) / 2 + 10 + PWSelectOKButton.WinWidth;
		PWSelectCancelButton.WinTop = PWSelectEditBox.WinTop + PWSelectEditBox.WinHeight + 10;
	}
	else if ( CurrentMode == WMode_PWChange )
	{
		PWChange1EditBox.SetSize( 180, PWChange1EditBox.WinHeight );
		PWChange1EditBox.WinLeft = CColRight;
		PWChange1EditBox.WinTop = 10;
		PWChange1EditBox.EditBoxWidth = PWChange1EditBox.WinWidth;

		PWChange1Label.SetSize( CenterWidth-100, PWChange1Label.WinWidth );
		PWChange1Label.WinLeft = CColLeft - PWChange1Label.WinWidth;
		PWChange1Label.WinTop = PWChange1EditBox.WinTop + 8;

		PWChange2EditBox.SetSize( 180, PWChange2EditBox.WinHeight );
		PWChange2EditBox.WinLeft = CColRight;
		PWChange2EditBox.WinTop = PWChange1EditBox.WinTop + PWChange1EditBox.WinHeight + 10;
		PWChange2EditBox.EditBoxWidth = PWChange2EditBox.WinWidth;

		PWChange2Label.SetSize( CenterWidth-100, PWChange2Label.WinWidth );
		PWChange2Label.WinLeft = CColLeft - PWChange2Label.WinWidth;
		PWChange2Label.WinTop = PWChange2EditBox.WinTop + 8;

		PWChange3EditBox.SetSize( 180, PWChange3EditBox.WinHeight );
		PWChange3EditBox.WinLeft = CColRight;
		PWChange3EditBox.WinTop = PWChange2EditBox.WinTop + PWChange2EditBox.WinHeight + 10;
		PWChange3EditBox.EditBoxWidth = PWChange3EditBox.WinWidth;

		PWChange3Label.SetSize( CenterWidth-100, PWChange3Label.WinWidth );
		PWChange3Label.WinLeft = CColLeft - PWChange3Label.WinWidth;
		PWChange3Label.WinTop = PWChange3EditBox.WinTop + 8;

		PWChangeOKButton.AutoSize( C );
		PWChangeCancelButton.AutoSize( C );

		PWChangeOKButton.WinLeft = (WinWidth - (PWChangeOKButton.WinWidth + PWChangeCancelButton.WinWidth + 10)) / 2;
		PWChangeOKButton.WinTop = PWChange3EditBox.WinTop + PWChange3EditBox.WinHeight + 10;

		PWChangeCancelButton.WinLeft = (WinWidth - (PWChangeOKButton.WinWidth + PWChangeCancelButton.WinWidth + 10)) / 2 + 10 + PWChangeOKButton.WinWidth;
		PWChangeCancelButton.WinTop = PWChange3EditBox.WinTop + PWChange3EditBox.WinHeight + 10;
	}
}

//==========================================================================================
//	MessageBoxDone
//==========================================================================================
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	ParentWindow.ParentWindow.ShowWindow();

	if ( W == ConfirmInvalidPW && Result == MR_OK )
	{
		ChangeWindowModes( WMode_PWSelect );
		UpdateParentalLockCheckBoxes();
	}
}

//==========================================================================================
//	ChangePasswords
//==========================================================================================
function ChangePasswords()
{
	if ( PWChange2EditBox.GetValue() == PWChange3EditBox.GetValue() )
	{
		if ( GetPlayerOwner().SetParentalLockPassword(PWChange1EditBox.GetValue(), PWChange2EditBox.GetValue()) )
			ChangeWindowModes(WMode_Default);
		else
			MessageBox("Error ", "Incorrect password!", MB_OK, MR_OK, MR_OK);
	}
	else
		MessageBox("Error ", "The passwords do not match!", MB_OK, MR_OK, MR_OK);
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

	if ( GetPlayerOwner().ValidateParentalLockPassword("") )
		PW = "";
	else
		PW = PWSelectEditBox.GetValue();

	if ( GetPlayerOwner().SetParentalLockStatus(false, PW) )
		ChangeWindowModes(WMode_Default);
	else
		ConfirmInvalidPW = MessageBox("Error ", "Incorrect password!", MB_OK, MR_OK, MR_OK);

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
	else if (E == DE_Change && C == AdultModeCheck)
	{
		if ( AdultModeCheck.bChecked )
			TurnParentLockOffStep1();
		else
			TurnParentLockOn();
	}
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
	AdultModeText="Adult Mode"
	AdultModeHelp="Toggle adult content mode on or off."
	PWChange1Text="Old Password:"
	PWChange1Help="Enter your old password."
	PWChange2Text="New Password:"
	PWChange2Help="Enter your new password."
	PWChange3Text="Confirm Password:"
	PWChange3Help="Enter your new password again to confirm it."
	PWSelectText="Password:"
	PWSelectHelp="Enter your password to enable adult mode."
}