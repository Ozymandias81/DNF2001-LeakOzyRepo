#ifndef __MACEDIT_H__
#define __MACEDIT_H__
//****************************************************************************
//**
//**    MACEDIT.H
//**    Header - Model Actor Editor
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================

// IPC communication info - inbound messages (hook to editor)
#define MACEDIT_IPC_PROTOCOL_IN		0x56582106
enum
{
	MACEDIT_IPC_IMSG_CLOSE			= 0x01,	// no parameters, request to close the dialog
	MACEDIT_IPC_IMSG_SETTITLE		= 0x02,	// paramString = title to set edit box to
	MACEDIT_IPC_IMSG_SELECTCONFIG	= 0x03, // paramString = configuration name to select in tree view
};

// IPC communication info - outbound messages (editor to hook)
#define MACEDIT_IPC_PROTOCOL_OUT	0x56582107
enum
{
	MACEDIT_IPC_OMSG_SETCONFIG		= 0x81,	// paramString = new configuration name, return value ignored
	MACEDIT_IPC_OMSG_GETCURTEXREF	= 0x82,	// paramString = outbuffer to place current texture ref name, should return 1
	MACEDIT_IPC_OMSG_ACTORUPDATE	= 0x83,	// paramString = temp configuration file to update contents of actor from
	MACEDIT_IPC_OMSG_TEXREFUPDATE	= 0x84,	// no parameters, texture refs have changed, update objects in memory
};

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void MAC_EditBox(NDword inIpcHook);

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER MACEDIT.H
//**
//****************************************************************************
#endif // __MACEDIT_H__
