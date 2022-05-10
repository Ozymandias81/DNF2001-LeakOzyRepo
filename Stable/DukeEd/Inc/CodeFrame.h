/*=============================================================================
	CodeFrame : This window is where all UnrealScript editing takes place
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

#pragma once

TArray<FString> GFindHistory, GReplaceHistory;
FString GSearchText;
UBOOL GMatchCase = 0;

class WDlgFindReplace : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgFindReplace,WDialog,DukeEd)

	// Variables.
	WButton FindButton;
	WButton FindNextButton;
	WButton FindPrevButton;
	WButton ReplaceButton;
	WButton ReplaceAllButton;
	WButton CancelButton;
	WButton CloseButton;
	WComboBox FindCombo;
	WComboBox ReplaceCombo;
	WCheckBox MatchCaseCheck;

	HWND EditHwnd;

	// Constructor.
	WDlgFindReplace( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog			( TEXT("Find/Replace"), IDDIALOG_FINDREPLACE, InOwnerWindow )
	,	FindButton			( this, IDPB_FIND,			FDelegate(this,(TDelegate)OnFind) )
	,	FindNextButton		( this, IDPB_FIND_NEXT,		FDelegate(this,(TDelegate)OnFindNext) )
	,	FindPrevButton		( this, IDPB_FIND_PREV,		FDelegate(this,(TDelegate)OnFindPrev) )
	,	ReplaceButton		( this, IDPB_REPLACE,		FDelegate(this,(TDelegate)OnReplace) )
	,	ReplaceAllButton	( this, IDPB_REPLACE_ALL,	FDelegate(this,(TDelegate)OnReplaceAll) )
	,	CloseButton			( this, IDPB_CLOSE,			FDelegate(this,(TDelegate)OnCloseButton) )
	,	FindCombo			( this, IDCB_FIND )
	,	ReplaceCombo		( this, IDCB_REPLACE )
	,	MatchCaseCheck		( this, IDCK_MATCH_CASE)
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		::SetFocus( FindCombo.hWnd );
		RefreshHistory();

		// If there is text selected, pull it in and make it the default text to search for.
		CHARRANGE range;
		SendMessageX( EditHwnd, EM_EXGETSEL, 0, (LPARAM)&range );

		if( range.cpMax - range.cpMin )
		{
			char Text[256] = "";

			TEXTRANGEA txtrange;
			txtrange.chrg = range;
			txtrange.lpstrText = Text;
			SendMessageX( EditHwnd, EM_GETTEXTRANGE, 0, (LPARAM)&txtrange );

			FindCombo.SetText( appFromAnsi( Text ) );
		}

		MatchCaseCheck.SetCheck( GMatchCase ? BST_CHECKED : BST_UNCHECKED );
	}
	void UpdateHistory( FString Find, FString Replace )
	{
		// FIND
		//
		if( Find.Len() )
		{
			// Check if value is already in the list.  If not, add it.
			for(INT x = 0 ; x < GFindHistory.Num() ; x++)
			{
				if( GFindHistory(x) == Find )
					break;
			}

			if( x == GFindHistory.Num() )
				GFindHistory.AddItem( Find );
		}

		// REPLACE
		//
		if( Replace.Len() )
		{
			for(INT x = 0 ; x < GReplaceHistory.Num() ; x++)
			{
				if( GReplaceHistory(x) == Replace )
					break;
			}

			if( x == GReplaceHistory.Num() )
				GReplaceHistory.AddItem( Replace );
		}
	}
	void RefreshHistory()
	{
		FindCombo.Empty();
		for( INT x = 0 ; x < GFindHistory.Num() ; x++ )
		{
			FindCombo.AddString( *(GFindHistory(x)) );
		}

		ReplaceCombo.Empty();
		for( x = 0 ; x < GReplaceHistory.Num() ; x++ )
		{
			ReplaceCombo.AddString( *(GReplaceHistory(x)) );
		}
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual void DoModeless()
	{
		_Windows.AddItem( this );
		hWnd = CreateDialogParamA( hInstance, MAKEINTRESOURCEA(IDDIALOG_FINDREPLACE), OwnerWindow?OwnerWindow->hWnd:NULL, (DLGPROC)StaticDlgProc, (LPARAM)this);
		if( !hWnd )
			appGetLastError();
		Show( TRUE );
	}
	void GetUserInput()
	{
		GSearchText = FindCombo.GetText();
		GMatchCase = MatchCaseCheck.IsChecked();
	}
	void OnFind()
	{
		GetUserInput();

		CHARRANGE range;
		SendMessageX( EditHwnd, EM_EXGETSEL, 0, (LPARAM)&range );

		if( FindNext( range.cpMax, -1, (GMatchCase?FR_MATCHCASE:0), &range ) )
		{
			SendMessageX( EditHwnd, EM_EXSETSEL, 0, (LPARAM)&range );
			SendMessageX( EditHwnd, EM_SCROLLCARET, 0, 0 );

			Show(0);
		}
		else
			appMsgf(TEXT("Text not found"));
	}
	void OnFindNext()
	{
		GetUserInput();

		CHARRANGE range;
		SendMessageX( EditHwnd, EM_EXGETSEL, 0, (LPARAM)&range );

		if( FindNext( range.cpMax, -1, (GMatchCase?FR_MATCHCASE:0), &range ) )
		{
			SendMessageX( EditHwnd, EM_EXSETSEL, 0, (LPARAM)&range );
			SendMessageX( EditHwnd, EM_SCROLLCARET, 0, 0 );
		}
		else
			appMsgf(TEXT("End of text"));
	}
	UBOOL FindNext( INT Start, INT End, INT Flags, CHARRANGE* Range )
	{
		GetUserInput();

		CHARRANGE range;
		SendMessageX( EditHwnd, EM_EXGETSEL, 0, (LPARAM)&range );

		return FindText( range.cpMax, -1, (GMatchCase?FR_MATCHCASE:0), Range );
	}
	void OnFindPrev()
	{
		CHARRANGE rangeOrig;
		SendMessageX( EditHwnd, EM_EXGETSEL, 0, (LPARAM)&rangeOrig );

		CHARRANGE range, rangePrev;
		rangePrev.cpMin = rangePrev.cpMax = -1;
		range.cpMax = 0;
		while( FindText( range.cpMax, rangeOrig.cpMin, (GMatchCase?FR_MATCHCASE:0), &range ) )
		{
			rangePrev = range;
		}

		if( rangePrev.cpMin == -1 && rangePrev.cpMax == -1 )
			appMsgf(TEXT("Beginning of text"));
		else
		{
			SendMessageX( EditHwnd, EM_EXSETSEL, 0, (LPARAM)&rangePrev );
			SendMessageX( EditHwnd, EM_SCROLLCARET, 0, 0 );
		}
	}
	UBOOL FindText( INT Start, INT End, INT Flags, CHARRANGE* Range )
	{
		char Text[256] = "";
		::strcpy( Text, appToAnsi( *GSearchText ) );

		FINDTEXTEXA ft;
		ft.chrg.cpMin = Start;
		ft.chrg.cpMax = End;
		ft.lpstrText = Text;
		check(::IsWindow(EditHwnd));
		INT Loc = SendMessageX( EditHwnd, EM_FINDTEXTEX, Flags, (LPARAM)&ft );

		Range->cpMin = Loc;
		Range->cpMax = (Loc == -1) ? 0 : Loc + ::strlen( Text );

		return !(Range->cpMin == -1);
	}
	void OnReplace()
	{
		/*
		FString ReplaceString = ReplaceCombo.GetText();
		GSearchText = FindCombo.GetText();

		if( GSearchText.Len() )
		{
			UpdateHistory( GSearchText, ReplaceString );

			CHARRANGE range;
			SendMessageX( EditHwnd, EM_EXGETSEL, 0, (LPARAM)&range );

			if( range.cpMin != range.cpMax )
			{
				FString OldText = GCodeFrame->Edit.GetText(1);
				FString NewText = OldText.Left(range.cpMin) + ReplaceString + OldText.Right( OldText.Len() - range.cpMax );
				GCodeFrame->Edit.SetText( *NewText );
			}

			OnFindNext();
		}
		*/
	}
	void OnReplaceAll()
	{
	}
	void OnCloseButton()
	{
		Show(0);
	}
	/*
	void OnGoLineNUm()
	{
		GCodeFrame->ScrollToLine( appAtoi( *(LineNumEdit.GetText()) ) );
		Show( FALSE );
	}
	*/
};

extern void ParseStringToArray( const TCHAR* pchDelim, FString String, TArray<FString>* _pArray);
extern WBrowserMaster* GBrowserMaster;

#define ID_CF_TOOLBAR	29001
TBBUTTON tbCFButtons[] = {
	{ 0, IDMN_CLOSE, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 1, IDMN_CF_COMPILE, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 2, IDMN_CF_COMPILE_ALL, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 3, ID_BrowserActor, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 4, IDMN_CF_FIND, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 5, IDMN_CF_FIND_PREV, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 6, IDMN_CF_FIND_NEXT, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
};
struct {
	TCHAR ToolTip[64];
	INT ID;
} ToolTips_CF[] = {
	TEXT("Close Script"), IDMN_CLOSE,
	TEXT("Compile Changed Scripts"), IDMN_CF_COMPILE,
	TEXT("Compile ALL Scripts"), IDMN_CF_COMPILE_ALL,
	TEXT("Actor Class Browser"), ID_BrowserActor,
	TEXT("Find"), IDMN_CF_FIND,
	TEXT("Find Previous"), IDMN_CF_FIND_PREV,
	TEXT("Find Next"), IDMN_CF_FIND_NEXT,
	NULL, 0
};

// A code editing window.
class WCodeFrame : public WWindow
{
	DECLARE_WINDOWCLASS(WCodeFrame,WWindow,DukeEd)

	// Variables.
	UClass* Class;
	WRichEdit Edit;
	WListBox FilesList;
	BOOL bFirstTime;
	RECT rcStatus;
	BOOL m_bStatusError;
	FString m_StatusText;
	HWND hWndToolBar;
	WToolTip* ToolTipCtrl;
	WDlgFindReplace* DlgFindReplace;

	HMENU CodeFrameMenu;

	TArray<UClass*> m_Classes;	// the list of classes we are editing scripts for
	UClass* pCurrentClass;

	// Constructor.
	WCodeFrame( FName InPersistentName, WWindow* InOwnerWindow )
	: WWindow( InPersistentName, InOwnerWindow )
	,	Edit		( this )
	,	FilesList	( this, IDLB_FILES )
	{
		pCurrentClass = NULL;
		bFirstTime = TRUE;
		rcStatus.top = rcStatus.bottom = rcStatus.left = rcStatus.right = 0;
	}

	// WWindow interface.
	void OnSetFocus( HWND hWndLoser )
	{
		WWindow::OnSetFocus( hWndLoser );
		SetFocus( Edit );
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WWindow::OnSize( Flags, NewX, NewY );
		PositionChildControls();
	}
	void PositionChildControls( void )
	{
		if( !::IsWindow( GetDlgItem( hWnd, ID_CF_TOOLBAR )))	return;

		FRect CR = GetClientRect();
		RECT R;
		::GetWindowRect( GetDlgItem( hWnd, ID_CF_TOOLBAR ), &R );
		::MoveWindow( GetDlgItem( hWnd, ID_CF_TOOLBAR ), 0, 0, CR.Max.X, R.bottom, TRUE );

		FilesList.MoveWindow( FRect(0,(R.bottom - R.top) - 1,128,CR.Max.Y), TRUE );

		Edit.MoveWindow( FRect(128,(R.bottom - R.top) - 1,CR.Max.X,CR.Max.Y - 20), TRUE );
		//warren Edit.ScrollCaret();

		rcStatus.left = 128;
		rcStatus.right = CR.Max.X;
		rcStatus.top = CR.Max.Y - 20;
		rcStatus.bottom = CR.Max.Y;

		::InvalidateRect( hWnd, NULL, TRUE );
	}
	void UpdateStatus( BOOL bError, FString Text )
	{
		m_bStatusError = bError;
		m_StatusText = Text;
		::InvalidateRect( hWnd, NULL, TRUE );
	}
	void OnPaint()
	{
		PAINTSTRUCT PS;
		HDC hDC = BeginPaint( *this, &PS );

		//
		// STATUS BAR
		//

		HPEN l_penError, l_penOK, l_penOld;
		HBRUSH l_brushError, l_brushOK, l_brushOld;

		::SetBkMode( hDC, TRANSPARENT );

		l_penError = ::CreatePen( PS_SOLID, 1, RGB(255, 0, 0) );
		l_penOK = ::CreatePen( PS_SOLID, 1, ::GetSysColor( COLOR_3DFACE ) );
		l_brushError = ::CreateSolidBrush( RGB(255, 0, 0) );
		l_brushOK = ::CreateSolidBrush( ::GetSysColor( COLOR_3DFACE ) );

		if( m_bStatusError )
		{
			l_penOld = (HPEN)::SelectObject( hDC, l_penError );
			l_brushOld = (HBRUSH)::SelectObject( hDC, l_brushError );
			::SetTextColor( hDC, RGB(255, 255, 255) );
		}
		else
		{
			l_penOld = (HPEN)::SelectObject( hDC, l_penOK );
			l_brushOld = (HBRUSH)::SelectObject( hDC, l_brushOK );
			::SetTextColor( hDC, ::GetSysColor( COLOR_BTNTEXT ) );
		}

		// Draw the background
		::Rectangle( hDC, rcStatus.left, rcStatus.top, rcStatus.right, rcStatus.bottom );

		// Draw the message
		::DrawTextA( hDC, TCHAR_TO_ANSI( *m_StatusText ), ::strlen( TCHAR_TO_ANSI( *m_StatusText ) ), &rcStatus, DT_LEFT | DT_VCENTER | DT_SINGLELINE );

		// Clean up
		::SetBkMode( hDC, OPAQUE );

		::SelectObject( hDC, l_penOld );
		::SelectObject( hDC, l_brushOld );

		EndPaint( *this, &PS );

		::DeleteObject( l_penError );
		::DeleteObject( l_penOK );
		::DeleteObject( l_brushError );
		::DeleteObject( l_brushOK );
	}
	// Checks for script compile errors.
	//
	void ProcessResults(void)
	{
		FStringOutputDevice GetPropResult = FStringOutputDevice();
		GEditor->Get( TEXT("TEXT"), TEXT("RESULTS"), GetPropResult );

		FString S, T, Msg;
		long i, Line;
		BOOL l_bError = FALSE;

		S = GetPropResult;

		if( !appStrcmp( *(S.Left(9)), TEXT("Error in ") )
				&& S.InStr(TEXT(":")) > -1 )
		{
			l_bError = TRUE;

			S = S.Mid(9);
			i = S.InStr(TEXT(", Line "));
			if(i != -1)
			{
				Line = appAtoi(*(S.Mid(i + 7)));	// Line number
				S = S.Left(i);						// Class name
				HighlightError( S, Line );
			}
		}

		S = GetPropResult;
		// Sometimes there's crap on the end of the message .. strip it off.
	    if( S.InStr(TEXT("\x0d")) != -1 )
			S = S.Left( S.InStr(TEXT("\x0d")) );
        UpdateStatus( l_bError, *S);
	}
	// Highlights a compilation error by opening up that classes script and moving to the appropriate line.
	//
	void HighlightError( FString Name, INT Line )
	{
		UClass* Class;
		if( ParseObject<UClass>( *(FString::Printf(TEXT("CLASS=%s"), *Name)), TEXT("CLASS="), Class, ANY_PACKAGE ) )
		{
			// Figure out where in the script the error line is, in chars.
			//
			char ch10 = '\x0a', *pch = TCHAR_TO_ANSI( *(Class->ScriptText->Text) );
			INT iChar = 0, iLine = 1;

			while( *pch && iLine < Line )
			{
				if( *pch == ch10 )
					iLine++;

				iChar++;
				pch++;
			}

			AddClass( Class, iChar, Line - 1 );
		}
	}
	void OnCommand( INT Command )
	{
		switch( Command ) {

			case IDMN_CF_FIND:
				DlgFindReplace->Show(1);
				break;

			case IDMN_CF_FIND_NEXT:
				if( GSearchText.Len() )
					DlgFindReplace->OnFindNext();
				else
					DlgFindReplace->Show(1);
				break;

			case IDMN_CF_FIND_PREV:
				if( GSearchText.Len() )
					DlgFindReplace->OnFindPrev();
				else
					DlgFindReplace->Show(1);
				break;

			case IDMN_CF_EXPORT_CHANGED:
				{
					if( ::MessageBox( hWnd, TEXT("This option will export all modified classes to text .uc files which can later be rebuilt. Do you want to do this?"), TEXT("Export classes to *.uc files"), MB_YESNO) == IDYES)
						GEditor->Exec( TEXT("CLASS SPEW") );
				}
				break;

			case IDMN_CF_EXPORT_ALL:
				{
					if( ::MessageBox( hWnd, TEXT("This option will export all classes to text .uc files which can later be rebuilt. Do you want to do this?"), TEXT("Export classes to *.uc files"), MB_YESNO) == IDYES)
						GEditor->Exec( TEXT("CLASS SPEW ALL") );
				}
				break;

			case IDMN_CF_COMPILE:
				{
					GWarn->BeginSlowTask( TEXT("Compiling changed scripts"), 1, 0 );
					Save();
					GEditor->Exec( TEXT("SCRIPT MAKE") );
					GWarn->EndSlowTask();

					ProcessResults();
				}
				break;

			case IDMN_CF_COMPILE_ALL:
				{
					GWarn->BeginSlowTask( TEXT("Compiling all scripts"), 1, 0 );
					Save();
					GEditor->Exec( TEXT("SCRIPT MAKE ALL") );
					GWarn->EndSlowTask();

					ProcessResults();
				}
				break;

			case IDMN_CLOSE:
				{
					Save();

					// Find the currently selected class and remove it from the list.
					//
					FString Name = FilesList.GetString( FilesList.GetCurrent() );
					RemoveClass( Name );
				}
				break;

			case ID_BrowserActor:
			{
				GBrowserMaster->ShowBrowser( eBROWSER_ACTOR );
			}
			break;

			default:
				WWindow::OnCommand(Command);
				break;
		}
	}
	void OnCreate()
	{
		WWindow::OnCreate();

		CodeFrameMenu = LoadMenuIdX(hInstance, IDMENU_CodeFrame);
		SetMenu( hWnd, CodeFrameMenu );

		// Load windows last position.
		//
		INT X, Y, W, H;

		if(!GConfig->GetInt( *PersistentName, TEXT("X"), X, TEXT("DukeEd.ini") ))	X = 0;
		if(!GConfig->GetInt( *PersistentName, TEXT("Y"), Y, TEXT("DukeEd.ini") ))	Y = 0;
		if(!GConfig->GetInt( *PersistentName, TEXT("W"), W, TEXT("DukeEd.ini") ))	W = 512;
		if(!GConfig->GetInt( *PersistentName, TEXT("H"), H, TEXT("DukeEd.ini") ))	H = 384;

		if( !W ) W = 320;
		if( !H ) H = 200;

		::MoveWindow( hWnd, X, Y, W, H, TRUE );

		// Set up the main edit control.
		//
		Edit.OpenWindow(1,0);
		UINT Tabs[16];
		for( INT i=0; i<16; i++ )
			Tabs[i]=4*(i+1);
			//Tabs[i]=5*4*(i+1);
		SendMessageX( Edit.hWnd, EM_SETTABSTOPS, 16, (LPARAM)Tabs );
		Edit.SetFont( (HFONT)GetStockObject(ANSI_FIXED_FONT) );
		SendMessageX( Edit.hWnd, EM_EXLIMITTEXT, 0, 262144 );
		Edit.SetText(TEXT(""));
		SendMessageX( Edit.hWnd, EM_SETTEXTMODE, 0, TM_RICHTEXT | TM_MULTILEVELUNDO );
		SendMessageX( Edit.hWnd, EM_SETBKGNDCOLOR, 0, (LPARAM)(COLORREF)RGB(0,0,64) );

		Edit.SetReadOnly( TRUE );

		hWndToolBar = CreateToolbarEx( 
			hWnd, WS_CHILD | WS_BORDER | WS_VISIBLE | CCS_ADJUSTABLE,
			ID_CF_TOOLBAR,
			8,
			hInstance,
			IDB_CodeFrame_TOOLBAR,
			(LPCTBBUTTON)&tbCFButtons,
			10,
			16,16,
			16,16,
			sizeof(TBBUTTON));

		if( !hWndToolBar )
			appMsgf( TEXT("Toolbar not created!") );


		ToolTipCtrl = new WToolTip(this);
		ToolTipCtrl->OpenWindow();

		for( INT tooltip = 0 ; ToolTips_CF[tooltip].ID > 0 ; tooltip++ )
		{
			// Figure out the rectangle for the toolbar button.
			INT index = SendMessageX( hWndToolBar, TB_COMMANDTOINDEX, ToolTips_CF[tooltip].ID, 0 );
			RECT rect;
			SendMessageX( hWndToolBar, TB_GETITEMRECT, index, (LPARAM)&rect);

			ToolTipCtrl->AddTool( hWndToolBar, ToolTips_CF[tooltip].ToolTip, tooltip, &rect );
		}

		FilesList.OpenWindow( 1, 0, 0, 0, 1 );
		FilesList.DoubleClickDelegate = FDelegate(this, (TDelegate)OnFilesListDblClick);

		UpdateStatus( FALSE, TEXT("Ready."));
//		DlgFindReplace = new WDlgFindReplace( NULL, this );
//		DlgFindReplace->EditHwnd = Edit.hWnd;
//		DlgFindReplace->DoModeless();
//		DlgFindReplace->Show(0);		
	}
	TCHAR* MY_ANSI_TO_TCHAR(char* str)
	{
		INT iLength = winGetSizeUNICODE(str);
		TCHAR* pBuffer = new TCHAR[iLength];
		appStrcpy(pBuffer,TEXT(""));
		TCHAR* ret = winToUNICODE(pBuffer,str,iLength);
		return ret;
	}
	void Save(void)
	{
		if( !pCurrentClass )	return;
		if( !m_Classes.Num() )	return;

		INT iLength = SendMessageA( Edit.hWnd, WM_GETTEXTLENGTH, 0, 0 );
		char* pchBuffer = new char[iLength];
		::strcpy(pchBuffer, "");
		const TCHAR* ptchBuffer;
		Edit.StreamTextOut( pchBuffer, iLength );

		ptchBuffer = MY_ANSI_TO_TCHAR(pchBuffer);

		pCurrentClass->ScriptText->Text = ptchBuffer;
		SendMessageX( Edit.hWnd, EM_GETSEL, (WPARAM)&(pCurrentClass->ScriptText->Pos), 0 );
		pCurrentClass->ScriptText->Top = SendMessageX( Edit.hWnd, EM_GETFIRSTVISIBLELINE, 0, 0 );

		delete [] pchBuffer;
	}
	void OnDestroy()
	{
		Save();

		// Save Window position (base class doesn't always do this properly)
		// (Don't do this if the window is minimized.)
		//
		if( !::IsIconic( hWnd ) && !::IsZoomed( hWnd ) )
		{
			RECT R;
			::GetWindowRect(hWnd, &R);

			GConfig->SetInt( *PersistentName, TEXT("Active"), m_bShow, TEXT("DukeEd.ini") );
			GConfig->SetInt( *PersistentName, TEXT("X"), R.left, TEXT("DukeEd.ini") );
			GConfig->SetInt( *PersistentName, TEXT("Y"), R.top, TEXT("DukeEd.ini") );
			GConfig->SetInt( *PersistentName, TEXT("W"), R.right - R.left, TEXT("DukeEd.ini") );
			GConfig->SetInt( *PersistentName, TEXT("H"), R.bottom - R.top, TEXT("DukeEd.ini") );
		}

		::DestroyWindow( hWndToolBar );
		delete ToolTipCtrl;

//		delete DlgFindReplace;

		DestroyMenu( CodeFrameMenu );

		WWindow::OnDestroy();
	}
	void OpenWindow( UBOOL bMdi=0, UBOOL AppWindow=0 )
	{
		MdiChild = bMdi;
		PerformCreateWindowEx
		(
			WS_EX_WINDOWEDGE,
			TEXT("Script Editor"),
			WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_SIZEBOX | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
			CW_USEDEFAULT,
			CW_USEDEFAULT,
			384,
			512,
			OwnerWindow->hWnd,
			NULL,
			hInstance
		);
	}
	void AddClass( UClass* pClass, INT Pos = -1, INT Top = -1 )
	{
		if( !pClass ) return;
		
		// Make sure this class has a script.
		//
		FStringOutputDevice GetPropResult = FStringOutputDevice();
	    GEditor->Get(TEXT("SCRIPTPOS"), pClass->GetName(), GetPropResult);
		if( !GetPropResult.Len() )
		{
			appMsgf( *(FString::Printf(TEXT("'%s' has no script to edit."), pClass->GetName())) );
			return;
		}

		// Only add this class to the list if it's not already there.
		//
		if( FilesList.FindString( pClass->GetName() ) == -1 )
			m_Classes.AddItem( pClass );

		RefreshScripts();
		SetClass( pClass->GetName(), Pos, Top );

		Show(1);
		::BringWindowToTop( hWnd );
	}
	void RemoveClass( FString Name )
	{
		// Remove the class from the internal list.
		//
		for( INT x = 0 ; x < m_Classes.Num() ; x++ )
		{
			if( !appStrcmp( m_Classes(x)->GetName(), *Name ) )
			{
				m_Classes.Remove(x);
				break;
			}
		}

		RefreshScripts();
		FilesList.SetCurrent( 0, 1 );
		OnFilesListDblClick();

		if( !m_Classes.Num() )
			pCurrentClass = NULL;
		SetCaption();
	}
	void RefreshScripts(void)
	{
		// LOADED SCRIPTS
		//
		FilesList.Empty();
		for( INT x = 0 ; x < m_Classes.Num() ; x++ )
			FilesList.AddString( m_Classes(x)->GetName() );
	}
	// Saves the current script and selects a new script.
	//
	void SetClass( FString Name, INT Pos = -1, INT Top = -1 )
	{
		// If there are no classes loaded, just empty the edit control.
		//
		if( !m_Classes.Num() )
		{
			Edit.SetReadOnly( TRUE );
			Edit.SetText(TEXT("No scripts loaded."));
			pCurrentClass = NULL;
			return;
		}

		// Save the settings/script for the current class before changing.
		//
		if( pCurrentClass && !bFirstTime )
		{
//			Save();
		}

		bFirstTime = FALSE;

		FilesList.SetCurrent( FilesList.FindString( *Name ), 1 );

		Edit.SetReadOnly( FALSE );

		// Locate the proper class pointer.
		//
		for( INT x = 0 ; x < m_Classes.Num() ; x++ )
			if( !appStrcmp( m_Classes(x)->GetName(), *Name ) )
			{
				pCurrentClass = m_Classes(x);
				break;
			}

		// Override whatever is in the class if we need to.
		//
		if( Pos > -1 )		pCurrentClass->ScriptText->Pos = Pos;
		if( Top > -1 )		pCurrentClass->ScriptText->Top = Top;

		// Load current script into edit window.
		//
		SetCaption();

		// old code
		//Edit.SetText( *(pCurrentClass->ScriptText->Text) );

		// Get the script text in RTF format
		FStringOutputDevice GetPropResult = FStringOutputDevice();
		GEditor->Get( TEXT("RTF"), pCurrentClass->GetName(), GetPropResult );

		// Convert it to ANSI
		TCHAR* tchScriptText = new TCHAR[GetPropResult.Len()];
		appStrcpy( tchScriptText, TEXT("") ); 

		appStrcpy( tchScriptText, *GetPropResult ); 
		const char* chScriptText = TCHAR_TO_ANSI(tchScriptText);
		
		// Stream it into the RichEdit control
		LockWindowUpdate(Edit.hWnd);
		Edit.StreamTextIn( (char*)chScriptText, strlen(chScriptText) );
		LockWindowUpdate(NULL);

		delete [] tchScriptText;

		SendMessageX( Edit.hWnd, EM_SETSEL, pCurrentClass->ScriptText->Pos, pCurrentClass->ScriptText->Pos );
		SendMessageX( Edit.hWnd, EM_SCROLLCARET, 0, 0 );

		ScrollToLine( pCurrentClass->ScriptText->Top );

		::SetFocus( Edit.hWnd );
	}
	void SetCaption()
	{
		if( pCurrentClass )
			SetText( pCurrentClass->GetFullName() );
		else
			SetText( TEXT("") );
	}
	void ScrollToLine( INT Line )
	{
		// Stop the window from updating while scrolling to the requested line.  This makes
		// it go MUCH faster -- and it looks better.
		//
		LockWindowUpdate( hWnd );

		INT CurTop = SendMessageX(Edit.hWnd, EM_GETFIRSTVISIBLELINE, 0, 0);
		while( CurTop > Line )
		{
			SendMessageX(Edit.hWnd, EM_SCROLL, SB_LINEUP, 0);
			CurTop--;
		}
		while( CurTop < Line )
		{
			SendMessageX(Edit.hWnd, EM_SCROLL, SB_LINEDOWN, 0);
			CurTop++;
		}

		LockWindowUpdate( NULL );
	}
	INT OnSysCommand( INT Command )
	{
		// Don't actually close the window when the user hits the "X" button.  Just hide it.
		if( Command == SC_CLOSE )
		{
			Show(0);
			return 1;
		}

		return 0;
	}
	// Notification delegates for child controls.
	//
	void OnFilesListDblClick()
	{
		FString Name = FilesList.GetString( FilesList.GetCurrent() );
		SetClass( Name );
		SetCaption();
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
