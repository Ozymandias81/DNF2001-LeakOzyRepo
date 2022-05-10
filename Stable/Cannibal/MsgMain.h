#ifndef __MSGMAIN_H__
#define __MSGMAIN_H__
//****************************************************************************
//**
//**    MSGMAIN.H
//**    Header - Messenger
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//#define MSG_CALL(xtype) extern "C" __declspec(dllexport) xtype __cdecl
#define MSG_CALL(xtype) extern "C" xtype __cdecl

#define MSG_FUNC_RAW(xrouter, xname) \
	MSG_CALL(NBool) xname##_msgraw_##xrouter(IMsgTarget* This, IMsg* inMsg); \
	NBool xname##_msgraw_##xrouter##_dummy = MSG_RegisterHandlerRaw(#xrouter, #xname, xname##_msgraw_##xrouter); \
	MSG_CALL(NBool) xname##_msgraw_##xrouter(IMsgTarget* This, IMsg* inMsg)
#define MSG_FUNC_RAW_GLOBAL(xname) \
	MSG_CALL(NBool) xname##_msgraw_global(IMsgTarget* This, IMsg* inMsg); \
	NBool xname##_msgraw_global_dummy = MSG_RegisterHandlerRaw(NULL, #xname, xname##_msgraw_global); \
	MSG_CALL(NBool) xname##_msgraw_global(IMsgTarget* This, IMsg* inMsg)

#define MSG_FUNC_C(xrouter, xname, xparmstr, parms) \
	MSG_CALL(NBool) xname##_msg_##xrouter parms; \
	NBool xname##_msg_##xrouter##_dummy = MSG_RegisterHandlerC(#xrouter, #xname, xname##_msg_##xrouter, xparmstr); \
	MSG_CALL(NBool) xname##_msg_##xrouter parms
#define MSG_FUNC_C_GLOBAL(xname, xparmstr, parms) \
	MSG_CALL(NBool) xname##_msg_global parms; \
	NBool xname##_msg_global_dummy = MSG_RegisterHandlerC(NULL, #xname, xname##_msg_global, xparmstr); \
	MSG_CALL(NBool) xname##_msg_global parms

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class IMsgToken;
class IMsg;
class IMsgTarget;
class IMsgRouter;

/*
	IMsgToken
	Single argument of a string-based message.
*/
/* --RETARDED-- */
/* change this structure and die painfully */
class IMsgToken
{
public:
	NChar m_String[256];
	NInt m_Int;
	NFloat m_Float;

	virtual NChar* GetString() { return(m_String); }
	virtual NInt GetInt() { return(m_Int); }
	virtual NFloat GetFloat() { return(m_Float); }
};

/*
	IMsg
	Argument-separated string-based message.
*/
/* --RETARDED-- */
class IMsg
{
public:
	NDword m_Argc;
	IMsgToken m_Argv[32];

	virtual NDword Argc() { return(m_Argc); }
	virtual IMsgToken* Argv(NDword inIndex) { return(&m_Argv[inIndex]); }
};

/*
	IMsgRouter
	Routes a message through any global message handlers registered to it.
*/
class KRN_API IMsgRouter
{
public:
	virtual NBool MsgRoute(IMsgTarget* inTarget, IMsg* inMsg)=0; // routes a message

	NBool MsgRoutef(IMsgTarget* inTarget, NChar* inFmt, ... ); // variable-argument string message
	NBool MsgRouteFile(IMsgTarget* inTarget, NChar* inFileName); // execute a series of messages from a script file
	virtual U32 Delete(void)=null;
};

/*
	IMsgTarget
	Target of messages.  If an implementor does not handle a message directly,
	it should pass it down to a router so any global message handlers can be checked.
	The MsgGetChild, MsgGetParent, and MsgGetRoot functions are used by Msgf to allow
	the message command to contain a target "path" for determining the final target.
*/
class KRN_API IMsgTarget
{
public:
	virtual NBool Msg(IMsg* inMsg)=0; // processes a message
	virtual IMsgTarget* MsgGetChild(NChar* inChildName)=0; // locates a child target if present
	virtual IMsgTarget* MsgGetParent()=0; // locates the parent target if present
	virtual IMsgTarget* MsgGetRoot()=0; // locates the root target if present

	NBool Msgf(NChar* inFmt, ... ); // variable-argument string message
	NBool MsgFile(NChar* inFileName); // execute a series of messages from a script file
	IMsgTarget* MsgGetPathTarget(NChar* inPath); // locate a target from path, using child/parent/root functions
};

typedef NBool (*FMsgHandlerRaw)(IMsgTarget* This, IMsg* inMsg); // Raw message handler
typedef void* FMsgHandlerC; // C-style message handler, (IMsgTarget* This, IMsg* inMsg, ... )

//============================================================================
//    GLOBAL DATA
//============================================================================
extern "C"{
extern U32 _msg_string_off;
extern U32 _msg_float_off;
extern U32 _msg_int_off;
extern U32 _msg_token_size;
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void MSG_Init();
KRN_API void MSG_Shutdown();
KRN_API void InitMsgAsm(void);

// creates/finds a message router for global handlers, with the given name
// passing in a NULL name returns the stock global router
KRN_API IMsgRouter* MSG_MakeRouter(NChar* inName);

// global handler auto-registration, can use NULL router name for global router
KRN_API NBool MSG_RegisterHandlerRaw(const NChar* inRouterName, const NChar* inName, FMsgHandlerRaw inHandler);
KRN_API NBool MSG_RegisterHandlerC(const NChar* inRouterName, const NChar* inName, FMsgHandlerC inHandler, const NChar* inParms);

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER MSGMAIN.H
//**
//****************************************************************************
#endif // __MSGMAIN_H__
