//****************************************************************************
//**
//**    CPJPROJ.CPP
//**    Projects
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "CpjProj.h"
#include "FileMain.h"
#include <direct.h>

#define CPJVECTOR VVec3
#define CPJQUAT VQuat3
#pragma pack(push,1)
#include "CpjFmt.h"
#pragma pack(pop)

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define CPJ_PROJECTHASH_BITS		10
#define CPJ_PROJECTHASH_BUCKETS		(1<<CPJ_PROJECTHASH_BITS)
#define CPJ_PROJECTHASH_MASK		(CPJ_PROJECTHASH_BUCKETS-1)

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    PRIVATE DATA
//============================================================================
static CCorString cpj_BasePath;

static OObject* cpj_ProjectHash[CPJ_PROJECTHASH_BUCKETS];
static OObject* cpj_ProjectHashEmpty;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static OCpjProject* FindHashedProject(const NChar* inFileName)
{
	if (!inFileName)
		return(NULL);
	NDword hash = STR_CalcHash((NChar*)inFileName) & CPJ_PROJECTHASH_MASK;
	if (!cpj_ProjectHash[hash])
		return(NULL);
	for (TObjIter<OCpjProject> i(cpj_ProjectHash[hash]); i; i++)
	{
		if (!stricmp(inFileName, i->GetFileName()))
			return(*i);
	}
	return(NULL);
}

static void DumpProjects(OObject* inBucket, NBool inDumpChunks)
{
	if (!inBucket)
		return;
	for (TObjIter<OCpjProject> i(inBucket); i; i++)
	{
		LOG_Logf("%s", i->GetFileName());
		if (inDumpChunks)
		{
			static NChar* noyes[2] = { "No", "Yes" };
			for (TObjIter<OCpjChunk> j(*i); j; j++)
				LOG_Logf("  %s (%s) Loaded:%s", j->GetName(), j->GetClass()->GetName(), noyes[j->mIsLoaded!=0]);
		}
	}
}

MSG_FUNC_RAW_GLOBAL(ListLoadedProjects)
{
	DumpProjects(cpj_ProjectHashEmpty, false);
	for (NDword i=0;i<CPJ_PROJECTHASH_BUCKETS;i++)
		DumpProjects(cpj_ProjectHash[i], false);
	return(1);
}

MSG_FUNC_RAW_GLOBAL(ListLoadedChunks)
{
	DumpProjects(cpj_ProjectHashEmpty, true);
	for (NDword i=0;i<CPJ_PROJECTHASH_BUCKETS;i++)
		DumpProjects(cpj_ProjectHash[i], true);
	return(1);
}

MSG_FUNC_C_GLOBAL(LoadChunk, "ss", (IMsgTarget*, IMsg*, NChar* inClass, NChar* inName))
{
	CObjClass* cls = CObjClass::FindClassNamed(inClass);
	if (!cls)
	{
		LOG_Logf("No class named \"%s\".", inClass);
		return(1);
	}
	OCpjChunk* chunk = CPJ_FindChunk(NULL, cls, inName);
	if (chunk)
	{
		LOG_Logf("\"%s\" loaded.", inName);
		chunk->CacheIn();
	}
	else
		LOG_Logf("Could not load \"%s\".", inName);
	return(1);
}

MSG_FUNC_C_GLOBAL(SetProjectPath, "s", (IMsgTarget*, IMsg*, NChar* inPath))
{
	CPJ_SetBasePath(inPath);
	return(1);
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void CPJ_SetBasePath(const NChar* inPath)
{
	cpj_BasePath = inPath;
	if (cpj_BasePath.Len() && ((*cpj_BasePath)[cpj_BasePath.Len()-1] != '\\'))
		cpj_BasePath += "\\";
}
KRN_API const NChar* CPJ_GetBasePath()
{
	return(*cpj_BasePath);
}
KRN_API OCpjProject* CPJ_FindProject(const NChar* inPath)
{
	if (!inPath || !inPath[0])
		return(NULL);

	CCorString fileName = cpj_BasePath + STR_FileSuggestedExt((NChar*)inPath, "cpj");

	// is this project already loaded?
	OCpjProject* res = FindHashedProject(*fileName);
	if (res)
		return(res);

	// attempt to load the project from within the base directory
	res = OCpjProject::New(NULL);
	NBool result = res->ImportFile(*fileName);
	if (!result)
	{
		res->Destroy();
		res = NULL;
	}
	return(res);
}
KRN_API OCpjChunk* CPJ_FindChunk(OCpjProject* inContext, CObjClass* inClass, const NChar* inPath)
{
	if (!inPath || !inPath[0] || !inClass)
		return(NULL);

	if (!strchr(inPath, '\\'))
	{
		// context-relative resource
		if (inContext)
			return(inContext->FindChunk(inClass, inPath));
		return(NULL);
	}

	// separate project name from chunk name
	char projectName[256], *chunkName;
	strcpy(projectName, inPath);
	chunkName = strrchr(projectName, '\\');
	*chunkName = 0;
	chunkName++;

	inContext = CPJ_FindProject(projectName);
	if (!inContext)
		return(NULL); // no backing project, cut out
	
	return(inContext->FindChunk(inClass, chunkName));
}
KRN_API const NChar* CPJ_GetProjectPath(OCpjProject* inProject)
{
	static NChar buf[256];

	if (!inProject)
		return(NULL);
	if (!CPJ_GetBasePath()[0])
		return(NULL); // project paths not allowed without a base
	if (strnicmp(inProject->GetFileName(), CPJ_GetBasePath(), strlen(CPJ_GetBasePath())))
		return(NULL); // project filename isn't underneath the base path
	
	strcpy(buf, inProject->GetFileName() + strlen(CPJ_GetBasePath()));
	return(buf);
}
KRN_API const NChar* CPJ_GetChunkPath(OCpjProject* inContext, OCpjChunk* inChunk)
{
	static NChar buf[256];

	if (!inChunk || !inChunk->GetParent() || !inChunk->GetParent()->IsA(OCpjProject::GetStaticClass()))
		return(NULL); // chunk needs to be underneath a project
	OCpjProject* prj = (OCpjProject*)inChunk->GetParent();
	if (inContext == prj)
	{
		strcpy(buf, inChunk->GetName());
		return(buf); // same project as context, name alone will suffice
	}
	strcpy(buf, CPJ_GetProjectPath(prj));
	strcat(buf, "\\");
	strcat(buf, inChunk->GetName());
	return(buf); // use full chunk path with project
}

//============================================================================
//    CLASS METHODS
//============================================================================
/*
	OCpjProject
*/
OBJ_CLASS_IMPLEMENTATION(OCpjProject, OCpjRes, 0);

void OCpjProject::SetFileName(const NChar* inFileName)
{
	mFileName = inFileName;
	NDword hash = STR_CalcHash((NChar*)inFileName) & CPJ_PROJECTHASH_MASK;

	if (!mFileName.Len())
	{
		if (!cpj_ProjectHashEmpty)
			cpj_ProjectHashEmpty = OObject::New(NULL);
		SetParent(cpj_ProjectHashEmpty);
	}
	else
	{
		if (!cpj_ProjectHash[hash])
			cpj_ProjectHash[hash] = OObject::New(NULL);
		SetParent(cpj_ProjectHash[hash]);
	}
}
OCpjChunk* OCpjProject::FindChunk(CObjClass* inResClass, const NChar* inResName)
{
	if (!inResClass)
		return(NULL);
	NDword hash = 0;
	if (inResName)
		hash = STR_CalcHash((NChar*)inResName);
	for (TObjIter<OCpjChunk> i(this); i; i++)
	{
		if (!i->IsA(inResClass))
			continue;
		if (inResName)
		{
			if (hash != i->GetNameHash())
				continue;
			if (stricmp(inResName, i->GetName()))
				continue;
		}
		return(*i);
	}
	return(NULL);
}

NBool OCpjProject::LoadFile(NChar* inFileName)
{
	SCpjFileHeader header;

	IFileRead* fp = FILE_OpenRead(inFileName);
	if (!fp)
		return(0);

	fp->Read(&header, sizeof(SCpjFileHeader));
	if ((header.riffMagic != KRN_FOURCC(CPJ_HDR_RIFF_MAGIC))
	 || (header.formMagic != KRN_FOURCC(CPJ_HDR_FORM_MAGIC)))
	{
		fp->Close();
		return(0);
	}

	// remove old data
	for (TObjIter<OCpjChunk> i(this); i; i++)
		i->Destroy();

	NDword position = sizeof(SCpjFileHeader);
	while (position < (header.lenFile + 8))
	{
		// seek to chunk position
		fp->SeekStart(position);

		// read RIFF magic and length fields
		NDword magic, length;
		*fp >> magic >> length;

		OCpjChunk* chunk = NULL;
		for (CObjClass* cls = CObjClass::GetFirstClass(); cls; cls = cls->GetNextClass())
		{
			OCpjChunk* r = OBJ_GetStaticInstance<OCpjChunk>(cls);
			if (r && (r->GetFourCC() == magic))
			{
				chunk = (OCpjChunk*)cls->New(this); // known chunk type, additional info will be present
				NDword version, timeStamp, ofsName;
				*fp >> version >> timeStamp >> ofsName;
				if (ofsName)
				{
					fp->SeekStart(position + ofsName);
					chunk->SetName(fp->ReadString());
				}				
				break;
			}
		}
		if (!chunk)
			chunk = OCpjUnkChunk::New(this);
		
		chunk->mIsLoaded = 0;
		chunk->mProxyOfs = position;
		chunk->mProxyLen = length + 8;
		chunk->mProxyTimeStamp = 0.f;

		// set position to start of next chunk
		position += (length + 8);
		if (length & 1)
			position++;
	}

	fp->Close();

	SetFileName(inFileName);

	return(1);
}

NBool OCpjProject::SaveFile(NChar* inFileName)
{
	NDword imageLen, tempLen;

	imageLen = sizeof(SCpjFileHeader);
	for (TObjIter<OCpjChunk> i(this); i; i++)
	{
		i->CacheIn();
		i->SaveChunk(NULL, &tempLen);
		imageLen += tempLen;
		if (tempLen & 1)
			imageLen++;
	}

	IFileWrite* fp = FILE_CreateWrite(inFileName);
	if (!fp)
		return(0);

	NByte* buf = MEM_Malloc(NByte, imageLen);

	SCpjFileHeader header;
	memset(&header, 0, sizeof(SCpjFileHeader));
	header.riffMagic = KRN_FOURCC(CPJ_HDR_RIFF_MAGIC);
	header.lenFile = imageLen - 8;
	header.formMagic = KRN_FOURCC(CPJ_HDR_FORM_MAGIC);

	SCpjFileHeader* file = (SCpjFileHeader*)buf;
	memcpy(file, &header, sizeof(SCpjFileHeader));

	imageLen = sizeof(SCpjFileHeader);
	for (i.Reset(this); i; i++)
	{		
		i->SaveChunk((NByte*)buf+imageLen, &tempLen);
		
		i->mProxyOfs = imageLen;
		i->mProxyLen = tempLen;
		i->mProxyTimeStamp = 0.f;
		
		imageLen += tempLen;
		if (tempLen & 1)
		{
			*((NByte*)buf+imageLen) = 0;
			imageLen++;
		}
	}

	fp->Write(buf, imageLen);
	fp->Close();

	SetFileName(inFileName);

	MEM_Free(buf);
	return(1);
}

//****************************************************************************
//**
//**    END MODULE CPJPROJ.CPP
//**
//****************************************************************************

