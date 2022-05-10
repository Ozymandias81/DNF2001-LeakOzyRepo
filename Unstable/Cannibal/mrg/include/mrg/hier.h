/** MRG
 **
 ** (c)1998 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

//////////////////////////////////////////////////////////////////////////////
// hier.h
// ----------------
// Class declaration for MrgHier object - face set hierarchy holder

#pragma once

class MrgVertexData;
class MrgFaceSet;
class MrgCopyDict;

#include "mrg/object.h"
#include "mrg/matrix.h"

class MrgHier : public MrgObject
{
	MRG_DECLARE(MrgHier)

public:
	// default constructor
	MrgHier()
		: mFaceSet(NULL), mVData(NULL), mXform(MrgMatrix::identity()),
		mChildren(NULL), mNumChildren(0) {  }
	// dummy constructor
	MrgHier(const MrgMatrix& xform)
		: mFaceSet(NULL), mVData(NULL), mXform(xform),
		mChildren(NULL), mNumChildren(0) {  }
	// mesh constructor
	MrgHier(MrgFaceSet& fs, MrgVertexData& vdata,
		const MrgMatrix& xform = MrgMatrix::identity());
	// copy constructor
	MrgHier(const MrgHier& src);

	// destructor
	~MrgHier();

	// assignment
	MrgHier&	operator = (const MrgHier& src);

	// children
	MrgHier**				getChildren(void) const { return mChildren; }
	MrgHier**				getChildren(MrgUint16& num) const { num = mNumChildren; return mChildren; }
	MrgUint16				addChild(MrgHier* child);
	MrgUint16				removeChild(const MrgHier* child);

	// get sum transformation
	MrgBoolean				getSumTransformation(const MrgFaceSet* fs, MrgMatrix& xform) const;

	// get bounding box
	MrgBoolean				getBoundingBox(const MrgMatrix& xform, MrgCoord3D& min, MrgCoord3D& max) const;

	// find data
	MrgHier*				findFaceSet(const MrgFaceSet* fs);
	MrgHier*				findVertexData(const MrgVertexData *vdata);

	// find parent
	MrgHier*				getParentOf(const MrgHier* hier);

	// check hierarchy
	MrgBoolean				hasChild(const MrgHier* child) const;
	MrgBoolean				hasDescendant(const MrgHier* child) const;\

	// get mesh data
	const MrgFaceSet*		getFaceSet(void) const { return mFaceSet; }
	const MrgVertexData*	getVertexData(void) const { return mVData; }
	MrgFaceSet*				getFaceSet(void) { return mFaceSet; }
	MrgVertexData*			getVertexData(void) { return mVData; }

	// force vertex normal calculations
	void					calcVertexNorms(void);

	// count facesets/faces
	MrgUint16				getNumFaceSets(void) const;
	MrgUint16				getNumFaces(void) const;

	// reverse faces
	void					reverseFaces(void);

	// persistence
#ifndef NOSTREAMS
	virtual ostream&	saveOn(ostream& stream) const;
	virtual istream&	restoreFrom(istream& stream);
#endif //NOSTREAMS
	virtual MrgUint32	getSizeOfBlock(void) const;

	MrgMatrix				mXform;			// transformation

protected:
	// mesh data
	MrgFaceSet*				mFaceSet;		// face set
	MrgVertexData*			mVData;			// vertex data
	
	// children
	MrgHier**				mChildren;		// children
	MrgUint16				mNumChildren;	// number of children

	// data
	void					deleteData(void);
	void					copyData(const MrgHier& src);

	// copy dictionary
	static MrgCopyDict*		sCopyDict;

	// friends
	friend class MrgModel;
};

