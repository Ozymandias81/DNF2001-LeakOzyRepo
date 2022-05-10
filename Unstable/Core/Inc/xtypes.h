#ifndef _XTYPES_H_
#define _XTYPES_H_

typedef unsigned char		U8;
typedef unsigned short		U16;
typedef unsigned long		U32;
typedef unsigned __int64	U64;

typedef signed char			I8;
typedef signed short		I16;
typedef signed long			I32;
typedef signed __int64		I64;

typedef const unsigned char		CU8;
typedef const char				CC8;
typedef char *					charp;
typedef const char *			CC8P;
typedef const unsigned short	CU16;
typedef const unsigned long		CU32;
typedef const void				cvoid;
typedef void *					voidp;

typedef void *				XHandle;

#define BAD_HANDLE			((void *)0xFFFFFFFF)

/* TODO: may need to redefine for unix os's */
#define XMAX_PATH			260

#define null 0

#define true 1
#define false 0

#define TRUE 1
#define FALSE 0

#ifdef _WIN32
#define OS_SLASH		'\\'
#define OS_SLASH_OTHER	'/'
#else
#define OS_SLASH		'/'
#define OS_SLASH_OTHER	'\\'
#endif

#ifdef _WIN32
typedef struct
{
    U32 dwLowDateTime;
    U32 dwHighDateTime;
}XFiletime;

typedef struct
{
    U32			dwFileAttributes;
    XFiletime	ftCreationTime;
    XFiletime	ftLastAccessTime;
    XFiletime	ftLastWriteTime;
    U32			nFileSizeHigh;
    U32			nFileSizeLow;
    U32			dwReserved0;
    U32			dwReserved1;
    char		cFileName[XMAX_PATH];
    char		cAlternateFileName[14];
}XWin32FindData;
#endif

#define ERROR_FATAL		0
#define ERROR_SEVERE	1
#define ERROR_IMPORTANT	2
#define ERROR_NORMAL	3
#define ERROR_BITCH		4

enum error_enums
{
	ERR_NONE			=0,
	ERR_TIMEOUT			=1,
	ERR_ABANDONED		=2
};

#define IS_POW2(val) (!(val & (val-1)))

#define ALIGN_POW2(val,pow2) \
   ((U32)((((U32)(char *)val) + (((U32)(char *)pow2) - 1)) & (~(((U32)(char *)pow2) - 1))))

#define oof(s,x)      ((U32)&(((s *)0)->x))
#define oofs(s,x,y)   ((U32)&(((s *)0)->x)),((U32)&(((s *)0)->y))

#define PACK_RGB(r,g,b) ((((r)&0xFF)<<16) | (((g)&0xFF)<<8) | ((b)&0xFF))
#define PACK_ARGB(a,r,g,b) (((a&0xFF)<<24) | ((r&0xFF)<<16) | ((g&0xFF)<<8) | (b&0xFF))

#ifdef _WIN32
#define XDLL_EXPORT __declspec(dllexport)
#define XDLL_IMPORT	__declspec(dllimport)
#else
#define XDLL_EXPORT
#define XDLL_IMPORT
#endif

#ifdef _UNIX
#define __regcall(x) __attribute__((regparm(x)))
#elif defined(_WIN32)
#define __regcall(x) __fastcall
#endif 

#endif /*ifndef _XTYPES_H_ */