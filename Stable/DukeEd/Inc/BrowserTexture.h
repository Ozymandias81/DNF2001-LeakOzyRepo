/*=============================================================================
	BrowserTexture : Browser window for textures
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:
	- needs ability to export to BMP format

=============================================================================*/

#include "DlgTexUsage.h"
#define WM_MOUSEWHEEL                   0x020A

__declspec(dllimport) INT GLastScroll;

extern void Query( ULevel* Level, const TCHAR* Item, FString* pOutput );
extern void ParseStringToArray( const TCHAR* pchDelim, FString String, TArray<FString>* _pArray);
extern FString GLastDir[eLASTDIR_MAX];

// --------------------------------------------------------------
//
// NEW TEXTURE Dialog
//
// --------------------------------------------------------------

class WDlgNewTexture : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgNewTexture,WDialog,DukeEd)

	// Variables.
	WButton OkButton;
	WButton CancelButton;
	WEdit PackageEdit;
	WEdit GroupEdit;
	WEdit NameEdit;
	WComboBox ClassCombo;
	WComboBox WidthCombo;
	WComboBox HeightCombo;

	FString defPackage, defGroup;
	TArray<FString>* paFilenames;

	FString Package, Group, Name;

	// Constructor.
	WDlgNewTexture( UObject* InContext, WBrowser* InOwnerWindow )
		:	WDialog			( TEXT("New Texture"), IDDIALOG_NEW_TEXTURE, InOwnerWindow )
	,	OkButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOk) )
	,	CancelButton	( this, IDCANCEL,		FDelegate(this,(TDelegate)EndDialogFalse) )
	,	PackageEdit		( this, IDEC_PACKAGE )
	,	GroupEdit		( this, IDEC_GROUP )
	,	NameEdit		( this, IDEC_NAME )
	,	ClassCombo		( this, IDCB_CLASS )
	,	WidthCombo		( this, IDCB_WIDTH )
	,	HeightCombo		( this, IDCB_HEIGHT )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		PackageEdit.SetText( *defPackage );
		GroupEdit.SetText( *defGroup );
		::SetFocus( NameEdit.hWnd );

		WidthCombo.AddString( TEXT("1") );
		WidthCombo.AddString( TEXT("2") );
		WidthCombo.AddString( TEXT("4") );
		WidthCombo.AddString( TEXT("8") );
		WidthCombo.AddString( TEXT("16") );
		WidthCombo.AddString( TEXT("32") );
		WidthCombo.AddString( TEXT("64") );
		WidthCombo.AddString( TEXT("128") );
		WidthCombo.AddString( TEXT("256") );
		WidthCombo.SetCurrent(8);

		HeightCombo.AddString( TEXT("1") );
		HeightCombo.AddString( TEXT("2") );
		HeightCombo.AddString( TEXT("4") );
		HeightCombo.AddString( TEXT("8") );
		HeightCombo.AddString( TEXT("16") );
		HeightCombo.AddString( TEXT("32") );
		HeightCombo.AddString( TEXT("64") );
		HeightCombo.AddString( TEXT("128") );
		HeightCombo.AddString( TEXT("256") );
		HeightCombo.SetCurrent(8);

		FString Classes;

		Query( GEditor->Level, TEXT("GETCHILDREN CLASS=TEXTURE CONCRETE=1"), &Classes);

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
			GEditor->Exec( *(FString::Printf( TEXT("TEXTURE NEW NAME=\"%s\" CLASS=\"%s\" GROUP=\"%s\" USIZE=%s VSIZE=%s PACKAGE=\"%s\""),
				*NameEdit.GetText(), *ClassCombo.GetString( ClassCombo.GetCurrent() ), *GroupEdit.GetText(),
				*WidthCombo.GetString( WidthCombo.GetCurrent() ), *HeightCombo.GetString( HeightCombo.GetCurrent() ),
				*PackageEdit.GetText() )));
			EndDialog(TRUE);
		}
	}
	BOOL GetDataFromUser( void )
	{
		Package = PackageEdit.GetText();
		Group = GroupEdit.GetText();
		Name = NameEdit.GetText();

		if( !Package.Len()
				|| !Name.Len() )
		{
			appMsgf( TEXT("Invalid input.") );
			return FALSE;
		}

		return TRUE;
	}
};

// --------------------------------------------------------------
//
// IMPORT TEXTURE Dialog
//
// --------------------------------------------------------------

class WDlgImportTexture : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgImportTexture,WDialog,DukeEd)

	// Variables.
	WButton OkButton;
	WButton OkAllButton;
	WButton SkipButton;
	WButton CancelButton;
	WLabel FilenameStatic;
	WEdit PackageEdit;
	WEdit GroupEdit;
	WEdit NameEdit;
	WCheckBox CheckMasked;
	WCheckBox CheckMipMap;

	FString defPackage, defGroup;
	TArray<FString>* paFilenames;

	FString Package, Group, Name;
	BOOL bOKToAll;
	INT iCurrentFilename;

	// Constructor.
	WDlgImportTexture( UObject* InContext, WBrowser* InOwnerWindow )
	:	WDialog			( TEXT("Import Texture"), IDDIALOG_IMPORT_TEXTURE, InOwnerWindow )
	,	OkButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOk) )
	,	OkAllButton		( this, IDPB_OKALL,		FDelegate(this,(TDelegate)OnOkAll) )
	,	SkipButton		( this, IDPB_SKIP,		FDelegate(this,(TDelegate)OnSkip) )
	,	CancelButton	( this, IDCANCEL,		FDelegate(this,(TDelegate)EndDialogFalse) )
	,	PackageEdit		( this, IDEC_PACKAGE )
	,	GroupEdit		( this, IDEC_GROUP )
	,	NameEdit		( this, IDEC_NAME )
	,	FilenameStatic	( this, IDSC_FILENAME )
	,	CheckMasked		( this, IDCK_MASKED )
	,	CheckMipMap		( this, IDCK_MIPMAP )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		PackageEdit.SetText( *defPackage );
		GroupEdit.SetText( *defGroup );
		::SetFocus( NameEdit.hWnd );

		bOKToAll = FALSE;
		iCurrentFilename = -1;
		SetNextFilename();

		CheckMipMap.SetCheck( BST_CHECKED );
	}
	void OnDestroy()
	{
		WDialog::OnDestroy();
	}
	virtual INT DoModal( FString _defPackage, FString _defGroup, TArray<FString>* _paFilenames)
	{
		defPackage = _defPackage;
		defGroup = _defGroup;
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
		Package = PackageEdit.GetText();
		Group = GroupEdit.GetText();
		Name = NameEdit.GetText();

		if( !Package.Len()
				|| !Name.Len() )
		{
			appMsgf( TEXT("Invalid input.") );
			return FALSE;
		}

		return TRUE;
	}
	void SetNextFilename( void )
	{
		iCurrentFilename++;
		if( iCurrentFilename == paFilenames->Num() ) 
		{
			EndDialogTrue();
			return;
		}

		if( bOKToAll ) 
		{
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

		if( Group.Len() )
			appSprintf( l_chCmd, TEXT("TEXTURE IMPORT FILE=\"%s\" NAME=\"%s\" PACKAGE=\"%s\" GROUP=\"%s\" MIPS=%d FLAGS=%d"),
				*(*paFilenames)(iCurrentFilename), *Name, *Package, *Group,
				CheckMipMap.IsChecked(), (CheckMasked.IsChecked() ? PF_Masked : 0) );
		else
			appSprintf( l_chCmd, TEXT("TEXTURE IMPORT FILE=\"%s\" NAME=\"%s\" PACKAGE=\"%s\" MIPS=%d FLAGS=%d"),
				*(*paFilenames)(iCurrentFilename), *Name, *Package,
				CheckMipMap.IsChecked(), (CheckMasked.IsChecked() ? PF_Masked : 0) );

		GEditor->Exec( l_chCmd );
		GEditor->Exec(TEXT("TEXTURE FLUSH"));
		//FlushAllViewports();
	}
};

// --------------------------------------------------------------
//
// WBrowserTexture
//
// --------------------------------------------------------------

#define ID_BT_TOOLBAR	29040
TBBUTTON tbBTButtons[] = {
	{ 0, IDMN_MB_DOCK, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 1, IDMN_TB_FileOpen, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 2, IDMN_TB_FileSave, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 3, IDMN_TB_PROPERTIES, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 4, IDMN_TB_PREV_GRP, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 5, IDMN_TB_NEXT_GRP, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
};
struct {
	TCHAR ToolTip[64];
	INT ID;
} ToolTips_BT[] = {
	TEXT("Toggle Dock Status"), IDMN_MB_DOCK,
	TEXT("Open Package"), IDMN_TB_FileOpen,
	TEXT("Save Package"), IDMN_TB_FileSave,
	TEXT("Texture Properties"), IDMN_TB_PROPERTIES,
	TEXT("Previous Group"), IDMN_TB_PREV_GRP,
	TEXT("Next Group"), IDMN_TB_NEXT_GRP,
	NULL, 0
};

class WBrowserTexture : public WBrowser
{
	DECLARE_WINDOWCLASS(WBrowserTexture,WBrowser,Window)

	TArray<WDlgTexProp> PropWindows;

	WComboBox *pComboPackage, *pComboGroup;
	WCheckBox *pCheckGroupAll;
	WLabel *pLabelFilter;
	WEdit *pEditFilter;
	WVScrollBar* pScrollBar;
	HWND hWndToolBar;
	WToolTip *ToolTipCtrl;
	MRUList* mrulist;

	UViewport *pViewport;
	INT iZoom, iScroll;

	HMENU BrowserTextureMenu;

	// Structors.
	WBrowserTexture( FName InPersistentName, WWindow* InOwnerWindow, HWND InEditorFrame )
	:	WBrowser( InPersistentName, InOwnerWindow, InEditorFrame )
	{
		pComboPackage = pComboGroup = NULL;
		pCheckGroupAll = NULL;
		pViewport = NULL;
		pLabelFilter = NULL;
		pEditFilter = NULL;
		pScrollBar = NULL;
		iZoom = 128;
		iScroll = 0;
		MenuID = IDMENU_BrowserTexture;
		BrowserID = eBROWSER_TEXTURE;
		Description = TEXT("Textures");
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

		BrowserTextureMenu = LoadMenuIdX(hInstance, IDMENU_BrowserTexture);
		SetMenu( hWnd, BrowserTextureMenu );

		// PACKAGES
		//
		pComboPackage = new WComboBox( this, IDCB_PACKAGE );
		pComboPackage->OpenWindow( 1, 1 );
		pComboPackage->SelectionChangeDelegate = FDelegate(this, (TDelegate)OnComboPackageSelChange);

		// GROUP
		//
		pComboGroup = new WComboBox( this, IDCB_GROUP );
		pComboGroup->OpenWindow( 1, 1 );
		pComboGroup->SelectionChangeDelegate = FDelegate(this, (TDelegate)OnComboGroupSelChange);

		// CHECK BOXES
		//
		pCheckGroupAll = new WCheckBox( this, IDCK_GRP_ALL, FDelegate(this, (TDelegate)OnGroupAllClick) );
		pCheckGroupAll->OpenWindow( 1, 0, 0, 1, 1, TEXT("All"), 1, 0, BS_PUSHLIKE );

		// LABELS
		//
		pLabelFilter = new WLabel( this, IDST_FILTER );
		pLabelFilter->OpenWindow( 1, 0 );
		pLabelFilter->SetText( TEXT("Filter : ") );
		
		// EDIT CONTROLS
		//
		pEditFilter = new WEdit( this, IDEC_FILTER );
		pEditFilter->OpenWindow( 1, 0, 0 );
		pEditFilter->SetText( TEXT("") );
		pEditFilter->ChangeDelegate = FDelegate(this, (TDelegate)OnEditFilterChange);

		// SCROLLBARS
		//
		pScrollBar = new WVScrollBar( this, IDSB_SCROLLBAR );
		pScrollBar->OpenWindow( 1, 0, 0, 320, 200 );

		// Create the texture browser viewport
		//
		FName Name = TEXT("TextureBrowser");
		pViewport = GEditor->Client->NewViewport( Name );
		GEditor->Level->SpawnViewActor( pViewport );
		pViewport->Actor->ShowFlags = SHOW_StandardView | SHOW_NoButtons | SHOW_ChildWindow;
		pViewport->Actor->RendMap   = REN_TexBrowser;
		pViewport->Actor->Misc1 = iZoom;
		pViewport->Actor->Misc2 = iScroll;
		pViewport->Group = NAME_None;
		pViewport->MiscRes = NULL;
		pViewport->Input->Init( pViewport );
		pViewport->OpenWindow( (DWORD)hWnd, 0, 320, 200, 0, 0 );

		if(!GConfig->GetInt( *PersistentName, TEXT("Zoom"), iZoom, TEXT("DukeEd.ini") ))
			iZoom = 128;

		hWndToolBar = CreateToolbarEx( 
			hWnd, WS_CHILD | WS_BORDER | WS_VISIBLE | CCS_ADJUSTABLE,
			IDB_BrowserTexture_TOOLBAR,
			6,
			hInstance,
			IDB_BrowserTexture_TOOLBAR,
			(LPCTBBUTTON)&tbBTButtons,
			9,
			16,16,
			16,16,
			sizeof(TBBUTTON));
		check(hWndToolBar);

		ToolTipCtrl = new WToolTip(this);
		ToolTipCtrl->OpenWindow();
		for( INT tooltip = 0 ; ToolTips_BT[tooltip].ID > 0 ; tooltip++ )
		{
			// Figure out the rectangle for the toolbar button.
			INT index = SendMessageX( hWndToolBar, TB_COMMANDTOINDEX, ToolTips_BT[tooltip].ID, 0 );
			RECT rect;
			SendMessageX( hWndToolBar, TB_GETITEMRECT, index, (LPARAM)&rect);

			ToolTipCtrl->AddTool( hWndToolBar, ToolTips_BT[tooltip].ToolTip, tooltip, &rect );
		}

		mrulist = new MRUList( *PersistentName );
		mrulist->ReadINI();
		if( GBrowserMaster->GetCurrent()==BrowserID )
			mrulist->AddToMenu( hWnd, GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd ) );

		PositionChildControls();
		RefreshPackages();
		RefreshGroups();
		RefreshTextureList();

		SetCaption();
	}
	void OnDestroy()
	{
		GConfig->SetInt( *PersistentName, TEXT("Zoom"), iZoom, TEXT("DukeEd.ini") );

		delete pComboPackage;
		delete pComboGroup;
		delete pCheckGroupAll;
		delete pLabelFilter;
		delete pEditFilter;
		delete pScrollBar;

		::DestroyWindow( hWndToolBar );
		delete ToolTipCtrl;

		mrulist->WriteINI();
		delete mrulist;

		// Clean up all open texture property windows.
		for( INT x = 0 ; x < PropWindows.Num() ; x++ )
		{
			::DestroyWindow( PropWindows(x).hWnd );
			delete PropWindows(x);
		}
		delete pViewport;

		DestroyMenu( BrowserTextureMenu );

		WBrowser::OnDestroy();
	}
	virtual void UpdateMenu()
	{
		HMENU menu = GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd );

		CheckMenuItem( menu, IDMN_TB_ZOOM_32, MF_BYCOMMAND | ((iZoom == 32) ? MF_CHECKED : MF_UNCHECKED) );
		CheckMenuItem( menu, IDMN_TB_ZOOM_64, MF_BYCOMMAND | ((iZoom == 64) ? MF_CHECKED : MF_UNCHECKED) );
		CheckMenuItem( menu, IDMN_TB_ZOOM_128, MF_BYCOMMAND | ((iZoom == 128) ? MF_CHECKED : MF_UNCHECKED) );
		CheckMenuItem( menu, IDMN_TB_ZOOM_256, MF_BYCOMMAND | ((iZoom == 256) ? MF_CHECKED : MF_UNCHECKED) );
		CheckMenuItem( menu, IDMN_VAR_200, MF_BYCOMMAND | ((iZoom == 1200) ? MF_CHECKED : MF_UNCHECKED) );
		CheckMenuItem( menu, IDMN_VAR_100, MF_BYCOMMAND | ((iZoom == 1100) ? MF_CHECKED : MF_UNCHECKED) );
		CheckMenuItem( menu, IDMN_VAR_50, MF_BYCOMMAND | ((iZoom == 1050) ? MF_CHECKED : MF_UNCHECKED) );
		CheckMenuItem( menu, IDMN_VAR_25, MF_BYCOMMAND | ((iZoom == 1025) ? MF_CHECKED : MF_UNCHECKED) );
		CheckMenuItem( menu, IDMN_MB_DOCK, MF_BYCOMMAND | (IsDocked() ? MF_CHECKED : MF_UNCHECKED) );

		if( mrulist 
				&& GBrowserMaster->GetCurrent()==BrowserID )
			mrulist->AddToMenu( hWnd, GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd ) );
	}
	void OnCommand( INT Command )
	{
		switch( Command )
		{
			case IDMN_TB_NEW:
				{
					FString Package = pComboPackage->GetString( pComboPackage->GetCurrent() );
					FString Group = pComboGroup->GetString( pComboGroup->GetCurrent() );

					WDlgNewTexture l_dlg( NULL, this );
					if( l_dlg.DoModal( Package, Group ) )
					{
						RefreshPackages();
						pComboPackage->SetCurrent( pComboPackage->FindStringExact( *l_dlg.Package) );
						RefreshGroups();
						pComboGroup->SetCurrent( pComboGroup->FindStringExact( *l_dlg.Group) );
						RefreshTextureList();

						// Call up the properties on this new texture.
						WDlgTexProp* pDlgTexProp = new(PropWindows)WDlgTexProp(NULL, OwnerWindow, GEditor->CurrentTexture );
						pDlgTexProp->DoModeless();
						pDlgTexProp->pProps->SetNotifyHook( GEditor );
					}
				}
				break;

			case IDMN_TB_PROPERTIES:
				{
					if( GEditor->CurrentTexture )
					{
						WDlgTexProp* pDlgTexProp = new(PropWindows)WDlgTexProp(NULL, OwnerWindow, GEditor->CurrentTexture );
						pDlgTexProp->DoModeless();
						pDlgTexProp->pProps->SetNotifyHook( GEditor );
					}
				}
				break;

			case IDMN_TB_DELETE:
				{
					if( !GEditor->CurrentTexture )
					{
						appMsgf( TEXT("Select a texture first.") );
						break;
					}

					FString Name = GEditor->CurrentTexture->GetName();
					FStringOutputDevice GetPropResult = FStringOutputDevice();
					TCHAR l_chCmd[256];

					appSprintf( l_chCmd, TEXT("DELETE CLASS=TEXTURE OBJECT=\"%s\""), *Name);
				    GEditor->Get( TEXT("Obj"), l_chCmd, GetPropResult);

					if( !GetPropResult.Len() )
					{
						RefreshPackages();
						RefreshGroups();
						RefreshTextureList();
					}
					else
					{
						appMsgf( TEXT("Can't delete texture.\n\n%s"), *GetPropResult );
					}
				}
				break;

			case IDMN_TB_PREV_GRP:
				{
					INT Sel = pComboGroup->GetCurrent();
					Sel--;
					if( Sel < 0 ) Sel = pComboGroup->GetCount() - 1;
					pComboGroup->SetCurrent(Sel);
					RefreshTextureList();
				}
				break;

			case IDMN_TB_NEXT_GRP:
				{
					INT Sel = pComboGroup->GetCurrent();
					Sel++;
					if( Sel >= pComboGroup->GetCount() ) Sel = 0;
					pComboGroup->SetCurrent(Sel);
					RefreshTextureList();
				}
				break;

			case IDMN_TB_RENAME:
				{
					if( !GEditor->CurrentTexture )
					{
						appMsgf( TEXT("Select a texture first.") );
						break;
					}

					WDlgRename dlg( NULL, this );
					if( dlg.DoModal( GEditor->CurrentTexture->GetName() ) )
						GEditor->CurrentTexture->Rename( *dlg.NewName );
					RefreshTextureList();
				}
				break;

			case IDMN_TB_REMOVE:
				{
					if( !GEditor->CurrentTexture )
					{
						appMsgf( TEXT("Select a texture first.") );
						break;
					}

					debugf(TEXT("Removing texture %s from level"),GEditor->CurrentTexture->GetFullName());
					for( TArray<AActor*>::TIterator ItA(GEditor->Level->Actors); ItA; ++ItA )
					{
						AActor* Actor = *ItA;
						if( Actor )
						{
							UModel* M = Actor->IsA(ALevelInfo::StaticClass()) ? Actor->GetLevel()->Model : Actor->Brush;
							if( M )
							{
								for( TArray<FBspSurf>::TIterator ItS(M->Surfs); ItS; ++ItS )
									if( ItS->Texture==GEditor->CurrentTexture )
										ItS->Texture = NULL;
								if( M->Polys )
									for( TArray<FPoly>::TIterator ItP(M->Polys->Element); ItP; ++ItP )
										if( ItP->Texture==GEditor->CurrentTexture )
											ItP->Texture = NULL;
							}
						}
					}
					GEditor->RedrawLevel(NULL);
				}
				break;

			case IDMN_TB_CULL:
				{
					GEditor->Exec( TEXT("TEXTURE CULL"));
					appMsgf(TEXT("Texture cull complete.  Check log file for detailed report."));
				}
				break;

			case IDMN_TB_COUNTTEX:
				{
					if( !GEditor->CurrentTexture )
					{
						appMsgf( TEXT("Select a texture first.") );
						break;
					}

					WDlgTexUsage dlg( NULL, this );
					dlg.DoModal(hInstance);
				}
				break;

			case IDMN_TB_ZOOM_32:
				iZoom = 32;
				iScroll = 0;
				RefreshTextureList();
				break;

			case IDMN_TB_ZOOM_64:
				iZoom = 64;
				iScroll = 0;
				RefreshTextureList();
				break;

			case IDMN_TB_ZOOM_128:
				iZoom = 128;
				iScroll = 0;
				RefreshTextureList();
				break;

			case IDMN_TB_ZOOM_256:
				iZoom = 256;
				iScroll = 0;
				RefreshTextureList();
				break;

			case IDMN_VAR_200:
				iZoom = 1200;
				iScroll = 0;
				RefreshTextureList();
				break;

			case IDMN_VAR_100:
				iZoom = 1100;
				iScroll = 0;
				RefreshTextureList();
				break;

			case IDMN_VAR_50:
				iZoom = 1050;
				iScroll = 0;
				RefreshTextureList();
				break;

			case IDMN_VAR_25:
				iZoom = 1025;
				iScroll = 0;
				RefreshTextureList();
				break;

			case IDMN_TB_FileOpen:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "Texture Packages (*.dtx)\0*.dtx\0All Files\0*.*\0\0";
					ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DTX]) );
					ofn.lpstrDefExt = "dtx";
					ofn.lpstrTitle = "Open Texture Package";
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
							GLastDir[eLASTDIR_DTX] = StringArray(0).Left( StringArray(0).InStr( TEXT("\\"), 1 ) );
						else
							GLastDir[eLASTDIR_DTX] = StringArray(0);

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
						pComboPackage->SetCurrent( pComboPackage->FindStringExact( *SavePkgName ) );
						RefreshGroups();
						RefreshTextureList();
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
				}
				break;

			case IDMN_TB_FileSave:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";
					FString Package = pComboPackage->GetString( pComboPackage->GetCurrent() );

					::sprintf( File, "%s.Dtx", TCHAR_TO_ANSI( *Package ) );

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "Texture Packages (*.dtx)\0*.dtx\0All Files\0*.*\0\0";
					ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DTX]) );
					ofn.lpstrDefExt = "dtx";
					ofn.lpstrTitle = "Save Texture Package";
					ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

					if( GetSaveFileNameA(&ofn) )
					{
						TCHAR l_chCmd[256];

						appSprintf( l_chCmd, TEXT("OBJ SAVEPACKAGE PACKAGE=\"%s\" FILE=\"%s\""),
							*Package, appFromAnsi( File ) );
						GEditor->Exec( l_chCmd );

						FString S = appFromAnsi( File );
						mrulist->AddItem( S );
						if( GBrowserMaster->GetCurrent()==BrowserID )
							mrulist->AddToMenu( hWnd, GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd ) );
						GLastDir[eLASTDIR_DTX] = S.Left( S.InStr( TEXT("\\"), 1 ) );
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

				FString Package = Filename.Right( Filename.Len() - (Filename.InStr( TEXT("\\"), 1) + 1) );
				Package = Package.Left( Package.InStr( TEXT(".")) );

				GBrowserMaster->RefreshAll();
				RefreshPackages();
				pComboPackage->SetCurrent( pComboPackage->FindStringExact( *Package ) );
				RefreshGroups();
				RefreshTextureList();
			}
			break;

			case IDMN_TB_IMPORT_PCX:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					//ofn.lpstrFilter = "PCX Files (*.pcx)\0*.pcx\0All Files\0*.*\0\0";
					//ofn.lpstrDefExt = "pcx";
					ofn.lpstrFilter = "Supported formats (*.bmp,*.pcx,*.tga,*.dds)\0*.pcx;*.bmp;*.tga;*.dds\0BMP Files (*.bmp)\0*.bmp\0PCX Files (*.pcx)\0*.pcx\0Targa Files (*.tga)\0*.tga\0DXT Files (*.dds)\0*.dds\0All Files\0*.*\0\0";
					ofn.nFilterIndex= 1;
					ofn.lpstrDefExt= "bmp";
					ofn.lpstrTitle = "Import Textures";
					ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_PCX]) );
					ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_ALLOWMULTISELECT | OFN_EXPLORER;

					// Display the Open dialog box. 
					//
					if( GetOpenFileNameA(&ofn) )
					{
						INT iNULLs = FormatFilenames( File );
						FString Package = pComboPackage->GetString( pComboPackage->GetCurrent() );
						FString Group = pComboGroup->GetString( pComboGroup->GetCurrent() );
		
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

						if( StringArray.Num() == 1 )
							GLastDir[eLASTDIR_PCX] = StringArray(0).Left( StringArray(0).InStr( TEXT("\\"), 1 ) );
						else
							GLastDir[eLASTDIR_PCX] = StringArray(0);

						TArray<FString> FilenamesArray;

						for( INT x = iStart ; x < StringArray.Num() ; x++ )
						{
							FString NewString;

							NewString = FString::Printf( TEXT("%s%s"), *Prefix, *(StringArray(x)) );
							new(FilenamesArray)FString( NewString );

							FString S = NewString;
						}

						WDlgImportTexture l_dlg( NULL, this );
						l_dlg.DoModal( Package, Group, &FilenamesArray );

						// Flip to the texture/group that was used for importing
						GBrowserMaster->RefreshAll();
						pComboPackage->SetCurrent( pComboPackage->FindStringExact( *l_dlg.Package) );
						RefreshGroups();
						pComboGroup->SetCurrent( pComboGroup->FindStringExact( *l_dlg.Group) );
						if(pViewport&&pViewport->RenDev)
						{
							// Flush the viewport:
							pViewport->RenDev->Flush(0); 
						}
						RefreshTextureList();
						
						StringArray.Empty();
						FilenamesArray.Empty();
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
				}
				break;

			case IDMN_TB_EXPORT_PCX:
				{
					if( !GEditor->CurrentTexture )
					{
						appMsgf( TEXT("Select a texture first.") );
						break;
					}

					OPENFILENAMEA ofn;
					char File[8192] = "\0";
					FString Name = GEditor->CurrentTexture->GetName();

					::sprintf( File, "%s", TCHAR_TO_ANSI( *Name ) );

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.nFilterIndex = 1;
					ofn.lpstrTitle = "Export Texture";
					ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_PCX]) );
					ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

					//!! ugly + retarded
					switch( GEditor->CurrentTexture->Format )
					{
					case TEXF_P8:
						ofn.lpstrFilter = "8-bit Palettized BMP (*.bmp)\0*.bmp\0""8-bit Palettized PCX (*.pcx)\0*.pcx\0\0";
						ofn.lpstrDefExt = "bmp";
						break;
					case TEXF_G16:
						ofn.lpstrFilter = "16-bit Grayscale BMP (*.bmp)\0*.bmp\0";
						ofn.lpstrDefExt = "bmp";
						break;
					case TEXF_RGBA8:
						ofn.lpstrFilter = "32-bit Targa (*.tga)\0*.tga\0""24-bit BMP (*.bmp)\0*.bmp\0""24-bit PCX (*.pcx)\0*.pcx\0\0";
						ofn.lpstrDefExt = "tga";
						break;
					}

					// Display the Open dialog box. 
					//
					if( GetSaveFileNameA(&ofn) )
					{
						TCHAR l_chCmd[512];

						appSprintf( l_chCmd, TEXT("OBJ EXPORT TYPE=TEXTURE NAME=\"%s\" FILE=\"%s\""),
							*Name, appFromAnsi( File ) );
						GEditor->Exec( l_chCmd );

						FString S = appFromAnsi( File );
						GLastDir[eLASTDIR_PCX] = S.Left( S.InStr( TEXT("\\"), 1 ) );
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
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
		RefreshScrollBar();
		UpdateMenu();
	}
	virtual void RefreshAll()
	{
		RefreshPackages();
		RefreshGroups();
		RefreshTextureList();
		if( GBrowserMaster->GetCurrent()==BrowserID )
			mrulist->AddToMenu( hWnd, GetMenu( IsDocked() ? OwnerWindow->hWnd : hWnd ) );
	}
	void RefreshPackages( void )
	{
		INT Current = pComboPackage->GetCurrent();
		Current = (Current != CB_ERR) ? Current : 0;

		// PACKAGES
		//
		pComboPackage->Empty();

		FStringOutputDevice GetPropResult = FStringOutputDevice();
		GEditor->Get( TEXT("OBJ"), TEXT("PACKAGES CLASS=Texture"), GetPropResult );

		TArray<FString> StringArray;
		ParseStringToArray( TEXT(","), *GetPropResult, &StringArray );

		for( INT x = 0 ; x < StringArray.Num() ; x++ )
			pComboPackage->AddString( *(StringArray(x)) );

		pComboPackage->SetCurrent( 0 );

		pComboPackage->SetCurrent( Current );
	}
	void RefreshGroups( void )
	{
		FString Package = pComboPackage->GetString( pComboPackage->GetCurrent() );
		INT Current = pComboGroup->GetCurrent();
		Current = (Current != CB_ERR) ? Current : 0;

		// GROUPS
		//
		pComboGroup->Empty();

		FStringOutputDevice GetPropResult = FStringOutputDevice();
		TCHAR l_ch[256];
		appSprintf( l_ch, TEXT("GROUPS CLASS=Texture PACKAGE=\"%s\""), *Package );
		GEditor->Get( TEXT("OBJ"), l_ch, GetPropResult );

		TArray<FString> StringArray;
		ParseStringToArray( TEXT(","), *GetPropResult, &StringArray );

		for( INT x = 0 ; x < StringArray.Num() ; x++ )
		{
			pComboGroup->AddString( *(StringArray(x)) );
		}

		pComboGroup->SetCurrent(Current);
	}
	void RefreshTextureList( void )
	{
		FString Package = pComboPackage->GetString( pComboPackage->GetCurrent() );
		FString Group = pComboGroup->GetString( pComboGroup->GetCurrent() );
		FString NameFilter = pEditFilter->GetText();

		TCHAR l_chCmd[1024];

		if( pCheckGroupAll->IsChecked() )
		{
			appSprintf( l_chCmd, TEXT("CAMERA UPDATE FLAGS=%d MISC1=%d MISC2=%d REN=%d NAME=TextureBrowser PACKAGE=\"%s\" GROUP=\"%s\" NAMEFILTER=\"%s\""),
				SHOW_StandardView | SHOW_NoButtons | SHOW_ChildWindow,
				iZoom,
				iScroll,
				REN_TexBrowser,
				*Package,
				TEXT("(All)"),
				*NameFilter);
		}
		else
		{
			appSprintf( l_chCmd, TEXT("CAMERA UPDATE FLAGS=%d MISC1=%d MISC2=%d REN=%d NAME=TextureBrowser PACKAGE=\"%s\" GROUP=\"%s\" NAMEFILTER=\"%s\""),
				SHOW_StandardView | SHOW_NoButtons | SHOW_ChildWindow,
				iZoom,
				iScroll,
				REN_TexBrowser,
				*Package,
				*Group,
				*NameFilter);
		}
		GEditor->Exec( l_chCmd );

		RefreshScrollBar();
		UpdateMenu();


	}
	void RefreshScrollBar( void )
	{
		if( !pScrollBar ) return;

		// Set the scroll bar to have a valid range.
		//
		SCROLLINFO si;
		si.cbSize = sizeof(SCROLLINFO);
		si.fMask = SIF_DISABLENOSCROLL | SIF_RANGE | SIF_POS;
		si.nMin = 0;
		si.nMax = GLastScroll;
		si.nPos = iScroll;
		iScroll = SetScrollInfo( pScrollBar->hWnd, SB_CTL, &si, TRUE );
	}

	// Moves the child windows around so that they best match the window size.
	//
	void PositionChildControls( void )
	{
		if( !pComboPackage
			|| !pComboGroup
			|| !pCheckGroupAll 
			|| !pLabelFilter
			|| !pEditFilter
			|| !pScrollBar
			|| !pViewport )
		return;

		FRect CR = GetClientRect();
		RECT R;
		::GetClientRect( hWndToolBar, &R );

		FLOAT Top = R.bottom + 4;
		::MoveWindow( pComboPackage->hWnd, 4, Top, CR.Width() - 8, 20, 1 );

		Top += 24;
		::MoveWindow( pCheckGroupAll->hWnd, 5,		Top, 32,	20, 1 );
		::MoveWindow( pComboGroup->hWnd, 4 + 32, Top, CR.Max.X - 8 - 32, 20, 1 );

		Top += 24;
		::MoveWindow( (HWND)pViewport->GetWindow(), 4, Top, CR.Width() - 20, CR.Height() - 80 - R.bottom, 1 );
		pViewport->Repaint(1);
		::MoveWindow( pScrollBar->hWnd, CR.Width() - 16, Top, 16, CR.Height() - 80 - R.bottom, 1 );

		Top += CR.Height() - 80 - R.bottom + 4;
		::MoveWindow( pLabelFilter->hWnd, 4, Top + 2, 48, 20, 1 );
		::MoveWindow( pEditFilter->hWnd, 4 + 48, Top, CR.Width() - 48, 20, 1 );
	}
	virtual void SetCaption( FString* Tail = NULL )
	{
		FString Extra;
		if( GEditor->CurrentTexture )
			Extra = *(FString::Printf( TEXT("%s (%dx%d)"),
				GEditor->CurrentTexture->GetName(), GEditor->CurrentTexture->USize, GEditor->CurrentTexture->VSize ) );

		WBrowser::SetCaption( &Extra );
	}

	// Notification delegates for child controls.
	//
	void OnComboPackageSelChange()
	{
		RefreshGroups();
		iScroll = 0;
		RefreshTextureList();
	}
	void OnComboGroupSelChange()
	{
		iScroll = 0;
		RefreshTextureList();
	}
	void OnGroupAllClick()
	{
		EnableWindow( pComboGroup->hWnd, !pCheckGroupAll->IsChecked() );
		RefreshTextureList();
	}
	void OnEditFilterChange()
	{
		RefreshTextureList();
	}
	virtual void OnVScroll( WPARAM wParam, LPARAM lParam )
	{
		if( (HWND)lParam == pScrollBar->hWnd ) {

			switch(LOWORD(wParam)) {

				case SB_LINEUP:
					iScroll -= 64;
					iScroll = Max( iScroll, 0 );
					RefreshTextureList();
					break;

				case SB_LINEDOWN:
					iScroll += 64;
					iScroll = Min( iScroll, GLastScroll );
					RefreshTextureList();
					break;

				case SB_PAGEUP:
					iScroll -= 256;
					iScroll = Max( iScroll, 0 );
					RefreshTextureList();
					break;

				case SB_PAGEDOWN:
					iScroll += 256;
					iScroll = Min( iScroll, GLastScroll );
					RefreshTextureList();
					break;

				case SB_THUMBTRACK:
					iScroll = (short int)HIWORD(wParam);
					RefreshTextureList();
					break;
			}
		}
	}
	LONG WndProc( UINT Message, UINT wParam, LONG lParam )
	{
		if ( Message == WM_MOUSEWHEEL )
		{
			signed short Scroll = HIWORD(wParam);
			debugf( _T("WM_MOUSEWHEEL %i %i"), Scroll, Scroll / 120 );
			if ( Scroll > 0 )
			{
				iScroll -= 64;
				iScroll = Max( iScroll, 0 );
				RefreshTextureList();
			} else {
				iScroll += 64;
				iScroll = Min( iScroll, GLastScroll );
				RefreshTextureList();
			}
			return 1;
		}
		return WBrowser::WndProc( Message, wParam, lParam );
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
