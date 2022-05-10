//****************************************************************************
//**
//**    IPCMAIN.CPP
//**    Interprocess Communication
//**	Used only between multiple instantiations of kernel library
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "IpcMain.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define IPC_MAXMESSAGES		512
#define IPC_MAXPROCESSES	8

enum
{
	IPCMF_Handled		= 0x00000001, // message has been handled in a GetMessages call
	IPCMF_SenderFree	= 0x00000002, // needs a result, so sender will free the message
};

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
struct SIpcMsg
{
	NDword mSenderProcess; // process which sent this message
	NDword mProtocol; // application-defined protocol value indicating the message value's type
	NDword mMessage; // message value, meaning determined by application according to protocol
	NDword mFlags; // IPCMF_ message flags
	NDword mParamValue; // parameter value, arbitrary meaning
	NChar mParamString[128]; // parameter string, arbitrary meaning
	SIpcMsg* mPrev; // linked list link
	SIpcMsg* mNext; // linked list link
};
struct SIpcProcess
{	
	NDword mIndex; // process index
	NDword mPlatformId; // unique platform-determined identifier for owning process, must be nonzero
	NDword mMutex; // mutex block activated when messages are being manipulated on this process, set to current thread
	SIpcMsg mMessageList; // incoming message list head link
	NChar mProcessName[64]; // string name of process for finding
};

//============================================================================
//    PRIVATE DATA
//============================================================================
#pragma data_seg(".shared")

NBool ipc_Initialized = 0; // global initialization
SIpcMsg ipc_MsgPool[IPC_MAXMESSAGES] = {{0,0,0,0,0,0,{0},NULL,NULL}}; // pool where messages actually reside
SIpcMsg ipc_MsgFreeList = {0,0,0,0,0,0,{0},NULL,NULL}; // free list head link
SIpcProcess ipc_Processes[IPC_MAXPROCESSES] = {{0,0,0,{0,0,0,0,0,0,{0},NULL,NULL},{0}}};

#pragma data_seg()
#pragma comment(linker, "/SECTION:.shared,RWS")

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static SIpcMsg* IPC_AllocMessage()
{
	// if we don't have any available messages in the free list, we failed
	if (ipc_MsgFreeList.mNext == &ipc_MsgFreeList)
		return(NULL);

	// disconnect a message from the list and return it
	SIpcMsg* msg = ipc_MsgFreeList.mNext;
	msg->mPrev->mNext = msg->mNext;
	msg->mNext->mPrev = msg->mPrev;
	msg->mNext = msg->mPrev = msg;
	
	return(msg);
}

static void IPC_FreeMessage(SIpcMsg* inMsg)
{
	if (!inMsg)
		return;

	// disconnect this message from wherever it may have previously been
	inMsg->mPrev->mNext = inMsg->mNext;
	inMsg->mNext->mPrev = inMsg->mPrev;

	// add the message back into the free list
	inMsg->mPrev = &ipc_MsgFreeList;
	inMsg->mNext = ipc_MsgFreeList.mNext;
	inMsg->mPrev->mNext = inMsg->mNext->mPrev = inMsg;
}

static void SetMutex(SIpcProcess* inProcess)
{
	while (inProcess->mMutex && (inProcess->mMutex != GetCurrentThreadId()))
		Sleep(0);
	inProcess->mMutex = GetCurrentThreadId();
}

static void ClearMutex(SIpcProcess* inProcess)
{
	inProcess->mMutex = 0;
}

static SIpcProcess* IPC_AllocProcess()
{
	for (NDword i=0;i<IPC_MAXPROCESSES;i++)
	{
		SIpcProcess* p = &ipc_Processes[i];
		if (p->mPlatformId)
			continue; // already taken
		p->mPlatformId = (NDword)GetCurrentProcessId(); // calling actual process module handle
		//LOG_Logf("BLARGO: IPC_AllocProcess: Index %d, threadid %d, processes base %X", i, p->mPlatformId, ipc_Processes);
		return(p);
	}
	return(NULL); // none available
}

static void IPC_FreeProcess(SIpcProcess* inProcess)
{
	if (!inProcess)
		return;
	
	inProcess->mPlatformId = 0; // available again

	SetMutex(inProcess);
	while (inProcess->mMessageList.mNext != &inProcess->mMessageList)
		IPC_FreeMessage(inProcess->mMessageList.mNext); // free all remaining messages
	ClearMutex(inProcess);
}

static SIpcProcess* IPC_FindCurrentProcess()
{
	NDword curModuleHandle = (NDword)GetCurrentProcessId();
	for (NDword i=0;i<IPC_MAXPROCESSES;i++)
	{
		if (ipc_Processes[i].mPlatformId == curModuleHandle)
			return(&ipc_Processes[i]);
	}
	return(NULL);
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API NBool IPC_Init(const NChar* inProcessName)
{
	// global initialization
	if (!ipc_Initialized)
	{
		// message free list
		ipc_MsgFreeList.mPrev = ipc_MsgFreeList.mNext = &ipc_MsgFreeList;
		for (NDword i=0;i<IPC_MAXMESSAGES;i++)
		{
			SIpcMsg* msg = &ipc_MsgPool[i];
			msg->mPrev = &ipc_MsgFreeList;
			msg->mNext = ipc_MsgFreeList.mNext;
			msg->mPrev->mNext = msg->mNext->mPrev = msg;
		}

		// process list
		for (i=0;i<IPC_MAXPROCESSES;i++)
		{
			SIpcProcess* p = &ipc_Processes[i];
			p->mIndex = i + 1;
			p->mPlatformId = 0;
			p->mMessageList.mPrev = p->mMessageList.mNext = &p->mMessageList;
		}

		ipc_Initialized = 1;
	}
	
	// snag a process
	SIpcProcess* p = IPC_AllocProcess();
	if (!p)
		return(0);
	if (!inProcessName)
		inProcessName = "";
	strcpy(p->mProcessName, inProcessName);
	return(1);
}
KRN_API void IPC_Shutdown()
{
	IPC_FreeProcess(IPC_FindCurrentProcess()); // release the process
}
KRN_API NDword IPC_GetCurrentProcess()
{
	SIpcProcess* p = IPC_FindCurrentProcess();
	if (!p)
		return(0);
	return(p->mIndex);
}
KRN_API NDword IPC_GetNamedProcess(const NChar* inProcessName)
{	
	for (NDword i=0;i<IPC_MAXPROCESSES;i++)
	{
		if (!strcmp(inProcessName, ipc_Processes[i].mProcessName))
			return(ipc_Processes[i].mIndex);
	}
	return(0);
}

KRN_API NBool IPC_PostMessage(NDword inTargetProcess, NDword inProtocol, NDword inMessage, NDword inParamValue, NChar* inParamString)
{
	// make sure we are a valid source
	SIpcProcess* src = IPC_FindCurrentProcess();
	if (!src)
		return(0);
	
	// make sure the target is valid
	if (!inTargetProcess)
		return(0);
	SIpcProcess* dest = &ipc_Processes[inTargetProcess-1];
	if (!dest->mPlatformId)
		return(0);

	// set up a message
	SIpcMsg* msg = IPC_AllocMessage();
	if (!msg)
		return(0);

	SetMutex(dest);

	msg->mSenderProcess = src->mIndex;
	msg->mProtocol = inProtocol;
	msg->mMessage = inMessage;
	msg->mFlags = 0;
	msg->mParamValue = inParamValue;
	msg->mParamString[0] = 0;
	if (inParamString)
	{
		strncpy(msg->mParamString, inParamString, 127);
		msg->mParamString[127] = 0;
	}

	// connect the message to the end of the target process's message list
	msg->mPrev = dest->mMessageList.mPrev;
	msg->mNext = &dest->mMessageList;
	msg->mPrev->mNext = msg->mNext->mPrev = msg;

	ClearMutex(dest);

	return(1);
}
KRN_API NDword IPC_SendMessage(NDword inTargetProcess, NDword inProtocol, NDword inMessage, NDword inParamValue, NChar* inParamString, NChar* outResultString)
{
	// make sure we are a valid source
	SIpcProcess* src = IPC_FindCurrentProcess();
	if (!src)
		return(0);
	
	// make sure the target is valid
	if (!inTargetProcess)
		return(0);
	SIpcProcess* dest = &ipc_Processes[inTargetProcess-1];
	if (!dest->mPlatformId)
		return(0);

	// set up a message
	SIpcMsg* msg = IPC_AllocMessage();
	if (!msg)
		return(0);

	SetMutex(dest);

	msg->mSenderProcess = src->mIndex;
	msg->mProtocol = inProtocol;
	msg->mMessage = inMessage;
	msg->mFlags = IPCMF_SenderFree;
	msg->mParamValue = inParamValue;
	msg->mParamString[0] = 0;
	if (inParamString)
	{
		strncpy(msg->mParamString, inParamString, 127);
		msg->mParamString[127] = 0;
	}

	// connect the message to the end of the target process's message list
	msg->mPrev = dest->mMessageList.mPrev;
	msg->mNext = &dest->mMessageList;
	msg->mPrev->mNext = msg->mNext->mPrev = msg;

	ClearMutex(dest);

	// wait for message's "needs result" flag to be cleared during handling
	while (!(msg->mFlags & IPCMF_Handled))
		Sleep(0);

	SetMutex(dest);

	// message has been processed, result should be valid, free the message and return
	NDword result = msg->mParamValue;
	if (outResultString)
		strcpy(outResultString, msg->mParamString);
	IPC_FreeMessage(msg);
	
	ClearMutex(dest);
	
	return(result);
}

KRN_API NBool IPC_GetMessages(FIpcMessageFunc inFunc, NDword inProtocol, void* inUserData)
{
	if (!inFunc)
		return(0);

	// make sure we are a valid process and we have messages pending
	SIpcProcess* p = IPC_FindCurrentProcess();
	if (!p || (p->mMessageList.mNext == &p->mMessageList))
		return(0);

	SetMutex(p);

	// iterate through all the messages and handle them
	SIpcMsg* next;
	for (SIpcMsg* m = p->mMessageList.mNext; m != &p->mMessageList; m = next)
	{
		next = m->mNext; // incase the message is removed

		if (m->mProtocol != inProtocol)
			continue; // different protocol than what we're reading, skip it
		if (m->mFlags & IPCMF_Handled)
			continue; // message has already been handled, might be waiting for sender to free it, skip it

		// handle it
		ClearMutex(p);
		m->mParamValue = inFunc(m->mSenderProcess, m->mMessage, m->mParamValue, m->mParamString, inUserData);
		m->mFlags |= IPCMF_Handled;
		SetMutex(p);

		// unless the sender is freeing it, remove it from the list
		if (!(m->mFlags & IPCMF_SenderFree))
			IPC_FreeMessage(m);
	}
	
	ClearMutex(p);

	// all done
	return(1);
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE IPCMAIN.CPP
//**
//****************************************************************************

