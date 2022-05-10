/*=============================================================================
	BrowserMusic : Browser window for music files
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

// --------------------------------------------------------------
//
// IMPORT MUSIC Dialog
//
// --------------------------------------------------------------

class WDlgImportMusic : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgImportMusic,WDialog,DukeEd)

	// Variables.
	WButton OkButton;
	WButton OkAllButton;
	WButton SkipButton;
	WButton CancelButton;
	WLabel FilenameStatic;
	WEdit NameEdit;

	TArray<FString>* paFilenames;

	FString Name;
	BOOL bOKToAll;
	INT iCurrentFilename;

	// Constructor.
	WDlgImportMusic( UObject* InContext, WBrowser* InOwnerWindow )
	:	WDialog			( TEXT("Import Music"), IDDIALOG_IMPORT_MUSIC, InOwnerWindow )
	,	OkButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOk) )
	,	OkAllButton		( this, IDPB_OKALL,		FDelegate(this,(TDelegate)OnOkAll) )
	,	SkipButton		( this, IDPB_SKIP,		FDelegate(this,(TDelegate)OnSkip) )
	,	CancelButton	( this, IDCANCEL,		FDelegate(this,(TDelegate)EndDialogFalse) )
	,	NameEdit		( this, IDEC_NAME )
	,	FilenameStatic	( this, IDSC_FILENAME )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		::SetFocus( NameEdit.hWnd );

		bOKToAll = FALSE;
		iCurrentFilename = -1;
		SetNextFilename();
	}
	void OnDestroy()
	{
		WDialog::OnDestroy();
	}
	virtual INT DoModal( TArray<FString>* _paFilenames)
	{
		paFilenames = _paFilenames;

		return WDialog::DoModal( hInstance );
	}
	void OnOk()
	{
		if( GetDataFromUser() )
		{
			ImportFile( (*paFilenames)(iCurrentFilename) );
			SetNextFilename();
		}
	}
	void OnOkAll()
	{
		if( GetDataFromUser() )
		{
			ImportFile( (*paFilenames)(iCurrentFilename) );
			bOKToAll = TRUE;
			SetNextFilename();
		}
	}
	void OnSkip()
	{
		if( GetDataFromUser() )
			SetNextFilename();
	}
	void ImportTexture( void )
	{
	}
	void RefreshName( void )
	{
		FilenameStatic.SetText( *(*paFilenames)(iCurrentFilename) );

		FString Name = GetFilenameOnly( (*paFilenames)(iCurrentFilename) );
		NameEdit.SetText( *Name );
	}
	BOOL GetDataFromUser( void )
	{
		Name = NameEdit.GetText();

		if( !Name.Len() )
		{
			appMsgf( TEXT("Invalid input.") );
			return FALSE;
		}

		return TRUE;
	}
	void SetNextFilename( void )
	{
		iCurrentFilename++;
		if( iCurrentFilename == paFilenames->Num() ) {
			EndDialogTrue();
			return;
		}

		if( bOKToAll ) {
			RefreshName();
			GetDataFromUser();
			ImportFile( (*paFilenames)(iCurrentFilename) );
			SetNextFilename();
			return;
		};

		RefreshName();
	}
	void ImportFile( FString Filename )
	{
		TCHAR l_chCmd[512];

		appSprintf( l_chCmd, TEXT("OBJ IMPORT STANDALONE TYPE=MUSIC FILE=\"%s\" NAME=\"%s\" PACKAGE=\"%s\""),
			*Filename, *Name, *Name );
		GEditor->Exec( l_chCmd );
	}
};

// --------------------------------------------------------------
//
// WBrowserMusic
//
// --------------------------------------------------------------

#define ID_BM_TOOLBAR	29030
TBBUTTON tbBMButtons[] = {
	{ 0, IDMN_MB_DOCK, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 1, IDMN_MB_FileOpen, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 2, IDMN_MB_FileSave, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 3, IDMN_MB_PLAY, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 4, IDMN_MB_STOP, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
};
struct {
	TCHAR ToolTip[64];
	INT ID;
} ToolTips_BM[] = {
	TEXT("Toggle Dock Status"), IDMN_MB_DOCK,
	TEXT("Open Package"), IDMN_MB_FileOpen,
	TEXT("Save Package"), IDMN_MB_FileSave,
	TEXT("Play"), IDMN_MB_PLAY,
	TEXT("Stop"), IDMN_MB_STOP,
	NULL, 0
};

class WBrowserMusic : public WBrowser
{
	DECLARE_WINDOWCLASS(WBrowserMusic,WBrowser,Window)

	WListBox *pListMusic;
	HWND hWndToolBar;
	WToolTip* ToolTipCtrl;
	MRUList* mrulist;

	HMENU BrowserMusicMenu;

	// Structors.
	WBrowserMusic( FName InPersistentName, WWindow* InOwnerWindow, HWND InEditorFrame )
	:	WBrowser( InPersistentName, InOwnerWindow, InEditorFrame )
	{
		pListMusic = NULL;
		MenuID = IDMENU_BrowserMusic;
		BrowserID = eBROWSER_MUSIC;
		Description = TEXT("Music");
		mrulist = NULL;
	}

	// WBrowser interface.
	void OpenWindow( UBOOL bChild )
	{
		WBrowser::OpenWindow( bChild );
		SetCaption();
	}
	void OnCreate()
	{
		WBrowser::OnCreate();

		BrowserMusicMenu = LoadMenuIdX(hInstance, IDMENU_BrowserMusic);
		SetMenu( hWnd, BrowserMusicMenu );

		// MUSIC LIST
		//
		pListMusic = new WListBox( this, IDLB_MUSIC );
		pListMusic->OpenWindow( 1, 0, 0, 0, 1 );
		pListMusic->DoubleClickDelegate = FDelegate(this, (TDelegate)OnListMusicDblClick);

		hWndToolBar = CreateToolbarEx( 
			hWnd, WS_CHILD | WS_BORDER | WS_VISIBLE | CCS_ADJUSTABLE,
			IDB_BrowserMusic_TOOLBAR,
			5,
			hInstance,
			IDB_BrowserMusic_TOOLBAR,
			(LPCTBBUTTON)&tbBMButtons,
			7,
			16,16,
			16,16,
			sizeof(TBBUTTON));
		check(hWndToolBar);

		ToolTipCtrl = new WToolTip(this);
		ToolTipCtrl->OpenWindow();
		for( INT tooltip = 0 ; ToolTips_BM[tooltip].ID > 0 ; tooltip++ )
		{
			// Figure out the rectangle for the toolbar button.
			INT index = SendMessageX( hWndToolBar, TB_COMMANDTOINDEX, ToolTips_BM[tooltip].ID, 0 );
			RECT rect;
			SendMessageX( hWndToolBar, TB_GETITEMRECT, index, (LPARAM)&rect);

			ToolTipCtrl->AddTool( hWndToolBar, ToolTips_BM[tooltip].ToolTip, tooltip, &rect );
		}

		mrulist = new MRUList( *PersistentName );
		mrulist->ReadINI();
		if( GBrowserMaster->GetCurrent()==BrowserID )
			mrulist->AddToMenu( hWnd, GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd ) );

		RefreshMusicList();
		PositionChildControls();

	}
	void OnDestroy()
	{
		delete pListMusic;

		::DestroyWindow( hWndToolBar );
		delete ToolTipCtrl;

		mrulist->WriteINI();
		delete mrulist;

		DestroyMenu( BrowserMusicMenu );

		WBrowser::OnDestroy();
	}
	virtual void UpdateMenu()
	{
		HMENU menu = IsDocked() ? GetMenu( OwnerWindow->hWnd ) : GetMenu( hWnd );
		CheckMenuItem( menu, IDMN_MB_DOCK, MF_BYCOMMAND | (IsDocked() ? MF_CHECKED : MF_UNCHECKED) );

		if( mrulist 
				&& GBrowserMaster->GetCurrent()==BrowserID )
			mrulist->AddToMenu( hWnd, GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd ) );
	}
	void OnCommand( INT Command )
	{
		switch( Command ) {

			case IDMN_MB_EXPORT:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";
					FString Name = pListMusic->GetString( pListMusic->GetCurrent() );

					::sprintf( File, "%s", TCHAR_TO_ANSI( *Name ) );

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "S3M Files (*.s3m)\0*.s3m\0All Files\0*.*\0\0";
					ofn.lpstrDefExt = "s3m";
					ofn.lpstrTitle = "Export Music";
					ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

					// Display the Open dialog box. 
					//
					if( GetSaveFileNameA(&ofn) )
					{
						TCHAR l_chCmd[512];

						appSprintf( l_chCmd, TEXT("OBJ EXPORT TYPE=MUSIC PACKAGE=\"%s\" NAME=\"%s\" FILE=\"%s\""),
							*Name, *Name, appFromAnsi( File ) );
						GEditor->Exec( l_chCmd );
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
				}
				break;

			case IDMN_MB_IMPORT:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "Music Files (*.mod, *.s3m, *.stm, *.it, *.xm, *.far, *.669)\0*.mod;*.s3m;*.stm;*.it;*.xm;*.far;*.669\0Amiga Modules (*,mod)\0*.mod\0Scream Tracker 3 (*.s3m)\0*.s3m\0Scream Tracker 2 (*.stm)\0*.stm\0Impulse Tracker (*.it)\0*.it\0Fasttracker 2\0*,xm\0Farandole (*.far)\0*.far\0ComposD (*.669)\0*.669\0All Files\0*.*\0\0";
					ofn.lpstrDefExt = "*.mod;*.s3m;*.stm;*.it;*.xm;*.far;*.669";
					ofn.lpstrTitle = "Import Music";
					ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_ALLOWMULTISELECT | OFN_EXPLORER;

					// Display the Open dialog box. 
					//
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

						TArray<FString> FilenamesArray;

						for( INT x = iStart ; x < StringArray.Num() ; x++ )
						{
							FString NewString;

							NewString = FString::Printf( TEXT("%s%s"), *Prefix, *(StringArray(x)) );
							new(FilenamesArray)FString( NewString );
						}

						WDlgImportMusic l_dlg( NULL, this );
						l_dlg.DoModal( &FilenamesArray );

						RefreshMusicList();
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
				}
				break;

			case IDMN_MB_PLAY:
				OnPlay();
				break;

			case IDMN_MB_STOP:
				OnStop();
				break;

			case IDMN_MB_FileSave:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";
					::sprintf( File, "%s.umx", TCHAR_TO_ANSI( *(pListMusic->GetString( pListMusic->GetCurrent())) ) );

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "Music Packages (*.umx)\0*.umx\0All Files\0*.*\0\0";
					ofn.lpstrInitialDir = "..\\music";
					ofn.lpstrDefExt = "umx";
					ofn.lpstrTitle = "Save Music Package";
					ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

					if( GetSaveFileNameA(&ofn) )
					{
						TCHAR l_chCmd[256];
						appSprintf( l_chCmd, TEXT("OBJ SAVEPACKAGE PACKAGE=\"%s\" FILE=\"%s\""),
							*(pListMusic->GetString( pListMusic->GetCurrent())), appFromAnsi( File ) );
						GEditor->Exec( l_chCmd );
					
						mrulist->AddItem( appFromAnsi( File ) );
						if( GBrowserMaster->GetCurrent()==BrowserID )
							mrulist->AddToMenu( hWnd, GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd ) );
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
				}
				break;

			case IDMN_MB_FileOpen:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "Music Packages (*.umx)\0*.umx\0All Files\0*.*\0\0";
					ofn.lpstrInitialDir = "..\\music";
					ofn.lpstrDefExt = "umx";
					ofn.lpstrTitle = "Open Music Package";
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

						GWarn->BeginSlowTask( TEXT(""), 1, 0 );

						for( INT x = iStart ; x < StringArray.Num() ; x++ )
						{
							GWarn->StatusUpdatef( x, StringArray.Num(), TEXT("Loading %s"), *(StringArray(x)) );

							TCHAR l_chCmd[512];
							appSprintf( l_chCmd, TEXT("OBJ LOAD FILE=\"%s%s\""), *Prefix, *(StringArray(x)) );
							GEditor->Exec( l_chCmd );

							mrulist->AddItem( *(StringArray(x)) );
							if( GBrowserMaster->GetCurrent()==BrowserID )
								mrulist->AddToMenu( hWnd, GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd ) );
						}

						GWarn->EndSlowTask();

						GBrowserMaster->RefreshAll();
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
				}
				break;

			case IDMN_MRU1:
			case IDMN_MRU2:
			case IDMN_MRU3:
			case IDMN_MRU4:
			case IDMN_MRU5:
			case IDMN_MRU6:
			case IDMN_MRU7:
			case IDMN_MRU8:
			{
				FString Filename = mrulist->Items[Command - IDMN_MRU1];
				GEditor->Exec( *(FString::Printf(TEXT("OBJ LOAD FILE=\"%s\""), *Filename )) );

				GBrowserMaster->RefreshAll();
			}
			break;

			default:
				WBrowser::OnCommand(Command);
				break;
		}
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WBrowser::OnSize(Flags, NewX, NewY);
		PositionChildControls();
		InvalidateRect( hWnd, NULL, FALSE );
		UpdateMenu();
	}
	virtual void RefreshAll()
	{
		RefreshMusicList();
		if( GBrowserMaster->GetCurrent()==BrowserID )
			mrulist->AddToMenu( hWnd, GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd ) );
	}
	void RefreshMusicList( void )
	{
		// MUSIC
		//
		pListMusic->Empty();
		FStringOutputDevice GetPropResult = FStringOutputDevice();
		GEditor->Get( TEXT("OBJ"), TEXT("QUERY TYPE=MUSIC"), GetPropResult );

		TArray<FString> StringArray;
		ParseStringToArray( TEXT(" "), *GetPropResult, &StringArray );

		for( INT x = 0 ; x < StringArray.Num() ; x++ )
			if( StringArray(x).Len() )
				pListMusic->AddString( *(StringArray(x)) );

		pListMusic->SetCurrent( 0, 1 );
	}
	// Moves the child windows around so that they best match the window size.
	//
	void PositionChildControls( void )
	{
		if( !pListMusic ) return;

		FRect CR = GetClientRect();
		RECT R;
		::GetClientRect( hWndToolBar, &R );
		HWND ChildHandle = GetDlgItem( hWnd, ID_BM_TOOLBAR );
		if ( ChildHandle )
			::MoveWindow( ChildHandle, 0, 0, 2000, R.bottom, TRUE );

		FLOAT Top = (R.bottom - R.top) + 8;
		::MoveWindow( pListMusic->hWnd, 4, Top, CR.Width() - 8, CR.Height() - R.bottom - 8, 1 );
	}
	void OnPlay()
	{
		TCHAR l_chCmd[256];
		FString Name = pListMusic->GetString( pListMusic->GetCurrent() );
		appSprintf( l_chCmd, TEXT("MUSIC PLAY NAME=\"%s\""), *Name );
		GEditor->Exec( l_chCmd );
	}
	void OnStop()
	{
		GEditor->Exec( TEXT("MUSIC PLAY NAME=None") );
	}

	// Notification delegates for child controls.
	//
	void OnListMusicDblClick()
	{
		OnPlay();
	}
	virtual FString GetCurrentPathName( void )
	{
		return *(pListMusic->GetString( pListMusic->GetCurrent() ));
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
