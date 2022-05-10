/*=============================================================================
	DlgBevel : Accepts the values for a surface bevel operation
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

INT GLastDepth = 16, GLastBevel = 16;
class WDlgBevel : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgBevel,WDialog,DukeEd)

	WButton OKButton, CancelButton;
	WEdit DepthEdit, BevelEdit;

	// Variables.
	INT Depth, Bevel;

	// Constructor.
	WDlgBevel( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog				( TEXT("Bevel"), IDDIALOG_SurfBevel, InOwnerWindow )
	,	CancelButton		( this, IDCANCEL, FDelegate(this,(TDelegate)EndDialogFalse) )
	,	OKButton			( this, IDOK, FDelegate(this,(TDelegate)OnOK) )
	,	DepthEdit			( this, IDEC_DEPTH )
	,	BevelEdit			( this, IDEC_BEVEL )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();
		DepthEdit.SetText( *FString::Printf(TEXT("%d"), GLastDepth ) );
		BevelEdit.SetText( *FString::Printf(TEXT("%d"), GLastBevel ) );
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual int DoModal()
	{
		return WDialog::DoModal( hInstance );
	}

	void OnOK()
	{
		GLastDepth = Depth = appAtoi( *DepthEdit.GetText() );
		GLastBevel = Bevel = appAtoi( *BevelEdit.GetText() );
		EndDialogTrue();
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
