//****************************************************************************
//**
//**    CPJSRF.CPP
//**    Cannibal Models - Surface Descriptions
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "CpjSrf.h"
#include <time.h>

#define CPJVECTOR VVec3
#define CPJQUAT VQuat3
#pragma pack(push,1)
#include "CpjFmt.h"
#pragma pack(pop)

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    PRIVATE DATA
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    CLASS METHODS
//============================================================================
/*
	OCpjSurface
*/
OBJ_CLASS_IMPLEMENTATION(OCpjSurface, OCpjChunk, 0);

NDword OCpjSurface::GetFourCC()
{
	return(KRN_FOURCC(CPJ_SRF_MAGIC));
}
NBool OCpjSurface::LoadChunk(void* inImagePtr, NDword inImageLen)
{
    NDword i;

	if (!inImagePtr)
	{
		// remove old array data
		m_Textures.Purge(); m_Textures.Shrink();
		m_Tris.Purge(); m_Tris.Shrink();
		m_UV.Purge(); m_UV.Shrink();
		return(1);
	}

	// verify header
	SSrfFile* file = (SSrfFile*)inImagePtr;
	if ((file->header.magic != KRN_FOURCC(CPJ_SRF_MAGIC))
	 || (file->header.version != CPJ_SRF_VERSION))
		return(0);

	// set up image data pointers
    SSrfTex* fileTextures = (SSrfTex*)(&file->dataBlock[file->ofsTextures]);
	SSrfTri* fileTris = (SSrfTri*)(&file->dataBlock[file->ofsTris]);
	SSrfUV* fileUV = (SSrfUV*)(&file->dataBlock[file->ofsUV]);

	// remove old array data
	m_Textures.Purge(); m_Textures.Shrink(); m_Textures.Add(file->numTextures);
	m_Tris.Purge(); m_Tris.Shrink(); m_Tris.Add(file->numTris);
	m_UV.Purge(); m_UV.Shrink(); m_UV.Add(file->numUV);

	if (file->header.ofsName)
		SetName((char*)inImagePtr + file->header.ofsName);

	// textures
	for (i=0;i<file->numTextures;i++)
	{
        strcpy(m_Textures[i].name, (NChar*)(&file->dataBlock[fileTextures[i].ofsName]));
        strcpy(m_Textures[i].refName, (NChar*)(&file->dataBlock[fileTextures[i].ofsRefName]));
	}

	// triangles
	for (i=0;i<file->numTris;i++)
	{
		SSrfTri* iT = &fileTris[i];
		CCpjSrfTri* oT = &m_Tris[i];
		for (NDword j=0;j<3;j++)
			oT->uvIndex[j] = iT->uvIndex[j];
		oT->texIndex = iT->texIndex;
		oT->flags = iT->flags;
		oT->smoothGroup = iT->smoothGroup;
		oT->alphaLevel = iT->alphaLevel;
		oT->glazeTexIndex = iT->glazeTexIndex;
		oT->glazeFunc = iT->glazeFunc;
	}

	// texture vertex UVs
	for (i=0;i<file->numUV;i++)
		m_UV[i] = VVec2(fileUV[i].u, fileUV[i].v);

	return(1);
}

NBool OCpjSurface::SaveChunk(void* inImagePtr, NDword* outImageLen)
{
    NDword i;
	SSrfFile header;
    NDword imageLen;
    NDword ofsTexNames;

	// build header and calculate memory required for image
	imageLen = 0;
	header.header.ofsName = imageLen + offsetof(SSrfFile, dataBlock);
	imageLen += strlen(GetName())+1;
	header.numTextures = m_Textures.GetCount();
	header.ofsTextures = imageLen;
    imageLen += header.numTextures*sizeof(SSrfTex);
	header.numTris = m_Tris.GetCount();
	header.ofsTris = imageLen;
	imageLen += header.numTris*sizeof(SSrfTri);
	header.numUV = m_UV.GetCount();
	header.ofsUV = imageLen;
	imageLen += header.numUV*sizeof(SSrfUV);
	ofsTexNames = imageLen;
	for (i=0;i<header.numTextures;i++)
	{
		imageLen += strlen(m_Textures[i].name)+1;
		imageLen += strlen(m_Textures[i].refName)+1;
	}
	imageLen += offsetof(SSrfFile, dataBlock);

	// return if length is all that's desired
	if (outImageLen)
		*outImageLen = imageLen;
	if (!inImagePtr)
		return(1);

	header.header.magic = KRN_FOURCC(CPJ_SRF_MAGIC);
	header.header.lenFile = imageLen - 8;
	header.header.version = CPJ_SRF_VERSION;
	header.header.timeStamp = time(NULL);

	SSrfFile* file = (SSrfFile*)inImagePtr;
	memcpy(file, &header, offsetof(SSrfFile, dataBlock));

	// set up image data pointers
    SSrfTex* fileTextures = (SSrfTex*)(&file->dataBlock[file->ofsTextures]);
	SSrfTri* fileTris = (SSrfTri*)(&file->dataBlock[file->ofsTris]);
	SSrfUV* fileUV = (SSrfUV*)(&file->dataBlock[file->ofsUV]);
    NChar* fileTexNames = (NChar*)(&file->dataBlock[ofsTexNames]);

	strcpy((char*)inImagePtr + file->header.ofsName, GetName());

	// textures
    NDword curTexNameOfs = 0;
	for (i=0;i<file->numTextures;i++)
	{
		fileTextures[i].ofsName = ofsTexNames+curTexNameOfs;
		strcpy(fileTexNames+curTexNameOfs, m_Textures[i].name);
		curTexNameOfs += strlen(m_Textures[i].name)+1;
		fileTextures[i].ofsRefName = ofsTexNames+curTexNameOfs;
		strcpy(fileTexNames+curTexNameOfs, m_Textures[i].refName);
		curTexNameOfs += strlen(m_Textures[i].refName)+1;
	}

	// triangles
	for (i=0;i<file->numTris;i++)
	{
		SSrfTri* iT = &fileTris[i];
		CCpjSrfTri* oT = &m_Tris[i];
		for (NDword j=0;j<3;j++)
			iT->uvIndex[j] = oT->uvIndex[j];
		iT->texIndex = oT->texIndex;
		iT->reserved = 0;
		iT->flags = oT->flags;
		iT->smoothGroup = oT->smoothGroup;
		iT->alphaLevel = oT->alphaLevel;
		iT->glazeTexIndex = oT->glazeTexIndex;
		iT->glazeFunc = oT->glazeFunc;
	}

	// texture vertex UVs
	for (i=0;i<file->numUV;i++)
	{
		fileUV[i].u = m_UV[i].x;
		fileUV[i].v = m_UV[i].y;
	}

	return(1);
}

//****************************************************************************
//**
//**    END MODULE CPJSRF.CPP
//**
//****************************************************************************