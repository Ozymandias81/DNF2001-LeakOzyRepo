#ifndef __CPJMAIN_H__
#define __CPJMAIN_H__
//****************************************************************************
//**
//**    CPJMAIN.H
//**    Header - Cannibal Project Files
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "VecMain.h"
#include "ObjMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
/*
	OCpjRes
	Base CPJ resource object, used as the base of project chunks as well as
	the projects themselves.  Controls loading, saving, import, and export.
*/
class KRN_API OCpjRes
: public OObject
{
	OBJ_CLASS_DEFINE(OCpjRes, OObject);

	virtual NChar* GetFileExtension() { return(NULL); }
	virtual NChar* GetFileDescription() { return(NULL); }
	virtual NBool LoadFile(NChar* inFileName) { return(0); }
	virtual NBool SaveFile(NChar* inFileName) { return(0); }

	NChar* GetImportSpec(); // returns file box import spec based on extension and importers
	NChar* GetExportSpec(); // returns file box export spec based on extension and exporters
	NBool ImportFile(NChar* inFileName, NBool inKeepConfiguration = 0); // calls LoadFile or passes to an importer based on extension
	NBool ExportFile(NChar* inFileName, NBool inKeepConfiguration = 0); // calls SaveFile or passes to an exporter based on extension
};

/*
	OCpjChunk
	Resources which are chunks embedded within project files.
*/
class OCpjProject;

class KRN_API OCpjChunk
: public OCpjRes
{
	OBJ_CLASS_DEFINE(OCpjChunk, OCpjRes);

	NBool mIsLoaded; // whether chunk is currently loaded, or false if it's still just a proxy
	NDword mProxyOfs, mProxyLen; // offset and length of chunk data within project file if not loaded
	NFloat mProxyTimeStamp; // time stamp of last access, at frame resolution
	
	void Create() { Super::Create(); mIsLoaded = 0; mProxyOfs = mProxyLen = 0; mProxyTimeStamp = 0.f; }
	
	NBool CacheIn();
	NBool CacheOut();
	OCpjProject* GetProjectParent();

	virtual NDword GetFourCC() { return(0); }
	virtual NBool LoadChunk(void* inImagePtr, NDword inImageLen) { return(0); }
	virtual NBool SaveChunk(void* inImagePtr, NDword* outImageLen) { return(0); }

	// OCpjRes
	NBool LoadFile(NChar* inFileName);
	NBool SaveFile(NChar* inFileName);
};

/*
	OCpjUnkChunk
	Chunk resource with unknown purpose; preserved as a raw data block
*/
class KRN_API OCpjUnkChunk
: public OCpjChunk
{
	OBJ_CLASS_DEFINE(OCpjUnkChunk, OCpjChunk);

	TCorArray<NByte> mData;

	// OCpjChunk
	NBool LoadChunk(void* inImagePtr, NDword inImageLen);
	NBool SaveChunk(void* inImagePtr, NDword* outImageLen);
};

/*
	OCpjImporter
	Object capable of importing a file from an external file format into
	a project resource, which may be a chunk or an entire project itself.
*/
class KRN_API OCpjImporter
: public OObject
{
	OBJ_CLASS_DEFINE(OCpjImporter, OObject);

	virtual CObjClass* GetImportClass() { return(NULL); }
	virtual NChar* GetFileExtension() { return(NULL); }
	virtual NChar* GetFileDescription() { return(NULL); }
	virtual NBool Configure(OObject* inRes, NChar* inFileName) { return(1); }
	virtual NBool Import(OObject* inRes, NChar* inFileName, NChar* outError)
	{
		strcpy(outError, "Invalid importer");
		return(0);
	}
};

/*
	OCpjExporter
	Object capable of exporting a project resource (an individual chunk or
	an entire project) to an external file format.
*/
class KRN_API OCpjExporter
: public OObject
{
	OBJ_CLASS_DEFINE(OCpjExporter, OObject);

	virtual CObjClass* GetExportClass() { return(NULL); }
	virtual NChar* GetFileExtension() { return(NULL); }
	virtual NChar* GetFileDescription() { return(NULL); }
	virtual NBool Configure(OObject* inRes, NChar* inFileName) { return(1); }
	virtual NBool Export(OObject* inRes, NChar* inFileName, NChar* outError)
	{
		strcpy(outError, "Invalid exporter");
		return(0);
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
//============================================================================
//    TRAILING HEADERS
//============================================================================
#include "CpjProj.h"
#include "CpjGeo.h"
#include "CpjSrf.h"
#include "CpjLod.h"
#include "CpjSkl.h"
#include "CpjFrm.h"
#include "CpjSeq.h"
#include "CpjMac.h"

//****************************************************************************
//**
//**    END HEADER CPJMAIN.H
//**
//****************************************************************************
#endif // __CPJMAIN_H__
