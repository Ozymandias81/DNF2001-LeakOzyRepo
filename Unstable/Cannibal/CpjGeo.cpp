//****************************************************************************
//**
//**    CPJGEO.CPP
//**    Cannibal Models - Geometry Descriptions
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "CpjMain.h"
#include "CpjGeo.h"
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
	OCpjGeometry
*/
OBJ_CLASS_IMPLEMENTATION(OCpjGeometry, OCpjChunk, 0);

NBool OCpjGeometry::Generate(NDword inNumVerts, NFloat* inVerts, NDword inNumTris, NDword* inTris)
{
	if (!inNumVerts || !inNumTris || !inTris)
		return(0);

	// remove old array data
	m_Verts.Purge(); m_Verts.Shrink();
	m_Edges.Purge(); m_Edges.Shrink();
	m_Tris.Purge(); m_Tris.Shrink();

	// add stub vertices and triangles
	m_Verts.Add(inNumVerts);
	m_Tris.Add(inNumTris);

	// add edges, fill in head and tail vertices
	for (NDword i=0;i<inNumTris;i++)
	{
		CCpjGeoVert* v[3];
		for (NDword j=0;j<3;j++)
			v[j] = &m_Verts[inTris[i*3+j]];

		CCpjGeoEdge* e[3] = {NULL,NULL,NULL};
		CCpjGeoEdge* et;
		for (j=0;j<m_Edges.GetCount();j++)
		{
			et = &m_Edges[j];
			if ((et->tailVertex == v[0]) && (et->headVertex == v[1]))
				e[0] = et;
			if ((et->tailVertex == v[1]) && (et->headVertex == v[2]))
				e[1] = et;
			if ((et->tailVertex == v[2]) && (et->headVertex == v[0]))
				e[2] = et;
			if (e[0] && e[1] && e[2])
				break; // found all three
		}
		for (j=0;j<3;j++)
		{
			if (e[j])
				continue;
			NDword k = (j+1)%3;
			e[j] = &m_Edges[m_Edges.Add()];
			e[j]->tailVertex = v[j];
			e[j]->headVertex = v[k];
			et = &m_Edges[m_Edges.Add()];
			et->tailVertex = v[k];
			et->headVertex = v[j];
		}
	}
	
	// fill in links to edges etc. after edge array is completely built, so pointers are valid
	for (i=0;i<inNumTris;i++)
	{
		CCpjGeoVert* v[3];
		for (NDword j=0;j<3;j++)
			v[j] = &m_Verts[inTris[i*3+j]];

		CCpjGeoEdge* e[3] = {NULL,NULL,NULL};
		CCpjGeoEdge* et;
		for (j=0;j<m_Edges.GetCount();j++)
		{
			et = &m_Edges[j];
			if ((et->tailVertex == v[0]) && (et->headVertex == v[1]))
				e[0] = et;
			if ((et->tailVertex == v[1]) && (et->headVertex == v[2]))
				e[1] = et;
			if ((et->tailVertex == v[2]) && (et->headVertex == v[0]))
				e[2] = et;
			if (e[0] && e[1] && e[2])
				break; // found all three
		}
		for (j=0;j<3;j++)
		{
			NDword k = (j+1)%3;
			if ((e[j] - &m_Edges[0]) & 1)
				et = e[j]-1;
			else
				et = e[j]+1;
			et->invertedEdge = e[j];
			e[j]->invertedEdge = et;
			v[j]->edgeLinks.AddItem(e[j]);
			v[j]->edgeLinks.AddItem(et);
			v[k]->edgeLinks.AddItem(e[j]);
			v[k]->edgeLinks.AddItem(et);
		}
		CCpjGeoTri* t = &m_Tris[i];
		for (j=0;j<3;j++)
		{
			t->edgeRing[j] = e[j];
			e[j]->triLinks.AddItem(t);
			if (!v[j]->triLinks.FindItem(t, NULL))
				v[j]->triLinks.AddItem(t);
		}
	}
	
	// vertex positions are optional, but if they're present, use them as reference positions
	if (inVerts)
	{
		for (i=0;i<inNumVerts;i++)
			m_Verts[i].refPosition = VVec3(inVerts[i*3], inVerts[i*3+1], inVerts[i*3+2]);
	}

	return(1);
}

NDword OCpjGeometry::GetFourCC()
{
	return(KRN_FOURCC(CPJ_GEO_MAGIC));
}
NBool OCpjGeometry::LoadChunk(void* inImagePtr, NDword inImageLen)
{
	NDword i, j;

	if (!inImagePtr)
	{
		// remove old array data
		m_Verts.Purge(); m_Verts.Shrink();
		m_Edges.Purge(); m_Edges.Shrink();
		m_Tris.Purge(); m_Tris.Shrink();
		m_Mounts.Purge(); m_Mounts.Shrink();
		return(1);
	}

	// verify header
	SGeoFile* file = (SGeoFile*)inImagePtr;
	if ((file->header.magic != KRN_FOURCC(CPJ_GEO_MAGIC))
	 || (file->header.version != CPJ_GEO_VERSION))
		return(0);

	// set up image data pointers
	SGeoVert* fileVerts = (SGeoVert*)(&file->dataBlock[file->ofsVertices]);
	SGeoEdge* fileEdges = (SGeoEdge*)(&file->dataBlock[file->ofsEdges]);
	SGeoTri* fileTris = (SGeoTri*)(&file->dataBlock[file->ofsTris]);
	SGeoMount* fileMounts = (SGeoMount*)(&file->dataBlock[file->ofsMounts]);
	NWord* fileObjLinks = (NWord*)(&file->dataBlock[file->ofsObjLinks]);

	// remove old array data
	m_Verts.Purge(); m_Verts.Shrink(); m_Verts.Add(file->numVertices);
	m_Edges.Purge(); m_Edges.Shrink(); m_Edges.Add(file->numEdges);
	m_Tris.Purge(); m_Tris.Shrink(); m_Tris.Add(file->numTris);
	m_Mounts.Purge(); m_Mounts.Shrink(); m_Mounts.Add(file->numMounts);

	if (file->header.ofsName)
		SetName((char*)inImagePtr + file->header.ofsName);

	// vertices
	for (i=0;i<file->numVertices;i++)
	{
		SGeoVert* iV = &fileVerts[i];
		CCpjGeoVert* oV = &m_Verts[i];
		oV->flags = iV->flags;
		oV->groupIndex = iV->groupIndex;
		oV->edgeLinks.AddNoConstruct(iV->numEdgeLinks);
		for (j=0;j<iV->numEdgeLinks;j++)
			oV->edgeLinks[j] = &m_Edges[fileObjLinks[iV->firstEdgeLink+j]];
		oV->triLinks.AddNoConstruct(iV->numTriLinks);
		for (j=0;j<iV->numTriLinks;j++)
			oV->triLinks[j] = &m_Tris[fileObjLinks[iV->firstTriLink+j]];
		oV->refPosition = iV->refPosition;
	}

	// edges
	for (i=0;i<file->numEdges;i++)
	{
		SGeoEdge* iE = &fileEdges[i];
		CCpjGeoEdge* oE = &m_Edges[i];
		oE->headVertex = &m_Verts[iE->headVertex];
		oE->tailVertex = &m_Verts[iE->tailVertex];
		oE->invertedEdge = &m_Edges[iE->invertedEdge];
		oE->triLinks.AddNoConstruct(iE->numTriLinks);
		for (j=0;j<iE->numTriLinks;j++)
			oE->triLinks[j] = &m_Tris[fileObjLinks[iE->firstTriLink+j]];
	}

	// triangles
	for (i=0;i<file->numTris;i++)
	{
		SGeoTri* iT = &fileTris[i];
		CCpjGeoTri* oT = &m_Tris[i];
		for (j=0;j<3;j++)
			oT->edgeRing[j] = &m_Edges[iT->edgeRing[j]];
	}

	// mount points
	for (i=0;i<file->numMounts;i++)
	{
		SGeoMount* iM = &fileMounts[i];
		CCpjGeoMount* oM = &m_Mounts[i];
		strcpy(oM->name, (char*)(&file->dataBlock[iM->ofsName]));
		oM->triIndex = iM->triIndex;
		oM->triBarys = iM->triBarys;
		oM->baseCoords.s = iM->baseScale;
		oM->baseCoords.r = iM->baseRotate;
		oM->baseCoords.t = iM->baseTranslate;
	}

	return(1);
};

NBool OCpjGeometry::SaveChunk(void* inImagePtr, NDword* outImageLen)
{
	NDword i, j;
	SGeoFile header;
	NDword imageLen;
	NDword ofsMountNames;

	// build header and calculate memory required for image
	imageLen = 0;
	header.header.ofsName = imageLen + offsetof(SGeoFile, dataBlock);
	imageLen += strlen(GetName())+1;
	header.numVertices = m_Verts.GetCount();
	header.ofsVertices = imageLen;
	imageLen += header.numVertices*sizeof(SGeoVert);
	header.numEdges = m_Edges.GetCount();
	header.ofsEdges = imageLen;
	imageLen += header.numEdges*sizeof(SGeoEdge);
	header.numTris = m_Tris.GetCount();
	header.ofsTris = imageLen;
	imageLen += header.numTris*sizeof(SGeoTri);
	header.numMounts = m_Mounts.GetCount();
	header.ofsMounts = imageLen;
	imageLen += header.numMounts*sizeof(SGeoMount);	
	header.numObjLinks = 0;
	header.ofsObjLinks = imageLen;
	for (i=0;i<m_Verts.GetCount();i++)
	{
		header.numObjLinks += m_Verts[i].edgeLinks.GetCount();
		header.numObjLinks += m_Verts[i].triLinks.GetCount();
	}
	for (i=0;i<m_Edges.GetCount();i++)
	{
		header.numObjLinks += m_Edges[i].triLinks.GetCount();
	}
	imageLen += header.numObjLinks*sizeof(NWord);
	ofsMountNames = imageLen;
	for (i=0;i<m_Mounts.GetCount();i++)
	{
		imageLen += strlen(m_Mounts[i].name)+1;
	}	
	imageLen += offsetof(SGeoFile, dataBlock);

	// return if length is all that's desired
	if (outImageLen)
		*outImageLen = imageLen;
	if (!inImagePtr)
		return(1);

	header.header.magic = KRN_FOURCC(CPJ_GEO_MAGIC);
	header.header.lenFile = imageLen - 8;
	header.header.version = CPJ_GEO_VERSION;
	header.header.timeStamp = time(NULL);

	SGeoFile* file = (SGeoFile*)inImagePtr;
	memcpy(file, &header, offsetof(SGeoFile, dataBlock));
	
	// set up image data pointers
	SGeoVert* fileVerts = (SGeoVert*)(&file->dataBlock[file->ofsVertices]);
	SGeoEdge* fileEdges = (SGeoEdge*)(&file->dataBlock[file->ofsEdges]);
	SGeoTri* fileTris = (SGeoTri*)(&file->dataBlock[file->ofsTris]);
	SGeoMount* fileMounts = (SGeoMount*)(&file->dataBlock[file->ofsMounts]);
	NWord* fileObjLinks = (NWord*)(&file->dataBlock[file->ofsObjLinks]);
	NChar* fileMountNames = (NChar*)(&file->dataBlock[ofsMountNames]);

	strcpy((char*)inImagePtr + file->header.ofsName, GetName());

	NDword curObjLink = 0;

	// vertices
	for (i=0;i<file->numVertices;i++)
	{
		SGeoVert* iV = &fileVerts[i];
		CCpjGeoVert* oV = &m_Verts[i];
		iV->flags = oV->flags;
		iV->groupIndex = oV->groupIndex;
		iV->reserved = 0;
		iV->numEdgeLinks = (NWord)oV->edgeLinks.GetCount();
		iV->firstEdgeLink = curObjLink;
		curObjLink += iV->numEdgeLinks;
		for (j=0;j<iV->numEdgeLinks;j++)
			fileObjLinks[iV->firstEdgeLink+j] = (CCpjGeoEdge*)oV->edgeLinks[j] - &m_Edges[0];
		iV->numTriLinks = (NWord)oV->triLinks.GetCount();
		iV->firstTriLink = curObjLink;
		curObjLink += iV->numTriLinks;		
		for (j=0;j<iV->numTriLinks;j++)
			fileObjLinks[iV->firstTriLink+j] = (CCpjGeoTri*)oV->triLinks[j] - &m_Tris[0];
		iV->refPosition = oV->refPosition;
	}

	// edges
	for (i=0;i<file->numEdges;i++)
	{
		SGeoEdge* iE = &fileEdges[i];
		CCpjGeoEdge* oE = &m_Edges[i];
		iE->headVertex = (CCpjGeoVert*)oE->headVertex - &m_Verts[0];
		iE->tailVertex = (CCpjGeoVert*)oE->tailVertex - &m_Verts[0];
		iE->invertedEdge = (CCpjGeoEdge*)oE->invertedEdge - &m_Edges[0];
		iE->numTriLinks = (NWord)oE->triLinks.GetCount();
		iE->firstTriLink = curObjLink;
		curObjLink += iE->numTriLinks;		
		for (j=0;j<iE->numTriLinks;j++)
			fileObjLinks[iE->firstTriLink+j] = (CCpjGeoTri*)oE->triLinks[j] - &m_Tris[0];
	}

	// triangles
	for (i=0;i<file->numTris;i++)
	{
		SGeoTri* iT = &fileTris[i];
		CCpjGeoTri* oT = &m_Tris[i];
		for (j=0;j<3;j++)
			iT->edgeRing[j] = (CCpjGeoEdge*)oT->edgeRing[j] - &m_Edges[0];
		iT->reserved = 0;
	}

	// mount points
	NDword curMountNameOfs = 0;
	for (i=0;i<file->numMounts;i++)
	{
		SGeoMount* iM = &fileMounts[i];
		CCpjGeoMount* oM = &m_Mounts[i];		
		iM->ofsName = ofsMountNames+curMountNameOfs;
		strcpy(fileMountNames+curMountNameOfs, oM->name);
		curMountNameOfs += strlen(oM->name)+1;
		iM->triIndex = oM->triIndex;
		iM->triBarys = oM->triBarys;
		iM->baseScale = oM->baseCoords.s;
		iM->baseRotate = oM->baseCoords.r;
		iM->baseTranslate = oM->baseCoords.t;
	}

	return(1);
}

//****************************************************************************
//**
//**    END MODULE CPJGEO.CPP
//**
//****************************************************************************

