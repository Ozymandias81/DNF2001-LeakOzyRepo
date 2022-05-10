//****************************************************************************
//**
//**    CPJMAC.CPP
//**    Cannibal Models - Model Actor Configuration
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "CpjMac.h"
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
	OCpjConfig
*/
OBJ_CLASS_IMPLEMENTATION(OCpjConfig, OCpjChunk, 0);

NDword OCpjConfig::GetFourCC()
{
	return(KRN_FOURCC(CPJ_MAC_MAGIC));
}
NBool OCpjConfig::LoadChunk(void* inImagePtr, NDword inImageLen)
{
	NDword i, j;

	if (!inImagePtr)
	{
		// remove old array data
		m_Sections.Purge(); m_Sections.Shrink();
		return(1);
	}

	// verify header
	SMacFile* file = (SMacFile*)inImagePtr;
	if ((file->header.magic != KRN_FOURCC(CPJ_MAC_MAGIC))
	 || (file->header.version != CPJ_MAC_VERSION))
		return(0);

	// set up image data pointers
	SMacSection* fileSections = (SMacSection*)(&file->dataBlock[file->ofsSections]);
	NDword* fileCommands = (NDword*)(&file->dataBlock[file->ofsCommands]);

	// remove old array data
	m_Sections.Purge(); m_Sections.Shrink(); m_Sections.Add(file->numSections);

	if (file->header.ofsName)
		SetName((char*)inImagePtr + file->header.ofsName);

	// sections
	for (i=0;i<file->numSections;i++)
	{
		SMacSection* iS = &fileSections[i];
		CCpjMacSection* oS = &m_Sections[i];
		oS->name = (char*)(&file->dataBlock[iS->ofsName]);
		oS->commands.Add(iS->numCommands);
		for (j=0;j<iS->numCommands;j++)
			oS->commands[j] = (char*)(&file->dataBlock[fileCommands[iS->firstCommand+j]]);		
	}
	
	return(1);
}
NBool OCpjConfig::SaveChunk(void* inImagePtr, NDword* outImageLen)
{
	NDword i, j;
	SMacFile header;
	NDword imageLen;
	NDword ofsStrings;

	imageLen = 0;
	header.header.ofsName = imageLen + offsetof(SMacFile, dataBlock);
	imageLen += strlen(GetName())+1;
	header.numSections = m_Sections.GetCount();
	header.ofsSections = imageLen;
	imageLen += header.numSections*sizeof(SMacSection);
	header.numCommands = 0;
	header.ofsCommands = imageLen;
	for (i=0;i<header.numSections;i++)
		header.numCommands += m_Sections[i].commands.GetCount();
	imageLen += header.numCommands*sizeof(NDword);
	ofsStrings = imageLen;
	for (i=0;i<header.numSections;i++)
	{
		imageLen += strlen(*m_Sections[i].name)+1;
		for (j=0;j<m_Sections[i].commands.GetCount();j++)
			imageLen += strlen(*m_Sections[i].commands[j])+1;
	}
	imageLen += offsetof(SMacFile, dataBlock);

	// return if length is all that's desired
	if (outImageLen)
		*outImageLen = imageLen;
	if (!inImagePtr)
		return(1);

	header.header.magic = KRN_FOURCC(CPJ_MAC_MAGIC);
	header.header.lenFile = imageLen - 8;
	header.header.version = CPJ_MAC_VERSION;
	header.header.timeStamp = time(NULL);

	SMacFile* file = (SMacFile*)inImagePtr;
	memcpy(file, &header, offsetof(SMacFile, dataBlock));

	// set up image data pointers
	SMacSection* fileSections = (SMacSection*)(&file->dataBlock[file->ofsSections]);
	NDword* fileCommands = (NDword*)(&file->dataBlock[file->ofsCommands]);

	strcpy((char*)inImagePtr + file->header.ofsName, GetName());

	// sections
	NDword curStringOfs = ofsStrings;
	NDword curCommand = 0;
	for (i=0;i<file->numSections;i++)
	{
		SMacSection* iS = &fileSections[i];
		CCpjMacSection* oS = &m_Sections[i];
		iS->ofsName = curStringOfs;
		curStringOfs += strlen(*oS->name)+1;
		strcpy((char*)(&file->dataBlock[iS->ofsName]), *oS->name);
		iS->numCommands = oS->commands.GetCount();
		iS->firstCommand = curCommand;
		curCommand += iS->numCommands;
		for (j=0;j<iS->numCommands;j++)
		{
			fileCommands[iS->firstCommand+j] = curStringOfs;
			curStringOfs += strlen(*oS->commands[j])+1;
			strcpy((char*)(&file->dataBlock[fileCommands[iS->firstCommand+j]]), *oS->commands[j]);
		}
	}

	return(1);
}

//****************************************************************************
//**
//**    END MODULE CPJMAC.CPP
//**
//****************************************************************************

