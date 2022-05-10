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
void OVL_SkinPaint(modelSkin_t *skin, int px, int py, int size, float alpha, U32 reload, U32 aa);
void OVL_SkinLine(modelSkin_t *skin, int x1, int y1, int x2, int y2, int size, float alpha, U32 aa);

//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
///////////////////////////////////////////
////    OPalette
///////////////////////////////////////////
class OPalette : public OWindow
{
public:
	vector_t palColors[33][32];

	void InvalidatePalColors();

    OVL_DEFINE2(OPalette, OWindow)
	OPalette(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OPalette"); }
    OPalette(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
    {
		InvalidatePalColors();
	}

    ~OPalette() {}

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
    //U32 OnMessage(ovlmsg_t *msg);
};
extern OPalette OPalette_ovlprototype;

///////////////////////////////////////////
////    OSkinView
///////////////////////////////////////////
class OSkinView : public OToolWindow
{
public:
	modelSkin_t *skin;
	camera_t camera;
	int skinbrushsize, axislockmode;
	U32 skinantialias, skinfiltered;
	int oldMouseX, oldMouseY, bfmode, bfaltmode;
	vector_t skinlineStart, bftransStart, baseboxStart;
	U32 refOverride, selectionMarks, wireframeActive;

    OVL_DEFINE2(OSkinView, OToolWindow)
	OSkinView(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OSkinView"); }
    OSkinView(COvlTypeDecl *decl, overlay_t *parentwindow) : OToolWindow(decl, parentwindow)
    {
		oldMouseX = oldMouseY = -1;
		skin = NULL;
		camera.SetPositioni(0, 0, 256);
		camera.SetTarget(0, 0, 0);
		skinbrushsize = 0;
		skinantialias = skinfiltered = 0;
		skinlineStart.Seti(-1, -1, 0);
		baseboxStart.Seti(-1, -1, 0);
		refOverride = selectionMarks = 0;
		wireframeActive = 0;
		axislockmode = 0;
    }

    ~OSkinView() {}

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
    //U32 OnMessage(ovlmsg_t *msg);
	//U32 OnDragDrop(overlay_t *dropovl);

};
extern OSkinView OSkinView_ovlprototype;

//****************************************************************************
//**
//**    END HEADER OVL_SKIN.H
//**
//****************************************************************************
#endif // __OVL_SKIN_H__
