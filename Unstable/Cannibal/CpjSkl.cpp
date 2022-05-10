//****************************************************************************
//**
//**    CPJSKL.CPP
//**    Cannibal Models - Skeleton Descriptions
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "CpjSkl.h"
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
	OCpjSkeleton
*/
OBJ_CLASS_IMPLEMENTATION(OCpjSkeleton, OCpjChunk, 0);

NDword OCpjSkeleton::GetFourCC()
{
	return(KRN_FOURCC(CPJ_SKL_MAGIC));
}
NBool OCpjSkeleton::LoadChunk(void* inImagePtr, NDword inImageLen)
{
    NDword i, j;

	if (!inImagePtr)
	{
		// remove old array data
		m_Bones.Purge(); m_Bones.Shrink();
		m_Verts.Purge(); m_Verts.Shrink();
		m_Mounts.Purge(); m_Mounts.Shrink();
		return(1);
	}

	// verify header
	SSklFile* file = (SSklFile*)inImagePtr;
	if ((file->header.magic != KRN_FOURCC(CPJ_SKL_MAGIC))
	 || (file->header.version != CPJ_SKL_VERSION))
		return(0);

	// set up image data pointers
	SSklBone* fileBones = (SSklBone*)(&file->dataBlock[file->ofsBones]);
	SSklVert* fileVerts = (SSklVert*)(&file->dataBlock[file->ofsVerts]);
	SSklWeight* fileWeights = (SSklWeight*)(&file->dataBlock[file->ofsWeights]);
	SSklMount* fileMounts = (SSklMount*)(&file->dataBlock[file->ofsMounts]);

	// remove old array data
	m_Bones.Purge(); m_Bones.Shrink(); m_Bones.Add(file->numBones);
	m_Verts.Purge(); m_Verts.Shrink(); m_Verts.Add(file->numVerts);
	m_Mounts.Purge(); m_Mounts.Shrink(); m_Mounts.Add(file->numMounts);

	if (file->header.ofsName)
		SetName((char*)inImagePtr + file->header.ofsName);

	// bones
	for (i=0;i<file->numBones;i++)
	{
		SSklBone* iB = &fileBones[i];
		CCpjSklBone* oB = &m_Bones[i];
		oB->name = (char*)(&file->dataBlock[iB->ofsName]);
		oB->nameHash = STR_CalcHash(*oB->name);
		oB->parentBone = NULL;
		if (iB->parentIndex != 0xFFFFFFFF)
			oB->parentBone = &m_Bones[iB->parentIndex];
		oB->baseCoords.s = iB->baseScale;
		oB->baseCoords.r = iB->baseRotate;
		oB->baseCoords.t = iB->baseTranslate;
		oB->length = iB->length;
	}

	// vertices
	for (i=0;i<file->numVerts;i++)
	{
		SSklVert* iV = &fileVerts[i];
		CCpjSklVert* oV = &m_Verts[i];
		oV->weights.Add(iV->numWeights);
		for (j=0;j<iV->numWeights;j++)
		{
			SSklWeight* iW = &fileWeights[iV->firstWeight+j];
			CCpjSklWeight* oW = &oV->weights[j];
			oW->bone = &m_Bones[iW->boneIndex];
			oW->factor = iW->weightFactor;
			oW->offsetPos = iW->offsetPos;
		}
	}

	// mounts
	for (i=0;i<file->numMounts;i++)
	{
		SSklMount* iM = &fileMounts[i];
		CCpjSklMount* oM = &m_Mounts[i];
		oM->name = (char*)(&file->dataBlock[iM->ofsName]);
		oM->bone = NULL;
		if (iM->boneIndex != 0xFFFFFFFF)
			oM->bone = &m_Bones[iM->boneIndex];
		oM->baseCoords.s = iM->baseScale;
		oM->baseCoords.r = iM->baseRotate;
		oM->baseCoords.t = iM->baseTranslate;
	}

	return(1);
}

NBool OCpjSkeleton::SaveChunk(void* inImagePtr, NDword* outImageLen)
{
    NDword i, j;
	SSklFile header;
    NDword imageLen;
    NDword ofsBoneNames;
	NDword ofsMountNames;

	// build header and calculate memory required for image
	imageLen = 0;
	header.header.ofsName = imageLen + offsetof(SSklFile, dataBlock);
	imageLen += strlen(GetName())+1;
	header.numBones = m_Bones.GetCount();
	header.ofsBones = imageLen;
	imageLen += header.numBones*sizeof(SSklBone);
	header.numVerts = m_Verts.GetCount();
	header.ofsVerts = imageLen;
	imageLen += header.numVerts*sizeof(SSklVert);
	header.numWeights = 0;
	header.ofsWeights = imageLen;
	for (i=0;i<header.numVerts;i++)
		header.numWeights += m_Verts[i].weights.GetCount();
	imageLen += header.numWeights*sizeof(SSklWeight);
	header.numMounts = m_Mounts.GetCount();
	header.ofsMounts = imageLen;
	imageLen += header.numMounts*sizeof(SSklMount);
	ofsBoneNames = imageLen;
	for (i=0;i<header.numBones;i++)
		imageLen += strlen(*m_Bones[i].name)+1;
	ofsMountNames = imageLen;
	for (i=0;i<header.numMounts;i++)
		imageLen += strlen(*m_Mounts[i].name)+1;
	imageLen += offsetof(SSklFile, dataBlock);

	// return if length is all that's desired
	if (outImageLen)
		*outImageLen = imageLen;
	if (!inImagePtr)
		return(1);

	header.header.magic = KRN_FOURCC(CPJ_SKL_MAGIC);
	header.header.lenFile = imageLen - 8;
	header.header.version = CPJ_SKL_VERSION;
	header.header.timeStamp = time(NULL);

	SSklFile* file = (SSklFile*)inImagePtr;
	memcpy(file, &header, offsetof(SSklFile, dataBlock));

	// set up image data pointers
	SSklBone* fileBones = (SSklBone*)(&file->dataBlock[file->ofsBones]);
	SSklVert* fileVerts = (SSklVert*)(&file->dataBlock[file->ofsVerts]);
	SSklWeight* fileWeights = (SSklWeight*)(&file->dataBlock[file->ofsWeights]);
	SSklMount* fileMounts = (SSklMount*)(&file->dataBlock[file->ofsMounts]);
    NChar* fileBoneNames = (NChar*)(&file->dataBlock[ofsBoneNames]);
	NChar* fileMountNames = (NChar*)(&file->dataBlock[ofsMountNames]);

	strcpy((char*)inImagePtr + file->header.ofsName, GetName());

	// bones
    NDword curBoneNameOfs = 0;
	for (i=0;i<file->numBones;i++)
	{
		SSklBone* iB = &fileBones[i];
		CCpjSklBone* oB = &m_Bones[i];
		iB->ofsName = ofsBoneNames+curBoneNameOfs;
		strcpy(fileBoneNames+curBoneNameOfs, *m_Bones[i].name);
		curBoneNameOfs += strlen(*m_Bones[i].name)+1;
		iB->parentIndex = 0xFFFFFFFF;
		if (oB->parentBone)
			iB->parentIndex = (CCpjSklBone*)oB->parentBone - &m_Bones[0];
		iB->baseScale = oB->baseCoords.s;
		iB->baseRotate = oB->baseCoords.r;
		iB->baseTranslate = oB->baseCoords.t;
		iB->length = oB->length;
	}

	// vertices
    NDword curWeight = 0;
	for (i=0;i<file->numVerts;i++)
	{
		SSklVert* iV = &fileVerts[i];
		CCpjSklVert* oV = &m_Verts[i];
        iV->numWeights = (NWord)oV->weights.GetCount();
        iV->firstWeight = (NWord)curWeight;
		curWeight += iV->numWeights;
		for (j=0;j<iV->numWeights;j++)
		{
			SSklWeight* iW = &fileWeights[iV->firstWeight+j];
			CCpjSklWeight* oW = &oV->weights[j];
			iW->boneIndex = (CCpjSklBone*)oW->bone - &m_Bones[0];
			iW->weightFactor = oW->factor;
			iW->offsetPos = oW->offsetPos;
		}
	}

	// mounts
	NDword curMountNameOfs = 0;
	for (i=0;i<file->numMounts;i++)
	{
		SSklMount* iM = &fileMounts[i];
		CCpjSklMount* oM = &m_Mounts[i];
		iM->ofsName = ofsMountNames+curMountNameOfs;
		strcpy(fileMountNames+curMountNameOfs, *m_Mounts[i].name);
		curMountNameOfs += strlen(*m_Mounts[i].name)+1;
		iM->boneIndex = 0xFFFFFFFF;
		if (oM->bone)
			iM->boneIndex = (CCpjSklBone*)oM->bone - &m_Bones[0];
		iM->baseScale = oM->baseCoords.s;
		iM->baseRotate = oM->baseCoords.r;
		iM->baseTranslate = oM->baseCoords.t;
	}

	return(1);
}

//****************************************************************************
//**
//**    END MODULE CPJSKL.CPP
//**
//****************************************************************************