#ifndef __OBJMAIN_H__
#define __OBJMAIN_H__
//****************************************************************************
//**
//**    OBJMAIN.H
//**    Header - Object Core
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "MemMain.h"
#include "InMain.h"
#include "MsgMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
/*
	Object class definitions

	These declare an object class and automatically manage creation
    and registration of the corresponding CObjClass object, for runtime
	usage.

	IMPORTANT: Only the parent and object class are known to an object when
	its constructor is called.  If you need more detailed initialization,
	use the Create() function, which is called after all other creation variables
	are set and is correctly handled in the virtual function chain.

	Example class:

	// OMyObject.h
	class OMyObject : public OObject
	{
		OBJ_CLASS_DEFINE(OMyObject, OObject);

		OMyObject() {}
		~OMyObject() {}

		// ...etc.
	};

    // OMyObject.cpp
	OBJ_CLASS_IMPLEMENTATION(OMyObject, OObject, 0);
*/

// Common class definition, do not use directly
#define OBJ_COMMON_CLASS_DEFINE(xname) \
private: \
    static CObjClass* staticObjClass; \
    void* operator new(size_t size, OObject* inParent, CObjClass* inSetClass) \
	{ \
		OObject* obj = MEM_Malloc(xname, 1); \
		OObject::sObjCount++; \
		memset(obj, 0, sizeof(xname)); \
		obj->SetValid(1); \
		obj->SetClass(inSetClass); \
		obj->PreConstruct(inParent); \
		return(obj); \
	} \
	void operator delete(void* ptr) { ((OObject*)ptr)->SetValid(0); OObject::sObjCount--; MEM_Free(ptr); } \
	void operator delete(void* ptr, OObject*, CObjClass*) { ((OObject*)ptr)->SetValid(0); OObject::sObjCount--; MEM_Free(ptr); } \
public: \
	typedef xname ThisClass; \
    static CObjClass* GetStaticClass() { return(staticObjClass); } \
	static xname* New(OObject* inParent, CObjClass* inSetClass=NULL) \
	{ \
		if (!inSetClass) \
			inSetClass = GetStaticClass(); \
		xname* obj = new(inParent, inSetClass) xname; \
		obj->Create(); \
		return(obj); \
	}

// Standard OObject subclass definitions
#define OBJ_CLASS_DEFINE(xname, xsuper) \
	OBJ_COMMON_CLASS_DEFINE(xname) \
	typedef xsuper Super; \
    CObjClass* GetClass() { return(mClass); }

#define OBJ_CLASS_IMPLEMENTATION(xname, xsuper, xflags) \
    CObjClass xname##_objClassInstance; \
    CObjClass* xname::staticObjClass = OBJ_ConstructClass(&xname##_objClassInstance, #xname, #xsuper, (FObjSpawnFunc)xname::New, xflags); \

// Base class definitions, only used by OObject
#define OBJ_BASE_CLASS_DEFINE(xname) \
	OBJ_COMMON_CLASS_DEFINE(xname) \
    virtual CObjClass* GetClass() { return(mClass); }

#define OBJ_BASE_CLASS_IMPLEMENTATION(xname, xflags) \
    CObjClass xname##_objClassInstance(#xname, NULL, xname::New, xflags); \
    CObjClass* xname::staticObjClass = &xname##_objClassInstance;

#define OBJ_VALIDITY_STAMP		0x12345678

// class flags
enum
{
	OBJCF_Abstract		= 0x00000001,	// class can not be instantiated directly
};

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class CObjInterface;
class CObjClass;
class CObjLink;
class OObject;
class CObjIter;

/*
	CObjInterface
*/
class KRN_API CObjInterface
{
private:
	CCorString mInterfaceName;
	CObjInterface* mNext;

	static CObjInterface* sInterfaceList;
	static void RegisterInterface(CObjInterface* inInterface);

public:
	const NChar* GetName();

	static CObjInterface* GetFirstInterface() { return(sInterfaceList); }
	CObjInterface* GetNextInterface() { return(mNext); }

	CObjInterface(const NChar* inName);
	~CObjInterface();

	static CObjInterface* FindInterfaceNamed(NChar* inName);
};

/*
	CObjClass
	Object runtime class type
	Acts as a factory for instances of the class, so objects can be created
	by class name.  Contains class identification info such as name and super
	class, as well as other class-common functionality like key binding and
	message handlers.
*/
typedef OObject* (*FObjSpawnFunc)(OObject* inParent, CObjClass* inSetClass);

class KRN_API CObjClass
{
private:
	CCorString mClassName;
    CCorString mSuperClassName;
	CObjClass* mSuperClass;
	FObjSpawnFunc mSpawnFunc;
	NDword mClassFlags; // OBJCF_ flags
    CObjClass* mNext;
	OObject* mStaticInstance;
	HInBindMap mBindMap;
	IMsgRouter* mRouter;

    static CObjClass* sClassList;
    static void RegisterClass(CObjClass* inClass);

public:
	OObject* New(OObject* inParent);
	const NChar* GetName();
    CObjClass* GetSuper();
    NBool IsDerivedFrom(CObjClass* inClass);
	OObject* GetStaticInstance();
	HInBindMap GetBindMap();
	IMsgRouter* GetMsgRouter();
	CObjClass* MakeDerivedClass(const NChar* inName, NDword inFlags);

    static CObjClass* GetFirstClass() { return(sClassList); }
    CObjClass* GetNextClass() { return(mNext); }

	CObjClass() {}
	CObjClass(const NChar* inName, const NChar* inSuperName, FObjSpawnFunc inSpawn, NDword inFlags);
    ~CObjClass();

    static CObjClass* FindClassNamed(NChar* inName);
};

/*
	CObjLink
	Connection between an object and its parent, linking to siblings to create a forest.
	These links are not allocated at runtime, instead each object has two links embedded
	within it, the parent and child links.  The parent link is connected in a CLL with the
	child link of the object's parent, and the child link acts as a dummy for child objects.
	Links with no siblings will be self-connected.

    Diagram:
                             ____
                           P/    \C
                          /|\____/
                         / |
				  ____  /  |
				P/    \C   |
			   /|\____/ \  |
              / |        \ |
       ____  /  | ____    \| ____
	 P/    \C   P/    \C   P/    \C
	  \____/ \  |\____/     \____/
              \ |
               \| ____
                P/    \C
                 \____/

*/
class KRN_API CObjLink
{
private:
	OObject* mChild;
	OObject* mParent;
    CObjLink* mNext;
    CObjLink* mPrev;

public:
	inline OObject* GetChild() { return(mChild); }
	inline void SetChild(OObject* inObj) { mChild = inObj; }
	inline OObject* GetParent() { return(mParent); }
	inline void SetParent(OObject* inObj) { mParent = inObj; }
    inline CObjLink* GetNext() { return(mNext); }
    inline void SetNext(CObjLink* inLink) { mNext = inLink; }
    inline CObjLink* GetPrev() { return(mPrev); }
    inline void SetPrev(CObjLink* inLink) { mPrev = inLink; }

    void LinkBefore(CObjLink* inLink);
    void LinkAfter(CObjLink* inLink);
	void Unlink();

	void PreConstruct() { mChild = mParent = NULL; mNext = mPrev = this; }
    CObjLink() {}
    ~CObjLink() { Unlink(); }
};

/*
	OObject
	Base class of all objects
*/
class KRN_API OObject : public IMsgTarget
{
protected:
	static NDword sObjCount;

public:
	OBJ_BASE_CLASS_DEFINE(OObject);

	void /*final*/SetClass(CObjClass* inClass)
	{
		if (mClass)
			return; // can only be set once, at initialization
		mClass = inClass;
	}

	void /*final*/SetValid(NBool inIsValid)
	{
		if (inIsValid) mValidityStamp = OBJ_VALIDITY_STAMP;
		else mValidityStamp = 0;
	}

private:
	static OObject* sRootObject;

protected:    
	NDword mValidityStamp;
	CObjLink mParentLink, mChildLink;
    CObjClass* mClass;
	CCorString mName;
	NDword mNameHash;
	NDword mFlags;

public:	
	static NDword GetObjectCount() { return(sObjCount); }
	static OObject* GetRoot();
	static void KillRoot();

	inline NBool HasName() { return(mName.Len()!=0); }
	inline const NChar* GetName() { return(*mName); }
	inline NDword GetNameHash() { return(mNameHash); }
	inline void SetName(const NChar* inName) { mName = inName; mNameHash = STR_CalcHash((NChar*)inName); }
	
	inline NDword GetFlags() { return(mFlags); }
	inline void SetFlags(NDword inFlags) { mFlags = inFlags; }
	inline void AddFlags(NDword inFlags) { mFlags |= inFlags; }
	inline void SubFlags(NDword inFlags) { mFlags &= ~inFlags; }
	
	inline NBool IsValid() { return(mValidityStamp == OBJ_VALIDITY_STAMP); }

	OObject();
	virtual ~OObject();
	void /*final*/PreConstruct(OObject* inParent); // can NOT be virtual (called by operator new)
	virtual void Create();
	virtual void Destroy();	

	virtual OObject* GetParent();
	virtual void SetParent(OObject* inParent, NBool inReverseLinked=0);
	virtual NBool HasChildren() { return(mChildLink.GetNext() != &mChildLink); }
    virtual NBool IsA(CObjClass* inClass) { return(GetClass()->IsDerivedFrom(inClass)); }

	// IMsgTarget
	NBool Msg(IMsg* inMsg);
	IMsgTarget* MsgGetChild(NChar* inChildName);
	IMsgTarget* MsgGetParent();
	IMsgTarget* MsgGetRoot();

	friend class CObjClass;
	friend class CObjIter;	
};

/*
	CObjIter
	Object child iterator, used for convenience when iterating linked children
	of an object.  Can go forward or backward through the child list.  Forward is
	the default, but setting an optional second constructor/Reset parameter to true
	will iterate backwards instead. Star and arrow operators are used to access the
	object itself.

    Example:

	CMyObject* GetMyFirstChild(OObject* inObj)
	{
		for (CObjIter child(inObj); child; child++)
		{
            if (child->IsA(OMyObject::GetStaticClass()))
				return (CMyObject*) *child; // remember the star operator when casting!
		}
		return NULL;
	}
*/
class CObjIter
{
protected:
    CObjLink* mLink;
    CObjLink* mLinkNext;
	bool mReverse;

	inline OObject* GetObject()
	{
		if (!mLink)
			return(NULL);
		return(mLink->GetChild());
	}
	inline void GetNext()
	{
		if (mReverse)
			mLinkNext = mLink->GetPrev();
		else
			mLinkNext = mLink->GetNext();
	}
	inline void Advance()
	{
		mLink = mLinkNext;
		GetNext();
	}

public:
	inline void Reset(OObject* inObj, bool inReverse=false)
	{
		mLink = mLinkNext = NULL;
		if (!inObj)
			return;
		mLink = &inObj->mChildLink;
		mReverse = inReverse;
		GetNext();
		Advance();
	}
    inline CObjIter(OObject* inObj, bool inReverse=false) { Reset(inObj,inReverse); }
    inline CObjLink* operator ~ () { return(mLink); }
	inline OObject* operator * () { return(GetObject()); }
	inline OObject* operator -> () { return(GetObject()); }
	inline void operator ++ () { Advance(); }
	inline void operator ++ (int) { Advance(); }
	inline operator int () { return(GetObject()!=NULL); }
	inline operator bool () { return(GetObject()!=NULL); }
};

template<class T> class TObjIter
: public CObjIter
{
protected:
	inline void AdvanceToType()
	{
		while (GetObject() && (!GetObject()->IsA(T::GetStaticClass())))
			Advance();
	}
public:
	inline void Reset(OObject* inObj, bool inReverse=false)
	{
		CObjIter::Reset(inObj, inReverse);
		AdvanceToType();
	}
	inline TObjIter(OObject* inObj, bool inReverse=false) : CObjIter(inObj, inReverse) { Reset(inObj,inReverse); }
	inline void operator ++ () { Advance(); AdvanceToType(); }
	inline void operator ++ (int) { Advance(); AdvanceToType(); }
	inline T* operator * () { return((T*)GetObject()); }
	inline T* operator -> () { return((T*)GetObject()); }
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void OBJ_Init(CObjClass* inRootClass);
KRN_API void OBJ_Shutdown();

KRN_API CObjClass* OBJ_ConstructClass(CObjClass* inClass, const NChar* inName, const NChar* inSuperName, FObjSpawnFunc inSpawn, NDword inFlags);

template<class T> T* OBJ_GetStaticInstance(CObjClass* inClass=NULL)
{
	if (!inClass)
		return((T*)T::GetStaticClass()->GetStaticInstance());
	if (!inClass->IsDerivedFrom(T::GetStaticClass()))
		return(NULL);
	return((T*)inClass->GetStaticInstance());
}

//============================================================================
//    INLINE CLASS METHODS
//============================================================================
inline void CObjLink::LinkBefore(CObjLink* inLink)
{
	mNext = inLink;
	mPrev = inLink->mPrev;
	mNext->mPrev = mPrev->mNext = this;
}
inline void CObjLink::LinkAfter(CObjLink* inLink)
{
	mPrev = inLink;
	mNext = inLink->mNext;
	mNext->mPrev = mPrev->mNext = this;
}
inline void CObjLink::Unlink()
{
	mNext->mPrev = mPrev;
	mPrev->mNext = mNext;
	mNext = mPrev = this;
}

//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER OBJMAIN.H
//**
//****************************************************************************
#endif // __OBJMAIN_H__
