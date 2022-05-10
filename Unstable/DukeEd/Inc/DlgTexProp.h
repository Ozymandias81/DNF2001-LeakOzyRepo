/*=============================================================================
	TexProp : Properties of a texture
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

INT GLastViewportNum = -1;

class WDlgTexProp : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgTexProp,WDialog,DukeEd)

	// Variables.
	WButton ClearButton;

	FString ViewportName;
	UViewport *pViewport;
	UTexture *pTexture;
	WObjectProperties* pProps;

	// Constructor.
	WDlgTexProp( UObject* InContext, WWindow* InOwnerWindow, UTexture* InTexture )
	:	WDialog		( TEXT("Texture Properties"), IDDIALOG_TEX_PROP, InOwnerWindow )
	,	ClearButton	( this, IDPB_CLEAR, FDelegate(this,(TDelegate)OnClear) )
	{
		ViewportName = FString::Printf( TEXT("TextureProp%d"), ++GLastViewportNum );
		pTexture = InTexture;
		pViewport = NULL;
		pProps = new WObjectProperties( NAME_None, CPF_Edit, TEXT(""), this, 1 );
		pProps->ShowTreeLines = 1;
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();
		FlushAllViewports();	// NJS: Test

		pProps->OpenChildWindow( IDSC_PROPS );
		pProps->Root.SetObjects( (UObject**)&pTexture, 1 );

		// Create the texture viewport
		pViewport = GEditor->Client->NewViewport( *ViewportName );
		GEditor->Level->SpawnViewActor( pViewport );
		pViewport->Input->Init( pViewport );
		check(pViewport->Actor);
		pViewport->Actor->ShowFlags = SHOW_StandardView | SHOW_NoButtons | SHOW_ChildWindow | SHOW_RealTime;
		pViewport->Actor->RendMap   = REN_TexView;
		pViewport->Group = NAME_None;
		pViewport->MiscRes = pTexture;

		RECT l_rc;
		::GetWindowRect(GetDlgItem(hWnd,IDSC_TEXTURE),&l_rc);
		POINT l_point;
		l_point.x=l_rc.left; l_point.y=l_rc.top;
		::ScreenToClient( hWnd, &l_point );
		
		pViewport->OpenWindow( (DWORD)hWnd, 0, min( 256, pTexture->USize ), min( 256, pTexture->VSize ), l_point.x, l_point.y );

		FString Caption = FString::Printf( TEXT("Texture Properties - %s (%dx%d)"),
			pTexture->GetPathName(),
			pTexture->USize,
			pTexture->VSize );
		SetText( *Caption );
	}
	void OnDestroy()
	{
		if(pProps)	  { delete pProps;		pProps=NULL;    }
		if(pViewport) { delete pViewport;   pViewport=NULL; }
		WDialog::OnDestroy();
	}
	virtual void DoModeless()
	{
		_Windows.AddItem( this );
		hWnd=CreateDialogParamA(hInstance,MAKEINTRESOURCEA(IDDIALOG_TEX_PROP),OwnerWindow?OwnerWindow->hWnd:NULL,(DLGPROC)StaticDlgProc,(LPARAM)this);
		if(!hWnd)
			appGetLastError();
		Show(1);
	}
	void OnClear()
	{
		GEditor->Exec(*(FString::Printf(TEXT("TEXTURE CLEAR NAME=%s"),pTexture->GetPathName())));
	}
};
