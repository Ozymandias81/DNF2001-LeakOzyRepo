/*=============================================================================
	ViewportFrame : Simple window to hold a viewport into a level
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

#include "..\..\core\inc\UnMsg.h"

extern WSurfacePropSheet* GSurfPropSheet;
extern WBuildPropSheet* GBuildSheet;

class WVFToolBar : public WWindow
{
	DECLARE_WINDOWCLASS(WVFToolBar,WWindow,Window)

	TArray<WPictureButton> Buttons;
	HBITMAP hbm;
	BITMAP bm;
	FString Caption;
	UViewport* m_pViewport;
	HBRUSH brushBack;
	HPEN penLine;
	HMENU VFContextMenu;

	// Structors.
	WVFToolBar( FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	{
		hbm = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_VF_TOOLBAR), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );	check(hbm);
		GetObjectA( hbm, sizeof(BITMAP), (LPSTR)&bm );
		m_pViewport = NULL;
		brushBack = CreateSolidBrush( RGB(128,128,128) );
		penLine = CreatePen( PS_SOLID, 1, RGB(80,80,80) );
	}

	// WWindow interface.
	void OpenWindow()
	{
		MdiChild = 0;

		PerformCreateWindowEx
		(
			0,
			NULL,
			WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
			0,
			0,
			320,
			200,
			OwnerWindow ? OwnerWindow->hWnd : NULL,
			NULL,
			hInstance
		);
		SendMessageX( *this, WM_SETFONT, (WPARAM)GetStockObject(DEFAULT_GUI_FONT), MAKELPARAM(0,0) );
	}
	void OnDestroy()
	{
		WWindow::OnDestroy();
		for( INT x = 0 ; x < Buttons.Num() ; x++ )
			DestroyWindow( Buttons(x).hWnd );
		Buttons.Empty();
		DeleteObject( hbm );
		DeleteObject( brushBack );
		DeleteObject( penLine );
		DestroyMenu( VFContextMenu );
	}
	void OnCreate()
	{
		WWindow::OnCreate();
		VFContextMenu = LoadMenuIdX(hInstance, IDMENU_VF_CONTEXT);
	}
	void SetCaption( FString InCaption )
	{
		Caption = InCaption;
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void OnPaint()
	{
		PAINTSTRUCT PS;
		HDC hDC = BeginPaint( *this, &PS );

		RECT rc;
		::GetClientRect( hWnd, &rc );

		FillRect( hDC, &rc, brushBack );

		rc.left += 2;
		rc.top += 1;
		if( GViewportStyle == VSTYLE_Fixed )
		{
			::SetBkMode( hDC, TRANSPARENT );
			::DrawTextA( hDC, TCHAR_TO_ANSI( *Caption ), ::strlen( TCHAR_TO_ANSI( *Caption ) ), &rc, DT_LEFT | DT_SINGLELINE );
		}
		rc.left -= 2;
		rc.top -= 1;

		HPEN OldPen = (HPEN)SelectObject( hDC, penLine );
		::MoveToEx( hDC, 0, rc.bottom - 4, NULL );
		::LineTo( hDC, rc.right, rc.bottom - 4 );
		SelectObject( hDC, OldPen );

		EndPaint( *this, &PS );
	}
	void AddButton( FString InToolTip, INT InID, 
		INT InClientLeft, INT InClientTop, INT InClientRight, INT InClientBottom,
		INT InBmpOffLeft, INT InBmpOffTop, INT InBmpOffRight, INT InBmpOffBottom,
		INT InBmpOnLeft, INT InBmpOnTop, INT InBmpOnRight, INT InBmpOnBottom )
	{
		new(Buttons)WPictureButton( this );
		WPictureButton* ppb = &(Buttons(Buttons.Num() - 1));
		check(ppb);

		ppb->SetUp( InToolTip, InID, 
			InClientLeft, InClientTop, InClientRight, InClientBottom,
			hbm, InBmpOffLeft, InBmpOffTop, InBmpOffRight, InBmpOffBottom,
			hbm, InBmpOnLeft, InBmpOnTop, InBmpOnRight, InBmpOnBottom );
		ppb->OpenWindow();
		ppb->OnSize( SIZE_MAXSHOW, InClientRight, InClientBottom );
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WWindow::OnSize(Flags, NewX, NewY);

		for( INT x = 0 ; x < Buttons.Num() ; x++ )
		{
			WPictureButton* ppb = &(Buttons(x));
			::MoveWindow( ppb->hWnd, ppb->ClientPos.left, ppb->ClientPos.top, ppb->ClientPos.right, ppb->ClientPos.bottom, 1 );
		}
	}
	void SetViewport( UViewport* pViewport )
	{
		m_pViewport = pViewport;
	}
	void OnRightButtonUp()
	{
		HMENU l_menu = GetSubMenu( VFContextMenu, 0 );

		POINT pt;
		::GetCursorPos( &pt );

		// "Check" appropriate menu items based on current settings.
		CheckMenuItem( l_menu, ID_MapOverhead, (m_pViewport->Actor->RendMap == REN_OrthXY) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_MapXZ, (m_pViewport->Actor->RendMap == REN_OrthXZ) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_MapYZ, (m_pViewport->Actor->RendMap == REN_OrthYZ) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_MapWire, (m_pViewport->Actor->RendMap == REN_Wire) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_MapPolys, (m_pViewport->Actor->RendMap == REN_Polys) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_MapPolyCuts, (m_pViewport->Actor->RendMap == REN_PolyCuts) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_MapPlainTex, (m_pViewport->Actor->RendMap == REN_PlainTex) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_MapDynLight, (m_pViewport->Actor->RendMap == REN_DynLight) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_MapZones, (m_pViewport->Actor->RendMap == REN_Zones) ? MF_CHECKED : MF_UNCHECKED );

		CheckMenuItem( l_menu, ID_ShowBrush, (m_pViewport->Actor->ShowFlags&SHOW_Brush) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_ShowHardwareBrushes, (m_pViewport->Actor->ShowFlags&SHOW_HardwareBrushes) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_ShowBackdrop, (m_pViewport->Actor->ShowFlags&SHOW_Backdrop) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_ShowCoords, (m_pViewport->Actor->ShowFlags&SHOW_Coords) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_ShowMovingBrushes, (m_pViewport->Actor->ShowFlags&SHOW_MovingBrushes) ? MF_CHECKED : MF_UNCHECKED );
		CheckMenuItem( l_menu, ID_ShowPaths, (m_pViewport->Actor->ShowFlags&SHOW_Paths) ? MF_CHECKED : MF_UNCHECKED );

		CheckMenuItem( l_menu, ID_Color16Bit, ((m_pViewport->ColorBytes==2) ? MF_CHECKED : MF_UNCHECKED ) );
		CheckMenuItem( l_menu, ID_Color32Bit, ((m_pViewport->ColorBytes==4) ? MF_CHECKED : MF_UNCHECKED ) );

		CheckMenuItem( l_menu, IDMN_RD_SOFTWARE, (!appStrcmp(TEXT("Class SoftDrv.SoftwareRenderDevice"), m_pViewport->RenDev->GetClass()->GetFullName()) ? MF_CHECKED : MF_UNCHECKED ) );
		CheckMenuItem( l_menu, IDMN_RD_DIRECT3D, (!appStrcmp(TEXT("Class D3DDrv.D3DRenderDevice"), m_pViewport->RenDev->GetClass()->GetFullName()) ? MF_CHECKED : MF_UNCHECKED ) );
		
		// NJS: Software removal, phase I
		EnableMenuItem(l_menu, IDMN_RD_SOFTWARE, MF_GRAYED);
		EnableMenuItem(l_menu, IDMN_RD_DIRECT3D, MF_GRAYED);



		DWORD ShowFilter = m_pViewport->Actor->ShowFlags & (SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii);
		if		(ShowFilter==(SHOW_Actors | SHOW_ActorIcons)) CheckMenuItem( l_menu, ID_ActorsIcons, MF_CHECKED );
		else if (ShowFilter==(SHOW_Actors | SHOW_ActorRadii)) CheckMenuItem( l_menu, ID_ActorsRadii, MF_CHECKED );
		else if (ShowFilter==(SHOW_Actors                  )) CheckMenuItem( l_menu, ID_ActorsShow, MF_CHECKED );
		else CheckMenuItem( l_menu, ID_ActorsHide, MF_CHECKED );

		TrackPopupMenu( l_menu,
			TPM_LEFTALIGN | TPM_TOPALIGN | TPM_RIGHTBUTTON,
			pt.x, pt.y, 0,
			OwnerWindow->hWnd, NULL);
	}
	// Sets the bOn variable in the various buttons
	void UpdateButtons()
	{
		if( !m_pViewport ) return;

		for( INT x = 0 ; x < Buttons.Num() ; x++ )
		{
			switch( Buttons(x).ID )
			{
				case IDMN_VF_REALTIME_PREVIEW:
					Buttons(x).bOn = m_pViewport->Actor->ShowFlags & SHOW_PlayerCtrl;
					break;

				case ID_MapDynLight:
					Buttons(x).bOn = (m_pViewport->Actor->RendMap == REN_DynLight);
					break;

				case ID_MapPlainTex:
					Buttons(x).bOn = (m_pViewport->Actor->RendMap == REN_PlainTex);
					break;

				case ID_MapWire:
					Buttons(x).bOn = (m_pViewport->Actor->RendMap == REN_Wire);
					break;

				case ID_MapOverhead:
					Buttons(x).bOn = (m_pViewport->Actor->RendMap == REN_OrthXY);
					break;

				case ID_MapXZ:
					Buttons(x).bOn = (m_pViewport->Actor->RendMap == REN_OrthXZ);
					break;

				case ID_MapYZ:
					Buttons(x).bOn = (m_pViewport->Actor->RendMap == REN_OrthYZ);
					break;

				case ID_MapPolys:
					Buttons(x).bOn = (m_pViewport->Actor->RendMap == REN_Polys);
					break;

				case ID_MapPolyCuts:
					Buttons(x).bOn = (m_pViewport->Actor->RendMap == REN_PolyCuts);
					break;

				case ID_MapZones:
					Buttons(x).bOn = (m_pViewport->Actor->RendMap == REN_Zones);
					break;
			}

			InvalidateRect( Buttons(x).hWnd, NULL, 1 );
		}
	}
	void OnCommand( INT Command )
	{
		switch( Command ) {

			case WM_PB_PUSH:
				ButtonClicked(LastlParam);
				SendMessageX( OwnerWindow->hWnd, WM_COMMAND, WM_VIEWPORT_UPDATEWINDOWFRAME, 0 );
				break;

			default:
				WWindow::OnCommand(Command);
				break;
		}
	}
	void ButtonClicked( INT ID )
	{
		switch( ID )
		{
			case IDMN_VF_REALTIME_PREVIEW:
				m_pViewport->Actor->ShowFlags ^= SHOW_PlayerCtrl;
				break;

			case ID_MapDynLight:
				m_pViewport->Actor->RendMap=REN_DynLight;
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapPlainTex:
				m_pViewport->Actor->RendMap=REN_PlainTex;
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapWire:
				m_pViewport->Actor->RendMap=REN_Wire;
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapOverhead:
				m_pViewport->Actor->RendMap=REN_OrthXY;
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapXZ:
				m_pViewport->Actor->RendMap=REN_OrthXZ;
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapYZ:
				m_pViewport->Actor->RendMap=REN_OrthYZ;
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapPolys:
				m_pViewport->Actor->RendMap=REN_Polys;
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapPolyCuts:
				m_pViewport->Actor->RendMap=REN_PolyCuts;
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapZones:
				{
					m_pViewport->Actor->RendMap=REN_Zones;
					m_pViewport->Repaint( 1 );
				}
				break;
		}

		UpdateButtons();
		InvalidateRect( hWnd, NULL, FALSE );
	}
};

struct
{
	INT ID;
	TCHAR ToolTip[64];
	INT Move;
} GVFButtons[] =
{
	IDMN_VF_REALTIME_PREVIEW, TEXT("Realtime Preview (P)"), 22,
	-1, TEXT(""), 11,
	ID_MapOverhead, TEXT("Top (Alt+7)"), 22,
	ID_MapXZ, TEXT("Front (Alt+8)"), 22,
	ID_MapYZ, TEXT("Side (Alt+9)"), 22,
	-1, TEXT(""), 11,
	ID_MapWire, TEXT("Perspective (Alt+1)"), 22,
	ID_MapPolys, TEXT("Texture Usage (Alt+3)"), 22,
	ID_MapPolyCuts, TEXT("BSP Cuts (Alt+4)"), 22,
	ID_MapPlainTex, TEXT("Textured (Alt+6)"), 22,
	ID_MapDynLight, TEXT("Dynamic Light (Alt+5)"), 22,
	ID_MapZones, TEXT("Zone/Portal (Alt+2)"), 22,
	-2, TEXT(""), 0
};

class WViewportFrame : public WWindow
{
	DECLARE_WINDOWCLASS(WViewportFrame,WWindow,Window)

	UViewport* m_pViewport;	// The viewport that this frame contains
	INT m_iIdx;				// Index into the global TArray of viewport frames (GViewports)
	FString Caption;
	HBITMAP bmpToolbar;
	WVFToolBar* VFToolbar;
	
	// Structors.
	WViewportFrame( FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	{
		m_pViewport = NULL;
		m_iIdx = INDEX_NONE;
		Caption = TEXT("");
		VFToolbar = NULL;
	}

	// WWindow interface.
	void OpenWindow()
	{
		MdiChild = 0;

		PerformCreateWindowEx
		(
			0,
			TEXT("Viewport"),
			(GViewportStyle == VSTYLE_Floating)
				? WS_OVERLAPPEDWINDOW | WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS
				: WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
			0,
			0,
			320,
			200,
			OwnerWindow ? OwnerWindow->hWnd : NULL,
			NULL,
			hInstance
		);

		VFToolbar = new WVFToolBar( TEXT("VFToolbar"), this );
		VFToolbar->OpenWindow();

		INT BmpPos = 0;
		for( INT x = 0 ; GVFButtons[x].ID != -2 ; x++ )
		{
			if( GVFButtons[x].ID != -1 )
			{
				VFToolbar->AddButton( GVFButtons[x].ToolTip, GVFButtons[x].ID,
					0, 0, 22, 20,
					(22*BmpPos), 0, 22, 20,
					(22*BmpPos), 20, 22, 20 );
				BmpPos++;
			}
		}
		AdjustToolbarButtons();

		VFToolbar->UpdateButtons();
		UpdateWindow();
	}
	// call this function when the viewportstyle changes to move buttons on the toolbar back and forth.
	void AdjustToolbarButtons()
	{
		INT Button = 0, Pos = (GViewportStyle == VSTYLE_Floating ? 0 : 100 );
		WPictureButton* pButton;
		for( INT x = 0 ; GVFButtons[x].ID != -2 ; x++ )
		{
			if( GVFButtons[x].ID != -1 )
			{
				pButton = &(VFToolbar->Buttons(Button));
				pButton->ClientPos.left = Pos;
				::MoveWindow( pButton->hWnd, pButton->ClientPos.left, pButton->ClientPos.top, pButton->ClientPos.right, pButton->ClientPos.bottom, 1 );
				Button++;
			}
			Pos += GVFButtons[x].Move;
		}
	}
	void OnDestroy()
	{
		DestroyWindow(VFToolbar->hWnd);
		delete VFToolbar;
	}
	void OnCreate()
	{
		WWindow::OnCreate();
	}
	void OnPaint()
	{
		UpdateWindow();

		PAINTSTRUCT PS;
		HDC hDC = BeginPaint( *this, &PS );
		FRect rectOutline = GetClientRect();
		HBRUSH brushOutline = CreateSolidBrush( RGB(192,192,192) );

		rectOutline.Min.X += 2;
		rectOutline.Min.Y += 2;
		rectOutline.Max.X -= 2;
		rectOutline.Max.Y -= 2;

		// The current viewport has a white border.
		if( GCurrentViewport == (DWORD)m_pViewport )
			FillRect( hDC, GetClientRect(), (HBRUSH)GetStockObject(WHITE_BRUSH) );
		else
			FillRect( hDC, GetClientRect(), (HBRUSH)GetStockObject(BLACK_BRUSH) );

		FillRect( hDC, rectOutline, brushOutline );

		EndPaint( *this, &PS );

		DeleteObject(brushOutline);
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WWindow::OnSize(Flags, NewX, NewY);

		FRect R = GetClientRect();
		if( VFToolbar )
			::MoveWindow( VFToolbar->hWnd, 3, 3, R.Max.X - 6, 24, 1 );

		RECT rcVFToolbar = { 0, 0, 0, 0 };
		if( VFToolbar )
			::GetClientRect( VFToolbar->hWnd, &rcVFToolbar );

		if( m_pViewport )
		{
			// Viewport should leave a border around the outside so we can show which viewport is active.
			// This border will be colored white if the viewport is active, black if not.

			R.Max.X -= 3;
			R.Max.Y -= 3;
			R.Min.X += 3;
			R.Min.Y += (rcVFToolbar.bottom - rcVFToolbar.top);
			::MoveWindow( (HWND)m_pViewport->GetWindow(), R.Min.X, R.Min.Y, R.Width(), R.Height(), 1 );
			m_pViewport->Repaint( 1 );
		}

		InvalidateRect( hWnd, NULL, FALSE );
	}
	// Computes the viewport frames position data relative to the parent window
	void ComputePositionData()
	{
		VIEWPORTCONFIG* pVC = &(GViewports(m_iIdx));

		// Get the size of the client area we are being put into.
		RECT rcParent;
		HWND hwndParent = GetParent(GetParent(hWnd));
		::GetClientRect(hwndParent, &rcParent);

		// Get the size of this window, in screen coordinates.
		RECT rcThis;
		POINT point;
		::GetWindowRect( hWnd, &rcThis );
		point.x = rcThis.left;	point.y = rcThis.top;		::ScreenToClient( hwndParent, &point );		rcThis.left = point.x;	rcThis.top = point.y;
		point.x = rcThis.right;	point.y = rcThis.bottom;	::ScreenToClient( hwndParent, &point );		rcThis.right = point.x;	rcThis.bottom = point.y;
		
		// Compute the sizing percentages for this window.
		//
		// Avoid divide by zero
		rcParent.right = max(rcParent.right, 1);
		rcParent.bottom = max(rcParent.bottom, 1);

		pVC->PctLeft = rcThis.left / (FLOAT)rcParent.right;
		pVC->PctTop = rcThis.top / (FLOAT)rcParent.bottom;
		pVC->PctRight = (rcThis.right / (FLOAT)rcParent.right) - pVC->PctLeft;
		pVC->PctBottom = (rcThis.bottom / (FLOAT)rcParent.bottom) - pVC->PctTop;

		// Clamp the percentages to be INT's ... this prevents the viewports from drifting
		// between sessions.
		pVC->PctLeft = appRound(pVC->PctLeft * 100.0f) / 100.0f;
		pVC->PctTop = appRound(pVC->PctTop * 100.0f) / 100.0f;
		pVC->PctRight = appRound(pVC->PctRight * 100.0f) / 100.0f;
		pVC->PctBottom = appRound(pVC->PctBottom * 100.0f) / 100.0f;

		pVC->Left = rcThis.left;
		pVC->Top = rcThis.top;
		pVC->Right = rcThis.right - pVC->Left;
		pVC->Bottom = rcThis.bottom - pVC->Top;
	}
	void OnKeyUp( WPARAM wParam, LPARAM lParam )
	{
		// A hack to get the familiar hotkeys working again.  This should really go through
		// Proper Windows accelerators, but I can't get them to work.
		switch( wParam )
		{
			case VK_F4:
				GEditor->Exec( TEXT("HOOK ACTORPROPERTIES") );
				break;

			case VK_F5:
				GSurfPropSheet->Show( TRUE );
				break;

			case VK_F6:
				if( !GEditor->LevelProperties )
				{
					GEditor->LevelProperties = new WObjectProperties( TEXT("LevelProperties"), CPF_Edit, TEXT("Level Properties"), NULL, 1 );
					GEditor->LevelProperties->OpenWindow( hWnd );
					GEditor->LevelProperties->SetNotifyHook( GEditor );
				}
				GEditor->LevelProperties->Root.SetObjects( (UObject**)&GEditor->Level->Actors(0), 1 );
				GEditor->LevelProperties->Show(1);
				break;

			case VK_F7:
				GWarn->BeginSlowTask( TEXT("Compiling changed scripts"), 1, 0 );
				GEditor->Exec( TEXT("SCRIPT MAKE") );
				GWarn->EndSlowTask();
				break;

			case VK_F8:
				GBuildSheet->Show(1);
				break;

			case VK_DELETE:
				/*
				FStringOutputDevice GetPropResult = FStringOutputDevice();
				GEditor->Get( TEXT("ACTOR"), TEXT("NUMSELECTED"), GetPropResult );
				INT NumSelected = appAtoi(*GetPropResult);
				if (NumSelected == 0)
					GEditor->Exec( TEXT("DELETE") );
				else if ( IDYES == MessageBox( (HWND)GEditor->Client->Viewports(0)->GetWindow(), TEXT("Are you sure you want to delete?"), TEXT("Confirm Delete"), MB_YESNO | MB_ICONWARNING | MB_DEFBUTTON1 ) )
					GEditor->Exec( TEXT("DELETE") );
				*/
				GEditor->Exec( TEXT("DELETE") );
				break;
		}
	}
	void OnCommand( INT Command )
	{
		switch( Command ) {

			case WM_VIEWPORT_UPDATEWINDOWFRAME:
				UpdateWindow();
				break;

			case ID_MapDynLight:
				m_pViewport->Actor->RendMap=REN_DynLight;
				UpdateWindow();
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapPlainTex:
				m_pViewport->Actor->RendMap=REN_PlainTex;
				UpdateWindow();
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapWire:
				m_pViewport->Actor->RendMap=REN_Wire;
				UpdateWindow();
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapOverhead:
				m_pViewport->Actor->RendMap=REN_OrthXY;
				UpdateWindow();
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapXZ:
				m_pViewport->Actor->RendMap=REN_OrthXZ;
				UpdateWindow();
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapYZ:
				m_pViewport->Actor->RendMap=REN_OrthYZ;
				UpdateWindow();
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapPolys:
				m_pViewport->Actor->RendMap=REN_Polys;
				UpdateWindow();
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapPolyCuts:
				m_pViewport->Actor->RendMap=REN_PolyCuts;
				UpdateWindow();
				m_pViewport->Repaint( 1 );
				break;

			case ID_MapZones:
				m_pViewport->Actor->RendMap=REN_Zones;
				UpdateWindow();
				m_pViewport->Repaint( 1 );
				appMsgf(TEXT("XXX 1"));
				break;

			case IDMN_RD_SOFTWARE:
				m_pViewport->TryRenderDevice( TEXT("SoftDrv.SoftwareRenderDevice"), m_pViewport->SizeX, m_pViewport->SizeY, INDEX_NONE, 0 );
				m_pViewport->Repaint( 1 );
				break;

			case IDMN_RD_DIRECT3D:
				m_pViewport->TryRenderDevice( TEXT("D3DDrv.D3DRenderDevice"), m_pViewport->SizeX, m_pViewport->SizeY, INDEX_NONE, 0 );
				if( !m_pViewport->RenDev )
				{
					appMsgf(TEXT("Could not set render device ... reverting to software."));
					m_pViewport->TryRenderDevice( TEXT("SoftDrv.SoftwareRenderDevice"), m_pViewport->SizeX, m_pViewport->SizeY, INDEX_NONE, 0 );
				}
				m_pViewport->Repaint( 1 );
				break;

			case ID_Color16Bit:
				m_pViewport->RenDev->SetRes( m_pViewport->SizeX, m_pViewport->SizeY, 2, 0 );
				m_pViewport->Repaint( 1 );
				break;

			case ID_Color32Bit:
				m_pViewport->RenDev->SetRes( m_pViewport->SizeX, m_pViewport->SizeY, 4, 0 );
				m_pViewport->Repaint( 1 );
				break;

			case ID_ShowBackdrop:
				m_pViewport->Actor->ShowFlags ^= SHOW_Backdrop;
				m_pViewport->Repaint( 1 );
				break;

			case ID_ActorsShow:
				m_pViewport->Actor->ShowFlags &= ~(SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii);
				m_pViewport->Actor->ShowFlags |= SHOW_Actors; 
				m_pViewport->Repaint( 1 );
				break;

			case ID_ActorsIcons:
				m_pViewport->Actor->ShowFlags &= ~(SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii); 
				m_pViewport->Actor->ShowFlags |= SHOW_Actors | SHOW_ActorIcons;
				m_pViewport->Repaint( 1 );
				break;

			case ID_ActorsRadii:
				m_pViewport->Actor->ShowFlags &= ~(SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii); 
				m_pViewport->Actor->ShowFlags |= SHOW_Actors | SHOW_ActorRadii;
				m_pViewport->Repaint( 1 );
				break;

			case ID_ActorsHide:
				m_pViewport->Actor->ShowFlags &= ~(SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii); 
				m_pViewport->Repaint( 1 );
				break;

			case ID_ShowPaths:
				m_pViewport->Actor->ShowFlags ^= SHOW_Paths;
				m_pViewport->Repaint( 1 );
				break;

			case ID_ShowCoords:
				m_pViewport->Actor->ShowFlags ^= SHOW_Coords;
				m_pViewport->Repaint( 1 );
				break;

			case ID_ShowBrush:
				m_pViewport->Actor->ShowFlags ^= SHOW_Brush;
				m_pViewport->Repaint( 1 );
				break;

			case ID_ShowHardwareBrushes:
				m_pViewport->Actor->ShowFlags ^= SHOW_HardwareBrushes;
				m_pViewport->Repaint( 1 );
				break;

			case ID_ShowMovingBrushes:
				m_pViewport->Actor->ShowFlags ^= SHOW_MovingBrushes;
				m_pViewport->Repaint( 1 );
				break;

			default:
				WWindow::OnCommand(Command);
				break;
		}
	}
	void UpdateWindow( void )
	{
		if( !m_pViewport ) 
		{
			Caption = TEXT("Viewport Frame");
			return;
		}

		switch( m_pViewport->Actor->RendMap )
		{
			case REN_Wire:
				Caption = TEXT("Wireframe");
				break;

			case REN_Zones:
				Caption = TEXT("Zone/Portal");
				break;

			case REN_Polys:
				Caption = TEXT("Texture Use");
				break;

			case REN_PolyCuts:
				Caption = TEXT("BSP Cuts");
				break;

			case REN_DynLight:
				Caption = TEXT("Dynamic Light");
				break;

			case REN_PlainTex:
				Caption = TEXT("Textured");
				break;

			case REN_OrthXY:
				Caption = TEXT("Top");
				break;

			case REN_OrthXZ:
				Caption = TEXT("Front");
				break;

			case REN_OrthYZ:
				Caption = TEXT("Side");
				break;

			case REN_TexView:
				Caption = TEXT("Texture View");
				break;

			case REN_TexBrowser:
				Caption = TEXT("Texture Browser");
				break;

			case REN_MeshView:
				Caption = TEXT("Mesh Viewer");
				break;

			default:
				Caption = TEXT("Unknown");
				break;
		}

		SetText(*Caption);
		VFToolbar->SetCaption( Caption );
		VFToolbar->UpdateButtons();
	}
	void SetViewport( UViewport* pViewport )
	{
		m_pViewport = pViewport;

		FRect R = GetClientRect();
		m_pViewport->OpenWindow( (DWORD)hWnd, 0, R.Width(), R.Height(), R.Min.X, R.Min.Y );

		// Forces things to set themselves up properly when the viewport is first assigned.
		OnSize( SIZE_MAXSHOW, R.Max.X, R.Max.Y );
		VFToolbar->SetViewport(pViewport);

		UpdateWindow();
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
