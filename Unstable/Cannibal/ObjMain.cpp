//****************************************************************************
//**
//**    OBJMAIN.CPP
//**    Object Core
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "LogMain.h"
//#include "SysMain.h"
#include "MsgMain.h"
#include "TimeMain.h"
#include "ObjMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    PRIVATE DATA
//============================================================================
static CObjClass* obj_RootClass = NULL;

//============================================================================
//    GLOBAL DATA
//============================================================================
OBJ_BASE_CLASS_IMPLEMENTATION(OObject, 0);

//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void OBJ_Init(CObjClass* inRootClass)
{
	if (!inRootClass)
		inRootClass = OObject::GetStaticClass();
	obj_RootClass = inRootClass;
	OObject::GetRoot();
}
KRN_API void OBJ_Shutdown()
{
	OObject::KillRoot();
}

KRN_API CObjClass* OBJ_ConstructClass(CObjClass* inClass, const NChar* inName, const NChar* inSuperName, FObjSpawnFunc inSpawn, NDword inFlags)
{
	if (!inClass)
		return(NULL);
	return(new(inClass) CObjClass(inName, inSuperName, inSpawn, inFlags));
}

//============================================================================
//    CLASS METHODS
//============================================================================
/*
	CObjInterface
*/
CObjInterface* CObjInterface::sInterfaceList = NULL;
void CObjInterface::RegisterInterface(CObjInterface* inInterface)
{
	static CObjInterface* ifaceList = NULL;
	inInterface->mNext = ifaceList;
	ifaceList = inInterface;
	sInterfaceList = ifaceList;
}
const NChar* CObjInterface::GetName()
{
	return(*mInterfaceName);
}

CObjInterface::CObjInterface(const NChar* inName)
: mInterfaceName(inName), mNext(NULL)
{
	RegisterInterface(this);
}
CObjInterface::~CObjInterface()
{
}
CObjInterface* CObjInterface::FindInterfaceNamed(char* inName)
{
	if (!inName)
		return(NULL);
    for (CObjInterface* i = sInterfaceList; i; i = i->mNext)
	{
		if (!stricmp(i->GetName(), inName))
			return(i);
	}
	return(NULL);
}

/*
	CObjClass
*/
CObjClass* CObjClass::sClassList = NULL;
void CObjClass::RegisterClass(CObjClass* inClass)
{
    static CObjClass* clsList = NULL;
	inClass->mNext = clsList;
	clsList = inClass;
	sClassList = clsList;
}
OObject* CObjClass::New(OObject* inParent)
{
	if ((!mSpawnFunc) || (mClassFlags & OBJCF_Abstract))
		return(NULL);
	return(mSpawnFunc(inParent, this));
}
const char* CObjClass::GetName()
{
	return(*mClassName);
}
CObjClass* CObjClass::GetSuper()
{
	if (!mSuperClass && mSuperClassName.Len())
	{
		mSuperClass = FindClassNamed(*mSuperClassName);
		if (!mSuperClass)
			LOG_Errorf("CObjClass::GetSuper() : Unresolved superclass \"%s\"", *mSuperClassName);
	}
	return(mSuperClass);
}
bool CObjClass::IsDerivedFrom(CObjClass* inClass)
{
    for (CObjClass* cls = this; cls; cls = cls->GetSuper())
	{
		if (cls == inClass)
			return(1);
	}
	return(0);
}
OObject* CObjClass::GetStaticInstance()
{
	if (!mStaticInstance)
		mStaticInstance = New(NULL);
	return(mStaticInstance);
}
HInBindMap CObjClass::GetBindMap()
{
	return(mBindMap);
}
IMsgRouter* CObjClass::GetMsgRouter()
{
	return(mRouter);
}
CObjClass* CObjClass::MakeDerivedClass(const NChar* inName, NDword inFlags)
{
	return(new CObjClass(inName-1, GetName()-1, mSpawnFunc, inFlags));
}

CObjClass::CObjClass(const NChar* inName, const NChar* inSuperName, FObjSpawnFunc inSpawn, NDword inFlags)
	: mClassName(inName+1), mSuperClass(NULL), mSpawnFunc(inSpawn), mClassFlags(inFlags), mNext(NULL)
{
	if (inSuperName)
		mSuperClassName = inSuperName+1;
	mStaticInstance = NULL;
	mBindMap = IN_MakeBindMap((char*)inName+1);
	mRouter = MSG_MakeRouter((char*)inName);
	RegisterClass(this);
}
CObjClass::~CObjClass()
{
	if (mRouter)
		mRouter->Delete();
	mRouter=null;
}
CObjClass* CObjClass::FindClassNamed(char* inName)
{
	if (!inName)
		return(NULL);
    for (CObjClass* cls = sClassList; cls; cls = cls->mNext)
	{
		if (!stricmp(cls->GetName(), inName))
			return(cls);
	}
	return(NULL);
}

/*
	OObject
*/
NDword OObject::sObjCount = 0;
OObject *OObject::sRootObject = NULL;

OObject* OObject::GetRoot()
{
	if (!sRootObject)
	{
		sRootObject = obj_RootClass->New(NULL);
		if (!sRootObject)
			LOG_Errorf("OObject::GetRoot: Unable to spawn object");
		sRootObject->SetName("_ROOT_");
	}
	return(sRootObject);
}
void OObject::KillRoot()
{
	if (sRootObject)
		sRootObject->Destroy();
	sRootObject = NULL;
}

OObject* OObject::GetParent()
{
	return(mParentLink.GetParent());
}
void OObject::SetParent(OObject* inParent, NBool inReverseLinked)
{
	mParentLink.Unlink();
	mParentLink.SetParent(NULL);
	if (!inParent)
		return;
	mParentLink.SetParent(inParent->mChildLink.GetParent());
	if (inReverseLinked)
		mParentLink.LinkBefore(&inParent->mChildLink);
	else
		mParentLink.LinkAfter(&inParent->mChildLink);
}
void OObject::PreConstruct(OObject* inParent)
{
	mParentLink.PreConstruct();
	mChildLink.PreConstruct();
	mParentLink.SetChild(this);
	if (!inParent)
		return;
	mParentLink.SetParent(inParent->mChildLink.GetParent());
	mParentLink.LinkAfter(&inParent->mChildLink);
}

void OObject::Create()
{
}
void OObject::Destroy()
{
    for (CObjIter i(this); i; i++)
		i->Destroy();
	SetParent(NULL);

	delete this;
}

OObject::OObject()
{
	mFlags = 0;
	mParentLink.SetChild(this);
	mChildLink.SetParent(this);
	mChildLink.SetChild(NULL);
}
OObject::~OObject()
{
}

NBool OObject::Msg(IMsg* inMsg)
{
	for (CObjClass* cls = GetClass(); cls; cls = cls->GetSuper())
	{
		if (cls->GetMsgRouter()->MsgRoute(this, inMsg))
			return(1);
	}
	return(MSG_MakeRouter(NULL)->MsgRoute(this, inMsg));
}
IMsgTarget* OObject::MsgGetChild(NChar* inChildName)
{
	if (!inChildName)
		return(NULL);
	for (CObjIter i(this); i; i++)
	{
		if (!stricmp(i->GetName(), inChildName))
			return(*i);
	}
	return(NULL);
}
IMsgTarget* OObject::MsgGetParent()
{
	return(GetParent());
}
IMsgTarget* OObject::MsgGetRoot()
{
	return(OObject::GetRoot());
}

MSG_FUNC_C_GLOBAL(NewClass, "ss", (IMsgTarget*, IMsg*, NChar* inNewClass, NChar* inBaseClass))
{
	CObjClass* cls = CObjClass::FindClassNamed(inBaseClass);
	if (!cls)
		return(1);
	cls->MakeDerivedClass(inNewClass, 0);
	return(1);
}
MSG_FUNC_C(OObject, New, "ss", (OObject* This, IMsg*, NChar* inClassName, NChar* inName))
{
	CObjClass* cls = CObjClass::FindClassNamed(inClassName);
	if (!cls)
		return(1);
	OObject* obj = cls->New(This);
	if (!obj)
		return(1);
	if (!inName)
		inName = "";
	obj->SetName(inName);
	return(1);
}
MSG_FUNC_C(OObject, Destroy, "", (OObject* This, IMsg*))
{
	This->Destroy();
	return(1);
}
MSG_FUNC_C(OObject, SetName, "s", (OObject* This, IMsg*, NChar* inName))
{
	This->SetName(inName);
	return(1);
}
MSG_FUNC_RAW(OObject, Bind)
{
	if (inMsg->Argc() < 3)
		return(1);
	HInBindMap map = IN_MakeBindMap((NChar*)((OObject*)This)->GetClass()->GetName());
	NDword flags = 0;
	for (NDword i=1; 1; i++)
	{
		if (!stricmp(inMsg->Argv(i)->GetString(), "ctrl"))
			flags |= INEVF_CTRL;
		else if (!stricmp(inMsg->Argv(i)->GetString(), "alt"))
			flags |= INEVF_ALT;
		else if (!stricmp(inMsg->Argv(i)->GetString(), "shift"))
			flags |= INEVF_SHIFT;
		else
			break;
	}
	EInKey key = IN_KeyForName(inMsg->Argv(i)->GetString());
	if (!key)
		return(1);
	IN_BindKey(map, key, flags, inMsg->Argv(i+1)->GetString());
	return(1);
}
MSG_FUNC_RAW(OObject, Unbind)
{
	if (inMsg->Argc() < 2)
		return(1);
	HInBindMap map = IN_MakeBindMap((NChar*)((OObject*)This)->GetClass()->GetName());
	NDword flags = 0;
	for (NDword i=1; 1; i++)
	{
		if (!stricmp(inMsg->Argv(i)->GetString(), "ctrl"))
			flags |= INEVF_CTRL;
		else if (!stricmp(inMsg->Argv(i)->GetString(), "alt"))
			flags |= INEVF_ALT;
		else if (!stricmp(inMsg->Argv(i)->GetString(), "shift"))
			flags |= INEVF_SHIFT;
		else
			break;
	}
	EInKey key = IN_KeyForName(inMsg->Argv(i)->GetString());
	if (!key)
		return(1);
	IN_BindKey(map, key, flags, NULL);
	return(1);
}

//****************************************************************************
//**
//**    END MODULE OBJMAIN.CPP
//**
//****************************************************************************

