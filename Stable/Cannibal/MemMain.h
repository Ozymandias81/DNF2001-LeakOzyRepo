#ifndef __MEMMAIN_H__
#define __MEMMAIN_H__
//****************************************************************************
//**
//**    MEMMAIN.H
//**    Header - Memory Management
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define MEM_Malloc(type,count) ((type*)MEM_GetAlloc()->Malloc((count)*sizeof(type)))
#define MEM_Realloc(type,ptr,count) ((type*)MEM_GetAlloc()->Realloc(ptr, (count)*sizeof(type)))
#define MEM_Free(ptr) MEM_GetAlloc()->Free(ptr)
#define MEM_Size(ptr) MEM_GetAlloc()->Size(ptr)
#define MEM_TotalSize MEM_GetAlloc()->TotalSize

#define MEM_DEFNEWDELETE \
	void* operator new(size_t size) { return(MEM_Malloc(NByte,size)); } \
	void operator delete(void* ptr) { MEM_Free(ptr); }

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
// memory allocator interface
class IMemAlloc
{
public:
	virtual void* Malloc(NDword inSize)=0;
	virtual void* Realloc(void* inPtr, NDword inNewSize)=0;
	virtual void Free(void* inPtr)=0;
	virtual NDword Size(void* inPtr)=0;
	virtual NDword TotalSize()=0;
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void MEM_SetAlloc(IMemAlloc* inAlloc);
KRN_API IMemAlloc* MEM_GetAlloc();

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER MEMMAIN.H
//**
//****************************************************************************
#endif // __MEMMAIN_H__
