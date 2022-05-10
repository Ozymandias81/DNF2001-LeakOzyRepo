//****************************************************************************
//**
//**    IMPC3S.CPP
//**    C3S Files
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "PlgMain.h"
#include "CpjFmt.h"

//#define CBLTK_STATICLIB
#define CBLTK_NOPLACEMENTNEW
#include ".\c3stk\c3stk.h"
#pragma comment(lib, ".\\c3stk\\release\\c3stk.lib")

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class __declspec(dllexport) OCpjImporterC3S
: public OCpjImporter
{
    OBJ_CLASS_DEFINE(OCpjImporterC3S, OCpjImporter);

	// OCpjImporter
	CObjClass* GetImportClass() { return(OCpjProject::GetStaticClass()); }
    NChar* GetFileExtension() { return("c3s"); }
    NChar* GetFileDescription() { return("Old Cannibal C3S File"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImporterC3S, OCpjImporter, 0);

class CImpPlugin
: public IPlgPlugin
{
public:
	// IPlgPlugin
	bool Create() { return(1); }
	bool Destroy() { return(1); }
    char* GetTitle() { return("Cannibal C3S Model Importer"); }
	char* GetDescription() { return("No description"); }
	char* GetAuthor() { return("3D Realms Entertainment"); }
	float GetVersion() { return(1.0f); }
};

//============================================================================
//    PRIVATE DATA
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
static CImpPlugin imp_Plugin;

//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static vgframe3 EulersToFrame(const vgvec3& inEulers)
{
	vgframe3 outFrame;

	outFrame >>= vgquat3(vgrotax3(vgvec3(0,0,1), inEulers.z));
	outFrame >>= vgquat3(vgrotax3(vgvec3(1,0,0), inEulers.x));
	outFrame >>= vgquat3(vgrotax3(vgvec3(0,1,0), inEulers.y));

	return(outFrame);
}

// output vector is actually pitch, yaw, roll
// order applied to reconstruct frame is roll, then pitch, then yaw
// assumes frame from object's POV is X=vLeft, Y=vUp, Z=vForward
static vgvec3 FrameToEulers(const vgframe3& inFrame)
{
	vgvec3 outEulers;

	// pitch is extrapolated from the Z axis, based on its two-dimensional
	// length in the ZX plane, and its Y value
	vgvec2 pitchTemp(inFrame.vZ.z, inFrame.vZ.x);
	outEulers.x = -atan2(inFrame.vZ.y, pitchTemp.Length());

	// yaw is extrapolated from the Z axis as well, based simply on its two-dimensional aspect
	// if the pitch is completely vertical, then this value should be forced to zero since the
	// yaw is indeterminate in such as case
	outEulers.y = 0.0;
	if (VG_Fabs(inFrame.vZ | vgvec3(0,1,0)) < 0.9997)
		outEulers.y = atan2(inFrame.vZ.x, inFrame.vZ.z);

	// roll is the tricky one.  Do the lame method for now by generating a frame
	// from the roll-less eulers, and checking the axis difference
	outEulers.z = 0.0;
	vgframe3 f = EulersToFrame(outEulers);
	outEulers.z = -atan2(inFrame.vY | f.vX, inFrame.vX | f.vX);

	return(outEulers);
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
NBool OCpjImporterC3S::Import(OObject* inRes, NChar* inFileName, NChar* outError)
{	
	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
	OCpjProject* prj = (OCpjProject*)inRes;

	CBL_Init();
	CBLScene* scene = new CBLScene;
	if (!scene->LoadFile(inFileName))
	{
		sprintf(outError, "Could not open file \"%s\"", inFileName);
		delete scene;
		CBL_Shutdown();
		return(0);
	}
	if (!scene->GetModels().GetCount())
	{
		strcpy(outError, "Scene has no models");
		delete scene;
		CBL_Shutdown();
		return(0);
	}
	CBLModel* model = scene->GetModels()[0];
	CBLEntity* entity = new CBLEntity(model);
	entity->AddSeqFrame(NULL, 0.0, true);
	entity->AddSeqFrame(NULL, 0.0, false);

	// remove old data
	for (TObjIter<OCpjChunk> iter(prj); iter; iter++)
		iter->Destroy();

	OCpjConfig* mac = OCpjConfig::New(prj);
	CCpjMacSection* section = &mac->m_Sections[mac->m_Sections.Add()];	
	section->name = "autoexec";
	section->commands.AddItem(CCorString("SetAuthor \"Unknown\""));
	section->commands.AddItem(CCorString("SetDescription \"None\""));	
	section->commands.AddItem(CCorString("SetOrigin 0 0 0"));
	section->commands.AddItem(CCorString("SetScale 1 1 1"));
	section->commands.AddItem(CCorString("SetRotation 0 0 0"));

	OCpjGeometry* mGeometry = OCpjGeometry::New(prj);
	section->commands.AddItem(CCorString("SetGeometry \"default\""));

	OCpjSurface* mSurface = OCpjSurface::New(prj);
	section->commands.AddItem(CCorString("SetSurface 0 \"default\""));

	OCpjFrames* mFrameData = NULL;
	OCpjSkeleton* mSkeleton = NULL;

	// Geometry description
	VVec3* loadingVerts = MEM_Malloc(VVec3, model->GetVertices().GetCount());
	NDword* loadingTris = MEM_Malloc(NDword, model->GetTriFaces().GetCount()*3);
	for (NDword i=0;i<model->GetTriFaces().GetCount();i++)
	{
		loadingTris[i*3+0] = model->GetTriFaces()[i]->GetEdgeRing()[0]->GetTailVertex()->GetIndex();
		loadingTris[i*3+1] = model->GetTriFaces()[i]->GetEdgeRing()[1]->GetTailVertex()->GetIndex();
		loadingTris[i*3+2] = model->GetTriFaces()[i]->GetEdgeRing()[2]->GetTailVertex()->GetIndex();
	}
	entity->GetVertexPosMulti(0, model->GetVertices().GetCount(), (vgvec3*)loadingVerts);
	
	mGeometry->Generate(model->GetVertices().GetCount(), loadingVerts[0], model->GetTriFaces().GetCount(), loadingTris);

	MEM_Free(loadingVerts);
	MEM_Free(loadingTris);

	for (i=0;i<model->GetVertices().GetCount();i++)
	{
		mGeometry->m_Verts[i].groupIndex = model->GetVertices()[i]->GetVertexGroup()->GetIndex();
		if (model->GetVertices()[i]->GetFlags() & CBL_VF_LODLOCK)
			mGeometry->m_Verts[i].flags |= GEOVF_LODLOCK;
	}

	for (i=0;i<model->GetSurfaceMounts().GetCount();i++)
	{		
		CBLSurfaceMount* iM = model->GetSurfaceMounts()[i];
		CCpjGeoMount* oM = &mGeometry->m_Mounts[mGeometry->m_Mounts.Add()];
		strcpy(oM->name, iM->GetName());
		oM->triIndex = iM->GetMountTriFace()->GetIndex();
		vgvec3 barys = iM->GetMountBarys();
		oM->triBarys = VVec3(barys.x, barys.y, barys.z);
		vgocs3 baseOCS = iM->GetMountBaseOCS();
		oM->baseCoords.r.vX = VVec3(baseOCS.frame.vX.x, baseOCS.frame.vX.y, baseOCS.frame.vX.z);
		oM->baseCoords.r.vY = VVec3(baseOCS.frame.vY.x, baseOCS.frame.vY.y, baseOCS.frame.vY.z);
		oM->baseCoords.r.vZ = VVec3(baseOCS.frame.vZ.x, baseOCS.frame.vZ.y, baseOCS.frame.vZ.z);
		oM->baseCoords.t = VVec3(baseOCS.translate.x, baseOCS.translate.y, baseOCS.translate.z);
		oM->baseCoords.s = VVec3(baseOCS.scale.x, baseOCS.scale.y, baseOCS.scale.z);
	}

	// Surface description
	mSurface->m_Textures.Add(model->GetTextures().GetCount());
	for (i=0;i<model->GetTextures().GetCount();i++)
	{		
		strcpy(mSurface->m_Textures[i].name, model->GetTextures()[i]->GetImageFile());
		if (!mSurface->m_Textures[i].name[0])
			strcpy(mSurface->m_Textures[i].name, model->GetTextures()[i]->GetName());
	}
	mSurface->m_Tris.Add(model->GetTriFaces().GetCount());
	mSurface->m_UV.AddZeroed(model->GetTexVertices().GetCount());
	entity->GetTexVertexPosMulti(0, model->GetTexVertices().GetCount(), (vgvec2*)&mSurface->m_UV[0]);
	for (i=0;i<model->GetTriFaces().GetCount();i++)
	{
		CBLTriFace* iT = model->GetTriFaces()[i];
		CCpjSrfTri* oT = &mSurface->m_Tris[i];

		oT->uvIndex[0] = (NWord)iT->GetTexVertexRing()[0]->GetIndex();
		oT->uvIndex[1] = (NWord)iT->GetTexVertexRing()[1]->GetIndex();
		oT->uvIndex[2] = (NWord)iT->GetTexVertexRing()[2]->GetIndex();
		oT->texIndex = 0;
		oT->flags |= SRFTF_INACTIVE;
		if (iT->GetFlags() & CBL_TFF_TWOSIDED)
			oT->flags |= SRFTF_TWOSIDED;
		if (iT->GetFlags() & CBL_TFF_VNIGNORE)
			oT->flags |= SRFTF_VNIGNORE;
		if (iT->GetFlags() & CBL_TFF_HIDDEN)
			oT->flags |= SRFTF_HIDDEN;
		if (iT->GetMaterial())
		{
			if (iT->GetMaterial()->GetFlags() & CBL_MATF_UNLIT)
				oT->flags |= SRFTF_UNLIT;
			if (iT->GetMaterial()->GetFlags() & CBL_MATF_ENVMAP)
				oT->flags |= SRFTF_ENVMAP;			
			oT->alphaLevel = iT->GetMaterial()->GetTransparency()*255.f;
			if (iT->GetMaterial()->GetFlags() & CBL_MATF_MODULATED)
				oT->flags |= SRFTF_MODULATED;
			if (iT->GetMaterial()->GetTransparency() > 0.f)
				oT->flags |= SRFTF_TRANSPARENT;
			if (iT->GetMaterial()->GetTextures().GetCount() && (iT->GetMaterial()->GetTextures()[0]))
			{
				oT->flags &= ~SRFTF_INACTIVE;
				if (iT->GetMaterial()->GetTextures()[0]->GetFlags() & CBL_TEXF_MASKING)
					oT->flags |= SRFTF_MASKING;
				oT->texIndex = iT->GetMaterial()->GetTextures()[0]->GetIndex();
				if ((iT->GetMaterial()->GetTextures().GetCount() > 1) && (iT->GetMaterial()->GetTextures()[1]))
				{
					oT->glazeFunc = SRFGLAZE_SPECULAR;
					oT->glazeTexIndex = iT->GetMaterial()->GetTextures()[1]->GetIndex();
				}
			}
		}
	}

	// Skeleton
	if (model->GetBones().GetCount())
	{
		mSkeleton = OCpjSkeleton::New(prj);
		section->commands.AddItem(CCorString("SetSkeleton \"default\""));

		mSkeleton->m_Bones.Add(model->GetBones().GetCount());
		mSkeleton->m_Verts.Add(model->GetVertices().GetCount());
		for (i=0;i<model->GetBones().GetCount();i++)
		{
			CBLBone* iB = model->GetBones()[i];
			CCpjSklBone* oB = &mSkeleton->m_Bones[i];
			oB->name = iB->GetName();
			oB->parentBone = NULL;
			if (iB->GetParentBone())
				oB->parentBone = &mSkeleton->m_Bones[iB->GetParentBone()->GetIndex()];
			vgocs3 baseOCS = iB->GetBaseOCS();
			oB->baseCoords.r.vX = VVec3(baseOCS.frame.vX.x, baseOCS.frame.vX.y, baseOCS.frame.vX.z);
			oB->baseCoords.r.vY = VVec3(baseOCS.frame.vY.x, baseOCS.frame.vY.y, baseOCS.frame.vY.z);
			oB->baseCoords.r.vZ = VVec3(baseOCS.frame.vZ.x, baseOCS.frame.vZ.y, baseOCS.frame.vZ.z);
			oB->baseCoords.t = VVec3(baseOCS.translate.x, baseOCS.translate.y, baseOCS.translate.z);
			oB->baseCoords.s = VVec3(baseOCS.scale.x, baseOCS.scale.y, baseOCS.scale.z);
		}
		for (i=0;i<model->GetBones().GetCount();i++)
		{
			// compute bone length from average of child translations
			CCpjSklBone* bA = &mSkeleton->m_Bones[i];
			NDword numChild = 0;
			NFloat lengthTotal = 0.f;
			for (NDword j=0;j<model->GetBones().GetCount();j++)
			{
				CCpjSklBone* bB = &mSkeleton->m_Bones[j];
				if (bB->parentBone != bA)
					continue;
				lengthTotal += bB->baseCoords.t.Length();
				numChild++;
			}			
			bA->length = 1.f;
			if (numChild)
				bA->length = lengthTotal / (NFloat)numChild;
		}
		for (i=0;i<model->GetVertices().GetCount();i++)
		{
			CBLVertex* iV = model->GetVertices()[i];
			CCpjSklVert* oV = &mSkeleton->m_Verts[i];
			if (!iV->GetVertexWeights().GetCount())
				continue;
			oV->weights.Add(iV->GetVertexWeights().GetCount());
			for (NDword k=0;k<iV->GetVertexWeights().GetCount();k++)
			{
				CBLVertex::vertexWeight_t* iW = &iV->GetVertexWeights()[k];
				CCpjSklWeight* oW = &oV->weights[k];
				oW->bone = NULL;
				if (iW->weightBone)
					oW->bone = &mSkeleton->m_Bones[iW->weightBone->GetIndex()];
				oW->factor = iW->weightFactor;
				oW->offsetPos = VVec3(iW->offsetPos.x, iW->offsetPos.y, iW->offsetPos.z);
			}
		}
	}

	// Vertex frames
	// Note: In order to collapse the frames of multiple vertex groups, this importer assumes that the
	// vertex frame names follow the "name_Gn" convention where n is the vertex group number and "name" is
	// common for all groups matching a particular combined frame.  All models exported by MDX2C3S have
	// this trait.
	if (model->GetVertexFrames().GetCount())
	{
		mFrameData = OCpjFrames::New(prj);
		section->commands.AddItem(CCorString("AddFrames \"NULL\""));
	}
	for (i=0;i<model->GetVertexFrames().GetCount();i++)
	{
		CBLVertexFrame* iF = model->GetVertexFrames()[i];
		iF->AuxDecompress();
		char baseName[256], *ptr;
		strcpy(baseName, iF->GetName());
		if (ptr = strrchr(baseName, '_'))
			*ptr = 0;
		CCpjFrmFrame* oF = NULL;
		for (NDword k=0;k<mFrameData->m_Frames.GetCount();k++)
		{
			if (!strcmp(*mFrameData->m_Frames[k].m_Name, baseName))
			{
				oF = &mFrameData->m_Frames[k];
				break;
			}
		}
		if (!oF)
		{
			oF = &mFrameData->m_Frames[mFrameData->m_Frames.Add()];
			oF->m_Name = baseName;
			oF->InitPositions(model->GetVertices().GetCount());
			for (NDword m=0;m<model->GetVertices().GetCount();m++)
				oF->m_PurePos[m] = mGeometry->m_Verts[m].refPosition;
		}
		CBLVertexGroup* iFgroup = iF->GetVertexGroup();
		if (iFgroup->GetVertices().GetCount() != iF->GetVertData().GetCount())
			LOG_Errorf("C3S Import: Vertex frame/group count desync");
		for (k=0;k<iFgroup->GetVertices().GetCount();k++)
		{
			vgvec3 iV = iF->GetVertData()[k];
			VVec3* oV = &oF->m_PurePos[iFgroup->GetVertices()[k]->GetIndex()];
			oV->x = iV.x; oV->y = iV.y; oV->z = iV.z;
		}
		iF->AuxCompress();
	}
	if (mFrameData)
	{
		for (i=0;i<mFrameData->m_Frames.GetCount();i++)
		{
			mFrameData->m_Frames[i].UpdateBounds();
			mFrameData->m_Frames[i].Compress(mGeometry);
		}
		mFrameData->UpdateBounds();
	}

	// Sequences
	NBool firstSequence = 0;	
	for (i=0;i<model->GetSequences().GetCount();i++)
	{
		CBLSequence* iS = model->GetSequences()[i];
		if (!strcmp(iS->GetName(), "ALL"))
			continue;
		if (!strcmp(iS->GetName(), "REFERENCE"))
			continue;
		if (!firstSequence)
		{
			section->commands.AddItem(CCorString("AddSequences \"NULL\""));
			firstSequence = 1;
		}

		OCpjSequence* oS = OCpjSequence::New(prj);
		oS->m_Rate = iS->GetPlayRate();
		oS->SetName(iS->GetName());
		for (NDword k=0;k<iS->GetKeyFrames().GetCount();k++)
		{
			CBLSequence::keyFrame_t* iF = &iS->GetKeyFrames()[k];
			CCpjSeqFrame* oF = &oS->m_Frames[oS->m_Frames.Add()];
			if (iF->vertexFrames.GetCount())
			{
				char baseName[256], *ptr;
				strcpy(baseName, iF->vertexFrames[0]->GetName());
				if (ptr = strrchr(baseName, '_'))
					*ptr = 0;
				oF->vertFrameName = baseName;
			}
			for (NDword m=0; m<iF->boneKeys.GetCount(); m++)
			{
				CBLSequence::boneKey_t* iB = &iF->boneKeys[m];
				NDword boneIndex = 0xffffffff;
				for (NDword n=0;n<oS->m_BoneInfo.GetCount();n++)
				{
					if (stricmp(iB->keyBone->GetName(), *oS->m_BoneInfo[n].name))
						continue;
					boneIndex = n;
					break;
				}
				if (n==oS->m_BoneInfo.GetCount())
				{
					boneIndex = oS->m_BoneInfo.Add();
					oS->m_BoneInfo[boneIndex].name = iB->keyBone->GetName();
					oS->m_BoneInfo[boneIndex].srcLength = mSkeleton->m_Bones[iB->keyBone->GetIndex()].length;
				}
				
				CCpjSeqRotate* br = &oF->rotates[oF->rotates.Add()];
				vgvec3 eulers = FrameToEulers(iB->animOCS.frame);
				eulers *= 32768.f / M_PI;
				while (eulers.x < 0.f) eulers.x += 65536.f;
				while (eulers.y < 0.f) eulers.y += 65536.f;
				while (eulers.z < 0.f) eulers.z += 65536.f;
				br->boneIndex = boneIndex;
				br->roll = (NSWord)eulers.z;
				br->pitch = (NSWord)eulers.x;
				br->yaw = (NSWord)eulers.y;
#ifndef CPJ_SEQ_NOQUATOPT
				VEulers3 eulers2;
				eulers2.r = (float)br->roll * M_PI / 32768.f;
				eulers2.p = (float)br->pitch * M_PI / 32768.f;
				eulers2.y = (float)br->yaw * M_PI / 32768.f;
				br->quat = VQuat3(~VAxes3(eulers2));
#endif

				if (iB->animOCS.translate.Length() > M_EPSILON)
				{
					CCpjSeqTranslate* bt = &oF->translates[oF->translates.Add()];
					bt->boneIndex = boneIndex;
					bt->translate = VVec3(iB->animOCS.translate.x, iB->animOCS.translate.y, iB->animOCS.translate.z);
				}
				if ((iB->animOCS.scale & vgvec3(1,1,1)) > M_EPSILON)
				{
					CCpjSeqScale* bs = &oF->scales[oF->scales.Add()];
					bs->boneIndex = boneIndex;
					bs->scale = VVec3(iB->animOCS.scale.x, iB->animOCS.scale.y, iB->animOCS.scale.z);
				}
			}
		}
		for (k=0;k<iS->GetSeqTriggers().GetCount();k++)
		{
			CBLSequence::seqTrigger_t* iE = &iS->GetSeqTriggers()[k];
			if (iE->command == KRN_FOURCC("TRIG"))
			{
				if (!stricmp((char*)iE->parameters.GetData(), "_HIDDENTRIS"))
					continue;
				CCpjSeqEvent* oE = &oS->m_Events[oS->m_Events.Add()];
				oE->eventType = SEQEV_TRIGGER;
				oE->time = iE->timeVal;
				oE->paramString = (char*)iE->parameters.GetData();
			}
			else if (iE->command == KRN_FOURCC("TFHF"))
			{
				CCpjSeqEvent* oE = &oS->m_Events[oS->m_Events.Add()];
				oE->eventType = SEQEV_TRIFLAGS;
				oE->time = 0.f;
				NChar buf[4096];
				NDword hideTrisCount = iE->parameters.GetCount();
				NByte* hideTrisData = (NByte*)iE->parameters.GetData();
				for (NDword x=0; x<hideTrisCount; x++)
					buf[x] = hideTrisData[x] ? '1' : '0';
				buf[hideTrisCount] = 0;
				oE->paramString = buf;
			}
		}
	}

	// LOD
	OCpjLodData* mLodData = OCpjLodData::New(prj);
	if (mLodData->Generate(mGeometry, mSurface))
		section->commands.AddItem(CCorString("SetLodData \"default\""));
	else
		mLodData->Destroy();

	// Cleanup
	for (iter.Reset(prj); iter; iter++)
	{
		iter->mIsLoaded = 1;
		if (!iter->HasName())
			iter->SetName("default");
	}

	delete entity;
	delete scene;
	CBL_Shutdown();
	return(1);
}

//****************************************************************************
//**
//**    END MODULE IMPC3S.CPP
//**
//****************************************************************************

