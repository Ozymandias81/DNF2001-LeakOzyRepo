#ifndef __IPCMAIN_H__
#define __IPCMAIN_H__
//****************************************************************************
//**
//**    IPCMAIN.H
//**    Header - Interprocess Communication
//**	Used only between multiple instantiations of kernel library
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
// message callback function
typedef NDword (*FIpcMessageFunc)(NDword inSenderProcess, NDword inMessage, NDword inParamV, NChar* inParamS, void* inUserData);

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API NBool IPC_Init(const NChar* inProcessName);
KRN_API void IPC_Shutdown();
KRN_API NDword IPC_GetCurrentProcess();
KRN_API NDword IPC_GetNamedProcess(const NChar* inProcessName);

KRN_API NBool IPC_PostMessage(NDword inTargetProcess, NDword inProtocol, NDword inMessage, NDword inParamValue, NChar* inParamString);
KRN_API NDword IPC_SendMessage(NDword inTargetProcess, NDword inProtocol, NDword inMessage, NDword inParamValue, NChar* inParamString, NChar* outResultString);

KRN_API NBool IPC_GetMessages(FIpcMessageFunc inFunc, NDword inProtocol, void* inUserData);

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER IPCMAIN.H
//**
//****************************************************************************
#endif // __IPCMAIN_H__
