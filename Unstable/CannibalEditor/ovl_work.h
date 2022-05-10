#ifndef __OVL_WORK_H__
#define __OVL_WORK_H__
//****************************************************************************
//**
//**    OVL_WORK.H
//**    Header - Overlays - Workspace
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "ovl_defs.h"
#include "ovl_cc.h"
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
typedef enum
{
	WRM_GENERAL,
	WRM_SKINS,
	WRM_FRAMES,
	WRM_SEQUENCES,

	WRM_NUMTYPES
} workResourceModeType_t;

//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
class OWorkspace;

//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
class modelFrame_t;
class modelSequence_t;
class modelSkin_t;
class model_t;

//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
int OVL_WriteBMP16(char *filename, word *data, int width, int height);

//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
///////////////////////////////////////////
////    OWorkspace
///////////////////////////////////////////

OVLTYPE(OWorkspace, OToolWindow)
{
public:
	overlay_t *resourcesOvl;
	model_t *mdx;
	char mdxName[128];
    vector_t vposBackup[4];

	modelFrame_t *GetTopmostFrame();
	modelSequence_t *GetTopmostSequence();

	void CloseFrameReferences(modelFrame_t *f);
	void CloseSkinReferences(modelSkin_t *sk);
	void CloseSequenceReferences(modelSequence_t *s);
    void InitModel();
	
	OVL_DEFINE(OWorkspace, OToolWindow)
    {
		resourcesOvl = NULL;
		InitModel();
		mdxName[0] = 0;
        for (int i=0;i<4;i++)
            vposBackup[i].Set(0,0,0);
	}

	~OWorkspace();

    void OnSave();
    void OnLoad();
    //void OnResize();
	void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    //boolean OnPress(inputevent_t *event);
    //boolean OnDrag(inputevent_t *event);
    //boolean OnRelease(inputevent_t *event);
    boolean OnPressCommand(int argNum, char **argList);
    //boolean OnDragCommand(int argNum, char **argList);
    //boolean OnReleaseCommand(int argNum, char **argList);
    //boolean OnMessage(ovlmsg_t *msg);
	boolean OnDragDrop(overlay_t *dropovl);
};
extern OWorkspace OWorkspace_ovlprototype;

///////////////////////////////////////////
////    OWorkResources
///////////////////////////////////////////

OVLTYPE(OWorkResources, OWindow)
{
public:
	OWorkspace *ws;
	workResourceModeType_t mode;

    OVL_DEFINE(OWorkResources, OWindow)
    {
		ws = (OWorkspace *)this->parent;
		mode = WRM_GENERAL;
	}

    ~OWorkResources() {}

    //void OnSave();
    //void OnLoad();
    //void OnResize();
	void OnCalcLogicalDim(int dx, int dy);
    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    boolean OnPress(inputevent_t *event);
    //boolean OnDrag(inputevent_t *event);
    boolean OnRelease(inputevent_t *event);
    //boolean OnPressCommand(int argNum, char **argList);
    //boolean OnDragCommand(int argNum, char **argList);
    //boolean OnReleaseCommand(int argNum, char **argList);
    //boolean OnMessage(ovlmsg_t *msg);
};
extern OWorkResources OWorkResources_ovlprototype;


//****************************************************************************
//**
//**    END HEADER OVL_WORK.H
//**
//****************************************************************************
#endif // __OVL_WORK_H__
