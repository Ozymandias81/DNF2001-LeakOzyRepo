//****************************************************************************
//**
//**    FILEMAIN.CPP
//**    Files
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "FileMain.h"

#pragma warning(disable: 4250) // class 'y' inherits 'x::f' via dominance
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class CStdFileBase
: virtual public IFileBase
{
protected:
	FILE* mFilePtr;

public:
	// IFileBase
	NBool SeekStart(NDword inPos) { return(!fseek(mFilePtr, inPos, SEEK_SET)); }
	NBool SeekCurrent(NSDword inPos) { return(!fseek(mFilePtr, inPos, SEEK_CUR)); }
	NBool SeekEnd(NDword inPos) { return(!fseek(mFilePtr, inPos, SEEK_END)); }
	NDword Tell() { return(ftell(mFilePtr)); }
	NDword Size()
	{
		NDword oldPos = Tell();
		SeekEnd(0);
		NDword size = Tell();
		SeekStart(oldPos);
		return(size);
	}
};

class CStdFileRead
: public CStdFileBase
, public IFileRead
{
public:
	MEM_DEFNEWDELETE;

	CStdFileRead(FILE* inFilePtr) { mFilePtr = inFilePtr; }

	// IFileRead
	NBool Close() { fclose(mFilePtr); delete this; return(1); }
	NBool Read(void* inPtr, NDword inLength) { return(fread(inPtr, 1, inLength, mFilePtr)==inLength); }
};

class CStdFileWrite
: public CStdFileBase
, public IFileWrite
{
public:
	MEM_DEFNEWDELETE;

	CStdFileWrite(FILE* inFilePtr) { mFilePtr = inFilePtr; }

	// IFileWrite
	NBool Close() { fclose(mFilePtr); delete this; return(1); }
	NBool Write(void* inPtr, NDword inLength) { return(fwrite(inPtr, 1, inLength, mFilePtr)==inLength); }
};

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
KRN_API IFileRead* FILE_OpenRead(const NChar* inFileName)
{	
	if (!inFileName)
		return(NULL);
	FILE* fp = fopen(inFileName, "rb");
	if (!fp)
		return(NULL);
	return(new CStdFileRead(fp));
}
KRN_API IFileWrite* FILE_CreateWrite(const NChar* inFileName)
{
	if (!inFileName)
		return(NULL);
	FILE* fp = fopen(inFileName, "wb");
	if (!fp)
		return(NULL);
	return(new CStdFileWrite(fp));
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE FILEMAIN.CPP
//**
//****************************************************************************

