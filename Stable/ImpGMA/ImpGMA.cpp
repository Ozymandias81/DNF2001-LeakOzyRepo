//****************************************************************************
//**
//**    IMPGMA.CPP
//**    Generic Mesh Animation
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
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
#pragma pack(push, 1)
typedef struct
{
    NDword magic; // AGMA
    NChar versionMajor;
    NChar versionMinor;
    NWord numFrames;
    NWord numTris;
    NWord numVerts;
    NDword vertOfs;
} SGmaHeader;
#pragma pack(pop)

class __declspec(dllexport) OCpjImpGeoGMA
: public OCpjImporter
{
    OBJ_CLASS_DEFINE(OCpjImpGeoGMA, OCpjImporter);

	NBool ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError);

	// OCpjImporter
	CObjClass* GetImportClass() { return(OCpjGeometry::GetStaticClass()); }
    NChar* GetFileExtension() { return("gma"); }
    NChar* GetFileDescription() { return("Generic Mesh Animation"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImpGeoGMA, OCpjImporter, 0);

class __declspec(dllexport) OCpjImpFrmGMA
: public OCpjImporter
{
    OBJ_CLASS_DEFINE(OCpjImpFrmGMA, OCpjImporter);

	NBool ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError);

	// OCpjImporter
	CObjClass* GetImportClass() { return(OCpjFrames::GetStaticClass()); }
    NChar* GetFileExtension() { return("gma"); }
    NChar* GetFileDescription() { return("Generic Mesh Animation"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImpFrmGMA, OCpjImporter, 0);

class CImpPlugin
: public IPlgPlugin
{
public:
	// IPlgPlugin
	bool Create() { return(1); }
	bool Destroy() { return(1); }
    char* GetTitle() { return("Generic Mesh Animation Importer"); }
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
/*
	OCpjImpGeoGMA
*/
NBool OCpjImpGeoGMA::ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError)
{
	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
	OCpjGeometry* geom = (OCpjGeometry*)inRes;

	SGmaHeader* header = (SGmaHeader*)inImagePtr;

	if ((header->magic != KRN_FOURCC("AGMA"))
	 || (header->versionMajor != 1) || (header->versionMinor != 0))
	{
		strcpy(outError, "Invalid GMA file");
		return(0);
	}

	if ((!header->numFrames) || (!header->numVerts) || (!header->numTris))
	{
		strcpy(outError, "GMA is missing frames / vertices / triangles");
		return(0);
	}

	NWord* gmaTris = (NWord*)((NByte*)inImagePtr + sizeof(SGmaHeader));
	VVec3* gmaVerts = (VVec3*)((NByte*)inImagePtr + header->vertOfs);

	VVec3* loadingVerts = MEM_Malloc(VVec3, header->numVerts);
	NDword* loadingTris = MEM_Malloc(NDword, header->numTris*3);

	for (NDword i=0;i<header->numVerts;i++)
		loadingVerts[i] = gmaVerts[i]; // only use first frame for geometry
	
	for (i=0;i<header->numTris;i++)
	{
		loadingTris[i*3] = gmaTris[i*3];
		loadingTris[i*3+1] = gmaTris[i*3+1];
		loadingTris[i*3+2] = gmaTris[i*3+2];
	}

	NBool result = geom->Generate(header->numVerts, loadingVerts[0], header->numTris, loadingTris);

	MEM_Free(loadingVerts);
	MEM_Free(loadingTris);

	if (!result)
		strcpy(outError, "Could not generate geometry");
	return(result);
}

NBool OCpjImpGeoGMA::Import(OObject* inRes, NChar* inFileName, NChar* outError)
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
	OCpjImpFrmGMA
*/
NBool OCpjImpFrmGMA::ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError)
{
	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
	OCpjFrames* frames = (OCpjFrames*)inRes;
	frames->m_Frames.Purge(); frames->m_Frames.Shrink();

	SGmaHeader* header = (SGmaHeader*)inImagePtr;

	if ((header->magic != KRN_FOURCC("AGMA"))
	 || (header->versionMajor != 1) || (header->versionMinor != 0))
	{
		strcpy(outError, "Invalid GMA file");
		return(0);
	}

	if ((!header->numFrames) || (!header->numVerts) || (!header->numTris))
	{
		strcpy(outError, "GMA is missing frames / vertices / triangles");
		return(0);
	}

	VVec3* gmaVerts = (VVec3*)((NByte*)inImagePtr + header->vertOfs);

	for (NDword iFrame=0; iFrame<header->numFrames; iFrame++)
	{
		CCpjFrmFrame* oFrame = &frames->m_Frames[frames->m_Frames.Add()];
		NChar nameBuf[256]; sprintf(nameBuf, "%s_%03d", frames->GetName(), iFrame);
		oFrame->m_Name = nameBuf; oFrame->m_NameHash = STR_CalcHash(nameBuf);
		oFrame->m_isCompressed = 0;
		oFrame->m_PurePos.AddNoConstruct(header->numVerts);
		memcpy(oFrame->m_PurePos[0], &gmaVerts[iFrame*header->numVerts], header->numVerts);
	}
	frames->UpdateBounds();

	return(1);
}

NBool OCpjImpFrmGMA::Import(OObject* inRes, NChar* inFileName, NChar* outError)
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
//**    END MODULE IMPGMA.CPP
//**
//****************************************************************************

