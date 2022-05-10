/*=============================================================================
	Generic : A generic dialog box for accepting parameters for various tools.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

class WDlgGeneric : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgGeneric,WDialog,DukeEd)

	// Variables.
	WButton OKButton, CancelButton;

	WObjectProperties* PropertyWindow;
	UOptionsProxy* Proxy;

	// Constructor.
	WDlgGeneric( UObject* InContext, WWindow* InOwnerWindow, UOptionsProxy* InProxy )
	:	WDialog			( TEXT("Generic"), IDDIALOG_GENERIC, InOwnerWindow )
	,	OKButton		( this, IDOK, FDelegate(this,(TDelegate)OnOK) )
	,	CancelButton	( this, IDCANCEL, FDelegate(this,(TDelegate)EndDialogFalse) )
	{
		check(InProxy);
		Proxy = InProxy;
		PropertyWindow = new WObjectProperties( NAME_None, CPF_Edit, TEXT(""), this, 1 );
		PropertyWindow->ShowTreeLines = 1;
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		PropertyWindow->OpenChildWindow( IDSC_PROPS );

		PropertyWindow->Root.Sorted = 0;
		PropertyWindow->Root._Objects.AddItem( Proxy );
		for( TFieldIterator<UProperty> It(Proxy->GetClass()); It; ++It )
			if( ( It->Category==FName(Proxy->GetClass()->GetName())
					|| It->Category==FName(TEXT("Options2DShaper")) )
					&& PropertyWindow->Root.AcceptFlags( It->PropertyFlags ) )
				PropertyWindow->Root.Children.AddItem( new(TEXT("FPropertyItem"))FPropertyItem( PropertyWindow, &(PropertyWindow->Root), *It, It->GetFName(), It->GetElementOffset(0), -1 ) );
		PropertyWindow->Root.Expand();
		PropertyWindow->ResizeList();
		PropertyWindow->bAllowForceRefresh = 0;

		SetText( *Proxy->DlgCaption );
	}
	void OnDestroy()
	{
		::DestroyWindow( PropertyWindow->hWnd );
//		::DestroyWindow( hWnd );

		delete PropertyWindow;

		WDialog::OnDestroy();
	}
	virtual INT DoModal()
	{
		return WDialog::DoModal( hInstance );
	}
	void OnOK()
	{
		// Force all controls to save their values before trying to build the brush.
		for( INT i=0; i<PropertyWindow->Root.Children.Num(); i++ )
			((FPropertyItem*)PropertyWindow->Root.Children(i))->SendToControl();

		EndDialogTrue();
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
