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
class OMenuItem : public OWindow
{
public:
    char command[128];
    OMenuItem* logicParent;
    
	OVL_DEFINE2(OMenuItem, OWindow)
	OMenuItem(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OMenuItem"); }
    OMenuItem(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
    {
        command[0] = 0;
        logicParent = NULL;
        flags |= OVLF_NOBORDER|OVLF_NOTITLE|OVLF_NOMOVE|OVLF_NORESIZE|OVLF_VIEWABSOLUTE
            |OVLF_NOTITLEMINMAX|OVLF_NOTITLEDESTROY|OVLF_NODRAGDROP|OVLF_NOFOCUS;
    }
    ~OMenuItem() {}

    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    U32 OnPress(inputevent_t* event);
    U32 OnRelease(inputevent_t* event);
};

///////////////////////////////////////////
////    OMenu
///////////////////////////////////////////
class OMenu : public OMenuItem
{
public:
    U32 showing;
    
    OVL_DEFINE2(OMenu, OMenuItem)
	OMenu(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OMenu"); }
    OMenu(COvlTypeDecl *decl, overlay_t *parentwindow) : OMenuItem(decl, parentwindow)
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
    U32 OnPress(inputevent_t* event);
    U32 OnRelease(inputevent_t* event);
    U32 OnPressCommand(int argNum, CC8 **argList);
};

///////////////////////////////////////////
////    OCheckBoxControl
///////////////////////////////////////////

class OCheckBoxControl : public OWindow
{
public:
    int checked;

    OVL_DEFINE2(OCheckBoxControl, OWindow)
	OCheckBoxControl(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OCheckBoxControl"); }
    OCheckBoxControl(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
    {
        checked = 0;
        flags |= OVLF_NOBORDER|OVLF_NOTITLE|OVLF_NOMOVE|OVLF_NORESIZE|OVLF_VIEWABSOLUTE
            |OVLF_NOTITLEMINMAX|OVLF_NOTITLEDESTROY|OVLF_NODRAGDROP|OVLF_NOFOCUS;
    }
    ~OCheckBoxControl() {}

    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    U32 OnPress(inputevent_t* event);
    U32 OnRelease(inputevent_t* event);
};

///////////////////////////////////////////
////    OSpinBoxControl
///////////////////////////////////////////
class OSpinBoxControl : public OWindow
{
public:
    int spinValue;
    int spinMin, spinMax;

    OVL_DEFINE2(OSpinBoxControl, OWindow)
	OSpinBoxControl(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OSpinBoxControl"); }
    OSpinBoxControl(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
    {
        spinValue = 0; spinMin = 0; spinMax = 100;
        flags |= OVLF_NOBORDER|OVLF_NOTITLE|OVLF_NOMOVE|OVLF_NORESIZE|OVLF_VIEWABSOLUTE
            |OVLF_NOTITLEMINMAX|OVLF_NOTITLEDESTROY|OVLF_NODRAGDROP|OVLF_NOFOCUS;
    }
    ~OSpinBoxControl() {}

    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    U32 OnPress(inputevent_t* event);
    U32 OnDrag(inputevent_t* event);
    U32 OnRelease(inputevent_t* event);
};

///////////////////////////////////////////
////    OToolbar
///////////////////////////////////////////
class OToolbar : public OWindow
{
private:	
	int buttondim;

public:

    OVL_DEFINE2(OToolbar, OWindow)
	OToolbar(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OToolbar"); }
    OToolbar(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
    {
		buttondim = 16;
	}

    ~OToolbar() {}

    //void OnSave();
    //void OnLoad();
    //void OnResize();
    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    U32 OnPress(inputevent_t *event);
    //U32 OnDrag(inputevent_t *event);
    U32 OnRelease(inputevent_t *event);
    //U32 OnPressCommand(int argNum, CC8 **argList);
    //U32 OnDragCommand(int argNum, CC8 **argList);
    //U32 OnReleaseCommand(int argNum, CC8 **argList);
    //U32 OnMessage(ovlmsg_t *msg);
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

class OToolWindow : public OWindowScrollable
{
public:
	ovltoolContext_t contexts[OTOOLWINDOW_MAXCONTEXTS], *curContext;
	overlay_t *toolbar;

	void ActivateRadioTool(ovltool_t *activeTool);
	ovltool_t *FindActiveRadioTool(int group);
	ovltool_t *ToolForName(CC8 *name);
	void SetContext(int contextNum);

    OVL_DEFINE2(OToolWindow, OWindowScrollable)
	OToolWindow(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OToolWindow"); }
    OToolWindow(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindowScrollable(decl, parentwindow)
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
    //U32 OnPress(inputevent_t *event);
    //U32 OnDrag(inputevent_t *event);
    //U32 OnRelease(inputevent_t *event);
    U32 OnPressCommand(int argNum, CC8 **argList);
    U32 OnDragCommand(int argNum, CC8 **argList);
    U32 OnReleaseCommand(int argNum, CC8 **argList);
    U32 OnMessage(ovlmsg_t *msg);
};
extern OToolWindow OToolWindow_ovlprototype;

///////////////////////////////////////////
////    OSelectionBox
///////////////////////////////////////////

#define OSELECTIONBOXF_SELECTED		0x00000001

class OSelectionBox : public OWindow
{
public:
	int numItems, selectedItem;
	char *itemStr;
	byte *itemFlags;
	char cbCommand[256], selectedItemText[256];
	overlay_t *cbOvl;
	U32 multiSelect;

    OVL_DEFINE2(OSelectionBox, OWindow)
	OSelectionBox(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OSelectionBox"); }
    OSelectionBox(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
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
		itemStr=null;
		itemFlags=null;
	}

    //void OnSave();
    //void OnLoad();
    //void OnResize();
    void OnCalcLogicalDim(int dx, int dy);
	void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    U32 OnPress(inputevent_t *event);
    //U32 OnDrag(inputevent_t *event);
    //U32 OnRelease(inputevent_t *event);
    //U32 OnPressCommand(int argNum, CC8 **argList);
    //U32 OnDragCommand(int argNum, CC8 **argList);
    //U32 OnReleaseCommand(int argNum, CC8 **argList);
    U32 OnMessage(ovlmsg_t *msg);
};
extern OSelectionBox OSelectionBox_ovlprototype;

///////////////////////////////////////////
////    OInputBox
///////////////////////////////////////////
class OInputBox : public OWindow
{
public:
	char text[256];
	char cbCommand[256];
	char inputBuffer[256];
	overlay_t *cbOvl;

    OVL_DEFINE2(OInputBox, OWindow)
	OInputBox(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OInputBox"); }
    OInputBox(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
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
    U32 OnPress(inputevent_t *event);
    //U32 OnDrag(inputevent_t *event);
    //U32 OnRelease(inputevent_t *event);
    //U32 OnPressCommand(int argNum, CC8 **argList);
    //U32 OnDragCommand(int argNum, CC8 **argList);
    //U32 OnReleaseCommand(int argNum, CC8 **argList);
    U32 OnMessage(ovlmsg_t *msg);
};
extern OInputBox OInputBox_ovlprototype;


//****************************************************************************
//**
//**    END HEADER OVL_CC.H
//**
//****************************************************************************
#endif // __OVL_CC_H__
