#ifndef __CPJSKL_H__
#define __CPJSKL_H__
//****************************************************************************
//**
//**    CPJSKL.H
//**    Header - Cannibal Models - Skeleton Descriptions
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
class CCpjSklBone
{
public:
	CCorString name;
	NDword nameHash;
	CCpjSklBone* parentBone;
	VCoords3 baseCoords;
	NFloat length;

	CCpjSklBone() { parentBone = NULL; nameHash = 0; length = 1.f; }
};

class CCpjSklWeight
{
public:
	CCpjSklBone* bone;
    NFloat factor;
	VVec3 offsetPos;

	CCpjSklWeight() { bone = NULL; factor = 0.0; offsetPos = VVec3(0,0,0); }
};

class CCpjSklVert
{
public:
	TCorArray<CCpjSklWeight> weights;

	CCpjSklVert() {}
};

class CCpjSklMount
{
public:	
	CCorString name;
	CCpjSklBone* bone;
	VCoords3 baseCoords;

	CCpjSklMount() { bone = NULL; }
};

class KRN_API OCpjSkeleton
: public OCpjChunk
{
	OBJ_CLASS_DEFINE(OCpjSkeleton, OCpjChunk);

	TCorArray<CCpjSklBone> m_Bones;
	TCorArray<CCpjSklVert> m_Verts;
	TCorArray<CCpjSklMount> m_Mounts;

	// OCpjChunk
    NBool LoadChunk(void* inImagePtr, NDword inImageLen);
    NBool SaveChunk(void* inImagePtr, NDword* outImageLen);

	// OCpjRes
	NDword GetFourCC();
	NChar* GetFileExtension() { return("skl"); }
	NChar* GetFileDescription() { return("Cannibal Skeleton"); }
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
//**    END HEADER CPJSKL.H
//**
//****************************************************************************
#endif // __CPJSKL_H__