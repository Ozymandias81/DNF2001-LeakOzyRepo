/** MRG
 **
 ** (c)1997 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

//////////////////////////////////////////////////////////////////////////////
// tri.h
// ---------
// Declaration of MrgTri -- the class representing a single triangular face in
// a faceset.

#pragma once

#include "mrg/types.h"

class MrgTri
{
public:
	MrgTri() { }

	// set/get indices
	void			setFace(MrgUint16 v0,MrgUint16 v1,MrgUint16 v2);
	void			getFace(MrgUint16& v0,MrgUint16& v1,MrgUint16& v2) const;

	// get a vertex index
	MrgUint16		operator[](int index) const { return mPoints[index]; }
	MrgUint16&		operator[](int index)		{ return mPoints[index]; }

	// equality
	MrgBoolean		operator ==(const MrgTri& face) const;
	MrgBoolean		operator !=(const MrgTri& face) const { return !(*this == face); }

	// test adjacency
	MrgBoolean		adjacentTo(const MrgTri& face) const;

	// check if a face contains a given vertex
	MrgBoolean		contains(MrgUint16 index) const;
	MrgBoolean		contains(MrgUint16 index, MrgUint8& which) const;

	// get the next or previous vertex in CCW order
	MrgUint16		nextVertex(MrgUint16 index) const;
	MrgUint16		prevVertex(MrgUint16 index) const;


protected:
	// get indices in numerical order (instead of CCW order)
	void			getOrdered(MrgUint16& v0,MrgUint16& v1,MrgUint16& v2) const;

	MrgUint16	mPoints[3];		// the triangle

public:
	// collapsing/restoring operations
	enum CollapseAction { NO_CHANGE = 0, CHANGED, KILLED };

	CollapseAction	collapse(MrgUint16 from,MrgUint16 to);
	MrgBoolean		restore(MrgUint16 from,MrgUint16 to);

	friend class MrgFaceSet;
};

// inlines
inline void
MrgTri::setFace(MrgUint16 v0,MrgUint16 v1,MrgUint16 v2)
{ mPoints[0] = v0; mPoints[1] = v1; mPoints[2] = v2; }

inline void
MrgTri::getFace(MrgUint16& v0,MrgUint16& v1,MrgUint16& v2) const
{ v0 = mPoints[0]; v1 = mPoints[1]; v2 = mPoints[2]; }

inline MrgBoolean
MrgTri::contains(MrgUint16 index) const
{ return mPoints[0] == index || mPoints[1] == index || mPoints[2] == index; }
