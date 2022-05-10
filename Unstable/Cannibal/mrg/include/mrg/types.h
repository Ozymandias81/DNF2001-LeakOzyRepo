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
// types.h
// -------
// general types and enumerations

#pragma once

#if defined(_MAC)

// Macintosh

typedef signed char		MrgSint8;
typedef signed short		MrgSint16;
typedef signed long		MrgSint32;
typedef unsigned char	MrgUint8;
typedef unsigned short	MrgUint16;
typedef unsigned long	MrgUint32;

// type Boolean already defined by Universal Headers

#elif defined(IRIX)

// SGI IRIX

typedef signed char		MrgSint8;
typedef signed short		MrgSint16;
typedef signed int		MrgSint32;
typedef unsigned short	MrgUint8;
typedef unsigned short	MrgUint16;
typedef unsigned int		MrgUint32;

typedef unsigned char	MrgBoolean;

#else // assume windows-like

// Microsoft Windows (32-bit)

typedef signed char		MrgSint8;
typedef signed short	MrgSint16;
typedef signed long		MrgSint32;
typedef unsigned char	MrgUint8;
typedef unsigned short	MrgUint16;
typedef unsigned long	MrgUint32;

typedef unsigned char	MrgBoolean;


#endif

// ----- define MRG init progress callback
enum MrgInitProgressState {
	MRG_INIT_SCRUB,
	MRG_INIT_FACES,
	MRG_INIT_BOUNDS,
	MRG_INIT_CURVES,
	MRG_INIT_COLLAPSE,
	MRG_INIT_REORDER,
	MRG_INIT_SORT,
};
typedef MrgBoolean (*MrgInitProgressFn)(MrgInitProgressState state, MrgUint8 percent,void *userData);

// ----- define MRG stream progress callback
typedef MrgBoolean (*MrgStreamProgressFn)(MrgUint16 maxDownRes,void *userData);

// ----- define TRUE, FALSE, and NULL
#ifndef TRUE
#define TRUE	1
#endif

#ifndef FALSE
#define FALSE	0
#endif

#ifndef NULL
#define NULL	0
#endif

// ----- Define PI if not already defined
#ifndef M_PI
#define M_PI	 3.14159265359
#endif //M_PI

// ----- Manager Options
#define MRG_AVAILABLE		0x01
#define MRG_DISTANCE		0x02
#define MRG_VISIBLE			0x04
#define MRG_AREA			0x08
#define MRG_AREA_VIS		0x10 // never set just MRG_AREA_VIS
#define MRG_AREA_WITH_VIS	0x18 // set MRG_AREA_WITH_VIS instead

// ----- Error Codes
#define MRG_SUCCESS			0x0000
#define MRG_INVALIDARG		0x0001
#define MRG_OUTOFMEM		0x0002
#define MRG_UNABLEINIT		0x0004
#define MRG_UNABLERESTORE	0x0008
#define MRG_BADOPTION		0x0010
#define MRG_UNABLESAVE		0x0020
#ifndef MRGLITE
#define MRG_MUSTINIT		0x0040
#endif //MRGLITE


