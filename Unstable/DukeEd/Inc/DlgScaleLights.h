/*=============================================================================
	ScaleLights : Allows for the scaling of light values
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

class WDlgScaleLights : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgScaleLights,WDialog,DukeEd)

	// Variables.
	WCheckBox LiteralCheck;
	WButton OKButton, CloseButton;
	WEdit ValueEdit;

	// Constructor.
	WDlgScaleLights( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog			( TEXT("Scale Lights"), IDDIALOG_SCALE_LIGHTS, InOwnerWindow )
	,	OKButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOK) )
	,	CloseButton		( this, IDPB_CLOSE,		FDelegate(this,(TDelegate)OnClose) )
	,	LiteralCheck	( this, IDRB_LITERAL )
	,	ValueEdit		( this, IDEC_VALUE )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();
		LiteralCheck.SetCheck( BST_CHECKED );
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		WDialog::OnDestroy();
	}
	virtual void DoModeless()
	{
		_Windows.AddItem( this );
		hWnd = CreateDialogParamA( hInstance, MAKEINTRESOURCEA(IDDIALOG_SCALE_LIGHTS), OwnerWindow?OwnerWindow->hWnd:NULL, (DLGPROC)StaticDlgProc, (LPARAM)this);
		if( !hWnd )
			appGetLastError();
		Show(1);
	}
	void OnClose()
	{
		Show(0);
	}
	void OnOK()
	{
		UBOOL bLiteral = LiteralCheck.IsChecked();
		INT Value = appAtoi( *(ValueEdit.GetText()) );

		// Loop through all selected actors and scale their light value by the specified amount.
		for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
		{
			AActor* pActor = GEditor->Level->Actors(i);
			if( pActor && pActor->bSelected )
			{
				INT iLightBrighness = pActor->LightBrightness;
				if( bLiteral )
					iLightBrighness += Value;
				else
					iLightBrighness += (int)((FLOAT)iLightBrighness * (Value / 100.0f));

				iLightBrighness = iLightBrighness % 255;
				pActor->LightBrightness = iLightBrighness;
			}
		}

		GEditor->NoteSelectionChange( GEditor->Level );
		GEditor->RedrawLevel( GEditor->Level );
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
