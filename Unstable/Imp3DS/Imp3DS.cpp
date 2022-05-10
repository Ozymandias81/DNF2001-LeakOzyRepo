//****************************************************************************
//**
//**    IMP3DS.CPP
//**    3D Studio Files
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "PlgMain.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define CHUNK_MAINMAGIC		0x4d4d
#define CHUNK_NAMEDOBJECT	0x4000

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
typedef struct
{
	NWord type;
	NDword length;
	void* data;
} S3dsChunk;

class __declspec(dllexport) CCpjImpCommon3DS
{
public:
	static NDword sNumVerts;
	static NDword sNumTris;

	NBool ReadChunk(S3dsChunk* inPrevChunk, void* inLimit);
	void ParseVertList(S3dsChunk* inChunk, void* inLimit, VVec3* outVerts);
	void ParseFaceList(S3dsChunk* inChunk, void* inLimit, NDword* outTris);
	void ParseTriObject(S3dsChunk* inChunk, void* inLimit, VVec3* outVerts, NDword* outTris);
	void ParseNamedObject(S3dsChunk* inChunk, void* inLimit, VVec3* outVerts, NDword* outTris);
};

NDword CCpjImpCommon3DS::sNumVerts = 0;
NDword CCpjImpCommon3DS::sNumTris = 0;

class __declspec(dllexport) OCpjImpGeo3DS
: public OCpjImporter
, public CCpjImpCommon3DS
{
	OBJ_CLASS_DEFINE(OCpjImpGeo3DS, OCpjImporter);

	NBool ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError);

	// OCpjImporter
	CObjClass* GetImportClass() { return(OCpjGeometry::GetStaticClass()); }
	NChar* GetFileExtension() { return("3ds"); }
	NChar* GetFileDescription() { return("3D Studio File"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImpGeo3DS, OCpjImporter, 0);

class __declspec(dllexport) OCpjImpFrm3DS
: public OCpjImporter
, public CCpjImpCommon3DS
{
	OBJ_CLASS_DEFINE(OCpjImpFrm3DS, OCpjImporter);

	NBool ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError);

	// OCpjImporter
	CObjClass* GetImportClass() { return(OCpjFrames::GetStaticClass()); }
	NChar* GetFileExtension() { return("3ds"); }
	NChar* GetFileDescription() { return("3D Studio File"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImpFrm3DS, OCpjImporter, 0);

class CImpPlugin
: public IPlgPlugin
{
public:
	// IPlgPlugin
	bool Create() { return(1); }
	bool Destroy() { return(1); }
	char* GetTitle() { return("3D Studio Geometry Importer"); }
	char* GetDescription() { return("No description"); }
	char* GetAuthor() { return("3D Realms Entertainment"); }
	float GetVersion() { return(1.0f); }
};

//============================================================================
//    PRIVATE DATA
//============================================================================
static CImpPlugin imp_Plugin;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
extern "C" __declspec(dllexport) IPlgPlugin* __cdecl CannibalPluginCreate(void)
{
	return(&imp_Plugin);
}

//============================================================================
//    CLASS METHODS
//============================================================================
NBool CCpjImpCommon3DS::ReadChunk(S3dsChunk* inPrevChunk, void* inLimit)
{
	S3dsChunk res;

	res.data = (NByte*)inPrevChunk->data + inPrevChunk->length;
	if ((NDword)res.data >= (NDword)inLimit)
		return(0);
	res.type = *((NWord*)res.data);
	res.data = (NByte*)res.data + 2;
	res.length = *((NSDword*)res.data) - 6;
	res.data = (NByte*)res.data + 4;
	*inPrevChunk = res;
	return(1);
}

void CCpjImpCommon3DS::ParseVertList(S3dsChunk* inChunk, void* inLimit, VVec3* outVerts)
{
	NWord numChunkVerts = *((NWord*)inChunk->data);
	void* verts = (NByte*)inChunk->data + 2;

	if (!outVerts)
	{
		sNumVerts += numChunkVerts;
		return;
	}

	for (NDword i=0;i<numChunkVerts;i++)
	{        
		outVerts[sNumVerts+i].x = *((float*)verts);
		outVerts[sNumVerts+i].y = *((float*)verts+2);
		outVerts[sNumVerts+i].z = -(*((float*)verts+1));
		verts = (NByte*)verts + 12;
	}
	
	sNumVerts += numChunkVerts;
}

void CCpjImpCommon3DS::ParseFaceList(S3dsChunk* inChunk, void* inLimit, NDword* outTris)
{
	NWord numChunkTris = *((NWord*)inChunk->data);
	void* tris = (NByte*)inChunk->data + 2;
    NDword sizer = 2;

	if (!outTris)
	{
		sNumTris += numChunkTris;
		return;
	}

	for (NDword i=0;i<numChunkTris;i++)
	{
		outTris[(sNumTris+i)*3+2] = *((NWord *)tris);
		outTris[(sNumTris+i)*3+1] = *((NWord *)tris+1);
		outTris[(sNumTris+i)*3+0] = *((NWord *)tris+2);
		tris = (NByte*)tris + 8; // skip flags field
        sizer += 8;
	}

    S3dsChunk subChunk = {0x4120, sizer, inChunk->data};
    if (sizer < inChunk->length)
    {
        while (ReadChunk(&subChunk, inLimit))
			; // got rid of matgroup reading stuff here
    }        

	sNumTris += numChunkTris;
}

void CCpjImpCommon3DS::ParseTriObject(S3dsChunk* inChunk, void* inLimit, VVec3* outVerts, NDword* outTris)
{
	S3dsChunk subChunk = {0x4100, 0, inChunk->data};

	while (ReadChunk(&subChunk, inLimit))
	{
		if (subChunk.type == 0x4110)
			ParseVertList(&subChunk, (NByte*)subChunk.data+subChunk.length, outVerts);
		else if (subChunk.type == 0x4120)
			ParseFaceList(&subChunk, (NByte*)subChunk.data+subChunk.length, outTris);
	}
}

void CCpjImpCommon3DS::ParseNamedObject(S3dsChunk* inChunk, void* inLimit, VVec3* outVerts, NDword* outTris)
{
	NDword namelen = strlen((char*)inChunk->data) + 1;
	S3dsChunk subChunk = {0x4000, namelen, inChunk->data};

	while (ReadChunk(&subChunk, inLimit))
	{
		if (subChunk.type == 0x4100)
			ParseTriObject(&subChunk, (NByte*)subChunk.data+subChunk.length, outVerts, outTris);
	}
}

/*
	OCpjImpGeo3DS
*/
NBool OCpjImpGeo3DS::ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError)
{
	S3dsChunk mainChunk;
	NByte* imageEnd;

	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
	OCpjGeometry* geom = (OCpjGeometry*)inRes;

	imageEnd = (NByte*)inImagePtr + inImageLen;
	
	mainChunk.type = CHUNK_MAINMAGIC;
	mainChunk.length = 22;
	mainChunk.data = (NByte*)inImagePtr;
	sNumVerts = 0;
	sNumTris = 0;
	while (ReadChunk(&mainChunk, imageEnd))
	{
		if (mainChunk.type == CHUNK_NAMEDOBJECT)
			ParseNamedObject(&mainChunk, (NByte*)mainChunk.data + mainChunk.length, NULL, NULL);
	}

	NDword numFrames = 1;
	NDword numVerts = sNumVerts;
	NDword numTris = sNumTris;	
	VVec3* loadingVerts = MEM_Malloc(VVec3, numVerts);
	NDword* loadingTris = MEM_Malloc(NDword, numTris*3);

	mainChunk.type = CHUNK_MAINMAGIC;
	mainChunk.length = 22;
	mainChunk.data = (NByte*)inImagePtr;
	sNumVerts = 0;
	sNumTris = 0;
	while (ReadChunk(&mainChunk, imageEnd))
	{
		if (mainChunk.type == CHUNK_NAMEDOBJECT)
			ParseNamedObject(&mainChunk, (NByte*)mainChunk.data + mainChunk.length, loadingVerts, loadingTris);
	}
	
	NBool result = geom->Generate(numVerts, loadingVerts[0], numTris, loadingTris);

	MEM_Free(loadingVerts);
	MEM_Free(loadingTris);

	if (!result)
		strcpy(outError, "Could not generate geometry");
	return(result);
}

NBool OCpjImpGeo3DS::Import(OObject* inRes, NChar* inFileName, NChar* outError)
{	
	FILE* fp;
	NDword fplen;
	if (!(fp = fopen(inFileName, "rb")))
	{
		sprintf(outError, "Could not open file \"%s\"", inFileName);
		return(0);
	}
	fseek(fp, 0, SEEK_END);
	fplen = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	NByte* buf = MEM_Malloc(NByte, fplen);
	fread(buf, 1, fplen, fp);
	fclose(fp);
	NBool result = ImportMem(inRes, buf, fplen, outError);
	MEM_Free(buf);
	if (result)
	{
		OCpjGeometry* geom = (OCpjGeometry*)inRes;
		geom->SetName(STR_FileRoot(inFileName));
		geom->mIsLoaded = 1;
	}
	return(result);
}

/*
	OCpjImpFrm3DS
*/
NBool OCpjImpFrm3DS::ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError)
{
	S3dsChunk mainChunk;
	NByte* imageEnd;

	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
	OCpjFrames* frames = (OCpjFrames*)inRes;
	frames->m_Frames.Purge(); frames->m_Frames.Shrink();

	imageEnd = (NByte*)inImagePtr + inImageLen;
	
	mainChunk.type = CHUNK_MAINMAGIC;
	mainChunk.length = 22;
	mainChunk.data = (NByte*)inImagePtr;
	sNumVerts = 0;
	sNumTris = 0;
	while (ReadChunk(&mainChunk, imageEnd))
	{
		if (mainChunk.type == CHUNK_NAMEDOBJECT)
			ParseNamedObject(&mainChunk, (NByte*)mainChunk.data + mainChunk.length, NULL, NULL);
	}

	NDword numVerts = sNumVerts;
	VVec3* loadingVerts = MEM_Malloc(VVec3, numVerts);

	mainChunk.type = CHUNK_MAINMAGIC;
	mainChunk.length = 22;
	mainChunk.data = (NByte*)inImagePtr;
	sNumVerts = 0;
	sNumTris = 0;
	while (ReadChunk(&mainChunk, imageEnd))
	{
		if (mainChunk.type == CHUNK_NAMEDOBJECT)
			ParseNamedObject(&mainChunk, (NByte*)mainChunk.data + mainChunk.length, loadingVerts, NULL);
	}

	CCpjFrmFrame* oFrame = &frames->m_Frames[frames->m_Frames.Add()];
	NChar nameBuf[256]; sprintf(nameBuf, "%s_000", frames->GetName());
	oFrame->m_Name = nameBuf; oFrame->m_NameHash = STR_CalcHash(nameBuf);
	oFrame->m_isCompressed = 0;
	oFrame->m_PurePos.AddNoConstruct(numVerts);
	memcpy(oFrame->m_PurePos[0], loadingVerts[0], numVerts);
	frames->UpdateBounds();

	MEM_Free(loadingVerts);
	
	return(1);
}

NBool OCpjImpFrm3DS::Import(OObject* inRes, NChar* inFileName, NChar* outError)
{	
	FILE* fp;
	NDword fplen;
	if (!(fp = fopen(inFileName, "rb")))
	{
		sprintf(outError, "Could not open file \"%s\"", inFileName);
		return(0);
	}
	fseek(fp, 0, SEEK_END);
	fplen = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	NByte* buf = MEM_Malloc(NByte, fplen);
	fread(buf, 1, fplen, fp);
	fclose(fp);

	inRes->SetName(STR_FileRoot(inFileName));
	NBool result = ImportMem(inRes, buf, fplen, outError);

	MEM_Free(buf);
	
	if (result)
	{
		OCpjFrames* frames = (OCpjFrames*)inRes;
		frames->mIsLoaded = 1;
	}
	return(result);
}

//****************************************************************************
//**
//**    END MODULE IMP3DS.CPP
//**
//****************************************************************************

