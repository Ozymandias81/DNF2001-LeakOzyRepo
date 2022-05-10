#ifndef __OVL_CC_H__
#define __OVL_CC_H__
//****************************************************************************
//**
//**    OVL_CC.H
//**    Header - Overlays - Common Controls
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "ovl_defs.h"
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
extern pool_t<ovltool_t> ovl_toolPool;

//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
///////////////////////////////////////////
////    OMenuItem
///////////////////////////////////////////

OVLTYPE(OMenuItem, OWindow)
{
public:
    char command[128];
    OMenuItem* logicParent;
    
    OVL_DEFINE(OMenuItem, OWindow)
    {
        command[0] = 0;
        logicParent = NULL;
        flags |= OVLF_NOBORDER|OVLF_NOTITLE|OVLF_NOMOVE|OVLF_NORESIZE|OVLF_VIEWABSOLUTE
            |OVLF_NOTITLEMINMAX|OVLF_NOTITLEDESTROY|OVLF_NODRAGDROP|OVLF_NOFOCUS;
    }
    ~OMenuItem() {}

    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    boolean OnPress(inputevent_t* event);
    boolean OnRelease(inputevent_t* event);
};

///////////////////////////////////////////
////    OMenu
///////////////////////////////////////////

OVLTYPE(OMenu, OMenuItem)
{
public:
    boolean showing;
    
    OVL_DEFINE(OMenu, OMenuItem)
    {
        showing = true;
    }
    ~OMenu() {}

    void Show()
    {
	    for (overlay_t* child = parent->children->next; child != parent->children; child = child->next)
        {
            if (OVL_IsOverlayType(child, "OMenuItem"))
            {
                if (((OMenuItem*)child)->logicParent == this)
                    child->flags &= ~(OVLF_NODRAW|OVLF_NOINPUT);
            }
        }
        showing = true;
    }
    void Hide()
    {
	    for (overlay_t* child = parent->children->next; child != parent->children; child = child->next)
        {
            if (OVL_IsOverlayType(child, "OMenuItem"))
            {
                if (((OMenuItem*)child)->logicParent == this)
                    child->flags |= (OVLF_NODRAW|OVLF_NOINPUT);
            }
        }
        showing = false;
    }
    
    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    boolean OnPress(inputevent_t* event);
    boolean OnRelease(inputevent_t* event);
    boolean OnPressCommand(int argNum, char **argList);
};

///////////////////////////////////////////
////    OCheckBoxControl
///////////////////////////////////////////

OVLTYPE(OCheckBoxControl, OWindow)
{
public:
    int checked;

    OVL_DEFINE(OCheckBoxControl, OWindow)
    {
        checked = 0;
        flags |= OVLF_NOBORDER|OVLF_NOTITLE|OVLF_NOMOVE|OVLF_NORESIZE|OVLF_VIEWABSOLUTE
            |OVLF_NOTITLEMINMAX|OVLF_NOTITLEDESTROY|OVLF_NODRAGDROP|OVLF_NOFOCUS;
    }
    ~OCheckBoxControl() {}

    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    boolean OnPress(inputevent_t* event);
    boolean OnRelease(inputevent_t* event);
};

///////////////////////////////////////////
////    OSpinBoxControl
///////////////////////////////////////////

OVLTYPE(OSpinBoxControl, OWindow)
{
public:
    int spinValue;
    int spinMin, spinMax;

    OVL_DEFINE(OSpinBoxControl, OWindow)
    {
        spinValue = 0; spinMin = 0; spinMax = 100;
        flags |= OVLF_NOBORDER|OVLF_NOTITLE|OVLF_NOMOVE|OVLF_NORESIZE|OVLF_VIEWABSOLUTE
            |OVLF_NOTITLEMINMAX|OVLF_NOTITLEDESTROY|OVLF_NODRAGDROP|OVLF_NOFOCUS;
    }
    ~OSpinBoxControl() {}

    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    boolean OnPress(inputevent_t* event);
    boolean OnDrag(inputevent_t* event);
    boolean OnRelease(inputevent_t* event);
};

///////////////////////////////////////////
////    OToolbar
///////////////////////////////////////////

OVLTYPE(OToolbar, OWindow)
{
private:	
	int buttondim;

public:

    OVL_DEFINE(OToolbar, OWindow)
    {
		buttondim = 16;
	}

    ~OToolbar() {}

    //void OnSave();
    //void OnLoad();
    //void OnResize();
    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    boolean OnPress(inputevent_t *event);
    //boolean OnDrag(inputevent_t *event);
    boolean OnRelease(inputevent_t *event);
    //boolean OnPressCommand(int argNum, char **argList);
    //boolean OnDragCommand(int argNum, char **argList);
    //boolean OnReleaseCommand(int argNum, char **argList);
    //boolean OnMessage(ovlmsg_t *msg);
};
extern OToolbar OToolbar_ovlprototype;

///////////////////////////////////////////
////    OToolWindow
///////////////////////////////////////////

#define OTOOLWINDOW_MAXCONTEXTS 8
typedef struct
{
	ovltool_t toolsHead;
	int numtools, tooldx, curtooldx, tooldy;
} ovltoolContext_t;

OVLTYPE(OToolWindow, OWindowScrollable)
{
public:
	ovltoolContext_t contexts[OTOOLWINDOW_MAXCONTEXTS], *curContext;
	overlay_t *toolbar;

	void ActivateRadioTool(ovltool_t *activeTool);
	ovltool_t *FindActiveRadioTool(int group);
	ovltool_t *ToolForName(char *name);
	void SetContext(int contextNum);

    OVL_DEFINE(OToolWindow, OWindowScrollable)
    {
		toolbar = NULL;
		SetContext(0);
		for (int i=0; i<OTOOLWINDOW_MAXCONTEXTS; i++)
		{
			contexts[i].toolsHead.next = contexts[i].toolsHead.prev = &contexts[i].toolsHead;
			contexts[i].numtools = contexts[i].tooldx = contexts[i].curtooldx = contexts[i].tooldy = 0;
		}
    }

	~OToolWindow()
	{
		for (int i=0; i<OTOOLWINDOW_MAXCONTEXTS; i++)
		{
			while(contexts[i].toolsHead.next != &contexts[i].toolsHead)
			{
				ovltool_t *tool = contexts[i].toolsHead.next;
				tool->prev->next = tool->next;
				tool->next->prev = tool->prev;
				ovl_toolPool.Free(tool);
			}
		}
	}
    void OnSave();
    void OnLoad();
    //void OnResize();
    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    //boolean OnPress(inputevent_t *event);
    //boolean OnDrag(inputevent_t *event);
    //boolean OnRelease(inputevent_t *event);
    boolean OnPressCommand(int argNum, char **argList);
    boolean OnDragCommand(int argNum, char **argList);
    boolean OnReleaseCommand(int argNum, char **argList);
    boolean OnMessage(ovlmsg_t *msg);
};
extern OToolWindow OToolWindow_ovlprototype;

///////////////////////////////////////////
////    OSelectionBox
///////////////////////////////////////////

#define OSELECTIONBOXF_SELECTED		0x00000001

OVLTYPE(OSelectionBox, OWindow)
{
public:
	int numItems, selectedItem;
	char *itemStr;
	byte *itemFlags;
	char cbCommand[256], selectedItemText[256];
	overlay_t *cbOvl;
	boolean multiSelect;

    OVL_DEFINE(OSelectionBox, OWindow)
    {
		numItems = selectedItem = 0;
		itemStr = NULL;
		itemFlags = NULL;
		cbOvl = NULL;
		cbCommand[0] = 0;
		selectedItemText[0] = 0;
		multiSelect = 0;
	}

    ~OSelectionBox()
	{
		if (itemStr)
			FREE(itemStr);
		if (itemFlags)
			FREE(itemFlags);
	}

    //void OnSave();
    //void OnLoad();
    //void OnResize();
    void OnCalcLogicalDim(int dx, int dy);
	void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    boolean OnPress(inputevent_t *event);
    //boolean OnDrag(inputevent_t *event);
    //boolean OnRelease(inputevent_t *event);
    //boolean OnPressCommand(int argNum, char **argList);
    //boolean OnDragCommand(int argNum, char **argList);
    //boolean OnReleaseCommand(int argNum, char **argList);
    boolean OnMessage(ovlmsg_t *msg);
};
extern OSelectionBox OSelectionBox_ovlprototype;

///////////////////////////////////////////
////    OInputBox
///////////////////////////////////////////

OVLTYPE(OInputBox, OWindow)
{
public:
	char text[256];
	char cbCommand[256];
	char inputBuffer[256];
	overlay_t *cbOvl;

    OVL_DEFINE(OInputBox, OWindow)
    {
		text[0] = 0;
		cbCommand[0] = 0;
		inputBuffer[0] = 0;
		cbOvl = NULL;
	}

    ~OInputBox() {}

    //void OnSave();
    //void OnLoad();
    //void OnResize();
    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    boolean OnPress(inputevent_t *event);
    //boolean OnDrag(inputevent_t *event);
    //boolean OnRelease(inputevent_t *event);
    //boolean OnPressCommand(int argNum, char **argList);
    //boolean OnDragCommand(int argNum, char **argList);
    //boolean OnReleaseCommand(int argNum, char **argList);
    boolean OnMessage(ovlmsg_t *msg);
};
extern OInputBox OInputBox_ovlprototype;


//****************************************************************************
//**
//**    END HEADER OVL_CC.H
//**
//****************************************************************************
#endif // __OVL_CC_H__
