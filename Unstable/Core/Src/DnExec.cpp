//****************************************************************************
//**
//**    DNEXEC.CPP
//**    DNF Exec Implementation (CDH)
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "..\..\Engine\Src\EnginePrivate.h"

#if DNF

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    PRIVATE DATA
//============================================================================
EXECVAR_HELP(int, DnExec_StubVar, 0, "Exec stub variable, not used.");

//============================================================================
//    GLOBAL DATA
//============================================================================
CORE_API FDnExec* GDnExec = NULL;
static BYTE GDnExec_LocBuf[sizeof(FDnExec)];

//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static void InitDnExec()
{
	if (!GDnExec)
		GDnExec = new(GDnExec_LocBuf) FDnExec;
}

/*
static char GetLiteral(char*& ioPtr)
{
	char r;
	int i, shifter;

	if (*ioPtr != '\\')
	{
		r = *ioPtr++;
		return(r);
	}

	ioPtr++; // eat slash
	if (!(*ioPtr)) return(0);
	switch(*ioPtr)
	{
	case '0': r = 0x00; ioPtr++; break;
	case 'n': r = 0x0A; ioPtr++; break;
	case 'r': r = 0x0D; ioPtr++; break;
	case 't': r = 0x09; ioPtr++; break;
	case 'x':
		r = 0; ioPtr++;
		shifter = 4;
		for (i=0;i<2;i++)
		{
			if (!(*ioPtr)) return(0);
			if ((*ioPtr >= '0') && (*ioPtr <= '9'))
				r += ((*ioPtr - '0') << shifter);
			else if ((*ioPtr >= 'a') && (*ioPtr <= 'f'))
				r += (((*ioPtr - 'a') + 10) << shifter);
			else if ((*ioPtr >= 'A') && (*ioPtr <= 'F'))
				r += (((*ioPtr - 'A') + 10) << shifter);
			ioPtr++;
			shifter -= 4;
		}
		break;
	default: r = *ioPtr++; break;
	}
	return(r);
}
*/

EXECFUNC_HELP(DnExec_StubFunc, "Exec stub function, not used.")
{
	if (argc < 2)
		GDnExec->Printf(TEXT("Uhh... hello?"));
	else
		GDnExec->Printf(TEXT("Huh huh huh... you said \"%s\"..."), argv[1]);
}

EXECFUNC_HELP(ListVars, "Lists exec variables")
{
	if (!GDnExec || !GDnExec->vars)
		return;

	GDnExec->Printf(TEXT("Variables:"));
	for (FExecVariable* v = GDnExec->vars; v; v=v->next)
		GDnExec->Printf(TEXT("    %-20s - %s"), v->name, v->help);
	GDnExec->Printf(TEXT(""));
}

EXECFUNC_HELP(Variables, "Lists exec variables")
{
	if (!GDnExec || !GDnExec->vars)
		return;

	GDnExec->Printf(TEXT("Variables:"));
	for (FExecVariable* v = GDnExec->vars; v; v=v->next)
		GDnExec->Printf(TEXT("    %-20s - %s"), v->name, v->help);
	GDnExec->Printf(TEXT(""));
}

EXECFUNC_HELP(ListFuncs, "Lists exec functions")
{
	if (!GDnExec || !GDnExec->funcs)
		return;

	GDnExec->Printf(TEXT("Functions:"));
	for (FExecFunction* f = GDnExec->funcs; f; f=f->next)
		GDnExec->Printf(TEXT("    %-20s - %s"), f->name, f->help);
	GDnExec->Printf(TEXT(""));
}

EXECFUNC_HELP(Functions, "Lists exec functions")
{
	if (!GDnExec || !GDnExec->funcs)
		return;

	GDnExec->Printf(TEXT("Functions:"));
	for (FExecFunction* f = GDnExec->funcs; f; f=f->next)
		GDnExec->Printf(TEXT("    %-20s - %s"), f->name, f->help);
	GDnExec->Printf(TEXT(""));
}

EXECFUNC_HELP(DumpClasses,"Dumps all unreal classes")
{
	for (TObjectIterator<UClass> ItC; ItC; ++ItC)
	{
		GDnExec->Printf((unsigned short *)*(ItC->GetFName()));
		/*
		if (ItC->GetFName() == ClassName)
		{
			//*(UClass**)Result = *ItC;
			return;
		}*/
	}
}

/*
	Float handler
*/
EXECVARHANDLER(FLOAT)
{
	FLOAT* val = (FLOAT*)argVar->valuePtr;

	if (argc < 2)
	{
		GDnExec->Printf(TEXT(" float %s = %.4f"), argVar->name, *val);
		return;
	}
	if (argc < 3)
	{
		if (!appStrcmp(argv[1], TEXT("++")))
			*val += 1.f;
		else if (!appStrcmp(argv[1], TEXT("--")))
			*val -= 1.f;
		else
			*val = appAtof(argv[1]);
		return;
	}
	if (!appStrcmp(argv[1], TEXT("=")))
		*val = appAtof(argv[2]);
	else if (!appStrcmp(argv[1], TEXT("+=")))
		*val += appAtof(argv[2]);
	else if (!appStrcmp(argv[1], TEXT("-=")))
		*val -= appAtof(argv[2]);
	else if (!appStrcmp(argv[1], TEXT("*=")))
		*val *= appAtof(argv[2]);
	else if (!appStrcmp(argv[1], TEXT("/=")))
		*val /= appAtof(argv[2]);
}
EXECVARHANDLER_SAVE(FLOAT)
{
	GConfig->SetFloat(TEXT("Core.ExecVariables"), inVar->name, *((FLOAT*)inVar->valuePtr), NULL);
}
EXECVARHANDLER_LOAD(FLOAT)
{
	GConfig->GetFloat(TEXT("Core.ExecVariables"), inVar->name, *((FLOAT*)inVar->valuePtr), NULL);
}

/*
	Int handler
*/
EXECVARHANDLER(INT)
{
	INT* val = (INT*)argVar->valuePtr;

	if (argc < 2)
	{
		GDnExec->Printf(TEXT(" int %s = %d"), argVar->name, *val);
		return;
	}
	if (argc < 3)
	{
		if (!appStrcmp(argv[1], TEXT("++")))
			*val += 1;
		else if (!appStrcmp(argv[1], TEXT("--")))
			*val -= 1;
		else if (!appStrcmp(argv[1], TEXT("^^")))
			*val = (*val == 0);
		else if (!appStricmp(argv[1], TEXT("tog")))
			*val = (*val == 0);
		else if (!appStrcmp(argv[1], TEXT("on")))
			*val = 1;
		else if (!appStrcmp(argv[1], TEXT("off")))
			*val = 0;
		else
			*val = appAtoi(argv[1]);
		return;
	}
	if (!appStrcmp(argv[1], TEXT("=")))
		*val = appAtoi(argv[2]);
	else if (!appStrcmp(argv[1], TEXT("+=")))
		*val += appAtoi(argv[2]);
	else if (!appStrcmp(argv[1], TEXT("-=")))
		*val -= appAtoi(argv[2]);
	else if (!appStrcmp(argv[1], TEXT("*=")))
		*val *= appAtoi(argv[2]);
	else if (!appStrcmp(argv[1], TEXT("/=")))
		*val /= appAtoi(argv[2]);
}
EXECVARHANDLER_SAVE(INT)
{
	GConfig->SetInt(TEXT("Core.ExecVariables"), inVar->name, *((INT*)inVar->valuePtr), NULL);
}
EXECVARHANDLER_LOAD(INT)
{
	GConfig->GetInt(TEXT("Core.ExecVariables"), inVar->name, *((INT*)inVar->valuePtr), NULL);
}

/*
	Ubool handler
*/
EXECVARHANDLER(UBOOL)
{
	UBOOL* val = (UBOOL*)argVar->valuePtr;

	if (argc < 2)
	{
		if (*val)
			GDnExec->Printf(TEXT(" ubool %s is on"), argVar->name);
		else
			GDnExec->Printf(TEXT(" ubool %s is off"), argVar->name);
		return;
	}
	if (argc < 3)
	{
		if (!appStrcmp(argv[1], TEXT("^^")))
			*val = (*val == 0);
		else if (!appStricmp(argv[1], TEXT("tog")))
			*val = (*val == 0);
		else if (!appStrcmp(argv[1], TEXT("on")))
			*val = 1;
		else if (!appStrcmp(argv[1], TEXT("off")))
			*val = 0;
		else
			*val = (appAtoi(argv[1]) != 0);
		return;
	}
	if (!appStrcmp(argv[1], TEXT("=")))
		*val = (appAtoi(argv[2]) != 0);
}
EXECVARHANDLER_SAVE(UBOOL)
{
	GConfig->SetBool(TEXT("Core.ExecVariables"), inVar->name, *((UBOOL*)inVar->valuePtr), NULL);
}
EXECVARHANDLER_LOAD(UBOOL)
{
	GConfig->GetBool(TEXT("Core.ExecVariables"), inVar->name, *((UBOOL*)inVar->valuePtr), NULL);
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    CLASS METHODS
//============================================================================
/*
	FExecVariable
*/
FExecVariable::FExecVariable(TCHAR* inName, DWORD inFlags, void* inValuePtr, TCHAR* inVarType, TCHAR* inHelp)
: name(inName), flags(inFlags), valuePtr(inValuePtr), varTypeName(inVarType), help(inHelp), next(NULL)
{
	InitDnExec();
	handler = GDnExec->FindVarHandler((TCHAR*)varTypeName);
	GDnExec->RegisterVariable(this);
}
FExecVariable::~FExecVariable()
{
}

/*
	FExecFunction
*/
FExecFunction::FExecFunction(TCHAR* inName, FExecFunctionCallback inFunc, TCHAR* inHelp)
: name(inName), func(inFunc), help(inHelp), next(NULL)
{
	InitDnExec();
	GDnExec->RegisterFunction(this);
}
FExecFunction::~FExecFunction()
{
}

/*
	FExecVarHandler
*/
FExecVarHandler::FExecVarHandler(TCHAR* inName, FExecFunctionCallback inFunc)
: name(inName), func(inFunc), next(NULL)
{
	InitDnExec();
	GDnExec->RegisterVarHandler(this);
}
FExecVarHandler::~FExecVarHandler()
{
}

/*
	FDnExec
*/
FDnExec::FDnExec()
: vars(NULL), funcs(NULL), varHandlers(NULL), printContext(NULL), printLogIndex(0)
{
	for (INT i=0;i<DNEXEC_PRINTLOG_LINECOUNT;i++)
		printLog[i][0]=0;
}
FDnExec::~FDnExec()
{
}

FExecVariable* FDnExec::FindVariable(TCHAR* inName)
{
	for (FExecVariable* v = vars; v; v=v->next)
	{
		if (!appStricmp(v->name, inName))
			return(v);
	}
	return(NULL);
}
void FDnExec::RegisterVariable(FExecVariable* inVar)
{
	inVar->next = vars;
	vars = inVar;
}
FExecFunction* FDnExec::FindFunction(TCHAR* inName)
{
	for (FExecFunction* f = funcs; f; f=f->next)
	{
		if (!appStricmp(f->name, inName))
			return(f);
	}
	return(NULL);
}
void FDnExec::RegisterFunction(FExecFunction* inFunc)
{
	inFunc->next = funcs;
	funcs = inFunc;
}
FExecVarHandler* FDnExec::FindVarHandler(TCHAR* inName)
{
	for (FExecVarHandler* vh = varHandlers; vh; vh=vh->next)
	{
		if (!appStricmp(vh->name, inName))
			return(vh);
	}
	return(NULL);
}
void FDnExec::RegisterVarHandler(FExecVarHandler* inHandler)
{
	inHandler->next = varHandlers;
	varHandlers = inHandler;
}
void FDnExec::Printf(TCHAR* Fmt, ... )
{
	static TCHAR buf[2048];
	static FLOAT lastPrintTime = 0.0;

	appGetVarArgs(buf, 2047, Fmt);
	FLOAT curTime = appSeconds();
	INT crop = (curTime-lastPrintTime)*10.0;
	printLogIndex -= crop;
	if (crop)
		lastPrintTime = curTime;
	if (printLogIndex < 0)
		printLogIndex = 0;
	if (printLogIndex >= DNEXEC_PRINTLOG_LINECOUNT)
		printLogIndex = DNEXEC_PRINTLOG_LINECOUNT-1;
	for (INT i=printLogIndex; i>0; i--)
		appStrcpy(printLog[i-1], printLog[i]);
	if (!buf[0])
		return;
	if (printContext)
		printContext->Log(buf);
	debugf(TEXT("DnExec: %s"), buf);
	appStrcpy(printLog[printLogIndex], buf);
	printLogIndex++;
}
UBOOL FDnExec::GetLog(INT* outNumLines, TCHAR*** outLines)
{
	static TCHAR* tempLog[DNEXEC_PRINTLOG_LINECOUNT];

	if (!printLogIndex)
		return(0);
	if (outNumLines)
		*outNumLines = (INT)printLogIndex;
	for (INT i=0;i<DNEXEC_PRINTLOG_LINECOUNT;i++)
		tempLog[i] = &printLog[i][0];
	if (outLines)
		*outLines = tempLog;
	return(1);
}
void FDnExec::SaveConfigVariables()
{
	for (FExecVariable* v = vars; v; v=v->next)
	{
		if (!(v->flags & EXECVARF_CONFIG))
			continue;
		if (!v->handler)
		{
			v->handler = FindVarHandler((TCHAR*)v->varTypeName);
			if (!v->handler)
				appErrorf(TEXT("FDnExec::SaveConfigVariables: Unresolved type %s"), v->varTypeName);
		}
		v->handler->SaveConfig(v);
	}
}
void FDnExec::LoadConfigVariables()
{
	for (FExecVariable* v = vars; v; v=v->next)
	{
		if (!(v->flags & EXECVARF_CONFIG))
			continue;
		if (!v->handler)
		{
			v->handler = FindVarHandler((TCHAR*)v->varTypeName);
			if (!v->handler)
				appErrorf(TEXT("FDnExec::LoadConfigVariables: Unresolved type %s"), v->varTypeName);
		}
		v->handler->LoadConfig(v);
	}
}
UBOOL FDnExec::Execf(FOutputDevice& Ar, TCHAR* Cmd, ... )
{
	static TCHAR buf[2048];
	appGetVarArgs(buf, 2047, Cmd);
	return(Exec(buf, Ar));
}
UBOOL FDnExec::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	TCHAR buf[2048];
	TCHAR* cmdArgv[32];
	INT cmdArgc;
	TCHAR* ptr;
	UBOOL inQuoteState = 0;
	UBOOL inWhiteSpace = 1;

	appStrncpy(buf, Cmd, 2047);

	printContext = &Ar;

	cmdArgc = 0;
	for (ptr=buf; *ptr; ptr++)
	{
		if (!inQuoteState)
		{
			if ((*ptr == '/') && (*(ptr+1) == '/'))
			{
				// EOL comment, line is over
				*ptr = 0;
				ptr--; // so zero will catch
			}
			else if (*ptr == ' ')
			{
				// whitespace means an argument change is impending
				*ptr = 0;
				inWhiteSpace = 1;
			}
			else if (inWhiteSpace)
			{
				// we were in whitespace, now we're not
				if (cmdArgc >= 32)
				{
					// maximum arguments
					*ptr = 0;
					ptr--;
				}
				else
				{
					// start a new argument
					cmdArgv[cmdArgc] = ptr;
					cmdArgc++;
					inWhiteSpace = 0;
					if (*ptr == '\"')
					{
						// if argument starts with a quote, change to quote state
						inQuoteState = 1;
						cmdArgv[cmdArgc-1] = ptr+1; // skip the quote
					}
				}
			}
		}
		else // inQuoteState
		{
			if (*ptr == '\"')
			{
				// quote state is over
				*ptr = 0;
				inQuoteState = 0;
				inWhiteSpace = 1;
			}
		}
	}

	if (!cmdArgc)
	{
		printContext = NULL;
		return(0); // abort if nothing to execute
	}

	UBOOL found = 0;

	// check variables first
	FExecVariable* vLast = NULL;
	for (FExecVariable* v = vars; v; vLast=v, v=v->next)
	{
		if (appStricmp(v->name, cmdArgv[0]))
			continue;
		// found a match, see if we have a handler
		if (!v->handler)
		{
			v->handler = FindVarHandler((TCHAR*)v->varTypeName);
			if (!v->handler)
				appErrorf(TEXT("FDnExec::LoadConfigVariables: Unresolved type %s"), v->varTypeName);
		}
		v->handler->func(v, cmdArgc, cmdArgv);
		// move variable to top of list for quicker access next time
		if (vLast)
		{
			vLast->next = v->next;
			v->next = vars;
			vars = v;
		}
		found = 1;
		break;
	}

	// check functions next
	if (!found)
	{
		FExecFunction* fLast = NULL;
		for (FExecFunction* f = funcs; f; fLast=f, f=f->next)
		{
			if (appStricmp(f->name, cmdArgv[0]))
				continue;
			// found a match
			f->func(NULL, cmdArgc, cmdArgv);
			// move function to top of list for quicker access next time
			if (fLast)
			{
				fLast->next = f->next;
				f->next = funcs;
				funcs = f;
			}
			found = 1;
			break;
		}
	}

	if (!found)
	{
		// Commented out for now since many functions that are handled elsewhere still
		//   manage to make it down here to DnExec and are rejected (like OnRelease)
		//Printf(TEXT("Unknown variable/function %s"), cmdArgv[0]);
		printContext = NULL;
		return(0);
	}

	printContext = NULL;
	return(1);
}

//****************************************************************************
//**
//**    END MODULE DNEXEC.CPP
//**
//****************************************************************************
#endif // DNF
