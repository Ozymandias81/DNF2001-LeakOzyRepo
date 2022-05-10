/** MRG
 **
 ** (c)1997-1998 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

//////////////////////////////////////////////////////////////////////////////
// model.h
// --------
// Class declaration of Model Object

#pragma once

#include "mrg/types.h"
#include "mrg/coord.h"
#include "mrg/matrix.h"
#include "mrg/object.h"

class MrgVertexData;
class MrgHier;
class MrgFaceSet;
class MrgInitOption;

class MrgModel : public MrgObject
{
	MRG_DECLARE(MrgModel)

public:
	// constructors
	MrgModel();
	MrgModel(MrgHier* hier);
	MrgModel(const MrgModel& src);

	// destructor
	virtual ~MrgModel();

	// assignment operator
	MrgModel&				operator =(const MrgModel& src);

	// merge with another model
	MrgUint16				merge(MrgModel& src);

	// add/remove vertex data, facesets, or hierarchies
	MrgUint16				addMesh(MrgHier* hier, MrgHier* parent = NULL);
	MrgUint16				removeMesh(MrgHier* hier, MrgBoolean kill = TRUE);

	// get mesh hierarchy
	MrgHier*				getHierarchy(void) { return mRoot; }
	const MrgHier*			getHierarchy(void) const { return mRoot; }

	// get vertex data
	MrgVertexData**			getVertexData(void) const { return mVData; }
	MrgVertexData**			getVertexData(MrgUint16& num) const { num = mNumVData; return mVData; }

	// get bounding box:
	virtual MrgBoolean		getBoundingBox(const MrgMatrix& xform,MrgCoord3D &min,MrgCoord3D &max) const;
	
	// down-res stuff
	MrgUint16			initMRG(const MrgInitOption* options = NULL,
									  MrgUint32 startAt = 0, MrgUint32 stopAt=0,
									  MrgInitProgressFn updateFunc = NULL,
									  void* userData = NULL);
	MrgUint16			initMRG(const MrgInitOption* options,
									  MrgInitProgressFn updateFunc,
									  void* userData = NULL);
	MrgUint16			initMRG(MrgUint32 startAt, MrgUint32 stopAt=0,
									  MrgInitProgressFn updateFunc = NULL,
									  void* userData = NULL);
	MrgUint16			initMRG(MrgInitProgressFn updateFunc, void* userData = NULL);
	
	MrgUint16			setResLevel(MrgUint32 level, MrgSint32& polyChange);
	MrgUint16			setResLevel(MrgUint32 level);
	MrgUint32			getResLevel(void) const { return mDownResLevel; }
	MrgUint32			getMaxResLevel(void) const { return mDownResMax; }
	MrgUint32			getNumFaces(void) const;
	MrgBoolean			isInit(void) const { return mMrgInit; }
	MrgUint16			initCache(void);

	// get the poly count below which texture mapping gets degraded
	MrgUint16			getTexDegradePolys(void) const {return mTexDegPolys;}
	
#ifndef NOSTREAMS
	// persistence
	MrgUint16			getPersistenceBlock(void*& memoryBlock, MrgUint32& sizeOfBlock) const;
	MrgUint16			restoreFromPersistenceBlock(void* memoryBlock);
	virtual ostream&	saveOn(ostream& stream) const;
	virtual istream&	restoreFrom(istream& stream);
	MrgUint16			readAllStreamSegs(istream& stream,
							MrgStreamProgressFn updateFn =NULL,
							void* userData = NULL);
	MrgUint16			readAllStreamSegs(void *memoryBlock,
							MrgStreamProgressFn updateFn =NULL,
							void* userData = NULL);
	virtual MrgUint16	readStreamSeg(istream& stream);
	MrgUint16			writeFile(const char* filename) const;
	MrgUint16			readFile(const char* filename,
							MrgBoolean readAllStreams = TRUE,
							MrgStreamProgressFn updateFn = NULL,
							void* userData = NULL);
	MrgUint16			writeFile(ostream& stream) const;
	MrgUint16			readFile(istream& stream, MrgBoolean readAllStreams = TRUE,
							MrgStreamProgressFn updateFn = NULL,
							void* userData = NULL);	
	static MrgModel*	createFromFile(const char* filename,
							MrgBoolean readAllStreams = TRUE,
							MrgStreamProgressFn updateFn = NULL,
							void* userData = NULL);

	// export to MRGPlay
	MrgUint16			exportPlay(const char* filename, const MrgFaceSet* fs) const;
	MrgUint16			exportPlay(ostream &stream, const MrgFaceSet* fs) const;
#endif //NOSTREAMS
	// calculate block size
	virtual MrgUint32	getSizeOfBlock() const;
	MrgUint32			getSizeOfPlayBlock(const MrgFaceSet* fs) const;

	// get next vertex group action
	const MrgVertexData*		getNextVData(void) const;
	// EDITING
	MrgUint16			nextNeighbor(const MrgVertexData* vdata);
	MrgUint16			nextVertex(const MrgVertexData* vdata);
	MrgUint16			nextVertex(const MrgVertexData* vdata, MrgUint16 idx);
	MrgUint16			nextToMin(const MrgVertexData* vdata);
	MrgUint16			removeFromMin(const MrgVertexData* vdata, MrgUint16 idx);	
	MrgUint16			complete(const MrgVertexData* vdata, const MrgInitOption* options = NULL,
								MrgUint16 steps = 0, MrgInitProgressFn updateFunc =NULL, void* userData =NULL);

	// down res ratios
	const float*		getDownResRatios(void) const { return mDownResRatio; }
	const float*		getDownResRatios(MrgUint16& num) const { num = mNumVData; return mDownResRatio; }
	MrgUint16			setDownResRatios(const float* ratios);
	
	// misc.
	void				reverseFaces(void);
	void				calcVertexNorms(void);

	// save streamed format
	static MrgBoolean	sSaveStreamed;

protected:
	
	MrgUint16			setResLevel(MrgUint32 level, MrgSint32& polyChange) const;
	MrgUint16			setResLevel(MrgUint32 level) const;
	MrgUint16			appendVData(MrgHier* hier); // append vertex data from hier


	MrgHier*			mRoot;				// root of hierarchy
	MrgVertexData**		mVData;				// vertex data
	MrgUint16			mNumVData;			// # of vertex data
	MrgUint32			mDownResMax;		// maximum down-res level
	MrgUint32			mDownResLevel;		// current down-res level
	MrgBoolean			mMrgInit;			// Mrg initialized?
	
	// down-res stuff
	MrgUint16			startDownRes(MrgBoolean sort = TRUE);
	MrgUint8			calcResLevels(MrgUint32 level) const;

	// sort down-res ratios
	void				sortDownResRatios(void);
	
	// progress
	static MrgBoolean	doUpdateFunc(MrgInitProgressState state, MrgUint8 percent, void* model);
	MrgBoolean			updateFunc(MrgInitProgressState state, MrgUint8 percent);

	MrgUint16			mTexDegPolys;  // # of polys at which texture degredation begins

	float*				mDownResRatio;		// down-res vdata ratio cycle
	MrgUint16*			mDownResLevels;		// workspace for vdata res level calcs
	MrgInitProgressFn	mUpdateFunc;		// update progress function
	void*				mUserData;			// user data
	
private:
	void				copyData(const MrgModel& src);
	void				deleteData(void);

public:
	static const MrgUint32	kCurrentFileVersion;	// file version			

};
