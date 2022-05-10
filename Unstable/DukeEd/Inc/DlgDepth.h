/*=============================================================================
	DlgDepth : Accepts the depth value for a brush extrusion
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

class WDlgDepth : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgDepth,WDialog,DukeEd)

	WButton OKButton, CancelButton;
	WEdit DepthEdit;

	// Variables.
	INT Depth;

	// Constructor.
	WDlgDepth( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog				( TEXT("Depth"), IDDIALOG_Depth, InOwnerWindow )
	,	CancelButton		( this, IDCANCEL, FDelegate(this,(TDelegate)EndDialogFalse) )
	,	OKButton			( this, IDOK, FDelegate(this,(TDelegate)OnOK) )
	,	DepthEdit			( this, IDEC_DEPTH )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();
		DepthEdit.SetText( TEXT("256") );
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual INT DoModal()
	{
		return WDialog::DoModal( hInstance );
	}

	void OnOK()
	{
		Depth = appAtoi( *DepthEdit.GetText() );
		EndDialogTrue();
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
