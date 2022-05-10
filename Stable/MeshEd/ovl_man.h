#ifndef __OVL_MAN_H__
#define __OVL_MAN_H__
//****************************************************************************
//**
//**    OVL_MAN.H
//**    Header - Overlay Management
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
//#define OVLTYPE(xname, xroot) class xname : public xroot
#if 1
#define REGISTEROVLTYPE(xname, xroot) extern COvlTypeDecl xname##_ovldecltype; \
							   xname xname##_ovlprototype(&##xname##_ovldecltype, NULL); \
							   COvlTypeDecl xname##_ovldecltype(#xname, &##xname##_ovlprototype, &##xroot##_ovlprototype)
#endif
#if 0
#define OVL_DEFINE(xtype, xroot) \
    typedef xroot Super; \
	overlay_t *Spawn(COvlTypeDecl *decl, overlay_t *parentwindow) { return(new xtype(decl, parentwindow)); } \
	public: xtype() { SYS_Error("Default OVLCONSTRUCTOR received for type "#xtype); } \
    xtype(COvlTypeDecl *decl, overlay_t *parentwindow) : xroot(decl, parentwindow)
#endif
#define OVL_DEFINE2(xtype, xroot) \
    typedef xroot Super; \
	overlay_t *Spawn(COvlTypeDecl *decl, overlay_t *parentwindow) { return(new xtype(decl, parentwindow)); }

#define OVLCMDSTART if ((!argNum) || (!argList[0][0])) { return(1); }
#define OVLCMD(xstr) else if (!_stricmp(argList[0], xstr))

#define OVLMSG_NUMPARMS 12
#define OVLMSGPARM(parm, type) MEMCAST(type, msg->p[parm])
#define OVLMAKEMSGPARM(parm, type, name) type name = OVLMSGPARM(parm, type)
#define OVLMSGSTART if ((!msg->msgname) || (!msg->msgname[0])) { return(1); }
#define OVLMSG(message) else if (!_stricmp(msg->msgname, message))

typedef struct
{
	CC8 *msgname;
	void *p[OVLMSG_NUMPARMS];
} ovlmsg_t;

typedef struct
{
	int sx, sy, ex, ey;
} ovlClipBox_t;

typedef enum
{
	OVLTOOL_RADIO, // tool is a radio button with other tools in that radiogroup
	OVLTOOL_TOGGLE, // tool is an on/off toggle
	OVLTOOL_INSTANT, // tool is a button with a single instant action
	OVLTOOL_HSEPAR, // horizontal separator
	OVLTOOL_VSEPAR, // vertical separator

	OVLTOOL_NUMTYPES
} ovltooltype_t;

typedef struct ovltool_s ovltool_t;
struct ovltool_s
{	
	char name[64];
	ovltool_t *next, *prev;
	U32 active;
	char cursor[32];
	char button[32];
	ovltooltype_t tooltype;
	int radiogroup, flashframes;
	vector_t color;
	char commands[3][128];
	/* command 0
		INSTANT - command to execute on press
		TOGGLE - command to execute on activation
		RADIO - command to execute on activation
	   command 1
		INSTANT - unused
		TOGGLE - command to execute on deactivation
		RADIO - command to execute when toolbar gets "radiocmd #" command for a group
	   command 2
	    INSTANT - unused
		TOGGLE - unused
		RADIO - command to execute on deactivation		
	*/
};

#define OVLF_NODRAW			0x00000001		// overlay is not to be drawn
#define OVLF_NOINPUT		0x00000002		// overlay is not to receive user input
#define OVLF_NOBORDER		0x00000004		// don't draw a border
#define OVLF_NOTITLE		0x00000008		// don't draw a title bar
#define OVLF_NOERASECOLOR	0x00000010		// don't erase the color buffer in the window body
#define OVLF_NOERASEDEPTH	0x00000020		// don't erase the depth buffer in the window body
#define OVLF_NOMOVE			0x00000040		// overlay is not movable by user input
#define OVLF_NORESIZE		0x00000080		// overlay is not resizable by user input
#define OVLF_ALWAYSTOP		0x00000100		// overlay shouldn't be superceded when another overlay gets set topmost
#define OVLF_PROPORTIONAL	0x00000200		// resize should keep same window size ratio
#define OVLF_NOTITLEDESTROY	0x00000400		// title bar does not have a destroy button
#define OVLF_VIEWABSOLUTE	0x00000800		// always stay in view based on position, do not compensate for parent logical window
#define OVLF_NOTITLEMINMAX	0x00001000		// title bar does not have a minimize/maximize/restore button
#define OVLF_NODRAGDROP		0x00002000		// overlay cannot be dragged out of its parent into another
#define OVLF_NOFOCUS		0x00004000		// overlay should not be set as the focus overlay
#define OVLF_MEGALOCK		0x00008000		// not even UnlockInput can stop this lock; the overlay must do so itself

#define OVLF_REDRAWSWAP		0x00100000
#define OVLF_REDRAW			0x00200000		// overlay has been flagged for a redraw
#define OVLF_HASFOCUS		0x00400000		// overlay is the ovl_focusOverlay (used only during save/load)
#define OVLF_ROOTWINDOW		0x00800000		// overlay is the root window (for save/load, ONLY used by ovl_Windows) (private)
#define OVLF_TAGDESTROY		0x01000000		// overlay is tagged for deletion at the end of the frame (private)
#define OVLF_MAXIMIZED		0x02000000		// overlay is minimized (fullscreen within parent view) (private)
#define OVLF_MINIMIZED		0x04000000		// overlay is minimized (title bar visible only) (private)
#define OVLF_TOUCH			0x08000000		// overlay has been touched during a list walkthrough (private)
#define OVLF_HSCROLL		0x10000000		// horizontal scrollbar is active (private)
#define OVLF_VSCROLL		0x20000000		// vertical scrollbar is active (private)
#define OVLF_PROTOTYPE		0x40000000		// overlay is a creatable overlay prototype (private)
#define OVLF_DUMMY			0x80000000		// overlay is a dummy head node (private)

typedef enum
{
	OVLREGION_NONE,
	OVLREGION_BODY,
	OVLREGION_TITLE,
	OVLREGION_BLEFT,
	OVLREGION_BRIGHT,
	OVLREGION_BBOTTOM,
	OVLREGION_BTOP,
	OVLREGION_BULCORNER,
	OVLREGION_BURCORNER,
	OVLREGION_BLLCORNER,
	OVLREGION_BLRCORNER,
	OVLREGION_HSCROLL,
	OVLREGION_VSCROLL,
	OVLREGION_TDESTROY,
	OVLREGION_TMINIMIZE,
	OVLREGION_TMAXIMIZE,
	OVLREGION_TRESTORE,
	OVLREGION_DRAGDROP, // not an actual region, but trigger by window drag&drop operation

	OVLREGION_NUMTYPES
} ovlInputRegion_t;

//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
class ovlwindow_t;
class overlay_t;

//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
typedef struct
{
	char keyBindings[IN_NUMKEYS][8][256];
} ovl_bindconfig_t;

class COvlTypeDecl
{
public:
	const char *ovlTypeName;
	overlay_t *ovlPrototype;
	overlay_t *ovlPrototypeBase;
	COvlTypeDecl *next;
	ovl_bindconfig_t bindconfig;

	COvlTypeDecl(const char *name, overlay_t *proto, overlay_t *protobase);
	~COvlTypeDecl();
};

//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
extern overlay_t *ovl_lockOverlay, *ovl_focusOverlay, *ovl_Windows;

//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
void OVL_Init();
void OVL_Shutdown();
void OVL_Frame();
void OVL_InputEvent(inputevent_t *event);
void OVL_CreateRootWindow();
void OVL_SetTopmost(overlay_t *ovl);
void OVL_SetRedraw(overlay_t *ovl, U32 extreme);
U32 OVL_ClipToBoxLimits(int sx, int sy, int ex, int ey, ovlClipBox_t *clip);
overlay_t *OVL_FindChild(overlay_t *parent, overlay_t *previous, char *ctype, char *cname);
void OVL_MousePosWindowRelative(overlay_t *ovl, int *mx, int *my);
U32 OVL_SendMsg(overlay_t *ovl, CC8 *msgname, int numparms, ... );
void OVL_SendMsgAll(overlay_t *ovl, CC8 *msgname, int numparms, ... );
U32 OVL_SendPressCommand(overlay_t *ovl, CC8 *text, ... );
U32 OVL_SendDragCommand(overlay_t *ovl, CC8 *text, ... );
U32 OVL_SendReleaseCommand(overlay_t *ovl, CC8 *text, ... );
void OVL_LockInput(overlay_t *ovl);
void OVL_UnlockInput(overlay_t *ovl);
void OVL_SaveOverlay(overlay_t *ovl);
void OVL_LoadOverlay(overlay_t *parent);
overlay_t *OVL_CreateOverlay(char *ovltype,
							 char *title,
							 overlay_t *parent,
							 int posX, int posY,
							 int dimX, int dimY,
							 unsigned long flags,
							 U32 runConfig);
U32 OVL_IsOverlayType(overlay_t *ovl, char *ovltype);
void OVL_SelectionBox(char *caption, char *choices, overlay_t *cbOvl, char *cbCommand, int multiSelect);
void OVL_InputBox(char *caption, char *text, overlay_t *cbOvl, char *cbCommand, char *initialInput);

//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
class overlay_t
{
public:
	char name[256];
	COvlTypeDecl *typedecl;
	unsigned long flags;
	vector_t pos, dim; // position and physical dimensions within parent window
	vector_t vpos; // view position in child space
	vector_t vmin, vmax; // child space range limits (checked against vpos&dim for scrollbar)
	overlay_t *next, *prev;
	overlay_t *children, *parent;
	ovlInputRegion_t iregion;
	float proportionRatio;
	//incursortype_t bodycursor;

	overlay_t() { SYS_Error("overlay_t: Illegal default constructor"); }
	overlay_t(overlay_t *parentwindow); // used only for dummy nodes
	overlay_t(COvlTypeDecl *decl, overlay_t *parentwindow);
	virtual ~overlay_t();
	virtual overlay_t *Spawn(COvlTypeDecl *decl, overlay_t *parentwindow);
	void LinkChild(overlay_t *kid);
	void UnlinkChild(overlay_t *kid);

	virtual U32 SetDimensions(U32 width,U32 height)
	{
		dim.x=(float)width;dim.y=(float)height;
		return TRUE;
	}
	virtual void OnSave();
	virtual void OnLoad();
	virtual void OnResize();
	virtual void OnCalcLogicalDim(int dx, int dy);
	virtual void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
	virtual U32 OnMouseMove(inputevent_t *event);
	virtual U32 OnPress(inputevent_t *event);
	virtual U32 OnDrag(inputevent_t *event);
	virtual U32 OnRelease(inputevent_t *event);
	virtual U32 OnPressCommand(int argNum, CC8 **argList);
	virtual U32 OnDragCommand(int argNum, CC8 **argList);
	virtual U32 OnReleaseCommand(int argNum, CC8 **argList);
	virtual U32 OnMessage(ovlmsg_t *msg);
	virtual U32 OnDragDrop(overlay_t *dropovl);
};

//****************************************************************************
//**
//**    END HEADER OVL_MAN.H
//**
//****************************************************************************
#endif // __OVL_MAN_H__
