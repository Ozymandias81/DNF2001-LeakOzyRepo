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
// texfaceset.h
// ------------
// Class declaration of TexFaceSet object, a textured face set

#pragma once

#include "mrg/faceset.h"

class MrgPixmap;

class MrgTexFaceSet : public MrgFaceSet
{
	MRG_DECLARE(MrgTexFaceSet)

public:
	// constructors
	MrgTexFaceSet();
	MrgTexFaceSet(const MrgTexFaceSet& src);
	MrgTexFaceSet(const MrgFaceSet& src);

	// destructor
	virtual ~MrgTexFaceSet();

	// assignment operator
	MrgTexFaceSet&		operator =(const MrgTexFaceSet& src);

	// texture itself
	const MrgPixmap*	getTexture(void) const { return mTexture; }
	MrgPixmap*			getTexture(void) { return mTexture; }
	void				setTexture(MrgPixmap* tex);

protected:
	
	// persistence
	virtual MrgUint32	getSizeOfBlock() const;
#ifndef NOSTREAMS
	virtual ostream&	saveOn(ostream& stream) const;
	virtual istream&	restoreFrom(istream& stream);
#endif //!NOSTREAMS

	MrgPixmap*			mTexture;
private:

	// delete and copy data
	void				deleteData(void);
	void				copyData(const MrgTexFaceSet& src);
};
