//****************************************************************************
//**
//**    CPJFRM.CPP
//**    Cannibal Models - Vertex Frames
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "CpjFrm.h"
#include <time.h>

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
/*
	CCpjFrmFrame
*/
NDword CCpjFrmFrame::GetNumPositions()
{
	if (m_isCompressed)
		return(m_BytePos.GetCount());
	return(m_PurePos.GetCount());
}
VVec3 CCpjFrmFrame::GetPosition(NDword inIndex)
{
	if (!m_isCompressed)
		return(m_PurePos[inIndex]);
	CCpjFrmBytePos* b = &m_BytePos[inIndex];
	CCpjFrmGroup* g = &m_Groups[b->group];
	VVec3 v;
	v.x = ((NFloat)b->pos[0] * g->scale.x) + g->translate.x;
	v.y = ((NFloat)b->pos[1] * g->scale.y) + g->translate.y;
	v.z = ((NFloat)b->pos[2] * g->scale.z) + g->translate.z;
	return(v);
}
NBool CCpjFrmFrame::UpdateBounds()
{
	m_Bounds[0] = VVec3(FLT_MAX,FLT_MAX,FLT_MAX);
	m_Bounds[1] = VVec3(-FLT_MAX,-FLT_MAX,-FLT_MAX);

	if (!m_isCompressed)
	{
		VVec3 v;
		NDword numVerts = m_PurePos.GetCount();
		for (NDword i=0;i<numVerts;i++)
		{
			v = m_PurePos[i];
			if (v.x < m_Bounds[0].x) m_Bounds[0].x = v.x;
			if (v.y < m_Bounds[0].y) m_Bounds[0].y = v.y;
			if (v.z < m_Bounds[0].z) m_Bounds[0].z = v.z;
			if (v.x > m_Bounds[1].x) m_Bounds[1].x = v.x;
			if (v.y > m_Bounds[1].y) m_Bounds[1].y = v.y;
			if (v.z > m_Bounds[1].z) m_Bounds[1].z = v.z;
		}
	}
	else
	{
		VVec3 v;
		CCpjFrmGroup* g;
		NDword numVerts = m_BytePos.GetCount();
		for (NDword i=0;i<numVerts;i++)
		{
			g = &m_Groups[m_BytePos[i].group];
			v.x = (m_BytePos[i].pos[0] * g->scale.x) + g->translate.x;
			v.y = (m_BytePos[i].pos[1] * g->scale.y) + g->translate.y;
			v.z = (m_BytePos[i].pos[2] * g->scale.z) + g->translate.z;
			if (v.x < m_Bounds[0].x) m_Bounds[0].x = v.x;
			if (v.y < m_Bounds[0].y) m_Bounds[0].y = v.y;
			if (v.z < m_Bounds[0].z) m_Bounds[0].z = v.z;
			if (v.x > m_Bounds[1].x) m_Bounds[1].x = v.x;
			if (v.y > m_Bounds[1].y) m_Bounds[1].y = v.y;
			if (v.z > m_Bounds[1].z) m_Bounds[1].z = v.z;
		}
	}
	return(1);
}
NBool CCpjFrmFrame::InitPositions(NDword inNumPos)
{
	m_Groups.Purge(); m_Groups.Shrink();
	m_BytePos.Purge(); m_BytePos.Shrink();
	m_PurePos.Purge(); m_PurePos.Shrink(); m_PurePos.AddNoConstruct(inNumPos);
	memset(&m_PurePos[0], 0, inNumPos*sizeof(VVec3));
	m_isCompressed = 0;
	return(1);
}
NBool CCpjFrmFrame::Compress(OCpjGeometry* inGeom)
{
	if (m_isCompressed)
		return(1);
	
	// make sure vertex count matches geometry
	NDword numVerts = m_PurePos.GetCount();
	if (!numVerts)
		return(0);
	if (inGeom->m_Verts.GetCount() != numVerts)
		return(0);

	// calculate bounding boxes and find highest group used

	static VVec3 groupBounds[256][2]; // 256 is the maximum number of groups since it's stored as a byte in geometry
	for (NDword i=0;i<256;i++)
	{
		groupBounds[i][0] = VVec3(FLT_MAX,FLT_MAX,FLT_MAX);
		groupBounds[i][1] = VVec3(-FLT_MAX,-FLT_MAX,-FLT_MAX);
	}
	
	VVec3 v;
	NDword group, maxGroup = 0;
	for (i=0;i<numVerts;i++)
	{				
		v = m_PurePos[i];
		group = (NDword)inGeom->m_Verts[i].groupIndex;
		if (maxGroup < group)
			maxGroup = group;

		// update group bounds
		if (v.x < groupBounds[group][0].x) groupBounds[group][0].x = v.x;
		if (v.y < groupBounds[group][0].y) groupBounds[group][0].y = v.y;
		if (v.z < groupBounds[group][0].z) groupBounds[group][0].z = v.z;
		if (v.x > groupBounds[group][1].x) groupBounds[group][1].x = v.x;
		if (v.y > groupBounds[group][1].y) groupBounds[group][1].y = v.y;
		if (v.z > groupBounds[group][1].z) groupBounds[group][1].z = v.z;
	}

	// allocate as many groups as necessary
	m_Groups.Add(maxGroup+1);

	// set up group compression info
	for (i=0;i<m_Groups.GetCount();i++)
	{
		m_Groups[i].scale = (groupBounds[i][1] - groupBounds[i][0]) / 255.0;
		m_Groups[i].translate = groupBounds[i][0];
	}

	// build byte positions
	NDword j;
	m_BytePos.Add(numVerts);
	for (i=0;i<numVerts;i++)
	{
		v = m_PurePos[i];
		group = inGeom->m_Verts[i].groupIndex;
		m_BytePos[i].group = (NByte)group;
		for (j=0;j<3;j++)
		{
			NFloat f = (NFloat)floor(((v[j] - m_Groups[group].translate[j]) / m_Groups[group].scale[j]) + 0.5);
			if (f > 255) f = 255;
			if (f < 0) f = 0;
			m_BytePos[i].pos[j] = (NByte)f;
		}
	}

	// finish up
	m_PurePos.Purge(); m_PurePos.Shrink();
	m_isCompressed = 1;

	return(1);
}
NBool CCpjFrmFrame::Decompress()
{
	if (!m_isCompressed)
		return(1);

	NDword numVerts = m_BytePos.GetCount();
	if (!numVerts)
		return(0);
	
	// build pure positions
	CCpjFrmBytePos* b;
	CCpjFrmGroup* g;
	VVec3* v;
	m_PurePos.AddNoConstruct(numVerts);
	for (NDword i=0;i<numVerts;i++)
	{
		v = &m_PurePos[i];		
		b = &m_BytePos[i];
		g = &m_Groups[b->group];
		v->x = (b->pos[0] * g->scale.x) + g->translate.x;
		v->y = (b->pos[1] * g->scale.y) + g->translate.y;
		v->z = (b->pos[2] * g->scale.z) + g->translate.z;
	}

	// finish up
	m_BytePos.Purge(); m_BytePos.Shrink();
	m_Groups.Purge(); m_Groups.Shrink(); 
	m_isCompressed = 0;

	return(1);
}

/*
	OCpjFrames
*/
OBJ_CLASS_IMPLEMENTATION(OCpjFrames, OCpjChunk, 0);

NBool OCpjFrames::UpdateBounds()
{
	m_Bounds[0] = VVec3(FLT_MAX,FLT_MAX,FLT_MAX);
	m_Bounds[1] = VVec3(-FLT_MAX,-FLT_MAX,-FLT_MAX);

	for (NDword i=0;i<m_Frames.GetCount();i++)
	{
		CCpjFrmFrame* f = &m_Frames[i];
		f->UpdateBounds();
		if (f->m_Bounds[0].x < m_Bounds[0].x) m_Bounds[0].x = f->m_Bounds[0].x;
		if (f->m_Bounds[0].y < m_Bounds[0].y) m_Bounds[0].y = f->m_Bounds[0].y;
		if (f->m_Bounds[0].z < m_Bounds[0].z) m_Bounds[0].z = f->m_Bounds[0].z;
		if (f->m_Bounds[1].x > m_Bounds[1].x) m_Bounds[1].x = f->m_Bounds[1].x;
		if (f->m_Bounds[1].y > m_Bounds[1].y) m_Bounds[1].y = f->m_Bounds[1].y;
		if (f->m_Bounds[1].z > m_Bounds[1].z) m_Bounds[1].z = f->m_Bounds[1].z;
	}
	return(1);
}

NDword OCpjFrames::GetFourCC()
{
	return(KRN_FOURCC(CPJ_FRM_MAGIC));
}
NBool OCpjFrames::LoadChunk(void* inImagePtr, NDword inImageLen)
{
	NDword i;

	if (!inImagePtr)
	{
		// remove old array data
		m_Frames.Purge(); m_Frames.Shrink();
		return(1);
	}

	// verify header
	SFrmFile* file = (SFrmFile*)inImagePtr;
	if ((file->header.magic != KRN_FOURCC(CPJ_FRM_MAGIC))
	 || (file->header.version != CPJ_FRM_VERSION))
		return(0);

	// set up image data pointers
	SFrmFrame* fileFrames = (SFrmFrame*)(&file->dataBlock[file->ofsFrames]);

	// remove old array data
	m_Frames.Purge(); m_Frames.Shrink(); m_Frames.Add(file->numFrames);

	if (file->header.ofsName)
		SetName((char*)inImagePtr + file->header.ofsName);

	// bounding box
	m_Bounds[0] = file->bbMin;
	m_Bounds[1] = file->bbMax;

	// frames
	for (NDword frame=0;frame<file->numFrames;frame++)
	{
		SFrmFrame* iF = &fileFrames[frame];
		CCpjFrmFrame* oF = &m_Frames[frame];

		oF->m_Name = (char*)(&file->dataBlock[iF->ofsFrameName]);
		oF->m_NameHash = STR_CalcHash(*oF->m_Name);

		// bounding box
		oF->m_Bounds[0] = iF->bbMin;
		oF->m_Bounds[1] = iF->bbMax;

		// set up image data pointers
		SFrmGroup* fileGroups = (SFrmGroup*)(&file->dataBlock[iF->ofsGroups]);
		VVec3* fileVertsPure = (VVec3*)(&file->dataBlock[iF->ofsVerts]);
		SFrmBytePos* fileVertsByte = (SFrmBytePos*)(&file->dataBlock[iF->ofsVerts]);

		oF->m_isCompressed = (iF->numGroups!=0);

		if (oF->m_isCompressed)
		{
			// groups
			oF->m_Groups.Add(iF->numGroups);
			for (i=0;i<iF->numGroups;i++)
			{
				oF->m_Groups[i].scale = fileGroups[i].byteScale;
				oF->m_Groups[i].translate = fileGroups[i].byteTranslate;
			}

			// vertices
			oF->m_BytePos.Add(iF->numVerts);
			
			memcpy(&oF->m_BytePos[0], &fileVertsByte[0], iF->numVerts*sizeof(SFrmBytePos));
			/*
			for (i=0;i<file->numVerts;i++)
			{
				SFrmBytePos* iV = &fileVertsByte[i];
				CCpjFrmBytePos* oV = &m_BytePos[i];
				oV->group = iV->group;
				oV->pos[0] = iV->pos[0];
				oV->pos[1] = iV->pos[1];
				oV->pos[2] = iV->pos[2];
			}
			*/
		}
		else
		{
			// vertices
			oF->m_PurePos.Add(iF->numVerts);
			
			memcpy(&oF->m_PurePos[0], &fileVertsPure[0], iF->numVerts*sizeof(VVec3));
			/*
			for (i=0;i<file->numVerts;i++)
				m_PurePos[i] = fileVertsPure[i];
			*/
		}
	}

	return(1);
}

NBool OCpjFrames::SaveChunk(void* inImagePtr, NDword* outImageLen)
{
	NDword i;
	SFrmFile header;
	NDword imageLen;

	// build header and calculate memory required for image
	imageLen = 0;
	header.header.ofsName = imageLen + offsetof(SFrmFile, dataBlock);
	imageLen += strlen(GetName())+1;
	header.numFrames = m_Frames.GetCount();
	header.ofsFrames = imageLen;
	imageLen += header.numFrames*sizeof(SFrmFrame);
	for (NDword frame=0;frame<header.numFrames;frame++)
	{
		CCpjFrmFrame* oF = &m_Frames[frame];
		
		imageLen += strlen(*oF->m_Name)+1;
		
		if (oF->m_isCompressed)
		{
			imageLen += oF->m_Groups.GetCount()*sizeof(SFrmGroup);
			imageLen += oF->m_BytePos.GetCount()*sizeof(SFrmBytePos);
		}
		else
		{
			imageLen += oF->m_PurePos.GetCount()*sizeof(VVec3);
		}
	}
	imageLen += offsetof(SFrmFile, dataBlock);

	// return if length is all that's desired
	if (outImageLen)
		*outImageLen = imageLen;
	if (!inImagePtr)
		return(1);

	header.header.magic = KRN_FOURCC(CPJ_FRM_MAGIC);
	header.header.lenFile = imageLen - 8;
	header.header.version = CPJ_FRM_VERSION;
	header.header.timeStamp = time(NULL);
	
	// bounding box
	header.bbMin = m_Bounds[0];
	header.bbMax = m_Bounds[1];

	SFrmFile* file = (SFrmFile*)inImagePtr;
	memcpy(file, &header, offsetof(SFrmFile, dataBlock));

	// set up image data pointers
	SFrmFrame* fileFrames = (SFrmFrame*)(&file->dataBlock[file->ofsFrames]);

	strcpy((char*)inImagePtr + file->header.ofsName, GetName());

	// frames
	NDword curDataOfs = strlen(GetName())+1;
	curDataOfs += file->numFrames*sizeof(SFrmFrame);

	for (frame=0;frame<file->numFrames;frame++)
	{
		SFrmFrame* iF = &fileFrames[frame];
		CCpjFrmFrame* oF = &m_Frames[frame];

		// frame info
		iF->ofsFrameName = curDataOfs;
		curDataOfs += strlen(*oF->m_Name)+1;
		if (oF->m_isCompressed)
		{
			iF->numGroups = oF->m_Groups.GetCount();
			iF->ofsGroups = curDataOfs;
			curDataOfs += iF->numGroups*sizeof(SFrmGroup);
			iF->numVerts = oF->m_BytePos.GetCount();
			iF->ofsVerts = curDataOfs;
			curDataOfs += iF->numVerts*sizeof(SFrmBytePos);
		}
		else
		{
			iF->numGroups = 0;
			iF->ofsGroups = curDataOfs;
			iF->numVerts = oF->m_PurePos.GetCount();
			iF->ofsVerts = curDataOfs;
			curDataOfs += iF->numVerts*sizeof(VVec3);
		}

		// bounding box
		iF->bbMin = oF->m_Bounds[0];
		iF->bbMax = oF->m_Bounds[1];

		// set up image data pointers
		SFrmGroup* fileGroups = (SFrmGroup*)(&file->dataBlock[iF->ofsGroups]);
		VVec3* fileVertsPure = (VVec3*)(&file->dataBlock[iF->ofsVerts]);
		SFrmBytePos* fileVertsByte = (SFrmBytePos*)(&file->dataBlock[iF->ofsVerts]);

		strcpy((char*)(&file->dataBlock[iF->ofsFrameName]), *oF->m_Name);

		if (oF->m_isCompressed)
		{
			// groups
			for (i=0;i<iF->numGroups;i++)
			{
				fileGroups[i].byteScale = oF->m_Groups[i].scale;
				fileGroups[i].byteTranslate = oF->m_Groups[i].translate;
			}

			// vertices
			memcpy(&fileVertsByte[0], &oF->m_BytePos[0], iF->numVerts*sizeof(SFrmBytePos));
		}
		else
		{
			// vertices
			memcpy(&fileVertsPure[0], &oF->m_PurePos[0], iF->numVerts*sizeof(VVec3));
		}
	}

	return(1);
}

//****************************************************************************
//**
//**    END MODULE CPJFRM.CPP
//**
//****************************************************************************

