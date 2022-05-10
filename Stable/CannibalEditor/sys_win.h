#ifndef __SYS_WIN_H__
#define __SYS_WIN_H__
//****************************************************************************
//**
//**    SYS_WIN.H
//**    Header - System Control - Windows Interface
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
extern int sys_argc;
extern char **sys_argv;
extern boolean sys_userException;
extern char sys_userExceptionString[256];
extern char sys_programPath[256];
extern U32 is_win2k;

//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
int SYS_EvaluateException(unsigned long n_except);
void SYS_ExceptionHandler(unsigned long e);
extern "C" float SYS_GetTimeFloat();
void SYS_PlaySound(char *filename);
char *SYS_InputBox(char *caption, char *definput, char *text, ...);
char *SYS_SelectionBox(char *caption, char *choices, char *text, ... );
char *SYS_OpenFileBox(char *maskInfo, char *boxTitle, char *defExt);
int SYS_OpenFileBoxMulti(char *maskInfo, char *boxTitle, char *defExt);
char *SYS_NextMultiFile();
char *SYS_SaveFileBox(char *maskInfo, char *boxTitle, char *defExt);
//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------


//****************************************************************************
//**
//**    END HEADER SYS_WIN.H
//**
//****************************************************************************
#endif // __SYS_WIN_H__
