#ifndef __LOGMAIN_H__
#define __LOGMAIN_H__
//****************************************************************************
//**
//**    LOGMAIN.H
//**    Header - Logging
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
// log level
typedef enum
{
	LOGLVL_Error=0,			// fatal errors only
	LOGLVL_Warning,			// add warnings
	LOGLVL_Normal,			// add normal log text
	LOGLVL_Verbose,			// add verbose log text
	LOGLVL_Debug			// add debugging text
} ELogLevel;

// log level flags
enum
{
	LOGLVLF_Alert		= 0x00000001,	// alert user immediately
	LOGLVLF_Developer	= 0x00000002,	// developer-level text
	LOGLVLF_HideLevel	= 0x00000004	// no bracketed level-name prepends
};

// stock log targets
typedef enum
{
	LOGTARGET_File=1,		// disk log file
	LOGTARGET_Console,		// console window
	LOGTARGET_Debug,		// debug strings
	LOGTARGET_Stdout		// stdout output
} ELogStockTarget;

// log target handles
typedef NDword HLogTarget;

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
/*
	ILogTarget
	Interface to a target for log output
*/
class ILogTarget
{
public:
	virtual void Init(NChar* inTitle)=0;
	virtual void Shutdown()=0;
	virtual void Write(NChar* inStr)=0;
};

// function to quit application if error is signaled
typedef void (*FLogErrorQuit)();

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================

// init/shutdown
KRN_API void LOG_Init(NChar* inTitle, FLogErrorQuit inErrorQuit=NULL,
			  ELogLevel inLevel=LOGLVL_Normal, NDword inFlags=LOGLVLF_Alert);
KRN_API void LOG_Shutdown();

// log targets
KRN_API HLogTarget LOG_AddTarget(ILogTarget* inTarget);
KRN_API void LOG_RemoveTarget(HLogTarget inTargetHandle);
KRN_API ILogTarget* LOG_GetStockTarget(ELogStockTarget inTarget);

// logging functions
KRN_API void LOG_SetLevel(ELogLevel inLevel, NDword inFlags);
KRN_API void LOG_Write(ELogLevel inLevel, NDword inFlags, NChar* inStr);

// log convenience functions
KRN_API void LOG_Errorf(char* inFmt, ... );
KRN_API void LOG_Warnf(char* inFmt, ... );
KRN_API void LOG_Logf(char* inFmt, ... );
KRN_API void LOG_Verbosef(char* inFmt, ... );
KRN_API void LOG_Debugf(char* inFmt, ... );
KRN_API void LOG_DevWarnf(char* inFmt, ... );
KRN_API void LOG_DevLogf(char* inFmt, ... );
KRN_API void LOG_DevVerbosef(char* inFmt, ... );
KRN_API void LOG_DevDebugf(char* inFmt, ... );

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER LOGMAIN.H
//**
//****************************************************************************
#endif // __LOGMAIN_H__
