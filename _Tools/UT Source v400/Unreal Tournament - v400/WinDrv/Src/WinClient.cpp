/*=============================================================================
	WinClient.cpp: UWindowsClient code.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "WinDrv.h"

/*-----------------------------------------------------------------------------
	Class implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UWindowsClient);

/*-----------------------------------------------------------------------------
	UWindowsClient implementation.
-----------------------------------------------------------------------------*/

//
// UWindowsClient constructor.
//
UWindowsClient::UWindowsClient()
{
	guard(UWindowsClient::UWindowsClient);

	// Init hotkey atoms.
	hkAltEsc	= GlobalAddAtom( TEXT("UnrealAltEsc")  );
	hkAltTab	= GlobalAddAtom( TEXT("UnrealAltTab")  );
	hkCtrlEsc	= GlobalAddAtom( TEXT("UnrealCtrlEsc") );
	hkCtrlTab	= GlobalAddAtom( TEXT("UnrealCtrlTab") );

	di = NULL;

	unguard;
}

//
// Static init.
//
void UWindowsClient::StaticConstructor()
{
	guard(UWindowsClient::StaticConstructor);

	new(GetClass(),TEXT("UseDirectDraw"),     RF_Public)UBoolProperty(CPP_PROPERTY(UseDirectDraw),     TEXT("Display"),  CPF_Config );
	new(GetClass(),TEXT("UseDirectInput"),    RF_Public)UBoolProperty(CPP_PROPERTY(UseDirectInput),    TEXT("Display"),  CPF_Config );
	new(GetClass(),TEXT("UseJoystick"),       RF_Public)UBoolProperty(CPP_PROPERTY(UseJoystick),       TEXT("Display"),  CPF_Config );
	new(GetClass(),TEXT("StartupFullscreen"), RF_Public)UBoolProperty(CPP_PROPERTY(StartupFullscreen), TEXT("Display"),  CPF_Config );
	new(GetClass(),TEXT("SlowVideoBuffering"),RF_Public)UBoolProperty(CPP_PROPERTY(SlowVideoBuffering),TEXT("Display"),  CPF_Config );
	new(GetClass(),TEXT("DeadZoneXYZ"),       RF_Public)UBoolProperty(CPP_PROPERTY(DeadZoneXYZ),       TEXT("Joystick"), CPF_Config );
	new(GetClass(),TEXT("DeadZoneRUV"),       RF_Public)UBoolProperty(CPP_PROPERTY(DeadZoneRUV),       TEXT("Joystick"), CPF_Config );
	new(GetClass(),TEXT("InvertVertical"),    RF_Public)UBoolProperty(CPP_PROPERTY(InvertVertical),    TEXT("Joystick"), CPF_Config );
	new(GetClass(),TEXT("ScaleXYZ"),          RF_Public)UFloatProperty(CPP_PROPERTY(ScaleXYZ),         TEXT("Joystick"), CPF_Config );
	new(GetClass(),TEXT("ScaleRUV"),          RF_Public)UFloatProperty(CPP_PROPERTY(ScaleRUV),         TEXT("Joystick"), CPF_Config );

	unguard;
}

//
// DirectDraw driver enumeration callback.
//
BOOL WINAPI UWindowsClient::EnumDriversCallbackA( GUID* GUID, ANSICHAR* DriverDescription, ANSICHAR* DriverName, void* Context )
{
	guard(UWindowsViewport::EnumDriversCallback);
	UWindowsClient* Client = (UWindowsClient *)Context;
	debugf( TEXT("   %s (%s)"), appFromAnsi(DriverName), appFromAnsi(DriverDescription) );
	Client->DirectDrawGUIDs.AddItem( GUID ? *(FGuid*)GUID : FGuid(0,0,0,0) );
	return DDENUMRET_OK;
	unguard;
}

//
// DirectDraw mode enumeration callback.
//
HRESULT WINAPI UWindowsClient::EnumModesCallback( DDSURFACEDESC* SurfaceDesc, void* Context )
{
	guard(UWindowsViewport::EnumModesCallback);
	((TArray<FVector>*)Context)->AddUniqueItem( FVector(SurfaceDesc->dwWidth,SurfaceDesc->dwHeight,SurfaceDesc->ddpfPixelFormat.dwRGBBitCount) );
	return DDENUMRET_OK;
	unguard;
}

//
// Initialize the platform-specific viewport manager subsystem.
// Must be called after the Unreal object manager has been initialized.
// Must be called before any viewports are created.
//
void UWindowsClient::Init( UEngine* InEngine )
{
	guard(UWindowsClient::UWindowsClient);

	// Init base.
	UClient::Init( InEngine );

	// Register window class.
	IMPLEMENT_WINDOWCLASS(WWindowsViewportWindow,GIsEditor ? (CS_DBLCLKS|CS_OWNDC) : (CS_OWNDC));

	// Create a working DC compatible with the screen, for CreateDibSection.
	hMemScreenDC = CreateCompatibleDC( NULL );
	if( !hMemScreenDC )
		appErrorf( TEXT("CreateCompatibleDC failed: %s"), appGetSystemErrorMessage() );

	// Get mouse info.
	SystemParametersInfoX( SPI_GETMOUSE, 0, NormalMouseInfo, 0 );
	debugf( NAME_Init, TEXT("Mouse info: %i %i %i"), NormalMouseInfo[0], NormalMouseInfo[1], NormalMouseInfo[2] );
	CaptureMouseInfo[0] = 0;     // First threshold.
	CaptureMouseInfo[1] = 0;     // Second threshold.
	CaptureMouseInfo[2] = 65536; // Speed.

	// Init DirectDraw.
	for( ; ; )
	{
		// Skip out.
		if
		(	!UseDirectDraw
		||	ParseParam(appCmdLine(),TEXT("noddraw"))
		||	appStricmp(GConfig->GetStr(TEXT("Engine.Engine"),TEXT("GameRenderDevice")),TEXT("GlideDrv.GlideRenderDevice"))==0
		||	appStricmp(GConfig->GetStr(TEXT("Engine.Engine"),TEXT("GameRenderDevice")),TEXT("D3DDrv.D3DRenderDevice"))==0 )
		{
			break;
		}
		debugf( NAME_Init, TEXT("Initializing DirectDraw") );

		// Load DirectDraw DLL.
		HINSTANCE Instance = LoadLibraryX(TEXT("ddraw.dll"));
		if( Instance == NULL )
		{
			debugf( NAME_Init, TEXT("DirectDraw not installed") );
			break;
		}
		ddCreateFunc = (DD_CREATE_FUNC)GetProcAddress( Instance, "DirectDrawCreate" );
		ddEnumFunc   = (DD_ENUM_FUNC)GetProcAddress( Instance, "DirectDrawEnumerateA" );
		if( !ddCreateFunc || !ddEnumFunc )
		{
			debugf( NAME_Init, TEXT("DirectDraw GetProcAddress failed") );
			break;
		}

		// Show available DirectDraw drivers.
		debugf( NAME_Log, TEXT("DirectDraw drivers:") );
		ddEnumFunc( EnumDriversCallbackA, this );
		if( !DirectDrawGUIDs.Num() )
		{
			debugf( NAME_Init, TEXT("No DirectDraw drivers found") );
			break;
		}

		// Init direct draw and see if it's available.
		IDirectDraw* dd1;
		HRESULT Result = (*ddCreateFunc)( NULL, &dd1, NULL );
		if( Result != DD_OK )
		{
			debugf( NAME_Init, TEXT("DirectDraw created failed: %s"), ddError(Result) );
   			break;
		}
		Result = dd1->QueryInterface( IID_IDirectDraw2, (void**)&dd );
		dd1->Release();
		if( Result != DD_OK )
		{
			debugf( NAME_Init, TEXT("DirectDraw2 interface not available") );
   			break;
		}
		debugf( NAME_Init, TEXT("DirectDraw initialized successfully") );

		// Get list of DirectDraw modes.
		for( INT c=0; c<ARRAY_COUNT(DirectDrawModes); c++ )
		{
			if( c!=1 && c!=2 && c!=3 && c!=4 && c!=7 && c!=8 )
				continue;
			DDSURFACEDESC SurfaceDesc; 
			appMemzero( &SurfaceDesc, sizeof(DDSURFACEDESC) );
			SurfaceDesc.dwSize                        = sizeof(DDSURFACEDESC);
			SurfaceDesc.dwFlags                       = DDSD_PIXELFORMAT;
			SurfaceDesc.ddpfPixelFormat.dwSize        = sizeof(DDPIXELFORMAT);
			SurfaceDesc.ddpfPixelFormat.dwFlags       = DDPF_RGB;
			SurfaceDesc.ddpfPixelFormat.dwRGBBitCount = c*8;
			dd->EnumDisplayModes( 0, &SurfaceDesc, &DirectDrawModes[c], EnumModesCallback );
			for( INT i=0; i<DirectDrawModes[c].Num(); i++ )
				for( INT j=0; j<i; j++ )
					if( DirectDrawModes[c](j).X>DirectDrawModes[c](i).X || (DirectDrawModes[c](j).X==DirectDrawModes[c](i).X && DirectDrawModes[c](j).Y>DirectDrawModes[c](i).Y) )
						Exchange( DirectDrawModes[c](i), DirectDrawModes[c](j) );
			INT q=0;
			if( DirectDrawModes[c].FindItem(FVector(320,240,0),q) )
				DirectDrawModes[c].RemoveItem(FVector(320,200,0));
		}

		// Successfuly initialized DirectDraw.
		break;
	}

	if( UseDirectInput && !ParseParam(appCmdLine(),TEXT("safe")) )
	{
		for( ; ; )
		{
			// Init DirectInput
			HINSTANCE Instance = LoadLibraryX(TEXT("dinput.dll"));
			if( Instance == NULL )
			{
				debugf( NAME_Init, TEXT("DirectInput not installed") );
				break;
			}
			diCreateFunc = (DI_CREATE_FUNC)GetProcAddress( Instance, "DirectInputCreateA" ); //!!W version for UNICODE?
			if( !diCreateFunc )
			{
				debugf( NAME_Init, TEXT("DirectInput GetProcAddress failed") );
				diShutdown();
				break;
			}
			HRESULT Result = (*diCreateFunc)( hInstance, 0x0500, &di, NULL );
			if( Result != DI_OK )
			{
				debugf( NAME_Init, TEXT("DirectInput created failed: %s"), diError(Result) );
				diShutdown();
   				break;
			}
			debugf( NAME_Init, TEXT("DirectInput initialized successfully.") );
			break;
		}
	}

	// Fix up the environment variables for 3dfx.
	_putenv( "SST_RGAMMA=" );
	_putenv( "SST_GGAMMA=" );
	_putenv( "SST_BGAMMA=" );
	_putenv( "FX_GLIDE_NO_SPLASH=1" );

	// Note configuration.
	PostEditChange();

	// Default res option.
	if( ParseParam(appCmdLine(),TEXT("defaultres")) )
	{
		WindowedViewportX  = FullscreenViewportX  = 640;
		WindowedViewportY  = FullscreenViewportY  = 480;
	}

	// Success.
	debugf( NAME_Init, TEXT("Client initialized") );
	unguard;
}

void UWindowsClient::diShutdown()
{
	guard(UWindowsClient::diShutdown);
    if (di) 
    { 
		di->Release();
        di = NULL; 
    } 
	unguard;
} 
 
//
// Shut down the platform-specific viewport manager subsystem.
//
void UWindowsClient::Destroy()
{
	guard(UWindowsClient::Destroy);

	// Shutdown DirectInput
	diShutdown();

	// Shut down DirectDraw.
	if( dd )
	{
		ddEndMode();
		HRESULT Result = dd->Release();
		if( Result != DD_OK )
			debugf( NAME_Exit, TEXT("DirectDraw Release failed: %s"), ddError(Result) );
		else
			debugf( NAME_Exit, TEXT("DirectDraw released") );
		dd = NULL;
	}

	// Stop capture.
	SetCapture( NULL );
	ClipCursor( NULL );
	SystemParametersInfoX( SPI_SETMOUSE, 0, NormalMouseInfo, 0 );

	// Clean up Windows resources.
	if( !DeleteDC( hMemScreenDC ) )
		debugf( NAME_Exit, TEXT("DeleteDC failed %i"), GetLastError() );

	debugf( NAME_Exit, TEXT("Windows client shut down") );
	Super::Destroy();
	unguard;
}

//
// Failsafe routine to shut down viewport manager subsystem
// after an error has occured. Not guarded.
//
void UWindowsClient::ShutdownAfterError()
{
	debugf( NAME_Exit, TEXT("Executing UWindowsClient::ShutdownAfterError") );
	SetCapture( NULL );
	ClipCursor( NULL );
	SystemParametersInfoX( SPI_SETMOUSE, 0, NormalMouseInfo, 0 );
  	ShowCursor( TRUE );
	if( Engine && Engine->Audio )
	{
		Engine->Audio->ConditionalShutdownAfterError();
	}
	for( INT i=Viewports.Num()-1; i>=0; i-- )
	{
		UWindowsViewport* Viewport = (UWindowsViewport*)Viewports( i );
		Viewport->ConditionalShutdownAfterError();
	}
	ddEndMode();
	Super::ShutdownAfterError();
}

void UWindowsClient::NotifyDestroy( void* Src )
{
	guard(UWindowsClient::NotifyDestroy);
	if( Src==ConfigProperties )
	{
		ConfigProperties = NULL;
		if( ConfigReturnFullscreen && Viewports.Num() )
			Viewports(0)->Exec( TEXT("ToggleFullscreen") );
	}
	unguard;
}

//
// Command line.
//
UBOOL UWindowsClient::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(UWindowsClient::Exec);
	if( UClient::Exec( Cmd, Ar ) )
	{
		return 1;
	}
	return 0;
	unguard;
}

//
// Perform timer-tick processing on all visible viewports.  This causes
// all realtime viewports, and all non-realtime viewports which have been
// updated, to be blitted.
//
void UWindowsClient::Tick()
{
	guard(UWindowsClient::Tick);

	// Blit any viewports that need blitting.
	UWindowsViewport* BestViewport = NULL;
  	for( INT i=0; i<Viewports.Num(); i++ )
	{
		UWindowsViewport* Viewport = CastChecked<UWindowsViewport>(Viewports(i));
		check(!Viewport->HoldCount);
		if( !IsWindow(Viewport->Window->hWnd) )
		{
			// Window was closed via close button.
			delete Viewport;
			return;
		}
  		else if
		(	Viewport->IsRealtime()
		&&	Viewport->SizeX
		&&	Viewport->SizeY
		&&	(!BestViewport || Viewport->LastUpdateTime<BestViewport->LastUpdateTime) )
		{
			BestViewport = Viewport;
		}
	}
	if( BestViewport )
		BestViewport->Repaint( 1 );
	unguard;
}

//
// Create a new viewport.
//
UViewport* UWindowsClient::NewViewport( const FName Name )
{
	guard(UWindowsClient::NewViewport);
	return new( this, Name )UWindowsViewport();
	unguard;
}

//
// End the current DirectDraw mode.
//
void UWindowsClient::ddEndMode()
{
	guard(UWindowsClient::ddEndMode);
	if( dd )
	{
		// Return to normal cooperative level.
		debugf( NAME_Log, TEXT("DirectDraw End Mode") );
		HRESULT Result = dd->SetCooperativeLevel( NULL, DDSCL_NORMAL );
		if( Result!=DD_OK )
			debugf( NAME_Log, TEXT("DirectDraw SetCooperativeLevel: %s"), ddError(Result) );

		// Restore the display mode.
		Result = dd->RestoreDisplayMode();
		if( Result!=DD_OK )
			debugf( NAME_Log, TEXT("DirectDraw RestoreDisplayMode: %s"), ddError(Result) );

		// Flip to GDI surface (may return error code; this is ok).
		dd->FlipToGDISurface();
	}
	if( !GIsCriticalError )
	{
		// Flush the cache unless we're ending DirectDraw due to a crash.
		debugf( NAME_Log, TEXT("Flushing cache") );
		GCache.Flush();
	}
	unguard;
}

//
// Configuration change.
//
void UWindowsClient::PostEditChange()
{
	guard(UWindowsClient::PostEditChange);
	Super::PostEditChange();

	// Joystick.
	appMemzero( &JoyCaps, sizeof(JoyCaps) );
	if( UseJoystick && !ParseParam(appCmdLine(),TEXT("NoJoy")) && !GIsEditor )
	{
		INT nJoys = joyGetNumDevs();
		if( !nJoys )
			debugf( TEXT("No joystick detected") );
		if( joyGetDevCapsA(JOYSTICKID1,&JoyCaps,sizeof(JoyCaps))==JOYERR_NOERROR )
			debugf( TEXT("Detected joysticks: %i (%s)"), nJoys, JoyCaps.szOEMVxD ? appFromAnsi(JoyCaps.szOEMVxD) : TEXT("None") );
		else debugf( TEXT("joyGetDevCaps failed") );
	}

	unguard;
}

//
// Enable or disable all viewport windows that have ShowFlags set (or all if ShowFlags=0).
//
void UWindowsClient::EnableViewportWindows( DWORD ShowFlags, int DoEnable )
{
	guard(UWindowsClient::EnableViewportWindows);
  	for( int i=0; i<Viewports.Num(); i++ )
	{
		UWindowsViewport* Viewport = (UWindowsViewport*)Viewports(i);
		if( (Viewport->Actor->ShowFlags & ShowFlags)==ShowFlags )
			EnableWindow( Viewport->Window->hWnd, DoEnable );
	}
	unguard;
}

//
// Show or hide all viewport windows that have ShowFlags set (or all if ShowFlags=0).
//
void UWindowsClient::ShowViewportWindows( DWORD ShowFlags, int DoShow )
{
	guard(UWindowsClient::ShowViewportWindows); 	
	for( int i=0; i<Viewports.Num(); i++ )
	{
		UWindowsViewport* Viewport = (UWindowsViewport*)Viewports(i);
		if( (Viewport->Actor->ShowFlags & ShowFlags)==ShowFlags )
			Viewport->Window->Show(DoShow);
	}
	unguard;
}

//
// Make this viewport the current one.
// If Viewport=0, makes no viewport the current one.
//
void UWindowsClient::MakeCurrent( UViewport* InViewport )
{
	guard(UWindowsViewport::MakeCurrent);
	for( INT i=0; i<Viewports.Num(); i++ )
	{
		UViewport* OldViewport = Viewports(i);
		if( OldViewport->Current && OldViewport!=InViewport )
		{
			OldViewport->Current = 0;
			OldViewport->UpdateWindowFrame();
		}
	}
	if( InViewport )
	{
		InViewport->Current = 1;
		InViewport->UpdateWindowFrame();
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	Getting error messages.
-----------------------------------------------------------------------------*/
