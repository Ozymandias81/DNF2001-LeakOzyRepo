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
// manager.h
// ------------
// Header file for MrgManager

#pragma once

#include "mrg/types.h"
#include "mrg/coord.h"
#include "mrg/matrix.h"

class MrgModel;
class MrgTimer;
class MrgCharacter;

class MrgManager
{
private:
	// initial options
	static const MrgUint8	kOptions;
	static const float		kPolyDistFac, kPolyRangeFac, kPolyAreaFac;	
	static const MrgUint8	kSample;
	static const float		kFrDelta;
	static const float		kDistAdj;
public:
	// constructor
	MrgManager();
	
	// destructor
	virtual ~MrgManager();

	// models
	MrgUint16			add(MrgModel* model, MrgBoolean update = TRUE);
	MrgUint16			add(MrgCharacter* character, MrgBoolean update = TRUE);
	MrgUint16			remove(MrgModel* model, MrgBoolean update = TRUE);
	MrgUint16			getNumModels(void) const { return mNumCharacters; }
	MrgCharacter*		getCharacter(const MrgModel* model) const;
	MrgUint16			getModels(MrgModel**& models) const;
	MrgCharacter**		getCharacters(MrgUint16& numCharacters) const { numCharacters = mNumCharacters; return mCharacters; }
	MrgUint16			getCharacterAt(MrgUint16 index, MrgCharacter*& character) const;
	MrgUint16			getModelAt(MrgUint16 index, MrgModel*& model) const;
	void				clear(void);
	void				clearAndDelete(void);

	// reset internal polygon count memory
	MrgUint16			updateCounts(const MrgModel* model);
	MrgUint16			updateCounts(MrgCharacter* character);
	MrgUint16			updateCountsAt(MrgUint16 index);

	// bounding box
	void				getBoundingBox(const MrgMatrix& xform, MrgCoord3D& min, MrgCoord3D& max) const;

	// poly count
	MrgUint32			getPolyCount(void) const { return mCurrentPolys; }
	MrgUint16			getPolyCount(MrgModel* model, MrgUint32& count) const;
	MrgUint16			getPolyCount(MrgCharacter* model, MrgUint32& count) const;
	MrgUint16			getPolyCountAt(MrgUint16 index, MrgUint32& count) const;
	MrgUint16			setPolyCount(MrgUint32 maxPolys, MrgUint32& actualPolys );
	MrgUint16			setPolyCount(MrgModel* model, MrgUint32 maxPolys, MrgUint32& actualPolys );
	MrgUint16			setPolyCount(MrgCharacter* model, MrgUint32 maxPolys, MrgUint32& actualPolys );
	MrgUint16			setPolyCountAt(MrgUint16 index, MrgUint32 maxPolys, MrgUint32& actualPolys );
	MrgUint32			getPolyCountTarget(void) const { return mPolyTarget; }
	
	// update poly count
	MrgUint16			updatePolyCount(void) { return setPolyCount(mPolyTarget, mCurrentPolys); }

	// camera data
	void				setCameraData(const MrgCoord3D& cameraPosition, const MrgCoord3D& cameraDirection, float fovy,
								MrgBoolean updateVisAndDist = TRUE);
	float				getMaxDistance(void) const { return mMaxDist; }
	float				getMinDistance(void) const { return mMinDist; }

	// screen data
	void				setScreenData(const MrgCoord2Di& dimension, MrgBoolean updateArea = TRUE);

	// positions
	MrgUint16			setPosition(MrgModel* model, const MrgCoord3D& position, MrgBoolean updateVisAndDist = TRUE);
	MrgUint16			setPosition(MrgCharacter* character, const MrgCoord3D& position, MrgBoolean updateVisAndDist = TRUE);
	MrgUint16			setPositionAt(MrgUint16 index, const MrgCoord3D& position, MrgBoolean updateVisAndDist = TRUE);
	MrgUint16			getPosition(MrgModel* model, MrgCoord3D& position) const;
	MrgUint16			getPosition(MrgCharacter* character, MrgCoord3D& position) const;
	MrgUint16			getPositionAt(MrgUint16 index, MrgCoord3D& position) const;
	
	// scales
	MrgUint16			setScale(MrgModel* model, const MrgCoord3D& scale, MrgBoolean updateVisAndDist = TRUE);
	MrgUint16			setScale(MrgCharacter* character, const MrgCoord3D& scale, MrgBoolean updateVisAndDist = TRUE);
	MrgUint16			setScaleAt(MrgUint16 index, const MrgCoord3D& scale, MrgBoolean updateVisAndDist = TRUE);
	MrgUint16			getScale(MrgModel* model, MrgCoord3D& scale) const;
	MrgUint16			getScale(MrgCharacter* character, MrgCoord3D& scale) const;
	MrgUint16			getScaleAt(MrgUint16 index, MrgCoord3D& scale) const;


	// options
	void				setOptions(MrgUint8 options);
	MrgUint8			getOptions(void) const { return mOptions; }

	// option factors
	void				setOptionFactors(float rangeFactor, float distanceFactor, float areaFactor);
	void				getOptionFactors(float& rangeFactor, float& distanceFactor, float& areaFactor) const;

	// visible
	MrgUint16			isVisible(MrgModel* model, MrgBoolean& visible) const;
	MrgUint16			isVisible(MrgCharacter* character, MrgBoolean& visible) const;
	MrgUint16			isVisibleAt(MrgUint16 index, MrgBoolean& visible) const;
	MrgBoolean			usingTrueVis(void) const { return mTrueVis; }
	void				useTrueVis(MrgBoolean useIt = TRUE);
	const MrgBoolean*	getVisibility(void) const { return mVisible; }
	
	// frame rate
	MrgUint16			trackFrameRate(MrgBoolean track = TRUE);
	void				resetTrackFrameRate(void);
	MrgUint16			setFrameRateTarget(float fps, MrgUint8 sampleEvery = kSample, float frameRange = kFrDelta);
	float				getFrameRate(void) const;
	float				getFrameRateTarget(void) const { return mFrTarget; }
	void				resetFrameRate(void) { setFrameRateTarget(0.0f); }
	void				frame(void);

	// public type index function
	MrgUint16			index(const MrgModel* model, MrgUint16& index) const;
	MrgUint16			index(const MrgCharacter* model, MrgUint16& index) const;
protected:
	// index of models
	MrgSint32			getIndex(const MrgModel* model) const;
	MrgSint32			getIndex(const MrgCharacter* model) const;
	
	// models
	MrgCharacter**		mCharacters;		// populace
	MrgUint16			mNumCharacters;		// number of characters
	MrgBoolean *		mVisible;			// each visible character
	// camera data
	MrgCoord3D			mCamera;			// last known camera position
	float				mFovY;				// last known fov-y
	MrgCoord3D			mCamDirection;		// last known camera direction
	// options
	MrgUint8			mOptions;			// options
	MrgBoolean			mTrueVis;			// using true-visiblity?
	// Polygon Count data
	MrgUint32			mCurrentPolys;		// current polygon count
	MrgUint32			mPolyTarget;		// target polygon count
	float				mPolyDistFac;		// options factor for distance
	float				mPolyRangeFac;		// options factor for poly range
	float				mPolyAreaFac;		// options factor for screen area
	// frame rate data
	MrgUint32			mFrames;			// number of frames
	float				mFrTarget;			// frame rate target
	MrgUint8			mFrSample;			// adjust polys for frame rate every n frames
	float				mFrDelta;			// frame rate range
	// world->screen xform
	MrgMatrix			mCSXform;			// camera->screen transformation
	MrgMatrix			mWCXform;			// world->camera transform (modelview)
	MrgCoord2Di			mScreenDim;			// screen dimension
	MrgUint32			mScreenArea;		// screen area
private:
	// Mrg data
	float				mMaxDist;			// maximum distance 
	float				mMinDist;			// minimum distance
	float				mDistRangeSquared;	// squared distance range
	MrgUint32			mTotalRange;		// sum of all res level ranges
	MrgUint32			mTotalMaxCount;		// sum of all res level counts at res level max
	MrgUint32			mTotalMinCount;		// sum of all res level counts at res level 0
	MrgTimer*			mFrTimer;			// frame rate timer
	MrgSint32			mFrLastPolyChange;	// last frame rate poly target

	// compute visibility of characters
	MrgBoolean			calcVis(MrgUint16 index) const;
	static MrgBoolean	isVisible(const MrgCoord3D& pos, const MrgCoord3D& cam,
									const MrgCoord3D& camDir, float fovy, float fAspect);
};

// inlines
inline void							
MrgManager::getOptionFactors(float& rangeFactor, float& distanceFactor, float& areaFactor) const
{ rangeFactor = mPolyRangeFac; distanceFactor = mPolyDistFac; areaFactor = mPolyAreaFac;}
