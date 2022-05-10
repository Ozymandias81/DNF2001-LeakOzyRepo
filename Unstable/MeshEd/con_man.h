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
class CConVar
{
public:
    // data
	char *name;
	void *valuePtr;
	U32 flags;
	CConFunc *handler;
	char *vtype;
	float clamp[2];
	void (*callbackfunc)();
	CConVar *next;
    // construction
	CConVar(void *invaluePtr, char *varType, char *varName, U32 inflags,
		float clampmin, float clampmax, void (*cback)());
	~CConVar();
    // methods
};

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
class CConFunc
{
public:
    // data	
	char *name;
	void (*func)(CConVar *, int, char**);
	U32 flags;
	CConFunc *next;
    // construction
	CConFunc(char *funcName, void (*inFunc)(CConVar *, int, char **),
		U32 inflags, U32 isHandler, char *handlerType);
	~CConFunc();
    // methods
    // friend classes
	friend class CConsoleManager;
};

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
	autochar cmdDisplay;
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
	U32 Execute(overlay_t *ovlcontext, CC8 *cmd, U32 ccflags);
	void ExecuteFile(overlay_t *ovlcontext, CC8 *filename, U32 alertfail);
	void ExecuteCmdLine(overlay_t *ovlcontext, int argc, CC8 **argv);
	char *MatchCommand(char *namestart, int skipmatches, int len);
	void Printf(CC8 *msg, ... );
};

class ConQueue;
typedef U32 (*con_action_f)(ConQueue *q);

class ConQueue
{
	U32				num_args;
	CC8				**arg_list;
	void			*action_data;
	con_action_f	action;

	U32				buf_size;
	autochar		buffer;
protected:
	void realloc(U32 size_needed);

public:
	ConQueue(U32 def_size=512);
	U32 get_size(void){return buf_size;}
	void set_args(U32 num,CC8 **list);
	void set_action(con_action_f func){action=func;}
	void set_data(void *data){action_data=data;}
	void get_args(U32 &num,CC8 **&list){num=num_args;list=arg_list;}
	con_action_f get_action(void){return action;}
	static U32 get_size_needed(U32 num,CC8 **list);
};

class ConQueueList : public XList<ConQueue>
{
public:
	XPos *find_size(U32 size_needed);
};

class ConQueueSystem
{
	ConQueueList	active;
	ConQueueList	free;
public:
	ConQueueSystem(U32 def_num=4);
	ConQueue *get_queue(U32 num,CC8 **list);
	void add_queue(ConQueue *q);
	void handle_actions(void);
};

#endif // __CON_MAN_H__
