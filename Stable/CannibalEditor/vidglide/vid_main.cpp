//****************************************************************************
//**
//**    VID_MAIN.CPP
//**    Video System
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include <windows.h>
#include <windowsx.h>
#include <commctrl.h>

#include <stdio.h>

#include <glide.h>
#include <xtypes.h>
//#include <math_vec.h>
#include <float.h>
#include <xcore.h>
#include <vid_main.h>
#include "vidglide.h"
#ifdef __cplusplus
extern "C" {
#endif

#pragma intrinsic(memset)

//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
#define VIDTEX_MAXTEXTURES	512

#define NUMLODS 9
#define NUMASPECTS 7

#define ALLOC(type, num) (type*)sys.SafeMalloc((num)*sizeof(type))
#define FREE(ptr) sys.SafeFree((void **)&ptr)

//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
typedef struct
{
	GrTexInfo texInfo;
	GrTexInfo *xoTexInfo;
	GrTexInfo *yoTexInfo;
} vidtexinfo_t;

typedef struct
{
	void *totaldata; // alloc'ed
	BITMAPINFO *info; // points into totaldata, do not free! 
	void *imagedata; // points into totaldata, do not free!
	int width, height, bitdepth; // extracted from info
} bmpimg_t;

typedef struct
{
	void *data;
}tgaimg_t;

//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
GrLOD_t vid_LODs[NUMLODS] = { GR_LOD_1, GR_LOD_2, GR_LOD_4, GR_LOD_8, GR_LOD_16,
	GR_LOD_32, GR_LOD_64, GR_LOD_128, GR_LOD_256 }; // val = (1 << index)

GrAspectRatio_t vid_Aspects[NUMASPECTS] = { GR_ASPECT_8x1, GR_ASPECT_4x1,
	GR_ASPECT_2x1, GR_ASPECT_1x1, GR_ASPECT_1x2, GR_ASPECT_1x4, GR_ASPECT_1x8 };

struct vid_Resolution_s
{
    int xRes, yRes;
    GrScreenResolution_t grRes;
} vid_Resolutions[] = {
    { 320, 200, GR_RESOLUTION_320x200 },
    { 320, 240, GR_RESOLUTION_320x240 },
    { 400, 256, GR_RESOLUTION_400x256 },
    { 512, 384, GR_RESOLUTION_512x384 },
    { 640, 200, GR_RESOLUTION_640x200 },
    { 640, 350, GR_RESOLUTION_640x350 },
    { 640, 400, GR_RESOLUTION_640x400 },
    { 640, 480, GR_RESOLUTION_640x480 },
    { 800, 600, GR_RESOLUTION_800x600 },
    { 960, 720, GR_RESOLUTION_960x720 },
    { 856, 480, GR_RESOLUTION_856x480 },
    { 512, 256, GR_RESOLUTION_512x256 },
    { 1024, 768, GR_RESOLUTION_1024x768 },
    { 1280, 1024, GR_RESOLUTION_1280x1024 },
    { 1600, 1200, GR_RESOLUTION_1600x1200 },
    { 400, 300, GR_RESOLUTION_400x300 },
    { 0, 0, GR_RESOLUTION_640x480 },
};

int vid_Ratios[NUMASPECTS] = { 64, 32, 16, 8, 4, 2, 1 };

int vid_texMemPtr;
int vid_texMemLimit;
static int vid_numLines=0, vid_numPolys=0;

static boolean vid_Initialized = 0;
static boolean vid_depthActive = 1;
static boolean vid_antialias = 0;
static GrHwConfiguration vid_glideConfig;

//static vidtex_t vid_Textures[VIDTEX_MAXTEXTURES];
//static vidtexinfo_t vid_TextureInfo[VIDTEX_MAXTEXTURES];
//static vidtexslot_t vid_TextureSlots[VIDTEX_MAXTEXTURES];
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
vid_export_t vid;
vid_import_t sys;

vidresolution_t vid_resolution;
unsigned long vid_maskColor, vid_flatshadeColor;
VidTex *vid_activeTex, *vid_blankTex;
byte vid_charDrawable[260];

//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
static void ErrorCallback(const char *string, FxBool fatal);
static int OpenBMP(CC8 *filename, bmpimg_t *bInfo);
static int FreeBMP(bmpimg_t *bInfo);

//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
void SafeRead(void *ptr, int elemSize, int numElems, FILE *fp)
{
	unsigned actual;
	if ((actual = fread(ptr, (unsigned)elemSize, (unsigned)numElems, fp)) != (unsigned)numElems)
		sys.Error("SafeRead failure, %d elements read, %d attempted", actual, numElems);
}

void SafeWrite(void *ptr, int elemSize, int numElems, FILE *fp)
{
	if (fwrite(ptr, elemSize, numElems, fp) != (unsigned)numElems)
		sys.Error("SafeWrite failure");
}

static void VSet(vector_str *v, float x, float y, float z)
{
	v->x = x; v->y = y; v->z = z;
}

static void ErrorCallback(const char *string, FxBool fatal)
{
	if (fatal)
		sys.Error("GLIDE: Fatal Error - %s", string);
	else
		sys.Error("GLIDE: Recoverable Error - %s", string);
}

static int OpenBMP(CC8 *filename, bmpimg_t *bInfo)
{
	BITMAPFILEHEADER fhdr;
	char filebuf[_MAX_PATH];
	
	bInfo->totaldata = NULL;
	
	strcpy(filebuf, filename);
	
	sys.ForceFileExtention(filebuf, "BMP");
	
	FILE *fp = fopen(filebuf, "rb");	
	if (!fp)
		return(0);
	
	SafeRead(&fhdr, sizeof(BITMAPFILEHEADER), 1, fp);	
	if (fhdr.bfType != 0x4D42) // "BM"
	{
		fclose(fp);
		return(0);
	}
	bInfo->totaldata = ALLOC(char, fhdr.bfSize-sizeof(BITMAPFILEHEADER));
	SafeRead(bInfo->totaldata, 1, fhdr.bfSize-sizeof(BITMAPFILEHEADER), fp);
	bInfo->info = (BITMAPINFO *)bInfo->totaldata;
	bInfo->imagedata = (byte *)bInfo->totaldata
		+ fhdr.bfOffBits - sizeof(BITMAPFILEHEADER);
	fclose(fp);
	
	bInfo->width = bInfo->info->bmiHeader.biWidth;
	bInfo->height = bInfo->info->bmiHeader.biHeight;
	bInfo->bitdepth = bInfo->info->bmiHeader.biBitCount;
	return(1);
}

static int FreeBMP(bmpimg_t *bInfo)
{
	if (bInfo->totaldata)
		FREE(bInfo->totaldata);
	return(1);
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
VidTex *VID_TexLoadBMP(CC8 *filename, boolean fatal);
VidTex *VID_TexLoadTGA(CC8 *filename, boolean fatal);

// Video system maintenance

void VID_Activate()
{
	if (!vid_Initialized)
		return;
	if (!grSstControl(GR_CONTROL_ACTIVATE))
		sys.Error("VID_Activate: activation failure");
}

void VID_Deactivate()
{
	if (!vid_Initialized)
		return;
	if (!grSstControl(GR_CONTROL_DEACTIVATE))
		sys.Error("VID_Deactivate: deactivation failure");
}

void VAPI_Init(int xRes, int yRes)
{
	static char version[80];
	float ver;
	int i;

	XImageLibInit();

	grGlideInit();
	grGlideGetVersion(version);
	ver = (float)atof(version);
	if (ver < 2.43f)
		sys.Error("VID_Init: This program requires Glide 2.43 or higher to be installed");
	if (!grSstQueryHardware(&vid_glideConfig))
		sys.Error("VID_Init: failure to initialize");
	grSstSelect(0);	
	for (i=0;vid_Resolutions[i].xRes;i++)
    {
        if ((xRes == vid_Resolutions[i].xRes) && (yRes == vid_Resolutions[i].yRes))
        {
            if (!grSstWinOpen(0, vid_Resolutions[i].grRes, GR_REFRESH_60Hz,
		        GR_COLORFORMAT_ABGR, GR_ORIGIN_UPPER_LEFT, 2, 1))
		        sys.Error("VID_Init: failure to initialize");
            break;
        }
    }
    if (!vid_Resolutions[i].xRes)
    {
        sys.Error("VID_Init: invalid resolution");
    }
    grErrorSetCallback(ErrorCallback);

	_vg_dll.init_cache();

	grDitherMode(GR_DITHER_DISABLE);
	grDepthBufferMode(GR_DEPTHBUFFER_WBUFFER);
	grDepthBufferFunction(GR_CMP_LESS);
	vid.DepthActive(true);
	grTexMipMapMode(GR_TMU0, GR_MIPMAP_NEAREST, FXFALSE);
	grTexClampMode(GR_TMU0, GR_TEXTURECLAMP_WRAP, GR_TEXTURECLAMP_WRAP);
	grTexCombine(GR_TMU0, GR_COMBINE_FUNCTION_LOCAL,
		GR_COMBINE_FACTOR_NONE, GR_COMBINE_FUNCTION_LOCAL_ALPHA,
		GR_COMBINE_FACTOR_NONE, FXFALSE, FXFALSE);

	vid.resolution->width=xRes;
	vid.resolution->height=yRes;
	vid.ClipWindow(0, 0, vid.resolution->width, vid.resolution->height);
	vid.ClearScreen();
	vid.Swap();
	vid.FlatColor(255, 255, 255);
	vid.FlatAlpha(255);
	vid.ColorMode(VCM_FLAT);
	vid.AlphaMode(VAM_FLAT);
	vid.BlendMode(VBM_OPAQUE);
	vid.WindingMode(VWM_SHOWCLOCKWISE);
	vid.FilterMode(VFM_NONE);
	vid.MaskMode(VMM_DISABLE);

	vid_texMemPtr = grTexMinAddress(GR_TMU0);
	vid_texMemLimit = grTexMaxAddress(GR_TMU0);
#if 0
	for (i=0;i<VIDTEX_MAXTEXTURES;i++)
	{
		memset(&vid_Textures[i], 0, sizeof(vidtex_t));
		vid_Textures[i].index = -1;
		memset(&vid_TextureInfo[i], 0, sizeof(vidtexinfo_t));
		memset(&vid_TextureSlots[i], 0, sizeof(vidtexslot_t));
	}
#endif
	*vid.blankTex = CreateBlankVidtex();
	memset(vid.charDrawable, 0, sizeof(vid.charDrawable));
	vid.TexLoadGBAFont("resource\\fontdata.gba", true);
	vid.charDrawable[' '] = 1;
	vid_Initialized = 1;

}

void VAPI_Shutdown()
{
	grGlideShutdown();
}

void VID_ResetPolyCounts()
{
	vid_numLines = vid_numPolys = 0;
}

void VID_GetPolyCounts(int *numPolys, int *numLines)
{
	if (numPolys)
		*numPolys = vid_numPolys;
	if (numLines)
		*numLines = vid_numLines;
}

// Frame buffer

void VID_ClearScreen()
{
	grBufferClear(0x000000, 0, GR_WDEPTHVALUE_FARTHEST);
}

void VID_Swap()
{
	grBufferSwap(1);
}

void VID_ClipWindow(I32 x1,I32 y1,I32 x2,I32 y2)
{
	if (x1 < 0)
		x1 = 0;
	if (y1 < 0)
		y1 = 0;
	if (x2 > (I32)vid.resolution->width)
		x2 = (int)vid.resolution->width;
	if (y2 > (I32)vid.resolution->height)
		y2 = (int)vid.resolution->height;
	grClipWindow(x1, y1, x2, y2);
}

void VID_ColorActive(boolean enable)
{
	grColorMask(enable, enable);
}

void VID_DepthActive(boolean enable)
{
	grDepthMask(enable);
}

// Mode stuff

void VID_FlatColor(int r, int g, int b)
{
	if ((int)(*vid.flatshadeColor&0x00FFFFFF) == ((b<<16)+(g<<8)+r))
		return;
	*vid.flatshadeColor = (*vid.flatshadeColor&0xFF000000)+(b << 16)+(g << 8)+r;
	grConstantColorValue(*vid.flatshadeColor);
}

void VID_FlatAlpha(int a)
{
	if ((int)(*vid.flatshadeColor&0xFF000000) == (a<<24))
		return;
	*vid.flatshadeColor = (*vid.flatshadeColor&0x00FFFFFF)+(a<<24);
	grConstantColorValue(*vid.flatshadeColor);
}

void VID_MaskColor(int r, int g, int b, int a)
{
	if ((int)(*vid.maskColor) == (a << 24)+(b << 16)+(g << 8)+r)
		return;
	*vid.maskColor = (a << 24)+(b << 16)+(g << 8)+r;
	grChromakeyValue(*vid.maskColor);
}

vidcolormodetype_t VID_ColorMode(vidcolormodetype_t vcmtype)
{
	static vidcolormodetype_t oldmode = (vidcolormodetype_t)-1;
	vidcolormodetype_t retmode;

	if (vcmtype == oldmode)
		return(oldmode);
	switch(vcmtype)
	{
	case VCM_FLAT:
		grColorCombine(GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_ONE,
			GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_NONE, FXFALSE);
		break;
	case VCM_GOURAUD:
		grColorCombine(GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_ONE,
			GR_COMBINE_LOCAL_ITERATED, GR_COMBINE_OTHER_NONE, FXFALSE);
		break;
	case VCM_TEXTURE:
		grColorCombine(GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_ONE,
			GR_COMBINE_LOCAL_NONE, GR_COMBINE_OTHER_TEXTURE, FXFALSE);
		break;
	case VCM_FLATTEXTURE:
		grColorCombine(GR_COMBINE_FUNCTION_SCALE_OTHER_ADD_LOCAL, GR_COMBINE_FACTOR_ONE,
			GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_TEXTURE, FXFALSE);
		break;
	case VCM_GOURAUDTEXTURE:
		grColorCombine(GR_COMBINE_FUNCTION_SCALE_OTHER_ADD_LOCAL, GR_COMBINE_FACTOR_ONE,
			GR_COMBINE_LOCAL_ITERATED, GR_COMBINE_OTHER_TEXTURE, FXFALSE);
		break;
	default:
		break;
	}
	retmode = oldmode;
	oldmode = vcmtype;
	return(retmode);
}

vidalphamodetype_t VID_AlphaMode(vidalphamodetype_t vamtype)
{
	static vidalphamodetype_t oldmode = (vidalphamodetype_t)-1;
	vidalphamodetype_t retmode;

	if (vamtype == oldmode)
		return(oldmode);
	switch(vamtype)
	{
	case VAM_FLAT:
		grAlphaCombine(GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_ONE,
			GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_NONE, FXFALSE);
		break;
	case VAM_GOURAUD:
		grAlphaCombine(GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_ONE,
			GR_COMBINE_LOCAL_ITERATED, GR_COMBINE_OTHER_NONE, FXFALSE);
		break;
	case VAM_TEXTURE:
		grAlphaCombine(GR_COMBINE_FUNCTION_SCALE_OTHER,
						GR_COMBINE_FACTOR_ONE,
						GR_COMBINE_LOCAL_NONE,
						GR_COMBINE_OTHER_TEXTURE,
						FXFALSE);
		break;
	case VAM_DEPTH:
		grAlphaCombine(GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_ONE,
			GR_COMBINE_LOCAL_DEPTH, GR_COMBINE_OTHER_NONE, FXFALSE);
		break;
	default:
		break;
	}
	retmode = oldmode;
	oldmode = vamtype;
	return(retmode);
}

vidblendmodetype_t VID_BlendMode(vidblendmodetype_t vbmtype)
{
	static vidblendmodetype_t oldmode = (vidblendmodetype_t)-1;
	vidblendmodetype_t retmode;

	if (vbmtype == oldmode)
		return(oldmode);
	switch(vbmtype)
	{
	case VBM_OPAQUE:
		grAlphaBlendFunction(GR_BLEND_ONE, GR_BLEND_ZERO, GR_BLEND_ONE, GR_BLEND_ZERO);
		break;
	case VBM_OPAQUETOTAL:
		grAlphaBlendFunction(GR_BLEND_ONE, GR_BLEND_ONE, GR_BLEND_ONE, GR_BLEND_ZERO);
		break;
	case VBM_TRANS:
		grAlphaBlendFunction(GR_BLEND_SRC_ALPHA, GR_BLEND_ZERO, GR_BLEND_ONE, GR_BLEND_ZERO);
		break;
	case VBM_TRANSTOTAL:
		grAlphaBlendFunction(GR_BLEND_SRC_ALPHA, GR_BLEND_ONE, GR_BLEND_ONE, GR_BLEND_ZERO);
		break;
	case VBM_TRANSMERGE:
		grAlphaBlendFunction(GR_BLEND_SRC_ALPHA, GR_BLEND_ONE_MINUS_SRC_ALPHA, GR_BLEND_ONE, GR_BLEND_ZERO);
		break;
	default:
		break;
	}
	retmode = oldmode;
	oldmode = vbmtype;
	return(retmode);
}

vidwindingmodetype_t VID_WindingMode(vidwindingmodetype_t vwmmode)
{
	static vidwindingmodetype_t oldmode = (vidwindingmodetype_t)-1;
	vidwindingmodetype_t retmode;

	if (vwmmode == oldmode)
		return(oldmode);
	switch(vwmmode)
	{
	case VWM_SHOWCLOCKWISE:
		grCullMode(GR_CULL_NEGATIVE);
		break;
	case VWM_SHOWCOUNTERCLOCKWISE:
		grCullMode(GR_CULL_POSITIVE);
		break;
	case VWM_SHOWALL:
		grCullMode(GR_CULL_DISABLE);
		break;
	default:
		break;
	}
	retmode = oldmode;
	oldmode = vwmmode;
	return(retmode);
}

vidfiltermodetype_t VID_FilterMode(vidfiltermodetype_t vfmmode)
{
	static vidfiltermodetype_t oldmode = (vidfiltermodetype_t)-1;
	vidfiltermodetype_t retmode;

	if (vfmmode == oldmode)
		return(oldmode);
	switch(vfmmode)
	{
	case VFM_NONE:
		grTexFilterMode(GR_TMU0, GR_TEXTUREFILTER_POINT_SAMPLED, GR_TEXTUREFILTER_POINT_SAMPLED);
		break;
	case VFM_BILINEAR:
		grTexFilterMode(GR_TMU0, GR_TEXTUREFILTER_BILINEAR, GR_TEXTUREFILTER_BILINEAR);
		break;
	default:
		break;
	}
	retmode = oldmode;
	oldmode = vfmmode;
	return(retmode);
}

vidmaskmodetype_t VID_MaskMode(vidmaskmodetype_t vmmmode)
{
	static vidmaskmodetype_t oldmode = (vidmaskmodetype_t)-1;
	vidmaskmodetype_t retmode;

	if (vmmmode == oldmode)
		return(oldmode);
	switch(vmmmode)
	{
	case VMM_ENABLE:
		grChromakeyMode(GR_CHROMAKEY_ENABLE);
		break;
	case VMM_DISABLE:
		grChromakeyMode(GR_CHROMAKEY_DISABLE);
		break;
	default:
		break;
	}
	retmode = oldmode;
	oldmode = vmmmode;
	return(retmode);
}

// Drawing Primitives

static boolean forceDraw = 0;
void VID_ForceDraw(boolean enable)
{
	forceDraw = enable;
}

void VID_Antialias(boolean enable)
{
	vid_antialias = enable;
}

static void ChangeDepth(boolean useDepth)
{
	if (forceDraw)
		useDepth = false;
	if (useDepth != vid_depthActive)
	{
		vid_depthActive = useDepth;
		if (vid_depthActive)
			grDepthBufferFunction(GR_CMP_LESS);
		else
			grDepthBufferFunction(GR_CMP_ALWAYS);
	}
}

void VID_DrawLine(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2, boolean useDepth)
{
	static GrVertex gv1, gv2;
	vidcolormodetype_t vcm;

	ChangeDepth(useDepth);
	if (!p1 || !p2)
		return;
	if (!c1 || !c2)
		vcm = VID_ColorMode(VCM_FLAT);
	else
	{
		vcm = VID_ColorMode(VCM_GOURAUD);
		gv1.r = c1->x; gv1.g = c1->y; gv1.b = c1->z; gv1.a = 255;
		gv2.r = c2->x; gv2.g = c2->y; gv2.b = c2->z; gv2.a = 255;
		gv1.z = gv1.oow = gv2.z = gv2.oow = 1.0;
	}

	gv1.x = p1->x; gv1.y = p1->y;
	gv2.x = p2->x; gv2.y = p2->y;
	if (useDepth)
	{
		gv1.z = p1->z; gv1.oow = 1.0f / gv1.z;
		gv2.z = p2->z; gv2.oow = 1.0f / gv2.z;
	}

	vid_numLines++;
	if (!vid_antialias)
		grDrawLine(&gv1, &gv2);
	else
		grAADrawLine(&gv1, &gv2);
	VID_ColorMode(vcm);
}

void VID_DrawLineBox(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2, boolean useDepth)
{
	static GrVertex gv1, gv2, gv3, gv4;
	vidcolormodetype_t vcm;

	ChangeDepth(useDepth);
	if (!p1 || !p2)
		return;
	if (!c1 || !c2)
		vcm = VID_ColorMode(VCM_FLAT);
	else
	{
		vcm = VID_ColorMode(VCM_GOURAUD);
		gv1.r = c1->x; gv1.g = c1->y; gv1.b = c1->z; gv1.a = 255;
		gv2.r = c2->x; gv2.g = c2->y; gv2.b = c2->z; gv2.a = 255;
		gv3.r = gv4.r = (c1->x+c2->x)/2; gv3.g = gv4.g = (c1->y+c2->y)/2; gv3.b = gv4.b = (c1->z+c2->z)/2; gv3.a = gv4.a = 255;
	}

	gv1.z = gv1.oow = gv2.z = gv2.oow = gv3.z = gv3.oow = gv4.z = gv4.oow = 1.0;
	if (useDepth)
	{
		gv1.z = p1->z; gv1.oow = 1.0f / gv1.z;
		gv2.z = p2->z; gv2.oow = 1.0f / gv2.z;
		gv3.z = gv4.z = (p1->z+p2->z)/2.0f; gv3.oow = gv4.oow = 1.0f / gv3.z;
	}

	vid_numLines += 4;
	gv1.x = p1->x+1.0f;
	gv1.y = p1->y+1.0f;
	gv2.x = p2->x+1.0f;
	gv2.y = p2->y+1.0f;
	gv3.x = p1->x+1.0f;
	gv3.y = p2->y+1.0f;
	gv4.x = p2->x+1.0f;
	gv4.y = p1->y+1.0f;
	grDrawLine(&gv1, &gv4);
	gv1.y -= 1.0f;
	grDrawLine(&gv1, &gv3);
	grDrawLine(&gv3, &gv2);
	grDrawLine(&gv4, &gv2);

	VID_ColorMode(vcm);
}

void VID_DrawTriangle(vector_type *p /* 3 */, vector_type *c /* 3 */, float *a /* 3 */, vector_type *tv /* 3 */, boolean useDepth)
{
	static GrVertex gv[3];
	int i;
	const float vsnap = (float)(3L << 18);
	
	ChangeDepth(useDepth);
	if (!p)
		return;
	memset(gv, 0, 3*sizeof(GrVertex));
	if (c)
	{
		for (i=0;i<3;i++)
		{
			gv[i].r = c[i].x;
			gv[i].g = c[i].y;
			gv[i].b = c[i].z;
		}
	}
	if (a)
	{
		for (i=0;i<3;i++)
			gv[i].a = a[i];
	}
	for (i=0;i<3;i++)
	{
		gv[i].x = p[i].x + vsnap; gv[i].x -= vsnap;
		gv[i].y = p[i].y + vsnap; gv[i].y -= vsnap;
		gv[i].z = gv[i].oow = 1.0; // will be changed if usedepth is on
	}
	if (useDepth)
	{
		for (i=0;i<3;i++)
		{
			gv[i].z = p[i].z;
			gv[i].oow = 1.0f / gv[i].z;
		}
	}
	if (tv)
	{
		for (i=0;i<3;i++)
		{
			gv[i].tmuvtx[0].oow = 1.0f / gv[i].z;
			gv[i].tmuvtx[0].sow = tv[i].x * gv[i].tmuvtx[0].oow;
			gv[i].tmuvtx[0].tow = tv[i].y * gv[i].tmuvtx[0].oow;
		}
	}

	vid_numPolys++;
	grDrawTriangle(&gv[0], &gv[1], &gv[2]);
}

volatile U32 vol_mem=0;

#define TF_TEXBLEND			0x00000800

void VID_DrawPolygonFlags(U32 flags,int numverts, vector_type *p, vector_type *c, float *a, vector_type *tv,U8 useDepth)
{
	static GrVertex gv[64];
	int i;
	const float vsnap = (float)(3L << 18);
	
	ChangeDepth(useDepth);
	if (!p)
		return;
	
//	U32 old_alpha,old_blend;

	if (flags & TF_TEXBLEND)
	{
//		old_alpha=VID_AlphaMode(VAM_TEXTURE);
//		old_blend=VID_BlendMode(VBM_TRANSMERGE);
		grAlphaTestFunction(GR_CMP_GREATER);
		grAlphaTestReferenceValue(0);
	}

	memset(gv, 0, numverts*sizeof(GrVertex));
	if (c)
	{
		for (i=0;i<numverts;i++)
		{
			gv[i].r = c[i].x;
			gv[i].g = c[i].y;
			gv[i].b = c[i].z;
		}
	}
	if (a)
	{
		for (i=0;i<numverts;i++)
			gv[i].a = a[i];
	}
	for (i=0;i<numverts;i++)
	{
		gv[i].x = p[i].x + vsnap; gv[i].x -= vsnap;
		gv[i].y = p[i].y + vsnap; gv[i].y -= vsnap;
		gv[i].z = gv[i].oow = 1.0; // will be changed if usedepth is on
	}
	if (useDepth)
	{
		for (i=0;i<numverts;i++)
		{
			gv[i].z = p[i].z;
			gv[i].oow = 1.0f / gv[i].z;
		}
	}
	if (tv)
	{
		for (i=0;i<numverts;i++)
		{
			gv[i].tmuvtx[0].oow = 1.0f / gv[i].z;
			gv[i].tmuvtx[0].sow = tv[i].x * gv[i].tmuvtx[0].oow;
			gv[i].tmuvtx[0].tow = tv[i].y * gv[i].tmuvtx[0].oow;
		}
	}

	vid_numPolys += numverts-2;
	//grDrawPlanarPolygonVertexList(numverts, gv);
	grDrawPolygonVertexList(numverts, gv);
	if (flags & TF_TEXBLEND)
	{
//		VID_AlphaMode((vidalphamodetype_t)old_alpha);
//		VID_BlendMode((vidblendmodetype_t)old_blend);
		grAlphaTestFunction(GR_CMP_ALWAYS);
	}
}

void VID_DrawPolygon(int numverts, vector_type *p, vector_type *c, float *a, vector_type *tv, boolean useDepth)
{
	static GrVertex gv[64];
	int i;
	const float vsnap = (float)(3L << 18);
	
	ChangeDepth(useDepth);
	if (!p)
		return;
	memset(gv, 0, numverts*sizeof(GrVertex));
	if (c)
	{
		for (i=0;i<numverts;i++)
		{
			gv[i].r = c[i].x;
			gv[i].g = c[i].y;
			gv[i].b = c[i].z;
		}
	}
	if (a)
	{
		for (i=0;i<numverts;i++)
			gv[i].a = a[i];
	}
	for (i=0;i<numverts;i++)
	{
		gv[i].x = p[i].x + vsnap; gv[i].x -= vsnap;
		gv[i].y = p[i].y + vsnap; gv[i].y -= vsnap;
		gv[i].z = gv[i].oow = 1.0; // will be changed if usedepth is on
	}
	if (useDepth)
	{
		for (i=0;i<numverts;i++)
		{
			gv[i].z = p[i].z;
			gv[i].oow = 1.0f / gv[i].z;
		}
	}
	if (tv)
	{
		for (i=0;i<numverts;i++)
		{
			gv[i].tmuvtx[0].oow = 1.0f / gv[i].z;
			gv[i].tmuvtx[0].sow = tv[i].x * gv[i].tmuvtx[0].oow;
			gv[i].tmuvtx[0].tow = tv[i].y * gv[i].tmuvtx[0].oow;
		}
	}

	vid_numPolys += numverts-2;
	//grDrawPlanarPolygonVertexList(numverts, gv);
	grDrawPolygonVertexList(numverts, gv);
}

void VID_DrawString(int x1, int y1, int dx, int dy, char *str, boolean filtered, int r, int g, int b)
{
	vidcolormodetype_t vcm;
	vidmaskmodetype_t vmm;
	vidfiltermodetype_t vfm;
	vidalphamodetype_t vam;
	vidblendmodetype_t vbm;
	vector_type p[4], tv[4];
	char *ptr;
	int i, oldmaskcolor, oldflatcolor;

	if (!str)
		return;
	VSet(&tv[0], 0, 0, 0);
	VSet(&tv[1], 192, 0, 0); // 192 since font texture is 8x8 but chars are only 6x6
	VSet(&tv[2], 192, 192, 0);
	VSet(&tv[3], 0, 192, 0);
	ptr = str;
	oldmaskcolor = *vid.maskColor;
	oldflatcolor = *vid.flatshadeColor;
	VID_MaskColor(0, 0, 0, 0);
	VID_FlatColor(r, g, b);
	vcm = VID_ColorMode(VCM_FLATTEXTURE);
	vmm = VID_MaskMode(VMM_ENABLE);
	if (filtered)
		vfm = VID_FilterMode(VFM_BILINEAR);
	else
		vfm = VID_FilterMode(VFM_NONE);
	vam = VID_AlphaMode(VAM_FLAT);
	vbm = VID_BlendMode(VBM_OPAQUE);
	VSet(&p[0], (float)x1,(float)y1, 0.0f);
	VSet(&p[1], (float)(x1+dx),(float)y1, 0.0f);
	VSet(&p[2], (float)(x1+dx),(float)(y1+dy), 0.0f);
	VSet(&p[3], (float)x1,(float)(y1+dy), 0.0f);
	GFont *font=_vg_dll.get_font();
	for (i=0;*ptr;i++,ptr++)
	{
		vid.TexActivate(font->get_tex(*ptr), VTA_NORMAL);
		//vid.TexActivate(vid.TexForName(tbuffer), VTA_NORMAL);
		vid.DrawPolygon(4, p, NULL, NULL, tv, false);
		p[0].x += dx;
		p[1].x += dx;
		p[2].x += dx;
		p[3].x += dx;
	}
	VID_ColorMode(vcm);
	VID_AlphaMode(vam);
	VID_MaskMode(vmm);
	VID_FilterMode(vfm);
	VID_BlendMode(vbm);
	VID_MaskColor(oldmaskcolor&255, (oldmaskcolor>>8)&255, (oldmaskcolor>>16)&255, (oldmaskcolor>>24)&255);
	VID_FlatColor(oldflatcolor&255, (oldflatcolor>>8)&255, (oldflatcolor>>16)&255);
}

void test_texture(GVidTex *tex)
{
	grRenderBuffer(GR_BUFFER_FRONTBUFFER);

	vid.TexActivate(tex,VTA_NORMAL);
	GVertex a,b,c,d;

	a.x=-0.5f;
	a.y=-0.5f;
	a.oow=1.0f;
	a.s0=0.0f;
	a.t0=0.0f;

	b.x=0.5f;
	b.y=-0.5f;
	b.oow=1.0f;
	b.s0=1.0f;
	b.t0=0.0f;

	c.x=0.5f;
	c.y=0.5f;
	c.oow=1.0f;
	c.s0=1.0f;
	c.t0=1.0f;

	d.x=-0.5f;
	d.y=0.5f;
	d.oow=1.0f;
	d.s0=0.0f;
	d.t0=1.0f;

	float sow=tex->gl_info.get_scale_s0();
	float tow=tex->gl_info.get_scale_t0();
	
	a.s0 *= sow;
	a.t0 *= tow;
	b.s0 *= sow;
	b.t0 *= tow;
	c.s0 *= sow;
	c.t0 *= tow;
	d.s0 *= sow;
	d.t0 *= tow;

	float width=(float)vid.resolution->width;
	float height=(float)vid.resolution->height;

	float x_scale=(float)tex->width;
	float y_scale=(float)tex->height;

	a.x= width/2.0f + (a.x * x_scale);
	b.x= width/2.0f + (b.x * x_scale);
	c.x= width/2.0f + (c.x * x_scale);
	d.x= width/2.0f + (d.x * x_scale);

	a.y= height/2.0f + (a.y * y_scale);
	b.y= height/2.0f + (b.y * y_scale);
	c.y= height/2.0f + (c.y * y_scale);
	d.y= height/2.0f + (d.y * y_scale);

	if (tex->gl_info.format==GR_TEXFMT_ARGB_4444)
	{
		grAlphaTestFunction(GR_CMP_ALWAYS);
		grChromakeyMode(GR_CHROMAKEY_DISABLE);
		grDepthBufferFunction(GR_CMP_ALWAYS);

		grAlphaCombine(GR_COMBINE_FUNCTION_SCALE_OTHER,
						GR_COMBINE_FACTOR_ONE,
						GR_COMBINE_LOCAL_NONE,
						GR_COMBINE_OTHER_TEXTURE,
						FXFALSE);
		grColorCombine(GR_COMBINE_FUNCTION_SCALE_OTHER,
						GR_COMBINE_FACTOR_ONE,
						GR_COMBINE_LOCAL_NONE,
						GR_COMBINE_OTHER_TEXTURE,
						FXFALSE);
		grTexCombine(GR_TMU0,
					 GR_COMBINE_FUNCTION_LOCAL,
					 GR_COMBINE_FACTOR_ONE,
					 GR_COMBINE_FUNCTION_LOCAL,
					 GR_COMBINE_FACTOR_ONE,
					 FXFALSE,
					 FXFALSE);
		grAlphaBlendFunction(GR_BLEND_SRC_ALPHA,
							GR_BLEND_ONE_MINUS_SRC_ALPHA,
							GR_BLEND_ONE,
							GR_BLEND_ZERO);
	}
	grDrawTriangle((GrVertex *)&a,(GrVertex *)&b,(GrVertex *)&c);
	grDrawTriangle((GrVertex *)&a,(GrVertex *)&c,(GrVertex *)&d);
}

VidTex *VID_TexLoad(CPathRef &path,boolean fatal)
{
	GVidTex *tex;

	CC8 *ext=path->get_extension();

	if (_stricmp(ext,"tga")==0)
	{
		XImageRef image=XLoadTGADevice(path,_vg_dll.get_img_device());
		if (!image)
		{
			sys.Error("Unable to load %s\n",path->get_path());
			return null;
		}
		tex=new GVidTex(path->get_filename(),image);
	}
	else
		return VID_TexLoadBMP(path->get_path(),TRUE);
	
	return tex;
}

VidTex *VID_TexLoadTGA(CC8 *filename, boolean fatal)
{
	GVidTex	*tex;

	/* try and load image to best fit device */
	XImageRef image=XLoadTGADevice(filename,_vg_dll.get_img_device());
	if (!image)
	{
		sys.Error("Unable to load %s\n",filename);
		return null;
	}
	tex=new GVidTex(sys.GetFileRoot(filename),image);
	
	return tex;
}

// Texture management
VidTex *VID_TexLoadBMP(CC8 *filename, boolean fatal)
{
	GVidTex *tex;
	bmpimg_t bmpInfo;
	int i, k;
	int val, wval, r, g, b;

	if (!OpenBMP(filename, &bmpInfo))
	{
		if (fatal)
			sys.Error("Unable to load %s\n", filename);
		return(NULL);
	}
	tex=new GVidTex(sys.GetFileRoot(filename),bmpInfo.width,bmpInfo.height,IMG_FORMAT_ARGB_1555);
	U16 *tex16=(U16 *)tex->tex_data;
	for (i=0;i<(int)tex->height;i++)
	{
		for (k=0;k<(int)tex->width;k++)
		{
			val = *((int *)((byte *)bmpInfo.imagedata+((tex->height-i-1)*bmpInfo.width+k)*3));
			r = (val >> 16) & 255; g = (val >> 8) & 255; b = val & 255;
			r >>= 3; g >>= 3; b >>= 3;
			wval = (r << 10) + (g << 5) + b + 0x8000;
			tex16[i*tex->width+k] = wval;
		}
	}
	FreeBMP(&bmpInfo);
#if 0
	if (_stricmp(tex->name,"but_blist")==0)
		delete tex;
#endif
	return(tex);
}

VidTex *VID_TexForName(char *name)
{
	VidTex *tex;
	
	if (tex=_vg_dll.get_named_tex(name))
		return tex;
	return (*vid.blankTex);
}

static vidlockscreentype_t lockScreenType;
int VID_LockScreen(vidlockscreentype_t lock, unsigned short **buffer, int *pitch)
{
	GrLfbInfo_t lfbInfo;
	grSstIdle();
	for (int i=0;i<10;i++)
	{
		if (lock == VLS_READBACK)
		{
			if (grLfbLock(GR_LFB_READ_ONLY, GR_BUFFER_BACKBUFFER, GR_LFBWRITEMODE_ANY,
				GR_ORIGIN_UPPER_LEFT, FXFALSE, &lfbInfo) == FXTRUE)
				break;
		}
		else if (lock == VLS_READFRONT)
		{
			if (grLfbLock(GR_LFB_READ_ONLY, GR_BUFFER_FRONTBUFFER, GR_LFBWRITEMODE_ANY,
				GR_ORIGIN_UPPER_LEFT, FXFALSE, &lfbInfo) == FXTRUE)
				break;
		}
		else if (lock == VLS_WRITEBACK)
		{
			if (grLfbLock(GR_LFB_WRITE_ONLY, GR_BUFFER_BACKBUFFER, GR_LFBWRITEMODE_565,
				GR_ORIGIN_UPPER_LEFT, FXFALSE, &lfbInfo) == FXTRUE)
				break;
		}
		else if (lock == VLS_WRITEFRONT)
		{
			if (grLfbLock(GR_LFB_WRITE_ONLY, GR_BUFFER_FRONTBUFFER, GR_LFBWRITEMODE_565,
				GR_ORIGIN_UPPER_LEFT, FXFALSE, &lfbInfo) == FXTRUE)
				break;
		}
		if (i==9)
			return(0);
	}
	lockScreenType = lock;
	if (buffer)
		*buffer = (unsigned short *)lfbInfo.lfbPtr;
	if (pitch)
		*pitch = lfbInfo.strideInBytes>>1; // pitch is in words
	return(1);
}

void VID_UnlockScreen()
{
	if (lockScreenType == VLS_READBACK)
		grLfbUnlock(GR_LFB_READ_ONLY, GR_BUFFER_BACKBUFFER);
	else if (lockScreenType == VLS_READFRONT)
		grLfbUnlock(GR_LFB_READ_ONLY, GR_BUFFER_FRONTBUFFER);
	if (lockScreenType == VLS_WRITEBACK)
		grLfbUnlock(GR_LFB_WRITE_ONLY, GR_BUFFER_BACKBUFFER);
	else if (lockScreenType == VLS_WRITEFRONT)
		grLfbUnlock(GR_LFB_WRITE_ONLY, GR_BUFFER_FRONTBUFFER);
}

void VID_DebugFront(void)
{
	grRenderBuffer(GR_BUFFER_FRONTBUFFER);
	grBufferClear(0x000000, 0, GR_WDEPTHVALUE_FARTHEST);
}

// system hookup

vid_export_t* __cdecl VID_QueryAPI(vid_import_t *import)
{
	sys = *import;
	
	vid.vidApiVersion = VID_API_VERSION;
	vid.resolution = &vid_resolution;
	vid.maskColor = &vid_maskColor;
	vid.flatshadeColor = &vid_flatshadeColor;
	vid.activeTex = &vid_activeTex;
	vid.blankTex = &vid_blankTex;
	vid.charDrawable = vid_charDrawable;
	
	*vid.maskColor = 0;
	*vid.flatshadeColor = 0xFFFFFFFF;
	*vid.activeTex = NULL;

	vid.Activate = VID_Activate;
	vid.Deactivate = VID_Deactivate;
	vid.Init = VAPI_Init;
	vid.Shutdown = VAPI_Shutdown;
	vid.ResetPolyCounts = VID_ResetPolyCounts;
	vid.GetPolyCounts = VID_GetPolyCounts;

	vid.ClearScreen = VID_ClearScreen;
	vid.Swap = VID_Swap;
	vid.ClipWindow = VID_ClipWindow;
	vid.ColorActive = VID_ColorActive;
	vid.DepthActive = VID_DepthActive;

	vid.FlatColor = VID_FlatColor;
	vid.FlatAlpha = VID_FlatAlpha;
	vid.MaskColor = VID_MaskColor;
	vid.ColorMode = VID_ColorMode;
	vid.AlphaMode = VID_AlphaMode;
	vid.BlendMode = VID_BlendMode;
	vid.WindingMode = VID_WindingMode;
	vid.FilterMode = VID_FilterMode;
	vid.MaskMode = VID_MaskMode;

	vid.ForceDraw = VID_ForceDraw;
	vid.Antialias = VID_Antialias;
	vid.DrawLine = VID_DrawLine;
	vid.DrawLineBox = VID_DrawLineBox;
	vid.DrawTriangle = VID_DrawTriangle;
	vid.DrawPolygon = VID_DrawPolygon;
	vid.DrawPolygonFlags = VID_DrawPolygonFlags;
	vid.DrawString = VID_DrawString;

	vid.TexLoad = VID_TexLoad;
	vid.TexLoadBMP = VID_TexLoadBMP;
	vid.TexLoadTGA = VID_TexLoadTGA;
	vid.TexLoadGBAFont = VID_TexLoadGBAFont;
	vid.TexForName = VID_TexForName;
	vid.TexActivate = VID_TexActivate;
	vid.TexUpload = VID_TexUpload;
	vid.TexReload = VID_TexReload;
	vid.TexRelease= VID_TexRelease;

	vid.LockScreen = VID_LockScreen;
	vid.UnlockScreen = VID_UnlockScreen;

	vid.DebugFront = VID_DebugFront;

	return(&vid);
}


//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------

#ifdef __cplusplus
}
#endif
//****************************************************************************
//**
//**    END MODULE VID_MAIN.CPP
//**
//****************************************************************************

