/*=============================================================================
	DlgRename : Accepts input of a new name for something
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

class WDlgRename : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgRename,WDialog,DukeEd)

	WButton OKButton, CancelButton;
	WEdit NameEdit;

	// Variables.
	FString OldName, NewName;

	// Constructor.
	WDlgRename( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog				( TEXT("Rename"), IDDIALOG_RENAME, InOwnerWindow )
	,	CancelButton		( this, IDCANCEL, FDelegate(this,(TDelegate)EndDialogFalse) )
	,	OKButton			( this, IDOK, FDelegate(this,(TDelegate)OnOK) )
	,	NameEdit			( this, IDEC_NAME )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();
		NameEdit.SetText( *OldName );
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual INT DoModal( FString InOldName )
	{
		NewName = OldName = InOldName;

		return WDialog::DoModal( hInstance );
	}

	void OnOK()
	{
		NewName = NameEdit.GetText();
		EndDialogTrue();
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
