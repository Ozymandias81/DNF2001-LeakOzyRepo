#ifndef __CPJLOD_H__
#define __CPJLOD_H__
//****************************************************************************
//**
//**    CPJLOD.H
//**    Header - Cannibal Models - LOD Descriptions
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
class CCpjLodTri
{
public:
	NDword srfTriIndex;
	NWord vertIndex[3];
	NWord uvIndex[3];

	CCpjLodTri() { srfTriIndex = 0; vertIndex[0] = vertIndex[1] = vertIndex[2] = 0; uvIndex[0] = uvIndex[1] = uvIndex[2] = 0; }
};

class CCpjLodLevel
{
public:
	NFloat detail;
	TCorArray<NWord> vertRelay;
	TCorArray<CCpjLodTri> triangles;

	CCpjLodLevel() { detail = 1.f; }
};

class KRN_API OCpjLodData
: public OCpjChunk
{
	OBJ_CLASS_DEFINE(OCpjLodData, OCpjChunk);

	TCorArray<CCpjLodLevel> m_Levels;
	
	NBool Generate(OCpjGeometry* inGeo, OCpjSurface* inSrf);

	// OCpjChunk
    NBool LoadChunk(void* inImagePtr, NDword inImageLen);
    NBool SaveChunk(void* inImagePtr, NDword* outImageLen);

	// OCpjRes
	NDword GetFourCC();
	NChar* GetFileExtension() { return("lod"); }
	NChar* GetFileDescription() { return("Cannibal LOD Data"); }
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
//**    END HEADER CPJLOD.H
//**
//****************************************************************************
#endif // __CPJLOD_H__