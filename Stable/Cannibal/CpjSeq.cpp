//****************************************************************************
//**
//**    CPJSEQ.CPP
//**    Cannibal Models - Sequenced Animations
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "CpjSeq.h"
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
	OCpjSequence
*/
OBJ_CLASS_IMPLEMENTATION(OCpjSequence, OCpjChunk, 0);

NDword OCpjSequence::GetFourCC()
{
	return(KRN_FOURCC(CPJ_SEQ_MAGIC));
}
NBool OCpjSequence::LoadChunk(void* inImagePtr, NDword inImageLen)
{
    NDword i, j;

	if (!inImagePtr)
	{
		// remove old array data
		m_Frames.Purge(); m_Frames.Shrink();
		m_Events.Purge(); m_Events.Shrink();
		m_BoneInfo.Purge(); m_BoneInfo.Shrink();
		return(1);
	}

	// verify header
	SSeqFile* file = (SSeqFile*)inImagePtr;
	if ((file->header.magic != KRN_FOURCC(CPJ_SEQ_MAGIC))
	 || (file->header.version != CPJ_SEQ_VERSION))
		return(0);

	// set up image data pointers
	SSeqFrame* fileFrames = (SSeqFrame*)(&file->dataBlock[file->ofsFrames]);
	SSeqEvent* fileEvents = (SSeqEvent*)(&file->dataBlock[file->ofsEvents]);
    SSeqBoneInfo* fileBoneInfo = (SSeqBoneInfo*)(&file->dataBlock[file->ofsBoneInfo]);
	SSeqBoneTranslate* fileBoneTranslate = (SSeqBoneTranslate*)(&file->dataBlock[file->ofsBoneTranslate]);
	SSeqBoneRotate* fileBoneRotate = (SSeqBoneRotate*)(&file->dataBlock[file->ofsBoneRotate]);
	SSeqBoneScale* fileBoneScale = (SSeqBoneScale*)(&file->dataBlock[file->ofsBoneScale]);

	// remove old array data
	m_Frames.Purge(); m_Frames.Shrink(); m_Frames.Add(file->numFrames);
	m_Events.Purge(); m_Events.Shrink(); m_Events.Add(file->numEvents);
	m_BoneInfo.Purge(); m_BoneInfo.Shrink(); m_BoneInfo.Add(file->numBoneInfo);

	if (file->header.ofsName)
		SetName((char*)inImagePtr + file->header.ofsName);
	
	m_Rate = file->playRate;

	// frames
	for (i=0;i<file->numFrames;i++)
	{
		SSeqFrame* iF = &fileFrames[i];
		CCpjSeqFrame* oF = &m_Frames[i];
		if (iF->ofsVertFrameName != 0xFFFFFFFF)
			oF->vertFrameName = (char*)(&file->dataBlock[iF->ofsVertFrameName]);
		oF->translates.Add(iF->numBoneTranslate);
		for (j=0;j<iF->numBoneTranslate;j++)
		{
			SSeqBoneTranslate* iT = &fileBoneTranslate[iF->firstBoneTranslate+j];
			CCpjSeqTranslate* oT = &oF->translates[j];
			oT->boneIndex = iT->boneIndex;
			oT->translate = iT->translate;
		}
		oF->rotates.Add(iF->numBoneRotate);
		for (j=0;j<iF->numBoneRotate;j++)
		{
			SSeqBoneRotate* iR = &fileBoneRotate[iF->firstBoneRotate+j];
			CCpjSeqRotate* oR = &oF->rotates[j];
			oR->boneIndex = iR->boneIndex;
			oR->roll = iR->roll;
			oR->pitch = iR->pitch;
			oR->yaw = iR->yaw;
#ifndef CPJ_SEQ_NOQUATOPT
			VEulers3 eulers;
			eulers.r = (float)iR->roll * M_PI / 32768.f;
			eulers.p = (float)iR->pitch * M_PI / 32768.f;
			eulers.y = (float)iR->yaw * M_PI / 32768.f;
			oR->quat = VQuat3(~VAxes3(eulers));
#endif
		}
		oF->scales.Add(iF->numBoneScale);
		for (j=0;j<iF->numBoneScale;j++)
		{
			SSeqBoneScale* iS = &fileBoneScale[iF->firstBoneScale+j];
			CCpjSeqScale* oS = &oF->scales[j];
			oS->boneIndex = iS->boneIndex;
			oS->scale = iS->scale;
		}
	}

	// events
	for (i=0;i<file->numEvents;i++)
	{
		SSeqEvent* iE = &fileEvents[i];
		CCpjSeqEvent* oE = &m_Events[i];
		oE->eventType = iE->eventType;
		oE->time = iE->time;
		if (iE->ofsParam != 0xFFFFFFFF)
			oE->paramString = (char*)(&file->dataBlock[iE->ofsParam]);
	}

	// bone info
	for (i=0;i<file->numBoneInfo;i++)
	{
        SSeqBoneInfo* iI = &fileBoneInfo[i];
		CCpjSeqBoneInfo* oI = &m_BoneInfo[i];
		oI->name = (NChar*)(&file->dataBlock[iI->ofsName]);
		oI->srcLength = iI->srcLength;
	}

	return(1);
}

NBool OCpjSequence::SaveChunk(void* inImagePtr, NDword* outImageLen)
{
    NDword i, j;
	SSeqFile header;
    NDword imageLen;
    NDword ofsVertFrameNames;
    NDword ofsBoneNameStrings;
    NDword ofsParamStrings;

	// build header and calculate memory required for image
	imageLen = 0;
	header.header.ofsName = imageLen + offsetof(SSeqFile, dataBlock);
	imageLen += strlen(GetName())+1;
	header.numFrames = m_Frames.GetCount();
	header.ofsFrames = imageLen;
	imageLen += header.numFrames*sizeof(SSeqFrame);
	ofsVertFrameNames = imageLen;
	for (i=0;i<header.numFrames;i++)
	{
		if (m_Frames[i].vertFrameName.Len())
			imageLen += strlen(*m_Frames[i].vertFrameName)+1;
	}
	header.numEvents = m_Events.GetCount();
	header.ofsEvents = imageLen;
	imageLen += header.numEvents*sizeof(SSeqEvent);
	ofsParamStrings = imageLen;
	for (i=0;i<header.numEvents;i++)
	{
		if (m_Events[i].paramString.Len())
			imageLen += strlen(*m_Events[i].paramString)+1;
	}
	header.numBoneInfo = m_BoneInfo.GetCount();
	header.ofsBoneInfo = imageLen;
    imageLen += header.numBoneInfo*sizeof(SSeqBoneInfo);
	ofsBoneNameStrings = imageLen;
	for (i=0;i<header.numBoneInfo;i++)
		imageLen += strlen(*m_BoneInfo[i].name)+1;
	header.numBoneTranslate = 0;
	header.ofsBoneTranslate = imageLen;
	for (i=0;i<header.numFrames;i++)
		header.numBoneTranslate += m_Frames[i].translates.GetCount();
	imageLen += header.numBoneTranslate*sizeof(SSeqBoneTranslate);
	header.numBoneRotate = 0;
	header.ofsBoneRotate = imageLen;
	for (i=0;i<header.numFrames;i++)
		header.numBoneRotate += m_Frames[i].rotates.GetCount();
	imageLen += header.numBoneRotate*sizeof(SSeqBoneRotate);
	header.numBoneScale = 0;
	header.ofsBoneScale = imageLen;
	for (i=0;i<header.numFrames;i++)
		header.numBoneScale += m_Frames[i].scales.GetCount();
	imageLen += offsetof(SSeqFile, dataBlock);

	// return if length is all that's desired
	if (outImageLen)
		*outImageLen = imageLen;
	if (!inImagePtr)
		return(1);

	header.header.magic = KRN_FOURCC(CPJ_SEQ_MAGIC);
	header.header.lenFile = imageLen - 8;
	header.header.version = CPJ_SEQ_VERSION;
	header.header.timeStamp = time(NULL);

	header.playRate = m_Rate;

	SSeqFile* file = (SSeqFile*)inImagePtr;
	memcpy(file, &header, offsetof(SSeqFile, dataBlock));

	// set up image data pointers
	SSeqFrame* fileFrames = (SSeqFrame*)(&file->dataBlock[file->ofsFrames]);
	SSeqEvent* fileEvents = (SSeqEvent*)(&file->dataBlock[file->ofsEvents]);
    SSeqBoneInfo* fileBoneInfo = (SSeqBoneInfo*)(&file->dataBlock[file->ofsBoneInfo]);
	SSeqBoneTranslate* fileBoneTranslate = (SSeqBoneTranslate*)(&file->dataBlock[file->ofsBoneTranslate]);
	SSeqBoneRotate* fileBoneRotate = (SSeqBoneRotate*)(&file->dataBlock[file->ofsBoneRotate]);
	SSeqBoneScale* fileBoneScale = (SSeqBoneScale*)(&file->dataBlock[file->ofsBoneScale]);
    NChar* fileVertFrameNames = (NChar*)(&file->dataBlock[ofsVertFrameNames]);
    NChar* fileBoneNameStrings = (NChar*)(&file->dataBlock[ofsBoneNameStrings]);
    NChar* fileParamStrings = (NChar*)(&file->dataBlock[ofsParamStrings]);

	strcpy((char*)inImagePtr + file->header.ofsName, GetName());

	// frames
    NDword curVertFrameNameOfs = 0;
    NDword curTranslate = 0;
    NDword curRotate = 0;
    NDword curScale = 0;
	for (i=0;i<file->numFrames;i++)
	{
		SSeqFrame* iF = &fileFrames[i];
		CCpjSeqFrame* oF = &m_Frames[i];
		iF->ofsVertFrameName = 0xFFFFFFFF;
		iF->reserved = 0;
		if (oF->vertFrameName.Len())
		{
			iF->ofsVertFrameName = ofsVertFrameNames+curVertFrameNameOfs;
			strcpy(fileVertFrameNames+curVertFrameNameOfs, *oF->vertFrameName);
			curVertFrameNameOfs += strlen(*oF->vertFrameName)+1;
		}
		iF->numBoneTranslate = (NByte)oF->translates.GetCount();
		iF->firstBoneTranslate = curTranslate;
		curTranslate += iF->numBoneTranslate;
		for (j=0;j<iF->numBoneTranslate;j++)
		{
			SSeqBoneTranslate* iT = &fileBoneTranslate[iF->firstBoneTranslate+j];
			CCpjSeqTranslate* oT = &oF->translates[j];
			iT->boneIndex = oT->boneIndex;
			iT->translate = oT->translate;
			iT->reserved = 0;
		}
		iF->numBoneRotate = (NByte)oF->rotates.GetCount();
		iF->firstBoneRotate = curRotate;
		curRotate += iF->numBoneRotate;
		for (j=0;j<iF->numBoneRotate;j++)
		{
			SSeqBoneRotate* iR = &fileBoneRotate[iF->firstBoneRotate+j];
			CCpjSeqRotate* oR = &oF->rotates[j];
			iR->boneIndex = oR->boneIndex;
			iR->roll = oR->roll;
			iR->pitch = oR->pitch;
			iR->yaw = oR->yaw;
		}
		iF->numBoneScale = (NByte)oF->scales.GetCount();
		iF->firstBoneScale = curScale;
		curScale += iF->numBoneScale;
		for (j=0;j<iF->numBoneScale;j++)
		{
			SSeqBoneScale* iS = &fileBoneScale[iF->firstBoneScale+j];
			CCpjSeqScale* oS = &oF->scales[j];
			iS->boneIndex = oS->boneIndex;
			iS->scale = oS->scale;
			iS->reserved = 0;
		}
	}

	// events
    NDword curParamStrOfs = 0;
	for (i=0;i<file->numEvents;i++)
	{
		SSeqEvent* iE = &fileEvents[i];
		CCpjSeqEvent* oE = &m_Events[i];
		iE->eventType = oE->eventType;
		iE->time = oE->time;
		iE->ofsParam = 0xFFFFFFFF;
		if (oE->paramString.Len())
		{
			iE->ofsParam = ofsParamStrings+curParamStrOfs;
			strcpy(fileParamStrings+curParamStrOfs, *oE->paramString);
			curParamStrOfs += strlen(*oE->paramString)+1;
		}
	}

	// bone info
    NDword curBoneNameOfs = 0;
	for (i=0;i<file->numBoneInfo;i++)
	{
        SSeqBoneInfo* iI = &fileBoneInfo[i];
		CCpjSeqBoneInfo* oI = &m_BoneInfo[i];
		iI->ofsName = ofsBoneNameStrings+curBoneNameOfs;
		strcpy(fileBoneNameStrings+curBoneNameOfs, *oI->name);
		curBoneNameOfs += strlen(*oI->name)+1;
		iI->srcLength = oI->srcLength;
	}

	return(1);
}

//****************************************************************************
//**
//**    END MODULE CPJSEQ.CPP
//**
//****************************************************************************