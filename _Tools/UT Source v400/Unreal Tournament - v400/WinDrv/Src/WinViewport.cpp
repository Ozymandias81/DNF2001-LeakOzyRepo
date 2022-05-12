/*=============================================================================
	UnWnCam.cpp: UWindowsViewport code.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "WinDrv.h"

#define DD_OTHERLOCKFLAGS 0 /*DDLOCK_NOSYSLOCK*/ /*0x00000800L*/
#define WM_MOUSEWHEEL 0x020A

/*-----------------------------------------------------------------------------
	Class implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UWindowsViewport);

/*-----------------------------------------------------------------------------
	UWindowsViewport Init/Exit.
-----------------------------------------------------------------------------*/

//
// Constructor.
//
UWindowsViewport::UWindowsViewport()
:	UViewport()
,	Status( WIN_ViewportOpening )
,	diKeyboard(NULL)
,	diMouse(NULL)
{
	guard(UWindowsViewport::UWindowsViewport);
	Window = new WWindowsViewportWindow( this );

	// Set color bytes based on screen resolution.
	HWND hwndDesktop = GetDesktopWindow();
	HDC  hdcDesktop  = GetDC(hwndDesktop);
	switch( GetDeviceCaps( hdcDesktop, BITSPIXEL ) )
	{
		case 8:
			ColorBytes  = 2;
			break;
		case 16:
			ColorBytes  = 2;
			Caps       |= CC_RGB565;
			break;
		case 24:
			ColorBytes  = 4;
			break;
		case 32: 
			ColorBytes  = 4;
			break;
		default: 
			ColorBytes  = 2; 
			Caps       |= CC_RGB565;
			break;
	}
	DesktopColorBytes = ColorBytes;

	// Init other stuff.
	ReleaseDC( hwndDesktop, hdcDesktop );
	SavedCursor.x = -1;

	StandardCursors[0] = LoadCursorIdX(NULL, IDC_ARROW);
	StandardCursors[1] = LoadCursorIdX(NULL, IDC_SIZEALL);
	StandardCursors[2] = LoadCursorIdX(NULL, IDC_SIZENESW);
	StandardCursors[3] = LoadCursorIdX(NULL, IDC_SIZENS);
	StandardCursors[4] = LoadCursorIdX(NULL, IDC_SIZENWSE);
	StandardCursors[5] = LoadCursorIdX(NULL, IDC_SIZEWE);
	StandardCursors[6] = LoadCursorIdX(NULL, IDC_WAIT);

	unguard;
}

//
// Destroy.
//
void UWindowsViewport::Destroy()
{
	guard(UWindowsViewport::Destroy);
	Super::Destroy();
	diShutdownKeyboardMouse();
	if( BlitFlags & BLIT_Temporary )
		appFree( ScreenPointer );
	Window->MaybeDestroy();
	delete Window;
	Window = NULL;
	unguard;
}

//
// Error shutdown.
//
void UWindowsViewport::ShutdownAfterError()
{
	if( ddBackBuffer )
	{
		ddBackBuffer->Release();
		ddBackBuffer = NULL;
	}
	if( ddFrontBuffer )
	{
		ddFrontBuffer->Release();
		ddFrontBuffer = NULL;
	}
	if( Window->hWnd )
	{
		DestroyWindow( Window->hWnd );
	}
	Super::ShutdownAfterError();
}

/*-----------------------------------------------------------------------------
	Command line.
-----------------------------------------------------------------------------*/

//
// Command line.
//
UBOOL UWindowsViewport::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(UWindowsViewport::Exec);
	if( UViewport::Exec( Cmd, Ar ) )
	{
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("EndFullscreen")) )
	{
		EndFullscreen();
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("ToggleFullscreen")) )
	{
		ToggleFullscreen();
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GetCurrentRes")) )
	{
		Ar.Logf( TEXT("%ix%i"), SizeX, SizeY, (ColorBytes?ColorBytes:2)*8 );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GetCurrentColorDepth")) )
	{
		Ar.Logf( TEXT("%i"), (ColorBytes?ColorBytes:2)*8 );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GetColorDepths")) )
	{
		Ar.Log( TEXT("16 32") );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GetCurrentRenderDevice")) )
	{
		Ar.Log( RenDev->GetClass()->GetPathName() );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GetRes")) )
	{
		if( BlitFlags & BLIT_DirectDraw )
		{
			// DirectDraw modes.
			FString Result;
			for( INT i=0; i<GetOuterUWindowsClient()->DirectDrawModes[ColorBytes].Num(); i++ )
				Result += FString::Printf( TEXT("%ix%i "), (INT)GetOuterUWindowsClient()->DirectDrawModes[ColorBytes](i).X, (INT)GetOuterUWindowsClient()->DirectDrawModes[ColorBytes](i).Y );
			if( Result.Right(1)==TEXT(" ") )
				Result = Result.LeftChop(1);
			Ar.Log( *Result );
		}
		else if( BlitFlags & BLIT_DibSection )
		{
			// Windowed mode.
			Ar.Log( TEXT("320x240 400x300 512x384 640x480 800x600") );
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("SetRes")) )
	{
		INT X=appAtoi(Cmd);
		TCHAR* CmdTemp = appStrchr(Cmd,'x') ? appStrchr(Cmd,'x')+1 : appStrchr(Cmd,'X') ? appStrchr(Cmd,'X')+1 : TEXT("");
		INT Y=appAtoi(CmdTemp);
		Cmd = CmdTemp;
		CmdTemp = appStrchr(Cmd,'x') ? appStrchr(Cmd,'x')+1 : appStrchr(Cmd,'X') ? appStrchr(Cmd,'X')+1 : TEXT("");
		INT C=appAtoi(CmdTemp);
		INT NewColorBytes = C ? C/8 : ColorBytes;
		if( X && Y )
		{
			HoldCount++;
			UBOOL Result = RenDev->SetRes( X, Y, NewColorBytes, IsFullscreen() );
			HoldCount--;
			if( !Result )
				EndFullscreen();
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("Preferences")) )
	{
		UWindowsClient* Client = GetOuterUWindowsClient();
		Client->ConfigReturnFullscreen = 0;
		if( BlitFlags & BLIT_Fullscreen )
		{
			EndFullscreen();
			Client->ConfigReturnFullscreen = 1;
		}
		if( !Client->ConfigProperties )
		{
			Client->ConfigProperties = new WConfigProperties( TEXT("Preferences"), LocalizeGeneral("AdvancedOptionsTitle",TEXT("Window")) );
			Client->ConfigProperties->SetNotifyHook( Client );
			Client->ConfigProperties->OpenWindow( Window->hWnd );
			Client->ConfigProperties->ForceRefresh();
		}
		GetOuterUWindowsClient()->ConfigProperties->Show(1);
		SetFocus( *GetOuterUWindowsClient()->ConfigProperties );
		return 1;
	}
	else return 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	Window openining and closing.
-----------------------------------------------------------------------------*/

//
// Open this viewport's window.
//
void UWindowsViewport::OpenWindow( DWORD InParentWindow, UBOOL IsTemporary, INT NewX, INT NewY, INT OpenX, INT OpenY )
{
	guard(UWindowsViewport::OpenWindow);
	check(Actor);
	check(!HoldCount);
	UBOOL DoRepaint=0, DoSetActive=0;
	UWindowsClient* C = GetOuterUWindowsClient();
	if( NewX!=INDEX_NONE )
		NewX = Align( NewX, 2 );

	// User window of launcher if no parent window was specified.
	if( !InParentWindow )
		Parse( appCmdLine(), TEXT("HWND="), InParentWindow );

	// Create frame buffer.
	if( IsTemporary )
	{
		// Create in-memory data.
		BlitFlags     = BLIT_Temporary;
		ColorBytes    = 2;
		SizeX         = NewX;
		SizeY         = NewY;
		ScreenPointer = (BYTE*)appMalloc( 2 * NewX * NewY, TEXT("TemporaryViewportData") );	
		Window->hWnd  = NULL;
		debugf( NAME_Log, TEXT("Opened temporary viewport") );
   	}
	else
	{
		// Figure out physical window size we must specify to get appropriate client area.
		FRect rTemp( 100, 100, (NewX!=INDEX_NONE?NewX:C->WindowedViewportX) + 100, (NewY!=INDEX_NONE?NewY:C->WindowedViewportY) + 100 );

		// Get style and proper rectangle.
		DWORD Style;
		if( InParentWindow && (Actor->ShowFlags & SHOW_ChildWindow) )
		{
			Style = WS_VISIBLE | WS_CHILD | WS_CLIPSIBLINGS;
   			AdjustWindowRect( rTemp, Style, 0 );
		}
		else
		{
			Style = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_THICKFRAME;
   			AdjustWindowRect( rTemp, Style, (Actor->ShowFlags & SHOW_Menu) ? TRUE : FALSE );
		}

		// Set position and size.
		if( OpenX==-1 )
			OpenX = CW_USEDEFAULT;
		if( OpenY==-1 )
			OpenY = CW_USEDEFAULT;
		INT OpenXL = rTemp.Width();
		INT OpenYL = rTemp.Height();

		// Create or update the window.
		if( !Window->hWnd )
		{
			// Creating new viewport.
			ParentWindow = (HWND)InParentWindow;
			hMenu = (Actor->ShowFlags & SHOW_Menu) ? LoadLocalizedMenu( hInstance, IDMENU_EditorCam, TEXT("IDMENU_EditorCam") ) : NULL;
			if( ParentWindow && (Actor->ShowFlags & SHOW_ChildWindow) )
				DeleteMenu( hMenu, ID_ViewTop, MF_BYCOMMAND );

			// Open the physical window.
			Window->PerformCreateWindowEx
			(
				WS_EX_APPWINDOW,
				TEXT(""),
				Style,
				OpenX, OpenY,
				OpenXL, OpenYL,
				ParentWindow,
				hMenu,
				hInstance
			);

			// Set parent window.
			if( ParentWindow && (Actor->ShowFlags & SHOW_ChildWindow) )
			{
				// Force this to be a child.
				SetWindowLongX( Window->hWnd, GWL_STYLE, WS_VISIBLE | WS_POPUP );
				if( Actor->ShowFlags & SHOW_Menu )
					SetMenu( Window->hWnd, hMenu );
			}
			debugf( NAME_Log, TEXT("Opened viewport") );
			DoSetActive = DoRepaint = 1;

			// Init DirectInput Keyboard/Mouse for this viewport
			if( GetOuterUWindowsClient()->di )
			{
				if( !diSetupKeyboardMouse() )
				{
					diShutdownKeyboardMouse();
					GetOuterUWindowsClient()->diShutdown();
				}
			}
		}
		else
		{
			// Resizing existing viewport.
			//!!only needed for old vb code
			SetWindowPos( Window->hWnd, NULL, OpenX, OpenY, OpenXL, OpenYL, SWP_NOACTIVATE );
		}
		ShowWindow( Window->hWnd, SW_SHOWNOACTIVATE );
		FindAvailableModes();		
		if( DoRepaint )
			UpdateWindow( Window->hWnd );
	}

	// Create rendering device.
	if( !RenDev && (BlitFlags & BLIT_Temporary) )
		TryRenderDevice( TEXT("SoftDrv.SoftwareRenderDevice"), NewX, NewY, ColorBytes, 0 );
	if( !RenDev && !GIsEditor && !ParseParam(appCmdLine(),TEXT("nohard")) )
		TryRenderDevice( TEXT("ini:Engine.Engine.GameRenderDevice"), NewX, NewY, INDEX_NONE, C->StartupFullscreen );
	if( !RenDev && !GIsEditor && GetOuterUWindowsClient()->StartupFullscreen )
		TryRenderDevice( TEXT("ini:Engine.Engine.WindowedRenderDevice"), NewX, NewY, INDEX_NONE, 1 );
	if( !RenDev )
		TryRenderDevice( TEXT("ini:Engine.Engine.WindowedRenderDevice"), NewX, NewY, INDEX_NONE, 0 );
	check(RenDev);
	UpdateWindowFrame();
	if( DoRepaint )
		Repaint( 1 );
	if( DoSetActive )
		SetActiveWindow( Window->hWnd );

	unguard;
}

//
// Close a viewport window.  Assumes that the viewport has been openened with
// OpenViewportWindow.  Does not affect the viewport's object, only the
// platform-specific information associated with it.
//
void UWindowsViewport::CloseWindow()
{
	guard(UWindowsViewport::CloseWindow);
	if( Window->hWnd && Status==WIN_ViewportNormal )
	{
		Status = WIN_ViewportClosing;
		DestroyWindow( Window->hWnd );
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	UWindowsViewport operations.
-----------------------------------------------------------------------------*/

//
// Find all available DirectDraw modes for a certain number of color bytes.
//
void UWindowsViewport::FindAvailableModes()
{
	guard(UWindowsViewport::FindAvailableModes);

	// Make sure we have a menu.
	if( !Window->hWnd )
		return;
	HMENU hMenu = GetMenu(Window->hWnd);
	if( !hMenu )
		return;

	// Get menus.
	INT nMenu = GIsEditor ? 3 : 2;
	HMENU hSizes = GetSubMenu( hMenu, nMenu );
	check(hSizes);

	// Completely rebuild the "Size" submenu based on what modes are available.
	while( GetMenuItemCount( hSizes ) )
		if( !DeleteMenu( hSizes, 0, MF_BYPOSITION ) )
			appErrorf( TEXT("DeleteMenu failed: %s"), appGetSystemErrorMessage() );

	// Add color depth items.
	AppendMenuX( hSizes, MF_STRING, ID_Color16Bit, LocalizeGeneral("Color16") );
	AppendMenuX( hSizes, MF_STRING, ID_Color32Bit, LocalizeGeneral("Color32") );

	// Add resolution items.
	if( !(Actor->ShowFlags & SHOW_ChildWindow) )
	{
		// Windows resolution items.
		AppendMenuX( hSizes, MF_SEPARATOR, 0, NULL );
		AppendMenuX( hSizes, MF_STRING, ID_Win320, TEXT("320x240") );
		AppendMenuX( hSizes, MF_STRING, ID_Win400, TEXT("400x300") );
		AppendMenuX( hSizes, MF_STRING, ID_Win512, TEXT("512x384") );
		AppendMenuX( hSizes, MF_STRING, ID_Win640, TEXT("640x480") );
		AppendMenuX( hSizes, MF_STRING, ID_Win800, TEXT("800x600") );

		// DirectDraw resolution items.
		if( GetOuterUWindowsClient()->DirectDrawModes[ColorBytes].Num() )
		{
			AppendMenuX( hSizes, MF_SEPARATOR, 0, NULL );
			for( INT i=0; i<GetOuterUWindowsClient()->DirectDrawModes[ColorBytes].Num(); i++ )
			{
				TCHAR Text[256];
				appSprintf( Text, TEXT("Fullscreen %ix%i"), (INT)GetOuterUWindowsClient()->DirectDrawModes[ColorBytes](i).X, (INT)GetOuterUWindowsClient()->DirectDrawModes[ColorBytes](i).Y );
				if( !AppendMenuX( hSizes, MF_STRING, ID_DDMode0+i, Text ) ) 
					appErrorf( TEXT("AppendMenu failed: %s"), appGetSystemErrorMessage() );
			}
		}
		DrawMenuBar( Window->hWnd );
	}
	unguard;
}

//
// Set window position according to menu's on-top setting:
//
void UWindowsViewport::SetTopness()
{
	guard(UWindowsViewport::SetTopness);
	HWND Topness = HWND_NOTOPMOST;
	if( GetMenu(Window->hWnd) && GetMenuState(GetMenu(Window->hWnd),ID_ViewTop,MF_BYCOMMAND)&MF_CHECKED )
		Topness = HWND_TOPMOST;
	SetWindowPos( Window->hWnd, Topness, 0, 0, 0, 0, SWP_NOMOVE|SWP_NOSIZE|SWP_SHOWWINDOW|SWP_NOACTIVATE );
	unguard;
}

//
// Repaint the viewport.
//
void UWindowsViewport::Repaint( UBOOL Blit )
{
	guard(UWindowsViewport::Repaint);
	GetOuterUWindowsClient()->Engine->Draw( this, Blit );
	unguard;
}

//
// Return whether fullscreen.
//
UBOOL UWindowsViewport::IsFullscreen()
{
	guard(UWindowsViewport::IsFullscreen);
	return (BlitFlags & BLIT_Fullscreen)!=0;
	unguard;
}

//
// Set the mouse cursor according to Unreal or UnrealEd's mode, or to
// an hourglass if a slow task is active.
//
void UWindowsViewport::SetModeCursor()
{
	guard(UWindowsViewport::SetModeCursor);
	enum EEditorMode
	{
		EM_None 			= 0,
		EM_ViewportMove		= 1,
		EM_ViewportZoom		= 2,
		EM_BrushRotate		= 5,
		EM_BrushSheer		= 6,
		EM_BrushScale		= 7,
		EM_BrushStretch		= 8,
		EM_TexturePan		= 11,
		EM_TextureRotate	= 13,
		EM_TextureScale		= 14,
		EM_BrushSnap		= 18,
		EM_TexView			= 19,
		EM_TexBrowser		= 20,
		EM_MeshView			= 21,
	};
	if( GIsSlowTask )
	{
		SetCursor(LoadCursorIdX(NULL,IDC_WAIT));
		return;
	}
	HCURSOR hCursor;
	switch( GetOuterUWindowsClient()->Engine->edcamMode(this) )
	{
		case EM_ViewportZoom:	hCursor = LoadCursorIdX(hInstance,IDCURSOR_CameraZoom); break;
		case EM_BrushRotate:	hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushRot); break;
		case EM_BrushSheer:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushSheer); break;
		case EM_BrushScale:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushScale); break;
		case EM_BrushStretch:	hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushStretch); break;
		case EM_BrushSnap:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushSnap); break;
		case EM_TexturePan:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_TexPan); break;
		case EM_TextureRotate:	hCursor = LoadCursorIdX(hInstance,IDCURSOR_TexRot); break;
		case EM_TextureScale:	hCursor = LoadCursorIdX(hInstance,IDCURSOR_TexScale); break;
		case EM_None: 			hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		case EM_ViewportMove: 	hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		case EM_TexView:		hCursor = LoadCursorIdX(NULL,IDC_ARROW); break;
		case EM_TexBrowser:		hCursor = LoadCursorIdX(NULL,IDC_ARROW); break;
		case EM_MeshView:		hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		default: 				hCursor = LoadCursorIdX(NULL,IDC_ARROW); break;
	}
	check(hCursor);
	SetCursor( hCursor );
	unguard;
}

//
// Update user viewport interface.
//
void UWindowsViewport::UpdateWindowFrame()
{
	guard(UWindowsViewport::UpdateWindowFrame);

	// If not a window, exit.
	if( HoldCount || !Window->hWnd || (BlitFlags&BLIT_Fullscreen) || (BlitFlags&BLIT_Temporary) )
		return;

	// Set viewport window's name to show resolution.
	TCHAR WindowName[80];
	if( !GIsEditor || (Actor->ShowFlags&SHOW_PlayerCtrl) )
	{
		appSprintf( WindowName, LocalizeGeneral("Product",appPackage()) );
	}
	else switch( Actor->RendMap )
	{
		case REN_Wire:		appStrcpy(WindowName,LocalizeGeneral("ViewPersp")); break;
		case REN_OrthXY:	appStrcpy(WindowName,LocalizeGeneral("ViewXY"   )); break;
		case REN_OrthXZ:	appStrcpy(WindowName,LocalizeGeneral("ViewXZ"   )); break;
		case REN_OrthYZ:	appStrcpy(WindowName,LocalizeGeneral("ViewYZ"   )); break;
		default:			appStrcpy(WindowName,LocalizeGeneral("ViewOther")); break;
	}
	Window->SetText( WindowName );

	// Set the menu.
	if( (Actor->ShowFlags & SHOW_Menu) && !(BlitFlags & BLIT_Fullscreen) )
	{
		if( !hMenu )
			hMenu = LoadLocalizedMenu( hInstance, IDMENU_EditorCam, TEXT("IDMENU_EditorCam") );
		UBOOL MustUpdate = !GetMenu(Window->hWnd);
		SetMenu( Window->hWnd, hMenu );
		if( MustUpdate )
			FindAvailableModes();
	}
	else SetMenu( Window->hWnd, NULL );

	// Update menu, Map rendering.
	CheckMenuItem(hMenu,ID_MapPlainTex,  (Actor->RendMap==REN_PlainTex  ? MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_MapDynLight,  (Actor->RendMap==REN_DynLight  ? MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_MapWire,      (Actor->RendMap==REN_Wire      ? MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_MapOverhead,  (Actor->RendMap==REN_OrthXY    ? MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_MapXZ, 		 (Actor->RendMap==REN_OrthXZ    ? MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_MapYZ, 		 (Actor->RendMap==REN_OrthYZ    ? MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_MapPolys,     (Actor->RendMap==REN_Polys     ? MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_MapPolyCuts,  (Actor->RendMap==REN_PolyCuts  ? MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_MapZones,     (Actor->RendMap==REN_Zones     ? MF_CHECKED:MF_UNCHECKED));

	// Show-attributes.
	CheckMenuItem(hMenu,ID_ShowBrush,     ((Actor->ShowFlags&SHOW_Brush			)?MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_ShowBackdrop,  ((Actor->ShowFlags&SHOW_Backdrop  		)?MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_ShowCoords,    ((Actor->ShowFlags&SHOW_Coords    		)?MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_ShowMovingBrushes,((Actor->ShowFlags&SHOW_MovingBrushes)?MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_ShowPaths,     ((Actor->ShowFlags&SHOW_Paths)?MF_CHECKED:MF_UNCHECKED));

	// Actor showing.
	CheckMenuItem(hMenu,ID_ActorsIcons,  MF_UNCHECKED);
	CheckMenuItem(hMenu,ID_ActorsRadii,  MF_UNCHECKED);
	CheckMenuItem(hMenu,ID_ActorsShow,   MF_UNCHECKED);
	CheckMenuItem(hMenu,ID_ActorsHide,   MF_UNCHECKED);

	// Actor options.
	DWORD ShowFilter = Actor->ShowFlags & (SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii);
	if		(ShowFilter==(SHOW_Actors | SHOW_ActorIcons)) CheckMenuItem(hMenu,ID_ActorsIcons,MF_CHECKED);
	else if (ShowFilter==(SHOW_Actors | SHOW_ActorRadii)) CheckMenuItem(hMenu,ID_ActorsRadii,MF_CHECKED);
	else if (ShowFilter==(SHOW_Actors                  )) CheckMenuItem(hMenu,ID_ActorsShow,MF_CHECKED);
	else CheckMenuItem(hMenu,ID_ActorsHide,MF_CHECKED);

	// Color depth.
	CheckMenuItem(hMenu,ID_Color16Bit,((ColorBytes==2)?MF_CHECKED:MF_UNCHECKED));
	CheckMenuItem(hMenu,ID_Color32Bit,((ColorBytes==4)?MF_CHECKED:MF_UNCHECKED));

	// Update parent window.
	if( ParentWindow )
		SendMessageX( ParentWindow, WM_CHAR, 0, 0 );

	unguard;
}

//
// Return the viewport's window.
//
void* UWindowsViewport::GetWindow()
{
	guard(UWindowsViewport::GetWindow);
	return Window->hWnd;
	unguard;
}

/*-----------------------------------------------------------------------------
	Input.
-----------------------------------------------------------------------------*/

//
// Input event router.
//
UBOOL UWindowsViewport::CauseInputEvent( INT iKey, EInputAction Action, FLOAT Delta )
{
	guard(UWindowsViewport::CauseInputEvent);

	// Route to engine if a valid key; some keyboards produce key
	// codes that go beyond IK_MAX.
	if( iKey>=0 && iKey<IK_MAX )
		return GetOuterUWindowsClient()->Engine->InputEvent( this, (EInputKey)iKey, Action, Delta );
	else
		return 0;

	unguard;
}

//
// If the cursor is currently being captured, stop capturing, clipping, and 
// hiding it, and move its position back to where it was when it was initially
// captured.
//
void UWindowsViewport::SetMouseCapture( UBOOL Capture, UBOOL Clip, UBOOL OnlyFocus )
{
	guard(UWindowsViewport::SetMouseCapture);

	bWindowsMouseAvailable = !Capture;

	// If only handling focus windows, exit out.
	if( OnlyFocus )
		if( Window->hWnd != GetFocus() )
			return;

	// If capturing, windows requires clipping in order to keep focus.
	Clip |= Capture;

	// Get window rectangle.
	RECT TempRect;
	::GetClientRect( Window->hWnd, &TempRect );
	MapWindowPoints( Window->hWnd, NULL, (POINT*)&TempRect, 2 );

	// Handle capturing.
	if( Capture )
	{
		// Acquire the mouse for DirectInput
		if( diMouse )
		{
			// Bring window to foreground.
			SetForegroundWindow( Window->hWnd );
			ShowCursor( FALSE );

			AcquireDIMouse(1);
		}
		else
		{
			if( SavedCursor.x == -1 )
			{
				// Bring window to foreground.
				SetForegroundWindow( Window->hWnd );

				// Confine cursor to window.
				::GetCursorPos( &SavedCursor );
				SetCursorPos( (TempRect.left+TempRect.right)/2, (TempRect.top+TempRect.bottom)/2 );

				// Start capturing cursor.
				SetCapture( Window->hWnd );
				SystemParametersInfoX( SPI_SETMOUSE, 0, GetOuterUWindowsClient()->CaptureMouseInfo, 0 );
				ShowCursor( FALSE );
			}
		}
	}
	else
	{
		// Release the mouse from DirectInput
		if( diMouse )
		{
			AcquireDIMouse(0);
			while( ShowCursor(TRUE)<0 );
		}
		else
		{
			// Release captured cursor.
			if( !(BlitFlags & BLIT_Fullscreen) )
			{
				SetCapture( NULL );
				SystemParametersInfoX( SPI_SETMOUSE, 0, GetOuterUWindowsClient()->NormalMouseInfo, 0 );
			}

			// Restore position.
			if( SavedCursor.x != -1 )
			{
				SetCursorPos( SavedCursor.x, SavedCursor.y );
				SavedCursor.x = -1;
				while( ShowCursor(TRUE)<0 );
			}
		}
	}

	// Handle clipping.
	ClipCursor( Clip ? &TempRect : NULL );

	unguard;
}

//
// Update input for viewport.
//
UBOOL UWindowsViewport::JoystickInputEvent( FLOAT Delta, EInputKey Key, FLOAT Scale, UBOOL DeadZone )
{
	guard(UWindowsViewport::JoystickInputEvent);
	Delta = (Delta-32768.0)/32768.0;
	if( DeadZone )
	{
		if( Delta > 0.2 )
			Delta = (Delta - 0.2) / 0.8;
		else if( Delta < -0.2 )
			Delta = (Delta + 0.2) / 0.8;
		else
			Delta = 0.0;
	}
	return CauseInputEvent( Key, IST_Axis, Scale * Delta );
	unguard;
}

//
// Update input for this viewport.
//
void UWindowsViewport::UpdateInput( UBOOL Reset )
{
	guard(UWindowsViewport::UpdateInput);
	BYTE Processed[256];
	appMemset( Processed, 0, 256 );
	//debugf(TEXT("%i"),(INT)GTempDouble);

	// Joystick.
	UWindowsClient* Client = GetOuterUWindowsClient();
	if( Client->JoyCaps.wNumButtons )
	{
		JOYINFOEX JoyInfo;
		appMemzero( &JoyInfo, sizeof(JoyInfo) );
		JoyInfo.dwSize  = sizeof(JoyInfo);
		JoyInfo.dwFlags = JOY_RETURNBUTTONS | JOY_RETURNCENTERED | JOY_RETURNPOV | JOY_RETURNR | JOY_RETURNU | JOY_RETURNV | JOY_RETURNX | JOY_RETURNY | JOY_RETURNZ;
		MMRESULT Result = joyGetPosEx( JOYSTICKID1, &JoyInfo );
		if( Result==JOYERR_NOERROR )
		{ 
			// Pass buttons to app.
			INT Index=0;
			for( Index=0; JoyInfo.dwButtons; Index++,JoyInfo.dwButtons/=2 )
			{
				if( !Input->KeyDown(Index) && (JoyInfo.dwButtons & 1) )
					CauseInputEvent( IK_Joy1+Index, IST_Press );
				else if( Input->KeyDown(Index) && !(JoyInfo.dwButtons & 1) )
					CauseInputEvent( IK_Joy1+Index, IST_Release );
				Processed[IK_Joy1+Index] = 1;
			}

			// Pass axes to app.
			JoystickInputEvent( JoyInfo.dwXpos, IK_JoyX, Client->ScaleXYZ, Client->DeadZoneXYZ );
			JoystickInputEvent( JoyInfo.dwYpos, IK_JoyY, Client->ScaleXYZ * (Client->InvertVertical ? 1.0 : -1.0), Client->DeadZoneXYZ );
			if( Client->JoyCaps.wCaps & JOYCAPS_HASZ )
				JoystickInputEvent( JoyInfo.dwZpos, IK_JoyZ, Client->ScaleXYZ, Client->DeadZoneXYZ );
			if( Client->JoyCaps.wCaps & JOYCAPS_HASR )
				JoystickInputEvent( JoyInfo.dwRpos, IK_JoyR, Client->ScaleRUV, Client->DeadZoneRUV );
			if( Client->JoyCaps.wCaps & JOYCAPS_HASU )
				JoystickInputEvent( JoyInfo.dwUpos, IK_JoyU, Client->ScaleRUV, Client->DeadZoneRUV );
			if( Client->JoyCaps.wCaps & JOYCAPS_HASV )
				JoystickInputEvent( JoyInfo.dwVpos, IK_JoyV, Client->ScaleRUV * (Client->InvertVertical ? 1.0 : -1.0), Client->DeadZoneRUV );
			if( Client->JoyCaps.wCaps & (JOYCAPS_POV4DIR|JOYCAPS_POVCTS) )
			{
				if( JoyInfo.dwPOV==JOY_POVFORWARD )
				{
					if( !Input->KeyDown(IK_JoyPovUp) )
						CauseInputEvent( IK_JoyPovUp, IST_Press );
					Processed[IK_JoyPovUp] = 1;
				}
				else if( JoyInfo.dwPOV==JOY_POVBACKWARD )
				{
					if( !Input->KeyDown(IK_JoyPovDown) )
						CauseInputEvent( IK_JoyPovDown, IST_Press );
					Processed[IK_JoyPovDown] = 1;
				}
				else if( JoyInfo.dwPOV==JOY_POVLEFT )
				{
					if( !Input->KeyDown(IK_JoyPovLeft) )
						CauseInputEvent( IK_JoyPovLeft, IST_Press );
					Processed[IK_JoyPovLeft] = 1;
				}
				else if( JoyInfo.dwPOV==JOY_POVRIGHT )
				{
					if( !Input->KeyDown(IK_JoyPovRight) )
						CauseInputEvent( IK_JoyPovRight, IST_Press );
					Processed[IK_JoyPovRight] = 1;
				}
			}
		}
		/*else
		{
			// Some joysticks sometimes fail reading.
			debugf( TEXT("Joystick read failed") );
			Client->JoyCaps.wNumButtons = 0;
		}*/
	}

	// DirectInput mouse
	if( diMouse && AcquiredDIMouse )
	{
		HRESULT Result;
		INT DX, DY, DZ, LDown, RDown, MDown;

		Result = diMouse->GetDeviceState(sizeof(diMouseState), &diMouseState);
		if(Result == DIERR_INPUTLOST)
		{
			AcquireDIMouse(1);
			Result = diMouse->GetDeviceState(sizeof(diMouseState), &diMouseState);
		}
		
		if(Result != DI_OK)
			debugf( NAME_Init, TEXT("GetDeviceState Failed: %s"), diError(Result) );
	
		DX = diMouseState.lX - diOldMouseX;
		DY = diMouseState.lY - diOldMouseY;
		DZ = diMouseState.lZ - diOldMouseZ;

        diOldMouseX = diMouseState.lX;
		diOldMouseY = diMouseState.lY;
		diOldMouseZ = diMouseState.lZ;

		// Mouse wheel
		if( DX ) CauseInputEvent( IK_MouseX, IST_Axis, +DX );
		if( DY ) CauseInputEvent( IK_MouseY, IST_Axis, -DY );
		if( DZ < 0)
		{
			CauseInputEvent( IK_MouseWheelDown, IST_Press );
			CauseInputEvent( IK_MouseWheelDown, IST_Release );
		}
		else
		if( DZ > 0)
		{
			CauseInputEvent( IK_MouseWheelUp, IST_Press );
			CauseInputEvent( IK_MouseWheelUp, IST_Release );
		}

		// Buffered mouse clicks
		DWORD dwItems = 100; 
		Result = diMouse->GetDeviceData( sizeof(DIDEVICEOBJECTDATA), diMouseBuffer, &dwItems, 0); 

		LDown = diLMouseDown;
		RDown = diRMouseDown;
		MDown = diMMouseDown;

		for(INT i=0;i<(INT)dwItems;i++)
		{
			if(diMouseBuffer[i].dwOfs == DIMOFS_BUTTON0)
				LDown = diMouseBuffer[i].dwData & 0x80;
			if(diMouseBuffer[i].dwOfs == DIMOFS_BUTTON1)
				RDown = diMouseBuffer[i].dwData & 0x80;
			if(diMouseBuffer[i].dwOfs == DIMOFS_BUTTON2)
				MDown = diMouseBuffer[i].dwData & 0x80;

			if(LDown && !diLMouseDown)
			{
				CauseInputEvent( IK_LeftMouse, IST_Press );
				diLMouseDown = LDown;
			}
			else
			if(!LDown && diLMouseDown)
			{
				CauseInputEvent( IK_LeftMouse, IST_Release );
				diLMouseDown = LDown;
			}
						
			if(RDown && !diRMouseDown)
			{
				CauseInputEvent( IK_RightMouse, IST_Press );
				diRMouseDown = RDown;
			}
			else
			if(!RDown && diRMouseDown)
			{
				CauseInputEvent( IK_RightMouse, IST_Release );
				diRMouseDown = RDown;
			}
							
			if(MDown && !diMMouseDown)
			{
				CauseInputEvent( IK_MiddleMouse, IST_Press );
				diMMouseDown = MDown;
			}
			else
			if(!MDown && diMMouseDown)
			{
				CauseInputEvent( IK_MiddleMouse, IST_Release );
				diMMouseDown = MDown;
			}
		}
		Processed[IK_LeftMouse] = 1;
		Processed[IK_RightMouse] = 1;
		Processed[IK_MiddleMouse] = 1;
	}

	// Keyboard.
	Reset = Reset && GetFocus()==Window->hWnd;
	for( INT i=0; i<256; i++ )
	{
		if( !Processed[i] )
		{
			if( !Input->KeyDown(i) )
			{
				//old: if( Reset && (GetAsyncKeyState(i) & 0x8000) )
				if( Reset && (GetKeyState(i) & 0x8000) )
					CauseInputEvent( i, IST_Press );
			}
			else
			{
				//old: if( !(GetAsyncKeyState(i) & 0x8000) )
				if( !(GetKeyState(i) & 0x8000) )
					CauseInputEvent( i, IST_Release );
			}
		}
	}

	unguard;
}

void UWindowsViewport::AcquireDIMouse( UBOOL Capture )
{
	AcquiredDIMouse = Capture;

	if(Capture)
		diMouse->Acquire();
	else
		diMouse->Unacquire();
}

/*-----------------------------------------------------------------------------
	Viewport WndProc.
-----------------------------------------------------------------------------*/

//
// Main viewport window function.
//
LONG UWindowsViewport::ViewportWndProc( UINT iMessage, WPARAM wParam, LPARAM lParam )
{
	guard(UWindowsViewport::ViewportWndProc);
	UWindowsClient* Client = GetOuterUWindowsClient();
	if( HoldCount || Client->Viewports.FindItemIndex(this)==INDEX_NONE || !Actor )
		return DefWindowProcX( Window->hWnd, iMessage, wParam, lParam );

	// Statics.
	static UBOOL MovedSinceLeftClick=0;
	static UBOOL MovedSinceRightClick=0;
	static UBOOL MovedSinceMiddleClick=0;
	static DWORD StartTimeLeftClick=0;
	static DWORD StartTimeRightClick=0;
	static DWORD StartTimeMiddleClick=0;

	// Updates.
	if( iMessage==WindowMessageMouseWheel )
	{
		iMessage = WM_MOUSEWHEEL;
		wParam   = MAKEWPARAM(0,wParam);
	}

	// Message handler.
	switch( iMessage )
	{
		case WM_CREATE:
		{
			guard(WM_CREATE);

         	// Set status.
			Status = WIN_ViewportNormal; 

			// Make this viewport current and update its title bar.
			GetOuterUClient()->MakeCurrent( this );

			return 0;
			unguard;
		}
		case WM_HOTKEY:
		{
			return 0;
		}
		case WM_DESTROY:
		{
			guard(WM_DESTROY);

			// If there's an existing Viewport structure corresponding to
			// this window, deactivate it.
			if( BlitFlags & BLIT_Fullscreen )
				EndFullscreen();

			// Free DIB section stuff (if any).
			if( hBitmap )
				DeleteObject( hBitmap );

			// Restore focus to caller if desired.
			DWORD ParentWindow=0;
			Parse( appCmdLine(), TEXT("HWND="), ParentWindow );
			if( ParentWindow )
			{
				::SetParent( Window->hWnd, NULL );
				SetFocus( (HWND)ParentWindow );
			}

			// Stop clipping.
			SetDrag( 0 );
			if( Status==WIN_ViewportNormal )
			{
				// Closed by user clicking on window's close button, so delete the viewport.
				Status = WIN_ViewportClosing; // Prevent recursion.
				delete this;
			}
			debugf( NAME_Log, TEXT("Closed viewport") );
			return 0;
			unguard;
		}
		case WM_PAINT:
		{
			guard(WM_PAINT);
			if( BlitFlags & (BLIT_Fullscreen|BLIT_Direct3D|BLIT_HardwarePaint) )
			{
				if( BlitFlags & BLIT_HardwarePaint )
					Repaint( 1 );
				ValidateRect( Window->hWnd, NULL );
				return 0;
			}
			else if( IsWindowVisible(Window->hWnd) && SizeX && SizeY && hBitmap )
			{
				PAINTSTRUCT ps;
				BeginPaint( Window->hWnd, &ps );
				HDC hDC = GetDC( Window->hWnd );
				if( hDC == NULL )
					appErrorf( TEXT("GetDC failed: %s"), appGetSystemErrorMessage() );
				if( SelectObject( Client->hMemScreenDC, hBitmap ) == NULL )
					appErrorf( TEXT("SelectObject failed: %s"), appGetSystemErrorMessage() );
				if( BitBlt( hDC, 0, 0, SizeX, SizeY, Client->hMemScreenDC, 0, 0, SRCCOPY ) == NULL )
					appErrorf( TEXT("BitBlt failed: %s"), appGetSystemErrorMessage() );
				if( ReleaseDC( Window->hWnd, hDC ) == NULL )
					appErrorf( TEXT("ReleaseDC failed: %s"), appGetSystemErrorMessage() );
				EndPaint( Window->hWnd, &ps );
				return 0;
			}
			else return 1;
			unguard;
		}
		case WM_COMMAND:
		{
			guard(WM_COMMAND);
      		switch( wParam )
			{
				case ID_MapDynLight:
				{
					Actor->RendMap=REN_DynLight;
					break;
				}
				case ID_MapPlainTex:
				{
					Actor->RendMap=REN_PlainTex;
					break;
				}
				case ID_MapWire:
				{
					Actor->RendMap=REN_Wire;
					break;
				}
				case ID_MapOverhead:
				{
					Actor->RendMap=REN_OrthXY;
					break;
				}
				case ID_MapXZ:
				{
					Actor->RendMap=REN_OrthXZ;
					break;
				}
				case ID_MapYZ:
				{
					Actor->RendMap=REN_OrthYZ;
					break;
				}
				case ID_MapPolys:
				{
					Actor->RendMap=REN_Polys;
					break;
				}
				case ID_MapPolyCuts:
				{
					Actor->RendMap=REN_PolyCuts;
					break;
				}
				case ID_MapZones:
				{
					Actor->RendMap=REN_Zones;
					break;
				}
				case ID_Win320:
				{
					RenDev->SetRes( 320, 240, ColorBytes, 0 );
					break;
				}
				case ID_Win400:
				{
					RenDev->SetRes( 400, 300, ColorBytes, 0 );
					break;
				}
				case ID_Win512:
				{
					RenDev->SetRes( 512, 384, ColorBytes, 0 );
					break;
				}
				case ID_Win640:
				{
					RenDev->SetRes( 640, 480, ColorBytes, 0 );
					break;
				}
				case ID_Win800:
				{
					RenDev->SetRes( 800, 600, ColorBytes, 0 );
					break;
				}
				case ID_Color16Bit:
				{
					RenDev->SetRes( SizeX, SizeY, 2, 0 );
					Repaint( 1 );
					FindAvailableModes();
					break;
				}
				case ID_Color32Bit:
				{
					RenDev->SetRes( SizeX, SizeY, 4, 0 );
					Repaint( 1 );
					FindAvailableModes();
					break;
				}
				case ID_ShowBackdrop:
				{
					Actor->ShowFlags ^= SHOW_Backdrop;
					break;
				}
				case ID_ActorsShow:
				{
					Actor->ShowFlags &= ~(SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii);
					Actor->ShowFlags |= SHOW_Actors; 
					break;
				}
				case ID_ActorsIcons:
				{
					Actor->ShowFlags &= ~(SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii); 
					Actor->ShowFlags |= SHOW_Actors | SHOW_ActorIcons;
					break;
				}
				case ID_ActorsRadii:
				{
					Actor->ShowFlags &= ~(SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii); 
					Actor->ShowFlags |= SHOW_Actors | SHOW_ActorRadii;
					break;
				}
				case ID_ActorsHide:
				{
					Actor->ShowFlags &= ~(SHOW_Actors | SHOW_ActorIcons | SHOW_ActorRadii); 
					break;
				}
				case ID_ShowPaths:
				{
					Actor->ShowFlags ^= SHOW_Paths;
					break;
				}
				case ID_ShowCoords:
				{
					Actor->ShowFlags ^= SHOW_Coords;
					break;
				}
				case ID_ShowBrush:
				{
					Actor->ShowFlags ^= SHOW_Brush;
					break;
				}
				case ID_ShowMovingBrushes:
				{
					Actor->ShowFlags ^= SHOW_MovingBrushes;
					break;
				}
				case ID_ViewLog:
				{
					Exec( TEXT("SHOWLOG"), *this );
					break;
				}
				case ID_FileExit:
				{
					DestroyWindow( Window->hWnd );
					return 0;
				}
				case ID_ViewTop:
				{
					ToggleMenuItem(GetMenu(Window->hWnd),ID_ViewTop);
					SetTopness();
					break;
				}
				case ID_ViewAdvanced:
				{
					Exec( TEXT("Preferences"), *GLog );
					break;
				}
				default:
				{
					if( wParam>=ID_DDMode0 && wParam<=ID_DDMode9 )
						ResizeViewport( BLIT_Fullscreen|BLIT_DirectDraw, Client->DirectDrawModes[ColorBytes](wParam-ID_DDMode0).X, Client->DirectDrawModes[ColorBytes](wParam-ID_DDMode0).Y );
					break;
				}
			}
			Repaint( 1 );
			UpdateWindowFrame();
			return 0;
			unguard;
		}
		case WM_KEYDOWN:
		case WM_SYSKEYDOWN:
		{
			guard(WM_KEYDOWN);

			// Get key code.
			EInputKey Key = (EInputKey)wParam;

			// Send key to input system.
			if( Key==IK_Enter && (GetKeyState(VK_MENU)&0x8000) )
			{
				ToggleFullscreen();
			}
			else if( CauseInputEvent( Key, IST_Press ) )
			{	
				// Redraw if the viewport won't be redrawn on timer.
				if( !IsRealtime() )
					Repaint( 1 );
			}

			// Send to UnrealEd.
			if( ParentWindow && GIsEditor )
			{
				if( Key==IK_F1 )
					PostMessageX( ParentWindow, iMessage, IK_F2, lParam );
				else if( Key!=IK_Tab && Key!=IK_Enter && Key!=IK_Alt )
					PostMessageX( ParentWindow, iMessage, wParam, lParam );
			}

			// Set the cursor.
			if( GIsEditor )
				SetModeCursor();

			return 0;
			unguard;
		}
		case WM_KEYUP:
		case WM_SYSKEYUP:
		{
			guard(WM_KEYUP);

			// Send to the input system.
			EInputKey Key = (EInputKey)wParam;
			if( CauseInputEvent( Key, IST_Release ) )
			{	
				// Redraw if the viewport won't be redrawn on timer.
				if( !IsRealtime() )
					Repaint( 1 );
			}

			// Pass keystroke on to UnrealEd.
			if( ParentWindow && GIsEditor )
			{				
				if( Key == IK_F1 )
					PostMessageX( ParentWindow, iMessage, IK_F2, lParam );
				else if( Key!=IK_Tab && Key!=IK_Enter && Key!=IK_Alt )
					PostMessageX( ParentWindow, iMessage, wParam, lParam );
			}
			if( GIsEditor )
				SetModeCursor();
			return 0;
			unguard;
		}
		case WM_SYSCHAR:
		case WM_CHAR:
		{
			guard(WM_CHAR);
			EInputKey Key = (EInputKey)wParam;
			if( Key!=IK_Enter && Client->Engine->Key( this, Key ) )
			{
				// Redraw if needed.
				if( !IsRealtime() )
					Repaint( 1 );
				
				if( GIsEditor )
					SetModeCursor();
			}
			else if( iMessage == WM_SYSCHAR )
			{
				// Perform default processing.
				return DefWindowProcX( Window->hWnd, iMessage, wParam, lParam );
			}
			return 0;
			unguard;
		}
		case WM_ERASEBKGND:
		{
			// Prevent Windows from repainting client background in white.
			return 0;
		}
		case WM_SETCURSOR:
		{
			guard(WM_SETCURSOR);
			if( (LOWORD(lParam)==1) || GIsSlowTask )
			{
				// In client area or processing slow task.
				if( GIsEditor )
					SetModeCursor();
				return 0;
			}
			else
			{
				// Out of client area.
				return DefWindowProcX( Window->hWnd, iMessage, wParam, lParam );
			}
			unguard;
		}
		case WM_LBUTTONDBLCLK:
		{
			if( SizeX && SizeY && !(BlitFlags&BLIT_Fullscreen) )
			{
				Client->Engine->Click( this, MOUSE_LeftDouble, LOWORD(lParam), HIWORD(lParam) );
				if( !IsRealtime() )
					Repaint( 1 );
			}
			return 0;
		}
		case WM_LBUTTONDOWN:
		case WM_RBUTTONDOWN:
		case WM_MBUTTONDOWN:
		{
			guard(WM_BUTTONDOWN);

			if( Client->InMenuLoop )
				return DefWindowProcX( Window->hWnd, iMessage, wParam, lParam );

			if( iMessage == WM_LBUTTONDOWN )
			{
				MovedSinceLeftClick = 0;
				StartTimeLeftClick = GetMessageTime();
				CauseInputEvent( IK_LeftMouse, IST_Press );
			}
			else if( iMessage == WM_RBUTTONDOWN )
			{
				MovedSinceRightClick = 0;
				StartTimeRightClick = GetMessageTime();
				CauseInputEvent( IK_RightMouse, IST_Press );
			}
			else if( iMessage == WM_MBUTTONDOWN )
			{
				MovedSinceMiddleClick = 0;
				StartTimeMiddleClick = GetMessageTime();
				CauseInputEvent( IK_MiddleMouse, IST_Press );
			}
			SetDrag( 1 );
			return 0;
			unguard;
		}
		case WM_MOUSEACTIVATE:
		{
			// Activate this window and send the mouse-down message.
			return MA_ACTIVATE;
		}
		case WM_ACTIVATE:
		{
			guard(WM_ACTIVATE);

			// If window is becoming inactive, release the cursor.
			if( wParam==0 )
				SetDrag( 0 );

			return 0;
			unguard;
		}
		case WM_LBUTTONUP:
		case WM_RBUTTONUP:
		case WM_MBUTTONUP:
		{
			guard(WM_BUTTONUP);

			// Exit if in menu loop.
			if( Client->InMenuLoop )
				return DefWindowProcX( Window->hWnd, iMessage, wParam, lParam );

			// Get mouse cursor position.
			POINT TempPoint={0,0};
			::ClientToScreen( Window->hWnd, &TempPoint );
			INT MouseX = SavedCursor.x!=-1 ? SavedCursor.x-TempPoint.x : LOWORD(lParam);
			INT MouseY = SavedCursor.x!=-1 ? SavedCursor.y-TempPoint.y : HIWORD(lParam);

			// Get time interval to determine if a click occured.
			INT DeltaTime, Button;
			EInputKey iKey;
			if( iMessage == WM_LBUTTONUP )
			{
				DeltaTime = GetMessageTime() - StartTimeLeftClick;
				iKey      = IK_LeftMouse;
				Button    = MOUSE_Left;
			}
			else if( iMessage == WM_MBUTTONUP )
			{
				DeltaTime = GetMessageTime() - StartTimeMiddleClick;
				iKey      = IK_MiddleMouse;
				Button    = MOUSE_Middle;
			}
			else
			{
				DeltaTime = GetMessageTime() - StartTimeRightClick;
				iKey      = IK_RightMouse;
				Button    = MOUSE_Right;
			}

			// Send to the input system.
			CauseInputEvent( iKey, IST_Release );

			// Release the cursor.
			if
			(	!Input->KeyDown(IK_LeftMouse)
			&&	!Input->KeyDown(IK_MiddleMouse)
			&&	!Input->KeyDown(IK_RightMouse) 
			&&	!(BlitFlags & BLIT_Fullscreen) )
                SetDrag( 0 );

			// Handle viewport clicking.
			if
			(	!(BlitFlags & BLIT_Fullscreen)
			&&	SizeX && SizeY 
			&&	!(MovedSinceLeftClick || MovedSinceRightClick || MovedSinceMiddleClick) )
			{
				Client->Engine->Click( this, Button, MouseX, MouseY );
				if( !IsRealtime() )
					Repaint( 1 );
			}

			// Update times.
			if		( iMessage == WM_LBUTTONUP ) MovedSinceLeftClick	= 0;
			else if	( iMessage == WM_RBUTTONUP ) MovedSinceRightClick	= 0;
			else if	( iMessage == WM_MBUTTONUP ) MovedSinceMiddleClick	= 0;

			return 0;
			unguard;
		}
		case WM_ENTERMENULOOP:
		{
			guard(WM_ENTERMENULOOP);
			Client->InMenuLoop = 1;
			SetDrag( 0 );
			UpdateWindowFrame();
			return 0;
			unguard;
		}
		case WM_EXITMENULOOP:
		{
			guard(WM_EXITMENULOOP);
			Client->InMenuLoop = 0;
			return 0;
			unguard;
		}
		case WM_CANCELMODE:
		{
			guard(WM_CANCELMODE);
			SetDrag( 0 );
			return 0;
			unguard;
		}
		case WM_MOUSEWHEEL:
		{
			guard(WM_MOUSEWHEEL);
			SWORD zDelta = HIWORD(wParam);
			if( zDelta )
			{
				CauseInputEvent( IK_MouseW, IST_Axis, zDelta );
				if( zDelta < 0 )
				{
					CauseInputEvent( IK_MouseWheelDown, IST_Press );
					CauseInputEvent( IK_MouseWheelDown, IST_Release );
				}
				else if( zDelta > 0 )
				{
					CauseInputEvent( IK_MouseWheelUp, IST_Press );
					CauseInputEvent( IK_MouseWheelUp, IST_Release );
				}
			}
			return 0;
			unguard;
		}
		case WM_MOUSEMOVE:
		{
			guard(WM_MOUSEMOVE);
			if( !diMouse || !AcquiredDIMouse )
			{
				//GTempDouble=GTempDouble+1;

				// If in a window, see if cursor has been captured; if not, ignore mouse movement.
				if( Client->InMenuLoop )
					break;

				// Get window rectangle.
				RECT TempRect;
				::GetClientRect( Window->hWnd, &TempRect );
				WORD Buttons = wParam & (MK_LBUTTON | MK_RBUTTON | MK_MBUTTON);

				// If cursor isn't captured, just do MousePosition.
				if( !(BlitFlags & BLIT_Fullscreen) && SavedCursor.x==-1 )
				{
					// Do mouse messaging.
					POINTS Point = MAKEPOINTS(lParam);
					DWORD ViewportButtonFlags = 0;
					if( Buttons & MK_LBUTTON     ) ViewportButtonFlags |= MOUSE_Left;
					if( Buttons & MK_RBUTTON     ) ViewportButtonFlags |= MOUSE_Right;
					if( Buttons & MK_MBUTTON     ) ViewportButtonFlags |= MOUSE_Middle;
					if( Input->KeyDown(IK_Shift) ) ViewportButtonFlags |= MOUSE_Shift;
					if( Input->KeyDown(IK_Ctrl ) ) ViewportButtonFlags |= MOUSE_Ctrl;
					if( Input->KeyDown(IK_Alt  ) ) ViewportButtonFlags |= MOUSE_Alt;
					Client->Engine->MousePosition( this, Buttons, Point.x-TempRect.left, Point.y-TempRect.top );
					if( bShowWindowsMouse && SelectedCursor >= 0 && SelectedCursor <= 6 )
						SetCursor( StandardCursors[SelectedCursor] );
					break;
				}

				// Get center of window.			
				POINT TempPoint, Base;
				TempPoint.x = (TempRect.left + TempRect.right )/2;
				TempPoint.y = (TempRect.top  + TempRect.bottom)/2;
				Base = TempPoint;

				// Movement accumulators.
				UBOOL Moved=0;
				INT Cumulative=0;

				// Grab all pending mouse movement.
				INT DX=0, DY=0;
				Loop:
				Buttons		  = wParam & (MK_LBUTTON | MK_RBUTTON | MK_MBUTTON);
				POINTS Points = MAKEPOINTS(lParam);
				INT X         = Points.x - Base.x;
				INT Y         = Points.y - Base.y;
				Cumulative += Abs(X) + Abs(Y);
				DX += X;
				DY += Y;

				// Process valid movement.
				DWORD ViewportButtonFlags = 0;
				if( Buttons & MK_LBUTTON     ) ViewportButtonFlags |= MOUSE_Left;
				if( Buttons & MK_RBUTTON     ) ViewportButtonFlags |= MOUSE_Right;
				if( Buttons & MK_MBUTTON     ) ViewportButtonFlags |= MOUSE_Middle;
				if( Input->KeyDown(IK_Shift) ) ViewportButtonFlags |= MOUSE_Shift;
				if( Input->KeyDown(IK_Ctrl ) ) ViewportButtonFlags |= MOUSE_Ctrl;
				if( Input->KeyDown(IK_Alt  ) ) ViewportButtonFlags |= MOUSE_Alt;

				// Move viewport with buttons.
				if( X || Y )
				{
					Moved = 1;
					Client->Engine->MouseDelta( this, ViewportButtonFlags, X, Y );
				}

				// Handle any more mouse moves.
				MSG Msg;
				if( PeekMessageX( &Msg, Window->hWnd, WM_MOUSEMOVE, WM_MOUSEMOVE, PM_REMOVE ) )
				{
					lParam = Msg.lParam;
					wParam = Msg.wParam;
					Base.x = Points.x;
					Base.y = Points.y;
					goto Loop;
				}

				// Set moved-flags.
				if( Cumulative>4 )
				{
					if( wParam & MK_LBUTTON ) MovedSinceLeftClick   = 1;
					if( wParam & MK_RBUTTON ) MovedSinceRightClick  = 1;
					if( wParam & MK_MBUTTON ) MovedSinceMiddleClick = 1;
				}

				// Send to input subsystem.
				if( DX ) CauseInputEvent( IK_MouseX, IST_Axis, +DX );
				if( DY ) CauseInputEvent( IK_MouseY, IST_Axis, -DY );

				// Put cursor back in middle of window.
				if( DX || DY )
				{
					::ClientToScreen( Window->hWnd, &TempPoint );
					SetCursorPos( TempPoint.x, TempPoint.y );
				}
				//else GTempDouble += 1000;

				// Viewport isn't realtime, so we must update the frame here and now.
				if( Moved && !IsRealtime() )
				{
					if( Input->KeyDown(IK_Space) )
						for( INT i=0; i<Client->Viewports.Num(); i++ )
							Client->Viewports(i)->Repaint( 1 );
					else
						Repaint( 1 );
				}

				// Dispatch keyboard events.
				while( PeekMessageX( &Msg, NULL, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE ) )
				{
					TranslateMessage( &Msg );
					DispatchMessageX( &Msg );
				}
			}
			else	
			{
				return DefWindowProcX( Window->hWnd, iMessage, wParam, lParam );
			}
			return 0;
			unguard;
		}
		case WM_SIZE:
		{
			guard(WM_SIZE);
			INT NewX = LOWORD(lParam);
			INT NewY = HIWORD(lParam);
			if( BlitFlags & BLIT_Fullscreen )
			{
				// Window forced out of fullscreen.
				if( wParam==SIZE_RESTORED )
				{
					HoldCount++;
					Window->MoveWindow( SavedWindowRect, 1 );
					HoldCount--;
				}
				return 0;
			}
			else if( wParam==SIZE_RESTORED && DirectDrawMinimized )
			{
				DirectDrawMinimized = 0;
				ToggleFullscreen();
				return 0;
			}
			else
			{
				// Use resized window.
				if( RenDev && (BlitFlags & (BLIT_OpenGL|BLIT_Direct3D)) )
				{
					RenDev->SetRes( NewX, NewY, ColorBytes, 0 );
				}
				else
				{
					ResizeViewport( BlitFlags|BLIT_NoWindowChange, NewX, NewY, ColorBytes );
				}
				if( GIsEditor )
					Repaint( 0 );
      			return 0;
        	}
			unguard;
		}
		case WM_KILLFOCUS:
		{
			guard(WM_KILLFOCUS);
			SetMouseCapture( 0, 0, 0 );
			if( GIsRunning )
				Exec( TEXT("SETPAUSE 1"), *this );
			SetDrag( 0 );
			Input->ResetInput();
			if( BlitFlags & BLIT_Fullscreen )
			{
				debugf(TEXT("WM_KILLFOCUS"));
				EndFullscreen();
				HoldCount++;
				ShowWindow( Window->hWnd, SW_SHOWMINNOACTIVE );
				HoldCount--;
				DirectDrawMinimized = 1;
			}
			if( diKeyboard )
				diKeyboard->Unacquire();

			GetOuterUClient()->MakeCurrent( NULL );
			return 0;
			unguard;
		}
		case WM_SETFOCUS:
		{
			guard(WM_SETFOCUS);

			// Reset viewport's input.
			Exec( TEXT("SETPAUSE 0"), *this );
			Input->ResetInput();

			if( diKeyboard )
				diKeyboard->Acquire();

			// Make this viewport current.
			GetOuterUClient()->MakeCurrent( this );
			SetModeCursor();
            return 0;
			unguard;
		}
		case WM_SYSCOMMAND:
		{
			guard(WM_SYSCOMMAND);
			DWORD nID = wParam & 0xFFF0;
			if( nID==SC_SCREENSAVE || nID==SC_MONITORPOWER )
			{
				// Return 1 to prevent screen saver.
				if( nID==SC_SCREENSAVE )
					debugf( NAME_Log, TEXT("Received SC_SCREENSAVE") );
				else
					debugf( NAME_Log, TEXT("Received SC_MONITORPOWER") );
				return 0;
			}
			else if( nID==SC_MAXIMIZE )
			{
				// Maximize.
				ToggleFullscreen();
				return 0;
			}
			else if
			(	(BlitFlags & BLIT_Fullscreen)
			&&	(nID==SC_NEXTWINDOW || nID==SC_PREVWINDOW || nID==SC_TASKLIST || nID==SC_HOTKEY) )
			{
				// Don't allow window changes here.
				return 0;
			}
			else return DefWindowProcX(Window->hWnd,iMessage,wParam,lParam);
			unguard;
		}
		case WM_POWER:
		{
			guard(WM_POWER);
			if( wParam )
			{
				if( wParam == PWR_SUSPENDREQUEST )
				{
					debugf( NAME_Log, TEXT("Received WM_POWER suspend") );

					// Prevent powerdown if dedicated server or using joystick.
					if( 1 )
						return PWR_FAIL;
					else
						return PWR_OK;
				}
				else
				{
					debugf( NAME_Log, TEXT("Received WM_POWER") );
					return DefWindowProcX( Window->hWnd, iMessage, wParam, lParam );
				}
			}
			return 0;
			unguard;
		}
		case WM_DISPLAYCHANGE:
		{
			guard(WM_DISPLAYCHANGE);
			debugf( NAME_Log, TEXT("Viewport %s: WM_DisplayChange"), GetName() );
			unguard;
			return 0;
		}
		case WM_WININICHANGE:
		{
			guard(WM_WININICHANGE);
			if( !DeleteDC(Client->hMemScreenDC) )
				appErrorf( TEXT("DeleteDC failed: %s"), appGetSystemErrorMessage() );
			Client->hMemScreenDC = CreateCompatibleDC (NULL);
			return 0;
			unguard;
		}
		default:
		{
			guard(WM_UNKNOWN);
			return DefWindowProcX( Window->hWnd, iMessage, wParam, lParam );
			unguard;
		}
	}
	unguard;
	return 0;
}
W_IMPLEMENT_CLASS(WWindowsViewportWindow)

/*-----------------------------------------------------------------------------
	DirectDraw support.
-----------------------------------------------------------------------------*/

//
// Set DirectDraw to a particular mode, with full error checking
// Returns 1 if success, 0 if failure.
//
UBOOL UWindowsViewport::ddSetMode( INT NewX, INT NewY, INT ColorBytes )
{
	guard(UWindowsViewport::ddSetMode);
	UWindowsClient* Client = GetOuterUWindowsClient();
	check(Client->dd);
	HRESULT	Result;

	// Set the display mode.
	debugf( NAME_Log, TEXT("Setting %ix%ix%i"), NewX, NewY, ColorBytes*8 );
	Result = Client->dd->SetDisplayMode( NewX, NewY, ColorBytes*8, 0, 0 );
	if( Result!=DD_OK )
	{
		debugf( NAME_Log, TEXT("DirectDraw Failed %ix%ix%i: %s"), NewX, NewY, ColorBytes*8, ddError(Result) );
		Result = Client->dd->SetCooperativeLevel( NULL, DDSCL_NORMAL );
   		return 0;
	}

	// Create surfaces.
	DDSURFACEDESC SurfaceDesc;
	appMemzero( &SurfaceDesc, sizeof(DDSURFACEDESC) );
	SurfaceDesc.dwSize = sizeof(DDSURFACEDESC);
	SurfaceDesc.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
	SurfaceDesc.ddsCaps.dwCaps
	=	DDSCAPS_PRIMARYSURFACE
	|	DDSCAPS_FLIP
	|	DDSCAPS_COMPLEX
	|	(Client->SlowVideoBuffering ? DDSCAPS_SYSTEMMEMORY : DDSCAPS_VIDEOMEMORY);

	// Create the best possible surface for rendering.
	TCHAR* Descr=NULL;
	if( 1 )
	{
		// Try triple-buffered video memory surface.
		SurfaceDesc.dwBackBufferCount = 2;
		Result = Client->dd->CreateSurface( &SurfaceDesc, &ddFrontBuffer, NULL );
		Descr  = TEXT("Triple buffer");
	}
	if( Result != DD_OK )
   	{
		// Try to get a double buffered video memory surface.
		SurfaceDesc.dwBackBufferCount = 1; 
		Result = Client->dd->CreateSurface( &SurfaceDesc, &ddFrontBuffer, NULL );
		Descr  = TEXT("Double buffer");
    }
	if( Result != DD_OK )
	{
		// Settle for a main memory surface.
		SurfaceDesc.ddsCaps.dwCaps &= ~DDSCAPS_VIDEOMEMORY;
		Result = Client->dd->CreateSurface( &SurfaceDesc, &ddFrontBuffer, NULL );
		Descr  = TEXT("System memory");
    }
	if( Result != DD_OK )
	{
		debugf( NAME_Log, TEXT("DirectDraw, no available modes %s"), ddError(Result) );
		Client->dd->RestoreDisplayMode();
		Client->dd->FlipToGDISurface();
	   	return 0;
	}
	debugf( NAME_Log, TEXT("DirectDraw: %s, %ix%i, Stride=%i"), Descr, NewX, NewY, SurfaceDesc.lPitch );
	debugf( NAME_Log, TEXT("DirectDraw: Rate=%i"), SurfaceDesc.dwRefreshRate );

	// Clear the screen.
	DDBLTFX ddbltfx;
	ddbltfx.dwSize = sizeof( ddbltfx );
	ddbltfx.dwFillColor = 0;
	ddFrontBuffer->Blt( NULL, NULL, NULL, DDBLT_COLORFILL, &ddbltfx );

	// Get a pointer to the back buffer.
	DDSCAPS caps;
	caps.dwCaps = DDSCAPS_BACKBUFFER;
	if( ddFrontBuffer->GetAttachedSurface( &caps, &ddBackBuffer )!=DD_OK )
	{
		debugf( NAME_Log, TEXT("DirectDraw GetAttachedSurface failed %s"), ddError(Result) );
		ddFrontBuffer->Release();
		ddFrontBuffer = NULL;
		Client->dd->RestoreDisplayMode();
		Client->dd->FlipToGDISurface();
		return 0;
	}

	// Get pixel format.
	DDPIXELFORMAT PixelFormat;
	PixelFormat.dwSize = sizeof(DDPIXELFORMAT);
	Result = ddFrontBuffer->GetPixelFormat( &PixelFormat );
	if( Result!=DD_OK )
	{
		debugf( TEXT("DirectDraw GetPixelFormat failed: %s"), ddError(Result) );
		ddBackBuffer->Release();
		ddBackBuffer = NULL;
		ddFrontBuffer->Release();
		ddFrontBuffer = NULL;
		Client->dd->RestoreDisplayMode();
		Client->dd->FlipToGDISurface();
		return 0;
	}

	// See if we're in a 16-bit color mode.
	Caps &= ~CC_RGB565;
	if( ColorBytes==2 && PixelFormat.dwRBitMask==0xf800 ) 
		Caps |= CC_RGB565;

	// Flush the cache.
	GCache.Flush();

	// Success.
	return 1;
	unguard;
}

/*-----------------------------------------------------------------------------
	DirectInput support.
-----------------------------------------------------------------------------*/
UBOOL UWindowsViewport::diSetupKeyboardMouse()
{
	guard(UWindowsViewport::diSetupKeyboardMouse());
	UWindowsClient* Client = GetOuterUWindowsClient();

	HRESULT Result;
	/*
	Result = Client->di->CreateDevice(GUID_SysKeyboard, &diKeyboard, NULL);  
	if( Result == DI_OK )
		Result = diKeyboard->SetDataFormat(&c_dfDIKeyboard);
	if( Result == DI_OK )
		Result = diKeyboard->SetCooperativeLevel(Window->hWnd, DISCL_FOREGROUND | DISCL_NONEXCLUSIVE); 

	if( Result != DI_OK )
	{
		debugf( NAME_Init, TEXT("DirectInput - failed to gain access to keyboard: %s"), diError(Result) );
		return 0;
	}*/
	
	Result = Client->di->CreateDevice(GUID_SysMouse, &diMouse, NULL);  
	if( Result == DI_OK )
	{
		diMouseBuffer = (DIDEVICEOBJECTDATA*)appMalloc( 100 * sizeof(DIDEVICEOBJECTDATA), TEXT("DirectInputMouseBuffer") );
		Result = diMouse->SetDataFormat(&c_dfDIMouse);
	}
	if( Result == DI_OK )
		Result = diMouse->SetCooperativeLevel(Window->hWnd, DISCL_EXCLUSIVE | DISCL_FOREGROUND);
	if( Result == DI_OK )
	{
		DIPROPDWORD dipdw;
		dipdw.diph.dwSize = sizeof(DIPROPDWORD);
		dipdw.diph.dwHeaderSize = sizeof(DIPROPHEADER);
		dipdw.diph.dwObj = 0;
		dipdw.diph.dwHow = DIPH_DEVICE;
		dipdw.dwData = DIPROPAXISMODE_ABS;
		Result = diMouse->SetProperty(DIPROP_AXISMODE, &dipdw.diph);
		if(Result == DI_OK)
		{
			dipdw.diph.dwSize = sizeof(DIPROPDWORD);
			dipdw.diph.dwHeaderSize = sizeof(DIPROPHEADER);
			dipdw.diph.dwObj = 0;
			dipdw.diph.dwHow = DIPH_DEVICE;
			dipdw.dwData = 100;	// buffer size of 100 mouse entries
			Result = diMouse->SetProperty(DIPROP_BUFFERSIZE, &dipdw.diph);
			
			AcquireDIMouse(1);
			diMouse->GetDeviceState(sizeof(diMouseState), &diMouseState);
			diOldMouseX = diMouseState.lX;
			diOldMouseY = diMouseState.lY;
			diOldMouseZ = diMouseState.lZ;
			diLMouseDown = 0;
			diRMouseDown = 0;
			diMMouseDown = 0;
			AcquireDIMouse(0);
		}
	}

	if( Result != DI_OK )
	{
		debugf( NAME_Init, TEXT("DirectInput - failed to gain access to mouse: %s"), diError(Result) );
		return 0;
	}
	
	return 1;
	unguard;
}

void UWindowsViewport::diShutdownKeyboardMouse()
{
	guard(UWindowsViewport::diShutdownKeyboardMouse);
    if (diKeyboard ) 
    { 
         diKeyboard->Unacquire(); 
         diKeyboard->Release();
         diKeyboard = NULL; 
    } 
    if( diMouse ) 
    { 
         diMouse->Unacquire(); 
         diMouse->Release();
         diMouse = NULL; 
		 if( diMouseBuffer )
			appFree( diMouseBuffer );
    } 
	unguard;
}


/*-----------------------------------------------------------------------------
	Lock and Unlock.
-----------------------------------------------------------------------------*/

//
// Lock the viewport window and set the approprite Screen and RealScreen fields
// of Viewport.  Returns 1 if locked successfully, 0 if failed.  Note that a
// lock failing is not a critical error; it's a sign that a DirectDraw mode
// has ended or the user has closed a viewport window.
//
UBOOL UWindowsViewport::Lock( FPlane FlashScale, FPlane FlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* HitData, INT* HitSize )
{
	guard(UWindowsViewport::LockWindow);
	UWindowsClient* Client = GetOuterUWindowsClient();
	clock(Client->DrawCycles);

	// Make sure window is lockable.
	if( (Window->hWnd && !IsWindow(Window->hWnd)) || HoldCount || !SizeX || !SizeY || !RenDev )
      	return 0;

	// Get info.
	Stride = SizeX;
	if( BlitFlags & BLIT_DirectDraw )
	{
		// Lock DirectDraw.
		check(!(BlitFlags&BLIT_DibSection));
		HRESULT Result;
  		if( ddFrontBuffer->IsLost() == DDERR_SURFACELOST )
		{
			Result = ddFrontBuffer->Restore();
   			if( Result != DD_OK )
			{
				debugf( NAME_Log, TEXT("DirectDraw Lock Restore failed %s"), ddError(Result) );
				ResizeViewport( BLIT_DibSection );//!!failure of d3d?
				return 0;
			}
		}
		appMemzero( &ddSurfaceDesc, sizeof(ddSurfaceDesc) );
  		ddSurfaceDesc.dwSize = sizeof(ddSurfaceDesc);
		Result = ddBackBuffer->Lock( NULL, &ddSurfaceDesc, DDLOCK_WAIT|DD_OTHERLOCKFLAGS, NULL );
  		if( Result != DD_OK )
		{
			debugf( NAME_Log, TEXT("DirectDraw Lock failed: %s"), ddError(Result) );
  			return 0;
		}
		if( ddSurfaceDesc.lPitch )
			Stride = ddSurfaceDesc.lPitch/ColorBytes;
		ScreenPointer = (BYTE*)ddSurfaceDesc.lpSurface;
		check(ScreenPointer);
	}
	else if( BlitFlags & BLIT_DibSection )
	{
		check(!(BlitFlags&BLIT_DirectDraw));
		check(ScreenPointer);
	}

	// Success here, so pass to superclass.
	unclock(Client->DrawCycles);
	return UViewport::Lock(FlashScale,FlashFog,ScreenClear,RenderLockFlags,HitData,HitSize);

	unguard;
}

//
// Unlock the viewport window.  If Blit=1, blits the viewport's frame buffer.
//
void UWindowsViewport::Unlock( UBOOL Blit )
{
	guard(UWindowsViewport::Unlock);
	UWindowsClient* Client = GetOuterUWindowsClient();
	check(!HoldCount);
	Client->DrawCycles=0;
	clock(Client->DrawCycles);
	UViewport::Unlock( Blit );
	if( BlitFlags & BLIT_DirectDraw )
	{
		// Handle DirectDraw.
		guard(UnlockDirectDraw);
		HRESULT Result;
		Result = ddBackBuffer->Unlock( ddSurfaceDesc.lpSurface );
		if( Result ) 
		 	appErrorf( TEXT("DirectDraw Unlock: %s"), ddError(Result) );
		if( Blit )
		{
			HRESULT Result = ddFrontBuffer->Flip( NULL, DDFLIP_WAIT );
			if( Result != DD_OK )
				appErrorf( TEXT("DirectDraw Flip failed: %s"), ddError(Result) );
		}
		unguard;
	}
	else if( BlitFlags & BLIT_DibSection )
	{
		// Handle CreateDIBSection.
		if( Blit )
		{
			HDC hDC = GetDC( Window->hWnd );
			if( hDC == NULL )
				appErrorf( TEXT("GetDC failed: %s"), appGetSystemErrorMessage() );
			if( SelectObject( Client->hMemScreenDC, hBitmap ) == NULL )
				appErrorf( TEXT("SelectObject failed: %s"), appGetSystemErrorMessage() );
			if( BitBlt( hDC, 0, 0, SizeX, SizeY, Client->hMemScreenDC, 0, 0, SRCCOPY ) == NULL )
				appErrorf( TEXT("BitBlt failed: %s"), appGetSystemErrorMessage() );
			if( ReleaseDC( Window->hWnd, hDC ) == NULL )
				appErrorf( TEXT("ReleaseDC failed: %s"), appGetSystemErrorMessage() );
		}
	}
	unclock(Client->DrawCycles);
	unguard;
}

/*-----------------------------------------------------------------------------
	Viewport modes.
-----------------------------------------------------------------------------*/

//
// Try switching to a new rendering device.
//
void UWindowsViewport::TryRenderDevice( const TCHAR* ClassName, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
{
	guard(UWindowsViewport::TryRenderDevice);

	// Shut down current rendering device.
	if( RenDev )
	{
		RenDev->Exit();
		delete RenDev;
		RenDev = NULL;
	}

	// Use appropriate defaults.
	UWindowsClient* C = GetOuterUWindowsClient();
	if( NewX==INDEX_NONE )
		NewX = Fullscreen ? C->FullscreenViewportX : C->WindowedViewportX;
	if( NewY==INDEX_NONE )
		NewY = Fullscreen ? C->FullscreenViewportY : C->WindowedViewportY;
	if( NewColorBytes==INDEX_NONE )
		NewColorBytes = Fullscreen ? C->FullscreenColorBits/8 : ColorBytes;

	// Find device driver.
	UClass* RenderClass = UObject::StaticLoadClass( URenderDevice::StaticClass(), NULL, ClassName, NULL, 0, NULL );
	if( RenderClass )
	{
		HoldCount++;
		RenDev = ConstructObject<URenderDevice>( RenderClass, this );
		if( RenDev->Init( this, NewX, NewY, NewColorBytes, Fullscreen ) )
		{
			if( GIsRunning )
				Actor->GetLevel()->DetailChange( RenDev->HighDetailActors );
		}
		else
		{
			debugf( NAME_Log, LocalizeError("Failed3D") );
			delete RenDev;
			RenDev = NULL;
		}
		HoldCount--;
	}
	GRenderDevice = RenDev;
	unguard;
}

//
// If in fullscreen mode, end it and return to Windows.
//
void UWindowsViewport::EndFullscreen()
{
	guard(UWindowsViewport::EndFullscreen);
	UWindowsClient* Client = GetOuterUWindowsClient();
	debugf(TEXT("EndFullscreen"));
	if( RenDev && RenDev->FullscreenOnly )
	{
		// This device doesn't support fullscreen, so use a window-capable rendering device.
		TryRenderDevice( TEXT("ini:Engine.Engine.WindowedRenderDevice"), INDEX_NONE, INDEX_NONE, INDEX_NONE, 0 );
		check(RenDev);
	}
	else if( RenDev && (BlitFlags & BLIT_Direct3D))
	{
		RenDev->SetRes( Client->WindowedViewportX, Client->WindowedViewportY, ColorBytes, 0 );
	}
	else if( RenDev && (BlitFlags & BLIT_OpenGL) )
	{
		RenDev->SetRes( INDEX_NONE, INDEX_NONE, ColorBytes, 0 );
	}
	else
	{
		ResizeViewport( BLIT_DibSection );
	}
	UpdateWindowFrame();
	unguard;
}

//
// Toggle fullscreen.
//
void UWindowsViewport::ToggleFullscreen()
{
	guard(UWindowsViewport::ToggleFullscreen);
	if( BlitFlags & BLIT_Fullscreen )
	{
		EndFullscreen();
	}
	else if( !(Actor->ShowFlags & SHOW_ChildWindow) )
	{
		debugf(TEXT("AttemptFullscreen"));
		TryRenderDevice( TEXT("ini:Engine.Engine.GameRenderDevice"), INDEX_NONE, INDEX_NONE, INDEX_NONE, 1 );
		if( !RenDev )
			TryRenderDevice( TEXT("ini:Engine.Engine.WindowedRenderDevice"), INDEX_NONE, INDEX_NONE, INDEX_NONE, 1 );
		if( !RenDev )
			TryRenderDevice( TEXT("ini:Engine.Engine.WindowedRenderDevice"), INDEX_NONE, INDEX_NONE, INDEX_NONE, 0 );
	}
	unguard;
}

//
// Resize the viewport.
//
UBOOL UWindowsViewport::ResizeViewport( DWORD NewBlitFlags, INT InNewX, INT InNewY, INT InNewColorBytes )
{
	guard(UWindowsViewport::ResizeViewport);
	UWindowsClient* Client = GetOuterUWindowsClient();

	// Handle temporary viewports.
	if( BlitFlags & BLIT_Temporary )
		NewBlitFlags &= ~(BLIT_DirectDraw | BLIT_DibSection);

	// Handle DirectDraw not available.
	if( (NewBlitFlags & BLIT_DirectDraw) && !Client->dd )
		NewBlitFlags = (NewBlitFlags | BLIT_DibSection) & ~(BLIT_Fullscreen | BLIT_DirectDraw);

	// If going windowed, but the rendering device is fullscreen-only, switch to the software renderer.
	if( RenDev && RenDev->FullscreenOnly && !(NewBlitFlags & BLIT_Fullscreen) )
	{
		guard(SoftwareBail);
		if( !(GetFlags() & RF_Destroyed) )
		{
			TryRenderDevice( TEXT("ini:Engine.Engine.WindowedRenderDevice"), INDEX_NONE, INDEX_NONE, InNewColorBytes, 0 );
			check(RenDev);
		}
		return 0;
		unguard;
	}

	// Remember viewport.
	UViewport* SavedViewport = NULL;
	if( Client->Engine->Audio && !GIsEditor && !(GetFlags() & RF_Destroyed) )
		SavedViewport = Client->Engine->Audio->GetViewport();

	// Accept default parameters.
	INT NewX          = InNewX         ==INDEX_NONE ? SizeX      : InNewX;
	INT NewY          = InNewY         ==INDEX_NONE ? SizeY      : InNewY;
	INT NewColorBytes = InNewColorBytes==INDEX_NONE ? ColorBytes : InNewColorBytes;

	// Shut down current frame.
	if( BlitFlags & BLIT_DirectDraw )
	{
		debugf( NAME_Log, TEXT("DirectDraw session ending") );
		if( SavedViewport )
			Client->Engine->Audio->SetViewport( NULL );
		check(ddBackBuffer);
		ddBackBuffer->Release();
		check(ddFrontBuffer);
		ddFrontBuffer->Release();
		if( !(NewBlitFlags & BLIT_DirectDraw) )
		{
			HoldCount++;
			Client->ddEndMode();
			HoldCount--;
		}
	}
	else if( BlitFlags & BLIT_DibSection )
	{
		if( hBitmap )
			DeleteObject( hBitmap );
		hBitmap = NULL;
	}

	// Get this window rect.
	FRect WindowRect = SavedWindowRect;
	if( Window->hWnd && !(BlitFlags & BLIT_Fullscreen) && !(NewBlitFlags&BLIT_NoWindowChange) )
		WindowRect = Window->GetWindowRect();

	// Default resolution handling.
	NewX = InNewX!=INDEX_NONE ? InNewX : (NewBlitFlags&BLIT_Fullscreen) ? Client->FullscreenViewportX : Client->WindowedViewportX;
	NewY = InNewX!=INDEX_NONE ? InNewY : (NewBlitFlags&BLIT_Fullscreen) ? Client->FullscreenViewportY : Client->WindowedViewportY;

	// Align NewX.
	check(NewX>=0);
	check(NewY>=0);
	NewX = Align(NewX,2);

	// If currently fullscreen, end it.
	if( BlitFlags & BLIT_Fullscreen )
	{
		// Saved parameters.
		SetFocus( Window->hWnd );
		if( InNewColorBytes==INDEX_NONE )
			NewColorBytes = SavedColorBytes;

		// Remember saved info.
		WindowRect          = SavedWindowRect;
		Caps                = SavedCaps;

		// Restore window topness.
		SetTopness();
		SetDrag( 0 );

		// Stop inhibiting windows keys.
		UnregisterHotKey( Window->hWnd, Client->hkAltEsc  );
		UnregisterHotKey( Window->hWnd, Client->hkAltTab  );
		UnregisterHotKey( Window->hWnd, Client->hkCtrlEsc );
		UnregisterHotKey( Window->hWnd, Client->hkCtrlTab );
		//DWORD Old=0;
		//SystemParametersInfoX( SPI_SCREENSAVERRUNNING, 0, &Old, 0 );
	}

	// If transitioning into fullscreen.
	if( (NewBlitFlags & BLIT_Fullscreen) && !(BlitFlags & BLIT_Fullscreen) )
	{
		// Save window parameters.
		SavedWindowRect = WindowRect;
		SavedColorBytes	= ColorBytes;
		SavedCaps       = Caps;

		// Make "Advanced Options" not return fullscreen after this.
		if( Client->ConfigProperties )
		{
			Client->ConfigReturnFullscreen = 0;
			DestroyWindow( *Client->ConfigProperties );
		}

		// Turn off window border and menu.
		HoldCount++;
		SendMessageX( Window->hWnd, WM_SETREDRAW, 0, 0 );
		SetMenu( Window->hWnd, NULL );
		if( !GIsEditor )
		{
			SetWindowLongX( Window->hWnd, GWL_STYLE, GetWindowLongX(Window->hWnd,GWL_STYLE) & ~(WS_CAPTION|WS_THICKFRAME) );
			Borderless = 1;
		}
		SendMessageX( Window->hWnd, WM_SETREDRAW, 1, 0 );
		HoldCount--;
	}

	// Handle display method.
	if( NewBlitFlags & BLIT_DirectDraw )
	{
		// Go into closest matching DirectDraw mode.
		INT BestMode=-1, BestDelta=MAXINT;		
		for( INT i=0; i<Client->DirectDrawModes[ColorBytes].Num(); i++ )
		{
			INT Delta = Abs(Client->DirectDrawModes[ColorBytes](i).X-NewX) + Abs(Client->DirectDrawModes[ColorBytes](i).Y-NewY);
			if( Delta < BestDelta )
			{
				BestMode  = i;
				BestDelta = Delta;
			}
		}
		if( BestMode>=0 )
		{
			// Try to go into DirectDraw.
			NewX = Client->DirectDrawModes[ColorBytes](BestMode).X;
			NewY = Client->DirectDrawModes[ColorBytes](BestMode).Y;
			HoldCount++;
			if( !(BlitFlags & BLIT_DirectDraw) )
			{
				if( SavedViewport )
					Client->Engine->Audio->SetViewport( NULL );
				HRESULT Result = Client->dd->SetCooperativeLevel( Window->hWnd, DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN | DDSCL_ALLOWREBOOT );
				if( Result != DD_OK )
				{
					debugf( TEXT("DirectDraw SetCooperativeLevel failed: %s"), ddError(Result) );
   					return 0;
				}
			}
			SetCursor( NULL );
			UBOOL Result = ddSetMode( NewX, NewY, NewColorBytes );
			SetForegroundWindow( Window->hWnd );
			HoldCount--;
			if( !Result )
			{
				// DirectDraw failed.
				HoldCount++;
				Client->dd->SetCooperativeLevel( NULL, DDSCL_NORMAL );
				Window->MoveWindow( SavedWindowRect, 1 );
				SetTopness();
				HoldCount--;
				debugf( LocalizeError("DDrawMode") );
				return 0;
			}
		}
		else
		{
			debugf( TEXT("No DirectDraw modes") );
			return 0;
		}
	}
	else if( (NewBlitFlags&BLIT_DibSection) && NewX && NewY )
	{
		// Create DIB section.
		struct { BITMAPINFOHEADER Header; RGBQUAD Colors[256]; } Bitmap;

		// Init BitmapHeader for DIB.
		appMemzero( &Bitmap, sizeof(Bitmap) );
		Bitmap.Header.biSize			= sizeof(BITMAPINFOHEADER);
		Bitmap.Header.biWidth			= NewX;
		Bitmap.Header.biHeight			= -NewY;
		Bitmap.Header.biPlanes			= 1;
		Bitmap.Header.biBitCount		= NewColorBytes * 8;
		Bitmap.Header.biSizeImage		= NewX * NewY * NewColorBytes;

		// Handle color depth.
		if( NewColorBytes==2 )
		{
			// 16-bit color (565).
			Bitmap.Header.biCompression = BI_BITFIELDS;
			*(DWORD *)&Bitmap.Colors[0] = (Caps & CC_RGB565) ? 0xF800 : 0x7C00;
			*(DWORD *)&Bitmap.Colors[1] = (Caps & CC_RGB565) ? 0x07E0 : 0x03E0;
			*(DWORD *)&Bitmap.Colors[2] = (Caps & CC_RGB565) ? 0x001F : 0x001F;
		}
		else if( NewColorBytes==3 || NewColorBytes==4 )
		{
			// 24-bit or 32-bit color.
			Bitmap.Header.biCompression = BI_RGB;
			*(DWORD *)&Bitmap.Colors[0] = 0;
		}
		else appErrorf( TEXT("Invalid DibSection color depth %i"), NewColorBytes );

		// Create DIB section.
		HDC TempDC = GetDC(0);
		check(TempDC);
		hBitmap = CreateDIBSection( TempDC, (BITMAPINFO*)&Bitmap.Header, DIB_RGB_COLORS, (void**)&ScreenPointer, NULL, 0 );
		ReleaseDC( 0, TempDC );
		if( !hBitmap )
			appErrorf( LocalizeError("OutOfMemory",TEXT("Core")) );
		check(ScreenPointer);
	}
	else if( !(NewBlitFlags & BLIT_Temporary) )
	{
		ScreenPointer = NULL;
	}

	// OpenGL handling.
	if( (NewBlitFlags & BLIT_Fullscreen) && !GIsEditor && RenDev && appStricmp(RenDev->GetClass()->GetName(),TEXT("OpenGLRenderDevice"))==0 )
	{
		// Turn off window border and menu.
		HoldCount++;
		SendMessageX( Window->hWnd, WM_SETREDRAW, 0, 0 );
		Window->MoveWindow( FRect(0,0,NewX,NewY), 0 );
		SendMessageX( Window->hWnd, WM_SETREDRAW, 1, 0 );
		HoldCount--;
	}

	// Set new info.
	DWORD OldBlitFlags = BlitFlags;
	BlitFlags          = NewBlitFlags & ~BLIT_ParameterFlags;
	SizeX              = NewX;
	SizeY              = NewY;
	ColorBytes         = NewColorBytes ? NewColorBytes : ColorBytes;

	// If transitioning out of fullscreen.
	if( !(NewBlitFlags & BLIT_Fullscreen) && (OldBlitFlags & BLIT_Fullscreen) )
	{
		SetMouseCapture( 0, 0, 0 );
	}

	// Handle type.
	if( NewBlitFlags & BLIT_Fullscreen )
	{	
		// Handle fullscreen input.
		SetDrag( 1 );
		SetMouseCapture( 1, 1, 0 );
		RegisterHotKey( Window->hWnd, Client->hkAltEsc,  MOD_ALT,     VK_ESCAPE );
		RegisterHotKey( Window->hWnd, Client->hkAltTab,  MOD_ALT,     VK_TAB    );
		RegisterHotKey( Window->hWnd, Client->hkCtrlEsc, MOD_CONTROL, VK_ESCAPE );
		RegisterHotKey( Window->hWnd, Client->hkCtrlTab, MOD_CONTROL, VK_TAB    );
		//DWORD Old=0;
		//SystemParametersInfoX( SPI_SCREENSAVERRUNNING, 1, &Old, 0 );
	}
	else if( !(NewBlitFlags & BLIT_Temporary) && !(NewBlitFlags & BLIT_NoWindowChange) )
	{
		// Turn on window border and menu.
		if( Borderless )
		{
			HoldCount++;
			SetWindowLongX( Window->hWnd, GWL_STYLE, GetWindowLongX(Window->hWnd,GWL_STYLE) | (WS_CAPTION|WS_THICKFRAME) );
			HoldCount--;
		}

		// Going to a window.
		FRect ClientRect(0,0,NewX,NewY);
		AdjustWindowRect( ClientRect, GetWindowLongX(Window->hWnd,GWL_STYLE), (Actor->ShowFlags & SHOW_Menu)!=0 );

		// Resize the window and repaint it.
		if( !(Actor->ShowFlags & SHOW_ChildWindow) )
		{
			HoldCount++;
			Window->MoveWindow( FRect(WindowRect.Min,WindowRect.Min+ClientRect.Size()), 1 );
			HoldCount--;
		}
		SetDrag( 0 );
	}

	// Update audio.
	if( SavedViewport && SavedViewport!=Client->Engine->Audio->GetViewport() )
		Client->Engine->Audio->SetViewport( SavedViewport );

	// Update the window.
	UpdateWindowFrame();

	// Save info.
	if( RenDev && !GIsEditor )
	{
		if( NewBlitFlags & BLIT_Fullscreen )
		{
			if( NewX && NewY )
			{
				Client->FullscreenViewportX  = NewX;
				Client->FullscreenViewportY  = NewY;
				Client->FullscreenColorBits  = NewColorBytes*8;
			}
		}
		else
		{
			if( NewX && NewY )
			{
				Client->WindowedViewportX  = NewX;
				Client->WindowedViewportY  = NewY;
				Client->WindowedColorBits  = NewColorBytes*8;
			}
		}
		Client->SaveConfig();
	}

	return 1;
	unguard;
}

//
// DirectInput Constants (!!)
//
DIOBJECTDATAFORMAT c_rgodfDIMouse[7] =
{
	{ &GUID_XAxis, 0, 0xFFFF03, 0 },
	{ &GUID_YAxis, 4, 0xFFFF03, 0 },
	{ &GUID_ZAxis, 8, 0x80FFFF03, 0 },
	{ NULL, 12, 0xFFFF0C, 0 },
	{ NULL, 13, 0xFFFF0C, 0 },
	{ NULL, 14, 0x80FFFF0C, 0 },
	{ NULL, 15, 0x80FFFF0C, 0 }
};
const DIDATAFORMAT c_dfDIMouse = { 24, 16, 0x2, 16, 7, c_rgodfDIMouse };

DIOBJECTDATAFORMAT c_rgodfDIKeyboard[256] =
{
	{ &GUID_Key, 0, 0x8000000C, 0 },
	{ &GUID_Key, 1, 0x8000010C, 0 },
	{ &GUID_Key, 2, 0x8000020C, 0 },
	{ &GUID_Key, 3, 0x8000030C, 0 },
	{ &GUID_Key, 4, 0x8000040C, 0 },
	{ &GUID_Key, 5, 0x8000050C, 0 },
	{ &GUID_Key, 6, 0x8000060C, 0 },
	{ &GUID_Key, 7, 0x8000070C, 0 },
	{ &GUID_Key, 8, 0x8000080C, 0 },
	{ &GUID_Key, 9, 0x8000090C, 0 },
	{ &GUID_Key, 10, 0x80000A0C, 0 },
	{ &GUID_Key, 11, 0x80000B0C, 0 },
	{ &GUID_Key, 12, 0x80000C0C, 0 },
	{ &GUID_Key, 13, 0x80000D0C, 0 },
	{ &GUID_Key, 14, 0x80000E0C, 0 },
	{ &GUID_Key, 15, 0x80000F0C, 0 },
	{ &GUID_Key, 16, 0x8000100C, 0 },
	{ &GUID_Key, 17, 0x8000110C, 0 },
	{ &GUID_Key, 18, 0x8000120C, 0 },
	{ &GUID_Key, 19, 0x8000130C, 0 },
	{ &GUID_Key, 20, 0x8000140C, 0 },
	{ &GUID_Key, 21, 0x8000150C, 0 },
	{ &GUID_Key, 22, 0x8000160C, 0 },
	{ &GUID_Key, 23, 0x8000170C, 0 },
	{ &GUID_Key, 24, 0x8000180C, 0 },
	{ &GUID_Key, 25, 0x8000190C, 0 },
	{ &GUID_Key, 26, 0x80001A0C, 0 },
	{ &GUID_Key, 27, 0x80001B0C, 0 },
	{ &GUID_Key, 28, 0x80001C0C, 0 },
	{ &GUID_Key, 29, 0x80001D0C, 0 },
	{ &GUID_Key, 30, 0x80001E0C, 0 },
	{ &GUID_Key, 31, 0x80001F0C, 0 },
	{ &GUID_Key, 32, 0x8000200C, 0 },
	{ &GUID_Key, 33, 0x8000210C, 0 },
	{ &GUID_Key, 34, 0x8000220C, 0 },
	{ &GUID_Key, 35, 0x8000230C, 0 },
	{ &GUID_Key, 36, 0x8000240C, 0 },
	{ &GUID_Key, 37, 0x8000250C, 0 },
	{ &GUID_Key, 38, 0x8000260C, 0 },
	{ &GUID_Key, 39, 0x8000270C, 0 },
	{ &GUID_Key, 40, 0x8000280C, 0 },
	{ &GUID_Key, 41, 0x8000290C, 0 },
	{ &GUID_Key, 42, 0x80002A0C, 0 },
	{ &GUID_Key, 43, 0x80002B0C, 0 },
	{ &GUID_Key, 44, 0x80002C0C, 0 },
	{ &GUID_Key, 45, 0x80002D0C, 0 },
	{ &GUID_Key, 46, 0x80002E0C, 0 },
	{ &GUID_Key, 47, 0x80002F0C, 0 },
	{ &GUID_Key, 48, 0x8000300C, 0 },
	{ &GUID_Key, 49, 0x8000310C, 0 },
	{ &GUID_Key, 50, 0x8000320C, 0 },
	{ &GUID_Key, 51, 0x8000330C, 0 },
	{ &GUID_Key, 52, 0x8000340C, 0 },
	{ &GUID_Key, 53, 0x8000350C, 0 },
	{ &GUID_Key, 54, 0x8000360C, 0 },
	{ &GUID_Key, 55, 0x8000370C, 0 },
	{ &GUID_Key, 56, 0x8000380C, 0 },
	{ &GUID_Key, 57, 0x8000390C, 0 },
	{ &GUID_Key, 58, 0x80003A0C, 0 },
	{ &GUID_Key, 59, 0x80003B0C, 0 },
	{ &GUID_Key, 60, 0x80003C0C, 0 },
	{ &GUID_Key, 61, 0x80003D0C, 0 },
	{ &GUID_Key, 62, 0x80003E0C, 0 },
	{ &GUID_Key, 63, 0x80003F0C, 0 },
	{ &GUID_Key, 64, 0x8000400C, 0 },
	{ &GUID_Key, 65, 0x8000410C, 0 },
	{ &GUID_Key, 66, 0x8000420C, 0 },
	{ &GUID_Key, 67, 0x8000430C, 0 },
	{ &GUID_Key, 68, 0x8000440C, 0 },
	{ &GUID_Key, 69, 0x8000450C, 0 },
	{ &GUID_Key, 70, 0x8000460C, 0 },
	{ &GUID_Key, 71, 0x8000470C, 0 },
	{ &GUID_Key, 72, 0x8000480C, 0 },
	{ &GUID_Key, 73, 0x8000490C, 0 },
	{ &GUID_Key, 74, 0x80004A0C, 0 },
	{ &GUID_Key, 75, 0x80004B0C, 0 },
	{ &GUID_Key, 76, 0x80004C0C, 0 },
	{ &GUID_Key, 77, 0x80004D0C, 0 },
	{ &GUID_Key, 78, 0x80004E0C, 0 },
	{ &GUID_Key, 79, 0x80004F0C, 0 },
	{ &GUID_Key, 80, 0x8000500C, 0 },
	{ &GUID_Key, 81, 0x8000510C, 0 },
	{ &GUID_Key, 82, 0x8000520C, 0 },
	{ &GUID_Key, 83, 0x8000530C, 0 },
	{ &GUID_Key, 84, 0x8000540C, 0 },
	{ &GUID_Key, 85, 0x8000550C, 0 },
	{ &GUID_Key, 86, 0x8000560C, 0 },
	{ &GUID_Key, 87, 0x8000570C, 0 },
	{ &GUID_Key, 88, 0x8000580C, 0 },
	{ &GUID_Key, 89, 0x8000590C, 0 },
	{ &GUID_Key, 90, 0x80005A0C, 0 },
	{ &GUID_Key, 91, 0x80005B0C, 0 },
	{ &GUID_Key, 92, 0x80005C0C, 0 },
	{ &GUID_Key, 93, 0x80005D0C, 0 },
	{ &GUID_Key, 94, 0x80005E0C, 0 },
	{ &GUID_Key, 95, 0x80005F0C, 0 },
	{ &GUID_Key, 96, 0x8000600C, 0 },
	{ &GUID_Key, 97, 0x8000610C, 0 },
	{ &GUID_Key, 98, 0x8000620C, 0 },
	{ &GUID_Key, 99, 0x8000630C, 0 },
	{ &GUID_Key, 100, 0x8000640C, 0 },
	{ &GUID_Key, 101, 0x8000650C, 0 },
	{ &GUID_Key, 102, 0x8000660C, 0 },
	{ &GUID_Key, 103, 0x8000670C, 0 },
	{ &GUID_Key, 104, 0x8000680C, 0 },
	{ &GUID_Key, 105, 0x8000690C, 0 },
	{ &GUID_Key, 106, 0x80006A0C, 0 },
	{ &GUID_Key, 107, 0x80006B0C, 0 },
	{ &GUID_Key, 108, 0x80006C0C, 0 },
	{ &GUID_Key, 109, 0x80006D0C, 0 },
	{ &GUID_Key, 110, 0x80006E0C, 0 },
	{ &GUID_Key, 111, 0x80006F0C, 0 },
	{ &GUID_Key, 112, 0x8000700C, 0 },
	{ &GUID_Key, 113, 0x8000710C, 0 },
	{ &GUID_Key, 114, 0x8000720C, 0 },
	{ &GUID_Key, 115, 0x8000730C, 0 },
	{ &GUID_Key, 116, 0x8000740C, 0 },
	{ &GUID_Key, 117, 0x8000750C, 0 },
	{ &GUID_Key, 118, 0x8000760C, 0 },
	{ &GUID_Key, 119, 0x8000770C, 0 },
	{ &GUID_Key, 120, 0x8000780C, 0 },
	{ &GUID_Key, 121, 0x8000790C, 0 },
	{ &GUID_Key, 122, 0x80007A0C, 0 },
	{ &GUID_Key, 123, 0x80007B0C, 0 },
	{ &GUID_Key, 124, 0x80007C0C, 0 },
	{ &GUID_Key, 125, 0x80007D0C, 0 },
	{ &GUID_Key, 126, 0x80007E0C, 0 },
	{ &GUID_Key, 127, 0x80007F0C, 0 },
	{ &GUID_Key, 128, 0x8000800C, 0 },
	{ &GUID_Key, 129, 0x8000810C, 0 },
	{ &GUID_Key, 130, 0x8000820C, 0 },
	{ &GUID_Key, 131, 0x8000830C, 0 },
	{ &GUID_Key, 132, 0x8000840C, 0 },
	{ &GUID_Key, 133, 0x8000850C, 0 },
	{ &GUID_Key, 134, 0x8000860C, 0 },
	{ &GUID_Key, 135, 0x8000870C, 0 },
	{ &GUID_Key, 136, 0x8000880C, 0 },
	{ &GUID_Key, 137, 0x8000890C, 0 },
	{ &GUID_Key, 138, 0x80008A0C, 0 },
	{ &GUID_Key, 139, 0x80008B0C, 0 },
	{ &GUID_Key, 140, 0x80008C0C, 0 },
	{ &GUID_Key, 141, 0x80008D0C, 0 },
	{ &GUID_Key, 142, 0x80008E0C, 0 },
	{ &GUID_Key, 143, 0x80008F0C, 0 },
	{ &GUID_Key, 144, 0x8000900C, 0 },
	{ &GUID_Key, 145, 0x8000910C, 0 },
	{ &GUID_Key, 146, 0x8000920C, 0 },
	{ &GUID_Key, 147, 0x8000930C, 0 },
	{ &GUID_Key, 148, 0x8000940C, 0 },
	{ &GUID_Key, 149, 0x8000950C, 0 },
	{ &GUID_Key, 150, 0x8000960C, 0 },
	{ &GUID_Key, 151, 0x8000970C, 0 },
	{ &GUID_Key, 152, 0x8000980C, 0 },
	{ &GUID_Key, 153, 0x8000990C, 0 },
	{ &GUID_Key, 154, 0x80009A0C, 0 },
	{ &GUID_Key, 155, 0x80009B0C, 0 },
	{ &GUID_Key, 156, 0x80009C0C, 0 },
	{ &GUID_Key, 157, 0x80009D0C, 0 },
	{ &GUID_Key, 158, 0x80009E0C, 0 },
	{ &GUID_Key, 159, 0x80009F0C, 0 },
	{ &GUID_Key, 160, 0x8000A00C, 0 },
	{ &GUID_Key, 161, 0x8000A10C, 0 },
	{ &GUID_Key, 162, 0x8000A20C, 0 },
	{ &GUID_Key, 163, 0x8000A30C, 0 },
	{ &GUID_Key, 164, 0x8000A40C, 0 },
	{ &GUID_Key, 165, 0x8000A50C, 0 },
	{ &GUID_Key, 166, 0x8000A60C, 0 },
	{ &GUID_Key, 167, 0x8000A70C, 0 },
	{ &GUID_Key, 168, 0x8000A80C, 0 },
	{ &GUID_Key, 169, 0x8000A90C, 0 },
	{ &GUID_Key, 170, 0x8000AA0C, 0 },
	{ &GUID_Key, 171, 0x8000AB0C, 0 },
	{ &GUID_Key, 172, 0x8000AC0C, 0 },
	{ &GUID_Key, 173, 0x8000AD0C, 0 },
	{ &GUID_Key, 174, 0x8000AE0C, 0 },
	{ &GUID_Key, 175, 0x8000AF0C, 0 },
	{ &GUID_Key, 176, 0x8000B00C, 0 },
	{ &GUID_Key, 177, 0x8000B10C, 0 },
	{ &GUID_Key, 178, 0x8000B20C, 0 },
	{ &GUID_Key, 179, 0x8000B30C, 0 },
	{ &GUID_Key, 180, 0x8000B40C, 0 },
	{ &GUID_Key, 181, 0x8000B50C, 0 },
	{ &GUID_Key, 182, 0x8000B60C, 0 },
	{ &GUID_Key, 183, 0x8000B70C, 0 },
	{ &GUID_Key, 184, 0x8000B80C, 0 },
	{ &GUID_Key, 185, 0x8000B90C, 0 },
	{ &GUID_Key, 186, 0x8000BA0C, 0 },
	{ &GUID_Key, 187, 0x8000BB0C, 0 },
	{ &GUID_Key, 188, 0x8000BC0C, 0 },
	{ &GUID_Key, 189, 0x8000BD0C, 0 },
	{ &GUID_Key, 190, 0x8000BE0C, 0 },
	{ &GUID_Key, 191, 0x8000BF0C, 0 },
	{ &GUID_Key, 192, 0x8000C00C, 0 },
	{ &GUID_Key, 193, 0x8000C10C, 0 },
	{ &GUID_Key, 194, 0x8000C20C, 0 },
	{ &GUID_Key, 195, 0x8000C30C, 0 },
	{ &GUID_Key, 196, 0x8000C40C, 0 },
	{ &GUID_Key, 197, 0x8000C50C, 0 },
	{ &GUID_Key, 198, 0x8000C60C, 0 },
	{ &GUID_Key, 199, 0x8000C70C, 0 },
	{ &GUID_Key, 200, 0x8000C80C, 0 },
	{ &GUID_Key, 201, 0x8000C90C, 0 },
	{ &GUID_Key, 202, 0x8000CA0C, 0 },
	{ &GUID_Key, 203, 0x8000CB0C, 0 },
	{ &GUID_Key, 204, 0x8000CC0C, 0 },
	{ &GUID_Key, 205, 0x8000CD0C, 0 },
	{ &GUID_Key, 206, 0x8000CE0C, 0 },
	{ &GUID_Key, 207, 0x8000CF0C, 0 },
	{ &GUID_Key, 208, 0x8000D00C, 0 },
	{ &GUID_Key, 209, 0x8000D10C, 0 },
	{ &GUID_Key, 210, 0x8000D20C, 0 },
	{ &GUID_Key, 211, 0x8000D30C, 0 },
	{ &GUID_Key, 212, 0x8000D40C, 0 },
	{ &GUID_Key, 213, 0x8000D50C, 0 },
	{ &GUID_Key, 214, 0x8000D60C, 0 },
	{ &GUID_Key, 215, 0x8000D70C, 0 },
	{ &GUID_Key, 216, 0x8000D80C, 0 },
	{ &GUID_Key, 217, 0x8000D90C, 0 },
	{ &GUID_Key, 218, 0x8000DA0C, 0 },
	{ &GUID_Key, 219, 0x8000DB0C, 0 },
	{ &GUID_Key, 220, 0x8000DC0C, 0 },
	{ &GUID_Key, 221, 0x8000DD0C, 0 },
	{ &GUID_Key, 222, 0x8000DE0C, 0 },
	{ &GUID_Key, 223, 0x8000DF0C, 0 },
	{ &GUID_Key, 224, 0x8000E00C, 0 },
	{ &GUID_Key, 225, 0x8000E10C, 0 },
	{ &GUID_Key, 226, 0x8000E20C, 0 },
	{ &GUID_Key, 227, 0x8000E30C, 0 },
	{ &GUID_Key, 228, 0x8000E40C, 0 },
	{ &GUID_Key, 229, 0x8000E50C, 0 },
	{ &GUID_Key, 230, 0x8000E60C, 0 },
	{ &GUID_Key, 231, 0x8000E70C, 0 },
	{ &GUID_Key, 232, 0x8000E80C, 0 },
	{ &GUID_Key, 233, 0x8000E90C, 0 },
	{ &GUID_Key, 234, 0x8000EA0C, 0 },
	{ &GUID_Key, 235, 0x8000EB0C, 0 },
	{ &GUID_Key, 236, 0x8000EC0C, 0 },
	{ &GUID_Key, 237, 0x8000ED0C, 0 },
	{ &GUID_Key, 238, 0x8000EE0C, 0 },
	{ &GUID_Key, 239, 0x8000EF0C, 0 },
	{ &GUID_Key, 240, 0x8000F00C, 0 },
	{ &GUID_Key, 241, 0x8000F10C, 0 },
	{ &GUID_Key, 242, 0x8000F20C, 0 },
	{ &GUID_Key, 243, 0x8000F30C, 0 },
	{ &GUID_Key, 244, 0x8000F40C, 0 },
	{ &GUID_Key, 245, 0x8000F50C, 0 },
	{ &GUID_Key, 246, 0x8000F60C, 0 },
	{ &GUID_Key, 247, 0x8000F70C, 0 },
	{ &GUID_Key, 248, 0x8000F80C, 0 },
	{ &GUID_Key, 249, 0x8000F90C, 0 },
	{ &GUID_Key, 250, 0x8000FA0C, 0 },
	{ &GUID_Key, 251, 0x8000FB0C, 0 },
	{ &GUID_Key, 252, 0x8000FC0C, 0 },
	{ &GUID_Key, 253, 0x8000FD0C, 0 },
	{ &GUID_Key, 254, 0x8000FE0C, 0 },
	{ &GUID_Key, 255, 0x8000FF0C, 0 }
};
const DIDATAFORMAT c_dfDIKeyboard = { 24, 16, 0x2, 256, 256, c_rgodfDIKeyboard };

DIOBJECTDATAFORMAT c_rgodfDIJoystick[44] =
{
	{ &GUID_XAxis, 0, 0x80FFFF03, 256 },
	{ &GUID_YAxis, 4, 0x80FFFF03, 256 },
	{ &GUID_ZAxis, 8, 0x80FFFF03, 256 },
	{ &GUID_RxAxis, 12, 0x80FFFF03, 256 },
	{ &GUID_RyAxis, 16, 0x80FFFF03, 256 },
	{ &GUID_RzAxis, 20, 0x80FFFF03, 256 },
	{ &GUID_Slider, 24, 0x80FFFF03, 256 },
	{ &GUID_Slider, 28, 0x80FFFF03, 256 },
	{ &GUID_POV, 32, 0x80FFFF10, 0 },
	{ &GUID_POV, 36, 0x80FFFF10, 0 },
	{ &GUID_POV, 40, 0x80FFFF10, 0 },
	{ &GUID_POV, 44, 0x80FFFF10, 0 },
	{ NULL, 48, 0x80FFFF0C, 0 },
	{ NULL, 49, 0x80FFFF0C, 0 },
	{ NULL, 50, 0x80FFFF0C, 0 },
	{ NULL, 51, 0x80FFFF0C, 0 },
	{ NULL, 52, 0x80FFFF0C, 0 },
	{ NULL, 53, 0x80FFFF0C, 0 },
	{ NULL, 54, 0x80FFFF0C, 0 },
	{ NULL, 55, 0x80FFFF0C, 0 },
	{ NULL, 56, 0x80FFFF0C, 0 },
	{ NULL, 57, 0x80FFFF0C, 0 },
	{ NULL, 58, 0x80FFFF0C, 0 },
	{ NULL, 59, 0x80FFFF0C, 0 },
	{ NULL, 60, 0x80FFFF0C, 0 },
	{ NULL, 61, 0x80FFFF0C, 0 },
	{ NULL, 62, 0x80FFFF0C, 0 },
	{ NULL, 63, 0x80FFFF0C, 0 },
	{ NULL, 64, 0x80FFFF0C, 0 },
	{ NULL, 65, 0x80FFFF0C, 0 },
	{ NULL, 66, 0x80FFFF0C, 0 },
	{ NULL, 67, 0x80FFFF0C, 0 },
	{ NULL, 68, 0x80FFFF0C, 0 },
	{ NULL, 69, 0x80FFFF0C, 0 },
	{ NULL, 70, 0x80FFFF0C, 0 },
	{ NULL, 71, 0x80FFFF0C, 0 },
	{ NULL, 72, 0x80FFFF0C, 0 },
	{ NULL, 73, 0x80FFFF0C, 0 },
	{ NULL, 74, 0x80FFFF0C, 0 },
	{ NULL, 75, 0x80FFFF0C, 0 },
	{ NULL, 76, 0x80FFFF0C, 0 },
	{ NULL, 77, 0x80FFFF0C, 0 },
	{ NULL, 78, 0x80FFFF0C, 0 },
	{ NULL, 79, 0x80FFFF0C, 0 }
};
const DIDATAFORMAT c_dfDIJoystick = { 24, 16, 0x1, 80, 44, c_rgodfDIJoystick };

DIOBJECTDATAFORMAT c_rgodfDIJoystick2[164] =
{
	{ &GUID_XAxis, 0, 0x80FFFF03, 256 },
	{ &GUID_YAxis, 4, 0x80FFFF03, 256 },
	{ &GUID_ZAxis, 8, 0x80FFFF03, 256 },
	{ &GUID_RxAxis, 12, 0x80FFFF03, 256 },
	{ &GUID_RyAxis, 16, 0x80FFFF03, 256 },
	{ &GUID_RzAxis, 20, 0x80FFFF03, 256 },
	{ &GUID_Slider, 24, 0x80FFFF03, 256 },
	{ &GUID_Slider, 28, 0x80FFFF03, 256 },
	{ &GUID_POV, 32, 0x80FFFF10, 0 },
	{ &GUID_POV, 36, 0x80FFFF10, 0 },
	{ &GUID_POV, 40, 0x80FFFF10, 0 },
	{ &GUID_POV, 44, 0x80FFFF10, 0 },
	{ &GUID_XAxis, 48, 0x80FFFF0C, 0 },
	{ &GUID_YAxis, 49, 0x80FFFF0C, 0 },
	{ &GUID_ZAxis, 50, 0x80FFFF0C, 0 },
	{ &GUID_RxAxis, 51, 0x80FFFF0C, 0 },
	{ &GUID_RyAxis, 52, 0x80FFFF0C, 0 },
	{ &GUID_RzAxis, 53, 0x80FFFF0C, 0 },
	{ &GUID_Slider, 54, 0x80FFFF0C, 0 },
	{ &GUID_Slider, 55, 0x80FFFF0C, 0 },
	{ &GUID_XAxis, 56, 0x80FFFF0C, 0 },
	{ &GUID_YAxis, 57, 0x80FFFF0C, 0 },
	{ &GUID_ZAxis, 58, 0x80FFFF0C, 0 },
	{ &GUID_RxAxis, 59, 0x80FFFF0C, 0 },
	{ &GUID_RyAxis, 60, 0x80FFFF0C, 0 },
	{ &GUID_RzAxis, 61, 0x80FFFF0C, 0 },
	{ &GUID_Slider, 62, 0x80FFFF0C, 0 },
	{ &GUID_Slider, 63, 0x80FFFF0C, 0 },
	{ &GUID_XAxis, 64, 0x80FFFF0C, 0 },
	{ &GUID_YAxis, 65, 0x80FFFF0C, 0 },
	{ &GUID_ZAxis, 66, 0x80FFFF0C, 0 },
	{ &GUID_RxAxis, 67, 0x80FFFF0C, 0 },
	{ &GUID_RyAxis, 68, 0x80FFFF0C, 0 },
	{ &GUID_RzAxis, 69, 0x80FFFF0C, 0 },
	{ &GUID_Slider, 70, 0x80FFFF0C, 0 },
	{ &GUID_Slider, 71, 0x80FFFF0C, 0 },
	{ NULL, 72, 0x80FFFF0C, 0 },
	{ NULL, 73, 0x80FFFF0C, 0 },
	{ NULL, 74, 0x80FFFF0C, 0 },
	{ NULL, 75, 0x80FFFF0C, 0 },
	{ NULL, 76, 0x80FFFF0C, 0 },
	{ NULL, 77, 0x80FFFF0C, 0 },
	{ NULL, 78, 0x80FFFF0C, 0 },
	{ NULL, 79, 0x80FFFF0C, 0 },
	{ NULL, 80, 0x80FFFF0C, 0 },
	{ NULL, 81, 0x80FFFF0C, 0 },
	{ NULL, 82, 0x80FFFF0C, 0 },
	{ NULL, 83, 0x80FFFF0C, 0 },
	{ NULL, 84, 0x80FFFF0C, 0 },
	{ NULL, 85, 0x80FFFF0C, 0 },
	{ NULL, 86, 0x80FFFF0C, 0 },
	{ NULL, 87, 0x80FFFF0C, 0 },
	{ NULL, 88, 0x80FFFF0C, 0 },
	{ NULL, 89, 0x80FFFF0C, 0 },
	{ NULL, 90, 0x80FFFF0C, 0 },
	{ NULL, 91, 0x80FFFF0C, 0 },
	{ NULL, 92, 0x80FFFF0C, 0 },
	{ NULL, 93, 0x80FFFF0C, 0 },
	{ NULL, 94, 0x80FFFF0C, 0 },
	{ NULL, 95, 0x80FFFF0C, 0 },
	{ NULL, 96, 0x80FFFF0C, 0 },
	{ NULL, 97, 0x80FFFF0C, 0 },
	{ NULL, 98, 0x80FFFF0C, 0 },
	{ NULL, 99, 0x80FFFF0C, 0 },
	{ NULL, 100, 0x80FFFF0C, 0 },
	{ NULL, 101, 0x80FFFF0C, 0 },
	{ NULL, 102, 0x80FFFF0C, 0 },
	{ NULL, 103, 0x80FFFF0C, 0 },
	{ NULL, 104, 0x80FFFF0C, 0 },
	{ NULL, 105, 0x80FFFF0C, 0 },
	{ NULL, 106, 0x80FFFF0C, 0 },
	{ NULL, 107, 0x80FFFF0C, 0 },
	{ NULL, 108, 0x80FFFF0C, 0 },
	{ NULL, 109, 0x80FFFF0C, 0 },
	{ NULL, 110, 0x80FFFF0C, 0 },
	{ NULL, 111, 0x80FFFF0C, 0 },
	{ NULL, 112, 0x80FFFF0C, 0 },
	{ NULL, 113, 0x80FFFF0C, 0 },
	{ NULL, 114, 0x80FFFF0C, 0 },
	{ NULL, 115, 0x80FFFF0C, 0 },
	{ NULL, 116, 0x80FFFF0C, 0 },
	{ NULL, 117, 0x80FFFF0C, 0 },
	{ NULL, 118, 0x80FFFF0C, 0 },
	{ NULL, 119, 0x80FFFF0C, 0 },
	{ NULL, 120, 0x80FFFF0C, 0 },
	{ NULL, 121, 0x80FFFF0C, 0 },
	{ NULL, 122, 0x80FFFF0C, 0 },
	{ NULL, 123, 0x80FFFF0C, 0 },
	{ NULL, 124, 0x80FFFF0C, 0 },
	{ NULL, 125, 0x80FFFF0C, 0 },
	{ NULL, 126, 0x80FFFF0C, 0 },
	{ NULL, 127, 0x80FFFF0C, 0 },
	{ NULL, 128, 0x80FFFF0C, 0 },
	{ NULL, 129, 0x80FFFF0C, 0 },
	{ NULL, 130, 0x80FFFF0C, 0 },
	{ NULL, 131, 0x80FFFF0C, 0 },
	{ NULL, 132, 0x80FFFF0C, 0 },
	{ NULL, 133, 0x80FFFF0C, 0 },
	{ NULL, 134, 0x80FFFF0C, 0 },
	{ NULL, 135, 0x80FFFF0C, 0 },
	{ NULL, 136, 0x80FFFF0C, 0 },
	{ NULL, 137, 0x80FFFF0C, 0 },
	{ NULL, 138, 0x80FFFF0C, 0 },
	{ NULL, 139, 0x80FFFF0C, 0 },
	{ NULL, 140, 0x80FFFF0C, 0 },
	{ NULL, 141, 0x80FFFF0C, 0 },
	{ NULL, 142, 0x80FFFF0C, 0 },
	{ NULL, 143, 0x80FFFF0C, 0 },
	{ NULL, 144, 0x80FFFF0C, 0 },
	{ NULL, 145, 0x80FFFF0C, 0 },
	{ NULL, 146, 0x80FFFF0C, 0 },
	{ NULL, 147, 0x80FFFF0C, 0 },
	{ NULL, 148, 0x80FFFF0C, 0 },
	{ NULL, 149, 0x80FFFF0C, 0 },
	{ NULL, 150, 0x80FFFF0C, 0 },
	{ NULL, 151, 0x80FFFF0C, 0 },
	{ NULL, 152, 0x80FFFF0C, 0 },
	{ NULL, 153, 0x80FFFF0C, 0 },
	{ NULL, 154, 0x80FFFF0C, 0 },
	{ NULL, 155, 0x80FFFF0C, 0 },
	{ NULL, 156, 0x80FFFF0C, 0 },
	{ NULL, 157, 0x80FFFF0C, 0 },
	{ NULL, 158, 0x80FFFF0C, 0 },
	{ NULL, 159, 0x80FFFF0C, 0 },
	{ NULL, 160, 0x80FFFF0C, 0 },
	{ NULL, 161, 0x80FFFF0C, 0 },
	{ NULL, 162, 0x80FFFF0C, 0 },
	{ NULL, 163, 0x80FFFF0C, 0 },
	{ NULL, 164, 0x80FFFF0C, 0 },
	{ NULL, 165, 0x80FFFF0C, 0 },
	{ NULL, 166, 0x80FFFF0C, 0 },
	{ NULL, 167, 0x80FFFF0C, 0 },
	{ NULL, 168, 0x80FFFF0C, 0 },
	{ NULL, 169, 0x80FFFF0C, 0 },
	{ NULL, 170, 0x80FFFF0C, 0 },
	{ NULL, 171, 0x80FFFF0C, 0 },
	{ NULL, 172, 0x80FFFF0C, 0 },
	{ NULL, 173, 0x80FFFF0C, 0 },
	{ NULL, 174, 0x80FFFF0C, 0 },
	{ NULL, 175, 0x80FFFF0C, 0 },
	{ NULL, 176, 0x80FFFF03, 512 },
	{ NULL, 180, 0x80FFFF03, 512 },
	{ NULL, 184, 0x80FFFF03, 512 },
	{ NULL, 188, 0x80FFFF03, 512 },
	{ NULL, 192, 0x80FFFF03, 512 },
	{ NULL, 196, 0x80FFFF03, 512 },
	{ NULL, 24, 0x80FFFF03, 512 },
	{ NULL, 28, 0x80FFFF03, 512 },
	{ NULL, 208, 0x80FFFF03, 768 },
	{ NULL, 212, 0x80FFFF03, 768 },
	{ NULL, 216, 0x80FFFF03, 768 },
	{ NULL, 220, 0x80FFFF03, 768 },
	{ NULL, 224, 0x80FFFF03, 768 },
	{ NULL, 228, 0x80FFFF03, 768 },
	{ NULL, 24, 0x80FFFF03, 768 },
	{ NULL, 28, 0x80FFFF03, 768 },
	{ NULL, 240, 0x80FFFF03, 1024 },
	{ NULL, 244, 0x80FFFF03, 1024 },
	{ NULL, 248, 0x80FFFF03, 1024 },
	{ NULL, 252, 0x80FFFF03, 1024 },
	{ NULL, 256, 0x80FFFF03, 1024 },
	{ NULL, 260, 0x80FFFF03, 1024 },
	{ NULL, 24, 0x80FFFF03, 1024 },
	{ NULL, 28, 0x80FFFF03, 1024 }
};
const DIDATAFORMAT c_dfDIJoystick2 = { 24, 16, 0x1, 272, 164, c_rgodfDIJoystick2 };

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
