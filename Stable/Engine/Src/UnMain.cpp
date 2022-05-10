#include "EnginePrivate.h"
#include "UnEngineWin.h"

/*-----------------------------------------------------------------------------
	Splash screen.
-----------------------------------------------------------------------------*/
//
// Splash screen, implemented with old-style Windows code so that it
// can be opened super-fast before initialization.
//
BOOL CALLBACK SplashDialogProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
	if( uMsg==WM_DESTROY )
		PostQuitMessage(0);
	return 0;
}

HWND    hWndSplash = NULL;
HBITMAP hBitmap    = NULL;
INT     BitmapX    = 0;
INT     BitmapY    = 0;
DWORD   ThreadId   = 0;
HANDLE  hThread    = 0;

DWORD has_splash=FALSE;
HANDLE splash_event=NULL;

DWORD WINAPI ThreadProc( VOID* Parm )
{
	WORD splash_id=(WORD)Parm;

	/* activate thread message loop */
	MSG msg;
	PeekMessage(&msg,NULL,WM_USER,WM_USER,PM_NOREMOVE);
	SetEvent(splash_event);

	hWndSplash = CreateDialogW(GetModuleHandle(NULL),MAKEINTRESOURCEW(splash_id), NULL, SplashDialogProc);
	if( hWndSplash )
	{
		HWND hWndLogo = GetDlgItem(hWndSplash,IDC_Logo);
		if( hWndLogo )
		{
			SetWindowPos(hWndSplash,HWND_TOPMOST,(GetSystemMetrics(SM_CXSCREEN)-BitmapX)/2,(GetSystemMetrics(SM_CYSCREEN)-BitmapY)/2,BitmapX,BitmapY,SWP_SHOWWINDOW);
			SetWindowPos(hWndSplash,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE|SWP_NOSIZE);
			SendMessageX( hWndLogo, STM_SETIMAGE, IMAGE_BITMAP, (LPARAM)hBitmap );
			UpdateWindow( hWndSplash );
			
			int res;
			while(res=GetMessageA(&msg,NULL,0,0))
			{
				if (res==-1)
					break;
				DispatchMessageX(&msg);
			}
		}
		DestroyWindow( hWndSplash );
	}
	else
	{
		DWORD ret;

		ret=GetLastError();
	}
	return 0;
}

void InitSplash(const TCHAR* Filename,DWORD splash_id)
{
	if (has_splash)
		debugf(TEXT("InitSplash: called while splash already exists"));

	has_splash=TRUE;

	if (!splash_event)
		splash_event=CreateEventA(NULL,FALSE,FALSE,"SplashActive");

	FWindowsBitmap Bitmap(1);
	if( Filename )
	{
		verify(Bitmap.LoadFile(Filename) );
		hBitmap = Bitmap.GetBitmapHandle();
		BitmapX = Bitmap.SizeX;
		BitmapY = Bitmap.SizeY;
	}

	hThread=CreateThread(NULL,0,&ThreadProc,(void *)splash_id,0,&ThreadId);
}

void ExitSplash(void)
{
	/* message queue must be active before posting. */
	if (has_splash)
		WaitForSingleObject(splash_event,0);

	if( ThreadId )
	{
		TCHAR_CALL_OS(PostThreadMessageW(ThreadId,WM_QUIT,0,0),PostThreadMessageA(ThreadId,WM_QUIT,0,0));
	}

	has_splash=FALSE;
}


/*-----------------------------------------------------------------------------
	IPC Stupidity
-----------------------------------------------------------------------------*/
static IpcHook_f ipc_hook=NULL;

void IpcHookInit(IpcHook_f hook)
{
	ipc_hook=hook;
}


/*-----------------------------------------------------------------------------
	Startup and shutdown.
-----------------------------------------------------------------------------*/

//
// Initialize.
//
HANDLE RunMutex;
UEngine* InitEngine(DWORD splash_id)
{
	DOUBLE LoadTime = appSeconds();

	// Set exec hook.
	static FExecHook GLocalHook;
	GExec = &GLocalHook;

	// Create mutex so installer knows we're running.
	RunMutex = CreateMutexX( NULL, 0, TEXT("UnrealIsRunning"));
	UBOOL AlreadyRunning = (GetLastError()==ERROR_ALREADY_EXISTS);

	// First-run menu.
	INT FirstRun=0;
	GConfig->GetInt( TEXT("FirstRun"), TEXT("FirstRun"), FirstRun );
	if( ParseParam(appCmdLine(),TEXT("FirstRun")) )
		FirstRun=0;

	// Commandline (for mplayer/heat)
	FString Command;
	if( Parse(appCmdLine(),TEXT("consolecommand="), Command) )
	{
		debugf(TEXT("Executing console command %s"),*Command);
		GExec->Exec( *Command, *GLog );
		return NULL;
	}

	// Test render device.
	FString Device;
	if( Parse(appCmdLine(),TEXT("testrendev="),Device) )
	{
		debugf(TEXT("Detecting %s"),*Device);
		try
		{
			UClass* Cls = LoadClass<URenderDevice>( NULL, *Device, NULL, 0, NULL );
			GConfig->SetInt(*Device,TEXT("DescFlags"),RDDESCF_Incompatible);
			GConfig->Flush(0);
			if( Cls )
			{
				URenderDevice* RenDev = ConstructObject<URenderDevice>(Cls);
				if( RenDev )
				{
					if( RenDev->Init(NULL,0,0,0,0) )
					{
						debugf(TEXT("Successfully detected %s"),*Device);
					}
					else delete RenDev;
				}
			}
		} catch( ... ) {}
		FArchive* Ar = GFileManager->CreateFileWriter(TEXT("Detected.ini"),0);
		if( Ar )
			delete Ar;
		return NULL;
	}

	// Config UI.
	if( !GIsEditor && GIsClient )
	{
		WConfigWizard D;
		WWizardPage* Page = NULL;
		if( ParseParam(appCmdLine(),TEXT("safe")) || appStrfind(appCmdLine(),TEXT("readini")) )
			{Page = new WConfigPageSafeMode(&D); D.Title=LocalizeGeneral(TEXT("SafeMode"),TEXT("Startup"));}
		else if( FirstRun<ENGINE_VERSION )
			{Page = new WConfigPageRenderer(&D); D.Title=LocalizeGeneral(TEXT("FirstTime"),TEXT("Startup"));}
		else if( ParseParam(appCmdLine(),TEXT("changevideo")) )
			{Page = new WConfigPageRenderer(&D); D.Title=LocalizeGeneral(TEXT("Video"),TEXT("Startup"));}
		else if( !AlreadyRunning && GFileManager->FileSize(TEXT("Running.ini"))>=0 )
		{
			int IgnoreSafeMode;
			GConfig->GetInt( TEXT("SafeMode"), TEXT("IgnoreSafeMode"), IgnoreSafeMode );
			if(!IgnoreSafeMode)
				Page = new WConfigPageSafeMode(&D); D.Title=LocalizeGeneral(TEXT("RecoveryMode"),TEXT("Startup"));
		}

		if( Page )
		{
			ExitSplash();
			D.Advance( Page );
			if( !D.DoModal() )
				return NULL;
			InitSplash(NULL,splash_id);
		}
	}

	// Create is-running semaphore file.
	FArchive* Ar = GFileManager->CreateFileWriter(TEXT("Running.ini"),0);
	if( Ar )
		delete Ar;

	// Update first-run.
	if( FirstRun<ENGINE_VERSION )
		FirstRun = ENGINE_VERSION;
	GConfig->SetInt( TEXT("FirstRun"), TEXT("FirstRun"), FirstRun );

	// Cd check.
	FString CdPath;
	GConfig->GetString( TEXT("Engine.Engine"), TEXT("CdPath"), CdPath );
	if
	(	CdPath!=TEXT("")
	&&	GFileManager->FileSize(TEXT("..\\Textures\\Palettes.utx"))<=0 )//oldver
	{
		FString Check = CdPath * TEXT("Textures\\Palettes.utx");
		while( !GIsEditor && GFileManager->FileSize(*Check)<=0 )
		{
			if( MessageBox
			(
				NULL,
				LocalizeGeneral("InsertCdText",TEXT("Window")),
				LocalizeGeneral("InsertCdTitle",TEXT("Window")),
				MB_TASKMODAL|MB_OKCANCEL
			)==IDCANCEL )
			{
				GIsCriticalError = 1;
				ExitProcess( 0 );
			}
		}
	}

	// Create the global engine object.
	UClass* EngineClass;
	if( !GIsEditor )
	{
		// Create game engine.
		EngineClass = UObject::StaticLoadClass( UGameEngine::StaticClass(), NULL, TEXT("ini:Engine.Engine.GameEngine"), NULL, LOAD_NoFail, NULL );
	}
	else
	{
		// Editor.
		EngineClass = UObject::StaticLoadClass( UEngine::StaticClass(), NULL, TEXT("ini:Engine.Engine.EditorEngine"), NULL, LOAD_NoFail, NULL );
	}
	UEngine* Engine = ConstructObject<UEngine>( EngineClass );
	Engine->Init();
	debugf( TEXT("Startup time: %f seconds"), appSeconds()-LoadTime );

	return Engine;
}

//
// Unreal's main message loop.  All windows in Unreal receive messages
// somewhere below this function on the stack.
//
void MainLoop(UEngine* Engine,U32 needs_ipc)
{
	check(Engine);

	// Enter main loop.
	if( GLogWindow )
		GLogWindow->SetExec( Engine );

	// Loop while running.
	GIsRunning = 1;
	DWORD ThreadId = GetCurrentThreadId();
	HANDLE hThread = GetCurrentThread();
	DOUBLE OldTime = appSeconds();
	DOUBLE SecondStartTime = OldTime;
	INT TickCount = 0;
	while( GIsRunning && !GIsRequestingExit )
	{
		// Update the world.
		DOUBLE NewTime   = appSeconds();
		FLOAT  DeltaTime = NewTime - OldTime;
		Engine->Tick( DeltaTime );
		if( GWindowManager )
			GWindowManager->Tick( DeltaTime );
		OldTime = NewTime;
		TickCount++;
		if( OldTime > SecondStartTime + 1 )
		{
			Engine->CurrentTickRate = (FLOAT)TickCount / (OldTime - SecondStartTime);
			SecondStartTime = OldTime;
			TickCount = 0;
		}

		// Enforce optional maximum tick rate.
		FLOAT MaxTickRate = Engine->GetMaxTickRate();
		if( MaxTickRate>0.0 )
		{
			FLOAT Delta = (1.0/MaxTickRate) - (appSeconds()-OldTime);
			appSleep( Max(0.f,Delta) );
		}


		if (ipc_hook)
			ipc_hook();

		// Handle all incoming messages.
		MSG Msg;
		while( PeekMessageX(&Msg,NULL,0,0,PM_REMOVE) )
		{
			if( Msg.message == WM_QUIT )
				GIsRequestingExit = 1;

			TranslateMessage( &Msg );

			DispatchMessageX( &Msg );
		}

		// If editor thread doesn't have the focus, don't suck up too much CPU time.
		if( GIsEditor )
		{
			static UBOOL HadFocus=1;
			UBOOL HasFocus = (GetWindowThreadProcessId(GetForegroundWindow(),NULL) == ThreadId );
			if( HadFocus && !HasFocus )
			{
				// Drop our priority to speed up whatever is in the foreground.
				SetThreadPriority( hThread, THREAD_PRIORITY_BELOW_NORMAL );
			}
			else if( HasFocus && !HadFocus )
			{
				// Boost our priority back to normal.
				SetThreadPriority( hThread, THREAD_PRIORITY_NORMAL );
			}
			if( !HasFocus )
			{
				// Surrender the rest of this timeslice.
				Sleep(0);
			}
			HadFocus = HasFocus;
		}
	}
	GIsRunning = 0;

	// Remove the running mutex.
	ReleaseMutex( RunMutex );

	// Exit main loop.
	if( GLogWindow )
		GLogWindow->SetExec( NULL );
	GExec = NULL;
}

void WConfigPageDetail::OnInitDialog(void)
{
	WWizardPage::OnInitDialog();
	FString Info;

	INT DescFlags=0;
	FString Driver = GConfig->GetStr(TEXT("Engine.Engine"),TEXT("GameRenderDevice"));
	GConfig->GetInt(*Driver,TEXT("DescFlags"),DescFlags);

	// Frame rate dependent LOD.
	if( Driver==TEXT("SoftDrv.SoftwareRenderDevice") || 280.0*1000.0*1000.0*GSecondsPerCycle>1.f )
	{
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("MinDesiredFrameRate"), TEXT("20") );
	}
	else if( Driver==TEXT("D3DDrv.D3DRenderDevice") )
	{
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("MinDesiredFrameRate"), TEXT("28") );
	}

	// Sound quality.
	if( !GIsMMX || GPhysicalMemory <= 32*1024*1024 )
	{
		Info = Info + LocalizeGeneral(TEXT("SoundLow"),TEXT("Startup")) + TEXT("\r\n");
		GConfig->SetString( TEXT("Galaxy.GalaxyAudioSubsystem"), TEXT("UseReverb"),       TEXT("False") );
		GConfig->SetString( TEXT("Galaxy.GalaxyAudioSubsystem"), TEXT("OutputRate"),      TEXT("11025Hz") );
		GConfig->SetString( TEXT("Galaxy.GalaxyAudioSubsystem"), TEXT("UseSpatial"),      TEXT("False") );
		GConfig->SetString( TEXT("Galaxy.GalaxyAudioSubsystem"), TEXT("UseFilter"),       TEXT("False") );
		GConfig->SetString( TEXT("Galaxy.GalaxyAudioSubsystem"), TEXT("EffectsChannels"), TEXT("8") );
		GConfig->SetString( TEXT("Botpack.TournamentPlayer"),    TEXT("AnnouncerVolume"), TEXT("false") );
		GConfig->SetString( TEXT("Botpack.TournamentPlayer"),    TEXT("bNoVoiceTaunts"),  TEXT("true") );		
		GConfig->SetBool( TEXT("Galaxy.GalaxyAudioSubsystem"), TEXT("LowSoundQuality"), 1 );
	}
	else
	{
		Info = Info + LocalizeGeneral(TEXT("SoundHigh"),TEXT("Startup")) + TEXT("\r\n");
	}

	// Skins.
	if( (GPhysicalMemory < 96*1024*1024) || (DescFlags&RDDESCF_LowDetailSkins) )
	{
		Info = Info + LocalizeGeneral(TEXT("SkinsLow"),TEXT("Startup")) + TEXT("\r\n");
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("SkinDetail"), TEXT("Medium") );
	}
	else
	{
		Info = Info + LocalizeGeneral(TEXT("SkinsHigh"),TEXT("Startup")) + TEXT("\r\n");
	}

	// World.
	if( (GPhysicalMemory < 64*1024*1024) || (DescFlags&RDDESCF_LowDetailWorld) )
	{
		Info = Info + LocalizeGeneral(TEXT("WorldLow"),TEXT("Startup")) + TEXT("\r\n");
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("TextureDetail"), TEXT("Medium") );
	}
	else
	{
		Info = Info + LocalizeGeneral(TEXT("WorldHigh"),TEXT("Startup")) + TEXT("\r\n");
	}

	// Resolution.
	if( (!GIsMMX || !GIsPentiumPro) && Driver==TEXT("SoftDrv.SoftwareRenderDevice") )
	{
		Info = Info + LocalizeGeneral(TEXT("ResLow"),TEXT("Startup")) + TEXT("\r\n");
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("WindowedViewportX"),  TEXT("320") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("WindowedViewportY"),  TEXT("240") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("WindowedColorBits"),  TEXT("16") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("FullscreenViewportX"), TEXT("320") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("FullscreenViewportY"), TEXT("240") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("FullscreenColorBits"), TEXT("16") );
	}
	else if( Driver==TEXT("SoftDrv.SoftwareRenderDevice") || (DescFlags&RDDESCF_LowDetailWorld) )
	{
		Info = Info + LocalizeGeneral(TEXT("ResLow"),TEXT("Startup")) + TEXT("\r\n");
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("WindowedViewportX"),  TEXT("512") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("WindowedViewportY"),  TEXT("384") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("WindowedColorBits"),  TEXT("16") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("FullscreenViewportX"), TEXT("512") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("FullscreenViewportY"), TEXT("384") );
		GConfig->SetString( TEXT("WinDrv.WindowsClient"), TEXT("FullscreenColorBits"), TEXT("16") );
	}
	else
	{
		Info = Info + LocalizeGeneral(TEXT("ResHigh"),TEXT("Startup")) + TEXT("\r\n");
	}
	DetailEdit.SetText(*Info);
}

UBOOL FExecHook::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	if( ParseCommand(&Cmd,TEXT("ShowLog")) )
	{
		if( GLogWindow )
		{
			GLogWindow->Show(1);
			SetFocus( *GLogWindow );
			GLogWindow->Display.ScrollCaret();
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("TakeFocus")) )
	{
		TObjectIterator<UEngine> EngineIt;
		if
		(	EngineIt
		&&	EngineIt->Client
		&&	EngineIt->Client->Viewports.Num() )
			SetForegroundWindow( (HWND)EngineIt->Client->Viewports(0)->GetWindow() );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("EditActor")) )
	{
		UClass* Class;
		TObjectIterator<UEngine> EngineIt;
		if( EngineIt && ParseObject<UClass>( Cmd, TEXT("Class="), Class, ANY_PACKAGE ) )
		{
			AActor* Player  = EngineIt->Client ? EngineIt->Client->Viewports(0)->Actor : NULL;
			AActor* Found   = NULL;
			FLOAT   MinDist = 999999.0;
			for( TObjectIterator<AActor> It; It; ++It )
			{
				FLOAT Dist = Player ? FDist(It->Location,Player->Location) : 0.0;
				if
				(	(!Player || It->GetLevel()==Player->GetLevel())
				&&	(!It->bDeleteMe)
				&&	(It->IsA( Class) )
				&&	(Dist<MinDist) )
				{
					MinDist = Dist;
					Found   = *It;
				}
			}
			if( Found )
			{
				WObjectProperties* P = new WObjectProperties( TEXT("EditActor"), 0, TEXT(""), NULL, 1 );
				P->OpenWindow( (HWND)EngineIt->Client->Viewports(0)->GetWindow() );
				P->Root.SetObjects( (UObject**)&Found, 1 );
				P->Show(1);
			}
			else Ar.Logf( TEXT("Actor not found") );
		}
		else Ar.Logf( TEXT("Missing class") );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("EditTraceActor")) )
	{
		TObjectIterator<UEngine> EngineIt;
		if ( !EngineIt )
			return 1;

		APlayerPawn* Player = EngineIt->Client ? ((APlayerPawn*) EngineIt->Client->Viewports(0)->Actor) : NULL;
		if ( !Player )
			return 1;

		FVector DrawOffset = Player->BaseEyeHeight * FVector(0,0,1);
		FVector TraceStart = Player->Location + DrawOffset;
		FVector TraceEnd   = TraceStart + (Player->ViewRotation.Vector()*1000.f);
		FVector TraceExtent = FVector(0,0,0);
		FCheckResult Hit(1.0);
		DWORD TraceFlags;
		TraceFlags = TRACE_AllColliding | TRACE_ProjTargets;
		Player->GetLevel()->SingleLineCheck( Hit, Player, TraceEnd, TraceStart, TraceFlags, TraceExtent, 0, FALSE );
		if (Hit.Actor)
		{
			WObjectProperties* P = new WObjectProperties( TEXT("EditTraceActor"), 0, TEXT(""), NULL, 1 );
			P->OpenWindow( (HWND) EngineIt->Client->Viewports(0)->GetWindow() );
			P->Root.SetObjects( (UObject**)&Hit.Actor, 1 );
			P->Show(1);
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("HideLog")) )
	{
		if( GLogWindow )
			GLogWindow->Show(0);
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("Preferences")) && !GIsClient )
	{
		if( !Preferences )
		{
			Preferences = new WConfigProperties( TEXT("Preferences"), LocalizeGeneral("AdvancedOptionsTitle",TEXT("Window")) );
			Preferences->SetNotifyHook( this );
			Preferences->OpenWindow( GLogWindow ? GLogWindow->hWnd : NULL );
			Preferences->ForceRefresh();
		}
		Preferences->Show(1);
		SetFocus( *Preferences );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("MPLAYER")) && GIsClient )
	{
		LaunchMplayer();			
		return 1;			
	}
	else if( ParseCommand(&Cmd,TEXT("HEAT")) && GIsClient )
	{
		appLaunchURL( TEXT("GotoHEAT.exe"), TEXT("5193") );
		return 1;			
	}
	else return 0;
}
