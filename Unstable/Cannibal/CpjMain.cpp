//****************************************************************************
//**
//**    CPJMAIN.CPP
//**    Cannibal Project Files
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "MemMain.h"
#include "FileMain.h"
#include "TimeMain.h"
#include "CpjMain.h"
#include <direct.h>

#define CPJVECTOR VVec3
#define CPJQUAT VQuat3
#pragma pack(push,1)
#include "CpjFmt.h"
#pragma pack(pop)

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
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
//============================================================================
//    CLASS METHODS
//============================================================================
OBJ_CLASS_IMPLEMENTATION(OCpjImporter, OObject, OBJCF_Abstract);
OBJ_CLASS_IMPLEMENTATION(OCpjExporter, OObject, OBJCF_Abstract);

/*
	OCpjRes
*/
OBJ_CLASS_IMPLEMENTATION(OCpjRes, OObject, OBJCF_Abstract);

NChar* OCpjRes::GetImportSpec()
{
	static NChar specBuf[2048];
	NChar* ptr;

	specBuf[0] = specBuf[1] = 0;
	ptr = specBuf;
	if (GetFileExtension() && GetFileDescription())
	{
		sprintf(ptr, "%s (*.%s)", GetFileDescription(), GetFileExtension());
		ptr += strlen(ptr)+1;
		sprintf(ptr, "*.%s", GetFileExtension());
		ptr += strlen(ptr)+1;
	}

	OCpjImporter* impo;
	for (CObjClass* cls = CObjClass::GetFirstClass(); cls; cls = cls->GetNextClass())
	{
		if ((!cls->IsDerivedFrom(OCpjImporter::GetStaticClass())) || (cls==OCpjImporter::GetStaticClass()))
			continue;
		if (!(impo = OBJ_GetStaticInstance<OCpjImporter>(cls)))
			continue;
		if (!IsA(impo->GetImportClass()))
			continue;
		
		if (impo->GetFileExtension() && impo->GetFileDescription())
		{
			sprintf(ptr, "%s (*.%s)", impo->GetFileDescription(), impo->GetFileExtension());
			ptr += strlen(ptr)+1;
			sprintf(ptr, "*.%s", impo->GetFileExtension());
			ptr += strlen(ptr)+1;
		}
	}
	*ptr = 0;
	return(specBuf);
}
NChar* OCpjRes::GetExportSpec()
{
	static NChar specBuf[2048];
	NChar* ptr;

	specBuf[0] = specBuf[1] = 0;
	ptr = specBuf;
	if (GetFileExtension() && GetFileDescription())
	{
		sprintf(ptr, "%s (*.%s)", GetFileDescription(), GetFileExtension());
		ptr += strlen(ptr)+1;
		sprintf(ptr, "*.%s", GetFileExtension());
		ptr += strlen(ptr)+1;
	}

	OCpjExporter* expo;
	for (CObjClass* cls = CObjClass::GetFirstClass(); cls; cls = cls->GetNextClass())
	{
		if ((!cls->IsDerivedFrom(OCpjExporter::GetStaticClass())) || (cls==OCpjExporter::GetStaticClass()))
			continue;
		if (!(expo = OBJ_GetStaticInstance<OCpjExporter>(cls)))
			continue;
		if (!IsA(expo->GetExportClass()))
			continue;
		
		if (expo->GetFileExtension() && expo->GetFileDescription())
		{
			sprintf(ptr, "%s (*.%s)", expo->GetFileDescription(), expo->GetFileExtension());
			ptr += strlen(ptr)+1;
			sprintf(ptr, "*.%s", expo->GetFileExtension());
			ptr += strlen(ptr)+1;
		}
	}
	*ptr = 0;
	return(specBuf);
}

NBool OCpjRes::ImportFile(NChar* inFileName, NBool inKeepConfiguration)
{
	if (!inFileName)
		return(0);
	NChar* ext = STR_FileExtension(inFileName);
	if (!ext)
		ext = GetFileExtension();
	if (!ext)
		return(0);

	if (GetFileExtension() && !stricmp(ext, GetFileExtension()))
		return(LoadFile(inFileName));

	OCpjImporter* impo;
	static char errorBuf[256];
	for (CObjClass* cls = CObjClass::GetFirstClass(); cls; cls = cls->GetNextClass())
	{
		if ((!cls->IsDerivedFrom(OCpjImporter::GetStaticClass())) || (cls==OCpjImporter::GetStaticClass()))
			continue;
		if (!(impo = OBJ_GetStaticInstance<OCpjImporter>(cls)))
			continue;
		if (!IsA(impo->GetImportClass()))
			continue;
		
		if (impo->GetFileExtension() && !stricmp(ext, impo->GetFileExtension()))
		{
			if (!inKeepConfiguration)
				impo->Configure(this, inFileName);
			if (!impo->Import(this, inFileName, errorBuf))
			{
				LOG_Warnf("ImportFile: %s", errorBuf);
				return(0);
			}
			return(1);
		}
	}
	return(0);
}
NBool OCpjRes::ExportFile(NChar* inFileName, NBool inKeepConfiguration)
{
	if (!inFileName)
		return(0);
	NChar* ext = STR_FileExtension(inFileName);
	if (!ext)
		ext = GetFileExtension();
	if (!ext)
		return(0);

	if (GetFileExtension() && !stricmp(ext, GetFileExtension()))
		return(SaveFile(inFileName));

	OCpjExporter* expo;
	static char errorBuf[256];
	for (CObjClass* cls = CObjClass::GetFirstClass(); cls; cls = cls->GetNextClass())
	{
		if ((!cls->IsDerivedFrom(OCpjExporter::GetStaticClass())) || (cls==OCpjExporter::GetStaticClass()))
			continue;
		if (!(expo = OBJ_GetStaticInstance<OCpjExporter>(cls)))
			continue;
		if (!IsA(expo->GetExportClass()))
			continue;
		
		if (expo->GetFileExtension() && !stricmp(ext, expo->GetFileExtension()))
		{
			if (!inKeepConfiguration)
				expo->Configure(this, inFileName);
			if (!expo->Export(this, inFileName, errorBuf))
			{
				LOG_Warnf("ExportFile: %s", errorBuf);
				return(0);
			}
			return(1);
		}
	}
	return(0);
}

/*
	OCpjChunk
*/
OBJ_CLASS_IMPLEMENTATION(OCpjChunk, OCpjRes, OBJCF_Abstract);

NBool OCpjChunk::CacheIn()
{
	mProxyTimeStamp = TIME_GetTimeFrame();
	if (mIsLoaded)
		return(1);
	if (!mProxyOfs || !GetParent()->IsA(OCpjProject::GetStaticClass()))
		return(0);
	OCpjProject* prj = (OCpjProject*)GetParent();
	IFileRead* fp = FILE_OpenRead(prj->GetFileName());
	if (!fp)
		return(0);
	fp->SeekStart(mProxyOfs);
	NByte* buf = MEM_Malloc(NByte, mProxyLen);
	fp->Read(buf, mProxyLen);
	fp->Close();
	if (LoadChunk(buf, mProxyLen))
		mIsLoaded = 1;
	MEM_Free(buf);
	return(mIsLoaded);
}
NBool OCpjChunk::CacheOut()
{
	if (!mIsLoaded)
		return(1); // already cached out
	if (!mProxyOfs || !GetParent()->IsA(OCpjProject::GetStaticClass()))
		return(0); // if it's not in a project, or it doesn't have an offset to load from, leave it
	OCpjProject* prj = (OCpjProject*)GetParent();
	if (prj->IsLocked())
		return(0); // project is locked, leave it
	//if ((TIME_GetTimeFrame() - mProxyTimeStamp) < 60.f) // FIXME: hardcoded test, preserve within 1 minute of use
	//	return(0);
	// flush it
	LoadChunk(NULL, 0);
	mIsLoaded = 0;
	return(1);
}
OCpjProject* OCpjChunk::GetProjectParent()
{
	if (GetParent() && GetParent()->IsA(OCpjProject::GetStaticClass()))
		return((OCpjProject*)GetParent());
	return(NULL);
}

NBool OCpjChunk::LoadFile(NChar* inFileName)
{
	IFileRead* fp = FILE_OpenRead(inFileName);
	if (!fp)
		return(0);
	NDword size = fp->Size();
	NByte* buf = MEM_Malloc(NByte, size);
	fp->Read(buf, size);
	fp->Close();

	SCpjFileHeader* file = (SCpjFileHeader*)buf;
	if ((file->riffMagic != KRN_FOURCC(CPJ_HDR_RIFF_MAGIC))
	 || (file->formMagic != KRN_FOURCC(CPJ_HDR_FORM_MAGIC)))
		return(0);
	
	NByte* chunkPtr = (NByte*)buf + sizeof(SCpjFileHeader);
	while (chunkPtr < ((NByte*)buf + file->lenFile + 8))
	{
		NDword magic = *((NDword*)chunkPtr);
		NDword length = *(((NDword*)chunkPtr)+1) + 8;

		if (GetFourCC() == magic)
			return(LoadChunk(chunkPtr, length));

		chunkPtr += length;
		if (length & 1)
			chunkPtr++;
	}
	
	MEM_Free(buf);
	return(1);
}

NBool OCpjChunk::SaveFile(NChar* inFileName)
{
	NDword imageLen, tempLen;

	CacheIn();

	IFileWrite* fp = FILE_CreateWrite(inFileName);
	if (!fp)
		return(0);	

	imageLen = sizeof(SCpjFileHeader);
	SaveChunk(NULL, &tempLen);
	imageLen += tempLen;
	if (tempLen & 1)
		imageLen++;

	NByte* buf = MEM_Malloc(NByte, imageLen);

	SCpjFileHeader header;
	memset(&header, 0, sizeof(SCpjFileHeader));
	header.riffMagic = KRN_FOURCC(CPJ_HDR_RIFF_MAGIC);
	header.lenFile = imageLen - 8;
	header.formMagic = KRN_FOURCC(CPJ_HDR_FORM_MAGIC);

	SCpjFileHeader* file = (SCpjFileHeader*)buf;
	memcpy(file, &header, sizeof(SCpjFileHeader));
	
	imageLen = sizeof(SCpjFileHeader);
	SaveChunk((NByte*)buf+imageLen, &tempLen);
	imageLen += tempLen;
	if (tempLen & 1)
	{
		*((NByte*)buf+imageLen) = 0;
		imageLen++;
	}
	
	fp->Write(buf, imageLen);
	fp->Close();
	MEM_Free(buf);
	return(1);
}

/*
	OCpjUnkChunk
*/
OBJ_CLASS_IMPLEMENTATION(OCpjUnkChunk, OCpjChunk, 0);

NBool OCpjUnkChunk::LoadChunk(void* inImagePtr, NDword inImageLen)
{
	mData.Purge(); mData.Shrink();
	if (inImageLen)
	{
		mData.AddNoConstruct(inImageLen);
		memcpy(&mData[0], inImagePtr, inImageLen);
	}
	return(1);
}
NBool OCpjUnkChunk::SaveChunk(void* inImagePtr, NDword* outImageLen)
{
	if (outImageLen)
		*outImageLen = mData.GetCount();
	if (inImagePtr && mData.GetCount())
		memcpy(inImagePtr, &mData[0], mData.GetCount());
	return(1);
}

//****************************************************************************
//**
//**    END MODULE CPJMAIN.CPP
//**
//****************************************************************************

