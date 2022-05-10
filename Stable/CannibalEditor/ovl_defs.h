#ifndef __OVL_DEFS_H__
#define __OVL_DEFS_H__
//****************************************************************************
//**
//**    OVL_DEFS.H
//**    Header - Overlays - Standard Overlay Type Definitions
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#ifndef __CBL_DEFS_H__
#include "cbl_defs.h"
#endif
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------

///////////////////////////////////////////
////	OWindow
///////////////////////////////////////////

OVLTYPE(OWindow, overlay_t)
{
public:

    OVL_DEFINE(OWindow, overlay_t)
    {
    }

    ~OWindow() {}

	boolean OnPressCommand(int argNum, char **argList);
	boolean OnMessage(ovlmsg_t *msg);
};
extern OWindow OWindow_ovlprototype;

///////////////////////////////////////////
////	OWindowScrollable
///////////////////////////////////////////

OVLTYPE(OWindowScrollable, OWindow)
{
private:
	int startx, starty;

public:
    OVL_DEFINE(OWindowScrollable, OWindow)
	{
	}
    ~OWindowScrollable() {}
	
	boolean OnPressCommand(int argNum, char **argList);
	boolean OnDragCommand(int argNum, char **argList);
	boolean OnReleaseCommand(int argNum, char **argList);
};
extern OWindowScrollable OWindowScrollable_ovlprototype;

///////////////////////////////////////////
////	OConsole
///////////////////////////////////////////

OVLTYPE(OConsole, OWindow)
{
private:	
	short clicker;
	int dispBackScroll;
	overlay_t *target;

public:

    OVL_DEFINE(OConsole, OWindow)
    {
		clicker = 0;
		dispBackScroll = 0;
		target = NULL;
    }

    ~OConsole() {}

	boolean OnMessage(ovlmsg_t *msg);
	boolean OnPressCommand(int argNum, char **argList);
	void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
	boolean OnPress(inputevent_t *event);
};
extern OConsole OConsole_ovlprototype;


//****************************************************************************
//**
//**    END HEADER OVL_DEFS.H
//**
//****************************************************************************
#endif // __OVL_DEFS_H__
