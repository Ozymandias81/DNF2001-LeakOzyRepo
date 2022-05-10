/*=============================================================================
	TerrainEditSheet : Property sheet for terrain editing
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

// --------------------------------------------------------------
//
// WPageSoftSelection
//
// --------------------------------------------------------------

class WPageSoftSelection : public WPropertyPage
{
	DECLARE_WINDOWCLASS(WPageSoftSelection,WPropertyPage,Window)

	WGroupBox *SoftSelectionBox, *MiscBox;
	WEdit *RadiusEdit;
	WButton *SelectButton, *DeselectButton, *ShowGridButton, *ResetMoveButton, *DeselectAllButton;

	// Structors.
	WPageSoftSelection ( WWindow* InOwnerWindow )
	:	WPropertyPage( InOwnerWindow )
	{
		SoftSelectionBox = MiscBox = NULL;
		RadiusEdit = NULL;
		SelectButton = DeselectButton = ShowGridButton = ResetMoveButton = DeselectAllButton = NULL;
	}

	virtual void OpenWindow( INT InDlgId, HMODULE InHMOD )
	{
		WPropertyPage::OpenWindow( InDlgId, InHMOD );

		// Create child controls and let the base class determine their proper positions.
		SoftSelectionBox = new WGroupBox( this, IDGP_SOFT_SELECTION );
		SoftSelectionBox->OpenWindow( 1, 0 );
		MiscBox = new WGroupBox( this, IDGP_MISC );
		MiscBox->OpenWindow( 1, 0 );
		SelectButton = new WButton( this, IDPB_SELECT);
		SelectButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		DeselectButton = new WButton( this, IDPB_DESELECT);
		DeselectButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		ShowGridButton = new WButton( this, IDPB_SHOWGRID);
		ShowGridButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		ResetMoveButton = new WButton( this, IDPB_RESETMOVE);
		ResetMoveButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		DeselectAllButton = new WButton( this, IDPB_DESELECT_ALL);
		DeselectAllButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		RadiusEdit = new WEdit( this, IDEC_RADIUS );
		RadiusEdit->OpenWindow( 1, 0, 0 );

		PlaceControl( SoftSelectionBox );
		PlaceControl( MiscBox );
		PlaceControl( SelectButton );
		PlaceControl( DeselectButton );
		PlaceControl( ShowGridButton );
		PlaceControl( ResetMoveButton );
		PlaceControl( DeselectAllButton );
		PlaceControl( RadiusEdit );

		Finalize();

		RadiusEdit->SetText(TEXT("1024"));

		// Delegates.
		SelectButton->ClickDelegate = FDelegate(this, (TDelegate)OnSelectClicked);
		DeselectButton->ClickDelegate = FDelegate(this, (TDelegate)OnDeselectClicked);
		ShowGridButton->ClickDelegate = FDelegate(this, (TDelegate)OnShowGridClicked);
		ResetMoveButton->ClickDelegate = FDelegate(this, (TDelegate)OnResetMoveClicked);
		DeselectAllButton->ClickDelegate = FDelegate(this, (TDelegate)OnDeselectAllClicked);
	}
	void OnDestroy()
	{
		::DestroyWindow( SoftSelectionBox->hWnd );
		::DestroyWindow( MiscBox->hWnd );
		::DestroyWindow( SelectButton->hWnd );
		::DestroyWindow( DeselectButton->hWnd );
		::DestroyWindow( ShowGridButton->hWnd );
		::DestroyWindow( ResetMoveButton->hWnd );
		::DestroyWindow( DeselectAllButton->hWnd );
		::DestroyWindow( RadiusEdit->hWnd );

		delete SoftSelectionBox;
		delete MiscBox;
		delete SelectButton;
		delete DeselectButton;
		delete ShowGridButton;
		delete ResetMoveButton;
		delete DeselectAllButton;
		delete RadiusEdit;

		WPropertyPage::OnDestroy();
	}
	void OnSelectClicked()
	{
		INT Radius = appAtoi( *RadiusEdit->GetText() );
		GEditor->Exec( *FString::Printf( TEXT("TERRAIN SOFTSELECT RADIUS=%d"), Radius ) );
		GEditor->RedrawLevel( GEditor->Level );
	}
	void OnDeselectClicked()
	{
		GEditor->Exec( TEXT("TERRAIN SOFTDESELECT") );
		GEditor->RedrawLevel( GEditor->Level );
	}
	void OnShowGridClicked()
	{
		GEditor->Exec( TEXT("TERRAIN SHOWGRID") );
		GEditor->RedrawLevel( GEditor->Level );
	}
	void OnResetMoveClicked()
	{
		GEditor->Exec( TEXT("TERRAIN RESETMOVE") );
		GEditor->RedrawLevel( GEditor->Level );
	}
	void OnDeselectAllClicked()
	{
		GEditor->Exec( TEXT("TERRAIN DESELECT") );
		GEditor->RedrawLevel( GEditor->Level );
	}
};

// --------------------------------------------------------------
//
// WTerrainEditSheet
//
// --------------------------------------------------------------

class WTerrainEditSheet : public WWindow
{
	DECLARE_WINDOWCLASS(WTerrainEditSheet,WWindow,Window)

	WPropertySheet* PropSheet;
	WPageSoftSelection* SoftSelectionPage;

	// Structors.
	WTerrainEditSheet( FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	{
	}

	// WTerrainEditSheet interface.
	void OpenWindow()
	{
		MdiChild = 0;
		PerformCreateWindowEx
		(
			NULL,
			TEXT("Terrain Editing"),
			WS_OVERLAPPED | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
			0, 0,
			0, 0,
			OwnerWindow ? OwnerWindow->hWnd : NULL,
			NULL,
			hInstance
		); 
	}
	void OnCreate()
	{
		WWindow::OnCreate();

		// Create the sheet
		PropSheet = new WPropertySheet( this, IDPS_SURFACE_PROPS );
		PropSheet->OpenWindow( 1, 0 );

		// Create the pages for the sheet
		SoftSelectionPage = new WPageSoftSelection( PropSheet->Tabs );
		SoftSelectionPage->OpenWindow( IDPP_TE_SELECTION, GetModuleHandleA("dukeed.exe") );
		PropSheet->AddPage( SoftSelectionPage );

		PropSheet->SetCurrent( 0 );

		// Resize the property sheet to surround the pages properly.
		RECT rect;
		::GetClientRect( SoftSelectionPage->hWnd, &rect );
		::SetWindowPos( hWnd, HWND_TOP, 0, 0, rect.right + 32, rect.bottom + 64, SWP_NOMOVE );

		PositionChildControls();
	}
	void OnDestroy()
	{
		WWindow::OnDestroy();

		delete SoftSelectionPage;
		delete PropSheet;
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WWindow::OnSize(Flags, NewX, NewY);
		PositionChildControls();
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void PositionChildControls()
	{
		if( !PropSheet || !::IsWindow( PropSheet->hWnd )
				)
			return;

		FRect CR = GetClientRect();
		::MoveWindow( PropSheet->hWnd, 0, 0, CR.Width(), CR.Height(), 1 );
	}
	INT OnSysCommand( INT Command )
	{
		if( Command == SC_CLOSE )
		{
			Show(0);
			return 1;
		}

		return 0;
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/