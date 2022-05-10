/*=============================================================================
	SearchActors : Searches for actors using various criteria
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

class WDlgSearchActors : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgSearchActors,WDialog,DukeEd)

	// Variables.
	WButton CloseButton;
	WListBox ActorList;
	WEdit NameEdit, EventEdit, TagEdit;

	// Constructor.
	WDlgSearchActors( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog			( TEXT("Search for Actors"), IDDIALOG_SEARCH, InOwnerWindow )
	,	CloseButton		( this, IDPB_CLOSE,		FDelegate(this,(TDelegate)OnClose) )
	,	NameEdit		( this, IDEC_NAME )
	,	EventEdit		( this, IDEC_EVENT )
	,	TagEdit			( this, IDEC_TAG )
	,	ActorList		( this, IDLB_NAMES )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();
		ActorList.DoubleClickDelegate = FDelegate(this, (TDelegate)OnActorListDblClick);
		NameEdit.ChangeDelegate = FDelegate(this, (TDelegate)OnNameEditChange);
		EventEdit.ChangeDelegate = FDelegate(this, (TDelegate)OnEventEditChange);
		TagEdit.ChangeDelegate = FDelegate(this, (TDelegate)OnTagEditChange);
		RefreshActorList();
	}
	virtual void OnShowWindow( UBOOL bShow )
	{
		WWindow::OnShowWindow( bShow );
		RefreshActorList();
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual void DoModeless()
	{
		_Windows.AddItem( this );
		hWnd = CreateDialogParamA( hInstance, MAKEINTRESOURCEA(IDDIALOG_SEARCH), OwnerWindow?OwnerWindow->hWnd:NULL, (DLGPROC)StaticDlgProc, (LPARAM)this);
		if( !hWnd )
			appGetLastError();
		Show(1);
	}
	void RefreshActorList( void )
	{
		ActorList.Empty();
		LockWindowUpdate( ActorList.hWnd );

		FString Name, Event, Tag;
		HWND hwndFocus = ::GetFocus();

		Name = NameEdit.GetText();
		Event = EventEdit.GetText();
		Tag = TagEdit.GetText();

		if( GEditor
				&& GEditor->Level )
		{
			for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
			{
				AActor* pActor = GEditor->Level->Actors(i);
				if( pActor )
				{
					FString ActorName = pActor->GetName(),
						ActorEvent = *(pActor->Event),
						ActorTag = *(pActor->Tag);
					if( Name != ActorName.Left( Name.Len() ) )
						continue;
					if( Event.Len() && Event != ActorEvent.Left( Event.Len() ) )
						continue;
					if( Tag.Len() && Tag != ActorTag.Left( Tag.Len() ) )
						continue;

					ActorList.AddString( pActor->GetName() );
				}
			}
		}

		LockWindowUpdate( NULL );
		::SetFocus( hwndFocus );
	}
	void OnClose()
	{
		Show(0);
	}
	void OnActorListDblClick()
	{
		GEditor->SelectNone( GEditor->Level, 0 );
		GEditor->Exec( *(FString::Printf(TEXT("CAMERA ALIGN NAME=%s"), *(ActorList.GetString( ActorList.GetCurrent()) ) ) ) );
		GEditor->NoteSelectionChange( GEditor->Level );
	}
	void OnNameEditChange()
	{
		RefreshActorList();
	}
	void OnEventEditChange()
	{
		RefreshActorList();
	}
	void OnTagEditChange()
	{
		RefreshActorList();
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
