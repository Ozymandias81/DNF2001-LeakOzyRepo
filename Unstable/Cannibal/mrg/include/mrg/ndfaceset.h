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
// ndfaceset.h
// ------------
// Class declaration of NdFaceSet object, a face set with Non Duplicated Vertices

#pragma once

#include "mrg/faceset.h"

class MrgNdFaceSet : public MrgFaceSet
{
	MRG_DECLARE(MrgNdFaceSet)

public:
	// constructors
	MrgNdFaceSet();
	MrgNdFaceSet(const MrgNdFaceSet& src);
#ifndef MRGLITE
	MrgNdFaceSet(const MrgFaceSet& src, const MrgCoord3D* points, MrgUint16 numPoints);
#endif //MRGLITE

	// destructor
	virtual ~MrgNdFaceSet();

	// assignment operator
	MrgNdFaceSet&		operator =(const MrgNdFaceSet& src);

	// non-dupe faces
#ifndef MRGLITE
	MrgUint16			calcFaces(const MrgCoord3D* points, MrgUint16 numPoints);
#endif //MRGLITE
	const MrgTri*		getNonDupeFaces(void) const { return mNdFaces; }

#ifdef MRGLITE
	// build non-dupe original point map
	MrgUint16			buildOrigMap(const MrgUint16* map);
	const MrgUint16*	getOrigMap(MrgUint16& numMap) { numMap = mNumMap; return mMap; }
#endif //MRGLITE

protected:

	// persistence
	virtual MrgUint32	getSizeOfBlock() const;
#ifndef NOSTREAMS
	virtual ostream&	saveOn(ostream& stream) const;
	virtual istream&	restoreFrom(istream& stream);
#ifndef MRGLITE
	virtual ostream&	saveStreamSeg(ostream& stream, MrgUint16 numPoints) const;
	virtual MrgUint16	readStreamSeg(istream& stream, MrgUint16 newPoints);	
#endif //!MRGLITE
#endif //!NOSTREAMS

#ifndef MRGLITE
	// swapping & welding points
	virtual void		weldPoints(MrgUint16 from, MrgUint16 to);
	virtual void		swapPoints(MrgUint16 from, MrgUint16 to);
	virtual void		nextVertex(MrgUint16 dead, MrgUint16 down, MrgUint16 next, MrgUint16 up);	

	// unimplemented functions:
	virtual void		movePoints(MrgUint16 from, MrgSint16 adj, MrgUint16 count);
	virtual MrgUint16	duplicateVertex(MrgUint16 idx, MrgUint16 dupes);
	virtual MrgUint16	postInit(MrgUint16 numPoints, const MrgUint16* reorderList, const MrgUint16* neighbors);


	// down-res stuff	
	virtual MrgUint16	downRes(MrgUint16 count, const MrgUint16 from,const MrgUint16* to,MrgBoolean clearHistory, const MrgCoord3D* points);
	virtual MrgUint16	upRes(MrgUint16 count, const MrgUint16* from, const MrgUint16 to, const MrgCoord3D* points);	
#else
	virtual MrgUint16	downRes(MrgUint16 count, const MrgUint16 from,const MrgUint16* to,MrgBoolean clearHistory);
	virtual MrgUint16	upRes(MrgUint16 count, const MrgUint16* from, const MrgUint16 to);
#endif
	virtual void		swapFaces(MrgUint16 from, MrgUint16 to);



	MrgTri*				mNdFaces;
	MrgUint16*			mNdMap;
	MrgUint16			mNumNdMap;
#ifdef MRGLITE
	MrgUint16*			mMap;
	MrgUint16			mNumMap;
#endif //MRGLITE

private:

	// delete and copy data
	void				deleteData(void);
	void				copyData(const MrgNdFaceSet& src);

	// friends
	friend class MrgPart;
	friend class MrgPiece;
	friend class MrgFaceSet;
#ifdef MRGPLAY
	friend class MeshObj;
#endif //MRGPLAY
};

