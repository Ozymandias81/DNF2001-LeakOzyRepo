#ifndef __CPJSEQ_H__
#define __CPJSEQ_H__
//****************************************************************************
//**
//**    CPJSEQ.H
//**    Header - Cannibal Models - Sequenced Animations
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class CCpjSeqBoneInfo
{
public:
	CCorString name;
	NFloat srcLength;

	CCpjSeqBoneInfo() { srcLength = 1.f; }
};

class CCpjSeqTranslate
{
public:
    NWord boneIndex;
    NWord reserved;
	VVec3 translate;

	CCpjSeqTranslate() { boneIndex = 0; translate = VVec3(0,0,0); }
};

class CCpjSeqRotate
{
public:
    NWord boneIndex;
	NSWord roll;
    NSWord pitch;
    NSWord yaw;
#ifndef CPJ_SEQ_NOQUATOPT
	VQuat3 quat;
#endif
	CCpjSeqRotate() { boneIndex = 0; roll = pitch = yaw = 0; }
};

class CCpjSeqScale
{
public:
    NWord boneIndex;
    NWord reserved;
	VVec3 scale;

	CCpjSeqScale() { boneIndex = 0; scale = VVec3(1,1,1); }
};

class CCpjSeqFrame
{
public:
	CCorString vertFrameName;
	TCorArray<CCpjSeqTranslate> translates;
	TCorArray<CCpjSeqRotate> rotates;
	TCorArray<CCpjSeqScale> scales;

	CCpjSeqFrame() { vertFrameName = NULL; }
};

class CCpjSeqEvent
{
public:
    NDword eventType;
    NFloat time;
    CCorString paramString;

	CCpjSeqEvent() { eventType = 0; time = 0.0; paramString = NULL; }
};

class KRN_API OCpjSequence
: public OCpjChunk
{
	OBJ_CLASS_DEFINE(OCpjSequence, OCpjChunk);

    NFloat m_Rate;
	TCorArray<CCpjSeqFrame> m_Frames;
	TCorArray<CCpjSeqEvent> m_Events;
	TCorArray<CCpjSeqBoneInfo> m_BoneInfo;

	void Create()
	{
		Super::Create();

		m_Rate = 10.0;
	}

	// OCpjChunk
    NBool LoadChunk(void* inImagePtr, NDword inImageLen);
    NBool SaveChunk(void* inImagePtr, NDword* outImageLen);

	// OCpjRes
	NDword GetFourCC();
	NChar* GetFileExtension() { return("seq"); }
	NChar* GetFileDescription() { return("Cannibal Sequence"); }
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
//**    END HEADER CPJSEQ.H
//**
//****************************************************************************
#endif // __CPJSEQ_H__