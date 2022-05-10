//****************************************************************************
//**
//**    MEMMAIN.CPP
//**    Memory Management
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "LogMain.h"
#include "MemMain.h"

#include <malloc.h>

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class CMemStdAlloc
: public IMemAlloc
{
public:
	NDword mTotalSize;

	CMemStdAlloc() { mTotalSize = 0; }

	// IMemAlloc
	void* Malloc(NDword inSize)
	{
		void* ptr = (char*)malloc(inSize);
		if (!ptr)
			LOG_Errorf("CMemStdAlloc::Malloc: Out of memory");
		mTotalSize += _msize(ptr);
		return(ptr);
	}
	void* Realloc(void* inPtr, NDword inSize)
	{
		mTotalSize -= _msize(inPtr);
		void* ptr = (char*)realloc(inPtr, inSize);
		if (!ptr)
			LOG_Errorf("CMemStdAlloc::Realloc: Out of memory");
		mTotalSize += _msize(ptr);
		return(ptr);
	}
	void Free(void* inPtr)
	{
		if (!inPtr)
			LOG_Errorf("CMemStdAlloc::Free: Null pointer");
		mTotalSize -= _msize(inPtr);
		free(inPtr);
	}
	NDword Size(void* inPtr)
	{
		if (!inPtr)
			return(0);
		return(_msize(inPtr));
	}
	NDword TotalSize()
	{
		return(mTotalSize);
	}
};

//============================================================================
//    PRIVATE DATA
//============================================================================
static IMemAlloc* mem_CurAlloc = NULL;
static IMemAlloc* mem_StdAlloc = NULL;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void MEM_SetAlloc(IMemAlloc* inAlloc)
{
	if (!inAlloc)
	{
		if (!mem_StdAlloc)
			mem_StdAlloc = new CMemStdAlloc;
		inAlloc = mem_StdAlloc;
	}
	mem_CurAlloc = inAlloc;
}
KRN_API IMemAlloc* MEM_GetAlloc()
{
	if (!mem_CurAlloc)
		MEM_SetAlloc(NULL);
	return(mem_CurAlloc);
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE MEMMAIN.CPP
//**
//****************************************************************************

