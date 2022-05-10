//****************************************************************************
//**
//**    OVL_MDL.CPP
//**    Overlays - Model View
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include <windows.h>
#include <windowsx.h>

#include "cbl_defs.h"
#include "ovl_defs.h"
#include "ovl_mdl.h"
//#include "ovl_skin.h"
//#include "ovl_frm.h"
//#include "ovl_seq.h"
#include "file_imp.h"

//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define OVL_MAXMODELFRAMES 2048
#define OVL_MAXMODELSKINS 128
#define OVL_MAXSEQITEMS 2048
#define OVL_MAXMODELSEQUENCES 256

#define MDX_CBLPVERSION 12

//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------

typedef int (*frameImportFunc_t)(char *filename,
								 int *numframes, int *numverts, vector_t **frameVerts,
								 int *numfaces, int **faces, char **frameNames);

typedef struct
{	
	char *ext;
	frameImportFunc_t func;
} frameImport_t;

//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
frameImport_t frameImports[] = {
	{ "MDL", FI_LoadMDL },
	{ "3DS", FI_Load3DS },
	{ "MD2", FI_LoadMD2 },
	{ "LWO", FI_LoadLWO },
	{ "GMA", FI_LoadGMA },
    { "MXB", FI_LoadMXB },
	{ NULL, NULL }
};

pool_t<sortitem_t> ovl_sortPool("SortPool", 2048, NULL, NULL);

//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
pool_t<modelFrame_t> ovl_framePool("Frames", OVL_MAXMODELFRAMES, NULL, NULL);
pool_t<modelSkin_t> ovl_skinPool("Skins", OVL_MAXMODELSKINS, NULL, NULL);
pool_t<seqItem_t> ovl_seqItemPool("SeqItems", OVL_MAXSEQITEMS, NULL, NULL);
pool_t<seqTrigger_t> ovl_seqTriggerPool("SeqTriggers", OVL_MAXSEQITEMS, NULL, NULL);
pool_t<modelSequence_t> ovl_seqPool("Sequences", OVL_MAXMODELSEQUENCES, NULL, NULL);

//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    CLASS modelSkin_t
//**
//****************************************************************************
void *modelSkin_t::operator new(size_t size)
{
	return(ovl_skinPool.Alloc(NULL));
}

void modelSkin_t::operator delete(void *ptr)
{
	ovl_skinPool.Free((modelSkin_t *)ptr);
}

//****************************************************************************
//**
//**    END CLASS modelSkin_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelTrimesh_t
//**
//****************************************************************************
void modelTrimesh_t::EvaluateLinks()
{
	int i, k, m, n1, n2;
	meshTri_t *itri, *ktri;

	for (i=0;i<numTris;i++)
	{
		itri = &meshTris[i];
		itri->edgeTris[0] = 0xFFFF;
		itri->edgeTris[1] = 0xFFFF;
		itri->edgeTris[2] = 0xFFFF;	
		for (k=0;k<numTris;k++)
		{
			ktri = &meshTris[k];
			if (!ktri)
				continue;
			if (itri == ktri)
				continue;
			for (m=0;m<3;m++)
			{
				n1 = m;
				n2 = (m+1)%3;
				if ((itri->verti[n1] == ktri->verti[0]) && (itri->verti[n2] == ktri->verti[2]))
				{
					itri->edgeTris[m] = (unsigned short)k | 0x8000;
					break;
				}
				if ((itri->verti[n1] == ktri->verti[1]) && (itri->verti[n2] == ktri->verti[0]))
				{
					itri->edgeTris[m] = (unsigned short)k;
					break;
				}
				if ((itri->verti[n1] == ktri->verti[2]) && (itri->verti[n2] == ktri->verti[1]))
				{
					itri->edgeTris[m] = (unsigned short)k | 0x4000;
					break;
				}
			}
		}
	}
}
//****************************************************************************
//**
//**    END CLASS modelTrimesh_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelFrame_t
//**
//****************************************************************************
int modelFrame_t::Import(int inNumVerts, vector_t *inVerts, int inNumTris, int *inTris)
{
	int i;
	frameVert_t *refVerts;
		
	CacheIn();
	if (verts)
		FREE(verts);
	if (baseTris)
		FREE(baseTris);
	numVerts = inNumVerts;
	verts = ALLOC(frameVert_t, numVerts);
	refVerts = NULL;
	if (mdl->refFrame != this)
		refVerts = mdl->refFrame->GetVerts();
	for (i=0;i<numVerts;i++)
	{
		verts[i].pos = inVerts[i];
		verts[i].flags = 0;
//		verts[i].mountIndex = 0;
		if (mdl->refFrame == this)
			verts[i].groupNum = 0;
		else
			verts[i].groupNum = refVerts[i].groupNum;
	}
	numTris = inNumTris;
	baseTris = ALLOC(baseTri_t, numTris);
	for (i=0;i<numTris;i++)
	{
		baseTris[i].tverts[0].Set(-1,-1,0);
		baseTris[i].tverts[1].Set(-1,-1,0);
		baseTris[i].tverts[2].Set(-1,-1,0);
		baseTris[i].flags = 0;
		baseTris[i].skinIndex = 0;
	}
	if (mdl->refFrame == this)
		CalcVertNormals();
	return(1);
}

int modelFrame_t::PreserveBaseframe(int preserveNumVerts, vector_t *preserveVerts,
					  int preserveNumTris, int *preserveMeshTris, float *preserveBaseTris)
{
	int i, k, m;
	int *pmTri;
	float *pbTri;
	int nv[3];
	int match[3];
	int matchcount = 0;
	int *matchVerts;
	float dist, matchDist;

	matchVerts = ALLOC(int, numVerts);
	
	// find the nearest old vertex to each new vertex
	for (i=0;i<numVerts;i++)
	{
		matchDist = FLT_MAX;
		for (k=0;k<preserveNumVerts;k++)
		{
			if ((dist = verts[i].pos.Distance(preserveVerts[k])) < matchDist)
			{
				matchDist = dist;
				matchVerts[i] = k;
			}
		}
	}

	for (i=0;i<numTris;i++)
	{ // for each new triangle
		for (k=0;k<3;k++)
			nv[k] = mdl->mesh.meshTris[i].verti[k];
		for (k=0,pmTri=preserveMeshTris,pbTri=preserveBaseTris; k<preserveNumTris; k++,pmTri+=3,pbTri+=6)
		{ // check each old triangle
			for (m=0;m<3;m++)
			{
				match[m] = -1;
				if (matchVerts[nv[m]] == pmTri[0])
					match[m] = 0;
				else
				if (matchVerts[nv[m]] == pmTri[1])
					match[m] = 1;
				else
				if (matchVerts[nv[m]] == pmTri[2])
					match[m] = 2;
			}
			// if they match
			if ((match[0] >= 0) && (match[1] >= 0) && (match[2] >= 0))
			{
				if ((match[0] != match[1]) && (match[0] != match[2]))
				{ // copy baseframe coordinates over
					baseTris[i].tverts[0].Set(pbTri[match[0]*2], pbTri[match[0]*2+1], 0);
					baseTris[i].tverts[1].Set(pbTri[match[1]*2], pbTri[match[1]*2+1], 0);
					baseTris[i].tverts[2].Set(pbTri[match[2]*2], pbTri[match[2]*2+1], 0);
					baseTris[i].flags = BTF_INUSE;
					if ((baseTris[i].tverts[0].x == -1) || (baseTris[i].tverts[0].y == -1)
					 || (baseTris[i].tverts[1].x == -1) || (baseTris[i].tverts[1].y == -1)
					 || (baseTris[i].tverts[2].x == -1) || (baseTris[i].tverts[2].y == -1))
						baseTris[i].flags = 0;
					matchcount++;
					break;
				}
			}
		}
	}
	FREE(matchVerts);
	return(matchcount);
}

void modelFrame_t::LoadMDXChunk(ascfentrylink_t *entry)
{
	strcpy(name, entry->entry.chunkInstance);
	flags = 0;
	CacheIn();
	if (verts)
		FREE(verts);
	if (baseTris)
		FREE(baseTris);
	if (entry->entry.chunkLabel == *((unsigned long *)"FRMD"))
	{ // deformation
		if (mdl->refFrame == this)
			SYS_Error("LoadMDXChunk: Attempt to load FRMD chunk at reference frame");
		numVerts = mdl->refFrame->numVerts;
		numTris = mdl->refFrame->numTris;
		flags |= MRF_COMPRESSED;
		frmdData = ALLOC(byte, entry->entry.chunkLen);
		frmdDataLen = entry->entry.chunkLen;
		memcpy(frmdData, entry->data, frmdDataLen);
		Decompress();
	}
	else
	if (entry->entry.chunkLabel == *((unsigned long *)"RFRM"))
	{ // reference frame
		if (mdl->refFrame != this)
			SYS_Error("LoadMDXChunk: Attempt to load RFRM chunk at non-reference frame");
		int i;
		vector_t scales[WSFRAME_MAXGROUPS], translates[WSFRAME_MAXGROUPS];
		vector_t bbMin[WSFRAME_MAXGROUPS], bbMax[WSFRAME_MAXGROUPS];
		VCR_PlaybackLocal((byte **)&entry->data, entry->entry.chunkLen);
		for (i=0;i<WSFRAME_MAXGROUPS;i++) { scales[i].x = VCR_ReadFloat(); scales[i].y = VCR_ReadFloat(); scales[i].z = VCR_ReadFloat(); }
		for (i=0;i<WSFRAME_MAXGROUPS;i++) { translates[i].x = VCR_ReadFloat(); translates[i].y = VCR_ReadFloat(); translates[i].z = VCR_ReadFloat(); }
		for (i=0;i<WSFRAME_MAXGROUPS;i++) { bbMin[i].x = VCR_ReadFloat(); bbMin[i].z = VCR_ReadFloat(); bbMin[i].z = VCR_ReadFloat(); }
		for (i=0;i<WSFRAME_MAXGROUPS;i++) { bbMax[i].x = VCR_ReadFloat(); bbMax[i].z = VCR_ReadFloat(); bbMax[i].z = VCR_ReadFloat(); }
		numVerts = VCR_ReadInt();
		numTris = VCR_ReadInt();
		if (numVerts)
			verts = ALLOC(frameVert_t, numVerts);
		if (numTris)
			baseTris = ALLOC(baseTri_t, numTris);
		for (i=0;i<numVerts;i++)
		{
			verts[i].groupNum = VCR_ReadByte();
			verts[i].flags = 0;
			if (verts[i].groupNum & FVF_P_LODLOCKED)
				verts[i].flags |= FVF_P_LODLOCKED;
			verts[i].groupNum &= 0x0F;
			verts[i].pos.x = ((float)VCR_ReadByte() * scales[verts[i].groupNum].x) + translates[verts[i].groupNum].x;
			verts[i].pos.y = ((float)VCR_ReadByte() * scales[verts[i].groupNum].y) + translates[verts[i].groupNum].y;
			verts[i].pos.z = ((float)VCR_ReadByte() * scales[verts[i].groupNum].z) + translates[verts[i].groupNum].z;
			VCR_ReadByte(); // skip light normal
			VCR_ReadByte();
			VCR_ReadByte();
			mdl->mesh.mountPoints[i] = /*verts[i].mountIndex = */VCR_ReadByte();
		}
		for (i=0;i<numTris;i++)
		{
			baseTris[i].tverts[0].x = VCR_ReadShort();
			baseTris[i].tverts[0].y = VCR_ReadShort();
			baseTris[i].tverts[0].z = 0.0f;
			baseTris[i].tverts[1].x = VCR_ReadShort();
			baseTris[i].tverts[1].y = VCR_ReadShort();
			baseTris[i].tverts[1].z = 0.0f;
			baseTris[i].tverts[2].x = VCR_ReadShort();
			baseTris[i].tverts[2].y = VCR_ReadShort();
			baseTris[i].tverts[2].z = 0.0f;
			baseTris[i].flags = BTF_INUSE;
			if ((baseTris[i].tverts[0].x == -1) || (baseTris[i].tverts[0].y == -1)
			 || (baseTris[i].tverts[1].x == -1) || (baseTris[i].tverts[1].y == -1)
			 || (baseTris[i].tverts[2].x == -1) || (baseTris[i].tverts[2].y == -1))
				baseTris[i].flags = 0;

		}
		for (i=0;i<numTris;i++)
		{
			baseTris[i].skinIndex = VCR_ReadByte();
		}
		CalcVertNormals();
	}
	else
		SYS_Error("LoadMDXChunk: Invalid chunk type");
}

#define MAXCACHEFRAMES 32
static modelFrame_t *ovl_framesCachedIn[MAXCACHEFRAMES];

void modelFrame_t::CacheIn()
{
	int i, k;
	for (i=0;i<MAXCACHEFRAMES;i++)
	{
		if (ovl_framesCachedIn[i] == this)
		{ // already cached in, shift list down and move to top
			for (k=i-1;k>=0;k--)
				ovl_framesCachedIn[k+1] = ovl_framesCachedIn[k];
			ovl_framesCachedIn[0] = this;
			Decompress();
			return;
		}
	}
	// not already cached in, move the list down and cache out the last one
	if (ovl_framesCachedIn[MAXCACHEFRAMES-1])
		ovl_framesCachedIn[MAXCACHEFRAMES-1]->Compress();
	for (i=MAXCACHEFRAMES-2;i>=0;i--)
		ovl_framesCachedIn[i+1] = ovl_framesCachedIn[i];
	ovl_framesCachedIn[0] = this;
	Decompress();
}

void modelFrame_t::RemoveFromCache()
{
	int i;

	for (i=0;i<MAXCACHEFRAMES;i++)
	{
		if (ovl_framesCachedIn[i] == this)
			ovl_framesCachedIn[i] = NULL;
	}
}

void modelFrame_t::SetReference(modelFrame_t *ref)
{
	if (flags & MRF_COMPRESSED)
	{
		Decompress();
		if (!ref)
			ref = this;
		if (ref == this)
			CalcVertNormals();
		Compress();
	}
	else
	{
		if (!ref)
			ref = this;
		if (ref == this)
			CalcVertNormals();
	}
}

void modelFrame_t::CalcVertNormals()
{
	frameVert_t *fverts;
	meshTri_t *mtri;
	int *lnormFactors;
	int i, m;
	plane_t pln;

	if (mdl->refFrame != this)
		return;
	if (vertNorms)
		FREE(vertNorms);
	if ((!numVerts) || (!numTris))
		return;
	fverts = GetVerts();
	if (!fverts)
		return;
	vertNorms = ALLOC(vector_t, numVerts);
	lnormFactors = ALLOC(int, numVerts);
	memset(vertNorms, 0, numVerts*sizeof(vector_t));
	memset(lnormFactors, 0, numVerts*sizeof(int));
	for (i=0;i<mdl->mesh.numTris;i++)
	{
		mtri = &mdl->mesh.meshTris[i];
		if (!(mtri->flags & TF_NOVERTLIGHT))
		{
			pln.TriExtract(fverts[mtri->verti[0]].pos, fverts[mtri->verti[1]].pos, fverts[mtri->verti[2]].pos);
			for (m=0;m<3;m++)
			{
				vertNorms[mtri->verti[m]] += pln.n;
				lnormFactors[mtri->verti[m]]++;
			}
		}
	}
	for (i=0;i<numVerts;i++)
	{
		vertNorms[i] /= lnormFactors[i];
		vertNorms[i].Normalize();
	}
	FREE(lnormFactors);
}

void modelFrame_t::Compress()
{
	int i, k, m, frmdDataVertOfs, frmdDataTriOfs;
	long triOfsOfs;
	float v;
	vector_t scales[WSFRAME_MAXGROUPS], translates[WSFRAME_MAXGROUPS];
	vector_t mins[WSFRAME_MAXGROUPS], maxs[WSFRAME_MAXGROUPS];
	vector_t bbMin[WSFRAME_MAXGROUPS], bbMax[WSFRAME_MAXGROUPS];
	byte vbyte;

	if (mdl->refFrame == this)
		return; // don't compress the reference frame
	if (flags & MRF_COMPRESSED)
		return; // already compressed
	flags |= MRF_COMPRESSED;
	if (frmdData)
		FREE(frmdData);
	VCR_Record(VCRA_LOCAL, "$framecompress", NULL, numVerts*10 + numTris*32 + sizeof(mdxfrmdchunk_t), &frmdData); // size is rough guess, should fit
	
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		scales[i] = 0; translates[i] = 0;
		mins[i] = FLT_MAX, maxs[i] = -FLT_MAX;
		bbMin[i] = 0, bbMax[i] = 0;
	}
	if (verts)
	{
		for (i=0;i<numVerts;i++)
		{
			if (verts[i].pos.x < mins[verts[i].groupNum].x) mins[verts[i].groupNum].x = verts[i].pos.x;
			if (verts[i].pos.y < mins[verts[i].groupNum].y) mins[verts[i].groupNum].y = verts[i].pos.y;
			if (verts[i].pos.z < mins[verts[i].groupNum].z) mins[verts[i].groupNum].z = verts[i].pos.z;
			if (verts[i].pos.x > maxs[verts[i].groupNum].x) maxs[verts[i].groupNum].x = verts[i].pos.x;
			if (verts[i].pos.y > maxs[verts[i].groupNum].y) maxs[verts[i].groupNum].y = verts[i].pos.y;
			if (verts[i].pos.z > maxs[verts[i].groupNum].z) maxs[verts[i].groupNum].z = verts[i].pos.z;
		}
	}
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		scales[i] = (maxs[i] - mins[i])/255.0;
		VCR_WriteFloat(scales[i].x);
		VCR_WriteFloat(scales[i].y);
		VCR_WriteFloat(scales[i].z);
	}
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		translates[i] = mins[i];
		VCR_WriteFloat(translates[i].x);
		VCR_WriteFloat(translates[i].y);
		VCR_WriteFloat(translates[i].z);
	}
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		bbMin[i] = mins[i];
		VCR_WriteFloat(bbMin[i].x);
		VCR_WriteFloat(bbMin[i].y);
		VCR_WriteFloat(bbMin[i].z);
	}
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		bbMax[i] = maxs[i];
		VCR_WriteFloat(bbMax[i].x);
		VCR_WriteFloat(bbMax[i].y);
		VCR_WriteFloat(bbMax[i].z);
	}
	triOfsOfs = VCR_GetActionWriteLen();
	VCR_WriteInt(0);
	
	// verts
	frmdDataVertOfs = VCR_GetActionWriteLen();
	if (verts)
	{
		int startvert=0, vertcount=0;
		for (i=0;i<numVerts;i++)
		{
			//if ((verts[i].pos == refFrame->verts[i].pos) && (verts[i].mountIndex == refFrame->verts[i].mountIndex))
			//	continue;
			if (!(verts[i].flags & FVF_IRRELEVANT))
			{
				if (!vertcount)
					startvert = i;
				vertcount++;
			}
			if ((verts[i].flags & FVF_IRRELEVANT)
			 || (i == (numVerts-1)))
			{
				if (vertcount == 1)
				{
					VCR_WriteShort(i | 0x1000);
					VCR_WriteByte(verts[i].groupNum | (verts[i].flags & FVF_P_LODLOCKED));
					for (m=0;m<3;m++)
					{
						v = floor(((verts[i].pos.v[m] - translates[verts[i].groupNum].v[m]) / scales[verts[i].groupNum].v[m]) + 0.5);
						if (v > 255) v = 255;
						if (v < 0) v = 0;
						vbyte = v;
						VCR_WriteByte(vbyte);
					}
					VCR_WriteByte(0); VCR_WriteByte(0); VCR_WriteByte(0x7F); // skip lightnorm for now, set to (0,0,1)
					VCR_WriteByte(mdl->mesh.mountPoints[i]); //VCR_WriteByte(0); //VCR_WriteByte(verts[i].mountIndex);
				}
				else
				if (vertcount > 1)
				{
					VCR_WriteShort(startvert | 0x2000);
					VCR_WriteShort(vertcount);
					for (k=startvert;k<(startvert+vertcount);k++)
					{
						VCR_WriteByte(verts[k].groupNum | (verts[k].flags & FVF_P_LODLOCKED));
						for (m=0;m<3;m++)
						{
							v = floor(((verts[k].pos.v[m] - translates[verts[k].groupNum].v[m]) / scales[verts[k].groupNum].v[m]) + 0.5);
							if (v > 255) v = 255;
							if (v < 0) v = 0;
							vbyte = v;
							VCR_WriteByte(vbyte);
						}
						VCR_WriteByte(0); VCR_WriteByte(0); VCR_WriteByte(0x7F); // skip lightnorm for now, set to (0,0,1)						
						VCR_WriteByte(mdl->mesh.mountPoints[k]); //VCR_WriteByte(0); //VCR_WriteByte(verts[k].mountIndex);
					}
				}
				vertcount = 0;
			}
		}
	}
	VCR_WriteShort(0);

	// baseframe triangles
	frmdDataTriOfs = VCR_GetActionWriteLen(); // do an "ftell" to fill in triInfoOfs in initial data
	*((long *)((byte *)frmdData+triOfsOfs)) = frmdDataTriOfs - frmdDataVertOfs;
	if (baseTris)
	{
		for (i=0;i<numTris;i++)
		{
			if ((baseTris[i].tverts[0] == mdl->refFrame->baseTris[i].tverts[0])
			 && (baseTris[i].tverts[1] == mdl->refFrame->baseTris[i].tverts[1])
			 && (baseTris[i].tverts[2] == mdl->refFrame->baseTris[i].tverts[2]))
				continue;
			if (!(baseTris[i].flags & BTF_INUSE))
				continue;
			VCR_WriteShort(i | 0x1000);
			VCR_WriteShort((short)baseTris[i].tverts[0].x);
			VCR_WriteShort((short)baseTris[i].tverts[0].y);
			VCR_WriteShort((short)baseTris[i].tverts[1].x);
			VCR_WriteShort((short)baseTris[i].tverts[1].y);
			VCR_WriteShort((short)baseTris[i].tverts[2].x);
			VCR_WriteShort((short)baseTris[i].tverts[2].y);
		}
		for (i=0;i<numTris;i++)
		{
			if (baseTris[i].skinIndex == mdl->refFrame->baseTris[i].skinIndex)
				continue;
			VCR_WriteShort(i | 0x5000);
			VCR_WriteShort((short)baseTris[i].skinIndex);
		}
	}
	VCR_WriteShort(0);
	frmdDataLen = VCR_GetActionWriteLen();

	if (verts)
		FREE(verts);
	if (baseTris)
		FREE(baseTris);
	if (vertNorms)
		FREE(vertNorms);
}

void modelFrame_t::Decompress()
{
	short i, k, startvert, vertcount;
	vector_t scales[WSFRAME_MAXGROUPS], translates[WSFRAME_MAXGROUPS];
	vector_t bbMin[WSFRAME_MAXGROUPS], bbMax[WSFRAME_MAXGROUPS];

	if (!(flags & MRF_COMPRESSED))
		return; // not compressed	
	if (!frmdData)
		return; // nothing to decompress
	flags &= ~MRF_COMPRESSED;
	if (verts)
		FREE(verts);
	if (baseTris)
		FREE(baseTris);
	if (vertNorms)
		FREE(vertNorms);
	numVerts = mdl->refFrame->numVerts;
	numTris = mdl->refFrame->numTris;
	if (numVerts)
		verts = ALLOC(frameVert_t, numVerts);
	if (numTris)
		baseTris = ALLOC(baseTri_t, numTris);
	VCR_PlaybackLocal(&frmdData, frmdDataLen);

	for (i=0;i<numVerts;i++)
	{
		verts[i] = mdl->refFrame->verts[i];
		verts[i].flags = FVF_IRRELEVANT;
	}
	for (i=0;i<numTris;i++)
	{
		baseTris[i] = mdl->refFrame->baseTris[i];
		baseTris[i].flags = 0;
	}
	for (i=0;i<WSFRAME_MAXGROUPS;i++) { scales[i].x = VCR_ReadFloat(); scales[i].y = VCR_ReadFloat(); scales[i].z = VCR_ReadFloat(); }
	for (i=0;i<WSFRAME_MAXGROUPS;i++) { translates[i].x = VCR_ReadFloat(); translates[i].y = VCR_ReadFloat(); translates[i].z = VCR_ReadFloat(); }
	for (i=0;i<WSFRAME_MAXGROUPS;i++) { bbMin[i].x = VCR_ReadFloat(); bbMin[i].z = VCR_ReadFloat(); bbMin[i].z = VCR_ReadFloat(); }
	for (i=0;i<WSFRAME_MAXGROUPS;i++) { bbMax[i].x = VCR_ReadFloat(); bbMax[i].z = VCR_ReadFloat(); bbMax[i].z = VCR_ReadFloat(); }
	VCR_ReadInt(); // triInfoOfs
	while ((i = VCR_ReadShort()) & (short)0xF000)
	{
		switch(i >> 12)
		{
		case 1:
			i &= 0x0FFF;
			verts[i].groupNum = VCR_ReadByte();
			verts[i].flags = 0;
			if (verts[i].groupNum & FVF_P_LODLOCKED)
				verts[i].flags |= FVF_P_LODLOCKED;
			verts[i].groupNum &= 0x0F;
			verts[i].pos.x = ((float)VCR_ReadByte() * scales[verts[i].groupNum].x) + translates[verts[i].groupNum].x;
			verts[i].pos.y = ((float)VCR_ReadByte() * scales[verts[i].groupNum].y) + translates[verts[i].groupNum].y;
			verts[i].pos.z = ((float)VCR_ReadByte() * scales[verts[i].groupNum].z) + translates[verts[i].groupNum].z;
			VCR_ReadByte(); // skip light normal
			VCR_ReadByte();
			VCR_ReadByte();
			VCR_ReadByte(); //verts[i].mountIndex = VCR_ReadByte();
			break;
		case 2:
			i &= 0x0FFF;
			startvert = i;
			vertcount = VCR_ReadShort();
			for (k=startvert;k<(startvert+vertcount);k++)
			{
				verts[k].groupNum = VCR_ReadByte();
				verts[k].flags = 0;
				if (verts[k].groupNum & FVF_P_LODLOCKED)
					verts[k].flags |= FVF_P_LODLOCKED;
				verts[k].groupNum &= 0x0F;
				verts[k].pos.x = ((float)VCR_ReadByte() * scales[verts[k].groupNum].x) + translates[verts[k].groupNum].x;
				verts[k].pos.y = ((float)VCR_ReadByte() * scales[verts[k].groupNum].y) + translates[verts[k].groupNum].y;
				verts[k].pos.z = ((float)VCR_ReadByte() * scales[verts[k].groupNum].z) + translates[verts[k].groupNum].z;
				VCR_ReadByte(); // skip light normal
				VCR_ReadByte();
				VCR_ReadByte();
				VCR_ReadByte(); //verts[k].mountIndex = VCR_ReadByte();
			}
			break;
		default:
			SYS_Error("workFrame_t::Decompress: Unacceptable Vert Command");
			break;
		}
	}
	while ((i = VCR_ReadShort()) & (short)0xF000)
	{
		switch(i >> 12)
		{
		case 1:
			i &= 0x0FFF;
			baseTris[i].flags |= BTF_INUSE;
			baseTris[i].tverts[0].x = VCR_ReadShort();
			baseTris[i].tverts[0].y = VCR_ReadShort();
			baseTris[i].tverts[0].z = 0.0f;
			baseTris[i].tverts[1].x = VCR_ReadShort();
			baseTris[i].tverts[1].y = VCR_ReadShort();
			baseTris[i].tverts[1].z = 0.0f;
			baseTris[i].tverts[2].x = VCR_ReadShort();
			baseTris[i].tverts[2].y = VCR_ReadShort();
			baseTris[i].tverts[2].z = 0.0f;
			break;
		case 5:
			i &= 0x0FFF;
			baseTris[i].skinIndex = VCR_ReadShort();
			break;
		default:
			SYS_Error("workFrame_t::Decompress: Unacceptable Tri Command");
		}
	}
	if (frmdData)
		FREE(frmdData);
	if (mdl->refFrame == this)
		CalcVertNormals();
}

frameVert_t *modelFrame_t::GetVerts()
{
	CacheIn();
	return(verts);
}

baseTri_t *modelFrame_t::GetBaseTris()
{
	CacheIn();
	return(baseTris);
}

void *modelFrame_t::operator new(size_t size)
{
	return(ovl_framePool.Alloc(NULL));
}

void modelFrame_t::operator delete(void *ptr)
{
	ovl_framePool.Free((modelFrame_t *)ptr);
}

//****************************************************************************
//**
//**    END CLASS modelFrame_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelSequence_t
//**
//****************************************************************************
void *modelSequence_t::operator new(size_t size)
{
	return(ovl_seqPool.Alloc(NULL));
}

void modelSequence_t::operator delete(void *ptr)
{
	ovl_seqPool.Free((modelSequence_t *)ptr);
}

//****************************************************************************
//**
//**    END CLASS modelSequence_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS modelMount_t
//**
//****************************************************************************
modelMount_t::~modelMount_t()
{
	if (attachModel)
		delete attachModel;
}

boolean modelMount_t::RecursiveCircularCheck(int mIndex)
{
	modelMount_t *m;
	meshTri_t *mTri;

	if (!mIndex)
		return(1);
	m = &mdl->mounts[mIndex];
	if (!(m->flags & MRF_INUSE))
		return(1);
	if (m == this)
		return(0);
	if (m->_triIndex == -1)
		return(1);
	mTri = &mdl->mesh.meshTris[m->_triIndex];
	if (!RecursiveCircularCheck(mdl->mesh.mountPoints[mTri->verti[0]]))
		return(0);
	if (!RecursiveCircularCheck(mdl->mesh.mountPoints[mTri->verti[1]]))
		return(0);
	if (!RecursiveCircularCheck(mdl->mesh.mountPoints[mTri->verti[2]]))
		return(0);
	return(1);
}

int modelMount_t::UpdateTransform(float updateTime, boolean forceUpdate)
{
	plane_t pln;
	vector_t pv[3];
	matrix_t rotTemp;
	vector_t axisX, axisY, axisZ;
	quatern_t q;
	int i;
	meshTri_t *tri;

	if ((_triIndex == -1) || (!(flags & MRF_INUSE)))
		return(0);

	if ((lastUpdateTime >= updateTime) && (!forceUpdate))
		return(1);
	
	tri = &mdl->mesh.meshTris[_triIndex];

	for (i=0;i<3;i++)
	{
		pv[i] = v[i];
		if (mdl->mesh.mountPoints[tri->verti[i]])
			mdl->mounts[mdl->mesh.mountPoints[tri->verti[i]]].RecursiveMountToWorld(pv[i], updateTime);
	}
	pln.TriExtract(pv[0], pv[1], pv[2]);

	_translate = pv[0]*barys[0] + pv[1]*barys[1] + pv[2]*barys[2];

	axisY = pln.n;
	axisZ = pv[0] - _translate;
	axisZ.Normalize();
//	q.Init(axisY, angle);
//	rotTemp = MatRotation(q);
//	axisZ = axisZ * rotTemp;
	axisX = axisY ^ axisZ;

	_rotate.Data[0][0] = axes[0].x; _rotate.Data[0][1] = axes[0].y; _rotate.Data[0][2] = axes[0].z; _rotate.Data[0][3] = 0.0;
	_rotate.Data[1][0] = axes[1].x; _rotate.Data[1][1] = axes[1].y; _rotate.Data[1][2] = axes[1].z; _rotate.Data[1][3] = 0.0;
	_rotate.Data[2][0] = axes[2].x; _rotate.Data[2][1] = axes[2].y; _rotate.Data[2][2] = axes[2].z; _rotate.Data[2][3] = 0.0;
	_rotate.Data[3][0] = 0.0; _rotate.Data[3][1] = 0.0; _rotate.Data[3][2] = 0.0; _rotate.Data[3][3] = 1.0;
	
	rotTemp.Data[0][0] = axisX.x; rotTemp.Data[0][1] = axisX.y; rotTemp.Data[0][2] = axisX.z; rotTemp.Data[0][3] = 0.0;
	rotTemp.Data[1][0] = axisY.x; rotTemp.Data[1][1] = axisY.y; rotTemp.Data[1][2] = axisY.z; rotTemp.Data[1][3] = 0.0;
	rotTemp.Data[2][0] = axisZ.x; rotTemp.Data[2][1] = axisZ.y; rotTemp.Data[2][2] = axisZ.z; rotTemp.Data[2][3] = 0.0;
	rotTemp.Data[3][0] = 0.0; rotTemp.Data[3][1] = 0.0; rotTemp.Data[3][2] = 0.0; rotTemp.Data[3][3] = 1.0;
	
	_rotate = _rotate * rotTemp;
	invrotate = _rotate.Transpose();

	lastUpdateTime = updateTime;
	
	return(1);
}

int modelMount_t::SetTriangle(int index)
{
	meshTri_t *tri;
	_triIndex = index;
	if (_triIndex == -1)
		return(1);
	tri = &mdl->mesh.meshTris[_triIndex];
	if (!RecursiveCircularCheck(mdl->mesh.mountPoints[tri->verti[0]]))
	{
		_triIndex = -1;
		return(0);
	}
	if (!RecursiveCircularCheck(mdl->mesh.mountPoints[tri->verti[1]]))
	{
		_triIndex = -1;
		return(0);
	}
	if (!RecursiveCircularCheck(mdl->mesh.mountPoints[tri->verti[2]]))
	{
		_triIndex = -1;
		return(0);
	}
	return(1);
}

int modelMount_t::SetFrame(modelFrame_t *frame)
{
	meshTri_t *tri;
	if (_triIndex == -1)
		return(0);
	tri = &mdl->mesh.meshTris[_triIndex];
	frameVert_t *rverts = mdl->refFrame->GetVerts();
	frameVert_t *fverts = frame->GetVerts();
	if (fverts[tri->verti[0]].flags & FVF_IRRELEVANT)
		v[0] = rverts[tri->verti[0]].pos;
	else
		v[0] = fverts[tri->verti[0]].pos;
	if (fverts[tri->verti[1]].flags & FVF_IRRELEVANT)
		v[1] = rverts[tri->verti[1]].pos;
	else
		v[1] = fverts[tri->verti[1]].pos;
	if (fverts[tri->verti[2]].flags & FVF_IRRELEVANT)
		v[2] = rverts[tri->verti[2]].pos;
	else
		v[2] = fverts[tri->verti[2]].pos;
	return(1);
}

int modelMount_t::SetFrameLerped(modelFrame_t *frame, modelFrame_t *lerpFrame, float back, float front)
{
	meshTri_t *tri;
	vector_t p[6];
	if (_triIndex == -1)
		return(0);
	tri = &mdl->mesh.meshTris[_triIndex];
	frameVert_t *rverts = mdl->refFrame->GetVerts();
	frameVert_t *fverts = frame->GetVerts();
	frameVert_t *lverts = lerpFrame->GetVerts();
	if (fverts[tri->verti[0]].flags & FVF_IRRELEVANT)
		p[0] = rverts[tri->verti[0]].pos;
	else
		p[0] = fverts[tri->verti[0]].pos;
	if (fverts[tri->verti[1]].flags & FVF_IRRELEVANT)
		p[1] = rverts[tri->verti[1]].pos;
	else
		p[1] = fverts[tri->verti[1]].pos;
	if (fverts[tri->verti[2]].flags & FVF_IRRELEVANT)
		p[2] = rverts[tri->verti[2]].pos;
	else
		p[2] = fverts[tri->verti[2]].pos;
	if (lverts[tri->verti[0]].flags & FVF_IRRELEVANT)
		p[3] = rverts[tri->verti[0]].pos;
	else
		p[3] = lverts[tri->verti[0]].pos;
	if (lverts[tri->verti[1]].flags & FVF_IRRELEVANT)
		p[4] = rverts[tri->verti[1]].pos;
	else
		p[4] = lverts[tri->verti[1]].pos;
	if (lverts[tri->verti[2]].flags & FVF_IRRELEVANT)
		p[5] = rverts[tri->verti[2]].pos;
	else
		p[5] = lverts[tri->verti[2]].pos;

	v[0] = p[0]*back + p[3]*front;
	v[1] = p[1]*back + p[4]*front;
	v[2] = p[2]*back + p[5]*front;
	return(1);
}

//****************************************************************************
//**
//**    END CLASS modelMount_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS model_t
//**
//****************************************************************************
void model_t::SetReference(modelFrame_t *ref)
{
	if (refFrame == ref)
		return;
	ref->SetReference(ref);
	MRL_ITERATENEXT(modelFrame_t *f, f, frames)
		f->SetReference(ref);
	refFrame = ref;
}

modelFrame_t *model_t::GetReference()
{
	return(refFrame);
}

int model_t::ImportFrames(char *filename, boolean forceRestart)
{
	int numverts, numtris, numframes;
	vector_t *frameVerts;
	char *frameNames = NULL;
	int *frameTris;
	modelFrame_t *f, *f2;
	int i, k;
	char *ptr;
	boolean res;
	frameImport_t *fi;
    char buf[256];
	
	boolean preserveBaseframe;
	int preserveNumTris=0, preserveNumVerts=0;
	int *preserveMeshTris;
	float *preserveBaseTris;
	vector_t *preserveVerts;

	if (!filename)
		return(0);
	for (fi=frameImports;fi->func;fi++)
	{
		if (!_stricmp(SYS_GetFileExtention(filename), fi->ext))
		{
			if (!fi->func(filename, &numframes, &numverts, &frameVerts, &numtris, &frameTris, &frameNames))
			{
				if (frameVerts)
					FREE(frameVerts);
				if (frameTris)
					FREE(frameTris);
				if (frameNames)
					FREE(frameNames);
				return(0);
			}
			break;
		}
	}
	if (!fi->func)
		return(0); // no loader function

	if ((numverts >= WSFRAME_MAXVERTS) || (numtris >= WSFRAME_MAXTRIS))
	{
		if (frameVerts)
			FREE(frameVerts);
		if (frameTris)
			FREE(frameTris);
		if (frameNames)
			FREE(frameNames);
		return(0);
	}
	
	ptr = NULL;
	if (frameNames)
		ptr = frameNames;
	for (i=0;i<numframes;i++)
	{
		preserveBaseframe = 0;
		if ((numtris != mesh.numTris) || (numverts != mesh.numVerts) || (forceRestart))
		{
			res = 0;
			if (!mesh.numTris)
				res = 1;
			else if ((forceRestart) && (SYS_MessageBox("Are you sure?", MB_YESNO,
				"You have requested to restart the model before adding new frames.\n"
				"This will reset the mesh to the new one, and remove all the existing frames.\n\n"
				"Do you wish to continue?", numtris, numverts, mesh.numTris, mesh.numVerts) == IDYES))
				res = 1;
			else if (SYS_MessageBox("Are you sure?", MB_YESNO,
				"The frame you are trying to import has:       %d triangles, %d vertices\n"
				"while the active mesh has:                    %d triangles, %d vertices.\n\n"
				"Loading this frame will reset the mesh to the new one, and remove all the existing frames.\n\n"
				"Do you wish to continue?", numtris, numverts, mesh.numTris, mesh.numVerts) == IDYES)
				res = 1;			
			if (!res)
			{
				if (frameVerts)
					FREE(frameVerts);
				if (frameTris)
					FREE(frameTris);
				return(0);
			}
			forceRestart = false;
			if (mesh.numTris)
			{
				if (SYS_MessageBox("Preserve Baseframe", MB_YESNO,
					"Cannibal can attempt to preserve your existing baseframe as much as possible\n"
					"by retaining the texture coordinates of those triangles with identical vertex\n"
					"positions in the new frame and the old reference frame.  To use this feature\n"
					"effectively, the frame you are importing should be virtually identical to the\n"
					"old reference frame, with the exception of triangles added or deleted.\n\n"
					"Do you want to try and preserve your baseframe?") == IDYES)
				{
					preserveBaseframe = 1;
					preserveNumVerts = mesh.numVerts;
					preserveNumTris = mesh.numTris;
					preserveVerts = ALLOC(vector_t, mesh.numVerts);
					preserveBaseTris = ALLOC(float, mesh.numTris*6);
					preserveMeshTris = ALLOC(int, mesh.numTris*3);
					baseTri_t *bt = refFrame->GetBaseTris();
					for (k=0;k<preserveNumTris;k++)
					{
						preserveMeshTris[k*3] = mesh.meshTris[k].verti[0];
						preserveMeshTris[k*3+1] = mesh.meshTris[k].verti[1];
						preserveMeshTris[k*3+2] = mesh.meshTris[k].verti[2];
						
						preserveBaseTris[k*6] = bt[k].tverts[0].x;
						preserveBaseTris[k*6+1] = bt[k].tverts[0].y;
						preserveBaseTris[k*6+2] = bt[k].tverts[1].x;
						preserveBaseTris[k*6+3] = bt[k].tverts[1].y;
						preserveBaseTris[k*6+4] = bt[k].tverts[2].x;
						preserveBaseTris[k*6+5] = bt[k].tverts[2].y;
					}
					frameVert_t *fv = refFrame->GetVerts();
					for (k=0;k<preserveNumVerts;k++)
					{
						preserveVerts[k] = fv[k].pos;
					}
				}
			}
			while (frames.Count())
				DeleteFrame(frames.First());
			f = AddFrame();
			if (f != refFrame)
				SYS_Error("LoadFrames: Desync");
			mesh.numTris = numtris;
			mesh.numVerts = numverts;
			for (k=0;k<mesh.numTris;k++)
			{
				mesh.meshTris[k].verti[0] = frameTris[k*3];
				mesh.meshTris[k].verti[1] = frameTris[k*3+1];
				mesh.meshTris[k].verti[2] = frameTris[k*3+2];
				mesh.meshTris[k].flags = 0;
                mesh.meshTris[k].aux1 = 128;
                mesh.meshTris[k].aux2 = 0;
			}
			for (k=0;k<mesh.numVerts;k++)
				mesh.mountPoints[k] = 0;
			mesh.EvaluateLinks();
		}
		else
		{
            if (ptr)
			{
				sprintf(buf, "%s_%s", SYS_GetFileRoot(filename), ptr);
			}
			else
			{
				sprintf(buf, "%s_%03d", SYS_GetFileRoot(filename), i);
			}
            boolean found = 0;
            MRL_ITERATENEXT(f2,f2,frames)
            {
                if (!_stricmp(f2->name, buf))
                {
                    found = 1;
                    break;
                }
            }
			if (!found)
            {
                f = AddFrame();
            }
            else
            {
				if (SYS_MessageBox("Replace frame", MB_YESNO,
					"Cannibal found a frame already loaded with the name \"%s\".\n"
                    "Do you wish to replace it?", f2->name) == IDYES)
                    f = f2;
                else
                    f = AddFrame();
            }
		}
		
		if (!f->Import(numverts, frameVerts+(i*numverts), numtris, frameTris))
		{
			DeleteFrame(f);
		}
		else
		{
            if (ptr)
			{
				sprintf(f->name, "%s_%s", SYS_GetFileRoot(filename), ptr);
				ptr += strlen(ptr)+1;
			}
			else
			{
				sprintf(f->name, "%s_%03d", SYS_GetFileRoot(filename), i);
			}
            
            char tempstr[2] = { 'a', 0 };
            boolean done = 1;
            MRL_ITERATENEXT(f2,f2,frames)
            {
                if ((f != f2) && !_stricmp(f2->name, f->name))
                {
                    done = 0;
                    strcat(f->name, tempstr);
                    break;
                }
            }
            int runaway = 100;
            while (!done)
            {
                done = 1;
                runaway++;
                if (runaway > 1000)
                    SYS_Error("Runaway loop in import");
                MRL_ITERATENEXT(f2,f2,frames)
                {
                    if ((f != f2) && !_stricmp(f2->name, f->name))
                    {
                        done = 0;
                        f->name[strlen(f->name)-1]++;
                        break;
                    }
                }
            }
		}
		frames.Sort(&model_t::DeleteFrame);

		if (preserveBaseframe)
		{
			int preserved = refFrame->PreserveBaseframe(preserveNumVerts, preserveVerts, preserveNumTris, preserveMeshTris, preserveBaseTris);
			if (!preserved)
				SYS_MessageBox("Preserve Baseframe", MB_OK, "Cannibal was not able to preserve any baseframe triangles.");
			else
				SYS_MessageBox("Preserve Baseframe", MB_OK, "Cannibal was able to preserve %d baseframe triangles\n"
				"(%.1f%% of original count, %.1f%% of new count)", preserved,
				((float)preserved*100.0 / (float)preserveNumTris),
				((float)preserved*100.0 / (float)mesh.numTris));
			
			FREE(preserveVerts);
			FREE(preserveBaseTris);
			FREE(preserveMeshTris);
			preserveBaseframe = 0;
		}
	}
	if (frameVerts)
		FREE(frameVerts);
	if (frameTris)
		FREE(frameTris);
	if (frameNames)
		FREE(frameNames);
	return(1);
}

int model_t::SaveMDX(char *filename)
{
	mdxChunkFile_t cf;
	byte *buffer;
	int i, m, numskins, validBits, totallen, writelen;
	float v;
	vector_t scales[WSFRAME_MAXGROUPS], translates[WSFRAME_MAXGROUPS];
	vector_t mins[WSFRAME_MAXGROUPS], maxs[WSFRAME_MAXGROUPS];
	vector_t bbMin[WSFRAME_MAXGROUPS], bbMax[WSFRAME_MAXGROUPS];
	byte vbyte;
	frameVert_t *fverts;
	meshTri_t *mtri;
	baseTri_t *ftris;
	mdxskin_t tSkin;
	mdxtri_t tTri;
	modelFrame_t *f;
	modelSequence_t *s;
	modelSkin_t *sk;
	vector_t *lnorms;
	int *lnormFactors;
	plane_t pln;
	char tbuffer[32];

	if (!filename)
		return(0);

	MDX_NewChunkFile(&cf, ASCFDNXMMARKER, ASCFDNXMVERSION);
	
	// CBLP chunk (Cannibal project data, not required by the models themselves)
	if (ovl_Windows)
	{
		OVL_SaveOverlay(NULL);
		MDX_AddChunk(&cf, "CBLP", "Cannibal", VCR_GetActionWriteLen(), MDX_CBLPVERSION, VCR_GetActionData());
	}

	// SKIN chunk
	numskins = 0;
	for (i=0;i<WS_MAXSKINS;i++)
		if (skins[i].flags & MRF_INUSE)
			numskins++;
	VCR_Record(VCRA_LOCAL, "$SKIN", NULL, numskins*sizeof(mdxskin_t)+4, &buffer);	
	VCR_WriteInt(numskins);
	
	for (i=0;i<WS_MAXSKINS;i++)
	{
		sk = &skins[i];
		if (!(sk->flags & MRF_INUSE))
			continue;
		tSkin.skinWidth = sk->tex->width;
		tSkin.skinHeight = sk->tex->height;
		tSkin.skinBitDepth = 16;
		memset(tSkin.skinFile, 0, sizeof(tSkin.skinFile));
		//strcpy(tSkin.skinFile, SYS_GetFileRoot(sk->name));
		strcpy(tSkin.skinFile,SYS_GetFileName(sk->name));
		VCR_WriteBulk(&tSkin, sizeof(mdxskin_t));
	}
	MDX_AddChunk(&cf, "SKIN", "MainSKIN", VCR_GetActionWriteLen(), 1, buffer);
	FREE(buffer);

	// All the remaining chunks require mesh/frame data to exist

	if ((!mesh.numTris) || (!mesh.numVerts) || (!refFrame))
	{
		MDX_SaveChunkFile(&cf, filename);
		MDX_FreeChunkFile(&cf);
		return(1);
	}

	for (f=frames.First();(f)&&(f!=refFrame);f=frames.Next(f))
		;
	if (!f)
		SYS_Error("SaveMDX: No valid reference frame");
	refFrame->CacheIn();
	fverts = refFrame->GetVerts();
	ftris = refFrame->GetBaseTris();
	if ((!fverts) || (!ftris))
	{
		MDX_SaveChunkFile(&cf, filename);
		MDX_FreeChunkFile(&cf);
		return(1);
	}

	// TRIS chunk
	VCR_Record(VCRA_LOCAL, "$TRIS", NULL, mesh.numTris*sizeof(mdxtri_t)+4, &buffer);
	VCR_WriteInt(mesh.numTris);
	for (i=0;i<mesh.numTris;i++)
	{
		tTri.vertIndex[0] = mesh.meshTris[i].verti[0];
		tTri.vertIndex[1] = mesh.meshTris[i].verti[1];
		tTri.vertIndex[2] = mesh.meshTris[i].verti[2];
		tTri.edgeIndex[0] = mesh.meshTris[i].edgeTris[0];
		tTri.edgeIndex[1] = mesh.meshTris[i].edgeTris[1];
		tTri.edgeIndex[2] = mesh.meshTris[i].edgeTris[2];
		tTri.flags = mesh.meshTris[i].flags;
		tTri.aux1 = mesh.meshTris[i].aux1;
        tTri.aux2 = mesh.meshTris[i].aux2;
		VCR_WriteBulk(&tTri, sizeof(mdxtri_t));
	}
	MDX_AddChunk(&cf, "TRIS", "MainTRIS", VCR_GetActionWriteLen(), 1, buffer);
	FREE(buffer);

	// MPNT chunk
	totallen = frames.Count()*sizeof(mdxmountframe_t) + sizeof(mdxmpntchunk_t);
	VCR_Record(VCRA_LOCAL, "$MPNT", NULL, totallen, &buffer);
	VCR_WriteInt(WS_MAXMOUNTS);
	VCR_WriteInt(frames.Count());
	validBits = 0;
	for (i=0;i<WS_MAXMOUNTS;i++)
	{
		if ((mounts[i].flags & MRF_INUSE) && (mounts[i]._triIndex != -1))
			validBits |= (1 << i);
	}
	VCR_WriteInt(validBits);
	for (i=0;i<WS_MAXMOUNTS;i++) // mdxmountpoint_t mountInfo[32]
	{
		if ((mounts[i].flags & MRF_INUSE) && (mounts[i]._triIndex != -1))
			VCR_WriteInt(mounts[i]._triIndex);
		else
			VCR_WriteInt(-1);
		VCR_WriteFloat(mounts[i].barys[0]);
		VCR_WriteFloat(mounts[i].barys[1]);
		VCR_WriteFloat(mounts[i].barys[2]);
		VCR_WriteFloat(mounts[i].axes[0].x);
		VCR_WriteFloat(mounts[i].axes[0].y);
		VCR_WriteFloat(mounts[i].axes[0].z);
		VCR_WriteFloat(mounts[i].axes[1].x);
		VCR_WriteFloat(mounts[i].axes[1].y);
		VCR_WriteFloat(mounts[i].axes[1].z);
		VCR_WriteFloat(mounts[i].axes[2].x);
		VCR_WriteFloat(mounts[i].axes[2].y);
		VCR_WriteFloat(mounts[i].axes[2].z);
		VCR_WriteFloat(mounts[i].scale.x);
		VCR_WriteFloat(mounts[i].scale.y);
		VCR_WriteFloat(mounts[i].scale.z);
		VCR_WriteFloat(mounts[i].attachOrigin.x);
		VCR_WriteFloat(mounts[i].attachOrigin.y);
		VCR_WriteFloat(mounts[i].attachOrigin.z);
	}
	MRL_ITERATENEXT(f,f,frames) // mdxmountframe_t mountFrames[numFrames]
	{
		memset(tbuffer, 0, 32);
		strncpy(tbuffer, f->name, 31);
		VCR_WriteBulk(tbuffer, 32);
		VCR_WriteInt(validBits); // FIXME: check verts to see if mount is valid for frame first
		for (i=0;i<WS_MAXMOUNTS;i++)
		{
			if (!(mounts[i].flags & MRF_INUSE))
			{
				VCR_WriteBulk(NULL, 3*sizeof(float));
			}
			else
			{
				writelen = VCR_GetActionWriteLen();
				mounts[i].SetFrame(f); // might change VCR status, need to reinitialize it
				mounts[i].UpdateTransform(sys_curTime, true);
				VCR_PlaybackLocal(&buffer, totallen);
				VCR_SetActionWriteLen(writelen);
				VCR_WriteFloat(mounts[i]._translate.x);
				VCR_WriteFloat(mounts[i]._translate.y);
				VCR_WriteFloat(mounts[i]._translate.z);
			}
		}
		for (i=0;i<WS_MAXMOUNTS;i++)
		{
			if (!(mounts[i].flags & MRF_INUSE))
			{
				VCR_WriteBulk(NULL, 3*3*sizeof(float));
			}
			else
			{
				writelen = VCR_GetActionWriteLen();
				mounts[i].SetFrame(f);
				mounts[i].UpdateTransform(sys_curTime, true);
				VCR_PlaybackLocal(&buffer, totallen);
				VCR_SetActionWriteLen(writelen);
				VCR_WriteFloat(mounts[i]._rotate.Data[0][0]);
				VCR_WriteFloat(mounts[i]._rotate.Data[0][1]);
				VCR_WriteFloat(mounts[i]._rotate.Data[0][2]);
				VCR_WriteFloat(mounts[i]._rotate.Data[1][0]);
				VCR_WriteFloat(mounts[i]._rotate.Data[1][1]);
				VCR_WriteFloat(mounts[i]._rotate.Data[1][2]);
				VCR_WriteFloat(mounts[i]._rotate.Data[2][0]);
				VCR_WriteFloat(mounts[i]._rotate.Data[2][1]);
				VCR_WriteFloat(mounts[i]._rotate.Data[2][2]);
			}
		}
	}
	MDX_AddChunk(&cf, "MPNT", "MainMPNT", VCR_GetActionWriteLen(), 1, buffer);

	// RFRM chunk
	VCR_Record(VCRA_LOCAL, "$RFRM", NULL,
		refFrame->numVerts*sizeof(mdxvert_t) + refFrame->numTris*sizeof(mdxtvert_t)*3 + refFrame->numTris + sizeof(mdxrfrmchunk_t), &buffer);
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		scales[i] = 0; translates[i] = 0;
		mins[i] = FLT_MAX, maxs[i] = -FLT_MAX;
		bbMin[i] = 0, bbMax[i] = 0;
	}
	if (fverts)
	{
		for (i=0;i<refFrame->numVerts;i++)
		{
			if (fverts[i].pos.x < mins[fverts[i].groupNum].x) mins[fverts[i].groupNum].x = fverts[i].pos.x;
			if (fverts[i].pos.y < mins[fverts[i].groupNum].y) mins[fverts[i].groupNum].y = fverts[i].pos.y;
			if (fverts[i].pos.z < mins[fverts[i].groupNum].z) mins[fverts[i].groupNum].z = fverts[i].pos.z;
			if (fverts[i].pos.x > maxs[fverts[i].groupNum].x) maxs[fverts[i].groupNum].x = fverts[i].pos.x;
			if (fverts[i].pos.y > maxs[fverts[i].groupNum].y) maxs[fverts[i].groupNum].y = fverts[i].pos.y;
			if (fverts[i].pos.z > maxs[fverts[i].groupNum].z) maxs[fverts[i].groupNum].z = fverts[i].pos.z;
		}
	}
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		scales[i] = (maxs[i] - mins[i])/255.0;
		VCR_WriteFloat(scales[i].x);
		VCR_WriteFloat(scales[i].y);
		VCR_WriteFloat(scales[i].z);
	}
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		translates[i] = mins[i];
		VCR_WriteFloat(translates[i].x);
		VCR_WriteFloat(translates[i].y);
		VCR_WriteFloat(translates[i].z);
	}
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		bbMin[i] = mins[i];
		VCR_WriteFloat(bbMin[i].x);
		VCR_WriteFloat(bbMin[i].y);
		VCR_WriteFloat(bbMin[i].z);
	}
	for (i=0;i<WSFRAME_MAXGROUPS;i++)
	{
		bbMax[i] = maxs[i];
		VCR_WriteFloat(bbMax[i].x);
		VCR_WriteFloat(bbMax[i].y);
		VCR_WriteFloat(bbMax[i].z);
	}
	VCR_WriteInt(refFrame->numVerts);
	VCR_WriteInt(refFrame->numTris);
	lnorms = ALLOC(vector_t, refFrame->numVerts);
	lnormFactors = ALLOC(int, refFrame->numVerts);
	memset(lnorms, 0, refFrame->numVerts*sizeof(vector_t));
	memset(lnormFactors, 0, refFrame->numVerts*sizeof(int));
	for (i=0;i<mesh.numTris;i++)
	{
		mtri = &mesh.meshTris[i];
		if (!(mtri->flags & TF_NOVERTLIGHT))
		{
			pln.TriExtract(fverts[mtri->verti[0]].pos, fverts[mtri->verti[1]].pos, fverts[mtri->verti[2]].pos);
			for (m=0;m<3;m++)
			{
				lnorms[mtri->verti[m]] += pln.n;
				lnormFactors[mtri->verti[m]]++;
			}
		}
	}
	if (fverts)
	{
		for (i=0;i<refFrame->numVerts;i++)
		{
			VCR_WriteByte(fverts[i].groupNum | (fverts[i].flags & FVF_P_LODLOCKED));
			for (m=0;m<3;m++)
			{
				v = floor(((fverts[i].pos.v[m] - translates[fverts[i].groupNum].v[m]) / scales[fverts[i].groupNum].v[m]) + 0.5);
				if (v > 255) v = 255;
				if (v < 0) v = 0;
				vbyte = v;
				VCR_WriteByte(vbyte);
			}
			lnorms[i] /= lnormFactors[i];
			lnorms[i].Normalize();
			for (m=0;m<3;m++)
			{
				vbyte = fabs(lnorms[i].v[m]*127);
				if (lnorms[i].v[m] < 0)
					vbyte |= 128;
				VCR_WriteByte(vbyte);
			}
			VCR_WriteByte(mesh.mountPoints[i]); //VCR_WriteByte(verts[i].mountIndex); // force to origin mount point for now
		}
	}
	FREE(lnorms);
	FREE(lnormFactors);
	if (ftris)
	{
		for (i=0;i<refFrame->numTris;i++)
		{
			VCR_WriteShort((short)ftris[i].tverts[0].x);
			VCR_WriteShort((short)ftris[i].tverts[0].y);
			VCR_WriteShort((short)ftris[i].tverts[1].x);
			VCR_WriteShort((short)ftris[i].tverts[1].y);
			VCR_WriteShort((short)ftris[i].tverts[2].x);
			VCR_WriteShort((short)ftris[i].tverts[2].y);		
		}
		for (i=0;i<refFrame->numTris;i++)
		{
			VCR_WriteByte((byte)ftris[i].skinIndex);
		}
	}
	refFrame->flags &= ~MRF_MODIFIED;
	MDX_AddChunk(&cf, "RFRM", refFrame->name, VCR_GetActionWriteLen(), 1, buffer);
	FREE(buffer);

	// FRMD chunks
	MRL_ITERATENEXT(f,f,frames)
	{
		if (f==refFrame)
			continue;
		f->Compress();
		MDX_AddChunk(&cf, "FRMD", f->name, f->frmdDataLen, 1, f->frmdData);
		f->flags &= ~MRF_MODIFIED;
	}

	// FSEQ chunks
	// "ALL" sequence
#if 0 // version 2	
	VCR_Record(VCRA_LOCAL, "$FSEQ", NULL, frames.Count()*sizeof(mdxSeqBlock_t) + 4, &buffer);
	VCR_WriteInt(frames.Count());
	MRL_ITERATENEXT(f,f,frames)
	{
		VCR_WriteInt(f->index*100);
		VCR_WriteInt(100);
		VCR_WriteInt(0);
		VCR_WriteInt(0);
		memset(tbuffer, 0, 32);
		strncpy(tbuffer, f->name, 31);
		VCR_WriteBulk(tbuffer, 32);
	}
	MDX_AddChunk(&cf, "FSEQ", "ALL", VCR_GetActionWriteLen(), 2, buffer);
	FREE(buffer);
#endif
	// version 3
	VCR_Record(VCRA_LOCAL, "$FSEQ", NULL, frames.Count()*sizeof(mdxSeqBlock_v3_t) + 8, &buffer);
	VCR_WriteFloat(10.0);
	VCR_WriteInt(frames.Count());
	MRL_ITERATENEXT(f,f,frames)
	{
		memset(tbuffer, 0, 32);
		strncpy(tbuffer, f->name, 31);
		VCR_WriteBulk(tbuffer, 32);
		VCR_WriteFloat(0);
		VCR_WriteInt(0);
	}
	MDX_AddChunk(&cf, "FSEQ", "ALL", VCR_GetActionWriteLen(), 3, buffer);
	FREE(buffer);
    // reference frame sequence
    VCR_Record(VCRA_LOCAL, "$FSEQ", NULL, sizeof(mdxSeqBlock_v3_t) + 8, &buffer);
    VCR_WriteFloat(10.0);
    VCR_WriteInt(1);
    memset(tbuffer, 0, 32);
    strncpy(tbuffer, refFrame->name, 31);
    VCR_WriteBulk(tbuffer, 32);
	VCR_WriteFloat(0);
	VCR_WriteInt(0);
	MDX_AddChunk(&cf, "FSEQ", "REFERENCE", VCR_GetActionWriteLen(), 3, buffer);
	FREE(buffer);

#if 0 // version 2
	// other sequences
	MRL_ITERATENEXT(s,s,seqs)
	{
		seqItem_t *item;
		int blen = 0;
		int ttotal = 0, ptotal = s->numItems*sizeof(mdxSeqBlock_v3_t)+4;

		for (item=s->items.next;item!=&s->items;item=item->next)
		{
			blen += sizeof(mdxSeqBlock_v3_t);
			if (item->trigger)
				blen += strlen(item->trigger)+1;
		}
		VCR_Record(VCRA_LOCAL, "$FSEQ", NULL, blen + 4, &buffer);
		VCR_WriteInt(s->numItems);
		for (item=s->items.next;item!=&s->items;item=item->next)
		{
			VCR_WriteInt(ttotal);
			VCR_WriteInt(item->duration);
			ttotal += item->duration;
			if (item->trigger)
			{
				VCR_WriteInt(ptotal);
				ptotal += strlen(item->trigger)+1;
			}
			else
				VCR_WriteInt(0);
			VCR_WriteInt(0); // no flags for now
			memset(tbuffer, 0, 32);
			strncpy(tbuffer, item->setFrame->name, 31);
			VCR_WriteBulk(tbuffer, 32);
		}
		for (item=s->items.next;item!=&s->items;item=item->next)
		{
			if (item->trigger)
				VCR_WriteString(item->trigger);
		}
		MDX_AddChunk(&cf, "FSEQ", s->name, VCR_GetActionWriteLen(), 2, buffer);
		FREE(buffer);
	}
#endif
	// version 3
	// other sequences
	MRL_ITERATENEXT(s,s,seqs)
	{
		seqItem_t *item;
		seqTrigger_t *trigger;
		int ptotal = (s->numItems+s->numTriggers)*sizeof(mdxSeqBlock_v3_t)+8;
		int blen = ptotal;
		for (trigger=s->triggers.next;trigger!=&s->triggers;trigger=trigger->next)
		{
			if (trigger->trigger)
				blen += strlen(trigger->trigger)+1;
			if (trigger->triggerBinData)
				blen += trigger->triggerBinSize+5;
		}
		VCR_Record(VCRA_LOCAL, "$FSEQ", NULL, blen, &buffer);
		VCR_WriteFloat(s->framesPerSecond);
		VCR_WriteInt(s->numItems+s->numTriggers);
		for (item=s->items.next;item!=&s->items;item=item->next)
		{
			memset(tbuffer, 0, 32);
			strncpy(tbuffer, item->setFrame->name, 31);
			VCR_WriteBulk(tbuffer, 32);
			VCR_WriteFloat(0);
			VCR_WriteInt(0);
		}
		for (trigger=s->triggers.next;trigger!=&s->triggers;trigger=trigger->next)
		{
			memset(tbuffer, 0, 32);
			VCR_WriteBulk(tbuffer, 32);
			VCR_WriteFloat(trigger->trigTimeFrac);
			if (trigger->trigger || trigger->triggerBinData)
			{
				VCR_WriteInt(ptotal);
				if (trigger->trigger)
					ptotal += strlen(trigger->trigger)+1;
				if (trigger->triggerBinData)
					ptotal += trigger->triggerBinSize+5;
			}
			else
				VCR_WriteInt(0);
		}
		for (trigger=s->triggers.next;trigger!=&s->triggers;trigger=trigger->next)
		{
			if (trigger->trigger)
				VCR_WriteString(trigger->trigger);
			if (trigger->triggerBinData)
			{
				VCR_WriteByte(0xFF); // indicates binary stream follows
				VCR_WriteInt(trigger->triggerBinSize);
				VCR_WriteBulk(trigger->triggerBinData, trigger->triggerBinSize);
			}
		}
		MDX_AddChunk(&cf, "FSEQ", s->name, VCR_GetActionWriteLen(), 3, buffer);
		FREE(buffer);
	}

	// MRGD chunk (optional MRGPlay data chunk)
	if ((lodData) && (lodActive) && (lodDataSize))
	{
		MDX_AddChunk(&cf, "MRGD", "MainMRGD", lodDataSize, 1, lodData);
	}

	MDX_SaveChunkFile(&cf, filename);
	MDX_FreeChunkFile(&cf);
	return(1);
}

U32 LoadSkin(modelSkin_t *skin,CC8 *filename,CC8 *pathname)
{
	CPathRef &path=skin->path;
	CC8 *fullname;

	path.init(filename,pathname);

	U32 exist=FALSE;
	U32 ext=SYS_GetImageTypeFromExt(path->get_extension());

	if (!ext)
	{
		U32 has_bmp,has_tga;

		path.set_extension("bmp");
		if (has_bmp=path->file_exist())
			ext=SYS_IMAGE_TYPE_BMP;
		path.set_extension("tga");
		if (has_tga=path->file_exist())
			ext=SYS_IMAGE_TYPE_TGA;
		if ((has_bmp) && (has_tga))
		{
			if (SYS_MessageBox("Texture file ambiguity",MB_YESNO,
				"LoadMDX: There is a filename ambiguity with the texture %s.\n"
				"Would you like to resolve it?",filename))
			{
				if (!(fullname = SYS_OpenFileBox("Image Files (*.bmp,*.tga)\0" "*.bmp;*.tga\0" "24-bit Bitmap Files (*.bmp)\0" "*.bmp\0" "32-bit Targa Files (*.tga)\0" "*.tga\0\0", "Open Skin",null)))
					return FALSE;
				ext=SYS_GetImageExtension(fullname);
				path.set_absolute(fullname);
			}
			else
				return FALSE;
		}
		else if (has_bmp)
		{
			/* restore bmp if it is a bmp */
			path.set_extension("bmp");
		}

		exist=has_bmp|has_tga;
	}
	else
		exist=(U32)path->file_exist();
	if (!exist)
	{
		if (SYS_MessageBox("Cannot Find Skin", MB_YESNO,"LoadMDX: Could not find skin \"%s\" for loading.\n" "Skins should be in the same directory as the MDX in order to load by default.\n\n" "Would you like to locate the skin?", filename) != IDYES)
			return FALSE;
		if (!(fullname = SYS_OpenFileBox("Image Files (*.bmp,*.tga)\0" "*.bmp;*.tga\0" "24-bit Bitmap Files (*.bmp)\0" "*.bmp\0" "32-bit Targa Files (*.tga)\0" "*.tga\0\0", "Open Skin",null)))
			return FALSE;
		path.set_absolute(fullname);
	}
	skin->tex=vid.TexLoad(path,false);
	if (!skin->tex)
	{
		SYS_MessageBox("Unable to load skin",MB_OK,
						"LoadMDX: Unable to open skin");
		return FALSE;
	}
	strcpy(skin->name,path->get_path());
	return TRUE;
}

int model_t::LoadMDX(char *filename, boolean useProjectData)
{
	mdxChunkFile_t cf;
	mdxskin_t tSkin;
	modelFrame_t *f;
	modelSequence_t *s;
	modelSkin_t *sk;
	seqItem_t *item;

	int i, count, version, bpos, tpos, validBits;
	ascfentrylink_t *cblpChunk, *skinChunk, *trisChunk, *mpntChunk, *rfrmChunk, *frmdChunk, *fseqChunk, *mrgdChunk;
	int cblpLen, skinLen, trisLen, mpntLen, rfrmLen, frmdLen, fseqLen, mrgdLen;
	char tbuffer[64];

	if (!filename)
		return(0);
	if (!MDX_LoadChunkFile(&cf, filename, ASCFDNXMMARKER, ASCFDNXMVERSION))
	{
		CON->Printf("Cannot load \"%s\", file is invalid or not present", filename);
		SYS_MessageBox("LoadMDX", MB_OK, "Cannot load \"%s\", file is invalid or not present", filename);
		return(0);
	}

	// Get rid of old data
	if (lodData)
		FREE(lodData);
	lodActive = false;
	lodDataSize = 0;
	for (i=0;i<WS_MAXMOUNTS;i++)
		mounts[i].flags &= ~MRF_INUSE;
	frames.DeleteAll();
	for (i=0;i<WS_MAXSKINS;i++)
		skins[i].flags &= ~MRF_INUSE;
	seqs.DeleteAll();
	refFrame = NULL;
	mesh.numTris = mesh.numVerts = 0;
	ws = NULL;

	// See if there's any project data with the MDX
	if (useProjectData)
	{
		cblpChunk = MDX_FindChunk(&cf, NULL, "CBLP", NULL, &cblpLen, &version);
		if ((cblpChunk) && (version == MDX_CBLPVERSION))
		{
			if ((!_stricmp(SYS_GetFileRoot(filename), "_backup_")) || (SYS_MessageBox("MDX Cannibal Project Info", MB_YESNO,
				"This file has compatible Cannibal Project information stored.  Do you wish to use it?") == IDYES))
			{
				VCR_Record(VCRA_CLIPBOARD, "$overlay", NULL, cblpLen, NULL);
				if (!VCR_WriteBulk((byte *)cblpChunk->data, cblpLen))
				{
					CON->Printf("LoadMDX: Unable to load project data");
				}
				else
				{
					OVL_LoadOverlay(NULL); // this model dies with the workspace
					if (ovl_Windows)
					{
						int res;
						MDX_FreeChunkFile(&cf);
						res = ((OWorkspace *)ovl_Windows)->mdx->LoadMDX(filename, false);
						if (res)
						{
							strcpy(((OWorkspace *)ovl_Windows)->mdxName, filename);
							((OWorkspace *)ovl_Windows)->mdx->ws = (OWorkspace *)ovl_Windows;
						}
						return(res);
					}
				}
			}
			else
			{
				int res;
				if (ovl_Windows)
					delete ovl_Windows; // this model dies with the workspace
				ovl_Windows = NULL;
				OVL_CreateRootWindow();
				MDX_FreeChunkFile(&cf);
				res = ((OWorkspace *)ovl_Windows)->mdx->LoadMDX(filename, false);
				if (res)
				{
					strcpy(((OWorkspace *)ovl_Windows)->mdxName, filename);
					((OWorkspace *)ovl_Windows)->mdx->ws = (OWorkspace *)ovl_Windows;
				}
				return(res);
			}
		}
	}

	skinChunk = MDX_FindChunk(&cf, NULL, "SKIN", NULL, &skinLen, &version);
	if ((skinChunk) && (version == 1))
	{
		// SKIN chunk
		VCR_PlaybackLocal((byte **)&skinChunk->data, skinLen);
		count = VCR_ReadInt();
		if (count > WS_MAXSKINS)
			count = WS_MAXSKINS;

		CC8 *file_path=SYS_GetFilePath(filename);
		for (i=0;i<count;i++)
		{
			VCR_ReadBulk(&tSkin, sizeof(mdxskin_t));
			sk = AddSkin(i);
			
			if (!LoadSkin(sk,tSkin.skinFile,file_path))
				DeleteSkin(sk);
		}
	}

	// if either the tris chunk or reference frame isn't there, the remaining chunks don't matter
	trisChunk = MDX_FindChunk(&cf, NULL, "TRIS", NULL, &trisLen, &version);
	if ((!trisChunk) || (version != 1))
	{ 
		MDX_FreeChunkFile(&cf);
		return(1);
	}
	rfrmChunk = MDX_FindChunk(&cf, NULL, "RFRM", NULL, &rfrmLen, &version);
	if ((!rfrmChunk) || (version != 1))
	{ 
		MDX_FreeChunkFile(&cf);
		return(1);
	}

	// TRIS chunk
	VCR_PlaybackLocal((byte **)&trisChunk->data, trisLen);
	mesh.numTris = VCR_ReadInt();
	for (i=0;i<mesh.numTris;i++)
	{
		mesh.meshTris[i].verti[0] = VCR_ReadShort();
		mesh.meshTris[i].verti[1] = VCR_ReadShort();
		mesh.meshTris[i].verti[2] = VCR_ReadShort();
		mesh.meshTris[i].edgeTris[0] = VCR_ReadShort();
		mesh.meshTris[i].edgeTris[1] = VCR_ReadShort();
		mesh.meshTris[i].edgeTris[2] = VCR_ReadShort();
		mesh.meshTris[i].flags = VCR_ReadShort();
		mesh.meshTris[i].aux1 = VCR_ReadByte();
		mesh.meshTris[i].aux2 = VCR_ReadByte();
        if (!mesh.meshTris[i].aux1)
            mesh.meshTris[i].aux1 = 128; // 0.5 alpha transparency
	}
	mesh.EvaluateLinks(); // recalculate edge links just incase

	// MPNT chunk
	mpntChunk = MDX_FindChunk(&cf, NULL, "MPNT", NULL, &mpntLen, &version);
	if ((mpntChunk) && (version == 1))
	{
		VCR_PlaybackLocal((byte **)&mpntChunk->data, mpntLen);
		i = VCR_ReadInt();
		if (i == WS_MAXMOUNTS)
		{
			count = VCR_ReadInt(); // frame count, ignored
			validBits = VCR_ReadInt();
			for (i=0;i<WS_MAXMOUNTS;i++)
			{
				mounts[i].flags = 0;
				if (validBits & (1 << i))
					mounts[i].flags = MRF_INUSE;
			}
			for (i=0;i<WS_MAXMOUNTS;i++) // mdxmountpoint_t mountInfo[32]
			{
				int tri;
				
				tri = VCR_ReadInt();
				mounts[i].SetTriangle(tri);
				mounts[i].barys[0] = VCR_ReadFloat();
				mounts[i].barys[1] = VCR_ReadFloat();
				mounts[i].barys[2] = VCR_ReadFloat();
				mounts[i].axes[0].x = VCR_ReadFloat();
				mounts[i].axes[0].y = VCR_ReadFloat();
				mounts[i].axes[0].z = VCR_ReadFloat();
				mounts[i].axes[1].x = VCR_ReadFloat();
				mounts[i].axes[1].y = VCR_ReadFloat();
				mounts[i].axes[1].z = VCR_ReadFloat();
				mounts[i].axes[2].x = VCR_ReadFloat();
				mounts[i].axes[2].y = VCR_ReadFloat();
				mounts[i].axes[2].z = VCR_ReadFloat();
				mounts[i].scale.x = VCR_ReadFloat();
				mounts[i].scale.y = VCR_ReadFloat();
				mounts[i].scale.z = VCR_ReadFloat();
				mounts[i].attachOrigin.x = VCR_ReadFloat();
				mounts[i].attachOrigin.y = VCR_ReadFloat();
				mounts[i].attachOrigin.z = VCR_ReadFloat();
			}
		}
		// following the mountInfo are the frame precalculations, which are ignored
	}

	// RFRM chunk
	f = AddFrame();
	SetReference(f);
	mesh.numVerts = ((mdxrfrmchunk_t *)rfrmChunk->data)->numVerts;
	for (i=0;i<mesh.numVerts;i++)
		mesh.mountPoints[i] = 0;
	f->LoadMDXChunk(rfrmChunk);
	strcpy(f->name, rfrmChunk->entry.chunkInstance);

	// FRMD chunks
	frmdChunk = NULL;
	while ((frmdChunk = MDX_FindChunk(&cf, frmdChunk, "FRMD", NULL, &frmdLen, &version)) && (version == 1))
	{
		f = AddFrame();
		f->LoadMDXChunk(frmdChunk);
		strcpy(f->name, frmdChunk->entry.chunkInstance);
	}

	frames.Sort(&model_t::DeleteFrame);

	// FSEQ chunks
	fseqChunk = NULL;
	while (fseqChunk = MDX_FindChunk(&cf, fseqChunk, "FSEQ", NULL, &fseqLen, &version))
	{
		if (version == 2)
		{
			if (!_stricmp(fseqChunk->entry.chunkInstance, "ALL"))
				continue;
			if (!_stricmp(fseqChunk->entry.chunkInstance, "REFERENCE"))
				continue;
			VCR_PlaybackLocal((byte **)&fseqChunk->data, fseqLen);
			s = AddSequence();
			strcpy(s->name, fseqChunk->entry.chunkInstance);
			s->framesPerSecond = -1.0;
			count = VCR_ReadInt();
			for (i=0;i<count;i++)
			{
				item = s->AddItem(NULL);
				VCR_ReadInt();
				if (s->framesPerSecond < 0.0)
					s->framesPerSecond = 1000.0 / VCR_ReadInt();
				else
					VCR_ReadInt();
				tpos = VCR_ReadInt();
				// ignore oldskool frame triggers
				/*
				if (tpos)
				{
					bpos = VCR_GetActionReadLen();
					VCR_SetActionReadLen(tpos);
					item->trigger = ALLOC(char, strlen((char *)fseqChunk->data + tpos)+1);
					strcpy(item->trigger, VCR_ReadString());
					VCR_SetActionReadLen(bpos);
				}
				*/
				VCR_ReadInt();
				VCR_ReadBulk(tbuffer, 32);
				MRL_ITERATENEXT(f,f,frames)
				{
					if (!_stricmp(f->name, tbuffer))
						item->setFrame = f;
				}
				if (!item->setFrame)
					s->DeleteItem(item);
			}
		}
		else if (version == 3)
		{
			float tfrac;
			seqTrigger_t *trigger;

			if (!_stricmp(fseqChunk->entry.chunkInstance, "ALL"))
				continue;
			if (!_stricmp(fseqChunk->entry.chunkInstance, "REFERENCE"))
				continue;
			VCR_PlaybackLocal((byte **)&fseqChunk->data, fseqLen);
			s = AddSequence();
			strcpy(s->name, fseqChunk->entry.chunkInstance);
			s->framesPerSecond = VCR_ReadFloat();
			count = VCR_ReadInt();
			for (i=0;i<count;i++)
			{
				VCR_ReadBulk(tbuffer, 32);
				tfrac = VCR_ReadFloat();
				tpos = VCR_ReadInt();
				if (tbuffer[0])
				{
					item = s->AddItem(NULL);
					MRL_ITERATENEXT(f,f,frames)
					{
						if (!_stricmp(f->name, tbuffer))
							item->setFrame = f;
					}
					if (!item->setFrame)
						s->DeleteItem(item);
				}
				else
				if (tpos)
				{
					trigger = s->AddTrigger();
					bpos = VCR_GetActionReadLen();
					VCR_SetActionReadLen(tpos);
					trigger->trigTimeFrac = tfrac;
					if (trigger->trigger)
						FREE(trigger->trigger);
					trigger->trigger = ALLOC(char, strlen((char *)fseqChunk->data + tpos)+1);
					strcpy(trigger->trigger, VCR_ReadString());
					if (trigger->triggerBinData)
						FREE(trigger->triggerBinData);
					trigger->triggerBinData = NULL;
					trigger->triggerBinSize = 0;
					if (VCR_ReadRemaining() && (VCR_ReadByte() == 0xFF))
					{
						trigger->triggerBinSize = VCR_ReadInt();
						trigger->triggerBinData = ALLOC(byte, trigger->triggerBinSize);
						VCR_ReadBulk(trigger->triggerBinData, trigger->triggerBinSize);
					}
					VCR_SetActionReadLen(bpos);
				}
			}
		}
	}

	// MRGD chunk (optional MRGPlay data chunk)
	mrgdChunk = MDX_FindChunk(&cf, NULL, "MRGD", NULL, &mrgdLen, &version);
	if ((mrgdChunk) && (version == 1))
	{
		VCR_PlaybackLocal((byte **)&mrgdChunk->data, mrgdLen);
		lodDataSize = mrgdLen;
		lodData = ALLOC(byte, lodDataSize);
		VCR_ReadBulk(lodData, lodDataSize);
		lodActive = true;
	}

	// Done
	MDX_FreeChunkFile(&cf);
	return(1);
}


//****************************************************************************
//**
//**    END CLASS model_t
//**
//****************************************************************************

//****************************************************************************
//**
//**    END MODULE OVL_MDL.CPP
//**
//****************************************************************************

