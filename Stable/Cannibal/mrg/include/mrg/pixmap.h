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
// pixmap.h
// -------
// defintions for MrgPixmap class -- a class providing a common interface to a
// platform dependent Pixmap

#pragma once

#include "mrg/types.h"

class MrgCoord2Di;
class MrgPixmapRef;
class MrgSaveDict;
#ifndef NOSTREAMS
class istream;
class ostream;
#endif //NOSTREAMS

#ifdef _WIN32
#ifndef STRICT
#define STRICT
#endif //STRICT
#include <wtypes.h>
#endif //_WIN32

class MrgPixmap
{
public:
	MrgPixmap() : mRef(NULL) { }
	MrgPixmap(const MrgPixmap& src);
	MrgPixmap(const MrgCoord2Di& dim, MrgUint8* rgb);
	MrgPixmap(const char* filename);
#ifdef _WIN32
	MrgPixmap(MrgUint16 id, HINSTANCE hInst, HDC hdc, MrgBoolean store = FALSE);
	MrgPixmap(HDC hDC, HBITMAP hBitmap, MrgBoolean store = FALSE);
#endif //_WIN32

	virtual ~MrgPixmap();

	// validity
	MrgBoolean			isValid(void) const { return (mRef != NULL); }

	// assignment
	MrgPixmap&			operator =(const MrgPixmap& src);

	// comparison
	MrgBoolean			operator == (const MrgPixmap& src) const;

	// get size:
	const MrgCoord2Di&	getDimensions(void) const;

	// get raw data
	const MrgUint8*		getRawData(void) const;

	// save/restore data to stream:
	MrgUint32			getSizeOfBlock() const;
#ifndef NOSTREAMS
	ostream&			saveOn(ostream& stream) const;
	istream&			restoreFrom(istream& stream);
	
	friend istream&	operator >> (istream& stream, MrgPixmap& pix);
	friend ostream& operator << (ostream& stream, const MrgPixmap& pix);
#endif //!NOSTREAMS


	// save inline or just filenames
	static MrgBoolean	sSaveInline;

	// get file name reference
	const char*			getFilename(void) const;

	// get file resource ID
	MrgUint16			getResID(void) const;

	// create from file
	static MrgPixmap *	createFromFile(const char* filename);

	// get # of unique pixmaps in memory
	static MrgUint16	getNumUniquePixmaps(void);
	
protected:
	// pixmap reference
	MrgPixmapRef*		mRef;

private:
	void				copyData(const MrgPixmap& src);
	void				deleteData(void);
	
	// persistence types
	enum SaveType { kInstance, kFile, kInline };

	friend class MrgModel;

public:
// PLATFORM DEPENDENT CODE :
#if defined(_WIN32)
public:
	HBITMAP			getWinBitmap(HDC hDC, MrgBoolean store = FALSE) const;	
	HBITMAP			getWinBitmap(HDC hDC, MrgBoolean store = FALSE);	
	// resize the bitmap
	MrgPixmap *			resizeToFit(HDC hDC, const MrgCoord2Di& dim,MrgBoolean keepAspect = TRUE,
									MrgBoolean store = FALSE) const;
	// save a windows bitmap
	MrgBoolean		writeWindowsBitmap(const char* filename, MrgBoolean storeName=TRUE) const;
#endif //_WIN32
#if defined (PSX)
	// free pixel memory (assumed to have been copied out)
	void			freePixmapData(void);
#endif //PSX
};
