#ifndef __OVL_SEQ_H__
#define __OVL_SEQ_H__
//****************************************************************************
//**
//**    OVL_SEQ.H
//**    Header - Overlays - Sequence
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
////    OSequence
///////////////////////////////////////////
class OSequence : public OWindow
{
public:
	modelSequence_t *seq;
	char sName[64];

    OVL_DEFINE2(OSequence, OWindow)
	OSequence(void) { SYS_Error("Default OVLCONSTRUCTOR received for type OSequence"); }
    OSequence(COvlTypeDecl *decl, overlay_t *parentwindow) : OWindow(decl, parentwindow)
    {
		seq = NULL;
		sName[0] = 0;
	}

    ~OSequence() {}

    void OnSave();
    void OnLoad();
    //void OnResize();
	void OnCalcLogicalDim(int dx, int dy);
    void OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox);
    U32 OnPress(inputevent_t *event);
    U32 OnDrag(inputevent_t *event);
    U32 OnRelease(inputevent_t *event);
    U32 OnPressCommand(int argNum, CC8 **argList);
    //U32 OnDragCommand(int argNum, CC8 **argList);
    //U32 OnReleaseCommand(int argNum, CC8 **argList);
    //U32 OnMessage(ovlmsg_t *msg);
};
extern OSequence OSequence_ovlprototype;

//****************************************************************************
//**
//**    END HEADER OVL_SEQ.H
//**
//****************************************************************************
#endif // __OVL_SEQ_H__
