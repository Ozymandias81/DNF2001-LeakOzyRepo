//****************************************************************************
//**
//**    CBLMACED.CPP
//**    Cannibal Model Actor Configuration Editor
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Cannibal.h"
#include <windows.h>
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    PRIVATE DATA
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static void APP_Shutdown()
{
	IPC_Shutdown();
	OBJ_Shutdown();
	PLG_Shutdown(); // must happen after object shutdown so plugin object classes will still be loaded when destroyed
	MSG_Shutdown();
	LOG_Shutdown();
}
static void Quit()
{
	APP_Shutdown();
	exit(0);
}
static void APP_Init()
{
	STR_ArgInit(__argc, __argv);
	FILE_BoxInit(NULL);
	LOG_Init("CblMacEd", Quit, LOGLVL_Normal, LOGLVLF_HideLevel);
	LOG_AddTarget(LOG_GetStockTarget(LOGTARGET_Console));
	LOG_AddTarget(LOG_GetStockTarget(LOGTARGET_File));
	MSG_Init();
	OBJ_Init(OObject::GetStaticClass());
	//PLG_Init(NULL);
	PLG_Init(".\\");
	TIME_Init();
	IPC_Init("IPC_CBLMACED");
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrevInst, LPSTR argList, int winMode)
{
	APP_Init();
	
	NChar* basePath = NULL;
	if (STR_Argc() > 1)
		basePath = STR_Argv(1);
	else
		basePath = FILE_DirBox("Select Base Directory");
	if (!basePath)
		basePath = ".\\";
	CPJ_SetBasePath(basePath);
	
	NDword ipcHook = 0;
	if (STR_Argc() > 2)
		ipcHook = atoi(STR_Argv(2));

	MAC_EditBox(ipcHook);

	APP_Shutdown();
	return(0);
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE CBLMACED.CPP
//**
//****************************************************************************

