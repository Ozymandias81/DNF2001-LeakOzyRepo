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
// vdata.h
// ----------------
// Class declaration of Mrg Vertex Data Object

#pragma once

#include "mrg/types.h"
#include "mrg/matrix.h"
#include "mrg/coord.h"
#include "mrg/rotation.h"
#include "mrg/object.h"

class MrgHier;
class MrgFaceSet;
class MrgInitOption;
#ifndef NOSTREAMS
class istream;
class ostream;
#endif //!NOSTREAMS

class MrgVertexData : public MrgObject
{
	MRG_DECLARE(MrgVertexData)

public:
	//constructors
	MrgVertexData();
	MrgVertexData(const MrgVertexData& src);
	virtual ~MrgVertexData();

	// ref/unref
	MrgUint16			ref(MrgFaceSet& fs);
	MrgUint16			unref(MrgFaceSet& fs);


public:

	// assignment operation
	MrgVertexData&		operator =(const MrgVertexData& src);

	// geometry
	MrgUint16			getNumGeometry(void) const { return mNumPoints; }
	const MrgCoord3D *	getGeometry(void) const { return mPoints; }
	const MrgCoord3D *	getGeometry(MrgUint16& num) const { num = mNumPoints; return mPoints; }
	MrgUint16			setGeometry(const MrgCoord3D* points, MrgUint16 numPoints);
	MrgUint16			getNumMinGeometry(void) const { return mNumMinPoints; }
	MrgUint16			setLowerGeometry(const MrgCoord3D* minPoints, MrgUint16 numMinPoints);
	MrgUint16			setMinGeometry(const MrgCoord3D* minPoints, MrgUint16 numMinPoints);
	MrgUint16			setLowerGeometry(const MrgUint16* minPoints, MrgUint16 numMinPoints);
	MrgUint16			setMinGeometry(const MrgUint16* minPoints, MrgUint16 numMinPoints);
	MrgUint16			activePoints(void) const { return mNumPoints - mDownResCount; }
	const MrgUint16*	getMinPoints(MrgUint16& num) const { num = mNumMinPoints; return mMinPoints; }
	const MrgUint16*	getMinPoints(void) const { return mMinPoints; }
	
	// tex coords
	const MrgCoord2Df*	getTexCoords(void) const { return mTexCoords; }
	MrgUint16			setTexCoords(const MrgCoord2Df* texCoords, MrgUint32 numTexCoords);

	// face sets
	MrgUint16			getNumFaceSets(void) const { return mNumFaceSets; }
	MrgFaceSet**		getFaceSets(MrgUint16& num) const { num = mNumFaceSets; return mFaceSets; }
	MrgFaceSet**		getFaceSets(void) const { return mFaceSets; }
	MrgFaceSet**		getFaceSet(void) const { return mFaceSets; }
	MrgBoolean			contains(const MrgFaceSet* fs) const;

	// get bounding box
	void				getBoundingBox(const MrgMatrix& xform,MrgCoord3D& min,MrgCoord3D& max) const;

	// misc.
	MrgUint16			getTexDegCutPolys(void) const {return mTexDegCutPolys;}
	MrgUint16			seamDepth(MrgUint16 index) const;
	MrgBoolean			getNextDownRes(MrgCoord3D& from, MrgCoord3D& to) const;
	MrgBoolean			getNextDownRes(MrgUint16& from, MrgUint16& to) const;
	MrgUint16			getDownResMax(void) const { return mDownResMax; }
	MrgUint16			getDownResLevel(void) const { return mDownResLevel; }
	
	// original map
	const MrgUint16*	getOrigMap(void) const { return mOrigMap; }

	// duplicate a vertex at a given index, adjusting all facesets
	MrgUint16			duplicateVertex(MrgUint16 idx, MrgUint16 dupes);

	// EDITING: change downres at current step
	MrgUint16			nextNeighbor(void);
	MrgUint16			nextVertex(void);
	MrgUint16			nextVertex(MrgUint16 index);
	MrgUint16			nextToMin(void);
	MrgUint16			complete(const MrgHier* hier, const MrgInitOption* options = NULL,
								MrgUint16 steps = 0, MrgInitProgressFn updateFunc =NULL, void* userData =NULL);
	MrgUint16			removeFromMin(MrgUint16 index);


	// persist minimum points
	static MrgBoolean	sSaveMinPoints;
	// export MRGPlay with non-duplicated faces
	static MrgBoolean	sExportPlayNd;

protected:
	MrgUint16			mNumPoints;			// number of points
	MrgCoord3D*			mPoints;			// geometry
	MrgCoord2Df*		mTexCoords;			// tex coords

	MrgUint16			mTexDegCutPolys;  //number of polys at which texture degredation begins
	
	MrgUint16			mNumFaceSets;		// number of facesets
	MrgFaceSet**		mFaceSets;			// facesets

	MrgUint16			mDownResLevel;		// # of down-res operations applied so far
	MrgUint16			mDownResMax;		// max down-res level
	MrgUint16*			mOrigMap;			// original point map

	// check a weld before done
	virtual MrgBoolean	weldOkay(MrgUint16 from, MrgUint16 to) const;

	// persistence
	virtual MrgUint32	getSizeOfBlock() const;
#ifndef NOSTREAMS
	virtual ostream&	saveOn(ostream& stream) const;
	virtual istream&	restoreFrom(istream& stream);
	virtual ostream&	saveStreamSeg(ostream& stream) const;
	virtual MrgUint16	readStreamSeg(istream& stream);
#endif //!NOSTREAMS

#ifdef _DEBUG
	// dictionary entry verification
	virtual MrgBoolean	isVertexData(void) const { return TRUE; }
#endif //_DEBUG

	// export to MRGPlay
	MrgUint32			getSizeOfPlayBlock(void);
#ifndef NOSTREAMS
	MrgUint16			exportPlay(ostream &stream);
#endif //!NOSTREAMS
	
	// post initialization change notification
	virtual MrgUint16	postInit(MrgUint16 numReorder, const MrgUint16* reorder);
	
	// MRG info
	MrgUint16			verge(const MrgHier* hier, const MrgInitOption* options = NULL,
									MrgUint16 startAt = 0, MrgUint16 stopAt = 0,
									MrgInitProgressFn updateFunc = NULL,
									void* userData = NULL);
	MrgUint16			weldPoints(double distance,	MrgUint32 &update,
									MrgInitProgressFn updateFunc = NULL,
									void* userData = NULL);
	MrgUint16			removeUnrefGeometry(MrgUint32 &update, MrgInitProgressFn updateFunc = NULL,
									void* userData = NULL);
	MrgUint16			removeMinPoint(MrgUint16 index);
	MrgUint16			weldMinPoint(MrgUint16 from, MrgUint16 to);
	MrgUint16			getNeighbors(MrgUint16 index, MrgUint16*& neighbors, MrgUint16& numNeighbors,
								MrgBoolean collapsableOnly = FALSE) const;
	MrgBoolean			collapseOkay(MrgUint16 from, MrgUint16 to) const;
	virtual void		swapPoints(MrgUint16 from, MrgUint16 to);
	virtual void		weldPoints(MrgUint16 from, MrgUint16 to) { }


	// down-resify/up-resify
	MrgUint16			downRes(MrgBoolean clearHistory = FALSE);
	MrgUint16			upRes(void);
	MrgUint16			upResAll(void);
	MrgUint16			setDownResLevel(MrgUint32 level);
	MrgUint16			setDownResLevel(MrgUint32 level, MrgSint32& pChange);
	// down- or up-res w/o any checks
	virtual MrgUint16	_downRes(MrgBoolean clearHistory = FALSE);
	virtual MrgUint16	_upRes(void);
	virtual MrgUint16	_downRes(MrgSint32& polyChange, MrgBoolean clearHistory = FALSE);
	virtual MrgUint16	_upRes(MrgSint32& polyChange);
	// lock face set down res caches
	void				lockCache(void);
	
	
	MrgUint16			mNumMinPoints;		// minimum number of points (for down-res)
	MrgUint16*			mMinPoints;			// minimum point index set (for down-res)
	MrgUint16*			mNeighbors;			// nearest neighbors (for down-res)
	MrgUint16*			mLocalNeighbors;	// local neighbor set for switching
	MrgUint16			mNumLocalNeighbors; // # of local neighbors
	MrgSint32			mLocalNeighborIndex;// index point with local neighbors
	MrgUint16			mDownResCount;		// # of down-res'd vertices
	MrgUint16			mNextVertex;		// next vertex to swap
	MrgBoolean			mClearNext;			// clear history with next res change
	
	// our data
	void				deleteData(void);
	void				copyData(const MrgVertexData& src);
	void				initData(void);

	// undefined
	static const MrgUint16 kUndefNeighbor;
public:
	static const MrgCoord2Df kUndefTexCoord;

	friend class MrgModel;
	friend class MrgHier;

#ifdef PSX
	void				freeXMem(void);
#endif

};
