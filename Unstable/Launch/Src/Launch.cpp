/*=============================================================================
	Launch.cpp: Game launcher.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Tim Sweeney.
=============================================================================*/

#include "LaunchPrivate.h"
#include "UnEngineWin.h"

/*-----------------------------------------------------------------------------
	Global variables.
-----------------------------------------------------------------------------*/

// General.
extern "C" {HINSTANCE hInstance;}
extern "C" {TCHAR GPackage[64]=TEXT("Launch");}

//#define DEBUG_ALLOC

// Memory allocator.
#if defined(_DEBUG) && defined(DEBUG_ALLOC)
	#include "FMallocDebug.h"
	FMallocDebug Malloc;
#else
	#include "FMallocWindows.h"
	FMallocWindows Malloc;
#endif

// Log file.
#include "FOutputDeviceFile.h"
FOutputDeviceFile Log;

// Error handler.
#include "FOutputDeviceWindowsError.h"
FOutputDeviceWindowsError Error;

// Feedback.
#include "FFeedbackContextWindows.h"
FFeedbackContextWindows Warn;

// File manager.
#if 0
#include "FFileManagerWindows.h"
FFileManagerWindows FileManager;
#else
#include <stdio.h>
#include <io.h>
#include <direct.h>
#include <errno.h>
#include <sys/stat.h>
#include <richedit.h>
#include "FFileManagerAnsi.h"
FFileManagerAnsi FileManager;
#endif
// Config.
#include "FConfigCacheIni.h"

#pragma warning( disable : 4505 )  /*  "Unreferenced local function removed"  */

//#if 0

/*-----------------------------------------------------------------------------
	Crash Handler.
-----------------------------------------------------------------------------*/
#include "mail.h"
#undef _T
#include "BugslayerUtil.h"
#pragma comment(lib,"bugslayerutil.lib")
#pragma comment(lib,"Comctl32.lib")

BOOL __stdcall EnumerateProcessWindows(HWND Hwnd,LPARAM lParam)
{
    static char Name[256];
	static char Buffer[1024];
    DWORD CurrentProcessID;

    if(!GetParent(Hwnd)
      &&GetWindowTextLength(Hwnd)
      &&IsWindowVisible(Hwnd))
    {
    	GetWindowThreadProcessId(Hwnd,&CurrentProcessID);
        GetWindowTextA(Hwnd,Name,sizeof(Name));		
		sprintf(Buffer,"[%08x] %s\n",CurrentProcessID,Name);
		strcat((char *)lParam,Buffer);
    }

    return TRUE;
}

LONG __stdcall CrashHandler( EXCEPTION_POINTERS *pExPtrs )
{
	static char BugTextBuffer[32767]; // Used to prevent having to allocate memory from the possibly corrpted heap.
	static char TempBuffer[4096], TempBuffer2[4096];
	strcpy(BugTextBuffer,"--- Fault Reason ---\n");

	strcat(BugTextBuffer,GetFaultReason(pExPtrs));
	strcat(BugTextBuffer,"\n\n");

	strcat(BugTextBuffer,"--- Register Dump ---\n");
	strcat(BugTextBuffer,GetRegisterString(pExPtrs));
	strcat(BugTextBuffer,"\n\n");

	strcat(BugTextBuffer,"--- Stack Trace ---\n");

	/* Do stack trace: */
	char *StackLevel=GetFirstStackTraceString(GSTSO_MODULE|GSTSO_SYMBOL|GSTSO_SRCLINE,pExPtrs);
	while(StackLevel)
	{
		strcat(BugTextBuffer,StackLevel);
		strcat(BugTextBuffer,"\n");

		/* In-place unicode conversion, to avoid exacerbating stack bugs */				
		static TCHAR UnicodeString[2048];
		TCHAR *UnicodeStringIndex=UnicodeString;

		while(*UnicodeStringIndex++=*StackLevel++)
			;

		StackLevel=GetNextStackTraceString(GSTSO_MODULE|GSTSO_SYMBOL|GSTSO_SRCLINE,pExPtrs);
	}             

	strcat(BugTextBuffer,"\n--- Memory Status ---\n");

	// Memory information:
	static MEMORYSTATUS stat;
	GlobalMemoryStatus (&stat);
	sprintf(TempBuffer,"%ld%% of memory currently in use\n"
					   "Physical memory: %.2lfM / %.2lfM\n"
					   "Page file: %.2lfM / %.2lfM\n"
					   "Virtual memory:%.2lfM / %.2lfM\n",
						stat.dwMemoryLoad,
						(stat.dwTotalPhys-stat.dwAvailPhys)/(1024.0*1024.0), stat.dwTotalPhys/(1024.0*1024.0),		 
						(stat.dwTotalPageFile-stat.dwAvailPageFile)/(1024.0*1024.0), stat.dwTotalPageFile/(1024.0*1024.0),
						(stat.dwTotalVirtual-stat.dwAvailVirtual)/(1024.0*1024.0),stat.dwTotalVirtual/(1024.0*1024.0));

	strcat(BugTextBuffer,TempBuffer);
	// Grab the processes working set:
	static DWORD WsMin=0, WsMax=0;
	GetProcessWorkingSetSize( GetCurrentProcess(), &WsMin, &WsMax );
	sprintf(TempBuffer,"Working set: %X / %X\n",WsMin,WsMax);
	strcat(BugTextBuffer,TempBuffer);

	// Drive Information:
	strcat(BugTextBuffer,"\n--- Drive Status ---\n");

	// Build up a list of logical drives and their types:
	GetLogicalDriveStringsA(sizeof(TempBuffer),TempBuffer);
	static char *TempBufferIndex=TempBuffer;
	while(*TempBufferIndex)
	{
		char *CurrentDrive=TempBufferIndex;
		
		strcat(BugTextBuffer,CurrentDrive);
		strcat(BugTextBuffer," - ");
		int DriveType=GetDriveTypeA(CurrentDrive);
		if((DriveType!=DRIVE_REMOVABLE) && (DriveType!=DRIVE_CDROM) && (DriveType!=DRIVE_UNKNOWN))
		{
			static __int64 FreeBytesAvailable, TotalNumberOfBytes;
			FreeBytesAvailable=TotalNumberOfBytes=0;
			GetDiskFreeSpaceExA(CurrentDrive,(PULARGE_INTEGER)&FreeBytesAvailable, (PULARGE_INTEGER)&TotalNumberOfBytes, NULL);
			sprintf(TempBuffer2,"%.1lfM/%.1lfM ",(TotalNumberOfBytes-FreeBytesAvailable)/(1024.0*1024.0),TotalNumberOfBytes/(1024.0*1024.0));
			strcat(BugTextBuffer,TempBuffer2);
		}

		switch(DriveType)
		{
			case DRIVE_NO_ROOT_DIR: strcat(BugTextBuffer,"[Invalid]");		break;
			case DRIVE_REMOVABLE:	strcat(BugTextBuffer,"[Removable]");	break;
			case DRIVE_FIXED:		strcat(BugTextBuffer,"[Fixed]");		break;
			case DRIVE_REMOTE:		strcat(BugTextBuffer,"[Remote]");		break;
			case DRIVE_CDROM:		strcat(BugTextBuffer,"[CD-ROM]");		break;
			case DRIVE_RAMDISK:		strcat(BugTextBuffer,"[RAMDisk]");		break;
			case DRIVE_UNKNOWN:		
			default: strcat(BugTextBuffer,"[Unknown]"); break;
		}
/*
		static char LongPath[MAX_PATH];
		char *PathPtr;
		GetFullPathNameA(CurrentDrive,sizeof(LongPath),LongPath,&PathPtr);
		//if(strcmp(LongPath,CurrentDrive))
		{
			strcat(BugTextBuffer,"\t");
			strcat(BugTextBuffer,LongPath);
		}
*/
		strcat(BugTextBuffer,"\n");

		
		while(*TempBufferIndex) TempBufferIndex++;
		TempBufferIndex++;
	}


	/* Append the os information: */
	strcat(BugTextBuffer,"\n--- System Information ---\n");
	static OSVERSIONINFOA osv;
	osv.dwOSVersionInfoSize=sizeof(osv);
	GetVersionExA(&osv);

	static char *OSString="";
	switch(osv.dwPlatformId)
	{
		case VER_PLATFORM_WIN32_NT:  if(osv.dwMajorVersion>=5) OSString=(osv.dwMajorVersion>=5)?"2000":"NT"; break;
		case VER_PLATFORM_WIN32_WINDOWS: OSString="95/98/ME"; break;
	}
	sprintf(TempBuffer,"Microsoft Windows %s %s (Version:%u.%u, Build:%u) \n",OSString, osv.szCSDVersion, osv.dwMajorVersion, osv.dwMinorVersion,  osv.dwBuildNumber);
	strcat(BugTextBuffer,TempBuffer);

	sprintf(TempBuffer,"Up Time: %.2f hours\n",GetTickCount()/1000.0f/60.0f/60.0f);
	strcat(BugTextBuffer,TempBuffer);
	

	// Get the current directory:
	GetCurrentDirectoryA(sizeof(TempBuffer),TempBuffer);
	strcat(BugTextBuffer,"Current Directory:");
	strcat(BugTextBuffer,TempBuffer);
	strcat(BugTextBuffer,"\n");
	
	GetWindowsDirectoryA(TempBuffer,sizeof(TempBuffer));
	strcat(BugTextBuffer,"Windows Directory:");
	strcat(BugTextBuffer,TempBuffer);
	strcat(BugTextBuffer,"\n");

	GetSystemDirectoryA(TempBuffer,sizeof(TempBuffer));
	strcat(BugTextBuffer,"System Directory:");
	strcat(BugTextBuffer,TempBuffer);
	strcat(BugTextBuffer,"\n");

	

	/* Append the build status: */
	strcat(BugTextBuffer,"\n--- Build Information ---\n");
	#define makestring(x) #x
	#define stringize( x ) makestring(x)

	strcat(BugTextBuffer,__FILE__ " Modified: " __TIMESTAMP__ "\n");
	strcat(BugTextBuffer,__FILE__ " Built: " __DATE__ "," __TIME__ "\n");
	strcat(BugTextBuffer,"Settings: " 
#ifdef _DEBUG
		"_DEBUG "
#endif
#ifdef NDEBUG
		"NDEBUG "
#endif
#ifdef __STDC__
		"__STDC__ "
#endif
#ifdef __cplusplus
		"__cplusplus "
#endif
#ifdef _CHAR_UNSIGNED
		"_CHAR_UNSIGNED "
#endif		
#ifdef _CPPRTTI
		"_CPPRTTI "
#endif
#ifdef _CPPUNWIND
		"_CPPUNWIND "
#endif
#ifdef _DLL
		"_DLL "
#endif 
#ifdef _M_ALPHA
		"_M_ALPHA "
#endif
#ifdef _M_IX86
		"_M_IX86=" stringize(_M_IX86) " "
#endif
#ifdef _M_MPPC
		"_M_MPPC=" stringize(_M_MPPC) " "
#endif
#ifdef _M_MRX000
		"_M_MRX000=" stringize(_M_MRX000) " "
#endif
#ifdef _M_PPC
		"_M_PPC=" stringize(_M_PPC) " "
#endif
#ifdef _MFC_VER
		"_MFC_VER=" stringize(_MFC_VER) " "
#endif
#ifdef _MSC_EXTENSIONS
		"_MSC_EXTENSIONS "
#endif
#ifdef _MSC_VER
		"_MSC_VER=" stringize(_MSC_VER) " "
#endif
#ifdef _MT
		"_MT "
#endif
#ifdef _WIN32
		"_WIN32 "
#endif
		"\n");

	/* Misc unsorted stuff: */
	/*
	strcat(BugTextBuffer,"\n--- Other Processes Running ---\n");	
    EnumWindows((WNDENUMPROC)EnumerateProcessWindows,(long)BugTextBuffer);
	*/
	/* Build the dialog: */
	strcat(BugTextBuffer,"\n *** Would you like to email this information to the coders? ***\n");

	static char subject[1024];
	static char moduleFileName[256];
	GetModuleFileNameA(NULL,moduleFileName,256);

	static char userName[128];
	static char computerName[128];
	DWORD NameSize=sizeof(userName);	GetUserNameA(userName,&NameSize);
	NameSize=sizeof(computerName);		GetComputerNameA(computerName,&NameSize);

	sprintf(subject,"[*** %s CRASH ***] %s/%s",strupr(strrchr(moduleFileName,'\\')+1),computerName,userName);

	//debugf(BugTextBuffer);
	//appErrorf(TEXT("Yo yo yo yo"));
	GIsCriticalError = 1;
	UObject::StaticShutdownAfterError();

	if(IDYES==MessageBoxA(NULL,BugTextBuffer,subject,MB_YESNO))
	{		
		SetCursor(LoadCursor(NULL,IDC_WAIT));

		static char *mailingList[] =
		{
			"<nicks@3drealms.com>",
			"<brandonr@3drealms.com>",
			"<jessc@3drealms.com>",
			"<scotta@3drealms.com>",
			"<andyh@3drealms.com>",
			"<johnp@3drealms.com>",
			NULL
		};

		// Mail the crash to the recipients: 
		//for(DWORD index=0;mailingList[index];index++)
		//	SendMailMessage("smtp.3drealms.com",NULL,mailingList[index], subject, BugTextBuffer);
		SendMultiMailMessage("smtp.3drealms.com",NULL,mailingList,subject,BugTextBuffer);
	}

	exit(EXIT_FAILURE);
	return 1;
}

/*-----------------------------------------------------------------------------
	WinMain.
-----------------------------------------------------------------------------*/

//
// Main entry point.
// This is an example of how to initialize and launch the engine.
//
INT WINAPI WinMain( HINSTANCE hInInstance, HINSTANCE hPrevInstance, char*, INT nCmdShow )
{
	InitCommonControls();
	LoadLibrary(_T("RICHED32.DLL"));
	SetCrashHandlerFilter(CrashHandler);
	debugf(_T("Crash handler installed."));

	// Remember instance.
	INT ErrorLevel = 0;
	GIsStarted     = 1;
	hInstance      = hInInstance;
	const TCHAR* CmdLine = GetCommandLine();
	appStrcpy( GPackage, appPackage() );

	// See if this should be passed to another instances.
	if
	(	!appStrfind(CmdLine,TEXT("Server"))
	&&	!appStrfind(CmdLine,TEXT("NewWindow"))
	&&	!appStrfind(CmdLine,TEXT("changevideo"))
	&&	!appStrfind(CmdLine,TEXT("TestRenDev")) )
	{
		TCHAR ClassName[256];
		MakeWindowClassName(ClassName,TEXT("WLog"));
		for( HWND hWnd=NULL; ; )
		{
			hWnd = TCHAR_CALL_OS(FindWindowExW(hWnd,NULL,ClassName,NULL),FindWindowExA(hWnd,NULL,TCHAR_TO_ANSI(ClassName),NULL));
			if( !hWnd )
				break;
			if( GetPropX(hWnd,TEXT("IsBrowser")) )
			{
				while( *CmdLine && *CmdLine!=' ' )
					CmdLine++;
				if( *CmdLine==' ' )
					CmdLine++;
				COPYDATASTRUCT CD;
				DWORD Result;
				CD.dwData = WindowMessageOpen;
				CD.cbData = (appStrlen(CmdLine)+1)*sizeof(TCHAR*);
				CD.lpData = const_cast<TCHAR*>( CmdLine );
				SendMessageTimeout( hWnd, WM_COPYDATA, (WPARAM)NULL, (LPARAM)&CD, SMTO_ABORTIFHUNG|SMTO_BLOCK, 30000, &Result );
				GIsStarted = 0;
				return 0;
			}
		}
	}

	// NJS: Ensure that only one copy of DukeForever is launched at a time.  more than one could be disasterous to it's configuration.
    GLaunchMutex = (HINSTANCE)::CreateMutex(NULL,TRUE, TEXT("DukeForeverMutex"));
    // NJS: Need to change:
	//if(appStrfind(CmdLine,TEXT("IgnoreMutex")) && GetLastError() == ERROR_ALREADY_EXISTS)
    //{
    //    if(GLaunchMutex) { CloseHandle(GLaunchMutex); GLaunchMutex=NULL; }
    //    return EXIT_FAILURE;
    //}

	// Begin guarded code.
//#undef DO_GUARD
//#define DO_GUARD 0
/*
#if DO_GUARD
#ifndef _DEBUG
	try
	{
#endif
#endif
	*/
		// Init core.
		GIsClient = GIsGuarded = 1;
		appInit( GPackage, CmdLine, &Malloc, &Log, &Error, &Warn, &FileManager, FConfigCacheIni::Factory, 1 );
		if( ParseParam(appCmdLine(),TEXT("MAKE")) )//oldver
			appErrorf( TEXT("'ucc -make' is obsolete, use 'ucc make' now") );

		// Init mode.
		GIsServer     = 1;
		GIsClient     = !ParseParam(appCmdLine(),TEXT("SERVER"));
		GIsEditor     = 0;
		GIsScriptable = 1;
		GLazyLoad     = !GIsClient || ParseParam(appCmdLine(),TEXT("LAZY"));
		//GLazyLoad     = 1;

		// Figure out whether to show log or splash screen.
		UBOOL ShowLog = ParseParam(CmdLine,TEXT("LOG"));
		FString Filename;// = FString(TEXT("..\\Help")) * GPackage + TEXT("Logo.bmp");
		//if( GFileManager->FileSize(*Filename)<0 )s
			Filename = TEXT("Logo.bmp");
		appStrcpy( GPackage, appPackage() );
		if( !ShowLog && !ParseParam(CmdLine,TEXT("server")) && !appStrfind(CmdLine,TEXT("TestRenDev")) )
			InitSplash(*Filename,IDDIALOG_Splash);

		// Init windowing.
		InitWindowing();

		// Create log window, but only show it if ShowLog.
		GLogWindow = new WLog( Log.Filename, Log.LogAr, TEXT("GameLog") );
		GLogWindow->OpenWindow( ShowLog, 0 );
		GLogWindow->Log( NAME_Title, LocalizeGeneral("Start") );
		if( GIsClient )
			SetPropX( *GLogWindow, TEXT("IsBrowser"), (HANDLE)1 );

		// Init engine.
		UEngine* Engine = InitEngine(IDDIALOG_Splash);
		if( Engine )
		{
			GLogWindow->Log( NAME_Title, LocalizeGeneral("Run") );

			// Hide splash screen.
			ExitSplash();

			// Optionally Exec an exec file
			FString Temp;
			if( Parse(CmdLine, TEXT("EXEC="), Temp) )
			{
				Temp = FString(TEXT("exec ")) + Temp;
				if( Engine->Client && Engine->Client->Viewports.Num() && Engine->Client->Viewports(0) )
					Engine->Client->Viewports(0)->Exec( *Temp, *GLogWindow );
			}

			// Start main engine loop, including the Windows message pump.
			if( !GIsRequestingExit )
				MainLoop( Engine,FALSE);
		}

		// Clean shutdown.
		GFileManager->Delete(TEXT("Running.ini"),0,0);
		RemovePropX( *GLogWindow, TEXT("IsBrowser") );
		GLogWindow->Log( NAME_Title, LocalizeGeneral("Exit") );
		delete GLogWindow;
		appPreExit();
		GIsGuarded = 0;
		/*
#if DO_GUARD
#ifndef _DEBUG
	}
	catch( ... )
	{
		// Crashed.
		ErrorLevel = 1;
		Error.HandleError();
	}
#endif
#endif
*/
	debugf(_T("Terminating main loop"));
	// Final shut down.

	appExit();
	GIsStarted = 0;
	return ErrorLevel;
}


/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
