#ifndef __STRMAIN_H__
#define __STRMAIN_H__
//****************************************************************************
//**
//**    STRMAIN.H
//**    Header - String Utilities
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
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
// variable argument "(inFmt, ... )" to single string conversion
KRN_API char* STR_Va(char*& inFmt);

// indentation strings (spacing)
KRN_API char* STR_Indent(unsigned long inNumSpc);

// literal evaluation (i.e. \n, \t, \x??, etc), advances pointer by amount read
KRN_API char STR_Literal(char*& ioPtr);

// calculate a simple hash value for string
KRN_API unsigned long STR_CalcHash(char* inStr);

// file name string functions
// these use internal buffers for results; copy the results before calling the
//   function again if you need to preserve what these return.
KRN_API char* STR_FilePath(char* inFileName);
KRN_API char* STR_FileRoot(char* inFileName);
KRN_API char* STR_FileExtension(char* inFileName);
KRN_API char* STR_FileSuggestedExt(char* inFileName, char* inExt);
KRN_API char* STR_FileForcedExt(char* inFileName, char* inExt);
KRN_API char* STR_FileFind(char* inFileSpec, int* outIsDir, unsigned long* outFileSize);
KRN_API void STR_FileFindPushState();
KRN_API void STR_FileFindPopState();

// atoi-style conversion functions
KRN_API int STR_Chartoi(char* str);
KRN_API int STR_Binatoi(char* str);
KRN_API int STR_Octatoi(char* str);
KRN_API int STR_Hexatoi(char* str);

// command-line arguments
KRN_API void STR_ArgInit(unsigned long inArgc, char** inArgv);
KRN_API unsigned long STR_Argc();
KRN_API char* STR_Argv(unsigned long inIndex);
KRN_API unsigned long STR_ArgOption(char* inOptStr, unsigned long inReqParms);

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER STRMAIN.H
//**
//****************************************************************************
#endif // __STRMAIN_H__
