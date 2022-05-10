#ifndef __OVL_SKIN_H__
#define __OVL_SKIN_H__
//****************************************************************************
//**
//**    OVL_SKIN.H
//**    Header - Overlays - Skin View
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "ovl_defs.h"
#include "ovl_cc.h"
#include "ovl_work.h"
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
void OVL_SkinPaint(modelSkin_t *skin, int px, int py, int size, float alpha, boolean reload, boolean aa);
void OVL_SkinLine(modelSkin_t *skin, int x1, int y1, int x2, int y2, int size, float alpha, boolean aa);

//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
///////////////////////////////////////////
////    OPalette
///////////////////////////////////////////

OVLTYPE(OPalette, OWindow)
{
public:
	vector_t palColors[33][32];

	void InvalidatePalColors();

    OVL_DEFINE(OPalette, OWindow)
    {
		InvalidatePalColors();
	}

    ~OPalette() {}

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
    //boolean OnMessage(ovlmsg_t *msg);
};
extern OPalette OPalette_ovlprototype;

///////////////////////////////////////////
////    OSkinView
///////////////////////////////////////////

OVLTYPE(OSkinView, OToolWindow)
{
public:
	modelSkin_t *skin;
	camera_t camera;
	int skinbrushsize, axislockmode;
	boolean skinantialias, skinfiltered;
	int oldMouseX, oldMouseY, bfmode, bfaltmode;
	vector_t skinlineStart, bftransStart, baseboxStart;
	boolean refOverride, selectionMarks, wireframeActive;

    OVL_DEFINE(OSkinView, OToolWindow)
    {
		oldMouseX = oldMouseY = -1;
		skin = NULL;
		camera.SetPosition(0, 0, 256);
		camera.SetTarget(0, 0, 0);
		skinbrushsize = 0;
		skinantialias = skinfiltered = 0;
		skinlineStart.Set(-1, -1, 0);
		baseboxStart.Set(-1, -1, 0);
		refOverride = selectionMarks = 0;
		wireframeActive = 0;
		axislockmode = 0;
    }

    ~OSkinView() {}

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
    //boolean OnMessage(ovlmsg_t *msg);
	//boolean OnDragDrop(overlay_t *dropovl);

};
extern OSkinView OSkinView_ovlprototype;

//****************************************************************************
//**
//**    END HEADER OVL_SKIN.H
//**
//****************************************************************************
#endif // __OVL_SKIN_H__
