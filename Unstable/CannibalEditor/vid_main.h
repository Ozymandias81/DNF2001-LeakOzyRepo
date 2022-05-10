#ifndef __VID_MAIN_H__
#define __VID_MAIN_H__
//****************************************************************************
//**
//**    VID_MAIN.H
//**    Header - Video System
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#ifndef _XCORE_H_
#include <xcore.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------

#define VID_API_VERSION 13

typedef enum
{
	VCM_FLAT,
	VCM_GOURAUD,
	VCM_TEXTURE,
	VCM_FLATTEXTURE,
	VCM_GOURAUDTEXTURE,

	VCM_NUMTYPES
} vidcolormodetype_t;

typedef enum
{
	VAM_FLAT,
	VAM_GOURAUD,
	VAM_TEXTURE,
	VAM_DEPTH,

	VAM_NUMTYPES
} vidalphamodetype_t;

typedef enum
{
	VBM_OPAQUE,
	VBM_OPAQUETOTAL,
	VBM_TRANS,
	VBM_TRANSTOTAL,
	VBM_TRANSMERGE,

	VBM_NUMTYPES
} vidblendmodetype_t;

typedef enum
{
	VWM_SHOWCLOCKWISE,
	VWM_SHOWCOUNTERCLOCKWISE,
	VWM_SHOWALL,

	VWM_NUMTYPES
} vidwindingmodetype_t;

typedef enum
{
	VFM_NONE,
	VFM_BILINEAR,

	VFM_NUMTYPES
} vidfiltermodetype_t;

typedef enum
{
	VMM_ENABLE,
	VMM_DISABLE,

	VMM_NUMTYPES
} vidmaskmodetype_t;

typedef enum
{
	VTA_NORMAL,
	VTA_XO,
	VTA_YO,

	VTA_NUMTYPES
} vidtexactivatetype_t;

typedef enum
{
	VLS_READFRONT,
	VLS_READBACK,
	VLS_WRITEFRONT,
	VLS_WRITEBACK,

	VLS_NUMTYPES
} vidlockscreentype_t;

//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
typedef struct
{
	float x;
	float y;
	float z;
} vector_str;

#ifdef CANNIBAL_TOOL
#define vector_type vector_t
#else
#define vector_type vector_str
#endif

//typedef struct vidtex_s vidtex_t;
class VidTex;

typedef struct
{
	VidTex *tex;
	int texMemOfs, xoTexMemOfs, yoTexMemOfs;
	int texMemSize; // size for each of the three listed above; actual memory size is texMemSize*3
} vidtexslot_t;

class VidTex
{
	/* Grrr... */
public:
	CStrRef	name;
	U32 width,height;
	U32 bpp;
	char			*tex_data;
	autoptr<char>	tex_free;

	float timestamp;
public:
	VidTex(CC8 *Name,U32 width,U32 height,U32 format);
	VidTex(void){}
};

typedef struct
{
	U32 width;
	U32 height;
}vidresolution_t;

typedef struct
{
	// version
	int vidApiVersion;
	
	// data
	vidresolution_t *resolution;
	unsigned long *maskColor;
	unsigned long *flatshadeColor;
	VidTex **activeTex;
	VidTex **blankTex;
	U8 *charDrawable;

	// functions
	void (*Activate)(void);
	void (*Deactivate)(void);
	void (*Init)(int xRes, int yRes);
	void (*Shutdown)(void);
	void (*ResetPolyCounts)(void);
	void (*GetPolyCounts)(int *numPolys, int *numLines);

	void (*ClearScreen)(void);
	void (*Swap)(void);
	void (*ClipWindow)(I32 x1,I32 y1,I32 x2,I32 y2);
	void (*ColorActive)(U8 enable);
	void (*DepthActive)(U8 enable);

	void (*FlatColor)(int r, int g, int b);
	void (*FlatAlpha)(int a);
	void (*MaskColor)(int r, int g, int b, int a);
	vidcolormodetype_t (*ColorMode)(vidcolormodetype_t vcmtype);
	vidalphamodetype_t (*AlphaMode)(vidalphamodetype_t vamtype);
	vidblendmodetype_t (*BlendMode)(vidblendmodetype_t vbmtype);
	vidwindingmodetype_t (*WindingMode)(vidwindingmodetype_t vwmmode);
	vidfiltermodetype_t (*FilterMode)(vidfiltermodetype_t vfmmode);
	vidmaskmodetype_t (*MaskMode)(vidmaskmodetype_t vmmmode);

	void (*ForceDraw)(U8 enable);
	void (*Antialias)(U8 enable);
	void (*DrawLine)(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2, U8 useDepth);
	void (*DrawLineBox)(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2, U8 useDepth);
	void (*DrawTriangle)(vector_type *p /* 3 */, vector_type *c /* 3 */, float *a /* 3 */, vector_type *tv /* 3 */, U8 useDepth);
	void (*DrawPolygon)(int numverts, vector_type *p, vector_type *c, float *a, vector_type *tv, U8 useDepth);
	void (*DrawPolygonFlags)(U32 flags,int numverts, vector_type *p, vector_type *c, float *a, vector_type *tv, U8 useDepth);
	void (*DrawString)(int x1, int y1, int dx, int dy, char *str, U8 filtered, int r, int g, int b);

	VidTex *(*TexLoad)(CPathRef &path,U8 fatal);
	VidTex *(*TexLoadBMP)(CC8 *filename, U8 fatal);
	VidTex *(*TexLoadTGA)(CC8 *filename, U8 fatal);
	int (*TexLoadGBAFont)(CC8 *filename, U8 fatal);
	VidTex *(*TexForName)(char *name);
	int (*TexActivate)(VidTex *tex, vidtexactivatetype_t vta);
	int (*TexUpload)(VidTex *tex);
	int (*TexReload)(VidTex *tex);

	int (*TexRelease)(VidTex *tex);

	int (*LockScreen)(vidlockscreentype_t lock, unsigned short **buffer, int *pitch);
	void (*UnlockScreen)();

	void (*DebugFront)();
} vid_export_t;

typedef struct
{
	void (*Error)(char *text, ...);
	void *(*SafeMalloc)(int size);
	void (*SafeFree)(void **ptr);
	char *(*GetFilePath)(char *filename);
	char *(*GetFileRoot)(CC8 *filename);
	char *(*GetFileName)(char *filename);
	char *(*GetFileExtention)(CC8 *filename);
	void (*ForceFileExtention)(char *filename, char *extention);
	void (*SuggestFileExtention)(char *filename, char *extention);
	float (*GetTimeFloat)();
} vid_import_t;

//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
extern U8 vid_dllActive;
extern vid_export_t vid;
extern vid_import_t sys;

//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------

//****************************************************************************
//**
//**    END HEADER VID_MAIN.H
//**
//****************************************************************************
#ifdef __cplusplus
}
#endif

#endif // __VID_MAIN_H__
