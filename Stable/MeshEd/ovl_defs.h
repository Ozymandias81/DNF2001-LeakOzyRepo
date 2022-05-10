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
class OWindow : public overlay_t
{
public:

    OVL_DEFINE2(OWindow, overlay_t)
	OWindow(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OWindow"); }
    OWindow(COvlTypeDecl *decl, overlay_t *parentwindow) : overlay_t(decl, parentwindow)
    {
    }

    ~OWindow() {}

	U32 OnPressCommand(int argNum, CC8 **argList);
	U32 OnMessage(ovlmsg_t *msg);
};
extern OWindow OWindow_ovlprototype;

///////////////////////////////////////////
////	OWindowScrollable
///////////////////////////////////////////
class OWindowScrollable : public OWindow
{
private:
	int startx, starty;

public:
    OVL_DEFINE2(OWindowScrollable, OWindow)
	OWindowScrollable(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OWindowScrollable"); }
    OWindowScrollable(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
	{
	}
    ~OWindowScrollable() {}
	
	U32 OnPressCommand(int argNum, CC8 **argList);
	U32 OnDragCommand(int argNum, CC8 **argList);
	U32 OnReleaseCommand(int argNum, CC8 **argList);
};
extern OWindowScrollable OWindowScrollable_ovlprototype;

///////////////////////////////////////////
////	OConsole
///////////////////////////////////////////
class OConsole : public OWindow
{
private:	
	short clicker;
	int dispBackScroll;
	overlay_t *target;

public:

    OVL_DEFINE2(OConsole, OWindow)
	OConsole(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OConsole"); }
    OConsole(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
    {
		clicker = 0;
		dispBackScroll = 0;
		target = NULL;
    }

    ~OConsole() {}

	U32 OnMessage(ovlmsg_t *msg);
	U32 OnPressCommand(int argNum, CC8 **argList);
	void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
	U32 OnPress(inputevent_t *event);
};
extern OConsole OConsole_ovlprototype;


//****************************************************************************
//**
//**    END HEADER OVL_DEFS.H
//**
//****************************************************************************
#endif // __OVL_DEFS_H__
