/*=============================================================================
	BrushImport : Options for importing brushes
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

class WDlgBrushImport : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgBrushImport,WDialog,DukeEd)

	// Variables.
	WButton OkButton;
	WButton CancelButton;
	WCheckBox MergeCheck, SolidCheck, NonSolidCheck;

	FString Filename;

	// Constructor.
	WDlgBrushImport( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog			( TEXT("Brush Import"), IDDIALOG_IMPORT_BRUSH, InOwnerWindow )
	,	OkButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOk) )
	,	CancelButton	( this, IDCANCEL,		FDelegate(this,(TDelegate)EndDialogFalse) )
	,	MergeCheck		( this, IDCK_MERGE_FACES )
	,	SolidCheck		( this, IDRB_SOLID )
	,	NonSolidCheck	( this, IDRB_NONSOLID )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		SolidCheck.SetCheck( BST_CHECKED );
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
		GEditor->Exec( *FString::Printf(TEXT("BRUSH IMPORT FILE=\"%s\" MERGE=%d FLAGS=%d"),
			*Filename,
			MergeCheck.IsChecked(),
			SolidCheck.IsChecked() ? PF_NotSolid : 0) );
		GEditor->Level->Brush()->Brush->BuildBound();
		EndDialog(1);
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
