/*=============================================================================
	BuildOptions : Full options for rebuilding maps
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:
	- add in some way to cancel rebuilds

=============================================================================*/

class WDlgBuildOptions : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgBuildOptions,WDialog,DukeEd)

	// Variables.
	WButton BuildAllButton;
	WButton RefreshButton;
	WButton HideButton;
	WLabel GeomBrushesLabel, GeomZonesLabel;
	WLabel BSPPolysLabel, BSPNodesLabel, BSPRatioLabel, BSPMaxDepthLabel, BSPAvgDepthLabel;
	WLabel LightLightsLabel;

	// Constructor.
	WDlgBuildOptions( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog				( TEXT("Build Options"), IDDIALOG_BUILD_OPTIONS, InOwnerWindow )
	,	BuildAllButton	( this, IDPB_BUILD_SELECTED, FDelegate(this,(TDelegate)OnBuildAll) )
	,	RefreshButton		( this, IDPB_REFRESH, FDelegate(this,(TDelegate)OnRefresh) )
	,	HideButton			( this, IDPB_HIDE, FDelegate(this,(TDelegate)OnHide) )
	,	GeomBrushesLabel	( this, IDSC_BRUSHES )
	,	GeomZonesLabel		( this, IDSC_ZONES )
	,	BSPPolysLabel		( this, IDSC_POLYS )
	,	BSPNodesLabel		( this, IDSC_NODES )
	,	BSPRatioLabel		( this, IDSC_RATIO )
	,	BSPMaxDepthLabel	( this, IDSC_MAX_DEPTH )
	,	BSPAvgDepthLabel	( this, IDSC_AVG_DEPTH )
	,	LightLightsLabel	( this, IDSC_LIGHTS )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		SendMessageX( ::GetDlgItem( hWnd, IDCK_GEOMETRY), BM_SETCHECK, BST_CHECKED, 0);
		SendMessageX( ::GetDlgItem( hWnd, IDCK_BSP), BM_SETCHECK, BST_CHECKED, 0);
		SendMessageX( ::GetDlgItem( hWnd, IDCK_LIGHTING), BM_SETCHECK, BST_CHECKED, 0);
		SendMessageX( ::GetDlgItem( hWnd, IDCK_PATH_DEFINE), BM_SETCHECK, BST_CHECKED, 0);

		RefreshStats();
	}
	void Show( UBOOL Show )
	{
		WWindow::Show(Show);
		RefreshStats();
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual void DoModeless()
	{
		_Windows.AddItem( this );
		hWnd = CreateDialogParamA( hInstance, MAKEINTRESOURCEA(IDDIALOG_BUILD_OPTIONS), OwnerWindow?OwnerWindow->hWnd:NULL, (DLGPROC)StaticDlgProc, (LPARAM)this);
		if( !hWnd )
			appGetLastError();
		Show( TRUE );
	}
	void RefreshStats(void)
	{
		// GEOMETRY
		//
		FStringOutputDevice GetPropResult = FStringOutputDevice();

		GetPropResult.Empty();	GEditor->Get( TEXT("MAP"), TEXT("BRUSHES"), GetPropResult );
		GeomBrushesLabel.SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("MAP"), TEXT("ZONES"), GetPropResult );
		GeomZonesLabel.SetText( *GetPropResult );

		// BSP
		//
		INT iPolys, iNodes;
		GetPropResult.Empty();	GEditor->Get( TEXT("BSP"), TEXT("POLYS"), GetPropResult );	iPolys = appAtoi( *GetPropResult );
		BSPPolysLabel.SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("BSP"), TEXT("NODES"), GetPropResult );	iNodes = appAtoi( *GetPropResult );
		BSPNodesLabel.SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("BSP"), TEXT("MAXDEPTH"), GetPropResult );	iNodes = appAtoi( *GetPropResult );
		BSPMaxDepthLabel.SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("BSP"), TEXT("AVGDEPTH"), GetPropResult );	iNodes = appAtoi( *GetPropResult );
		BSPAvgDepthLabel.SetText( *GetPropResult );

		if(!iPolys)
			BSPRatioLabel.SetText( TEXT("N/A") );
		else
		{
			FLOAT fRatio = ((iPolys * 100) / (FLOAT)iNodes) / 100.0f;
			BSPRatioLabel.SetText( *(FString::Printf(TEXT("%1.1f:1"), fRatio)) );
		}

		// LIGHTING
		//
		GetPropResult.Empty();	GEditor->Get( TEXT("LIGHT"), TEXT("COUNT"), GetPropResult );
		LightLightsLabel.SetText( *GetPropResult );
	}
	void OnBuildAll()
	{
		if( SendMessageX( ::GetDlgItem( hWnd, IDCK_GEOMETRY), BM_GETCHECK, 0, 0 ) == BST_CHECKED )
			GEditor->Exec( TEXT("MAP REBUILD") );
		if( SendMessageX( ::GetDlgItem( hWnd, IDCK_BSP), BM_GETCHECK, 0, 0 ) == BST_CHECKED )
			GEditor->Exec( TEXT("BSP REBUILD OPTIMAL BALANCE=15 ZONES OPTGEOM") );
		if( SendMessageX( ::GetDlgItem( hWnd, IDCK_LIGHTING), BM_GETCHECK, 0, 0 ) == BST_CHECKED )
			GEditor->Exec( TEXT("LIGHT APPLY SELECTED=off") );
		if( SendMessageX( ::GetDlgItem( hWnd, IDCK_PATH_DEFINE), BM_GETCHECK, 0, 0 ) == BST_CHECKED )
			GEditor->Exec( TEXT("PATHS DEFINE") );
		RefreshStats();
	}
	void OnRefresh()
	{
		RefreshStats();
	}
	void OnHide()
	{
		Show( FALSE );
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
