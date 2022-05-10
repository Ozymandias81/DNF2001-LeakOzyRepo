/*=============================================================================
	BrowserMaster : Master window where all "docked" browser reside
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

// --------------------------------------------------------------
//
// WBrowserMaster
//
// --------------------------------------------------------------

class WBrowserMaster : public WBrowser
{
	DECLARE_WINDOWCLASS(WBrowserMaster,WBrowser,Window)

	WToolTip* ToolTipCtrl;
	WBrowser** Browsers[eBROWSER_MAX];
	WTabControl* BrowserTabs;
	INT CurrentBrowser;

	// Structors.
	WBrowserMaster( FName InPersistentName, WWindow* InOwnerWindow )
	:	WBrowser( InPersistentName, InOwnerWindow, NULL )
	{
		for( INT x = 0 ; x < eBROWSER_MAX ; x++ )
			Browsers[x] = NULL;
		CurrentBrowser = -1;
		BrowserTabs = NULL;
		Description = TEXT("Browsers");
	}

	// WBrowser interface.
	void OpenWindow( UBOOL bChild )
	{
		WBrowser::OpenWindow( bChild );
		Show(1);
		SetCaption();
	}
	void ShowBrowser( INT InBrowser )
	{
//		if(InBrowser==eBROWSER_MESH)
//			DebugBreak();

		check(Browsers[InBrowser]);
		check(*Browsers[InBrowser]);	// Where the mesh browsers fails

		CurrentBrowser = InBrowser;

		(*Browsers[InBrowser])->Show(1);
		::BringWindowToTop( (*Browsers[InBrowser])->hWnd );

		if( (*Browsers[InBrowser])->IsDocked() )
		{
			UpdateBrowserPositions();
			RefreshBrowserTabs( InBrowser );
			(*Browsers[InBrowser])->SetCaption();
			Show(1);
		}
	}

	// NJS These two are not quite working yet: - well, they can successfully close a browser, but reopening some will cause a crash
	void HideBrowser(INT InBrowser)
	{
		check(Browsers[InBrowser]);
		check(*Browsers[InBrowser]);

		//ShowWindow((*Browsers[InBrowser])->hWnd,SW_MINIMIZE);
		ShowWindow((*Browsers[InBrowser])->hWnd,SW_HIDE);
		CurrentBrowser=-1;
		//DestroyWindow((*Browsers[InBrowser])->hWnd);

		//CloseWindow((*Browsers[InBrowser])->hWnd);
		//(*Browsers[InBrowser])->Show(0);
	}
	void HideAllBrowsers()
	{
		for( INT x = 0 ; x < eBROWSER_MAX ; x++ )
			if(Browsers[x])
				if(*Browsers[x])
					if((*Browsers[x])->hWnd)
						HideBrowser(x);

		CurrentBrowser=-1;

	}

	void UpdateBrowserPositions()
	{
		RECT rect;
		::GetClientRect( hWnd, &rect );

		for( INT x = 0 ; x < eBROWSER_MAX ; x++ )
		{
			// If the browser is docked, we need to fit it inside of our client area.
			if( Browsers[x] && *Browsers[x] && (*Browsers[x])->IsDocked() )
				::MoveWindow( (*Browsers[x])->hWnd, 4, 32, rect.right - 8 , rect.bottom - 36, 1);
		}
	}
	void OnCreate()
	{
		WBrowser::OnCreate();

		ToolTipCtrl = new WToolTip(this);
		ToolTipCtrl->OpenWindow();

		BrowserTabs = new WTabControl( this, IDCB_BROWSER );
		BrowserTabs->OpenWindow( 1 );
		BrowserTabs->SelectionChangeDelegate = FDelegate(this, (TDelegate)OnBrowserTabSelChange);

		PositionChildControls();
	}
	void OnDestroy()
	{
		WBrowser::OnDestroy();
		delete ToolTipCtrl;
		delete BrowserTabs;
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WBrowser::OnSize(Flags, NewX, NewY);
		PositionChildControls();
		UpdateBrowserPositions();
		InvalidateRect( hWnd, NULL, 1 );
	}
	void PositionChildControls( void )
	{
		if( !BrowserTabs ) return;

		RECT rect;
		::GetClientRect( *this, &rect );
		::MoveWindow( BrowserTabs->hWnd, 0, 0, rect.right, rect.bottom, 1 );

		::InvalidateRect( hWnd, NULL, 1);
	}
	// Check to see how many browsers are docked and create buttons for them.
	void RefreshBrowserTabs( INT InBrowser )
	{
		BrowserTabs->Empty();

		for( INT x = 0 ; x < eBROWSER_MAX ; x++ )
			if( Browsers[x] && *Browsers[x] && (*Browsers[x])->IsDocked() )
				BrowserTabs->AddTab( *(*Browsers[x])->Description, (*Browsers[x])->BrowserID );

		if( !BrowserTabs->GetCount() )
		{
			HMENU CurrentMenu = GetMenu( hWnd );
			if ( CurrentMenu )
				DestroyMenu( CurrentMenu );
			SetMenu( hWnd, NULL );
		}
		else
		{
			if( InBrowser != -1 )
			{
				if( Browsers[InBrowser] && *Browsers[InBrowser] && (*Browsers[InBrowser])->IsDocked() )
					BrowserTabs->SetCurrent( BrowserTabs->GetIndexFromlParam( (*Browsers[InBrowser])->BrowserID ) );

				HMENU CurrentMenu = GetMenu( hWnd );
				DestroyMenu( CurrentMenu );
				SetMenu( hWnd, LoadMenuIdX(hInstance, (*Browsers[InBrowser])->MenuID) );
				(*Browsers[InBrowser])->UpdateMenu();
			}
			else
			{
				BrowserTabs->SetCurrent(0);
				InBrowser = FindBrowserIdxFromName( BrowserTabs->GetString(0) );
				ShowBrowser( InBrowser );
				return;
			}
		}
	}
	virtual void RefreshAll()
	{
		for( INT x = 0 ; x < eBROWSER_MAX ; x++ )
			if( Browsers[x] && *Browsers[x] )
				(*Browsers[x])->RefreshAll();
	}
	INT FindBrowserIdxFromName( FString InDesc )
	{
		for( INT x = 0 ; x < eBROWSER_MAX ; x++ )
			if( Browsers[x] && *Browsers[x] && (*Browsers[x])->Description == InDesc )
				return x;

		return 0;
	}
	virtual void OnKeyDown( TCHAR Ch )
	{
		if( GetKeyState(VK_ESCAPE) & 0x8000)
			Show(0);
	}
	void OnCommand( INT Command )
	{
		// If we don't want to deal with this message, pass it to the currently active browser.
		if( CurrentBrowser > -1 && Browsers[CurrentBrowser] && (*Browsers[CurrentBrowser])->IsDocked() )
			SendMessageX( (*Browsers[CurrentBrowser])->hWnd, WM_COMMAND, Command, 0);
		else
			WBrowser::OnCommand(Command);
	}
	INT GetCurrent()
	{
		return CurrentBrowser;
	}
	void OnBrowserTabSelChange()
	{
		ShowBrowser( BrowserTabs->GetlParam( BrowserTabs->GetCurrent() ) );
	}

};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
