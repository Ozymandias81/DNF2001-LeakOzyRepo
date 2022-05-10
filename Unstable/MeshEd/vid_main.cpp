//****************************************************************************
//**
//**    VID_MAIN.CPP
//**    Video System
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "stdtool.h"
//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
static HINSTANCE vid_dll=NULL;
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
#if 0
void VID_Init(void)
{
	char *dllname;
	vid_export_t *(__cdecl *vidQueryAPI)(vid_import_t *import);
	vid_export_t *videxp;
    int xRes=640, yRes=480;
    int parm;

	//dllname = "drivers\\vidglide.dll";
#if 0
	char long_path[1024];
	GetCurrentDirectory(1024,long_path);
	SYS_Error(long_path);
#endif
	dllname = "drivers\\vidglide.dll";
	vid_dll = LoadLibrary(dllname);
	if (!vid_dll)
		SYS_Error("Unable to load video driver %s", dllname);
	vidQueryAPI = (vid_export_t *(__cdecl *)(vid_import_t *))GetProcAddress(vid_dll, "VID_QueryAPI");
	if (!vidQueryAPI)
		SYS_Error("Cannot locate VID_QueryAPI in %s", dllname);
	
	sys.Error = SYS_Error;
	sys.SafeMalloc = SYS_SafeMalloc;
	sys.SafeFree = SYS_SafeFree;
	sys.GetFilePath = SYS_GetFilePath;
	sys.GetFileRoot = SYS_GetFileRoot;
	sys.GetFileName = SYS_GetFileName;
	sys.GetFileExtention = SYS_GetFileExtention;
	sys.ForceFileExtention = SYS_ForceFileExtention;
	sys.SuggestFileExtention = SYS_SuggestFileExtention;
	sys.GetTimeFloat = SYS_GetTimeFloat;
		
	videxp = vidQueryAPI(&sys);
	memcpy(&vid, videxp, sizeof(vid_export_t));

	if (vid.vidApiVersion != VID_API_VERSION)
		SYS_Error("Video driver is version %d, expecting version %d", vid.vidApiVersion, VID_API_VERSION);
	
    if (parm = SYS_CheckParm("vidres", 2))
    {
        xRes = atoi(sys_argv[parm+1]);
        yRes = atoi(sys_argv[parm+2]);
    }
    
    vid.Init(xRes, yRes);

	vid_dllActive = 1;
}

void VID_Shutdown()
{
	if (vid_dll)
	{
		if ((vid_dllActive) && (!sys_infatalblock))
		{
			vid.Shutdown();
			if (!FreeLibrary(vid_dll))
				SYS_Error("Unable to free video driver");
		}
		vid_dll = NULL;
		vid_dllActive = 0;
	}
}
#endif

//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------


//****************************************************************************
//**
//**    END MODULE VID_MAIN.CPP
//**
//****************************************************************************

