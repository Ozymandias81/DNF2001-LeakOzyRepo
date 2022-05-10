#ifndef __OVL_FRM_H__
#define __OVL_FRM_H__
//****************************************************************************
//**
//**    OVL_FRM.H
//**    Header - Overlays - Frame View
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "ovl_defs.h"
#include "ovl_cc.h"
#include "ovl_mdl.h"
#include "ovl_work.h"
#include "ovl_skin.h"
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
////    OFrameView
///////////////////////////////////////////

OVLTYPE(OFrameView, OToolWindow)
{
public:
	modelTrimesh_t *mesh;
	modelFrame_t *frame, *refOverrideFrame;
	char frameName[64];
	camera_t camera;
	int gridNumUnits;
	vector_t gridStart, gridHDelta, gridVDelta, gridColor;
	boolean gridActive, wireframeActive, rotatewheelActive;
	vector_t rotateWheelCenter, rotateWheelBoxes[4][2]; // left,right,top,bottom
	float rotateWheelRadius;
	int rotateType;
	int oldMouseX, oldMouseY;
	char *rotateCursor;
	vector_t anchorPoint;
	boolean anchorActive, selectionGlow;
	int grabSkinIndex, mountIndex;
	int brushsize;
	boolean antialias, filtered, viewBlacklists, refOverride;
	meshTri_t *origamiTri;
	baseTri_t *origamiBTri;
	boolean origamiView;
	boolean envMapTest;
	vector_t selectBoxStart;
	boolean showLodLocked;

    OVL_DEFINE(OFrameView, OToolWindow)
    {
		mesh = NULL;
		frame = NULL;
		frameName[0] = 0;
		camera.SetPosition(0, 0, 128);
		camera.SetTarget(0, 0, 0);
		gridNumUnits = 64;
		gridColor.Set(255, 0, 0);
		gridStart.Set(-128, 0, -128);
		gridHDelta.Set(4, 0, 0);
		gridVDelta.Set(0, 0, 4);
		gridActive = rotatewheelActive = selectionGlow = 1;
		anchorPoint.Set(0, 0, 0);
		anchorActive = wireframeActive = 0;
		rotateCursor = "select";
		grabSkinIndex = 0;
		mountIndex = 1;
		refOverrideFrame = NULL;
		refOverride = 0;
		brushsize = 0;
		antialias = filtered = viewBlacklists = 0;
		origamiTri = NULL;
		origamiBTri = NULL;
		origamiView = 0;
		envMapTest = 0;
		selectBoxStart.Set(-1, -1, 0);
		showLodLocked = 1;
	}

    ~OFrameView() {}

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
	//boolean OnDragDrop(overlay_t *dropovl);
};
extern OFrameView OFrameView_ovlprototype;


//****************************************************************************
//**
//**    END HEADER OVL_FRM.H
//**
//****************************************************************************
#endif // __OVL_FRM_H__
