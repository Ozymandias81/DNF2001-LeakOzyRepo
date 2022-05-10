/*=============================================================================
	BrowserActor : Browser window for actor classes
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

// --------------------------------------------------------------
//
// NEW CLASS Dialog
//
// --------------------------------------------------------------

class WDlgNewClass : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgNewClass,WDialog,DukeEd)

	// Variables.
	WButton OkButton;
	WButton CancelButton;
	WLabel ParentLabel;
	WEdit PackageEdit;
	WEdit NameEdit;

	FString ParentClass, Package, Name;

	// Constructor.
	WDlgNewClass( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog			( TEXT("New Class"), IDDIALOG_NEW_CLASS, InOwnerWindow )
	,	OkButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOk) )
	,	CancelButton	( this, IDCANCEL,		FDelegate(this,(TDelegate)EndDialogFalse) )
	,	ParentLabel		( this, IDSC_PARENT )
	,	PackageEdit		( this, IDEC_PACKAGE )
	,	NameEdit		( this, IDEC_NAME )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		ParentLabel.SetText( *ParentClass );
		PackageEdit.SetText( TEXT("MyPackage") );
		NameEdit.SetText( *(FString::Printf(TEXT("My%s"), *ParentClass) ) );
		::SetFocus( PackageEdit.hWnd );
	}
	void OnDestroy()
	{
		WDialog::OnDestroy();
	}
	virtual INT DoModal( FString _ParentClass )
	{
		ParentClass = _ParentClass;

		return WDialog::DoModal( hInstance );
	}
	void OnOk()
	{
		if( GetDataFromUser() )
		{
			// Check if class already exists.
			//

			// Create new class.
			//
			GEditor->Exec( *(FString::Printf( TEXT("CLASS NEW NAME=\"%s\" PACKAGE=\"%s\" PARENT=\"%s\""),
				*Name, *Package, *ParentClass)) );
			GEditor->Exec( *(FString::Printf(TEXT("SETCURRENTCLASS CLASS=\"%s\""), *Name)) );

			// Create standard header for the new class.
			//
			char ch13 = '\x0d', ch10 = '\x0a';
			FString S = FString::Printf(
				TEXT("//=============================================================================%c%c// %s.%c%c//=============================================================================%c%cclass %s expands %s;%c%c"),
				ch13, ch10,
				*Name, ch13, ch10,
				ch13, ch10,
				*Name, *ParentClass, ch13, ch10);
			GEditor->Set(TEXT("SCRIPT"), *Name, *S);

			EndDialog(TRUE);
		}
	}
	BOOL GetDataFromUser( void )
	{
		Package = PackageEdit.GetText();
		Name = NameEdit.GetText();

		if( !Package.Len()
				|| !Name.Len() )
		{
			appMsgf( TEXT("Invalid input.") );
			return FALSE;
		}
		else
			return TRUE;
	}
};

// --------------------------------------------------------------
//
// WBrowserActor
//
// --------------------------------------------------------------

#define ID_BA_TOOLBAR	29030
TBBUTTON tbBAButtons[] = {
	{ 0, IDMN_MB_DOCK, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 1, IDMN_AB_FileOpen, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 2, IDMN_AB_FileSave, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 3, IDMN_AB_NEW_CLASS, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 4, IDMN_AB_EDIT_SCRIPT, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 5, IDMN_AB_DEF_PROP, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
};
struct {
	TCHAR ToolTip[64];
	INT ID;
} ToolTips_BA[] = {
	TEXT("Toggle Dock Status"), IDMN_MB_DOCK,
	TEXT("Open Package"), IDMN_AB_FileOpen,
	TEXT("Save Selected Packages"), IDMN_AB_FileSave,
	TEXT("New Script"), IDMN_AB_NEW_CLASS,
	TEXT("Edit Script"), IDMN_AB_EDIT_SCRIPT,
	TEXT("Edit Default Properties"), IDMN_AB_DEF_PROP,
	NULL, 0
};

class WBrowserActor : public WBrowser
{
	DECLARE_WINDOWCLASS(WBrowserActor,WBrowser,Window)

	WTreeView* pTreeView;
	WCheckBox* pInfoActorCheck;
	WCheckBox* pRenderActorCheck;
	WCheckListBox* pPackagesList;
	WLabel* pPinLabel;
	HTREEITEM htiRoot, htiLastSel;
	HWND hWndToolBar;
	WToolTip* ToolTipCtrl;

	HMENU BrowserActorMenu;
	HMENU BrowserActorContext;

	UBOOL bShowPackages;
	UBOOL bCustomPin;
	FString CustomPinName;

	// Structors.
	WBrowserActor( FName InPersistentName, WWindow* InOwnerWindow, HWND InEditorFrame )
	:	WBrowser( InPersistentName, InOwnerWindow, InEditorFrame )
	{
		pTreeView = NULL;
		pInfoActorCheck = NULL;
		pRenderActorCheck = NULL;
		pPinLabel = NULL;
		htiRoot = htiLastSel = NULL;
		MenuID = IDMENU_BrowserActor;
		BrowserID = eBROWSER_ACTOR;
		Description = TEXT("Actor Classes");
		bCustomPin = 0;
	}

	// WBrowser interface.
	void OpenWindow( UBOOL bChild )
	{
		WBrowser::OpenWindow( bChild );
		SetCaption();
	}
	virtual void SetCaption( FString* Tail = NULL )
	{
		FString Extra;
		if( GEditor->CurrentClass )
		{
			Extra = GEditor->CurrentClass->GetFullName();
			Extra = Extra.Right( Extra.Len() - 6 );	// remove "class" from the front of it
		}

		WBrowser::SetCaption( &Extra );
	}
	void OnCreate()
	{
		WBrowser::OnCreate();

		BrowserActorMenu = LoadMenuIdX(hInstance, IDMENU_BrowserActor);
		SetMenu( hWnd, BrowserActorMenu );
		
		BrowserActorContext = LoadMenuIdX(hInstance, IDMENU_BrowserActor_Context);

		pInfoActorCheck = new WCheckBox( this, IDCK_INFOACTOR );
		pInfoActorCheck->ClickDelegate = FDelegate(this, (TDelegate)OnInfoActorClick);
		pInfoActorCheck->OpenWindow( 1, 0, 0, 1, 1, TEXT("InfoActor Only") );

		pRenderActorCheck = new WCheckBox( this, IDCK_RENDERACTOR );
		pRenderActorCheck->ClickDelegate = FDelegate(this, (TDelegate)OnRenderActorClick);
		pRenderActorCheck->OpenWindow( 1, 0, 0, 1, 1, TEXT("RenderActor Only") );

		pPinLabel = new WLabel( this, IDSC_PINLABEL );
		pPinLabel->OpenWindow( 1, 0 );

		pTreeView = new WTreeView( this, IDTV_TREEVIEW );
		pTreeView->OpenWindow( 1, 1, 0, 0, 1 );
		pTreeView->SelChangedDelegate = FDelegate(this, (TDelegate)OnTreeViewSelChanged);
		pTreeView->ItemExpandingDelegate = FDelegate(this, (TDelegate)OnTreeViewItemExpanding);
		pTreeView->DblClkDelegate = FDelegate(this, (TDelegate)OnTreeViewDblClk);
		
		pPackagesList = new WCheckListBox( this, IDLB_PACKAGES );
		pPackagesList->OpenWindow( 1, 0, 0, 1 );

		if(!GConfig->GetInt( *PersistentName, TEXT("ShowPackages"), bShowPackages, TEXT("DukeEd.ini") ))		bShowPackages = 1;
		UpdateMenu();

		hWndToolBar = CreateToolbarEx( 
			hWnd, WS_CHILD | WS_BORDER | WS_VISIBLE | CCS_ADJUSTABLE,
			IDB_BrowserActor_TOOLBAR,
			6,
			hInstance,
			IDB_BrowserActor_TOOLBAR,
			(LPCTBBUTTON)&tbBAButtons,
			8,
			16,16,
			16,16,
			sizeof(TBBUTTON));
		check(hWndToolBar);

		ToolTipCtrl = new WToolTip(this);
		ToolTipCtrl->OpenWindow();
		for( INT tooltip = 0 ; ToolTips_BA[tooltip].ID > 0 ; tooltip++ )
		{
			// Figure out the rectangle for the toolbar button.
			INT index = SendMessageX( hWndToolBar, TB_COMMANDTOINDEX, ToolTips_BA[tooltip].ID, 0 );
			RECT rect;
			SendMessageX( hWndToolBar, TB_GETITEMRECT, index, (LPARAM)&rect);

			ToolTipCtrl->AddTool( hWndToolBar, ToolTips_BA[tooltip].ToolTip, tooltip, &rect );
		}

		PositionChildControls();
		RefreshPackages();
		RefreshActorList();
		SendMessageX( pTreeView->hWnd, TVM_EXPAND, TVE_EXPAND, (LPARAM)htiRoot );
	}
	virtual void UpdateMenu()
	{
		HMENU menu = IsDocked() ? GetMenu( OwnerWindow->hWnd ) : GetMenu( hWnd );

		CheckMenuItem( menu, IDMN_AB_SHOWPACKAGES, MF_BYCOMMAND | (bShowPackages ? MF_CHECKED : MF_UNCHECKED) );
		CheckMenuItem( menu, IDMN_MB_DOCK, MF_BYCOMMAND | (IsDocked() ? MF_CHECKED : MF_UNCHECKED) );
	}
	void RefreshPackages(void)
	{
		// PACKAGES
		//
		FStringOutputDevice GetPropResult = FStringOutputDevice();
	    GEditor->Get(TEXT("OBJ"), TEXT("PACKAGES CLASS=Class"), GetPropResult);

		TArray<FString> PkgArray;
		ParseStringToArray( TEXT(","), GetPropResult, &PkgArray );

		pPackagesList->Empty();

		for( INT x = 0 ; x < PkgArray.Num() ; x++ )
			pPackagesList->AddString( *(FString::Printf( TEXT("%s"), *PkgArray(x))) );
	}
	void OnDestroy()
	{
		delete pTreeView;
		delete pInfoActorCheck;
		delete pRenderActorCheck;
		delete pPinLabel;
		delete pPackagesList;

		::DestroyWindow( hWndToolBar );
		delete ToolTipCtrl;

		DestroyMenu( BrowserActorMenu );
		DestroyMenu( BrowserActorContext );

		GConfig->SetInt( *PersistentName, TEXT("ShowPackages"), bShowPackages, TEXT("DukeEd.ini") );

		WBrowser::OnDestroy();
	}
	void OnCommand( INT Command )
	{
		switch( Command )
		{
			case WM_TREEVIEW_RIGHT_CLICK:
				{
					// Select the tree item underneath the mouse cursor.
					TVHITTESTINFO tvhti;
					POINT ptScreen;
					::GetCursorPos( &ptScreen );
					tvhti.pt = ptScreen;
					::ScreenToClient( pTreeView->hWnd, &tvhti.pt );

					SendMessageX( pTreeView->hWnd, TVM_HITTEST, 0, (LPARAM)&tvhti);

					if( tvhti.hItem )
						SendMessageX( pTreeView->hWnd, TVM_SELECTITEM, TVGN_CARET, (LPARAM)(HTREEITEM)tvhti.hItem);

					// Show a context menu for the currently selected item.
					HMENU menu = GetSubMenu( BrowserActorContext, 0 );
					TrackPopupMenu( menu,
						TPM_LEFTALIGN | TPM_TOPALIGN | TPM_RIGHTBUTTON,
						ptScreen.x, ptScreen.y, 0,
						hWnd, NULL);
				}
				break;

			case IDMN_AB_EXPORT_ALL:
				{
					if( ::MessageBox( hWnd, TEXT("This option will export all classes to text .uc files which can later be rebuilt. Do you want to do this?"), TEXT("Export classes to *.uc files"), MB_YESNO) == IDYES)
					{
						GEditor->Exec( TEXT("CLASS SPEW ALL") );
					}
				}
				break;

			case IDMN_AB_EXPORT:
				{
					if( ::MessageBox( hWnd, TEXT("This option will export all modified classes to text .uc files which can later be rebuilt. Do you want to do this?"), TEXT("Export classes to *.uc files"), MB_YESNO) == IDYES)
					{
						GEditor->Exec( TEXT("CLASS SPEW") );
					}
				}
				break;

			case IDMN_AB_SHOWPACKAGES:
				{
					bShowPackages = !bShowPackages;
					PositionChildControls();
					UpdateMenu();
				}
				break;

			case IDMN_AB_PIN_CLASS:
				bCustomPin = 1;
				CustomPinName = FString::Printf( TEXT(" %s"), GEditor->CurrentClass->GetName() );
				::EnableWindow( pRenderActorCheck->hWnd, 0 );
				::EnableWindow( pInfoActorCheck->hWnd, 0 );
				pPinLabel->SetText( TEXT("*Custom Tree Root*") );
				RefreshActorList();
				break;

			case IDMN_AB_UNPIN_CLASS:
				bCustomPin = 0;
				::EnableWindow( pRenderActorCheck->hWnd, 1 );
				::EnableWindow( pInfoActorCheck->hWnd, 1 );
				pPinLabel->SetText( TEXT("") );
				RefreshActorList();
				break;

			case IDMN_AB_NEW_CLASS:
				{
					WDlgNewClass l_dlg( NULL, this );
					if( l_dlg.DoModal( GEditor->CurrentClass ? GEditor->CurrentClass->GetName() : TEXT("Actor") ) )
					{
						// Open an editing window.
						//
						GCodeFrame->AddClass( GEditor->CurrentClass );
						RefreshActorList();
						RefreshPackages();
					}
				}
				break;

			case IDMN_AB_DELETE:
				{
					if( GEditor->CurrentClass )
					{
						FString CurName = GEditor->CurrentClass->GetName();
						GEditor->Exec( TEXT("SETCURRENTCLASS Class=Light") );

						TCHAR l_chCmd[256];
						FStringOutputDevice GetPropResult = FStringOutputDevice();
						appSprintf( l_chCmd, TEXT("DELETE CLASS=CLASS OBJECT=\"%s\""), *CurName );
						
						GEditor->Get( TEXT("OBJ"), l_chCmd, GetPropResult);

						if( !GetPropResult.Len() )
						{
							// Try to cleanly update the actor list.  If this fails, just reload it from scratch...
							if( !SendMessageX( pTreeView->hWnd, TVM_DELETEITEM, 0, (LPARAM)htiLastSel ) )
								RefreshActorList();

							GCodeFrame->RemoveClass( CurName );
						}
						else
							appMsgf( TEXT("Can't delete class") );
					}
				}
				break;

			case IDMN_AB_DEF_PROP:
				GEditor->Exec( *(FString::Printf(TEXT("HOOK CLASSPROPERTIES CLASS=\"%s\""), GEditor->CurrentClass->GetName())) );
				break;

			case IDMN_AB_FileOpen:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "Class Packages (*.u)\0*.u\0All Files\0*.*\0\0";
					ofn.lpstrInitialDir = "..\\system";
					ofn.lpstrDefExt = "u";
					ofn.lpstrTitle = "Open Class Package";
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

						for( INT x = iStart ; x < StringArray.Num() ; x++ )
						{
							TCHAR l_chCmd[512];

							appSprintf( l_chCmd, TEXT("CLASS LOAD FILE=\"%s%s\""), *Prefix, *(StringArray(x)) );
							GEditor->Exec( l_chCmd );
						}

						GBrowserMaster->RefreshAll();
						RefreshPackages();
					}

					GFileManager->SetDefaultDirectory(appBaseDir());
					RefreshPackages();
				}
				break;

			case IDMN_AB_FileSave:
				{
					FString Pkg;

					GWarn->BeginSlowTask( TEXT("Saving Packages"), 1, 0 );

					for( INT x = 0 ; x < pPackagesList->GetCount() ; x++ )
					{
						if( (int)pPackagesList->GetItemData(x) )
						{
							Pkg = *(pPackagesList->GetString( x ));
							GEditor->Exec( *(FString::Printf(TEXT("OBJ SAVEPACKAGE PACKAGE=\"%s\" FILE=\"%s.u\""), *Pkg, *Pkg )) );
						}
					}

					GWarn->EndSlowTask();
				}
				break;

			case IDMN_AB_EDIT_SCRIPT:
				{
					GCodeFrame->AddClass( GEditor->CurrentClass );
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
	void PositionChildControls( void )
	{
		if ( !pTreeView || !pInfoActorCheck || !pRenderActorCheck || !pPinLabel || !pPackagesList )
			return;

		FRect CR = GetClientRect();
		RECT R;
		::GetClientRect( hWndToolBar, &R );
		FLOAT Fraction = (CR.Width() - 8) / 10.0f;
		FLOAT Top = 4 + R.bottom;

		::MoveWindow( pInfoActorCheck->hWnd, 4, Top, 110, 20, 1 );
		::MoveWindow( pRenderActorCheck->hWnd, 120, Top, 110, 20, 1 );
		::MoveWindow( pPinLabel->hWnd, 240, Top+4, 130, 14, 1 );
		Top += 20;

		if( bShowPackages )
		{
			::MoveWindow( pTreeView->hWnd, 4, Top, CR.Width() - 8, ((CR.Height() / 3) * 2) - Top, 1 );	Top += ((CR.Height() / 3) * 2) - Top;
			::MoveWindow( pPackagesList->hWnd, 4, Top, CR.Width() - 8, (CR.Height() / 3) - 4, 1);
			debugf(TEXT("%1.2f %1.2f %1.2f %1.2f"),
				(FLOAT)4,
				(FLOAT)(Top),
				(FLOAT)(CR.Width() - 8),
				(FLOAT)((CR.Height() / 3) - 4 ));
		}
		else
		{
			::MoveWindow( pTreeView->hWnd, 4, Top, CR.Width() - 8, CR.Height() - Top - 4, 1 );
			::MoveWindow( pPackagesList->hWnd, 0, 0, 0, 0, 1);
		}

		::InvalidateRect( hWnd, NULL, 1);
	}
	virtual void RefreshAll()
	{
		RefreshActorList();
	}
	void RefreshActorList( void )
	{
		pTreeView->Empty();

		if ( bCustomPin )
		{
			htiRoot = pTreeView->AddItem( *CustomPinName, NULL, TRUE );
		}
		else
		{
			if ( pInfoActorCheck->IsChecked() )
				htiRoot = pTreeView->AddItem( TEXT(" InfoActor"), NULL, TRUE );
			else if ( pRenderActorCheck->IsChecked() )
				htiRoot = pTreeView->AddItem( TEXT(" RenderActor"), NULL, TRUE );
			else
				htiRoot = pTreeView->AddItem( TEXT(" Object"), NULL, TRUE );
		}

		htiLastSel = NULL;
	}
	void AddChildren( const TCHAR* pParentName, HTREEITEM hti )
	{
		HTREEITEM newhti;
		FString String, StringQuery;

		FString ParentName = pParentName;
		ParentName = ParentName.Right( ParentName.Len() - 1 );	// Remove any "placeable" markers

		StringQuery = FString::Printf( TEXT("Query Parent=\"%s\""), *ParentName );
		Query( GEditor->Level, *StringQuery, &String );

		TArray<FString> StringArray;
		ParseStringToArray( TEXT(","), String, &StringArray );

		for( INT x = 0 ; x < StringArray.Num() ; x++ )
		{
			FString NewName = *(StringArray(x)), Children;

			Children = NewName.Left(1);
			NewName = NewName.Right( NewName.Len() - 1 );

			newhti = pTreeView->AddItem( *NewName, hti, Children == TEXT("C") );
		}
	}
	void OnTreeViewSelChanged( void )
	{
		NMTREEVIEW* pnmtv = (LPNMTREEVIEW)pTreeView->LastlParam;
		TCHAR chText[128] = TEXT("\0");
		TVITEM tvi;

		appMemzero( &tvi, sizeof(tvi));
		htiLastSel = tvi.hItem = pnmtv->itemNew.hItem;
		tvi.mask = TVIF_TEXT;
		tvi.pszText = chText;
		tvi.cchTextMax = sizeof(chText);

		if( SendMessageX( pTreeView->hWnd, TVM_GETITEM, 0, (LPARAM)&tvi) )
		{
			FString Classname = tvi.pszText;
			Classname = Classname.Right( Classname.Len()-1 );
			GEditor->Exec( *(FString::Printf(TEXT("SETCURRENTCLASS CLASS=\"%s\""), *Classname )));
		}
		SetCaption();
	}
	void OnTreeViewItemExpanding( void )
	{
		NMTREEVIEW* pnmtv = (LPNMTREEVIEW)pTreeView->LastlParam;
		TCHAR chText[128] = TEXT("\0");

		TVITEM tvi;

		appMemzero( &tvi, sizeof(tvi));
		tvi.hItem = pnmtv->itemNew.hItem;
		tvi.mask = TVIF_TEXT;
		tvi.pszText = chText;
		tvi.cchTextMax = sizeof(chText);

		// If this item already has children loaded, bail...
		if( SendMessageX( pTreeView->hWnd, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)pnmtv->itemNew.hItem ) )
			return;

		if( SendMessageX( pTreeView->hWnd, TVM_GETITEM, 0, (LPARAM)&tvi) )
			AddChildren( tvi.pszText, pnmtv->itemNew.hItem );
	}
	void OnTreeViewDblClk( void )
	{
		GCodeFrame->AddClass( GEditor->CurrentClass );
	}
	void OnInfoActorClick()
	{
		SendMessageX( pRenderActorCheck->hWnd, BM_SETCHECK, BST_UNCHECKED, 0 );
		RefreshActorList();
		SendMessageX( pTreeView->hWnd, TVM_EXPAND, TVE_EXPAND, (LPARAM)htiRoot );
	}
	void OnRenderActorClick()
	{
		SendMessageX( pInfoActorCheck->hWnd, BM_SETCHECK, BST_UNCHECKED, 0 );
		RefreshActorList();
		SendMessageX( pTreeView->hWnd, TVM_EXPAND, TVE_EXPAND, (LPARAM)htiRoot );
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
