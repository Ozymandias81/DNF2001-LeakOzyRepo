/*=============================================================================
	Progress : Progress indicator
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:
	- cancel button needs to work

=============================================================================*/

class WDlgProgress : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgProgress,WDialog,DukeEd)

	WButton CancelButton;

	// Variables.

	// Constructor.
	WDlgProgress( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog				( TEXT("Progress"), IDDIALOG_PROGRESS, InOwnerWindow )
	,	CancelButton		( this, IDPB_CANCEL, FDelegate(this,(TDelegate)OnCancel) )
	{
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
	virtual void DoModeless()
	{
		_Windows.AddItem( this );
		hWnd = CreateDialogParamA( hInstance, MAKEINTRESOURCEA(IDDIALOG_PROGRESS), OwnerWindow?OwnerWindow->hWnd:NULL, (DLGPROC)StaticDlgProc, (LPARAM)this);
		if( !hWnd )
			appGetLastError();
	}
	void OnCancel()
	{
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
