#ifndef __C3S_DEFS_H__
#define __C3S_DEFS_H__
//****************************************************************************
//**
//**    C3S_DEFS.H
//**    Header - Cannibal 3D C3S Toolkit Definitions
//**
//****************************************************************************
#ifndef __cplusplus
#error C3STK requires a C++ compiler
#endif

//============================================================================
//    INTERFACE REQUIRED HEADERS
//============================================================================
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#pragma warning(disable: 4251) // needs DLL interface

#ifdef CBLTK_BUILD
#define CBLTK_API __declspec(dllexport)
#else
#define CBLTK_API __declspec(dllimport)
#endif

#include "vg_lib.h"

//============================================================================
//    INTERFACE DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================

// basic types
typedef unsigned char cblByte;
typedef unsigned short cblWord;
typedef unsigned long cblDword;
typedef signed char cblSByte;
typedef signed short cblSWord;
typedef signed long cblSDword;
typedef float cblFloat;
typedef double cblDouble;
typedef char cblChar;
typedef cblSDword cblInt;
typedef cblByte cblBool;

// boolean constants
#define CBLTRUE 1
#define CBLFALSE 0

// null
#define CBLNULL (0)

// events
#define cblEvent(name) cblev##name
#define cblEvent_typedef(rtype, name, parms) \
	typedef rtype (*cblev##name) parms

// placement new
#ifndef CBLTK_NOPLACEMENTNEW
inline void* operator new (size_t size, void* ptr) { return(ptr); }
#ifdef _MSC_VER
#if _MSC_VER > 1100
inline void operator delete (void* inPtr, void*) {} // for VC6
#endif
#endif
#endif

// standard events
cblEvent_typedef(void, OnWarning, (cblChar* inText));
cblEvent_typedef(void, OnError, (cblChar* inText));
cblEvent_typedef(void*, OnMalloc, (cblDword inSize));
cblEvent_typedef(void*, OnRealloc, (void* inPtr, cblDword inNewSize));
cblEvent_typedef(void, OnFree, (void* inPtr));
cblEvent_typedef(cblDword, OnMSize, (void* inPtr));
cblEvent_typedef(void, OnSaveUpdate, (cblDword inProgress));

// member accessors

//#define CBL_ACCESSOR_INLINE inline
#define CBL_ACCESSOR_INLINE __forceinline
#define CBL_ACCESSOR_GET(xtype, xfunc, xmember) CBL_ACCESSOR_INLINE xtype xfunc() { return(xmember); }
#define CBL_ACCESSOR_GET_REF(xtype, xfunc, xmember) CBL_ACCESSOR_INLINE xtype& xfunc() { return(xmember); }
#define CBL_ACCESSOR_GET_PTR(xtype, xfunc, xmember) CBL_ACCESSOR_INLINE xtype* xfunc() const { return(&xmember); }
#define CBL_ACCESSOR_GET_STR(xfunc, xmember) CBL_ACCESSOR_INLINE cblChar* xfunc() const { return(CBL_GetStr(xmember)); }

#define CBL_ACCESSOR_GET_ARRAY(xtype, xfunc, xmember) CBL_ACCESSOR_INLINE cblArrayT<xtype>& xfunc() { return(xmember); }

#define CBL_ACCESSOR_SET(xtype, xfunc, xmember) CBL_ACCESSOR_INLINE void xfunc(xtype v) { xmember = v; }
#define CBL_ACCESSOR_SET_REF(xtype, xfunc, xmember) CBL_ACCESSOR_INLINE void xfunc(const xtype& v) { xmember = v; }
#define CBL_ACCESSOR_SET_PTR(xtype, xfunc, xmember) CBL_ACCESSOR_INLINE void xfunc(xtype* v) { if (!v) return; xmember = *v; }
#define CBL_ACCESSOR_SET_STR(xfunc, xmember) \
	CBL_ACCESSOR_INLINE void xfunc(cblChar* v) { CBL_SetStr(xmember, v); } \
	CBL_ACCESSOR_INLINE void xfunc##f(cblChar* fmt, ... ) { CBL_SetStr(xmember, CBL_FmtStr(fmt)); }

#define CBL_ACCESSOR_BOTH(xtype, xfunc, xmember) \
	CBL_ACCESSOR_GET(xtype, Get##xfunc, xmember) \
	CBL_ACCESSOR_SET(xtype, Set##xfunc, xmember)

#define CBL_ACCESSOR_BOTH_REF(xtype, xfunc, xmember) \
	CBL_ACCESSOR_GET_REF(xtype, Get##xfunc, xmember) \
	CBL_ACCESSOR_SET_REF(xtype, Set##xfunc, xmember)

#define CBL_ACCESSOR_BOTH_PTR(xtype, xfunc, xmember) \
	CBL_ACCESSOR_GET_PTR(xtype, Get##xfunc, xmember) \
	CBL_ACCESSOR_SET_PTR(xtype, Set##xfunc, xmember)

#define CBL_ACCESSOR_BOTH_STR(xfunc, xmember) \
	CBL_ACCESSOR_GET_STR(Get##xfunc, xmember) \
	CBL_ACCESSOR_SET_STR(Set##xfunc, xmember)

//============================================================================
//    INTERFACE CLASS PROTOTYPES / EXTERNAL CLASS REFERENCES
//============================================================================
//============================================================================
//    INTERFACE STRUCTURES / UTILITY CLASSES
//============================================================================
//============================================================================
//    INTERFACE DATA DECLARATIONS
//============================================================================
//============================================================================
//    INTERFACE FUNCTION PROTOTYPES
//============================================================================
CBLTK_API extern cblBool CBL_Init();
CBLTK_API extern cblBool CBL_Shutdown();
CBLTK_API extern cblDword CBL_GetToolkitVersion();
CBLTK_API extern cblDword CBL_GetSizeMalloced();

CBLTK_API extern cblBool CBL_SetOnWarning(cblEvent(OnWarning) inEvent);
CBLTK_API extern cblBool CBL_SetOnError(cblEvent(OnError) inEvent);
CBLTK_API extern cblBool CBL_SetOnSaveUpdate(cblEvent(OnSaveUpdate) inEvent);
CBLTK_API extern cblBool CBL_SetMemoryEvents(cblEvent(OnMalloc) inMallocEvent,
											 cblEvent(OnRealloc) inReallocEvent,
											 cblEvent(OnFree) inFreeEvent,
											 cblEvent(OnMSize) inMSizeEvent);

CBLTK_API extern void CBL_Warnf(cblChar* fmt, ... );
CBLTK_API extern void CBL_Errorf(cblChar* fmt, ... );
CBLTK_API extern void* CBL_Malloc(cblDword inSize);
CBLTK_API extern void* CBL_Realloc(void* inPtr, cblDword inNewSize);
CBLTK_API extern void CBL_Free(void* inPtr);
CBLTK_API extern cblDword CBL_MSize(void* inPtr);

inline cblChar* CBL_GetStr(cblChar*const& str)
{
	if (!str)
		return("");
	return(str);
}

inline void CBL_SetStr(cblChar*& str, cblChar* inStr)
{
	if (str)
	{
		CBL_Free(str);
		str = NULL;
	}
	if ((!inStr) || (!inStr[0]))
		return;
	str = (cblChar*)CBL_Malloc(strlen(inStr)+1);
	strcpy(str, inStr);
}

inline cblChar* CBL_FmtStr(cblChar*& fmt)
{
	static cblChar buf[4096];
	if (!fmt)
		return(CBLNULL);
	va_list args;
	va_start(args, fmt);
	vsprintf(buf, fmt, args);
	va_end(args);
	return(buf);
}

//============================================================================
//    INTERFACE OBJECT CLASS DEFINITIONS
//============================================================================

// compressed dword, is only a class to distinguish from dword typedef.
//   used by file streamer
class cblCompDword
{
public:	
	cblDword d;

	cblCompDword() {}
	cblCompDword(const cblCompDword& inCD) { d = inCD.d; }
	cblCompDword(const cblDword& inD) { d = inD; }
	cblCompDword& operator = (const cblCompDword& inCD) { d = inCD.d; return(*this); }
	cblCompDword& operator = (const cblDword& inD) { d = inD; return(*this); }
	operator cblDword& () { return(d); }
};

// CBLStream class
#include "c3s_strm.h"

// generic dynamic array (uses heap; prefers fast access time over
//   fast modification time)
class CBLTK_API cblArray
{
protected:
	void* m_Data;
	cblDword m_Count, m_Limit, m_ElemSize;

	inline void Realloc(cblDword inElemSize)
	{
		m_ElemSize = inElemSize;
		if (m_Data)
		{
			if (!m_ElemSize || !m_Limit)
			{
				CBL_Free(m_Data);
				m_Data = NULL;
			}
			else
			{
				m_Data = (cblByte*)CBL_Realloc(m_Data, m_Limit*m_ElemSize);
			}
		}
		else
		{
			if (!m_ElemSize || !m_Limit)
			{
				m_Data = NULL;
			}
			else
			{
				m_Data = (cblByte*)CBL_Malloc(m_Limit*m_ElemSize);
			}
		}
	}
	inline cblArray(cblDword inCount, cblDword inElemSize)
		: m_Count(inCount), m_Limit(inCount), m_Data(NULL), m_ElemSize(inElemSize)
	{
		Realloc(inElemSize);
	}
	inline ~cblArray() { if (m_Data) CBL_Free(m_Data); }
public:
	inline void* GetData() const { return(m_Data); }
	inline cblDword GetDataSize() const { return(m_Count*m_ElemSize); }
	inline void SetDataSize(cblDword inSize)
	{
		if (inSize % m_ElemSize)
			CBL_Errorf("SetDataSize with incompatible element size (%d %% %d == %d)",
				inSize, m_ElemSize, inSize % m_ElemSize);
		if (m_Data)
		{
			CBL_Free(m_Data);
			m_Data = NULL;
		}
		m_Count = m_Limit = inSize / m_ElemSize;
		Realloc(m_ElemSize);
	}
	inline void Remove(cblDword inIndex, cblDword inCount, cblDword inElemSize)
	{
		if (!inCount)
			return;
		memmove((cblByte*)m_Data+inIndex*inElemSize, (cblByte*)m_Data+(inIndex+inCount)*inElemSize, (m_Count-inIndex-inCount)*inElemSize);
		m_Count -= inCount;
	}
	//virtual void WriteStream(CBLStream& s) = 0;
	//virtual void ReadStream(CBLStream& s) = 0;
};

//inline CBLStream& operator << (CBLStream& inStream, cblArray& inArray) { inArray.WriteStream(inStream); return(inStream); }
//inline CBLStream& operator >> (CBLStream& inStream, cblArray& inArray) { inArray.ReadStream(inStream); return(inStream); }

template <class T>
class CBLTK_API cblArrayT : public cblArray
{
public:
	inline cblArrayT(cblDword inCount=0) : cblArray(inCount, sizeof(T)) {}
	inline cblArrayT(cblArrayT& inArray) : cblArray(inArray.m_Count, sizeof(T))
	{
		m_Count = 0;
		for (cblDword i=0;i<inArray.m_Count;i++)
			new(&(*this)[Add()]) T(inArray[i]);
	}
	inline cblArrayT& operator = (cblArrayT& inArray)
	{
		if (this == &inArray)
			return(*this);
		m_Count = 0;
		m_Limit = inArray.m_Count;
		Realloc(sizeof(T));
		for (cblDword i=0;i<inArray.m_Count;i++)
			new(&(*this)[Add()]) T(inArray[i]);
		return(*this);
	}
	inline ~cblArrayT() { Purge(); }
	inline T& operator [] (int i) { return(((T*)m_Data)[i]); }
	inline const T& operator [] (int i) const { return(((T*)m_Data)[i]); }
	inline cblDword GetCount() { return(m_Count); }
	inline T* GetData() { return((T*)m_Data); }
	inline cblBool IsInRange(int i) { return((i>=0) && (i<m_Count)); }
	inline void Purge() { Remove(0, m_Count); }
	inline void Shrink() { if (m_Limit == m_Count) return; m_Limit = m_Count; Realloc(sizeof(T)); }
	inline cblDword AddItem(const T& inItem) { cblDword i = Add(); (*this)[i] = inItem; return(i); }
	inline cblDword Add(cblDword inCount=1)
	{
		cblDword i = m_Count;
		if ((m_Count+=inCount)>m_Limit)
		{
			m_Limit = m_Count + (m_Count>>2) + 32;
			Realloc(sizeof(T));
		}
		return(i);
	}
	inline cblDword AddConstructed()
	{
		cblDword i = Add();
		new(&(*this)[i]) T;
		return(i);
	}
	inline cblDword AddNulled(cblDword inCount=1) { cblDword i = Add(inCount); memset(&(*this)[i], 0, inCount*sizeof(T)); return(i); }
	inline cblBool FindItem(const T& inItem, cblDword* outIndex) const
	{
		for (cblDword i=0;i<m_Count;i++)
		{
			if (((T*)m_Data)[i] == inItem)
			{
				if (outIndex)
					*outIndex = i;
				return(1);
			}
		}
		return(0);
	}
	inline cblDword AddUnique(const T& inItem) { cblDword i; if (FindItem(inItem, &i)) return(i); return(AddItem(inItem)); }
	inline cblDword RemoveItem(const T& inItem)
	{
		cblDword oldCount = m_Count;
		for (cblDword i=0;i<m_Count;i++)
		{
			if (((T*)m_Data)[i] == inItem)
				Remove(i--);
		}
		return(oldCount - m_Count);
	}
	inline void Remove(cblDword inIndex, cblDword inCount=1)
	{
		for (cblDword i=inIndex; i<(inIndex+inCount); i++)
			(&(*this)[i])->~T();
		cblArray::Remove(inIndex, inCount, sizeof(T));
	}
	inline void SetCount(cblDword inNewCount)
	{
		if((m_Count==inNewCount) && (m_Limit==inNewCount))
			return;
		m_Count = m_Limit = inNewCount;
		Realloc(sizeof(T));
	}

	void WriteStream(CBLStream& s)
	{
		s.WriteCompDword((cblCompDword)GetCount());
		for (cblDword i=0;i<GetCount();i++)
			s << (*this)[i];
	}
	void ReadStream(CBLStream& s)
	{
		cblDword count = s.ReadCompDword();
		for (cblDword i=GetCount(); i<count; i++)
			AddConstructed();
		for (i=0;i<count;i++)
			s >> (*this)[i];
	}
};

template <class T> inline CBLStream& operator << (CBLStream& inStream, cblArrayT<T>& inArray) { inArray.WriteStream(inStream); return(inStream); }
template <class T> inline CBLStream& operator >> (CBLStream& inStream, cblArrayT<T>& inArray) { inArray.ReadStream(inStream); return(inStream); }

//============================================================================
//    INTERFACE TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER C3S_DEFS.H
//**
//****************************************************************************
#endif // __C3S_DEFS_H__
