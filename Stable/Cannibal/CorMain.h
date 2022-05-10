#ifndef __CORMAIN_H__
#define __CORMAIN_H__
//****************************************************************************
//**
//**    CORMAIN.H
//**    Header - Core Data Structures
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "MemMain.h"
#include "LogMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPES
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
#ifndef KRN_NOPLACEMENTNEW
inline void* operator new (size_t size, void* ptr) { return(ptr); }
#ifdef KRN_MSVC6
inline void operator delete (void* inPtr, void*) {}
#endif
#endif

/*
	CCorString - General string utility class
	Allocates string data arbitrarily, based on the heap.  Doesn't bother
	refcounting or tracking aliases for copy-on-write, or any crap like that,
	it's just a raw string data class here for the hell of it.  Just because
	it's convenient doesn't mean it's efficient.  Caveat Coder.
*/
class KRN_API CCorString
{
private:
	char* mStr;
	static unsigned long sMemTotal;

public:
	inline void Set(char* inStr)
	{
		if (inStr && !inStr[0])
			inStr=NULL;
		if (mStr)
		{
			sMemTotal -= strlen(mStr)+1;
			MEM_Free(mStr);
		}
		mStr = NULL;
		if (inStr)
		{
			unsigned long size = strlen(inStr)+1;
			mStr = MEM_Malloc(char, size);
			if (mStr)
			{
				strcpy(mStr, inStr);
				sMemTotal += size;
			}
		}
	}
	inline void Cat(char* inStr)
	{
		if (inStr && !inStr[0])
			inStr=NULL;
		if (!mStr)
		{
			Set(inStr);
			return;
		}
		if (!inStr)
			return;
		unsigned long size = strlen(mStr)+strlen(inStr)+1;		
		char* nstr = MEM_Malloc(char, size);
		if (nstr)
		{
			strcpy(nstr, mStr);
			strcat(nstr, inStr);
			sMemTotal += size;
		}
		sMemTotal -= strlen(mStr)+1;
		MEM_Free(mStr);
		mStr = nstr;
	}
	inline void Setf(char* inStr, ... ) { Set(STR_Va(inStr)); }
	inline void Catf(char* inStr, ... ) { Cat(STR_Va(inStr)); }

	inline CCorString() { mStr = NULL; }
	inline ~CCorString() { Set(NULL); }
	inline CCorString(const CCorString& inStr) { mStr = NULL; Set(inStr.mStr); }
	inline CCorString(const char* inStr) { mStr = NULL; Set((char*)inStr); }

	inline CCorString& operator = (const CCorString& inStr) { Set(inStr.mStr); return(*this); }
	inline CCorString& operator = (const char* inStr) { Set((char*)inStr); return(*this); }
	inline CCorString& operator += (const CCorString& inStr) { Cat(inStr.mStr); return(*this); }
	inline CCorString& operator += (const char* inStr) { Cat((char*)inStr); return(*this); }

	inline friend CCorString operator + (const CCorString& inS1, const CCorString& inS2) { CCorString r(inS1); r += inS2; return(r); }
	inline friend CCorString operator + (const CCorString& inS1, const char* inS2) { CCorString r(inS1); r += inS2; return(r); }
	inline friend CCorString operator + (const char* inS1, const CCorString& inS2) { CCorString r(inS1); r += inS2; return(r); }

	inline bool operator == (const CCorString& inS) { return(strcmp(Str(), inS.Str())==0); }
	inline bool operator != (const CCorString& inS) { return(strcmp(Str(), inS.Str())!=0); }

	inline void operator ++ () { if (mStr) _strupr(mStr); }
	inline void operator ++ (int) { if (mStr) _strupr(mStr); }
	inline void operator -- () { if (mStr) _strlwr(mStr); }
	inline void operator -- (int) { if (mStr) _strlwr(mStr); }
	inline CCorString operator + () { CCorString r(*this); ++r; return(r); }
	inline CCorString operator - () { CCorString r(*this); --r; return(r); }

	inline char* operator * () const { return(Str()); }

	inline unsigned long Len() const { if (!mStr) return(0); return(strlen(mStr)); }
	inline char* Str() const { if (mStr) return(mStr); return(""); }
	inline static unsigned long GetStaticMemSize() { return(sMemTotal); }
};

/*
	ICorStreamRead/ICorStreamWrite - General stream interface classes
	Implementors need only fill in the Read and Write methods respectively
*/
class ICorStreamRead
{
public:
	virtual NBool Read(void* inPtr, NDword inLength)=0;

	// inline base type readers
	inline NByte ReadByte() { static NByte v; if (!Read(&v, sizeof(NByte))) return(0); return(v); }
	inline NWord ReadWord() { static NWord v; if (!Read(&v, sizeof(NWord))) return(0); return(v); }
	inline NDword ReadDword() { static NDword v; if (!Read(&v, sizeof(NDword))) return(0); return(v); }
	inline NSByte ReadSByte() { static NSByte v; if (!Read(&v, sizeof(NSByte))) return(0); return(v); }
	inline NSWord ReadSWord() { static NSWord v; if (!Read(&v, sizeof(NSWord))) return(0); return(v); }
	inline NSDword ReadSDword() { static NSDword v; if (!Read(&v, sizeof(NSDword))) return(0); return(v); }
	inline NFloat ReadFloat() { static NFloat v; if (!Read(&v, sizeof(NFloat))) return(0.0f); return(v); }
	inline NDouble ReadDouble() { static NDouble v; if (!Read(&v, sizeof(NDouble))) return(0.0); return(v); }
	inline NChar* ReadString()
	{
		static NChar v[1024];
		NChar* p = v;
		while (*p = (NChar)ReadByte())
			p++;
		if (!v[0])
			return(0);
		return(v);
	}
};

class ICorStreamWrite
{
public:
	virtual NBool Write(void* inPtr, NDword inLength)=0;

	// inline base type writers
	inline NBool WriteByte(NByte v) { return(Write(&v, sizeof(NByte))); }
	inline NBool WriteWord(NWord v) { return(Write(&v, sizeof(NWord))); }
	inline NBool WriteDword(NDword v) { return(Write(&v, sizeof(NDword))); }
	inline NBool WriteSByte(NSByte v) { return(Write(&v, sizeof(NSByte))); }
	inline NBool WriteSWord(NSWord v) { return(Write(&v, sizeof(NSWord))); } 
	inline NBool WriteSDword(NSDword v) { return(Write(&v, sizeof(NSDword))); }
	inline NBool WriteFloat(NFloat v) { return(Write(&v, sizeof(NFloat))); }
	inline NBool WriteDouble(NDouble v) { return(Write(&v, sizeof(NDouble))); }
	inline NBool WriteString(NChar* v)
	{
		if (!v) return(WriteByte(0));
		else return(Write(v, strlen(v)+1));
	}
};

/*
	CCorArray - General dynamic array
	Uses heap; prefers fast access time over fast modification time
*/
class CCorArray
{
protected:
	void* m_Data;
	NDword m_Count, m_Limit, m_ElemSize;

	inline void Realloc(NDword inElemSize)
	{
		m_ElemSize = inElemSize;
		if (m_Data)
		{
			if (!m_ElemSize || !m_Limit)
			{
				MEM_Free(m_Data);
				m_Data = NULL;
			}
			else
			{
				m_Data = MEM_Realloc(NByte, m_Data, m_Limit*m_ElemSize);
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
				m_Data = MEM_Malloc(NByte, m_Limit*m_ElemSize);
			}
		}
	}
	inline CCorArray(NDword inCount, NDword inElemSize)
		: m_Count(inCount), m_Limit(inCount), m_Data(NULL), m_ElemSize(inElemSize)
	{
		Realloc(inElemSize);
	}
	inline ~CCorArray()
	{
		if (m_Data)
			MEM_Free(m_Data);
	}
public:
	inline void* GetData() const
	{
		return(m_Data);
	}
	inline NDword GetDataSize() const
	{
		return(m_Count*m_ElemSize);
	}
	inline void SetDataSize(NDword inSize)
	{
		if (inSize % m_ElemSize)
			LOG_Errorf("SetDataSize with incompatible element size (%d %% %d == %d)",
				inSize, m_ElemSize, inSize % m_ElemSize);
		if (m_Data)
		{
			MEM_Free(m_Data);
			m_Data = NULL;
		}
		m_Count = m_Limit = inSize / m_ElemSize;
		Realloc(m_ElemSize);
	}
	inline void Remove(NDword inIndex, NDword inCount, NDword inElemSize)
	{
		if (!inCount)
			return;
		memmove((NByte*)m_Data+inIndex*inElemSize, (NByte*)m_Data+(inIndex+inCount)*inElemSize, (m_Count-inIndex-inCount)*inElemSize);
		m_Count -= inCount;
	}
};

/*
	TCorArray - General typed dynamic array
*/
template <class T> class TCorArray
: public CCorArray
{
public:
	inline TCorArray(NDword inCount=0)
		: CCorArray(inCount, sizeof(T))
	{
	}
	inline TCorArray(TCorArray& inArray)
		: CCorArray(inArray.m_Count, sizeof(T))
	{
		m_Count = 0;
		for (NDword i=0;i<inArray.m_Count;i++)
			new(&(*this)[AddNoConstruct()]) T(inArray[i]);
	}
	inline TCorArray& operator = (TCorArray& inArray)
	{
		if (this == &inArray)
			return(*this);
		m_Count = 0;
		m_Limit = inArray.m_Count;
		Realloc(sizeof(T));
		for (NDword i=0;i<inArray.m_Count;i++)
			new(&(*this)[AddNoConstruct()]) T(inArray[i]);
		return(*this);
	}
	inline ~TCorArray()
	{
		Purge();
	}
	inline T& operator [] (int i)
	{
		return(((T*)m_Data)[i]);
	}
	inline const T& operator [] (int i) const
	{
		return(((T*)m_Data)[i]);
	}
	inline NDword GetCount()
	{
		return(m_Count);
	}
	inline T* GetData()
	{
		return((T*)m_Data);
	}
	inline NBool IsInRange(int i)
	{
		return((i>=0) && (i<m_Count));
	}
	inline void Purge()
	{
		Remove(0, m_Count);
	}
	inline void Shrink()
	{
		if (m_Limit == m_Count)
			return;
		m_Limit = m_Count;
		Realloc(sizeof(T));
	}
	inline NDword AddItem(const T& inItem)
	{
		NDword i = Add();
		(*this)[i] = inItem;
		return(i);
	}
	inline NDword AddNoConstruct(NDword inCount=1)
	{
		NDword i = m_Count;
		if ((m_Count+=inCount)>m_Limit)
		{
			m_Limit = m_Count + (m_Count>>2) + 32;
			Realloc(sizeof(T));
		}
		return(i);
	}
	inline NDword Add(NDword inCount=1)
	{
		NDword index = AddNoConstruct(inCount);
		for (NDword i=index; i<index+inCount; i++)
			new(&(*this)[i]) T;
		return(index);
	}
	inline NDword AddZeroed(NDword inCount=1)
	{
		NDword i = AddNoConstruct(inCount);
		memset(&(*this)[i], 0, inCount*sizeof(T));
		return(i);
	}
	inline NBool FindItem(const T& inItem, NDword* outIndex) const
	{
		for (NDword i=0;i<m_Count;i++)
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
	inline NDword AddUnique(const T& inItem)
	{
		NDword i;
		if (FindItem(inItem, &i))
			return(i);
		return(AddItem(inItem));
	}
	inline NDword RemoveItem(const T& inItem)
	{
		NDword oldCount = m_Count;
		for (NDword i=0;i<m_Count;i++)
		{
			if (((T*)m_Data)[i] == inItem)
				Remove(i--);
		}
		return(oldCount - m_Count);
	}
	inline void Remove(NDword inIndex, NDword inCount=1)
	{
		for (NDword i=inIndex; i<(inIndex+inCount); i++)
			(&(*this)[i])->~T();
		CCorArray::Remove(inIndex, inCount, sizeof(T));
	}
	inline void SetCount(NDword inNewCount)
	{
		if((m_Count==inNewCount) && (m_Limit==inNewCount))
			return;
		m_Count = m_Limit = inNewCount;
		Realloc(sizeof(T));
	}
};

/*
	TCorStack - Generic dynamic stack
*/
template <class T> class TCorStack
{
private:
	TCorArray<T> m_Array;
	NDword m_Index;
public:
	inline TCorStack(NDword inCount=0)
		: m_Array(inCount), m_Index(0)
	{
	}
	inline TCorStack(TCorStack& inStack)
		: m_Array(inStack.m_Array), m_Index(inStack.m_Index)
	{
	}
	inline TCorStack& operator = (TCorStack& inStack)
	{
		m_Array = inStack.m_Array;
		m_Index = inStack.m_Index;
		return(*this);
	}
	inline ~TCorStack()
	{		
	}
	inline T& operator [] (int i)
	{
		return(m_Array[(NSDword)m_Index-(i+1)]);
	}
	inline const T& operator [] (int i) const
	{
		return(m_Array[(NSDword)m_Index-(i+1)]);
	}
	inline void Push(const T& inItem)
	{
		if (m_Index==m_Array.GetCount())
			m_Array.AddItem(inItem);
		else
			m_Array[m_Index] = inItem;
		m_Index++;
	}
	inline T Pop()
	{
		if (!m_Index)
			LOG_Errorf("TCorStack: Stack underflow");
		m_Index--;
		return(m_Array[m_Index]);
	}
	inline NDword GetCount()
	{
		return(m_Index);
	}
	inline void Purge()
	{
		m_Array.Purge();
		m_Array.Shrink();
		m_Index = 0;
	}
	inline void Shrink()
	{
		NDword count = m_Array.GetCount();
		if (m_Index == count)
			return;
		m_Array.Remove(m_Index, count-m_Index);
		m_Array.Shrink();
	}
	inline TCorArray<T>& GetArray()
	{
		return(m_Array);
	}
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    INLINE CLASS METHODS
//============================================================================
/*
	ICorStreamRead/ICorStreamWrite
	Stream operators
*/
inline ICorStreamRead& operator >> (ICorStreamRead& s, NByte& v) { v = s.ReadByte(); return(s); }
inline ICorStreamRead& operator >> (ICorStreamRead& s, NWord& v) { v = s.ReadWord(); return(s); }
inline ICorStreamRead& operator >> (ICorStreamRead& s, NDword& v) { v = s.ReadDword(); return(s); }
inline ICorStreamRead& operator >> (ICorStreamRead& s, NSByte& v) { v = s.ReadSByte(); return(s); }
inline ICorStreamRead& operator >> (ICorStreamRead& s, NSWord& v) { v = s.ReadSWord(); return(s); }
inline ICorStreamRead& operator >> (ICorStreamRead& s, NSDword& v) { v = s.ReadSDword(); return(s); }
inline ICorStreamRead& operator >> (ICorStreamRead& s, NFloat& v) { v = s.ReadFloat(); return(s); }
inline ICorStreamRead& operator >> (ICorStreamRead& s, NDouble& v) { v = s.ReadDouble(); return(s); }
inline ICorStreamRead& operator >> (ICorStreamRead& s, NChar*& v) { strcpy(v, s.ReadString()); return(s); }

inline ICorStreamWrite& operator << (ICorStreamWrite& s, NByte& v) { s.WriteByte(v); return(s); }
inline ICorStreamWrite& operator << (ICorStreamWrite& s, NWord& v) { s.WriteWord(v); return(s); }
inline ICorStreamWrite& operator << (ICorStreamWrite& s, NDword& v) { s.WriteDword(v); return(s); }
inline ICorStreamWrite& operator << (ICorStreamWrite& s, NSByte& v) { s.WriteSByte(v); return(s); }
inline ICorStreamWrite& operator << (ICorStreamWrite& s, NSWord& v) { s.WriteSWord(v); return(s); }
inline ICorStreamWrite& operator << (ICorStreamWrite& s, NSDword& v) { s.WriteSDword(v); return(s); }
inline ICorStreamWrite& operator << (ICorStreamWrite& s, NFloat& v) { s.WriteFloat(v); return(s); }
inline ICorStreamWrite& operator << (ICorStreamWrite& s, NDouble& v) { s.WriteDouble(v); return(s); }
inline ICorStreamWrite& operator << (ICorStreamWrite& s, NChar*& v) { s.WriteString(v); return(s); }

//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER CORMAIN.H
//**
//****************************************************************************
#endif // __CORMAIN_H__
