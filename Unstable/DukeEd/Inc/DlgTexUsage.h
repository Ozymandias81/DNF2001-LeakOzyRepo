/*=============================================================================
	DlgTexUsage : Replace one texture with another in the level
	Copyright 2001 3D Realms Entertainment. All Rights Reserved.

	Revision history:
		* Created by Brandon Reinhart
=============================================================================*/

class WDlgTexUsage : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgTexUsage,WDialog,DukeEd)

	// Variables.
	WButton		DoneButton;
	WButton		ViewButton;
	WLabel		TexNameLabel;
	WLabel		TexCountLabel;

	ABrush*		SurfaceBrush;

	// Constructor.
	WDlgTexUsage( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog		( TEXT("Teture Usage"), IDDIALOG_TEXUSAGE, InOwnerWindow )
	,	DoneButton	( this, IDTU_DONE, FDelegate(this,(TDelegate)EndDialogTrue) )
	,	ViewButton	( this, IDTU_VIEW, FDelegate(this,(TDelegate)OnViewButton) )
	,	TexNameLabel	(this, IDC_TUR_TEXNAME )
	,	TexCountLabel	(this, IDC_TUR_TEXCOUNT )
	,	SurfaceBrush ( NULL )
	{ }

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		// Texture usage count.
		debugf(TEXT("Gathering usage stats on %s"),GEditor->CurrentTexture->GetFullName());
		INT TexCount = 0;
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
						{
							TexCount++;
							if ( !SurfaceBrush && ItS->Actor )
								SurfaceBrush = ItS->Actor;
						}

					if( M->Polys )
						for( TArray<FPoly>::TIterator ItP(M->Polys->Element); ItP; ++ItP )
							if( ItP->Texture==GEditor->CurrentTexture )
							{
								TexCount++;
								if ( !SurfaceBrush && ItP->Actor )
									SurfaceBrush = ItP->Actor;
							}
				}
			}
		}
		TexNameLabel.SetText( GEditor->CurrentTexture->GetName() );
		TCHAR Count[256];
		appSprintf( Count, _T("%i"), TexCount );
		TexCountLabel.SetText( Count );

		if (TexCount == 0)
			::EnableWindow( ViewButton, 0 );
	}
	void OnViewButton()
	{
		debugf(_T("View button hit"));
		if ( SurfaceBrush )
		{
			debugf(_T("SurfaceBrush valid"));
			GEditor->SelectNone( GEditor->Level, 0 );
			GEditor->Exec( *(FString::Printf(TEXT("CAMERA ALIGN NAME=%s"), SurfaceBrush->GetName())) );
			GEditor->NoteSelectionChange( GEditor->Level );
		}
	}
};