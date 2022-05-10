//****************************************************************************
//**
//**    CON_MAN.CPP
//**    Console Manager
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
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
CConsoleManager *CON=NULL;

CONVARHANDLER(float)
{
	float *val = (float *)argVar->valuePtr;
	float oldval = *val;
	if (argNum < 2)
	{
		CON->Printf(" float %s == %.4f", argVar->name, *val);
		return;
	}
	if (!strcmp(argList[1], "="))
		*val = (float)atof(argList[2]);
	else
	if (!strcmp(argList[1], "+="))
		*val += (float)atof(argList[2]);
	else
	if (!strcmp(argList[1], "-="))
		*val -= (float)atof(argList[2]);
	else
	if (!strcmp(argList[1], "*="))
		*val *= (float)atof(argList[2]);
	else
	if (!strcmp(argList[1], "/="))
		*val /= (float)atof(argList[2]);
	else
	{
		//CON->Printf(" Unknown float operation %s", argList[1]);
		*val = (float)atof(argList[1]);
	}

	if (argVar->flags & CVF_CLAMPED)
	{
		if (argVar->flags & CVF_HARDCLAMP)
		{
			if (*val < argVar->clamp[0])
				*val = oldval;
			if (*val > argVar->clamp[1])
				*val = oldval;
		}
		else
		if (argVar->flags & CVF_CLAMPWRAP)
		{
			if (*val < argVar->clamp[0])
				*val = argVar->clamp[1];
			if (*val > argVar->clamp[1])
				*val = argVar->clamp[0];
		}
		else
		{
			if (*val < argVar->clamp[0])
				*val = argVar->clamp[0];
			if (*val > argVar->clamp[1])
				*val = argVar->clamp[1];
		}
	}
}

CONVARHANDLER(int)
{
	int *val = (int *)argVar->valuePtr;
	int oldval = *val;
	if (argNum < 2)
	{
		CON->Printf(" int %s == %d", argVar->name, *val);
		return;
	}
	if (!strcmp(argList[1], "="))
		*val = atoi(argList[2]);
	else
	if (!strcmp(argList[1], "+="))
		*val += atoi(argList[2]);
	else
	if (!strcmp(argList[1], "-="))
		*val -= atoi(argList[2]);
	else
	if (!strcmp(argList[1], "*="))
		*val *= atoi(argList[2]);
	else
	if (!strcmp(argList[1], "/="))
		*val /= atoi(argList[2]);
	else
	if (!strcmp(argList[1], "&="))
		*val &= atoi(argList[2]);
	else
	if (!strcmp(argList[1], "|="))
		*val |= atoi(argList[2]);
	else
	if (!strcmp(argList[1], "^="))
		*val ^= atoi(argList[2]);
	else
	if (!strcmp(argList[1], "%="))
		*val %= atoi(argList[2]);
	else
	if (!_stricmp(argList[1], "on"))
		*val = 1;
	else
	if (!_stricmp(argList[1], "off"))
		*val = 0;
	else
	if (!_stricmp(argList[1], "tog"))
	{
		if (*val)
			*val = 0;
		else
			*val = 1;
	}
	else
		//CON->Printf(" Unknown int operation %s", argList[1]);
		*val = atoi(argList[1]);

	if (argVar->flags & CVF_CLAMPED)
	{
		if (argVar->flags & CVF_HARDCLAMP)
		{
			if (*val < argVar->clamp[0])
				*val = oldval;
			if (*val > argVar->clamp[1])
				*val = oldval;
		}
		else
		if (argVar->flags & CVF_CLAMPWRAP)
		{
			if (*val < argVar->clamp[0])
				*val = (int)argVar->clamp[1];
			if (*val > argVar->clamp[1])
				*val = (int)argVar->clamp[0];
		}
		else
		{
			if (*val < argVar->clamp[0])
				*val = (int)argVar->clamp[0];
			if (*val > argVar->clamp[1])
				*val = (int)argVar->clamp[1];
		}
	}
}

/* Note by Andy: scarily unsafe macro usage */
#ifndef boolean
#define boolean unsigned int
#endif

CONVARHANDLER(boolean)
{
	int *val = (int *)argVar->valuePtr;
	int oldval = *val;
	if (argNum < 2)
	{
		if (*val)
			CON->Printf(" boolean %s is on", argVar->name, *val);
		else
			CON->Printf(" boolean %s is off", argVar->name, *val);
		return;
	}
	if (!strcmp(argList[1], "="))
		*val = atoi(argList[2]);
	else
	if (!strcmp(argList[1], "^="))
		*val ^= atoi(argList[2]);
	else
	if (!_stricmp(argList[1], "on"))
		*val = 1;
	else
	if (!_stricmp(argList[1], "off"))
		*val = 0;
	else
	if (!_stricmp(argList[1], "tog"))
	{
		if (*val)
			*val = 0;
		else
			*val = 1;
	}
	else
		//CON->Printf(" Unknown boolean operation %s", argList[1]);
		*val = atoi(argList[1]);

	// auto clamp to 0 or 1
	if (*val)
		*val = 1;
}

CONVARHANDLER(vector_t)
{
	vector_t *val = (vector_t *)argVar->valuePtr;
	vector_t oldval = *val;
	int vf;
	if (argNum < 2)
	{
		CON->Printf(" vector_t %s == (%.4f, %.4f, %.4f)", argVar->name, val->x, val->y, val->z);
		return;
	}
	if (!_stricmp(argList[1], "x"))
		vf = 0;
	else
	if (!_stricmp(argList[1], "y"))
		vf = 1;
	else
	if (!_stricmp(argList[1], "z"))
		vf = 2;
	else
	{
		if (argNum < 4)
		{
			CON->Printf(" Unknown vector_t field %s, please choose x, y, or z\n or supply all three float values", argList[1]);
			return;
		}
		val->Setf((float)atof(argList[1]),(float)atof(argList[2]),(float)atof(argList[3]));
		return;
	}
	if (argNum < 3)
	{
		CON->Printf(" vector_t %s.%s == %.4f", argVar->name, argList[1], val->v[vf]);
		return;
	}

	if (!strcmp(argList[2], "="))
		val->v[vf] = (float)atof(argList[3]);
	else
	if (!strcmp(argList[2], "+="))
		val->v[vf] += (float)atof(argList[3]);
	else
	if (!strcmp(argList[2], "-="))
		val->v[vf] -= (float)atof(argList[3]);
	else
	if (!strcmp(argList[2], "*="))
		val->v[vf] *= (float)atof(argList[3]);
	else
	if (!strcmp(argList[2], "/="))
		val->v[vf] /= (float)atof(argList[3]);
	else
		val->v[vf] = (float)atof(argList[2]);
}

CONFUNC(Listvars, NULL, 0)
{
	CConVar *v;

	if (argNum > 1)
	{
		for (v=CON->vars;v;v=v->next)
		{
			if (!_strnicmp(v->name, argList[1], fstrlen(argList[1])))
				CON->Printf("  %s (%s)", _strlwr(v->name), _strlwr(v->vtype));
		}
	}
	else
	{
		for (v=CON->vars;v;v=v->next)
		{
			CON->Printf("  %s (%s)", _strlwr(v->name), _strlwr(v->vtype));
		}
	}
}

CONFUNC(Listcmds, NULL, 0)
{
	CConFunc *f;
	if (argNum > 1)
	{
		for (f=CON->funcs;f;f=f->next)
		{
			if (!_strnicmp(f->name, argList[1], fstrlen(argList[1])))
			{
				CON->Printf("  %s", _strlwr(f->name));
			}
		}
	}
	else
	{
		for (f=CON->funcs;f;f=f->next)
		{
			CON->Printf("  %s", _strlwr(f->name));
		}
	}
}

CONFUNC(Listtypes, NULL, 0)
{
	CConFunc *f;
	if (argNum > 1)
	{
		for (f=CON->handlers;f;f=f->next)
		{
			if (!_strnicmp(f->name, argList[1], fstrlen(argList[1])))
			{
				CON->Printf("  %s", _strlwr(f->name));
			}
		}
	}
	else
	{
		for (f=CON->handlers;f;f=f->next)
		{
			CON->Printf("  %s", _strlwr(f->name));
		}
	}
}

CONFUNC(Exec, NULL, 0)
{
	if (argNum < 2)
	{
		CON->Printf("[?] EXEC filename.cfg");
		return;
	}
	CON->ExecuteFile(NULL, argList[1], true);
}

CONFUNC(Echo, NULL, 0)
{
	static char tbuffer[256];
	if (argNum < 2)
		return;
	tbuffer[0] = 0;
	for (int i=1;i<argNum-1;i++)
	{
		strcat(tbuffer, argList[i]);
		strcat(tbuffer, " ");
	}
	strcat(tbuffer, argList[i]);
	CON->Printf(tbuffer);
}

CONFUNC(Help, NULL, 0)
{
	CON->Printf("Help: Executing \"listcmds\"");
	CON->Execute(NULL, "listcmds", 0);
}

//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    CLASS CConVar
//**
//****************************************************************************

//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
CConVar::CConVar(void *invaluePtr, char *varType, char *varName, U32 inflags,
				 float clampmin, float clampmax, void (*cback)())
{
	D_ASSERT(CON);
	name = ALLOC(char, fstrlen(varName)+1);
	strcpy(name, varName);
	_strlwr(name);
	vtype = ALLOC(char, fstrlen(varType)+1);
	strcpy(vtype, varType);
	valuePtr = (char *)invaluePtr;
	flags = inflags;
	clamp[0] = clampmin;
	clamp[1] = clampmax;
	callbackfunc = cback;
	handler = CON->GetHandlerForType(varType);
	//if (!handler)
	//	M_Error("Convar %s declared of unknown type", varName);
	next = NULL;
	CON->RegisterVariable(this);
}

CConVar::~CConVar()
{
	FREE(name);
	FREE(vtype);
	name=null;
	vtype=null;
}

//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------

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

//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
CConFunc::CConFunc(char *funcName, void (*inFunc)(CConVar *, int, char **),
	U32 inflags, U32 isHandler, char *handlerType)
{
	D_ASSERT(CON);
	if (isHandler)
	{
		name = ALLOC(char, fstrlen(handlerType)+1);
		strcpy(name, handlerType);
	}
	else
	{
		name = ALLOC(char, fstrlen(funcName)+1);
		strcpy(name, funcName);
	}
	_strlwr(name);
	func = inFunc;
	flags = inflags;	
	next = NULL;
	if (isHandler)
	{
		CON->RegisterVarHandler(this);
	}
	else
	{
		CON->RegisterFunction(this);
	}
}

CConFunc::~CConFunc()
{
	FREE(name);
	name=null;
}

//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------

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

//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
CConsoleManager::CConsoleManager()
{
	if (CON)
		xxx_fatal("Console already initialized");

	int i;

	vars = NULL;
	funcs = NULL;
	handlers = NULL;
	cmdArgc = 0;
	cmdLine[0] = 0;
	for (i=0;i<CON_MAXARGS;i++)
		cmdArgv[i] = NULL;
	cmdDisplay = ALLOC(char, CON_DISPLAYLINES*CON_MAXLINELEN);
	cmdDisplayIndex = 0;
	memset(cmdDisplay, 0, CON_DISPLAYLINES*CON_MAXLINELEN);
	for (i=0;i<CON_HISTORYLINES;i++)
		cmdHistory[i][0] = 0;
	cmdHistoryIndex = 0;
	//IN_RegisterBindClass("console");
	Printf("Cannibal startup...");
	CON=this;
}

CConsoleManager::~CConsoleManager()
{
	CON=null;
}
//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------
CConFunc *CConsoleManager::GetHandlerForType(char *varType)
{
	CConFunc *hdl;
	for (hdl = handlers; hdl; hdl = hdl->next)
	{
		if (!_stricmp(hdl->name, varType))
			return(hdl);
	}
	return(NULL);
}

void CConsoleManager::RegisterVariable(CConVar *var)
{
	var->next = vars;
	vars = var;
}

void CConsoleManager::DeRegisterVariable(CConVar *var)
{
	CConVar *v, *last = NULL;
	for (v = vars; v; last = v, v = v->next)
	{
		if (v == var)
		{
			if (last)
			{
				last->next = v->next;
			}
			else
			{
				vars = v->next;
			}
			return;
		}
	}
}

void CConsoleManager::RegisterVarHandler(CConFunc *handler)
{
	handler->next = handlers;
	handlers = handler;
}

void CConsoleManager::RegisterFunction(CConFunc *func)
{
	func->next = funcs;
	funcs = func;
}

void CConsoleManager::ExecuteFile(overlay_t *ovlcontext, CC8 *filename, U32 alertfail)
{
	static char execbuf[256];
	static char filebuf[256];
	char *ptr;
	int len, elen;
	filebuf[0] = 0;
	if (!strchr(filename, ':'))
	{
		strcpy(filebuf, mesh_app.get_app_path());
		strcat(filebuf, "\\");
		strcat(filebuf, "config\\");
	}
	strcat(filebuf, filename);
	SYS_SuggestFileExtention(filebuf, "cfg");
	FILE *fp = fopen(filebuf, "rb");
	if (!fp)
	{
		if (alertfail)
			Printf("Exec: Cannot open %s", filebuf);
		return;
	}
	Printf("Execing %s", filebuf);
	fseek(fp, 0, SEEK_END);
	len = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	
	autochar cfgbuf=(char *)xmalloc(len+1);

	SYS_SafeRead(cfgbuf, 1, len, fp);
	fclose(fp);
	execbuf[0] = 0; elen = 0;
	for (ptr=cfgbuf;ptr<(cfgbuf+len);ptr++)
	{
		if (*ptr == 13)
		{
			Execute(ovlcontext, execbuf, 0);
			elen = 0;
			execbuf[elen] = 0;
		}
		else
		{
			if (*ptr != 10)
			{
				execbuf[elen++] = *ptr;
				execbuf[elen] = 0;
			}
		}
	}
}

void CConsoleManager::ExecuteCmdLine(overlay_t *ovlcontext, int argc, CC8 **argv)
{
	int i;
	static char ebuf[256];

	ebuf[0] = 0;
	for (i=1;i<argc;i++)
	{
		if (argv[i][0] == '+')
		{
			if (ebuf[0])
				Execute(ovlcontext, ebuf, 0);
			strcpy(ebuf, &argv[i][1]);
		}
		else
		if (argv[i][0] == '-')
		{
			if (ebuf[0])
				Execute(ovlcontext, ebuf, 0);
			ebuf[0] = 0;
		}
		else
		{
			if (ebuf[0])
			{
				strcat(ebuf, " ");
				strcat(ebuf, argv[i]);
			}
		}
	}
	if (ebuf[0])
		Execute(ovlcontext, ebuf, 0);
}

U32 CConsoleManager::Execute(overlay_t *ovlcontext, CC8 *cmd, U32 ccflags)
{
	char cmdBuffer[256];
	char pendingBuffer[256];

	enum
	{
		STATE_NORMAL,
		STATE_QUOTE
	};

	if (ovlcontext)
	{
		if (OVL_SendPressCommand(ovlcontext, cmd))
			return(1);
	}

	char *ptr = cmdLine;
	int state = STATE_NORMAL;
	int inWhiteSpace = 1;

	strcpy(cmdBuffer, cmd);
	cmdArgc = 0;
	pendingBuffer[0] = 0;
	for (ptr=cmdBuffer;*ptr;ptr++)
	{
		if (state == STATE_NORMAL)
		{
			if (*ptr == ';')
			{
				*ptr = 0;
				strcpy(pendingBuffer, ptr+1);
				ptr--; // so the zero will catch
			}
			else
			if ((*ptr == '/') && (*(ptr+1) == '/'))
			{
				*ptr = 0;
				ptr--; // starting a comment, line's over
			}
			else
			if (*ptr == '`')
			{
				*ptr = '\"'; // replace tilde-key apostrophes with literal quotes
			}
			else
			if (*ptr == ' ')
			{
				*ptr = 0;
				inWhiteSpace = 1;
			}
			else
			if (inWhiteSpace)
			{
				if (cmdArgc >= CON_MAXARGS)
				{
					*ptr = 0;
					ptr--;
				}
				else
				{
					cmdArgv[cmdArgc] = ptr;
					cmdArgc++;
					inWhiteSpace = 0;
					if (*ptr == '\"')
					{
						state = STATE_QUOTE;
						cmdArgv[cmdArgc-1] = ptr+1;
					}
				}
			}
		}
		else
		if (state == STATE_QUOTE)
		{
			if (*ptr == '\"')
			{
				*ptr = 0;
				state = STATE_NORMAL;
				inWhiteSpace = 1;
			}
			else
			if (*ptr == '`')
			{
				*ptr = '\"'; // replace tilde-key apostrophes with literal quotes
			}
		}
		else
			SYS_Error("CON->Execute: Unknown state");
	}
	if (!cmdArgc)
		return(0);

	int ok = 0;
	// check convars first
	CConVar *v, *last=NULL;
	for (v = vars; v; last=v, v = v->next)
	{
		if (!_stricmp(v->name, cmdArgv[0]))
		{
			if (!v->handler)
			{
				v->handler = GetHandlerForType(v->vtype);
				if (!v->handler)
				{
					Printf("Unknown data type %s", _strlwr(v->vtype));
					ok = 1;
					break;
				}
			}
			// call type handler
			v->handler->func(v, cmdArgc, cmdArgv);
			// call callback if applicable
			if (v->callbackfunc)
				v->callbackfunc();
			if (last)
			{
				last->next = v->next;
				v->next = vars;
				vars = v; // move accessed var to top
			}
			ok = 1;
			break;
		}
	}
	// now check confuncs
	CConFunc *f, *flast=NULL;
	for (f = funcs; f && (!ok); flast=f, f = f->next)
	{
		if (!_stricmp(f->name, cmdArgv[0]))
		{
			if (flast)
			{
				flast->next = f->next;
				f->next = funcs;
				funcs = f; // move accessed func to top
			}
			f->func(NULL, cmdArgc, cmdArgv);
			ok = 1;
			break;
		}
	}
	if (!ok)
	{
		Printf("Unknown variable/cmd: %s", _strlwr(cmdArgv[0]));
		return(0);
	}

	if (pendingBuffer[0])
		return(Execute(ovlcontext, pendingBuffer, ccflags));
	return(1);
}

char *CConsoleManager::MatchCommand(char *namestart, int skipmatches, int len)
{
	CConVar *v, *last=NULL;
	char *lastmatch=NULL;
	int oldmatches = skipmatches;
	while (1)
	{
		for (v = vars; v; last=v, v = v->next)
		{
			if (!_strnicmp(v->name, namestart, len))
			{
				lastmatch = v->name;
				if (!skipmatches)
					return(lastmatch);
				else
					skipmatches--;
			}
		}
		CConFunc *f, *flast=NULL;
		for (f = funcs; f; flast=f, f = f->next)
		{
			if (!_strnicmp(f->name, namestart, len))
			{
				lastmatch = f->name;
				if (!skipmatches)
					return(lastmatch);
				else
					skipmatches--;
			}
		}
		if (skipmatches == oldmatches)
			return(NULL);
	}
	return(lastmatch);
}

void CConsoleManager::Printf(CC8 *msg, ... )
{
	static char textBuffer[255];
	int i, len, textptr;

	va_list args;
	va_start(args, msg);
	vsprintf(textBuffer, msg, args);
	va_end(args);

	memset(cmdDisplay+(cmdDisplayIndex*CON_MAXLINELEN), 0, 256);
	textptr = 0;
	len = fstrlen(textBuffer);
	if (len > (CON_MAXLINELEN-1))
		len = CON_MAXLINELEN-1;
	for (i=0;i<len;i++)
	{
		if (textBuffer[i] != '\n')
		{
			cmdDisplay[(cmdDisplayIndex*CON_MAXLINELEN)+textptr] = textBuffer[i];
			textptr++;
		}
		else
		{
			cmdDisplayIndex++;
			cmdDisplayIndex %= CON_DISPLAYLINES;
			textptr = 0;
		}
	}
	if (textptr)
	{
		cmdDisplayIndex++;
		cmdDisplayIndex %= CON_DISPLAYLINES;
	}
}

/* ----------------------------- */
/* ConQueue */
/* ----------------------------- */
ConQueue::ConQueue(U32 def_size) : num_args(0),arg_list(null),action_data(null),buf_size(0)
{
	D_ASSERT(def_size);

	buffer=(char *)xmalloc(def_size);
	buf_size=def_size;
}

void ConQueue::set_args(U32 num,CC8 **list)
{
	U32 mem_needed=get_size_needed(num,list);

	if (mem_needed > buf_size)
		realloc(mem_needed);

	arg_list=(CC8 **)buffer.get_ptr();
	char *ptr=buffer + (num*sizeof(void *));
	
	for (U32 i=0;i<num;i++)
	{
		arg_list[0]=ptr;
		ptr=fstrcpy(ptr,list[i]);
		ptr++;
	}
	D_ASSERT(ptr <= (buffer + buf_size));
}

U32 ConQueue::get_size_needed(U32 num,CC8 **list)
{
	U32 mem_needed;

	mem_needed=num*sizeof(void *);
	for (U32 i=0;i<num;i++)
		mem_needed+=fstrlen(list[i])+1;

	return mem_needed;
}

void ConQueue::realloc(U32 size_needed)
{
	D_ASSERT(size_needed);
	delete buffer;
	buffer=(char *)xmalloc(size_needed);
}

/* ----------------------------- */
/* ConQueueList */
/* ----------------------------- */
XPos *ConQueueList::find_size(U32 size_needed)
{
	XNode *node;

	node=head;
	while(node)
	{
		ConQueue *q=node->data;
		if (q->get_size() >= size_needed)
			return (XPos *)node;
		node=node->next;
	}
	return null;
}

/* ----------------------------- */
/* ConQueueSystem */
/* ----------------------------- */
ConQueueSystem::ConQueueSystem(U32 def_num)
{
	for (U32 i=0;i<def_num;i++)
	{
		ConQueue *obj;
		
		obj=new ConQueue;
		free.add_head(obj);
	}
}

ConQueue *ConQueueSystem::get_queue(U32 num,CC8 **list)
{
	U32 size_needed=ConQueue::get_size_needed(num,list);

	/* if none available */
	if (!free.get_head_position())
	{
		ConQueue *obj;

		obj=new ConQueue(size_needed);
		free.add_head(obj);
	}

	XPos *node=free.find_size(size_needed);
	
	ConQueue *q=free.get_at(node);	
	free.remove(node);

	q->set_args(num,list);
	return q;
}

void ConQueueSystem::add_queue(ConQueue *q)
{
	if (!q)
		xxx_fatal("ConQueueSystem::add_queue: adding null");

	active.add_tail(q);
}

void ConQueueSystem::handle_actions(void)
{
	ConQueue *q;

	while(q=active.remove_head())
	{
		con_action_f action;
		
		action=q->get_action();
		action(q);
		free.add_head(q);
	}
}