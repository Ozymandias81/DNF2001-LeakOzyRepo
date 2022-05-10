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
int OVL_WriteBMP16(CC8 *filename, U16 *data, int width, int height);

//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
///////////////////////////////////////////
////    OWorkspace
///////////////////////////////////////////
class OWorkspace : public OToolWindow
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
	
	OVL_DEFINE2(OWorkspace, OToolWindow)
	OWorkspace(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OWorkspace"); }
    OWorkspace(COvlTypeDecl *decl, overlay_t *parentwindow) : OToolWindow(decl, parentwindow)
    {
		resourcesOvl = NULL;
		InitModel();
		mdxName[0] = 0;
        for (int i=0;i<4;i++)
            vposBackup[i].Seti(0,0,0);
	}

	~OWorkspace();

    void OnSave();
    void OnLoad();
    //void OnResize();
	void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    //U32 OnPress(inputevent_t *event);
    //U32 OnDrag(inputevent_t *event);
    //U32 OnRelease(inputevent_t *event);
    U32 OnPressCommand(int argNum, CC8 **argList);
    //U32 OnDragCommand(int argNum, CC8 **argList);
    //U32 OnReleaseCommand(int argNum, CC8 **argList);
    //U32 OnMessage(ovlmsg_t *msg);
	U32 OnDragDrop(overlay_t *dropovl);
};
extern OWorkspace OWorkspace_ovlprototype;

///////////////////////////////////////////
////    OWorkResources
///////////////////////////////////////////
class OWorkResources : public OWindow
{
public:
	OWorkspace *ws;
	workResourceModeType_t mode;

    OVL_DEFINE2(OWorkResources, OWindow)
	OWorkResources(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OWorkResources"); }
    OWorkResources(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
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
    U32 OnPress(inputevent_t *event);
    //U32 OnDrag(inputevent_t *event);
    U32 OnRelease(inputevent_t *event);
    //U32 OnPressCommand(int argNum, CC8 **argList);
    //U32 OnDragCommand(int argNum, CC8 **argList);
    //U32 OnReleaseCommand(int argNum, CC8 **argList);
    //U32 OnMessage(ovlmsg_t *msg);
};
extern OWorkResources OWorkResources_ovlprototype;


//****************************************************************************
//**
//**    END HEADER OVL_WORK.H
//**
//****************************************************************************
#endif // __OVL_WORK_H__
