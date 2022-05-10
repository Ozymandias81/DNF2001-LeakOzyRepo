#ifndef __CPJSRF_H__
#define __CPJSRF_H__
//****************************************************************************
//**
//**    CPJSRF.H
//**    Header - Cannibal Models - Surface Descriptions
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
class CCpjSrfTex
{
public:
    NChar name[128];
	NChar refName[128];
	union
	{ // transient image pointer or value
		void* imagePtr;
		NDword imageDword;
	};

	CCpjSrfTex() { name[0] = 0; refName[0] = 0; imagePtr = NULL; }
};

class CCpjSrfTri
{
public:
    NWord uvIndex[3];
    NByte texIndex;
	NDword flags;
    NByte smoothGroup;
	NByte alphaLevel;
    NByte glazeTexIndex;
    NByte glazeFunc;

	CCpjSrfTri()
	{
		uvIndex[0] = uvIndex[1] = uvIndex[2] = 0;
		texIndex = 0;
		flags = 0x00000001; // SRFTF_INACTIVE;
		smoothGroup = alphaLevel = glazeTexIndex = glazeFunc = 0;
	}
};

class KRN_API OCpjSurface
: public OCpjChunk
{
	OBJ_CLASS_DEFINE(OCpjSurface, OCpjChunk);

	TCorArray<CCpjSrfTex> m_Textures;
	TCorArray<CCpjSrfTri> m_Tris;
	TCorArray<VVec2> m_UV;

	// OCpjChunk
    NBool LoadChunk(void* inImagePtr, NDword inImageLen);
    NBool SaveChunk(void* inImagePtr, NDword* outImageLen);

	// OCpjRes
	NDword GetFourCC();
	NChar* GetFileExtension() { return("srf"); }
	NChar* GetFileDescription() { return("Cannibal Surface"); }
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
//**    END HEADER CPJSRF.H
//**
//****************************************************************************
#endif // __CPJSRF_H__