//****************************************************************************
//**
//**    IMPLWO.CPP
//**    Lightwave Object Files
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
typedef struct
{
	NChar label[4];
	NInt size;
} SLwoChunkHeader;

class __declspec(dllexport) OCpjImpGeoLWO
: public OCpjImporter
{
	OBJ_CLASS_DEFINE(OCpjImpGeoLWO, OCpjImporter);

	NBool ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError);

	// OCpjImporter
	CObjClass* GetImportClass() { return(OCpjGeometry::GetStaticClass()); }
	NChar* GetFileExtension() { return("lwo"); }
	NChar* GetFileDescription() { return("Lightwave Object"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImpGeoLWO, OCpjImporter, 0);

class __declspec(dllexport) OCpjImpFrmLWO
: public OCpjImporter
{
	OBJ_CLASS_DEFINE(OCpjImpFrmLWO, OCpjImporter);

	NBool ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError);

	// OCpjImporter
	CObjClass* GetImportClass() { return(OCpjFrames::GetStaticClass()); }
	NChar* GetFileExtension() { return("lwo"); }
	NChar* GetFileDescription() { return("Lightwave Object"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImpFrmLWO, OCpjImporter, 0);

class CLwoStream
: public ICorStreamRead
{
	NByte *mStartPtr, *mCurPtr, *mEndPtr;

public:
	CLwoStream(void* inPtr, NDword inLen)
	{
		mCurPtr = mStartPtr = (NByte*)inPtr;
		mEndPtr = mCurPtr + inLen;
	}

	NDword Tell()
	{
		return(mCurPtr - mStartPtr);
	}
	void Seek(NDword inOfs)
	{
		mCurPtr = mStartPtr + inOfs;
	}

	// ICorStream
	NBool Read(void* inPtr, NDword inLength)
	{
		if ((mCurPtr + inLength) > mEndPtr)
			return(0);
		if (inPtr)
		{
			switch(inLength)
			{
			case 1: *((NByte*)inPtr) = *((NByte*)mCurPtr); break;
			case 2: *((NWord*)inPtr) = *((NWord*)mCurPtr); break;
			case 4: *((NDword*)inPtr) = *((NDword*)mCurPtr); break;
			case 8: *((NQword*)inPtr) = *((NQword*)mCurPtr); break;
			default: memcpy(inPtr, mCurPtr, inLength); break;
			}
		}
		mCurPtr += inLength;
		return(1);
	}
};

class CImpPlugin
: public IPlgPlugin
{
public:
	// IPlgPlugin
	bool Create() { return(1); }
	bool Destroy() { return(1); }
	char* GetTitle() { return("Lightwave Object Importer"); }
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
static short SwapShort(short s)
{
	NByte b1,b2;
	b1 = s&255;
	b2 = (s>>8)&255;
	return((b1<<8)+b2);
}

static int SwapInt(int i)
{
	NByte b1,b2,b3,b4;
	b1 = i&255;
	b2 = (i>>8)&255;
	b3 = (i>>16)&255;
	b4 = (i>>24)&255;
	return(((int)b1<<24) + ((int)b2<<16) + ((int)b3<<8) + b4);
}

static float SwapFloat(float f)
{
	union { NByte b[4]; float f; } in, out;
	in.f = f;
	out.b[0] = in.b[3];
	out.b[1] = in.b[2];
	out.b[2] = in.b[1];
	out.b[3] = in.b[0];	
	return(out.f);
}

static NBool IsLabel(SLwoChunkHeader* chunk, NChar* label)
{
	return(((chunk->label[0] == label[0])
		&& (chunk->label[1] == label[1])
		&& (chunk->label[2] == label[2])
		&& (chunk->label[3] == label[3])));
}

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
	OCpjImpGeoLWO
*/
NBool OCpjImpGeoLWO::ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError)
{
	NDword i;
	VVec3 tempv;
	short triIndex[3];
	SLwoChunkHeader chunk;
	NDword fsize;
	int fpPols, bRead;
	short s;

	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
	OCpjGeometry* geom = (OCpjGeometry*)inRes;

	CLwoStream stream(inImagePtr, inImageLen);
	stream.Read(&chunk, sizeof(SLwoChunkHeader));
	chunk.size = SwapInt(chunk.size);

	if (!IsLabel(&chunk, "FORM"))
	{
		strcpy(outError, "Not a valid LWO file");
		return(0);
	}
	fsize = chunk.size + 8;
	stream.Read(chunk.label, 4);
	if (!IsLabel(&chunk, "LWOB"))
	{
		strcpy(outError, "Not a valid LWO file");
		return(0);
	}

	NDword numFrames = 1;
	NDword numVerts = 0;
	NDword numTris = 0;
	VVec3* loadingVerts = NULL;
	NDword* loadingTris = NULL;

	while ((!numVerts) || (!numTris))
	{
		if (stream.Tell() >= fsize)
		{
			if (!numVerts)
				strcpy(outError, "Vertices not found");
			if (!numTris)
				strcpy(outError, "Triangles not found");
			return(0);
		}
		stream.Read(&chunk, sizeof(SLwoChunkHeader));
		chunk.size = SwapInt(chunk.size);
		if (IsLabel(&chunk, "PNTS"))
		{
			numVerts = chunk.size / 12;
			loadingVerts = MEM_Malloc(VVec3, numVerts);
			for (i=0;i<numVerts;i++)
			{
				stream.Read(&tempv.x, sizeof(float)); tempv.x = SwapFloat(tempv.x);
				stream.Read(&tempv.y, sizeof(float)); tempv.y = SwapFloat(tempv.y);
				stream.Read(&tempv.z, sizeof(float)); tempv.z = SwapFloat(tempv.z); tempv.z = -tempv.z;
				loadingVerts[i] = tempv;
			}
		}
		else if (IsLabel(&chunk, "POLS"))
		{
			fpPols = stream.Tell();
			
			numTris = 0;
			bRead = 0;
			while (bRead < chunk.size)
			{
				stream.Read(&s, sizeof(short)); s = SwapShort(s); bRead += 2;
				if (s != 3)
				{
					strcpy(outError, "Non-triangular polygon found");
					return(0);
				}
				stream.Read(NULL, 6); bRead += 6;
				stream.Read(&s, sizeof(short)); s = SwapShort(s); bRead += 2;
				if (s < 0)
				{
					strcpy(outError, "Detail polygons are not allowed");
					return(0);
				}
				numTris++;
			}

			stream.Seek(fpPols);
			loadingTris = MEM_Malloc(NDword, numTris*3);
			for (i=0;i<numTris;i++)
			{
				stream.Read(&s, sizeof(short)); s = SwapShort(s);
				stream.Read(triIndex, sizeof(short)*3);
				loadingTris[i*3] = SwapShort(triIndex[0]);
				loadingTris[i*3+1] = SwapShort(triIndex[1]);
				loadingTris[i*3+2] = SwapShort(triIndex[2]);
				stream.Read(&s, sizeof(short)); s = SwapShort(s);
			}
		}
		else
			stream.Read(NULL, chunk.size);
	}

	NBool result = geom->Generate(numVerts, loadingVerts[0], numTris, loadingTris);

	MEM_Free(loadingVerts);
	MEM_Free(loadingTris);

	return(result);
}

NBool OCpjImpGeoLWO::Import(OObject* inRes, NChar* inFileName, NChar* outError)
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
	OCpjImpFrmLWO
*/
NBool OCpjImpFrmLWO::ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError)
{
	SLwoChunkHeader chunk;
	NDword fsize;

	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
	OCpjFrames* frames = (OCpjFrames*)inRes;
	frames->m_Frames.Purge(); frames->m_Frames.Shrink();

	CLwoStream stream(inImagePtr, inImageLen);
	stream.Read(&chunk, sizeof(SLwoChunkHeader));
	chunk.size = SwapInt(chunk.size);

	if (!IsLabel(&chunk, "FORM"))
	{
		strcpy(outError, "Not a valid LWO file");
		return(0);
	}
	fsize = chunk.size + 8;
	stream.Read(chunk.label, 4);
	if (!IsLabel(&chunk, "LWOB"))
	{
		strcpy(outError, "Not a valid LWO file");
		return(0);
	}

	NDword numVerts = 0;
	VVec3* loadingVerts = NULL;

	while (!numVerts)
	{
		if (stream.Tell() >= fsize)
		{
			if (!numVerts)
				strcpy(outError, "Vertices not found");
			return(0);
		}
		stream.Read(&chunk, sizeof(SLwoChunkHeader));
		chunk.size = SwapInt(chunk.size);
		if (IsLabel(&chunk, "PNTS"))
		{
			VVec3 tempv;
			numVerts = chunk.size / 12;
			loadingVerts = MEM_Malloc(VVec3, numVerts);
			for (NDword i=0;i<numVerts;i++)
			{
				stream.Read(&tempv.x, sizeof(float)); tempv.x = SwapFloat(tempv.x);
				stream.Read(&tempv.y, sizeof(float)); tempv.y = SwapFloat(tempv.y);
				stream.Read(&tempv.z, sizeof(float)); tempv.z = SwapFloat(tempv.z); tempv.z = -tempv.z;
				loadingVerts[i] = tempv;
			}
		}
		else
			stream.Read(NULL, chunk.size);
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

NBool OCpjImpFrmLWO::Import(OObject* inRes, NChar* inFileName, NChar* outError)
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
//**    END MODULE IMPLWO.CPP
//**
//****************************************************************************

