//****************************************************************************
//**
//**    IMPMDX.CPP
//**    MDX Files
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "CpjMain.h"
#include "PlgMain.h"
#include "CpjFmt.h"

#include "resource.h"

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define MDX_ASCF_MAGIC		"ASCF"
#define MDX_ASCF_VERSION	3
#define MDX_DNXM_MAGIC		"DNXM"
#define MDX_DNXM_VERSION	5

#define MDX_TF_HIDDEN		0x02
#define MDX_TF_NOVERTLIGHT	0x04
#define MDX_TF_TRANSPARENT	0x08
#define MDX_TF_SPECULAR		0x10
#define MDX_TF_UNLIT		0x20
#define MDX_TF_TWOSIDED		0x40
#define MDX_TF_MASKING		0x80
#define MDX_TF_MODULATED	0x100
#define MDX_TF_ENVMAP		0x200
#define MDX_TF_NONCOLLIDE	0x400
#define MDX_TF_TEXBLEND		0x800
#define MDX_TF_ZLATER		0x1000

#define FVF_P_LODLOCKED    0x10

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class __declspec(dllexport) OCpjImporterMDX
: public OCpjImporter
{
	OBJ_CLASS_DEFINE(OCpjImporterMDX, OCpjImporter);

	NBool ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError);

	// OCpjImporter
	CObjClass* GetImportClass() { return(OCpjProject::GetStaticClass()); }
	NChar* GetFileExtension() { return("mdx"); }
	NChar* GetFileDescription() { return("Old Cannibal MDX File"); }
	NBool Import(OObject* inRes, NChar* inFileName, NChar* outError);
};
OBJ_CLASS_IMPLEMENTATION(OCpjImporterMDX, OCpjImporter, 0);

class CImpPlugin
: public IPlgPlugin
{
public:
	// IPlgPlugin
	bool Create() { return(1); }
	bool Destroy() { return(1); }
	char* GetTitle() { return("Cannibal MDX Model Importer"); }
	char* GetDescription() { return("No description"); }
	char* GetAuthor() { return("3D Realms Entertainment"); }
	float GetVersion() { return(1.0f); }
};

#pragma pack(push, 1)

/*
	Header / Directory
*/
struct SMdxHeader
{
	NDword magic; // MDX_ASCF_MAGIC
	NDword typeMagic; // MDX_DNXM_MAGIC
    NWord ascfVersion; // MDX_ASCF_VERSION
	NWord typeVersion; // MDX_DNXM_VERSION
	NDword fileSize; // total size of file
	NDword dirOfs; // chunk directory offset
    NDword dirEntries; // chunk directory entry count
    NDword user1; // additional user data space
    NDword user2; // additional user data space
};
struct SMdxEntry
{
	NDword chunkLabel; // four-character label, see list below
	NDword chunkOfs; // chunk data offset
	NDword chunkLen; // chunk data length in bytes
    NByte chunkVersion; // chunk-specific version number
    NByte reserved[3]; // must be zero
    NChar chunkInstance[32]; // instance name of this chunk, for use by other chunks
};

/*
	Skin Chunk
*/
#define MDX_SKIN_MAGIC		"SKIN"
struct SMdxSkin
{
	NDword skinWidth; // width of skin data
	NDword skinHeight; // height of skin data
	NDword skinBitDepth; // bit depth of skin data
    NChar skinFile[64]; // skin filename relative to model location, no extention
};
struct SMdxSkinChunk
{
	NDword numSkins;
	SMdxSkin skins[1]; // variable sized
};

/*
	Tris Chunk
*/
#define MDX_TRIS_MAGIC		"TRIS"
struct SMdxTri
{
	NWord vertIndex[3];
    NWord edgeIndex[3]; // tris for linked tris at v0v1,v1v2,v2v0... used for tristrips, some effects, etc.
	                    // low 14 bits is index, high 2 bits is edge number on the other tri, 0-2
    NWord flags;
    NByte aux1;
	NByte aux2;
};
struct SMdxTrisChunk
{
    NDword numTris; // number of triangles
    SMdxTri tris[1]; // variable sized
};

/*
	Mount point chunk
*/
#define MDX_MPNT_MAGIC		"MPNT"
struct SMdxMountPoint
{
    NDword triIndex; // triangle index as basis of mount point, vertex indices are v0-v2.  triIndex of -1 indicates not in use.
    VVec3 barys; // barycentric coordinates of origin for v0-v2
    VAxes3 defFrame; // default xyz axes for frame adjustment as pretransform... posttransform to (y cross z, normal, normalize(v0-origin))
	VVec3 defScale; // default scalars for attached models
	VVec3 defOrg; // default origin for attached models as translate adjustment
};
struct SMdxMpntChunk
{
	NDword numMountPoints; // must be either 32 or 0, 0 meaning the rest of the chunk does not exist and no mounts exist.  Any other number is invalid.
						 // make sure to check for 0 before reading the rest of this chunk, since it might not be there!
	NDword numFrames; // number of frames in mountFrames list, ignored by this importer
	NDword validBits; // bit flags indicating mount points used (1) or unused (0).  Bit is (1 << mountIndex).  Bit 0 should ALWAYS be 0 (mount 0 reserved as origin).
	SMdxMountPoint mountInfo[32]; // source mount point definitions
	NByte mountFrames[1]; // variable sized, ignored by this importer
};

/*
	Frame chunks
*/
#define MDX_RFRM_MAGIC		"RFRM"
struct SMdxVert
{
	NByte groupNum; // group number for byte decompression
	NByte v[3];
	NByte normal[3]; // s.7, s = sign bit, .7 = fabs(component*127);
    NByte mountIndex; // mount point for basis
	//                  0 = none given (for FRMD chunks, use the one given for the RFRM.  For RFRM, use origin frame)
	//                  0xFF = force to none (identical to "none given" but doesn't default back to RFRM)
	//                  1 through 0xFE = use (index-1) in MPNT chunk
};
struct SMdxTVert
{
	NSWord s;
	NSWord t;
};
struct SMdxFrameInfo
{
	VVec3 scales[16]; // scales for each group number, multiply byte verts by this
	VVec3 translates[16]; // translates for each group number, add this after scale
    VVec3 bBox[2][16]; // bounding boxes min and max for each group number, [min/max][group]
};
struct SMdxRfrmChunk
{
	SMdxFrameInfo frameInfo; // geometry information for frame
    NDword numVerts; // number of model vertices
	NDword numTris; // number of model triangles (must match numTris in TRIS chunk)
    NDword info[1]; // variable sized, verts + baseTris + triSkins back to back
	// SMdxVert verts[numVerts]; // vertex positions
	// SMdxTVert baseTris[numTris][3]; // texture vert "baseframe" positions for triangles
	// NByte triSkins[numTris]; // skin indices into SKIN chunk for triangles
};
#define MDX_FRMD_MAGIC		"FRMD"
struct SMdxFrmdChunk
{
	SMdxFrameInfo frameInfo; // geometry information for frame
	NDword triInfoOfs; // byte offset into info block of triInfo
	NDword info[1]; // variable sized, vertInfo + triInfo back to back
	// vertInfo format: short vertex command plus any command data.  Command 0 is end of vertInfo
	//   Vertex commands: high four bits are command, low 12 bits optionally used as part of command data
	//   Command 0: End of vertInfo
	//   Command 1: Single Vert: Low 12 bits are vertex index, followed by mdxvert_t replacement for that index.
	//   Command 2: Contiguous Vert Set: Low 12 bits are starting vertex index, followed by a short count number of
	//                                   verts, followed by count number of mdxvert_t's.
	// triInfo format: short triangle command plus any command data.  Command 0 is end of triInfo
	//   Triangle commands: high four bits are command, low 12 bits optionally used as part of command data
	//   Command 0: End of triInfo
	//   Command 1: Single Tri TVerts: Low 12 bits are triangle index, followed by three mdxtvert_t's for that tri.
	//   Command 2: Multiple Tri TVerts: Low 12 bits are triCount, followed by three mdxtvert_t's to use,
	//                                   followed by triCount short triangle indices to use these tverts with.
	//   Command 3: Tri Range TVerts: Low 12 bits are starting triangle index, followed by three mdxtvert_t's to use,
	//                                followed by a short count number to use them for, beginning with the starting index.
	//   Command 4: Contiguous TVert Set: Low 12 bits are starting triangle index, followed by a short count number of
	//                                    triangles, followed by count number of three mdxtvert_t sets
	//   Command 5: Single Tri Skin: Low 12 bits are triangle index, followed by short skin index for that tri.
	//   Command 6: Multiple Tri Skin: Low 12 bits are triCount, followed by a short skin index to use,
	//                                 followed by triCount short triangle indices to use the skin with.
	//   Command 7: Tri Range Skin: Low 12 bits are starting triangle index, followed by a short skin index to use,
	//                              followed by a short count number to use it for, beginning with the starting index.
	//   Command 8: Contiguous Skin Set: Low 12 bits are starting triangle index, followed by a short count number of
	//                                   triangles, followed by count number of short skin indices
	//   Commands 9-15: Reserved for future use

};

/*
	Sequence chunks
*/
#define MDX_FSEQ_MAGIC		"FSEQ"
// version 2
struct SMdxFseqBlockV2
{
	NDword timeStart; // beginning of range in msec
	NDword timeDuration; // duration of range in msec
	NDword triggerOfs; // offset into **mdxfseqchunk_t** of trigger stream, falls into triggerBuffer area.  0 for no triggers.
	NDword flags;
	NChar frmdChunkName[32]; // frame chunk name at start of range.  Can also be reference frame.
};
struct SMdxFseqChunkV2
{
	NDword numBlocks;
	SMdxFseqBlockV2 blocks[1]; // variable sized
	// following the blocks is a buffer for data referred to by triggerOfs
};

// version 3
struct SMdxFseqBlockV3
{
	NChar frmdChunkName[32]; // frame chunk name at start of range.  Can also be reference frame.  If empty, means trigger.
	NFloat triggerTimeFrac; // time in sequence from 0.0-1.0 for trigger (only used if trigger)
	NDword triggerOfs; // offset into **mdxfseqchunk_t** of trigger stream, falls into triggerBuffer area.  0 for no triggers.
};
struct SMdxFseqChunkV3
{
	NFloat framesPerSecond; // rate of animation in frames per second
	NDword numBlocks; // number of blocks
	SMdxFseqBlockV3 blocks[1]; // variable sized
	// following the blocks is a buffer for data referred to by triggerOfs
};

#pragma pack(pop)

//============================================================================
//    PRIVATE DATA
//============================================================================
//============================================================================
//    GLOBAL DATA
//============================================================================
static CImpPlugin imp_Plugin;
static HINSTANCE imp_hInst;

// preservation options
static NBool imp_PreserveSkeleton;
static NBool imp_PreserveBoneSeqs;
static NBool imp_PreserveGeoMounts;
static NBool imp_PreserveSrfTexRefs;
static OCpjGeometry* imp_PreserveGeo;
static OCpjSurface* imp_PreserveSrf;

//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static BOOL CALLBACK IMP_PreserveDlgProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	RECT rect;

	switch(msg)
	{
	case WM_INITDIALOG:
		GetWindowRect(hWnd, &rect);
		SetWindowPos(hWnd, HWND_TOP,
			(GetSystemMetrics(SM_CXSCREEN)-(rect.right-rect.left))/2,
			(GetSystemMetrics(SM_CYSCREEN)-(rect.bottom-rect.top))/2,
			rect.right-rect.left, rect.bottom-rect.top, SWP_SHOWWINDOW);
		return(1);
		break;
	case WM_COMMAND:
		switch(GET_WM_COMMAND_ID(wParam, lParam))
		{
		case IDOK:
			imp_PreserveSkeleton = (SendDlgItemMessage(hWnd, IDC_CK_MDX_PSKL, BM_GETCHECK, 0, 0) == BST_CHECKED);
			imp_PreserveBoneSeqs = (SendDlgItemMessage(hWnd, IDC_CK_MDX_PBSEQ, BM_GETCHECK, 0, 0) == BST_CHECKED);
			imp_PreserveGeoMounts = (SendDlgItemMessage(hWnd, IDC_CK_MDX_PMGEO, BM_GETCHECK, 0, 0) == BST_CHECKED);
			imp_PreserveSrfTexRefs = (SendDlgItemMessage(hWnd, IDC_CK_MDX_PTSRF, BM_GETCHECK, 0, 0) == BST_CHECKED);
			EndDialog(hWnd, NULL);
			break;
		default:
			break;
		}
		break;
	}
	return(0);
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
extern "C" __declspec(dllexport) IPlgPlugin* __cdecl CannibalPluginCreate(void)
{
	return(&imp_Plugin);
}

BOOL WINAPI DllMain(HINSTANCE hInstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
	imp_hInst = hInstDLL;
	return(1);
}

//============================================================================
//    CLASS METHODS
//============================================================================
NBool OCpjImporterMDX::ImportMem(OObject* inRes, void* inImagePtr, NDword inImageLen, NChar* outError)
{
	NDword i;

	if (!inRes || !inRes->IsA(GetImportClass()))
	{
		strcpy(outError, "Invalid resource");
		return(0);
	}
	OCpjProject* prj = (OCpjProject*)inRes;

	SMdxHeader* header = (SMdxHeader*)inImagePtr;
	if ((header->magic != KRN_FOURCC(MDX_ASCF_MAGIC))
	 || (header->typeMagic != KRN_FOURCC(MDX_DNXM_MAGIC))
	 || (header->ascfVersion != MDX_ASCF_VERSION)
	 || (header->typeVersion != MDX_DNXM_VERSION))
	{
		strcpy(outError, "Invalid header information");
		return(0);
	}

	SMdxEntry* rfrmEntry = NULL;
	SMdxSkinChunk* skinChunk = NULL;
	SMdxTrisChunk* trisChunk = NULL;
	SMdxRfrmChunk* rfrmChunk = NULL;
	SMdxMpntChunk* mpntChunk = NULL;
	SMdxEntry* entries = (SMdxEntry*)((NByte*)inImagePtr + header->dirOfs);
	NDword numEntries = header->dirEntries;
	for (i=0;i<numEntries;i++)
	{
		if (entries[i].chunkLabel == KRN_FOURCC(MDX_SKIN_MAGIC))
		{
			if (entries[i].chunkVersion != 1)
			{
				sprintf(outError, "Invalid SKIN chunk version %d", entries[i].chunkVersion);
				return(0);
			}
			skinChunk = (SMdxSkinChunk*)((NByte*)inImagePtr + entries[i].chunkOfs);
		}
		else if (entries[i].chunkLabel == KRN_FOURCC(MDX_TRIS_MAGIC))
		{
			if (entries[i].chunkVersion != 1)
			{
				sprintf(outError, "Invalid TRIS chunk version %d", entries[i].chunkVersion);
				return(0);
			}
			trisChunk = (SMdxTrisChunk*)((NByte*)inImagePtr + entries[i].chunkOfs);
		}
		else if (entries[i].chunkLabel == KRN_FOURCC(MDX_RFRM_MAGIC))
		{
			if (entries[i].chunkVersion != 1)
			{
				sprintf(outError, "Invalid RFRM chunk version %d", entries[i].chunkVersion);
				return(0);
			}
			rfrmChunk = (SMdxRfrmChunk*)((NByte*)inImagePtr + entries[i].chunkOfs);
			rfrmEntry = &entries[i];
		}
		else if (entries[i].chunkLabel == KRN_FOURCC(MDX_MPNT_MAGIC))
		{
			if (entries[i].chunkVersion == 1)
				mpntChunk = (SMdxMpntChunk*)((NByte*)inImagePtr + entries[i].chunkOfs);
		}
	}
	if (!skinChunk || !trisChunk || !rfrmChunk)
	{
		if (!skinChunk)
			strcpy(outError, "No SKIN Chunk found");
		if (!trisChunk)
			strcpy(outError, "No TRIS Chunk found");
		if (!rfrmChunk)
			strcpy(outError, "No RFRM Chunk found");
		return(0);
	}
	SMdxVert* rfrmVerts = (SMdxVert*)(rfrmChunk->info);
	SMdxTVert* rfrmBaseTris = (SMdxTVert*)(rfrmVerts + rfrmChunk->numVerts);
	NByte* rfrmTriSkins = (NByte*)(rfrmBaseTris + rfrmChunk->numTris*3);

	// get preservation options	
	DialogBox(imp_hInst, MAKEINTRESOURCE(IDD_MDXPRESERVE), NULL, (DLGPROC)IMP_PreserveDlgProc);

	// remove old data
	for (TObjIter<OCpjChunk> iter(prj); iter; iter++)
	{
		if (imp_PreserveSkeleton)
		{
			// keep skeletons if present
			if (iter->IsA(OCpjSkeleton::GetStaticClass()))
				continue;
		}
		if (imp_PreserveBoneSeqs)
		{
			// keep sequences if they refer to bones
			if (iter->IsA(OCpjSequence::GetStaticClass()))
			{
				OCpjSequence* seq = (OCpjSequence*)*iter;
				if (seq->m_BoneInfo.GetCount())
					continue;
			}
		}
		if (imp_PreserveGeoMounts)
		{
			// keep geometry mount point names
			if (iter->IsA(OCpjGeometry::GetStaticClass())
			 && (!stricmp(iter->GetName(), "default")))
			{
				imp_PreserveGeo = (OCpjGeometry*)*iter;
				imp_PreserveGeo->SetParent(NULL);
				continue;
			}
		}
		if (imp_PreserveSrfTexRefs)
		{
			// keep surface texture reference names
			if (iter->IsA(OCpjSurface::GetStaticClass())
			 && (!stricmp(iter->GetName(), "default")))
			{
				imp_PreserveSrf = (OCpjSurface*)*iter;
				imp_PreserveSrf->SetParent(NULL);
				continue;
			}
		}
		iter->Destroy();
	}

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

	// Geometry description
	VVec3* loadingVerts = MEM_Malloc(VVec3, rfrmChunk->numVerts);
	NDword* loadingTris = MEM_Malloc(NDword, trisChunk->numTris*3);
	for (i=0;i<trisChunk->numTris;i++)
	{
		loadingTris[i*3+0] = trisChunk->tris[i].vertIndex[0];
		loadingTris[i*3+1] = trisChunk->tris[i].vertIndex[1];
		loadingTris[i*3+2] = trisChunk->tris[i].vertIndex[2];
	}
	for (i=0;i<rfrmChunk->numVerts;i++)
	{
		SMdxVert* iV = &rfrmVerts[i];
		VVec3* oV = &loadingVerts[i];
		VVec3* scale = &rfrmChunk->frameInfo.scales[iV->groupNum&0x0F];
		VVec3* translate = &rfrmChunk->frameInfo.translates[iV->groupNum&0x0F];
		oV->x = (NFloat)iV->v[0]*scale->x + translate->x;
		oV->y = (NFloat)iV->v[1]*scale->y + translate->y;
		oV->z = (NFloat)iV->v[2]*scale->z + translate->z;
	}
	mGeometry->Generate(rfrmChunk->numVerts, loadingVerts[0], trisChunk->numTris, loadingTris);
	MEM_Free(loadingVerts);
	MEM_Free(loadingTris);

	for (i=0;i<rfrmChunk->numVerts;i++)
	{
		mGeometry->m_Verts[i].groupIndex = rfrmVerts[i].groupNum&0x0F;
		if (rfrmVerts[i].groupNum & FVF_P_LODLOCKED)
			mGeometry->m_Verts[i].flags |= GEOVF_LODLOCK;
	}

	if (mpntChunk && mpntChunk->numMountPoints==32)
	{
		for (i=1;i<32;i++)
		{
			if (!(mpntChunk->validBits & (1 << i)))
				continue;
			SMdxMountPoint* iM = &mpntChunk->mountInfo[i];
			if (iM->triIndex >= trisChunk->numTris)
				continue;
			CCpjGeoMount* oM = &mGeometry->m_Mounts[mGeometry->m_Mounts.Add()];
			sprintf(oM->name, "Mount%d", i);
			oM->triIndex = iM->triIndex;
			oM->triBarys = iM->barys;
			oM->baseCoords.r = iM->defFrame;
			oM->baseCoords.t = iM->defOrg;
			oM->baseCoords.s = iM->defScale;
		}
	}

	// Surface description

	mSurface->m_Textures.Add(skinChunk->numSkins);
	for (i=0;i<skinChunk->numSkins;i++)
		strcpy(mSurface->m_Textures[i].name, skinChunk->skins[i].skinFile);
	mSurface->m_Tris.Add(trisChunk->numTris);
	mSurface->m_UV.AddZeroed(trisChunk->numTris*3);
	NBool hasSpecular = 0;
	for (i=0;i<trisChunk->numTris;i++)
	{
		SMdxTri* iT = &trisChunk->tris[i];
		CCpjSrfTri* oT = &mSurface->m_Tris[i];

		oT->uvIndex[0] = (NWord)i*3;
		oT->uvIndex[1] = (NWord)i*3+1;
		oT->uvIndex[2] = (NWord)i*3+2;
		oT->texIndex = rfrmTriSkins[i];
		oT->flags |= SRFTF_INACTIVE;
		if (oT->texIndex < skinChunk->numSkins)
		{
			for (int k=0;k<3;k++)
			{
				mSurface->m_UV[i*3+k].x = (NFloat)rfrmBaseTris[i*3+k].s / skinChunk->skins[oT->texIndex].skinWidth;
				mSurface->m_UV[i*3+k].y = (NFloat)rfrmBaseTris[i*3+k].t / skinChunk->skins[oT->texIndex].skinHeight;
			}
			for (k=0;k<3;k++)
			{
				if ((rfrmBaseTris[i*3+k].s == (NSWord)-1) || (rfrmBaseTris[i*3+k].t == (NSWord)-1))
					break;
			}
			if (k==3)
				oT->flags &= ~SRFTF_INACTIVE;
		}
		if (iT->flags & MDX_TF_HIDDEN)
			oT->flags |= SRFTF_HIDDEN;
		if (iT->flags & MDX_TF_NOVERTLIGHT)
			oT->flags |= SRFTF_VNIGNORE;
		if (iT->flags & MDX_TF_TRANSPARENT)
			oT->flags |= SRFTF_TRANSPARENT;
		if (iT->flags & MDX_TF_UNLIT)
			oT->flags |= SRFTF_UNLIT;
		if (iT->flags & MDX_TF_TWOSIDED)
			oT->flags |= SRFTF_TWOSIDED;
		if (iT->flags & MDX_TF_MASKING)
			oT->flags |= SRFTF_MASKING;
		if (iT->flags & MDX_TF_MODULATED)
			oT->flags |= SRFTF_MODULATED;
		if (iT->flags & MDX_TF_ENVMAP)
			oT->flags |= SRFTF_ENVMAP;
		if (iT->flags & MDX_TF_NONCOLLIDE)
			oT->flags |= SRFTF_NONCOLLIDE;
		if (iT->flags & MDX_TF_TEXBLEND)
			oT->flags |= SRFTF_TEXBLEND;
		if (iT->flags & MDX_TF_ZLATER)
			oT->flags |= SRFTF_ZLATER;
		if (iT->flags & MDX_TF_SPECULAR)
		{
			oT->glazeFunc = SRFGLAZE_SPECULAR;
			oT->glazeTexIndex = (NByte)mSurface->m_Textures.GetCount();
			hasSpecular = 1;
		}
		if (iT->flags & (MDX_TF_TRANSPARENT|MDX_TF_MODULATED))
		{
			oT->alphaLevel = 128;
			if (iT->aux1)
				oT->alphaLevel = iT->aux1;
		}
	}
	if (hasSpecular)
		strcpy(mSurface->m_Textures[mSurface->m_Textures.Add()].name, "DefaultSpecular");

	// Vertex frames
	for (i=0;i<numEntries;i++)
	{
		if (entries[i].chunkLabel != KRN_FOURCC(MDX_FRMD_MAGIC))
			continue;
		if (entries[i].chunkVersion != 1)
			continue;
		
		SMdxFrmdChunk* frmdChunk = (SMdxFrmdChunk*)((NByte*)inImagePtr + entries[i].chunkOfs);
		if (!mFrameData)
		{
			mFrameData = OCpjFrames::New(prj);
			section->commands.AddItem(CCorString("AddFrames \"NULL\""));
		}
		CCpjFrmFrame* oF = &mFrameData->m_Frames[mFrameData->m_Frames.Add()];
		oF->m_Name = entries[i].chunkInstance;
		
		oF->InitPositions(rfrmChunk->numVerts);		
		for (NDword m=0;m<rfrmChunk->numVerts;m++)
			oF->m_PurePos[m] = mGeometry->m_Verts[m].refPosition;

		NWord* frameData;
		NWord frmdCmd, frmdVertCount;
		SMdxVert* v;
		NDword frmdTotal=0;

		frameData = (NWord*)frmdChunk->info;
		for (frmdCmd = ((*frameData)&0xF000)>>12; frmdCmd; frmdCmd = ((*frameData)&0xF000)>>12)
		{
			if (frmdCmd==1)
			{
				m = (*frameData)&0x0FFF; frameData++;
				v = (SMdxVert*)frameData; frameData += (sizeof(SMdxVert)/2);
				VVec3* oV = &oF->m_PurePos[m];
				VVec3* scale = &frmdChunk->frameInfo.scales[v->groupNum&0x0F];
				VVec3* translate = &frmdChunk->frameInfo.translates[v->groupNum&0x0F];
				oV->x = (NFloat)v->v[0]*scale->x + translate->x;
				oV->y = (NFloat)v->v[1]*scale->y + translate->y;
				oV->z = (NFloat)v->v[2]*scale->z + translate->z;
			}
			else if (frmdCmd==2)
			{
				m = (*frameData)&0x0FFF; frameData++;
				frmdVertCount = *frameData + (NWord)m; frameData++;
				for ( ; m<frmdVertCount; m++)
				{
					v = (SMdxVert*)frameData; frameData += (sizeof(SMdxVert)/2);
					VVec3* oV = &oF->m_PurePos[m];
					VVec3* scale = &frmdChunk->frameInfo.scales[v->groupNum&0x0F];
					VVec3* translate = &frmdChunk->frameInfo.translates[v->groupNum&0x0F];
					oV->x = (NFloat)v->v[0]*scale->x + translate->x;
					oV->y = (NFloat)v->v[1]*scale->y + translate->y;
					oV->z = (NFloat)v->v[2]*scale->z + translate->z;
				}
			}
			else
				LOG_Warnf("MDX Import: Invalid FRMD command %d", frmdCmd);
		}

		oF->UpdateBounds();
		oF->Compress(mGeometry);
	}
	if (mFrameData)
		mFrameData->UpdateBounds();

	// Sequences
	NBool firstSequence = 0;
	for (i=0;i<numEntries;i++)
	{
		if (entries[i].chunkLabel != KRN_FOURCC(MDX_FSEQ_MAGIC))
			continue;
		if (entries[i].chunkVersion != 3)
			continue;
		if (!strcmp(entries[i].chunkInstance, "ALL"))
			continue;
		if (!strcmp(entries[i].chunkInstance, "REFERENCE"))
			continue;
		
		if (!firstSequence)
		{
			section->commands.AddItem(CCorString("AddSequences \"NULL\""));
			firstSequence = 1;
		}

		SMdxFseqChunkV3* fseqChunk = (SMdxFseqChunkV3*)((NByte*)inImagePtr + entries[i].chunkOfs);
		OCpjSequence* oS = OCpjSequence::New(prj);
		oS->m_Rate = fseqChunk->framesPerSecond;
		oS->SetName(entries[i].chunkInstance);
		for (NDword k=0;k<fseqChunk->numBlocks;k++)
		{
			if (fseqChunk->blocks[k].frmdChunkName[0])
			{
				CCpjSeqFrame* oF = &oS->m_Frames[oS->m_Frames.Add()];
				if (stricmp(fseqChunk->blocks[k].frmdChunkName, rfrmEntry->chunkInstance)) // leave frame name empty if reference frame
					oF->vertFrameName = fseqChunk->blocks[k].frmdChunkName;
			}
			else
			{
				CCpjSeqEvent* oE = &oS->m_Events[oS->m_Events.Add()];
				oE->eventType = SEQEV_TRIGGER;
				oE->time = fseqChunk->blocks[k].triggerTimeFrac;
				if (fseqChunk->blocks[k].triggerOfs)
				{
					NChar* triggerStr = (NChar*)fseqChunk + (fseqChunk->blocks[k].triggerOfs);
					if (stricmp(triggerStr, "_HIDDENTRIS"))
					{
						oE->paramString = triggerStr;
					}
					else if ((NByte)triggerStr[strlen(triggerStr)+1] == 0xFF)
					{
						oE->eventType = SEQEV_TRIFLAGS;
						oE->time = 0.f;
						NByte* hideTrisData = (NByte*)&triggerStr[strlen(triggerStr)+2];
						NDword hideTrisCount = *((NDword*)hideTrisData);
						hideTrisData += sizeof(NDword);
						NChar buf[4096];
						for (NDword x=0; x<hideTrisCount; x++)
							buf[x] = hideTrisData[x] ? '1' : '0';
						buf[hideTrisCount] = 0;
						oE->paramString = buf;
					}
				}
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

	// Update according to preservation options
	if (imp_PreserveGeo)
	{
		NDword count = mGeometry->m_Mounts.GetCount();
		if (count > imp_PreserveGeo->m_Mounts.GetCount())
			count = imp_PreserveGeo->m_Mounts.GetCount();
		for (NDword i=0;i<count;i++)
			strcpy(mGeometry->m_Mounts[i].name, imp_PreserveGeo->m_Mounts[i].name);
		imp_PreserveGeo->Destroy();
		imp_PreserveGeo = NULL;
	}
	if (imp_PreserveSrf)
	{
		NDword count = mSurface->m_Textures.GetCount();
		if (count > imp_PreserveSrf->m_Textures.GetCount())
			count = imp_PreserveSrf->m_Textures.GetCount();
		for (NDword i=0;i<count;i++)
			strcpy(mSurface->m_Textures[i].refName, imp_PreserveSrf->m_Textures[i].refName);
		imp_PreserveSrf->Destroy();
		imp_PreserveSrf = NULL;
	}

	return(1);
}

NBool OCpjImporterMDX::Import(OObject* inRes, NChar* inFileName, NChar* outError)
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
	return(result);
}

//****************************************************************************
//**
//**    END MODULE IMPMDX.CPP
//**
//****************************************************************************

