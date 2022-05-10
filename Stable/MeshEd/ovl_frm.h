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
class OFrameView : public OToolWindow
{
public:
	modelTrimesh_t *mesh;
	modelFrame_t *frame, *refOverrideFrame;
	char frameName[64];
	camera_t camera;
	int gridNumUnits;
	vector_t gridStart, gridHDelta, gridVDelta, gridColor;
	U32 gridActive, wireframeActive, rotatewheelActive;
	vector_t rotateWheelCenter, rotateWheelBoxes[4][2]; // left,right,top,bottom
	float rotateWheelRadius;
	int rotateType;
	int oldMouseX, oldMouseY;
	char *rotateCursor;
	vector_t anchorPoint;
	U32 anchorActive, selectionGlow;
	int grabSkinIndex, mountIndex;
	int brushsize;
	U32 antialias, filtered, viewBlacklists, refOverride;
	meshTri_t *origamiTri;
	baseTri_t *origamiBTri;
	U32 origamiView;
	U32 envMapTest;
	vector_t selectBoxStart;
	U32 showLodLocked;

    OVL_DEFINE2(OFrameView, OToolWindow)
	OFrameView(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OFrameView"); }
    OFrameView(COvlTypeDecl *decl, overlay_t *parentwindow) : OToolWindow(decl, parentwindow)
    {
		mesh = NULL;
		frame = NULL;
		frameName[0] = 0;
		camera.SetPositioni(0, 0, 128);
		camera.SetTarget(0, 0, 0);
		gridNumUnits = 64;
		gridColor.Seti(255, 0, 0);
		gridStart.Seti(-128, 0, -128);
		gridHDelta.Seti(4, 0, 0);
		gridVDelta.Seti(0, 0, 4);
		gridActive = rotatewheelActive = selectionGlow = 1;
		anchorPoint.Seti(0, 0, 0);
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
		selectBoxStart.Seti(-1, -1, 0);
		showLodLocked = 1;
	}

    ~OFrameView() {}

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
	//U32 OnDragDrop(overlay_t *dropovl);
};
extern OFrameView OFrameView_ovlprototype;


//****************************************************************************
//**
//**    END HEADER OVL_FRM.H
//**
//****************************************************************************
#endif // __OVL_FRM_H__
