#ifndef __CPJGEO_H__
#define __CPJGEO_H__
//****************************************************************************
//**
//**    CPJGEO.H
//**    Header - Cannibal Models - Geometry Descriptions
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
class CCpjGeoVert;
class CCpjGeoEdge;
class CCpjGeoTri;

class CCpjGeoVert
{
public:
    NByte flags;
    NByte groupIndex;
    VVec3 refPosition;
	TCorArray<CCpjGeoEdge*> edgeLinks;
	TCorArray<CCpjGeoTri*> triLinks;

	CCpjGeoVert() { flags = groupIndex = 0; refPosition = VVec3(0,0,0); }
};

class CCpjGeoEdge
{
public:
    CCpjGeoVert* headVertex;
    CCpjGeoVert* tailVertex;
    CCpjGeoEdge* invertedEdge;
	TCorArray<CCpjGeoTri*> triLinks;

	CCpjGeoEdge() { headVertex = tailVertex = NULL; invertedEdge = NULL; }
};

class CCpjGeoTri
{
public:
	CCpjGeoEdge* edgeRing[3];

	CCpjGeoTri() { for (NDword i=0;i<3;i++) { edgeRing[i] = NULL; } }
};

class CCpjGeoMount
{
public:
    NChar name[64];
    NDword triIndex;
    VVec3 triBarys;
    VCoords3 baseCoords;

	CCpjGeoMount() { name[0] = 0; triIndex = 0; triBarys = VVec3(0.33f,0.33f,0.34f); }
};

class KRN_API OCpjGeometry
: public OCpjChunk
{
	OBJ_CLASS_DEFINE(OCpjGeometry, OCpjChunk);

	TCorArray<CCpjGeoVert> m_Verts;
	TCorArray<CCpjGeoEdge> m_Edges;
	TCorArray<CCpjGeoTri> m_Tris;
	TCorArray<CCpjGeoMount> m_Mounts;

	NBool Generate(NDword inNumVerts, NFloat* inVerts, NDword inNumTris, NDword* inTris);

	// OCpjChunk
	NBool LoadChunk(void* inImagePtr, NDword inImageLen);
	NBool SaveChunk(void* inImagePtr, NDword* outImageLen);

	// OCpjRes
	NDword GetFourCC();
	NChar* GetFileExtension() { return("geo"); }
	NChar* GetFileDescription() { return("Cannibal Geometry"); }
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
//**    END HEADER CPJGEO.H
//**
//****************************************************************************
#endif // __CPJGEO_H__
