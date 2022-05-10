/*=============================================================================
	ViewportConfig : Options for configuring viewport layouts and options
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

class WDlgViewportConfig : public WDialog
{
	DECLARE_WINDOWCLASS(WDlgViewportConfig,WDialog,DukeEd)

	// Variables.
	WCheckBox Cfg0Check, Cfg1Check, Cfg2Check, Cfg3Check;
	WButton OKButton, CancelButton;
	HBITMAP hbmCfg0, hbmCfg1, hbmCfg2, hbmCfg3;

	INT ViewportConfig;

	// Constructor.
	WDlgViewportConfig( UObject* InContext, WWindow* InOwnerWindow )
	:	WDialog			( TEXT("Viewport Config"), IDDIALOG_VIEWPORT_CONFIG, InOwnerWindow )
	,	OKButton		( this, IDOK,			FDelegate(this,(TDelegate)OnOK) )
	,	CancelButton	( this, IDCANCEL,		FDelegate(this,(TDelegate)EndDialogFalse) )
	,	Cfg0Check		( this, IDRB_VCONFIG0 )
	,	Cfg1Check		( this, IDRB_VCONFIG1 )
	,	Cfg2Check		( this, IDRB_VCONFIG2 )
	,	Cfg3Check		( this, IDRB_VCONFIG3 )
	{
	}

	// WDialog interface.
	void OnInitDialog()
	{
		WDialog::OnInitDialog();

		// Set controls to initial values
		switch(ViewportConfig)
		{
			case 0:		Cfg0Check.SetCheck(BST_CHECKED);	break;
			case 1:		Cfg1Check.SetCheck(BST_CHECKED);	break;
			case 2:		Cfg2Check.SetCheck(BST_CHECKED);	break;
			case 3:		Cfg3Check.SetCheck(BST_CHECKED);	break;
		}

		hbmCfg0 = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_VIEWPORT_CFG0), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS );	check(hbmCfg0);
		hbmCfg1 = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_VIEWPORT_CFG1), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS );	check(hbmCfg1);
		hbmCfg2 = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_VIEWPORT_CFG2), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS );	check(hbmCfg2);
		hbmCfg3 = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_VIEWPORT_CFG3), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS );	check(hbmCfg3);

		SendMessageX( Cfg0Check.hWnd, BM_SETIMAGE, IMAGE_BITMAP, (LPARAM)hbmCfg0);
		SendMessageX( Cfg1Check.hWnd, BM_SETIMAGE, IMAGE_BITMAP, (LPARAM)hbmCfg1);
		SendMessageX( Cfg2Check.hWnd, BM_SETIMAGE, IMAGE_BITMAP, (LPARAM)hbmCfg2);
		SendMessageX( Cfg3Check.hWnd, BM_SETIMAGE, IMAGE_BITMAP, (LPARAM)hbmCfg3);
	}
	void OnDestroy()
	{
//		::DestroyWindow( hWnd );
		DeleteObject(hbmCfg0);
		DeleteObject(hbmCfg1);
		DeleteObject(hbmCfg2);
		DeleteObject(hbmCfg3);

		WDialog::OnDestroy();
	}
	virtual INT DoModal( INT _Config )
	{
		ViewportConfig = _Config;

		return WDialog::DoModal( hInstance );
	}
	void OnOK()
	{
		ViewportConfig = 0;

		if( Cfg0Check.IsChecked() ) ViewportConfig = 0;
		else if( Cfg1Check.IsChecked() ) ViewportConfig = 1;
		else if( Cfg2Check.IsChecked() ) ViewportConfig = 2;
		else if( Cfg3Check.IsChecked() ) ViewportConfig = 3;

		EndDialog(1);
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
