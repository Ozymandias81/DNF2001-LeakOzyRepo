#ifndef __CPJPROJ_H__
#define __CPJPROJ_H__
//****************************************************************************
//**
//**    CPJPROJ.H
//**    Header - Projects
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
class OCpjProject;

/*
	OCpjProject
	Resource representing a generic project composited of one or more
	chunk resources.
*/
class KRN_API OCpjProject
: public OCpjRes
{
protected:
	CCorString mFileName;
	NBool mIsLocked;

	OBJ_CLASS_DEFINE(OCpjProject, OCpjRes);	

	void Create() { Super::Create(); SetFileName(NULL); mIsLocked = 0; }
	void Destroy() { SetFileName(NULL); Super::Destroy(); }

	NBool Lock() { if (mIsLocked) return(0); mIsLocked=1; return(1); }
	NBool Unlock() { if (!mIsLocked) return(0); mIsLocked=0; return(1); }
	NBool IsLocked() { return(mIsLocked!=0); }

	const NChar* GetFileName() { return(*mFileName); }
	void SetFileName(const NChar* inFileName);
	OCpjChunk* FindChunk(CObjClass* inResClass, const NChar* inResName=NULL);

	// OCpjRes
	NChar* GetFileExtension() { return("cpj"); }
	NChar* GetFileDescription() { return("Cannibal Project"); }
	NBool LoadFile(NChar* inFileName);
	NBool SaveFile(NChar* inFileName);
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void CPJ_SetBasePath(const NChar* inPath);
KRN_API const NChar* CPJ_GetBasePath();
KRN_API OCpjProject* CPJ_FindProject(const NChar* inPath);
KRN_API OCpjChunk* CPJ_FindChunk(OCpjProject* inContext, CObjClass* inClass, const NChar* inPath);
KRN_API const NChar* CPJ_GetProjectPath(OCpjProject* inProject);
KRN_API const NChar* CPJ_GetChunkPath(OCpjProject* inContext, OCpjChunk* inChunk);

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER CPJPROJ.H
//**
//****************************************************************************
#endif // __CPJPROJ_H__
