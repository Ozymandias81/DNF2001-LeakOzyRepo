/*=============================================================================
	MapErrors : Displays errors/warnings for the map.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-MapErrors todo's:

=============================================================================*/

struct {
	char* Text;
	INT Width;
} GCols[] =
{
	"Actor", 80,
	"Message", 500,
	NULL, -1,
};

class WDlgMapErrors : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgMapErrors,WDialog,DukeEd)

	WButton CancelButton;
	HIMAGELIST himl;

	// Variables.
	WButton RefreshButton, CloseButton;
	WListView ErrorList;

	// Constructor.
	WDlgMapErrors( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog				( TEXT("Map Errors/Warnings"), IDDIALOG_MAP_ERRORS, InOwnerWindow )
	,	RefreshButton		( this, IDPB_REFRESH, FDelegate(this,(TDelegate)OnRefresh) )
	,	CloseButton			( this, IDCLOSE, FDelegate(this,(TDelegate)OnClose) )
	,	ErrorList			( this, IDLC_ERRORS )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		// Set up the list view
		LVCOLUMNA lvcol;
		lvcol.mask = LVCF_TEXT | LVCF_WIDTH;

		for( INT x = 0 ; GCols[x].Text ; x++ )
		{
			lvcol.pszText = GCols[x].Text;
			lvcol.cx = GCols[x].Width;

			SendMessageX( ErrorList.hWnd, LVM_INSERTCOLUMNA, x, (LPARAM)(const LPLVCOLUMNA)&lvcol );
		}

		himl = ImageList_LoadImage( hInstance, MAKEINTRESOURCE(IDBM_MAP_ERRORS), 16, 0, CLR_DEFAULT, IMAGE_BITMAP, LR_LOADMAP3DCOLORS );
		check(himl);
		ListView_SetImageList( ErrorList.hWnd, himl, LVSIL_SMALL );

		ErrorList.DblClkDelegate = FDelegate(this, (TDelegate)OnErrorListDblClk);
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual void DoModeless()
	{
		_Windows.AddItem( this );
		hWnd = CreateDialogParamA( hInstance, MAKEINTRESOURCEA(IDDIALOG_MAP_ERRORS), OwnerWindow?OwnerWindow->hWnd:NULL, (DLGPROC)StaticDlgProc, (LPARAM)this);
		if( !hWnd )
			appGetLastError();
	}
	void OnCommand( INT Command )
	{
		switch( Command )
		{
			case WM_ME_SHOW:
				Show(1);
				break;

			case WM_ME_SHOW_COND:
				if( SendMessageX( ErrorList.hWnd, LVM_GETITEMCOUNT, 0, 0 ) )
					Show(1);
				break;

			case WM_ME_CLEAR:
				ErrorList.Empty();
				break;

			case WM_ME_ADD:
				{
					MAPERROR* MapError;
					MapError = (MAPERROR*)LastlParam;

					// Add the message to the window.
					LVITEMA lvi;
					::ZeroMemory( &lvi, sizeof(lvi));
					lvi.mask = LVIF_TEXT | LVIF_IMAGE;
					lvi.pszText = (char*)appToAnsi(MapError->Actor->GetName());
					lvi.iItem = 0;
					lvi.iImage = 1;

					INT idx = SendMessageX( ErrorList.hWnd, LVM_INSERTITEMA, 0, (LPARAM)(const LPLVITEM)&lvi ); 
					if( idx > -1 )
					{
						::ZeroMemory( &lvi, sizeof(lvi));
						lvi.mask = LVIF_TEXT;
						lvi.pszText = (char*)appToAnsi( *MapError->Message );
						lvi.iItem = idx;
						lvi.iSubItem = 1;
						SendMessageX( ErrorList.hWnd, LVM_SETITEMA, 0, (LPARAM)(const LPLVITEM)&lvi );
					}
				}
				break;

			default:
				WWindow::OnCommand(Command);
				break;
		}
	}
	void OnRefresh()
	{
		GEditor->Exec(TEXT("MAP CHECK"));
	}
	void OnClose()
	{
		Show(0);
	}
	void OnErrorListDblClk()
	{
		INT idx = ErrorList.GetCurrent();
		if( idx == -1 ) return;	// Couldn't get valid selection

		char ActorName[80] = "";
		LVITEMA lvi;
		::ZeroMemory( &lvi, sizeof(lvi) );
		lvi.mask = LVIF_TEXT;
		lvi.cchTextMax = 80;
		lvi.pszText = ActorName;
		lvi.iItem = idx;

		SendMessageX( ErrorList.hWnd, LVM_GETITEMA, 0, (LPARAM)(LPLVITEM)&lvi );

		GEditor->Exec(TEXT("ACTOR SELECT NONE"));
		GEditor->Exec(*FString::Printf(TEXT("CAMERA ALIGN NAME=%s"), ANSI_TO_TCHAR( ActorName ) ) );
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
