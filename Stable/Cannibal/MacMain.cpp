//****************************************************************************
//**
//**    MACMAIN.CPP
//**    Model Actors
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "MacMain.h"

#define CPJVECTOR VVec3
#define CPJQUAT VQuat3
#pragma pack(push,1)
#include "CpjFmt.h"
#pragma pack(pop)

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define MAC_NUMCHANNELS		16

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    PRIVATE DATA
//============================================================================
static VVec3 mac_tempVerts[4096]; // sufficient maximum

NDword OMacActor::FrameCount=0;
NDword OMacActor::Evaluations=0;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
MSG_FUNC_C(OMacActor, SetAuthor, "s", (OMacActor* This, IMsg*, NChar* inAuthor)) { This->mAuthor = inAuthor; return(1); }
MSG_FUNC_C(OMacActor, SetDescription, "s", (OMacActor* This, IMsg*, NChar* inDesc)) { This->mDescription = inDesc; return(1); }
MSG_FUNC_C(OMacActor, SetOrigin, "fff", (OMacActor* This, IMsg*, NFloat inX, NFloat inY, NFloat inZ)) { This->mOrigin = VVec3(inX,inY,inZ); return(1); }
MSG_FUNC_C(OMacActor, SetScale, "fff", (OMacActor* This, IMsg*, NFloat inX, NFloat inY, NFloat inZ)) { This->mScale = VVec3(inX,inY,inZ); return(1); }
MSG_FUNC_C(OMacActor, SetRotation, "fff", (OMacActor* This, IMsg*, NFloat inRoll, NFloat inPitch, NFloat inYaw))
{
	This->mRotation = VEulers3(M_DEGTORAD(inRoll),M_DEGTORAD(inPitch),M_DEGTORAD(inYaw));
	return(1);
}
MSG_FUNC_C(OMacActor, SetBoundsMin, "fff", (OMacActor* This, IMsg*, NFloat inX, NFloat inY, NFloat inZ)) { This->mBounds[0] = VVec3(inX,inY,inZ); return(1); }
MSG_FUNC_C(OMacActor, SetBoundsMax, "fff", (OMacActor* This, IMsg*, NFloat inX, NFloat inY, NFloat inZ)) { This->mBounds[1] = VVec3(inX,inY,inZ); return(1); }

MSG_FUNC_C(OMacActor, SetGeometry, "s", (OMacActor* This, IMsg*, NChar* inChunkPath))
{	
	This->SetGeometry((OCpjGeometry*)CPJ_FindChunk(This->mLoadProject, OCpjGeometry::GetStaticClass(), inChunkPath));
	return(1);
}
MSG_FUNC_C(OMacActor, SetSurface, "is", (OMacActor* This, IMsg*, NInt inIndex, NChar* inChunkPath))
{
	This->SetSurface(inIndex, (OCpjSurface*)CPJ_FindChunk(This->mLoadProject, OCpjSurface::GetStaticClass(), inChunkPath));
	return(1);
}
MSG_FUNC_C(OMacActor, SetLodData, "s", (OMacActor* This, IMsg*, NChar* inChunkPath))
{
	This->SetLodData((OCpjLodData*)CPJ_FindChunk(This->mLoadProject, OCpjLodData::GetStaticClass(), inChunkPath));
	return(1);
}
MSG_FUNC_C(OMacActor, SetSkeleton, "s", (OMacActor* This, IMsg*, NChar* inChunkPath))
{
	This->SetSkeleton((OCpjSkeleton*)CPJ_FindChunk(This->mLoadProject, OCpjSkeleton::GetStaticClass(), inChunkPath));
	return(1);
}
MSG_FUNC_C(OMacActor, AddFrames, "s", (OMacActor* This, IMsg*, NChar* inProjectPath))
{
	if (!stricmp(inProjectPath, "NULL"))
	{
		This->AddFrames(This->mLoadProject);
		return(1);
	}
	if (!strchr(inProjectPath, '*'))
	{
		for (NDword i=0;i<This->mFramesFiles.GetCount();i++)
		{
			if (!stricmp(*This->mFramesFiles[i], inProjectPath))
				break;
		}
		if (i==This->mFramesFiles.GetCount())
		{
			This->mFramesFiles.AddItem(inProjectPath);
			This->AddFrames(CPJ_FindProject(inProjectPath));
		}
		return(1);
	}

	for (NDword i=0;i<This->mFramesStarFiles.GetCount();i++)
	{
		if (!stricmp(*This->mFramesStarFiles[i], inProjectPath))
			break;
	}
	if (i==This->mFramesStarFiles.GetCount())
	{
		This->mFramesStarFiles.AddItem(inProjectPath); // record the star path for later
		CCorString oldBasePath = CPJ_GetBasePath();
		CPJ_SetBasePath(""); // since the file find uses absolute paths but findproject doesn't
		CCorString spec = oldBasePath + inProjectPath;
		NChar* fileName = STR_FileFind(*spec, NULL, NULL);
		while (fileName)
		{
			This->AddFrames(CPJ_FindProject(fileName));
			fileName = STR_FileFind(NULL, NULL, NULL);
		}
		CPJ_SetBasePath(*oldBasePath);
	}
	return(1);
}
MSG_FUNC_C(OMacActor, AddSequences, "s", (OMacActor* This, IMsg*, NChar* inProjectPath))
{
	if (!stricmp(inProjectPath, "NULL"))
	{
		This->AddSequences(This->mLoadProject);
		return(1);
	}
	if (!strchr(inProjectPath, '*'))
	{
		for (NDword i=0;i<This->mSequencesFiles.GetCount();i++)
		{
			if (!stricmp(*This->mSequencesFiles[i], inProjectPath))
				break;
		}
		if (i==This->mSequencesFiles.GetCount())
		{
			This->mSequencesFiles.AddItem(inProjectPath);
			This->AddSequences(CPJ_FindProject(inProjectPath));
		}
		return(1);
	}

	for (NDword i=0;i<This->mSequencesStarFiles.GetCount();i++)
	{
		if (!stricmp(*This->mSequencesStarFiles[i], inProjectPath))
			break;
	}
	if (i==This->mSequencesStarFiles.GetCount())
	{
		This->mSequencesStarFiles.AddItem(inProjectPath); // record the star path for later
		CCorString oldBasePath = CPJ_GetBasePath();
		CPJ_SetBasePath(""); // since the file find uses absolute paths but findproject doesn't
		CCorString spec = oldBasePath + inProjectPath;
		NChar* fileName = STR_FileFind(*spec, NULL, NULL);
		while (fileName)
		{
			This->AddSequences(CPJ_FindProject(fileName));
			fileName = STR_FileFind(NULL, NULL, NULL);
		}
		CPJ_SetBasePath(*oldBasePath);
	}
	return(1);
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    CLASS METHODS
//============================================================================

void
OMacActor::Tick()
{
	Evaluations = 0;
	FrameCount++;
}

/*
	CMacBone
*/
void CMacBone::ValidateAbs(NBool inMakeValid)
{
	if (inMakeValid)
	{
		// validate a bone's absolute state, including its ancestors
		if (mAbsValid)
			return;
		if (mParent)
			mParent->ValidateAbs(true);
		mAbsCoords = mRelCoords;
		if (mParent)
			mAbsCoords <<= mParent->mAbsCoords;
		mAbsValid = 1;
	}
	else
	{
		// invalidate a bone's absolute state, including its children
		if (!mAbsValid)
			return;
		mAbsValid = 0;
		for (CMacBone* b = mFirstChild; b; b = b->mNextSibling)
			b->ValidateAbs(false);
	}
}

VCoords3 CMacBone::GetCoords(NBool inAbsolute)
{
	if (inAbsolute)
	{
		ValidateAbs(true);
		return(mAbsCoords);
	}
	return(mRelCoords);
}
void CMacBone::SetCoords(const VCoords3& inCoords, NBool inAbsolute)
{	
	if (inAbsolute)
	{
		VCoords3 elderCoords;
		// Get relative by backward transforming up the parent tree
		for (CMacBone* b = mParent; b; b = b->mParent)
			elderCoords <<= b->mRelCoords;
		mRelCoords = inCoords >> elderCoords;
		// Set absolute since we have it
		mAbsCoords = inCoords;
		// Only invalidate absolute from the children down
		if (mFirstChild)
			mFirstChild->ValidateAbs(false);
	}
	else
	{
		// Set relative since we have it
		mRelCoords = inCoords;
		// Invalidate absolute from here down
		ValidateAbs(false);
	}
}
void CMacBone::ResetCoords()
{
	SetCoords(mSklBone->baseCoords, false);
}

/*
	OMacActor
*/
OBJ_CLASS_IMPLEMENTATION(OMacActor, OObject, 0);

CMacActorLink CMacActorLink::sHeadLink;

IMsgTarget* OMacActor::MsgGetChild(NChar* inChildName)
{
	NDword index;

	if (!inChildName)
		return(NULL);
	if (!stricmp(inChildName, "GEO"))
		return(mGeometry);
	if (!stricmp(inChildName, "SKL"))
		return(mSkeleton);
	if (!stricmp(inChildName, "LOD"))
		return(mLodData);
	if (!strnicmp(inChildName, "SRF", 3))
	{
		index=atoi(inChildName+3);
		if (index >= mSurfaces.GetCount())
			return(NULL);
		return(mSurfaces[index]);
	}
	if (!strnicmp(inChildName, "FRM", 3))
	{
		index=atoi(inChildName+3);
		if (index >= mFrames.GetCount())
			return(NULL);
		return(mFrames[index]);
	}
	if (!strnicmp(inChildName, "SEQ", 3))
	{
		index=atoi(inChildName+3);
		if (index >= mSequences.GetCount())
			return(NULL);
		return(mSequences[index]);
	}
	return(Super::MsgGetChild(inChildName));
}
void OMacActor::Create()
{
	Super::Create();

	mActorLink.SetActor(this);

	mOrigin			= VVec3(0,0,0);
	mScale			= VVec3(1,1,1);
	mRotation		= VEulers3(0,0,0);
	mBounds[0]		= VVec3(-1,-1,-1);
	mBounds[1]		= VVec3(1,1,1);
	LastEvalFrame	= 0;
	bBonesDirty		= true;

	mActorChannels.AddZeroed(MAC_NUMCHANNELS);
	
	LoadConfig(NULL);
}

CMacBone* OMacActor::FindBone(const NChar* inName)
{
	if (!inName || !mSkeleton)
		return(NULL);
	NDword hash = STR_CalcHash((NChar*)inName);
	for (NDword i=0;i<mActorBones.GetCount();i++)
	{
		CMacBone* bone = &mActorBones[i];
		if (bone->mSklBone->nameHash != hash)
			continue;
		if (stricmp(*bone->mSklBone->name, inName))
			continue;
		return(bone);
	}
	return(NULL);
}
CCpjFrmFrame* OMacActor::FindFrame(const NChar* inName)
{
	if (!inName)
		return(NULL);
	NDword hash = STR_CalcHash((NChar*)inName);
	for (NDword i=0;i<mFrames.GetCount();i++)
	{
		if (!mFrames[i])
			continue;
		mFrames[i]->CacheIn();
		for (NDword j=0;j<mFrames[i]->m_Frames.GetCount();j++)
		{
			CCpjFrmFrame* frm = &mFrames[i]->m_Frames[j];
			if (frm->m_NameHash != hash)
				continue;
			if (stricmp(*frm->m_Name, inName))
				continue;
			return(frm);
		}
	}
	return(NULL);
}
OCpjSequence* OMacActor::FindSequence(const NChar* inName)
{
	if (!inName)
		return(NULL);
	NDword hash = STR_CalcHash((NChar*)inName);
	for (NDword i=0;i<mSequences.GetCount();i++)
	{
		OCpjSequence* seq = mSequences[i];
		if (!seq)
			continue;
		if (hash != seq->GetNameHash())
			continue;
		if (stricmp(inName, seq->GetName()))
			continue;
		seq->CacheIn();
		return(seq);
	}
	return(NULL);
}

NBool OMacActor::SetGeometry(OCpjGeometry* inGeometry)
{
	mGeometry = inGeometry;
	if (!mGeometry)
		return(0);
	mGeometry->CacheIn();
	return(1);
}
NBool OMacActor::SetSkeleton(OCpjSkeleton* inSkeleton)
{
	// clear out old bones
	mSkeleton = inSkeleton;
	mActorBones.Purge(); mActorBones.Shrink();
	if (!mSkeleton)
		return(0);
	mSkeleton->CacheIn();

	// add the same number of bones as the skeleton
	mActorBones.Add(mSkeleton->m_Bones.GetCount());
	
	// set up parents
	for (NDword i=0;i<mActorBones.GetCount();i++)
	{
		CMacBone* bone = &mActorBones[i];		
		bone->mSklBone = &mSkeleton->m_Bones[i];
		bone->mParent = NULL;
		if (bone->mSklBone->parentBone)
			bone->mParent = &mActorBones[bone->mSklBone->parentBone - &mSkeleton->m_Bones[0]];
		bone->mFirstChild = bone->mNextSibling = NULL;
	}
	// determine children
	for (i=0;i<mActorBones.GetCount();i++)
	{
		CMacBone* bA = &mActorBones[i];
		for (NDword j=0;j<mActorBones.GetCount();j++)
		{
			CMacBone* bB = &mActorBones[j];
			if (bB->mParent == bA)
			{
				bB->mNextSibling = bA->mFirstChild;
				bA->mFirstChild = bB;
			}
		}
	}
	// reset all the transforms
	for (i=0;i<mActorBones.GetCount();i++)
		mActorBones[i].ResetCoords();
	return(1);
}
NBool OMacActor::SetLodData(OCpjLodData* inLodData)
{
	mLodData = inLodData;
	if (!mLodData)
		return(0);
	mLodData->CacheIn();
	return(1);
}
NBool OMacActor::SetSurface(NDword inIndex, OCpjSurface* inSurface)
{
	if (mSurfaces.GetCount() <= inIndex)
		mSurfaces.AddZeroed((inIndex - mSurfaces.GetCount()) + 1);
	mSurfaces[inIndex] = inSurface;
	if (!inSurface)
		return(0);
	inSurface->CacheIn();
	return(1);
}
NBool OMacActor::AddFrames(OCpjProject* inProject)
{
	if (!inProject)
		return(0);
	for (TObjIter<OCpjFrames> it(inProject); it; it++)
		mFrames.AddItem(*it);
	return(1);
}
NBool OMacActor::AddSequences(OCpjProject* inProject)
{
	if (!inProject)
		return(0);
	for (TObjIter<OCpjSequence> it(inProject); it; it++)
		mSequences.AddItem(*it);
	return(1);
}

NBool OMacActor::LoadConfig(OCpjConfig* inConfig)
{
	NDword i;

	mLoadProject = NULL;
	
	mGeometry = NULL;
	mSkeleton = NULL;
	mLodData = NULL;
	mSurfaces.Purge(); mSurfaces.Shrink();
	mFrames.Purge(); mFrames.Shrink();
	mSequences.Purge(); mSequences.Shrink();
	mFramesFiles.Purge(); mFramesFiles.Shrink();
	mFramesStarFiles.Purge(); mFramesStarFiles.Shrink();
	mSequencesFiles.Purge(); mSequencesFiles.Shrink();
	mSequencesStarFiles.Purge(); mSequencesStarFiles.Shrink();

	mTraceInfo = NULL;
	
	if (!inConfig)
		return(0);
	inConfig->CacheIn();

	// find autoexec section for processing
	CCpjMacSection* section = NULL;
	for (i=0;i<inConfig->m_Sections.GetCount();i++)
	{
		if (!stricmp(*inConfig->m_Sections[i].name, "autoexec"))
		{
			section = &inConfig->m_Sections[i];
			break;
		}
	}
	if (!section)
		return(0);

	// we have our section, run the commands	
	if (inConfig->GetParent() && inConfig->GetParent()->IsA(OCpjProject::GetStaticClass()))
		mLoadProject = (OCpjProject*)inConfig->GetParent();
	for (i=0;i<section->commands.GetCount();i++)
		Msgf(*section->commands[i]);
	mLoadProject = NULL;

	return(1);
}

NBool OMacActor::SaveConfig(OCpjConfig* inConfig)
{
	if (!inConfig)
		return(0);
	inConfig->CacheIn();

	OCpjProject* configProject = NULL;
	if (inConfig->GetParent() && inConfig->GetParent()->IsA(OCpjProject::GetStaticClass()))
		configProject = (OCpjProject*)inConfig->GetParent();

	// find autoexec section for processing
	CCpjMacSection* section = NULL;
	for (NDword i=0;i<inConfig->m_Sections.GetCount();i++)
	{
		if (!stricmp(*inConfig->m_Sections[i].name, "autoexec"))
		{
			section = &inConfig->m_Sections[i];
			break;
		}
	}
	if (!section)
	{
		section = &inConfig->m_Sections[inConfig->m_Sections.Add()];
		section->name = "autoexec";
	}

	// nuke the contents of the section
	section->commands.Purge(); section->commands.Shrink();

	// add commands for regular properties
	char buf[256];
	if (mAuthor.Len()) { sprintf(buf, "SetAuthor \"%s\"", *mAuthor); section->commands.AddItem(buf); }
	if (mDescription.Len()) { sprintf(buf, "SetDescription \"%s\"", *mDescription); section->commands.AddItem(buf); }
	sprintf(buf, "SetOrigin %f %f %f", mOrigin.x, mOrigin.y, mOrigin.z); section->commands.AddItem(buf);
	sprintf(buf, "SetScale %f %f %f", mScale.x, mScale.y, mScale.z); section->commands.AddItem(buf);
	sprintf(buf, "SetRotation %f %f %f", M_RADTODEG(mRotation.r), M_RADTODEG(mRotation.p), M_RADTODEG(mRotation.y)); section->commands.AddItem(buf);
	sprintf(buf, "SetBoundsMin %f %f %f", mBounds[0].x, mBounds[0].y, mBounds[0].z); section->commands.AddItem(buf);
	sprintf(buf, "SetBoundsMax %f %f %f", mBounds[1].x, mBounds[1].y, mBounds[1].z); section->commands.AddItem(buf);

	// add commands for used resources
	const NChar* path;
	if (mGeometry && (path = CPJ_GetChunkPath(configProject, mGeometry))) { sprintf(buf, "SetGeometry \"%s\"", path); section->commands.AddItem(buf); }
	if (mSkeleton && (path = CPJ_GetChunkPath(configProject, mSkeleton))) { sprintf(buf, "SetSkeleton \"%s\"", path); section->commands.AddItem(buf); }
	if (mLodData && (path = CPJ_GetChunkPath(configProject, mLodData))) { sprintf(buf, "SetLodData \"%s\"", path); section->commands.AddItem(buf); }
	for (i=0;i<mSurfaces.GetCount();i++)
	{
		if (mSurfaces[i] && (path = CPJ_GetChunkPath(configProject, mSurfaces[i]))) { sprintf(buf, "SetSurface %d \"%s\"", i, path); section->commands.AddItem(buf); }
	}

	// add commands for resources taken from search paths
	section->commands.AddItem(CCorString("AddFrames \"NULL\""));
	TCorArray<OCpjProject*> frmProjects;
	for (i=0;i<mFrames.GetCount();i++)
	{
		if (mFrames[i] && mFrames[i]->GetParent() && mFrames[i]->GetParent()->IsA(OCpjProject::GetStaticClass()))
			frmProjects.AddUnique((OCpjProject*)mFrames[i]->GetParent());
	}
	for (i=0;i<frmProjects.GetCount();i++)
	{
		if (frmProjects[i] == configProject)
			continue; // already have null in the search path
		if (path = CPJ_GetProjectPath(frmProjects[i]))
		{			
			for (NDword j=0;j<mFramesFiles.GetCount();j++)
			{
				if (!stricmp(*mFramesFiles[j], path))
				{
					path = NULL; // project is a known file, no need to add it
					break;
				}
			}
			if (!path)
				continue;

			char b1[256];
			strcpy(b1, STR_FilePath((NChar*)path));
			for (j=0;j<mFramesStarFiles.GetCount();j++)
			{
				char b2[256];
				strcpy(b2, STR_FilePath(*mFramesStarFiles[j]));
				if (!stricmp(b1, b2))
				{
					path = NULL; // project is part of a star path, no need to add it
					break;
				}
			}
			if (path)
			{
				sprintf(buf, "AddFrames \"%s\"", path);
				section->commands.AddItem(buf);
			}
		}
	}
	for (i=0;i<mFramesFiles.GetCount();i++)
	{
		if (configProject)
		{
			const NChar* path = CPJ_GetProjectPath(configProject);
			if (!stricmp(*mFramesFiles[i], path))
				continue;
		}
		sprintf(buf, "AddFrames \"%s\"", *mFramesFiles[i]);
		section->commands.AddItem(buf);
	}
	for (i=0;i<mFramesStarFiles.GetCount();i++)
	{
		sprintf(buf, "AddFrames \"%s\"", *mFramesStarFiles[i]);
		section->commands.AddItem(buf);
	}

	section->commands.AddItem(CCorString("AddSequences \"NULL\""));
	TCorArray<OCpjProject*> seqProjects;
	for (i=0;i<mSequences.GetCount();i++)
	{
		if (mSequences[i] && mSequences[i]->GetParent() && mSequences[i]->GetParent()->IsA(OCpjProject::GetStaticClass()))
			seqProjects.AddUnique((OCpjProject*)mSequences[i]->GetParent());
	}
	for (i=0;i<seqProjects.GetCount();i++)
	{
		if (seqProjects[i] == configProject)
			continue; // already have null in the search path
		if (path = CPJ_GetProjectPath(seqProjects[i]))
		{
			for (NDword j=0;j<mSequencesFiles.GetCount();j++)
			{
				if (!stricmp(*mSequencesFiles[j], path))
				{
					path = NULL; // project is a known file, no need to add it
					break;
				}
			}
			if (!path)
				continue;

			char b1[256];
			strcpy(b1, STR_FilePath((NChar*)path));
			for (j=0;j<mSequencesStarFiles.GetCount();j++)
			{
				char b2[256];
				strcpy(b2, STR_FilePath(*mSequencesStarFiles[j]));
				if (!stricmp(b1, b2))
				{
					path = NULL; // project is part of a star path, no need to add it
					break;
				}
			}
			if (path)
			{
				sprintf(buf, "AddSequences \"%s\"", path);
				section->commands.AddItem(buf);
			}
		}
	}
	for (i=0;i<mSequencesFiles.GetCount();i++)
	{
		if (configProject)
		{
			const NChar* path = CPJ_GetProjectPath(configProject);
			if (!stricmp(*mSequencesFiles[i], path))
				continue;
		}
		sprintf(buf, "AddSequences \"%s\"", *mSequencesFiles[i]);
		section->commands.AddItem(buf);
	}
	for (i=0;i<mSequencesStarFiles.GetCount();i++)
	{
		sprintf(buf, "AddSequences \"%s\"", *mSequencesStarFiles[i]);
		section->commands.AddItem(buf);
	}

	return(1);
}

CCpjLodLevel* OMacActor::GetLodInfo(NFloat inLodLevel)
{
	CCpjLodLevel* lodLevel = NULL;
	if (inLodLevel > 1.f) inLodLevel = 1.f;
	if (inLodLevel < 0.f) inLodLevel = 0.f;
	if (mLodData && (inLodLevel < 1.f))
	{
		NFloat lowestLevelValue = 1.1f;
		for (NDword i=0;i<mLodData->m_Levels.GetCount();i++)
		{
			CCpjLodLevel* lev = &mLodData->m_Levels[i];
			if ((lev->detail >= inLodLevel) && (lev->detail < lowestLevelValue))
			{
				lodLevel = lev;
				lowestLevelValue = lev->detail;
			}
		}
	}
	return(lodLevel);
}

NDword OMacActor::EvaluateTris(NFloat inLodLevel, SMacTri* outTriList)
{
	static int rot1[3] = {1,2,0};
	static int rot2[3] = {2,0,1};
	
	SMacTri* oT = outTriList;
	NDword outTriCount = 0;

	CCpjLodLevel* lodLevel = GetLodInfo(inLodLevel);

	for (NDword iSurf=0; iSurf<mSurfaces.GetCount(); iSurf++)
	{	
		OCpjSurface* surf = mSurfaces[iSurf];
		OCpjGeometry* geom = mGeometry;

		if (!geom || !surf || (surf->m_Tris.GetCount() != geom->m_Tris.GetCount()))
			continue; // geometry and surface are mismatched

		// once past the primary surface, ignore any LOD data we may have had
		if (iSurf)
			lodLevel = NULL;

		VVec2* surfUV = &surf->m_UV[0];
		CCpjSrfTex* surfTexs = NULL;
		if (surf->m_Textures.GetCount())
			surfTexs = &surf->m_Textures[0];

		if (!lodLevel)
		{
			CCpjSrfTri* iTS = &surf->m_Tris[0];
			CCpjGeoTri* iTG = &geom->m_Tris[0];
			CCpjGeoVert* gVZero = &geom->m_Verts[0];
			NDword triCount = surf->m_Tris.GetCount();
			outTriCount += triCount;
			if (!oT)
				continue;
			for (NDword i=0; i<triCount; i++,iTS++,iTG++,oT++)
			{
				oT->triIndex = i;
				oT->vertIndex[0] = iTG->edgeRing[0]->tailVertex - gVZero;
				oT->vertIndex[1] = iTG->edgeRing[1]->tailVertex - gVZero;
				oT->vertIndex[2] = iTG->edgeRing[2]->tailVertex - gVZero;
				oT->texture = NULL;
				oT->glazeTexture = NULL;
				if (!(iTS->flags & SRFTF_INACTIVE))
				{
					oT->texture = &surfTexs[iTS->texIndex];
					if (iTS->glazeFunc != SRFGLAZE_NONE)
						oT->glazeTexture = &surfTexs[iTS->glazeTexIndex];
				}
				oT->texUV[0] = &surfUV[iTS->uvIndex[0]];
				oT->texUV[1] = &surfUV[iTS->uvIndex[1]];
				oT->texUV[2] = &surfUV[iTS->uvIndex[2]];
				oT->surfaceFlags = iTS->flags;
				oT->smoothGroup = iTS->smoothGroup;
				oT->alphaLevel = iTS->alphaLevel;
				oT->glazeFunc = iTS->glazeFunc;
				oT->surfaceIndex = (NByte)iSurf;
			}
		}
		else
		{
			CCpjLodTri* iTL = &lodLevel->triangles[0];
			CCpjSrfTri* iTSZero = &surf->m_Tris[0];
			CCpjSrfTri* iTS;
			NDword triCount = lodLevel->triangles.GetCount();
			outTriCount += triCount;
			if (!oT)
				continue;
			for (NDword i=0; i<triCount; i++,iTL++,oT++)
			{
				iTS = &iTSZero[iTL->srfTriIndex];

				oT->triIndex = iTL->srfTriIndex;
				oT->vertIndex[0] = iTL->vertIndex[0];
				oT->vertIndex[1] = iTL->vertIndex[1];
				oT->vertIndex[2] = iTL->vertIndex[2];				
				oT->texture = NULL;
				oT->glazeTexture = NULL;
				if (!(iTS->flags & SRFTF_INACTIVE))
				{
					oT->texture = &surfTexs[iTS->texIndex];
					if (iTS->glazeFunc != SRFGLAZE_NONE)
						oT->glazeTexture = &surfTexs[iTS->glazeTexIndex];
				}
				oT->texUV[0] = &surfUV[iTL->uvIndex[0]];
				oT->texUV[1] = &surfUV[iTL->uvIndex[1]];
				oT->texUV[2] = &surfUV[iTL->uvIndex[2]];
				oT->surfaceFlags = iTS->flags;
				oT->smoothGroup = iTS->smoothGroup;
				oT->alphaLevel = iTS->alphaLevel;
				oT->glazeFunc = iTS->glazeFunc;
				oT->surfaceIndex = (NByte)iSurf;
			}
		}
	}
	return(outTriCount);
}

NDword OMacActor::EvaluateVerts(NFloat inLodLevel, NFloat inVertAlpha, VVec3* outVerts)
{
	if (!outVerts || !mGeometry)
		return(0); // kinda pointless if we have no verts to evaluate to

	// compute lod level info
	CCpjLodLevel* lodLevel = GetLodInfo(inLodLevel);
	NWord* lodRelay = NULL;
	NDword numVerts = mGeometry->m_Verts.GetCount();
	if (lodLevel)
	{
		if (!lodLevel->vertRelay.GetCount())
			return(0);
		lodRelay = &lodLevel->vertRelay[0];
		numVerts = lodLevel->vertRelay.GetCount();
	}

	// clamp the vertex alpha
	if (inVertAlpha < 0.f) inVertAlpha = 0.f;
	if (inVertAlpha > 1.f) inVertAlpha = 1.f;

	// set our working vertices as our temporary buffer, unless no alpha is involved
	VVec3* evalVerts = mac_tempVerts;
	if (inVertAlpha >= (1.f - M_EPSILON))
		evalVerts = outVerts;

	// the first sequence is the only one that's allowed to be frame-based
	NBool frameBased = 0;
	if (!mActorChannels[0] || !mActorChannels[0]->EvalVerts(this, numVerts, lodRelay, evalVerts))
	{
		if (mSkeleton)
		{
			if (bBonesDirty)		// JEP Added dirty bone optimization
			{
				// if we have a skeleton and verts weren't modified by the primary channel
				// (i.e. if a frame-based sequence wasn't used), then we can process all the channels
				// for bone-based animation / alteration
				for (NDword i=0;i<mActorChannels.GetCount();i++)
				{
					if (mActorChannels[i])
						mActorChannels[i]->EvalBones(this);
				}
			
				bBonesDirty = false;
			}

			// and after all that's done, we evaluate our vertex positions
			CCpjSklWeight* w;
			CMacBone* b;
			VVec3 nv;
			NDword wcount;
			VVec3* ov = evalVerts;
			CCpjSklVert* iv = &mSkeleton->m_Verts[0];
			CCpjSklBone* boneZero = &mSkeleton->m_Bones[0];

			if (lodRelay)
			{
				CCpjSklVert* xv;
				NDword count = numVerts;
				for (NDword i=0; i<count; i++,ov++)
				{
					*ov = VVec3(0,0,0);
					xv = &iv[lodRelay[i]];
					wcount = xv->weights.GetCount();
					w = &xv->weights[0];
					for (NDword j=0;j<wcount;j++,w++)
					{
						b = &mActorBones[w->bone - boneZero];
						*ov += (w->offsetPos << b->GetCoords(true)) * w->factor;
					}
				}
			}
			else
			{
				NDword count = mSkeleton->m_Verts.GetCount();
				for (NDword i=0; i<count; i++,ov++,iv++)
				{					
					wcount = iv->weights.GetCount();
					switch(wcount)
					{
					case 1:
						w = &iv->weights[0];
						b = &mActorBones[w->bone - boneZero];
						*ov = (w->offsetPos << b->GetCoords(true));// * w->factor;
						break;
					case 2:
						w = &iv->weights[0];
						b = &mActorBones[w->bone - boneZero];
						*ov = (w->offsetPos << b->GetCoords(true)) * w->factor;
						w++;
						b = &mActorBones[w->bone - boneZero];
						*ov += (w->offsetPos << b->GetCoords(true)) * w->factor;
						break;
					case 0:
						*ov = VVec3(0,0,0);
						break;
					default:
						*ov = VVec3(0,0,0);
						w = &iv->weights[0];
						for (NDword j=0;j<wcount;j++,w++)
						{
							b = &mActorBones[w->bone - boneZero];
							*ov += (w->offsetPos << b->GetCoords(true)) * w->factor;
						}
						break;
					}
				}
			}
		}
		else
		{
			// if we don't have a skeleton at all, and we didn't have vertex modification,
			// then we'll need some kind of data in here, so use the reference positions
			if (lodRelay)
			{
				NDword i;
				VVec3* ov;
				CCpjGeoVert* iv;
				NDword count = numVerts;
				for (i=0,ov=evalVerts,iv=&mGeometry->m_Verts[0]; i<count; i++,ov++)
					*ov = iv[lodRelay[i]].refPosition;
			}
			else
			{
				NDword i;
				VVec3* ov;
				CCpjGeoVert* iv;
				NDword count = numVerts;
				for (i=0,ov=evalVerts,iv=&mGeometry->m_Verts[0]; i<count; i++,ov++,iv++)
					*ov = iv->refPosition;
			}
		}
	}

	// process remaining channels for vertex modification
	for (NDword i=1;i<mActorChannels.GetCount();i++)
	{
		if (mActorChannels[i])
			mActorChannels[i]->EvalVerts(this, numVerts, lodRelay, evalVerts);
	}

	// build the output vertices from the final work vertices and the alpha, if required
	if (evalVerts != outVerts)
	{
		NDword i;
		VVec3* ov, *iv;
		NDword count = numVerts;
		for (i=0,ov=outVerts,iv=evalVerts; i<count; i++,ov++,iv++)
			*ov = (*iv * inVertAlpha) + (*ov * (1.f-inVertAlpha));
	}
	
	return(numVerts);
}

NBool OMacActor::EvaluateTriVerts(NDword inTriIndex, NFloat inVertAlpha, VVec3* outVerts)
{
	if (!outVerts || !mGeometry)
		return(0); // kinda pointless if we have no verts to evaluate to
	if (inTriIndex > mGeometry->m_Tris.GetCount())
		return(0);

	// build up a relay along the same lines as the LOD does, but specifically for the triangle
	NDword numVerts = 3;
	NWord triRelay[3];
	CCpjGeoVert* gVZero = &mGeometry->m_Verts[0];
	for (NDword iRelay=0;iRelay<3;iRelay++)
		triRelay[iRelay] = mGeometry->m_Tris[inTriIndex].edgeRing[iRelay]->tailVertex - gVZero;
	
	// clamp the vertex alpha
	if (inVertAlpha < 0.f) inVertAlpha = 0.f;
	if (inVertAlpha > 1.f) inVertAlpha = 1.f;

	// set our working vertices as our temporary buffer, unless no alpha is involved
	VVec3* evalVerts = mac_tempVerts;
	if (inVertAlpha >= (1.f - M_EPSILON))
		evalVerts = outVerts;

	// the first sequence is the only one that's allowed to be frame-based
	NBool frameBased = 0;
	if (!mActorChannels[0] || !mActorChannels[0]->EvalVerts(this, numVerts, triRelay, evalVerts))
	{
		if (mSkeleton)
		{
			if (bBonesDirty)		// JEP Added dirty bone optimization
			{
				// if we have a skeleton and verts weren't modified by the primary channel
				// (i.e. if a frame-based sequence wasn't used), then we can process all the channels
				// for bone-based animation / alteration			
				for (NDword i=0;i<mActorChannels.GetCount();i++)
				{
					if (mActorChannels[i])
						mActorChannels[i]->EvalBones(this);
				}

				bBonesDirty = false;
			}

			// and after all that's done, we evaluate our vertex positions
			CCpjSklWeight* w;
			CMacBone* b;
			VVec3 nv;
			NDword wcount;
			VVec3* ov = evalVerts;
			CCpjSklVert* iv = &mSkeleton->m_Verts[0];
			CCpjSklBone* boneZero = &mSkeleton->m_Bones[0];

			CCpjSklVert* xv;
			NDword count = numVerts;
			for (NDword i=0; i<count; i++,ov++)
			{
				*ov = VVec3(0,0,0);
				xv = &iv[triRelay[i]];
				wcount = xv->weights.GetCount();
				w = &xv->weights[0];
				for (NDword j=0;j<wcount;j++,w++)
				{
					b = &mActorBones[w->bone - boneZero];
					*ov += (w->offsetPos << b->GetCoords(true)) * w->factor;
				}
			}
		}
		else
		{
			// if we don't have a skeleton at all, and we didn't have vertex modification,
			// then we'll need some kind of data in here, so use the reference positions
			NDword i;
			VVec3* ov;
			CCpjGeoVert* iv;
			NDword count = numVerts;
			for (i=0,ov=evalVerts,iv=&mGeometry->m_Verts[0]; i<count; i++,ov++)
				*ov = iv[triRelay[i]].refPosition;
		}
	}

	// process remaining channels for vertex modification
	for (NDword i=1;i<mActorChannels.GetCount();i++)
	{
		if (mActorChannels[i])
			mActorChannels[i]->EvalVerts(this, numVerts, triRelay, evalVerts);
	}

	// build the output vertices from the final work vertices and the alpha, if required
	if (evalVerts != outVerts)
	{
		NDword i;
		VVec3* ov, *iv;
		NDword count = numVerts;
		for (i=0,ov=outVerts,iv=evalVerts; i<count; i++,ov++,iv++)
			*ov = (*iv * inVertAlpha) + (*ov * (1.f-inVertAlpha));
	}

	return(1);
}

static NBool RayTriIntersect(const VLine3& inRay, const VVec3& inV0, const VVec3& inV1, const VVec3& inV2, NFloat& outT, VVec3& outBarys)
{
	VVec3 e1 = inV1 - inV0;
	VVec3 e2 = inV2 - inV0;
	VVec3 p = inRay.v ^ e2;
	NFloat a = e1 | p;
	if (M_Fabs(a) < M_EPSILON)
		return(0);
	NFloat f = 1.f / a;
	VVec3 s = inRay.u - inV0;
	NFloat u = f * (s | p);
	if ((u < 0.f) || (u > 1.f))
		return(0);
	VVec3 q = s ^ e1;
	NFloat v = f * (inRay.v | q);
	if ((v < 0.f) || ((u+v) > 1.f))
		return(0);
	NFloat t = f * (e2 | q);
	
	outT = t;
	outBarys.x = 1.f - (u+v);
	outBarys.y = u;
	outBarys.z = v;
	return(1);
}

NBool OMacActor::TraceRay(NDword inNumTris, SMacTri* inTris, NDword inNumVerts, VVec3* inVerts,
						  const VLine3& inRay, NDword* outTri, NFloat* outDist, VVec3* outBarys, CCpjSklBone** outBone)
{
	if (!inTris || !inVerts)
		return(0);
	if (mGeometry && mSkeleton)
	{
		if ((!mTraceInfo) || (mTraceInfo->mTraceGeometry!=mGeometry) || (mTraceInfo->mTraceSkeleton!=mSkeleton))
			mTraceInfo = CMacTraceInfo::StaticFindInfo(this, mGeometry, mSkeleton);
	}
	NBool result = 0;	
	NFloat minDist = FLT_MAX;
	NDword minTri;
	VVec3 minBarys;

	static NBool boneFilter[256];
	if (mTraceInfo)
	{
		NDword count = mTraceInfo->mBoneBounds.GetCount();
		VBox3 box;
		for (NDword i=0;i<count;i++)
		{
			box = mTraceInfo->mBoneBounds[i];
			box.c <<= mActorBones[i].GetCoords(true);
			boneFilter[i] = box.Intersects(inRay, NULL, NULL);
		}
	}

	for (NDword i=0;i<inNumTris;i++)
	{
		if (mTraceInfo && !boneFilter[mTraceInfo->mTriBones[i]])
			continue; // bone wasn't collided with, so skip this tri
		
		SMacTri* tri = &inTris[i];
		if (tri->surfaceFlags & SRFTF_NONCOLLIDE) // !BR Trace through this tri.
			continue;
		VVec3 v[3];
		for (NDword j=0;j<3;j++)
			v[j] = inVerts[tri->vertIndex[j]];
		NFloat t;
		VVec3 barys;
		if (RayTriIntersect(inRay, v[0], v[1], v[2], t, barys))
		{
			if ((t >= 0.f) && (t < minDist))
			{
				result = 1;
				minDist = t;
				minTri = i;
				minBarys = barys;
			}
		}
	}
	if (result)
	{
		if (outTri) *outTri = minTri;
		if (outDist) *outDist = minDist;
		if (outBarys) *outBarys = minBarys;
		if (outBone)
		{
			*outBone = NULL;
			if ((mTraceInfo) && (mTraceInfo->mTriBones[minTri]!=255))
				*outBone = &mSkeleton->m_Bones[mTraceInfo->mTriBones[minTri]];
		}
	}
	return(result);
}

NBool OMacActor::RemoveReferencesTo(OCpjChunk* inChunk)
{
	if (!inChunk)
		return(0);
	if ((inChunk->IsA(OCpjGeometry::GetStaticClass())) && (mGeometry == (OCpjGeometry*)inChunk))
	{
		SetGeometry(NULL);
		return(1);
	}
	if ((inChunk->IsA(OCpjSkeleton::GetStaticClass())) && (mSkeleton == (OCpjSkeleton*)inChunk))
	{
		SetSkeleton(NULL);
		return(1);
	}
	if ((inChunk->IsA(OCpjLodData::GetStaticClass())) && (mLodData == (OCpjLodData*)inChunk))
	{
		SetLodData(NULL);
		return(1);
	}
	if (inChunk->IsA(OCpjSurface::GetStaticClass()))
	{
		for (NDword i=0;i<mSurfaces.GetCount();i++)
		{
			if (mSurfaces[i] == (OCpjSurface*)inChunk)
			{
				SetSurface(i, NULL);
				return(1);
			}
		}
	}
	if (inChunk->IsA(OCpjFrames::GetStaticClass()))
	{
		for (NDword i=0;i<mFrames.GetCount();i++)
		{
			if (mFrames[i] == (OCpjFrames*)inChunk)
			{
				mFrames[i] = NULL;
				return(1);
			}
		}
	}
	if (inChunk->IsA(OCpjSequence::GetStaticClass()))
	{
		for (NDword i=0;i<mSequences.GetCount();i++)
		{
			if (mSequences[i] == (OCpjSequence*)inChunk)
			{
				mSequences[i] = NULL;
				return(1);
			}
		}
	}
	return(0);
}
NBool OMacActor::RemoveAllReferencesTo(OCpjChunk* inChunk)
{
	for (CMacActorLink* link = CMacActorLink::GetFirst(); !link->IsDone(); link = link->GetNext())
	{
		if (link->GetActor())
			link->GetActor()->RemoveReferencesTo(inChunk);
	}
	return(1);
}

/*
	OMacChannel
*/
OBJ_CLASS_IMPLEMENTATION(OMacChannel, OObject, 0);

/*
	OMacSequenceChannel
*/
OBJ_CLASS_IMPLEMENTATION(OMacSequenceChannel, OMacChannel, 0);

NBool OMacSequenceChannel::EvalBones(OMacActor* inActor)
{
	NDword i;
	
	if (!mSequence || !inActor || !inActor->mSkeleton)
		return(0);

	NFloat frameF = mTime * mSequence->m_Frames.GetCount();
	NDword frameI = (NDword)frameF;
	NFloat frameAlpha = frameF - frameI;
	CCpjSeqFrame* frm[2];
	frm[0] = &mSequence->m_Frames[frameI % mSequence->m_Frames.GetCount()];
	frm[1] = &mSequence->m_Frames[(frameI+1) % mSequence->m_Frames.GetCount()];

	if (frm[0]->vertFrameName.Len() || frm[1]->vertFrameName.Len())
		return(0); // frame-based frames, ignore

	static VCoords3 frmCoords[2][256], frmDeltaCoords[2][256];
	static NBool bonesUsed[256];

	// initialize all bone transforms based on blend mode
	switch(mBlendMode)
	{
	case MACSEQBLEND_SET:
		{
			for (i=0;i<inActor->mActorBones.GetCount();i++)
			{
				frmCoords[0][i] = frmCoords[1][i] = inActor->mActorBones[i].mSklBone->baseCoords; // use base transforms
				frmDeltaCoords[0][i] = frmDeltaCoords[1][i] = VCoords3();
				bonesUsed[i] = 0;
			}
		}
		break;
	case MACSEQBLEND_ADD:
		{
			for (i=0;i<inActor->mActorBones.GetCount();i++)
			{
				frmCoords[0][i] = frmCoords[1][i] = inActor->mActorBones[i].GetCoords(false); // use current transforms
				frmDeltaCoords[0][i] = frmDeltaCoords[1][i] = VCoords3();
				bonesUsed[i] = 0;
			}
		}
		break;
	}
	
	// map bone information from sequence
	static CMacBone* boneMap[256];
	for (i=0;i<mSequence->m_BoneInfo.GetCount();i++)
		boneMap[i] = inActor->FindBone(*mSequence->m_BoneInfo[i].name);

	// run through keyframe bone information and build up structure-relative transforms
	CMacBone* bone;
	NDword index;
	for (NDword ifrm=0;ifrm<2;ifrm++)
	{
		for (i=0;i<frm[ifrm]->translates.GetCount();i++)
		{				
			//bone = inActor->FindBone(*mSequence->m_BoneInfo[frm[ifrm]->translates[i].boneIndex].name);
			bone = boneMap[frm[ifrm]->translates[i].boneIndex];
			if (!bone)
				continue;
			index = bone - &inActor->mActorBones[0];
			bonesUsed[index] = 1;
			frmDeltaCoords[ifrm][index].t = frm[ifrm]->translates[i].translate;
/*
			NFloat desiredLength = mSequence->m_BoneInfo[frm[ifrm]->translates[i].boneIndex].srcLength;
			NFloat actualLength = bone->mSklBone->length;
			NFloat lengthScale = actualLength / desiredLength;
			frmDeltaCoords[ifrm][index].t /= lengthScale;
*/
		}
		for (i=0;i<frm[ifrm]->scales.GetCount();i++)
		{
			//bone = inActor->FindBone(*mSequence->m_BoneInfo[frm[ifrm]->scales[i].boneIndex].name);
			bone = boneMap[frm[ifrm]->scales[i].boneIndex];
			if (!bone)
				continue;
			index = bone - &inActor->mActorBones[0];
			bonesUsed[index] = 1;
			frmDeltaCoords[ifrm][index].s = frm[ifrm]->scales[i].scale;
		}
		for (i=0;i<frm[ifrm]->rotates.GetCount();i++)
		{
			//bone = inActor->FindBone(*mSequence->m_BoneInfo[frm[ifrm]->rotates[i].boneIndex].name);
			bone = boneMap[frm[ifrm]->rotates[i].boneIndex];
			if (!bone)
				continue;
			index = bone - &inActor->mActorBones[0];
			bonesUsed[index] = 1;
#if 0
			VQuat3 q;
			q.AxisAngle(VVec3(0,0,1), (float)frm[ifrm]->rotates[i].roll * M_PI / 32768.f); frmDeltaCoords[ifrm][index].r >>= q;
			q.AxisAngle(VVec3(1,0,0), (float)frm[ifrm]->rotates[i].pitch * M_PI / 32768.f); frmDeltaCoords[ifrm][index].r >>= q;
			q.AxisAngle(VVec3(0,1,0), (float)frm[ifrm]->rotates[i].yaw * M_PI / 32768.f); frmDeltaCoords[ifrm][index].r >>= q;
#else
#ifdef CPJ_SEQ_NOQUATOPT			
			VEulers3 eulers;
			eulers.r = (float)frm[ifrm]->rotates[i].roll * M_PI / 32768.f;
			eulers.p = (float)frm[ifrm]->rotates[i].pitch * M_PI / 32768.f;
			eulers.y = (float)frm[ifrm]->rotates[i].yaw * M_PI / 32768.f;
			frmDeltaCoords[ifrm][index].r >>= (~eulers);
#else			
			frmDeltaCoords[ifrm][index].r >>= frm[ifrm]->rotates[i].quat;
#endif // CPJ_SEQ_NOQUATOPT
#endif // if 0
/*
			NFloat desiredLength = mSequence->m_BoneInfo[frm[ifrm]->rotates[i].boneIndex].srcLength;
			NFloat actualLength = bone->mSklBone->length;
			NFloat lengthScale = actualLength / desiredLength;
			q = VQuat3();
			if (lengthScale < 1.f)
				q.Slerp(VQuat3(VAxes3()), VQuat3(frmDeltaCoords[ifrm][index].r), 1.f-lengthScale, lengthScale, false);
			else
				q.Slerp(VQuat3(VAxes3()), VQuat3(frmDeltaCoords[ifrm][index].r), 0.f, lengthScale, false);
			frmDeltaCoords[ifrm][index].r = q;
*/
		}
	}

	// extract skeleton relative transformations
	for (ifrm=0;ifrm<2;ifrm++)
	{
		for (i=0;i<inActor->mActorBones.GetCount();i++)
		{
			if (bonesUsed[i])
				frmCoords[ifrm][i] = frmDeltaCoords[ifrm][i] << frmCoords[ifrm][i];
		}
	}

	// interpolate to generate new bone state
	VCoords3 srcC, destC, finalC;
	VQuat3 srcQ, finalQ;
	for (i=0;i<inActor->mActorBones.GetCount();i++)
	{
		if (!bonesUsed[i])
			continue;

		srcC.t = frmCoords[0][i].t + (frmCoords[1][i].t - frmCoords[0][i].t)*frameAlpha;
		srcC.s = frmCoords[0][i].s + (frmCoords[1][i].s - frmCoords[0][i].s)*frameAlpha;
		srcQ.Slerp(VQuat3(frmCoords[0][i].r), VQuat3(frmCoords[1][i].r), 1.f-frameAlpha, frameAlpha, false);

		if (mBlendAlpha >= 1.f)
		{
			srcC.r = srcQ;
			inActor->mActorBones[i].SetCoords(srcC, false);
		}
		else
		{
			destC = inActor->mActorBones[i].GetCoords(false);

			finalC = destC;
			//finalC.t = destC.t;
			finalC.t = srcC.t*mBlendAlpha + destC.t*(1.f-mBlendAlpha);
			//finalC.s = destC.s;
			finalC.s = srcC.s*mBlendAlpha + destC.s*(1.f-mBlendAlpha);
			finalQ.Slerp(VQuat3(destC.r), srcQ, 1.f-mBlendAlpha, mBlendAlpha, false);
			finalC.r = finalQ;
			
			inActor->mActorBones[i].SetCoords(finalC, false);
		}
	}
	
	return(1);
}
NBool OMacSequenceChannel::EvalVerts(OMacActor* inActor, NDword inNumVerts, NWord* inVertRelay, VVec3* ioVerts)
{
	if (!mSequence || !mSequence->m_Frames.GetCount() || !inActor)
		return(0);

	NFloat frameF = mTime * mSequence->m_Frames.GetCount();
	NDword frameI = (NDword)frameF;
	NFloat frameAlpha = frameF - frameI;
	NFloat omframeAlpha = 1.f - frameAlpha;
	CCpjSeqFrame* sfrm[2];
	sfrm[0] = &mSequence->m_Frames[frameI % mSequence->m_Frames.GetCount()];
	sfrm[1] = &mSequence->m_Frames[(frameI+1) % mSequence->m_Frames.GetCount()];

	if (!sfrm[0]->vertFrameName.Len() && !sfrm[1]->vertFrameName.Len())
		return(0); // bone-based frames, ignore

	// make sure both frames are valid, by duplicating the frame if one is empty
	if (sfrm[0]->vertFrameName.Len() && !sfrm[1]->vertFrameName.Len())
		sfrm[1] = sfrm[0];
	else if (!sfrm[0]->vertFrameName.Len() && sfrm[1]->vertFrameName.Len())
		sfrm[0] = sfrm[1];

	CCpjFrmFrame* frm[2];
	frm[0] = inActor->FindFrame(*sfrm[0]->vertFrameName);
	frm[1] = inActor->FindFrame(*sfrm[1]->vertFrameName);

	if (!frm[0] && !frm[1])
		return(0); // neither frame was found, skip out

	// one again make sure both frames are valid
	if (frm[0] && !frm[1]) frm[1] = frm[0];
	else if (!frm[0] && frm[1]) frm[0] = frm[1];

	// set the relay
	static NWord defaultRelay[2048];
	static NBool defaultRelayInitialized = 0;
	if (!defaultRelayInitialized)
	{
		for (NDword i=0;i<2048;i++)
			defaultRelay[i] = (NWord)i;
		defaultRelayInitialized = 1;
	}
	if (!inVertRelay)
		inVertRelay = defaultRelay;

	// build the verts
	NDword i;
	NDword count = inNumVerts;//frm[0]->GetNumPositions();
	VVec3* oV = ioVerts;
	NWord* iR = inVertRelay;

#if 1
	NDword loopFlags = 0;
	if (frm[0]->m_isCompressed) loopFlags |= 1;
	if (frm[1]->m_isCompressed) loopFlags |= 2;
	if (mBlendAlpha < 1.f) loopFlags |= 4;

	CCpjFrmBytePos* frm0Byte, *frm1Byte, *tempByte;
	VVec3* frm0Pure, *frm1Pure;
	CCpjFrmGroup* byteGroup, *frm0Group, *frm1Group;
	NFloat omBlendAlpha = 1.f - mBlendAlpha;
	VVec3 vA, vB;

	switch(loopFlags)
	{
	case 0: // uncompressed, uncompressed, no blend
		frm0Pure = &frm[0]->m_PurePos[0];
		frm1Pure = &frm[1]->m_PurePos[0];
		for (i=0; i<count; i++,oV++)
			*oV = (frm1Pure[iR[i]]*frameAlpha) + (frm0Pure[iR[i]]*omframeAlpha);
		break;
	case 1: // compressed, uncompressed, no blend
		frm0Byte = &frm[0]->m_BytePos[0];
		frm1Pure = &frm[1]->m_PurePos[0];
		frm0Group = &frm[0]->m_Groups[0];
		for (i=0; i<count; i++,oV++)
		{
			tempByte = &frm0Byte[iR[i]];
			byteGroup = &frm0Group[tempByte->group];
			vA.x = ((NFloat)tempByte->pos[0] * byteGroup->scale.x) + byteGroup->translate.x;
			vA.y = ((NFloat)tempByte->pos[1] * byteGroup->scale.y) + byteGroup->translate.y;
			vA.z = ((NFloat)tempByte->pos[2] * byteGroup->scale.z) + byteGroup->translate.z;

			*oV = (frm1Pure[iR[i]]*frameAlpha) + (vA*omframeAlpha);
		}
		break;
	case 2: // uncompressed, compressed, no blend
		frm0Pure = &frm[0]->m_PurePos[0];
		frm1Byte = &frm[1]->m_BytePos[0];
		frm1Group = &frm[1]->m_Groups[0];
		for (i=0; i<count; i++,oV++)
		{
			tempByte = &frm1Byte[iR[i]];
			byteGroup = &frm1Group[tempByte->group];
			vB.x = ((NFloat)tempByte->pos[0] * byteGroup->scale.x) + byteGroup->translate.x;
			vB.y = ((NFloat)tempByte->pos[1] * byteGroup->scale.y) + byteGroup->translate.y;
			vB.z = ((NFloat)tempByte->pos[2] * byteGroup->scale.z) + byteGroup->translate.z;

			*oV = (vB*frameAlpha) + (frm0Pure[iR[i]]*omframeAlpha);
		}
		break;
	case 3: // compressed, compressed, no blend
		frm0Byte = &frm[0]->m_BytePos[0];
		frm1Byte = &frm[1]->m_BytePos[0];
		frm0Group = &frm[0]->m_Groups[0];
		frm1Group = &frm[1]->m_Groups[0];
		for (i=0; i<count; i++,oV++)
		{
			tempByte = &frm0Byte[iR[i]];
			byteGroup = &frm0Group[tempByte->group];
			vA.x = ((NFloat)tempByte->pos[0] * byteGroup->scale.x) + byteGroup->translate.x;
			vA.y = ((NFloat)tempByte->pos[1] * byteGroup->scale.y) + byteGroup->translate.y;
			vA.z = ((NFloat)tempByte->pos[2] * byteGroup->scale.z) + byteGroup->translate.z;

			tempByte = &frm1Byte[iR[i]];
			byteGroup = &frm1Group[tempByte->group];
			vB.x = ((NFloat)tempByte->pos[0] * byteGroup->scale.x) + byteGroup->translate.x;
			vB.y = ((NFloat)tempByte->pos[1] * byteGroup->scale.y) + byteGroup->translate.y;
			vB.z = ((NFloat)tempByte->pos[2] * byteGroup->scale.z) + byteGroup->translate.z;

			*oV = (vB*frameAlpha) + (vA*omframeAlpha);
		}
		break;
	case 4: // uncompressed, uncompressed, blend
		frm0Pure = &frm[0]->m_PurePos[0];
		frm1Pure = &frm[1]->m_PurePos[0];
		for (i=0; i<count; i++,oV++)
			*oV = (((frm1Pure[iR[i]]*frameAlpha) + (frm0Pure[iR[i]]*omframeAlpha)) * mBlendAlpha) + (*oV * omBlendAlpha);
		break;
	case 5: // compressed, uncompressed, blend
		frm0Byte = &frm[0]->m_BytePos[0];
		frm1Pure = &frm[1]->m_PurePos[0];
		frm0Group = &frm[0]->m_Groups[0];
		for (i=0; i<count; i++,oV++)
		{
			tempByte = &frm0Byte[iR[i]];
			byteGroup = &frm0Group[tempByte->group];
			vA.x = ((NFloat)tempByte->pos[0] * byteGroup->scale.x) + byteGroup->translate.x;
			vA.y = ((NFloat)tempByte->pos[1] * byteGroup->scale.y) + byteGroup->translate.y;
			vA.z = ((NFloat)tempByte->pos[2] * byteGroup->scale.z) + byteGroup->translate.z;

			*oV = (((frm1Pure[iR[i]]*frameAlpha) + (vA*omframeAlpha)) * mBlendAlpha) + (*oV * omBlendAlpha);
		}
		break;
	case 6: // uncompressed, compressed, blend
		frm0Pure = &frm[0]->m_PurePos[0];
		frm1Byte = &frm[1]->m_BytePos[0];
		frm1Group = &frm[1]->m_Groups[0];
		for (i=0; i<count; i++,oV++)
		{
			tempByte = &frm1Byte[iR[i]];
			byteGroup = &frm1Group[tempByte->group];
			vB.x = ((NFloat)tempByte->pos[0] * byteGroup->scale.x) + byteGroup->translate.x;
			vB.y = ((NFloat)tempByte->pos[1] * byteGroup->scale.y) + byteGroup->translate.y;
			vB.z = ((NFloat)tempByte->pos[2] * byteGroup->scale.z) + byteGroup->translate.z;

			*oV = (((vB*frameAlpha) + (frm0Pure[iR[i]]*omframeAlpha)) * mBlendAlpha) + (*oV * omBlendAlpha);
		}
		break;
	case 7: // compressed, compressed, blend
		frm0Byte = &frm[0]->m_BytePos[0];
		frm1Byte = &frm[1]->m_BytePos[0];
		frm0Group = &frm[0]->m_Groups[0];
		frm1Group = &frm[1]->m_Groups[0];
		for (i=0; i<count; i++,oV++)
		{
			tempByte = &frm0Byte[iR[i]];
			byteGroup = &frm0Group[tempByte->group];
			vA.x = ((NFloat)tempByte->pos[0] * byteGroup->scale.x) + byteGroup->translate.x;
			vA.y = ((NFloat)tempByte->pos[1] * byteGroup->scale.y) + byteGroup->translate.y;
			vA.z = ((NFloat)tempByte->pos[2] * byteGroup->scale.z) + byteGroup->translate.z;

			tempByte = &frm1Byte[iR[i]];
			byteGroup = &frm1Group[tempByte->group];
			vB.x = ((NFloat)tempByte->pos[0] * byteGroup->scale.x) + byteGroup->translate.x;
			vB.y = ((NFloat)tempByte->pos[1] * byteGroup->scale.y) + byteGroup->translate.y;
			vB.z = ((NFloat)tempByte->pos[2] * byteGroup->scale.z) + byteGroup->translate.z;

			*oV = (((vB*frameAlpha) + (vA*omframeAlpha)) * mBlendAlpha) + (*oV * omBlendAlpha);
		}
		break;	
	}
#else
	if (mBlendAlpha >= 1.f)
	{
		for (i=0; i<count; i++,oV++)//,iE++)
		{
			//if (!(*iE))
			//	continue;
			*oV = (frm[1]->GetPosition(i)*frameAlpha) + (frm[0]->GetPosition(i)*(1.f-frameAlpha));
		}
	}
	else
	{
		for (i=0; i<count; i++,oV++)//,iE++)
		{
			//if (!(*iE))
			//	continue;
			*oV = (((frm[1]->GetPosition(i)*frameAlpha) + (frm[0]->GetPosition(i)*(1.f-frameAlpha))) * mBlendAlpha) + (*oV * (1.f-mBlendAlpha));
		}
	}
#endif // #if 1

	return(1);
}

/*
	OMacIKChannel
*/
OBJ_CLASS_IMPLEMENTATION(OMacIKChannel, OMacChannel, 0);

NBool OMacIKChannel::EvalBones(OMacActor* inActor)
{
	if (!inActor || !mGoalBone)
		return(0);

	CMacBone* firstBone = mChildLimit ? mChildLimit : mGoalBone;
	CMacBone* lastBone = mParentLimit;

	for (CMacBone* curBone = firstBone; curBone; curBone = curBone->mParent)
	{
		VVec3 offsetPos = mGoalBoneOffset;
		if (offsetPos.Length() < M_EPSILON)
			offsetPos = VVec3(0.f,0.f,0.1f);

		VCoords3 gbc = mGoalBone->GetCoords(true);
		VCoords3 cbc = curBone->GetCoords(true);
		VVec3 pc = offsetPos << gbc;
		VVec3 pd = mGoalPosition;
		VAxes3 uc = gbc.r;
		VAxes3 ud = mGoalRotation;
		VVec3 base = cbc.t;

		if ((pc & pd) < M_EPSILON)
			return(1); // already there man

		VVec3 npic = pc - base;
		NFloat lpic = npic.Normalize();
		VVec3 npid = pd - base;
		NFloat lpid = npid.Normalize();
		VVec3 raxis = npic ^ npid; raxis.Normalize();

		NFloat a = 1;
		NFloat p;
		if (lpic < lpid)
			p = lpic / lpid;
		else
			p = lpid / lpic;
				
		NFloat wv = 1.f;
		NFloat wp = a*(1.f+p);

		NFloat k1 = wp*(npid|raxis)*(npic|raxis) + wv*(((ud.vX|raxis)*(uc.vX|raxis))+((ud.vY|raxis)*(uc.vY|raxis))+((ud.vZ|raxis)*(uc.vZ|raxis)));
		NFloat k2 = wp*(npid|npic) + wv*((ud.vX|uc.vX)+(ud.vY|uc.vY)+(ud.vZ|uc.vZ));
		NFloat k3 = raxis | ( (npic^npid)*wp + ((ud.vX^uc.vX)+(ud.vY^uc.vY)+(ud.vZ^uc.vZ))*wv );

		NFloat cand1 = (NFloat)atan(k3 / (k2 - k1));
		NFloat cand2 = cand1 + M_PI;
		NFloat cand3 = cand1 - M_PI;
		NFloat phi = 0.f;
		NFloat goalmax=-FLT_MAX;
		NFloat tgoal;
		if ( (cand1 > -M_PI) && (cand1 < M_PI) && (tgoal = ((k1*(1.0 - cos(cand1)) + k2*cos(cand1) + k3*sin(cand1))) > goalmax) )
		{ phi = cand1; goalmax = tgoal; }
		if ( (cand2 > -M_PI) && (cand2 < M_PI) && (tgoal = ((k1*(1.0 - cos(cand2)) + k2*cos(cand2) + k3*sin(cand2))) > goalmax) )
		{ phi = cand2; goalmax = tgoal; }
		if ( (cand3 > -M_PI) && (cand3 < M_PI) && (tgoal = ((k1*(1.0 - cos(cand3)) + k2*cos(cand3) + k3*sin(cand3))) > goalmax) )
		{ phi = cand3; goalmax = tgoal; }

		phi *= mRigidity;
		VQuat3 q; q.AxisAngle(raxis, phi);
		cbc.r >>= q;
		curBone->SetCoords(cbc, true);

		//ProcessConstraints(inCurBone);
	}

	return(1);
}

/*
	CMacTraceInfo
*/
TCorArray<CMacTraceInfo> CMacTraceInfo::sTraceInfoList;

CMacTraceInfo* CMacTraceInfo::StaticFindInfo(OMacActor* inActor, OCpjGeometry* inGeo, OCpjSkeleton* inSkl)
{
	if (!inGeo || !inSkl)
		return(NULL);

	CMacTraceInfo* ti;
	for (NDword i=0;i<sTraceInfoList.GetCount();i++)
	{
		ti = &sTraceInfoList[i];
		if ((inGeo == ti->mTraceGeometry)
		 && (inSkl == ti->mTraceSkeleton))
			return(ti);
	}
	ti = &sTraceInfoList[sTraceInfoList.Add()];
	ti->mTraceGeometry = inGeo;
	ti->mTraceSkeleton = inSkl;
	ti->Construct(inActor);
	return(ti);
}

void CMacTraceInfo::Construct(OMacActor* inActor)
{
	mTriBones.Purge(); mTriBones.Shrink();

	mTraceGeometry->CacheIn();
	mTraceSkeleton->CacheIn();

	// pick the bones that has the most influence on each triangle
	mTriBones.Add(mTraceGeometry->m_Tris.GetCount());
	static NFloat influence[256];
	CCpjSklVert* sklVerts = &mTraceSkeleton->m_Verts[0];
	CCpjGeoTri* geoTris = &mTraceGeometry->m_Tris[0];
	CCpjGeoVert* gvZero = &mTraceGeometry->m_Verts[0];
	CCpjSklBone* sbZero = &mTraceSkeleton->m_Bones[0];
	NDword wCount;
	CCpjSklWeight* w;
	for (NDword i=0;i<mTriBones.GetCount();i++)
	{
		memset(influence, 0, 256*sizeof(NFloat));
		for (NDword j=0;j<3;j++)
		{
			CCpjSklVert* v = &sklVerts[geoTris[i].edgeRing[j]->tailVertex - gvZero];
			wCount = v->weights.GetCount();
			w = &v->weights[0];
			for (NDword k=0;k<wCount;k++,w++)
				influence[w->bone - sbZero] += w->factor;
		}			
		NFloat maxInfluence = 0.f;
		NByte maxBone = 255;
		for (j=0;j<mTraceSkeleton->m_Bones.GetCount();j++)
		{
			if (influence[j] > maxInfluence)
			{
				maxInfluence = influence[j];
				maxBone = (NByte)j;
			}
		}
		mTriBones[i] = maxBone;
	}

	// create the bone bounds based on default vert positions
	TCorArray<OMacChannel*> channelBackup = inActor->mActorChannels;
	inActor->mActorChannels.Purge(); inActor->mActorChannels.Shrink();
	inActor->mActorChannels.AddZeroed(MAC_NUMCHANNELS);
	TCorArray<VVec3> tempVerts(mTraceGeometry->m_Verts.GetCount());
	NDword numVerts = inActor->EvaluateVerts(1.f, 1.f, &tempVerts[0]);
	
	static VVec3 boneMin[256], boneMax[256];
	static NBool boneUsed[256];
	mBoneBounds.Add(mTraceSkeleton->m_Bones.GetCount());
	for (i=0;i<mBoneBounds.GetCount();i++)
	{
		boneMin[i] = VVec3(FLT_MAX,FLT_MAX,FLT_MAX);
		boneMax[i] = VVec3(-FLT_MAX,-FLT_MAX,-FLT_MAX);
		boneUsed[i] = 0;
	}
	for (i=0;i<mTriBones.GetCount();i++)
	{
		for (NDword j=0;j<3;j++)
		{
			VVec3* v = &tempVerts[geoTris[i].edgeRing[j]->tailVertex - gvZero];
			VVec3* vMin = &boneMin[mTriBones[i]];
			VVec3* vMax = &boneMax[mTriBones[i]];
			if (v->x < vMin->x) vMin->x = v->x;
			if (v->y < vMin->y) vMin->y = v->y;
			if (v->z < vMin->z) vMin->z = v->z;
			if (v->x > vMax->x) vMax->x = v->x;
			if (v->y > vMax->y) vMax->y = v->y;
			if (v->z > vMax->z) vMax->z = v->z;
			boneUsed[mTriBones[i]] = 1;
		}
	}
	for (i=0;i<mBoneBounds.GetCount();i++)
	{
		if (boneUsed[i])
		{
			mBoneBounds[i] = VBox3(boneMin[i], boneMax[i]);
			VCoords3 boneCoords = inActor->mActorBones[i].GetCoords(true);
			mBoneBounds[i].c >>= boneCoords;
		}
		else
			mBoneBounds[i] = VBox3(VVec3(-0.5f,-0.5f,-0.5f), VVec3(0.5f,0.5f,0.5f));

		//LOG_Logf("PostBone %d: pos (%f,%f,%f) dim (%f,%f,%f)", i, mBoneBounds[i].c.t.x, mBoneBounds[i].c.t.y, mBoneBounds[i].c.t.z,
		//	mBoneBounds[i].c.s.x, mBoneBounds[i].c.s.y, mBoneBounds[i].c.s.z);
	}

	inActor->mActorChannels = channelBackup;
}

//****************************************************************************
//**
//**    END MODULE MACMAIN.CPP
//**
//****************************************************************************

