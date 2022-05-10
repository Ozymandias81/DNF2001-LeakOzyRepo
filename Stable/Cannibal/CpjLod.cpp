//****************************************************************************
//**
//**    CPJLOD.CPP
//**    Cannibal Models - LOD Descriptions
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "MacMain.h"
#include "CpjLod.h"
#include <time.h>

#define CPJVECTOR VVec3
#define CPJQUAT VQuat3
#pragma pack(push,1)
#include "CpjFmt.h"
#pragma pack(pop)

#include ".\Mrg\Include\Mrg.h"

#if KRN_DEBUG
#pragma comment(lib, ".\\Mrg\\Lib\\Mrgd.lib")
#else
#pragma comment(lib, ".\\Mrg\\Lib\\Mrg.lib")
#endif

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class XLodException
{
private:
	CCorString mText;
public:
	XLodException(NChar* inFmt, ... ) { mText = STR_Va(inFmt); }
	const NChar* GetText() { return(*mText); }
};

class CLodGenMrgInfo
{
public:
	MrgVertexData* mVerts;
	MrgFaceSet* mFaces;
	MrgHier* mHier;
	MrgModel* mModel;

	CLodGenMrgInfo()
	{
		mVerts = new MrgVertexData;
		mFaces = new MrgFaceSet;
		mHier = NULL;
		mModel = NULL;
	}
	void BuildModel()
	{
		mHier = new MrgHier(*mFaces, *mVerts);
		mModel = new MrgModel;
		mModel->addMesh(mHier);
	}
};

class CLodGenVert
{
public:
	struct STexVert
	{
		CCpjSrfTex* mTex;
		VVec2 mPos;
		NDword mUVIndex;
	};
	VVec3 mPos;
	TCorArray<STexVert> mTV;
};

class CLodGenVertInfo
{
public:
	NDword mOrigCount; // original vertex count
	NDword mMrgCount; // mrg vertex count, original plus duplicates
	TCorArray<CLodGenVert> mGenVerts; // original vertex positions
	TCorArray<NDword> mMrgToOrig; // original index for each mrg vertex
	TCorArray<NDword> mOrigToMrg; // first mrg index for each original vertex

	CLodGenVertInfo() { mOrigCount = mMrgCount = 0; }
};

class CLodGenTriInfo
{
public:
	NDword mCount;
	TCorArray<SMacTri> mMacTris;
	TCorArray<NDword> mOrigToMrg;
	TCorArray<NDword> mMrgToOrig;
};

class CLodGenerator
{
public:
	CLodGenMrgInfo mMrgInfo;
	
	OMacActor* mActor;
	
	NFloat mLodLevel;
	NBool mUseTexVerts;

	VVec3 mBBMin, mBBMax;
	VVec3 mBBox[8];
	NDword mMinActiveFaces;

	CLodGenTriInfo mTris;
	CLodGenVertInfo mVerts;

	TCorArray<VVec3> mMinGeom;

	CLodGenerator()
	{
		mActor = NULL;
	}
	~CLodGenerator()
	{
		if (mActor)
			mActor->Destroy();
	}
	NBool Init(OCpjLodData* inLod, OCpjGeometry* inGeo, OCpjSurface* inSrf, NFloat inLodLevel, NBool inUseTexVerts)
	{
		if (!inGeo || !inSrf)
			return(0);
		if (inGeo->m_Tris.GetCount() != inSrf->m_Tris.GetCount())
			return(0);
		
		mActor = OMacActor::New(NULL);
		mActor->SetGeometry(inGeo);
		mActor->SetSurface(0, inSrf);
		if (inLod)
			mActor->SetLodData(inLod);

		if (inLodLevel < 0.f) inLodLevel = 0.f;
		if (inLodLevel > 1.f) inLodLevel = 1.f;
		mLodLevel = inLodLevel;
		mUseTexVerts = inUseTexVerts;

		mMinActiveFaces = 0;

		return(1);
	}

	void PreGenerateVerts()
	{
		// initialize vertex positions
		mVerts.mOrigCount = mActor->mGeometry->m_Verts.GetCount();
		mVerts.mGenVerts.AddZeroed(mVerts.mOrigCount);
		for (NDword i=0;i<mVerts.mOrigCount;i++)
			mVerts.mGenVerts[i].mPos = mActor->mGeometry->m_Verts[i].refPosition;

		// build bounding boxes
		mBBMin = VVec3(FLT_MAX,FLT_MAX,FLT_MAX);
		mBBMax = VVec3(-FLT_MAX,-FLT_MAX,-FLT_MAX);
		for (i=0;i<mVerts.mOrigCount;i++)
		{
			for (NDword j=0;j<3;j++)
			{
				if (mBBMin[j] > mVerts.mGenVerts[i].mPos[j]) mBBMin[j] = mVerts.mGenVerts[i].mPos[j];
				if (mBBMax[j] < mVerts.mGenVerts[i].mPos[j]) mBBMax[j] = mVerts.mGenVerts[i].mPos[j];
			}
		}
		mBBox[0] = VVec3(mBBMin[0], mBBMin[1], mBBMin[2]);
		mBBox[1] = VVec3(mBBMax[0], mBBMin[1], mBBMin[2]);
		mBBox[2] = VVec3(mBBMin[0], mBBMax[1], mBBMin[2]);
		mBBox[3] = VVec3(mBBMax[0], mBBMax[1], mBBMin[2]);
		mBBox[4] = VVec3(mBBMin[0], mBBMin[1], mBBMax[2]);
		mBBox[5] = VVec3(mBBMax[0], mBBMin[1], mBBMax[2]);
		mBBox[6] = VVec3(mBBMin[0], mBBMax[1], mBBMax[2]);
		mBBox[7] = VVec3(mBBMax[0], mBBMax[1], mBBMax[2]);

		// assign to mrg
		TCorArray<VVec3> tempV(mVerts.mOrigCount);
		for (i=0;i<mVerts.mOrigCount;i++)
			tempV[i] = mVerts.mGenVerts[i].mPos;
		mMrgInfo.mVerts->setGeometry((MrgCoord3D*)&tempV[0], (NWord)mVerts.mOrigCount);
	}

	void PreGenerateFaces()
	{
		mTris.mCount = mActor->EvaluateTris(mLodLevel, NULL);
		mTris.mMacTris.AddZeroed(mTris.mCount);
		mActor->EvaluateTris(mLodLevel, &mTris.mMacTris[0]);

		if (mTris.mCount != mActor->mGeometry->m_Tris.GetCount())
			throw XLodException("mTris.mCount != mActor->mGeometry.m_Tris.GetCount()");

		// run through all faces and look at the vertices and texture vertices they
		// reference, building up the list of texture positions associated with each
		// vertex.
		VVec2* uvZero = &mActor->mSurfaces[0]->m_UV[0];
		for (NDword i=0;i<mTris.mCount;i++)
		{
			SMacTri* tri = &mTris.mMacTris[i];
			for (NDword j=0;j<3;j++)
			{
				CLodGenVert* oV = &mVerts.mGenVerts[tri->vertIndex[j]];

				// see if this texture vertex is already part of our list
				for (NDword m=0;m<oV->mTV.GetCount();m++)
				{
					if ((oV->mTV[m].mTex == tri->texture)
					 && (oV->mTV[m].mPos == *tri->texUV[j]))
						break;
				}
				if ((mUseTexVerts) && (m >= oV->mTV.GetCount()))
				{
					// not in the list, add it
					m = oV->mTV.Add();
					oV->mTV[m].mTex = tri->texture;
					oV->mTV[m].mPos = *tri->texUV[j];
					oV->mTV[m].mUVIndex = tri->texUV[j] - uvZero;
				}
			}
		}

		// build destination vertices
		TCorArray<NDword> vertFirstIndex;

		mVerts.mMrgCount = 0;
		for (i=0;i<mVerts.mOrigCount;i++)
		{
			CLodGenVert* oV = &mVerts.mGenVerts[i];
			if (!oV->mTV.GetCount())
			{
				// no texture vertices, create a stub
				NDword m = oV->mTV.Add();
				oV->mTV[m].mTex = NULL;
				oV->mTV[m].mPos = VVec2(0,0);
				oV->mTV[m].mUVIndex = 0;
			}
			if (mVerts.mGenVerts[i].mTV.GetCount() > 1)
				mMrgInfo.mVerts->duplicateVertex((NWord)mVerts.mMrgCount, (NWord)mVerts.mGenVerts[i].mTV.GetCount() - 1);

			vertFirstIndex.AddItem(mVerts.mMrgCount);
			mVerts.mMrgCount += mVerts.mGenVerts[i].mTV.GetCount();
		}
		if (mMrgInfo.mVerts->getNumGeometry() != mVerts.mMrgCount)
			throw XLodException("mMrgInfo.mVerts->getNumGeometry() != mVerts.mMrgCount");

		TCorArray<VVec2> destTV(mVerts.mMrgCount);
		VVec2* oTV = &destTV[0];
		for (i=0;i<mVerts.mOrigCount;i++)
		{
			for (NDword j=0;j<mVerts.mGenVerts[i].mTV.GetCount();j++)
				*oTV++ = mVerts.mGenVerts[i].mTV[j].mPos;
		}
		mMrgInfo.mVerts->setTexCoords((MrgCoord2Df*)&destTV[0], destTV.GetCount());
		
		TCorArray<NWord> destTris(mTris.mCount*3);
		for (i=0;i<mTris.mCount;i++)
		{
			SMacTri* tri = &mTris.mMacTris[i];
			for (NDword j=0;j<3;j++)
			{
				CLodGenVert* oV = &mVerts.mGenVerts[tri->vertIndex[j]];
				
				destTris[i*3+(2-j)] = (NWord)vertFirstIndex[tri->vertIndex[j]];
				if (mUseTexVerts)
				{
					for (NDword m=0;m<oV->mTV.GetCount();m++)
					{
						if ((oV->mTV[m].mTex == tri->texture)
						 && (oV->mTV[m].mPos == *tri->texUV[j]))
						{
							destTris[i*3+(2-j)] += (NWord)m;
							break;
						}
					}
				}
			}
		}
		mMrgInfo.mFaces->setTriangleFaces(&destTris[0], (NWord)mTris.mCount);
	}

	void PreGenerateMinGeom()
	{
		for (NDword i=0;i<mVerts.mOrigCount;i++)
		{
			CCpjGeoVert* v = &mActor->mGeometry->m_Verts[i];
			if (!(v->flags & GEOVF_LODLOCK))
				continue;
			CLodGenVert* oV = &mVerts.mGenVerts[i];
			for (NDword j=0;j<oV->mTV.GetCount();j++)
				mMinGeom.AddItem(oV->mPos);
		}
		if (mMinGeom.GetCount())
			mMrgInfo.mVerts->setMinGeometry((MrgCoord3D*)&mMinGeom[0], (NWord)mMinGeom.GetCount());
		else
			mMrgInfo.mVerts->setMinGeometry((MrgCoord3D*)&mBBox[0], 8);
	}

	void Process()
	{
		MrgInitOption options;
		NDword preV, preF;
		NDword postV, postF;

		mMrgInfo.BuildModel();

		preV = mMrgInfo.mVerts->getNumGeometry();
		preF = mMrgInfo.mFaces->getNumTriangles();

		options.mWeldDistance = -1; // no welding
		options.mPreserveFaces = 1; // don't kill me please sir
		options.mPreserveUnref = 1; // don't kill me either, please sir
		options.mHoldMinFaces = 1; // don't leave me out in the cold just because i'm locked
		options.mVolumeWeight = 15.0f; // 75% volume
		options.mAreaWeight = 5.0f; // 25% surface area
		
		mMrgInfo.mModel->initMRG(&options);

		postV = mMrgInfo.mVerts->getNumGeometry();
		postF = mMrgInfo.mFaces->getNumTriangles();

		if (preV!=postV)
			throw XLodException("Vertex removal");
		if (preF!=postF)
			throw XLodException("Face removal");

		mMrgInfo.mModel->calcVertexNorms();
	}

	void PostGenerateVertRemaps()
	{
		// mrg to original
		mVerts.mMrgToOrig.Add(mVerts.mMrgCount);
		const MrgUint16* origMap = mMrgInfo.mHier->getVertexData()->getOrigMap();
		for (NDword i=0;i<mVerts.mMrgCount;i++)
			mVerts.mMrgToOrig[i] = origMap[i];
		
		// original to mrg
		mVerts.mOrigToMrg.Add(mVerts.mOrigCount);
		memset(&mVerts.mOrigToMrg[0], 0xFF, mVerts.mOrigCount*sizeof(NDword));
		for (i=0;i<mVerts.mMrgCount;i++)
		{
			if (mVerts.mOrigToMrg[mVerts.mMrgToOrig[i]] == 0xFFFFFFFF)
				mVerts.mOrigToMrg[mVerts.mMrgToOrig[i]] = i;
		}
	}

	void PostGenerateFaceRemaps()
	{
		// mrg to original
		mTris.mMrgToOrig.Add(mTris.mCount);
		const MrgUint16* origMap = mMrgInfo.mHier->getFaceSet()->getOrigMap();
		for (NDword i=0;i<mTris.mCount;i++)
			mTris.mMrgToOrig[i] = origMap[i];

		// original to mrg
		mTris.mOrigToMrg.Add(mTris.mCount);
		memset(&mTris.mOrigToMrg[0], 0xFF, mTris.mCount*sizeof(NDword));
		for (i=0;i<mTris.mCount;i++)
		{
			if (mTris.mOrigToMrg[mTris.mMrgToOrig[i]] == 0xFFFFFFFF)
				mTris.mOrigToMrg[mTris.mMrgToOrig[i]] = i;
		}
	}

	void CreateLodData(OCpjLodData* inLod)
	{
		// build levels
		NDword numGenLevels = 10;
		NDword numMrgLevels = mMrgInfo.mModel->getMaxResLevel()+1;

		inLod->m_Levels.Add(numGenLevels);
		for (NDword i=0;i<numGenLevels;i++)
		{
			// set current detail level
			CCpjLodLevel* lev = &inLod->m_Levels[i];
			lev->detail = (NFloat)(i+1) / (NFloat)numGenLevels;
			mMrgInfo.mModel->setResLevel((NDword)((1.f-lev->detail)*(NFloat)numMrgLevels));
			NDword numLevelVerts = mMrgInfo.mVerts->activePoints();
			NDword numLevelTris = mMrgInfo.mFaces->getActiveFaceCount();
			const MrgTri* levelTris = mMrgInfo.mFaces->getTriangles();

			// build vertex relay
			TCorArray<NWord> antiRelay(numLevelVerts);
			memset(&antiRelay[0], 0xFF, antiRelay.GetCount()*sizeof(NWord));
			NDword mrgV = 0;
			while (mrgV < numLevelVerts)
			{				
				NDword origV = mVerts.mMrgToOrig[mrgV];
				antiRelay[mrgV] = (NWord)lev->vertRelay.GetCount();
				lev->vertRelay.AddItem((NWord)origV);
				mrgV += mVerts.mGenVerts[origV].mTV.GetCount();
			}

			// build triangles
			VVec2* uvZero = &mActor->mSurfaces[0]->m_UV[0];
			lev->triangles.Add(numLevelTris);
			for (NDword j=0;j<numLevelTris;j++)
			{
				CCpjLodTri* tri = &lev->triangles[j];				
				tri->srfTriIndex = mTris.mMrgToOrig[j];
				
				for (NDword k=0;k<3;k++)
				{
					tri->vertIndex[k] = antiRelay[mVerts.mOrigToMrg[mVerts.mMrgToOrig[levelTris[j][2-k]]]];
					
					if (mUseTexVerts)
					{
						CLodGenVert* v = &mVerts.mGenVerts[mVerts.mMrgToOrig[levelTris[j][2-k]]];
						NDword uvOfs = levelTris[j][2-k] - mVerts.mOrigToMrg[mVerts.mMrgToOrig[levelTris[j][2-k]]];
						tri->uvIndex[k] = (NWord)v->mTV[uvOfs].mUVIndex;
					}
					else
						tri->uvIndex[k] = mTris.mMacTris[tri->srfTriIndex].texUV[k] - uvZero;
				}
			}
		}

		// test report
		LOG_Logf("Levels: %d", inLod->m_Levels.GetCount());
		for (i=0;i<inLod->m_Levels.GetCount();i++)
		{
			CCpjLodLevel* lev = &inLod->m_Levels[i];
			LOG_Logf("  %d: Detail=%f, NumV=%d, NumT=%d", i, lev->detail, lev->vertRelay.GetCount(), lev->triangles.GetCount());
		}
	}

	NBool Generate(OCpjLodData* inLod, CCorString& outError)
	{
		outError = NULL;
		try
		{
			PreGenerateVerts();
			PreGenerateFaces();
			PreGenerateMinGeom();
			Process();
			PostGenerateVertRemaps();
			PostGenerateFaceRemaps();
			CreateLodData(inLod);
		}
		catch(XLodException &e)
		{
			outError = e.GetText();
		}
		return (!outError.Len());
	}
};

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
/*
	OCpjLodData
*/
OBJ_CLASS_IMPLEMENTATION(OCpjLodData, OCpjChunk, 0);

NBool OCpjLodData::Generate(OCpjGeometry* inGeo, OCpjSurface* inSrf)
{
	// flush the old data
	LoadChunk(NULL, 0);

	// run the generator
	CLodGenerator g;
	if (!g.Init(NULL, inGeo, inSrf, 1.01f, /*true*/false))
	{
		LOG_Logf("LOD Initialization failure");
		return(0);
	}

	CCorString genError;
	if (!g.Generate(this, genError))
	{
		LOG_Logf("LOD Generate: %s", *genError);
		return(0);
	}
/*
	LOG_Logf("NumTris: %d", g.mTris.mCount);
	LOG_Logf("NumOrigVerts: %d", g.mVerts.mOrigCount);
	LOG_Logf("NumMrgVerts: %d", g.mVerts.mMrgCount);

	LOG_Logf("Tri Mapping:");
	for (NDword i=0;i<g.mTris.mCount;i++)
		LOG_Logf("  %d -> %d -> %d", i, g.mTris.mOrigToMrg[i], g.mTris.mMrgToOrig[g.mTris.mOrigToMrg[i]]);
	LOG_Logf("Vert Mapping Orig To Mrg:");
	for (i=0;i<g.mVerts.mOrigCount;i++)
		LOG_Logf("  %d -> %d -> %d", i, g.mVerts.mOrigToMrg[i], g.mVerts.mMrgToOrig[g.mVerts.mOrigToMrg[i]]);
	LOG_Logf("Vert Mapping Mrg To Orig:");
	for (i=0;i<g.mVerts.mMrgCount;i++)
		LOG_Logf("  %d -> %d -> %d", i, g.mVerts.mMrgToOrig[i], g.mVerts.mOrigToMrg[g.mVerts.mMrgToOrig[i]]);
*/
	return(1);
}

NDword OCpjLodData::GetFourCC()
{
	return(KRN_FOURCC(CPJ_LOD_MAGIC));
}
NBool OCpjLodData::LoadChunk(void* inImagePtr, NDword inImageLen)
{
    NDword i, j;

	if (!inImagePtr)
	{
		// remove old array data
		m_Levels.Purge(); m_Levels.Shrink();
		return(1);
	}

	// verify header
	SLodFile* file = (SLodFile*)inImagePtr;
	if (file->header.magic != KRN_FOURCC(CPJ_LOD_MAGIC))
		return(0);
	if (file->header.version < 3)
	{
		// old LOD format, ignore contents
		m_Levels.Purge(); m_Levels.Shrink();
		if (file->header.ofsName)
			SetName((char*)inImagePtr + file->header.ofsName);
		return(1);
	}
	if (file->header.version != CPJ_LOD_VERSION)
		return(0);

	// set up image data pointers
	SLodLevel* fileLevels = (SLodLevel*)(&file->dataBlock[file->ofsLevels]);
	NWord* fileVertRelay = (NWord*)(&file->dataBlock[file->ofsVertRelay]);
	SLodTri* fileTriangles = (SLodTri*)(&file->dataBlock[file->ofsTriangles]);

	// remove old array data
	m_Levels.Purge(); m_Levels.Shrink(); m_Levels.Add(file->numLevels);

	if (file->header.ofsName)
		SetName((char*)inImagePtr + file->header.ofsName);

	// levels
	for (i=0;i<file->numLevels;i++)
	{
		SLodLevel* iL = &fileLevels[i];
		CCpjLodLevel* oL = &m_Levels[i];
		
		oL->detail = iL->detail;
		oL->vertRelay.Add(iL->numVertRelay);
		for (j=0;j<iL->numVertRelay;j++)
			oL->vertRelay[j] = fileVertRelay[iL->firstVertRelay+j];
		oL->triangles.Add(iL->numTriangles);
		for (j=0;j<iL->numTriangles;j++)
		{
			SLodTri* iT = &fileTriangles[iL->firstTriangle+j];
			CCpjLodTri* oT = &oL->triangles[j];
			oT->srfTriIndex = iT->srfTriIndex;
			oT->vertIndex[0] = iT->vertIndex[0];
			oT->vertIndex[1] = iT->vertIndex[1];
			oT->vertIndex[2] = iT->vertIndex[2];
			oT->uvIndex[0] = iT->uvIndex[0];
			oT->uvIndex[1] = iT->uvIndex[1];
			oT->uvIndex[2] = iT->uvIndex[2];
		}
	}

	return(1);
}

NBool OCpjLodData::SaveChunk(void* inImagePtr, NDword* outImageLen)
{
    NDword i, j;
	SLodFile header;
    NDword imageLen;

	// build header and calculate memory required for image
	imageLen = 0;
	header.header.ofsName = imageLen + offsetof(SLodFile, dataBlock);
	imageLen += strlen(GetName())+1;
	header.numLevels = m_Levels.GetCount();
	header.ofsLevels = imageLen;
	imageLen += header.numLevels*sizeof(SLodLevel);
	header.numTriangles = 0;
	header.ofsTriangles = imageLen;
	for (i=0;i<header.numLevels;i++)
		header.numTriangles += m_Levels[i].triangles.GetCount();
	imageLen += header.numTriangles*sizeof(SLodTri);
	header.numVertRelay = 0;
	header.ofsVertRelay = imageLen;
	for (i=0;i<header.numLevels;i++)
		header.numVertRelay += m_Levels[i].vertRelay.GetCount();
	imageLen += header.numVertRelay*sizeof(NWord);
	imageLen += offsetof(SLodFile, dataBlock);

	// return if length is all that's desired
	if (outImageLen)
		*outImageLen = imageLen;
	if (!inImagePtr)
		return(1);

	header.header.magic = KRN_FOURCC(CPJ_LOD_MAGIC);
	header.header.lenFile = imageLen - 8;
	header.header.version = CPJ_LOD_VERSION;
	header.header.timeStamp = time(NULL);

	SLodFile* file = (SLodFile*)inImagePtr;
	memcpy(file, &header, offsetof(SLodFile, dataBlock));

	// set up image data pointers
	SLodLevel* fileLevels = (SLodLevel*)(&file->dataBlock[file->ofsLevels]);
	NWord* fileVertRelay = (NWord*)(&file->dataBlock[file->ofsVertRelay]);
	SLodTri* fileTriangles = (SLodTri*)(&file->dataBlock[file->ofsTriangles]);

	strcpy((char*)inImagePtr + file->header.ofsName, GetName());

	// levels
	NDword curTriangle = 0;
	NDword curVertRelay = 0;
	for (i=0;i<file->numLevels;i++)
	{
		SLodLevel* iL = &fileLevels[i];
		CCpjLodLevel* oL = &m_Levels[i];
		
		iL->detail = oL->detail;
		iL->numVertRelay = (NWord)oL->vertRelay.GetCount();
		iL->firstVertRelay = (NWord)curVertRelay;
		curVertRelay += iL->numVertRelay;
		for (j=0;j<iL->numVertRelay;j++)
			fileVertRelay[iL->firstVertRelay+j] = oL->vertRelay[j];
		iL->numTriangles = (NWord)oL->triangles.GetCount();
		iL->firstTriangle = (NWord)curTriangle;
		curTriangle += iL->numTriangles;
		for (j=0;j<iL->numTriangles;j++)
		{
			SLodTri* iT = &fileTriangles[iL->firstTriangle+j];
			CCpjLodTri* oT = &oL->triangles[j];
			iT->srfTriIndex = oT->srfTriIndex;
			iT->vertIndex[0] = oT->vertIndex[0];
			iT->vertIndex[1] = oT->vertIndex[1];
			iT->vertIndex[2] = oT->vertIndex[2];
			iT->uvIndex[0] = oT->uvIndex[0];
			iT->uvIndex[1] = oT->uvIndex[1];
			iT->uvIndex[2] = oT->uvIndex[2];
		}
	}

	return(1);
}

//****************************************************************************
//**
//**    END MODULE CPJLOD.CPP
//**
//****************************************************************************