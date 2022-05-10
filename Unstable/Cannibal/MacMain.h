#ifndef __MACMAIN_H__
#define __MACMAIN_H__
//****************************************************************************
//**
//**    MACMAIN.H
//**    Header - Model Actors
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "VecPrim.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class KRN_API CMacBone;
class KRN_API OMacActor;
class KRN_API OMacChannel;
class KRN_API CMacTraceInfo;

/*
	CMacBone
	Actor bone state
*/
class KRN_API CMacBone
{
protected:
	VCoords3 mRelCoords; // parent-relative bone coords
	VCoords3 mAbsCoords; // absolute worldspace bone coords
	NBool mAbsValid; // whether absolute coords are currently valid

	void ValidateAbs(NBool inMakeValid); // validate or invalidate the absolute coords

public:
	CCpjSklBone* mSklBone; // bound skeletal bone	
	CMacBone* mParent; // parent actor bone
	CMacBone* mFirstChild; // first child actor bone
	CMacBone* mNextSibling; // next sibling actor bone

	CMacBone() { mSklBone = NULL; mParent = mFirstChild = mNextSibling = NULL; mAbsValid = 0; }

	VCoords3 GetCoords(NBool inAbsolute);
	void SetCoords(const VCoords3& inCoords, NBool inAbsolute);
	void ResetCoords();
};

/*
	SMacTri
*/
#pragma pack(push, 1)
struct SMacTri
{
	NDword triIndex; // original triangle index
	NDword vertIndex[3]; // triangle vertex indices
	CCpjSrfTex* texture; // surface texture used by triangle
	CCpjSrfTex* glazeTexture; // surface glaze texture used by triangle
	VVec2* texUV[3]; // texture coordinates for triangle
	NDword surfaceFlags; // surface triangle flags
	NByte smoothGroup; // smoothing group from surface
	NByte alphaLevel; // alpha level from surface
	NByte glazeFunc; // glaze function from surface
	NByte surfaceIndex; // index of surface that triangle came from
};
#pragma pack(pop)

/*
	CMacActorLink
*/
class KRN_API CMacActorLink
{
private:
	static CMacActorLink sHeadLink;
	OMacActor* mActor;
	CMacActorLink* mPrev;
	CMacActorLink* mNext;

	void Unlink() { mNext->mPrev = mPrev; mPrev->mNext = mNext; mPrev = mNext = this; }
	void Link(CMacActorLink* inLink) { mNext = inLink->mNext; mPrev = inLink; mNext->mPrev = mPrev->mNext = this; }
	
public:		
	CMacActorLink() { mPrev = mNext = this; Link(&sHeadLink); }
	~CMacActorLink() { Unlink(); }
	
	static CMacActorLink* GetFirst() { return(sHeadLink.mNext); }
	CMacActorLink* GetNext() { return(mNext); }
	NBool IsDone() { return(this == &sHeadLink); }

	OMacActor* GetActor() { return(mActor); }
	void SetActor(OMacActor* inActor) { mActor = inActor; }
};

/*
	OMacActor
	Runtime model actor
*/
class KRN_API OMacActor
: public OObject
{
	OBJ_CLASS_DEFINE(OMacActor, OObject);

	// global actor linked list
	CMacActorLink mActorLink;

	// transient active loading project
	OCpjProject* mLoadProject;

	// regular attributes
	CCorString mAuthor;
	CCorString mDescription;
	VVec3 mOrigin;
	VVec3 mScale;
	VEulers3 mRotation;
	VVec3 mBounds[2]; // min,max

	// resource attributes
	OCpjGeometry* mGeometry;
	OCpjSkeleton* mSkeleton;
	OCpjLodData* mLodData;
	TCorArray<OCpjSurface*> mSurfaces;
	TCorArray<OCpjFrames*> mFrames;
	TCorArray<OCpjSequence*> mSequences;
	TCorArray<CCorString> mFramesFiles;
	TCorArray<CCorString> mFramesStarFiles;
	TCorArray<CCorString> mSequencesFiles;
	TCorArray<CCorString> mSequencesStarFiles;

	// Frame tracking.
	static NDword FrameCount;
	static NDword Evaluations;
	NDword LastEvalFrame;

	// JEP...
	NBool		bBonesDirty;
	// ... JEP

	// bone state
	TCorArray<CMacBone> mActorBones;

	// animation channels
	TCorArray<OMacChannel*> mActorChannels;

	// combined resource info for tracing, internal
	CMacTraceInfo* mTraceInfo;

	// IMsgTarget
	IMsgTarget* MsgGetChild(NChar* inChildName);
	
	// OObject
	void Create();
	
	// Static tick.
	static void Tick();

	// OMacActor
	CMacBone* FindBone(const NChar* inName);
	CCpjFrmFrame* FindFrame(const NChar* inName);
	OCpjSequence* FindSequence(const NChar* inName);
	NBool SetGeometry(OCpjGeometry* inGeometry);
	NBool SetSkeleton(OCpjSkeleton* inSkeleton);
	NBool SetLodData(OCpjLodData* inLodData);
	NBool SetSurface(NDword inIndex, OCpjSurface* inSurface);
	NBool AddFrames(OCpjProject* inProject);
	NBool AddSequences(OCpjProject* inProject);
	NBool LoadConfig(OCpjConfig* inConfig);
	NBool SaveConfig(OCpjConfig* inConfig);
	
	CCpjLodLevel* GetLodInfo(NFloat inLodLevel);
	NDword EvaluateTris(NFloat inLodLevel, SMacTri* outTriList);
	NDword EvaluateVerts(NFloat inLodLevel, NFloat inVertAlpha, VVec3* outVerts);
	NBool EvaluateTriVerts(NDword inTriIndex, NFloat inVertAlpha, VVec3* outVerts);

	NBool TraceRay(NDword inNumTris, SMacTri* inTris, NDword inNumVerts, VVec3* inVerts,
				   const VLine3& inRay, NDword* outTri, NFloat* outDist, VVec3* outBarys, CCpjSklBone** outBone);

	NBool RemoveReferencesTo(OCpjChunk* inChunk);
	static NBool RemoveAllReferencesTo(OCpjChunk* inChunk);
};

/*
	OMacChannel
	Base actor animation channel

	Bone/vertex evaluation order:

	Step 1: EvalVerts for Channel 0 (primary channel) and use the result for step 2.
	Step 2: If result was true, jump to step 3.  If result was false, EvalBones for
	        all Channels 0 and above, and generate verts from bone status afterward.
	Step 3: EvalVerts for Channels 1 and above.
	
*/
class KRN_API OMacChannel
: public OObject
{
	OBJ_CLASS_DEFINE(OMacChannel, OObject);

	virtual NBool EvalBones(OMacActor* inActor) { return(0); } // returns true if change was performed
	virtual NBool EvalVerts(OMacActor* inActor, NDword inNumVerts, NWord* inVertRelay, VVec3* ioVerts) { return(0); } // returns true if change was performed
};

/*
	OMacSequenceChannel
	Channel for evaluating a point in a model sequences
*/
enum EMacSeqBlend
{
	MACSEQBLEND_SET=0,	// blends sequence transforms from animation and base transform
	MACSEQBLEND_ADD=1,	// blends sequence transforms from animation and current transform data
};

class KRN_API OMacSequenceChannel
: public OMacChannel
{
	OBJ_CLASS_DEFINE(OMacSequenceChannel, OMacChannel);

	OCpjSequence* mSequence; // sequence to be used
	NFloat mTime; // current time in sequence, zero to one
	NFloat mBlendAlpha; // blend value with current data, one means no blend (overwrite)
	EMacSeqBlend mBlendMode; // MACSEQBLEND_ blending mode

	void Create() { Super::Create(); mSequence = NULL; mTime = 0.f; mBlendAlpha = 1.f; mBlendMode = MACSEQBLEND_SET; }

	// OMacChannel
	NBool EvalBones(OMacActor* inActor);
	NBool EvalVerts(OMacActor* inActor, NDword inNumVerts, NWord* inVertRelay, VVec3* ioVerts);
};

/*
	OMacIKChannel
	Channel which evaluates a chain of bones based on an IK configuration
*/
class KRN_API OMacIKChannel
: public OMacChannel
{
	OBJ_CLASS_DEFINE(OMacIKChannel, OMacChannel);

	CMacBone* mGoalBone; // bone which should attempt to reach the goal transform
	CMacBone* mChildLimit; // child limit of chain, most descendent bone in computation, uses goal bone if null
	CMacBone* mParentLimit; // parent limit of chain, most ancestral bone in computation, uses entire chain if null
	VVec3 mGoalBoneOffset; // position offset from goal bone that should attempt to reach goal position
	VVec3 mGoalPosition; // absolute goal position
	VAxes3 mGoalRotation; // goal rotation (FIXME: should this be absolute or relative?  I can't remember)
	NFloat mRigidity; // rigidity multiplier

	void Create() { Super::Create(); mGoalBone = mChildLimit = mParentLimit = NULL; mGoalBoneOffset = mGoalPosition = VVec3(0,0,0); mRigidity = 1.f; }

	NBool EvalBones(OMacActor* inActor);
};

class KRN_API CMacTraceInfo
{
public:
	static TCorArray<CMacTraceInfo> sTraceInfoList; // list of all trace infos

	OCpjGeometry* mTraceGeometry; // geometry for this trace info
	OCpjSkeleton* mTraceSkeleton; // skeleton for this trace info
	TCorArray<NByte> mTriBones; // primary bone index in the skeleton for each triangle in the geometry
	TCorArray<VBox3> mBoneBounds; // bounding boxes for bones in reference space

	static CMacTraceInfo* StaticFindInfo(OMacActor* inActor, OCpjGeometry* inGeo, OCpjSkeleton* inSkl);
	void Construct(OMacActor* inActor);
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER MACMAIN.H
//**
//****************************************************************************
#endif // __MACMAIN_H__
