/**
 ** MRG
 **
 ** (c)1997-1998 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

////////////////////////////////////////////////////////////////////////////
// render.cpp
// -------
// Example of MRG rendering in openGL
#include "windows.h"

#include "mrg.h"
#include <gl/gl.h>

void RenderModel(const MrgModel& model);
void RenderHier(const MrgHier& hier);
void RenderFaceSet(const MrgFaceSet& fs, const MrgCoord3D* points, MrgUint16 numPoints);
void RenderXform(const MrgRotation& rot, const MrgCoord3D& transl, const MrgCoord3D& scale);

// ---------------------------------------------------------------------------
// * RenderModel
// ---------------------------------------------------------------------------
// Render whole model in OpenGL
void
RenderModel(const MrgModel& model)
{

	// Just render hierarchy
	RenderHier(*model.getHierarchy());
}

// ---------------------------------------------------------------------------
// * RenderHier
// ---------------------------------------------------------------------------
// Render a hierarchy in OpenGL
void
RenderHier(const MrgHier& hier)
{
	// Save modelview matrix state
	glPushMatrix();

	// Get transformations
	glMultMatrixf(hier.mXform.getValue());

	// get each child
	MrgUint16 i, numChild;
	MrgHier **children = hier.getChildren(numChild);
	for (i=0; i < numChild; i++)
		RenderHier(*children[i]);
	
	// check for faceset
	const MrgFaceSet *fs = hier.getFaceSet();
	if (fs)
	{
		RenderFaceSet(*fs,hier.getVertexData()->getGeometry(),hier.getVertexData()->getNumGeometry());
	}

	glPopMatrix();
	
}
// ---------------------------------------------------------------------------
// * RenderFaceSet
// ---------------------------------------------------------------------------
// render a face set using OpenGL 1.1
void
RenderFaceSet(const MrgFaceSet& fs, const MrgCoord3D* points, MrgUint16 numPoints)
{
	// get the faces
	MrgUint16 numVerts,numActiveFaces;
	const MrgTri *faces = fs.getTriangles();
	numVerts = (numActiveFaces = fs.getActiveFaceCount()) * 3;


	// be sure there's something to draw
	if (numVerts > 0)
	{
		// get normals
		MrgCoord3D* normals;
		fs.getVertexNormals(points,numPoints,normals);
		// set color to grey
		glColor4f(0.5f,0.5f,0.5f,1.0f);

		// set up vertex arrays
		glEnableClientState(GL_NORMAL_ARRAY);
		glNormalPointer(GL_FLOAT,0,normals);
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(3,GL_FLOAT,0,points);			

		// draw it
		glDrawElements(GL_TRIANGLES, numVerts, GL_UNSIGNED_SHORT, (GLushort*) faces);

	}
}

// ---------------------------------------------------------------------------
// * CalcNormals
// ---------------------------------------------------------------------------
// calculate normals to a face set assuming CCW winding
void
CalcNormals(const MrgFaceSet& fs, const MrgCoord3D* points, MrgCoord3D *normals)
{
	MrgUint32	num,i;

	// get point indices from faceset
	const MrgTri *faces = fs.getTriangles();
	num = fs.getActiveFaceCount();

	// for every face, add up the normals for each vertex:
	for (i = 0; i < num; i++)
	{
		MrgUint16	v0,v1,v2;

		// get indices from TriFace
		faces[i].getFace(v0,v1,v2);

		// get the normal to this face
		MrgCoord3D e1 = points[v1] - points[v0];
		MrgCoord3D e2 = points[v2] - points[v0];
		MrgCoord3D norm = e1.cross(e2);
		
		// add the surface normal to each vertex normal
		normals[v0] += norm;
		normals[v1] += norm;
		normals[v2] += norm;
	}

	// summed normals are not normalized  -- we want OpenGL to do this for us
	// so hardware acceleration can be used
}

// ---------------------------------------------------------------------------
// * RenderXform
// ---------------------------------------------------------------------------
// Add a transformation to the GL
void 
RenderXform(const MrgRotation& rot, const MrgCoord3D& transl, const MrgCoord3D& scale)
{
	// translate
	glTranslatef(transl[0],transl[1],transl[2]);

	// get rotation
	MrgCoord3D axis;
	float ang;
	rot.getValue(axis,ang);
	// rotate
	glRotatef(ang,axis[0],axis[1],axis[2]);

	// scale
	glScalef(scale[0],scale[1],scale[2]);
}
