#ifndef __DNEXEC_H__
#define __DNEXEC_H__
//****************************************************************************
//**
//**    DNEXEC.H
//**    Header - DNF Exec Interface (CDH)
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
/*
	Variables
*/
#define EXECVAR(xtype, xname, xvalue) \
	xtype xname = xvalue; \
	FExecVariable xname##_ExecVar(TEXT(#xname), 0, &##xname, TEXT(#xtype), TEXT(""))

#define EXECVAR_FLAGS(xtype, xname, xvalue, xflags) \
	xtype xname = xvalue; \
	FExecVariable xname##_ExecVar(TEXT(#xname), xflags, &##xname, TEXT(#xtype), TEXT(""))

#define EXECVAR_HELP(xtype, xname, xvalue, xhelp) \
	xtype xname = xvalue; \
	FExecVariable xname##_ExecVar(TEXT(#xname), 0, &##xname, TEXT(#xtype), TEXT(xhelp))

#define EXECVAR_FLAGS_HELP(xtype, xname, xvalue, xflags, xhelp) \
	xtype xname = xvalue; \
	FExecVariable xname##_ExecVar(TEXT(#xname), xflags, &##xname, TEXT(#xtype), TEXT(xhelp))

/*
	Functions
*/
#define EXECFUNC(xname) \
	void __fastcall xname##_ExecFuncCall(FExecVariable* argVar, INT argc, TCHAR** argv); \
	FExecFunction xname##_ExecFunc(TEXT(#xname), xname##_ExecFuncCall, TEXT("")); \
	void __fastcall xname##_ExecFuncCall(FExecVariable* argVar, INT argc, TCHAR** argv)

#define EXECFUNC_HELP(xname, xhelp) \
	void __fastcall xname##_ExecFuncCall(FExecVariable* argVar, INT argc, TCHAR** argv); \
	FExecFunction xname##_ExecFunc(TEXT(#xname), xname##_ExecFuncCall, TEXT(xhelp)); \
	void __fastcall xname##_ExecFuncCall(FExecVariable* argVar, INT argc, TCHAR** argv)

/*
	Variable Handlers
*/
#define EXECVARHANDLER(xtype) \
class FExecVarHandler##xtype \
: public FExecVarHandler \
{ \
public: \
	FExecVarHandler##xtype(TCHAR* inName, FExecFunctionCallback inFunc) \
	: FExecVarHandler(inName, inFunc) \
	{} \
	void SaveConfig(FExecVariable* inVar); \
	void LoadConfig(FExecVariable* inVar); \
}; \
void __fastcall xtype##_ExecVarHandlerCall(FExecVariable* argVar, INT argc, TCHAR** argv); \
FExecVarHandler##xtype xtype##_ExecVarHandler(TEXT(#xtype), xtype##_ExecVarHandlerCall); \
void __fastcall xtype##_ExecVarHandlerCall(FExecVariable* argVar, INT argc, TCHAR** argv)

#define EXECVARHANDLER_SAVE(xtype) void FExecVarHandler##xtype::SaveConfig(FExecVariable* inVar)
#define EXECVARHANDLER_LOAD(xtype) void FExecVarHandler##xtype::LoadConfig(FExecVariable* inVar)

/*
	Flags
*/
enum
{
	EXECVARF_CONFIG		= 0x00000001	// variable should be saved and loaded in configuration
};

/*
	Other
*/
#define DNEXEC_PRINTLOG_LINECOUNT	16
#define DNEXEC_PRINTLOG_LINELEN		2048

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class CORE_API FExecVariable;
class CORE_API FExecFunction;
class CORE_API FExecVarHandler;
class CORE_API FDnExec;

/*
	Callbacks
*/
typedef void (__fastcall *FExecFunctionCallback)(FExecVariable*, INT, TCHAR**);

/*
	FExecVariable
*/
class CORE_API FExecVariable
{
public:
	const TCHAR* name; // name of variable
	const TCHAR* help; // single line optional helpstring
	DWORD flags; // EXECVARF_ flags
	void* valuePtr; // pointer to data value
	const TCHAR* varTypeName; // name of variable type
	FExecVarHandler* handler; // handler for this var type, once located
	FExecVariable* next; // next in linked list of variables

	FExecVariable(TCHAR* inName, DWORD inFlags, void* inValuePtr, TCHAR* inVarType, TCHAR* inHelp);
	~FExecVariable();
};

/*
	FExecFunction
*/
class CORE_API FExecFunction
{
public:
	const TCHAR* name; // name of function
	const TCHAR* help; // single line optional helpstring
	DWORD flags; // EXECFUNCF_ flags
	FExecFunctionCallback func; // function to call
	FExecFunction* next; // next in linked list of functions

	FExecFunction(TCHAR* inName, FExecFunctionCallback inFunc, TCHAR* inHelp);
	~FExecFunction();
};

/*
	FExecVarHandler
*/
class CORE_API FExecVarHandler
{
public:
	const TCHAR* name; // name of variable handler
	DWORD flags; // EXECVARHANDLERF_ flags
	FExecFunctionCallback func; // function to call
	FExecVarHandler* next; // next in linked list of variable handlers

	FExecVarHandler(TCHAR* inName, FExecFunctionCallback inFunc);
	~FExecVarHandler();

	virtual void SaveConfig(FExecVariable* inVar) {}
	virtual void LoadConfig(FExecVariable* inVar) {}
};

/*
	FDnExec
*/
class CORE_API FDnExec
: public FExec
{
public:
	FExecVariable* vars; // variables
	FExecFunction* funcs; // non-handler functions
	FExecVarHandler* varHandlers; // handler functions
	FOutputDevice* printContext; // output device context for prints
	TCHAR printLog[DNEXEC_PRINTLOG_LINECOUNT][DNEXEC_PRINTLOG_LINELEN]; // log of recent prints
	INT printLogIndex; // current line index in print log
	
	FDnExec();
	~FDnExec();

	FExecVariable* FindVariable(TCHAR* inName);
	void RegisterVariable(FExecVariable* inVar);
	FExecFunction* FindFunction(TCHAR* inName);
	void RegisterFunction(FExecFunction* inFunc);
	FExecVarHandler* FindVarHandler(TCHAR* inName);
	void RegisterVarHandler(FExecVarHandler* inHandler);
	void Printf(TCHAR* Fmt, ... );
	UBOOL GetLog(INT* outNumLines, TCHAR*** outLines);
	void SaveConfigVariables();
	void LoadConfigVariables();
	UBOOL Execf(FOutputDevice& Ar, TCHAR* Cmd, ... );

	// FExec
	UBOOL Exec(const TCHAR* Cmd, FOutputDevice& Ar);
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER DNEXEC.H
//**
//****************************************************************************
#endif // __DNEXEC_H__
