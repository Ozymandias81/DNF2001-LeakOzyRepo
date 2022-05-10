//****************************************************************************
//**
//**    KERNEL.CPP
//**    Kernel
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "MsgMain.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class CblDll
{
public:
	CblDll(void);
	U32 attach_process(XHandle handle);
	U32 detach_process(XHandle handle);
	U32 attach_thread(XHandle handle);
	U32 detach_thread(XHandle handle);
	U32 init(void);
};

//============================================================================
//    PRIVATE DATA
//============================================================================
static HINSTANCE krn_hInstDLL = NULL;
static OSVERSIONINFO os_version;
static WinVersion com_version;
static WinVersion shell_version;
static WinVersion shlwapi_version;
static CblDll _cbl;
//============================================================================
//    GLOBAL DATA
//============================================================================
U32 is_win2k=FALSE;
U32 is_new_gui=FALSE;

//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
/* no memory allocation allowed in this constructor */
CblDll::CblDll(void)
{
	/* just sets up assembly offsets */
	InitMsgAsm();
}

U32 CblDll::attach_process(XHandle handle)
{
	init();
	krn_hInstDLL = (HINSTANCE)handle;
	return TRUE;
}

U32 CblDll::detach_process(XHandle handle)
{
	return TRUE;
}

U32 CblDll::attach_thread(XHandle handle)
{
	return TRUE;
}

U32 CblDll::detach_thread(XHandle handle)
{
	return TRUE;
}

U32 CblDll::init(void)
{
	os_version.dwOSVersionInfoSize=sizeof(OSVERSIONINFO);
	GetVersionEx(&os_version);
	is_win2k=FALSE;
	if (os_version.dwPlatformId==VER_PLATFORM_WIN32_NT)
	{
		/* so hopefully this will work for whistler too */
		if (os_version.dwMajorVersion>=5)
			is_win2k=TRUE;
	}
	
	/* initialize OLE */
	OleInitialize(null);
	
	KRN_GetDllVersion("comctl32.dll",&com_version);
	KRN_GetDllVersion("shell32.dll",&shell_version);
	KRN_GetDllVersion("shlwapi.dll",&shlwapi_version);

	is_new_gui=FALSE;
	if ((com_version.equal_or_better(5,80)) &&
		(shell_version.equal_or_better(5,0)) && 
		(shlwapi_version.equal_or_better(5,0)))
	{
		is_new_gui=TRUE;
	}
	
	return TRUE;
}

BOOL WINAPI DllMain(HINSTANCE hmodule, DWORD reason, LPVOID lpvReserved)
{
	switch(reason)
	{
		case DLL_PROCESS_ATTACH:
			return _cbl.attach_process(hmodule);
		case DLL_THREAD_ATTACH:
			return _cbl.attach_thread(hmodule);
		case DLL_PROCESS_DETACH:
			return _cbl.detach_process(hmodule);
		case DLL_THREAD_DETACH:
			return _cbl.detach_thread(hmodule);
	}
	return TRUE;
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void* KRN_GetModuleHandle()
{
	return(krn_hInstDLL);
}

class AutoLibrary
{
	HMODULE hinst;
public:
	AutoLibrary(void) : hinst(null) {}
	~AutoLibrary(void){FreeLibrary(hinst);}

	inline AutoLibrary &operator = (HMODULE handle)
	{
		hinst=handle;
		return *this;
	}
};

typedef struct
{
    DWORD cbSize;
    DWORD dwMajorVersion;                   // Major version
    DWORD dwMinorVersion;                   // Minor version
    DWORD dwBuildNumber;                    // Build number
    DWORD dwPlatformID;                     // DLLVER_PLATFORM_*
}KRN_DLLVERSIONINFO;

typedef U32 (__stdcall *DllGetVersionProc)(KRN_DLLVERSIONINFO *vinfo);

#define PACKVERSION(major,minor) MAKELONG(minor,major)

KRN_API U32 KRN_GetDllVersion(CC8 *name,WinVersion *version)
{
	/* autofrees library if we load it */
	AutoLibrary library;
	HMODULE hinst_dll;

	hinst_dll=GetModuleHandle(name);
	if (!hinst_dll)
	{
		hinst_dll=LoadLibrary(name);
		library=hinst_dll;
		if (!hinst_dll)
			return FALSE;
	}

	DllGetVersionProc dll_get_version;

	dll_get_version=(DllGetVersionProc)GetProcAddress(hinst_dll,"DllGetVersion");
	if (!dll_get_version)
		return FALSE;

	KRN_DLLVERSIONINFO dvi;
	memset(&dvi,0,sizeof(KRN_DLLVERSIONINFO));
	dvi.cbSize=sizeof(KRN_DLLVERSIONINFO);
	if (dll_get_version(&dvi)!=NOERROR)
		return FALSE;

	version->set(dvi.dwMajorVersion,dvi.dwMinorVersion);
	return TRUE;
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE KERNEL.CPP
//**
//****************************************************************************

