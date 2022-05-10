#ifndef __CON_MAN_H__
#define __CON_MAN_H__
//****************************************************************************
//**
//**    CON_MAN.H
//**    Header - Console Manager
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
#define CONFUNC(name, rtype, flags) \
	void name##_confunc(CConVar *cvar, int argNum, char **argList); \
	CConFunc name##_cf(#name, name##_confunc, flags, false, NULL); \
	void name##_confunc(CConVar *cvar, int argNum, char **argList)

#define CONVARHANDLER(type) \
	void handler_##type##_confunc(CConVar *argVar, int argNum, char **argList); \
	CConFunc handler_##type##_cf(NULL, handler_##type##_confunc, 0, true, #type); \
	void handler_##type##_confunc(CConVar *argVar, int argNum, char **argList)

#define CONVAR(type, name, ivalue, flags, cback) \
	type name = ivalue; \
	CConVar name##_convar(&##name, #type, #name, flags, 0, 0, cback)

#define CONVARCLAMPED(type, name, ivalue, flags, minv, maxv, cback) \
	type name = ivalue; \
	CConVar name##_convar(&##name, #type, #name, (flags)|CVF_CLAMPED, minv, maxv, cback)

#define CVF_HIDDEN		0x00000001
#define CVF_CLAMPED		0x00000002
#define CVF_HARDCLAMP	0x00000004
#define CVF_CLAMPWRAP	0x00000008

#define CCF_ROOM		0x00000001 // requires rminfo "room" field
#define CCF_CAM			0x00000002 // requires rminfo "cam" field
#define CCF_MOUSE		0x00000004 // requires rminfo mouse information
#define CCF_INPUTEVENT	0x00000008 // accepts input events beyond RMIE_PRESS
#define CCF_ALL			(CCF_ROOM|CCF_CAM|CCF_MOUSE|CCF_INPUTEVENT)

#define CON_DISPLAYLINES	256
#define CON_HISTORYLINES	32
#define CON_MAXLINELEN		256
#define CON_MAXARGS			32

//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
class CConVar;
class CConFunc;
class CConsoleManager;
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
extern CConsoleManager *CON;
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    CLASS CConVar
//**
//****************************************************************************
#ifndef dword
#define dword unsigned long
#endif

class CConVar
{
public:
    // data
	char *name;
	void *valuePtr;
	dword flags;
	CConFunc *handler;
	char *vtype;
	float clamp[2];
	void (*callbackfunc)();
	CConVar *next;
    // construction
	CConVar(void *invaluePtr, char *varType, char *varName, dword inflags,
		float clampmin, float clampmax, void (*cback)());
	~CConVar();
    // methods
};

#undef dword

//****************************************************************************
//**
//**    END CLASS CConVar
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS CConFunc
//**
//****************************************************************************

#ifndef dword
#define dword unsigned long
#endif

class CConFunc
{
public:
    // data	
	char *name;
	void (*func)(CConVar *, int, char**);
	dword flags;
	CConFunc *next;
    // construction
	CConFunc(char *funcName, void (*inFunc)(CConVar *, int, char **),
		dword inflags, boolean isHandler, char *handlerType);
	~CConFunc();
    // methods
    // friend classes
	friend class CConsoleManager;
};

#undef dword

//****************************************************************************
//**
//**    END CLASS CConFunc
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS CConsoleManager
//**
//****************************************************************************

class CConsoleManager
{
public:
	// data
	CConVar *vars;
	CConFunc *funcs;
	CConFunc *handlers;
	int cmdArgc;
	char *cmdArgv[CON_MAXARGS];
	char *cmdDisplay;
	int cmdDisplayIndex;
	char cmdHistory[CON_HISTORYLINES][CON_MAXLINELEN];
	int cmdHistoryIndex;
	char cmdLine[CON_MAXLINELEN];

	// construction
	CConsoleManager();
	~CConsoleManager();
    // methods
	CConFunc *GetHandlerForType(char *varType);
	void RegisterVariable(CConVar *var);
	void DeRegisterVariable(CConVar *var);
	void RegisterVarHandler(CConFunc *handler);
	void RegisterFunction(CConFunc *func);
	boolean Execute(overlay_t *ovlcontext, char *cmd, unsigned long ccflags);
	void ExecuteFile(overlay_t *ovlcontext, char *filename, boolean alertfail);
	void ExecuteCmdLine(overlay_t *ovlcontext, int argc, char **argv);
	char *MatchCommand(char *namestart, int skipmatches, int len);
	void Printf(char *msg, ... );
};

//****************************************************************************
//**
//**    END CLASS CConsoleManager
//**
//****************************************************************************

//****************************************************************************
//**
//**    END HEADER CON_MAN.H
//**
//****************************************************************************
#endif // __CON_MAN_H__
