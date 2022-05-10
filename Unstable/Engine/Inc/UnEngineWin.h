/*=============================================================================
	UnEngineWin.h: Unreal engine windows-specific code.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Tim Sweeney.
=============================================================================*/

#pragma DISABLE_OPTIMIZATION /* Avoid VC++ code generation bug */


/*-----------------------------------------------------------------------------
	System Directories.
-----------------------------------------------------------------------------*/

TCHAR SysDir[256]=TEXT(""), WinDir[256]=TEXT(""), ThisFile[256]=TEXT("");
void InitSysDirs()
{
#if UNICODE
	if( !GUnicodeOS )
	{
		ANSICHAR ASysDir[256]="", AWinDir[256]="", AThisFile[256]="";
		GetSystemDirectoryA( ASysDir, ARRAY_COUNT(ASysDir) );
		GetWindowsDirectoryA( AWinDir, ARRAY_COUNT(AWinDir) );
		GetModuleFileNameA( NULL, AThisFile, ARRAY_COUNT(AThisFile) );
		appStrcpy( SysDir, ANSI_TO_TCHAR(ASysDir) );
		appStrcpy( WinDir, ANSI_TO_TCHAR(AWinDir) );
		appStrcpy( ThisFile, ANSI_TO_TCHAR(AThisFile) );
	}
	else
#endif
	{
		GetSystemDirectory( SysDir, ARRAY_COUNT(SysDir) );
		GetWindowsDirectory( WinDir, ARRAY_COUNT(WinDir) );
		GetModuleFileName( NULL, ThisFile, ARRAY_COUNT(ThisFile) );
	}
}

/*-----------------------------------------------------------------------------
	Config wizard.
-----------------------------------------------------------------------------*/

class WConfigWizard : public WWizardDialog
{
	DECLARE_WINDOWCLASS(WConfigWizard,WWizardDialog,Startup)
	WLabel LogoStatic;
	FWindowsBitmap LogoBitmap;
	UBOOL Cancel;
	FString Title;
	WConfigWizard()
	: LogoStatic(this,IDC_Logo)
	, Cancel(0)
	{
		InitSysDirs();
	}
	void OnInitDialog()
	{
		WWizardDialog::OnInitDialog();
		SendMessageX( *this, WM_SETICON, ICON_BIG, (WPARAM)LoadIconIdX(hInstance,IDICON_Mainframe) );
		LogoBitmap.LoadFile( TEXT("..\\system\\LogoSmall.bmp") );
		SendMessageX( LogoStatic, STM_SETIMAGE, IMAGE_BITMAP, (LPARAM)LogoBitmap.GetBitmapHandle() );
		SetText( *Title );
		SetForegroundWindow( hWnd );
	}
};

class WConfigPageFirstTime : public WWizardPage
{
	DECLARE_WINDOWCLASS(WConfigPageFirstTime,WWizardPage,Startup)
	WConfigWizard* Owner;
	WConfigPageFirstTime( WConfigWizard* InOwner )
	: WWizardPage( TEXT("ConfigPageFirstTime"), IDDIALOG_ConfigPageFirstTime, InOwner )
	, Owner(InOwner)
	{}
	const TCHAR* GetNextText()
	{
		return LocalizeGeneral(TEXT("Run"),TEXT("Startup"));
	}
	WWizardPage* GetNext()
	{
		Owner->EndDialog(1);
		return NULL;
	}	
};

class WConfigPageSafeOptions : public WWizardPage
{
	DECLARE_WINDOWCLASS(WConfigPageSafeOptions,WWizardPage,Startup)
	WConfigWizard* Owner;
	WButton NoSoundButton, No3DSoundButton, No3DVideoButton, WindowButton, ResButton, ResetConfigButton, NoProcessorButton, NoJoyButton;
	WConfigPageSafeOptions( WConfigWizard* InOwner )
	: WWizardPage		( TEXT("ConfigPageSafeOptions"), IDDIALOG_ConfigPageSafeOptions, InOwner )
	, Owner				(InOwner)
	, NoSoundButton		(this,IDC_NoSound)
	, No3DSoundButton	(this,IDC_No3DSound)
	, No3DVideoButton	(this,IDC_No3dVideo)
	, WindowButton		(this,IDC_Window)
	, ResButton			(this,IDC_Res)
	, ResetConfigButton	(this,IDC_ResetConfig)
	, NoProcessorButton	(this,IDC_NoProcessor)
	, NoJoyButton		(this,IDC_NoJoy)
	{}
	void OnInitDialog()
	{
		WWizardPage::OnInitDialog();
		SendMessageX( NoSoundButton,     BM_SETCHECK, 1, 0 );
		SendMessageX( No3DSoundButton,   BM_SETCHECK, 1, 0 );
		SendMessageX( No3DVideoButton,   BM_SETCHECK, 1, 0 );
		SendMessageX( WindowButton,      BM_SETCHECK, 1, 0 );
		SendMessageX( ResButton,         BM_SETCHECK, 1, 0 );
		SendMessageX( ResetConfigButton, BM_SETCHECK, 0, 0 );
		SendMessageX( NoProcessorButton, BM_SETCHECK, 1, 0 );
		SendMessageX( NoJoyButton,       BM_SETCHECK, 1, 0 );
	}
	const TCHAR* GetNextText()
	{
		return LocalizeGeneral(TEXT("Run"),TEXT("Startup"));
	}
	WWizardPage* GetNext()
	{
		FString CmdLine;
		if( SendMessageX(NoSoundButton,BM_GETCHECK,0,0)==BST_CHECKED )
			CmdLine+=TEXT(" -nosound");
		if( SendMessageX(No3DSoundButton,BM_GETCHECK,0,0)==BST_CHECKED )
			CmdLine+=TEXT(" -no3dsound");
		if( SendMessageX(No3DSoundButton,BM_GETCHECK,0,0)==BST_CHECKED )
			CmdLine+=TEXT(" -nohard");
		if( SendMessageX(No3DSoundButton,BM_GETCHECK,0,0)==BST_CHECKED )
			CmdLine+=TEXT(" -nohard -noddraw");
		if( SendMessageX(No3DSoundButton,BM_GETCHECK,0,0)==BST_CHECKED )
			CmdLine+=TEXT(" -defaultres");
		if( SendMessageX(NoProcessorButton,BM_GETCHECK,0,0)==BST_CHECKED )
			CmdLine+=TEXT(" -nommx -nokni -nok6");
		if( SendMessageX(NoJoyButton,BM_GETCHECK,0,0)==BST_CHECKED )
			CmdLine+=TEXT(" -nojoy");
		if( SendMessageX(ResetConfigButton,BM_GETCHECK,0,0)==BST_CHECKED )
			GFileManager->Delete( *(FString(appPackage())+TEXT(".ini")) );
		ShellExecuteX( NULL, TEXT("open"), ThisFile, *CmdLine, appBaseDir(), SW_SHOWNORMAL );
		Owner->EndDialog(0);
		return NULL;
	}
};

class WConfigPageDetail : public WWizardPage
{
	DECLARE_WINDOWCLASS(WConfigPageDetail,WWizardPage,Startup)
	WConfigWizard* Owner;
	WEdit DetailEdit;
	WConfigPageDetail( WConfigWizard* InOwner )
	: WWizardPage( TEXT("ConfigPageDetail"), IDDIALOG_ConfigPageDetail, InOwner )
	, Owner(InOwner)
	, DetailEdit(this,IDC_DetailEdit)
	{}
	void OnInitDialog(void);
	WWizardPage* GetNext()
	{
		return new WConfigPageFirstTime(Owner);
	}
};

class WConfigPageDriver : public WWizardPage
{
	DECLARE_WINDOWCLASS(WConfigPageDriver,WWizardPage,Startup)
	WConfigWizard* Owner;
	WUrlButton WebButton;
	WLabel Card;
	WConfigPageDriver( WConfigWizard* InOwner )
	: WWizardPage( TEXT("ConfigPageDriver"), IDDIALOG_ConfigPageDriver, InOwner )
	, Owner(InOwner)
	, WebButton(this,LocalizeGeneral(TEXT("Direct3DWebPage"),TEXT("Startup")),IDC_WebButton)
	, Card(this,IDC_Card)
	{}
	void OnInitDialog()
	{
		WWizardPage::OnInitDialog();
		FString CardName=GConfig->GetStr(TEXT("D3DDrv.D3DRenderDevice"),TEXT("Description"));
		if( CardName!=TEXT("") )
			Card.SetText(*CardName);
	}
	WWizardPage* GetNext()
	{
		return new WConfigPageDetail(Owner);
	}	
};

class WConfigPageRenderer : public WWizardPage
{
	DECLARE_WINDOWCLASS(WConfigPageRenderer,WWizardPage,Startup)
	WConfigWizard* Owner;
	WListBox RenderList;
	WButton ShowCompatible, ShowAll;
	WLabel RenderNote;
	INT First;
	TArray<FRegistryObjectInfo> Classes;
	WConfigPageRenderer( WConfigWizard* InOwner )
	: WWizardPage( TEXT("ConfigPageRenderer"), IDDIALOG_ConfigPageRenderer, InOwner )
	, Owner(InOwner)
	, RenderList(this,IDC_RenderList)
	, ShowCompatible(this,IDC_Compatible,FDelegate(this,(TDelegate)RefreshList))
	, ShowAll(this,IDC_All,FDelegate(this,(TDelegate)RefreshList))
	, RenderNote(this,IDC_RenderNote)
	, First(0)
	{}
	void RefreshList()
	{
		RenderList.Empty();
		INT All=(SendMessageX(ShowAll,BM_GETCHECK,0,0)==BST_CHECKED), BestPriority=0;
		FString Default;
		Classes.Empty();
		UObject::GetRegistryObjects( Classes, UClass::StaticClass(), URenderDevice::StaticClass(), 0 );
		for( TArray<FRegistryObjectInfo>::TIterator It(Classes); It; ++It )
		{
			FString Path=It->Object, Left, Right, Temp;
			if( Path.Split(TEXT("."),&Left,&Right) )
			{
				INT DoShow=All, Priority=0;
				INT DescFlags=0;
				GConfig->GetInt(*Path,TEXT("DescFlags"),DescFlags);
				if
				(	It->Autodetect!=TEXT("")
				&& (GFileManager->FileSize(*FString::Printf(TEXT("%s\\%s"), SysDir, *It->Autodetect))>=0
				||  GFileManager->FileSize(*FString::Printf(TEXT("%s\\%s"), WinDir, *It->Autodetect))>=0) )
					DoShow = Priority = 3;
				else if( DescFlags & RDDESCF_Certified )
					DoShow = Priority = 2;
				if( DoShow )
				{
					RenderList.AddString( *(Temp=Localize(*Right,TEXT("ClassCaption"),*Left)) );
					if( Priority>=BestPriority )
						{Default=Temp; BestPriority=Priority;}
				}
			}
		}
		if( Default!=TEXT("") )
			RenderList.SetCurrent(RenderList.FindStringChecked(*Default),1);
		CurrentChange();
	}
	void CurrentChange()
	{
		RenderNote.SetText(Localize(TEXT("Descriptions"),*CurrentDriver(),TEXT("Startup"),NULL,1));
	}
	void OnPaint()
	{
		if( !First++ )
		{
			UpdateWindow( *this );
			GConfig->Flush( 1 );
			if( !ParseParam(appCmdLine(),TEXT("nodetect")) )
			{
				GFileManager->Delete(TEXT("Detected.ini"));
				ShellExecuteX( NULL, TEXT("open"), ThisFile, TEXT("testrendev=D3DDrv.D3DRenderDevice log=Detected.log"), appBaseDir(), SW_SHOWNORMAL );
				for( INT MSec=10000; MSec>0 && GFileManager->FileSize(TEXT("Detected.ini"))<0; MSec-=100 )
					Sleep(100);
			}
			RefreshList();
		}
	}
	void OnCurrent()
	{
	}
	void OnInitDialog()
	{
		WWizardPage::OnInitDialog();
		SendMessageX(ShowCompatible,BM_SETCHECK,BST_CHECKED,0);
		RenderList.SelectionChangeDelegate = FDelegate(this,(TDelegate)CurrentChange);
		RenderList.DoubleClickDelegate = FDelegate(Owner,(TDelegate)WWizardDialog::OnNext);
		RenderList.AddString( LocalizeGeneral(TEXT("Detecting"),TEXT("Startup")) );
	}
	FString CurrentDriver()
	{
		if( RenderList.GetCurrent()>=0 )
		{
			FString Name = RenderList.GetString(RenderList.GetCurrent());
			for( TArray<FRegistryObjectInfo>::TIterator It(Classes); It; ++It )
			{
				FString Path=It->Object, Left, Right, Temp;
				if( Path.Split(TEXT("."),&Left,&Right) )
					if( Name==Localize(*Right,TEXT("ClassCaption"),*Left) )
						return Path;
			}
		}
		return TEXT("");
	}
	WWizardPage* GetNext()
	{
		if( CurrentDriver()!=TEXT("") )
			GConfig->SetString(TEXT("Engine.Engine"),TEXT("GameRenderDevice"),*CurrentDriver());
		if( CurrentDriver()==TEXT("D3DDrv.D3DRenderDevice") )
			return new WConfigPageDriver(Owner);
		else
			return new WConfigPageDetail(Owner);
	}
};

class WConfigPageSafeMode : public WWizardPage
{
	DECLARE_WINDOWCLASS(WConfigPageSafeMode,WWizardPage,Startup)
	WConfigWizard* Owner;
	WCoolButton RunButton, VideoButton, SafeModeButton, WebButton;
	WConfigPageSafeMode( WConfigWizard* InOwner )
	: WWizardPage    ( TEXT("ConfigPageSafeMode"), IDDIALOG_ConfigPageSafeMode, InOwner )
	, RunButton      ( this, IDC_Run,      FDelegate(this,(TDelegate)OnRun) )
	, VideoButton    ( this, IDC_Video,    FDelegate(this,(TDelegate)OnVideo) )
	, SafeModeButton ( this, IDC_SafeMode, FDelegate(this,(TDelegate)OnSafeMode) )
	, WebButton      ( this, IDC_Web,      FDelegate(this,(TDelegate)OnWeb) )
	, Owner          (InOwner)
	{}
	void OnRun()
	{
		Owner->EndDialog(1);
	}
	void OnVideo()
	{
		Owner->Advance( new WConfigPageRenderer(Owner) );
	}
	void OnSafeMode()
	{
		Owner->Advance( new WConfigPageSafeOptions(Owner) );
	}
	void OnWeb()
	{
		ShellExecuteX( *this, TEXT("open"), LocalizeGeneral(TEXT("WebPage"),TEXT("Startup")), TEXT(""), appBaseDir(), SW_SHOWNORMAL );
		Owner->EndDialog(0);
	}
	const TCHAR* GetNextText()
	{
		return NULL;
	}
};

/*-----------------------------------------------------------------------------
	Launch mplayer.com.
	- by Jack Porter
	- Based on mp_launch2.c by Rich Rice --rich@mpath.com
-----------------------------------------------------------------------------*/

#define MPI_FILE TEXT("mput.mpi")
#define MPLAYNOW_EXE TEXT("mplaynow.exe")

static int GetMplayerDirectory(TCHAR *mplayer_directory)
{
	HKEY hkey;
	HKEY key = HKEY_LOCAL_MACHINE;
	TCHAR subkey[]=TEXT("software\\mpath\\mplayer\\main");
	TCHAR valuename[]=TEXT("root directory");
	TCHAR buffer[MAX_PATH];
	DWORD dwType, dwSize;
	
	if( RegOpenKeyExX(key, subkey, 0, KEY_READ, &hkey) == ERROR_SUCCESS )
	{
		dwSize = MAX_PATH;
		if( RegQueryValueExX(hkey, valuename, 0, &dwType, (LPBYTE) buffer, &dwSize) == ERROR_SUCCESS )
		{
			appSprintf(mplayer_directory, TEXT("%s"), buffer);
			return 1;
		}
		RegCloseKey(hkey);
	}

	return 0;
}

static void LaunchMplayer()
{
	TCHAR mplaunch_exe[MAX_PATH], mplayer_directory[MAX_PATH];

	if( GetMplayerDirectory(mplayer_directory) )
	{
		appSprintf( mplaunch_exe, TEXT("%s\\programs\\mplaunch.exe"), mplayer_directory );
		if( GFileManager->FileSize(mplaunch_exe)>0 )
		{
			appLaunchURL( mplaunch_exe, MPI_FILE );
			return;
		}
	}

	appLaunchURL( MPLAYNOW_EXE, TEXT("") );
}

#undef MPI_FILE
#undef MPLAYNOW_EXE

/*-----------------------------------------------------------------------------
	Exec hook.
-----------------------------------------------------------------------------*/

// FExecHook.
class FExecHook : public FExec, public FNotifyHook
{
private:
	WConfigProperties* Preferences;
	void NotifyDestroy( void* Src )
	{
		if( Src==Preferences )
			Preferences = NULL;
	}
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar );
public:
	FExecHook()
	: Preferences( NULL )
	{}
};

ENGINE_API UEngine* InitEngine(DWORD splash_id);
ENGINE_API void MainLoop(UEngine* Engine,DWORD needs_ipc);
ENGINE_API void InitSplash(const TCHAR* Filename,DWORD splash_id);
ENGINE_API void ExitSplash(void);
typedef void (* IpcHook_f)(void);
ENGINE_API void IpcHookInit(IpcHook_f hook);


/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
