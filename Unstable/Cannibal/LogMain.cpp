//****************************************************************************
//**
//**    LOGMAIN.CPP
//**    Logging
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "LogMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define LOG_MAXTARGETS 256

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class CLogFileTarget
: public ILogTarget
{
private:
	FILE* m_fp;
	NChar m_title[256];

public:
	CLogFileTarget() {}
	~CLogFileTarget() {}

	// ILogTarget
	void Init(NChar* inTitle)
	{
		m_fp = NULL;
		strcpy(m_title, inTitle);
		strcat(m_title, ".log");
	}
	void Shutdown()
	{
		if (m_fp)
		{
			fclose(m_fp);
			m_fp = NULL;
		}
	}
	void Write(NChar* inStr)
	{
		if (!inStr)
			return;
		if (!m_fp)
		{
			m_fp = fopen(m_title, "w");
		}
		if (m_fp)
		{
			fprintf(m_fp, "%s", inStr);
			fflush(m_fp);
		}
	}
};

class CLogConsoleTarget
: public ILogTarget
{
private:
	HANDLE m_hIn, m_hOut;

public:
	CLogConsoleTarget() {}
	~CLogConsoleTarget() {}

	// ILogTarget
	void Init(NChar* inTitle)
	{
		AllocConsole();
		char buf[256];
		sprintf(buf, "%s - Log", inTitle);
		SetConsoleTitle(buf);
		m_hIn = GetStdHandle(STD_INPUT_HANDLE);
		m_hOut = GetStdHandle(STD_OUTPUT_HANDLE);		
		/*
		UpdateWindow(sys_hWnd);
		HWND conWnd = FindWindow(NULL, buf);
		if (conWnd)
		{
			ShowWindow(conWnd, SW_MINIMIZE);
			ShowWindow(conWnd, SW_SHOWNOACTIVATE);
			//SetWindowPos(conWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE|SWP_NOSIZE|SWP_NOACTIVATE);
		}
		ShowWindow(sys_hWnd, SW_SHOWNORMAL);
		UpdateWindow(sys_hWnd);
		*/
	}
	void Shutdown()
	{
		CloseHandle(m_hIn);
		CloseHandle(m_hOut);
		FreeConsole();
	}
	void Write(NChar* inStr)
	{
		if (!inStr)
			return;
		NDword bogo;
		WriteConsole(m_hOut, inStr, strlen(inStr), &bogo, NULL);
	}
};

class CLogDebugTarget
: public ILogTarget
{
public:
	CLogDebugTarget() {}
	~CLogDebugTarget() {}

	// ILogTarget
	void Init(NChar* inTitle) {}
	void Shutdown() {}
	void Write(NChar* inStr)
	{
		if (!inStr)
			return;
		OutputDebugString(inStr);
	}
};

class CLogStdoutTarget
: public ILogTarget
{
public:
	CLogStdoutTarget() {}
	~CLogStdoutTarget() {}

	// ILogTarget
	void Init(NChar* inTitle) {}
	void Shutdown() {}
	void Write(NChar* inStr)
	{
		if (!inStr)
			return;
		printf(inStr);
	}
};

//============================================================================
//    PRIVATE DATA
//============================================================================
static ILogTarget* log_Targets[LOG_MAXTARGETS];

static ELogLevel log_Level;
static NDword log_LevelFlags;
static NChar log_Title[256];
static FLogErrorQuit log_ErrorQuit;

static CLogFileTarget log_StockTargetFileImp;
static CLogConsoleTarget log_StockTargetConsoleImp;
static CLogDebugTarget log_StockTargetDebugImp;
static CLogStdoutTarget log_StockTargetStdoutImp;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void LOG_Init(NChar* inTitle, FLogErrorQuit inErrorQuit, ELogLevel inLevel, NDword inFlags)
{
	if (!inTitle)
		inTitle = "Unnamed Application";
	strcpy(log_Title, inTitle);
	
	memset(log_Targets, 0, LOG_MAXTARGETS*sizeof(ILogTarget*));

	log_ErrorQuit = inErrorQuit;
	LOG_SetLevel(inLevel, inFlags);
}

KRN_API void LOG_Shutdown()
{
	for (NDword i=0;i<LOG_MAXTARGETS;i++)
	{
		if (log_Targets[i])
			log_Targets[i]->Shutdown();
	}
}

KRN_API HLogTarget LOG_AddTarget(ILogTarget* inTarget)
{
	for (NDword i=0;i<LOG_MAXTARGETS;i++)
	{
		if (!log_Targets[i])
			break;
	}
	if (i==LOG_MAXTARGETS)
		return((HLogTarget)0);
	log_Targets[i] = inTarget;
	if (log_Targets[i])
		log_Targets[i]->Init(log_Title);
	return((HLogTarget)(i + 1));
}

KRN_API void LOG_RemoveTarget(HLogTarget inTargetHandle)
{
	NDword i = ((NDword)inTargetHandle - 1);
	if (i >= LOG_MAXTARGETS)
		return;
	if (log_Targets[i])
		log_Targets[i]->Shutdown();
	log_Targets[i] = NULL;
}

KRN_API ILogTarget* LOG_GetStockTarget(ELogStockTarget inTarget)
{
	switch(inTarget)
	{
	case LOGTARGET_File: return(&log_StockTargetFileImp); break;
	case LOGTARGET_Console: return(&log_StockTargetConsoleImp); break;
	case LOGTARGET_Debug: return(&log_StockTargetDebugImp); break;
	case LOGTARGET_Stdout: return(&log_StockTargetStdoutImp); break;
	default: return(NULL); break;
	}
}

KRN_API void LOG_SetLevel(ELogLevel inLevel, NDword inFlags)
{
	log_Level = inLevel;
	log_LevelFlags = inFlags;
}

KRN_API void LOG_Write(ELogLevel inLevel, NDword inFlags, NChar* inStr)
{
	static char buf[4096];

	// check level
	if (inLevel > log_Level)
		return;
	
	// check developer flag
	if ((inFlags & LOGLVLF_Developer) && (!(log_LevelFlags & LOGLVLF_Developer)))
		return;
	
	if (!inStr)
		inStr = "";

	if (((inFlags & LOGLVLF_HideLevel) || (log_LevelFlags & LOGLVLF_HideLevel))
	 && (inLevel >= LOGLVL_Normal))
	{
		buf[0] = 0;
	}
	else
	{
		switch(inLevel)
		{
		case LOGLVL_Error:   strcpy(buf, "[Fatal Error]"); break;
		case LOGLVL_Warning: strcpy(buf, "[Warning]"); break;
		case LOGLVL_Normal:  strcpy(buf, "[Log]"); break;
		case LOGLVL_Verbose: strcpy(buf, "[Verbose]"); break;
		case LOGLVL_Debug:   strcpy(buf, "[Debug]"); break;
		default:             strcpy(buf, "[?]"); break;
		}
		if (inFlags & LOGLVLF_Developer)
			strcat(buf, "[Dev]");
		strcat(buf, " ");
	}
	strcat(buf, inStr);
	strcat(buf, "\n");
	
	// write to all log targets
	for (NDword i=0;i<LOG_MAXTARGETS;i++)
	{
		if (log_Targets[i])
			log_Targets[i]->Write(buf);
	}
	
	// alert if necessary
	if ((inFlags & LOGLVLF_Alert) && (log_LevelFlags & LOGLVLF_Alert))
	{
		char caption[256];
		sprintf(caption, "%s - Alert", log_Title);
		MessageBox(NULL, buf, caption, MB_OK);
	}

	// quit on fatal error
	if ((inLevel == LOGLVL_Error) && (log_ErrorQuit))
		log_ErrorQuit();
}

// log convenience functions

KRN_API void LOG_Errorf(char* inFmt, ... ) { LOG_Write(LOGLVL_Error, LOGLVLF_Alert, STR_Va(inFmt)); }
KRN_API void LOG_Warnf(char* inFmt, ... ) { LOG_Write(LOGLVL_Warning, LOGLVLF_Alert, STR_Va(inFmt)); }
KRN_API void LOG_Logf(char* inFmt, ... ) { LOG_Write(LOGLVL_Normal, 0, STR_Va(inFmt)); }
KRN_API void LOG_Verbosef(char* inFmt, ... ) { LOG_Write(LOGLVL_Verbose, 0, STR_Va(inFmt)); }
KRN_API void LOG_Debugf(char* inFmt, ... ) { LOG_Write(LOGLVL_Debug, 0, STR_Va(inFmt)); }
KRN_API void LOG_DevWarnf(char* inFmt, ... ) { LOG_Write(LOGLVL_Warning, LOGLVLF_Alert|LOGLVLF_Developer, STR_Va(inFmt)); }
KRN_API void LOG_DevLogf(char* inFmt, ... ) { LOG_Write(LOGLVL_Normal, LOGLVLF_Developer, STR_Va(inFmt)); }
KRN_API void LOG_DevVerbosef(char* inFmt, ... ) { LOG_Write(LOGLVL_Verbose, LOGLVLF_Developer, STR_Va(inFmt)); }
KRN_API void LOG_DevDebugf(char* inFmt, ... ) { LOG_Write(LOGLVL_Debug, LOGLVLF_Developer, STR_Va(inFmt)); }

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE LOGMAIN.CPP
//**
//****************************************************************************

