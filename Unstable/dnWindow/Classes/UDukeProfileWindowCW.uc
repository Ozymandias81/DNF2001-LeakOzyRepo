//==========================================================================
// 
// FILE:			UDukeProfileWindowCW.uc
// 
// AUTHOR:			John Pollard
// 
// DESCRIPTION:		Login screen for the player
// 
//==========================================================================
class UDukeProfileWindowCW extends UDukeDialogClientWindow;
	//config(user);

var UWindowLabelControl		PlayerLabel;
var	UWindowComboControl		PlayerCombo;
var localized string		PlayerText;
var localized string		PlayerHelp;

var UWindowSmallButton		CreateButton;
var localized string		CreateText;
var localized string		CreateHelp;

var UWindowEditControl		EditControl;
var localized string		EditText;
var localized string		EditHelp;

var UWindowSmallButton		DeleteButton;
var localized string		DeleteText;
var localized string		DeleteHelp;

var UWindowSmallButton		AcceptButton;
var localized string		AcceptText;
var localized string		AcceptHelp;

var UWindowMessageBox		ConfirmDelete;
var UWindowMessageBox		ConfirmRelaunch;

var bool					bInNotify;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	// Build PlayerCombo box
	PlayerLabel = UWindowLabelControl( CreateControl(class'UWindowLabelControl', 1, 1, 1, 1) );
	PlayerLabel.SetText(PlayerText);
	PlayerLabel.SetFont(F_Normal);
	PlayerLabel.Align = TA_Right;

	PlayerCombo = UWindowComboControl( CreateControl(class'UWindowComboControl', 1, 1, 1, 1) );
	PlayerCombo.SetHelpText( PlayerHelp );
	PlayerCombo.SetEditable( false );
	PlayerCombo.Align = TA_Right;	

	BuildPlayerProfileNames();

	// Build Create Button
	CreateButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	CreateButton.SetText( CreateText );
	CreateButton.SetHelpText( CreateHelp );

	// Build the create edit control
	EditControl = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1) );
	EditControl.SetMaxLength(40);
	EditControl.SetHelpText( EditHelp );
	EditControl.SetNumericOnly( false );

	// Build delete button
	DeleteButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	DeleteButton.SetText( DeleteText );
	DeleteButton.SetHelpText( DeleteHelp );

	// Build accept button
	AcceptButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	AcceptButton.SetText( AcceptText );
	AcceptButton.SetHelpText( AcceptHelp );

	bInNotify = false;

	Super.Created();
}

function BeforePaint( canvas C, float X, float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint( C, X, Y );

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	PlayerCombo.SetSize( 200, PlayerCombo.WinHeight );
	PlayerLabel.AutoSize( C );

	PlayerCombo.WinLeft = (WinWidth - (PlayerCombo.WinWidth + PlayerLabel.WinWidth + 10)) / 2 + 10 + PlayerLabel.WinWidth;
	PlayerCombo.WinTop = 10;

	PlayerLabel.WinLeft = (WinWidth - (PlayerCombo.WinWidth + PlayerLabel.WinWidth + 10)) / 2;
	PlayerLabel.WinTop = PlayerCombo.WinTop + 8;

	CreateButton.AutoSize( C );
	EditControl.SetSize( WinWidth - CreateButton.WinWidth - 40, EditControl.WinHeight );

	CreateButton.WinLeft = (WinWidth - (CreateButton.WinWidth + EditControl.WinWidth + 10)) / 2;
	CreateButton.WinTop = PlayerCombo.WinTop + PlayerCombo.WinHeight + 10;

	EditControl.WinLeft = (WinWidth - (CreateButton.WinWidth + EditControl.WinWidth + 10)) / 2 + 10 + CreateButton.WinWidth;
	EditControl.WinTop = PlayerCombo.WinTop + PlayerCombo.WinHeight + 10 + (CreateButton.WinHeight - EditControl.WinHeight)/2;
	EditControl.EditBoxWidth = EditControl.WinWidth;

	DeleteButton.AutoSize( C );
	DeleteButton.WinWidth = (WinWidth / 2) - 20;
	AcceptButton.AutoSize( C );
	AcceptButton.WinWidth = (WinWidth / 2) - 20;

	DeleteButton.WinLeft = (WinWidth - (DeleteButton.WinWidth + AcceptButton.WinWidth + 10)) / 2 + 10 + AcceptButton.WinWidth;
	DeleteButton.WinTop = EditControl.WinTop + EditControl.WinHeight + 10;

	AcceptButton.WinLeft = (WinWidth - (DeleteButton.WinWidth + AcceptButton.WinWidth + 10)) / 2;
	AcceptButton.WinTop = EditControl.WinTop + EditControl.WinHeight + 10;
}

//==========================================================================================
//	BuildPlayerProfileNames
//==========================================================================================
function BuildPlayerProfileNames()
{
	local string	Current, First;

	PlayerCombo.Clear();

	Current = GetPlayerOwner().GetNextPlayerProfile("");
	First = Current;

	while (Current != "")
	{
		PlayerCombo.AddItem(Current);
		Current = GetPlayerOwner().GetNextPlayerProfile(Current);
	}

	Current = GetPlayerOwner().GetCurrentPlayerProfile();

	if (Current != "")
		PlayerCombo.SetValue(Current);
	else if (First != "")
		PlayerCombo.SetValue(First);
}

//==========================================================================================
//	MessageBoxDone
//==========================================================================================
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(W == ConfirmDelete && Result == MR_Yes)
	{
		if (GetPlayerOwner().DestroyPlayerProfile(PlayerCombo.GetValue()))
			BuildPlayerProfileNames();
	}
	else if (W == ConfirmRelaunch && Result == MR_Yes)
	{
		SwitchProfiles();
	}
}

//==========================================================================================
//	SwitchProfiles
//==========================================================================================
function bool SwitchProfiles()
{
	if (GetPlayerOwner().SwitchToPlayerProfile(PlayerCombo.GetValue()))
	{
		ParentWindow.HideWindow();
		UDukeDesktopWindow(OwnerWindow).ShowIcons();
	}
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

	if ((E == DE_Click && C == AcceptButton))
	{
		if (PlayerCombo.GetValue() != "")
		{
			if (GetPlayerOwner().ProfileSwitchNeedsRelaunch(PlayerCombo.GetValue()))
			{
				ConfirmRelaunch = MessageBox("Confirm Relaunch ", "Changing to this profile will require Duke Nukem Forever to relaunch.  Are you sure?                                        ", MB_YesNo, MR_No, MR_Yes);
			}
			else
			{
				SwitchProfiles();
			}
		}
	}
	else if (E == DE_Click && C == CreateButton)
	{
		if (EditControl.GetValue() != "")
		{
			if (GetPlayerOwner().CreatePlayerProfile(EditControl.GetValue()))
			{
				BuildPlayerProfileNames();
				PlayerCombo.SetValue(EditControl.GetValue());
				EditControl.SetValue("");
			}
		}
	}
	else if (E == DE_Click && C == DeleteButton)
	{
		if (PlayerCombo.GetValue() != "")
		{
			ConfirmDelete = MessageBox("Confirm Delete ", "Delete '"$PlayerCombo.GetValue()$"'?", MB_YesNo, MR_No, MR_Yes);	
		}
	}


    bInNotify = false;
}

defaultproperties
{
	PlayerText="Profile:"
	PlayerHelp="Select your player profile."
	CreateText="Create Player"
	CreateHelp="Create a new player profile."
	EditHelp="Enter the name of the player to create."
	DeleteText="Delete"
	DeleteHelp="Delete this player profile."
	AcceptText="Accept"
	AcceptHelp="Choose this player profile."
}