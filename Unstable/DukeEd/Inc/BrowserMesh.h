/*=============================================================================
	BrowserMesh : Browser window for meshes
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:
=============================================================================*/

__declspec(dllimport) INT GLastScroll;

extern void Query( ULevel* Level, const TCHAR* Item, FString* pOutput );
extern void ParseStringToArray( const TCHAR* pchDelim, FString String, TArray<FString>* _pArray);

extern HWND GhwndEditorFrame;

extern FString GLastDir[eLASTDIR_MAX];

// --------------------------------------------------------------
//
// NEW MESH Dialog
//
// --------------------------------------------------------------

class WDlgNewMesh : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgNewMesh,WDialog,DukeEd)

	// Variables.
	WButton OkButton;
	WButton CancelButton;
	WEdit PackageEdit;
	WEdit GroupEdit;
	WEdit NameEdit;
	WComboBox ClassCombo;

	FString defPackage, defGroup;
	TArray<FString>* paFilenames;

	FString Package, Group, Name;

	// Constructor.
	WDlgNewMesh( UObject* InContext, WBrowser* InOwnerWindow )
	:	WDialog			( TEXT("New Mesh"), IDDIALOG_NEW_MESH, InOwnerWindow )
	,	OkButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOk) )
	,	CancelButton	( this, IDCANCEL,		FDelegate(this,(TDelegate)EndDialogFalse) )
	,	PackageEdit		( this, IDEC_PACKAGE_MESH )
	,	GroupEdit		( this, IDEC_GROUP_MESH )
	,	NameEdit		( this, IDEC_NAME_MESH )
	,	ClassCombo		( this, IDCB_CLASS_MESH )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		PackageEdit.SetText( *defPackage );
		GroupEdit.SetText( *defGroup );
		::SetFocus( NameEdit.hWnd );

		FString Classes;

		Query( GEditor->Level, TEXT("GETCHILDREN CLASS=DUKEMESH CONCRETE=1"), &Classes);

		TArray<FString> Array;
		ParseStringToArray( TEXT(","), Classes, &Array );

		for( INT x = 0 ; x < Array.Num() ; x++ )
		{
			ClassCombo.AddString( *(Array(x)) );
		}
		ClassCombo.SetCurrent(0);

		PackageEdit.SetText( *defPackage );
		GroupEdit.SetText( *defGroup );

	}
	void OnDestroy()
	{
		WDialog::OnDestroy();
	}
	virtual INT DoModal( FString _defPackage, FString _defGroup)
	{
		defPackage = _defPackage;
		defGroup = _defGroup;

		return WDialog::DoModal( hInstance );
	}
	void OnOk()
	{
		if( GetDataFromUser() )
		{
			GEditor->Exec( *(FString::Printf( TEXT("MESH CREATE NAME=\"%s\" GROUP=\"%s\" PACKAGE=\"%s\""),
				*NameEdit.GetText(), *GroupEdit.GetText(), *PackageEdit.GetText() )));
			EndDialog(TRUE);
		}
	}
	BOOL GetDataFromUser( void )
	{
		Package = PackageEdit.GetText();
		Group = GroupEdit.GetText();
		Name = NameEdit.GetText();

		if( !Package.Len() || !Name.Len() )
		{
			appMsgf( TEXT("Invalid input.") );
			return FALSE;
		}

		return TRUE;
	}
};

// --------------------------------------------------------------
// WBrowserMesh
// --------------------------------------------------------------
#define ID_MESH_TOOLBAR	29050
TBBUTTON tbMESHButtons[] = {
	{ 0, IDMN_MB_DOCK, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0},
	{ 1, IDMN_CF_FIND, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
};
struct {
	TCHAR ToolTip[64];
	INT ID;
} ToolTips_MESH[] = {
	TEXT("Toggle Dock Status"), IDMN_MB_DOCK,
	TEXT("Find"), IDMN_CF_FIND,
	NULL, 0
};

class WSequenceFrame : public WDialog
{
	DECLARE_WINDOWCLASS(WSequenceFrame,WDialog,Window)

	WComboBox		PackageCombo;
	WComboBox		GroupCombo;
	WComboBox		MeshCombo;
	WComboBox		AnimCombo;
	WButton			PlayButton;
	WButton			ForwardButton;
	WButton			BackButton;
	WButton			RenDevButton;
	WButton			ConfigButton;
	WEdit			ConfigEdit;
	UBOOL			Direct3D;

	INT				CurrentFrame;
	INT				FrameCount;
	UBOOL			PlayingAnim;

	UViewport*		MeshViewport;

	TMap<FName,INT>	Sequences;

	WSequenceFrame( FName InPersistentName, INT InDialogId, WWindow* InOwnerWindow )
	:	WDialog( InPersistentName, InDialogId, InOwnerWindow )
	,	PackageCombo( this, IDC_COMBO_PACKAGE )
	,	GroupCombo( this, IDC_COMBO_GROUP )
	,   MeshCombo( this, IDC_COMBO_MESH )
	,	AnimCombo( this, IDC_COMBO_SEQUENCE )
	,	PlayButton( this, IDC_BUTTON_PLAYANIM )
	,	ForwardButton( this, IDC_BUTTON_FORWARD )
	,	BackButton( this, IDC_BUTTON_BACK )
	,	RenDevButton( this, IDC_BUTTON_MESHRENDEV )
	,	ConfigButton( this, IDC_BUTTON_CONFIG )
	,	ConfigEdit( this, IDC_EDIT_CONFIG )
	,	Direct3D( FALSE )
	,	CurrentFrame( 0 )
	,	FrameCount( 0 )
	,	PlayingAnim( FALSE )
	,	MeshViewport( NULL )
	{ }

	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual void DoModeless()
	{
		_Windows.AddItem( this );
		hWnd = CreateDialogParamA( hInstance, MAKEINTRESOURCEA(IDDIALOG_SEQ_FRAME), OwnerWindow?OwnerWindow->hWnd:NULL, (DLGPROC)StaticDlgProc, (LPARAM)this);
		if( !hWnd )
			appGetLastError();
		Show(1);
	}
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		PackageCombo.SelectionChangeDelegate = FDelegate(this, (TDelegate)OnPackageSelChange);
		GroupCombo.SelectionChangeDelegate = FDelegate(this, (TDelegate)OnGroupSelChange);
		MeshCombo.SelectionChangeDelegate = FDelegate(this, (TDelegate)OnMeshSelChange);
		AnimCombo.SelectionChangeDelegate = FDelegate(this, (TDelegate)OnAnimSelChange);
		PlayButton.ClickDelegate = FDelegate(this, (TDelegate)OnPlayClick);
		ForwardButton.ClickDelegate = FDelegate(this, (TDelegate)OnForwardClick);
		BackButton.ClickDelegate = FDelegate(this, (TDelegate)OnBackClick);
		RenDevButton.ClickDelegate = FDelegate(this, (TDelegate)OnRenDevChange);
		ConfigButton.ClickDelegate = FDelegate(this, (TDelegate)OnConfigClick);

		::EnableWindow( ConfigEdit.hWnd, 0 );

		RefreshPackages();
		RefreshGroups();
	}
	void RefreshPackages()
	{
		FStringOutputDevice GetPropResult = FStringOutputDevice();
		GEditor->Get( TEXT("OBJ"), TEXT("PACKAGES CLASS=Mesh"), GetPropResult );

		TArray<FString> StringArray;
		ParseStringToArray( TEXT(","), *GetPropResult, &StringArray );

		PackageCombo.Empty();
		for( INT x = 0 ; x < StringArray.Num() ; x++ )
			PackageCombo.AddString( *(StringArray(x)) );
		PackageCombo.SetCurrent( 0 );
	}
	void RefreshGroups()
	{
		FString Package = PackageCombo.GetString( PackageCombo.GetCurrent() );

		FStringOutputDevice GetPropResult = FStringOutputDevice();
		TCHAR l_ch[256];
		appSprintf( l_ch, TEXT("GROUPS CLASS=Mesh PACKAGE=\"%s\""), *Package );
		GEditor->Get( TEXT("OBJ"), l_ch, GetPropResult );

		TArray<FString> StringArray;
		ParseStringToArray( TEXT(","), *GetPropResult, &StringArray );

		GroupCombo.Empty();
		GroupCombo.AddString( TEXT("[All Meshes]") );
		for( INT x = 0 ; x < StringArray.Num() ; x++ )
		{
			if ( StringArray(x) != FString(_T("")) )
				GroupCombo.AddString( *(StringArray(x)) );
		}
		GroupCombo.SetCurrent( 0 );
	}
	void RefreshMeshList( UBOOL GetNewMesh = FALSE )
	{
		FString Package = PackageCombo.GetString( PackageCombo.GetCurrent() );
		FString Group = GroupCombo.GetString( GroupCombo.GetCurrent() );

		if (Group == TEXT("[All Meshes]"))
			Group = FString(TEXT(""));

		CurrentFrame = 0;

		FStringOutputDevice GetPropResult = FStringOutputDevice();
		TCHAR QueryString[256];
		appSprintf( QueryString, TEXT("Query Type=Mesh Package=\"%s\" GROUP=\"%s\""), *Package, *Group );
		GEditor->Get( TEXT("OBJ"), QueryString, GetPropResult );

		MeshCombo.Empty();

		TArray<FString> StringArray;
		ParseStringToArray( TEXT(" "), *GetPropResult, &StringArray );

		for( INT x = 0 ; x < StringArray.Num() ; x++ )
			MeshCombo.AddString( *(StringArray(x)) );

		MeshCombo.SetCurrent(0);

		if ( GetNewMesh )
		{
			FString MeshName = MeshCombo.GetString( MeshCombo.GetCurrent() );
			GEditor->Exec( *(FString::Printf(TEXT("CAMERA UPDATE NAME=MeshViewer MESH=\"%s\""), *MeshName)) );
		}
		SendMessageLX( OwnerWindow->hWnd, WM_COMMAND, IDMN_REFRESH, 0 );
		RefreshAnimList();
	}
	void RefreshAnimList()
	{
		if (!MeshViewport || !MeshViewport->Actor || !MeshViewport->MiscRes)
			return;

		// Get a duke mesh pointer
		UDukeMesh* DukeMesh = (UDukeMesh*) MeshViewport->MiscRes;
		ConfigEdit.SetText( *DukeMesh->ConfigName );

		// Get a mesh instance.
		UDukeMeshInstance* MeshInst = (UDukeMeshInstance*) DukeMesh->GetInstance( MeshViewport->Actor );

		// Get any normal animations.
		AnimCombo.Empty();
		if ( MeshInst->Mac->mSequences.GetCount() > 0 )
		{
			for ( DWORD i=0; i<MeshInst->Mac->mSequences.GetCount(); i++ )
			{
				AnimCombo.AddString( appFromAnsi(MeshInst->Mac->mSequences[i]->GetName()) );
			}
			::EnableWindow( AnimCombo.hWnd, 1 );
			::EnableWindow( PlayButton.hWnd, 1 );
			::EnableWindow( ForwardButton.hWnd, 1 );
			::EnableWindow( BackButton.hWnd, 1 );
			AnimCombo.SetCurrent(0);
			OnAnimSelChange();
		}
		else 
		{
			// Load the configuration and get skeletal animations.
			OCpjConfig* Config = OCpjConfig::New( NULL );
			TCHAR FileName[256];
			appStrcpy( FileName, _T("..\\Meshes\\") );
			appStrcat( FileName, *DukeMesh->ConfigName );
			TCHAR* Xtra = appStrstr( FileName, _T("cpj\\") );
			Xtra += 3;
			if (Xtra) *Xtra = _T('\0');
			debugf( TEXT("Attempting to load Cannibal project %s"), FileName );
			if (Config->LoadFile( (char*) appToAnsi(FileName) ))
			{
				debugf( TEXT("Cannibal project loaded.") );
				MeshInst->Mac->LoadConfig( Config );
				INT NumSequences = MeshInst->GetNumSequences();

				::EnableWindow( AnimCombo.hWnd, NumSequences );
				::EnableWindow( PlayButton.hWnd, NumSequences );
				::EnableWindow( ForwardButton.hWnd, NumSequences );
				::EnableWindow( BackButton.hWnd, NumSequences );

				// Fill the anim combo.
				Sequences.Empty();
				if ( NumSequences )
					for ( INT i=0; i<NumSequences; i++ )
					{
						FName SequenceName = MeshInst->GetSeqName( MeshInst->GetSequence(i) );
						Sequences.Set( SequenceName, i );
						AnimCombo.AddString( *SequenceName );
					}
				else
					AnimCombo.AddString( _T("No Sequences") );
				AnimCombo.SetCurrent(0);
				OnAnimSelChange();
			} else {
				::EnableWindow( AnimCombo.hWnd, 0 );
				::EnableWindow( PlayButton.hWnd, 0 );
				::EnableWindow( ForwardButton.hWnd, 0 );
				::EnableWindow( BackButton.hWnd, 0 );
				Sequences.Empty();
				AnimCombo.AddString( _T("Failed to load project.") );
				AnimCombo.SetCurrent(0);
				debugf( TEXT("Failed to load Cannibal project.") );
			}
			Config->Destroy();
		}
	}
	FString GetCurrentMeshName()
	{
		if ( MeshViewport )
		{
			// Set the config tag.
			UDukeMesh* DukeMesh = (UDukeMesh*) MeshViewport->MiscRes;
			ConfigEdit.SetText( *DukeMesh->ConfigName );
		}

		return MeshCombo.GetString( MeshCombo.GetCurrent() );
	}
	FName GetCurrentAnimSequence()
	{
		if ( !MeshViewport || !MeshViewport->Actor || !MeshViewport->MiscRes )
			return 0;

		if ( ::IsWindowEnabled(AnimCombo.hWnd) )
		{
			// Get a duke mesh pointer
			UDukeMesh* DukeMesh = (UDukeMesh*) MeshViewport->MiscRes;

			// Get a mesh instance.
			UDukeMeshInstance* MeshInst = (UDukeMeshInstance*) DukeMesh->GetInstance( MeshViewport->Actor );

			FString SequenceName = AnimCombo.GetString(AnimCombo.GetCurrent());
			return *SequenceName;
		} else
			return NAME_None;
	}
	void OnPackageSelChange()
	{
		RefreshGroups();
		RefreshMeshList();
	}
	void OnGroupSelChange()
	{
		RefreshMeshList();
	}
	void OnMeshSelChange()
	{
		SendMessageLX( OwnerWindow->hWnd, WM_COMMAND, IDMN_REFRESH, 0 );
		RefreshAnimList();
	}
	void OnAnimSelChange()
	{
		if ( !MeshViewport || !MeshViewport->Actor || !MeshViewport->MiscRes )
			return;

		if ( ::IsWindowEnabled(AnimCombo.hWnd) )
		{
			// Get a duke mesh pointer
			UDukeMesh* DukeMesh = (UDukeMesh*) MeshViewport->MiscRes;

			// Get a mesh instance.
			UDukeMeshInstance* MeshInst = (UDukeMeshInstance*) DukeMesh->GetInstance( MeshViewport->Actor );

			// Get the sequence.
			FString SequenceName = AnimCombo.GetString(AnimCombo.GetCurrent());
			HMeshSequence Seq = MeshInst->FindSequence( *SequenceName );

			// Set the stats.
			CurrentFrame = 0;
			TCHAR Msg[256];
			appSprintf( Msg, _T("%i"), MeshInst->GetSeqRate(Seq) );
			SendMessageLX( GetDlgItem( hWnd, IDC_STATIC_PR ), WM_SETTEXT, NULL, Msg );
			appSprintf( Msg, _T("%i"), MeshInst->GetSeqNumFrames(Seq) );
			SendMessageLX( GetDlgItem( hWnd, IDC_STATIC_FC ), WM_SETTEXT, NULL, Msg );
			FrameCount = MeshInst->GetSeqNumFrames(Seq);
		} else {
			// No animation so these aren't relevant.
			TCHAR Msg[256];
			appSprintf( Msg, _T("N/A") );
			SendMessageLX( GetDlgItem( hWnd, IDC_STATIC_PR ), WM_SETTEXT, NULL, Msg );
			appSprintf( Msg, _T("N/A") );
			SendMessageLX( GetDlgItem( hWnd, IDC_STATIC_FC ), WM_SETTEXT, NULL, Msg );
		}

		// Stop a playing animation.
		if ( PlayingAnim )
		{
			OnPlayClick();
			CurrentFrame = 0;
		}

		SendMessageLX( OwnerWindow->hWnd, WM_COMMAND, IDMN_REFRESH, 0 );
	}
	void OnPlayClick()
	{
		if ( !MeshViewport || !MeshViewport->Actor || !MeshViewport->MiscRes )
			return;

		// Get a duke mesh pointer
		UDukeMesh* DukeMesh = (UDukeMesh*) MeshViewport->MiscRes;

		// Get a mesh instance.
		UDukeMeshInstance* MeshInst = (UDukeMeshInstance*) DukeMesh->GetInstance( MeshViewport->Actor );

		if ( !PlayingAnim )
		{
			// Get the sequence.
			HMeshSequence Seq = MeshInst->GetSequence( AnimCombo.GetCurrent() );

			// Play the animation.
			MeshInst->PlaySequence( Seq, 0, true, 1.f, 0.f, 0.f);
			PlayingAnim = true;

			// Set the button text.
			PlayButton.SetText( _T("Stop") );
		} else 
		{
			// Stop the animation.
			MeshInst->MeshChannels[0].AnimSequence = NAME_None;
			PlayingAnim = false;

			// Set the button text.
			PlayButton.SetText( _T("Play") );

			// Update the frame count.
			UpdateFrameCount();
		}
		SendMessageLX( OwnerWindow->hWnd, WM_COMMAND, IDMN_REFRESH, 0 );
	}
	void OnForwardClick()
	{
		CurrentFrame++;
		if (CurrentFrame > FrameCount-1)
			CurrentFrame = 0;
		UpdateFrameCount();
		SendMessageLX( OwnerWindow->hWnd, WM_COMMAND, IDMN_REFRESH, 0 );
	}
	void OnBackClick()
	{
		CurrentFrame--;
		if (CurrentFrame < 0)
			CurrentFrame = FrameCount-1;
		UpdateFrameCount();
		SendMessageLX( OwnerWindow->hWnd, WM_COMMAND, IDMN_REFRESH, 0 );
	}
	void OnConfigClick()
	{
		FString MeshName = MeshCombo.GetString( MeshCombo.GetCurrent() );

		TCHAR Cmd[256];
		appSprintf( Cmd, TEXT("MESH COMMAND MESH=\"%s\" CMD=\"ConfigEdit\""), *MeshName );
		GEditor->Exec( Cmd );
	}
	void UpdateFrameCount()
	{
		if (MeshViewport && MeshViewport->Actor)
		{
			TCHAR Msg[256];
			appSprintf( Msg, _T("%i"), CurrentFrame );
			SendMessageLX( GetDlgItem( hWnd, IDC_STATIC_CF ), WM_SETTEXT, NULL, Msg );
		}
	}
	void OnRenDevChange()
	{
		MeshViewport->TryRenderDevice( TEXT("D3DDrv.D3DRenderDevice"), MeshViewport->SizeX, MeshViewport->SizeY, INDEX_NONE, 0 );
		if ( !MeshViewport->RenDev )
		{
			appMsgf(TEXT("Could not set render device ... attempting to revert to software."));
			MeshViewport->TryRenderDevice( TEXT("SoftDrv.SoftwareRenderDevice"), MeshViewport->SizeX, MeshViewport->SizeY, INDEX_NONE, 0 );
		}
		else 
		{
			RenDevButton.SetText( _T("Direct3D") );
			Direct3D = TRUE;
		}
	}
	void SwitchToSoftware()
	{
		
#if 1
		OnRenDevChange();
#else
		if (Direct3D)
		{
			MeshViewport->TryRenderDevice( TEXT("SoftDrv.SoftwareRenderDevice"), MeshViewport->SizeX, MeshViewport->SizeY, INDEX_NONE, 0 );
			Direct3D = FALSE;
			RenDevButton.SetText( _T("Software") );
			SendMessageLX( OwnerWindow->hWnd, WM_COMMAND, IDMN_REFRESH, 0 );
		}
#endif
	}
};

class WBrowserMesh : public WBrowser
{
	DECLARE_WINDOWCLASS(WBrowserMesh,WBrowser,Window)

	UViewport*		MeshViewport;
	WSequenceFrame*	SequenceFrame;

	HWND			WndToolBar;
	WToolTip*		ToolTipCtrl;

	UBOOL			bPlaying;

	HMENU			BrowserMeshMenu;

	// Structors.
	WBrowserMesh( FName InPersistentName, WWindow* InOwnerWindow, HWND InEditorFrame )
	:	WBrowser( InPersistentName, InOwnerWindow, InEditorFrame )
	,	MeshViewport( NULL )
	,	SequenceFrame( NULL )
	,	ToolTipCtrl( NULL )
	{
		MeshViewport= NULL;
		bPlaying	= FALSE;
		MenuID		= IDMENU_BrowserMesh;
		BrowserID	= eBROWSER_MESH;
		Description = TEXT("Meshes");
	}

	// WBrowser interface.
	void OpenWindow( UBOOL bChild )
	{
		WBrowser::OpenWindow( bChild );
		SetCaption();
		Show(1);
	}
	void OnCreate()
	{
		WBrowser::OnCreate();

		BrowserMeshMenu = LoadMenuIdX(hInstance, IDMENU_BrowserMesh);
		SetMenu( hWnd, BrowserMeshMenu );

		SequenceFrame = new WSequenceFrame( TEXT("SequenceFrame"), IDDIALOG_SEQ_FRAME, this );
		SequenceFrame->DoModeless();
		SequenceFrame->Show(1);

		WndToolBar = CreateToolbarEx( 
			hWnd, WS_CHILD | WS_BORDER | WS_VISIBLE | CCS_ADJUSTABLE,
			IDB_BrowserMesh_TOOLBAR,
			3,
			hInstance,
			IDB_BrowserMesh_TOOLBAR,
			(LPCTBBUTTON)&tbMESHButtons,
			2,
			16,16,
			16,16,
			sizeof(TBBUTTON));
		check(WndToolBar);

		ToolTipCtrl = new WToolTip(this);
		ToolTipCtrl->OpenWindow();
		for( INT tooltip = 0 ; ToolTips_MESH[tooltip].ID > 0 ; tooltip++ )
		{
			// Figure out the rectangle for the toolbar button.
			INT index = SendMessageX( WndToolBar, TB_COMMANDTOINDEX, ToolTips_MESH[tooltip].ID, 0 );
			RECT rect;
			SendMessageX( WndToolBar, TB_GETITEMRECT, index, (LPARAM)&rect);

			ToolTipCtrl->AddTool( WndToolBar, ToolTips_MESH[tooltip].ToolTip, tooltip, &rect );
		}

		RefreshAll();
		SetCaption();

		PositionChildControls();
	}
	void OnDestroy()
	{
		delete MeshViewport;
		delete SequenceFrame;

		::DestroyWindow( WndToolBar );
		delete ToolTipCtrl;

		DestroyMenu( BrowserMeshMenu );

		WBrowser::OnDestroy();
	}
	virtual void RefreshAll()
	{
		SequenceFrame->RefreshMeshList();
		RefreshViewport();
	}
	void RefreshViewport()
	{
		if( !MeshViewport )
		{
			// Create the mesh viewport.
			MeshViewport = GEditor->Client->NewViewport( TEXT("MeshViewer") );
			check(MeshViewport);
			GEditor->Level->SpawnViewActor( MeshViewport );
			MeshViewport->Input->Init( MeshViewport );
			check(MeshViewport->Actor);
			MeshViewport->Actor->ShowFlags = SHOW_StandardView | SHOW_NoButtons | SHOW_ChildWindow;
			MeshViewport->Actor->RendMap   = REN_MeshView;
			MeshViewport->Group = NAME_None;
			MeshViewport->MiscRes = UObject::StaticFindObject( NULL, ANY_PACKAGE, *GetCurrentMeshName() );
			check(MeshViewport->MiscRes);
			MeshViewport->Actor->Misc1 = 0;
			MeshViewport->Actor->Misc2 = 0;
			MeshViewport->OpenWindow( (DWORD)hWnd, 0, 256, 256, 0, 0 );

			// Since we just opened the viewport, refresh.
			SequenceFrame->MeshViewport = MeshViewport;
			SequenceFrame->RefreshAnimList();
		}
		else
		{
			FString MeshName = GetCurrentMeshName();
			FName Seq = GetCurrentAnimSequence();
			DWORD Flags;
			if ( SequenceFrame->PlayingAnim )
				Flags = SHOW_StandardView | SHOW_NoButtons | SHOW_ChildWindow | SHOW_Backdrop | SHOW_RealTime;
			else
				Flags = SHOW_StandardView | SHOW_NoButtons | SHOW_ChildWindow;

			GEditor->Exec( 
				*(FString::Printf(TEXT("CAMERA UPDATE NAME=MeshViewer MESH=\"%s\" FLAGS=%d REN=%d MISC1=%d MISC2=%d"), 
				*MeshName, Flags, REN_MeshView, Seq.GetIndex(), SequenceFrame->CurrentFrame))
			);
		}
	}
	void PositionChildControls()
	{
		if ( !MeshViewport || !SequenceFrame )
			return;

		LockWindowUpdate( hWnd );

		FRect CR;
		CR = GetClientRect();
		RECT R;
		::GetClientRect( WndToolBar, &R );

		FLOAT Top = CR.Min.Y + R.bottom + 10;
		::MoveWindow( (HWND) MeshViewport->GetWindow(), 4, Top, (CR.Width()-8)/2, CR.Height() - Top - 2, 1 );
		SequenceFrame->MoveWindow( (CR.Width()/2)+4, Top, (CR.Width()-8)/2, CR.Height()-Top-2, 1 );

		// Repaint!
		MeshViewport->Repaint( 1 );

		// Refresh the display.
		LockWindowUpdate( NULL );
	}
	FString GetCurrentMeshName()
	{
		return SequenceFrame->GetCurrentMeshName();
	}
	FName GetCurrentAnimSequence()
	{
		return SequenceFrame->GetCurrentAnimSequence();
	}
	void SetCaption()
	{
		FString Caption = TEXT("Mesh Browser");

		if( GetCurrentMeshName().Len() )
			Caption += FString::Printf( TEXT(" - %s"), GetCurrentMeshName() );

		SetText( *Caption );
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WBrowser::OnSize(Flags, NewX, NewY);
		PositionChildControls();
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void OnShowWindow( UBOOL bShow )
	{
		WBrowser::OnShowWindow( bShow );

		if ( bShow )
			GEditor->LockMeshView = 0;
		else
		{
			GEditor->LockMeshView = 1;
			SequenceFrame->SwitchToSoftware();
		}
	}
	void OnCommand( INT Command )
	{
		switch( Command ) 
		{
			case IDMN_CF_FIND:
//				DlgFindReplace->Show(1);
				break;
			case IDMN_REFRESH:
				RefreshViewport();
				SetCaption();
				break;
			case IDMN_MB_PROPS:
				SequenceFrame->OnConfigClick();
				break;
			case IDMN_MB_NEW:
				{
					FString Package = SequenceFrame->PackageCombo.GetString( SequenceFrame->PackageCombo.GetCurrent() );
					FString Group = SequenceFrame->GroupCombo.GetString( SequenceFrame->GroupCombo.GetCurrent() );
					FString MeshName = SequenceFrame->MeshCombo.GetString( SequenceFrame->MeshCombo.GetCurrent() );

					if (Group == TEXT("[All Meshes]"))
						Group = FString(TEXT(""));

					WDlgNewMesh MeshDialog( NULL, this );
					if ( MeshDialog.DoModal( Package, Group ) )
					{
						SequenceFrame->RefreshPackages();
						SequenceFrame->PackageCombo.SetCurrent( SequenceFrame->PackageCombo.FindStringExact( *MeshDialog.Package) );
						SequenceFrame->RefreshGroups();
						SequenceFrame->GroupCombo.SetCurrent( SequenceFrame->GroupCombo.FindStringExact( *MeshDialog.Group) );
						SequenceFrame->RefreshMeshList();
					}
				}
				break;
			case IDMN_MB_OPEN:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "Mesh Packages (*.dmx)\0*.dmx\0All Files\0*.*\0\0";
					ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DMX]) );
					ofn.lpstrDefExt = "dmx";
					ofn.lpstrTitle = "Open Mesh Package";
					ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_ALLOWMULTISELECT | OFN_EXPLORER;

					if( GetOpenFileNameA(&ofn) )
					{
						INT iNULLs = FormatFilenames( File );
		
						TArray<FString> StringArray;
						ParseStringToArray( TEXT("|"), appFromAnsi( File ), &StringArray );

						INT iStart = 0;
						FString Prefix = TEXT("\0");

						if( iNULLs )
						{
							iStart = 1;
							Prefix = *(StringArray(0));
							Prefix += TEXT("\\");
						}

						if( StringArray.Num() > 0 )
						{
							if( StringArray.Num() == 1 )
							{
								SavePkgName = *(StringArray(0));
								SavePkgName = SavePkgName.Right( SavePkgName.Len() - (SavePkgName.Left( SavePkgName.InStr(TEXT("\\"), 1)).Len() + 1 ));
							}
							else
								SavePkgName = *(StringArray(1));
							SavePkgName = SavePkgName.Left( SavePkgName.InStr(TEXT(".")) );
						}

						if( StringArray.Num() == 1 )
							GLastDir[eLASTDIR_DMX] = StringArray(0).Left( StringArray(0).InStr( TEXT("\\"), 1 ) );
						else
							GLastDir[eLASTDIR_DMX] = StringArray(0);

						GWarn->BeginSlowTask( TEXT(""), 1, 0 );

						for( INT x = iStart ; x < StringArray.Num() ; x++ )
						{
							GWarn->StatusUpdatef( x, StringArray.Num(), TEXT("Loading %s"), *(StringArray(x)) );

							TCHAR l_chCmd[512];
							appSprintf( l_chCmd, TEXT("OBJ LOAD FILE=\"%s%s\""), *Prefix, *(StringArray(x)) );
							GEditor->Exec( l_chCmd );
						}

						GWarn->EndSlowTask();

						GBrowserMaster->RefreshAll();
						SequenceFrame->PackageCombo.SetCurrent( SequenceFrame->PackageCombo.FindStringExact( *SavePkgName ) );
						SequenceFrame->RefreshGroups();
						SequenceFrame->RefreshMeshList();
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
				}
				break;
			case IDMN_MB_SAVE:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";
					FString Package = SequenceFrame->PackageCombo.GetString( SequenceFrame->PackageCombo.GetCurrent() );

					::sprintf( File, "%s.dmx", TCHAR_TO_ANSI( *Package ) );

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "Mesh Packages (*.dmx)\0*.dmx\0All Files\0*.*\0\0";
					ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DMX]) );
					ofn.lpstrDefExt = "dmx";
					ofn.lpstrTitle = "Save Mesh Package";
					ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

					if( GetSaveFileNameA(&ofn) )
					{
						TCHAR l_chCmd[256];

						appSprintf( l_chCmd, TEXT("OBJ SAVEPACKAGE PACKAGE=\"%s\" FILE=\"%s\""),
							*Package, appFromAnsi( File ) );
						GEditor->Exec( l_chCmd );

						FString S = appFromAnsi( File );
						GLastDir[eLASTDIR_DMX] = S.Left( S.InStr( TEXT("\\"), 1 ) );
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
				}
				break;
			case IDMN_MB_DELETE:
				{
					FString MeshName = SequenceFrame->MeshCombo.GetString( SequenceFrame->MeshCombo.GetCurrent() );

					FStringOutputDevice GetPropResult = FStringOutputDevice();
					TCHAR l_chCmd[256];
					appSprintf( l_chCmd, TEXT("DELETE CLASS=MESH OBJECT=\"%s\""), *MeshName);
				    GEditor->Get( TEXT("Obj"), l_chCmd, GetPropResult);

					if( !GetPropResult.Len() )
					{
						MeshViewport->MiscRes = NULL;
						SequenceFrame->RefreshPackages();
						SequenceFrame->RefreshGroups();
						SequenceFrame->RefreshMeshList( TRUE );
					}
					else
						appMsgf( TEXT("Can't delete Mesh.\n\n%s"), *GetPropResult );
				}
				break;
			default:
				WBrowser::OnCommand( Command );
				break;
		}
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
