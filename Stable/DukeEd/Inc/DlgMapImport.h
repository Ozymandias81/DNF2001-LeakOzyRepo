/*=============================================================================
	MapImport : Options for importing maps
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

class WDlgMapImport : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgMapImport,WDialog,DukeEd)

	// Variables.
	WButton OkButton;
	WButton CancelButton;
	WCheckBox ImportIntoExistingCheck;

	FString Filename;
	UBOOL bImportIntoExistingCheck;

	// Constructor.
	WDlgMapImport( WWindow* InOwnerWindow )
	:	WDialog			( TEXT("Map Import"), IDDIALOG_IMPORT_MAP, InOwnerWindow )
	,	OkButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOk) )
	,	CancelButton	( this, IDCANCEL,		FDelegate(this,(TDelegate)EndDialogFalse) )
	,	ImportIntoExistingCheck		( this, IDCK_IMPORT_INTO_EXISTING)
	{
		bImportIntoExistingCheck = 0;
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual INT DoModal( FString _Filename )
	{
		Filename = _Filename;
		return WDialog::DoModal( hInstance );
	}
	void OnOk()
	{
		bImportIntoExistingCheck = ImportIntoExistingCheck.IsChecked();
		EndDialog(1);
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
