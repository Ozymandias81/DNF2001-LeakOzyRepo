/** MRGPlay
 **
 ** (c)1998 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

/* mrgplay.h
*/

/* NOTE : This file must remain C compatible! (ie: no C++ style comments)
*/

#pragma once

/* common basic macro defintison */

#ifndef NULL
#ifdef __cplusplus
#define NULL	0
#else
#define NULL	((void*)0)
#endif /*_cplusplus */
#endif /*NULL*/
#ifndef TRUE
#define TRUE	1
#endif /*TRUE*/
#ifndef FALSE
#define FALSE	0
#endif /*FALSE*/

#if defined(_WIN32)

/* Microsoft Windows (32-bit) */

typedef signed char		MrgSint8;
typedef signed short	MrgSint16;
typedef signed long		MrgSint32;
typedef unsigned char	MrgUint8;
typedef unsigned short	MrgUint16;
typedef unsigned long	MrgUint32;

typedef unsigned char	MrgBoolean;

#elif defined(_MAC)

/* Macintosh */

typedef signed char		MrgSint8;
typedef signed short		MrgSint16;
typedef signed long		MrgSint32;
typedef unsigned char	MrgUint8;
typedef unsigned short	MrgUint16;
typedef unsigned long	MrgUint32;

/* type Boolean already defined by Universal Headers */

#elif defined(IRIX)

/* SGI IRIX */

typedef signed char		MrgSint8;
typedef signed short		MrgSint16;
typedef signed int		MrgSint32;
typedef unsigned short	MrgUint8;
typedef unsigned short	MrgUint16;
typedef unsigned int		MrgUint32;

typedef unsigned char	MrgBoolean;

#endif

#undef DllExport

#ifdef MRGPLAY
#define DllExport   __declspec( dllexport )
#else
#define DllExport   __declspec( dllimport )
#endif /*MRGPLAY*/

#ifdef MRGLITE
class MrgTri;
#else
typedef struct _MrgTri
{
	MrgUint16 points[3];
} MrgTri;
#endif /*MRGLITE*/


#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef enum {
	MRG_NOERR,		/*	Operation was successful */
	MRG_OUTOFMEMORY,/*	The application has run out of memory */
	MRG_NOSUCHMESH,	/*	The mesh with the given ID could not be found */
	MRG_NOSUCHFILE,	/*	The file specified could not be read/written */
	MRG_BADFILE,	/*	Errors occurred while trying to read/write the file */
	MRG_BADPARAM,	/*	A parameter specified to the function was NULL or out of range */
	MRG_BADMEM,		/*	The memory block specified was invalid for reading/writing meshes */
	MRG_BADMESH,	/*	Errors occurred while trying to process the mesh */
	MRG_MUSTINIT,	/*	MrgCore must be initialized before any other function may be used */
	MRG_INTERNAL,	/*	An internal MRG error has occured */
} MrgErrCode;

/* function prototypes */

DllExport MrgErrCode	MrgInit(void);
DllExport MrgErrCode	MrgCreateMesh(MrgUint16* meshID);
DllExport MrgErrCode	MrgCopyMesh(MrgUint16 srcID, MrgUint16* meshID);
DllExport MrgErrCode	MrgFreeMesh(MrgUint16 meshID);
DllExport MrgErrCode	MrgLoadMeshFromFile(MrgUint16 meshID, const char* filename);
DllExport MrgErrCode	MrgSaveMeshToFile(MrgUint16 meshID, const char* filename);
DllExport MrgErrCode	MrgLoadMeshFromMemory(MrgUint16 meshID, void* address);
DllExport MrgErrCode	MrgSaveMeshToMemory(MrgUint16 meshID, void* address, MrgUint32* sizeOfBlock);
DllExport MrgErrCode	MrgSetMeshResLevel(MrgUint16 meshID, MrgUint16 resLevel);
DllExport MrgErrCode	MrgGetMeshResLevel(MrgUint16 meshID, MrgUint16* resLevel);
DllExport MrgErrCode	MrgGetMeshMaxResLevel(MrgUint16 meshID, MrgUint16* maxResLevel);
DllExport MrgErrCode	MrgGetMeshPolyCount(MrgUint16 meshID, MrgUint16* polyCount);
DllExport MrgErrCode	MrgSetMeshPolyCount(MrgUint16 meshID, MrgUint16 polyCount);
DllExport MrgTri*		MrgGetMeshTriangleArray(MrgUint16 meshID, MrgUint16* numTris);
DllExport MrgTri*		MrgGetMeshTexTriangleArray(MrgUint16 meshID, MrgUint16* numTris);
DllExport MrgTri*		MrgGetMeshOriginalTriangleArray(MrgUint16 meshID, MrgUint16* numTris);
DllExport MrgErrCode	MrgGetMeshVertexCount(MrgUint16 meshID, MrgUint16* count);
DllExport MrgErrCode	MrgGetMeshTexVertexCount(MrgUint16 meshID, MrgUint16* count);
DllExport MrgErrCode	MrgGetMeshReorderList(MrgUint16 meshID, MrgUint16** map, MrgUint16* numVerts);
DllExport MrgErrCode	MrgGetMeshTexReorderList(MrgUint16 meshID, MrgUint16** map, MrgUint16* numVerts);
DllExport MrgErrCode	MrgTerminate(void);
#ifdef _DEBUG
DllExport MrgUint32		MrgTime(void);
#endif /* _DEBUG */
// ver 1.5
DllExport MrgErrCode	MrgGetMeshFaceReorderList(MrgUint16 meshID, MrgUint16** map, MrgUint16* numFaces);
// ver 1.6
DllExport MrgErrCode	MrgUpResMesh(MrgUint16 meshID, MrgUint16* num, const MrgUint16** from, MrgUint16* reborn,
		   MrgUint16* numKills, MrgUint16* numChanges, const MrgUint16** changes);
DllExport MrgErrCode	MrgDownResMesh(MrgUint16 meshID, MrgUint16* num, MrgUint16* from, const MrgUint16** to,
		   MrgUint16* numKills, MrgUint16* numChanges, const MrgUint16** changes);
#ifdef __cplusplus
}
#endif /* __cplusplus */
