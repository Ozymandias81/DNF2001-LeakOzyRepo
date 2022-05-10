/** MRG
 **
 ** (c)1996-1998 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

//////////////////////////////////////////////////////////////////////////////
// faceset.h
// ------------
// Class declaration of FaceSet object

#pragma once

#include "mrg/types.h"
#include "mrg/object.h"

class MrgCoord3D;
class MrgMatrix;
class MrgResHistory;
class MrgTri;
class MrgVertexOpt;
#ifndef NOSTREAMS
class ostream;
class istream;
#endif //!NOSTREAMS

class MrgFaceSet : public MrgObject
{
	MRG_DECLARE(MrgFaceSet)

public:
	// constructors
	MrgFaceSet();
	MrgFaceSet(const MrgFaceSet& src);

	// destructor
	virtual ~MrgFaceSet();

	// assignment operator
	MrgFaceSet&			operator =(const MrgFaceSet& src);

	// faces
	MrgUint16			setTriangleFaces(MrgTri* tris, MrgUint16 numTris);
	MrgUint16			setTriangleFaces(MrgUint16* tris, MrgUint16 numTris);
	MrgUint16			setQuadFaces(MrgUint16* quads, MrgUint16 numQuads);
	MrgUint16			setArbitraryFaces(MrgSint32* faces, MrgUint32 numFaces, MrgSint32 faceSeparator = -1);

	MrgUint16			getNumTriangles(void) const { return mNumFaces; }
	MrgUint16			getActiveFaceCount(void) const { return mActiveFaces; }

	const MrgTri *		getTriangles(void) const { return mFaces; }

	// misc.
	void				reverseFaces(void);
	MrgFaceSet&			operator += (const MrgFaceSet& src); // append more data (used with export)
	
#ifndef MRGLITE
	// duplicate a vertex at a given index, adjusting all facesets
	virtual MrgUint16	duplicateVertex(MrgUint16 idx, MrgUint16 dupes);

	// get computed vertex normals
	MrgUint16			getVertexNormals(const MrgCoord3D* points, MrgUint16 numPoints, const MrgCoord3D*& normals) const;
	MrgUint16			getVertexNormals(const MrgCoord3D* points, MrgUint16 numPoints, const MrgCoord3D*& normals);


	// get bounding box:
	virtual MrgBoolean	getBoundingBox(const MrgMatrix& xform,const MrgCoord3D *pts,
									MrgUint32 num_pts,MrgCoord3D& min,MrgCoord3D& max) const;	
#ifndef NOSTREAMS
	virtual ostream&	saveStreamSeg(ostream& stream, MrgUint16 numPoints) const;
	virtual MrgUint16	readStreamSeg(istream& stream, MrgUint16 newPoints);
#endif //!NOSTREAMS
	
	
#endif //MRGLITE
	
	// persistence
#ifndef NOSTREAMS
	virtual ostream&	saveOn(ostream& stream) const;
	virtual istream&	restoreFrom(istream& stream);
#endif //NOSTREAMS
	virtual MrgUint32	getSizeOfBlock() const;	
	MrgUint32			getSizeOfPlayBlock(void) const;
#ifdef _DEBUG
	// dictionary entry verification
	virtual MrgBoolean	isFaceSet(void) const { return TRUE; }
#endif //_DEBUG

	// export/import to MRGPlay
#ifndef NOSTREAMS
	MrgUint16			exportPlay(ostream &stream) const;
#ifdef MRGLITE
	MrgUint16			importPlay(istream &stream);
#endif //MRGLITE
#endif //!NOSTREAMS

	// get original order mapping
	const MrgUint16*	getOrigMap(void) const { return mOrigMap; }

protected:
	// set the down res max
	void				setDownResMax(MrgUint16 max);
	
	// lock face set down res caches
	void				lockCache(void);
	
	MrgUint16			mNumFaces;		// number of faces in this faceset
	MrgTri *			mFaces;			// the faces
	MrgUint16			mActiveFaces;	// number of active faces in this faceset

#ifndef MRGLITE
	MrgCoord3D*			mNormals;		// vertex normals (if computed)
	MrgUint16			mNumNormals;	// # of computed vertex normals
#endif //MRGLITE

	// down-res stuff
	virtual void		swapFaces(MrgUint16 from, MrgUint16 to);
#ifdef MRGLITE
	virtual MrgUint16	downRes(MrgUint16 count, const MrgUint16 from,const MrgUint16* to,MrgBoolean clearHistory);
	virtual MrgUint16	upRes(MrgUint16 count, const MrgUint16* from, const MrgUint16 to);
#else
	virtual MrgUint16	downRes(MrgUint16 count, const MrgUint16 from,const MrgUint16* to,MrgBoolean clearHistory, const MrgCoord3D* points);
	virtual MrgUint16	upRes(MrgUint16 count, const MrgUint16* from, const MrgUint16 to, const MrgCoord3D* points);

	virtual void		weldPoints(MrgUint16 from, MrgUint16 to);
	virtual void		swapPoints(MrgUint16 from, MrgUint16 to);
	virtual void		movePoints(MrgUint16 from, MrgSint16 adj, MrgUint16 count);
	virtual MrgBoolean	weldOkay(MrgUint16 from, MrgUint16 to) const { return TRUE; }
	virtual void		nextVertex(MrgUint16 dead, MrgUint16 down, MrgUint16 next, MrgUint16 up);

	void				verge(MrgMatrix& xform, MrgVertexOpt& optimizer);
	void				markRefPoints(MrgUint16 numPoints, MrgBoolean* refList, MrgUint16& numRef) const;
	MrgUint16			getNeighbors(MrgUint16 index, MrgUint16*& neighbors, MrgUint16& numNeighbors) const;
	// calculate vertex normals
	void				calcNormals(const MrgCoord3D* points, MrgCoord3D *normals);
	void				updateNormsAfterDownRes(MrgUint16 num, const MrgUint16 from, const MrgUint16* to, const MrgCoord3D* points);
	void				updateNormsBeforeUpRes(MrgUint16 num, const MrgUint16* from, const MrgUint16 to, const MrgCoord3D* points);
	
	// post initialization change notification
	virtual MrgUint16	postInit(MrgUint16 numPoints, const MrgUint16* reorderList, const MrgUint16* neighbors);
#endif //MRGLITE
	void				clearHistory(void);

	// dres	
	void				setDresID(MrgSint32 pieceID, MrgUint32 index) { mPieceID = pieceID; mIndex = index; }
	void				getDresID(MrgSint32& pieceID, MrgUint32& index) const  { pieceID = mPieceID; index = mIndex; }
	static MrgResHistory* getResHistory(MrgSint32 pieceID, MrgUint32 index, MrgUint16 sz = 0);

	// restore cache from stream
	MrgUint16			restoreCache(istream& stream);


	MrgResHistory *		mResHistory;	// face resolution history
	MrgSint32			mPieceID;		// id of piece this faceset is on
	MrgUint32			mIndex;			// index of this faceset on piece

	// face reordering
	MrgUint16*			mOrigMap;

private:
	// delete and copy data
	void				deleteData(void);
	void				copyData(const MrgFaceSet& src);

	// friends
	friend class MrgVertexData;
#ifdef MRGPLAY
	friend class MeshObj;
#endif //MRGPLAY
};
