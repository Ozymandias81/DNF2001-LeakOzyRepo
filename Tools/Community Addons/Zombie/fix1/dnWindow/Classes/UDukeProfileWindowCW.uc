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

var	UWindowComboControl		PlayerCombo;

var UWindowSmallButton		AcceptButton;
var UWindowSmallButton		CreateButton;
var UWindowEditControl		EditControl;
var UWindowSmallButton		DeleteButton;

var UWindowMessageBox		ConfirmDelete;
var UWindowMessageBox		ConfirmRelaunch;

var bool					bInNotify;

//==========================================================================================
//	Created
//==========================================================================================
function Created() 
{
	local float		ControlPosX, ControlPosY;

	ControlPosX = 15.0f;
	ControlPosY = 10.0f;

	// Build PlayerCombo box
	PlayerCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 
													ControlPosX, 
													ControlPosY,
													170, 
													1));
	
	PlayerCombo.SetText("Player:");
	PlayerCombo.SetHelpText("Select your player profile here.");
	PlayerCombo.SetEditable( false );
	
	//PlayerCombo.SetSize( 100, 1 );
	//PlayerCombo.WinLeft	= ControlPosX+40.0;
	PlayerCombo.EditBoxWidth = 115;

	BuildPlayerProfileNames();

	// Build Create Button
	ControlPosY += 25.0f;

	CreateButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', ControlPosX, ControlPosY, 64, 16 ) );
	CreateButton.SetText("Create Player");
	CreateButton.SetHelpText("Create a new player profile.");

	ControlPosX += 70.0f;

	// Build the create edit control
	EditControl = UWindowEditControl(	CreateControl(class'UWindowEditControl', 
										ControlPosX, 
										ControlPosY, 
										100, 
										1));

	//EditControl.SetText("");
	EditControl.SetMaxLength(40);
	EditControl.SetHelpText("Enter the name of the player to create here.");
	EditControl.SetNumericOnly( false );

	EditControl.SetSize( 100, 1 );
	EditControl.WinLeft	= ControlPosX;
	EditControl.EditBoxWidth = 100;

	ControlPosX -= 70.0f;

	// Build Create Button
	ControlPosY += 25.0f;

	DeleteButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', ControlPosX, ControlPosY, 170, 16 ) );
	DeleteButton.SetText("Delete Player");
	DeleteButton.SetHelpText("Delete this player profile.");

	// Build Accept Button
	ControlPosY += 25.0f;

	AcceptButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', ControlPosX, ControlPosY, 170, 16 ) );
	AcceptButton.SetText("Accept");
	AcceptButton.SetHelpText("Choose this player profile.");

	bInNotify = false;

	Super.Created();

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
	ParentWindow.ShowWindow();

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
		UDukeDesktopWindow(OwnerWindow).ShowMenuBar();
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
				ParentWindow.HideWindow();
				ConfirmRelaunch = MessageBox("Confirm Relaunch", "Changing to this profile will require Duke Nukem Forever to Relaunch.  Are you sure?                                        ", MB_YesNo, MR_No, MR_Yes);
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
			ParentWindow.HideWindow();
			ConfirmDelete = MessageBox("Confirm Delete", "Delete '"@PlayerCombo.GetValue()@"'?", MB_YesNo, MR_No, MR_Yes);	
		}
	}


    bInNotify = false;
}

defaultproperties
{
}
