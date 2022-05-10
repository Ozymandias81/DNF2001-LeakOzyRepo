#ifndef __CPJFRM_H__
#define __CPJFRM_H__
//****************************************************************************
//**
//**    CPJFRM.H
//**    Header - Cannibal Models - Vertex Frames
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjGeo.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
#pragma pack(push,1)
class CCpjFrmBytePos
{
public:
	NByte group;
	NByte pos[3];
};
#pragma pack(pop)

class CCpjFrmGroup
{
public:
	VVec3 scale;
	VVec3 translate;

	CCpjFrmGroup() { scale = VVec3(1,1,1); translate = VVec3(0,0,0); }
};

class KRN_API CCpjFrmFrame
{
public:
	CCorString m_Name;
	NDword m_NameHash;
	NBool m_isCompressed;
	TCorArray<CCpjFrmGroup> m_Groups;
	TCorArray<CCpjFrmBytePos> m_BytePos;
	TCorArray<VVec3> m_PurePos;
	VVec3 m_Bounds[2];

	CCpjFrmFrame()
	{
		m_NameHash = 0;
		m_isCompressed = 0;
		m_Bounds[0] = VVec3(FLT_MAX,FLT_MAX,FLT_MAX);
		m_Bounds[1] = VVec3(-FLT_MAX,-FLT_MAX,-FLT_MAX);
	}

	NDword GetNumPositions();
	VVec3 GetPosition(NDword inIndex);
	NBool UpdateBounds();
	NBool InitPositions(NDword inNumPos);
	NBool Compress(OCpjGeometry* inGeom);
	NBool Decompress();
};

class KRN_API OCpjFrames
: public OCpjChunk
{
	OBJ_CLASS_DEFINE(OCpjFrames, OCpjChunk);

	VVec3 m_Bounds[2];
	TCorArray<CCpjFrmFrame> m_Frames;

	void Create()
	{
		Super::Create();

		m_Bounds[0] = VVec3(FLT_MAX,FLT_MAX,FLT_MAX);
		m_Bounds[1] = VVec3(-FLT_MAX,-FLT_MAX,-FLT_MAX);
	}

	NBool UpdateBounds();

	// OCpjChunk
	NBool LoadChunk(void* inImagePtr, NDword inImageLen);
	NBool SaveChunk(void* inImagePtr, NDword* outImageLen);

	// OCpjRes
	NDword GetFourCC();
	NChar* GetFileExtension() { return("frm"); }
	NChar* GetFileDescription() { return("Cannibal Vertex Frames"); }
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
//**    END HEADER CPJFRM.H
//**
//****************************************************************************
#endif // __CPJFRM_H__
