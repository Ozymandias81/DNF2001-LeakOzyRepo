/**
 ** MRG
 **
 ** (c)1997 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

////////////////////////////////////////////////////////////////////////////
// opt.h
// -------
// MRG Initalization option structure

#pragma once

#include "mrg/types.h"

class MrgInitOption
{
public:
	MrgInitOption();	// default constructor sets all defaults
	
	// init options
	float mWeldDistance;
	float mVolumeWeight;
	float mDistanceWeight;
	float mAreaWeight;
	float mCurveWeight;
	float mCollapseWeight;
	MrgUint8 mNeighborDepth;
	
	float mEdgeWeight;
	MrgBoolean mNeighborhood;

	MrgBoolean mPreserveFaces;
	MrgBoolean mPreserveUnref;

	MrgBoolean mHoldMinFaces;

	// default values
	static const float kWeldDistance;
	static const float kVolumeWeight;
	static const float kDistanceWeight;
	static const float kAreaWeight;
	static const float kCurveWeight;
	static const float kCollapseWeight;
	static const MrgUint8 kNeighborDepth;

	
	static const float kEdgeWeight;
	static const MrgBoolean kNeighborhood;

	static const MrgBoolean kPreserveFaces;
	static const MrgBoolean kPreserveUnref;

	static const MrgBoolean kHoldMinFaces;
};
