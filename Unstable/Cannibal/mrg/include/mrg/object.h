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
// object.h
// --------
// Class declaration of MRG persisted Object

#pragma once

#include "mrg/types.h"

#ifndef NOSTREAMS
class istream;
class ostream;
#endif //!NOSTREAMS

class MrgObject
{
public:
	// default constructor
	MrgObject() { }

	// copying
	virtual MrgObject*	copy(void) const = 0;

	// persistence
#ifndef NOSTREAMS
	virtual ostream&	saveOn(ostream& stream) const;
	virtual istream&	restoreFrom(istream& stream);
	virtual const MrgUint8 getTag(void) const = 0;
#endif //!NOSTREAMS
	virtual MrgUint32	getSizeOfBlock() const;

#ifdef _DEBUG
	// dictionary entry verification
	virtual MrgBoolean	isVertexData(void) const { return FALSE; }
	virtual MrgBoolean	isFaceSet(void) const { return FALSE; }
	virtual MrgBoolean	isPixmap(void) const { return FALSE; }
#endif //_DEBUG

	// create next class instance
#ifndef NOSTREAMS
	static MrgObject*	createFrom(istream& stream, MrgBoolean restore = TRUE);
	
	friend ostream&	operator << (ostream& stream, const MrgObject& obj);
	friend istream&	operator >> (istream& stream, MrgObject& obj);
#endif //NOSTREAMS
	
};

// class creation function

typedef MrgObject*(*MrgNewInstanceFn)(void);

// add stuff to factory
void mrgAddToFactory(MrgUint8 classID, MrgNewInstanceFn function);

// revmoe stuff from factory
void mrgRemoveFromFactory(MrgUint8 classID);

// DEFINE's for MRG_DECLARE and MRG_DEFINE:

#ifdef NOSTREAMS
#define MRG_DECLARE(className)	\
public:\
	virtual MrgObject*	copy(void) const;\
	static MrgObject*	newInstance(void);\
	virtual const MrgUint8 getTag(void) const;\
	static const MrgUint8 tag(void);

#define MRG_DEFINE(className,classID)	\
	MrgObject*	className::copy(void) const { return new className(*this); }\
	MrgObject*	className::newInstance(void) { return new className; }\
	const MrgUint8 className::getTag(void) const { return classID; }\
	const MrgUint8 className::tag(void) { return classID; }\
	struct _mrg##className {\
		_mrg##className();\
		~_mrg##className();\
	};\
	_mrg##className::_mrg##className() { mrgAddToFactory(classID,className::newInstance); }\
	_mrg##className::~_mrg##className() { mrgRemoveFromFactory(classID); }\
	_mrg##className s_mrg##className;
#else
#define MRG_DECLARE(className)	\
public:\
	virtual MrgObject*	copy(void) const;\
	static MrgObject*	newInstance(void);\
	virtual const MrgUint8 getTag(void) const;\
	static const MrgUint8 tag(void);\
	friend ostream&	operator << (ostream& stream, const className& obj);\
	friend istream&	operator >> (istream& stream, className& obj);
#define MRG_DEFINE(className,classID)	\
	MrgObject*	className::copy(void) const { return new className(*this); }\
	MrgObject*	className::newInstance(void) { return new className; }\
	const MrgUint8 className::getTag(void) const { return classID; }\
	const MrgUint8 className::tag(void) { return classID; }\
	ostream&	operator << (ostream& stream, const className& obj) { return obj.saveOn(stream); }\
	istream&	operator >> (istream& stream, className& obj) { return obj.restoreFrom(stream); }\
	struct _mrg##className {\
		_mrg##className();\
		~_mrg##className();\
	};\
	_mrg##className::_mrg##className() { mrgAddToFactory(classID,className::newInstance); }\
	_mrg##className::~_mrg##className() { mrgRemoveFromFactory(classID); }\
	_mrg##className s_mrg##className;
#endif //NOSTREAMS