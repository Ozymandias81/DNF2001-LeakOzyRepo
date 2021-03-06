#ifndef __KRNBUILD_H__
#define __KRNBUILD_H__
//****************************************************************************
//**
//**    KRNBUILD.H
//**    Header - Kernel Build Configuration
//**
//****************************************************************************
#ifndef __cplusplus
#error KRNBUILD.H - This application requires a C++ compiler
#endif

//============================================================================
//    HEADERS
//============================================================================
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#ifdef _MSC_VER
	#define KRN_MSVC
	#if _MSC_VER >= 1200
		#define KRN_MSVC6
	#endif
#endif

#ifdef _M_IX86
	#define KRN_INTEL
#endif

#ifdef _DEBUG
	#define KRN_DEBUG 1
	#define KRN_RELEASE 0
#else
	#define KRN_DEBUG 0
	#define KRN_RELEASE 1
#endif

#ifdef KRN_DLL
	#pragma warning(disable: 4251) // needs DLL interface
    #ifdef KRN_EXPORTS
		#define KRN_API __declspec(dllexport)
	#else
		#define KRN_API __declspec(dllimport)
	#endif
#else
	#define KRN_API
#endif

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    INLINE CLASS METHODS
//============================================================================
//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER KRNBUILD.H
//**
//****************************************************************************
#endif // __KRNBUILD_H__
