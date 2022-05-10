/*=============================================================================
	BrowserGroup : Browser window for actor groups
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

extern void ParseStringToArray( const TCHAR* pchDelim, FString String, TArray<FString>* _pArray);
extern HWND GhwndEditorFrame;

// --------------------------------------------------------------
//
// NEW/RENAME GROUP Dialog
//
// --------------------------------------------------------------

class WDlgGroup : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgGroup,WDialog,DukeEd)

	// Variables.
	WButton OkButton;
	WButton CancelButton;
	WEdit NameEdit;

	FString defName, Name;
	UBOOL bNew;

	// Constructor.
	WDlgGroup( UObject* InContext, WBrowser* InOwnerWindow )
	:	WDialog			( TEXT("Group"), IDDIALOG_GROUP, InOwnerWindow )
	,	OkButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOk) )
	,	CancelButton	( this, IDCANCEL,		FDelegate(this,(TDelegate)EndDialogFalse) )
	,	NameEdit		( this, IDEC_NAME )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		NameEdit.SetText( *defName );
		::SetFocus( NameEdit.hWnd );

		if( bNew )
			SetText(TEXT("New Group"));
		else
			SetText(TEXT("Rename Group"));

		NameEdit.SetSelection(0, -1);
	}
	virtual INT DoModal( UBOOL InbNew, FString _defName )
	{
		bNew = InbNew;
		defName = _defName;

		return WDialog::DoModal( hInstance );
	}
	void OnOk()
	{
		Name = NameEdit.GetText();
		EndDialog(TRUE);
	}
};

// --------------------------------------------------------------
//
// WBrowserGroup
//
// --------------------------------------------------------------

#define ID_BG_TOOLBAR	29050
TBBUTTON tbBGButtons[] = {
	{ 0, IDMN_MB_DOCK, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 1, IDMN_GB_NEW_GROUP, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 2, IDMN_GB_DELETE_GROUP, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 3, IDMN_GB_ADD_TO_GROUP, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 4, IDMN_GB_DELETE_FROM_GROUP, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 5, IDMN_GB_REFRESH, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 6, IDMN_GB_SELECT, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 7, IDMN_GB_DESELECT, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 7, IDMN_GB_INVERT_SELECT, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
};
struct {
	TCHAR ToolTip[64];
	INT ID;
} ToolTips_BG[] = {
	TEXT("Toggle Dock Status"), IDMN_MB_DOCK,
	TEXT("New Group"), IDMN_GB_NEW_GROUP,
	TEXT("Delete"), IDMN_GB_DELETE_GROUP,
	TEXT("Add Selected Actors to Group(s)"), IDMN_GB_ADD_TO_GROUP,
	TEXT("Delete Select Actors from Group(s)"), IDMN_GB_DELETE_FROM_GROUP,
	TEXT("Refresh Group List"), IDMN_GB_REFRESH,
	TEXT("Select Actors in Group(s)"), IDMN_GB_SELECT,
	TEXT("Deselect Actors in Group(s)"), IDMN_GB_DESELECT,
	TEXT("Invert group selection"), IDMN_GB_INVERT_SELECT,
	NULL, 0
};

class WBrowserGroup : public WBrowser
{
	DECLARE_WINDOWCLASS(WBrowserGroup,WBrowser,Window)

	WCheckListBox *pListGroups;
	HWND hWndToolBar;
	WToolTip *ToolTipCtrl;

	HMENU BrowserGroupMenu;

	// Structors.
	WBrowserGroup( FName InPersistentName, WWindow* InOwnerWindow, HWND InEditorFrame )
	:	WBrowser( InPersistentName, InOwnerWindow, InEditorFrame )
	{
		pListGroups = NULL;
		MenuID = IDMENU_BrowserGroup;
		BrowserID = eBROWSER_GROUP;
		Description = TEXT("Groups");
	}

	// WBrowser interface.
	void OpenWindow( UBOOL bChild )
	{
		WBrowser::OpenWindow( bChild );
		SetCaption();
	}
	virtual void UpdateMenu()
	{
		HMENU menu = IsDocked() ? GetMenu( OwnerWindow->hWnd ) : GetMenu( hWnd );
		if (menu)
			CheckMenuItem( menu, IDMN_MB_DOCK, MF_BYCOMMAND | (IsDocked() ? MF_CHECKED : MF_UNCHECKED) );
	}
	void OnCreate()
	{
		WBrowser::OnCreate();

		BrowserGroupMenu = LoadMenuIdX(hInstance, IDMENU_BrowserGroup);
		SetMenu( hWnd, BrowserGroupMenu );
		
		// GROUP LIST
		//
		pListGroups = new WCheckListBox( this, IDLB_GROUPS );
		pListGroups->OpenWindow( 1, 0, 1, 1 );

		hWndToolBar = CreateToolbarEx( 
			hWnd, WS_CHILD | WS_BORDER | WS_VISIBLE | CCS_ADJUSTABLE,
			IDB_BrowserGroup_TOOLBAR,
			8,
			hInstance,
			IDB_BrowserGroup_TOOLBAR,
			(LPCTBBUTTON)&tbBGButtons,
			12,
			16,16,
			16,16,
			sizeof(TBBUTTON));
		check(hWndToolBar);

		ToolTipCtrl = new WToolTip(this);
		ToolTipCtrl->OpenWindow();
		for( INT tooltip = 0 ; ToolTips_BG[tooltip].ID > 0 ; tooltip++ )
		{
			// Figure out the rectangle for the toolbar button.
			INT index = SendMessageX( hWndToolBar, TB_COMMANDTOINDEX, ToolTips_BG[tooltip].ID, 0 );
			RECT rect;
			SendMessageX( hWndToolBar, TB_GETITEMRECT, index, (LPARAM)&rect);

			ToolTipCtrl->AddTool( hWndToolBar, ToolTips_BG[tooltip].ToolTip, tooltip, &rect );
		}

		RefreshGroupList();
		PositionChildControls();
	}
	virtual void RefreshAll()
	{
		RefreshGroupList();
	}
	void OnDestroy()
	{
		SafeDelete(pListGroups);

		::DestroyWindow( hWndToolBar );
		SafeDelete(ToolTipCtrl);
		DestroyMenu( BrowserGroupMenu );

		WBrowser::OnDestroy();
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WBrowser::OnSize(Flags, NewX, NewY);
		PositionChildControls();
		InvalidateRect( hWnd, NULL, FALSE );
		UpdateMenu();
	}
	// Updates the check status of all the groups, based on the contents of the VisibleGroups
	// variable in the LevelInfo.
	void GetFromVisibleGroups()
	{
		// First set all groups to "off"
		for( INT x = 0 ; x < pListGroups->GetCount() ; x++ )
			pListGroups->SetItemData( x, 0 );

		// Now turn "on" the ones we need to.
		TArray<FString> Array;
		ParseStringToArray( TEXT(","), GEditor->Level->GetLevelInfo()->VisibleGroups, &Array );

		for( x = 0 ; x < Array.Num() ; x++ )
		{
			INT Index = pListGroups->FindStringExact( *Array(x) );
			if( Index != LB_ERR )
				pListGroups->SetItemData( Index, 1 );
		}

		UpdateVisibility();
	}
	// Updates the VisibleGroups variable in the LevelInfp
	void SendToVisibleGroups()
	{
		FString NewVisibleGroups;

		for( INT x = 0 ; x < pListGroups->GetCount() ; x++ )
		{
			if( (int)pListGroups->GetItemData( x ) )
			{
				if( NewVisibleGroups.Len() )
					NewVisibleGroups += TEXT(",");
				NewVisibleGroups += pListGroups->GetString(x);
			}
		}

		GEditor->Level->GetLevelInfo()->VisibleGroups = NewVisibleGroups;

		GEditor->NoteSelectionChange( GEditor->Level );
	}
	void RefreshGroupList()
	{
		// Loop through all the actors in the world and put together a list of unique group names.
		// Actors can belong to multiple groups by seperating the group names with semi-colons ("group1;group2")
		TArray<FString> Groups;

		for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
		{
			AActor* pActor = GEditor->Level->Actors(i);
			if(	pActor 
				&& !Cast<ACamera>(pActor )
				&& pActor!=GEditor->Level->Brush()
				&& pActor->GetClass()->GetDefaultActor()->bHiddenEd==0 )
			{
				TArray<FString> Array;
				ParseStringToArray( TEXT(","), *pActor->Group, &Array );

				for( INT x = 0 ; x < Array.Num() ; x++ )
				{
					// Only add the group name if it doesn't already exist.
					UBOOL bExists = FALSE;
					for( INT z = 0 ; z < Groups.Num() ; z++ )
						if( Groups(z) == Array(x) )
						{
							bExists = 1;
							break;
						}

					if( !bExists )
						new(Groups)FString( Array(x) );
				}
			}
		}

		// Add the list of unique group names to the group listbox
		pListGroups->Empty();

		for( INT x = 0 ; x < Groups.Num() ; x++ )
		{
			pListGroups->AddString( *Groups(x) );
			pListGroups->SetItemData( pListGroups->FindStringExact( *Groups(x) ), 1 );
		}

		GetFromVisibleGroups();

		pListGroups->SetCurrent( 0, 1 );
	}
	// Moves the child windows around so that they best match the window size.
	//
	void PositionChildControls( void )
	{
		if( !pListGroups ) return;

		FRect CR;
		CR = GetClientRect();
		RECT R;
		::GetClientRect( hWndToolBar, &R );

		::MoveWindow( pListGroups->hWnd, 4, R.bottom + 4, CR.Width() - 8, CR.Height() - 4 - R.bottom, 1 );
	}
	// Loops through all actors in the world and updates their visibility based on which groups are selected.
	void UpdateVisibility()
	{
		// For each actor ...
		//
		// - break out its group field into seperate group names
		// - compare that list against the listbox - if any of those groups names are
		//   turned off, the actor is hidden.
		//
		FString NewVisibleGroups;

		for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
		{
			AActor* pActor = GEditor->Level->Actors(i);

			if(	pActor 
				&& !Cast<ACamera>(pActor )
				&& pActor!=GEditor->Level->Brush()
				&& pActor->GetClass()->GetDefaultActor()->bHiddenEd==0 )
			{
				pActor->Modify();
				pActor->bHiddenEd = 0;

				TArray<FString> Array;
				ParseStringToArray( TEXT(","), *pActor->Group, &Array );

				for( INT x = 0 ; x < Array.Num() ; x++ )
				{
					INT Index = pListGroups->FindStringExact( *Array(x) );
					if( Index != LB_ERR && !(int)pListGroups->GetItemData( Index ) )
					{
						pActor->bHiddenEd = 1;
						break;
					}
				}
			}
		}

		PostMessageX( GhwndEditorFrame, WM_COMMAND, WM_REDRAWALLVIEWPORTS, 0 );
	}
	void OnCommand( INT Command )
	{
		switch( Command ) {

			case IDMN_GB_NEW_GROUP:
				NewGroup();
				break;

			case IDMN_GB_DELETE_GROUP:
				DeleteGroup();
				break;

			case IDMN_GB_ADD_TO_GROUP:
				{
					INT SelCount = pListGroups->GetSelectedCount();
					if( SelCount == LB_ERR )	return;
					int* Buffer = new int[SelCount];
					pListGroups->GetSelectedItems(SelCount, Buffer);
					for( INT s = 0 ; s < SelCount ; s++ )
						AddToGroup(pListGroups->GetString(Buffer[s]));
					delete [] Buffer;
				}
				break;

			case IDMN_GB_DELETE_FROM_GROUP:
				DeleteFromGroup();
				break;

			case IDMN_GB_RENAME_GROUP:
				RenameGroup();
				break;

			case IDMN_GB_REFRESH:
				OnRefreshGroups();
				break;

			case IDMN_GB_SELECT:
				SelectActorsInGroups(1);
				break;

			case IDMN_GB_DESELECT:
				SelectActorsInGroups(0);
				break;

			case IDMN_GB_INVERT_SELECT:
				pListGroups->InvertSelection();
				break;

			case WM_WCLB_UPDATE_VISIBILITY:
				UpdateVisibility();
				SendToVisibleGroups();
				break;

			default:
				WBrowser::OnCommand(Command);
				break;
		}
	}
	void SelectActorsInGroups( UBOOL Select )
	{
		INT SelCount = pListGroups->GetSelectedCount();
		if( SelCount == LB_ERR )	return;
		int* Buffer = new int[SelCount];
		pListGroups->GetSelectedItems(SelCount, Buffer);

		for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
		{
			AActor* pActor = GEditor->Level->Actors(i);
			if(	pActor 
				&& !Cast<ACamera>(pActor )
				&& pActor!=GEditor->Level->Brush()
				&& pActor->GetClass()->GetDefaultActor()->bHiddenEd==0 )
			{
				FString GroupName = *pActor->Group;
				TArray<FString> Array;
				ParseStringToArray( TEXT(","), *GroupName, &Array );
				for( INT x = 0 ; x < Array.Num() ; x++ )
				{
					INT idx = pListGroups->FindStringExact( *Array(x) );

					for( INT s = 0 ; s < SelCount ; s++ )
						if( idx == Buffer[s] )
							pActor->bSelected = Select;
				}
			}
		}

		delete [] Buffer;
		PostMessageX( GhwndEditorFrame, WM_COMMAND, WM_REDRAWALLVIEWPORTS, 0 );
	}
	void NewGroup()
	{
		if( !NumActorsSelected() )
		{
			appMsgf(TEXT("You must have some actors selected to create a new group."));
			return;
		}

		// Generate a suggested group name to use as a default.
		INT x = 1;
		FString DefaultName;
		while(1)
		{
			DefaultName = *(FString::Printf(TEXT("Group%d"), x) );
			if( pListGroups->FindStringExact( *DefaultName ) == LB_ERR )
				break;
			x++;
		}

		WDlgGroup dlg( NULL, this );
		if( dlg.DoModal( 1, DefaultName ) )
		{
			if( GEditor->Level->GetLevelInfo()->VisibleGroups.Len() )
				GEditor->Level->GetLevelInfo()->VisibleGroups += TEXT(",");
			GEditor->Level->GetLevelInfo()->VisibleGroups += dlg.Name;

			AddToGroup( dlg.Name );
			RefreshGroupList();
		}
	}
	void DeleteGroup()
	{
		INT SelCount = pListGroups->GetSelectedCount();
		if( SelCount == LB_ERR )	return;
		int* Buffer = new int[SelCount];
		pListGroups->GetSelectedItems(SelCount, Buffer);
		for( INT s = 0 ; s < SelCount ; s++ )
		{
			FString DeletedGroup = pListGroups->GetString(Buffer[s]);
			for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
			{
				AActor* pActor = GEditor->Level->Actors(i);
				if(	pActor 
					&& !Cast<ACamera>(pActor )
					&& pActor!=GEditor->Level->Brush()
					&& pActor->GetClass()->GetDefaultActor()->bHiddenEd==0 )
				{
					FString GroupName = *pActor->Group;
					TArray<FString> Array;
					ParseStringToArray( TEXT(","), *GroupName, &Array );
					FString NewGroup;
					for( INT x = 0 ; x < Array.Num() ; x++ )
					{
						if( Array(x) != DeletedGroup )
						{
							if( NewGroup.Len() )
								NewGroup += TEXT(",");
							NewGroup += Array(x);
						}
					}
					if( NewGroup != *pActor->Group )
					{
						pActor->Modify();
						pActor->Group = *NewGroup;
					}
				}
			}
		}
		delete [] Buffer;

		GEditor->NoteSelectionChange( GEditor->Level );
		RefreshGroupList();
	}
	void AddToGroup( FString InGroupName)
	{
		for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
		{
			AActor* pActor = GEditor->Level->Actors(i);
			if(	pActor 
				&& pActor->bSelected
				&& !Cast<ACamera>(pActor )
				&& pActor!=GEditor->Level->Brush()
				&& pActor->GetClass()->GetDefaultActor()->bHiddenEd==0 )
			{
				FString GroupName = *pActor->Group, NewGroupName;

				// Make sure this actor is not already in this group.  If so, don't add it again.
				TArray<FString> Array;
				ParseStringToArray( TEXT(","), *GroupName, &Array );
				for( INT x = 0 ; x < Array.Num() ; x++ )
				{
					if( Array(x) == InGroupName )
						break;
				}

				if( x == Array.Num() )
				{
					// Add the group to the actors group list
					NewGroupName = *(FString::Printf(TEXT("%s%s%s"), *GroupName, (GroupName.Len()?TEXT(","):TEXT("")), *InGroupName ) );
					pActor->Modify();
					pActor->Group = *NewGroupName;
				}
			}
		}

		GEditor->NoteSelectionChange( GEditor->Level );
	}
	void DeleteFromGroup()
	{
		INT SelCount = pListGroups->GetSelectedCount();
		if( SelCount == LB_ERR )	return;
		int* Buffer = new int[SelCount];
		pListGroups->GetSelectedItems(SelCount, Buffer);
		for( INT s = 0 ; s < SelCount ; s++ )
		{
			FString DeletedGroup = pListGroups->GetString(Buffer[s]);

			for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
			{
				AActor* pActor = GEditor->Level->Actors(i);
				if(	pActor 
					&& pActor->bSelected
					&& !Cast<ACamera>(pActor )
					&& pActor!=GEditor->Level->Brush()
					&& pActor->GetClass()->GetDefaultActor()->bHiddenEd==0 )
				{
					FString GroupName = *pActor->Group;
					TArray<FString> Array;
					ParseStringToArray( TEXT(","), *GroupName, &Array );
					FString NewGroup;
					for( INT x = 0 ; x < Array.Num() ; x++ )
						if( Array(x) != DeletedGroup )
						{
							if( NewGroup.Len() )
								NewGroup += TEXT(",");
							NewGroup += Array(x);
						}
					if( NewGroup != *pActor->Group )
					{
						pActor->Modify();
						pActor->Group = *NewGroup;
					}
				}
			}
		}

		GEditor->NoteSelectionChange( GEditor->Level );
		RefreshGroupList();
	}
	void RenameGroup()
	{
		WDlgGroup dlg( NULL, this );
		INT SelCount = pListGroups->GetSelectedCount();
		if( SelCount == LB_ERR )	return;
		int* Buffer = new int[SelCount];
		pListGroups->GetSelectedItems(SelCount, Buffer);
		for( INT s = 0 ; s < SelCount ; s++ )
		{
			FString Src = pListGroups->GetString(Buffer[s]);
			if( dlg.DoModal( 0, Src ) )
				SwapGroupNames( Src, dlg.Name );
		}
		delete [] Buffer;

		RefreshGroupList();
		GEditor->NoteSelectionChange( GEditor->Level );
	}
	void SwapGroupNames( FString Src, FString Dst )
	{
		if( Src == Dst ) return;
		check(Src.Len());
		check(Dst.Len());

		for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
		{
			AActor* pActor = GEditor->Level->Actors(i);
			if(	pActor 
				&& !Cast<ACamera>(pActor )
				&& pActor!=GEditor->Level->Brush()
				&& pActor->GetClass()->GetDefaultActor()->bHiddenEd==0 )
			{
				FString GroupName = *pActor->Group, NewGroup;
				TArray<FString> Array;
				ParseStringToArray( TEXT(","), *GroupName, &Array );
				for( INT x = 0 ; x < Array.Num() ; x++ )
				{
					FString AddName;
					AddName = Array(x);
					if( Array(x) == Src )
						AddName = Dst;

					if( NewGroup.Len() )
						NewGroup += TEXT(",");
					NewGroup += AddName;
				}

				if( NewGroup != *pActor->Group )
				{
					pActor->Modify();
					pActor->Group = *NewGroup;
				}
			}
		}
	}
	INT NumActorsSelected()
	{
		FStringOutputDevice GetPropResult = FStringOutputDevice();
		GEditor->Get( TEXT("ACTOR"), TEXT("NUMSELECTED"), GetPropResult );
		return appAtoi(*GetPropResult);
	}

	// Notification delegates for child controls.
	//
	void OnNewGroup()
	{
		NewGroup();
	}
	void OnDeleteGroup()
	{
		DeleteGroup();
	}
	void OnAddToGroup()
	{
		INT SelCount = pListGroups->GetSelectedCount();
		if( SelCount == LB_ERR )	return;
		int* Buffer = new int[SelCount];
		pListGroups->GetSelectedItems(SelCount, Buffer);
		for( INT s = 0 ; s < SelCount ; s++ )
			AddToGroup(pListGroups->GetString(Buffer[s]));
		delete [] Buffer;
	}
	void OnDeleteFromGroup()
	{
		DeleteFromGroup();
	}
	void OnRefreshGroups()
	{
		RefreshGroupList();
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
