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
// character.h
// ------------
// Header file for MrgCharacter

#pragma once

#include "mrg/types.h"
#include "mrg/coord.h"

class MrgModel;
class MrgMatrix;

class MrgCharacter
{
public:	
	// constructor
	MrgCharacter(MrgModel* model);
	
	// destructor
	virtual ~MrgCharacter();

	// model
	MrgModel*			getModel(void) const { return mModel; }
	
	// poly count and res. level
	virtual MrgUint32	getPolyCount(void) const;
	virtual MrgUint32	getPolyCount(void);
	virtual MrgUint16	setPolyCount(MrgUint32 target, MrgUint32& actual);
	MrgUint32			getResLevel(void) const;
	MrgUint32			getMaxResLevel(void) const { return mMaxResLevel; }
	MrgUint32			getResLevelRange(void) const { return mResLevelRange; }
	MrgUint16			getResLevelPolyCount(MrgUint32 level, MrgUint32& count) const;
	MrgUint32			getMaxResLevelPolyCount(void) const { return mResLevelCount[mMaxResLevel]; }
	float				getResRangeFactor(void) const  { return mResRangeFac; }
	void				computeResRangeFactor(MrgUint32 totalRange) { mResRangeFac = (float) mResLevelRange / (float) totalRange; }
	MrgUint16			setResLevel(MrgUint32 level);

	// update memory of res level counts
	void				updateCounts(void);

	// position, distance, area, scale
	const MrgCoord3D&	getPosition(void) const { return mPosition; }
	void				setPosition(const MrgCoord3D& position) { mPosition = position; }
	float				getDistance(void) const { return mDistance; }
	void				setDistance(float dist) { mDistance = dist; }
	void				setDistance(const MrgCoord3D& cam);
	float				getArea(void) const { return mArea; }
	float				setArea(float area) { return (mArea = area); }
	float				setArea(const MrgMatrix& model, const MrgMatrix& proj, const MrgCoord2Di& dim);
	float				setArea(const MrgMatrix& model, const MrgMatrix& proj);
	void				getScale(float& scaleX, float& scaleY, float& scaleZ) const;
	void				getScale(MrgCoord3D& scale) const { scale = mScale; }
	void				setScale(float uniformScale);
	void				setScale(const MrgCoord3D& scale) { mScale = scale; }
	void				setScale(float scaleX, float scaleY, float scaleZ);

	// bounding box
	void				getBoundingBox(const MrgMatrix& xform, MrgCoord3D& min, MrgCoord3D& max);
	
protected:
	// cached bounding box
	void				getBoundingBox(MrgCoord3D& min, MrgCoord3D& max);

	// get a bounding box of a transformed bounding box
	void				getBoundingBoxBox(const MrgMatrix& xform, const MrgCoord3D& min,
								const MrgCoord3D& max, MrgCoord3D& lmin,
								MrgCoord3D& lmax);



	// use a binary search to find the level needed for our target poly count
	MrgUint16			setPolyCount(MrgUint32 target, MrgUint32 minLevel, MrgUint32 maxLevel, MrgUint32& actual);

	MrgModel*			mModel;			// Model
	MrgCoord3D			mPosition;		// position
	MrgUint32			mMaxResLevel;	// maximum res level
	MrgUint32*			mResLevelCount;	// poly count at each res level
	MrgUint32 			mResLevelRange;	// range of polys from 0 to max
	float				mResRangeFac;	// res level range factor
	float				mDistance;		// distance to camera
	float				mArea;			// window area
	MrgCoord3D			mScale;			// scale
	MrgCoord3D			mMin,mMax;		// identity bounding box

};

