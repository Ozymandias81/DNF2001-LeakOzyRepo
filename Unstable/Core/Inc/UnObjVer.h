/*=============================================================================
	UnObjVer.h: Unreal object version.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

/*-----------------------------------------------------------------------------
	Version coding.
-----------------------------------------------------------------------------*/

// Earliest engine build that is network compatible with this one.
#define ENGINE_MIN_NET_VERSION 400

// Engine build number, for displaying to end users.
#define ENGINE_VERSION 400

// Base protocol version to negotiate in network play.
#define ENGINE_NEGOTIATION_VERSION 400

// Prevents incorrect files from being loaded.
#define PACKAGE_FILE_TAG 0x9E2A83C1

// The current Unrealfile version.
#define PACKAGE_FILE_VERSION 68

// The earliest file version which we can load with complete
// backwards compatibility. Must be at least PACKAGE_FILE_VERSION.
#define PACKAGE_MIN_VERSION 60

// CDH: Licensee version number, stored in upper word of previously 32-bit
//      package version, which is now only 16 bits.

// Version 0: Initial
// Version 1: Serialize structures with tagged properties instead of in binary
// Version 2: Added flags and category to UStruct, and meaning to UNameProperty
#define PACKAGE_LICENSEE_VERSION 2

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
