/*=============================================================================
	BuildPropSheet : Property sheet for map rebuilding.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

// --------------------------------------------------------------
//
// WPageOptions
//
// --------------------------------------------------------------

class WPageOptions : public WPropertyPage
{
	DECLARE_WINDOWCLASS(WPageOptions,WPropertyPage,Window)

	WCheckBox *GeomCheck, *BuildOnlyVisibleCheck, *BSPCheck, *OptGeomCheck,
		*BuildVisibilityZonesCheck, *LightingCheck, *ApplySelectedCheck,
		*DefinePathsCheck, *OptimalButton;
	WGroupBox *GeomBox, *BSPBox, *OptimizationBox, *LightingBox, *DefinePathsBox;
	WButton *BuildPathsButton, *BuildButton, *LameButton, *GoodButton;
	WTrackBar *BalanceBar, *PortalBiasBar;
	WLabel *BalanceLabel, *PortalBiasLabel;

	// Structors.
	WPageOptions ( WWindow* InOwnerWindow )
	:	WPropertyPage( InOwnerWindow )
	{
		GeomCheck = BuildOnlyVisibleCheck = BSPCheck = OptGeomCheck
			= BuildVisibilityZonesCheck = LightingCheck = ApplySelectedCheck
			= DefinePathsCheck = OptimalButton = NULL;
		GeomBox = BSPBox = OptimizationBox = LightingBox = DefinePathsBox = NULL;
		BuildPathsButton = BuildButton = LameButton = GoodButton = NULL;
		BalanceBar = PortalBiasBar = NULL;
		BalanceLabel = PortalBiasLabel = NULL;
	}

	virtual void OpenWindow( INT InDlgId, HMODULE InHMOD )
	{
		WPropertyPage::OpenWindow( InDlgId, InHMOD );

		// Create child controls and let the base class determine their proper positions.
		GeomBox = new WGroupBox( this, IDGP_GEOM );
		GeomBox->OpenWindow( 1, 0 );
		BSPBox = new WGroupBox( this, IDGP_BSP );
		BSPBox->OpenWindow( 1, 0 );
		OptimizationBox = new WGroupBox( this, IDGP_OPTIMIZATION );
		OptimizationBox->OpenWindow( 1, 0 );
		LightingBox = new WGroupBox( this, IDGP_LIGHTING );
		LightingBox->OpenWindow( 1, 0 );
		DefinePathsBox = new WGroupBox( this, IDGP_PATHS );
		DefinePathsBox->OpenWindow( 1, 0 );
		GeomCheck = new WCheckBox( this, IDCK_GEOMETRY );
		GeomCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		BuildOnlyVisibleCheck = new WCheckBox( this, IDCK_ONLY_VISIBLE );
		BuildOnlyVisibleCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		BSPCheck = new WCheckBox( this, IDCK_BSP );
		BSPCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		OptGeomCheck = new WCheckBox( this, IDCK_OPT_GEOM );
		OptGeomCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		BuildVisibilityZonesCheck = new WCheckBox( this, IDCK_BUILD_VIS_ZONES );
		BuildVisibilityZonesCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		LightingCheck = new WCheckBox( this, IDCK_LIGHTING );
		LightingCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		ApplySelectedCheck = new WCheckBox( this, IDCK_SEL_LIGHTS_ONLY );
		ApplySelectedCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		DefinePathsCheck = new WCheckBox( this, IDCK_PATH_DEFINE );
		DefinePathsCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		OptimalButton = new WCheckBox( this, IDRB_OPTIMAL );
		OptimalButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		BuildPathsButton = new WButton( this, IDPB_BUILD_PATHS );
		BuildPathsButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		BuildButton = new WButton( this, IDPB_BUILD );
		BuildButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		LameButton = new WButton( this, IDRB_LAME );
		LameButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		GoodButton = new WButton( this, IDRB_GOOD );
		GoodButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		BalanceBar = new WTrackBar( this, IDSL_BALANCE );
		BalanceBar->OpenWindow( 1, 0 );
		PortalBiasBar = new WTrackBar( this, IDSL_PORTALBIAS );
		PortalBiasBar->OpenWindow( 1, 0 );
		BalanceLabel = new WLabel( this, IDSC_BALANCE );
		BalanceLabel->OpenWindow( 1, 0 );
		PortalBiasLabel = new WLabel( this, IDSC_PORTALBIAS );
		PortalBiasLabel->OpenWindow( 1, 0 );

		PlaceControl( GeomBox );
		PlaceControl( BSPBox );
		PlaceControl( OptimizationBox );
		PlaceControl( LightingBox );
		PlaceControl( DefinePathsBox );
		PlaceControl( GeomCheck );
		PlaceControl( BuildOnlyVisibleCheck );
		PlaceControl( BSPCheck );
		PlaceControl( OptGeomCheck );
		PlaceControl( BuildVisibilityZonesCheck );
		PlaceControl( LightingCheck );
		PlaceControl( ApplySelectedCheck );
		PlaceControl( DefinePathsCheck );
		PlaceControl( OptimalButton );
		PlaceControl( BuildPathsButton );
		PlaceControl( BuildButton );
		PlaceControl( LameButton );
		PlaceControl( GoodButton );
		PlaceControl( BalanceBar );
		PlaceControl( PortalBiasBar );
		PlaceControl( BalanceLabel );
		PlaceControl( PortalBiasLabel );

		Finalize();

		// Delegates.
		GeomCheck->ClickDelegate = FDelegate(this, (TDelegate)OnGeomClick);
		BSPCheck->ClickDelegate = FDelegate(this, (TDelegate)OnBSPClick);
		LightingCheck->ClickDelegate = FDelegate(this, (TDelegate)OnLightingClick);
		DefinePathsCheck->ClickDelegate = FDelegate(this, (TDelegate)OnDefinePathsClick);
		BuildButton->ClickDelegate = FDelegate(this, (TDelegate)OnBuildClick);
		BuildPathsButton->ClickDelegate = FDelegate(this, (TDelegate)OnBuildPathsClick);
		BalanceBar->ThumbTrackDelegate = FDelegate(this, (TDelegate)Refresh);
		BalanceBar->ThumbPositionDelegate = FDelegate(this, (TDelegate)Refresh);
		PortalBiasBar->ThumbTrackDelegate = FDelegate(this, (TDelegate)Refresh);
		PortalBiasBar->ThumbPositionDelegate = FDelegate(this, (TDelegate)Refresh);

		// Initialize controls.
		GeomCheck->SetCheck( BST_CHECKED );
		BSPCheck->SetCheck( BST_CHECKED );
		LightingCheck->SetCheck( BST_CHECKED );
		DefinePathsCheck->SetCheck( BST_CHECKED );

		OptimalButton->SetCheck( BST_CHECKED );
		OptGeomCheck->SetCheck( BST_CHECKED );
		BuildVisibilityZonesCheck->SetCheck( BST_CHECKED );

		BalanceBar->SetRange( 1, 100 );
		BalanceBar->SetTicFreq( 10 );
		BalanceBar->SetPos( 15 );

		PortalBiasBar->SetRange( 1, 100 );
		PortalBiasBar->SetTicFreq( 5 );
		PortalBiasBar->SetPos( 70 );

	}
	void OnDestroy()
	{
		::DestroyWindow( GeomBox->hWnd );
		::DestroyWindow( BSPBox->hWnd );
		::DestroyWindow( OptimizationBox->hWnd );
		::DestroyWindow( LightingBox->hWnd );
		::DestroyWindow( DefinePathsBox->hWnd );
		::DestroyWindow( GeomCheck->hWnd );
		::DestroyWindow( BuildOnlyVisibleCheck->hWnd );
		::DestroyWindow( BSPCheck->hWnd );
		::DestroyWindow( OptGeomCheck->hWnd );
		::DestroyWindow( BuildVisibilityZonesCheck->hWnd );
		::DestroyWindow( LightingCheck->hWnd );
		::DestroyWindow( ApplySelectedCheck->hWnd );
		::DestroyWindow( DefinePathsCheck->hWnd );
		::DestroyWindow( BuildPathsButton->hWnd );
		::DestroyWindow( BuildButton->hWnd );
		::DestroyWindow( LameButton->hWnd );
		::DestroyWindow( GoodButton->hWnd );
		::DestroyWindow( OptimalButton->hWnd );
		::DestroyWindow( BalanceBar->hWnd );
		::DestroyWindow( PortalBiasBar->hWnd );
		::DestroyWindow( BalanceLabel->hWnd );
		::DestroyWindow( PortalBiasLabel->hWnd );

		delete GeomBox;
		delete BSPBox;
		delete OptimizationBox;
		delete LightingBox;
		delete DefinePathsBox;
		delete GeomCheck;
		delete BuildOnlyVisibleCheck;
		delete BSPCheck;
		delete OptGeomCheck;
		delete BuildVisibilityZonesCheck;
		delete LightingCheck;
		delete ApplySelectedCheck;
		delete DefinePathsCheck;
		delete BuildPathsButton;
		delete BuildButton;
		delete LameButton;
		delete GoodButton;
		delete OptimalButton;
		delete BalanceBar;
		delete PortalBiasBar;
		delete BalanceLabel;
		delete PortalBiasLabel;

		WPropertyPage::OnDestroy();
	}
	virtual void Refresh()
	{
		BalanceLabel->SetText( *FString::Printf(TEXT("%d"), BalanceBar->GetPos() ) );
		PortalBiasLabel->SetText( *FString::Printf(TEXT("%d"), PortalBiasBar->GetPos() ) );

		UBOOL Checked;

		Checked = BSPCheck->IsChecked();
		EnableWindow( OptimizationBox->hWnd, Checked );
		EnableWindow( LameButton->hWnd, Checked );
		EnableWindow( GoodButton->hWnd, Checked );
		EnableWindow( OptimalButton->hWnd, Checked );
		EnableWindow( OptGeomCheck->hWnd, Checked );
		EnableWindow( BuildVisibilityZonesCheck->hWnd, Checked );
		EnableWindow( PortalBiasBar->hWnd, Checked );
		EnableWindow( PortalBiasLabel->hWnd, Checked );
		EnableWindow( BalanceBar->hWnd, Checked );
		EnableWindow( BalanceLabel->hWnd, Checked );
		EnableWindow( GetDlgItem( hWnd, IDSC_BSP_1), Checked );
		EnableWindow( GetDlgItem( hWnd, IDSC_BSP_2), Checked );
		EnableWindow( GetDlgItem( hWnd, IDSC_BSP_3), Checked );
		EnableWindow( GetDlgItem( hWnd, IDSC_BSP_4), Checked );

		Checked = LightingCheck->IsChecked();
		EnableWindow( ApplySelectedCheck->hWnd, Checked );
	}

	void OnGeomClick()
	{
		Refresh();
	}
	void OnBSPClick()
	{
		Refresh();
	}
	void OnLightingClick()
	{
		Refresh();
	}
	void OnDefinePathsClick()
	{
		Refresh();
	}
	void BuildGeometry()
	{
		if( GeomCheck->IsChecked() )
			GEditor->Exec( *FString::Printf(TEXT("MAP REBUILD VISIBLEONLY=%d"), BuildOnlyVisibleCheck->IsChecked() ) );
	}
	void BuildBSP()
	{
		if( BSPCheck->IsChecked() )
		{
			FString Cmd = TEXT("BSP REBUILD");
			if( LameButton->IsChecked() ) Cmd += TEXT(" LAME");
			else if( GoodButton->IsChecked() ) Cmd += TEXT(" GOOD");
			else if( OptimalButton->IsChecked() ) Cmd += TEXT(" OPTIMAL");
			if( OptGeomCheck->IsChecked() ) Cmd += TEXT(" OPTGEOM");
			if( BuildVisibilityZonesCheck->IsChecked() ) Cmd += TEXT(" ZONES");
			Cmd += FString::Printf(TEXT(" BALANCE=%d"), BalanceBar->GetPos() );
			Cmd += FString::Printf(TEXT(" PORTALBIAS=%d"), PortalBiasBar->GetPos() );

			GEditor->Exec( *Cmd );
		}
	}
	void BuildLighting()
	{
		if( LightingCheck->IsChecked() )
			GEditor->Exec( *FString::Printf(TEXT("LIGHT APPLY SELECTED=%d VISIBLEONLY=%d"),
				ApplySelectedCheck->IsChecked(), BuildOnlyVisibleCheck->IsChecked() ) );
	}
	void BuildPaths()
	{
		if( DefinePathsCheck->IsChecked() )
			GEditor->Exec( *FString::Printf( TEXT("PATHS DEFINE VISIBLEONLY=%d"), BuildOnlyVisibleCheck->IsChecked() ) );
	}
	void OnBuildClick()
	{
		BuildGeometry();
		BuildBSP();
		BuildLighting();
		BuildPaths();
	}
	void OnBuildPathsClick()
	{
		if( ::MessageBox( hWnd, TEXT("This command will erase all existing pathnodes and attempt to create a pathnode network on its own.  Are you sure this is what you want to do?\n\nNOTE : This process can take a VERY long time."), TEXT("Build Paths"), MB_YESNO) == IDYES )
			GEditor->Exec( TEXT("PATHS BUILD") );
	}
};

// --------------------------------------------------------------
//
// WPageLevelStats
//
// --------------------------------------------------------------

class WPageLevelStats : public WPropertyPage
{
	DECLARE_WINDOWCLASS(WPageLevelStats,WPropertyPage,Window)

	WGroupBox *GeomBox, *BSPBox, *LightingBox, *DefinePathsBox;
	WButton *RefreshButton;
	WLabel *BrushesLabel, *ZonesLabel, *PolysLabel, *NodesLabel,
		*RatioLabel, *MaxDepthLabel, *AvgDepthLabel, *LightsLabel;

	// Structors.
	WPageLevelStats ( WWindow* InOwnerWindow )
	:	WPropertyPage( InOwnerWindow )
	{
		GeomBox = BSPBox = LightingBox = DefinePathsBox = NULL;
		RefreshButton = NULL;
		BrushesLabel = ZonesLabel = PolysLabel = NodesLabel
			= RatioLabel = MaxDepthLabel = AvgDepthLabel = LightsLabel = NULL;
	}

	virtual void OpenWindow( INT InDlgId, HMODULE InHMOD )
	{
		WPropertyPage::OpenWindow( InDlgId, InHMOD );

		// Create child controls and let the base class determine their proper positions.
		GeomBox = new WGroupBox( this, IDGP_GEOM );
		GeomBox->OpenWindow( 1, 0 );
		BSPBox = new WGroupBox( this, IDGP_BSP );
		BSPBox->OpenWindow( 1, 0 );
		LightingBox = new WGroupBox( this, IDGP_LIGHTING );
		LightingBox->OpenWindow( 1, 0 );
		DefinePathsBox = new WGroupBox( this, IDGP_PATHS );
		DefinePathsBox->OpenWindow( 1, 0 );
		RefreshButton = new WButton( this, IDPB_REFRESH );
		RefreshButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		BrushesLabel = new WLabel( this, IDSC_BRUSHES );
		BrushesLabel->OpenWindow( 1, 0 );
		ZonesLabel = new WLabel( this, IDSC_ZONES );
		ZonesLabel->OpenWindow( 1, 0 );
		PolysLabel = new WLabel( this, IDSC_POLYS );
		PolysLabel->OpenWindow( 1, 0 );
		NodesLabel = new WLabel( this, IDSC_NODES );
		NodesLabel->OpenWindow( 1, 0 );
		RatioLabel = new WLabel( this, IDSC_RATIO );
		RatioLabel->OpenWindow( 1, 0 );
		MaxDepthLabel = new WLabel( this, IDSC_MAX_DEPTH );
		MaxDepthLabel->OpenWindow( 1, 0 );
		AvgDepthLabel = new WLabel( this, IDSC_AVG_DEPTH );
		AvgDepthLabel->OpenWindow( 1, 0 );
		LightsLabel = new WLabel( this, IDSC_LIGHTS );
		LightsLabel->OpenWindow( 1, 0 );

		PlaceControl( GeomBox );
		PlaceControl( BSPBox );
		PlaceControl( LightingBox );
		PlaceControl( DefinePathsBox );
		PlaceControl( RefreshButton );
		PlaceControl( BrushesLabel );
		PlaceControl( ZonesLabel );
		PlaceControl( PolysLabel );
		PlaceControl( NodesLabel );
		PlaceControl( RatioLabel );
		PlaceControl( MaxDepthLabel );
		PlaceControl( AvgDepthLabel );
		PlaceControl( LightsLabel );

		Finalize();

		// Delegates.
		RefreshButton->ClickDelegate = FDelegate(this, (TDelegate)Refresh);

		// Initialize controls.
	}
	void OnDestroy()
	{
		::DestroyWindow( GeomBox->hWnd );
		::DestroyWindow( BSPBox->hWnd );
		::DestroyWindow( LightingBox->hWnd );
		::DestroyWindow( DefinePathsBox->hWnd );
		::DestroyWindow( RefreshButton->hWnd );
		::DestroyWindow( BrushesLabel->hWnd );
		::DestroyWindow( ZonesLabel->hWnd );
		::DestroyWindow( PolysLabel->hWnd );
		::DestroyWindow( NodesLabel->hWnd );
		::DestroyWindow( RatioLabel->hWnd );
		::DestroyWindow( MaxDepthLabel->hWnd );
		::DestroyWindow( AvgDepthLabel->hWnd );
		::DestroyWindow( LightsLabel->hWnd );

		delete GeomBox;
		delete BSPBox;
		delete LightingBox;
		delete DefinePathsBox;
		delete RefreshButton;
		delete BrushesLabel;
		delete ZonesLabel;
		delete PolysLabel;
		delete NodesLabel;
		delete RatioLabel;
		delete MaxDepthLabel;
		delete AvgDepthLabel;
		delete LightsLabel;

		WPropertyPage::OnDestroy();
	}
	virtual void Refresh()
	{
		FStringOutputDevice GetPropResult = FStringOutputDevice();

		// GEOMETRY
		GetPropResult.Empty();	GEditor->Get( TEXT("MAP"), TEXT("BRUSHES"), GetPropResult );
		BrushesLabel->SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("MAP"), TEXT("ZONES"), GetPropResult );
		ZonesLabel->SetText( *GetPropResult );

		// BSP
		GetPropResult.Empty();	GEditor->Get( TEXT("BSP"), TEXT("POLYS"), GetPropResult );
		INT Polys = appAtoi( *GetPropResult );
		PolysLabel->SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("BSP"), TEXT("NODES"), GetPropResult );
		INT Nodes = appAtoi( *GetPropResult );
		NodesLabel->SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("BSP"), TEXT("MAXDEPTH"), GetPropResult );
		MaxDepthLabel->SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("BSP"), TEXT("AVGDEPTH"), GetPropResult );
		AvgDepthLabel->SetText( *GetPropResult );

		if(!Polys)
			RatioLabel->SetText(TEXT("N/A"));
		else
		{
			FLOAT Ratio = (Nodes / (FLOAT)Polys);
			RatioLabel->SetText( *FString::Printf( TEXT("%1.2f:1"), Ratio ) );
		}

		// LIGHTING
		GetPropResult.Empty();	GEditor->Get( TEXT("LIGHT"), TEXT("COUNT"), GetPropResult );
		LightsLabel->SetText( *GetPropResult );
	}
};

// --------------------------------------------------------------
//
// WBuildPropSheet
//
// --------------------------------------------------------------

class WBuildPropSheet : public WWindow
{
	DECLARE_WINDOWCLASS(WBuildPropSheet,WWindow,Window)

	WPropertySheet* PropSheet;
	WPageOptions* OptionsPage;
	WPageLevelStats* LevelStatsPage;

	// Structors.
	WBuildPropSheet( FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	{
	}

	// WBuildPropSheet interface.
	void OpenWindow()
	{
		MdiChild = 0;
		PerformCreateWindowEx
		(
			NULL,
			TEXT("Build Options"),
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
		PropSheet = new WPropertySheet( this, IDPS_BUILD );
		PropSheet->OpenWindow( 1, 0 );

		// Create the pages for the sheet
		OptionsPage = new WPageOptions( PropSheet->Tabs );
		OptionsPage->OpenWindow( IDPP_BUILD_OPTIONS, GetModuleHandleA("dukeed.exe") );
		PropSheet->AddPage( OptionsPage );

		LevelStatsPage = new WPageLevelStats( PropSheet->Tabs );
		LevelStatsPage->OpenWindow( IDPP_BUILD_STATS, GetModuleHandleA("dukeed.exe") );
		PropSheet->AddPage( LevelStatsPage );

		PropSheet->SetCurrent( 0 );

		// Resize the property sheet to surround the pages properly.
		RECT rect;
		::GetClientRect( OptionsPage->hWnd, &rect );
		::SetWindowPos( hWnd, HWND_TOP, 0, 0, rect.right + 32, rect.bottom + 64, SWP_NOMOVE );

		PositionChildControls();
	}
	void OnDestroy()
	{
		WWindow::OnDestroy();

		delete OptionsPage;
		delete LevelStatsPage;
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
