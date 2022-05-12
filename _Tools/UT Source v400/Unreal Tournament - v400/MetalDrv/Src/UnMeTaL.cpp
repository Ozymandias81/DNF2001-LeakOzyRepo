/*=============================================================================
	UnMeTaL.cpp: Unreal support for the S3 MeTaL library.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

/* Dave, Raja, Andy, Derek and Seth for Savage3D!
 *
 * Modifications:
 * Raja:		rewrote init code
 * Raja/Dave:	Glide state function references translated to Metal
 * Dave:		removed 1/w and SCALE multiplication from all texture coordinates
 * Raja/Dave:	Translated other misc. Glide calls to Metal equivalents
 * Raja:		Made it compile, fixed things to work OK untextured
 * Dave:		Eliminated old TMU state concept; merged in basic texture cache
 * Raja:		Fixed lots of Dave's bugs
 * Dave:		Introduced new palette cache
 * Raja:		Taught Dave how to compile the bloody thing
 * Dave:		Got lighting map textures working - put all the SCALE back in
 * Raja:		Tried to fix bugs in Metal palette support
 * Dave:		Tidied out lots of unneeded crap that was getting in the way of debugging
 * Dave/Raja:	Found a major bug in hardware/Metal
 * Dave:		More texture code debugging
 * Dave:		Further Cleanup
 * Dave:		Added dynamic update textures. Potential sync problems here
 * Dave:		Tried to track down texture cache bugs with no luck
 * Derek:		Added hot resolution changing
 * Derek:       Added partial S3D output support (enable by #defining S3D_OUTPUT = 1)
 * Raja:        Merged bug fixes from Seth & dave
 * Raja:        Remove S3D output stuff
 * Raja:        Add AGP texturing
 * Dave:		Serious debug of texture management system
 * Seth:		Update to Unreal version 219
 * Seth:		Attempt to clean things up a little
 * Seth:		MS1 Modifications
 * Seth:		Seperate GX3 & MS1 draw functions
 * Seth:		MS1 multitexturing
 * Raja:        Added Precache() routine 
 * Raja:        Added #ifdef UNREAL_TOURNAMENT to take care of SupportsTC flag that Tim added
 * Seth:		Update to Unreal version 222
 * Seth:		Add support for triple-buffering
 * Seth:		Eliminate lightmap banding
 * Seth:		Fixed problem with dynamic textures
 * Seth:		Added texture stats
 * Seth:		Removed #ifdef UNREAL_TOURNAMENT
 * Seth:		Re-enabled EndFlash
 * Seth:		Fixed corruption in ReadPixels
 */

// Precompiled header.
#include <ddraw.h>
#include "Engine.h"
#include "UnRender.h"

//S3 includes
#define __WIN95__
#include <metal.h>

#ifdef _DEBUG
#define MTL_REPORT_ERR debugf( NAME_Log, TEXT("%s %i - error %d"), __FILE__, __LINE__, metal->mtlGetError())
#define MTL_CALL(f) \
	if ((f) != MTL_OK) \
		MTL_REPORT_ERR;
#else
#define MTL_REPORT_ERR	((void)0)
#define MTL_CALL(f)		((void)(f))
#endif

// Texture upload flags.
enum EMeTaLFlags
{
	MF_Alpha		= 0x01, // 5551 rgba texture.
	MF_NoPalette    = 0x02, // Non-palettized.
	MF_NoScale      = 0x04, // Scale for precision adjust.
	MF_LightMap		= 0x08,	// Light map.
};

// Unreal package implementation.
IMPLEMENT_PACKAGE(MeTaLDrv);

typedef struct
{
  MTL_VALUE sx;
  MTL_VALUE sy;
  MTL_VALUE rhw;
  union
  {
	MTL_COLOR color; // Diffuse
	MTL_COLOR_STRUCT scolor;
  };
  MTL_VALUE tu0;
  MTL_VALUE tv0;
  MTL_VALUE tu1;
  MTL_VALUE tv1;
} FVF_VERTEX;

#define MTL_NUMMODES 12

struct MTLDRV_Resolution
{
	int nX;
	int nY;
	int nColorBytes;
	MTL_MODE Mode;
} Resolutions[] = {	{ 512,  384, 2, MTL_MODE_512_384_16}, 
					{ 512,  384, 4, MTL_MODE_512_384_32},
					{ 640,  480, 2, MTL_MODE_640_480_16},
					{ 640,  480, 4, MTL_MODE_640_480_32},
					{ 800,  600, 2, MTL_MODE_800_600_16},
					{ 800,  600, 4, MTL_MODE_800_600_32},
					{1024,  768, 2, MTL_MODE_1024_768_16},
					{1024,  768, 4, MTL_MODE_1024_768_32},
					{1280, 1024, 2, MTL_MODE_1280_1024_16},
					{1280, 1024, 4, MTL_MODE_1280_1024_32},
					{1600, 1200, 2, MTL_MODE_1600_1200_16},
					{1600, 1200, 4, MTL_MODE_1600_1200_32}};

#define Z_SCALE			(1.0f / 12000.0f)	// Derived empyrically i.e. seeing what values come through
#define Z_NEAR			1.0f				// Similarly derived
#define Z_CORRECT		50.0f
#define Z_CONVERT(w)	((1 - (Z_NEAR+Z_CORRECT)/((w)+Z_CORRECT)))

#define MAX_TEXTURE_UNITS 2
#define MTL_STATS

MTL_TEXBLEND_CONTROL stage0copy =
{
	MTL_TEXBLEND_VERSION_1,
	TRUE,
	MTL_TEXARG_TEXTURE,		MTL_TEXARG_DIFFUSE,		MTL_TEXOP_SELECTARG1,
	MTL_TEXARG_TEXTURE,		MTL_TEXARG_DIFFUSE,		MTL_TEXOP_SELECTARG1
};

MTL_TEXBLEND_CONTROL stage0modulate =
{
	MTL_TEXBLEND_VERSION_1,
	TRUE,
	MTL_TEXARG_TEXTURE,		MTL_TEXARG_DIFFUSE,		MTL_TEXOP_MODULATE,
	MTL_TEXARG_TEXTURE,		MTL_TEXARG_DIFFUSE,		MTL_TEXOP_MODULATE
};

MTL_TEXBLEND_CONTROL stage1multitex =
{
	MTL_TEXBLEND_VERSION_1,
	TRUE,
	MTL_TEXARG_TEXTURE,		MTL_TEXARG_CURRENT,		MTL_TEXOP_MODULATE,
	MTL_TEXARG_TEXTURE,		MTL_TEXARG_CURRENT,		MTL_TEXOP_MODULATE
};

MTL_TEXBLEND_CONTROL stage1off =
{
	MTL_TEXBLEND_VERSION_1,
	TRUE,
	MTL_TEXARG_DIFFUSE,		MTL_TEXARG_CURRENT,		MTL_TEXOP_SELECTARG2,
	MTL_TEXARG_DIFFUSE,		MTL_TEXARG_CURRENT,		MTL_TEXOP_SELECTARG2
};

// DAVE: fast float-int cast
__inline DWORD f2i(float v)
{
	DWORD rv;

	__asm {
		fld v
		fistp rv
	}
	return(rv);
}

typedef struct palette_tag
{
	QWORD id;
	int ref_count;			// Reference count
	MTL_PALETTE handle;		// Handle of the MeTaL palette

	int used;
	int cannot_destroy;		// This gets set if the handle points to the fallback_palette
} Palette_cache;

typedef struct texinfo_data_tag Texinfo_data;
struct texinfo_data_tag
{
	QWORD id;						// Unreal cache ID
	QWORD palette_id;				// Palette ID

	Texinfo_data *next_on_hash;		// Next on hash table
	Texinfo_data *prev_on_cache;	// Dual linked-list structures to make it easy to remove from tail
	Texinfo_data *next_on_cache;

	MTL_TEXTURE vram_handle;		// MeTaL handle for renderable (vram) texture
	
	Palette_cache *palette;			// Pointer to data in above struct
	int mipmap_levels;				// Mipmap level count

	int used;						// Set if in use

	MTL_TEX_FORMAT mtl_native_format;
	/* Data for debugging */
#ifdef _DEBUG
	INT width, height;
	DWORD MeTaLFlags;
#endif // DEBUG
#ifdef MTL_STATS
	DWORD nStatTexSize;
#endif // MTL_STATS
};


/*-----------------------------------------------------------------------------
	UMeTaLRenderDevice definition.
-----------------------------------------------------------------------------*/

//
// The S3 MeTaL rendering device.
//
class DLL_EXPORT UMeTaLRenderDevice : public URenderDevice
{
	DECLARE_CLASS(UMeTaLRenderDevice,URenderDevice,CLASS_Config)

	// Constants.
	enum {ALIGNMENT=8};

	// Variables.
	MTL_CONTEXT		metal;
	INT				X, Y;
	FPlane			FlashScale;
	FPlane			FlashFog;
	DWORD			LockFlags;
	BITFIELD		BuffersExist;
	BITFIELD		DisableTripBuff;

	FLOAT			LastBrightness;

	bool Locked;
	int m_nScreenWidth, m_nScreenHeight, m_nScreenBpp;
	MTL_MODE m_nResolution;

	bool m_bIsMS1;
	int m_nTextureUnits;
	DWORD m_nVRAMSize;
	DWORD m_nBufferMode;

#ifdef MTL_STATS
	DWORD m_nStatUploadsThisFrame;
	DWORD m_nStatUploadsLastFrame;
	DWORD m_nStatTexMemAlloced;
	DWORD m_nStatTexMemInLevel;
	DWORD m_nStatTexUploadPrecache;
	DWORD m_nStatTexFreedPrecache;
	DWORD m_nStatTexUploadLevel;
	DWORD m_nStatTexFreedLevel;
	bool m_bPreCaching;
#endif

	// Dave's Texture Cache. Not C++, so looks pretty nasty here

	void AddEntryToHead(Texinfo_data *cacheentry);
	void UnlinkEntry(Texinfo_data *entry);
	void FreeTailEntry(void);
	Texinfo_data *texture_cache_head;
	Texinfo_data *texture_cache_tail;
	void ClearTextureCache(void);

#define HASH_COUNT   1024
#define HASHINDEX(x) ((x) ^ ((x) >> 10) ^ ((x) >> 20) ^ ((x) >> 30)) & (HASH_COUNT - 1);
	Texinfo_data *hash_table_head[HASH_COUNT];

#define MAX_TEXTURE_CACHE	2048
	Texinfo_data texinfo[MAX_TEXTURE_CACHE];
#define MAX_PALETTES 1024
	Palette_cache palette_table[MAX_PALETTES];

	QWORD		TextureCacheID[MAX_TEXTURE_UNITS];
	Texinfo_data* CurrTexture[MAX_TEXTURE_UNITS];
	int next_texture;

	int m_nFirstPrefMemory;
	int m_nSecondPrefMemory;

#define MAX_LIGHTMAP_SIZE 512
	void *scratchpad;		// Texture memory conversion scratchpad
	DWORD scratchpad_size;

	MTL_PALETTE fallback_palette;

	float UScale[MAX_TEXTURE_UNITS];
	float VScale[MAX_TEXTURE_UNITS];

	int firstframes;
#ifdef CRC_TEXTURES
	int m_nFrameCounter;
#endif

	// Constructer
	UMeTaLRenderDevice();
	
	// UObject interface.
	void StaticConstructor();
	void PostEditChange();

	// URenderDevice interface.
    UBOOL Init( UViewport* InViewport, INT NewX, INT NewY, INT NewColorBytes, UBOOL NewFullscreen );
    UBOOL SetRes( INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen );
	void Exit();
	void Flush( UBOOL AllowPrecache );
	void Lock( FPlane FlashScale, FPlane FlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* HitData, INT* HitSize );
	void Unlock( UBOOL Blit );
	void DrawComplexSurface( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet );
	void DrawGouraudPolygon( FSceneNode* Frame, FTextureInfo& Info, FTransTexture** Pts, int NumPts, DWORD PolyFlags, FSpanBuffer* Span );
	void DrawTile( FSceneNode* Frame, FTextureInfo& Info, FLOAT X, FLOAT Y, FLOAT XL, FLOAT YL, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL, class FSpanBuffer* Span, FLOAT Z, FPlane Color, FPlane Fog, DWORD PolyFlags );
    UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	void Draw2DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector P1, FVector P2 );
	void Draw2DPoint( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FLOAT X1, FLOAT Y1, FLOAT X2, FLOAT Y2, FLOAT Z );
	void GetStats( TCHAR* Result );
	void ClearZ( FSceneNode* Frame );
	void PushHit( const BYTE* Data, INT Count );
	void PopHit( INT Count, UBOOL bForce );
	void ReadPixels( FColor* Pixels );
	void EndFlash();
	void PrecacheTexture(FTextureInfo& Info, DWORD PolyFlags);

	// Functions.
	int PickRes(INT NewX, INT NewY, INT NewColorBytes);
	
	void DrawComplexSurfaceGX3( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet );
	void DrawComplexSurfaceMS1( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet );
	void DrawGouraudPolygonGX3( FSceneNode* Frame, FTextureInfo& Info, FTransTexture** Pts, int NumPts, DWORD PolyFlags, FSpanBuffer* Span );
	void DrawGouraudPolygonMS1( FSceneNode* Frame, FTextureInfo& Info, FTransTexture** Pts, int NumPts, DWORD PolyFlags, FSpanBuffer* Span );
	void DrawTileGX3( FSceneNode* Frame, FTextureInfo& Info, FLOAT X, FLOAT Y, FLOAT XL, FLOAT YL, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL, class FSpanBuffer* Span, FLOAT Z, FPlane Color, FPlane Fog, DWORD PolyFlags );
	void DrawTileMS1( FSceneNode* Frame, FTextureInfo& Info, FLOAT X, FLOAT Y, FLOAT XL, FLOAT YL, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL, class FSpanBuffer* Span, FLOAT Z, FPlane Color, FPlane Fog, DWORD PolyFlags );

	void SelectTexture( int nTextureUnit, FTextureInfo& Info, DWORD MeTaLFlags);
	void DeselectTexture( int nTextureUnit);
	DWORD* ConvertLightMaps(FTextureInfo& Info);

	void SetBlending( DWORD PolyFlags );
	void ResetBlending( DWORD PolyFlags );

#ifdef MTL_STATS
	DWORD CalcSurfaceSize(DWORD dwWidth, DWORD dwHeight, MTL_TEX_FORMAT format, MTL_DWORD cMip);
	int CalcBPP2(MTL_TEX_FORMAT format);
#endif
};
IMPLEMENT_CLASS(UMeTaLRenderDevice);

UMeTaLRenderDevice::UMeTaLRenderDevice()
{
	metal = NULL;
	Locked = false;

	scratchpad_size = NULL;
	scratchpad = NULL;

#ifdef MTL_STATS
	m_bPreCaching = false;
	m_nStatTexMemInLevel = 0;
	m_nStatTexUploadLevel = 0;
	m_nStatTexUploadPrecache = 0;
#endif
}

//-----------------------------------------------------------------------------
//	UMeTaLRenderDevice Init & Exit.
//-----------------------------------------------------------------------------

int UMeTaLRenderDevice::PickRes(INT NewX, INT NewY, INT NewColorBytes)
{
	int nMode;

	if(NewColorBytes == 4)
		nMode = 1;
	else
		nMode = 0;
		
	while((NewX > Resolutions[nMode].nX) && (nMode <= (MTL_NUMMODES-1)))
		nMode += 2;

	return nMode;
}

//
// Try a resolution.
//
UBOOL UMeTaLRenderDevice::SetRes(INT NewX, INT NewY, INT NewColorBytes, UBOOL NewFullscreen = true)
{
	guard(UMeTaLRenderDevice::SetRes);

	// Pick an appropriate resolution.
	int nNewMode = PickRes(NewX, NewY, NewColorBytes);

	// Have we already done this once ?
	if (BuffersExist)
	{
		// Flush all internal stufff
		Flush(1);
		GCache.Flush();

		// Dump the old buffers
		DeselectTexture(0);
		if(m_bIsMS1)
			DeselectTexture(1);
		ClearTextureCache();
		metal->mtlDestroyBuffers();
		BuffersExist = false;

		metal->mtlClose();
		if(mtlOpen(NULL, &metal) != MTL_ERR_NONE)
		{
			debugf(NAME_Init, TEXT("Metal Initialization failed"));
			return 0;
		}
	}

	// Open the display.
	while(nNewMode >= 0)
	{
		if(metal->mtlSetDisplayMode((HWND) Viewport->GetWindow(), Resolutions[nNewMode].Mode) == MTL_OK)
		{
			m_nScreenWidth = Resolutions[nNewMode].nX;
			m_nScreenHeight = Resolutions[nNewMode].nY;
			m_nScreenBpp = Resolutions[nNewMode].nColorBytes * 8;
			m_nResolution = Resolutions[nNewMode].Mode;
			if(m_bIsMS1 && !DisableTripBuff && 
				(m_nVRAMSize > (DWORD)(Resolutions[nNewMode].nX * Resolutions[nNewMode].nY * (2 + 3 * (Resolutions[nNewMode].nColorBytes)))))
				m_nBufferMode = MTL_BUF_TRIPLE_Z;
			else
				m_nBufferMode = MTL_BUF_DOUBLE_Z;
			break;
		}
		if(NewColorBytes == 2) // If 16bit mode requested only fall back to lower es 16bit modes
			nNewMode-=2;
		else
			nNewMode--;
	}
	
	if(nNewMode >= 0)
	{
		// Have set resolution OK, so initialise Metal properly here
		MTL_CALL(metal->mtlCreateBuffers(m_nBufferMode));

		MTL_CALL(metal->mtlSetRenderBuffer(MTL_RENDER_BUFFER_BACK));

		BuffersExist = true;

        MTL_CALL(metal->mtlEraseBuffers(MTL_BUF_BACK | MTL_BUF_Z16));
		MTL_CALL(metal->mtlSwapBuffers());
		MTL_CALL(metal->mtlEraseBuffers(MTL_BUF_BACK | MTL_BUF_Z16));

		// Set default state for Unreal
		metal->mtlSetState(MTL_ST_TEX_FILTER, MTL_TEX_FILTER_4TPP);
		metal->mtlSetState(MTL_ST_TEX_MIPMAP, MTL_TEX_MIPMAP_OFF);
		metal->mtlSetState(MTL_ST_TEX_ADDRESS_MODEL, MTL_TEX_ADDRESS_MODEL_WRAP);
		metal->mtlSetState(MTL_ST_DITHERING, TRUE);
		metal->mtlSetState(MTL_ST_Z_ENABLE, TRUE);
		metal->mtlSetState(MTL_ST_Z_COMPARE, MTL_COMPARE_LESSEQUAL);
		metal->mtlSetState(MTL_ST_ALPHA_REFERENCE, 127);
		metal->mtlSetState(MTL_ST_ALPHA_COMPARE, MTL_COMPARE_GREATER);
		metal->mtlSetState(MTL_ST_TEX_ENABLE, TRUE);

		metal->mtlSetState(MTL_ST_FOG_COLOR, 0x808080);
		metal->mtlSetState(MTL_ST_FOG_MODE_VERTEX, FALSE);
		metal->mtlSetState(MTL_ST_FOG_ENABLE, FALSE);

		if(m_bIsMS1)
		{
			metal->mtlSetState(MTL_ST_Z_FLOAT_ENABLE, TRUE);
			metal->mtlSetState(MTL_ST_VERTEX_FORMAT, (	MTL_VTX_X | MTL_VTX_Y | MTL_VTX_RHW |MTL_VTX_DIFFUSE | 
														MTL_VTX_U0 | MTL_VTX_V0 | MTL_VTX_U1 | MTL_VTX_V1));
		}

		MTL_GAMMA_CONTROL gamma;
		gamma.set = NULL;
		gamma.get = NULL;
		gamma.r = gamma.g = gamma.b =  0.2 + 1.5*Viewport->GetOuterUClient()->Brightness;
		metal->mtlGamma(&gamma);
		LastBrightness = Viewport->GetOuterUClient()->Brightness;
		PrecacheOnFlip = 1;
	}
	else
		return 0;

	Viewport->ResizeViewport(BLIT_Fullscreen, m_nScreenWidth, m_nScreenHeight, m_nScreenBpp/8);

#ifdef MTL_STATS
	m_nStatTexMemAlloced  = 0;
	m_nStatTexUploadLevel = 0;
	m_nStatTexFreedLevel  = 0;
#endif

	return ((m_nScreenWidth == NewX) && (m_nScreenHeight == NewY) && (m_nScreenBpp == NewColorBytes*8));
	unguard;
}

//
// Initializes MeTaL.  Can't fail.
//
UBOOL UMeTaLRenderDevice::Init( UViewport* InViewport, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
{
	guard(UMeTaLRenderDevice::Init);

	// Remember variables.
	Viewport			= InViewport;

	// Driver flags.
	SpanBased			 = 0;
	FullscreenOnly		 = 1;
	SupportsFogMaps		 = 1;
	SupportsDistanceFog	 = 1;
	SupportsTC           = 1;
	SupportsLazyTextures = 1;
	PrefersDeferredLoad  = 1;
	BuffersExist = true;

	// 	Fallback Resolution
	m_nScreenWidth = 640;
	m_nScreenHeight = 480;
	m_nScreenBpp = 16;
	m_nResolution = MTL_MODE_640_480_16;
	
	for(int nTextureUnit = 0 ; nTextureUnit < MAX_TEXTURE_UNITS ; nTextureUnit++)
	{
		TextureCacheID[nTextureUnit] = NULL;
		CurrTexture[nTextureUnit] = NULL;
	}
	
	// Log message.
	debugf( NAME_Init, TEXT("Initializing Metal...") );

	// Initialize the Metal library.
	if(metal == NULL)
	{
		if(mtlOpen(NULL, &metal) != MTL_ERR_NONE)
		{
			debugf(NAME_Init, TEXT("Metal Initialization failed"));
			return 0;
		}
	}

	DWORD dwChipID;
	metal->mtlGetState(MTL_ST_CHIP_ID, &dwChipID);
	metal->mtlGetState(MTL_ST_VRAM_SIZE, &m_nVRAMSize);
	if(dwChipID == 0x8A22)
	{
		m_bIsMS1 = true;
		m_nTextureUnits = 2;
		m_nFirstPrefMemory = MTL_TEX_VIDEOMEMORY;
		m_nSecondPrefMemory = MTL_TEX_AGPMEMORY;
		m_nBufferMode = MTL_BUF_TRIPLE_Z;
	}
	else
	{
		m_bIsMS1 = false;
		m_nTextureUnits = 1;
		m_nFirstPrefMemory = MTL_TEX_AGPMEMORY;
		m_nSecondPrefMemory = MTL_TEX_VIDEOMEMORY;
		m_nBufferMode = MTL_BUF_DOUBLE_Z;
	}
	
	// Allocate texture-munging scratch pad
	scratchpad_size = MAX_LIGHTMAP_SIZE * MAX_LIGHTMAP_SIZE * 4 * 22/16;
	scratchpad = malloc(scratchpad_size);

	// Set up resolution and buffers
	BuffersExist = false;
	UBOOL Result = SetRes(NewX, NewY, NewColorBytes);

	fallback_palette = 0;//Raja
	check(metal->mtlCreatePalette(MTL_PAL_RGB565, 256, &fallback_palette));

	// Go.
	Viewport->SetDrag( 1 );
	Viewport->SetMouseCapture( 1, 1 );

	// Texture cache
	next_texture = 0;

	firstframes = 10;
#ifdef CRC_TEXTURES
	m_nFrameCounter = 0;
#endif

	for(int i=0;i<MAX_TEXTURE_CACHE;i++)
		memset(&texinfo[i],0,sizeof(texinfo_data_tag));

	return Result;
	unguard;
}

//
// Register configurable properties.
//
void UMeTaLRenderDevice::StaticConstructor()
{
	guard(UMeTaLRenderDevice::InternalClassInitializer);

	new(GetClass(),TEXT("DisableTripleBuffering"), RF_Public)UBoolProperty ( CPP_PROPERTY(DisableTripBuff ), TEXT("Options"), CPF_Config );

	unguard;
}

//
// Validate configuration changes.
//
void UMeTaLRenderDevice::PostEditChange()
{
	guard(UMeTaLRenderDevice::PostEditChange);
	unguard;
}

//
// Shut down the MeTaL device.
//
void UMeTaLRenderDevice::Exit()
{
	guard(UMeTaLRenderDevice::Exit);
	debugf( NAME_Exit, TEXT("Shutting down Metal...") );

	if(scratchpad != NULL)
	{
		free(scratchpad);
		scratchpad = NULL;
		scratchpad_size = 0;
	}
	// Shut down MeTaL.
	if(metal != NULL)
	{
		if (Locked)
			metal->mtlEndDraw();
		Locked = false;

		DeselectTexture(0);
		if(m_bIsMS1)
			DeselectTexture(1);
		
		metal->mtlClose();
		metal=NULL;
	}

	debugf( NAME_Exit, TEXT("Metal shut down") );
	unguard;
};

void UMeTaLRenderDevice::PrecacheTexture( FTextureInfo& Info, DWORD PolyFlags )
{
	guard(UD3DRenderDevice::PrecacheTexture);
	DWORD MeTaLFlags =	((PolyFlags & PF_Masked) ? MF_Alpha : 0) | 
						((PolyFlags & (PF_Modulated|PF_Translucent))||Info.bRealtime ? MF_NoScale : 0);
	SelectTexture( 0, Info, MeTaLFlags);
#ifdef MTL_STATS
	m_bPreCaching = true;
#endif
	unguard;
}

//
// Flush all cached data.
//
void UMeTaLRenderDevice::Flush( UBOOL AllowPrecache )
{
	guard(UMeTaLRenderDevice::Flush);

	// Dump the old buffers
	DeselectTexture(0);
	if(m_bIsMS1)
		DeselectTexture(1);
	ClearTextureCache();

	if(Viewport->GetOuterUClient()->Brightness != LastBrightness)
	{
		MTL_GAMMA_CONTROL gamma;
		gamma.set = NULL;
		gamma.get = NULL;
		gamma.r = gamma.g = gamma.b =  0.2 + 1.5*Viewport->GetOuterUClient()->Brightness;
		metal->mtlGamma(&gamma);
		LastBrightness = Viewport->GetOuterUClient()->Brightness;
	}

#ifdef MTL_STATS
	m_bPreCaching = true;
	m_nStatTexMemInLevel = 0;
	m_nStatTexUploadPrecache = 0;
	m_nStatTexFreedPrecache = 0;
	m_nStatTexUploadLevel = 0;
	m_nStatTexFreedLevel = 0;
#endif

	unguard;
}

//
// Lighting map conversion
//
DWORD *UMeTaLRenderDevice::ConvertLightMaps(FTextureInfo& Info)
{
	DWORD size = Info.USize*Info.VSize * 22 / 16;// Include space for mipmaps 

	if ((size * 4) > scratchpad_size)
		debugf(NAME_Log, TEXT("Exceeded size of scratchpad"));

	DWORD *d = (DWORD *) scratchpad;

	DWORD w = Info.USize;
	DWORD h = Info.VSize;
	for(int i=0; i<Info.NumMips; i++)
	{
		DWORD* src = (DWORD *)Info.Mips[i]->DataPtr;
		DWORD levelsize = w*h;

		for(; levelsize; levelsize--)
			*d++ = ((*src++<<1) & 0x00fefefe) | 0xff000000;

		w = (w+1)>>1;
		h = (h+1)>>1;
	}

	return((DWORD *) scratchpad);
}

// Manipulate double-linked list; DOES NOT AFFECT HASH TABLES

void UMeTaLRenderDevice::AddEntryToHead(Texinfo_data *entry)
{
	if (texture_cache_head)
		texture_cache_head->prev_on_cache = entry;

	entry->next_on_cache = texture_cache_head;
	entry->prev_on_cache = NULL;
	texture_cache_head = entry;
}

void UMeTaLRenderDevice::UnlinkEntry(Texinfo_data *entry)
{
	if (entry->prev_on_cache)
		entry->prev_on_cache->next_on_cache = entry->next_on_cache;
	else
		texture_cache_head = entry->next_on_cache;

	if (entry->next_on_cache)
		entry->next_on_cache->prev_on_cache = entry->prev_on_cache;
	else
		texture_cache_tail = entry->prev_on_cache;
}

// This does free both entry and hash table
void UMeTaLRenderDevice::FreeTailEntry(void)
{
	// Remove from VRAM
#ifdef CRC_TEXTURES
	check(metal->mtlCRCTexture(texture_cache_tail->vram_handle));
#endif // CRC_TEXTURES
	metal->mtlDestroyTexture(texture_cache_tail->vram_handle);
#ifdef MTL_STATS
	m_nStatTexMemAlloced -= texture_cache_tail->nStatTexSize;
	if(m_bPreCaching)
		m_nStatTexFreedPrecache += texture_cache_tail->nStatTexSize;
	else
		m_nStatTexFreedLevel += texture_cache_tail->nStatTexSize;
#endif
	texture_cache_tail->palette_id = 0;
	
	if (texture_cache_tail->palette)
	{
		texture_cache_tail->palette->ref_count--;
		if (texture_cache_tail->palette->ref_count <= 0)
		{
			if (!texture_cache_tail->palette->cannot_destroy)
			{
				metal->mtlDestroyPalette(texture_cache_tail->palette->handle);
				texture_cache_tail->palette->handle = NULL;
			}
			texture_cache_tail->palette->used = 0;
		}
	}

	// Remove from cache, maintaining double-linked status For the tail, next is always NULL
	texture_cache_tail->used = 0;
	if (texture_cache_tail->prev_on_cache)
		(texture_cache_tail->prev_on_cache)->next_on_cache = NULL;
	else
		texture_cache_head = NULL;

	// Remove from hash table
	DWORD HashIndex = HASHINDEX(texture_cache_tail->id);
	if (hash_table_head[HashIndex] == texture_cache_tail)
		hash_table_head[HashIndex] = texture_cache_tail->next_on_hash;
	else
	{
		for(Texinfo_data* cacheentry=hash_table_head[HashIndex]; cacheentry; cacheentry = cacheentry->next_on_hash)
		{
			if (cacheentry->next_on_hash && (cacheentry->next_on_hash == texture_cache_tail))
			{
				cacheentry->next_on_hash = cacheentry->next_on_hash->next_on_hash;
				break;
			}
		}
	}

	texture_cache_tail = texture_cache_tail->prev_on_cache;
}

// Clear out internal texture cache

void UMeTaLRenderDevice::ClearTextureCache(void)
{
	for (int i = 0; i < MAX_TEXTURE_CACHE; i++)
	{
		if (texinfo[i].used && texinfo[i].id!=TextureCacheID[0] && texinfo[i].id!=TextureCacheID[1] )
		{
			metal->mtlDestroyTexture(texinfo[i].vram_handle);
			texinfo[i].vram_handle = NULL;

			texinfo[i].used = 0;
			texinfo[i].id = 0;
			texinfo[i].palette = NULL;
			texinfo[i].palette_id = 0;
#ifdef MTL_STATS
			m_nStatTexMemAlloced -= texinfo[i].nStatTexSize;
			if(m_bPreCaching)
				m_nStatTexFreedPrecache += texinfo[i].nStatTexSize;
			else
				m_nStatTexFreedLevel += texinfo[i].nStatTexSize;
#endif
		}
	}

	texture_cache_head = NULL;
	texture_cache_tail = NULL;
	for(i = 0; i < HASH_COUNT; i++)
		hash_table_head[i] = NULL;

	for (i = 0; i < MAX_PALETTES; i++)
	{
		if (palette_table[i].used && !palette_table[i].cannot_destroy)
			metal->mtlDestroyPalette(palette_table[i].handle);

		palette_table[i].used = 0;
		palette_table[i].ref_count = 0;
		palette_table[i].cannot_destroy = 0;
	}
}

//-----------------------------------------------------------------------------
//	UMeTaLRenderDevice Texture Management
//	All this code new by Dave
//-----------------------------------------------------------------------------
void UMeTaLRenderDevice::SelectTexture( int nTextureUnit, FTextureInfo& Info, DWORD MeTaLFlags )
{
	guard(UMeTaLRenderDevice::SelectTexture);

// Select Texture Unit
	check(nTextureUnit < m_nTextureUnits);
	metal->mtlSetState(MTL_ST_TEX_STAGE, nTextureUnit);

	Texinfo_data *cacheentry;
	MTL_TEX_FORMAT mtl_native_format;
	MTL_LOGTEX_FORMAT mtl_logtex_format;
	MTL_PAL_FORMAT mtl_pal_format = MTL_PAL_ARGB1555;
	int i,stride;
	int re_upload = 0, noncontiguous_mipmaps = 0;

	// First, check if we need to repeat upload even if registered
	if( Info.bRealtimeChanged ) // Must re-upload the texture, as something has changed.
	{											// In this case, will get right to the texture creation stage.
		re_upload = 1;
		Info.bRealtimeChanged = 0;
	}
	QWORD TestID = Info.CacheID + (((QWORD)MeTaLFlags) << 60);
	
	if ((TestID != TextureCacheID[nTextureUnit]) || re_upload) // Check if the current texture is already selected
	{	// It isn't
		// Is it in VRAM?
		DWORD HashIndex = HASHINDEX(TestID);
		for(cacheentry=hash_table_head[HashIndex]; cacheentry; cacheentry = cacheentry->next_on_hash)
			if ((cacheentry->id == TestID))
				break;

		if (cacheentry)	// If not creating, move to head of the list
		{
			UnlinkEntry(cacheentry);
			AddEntryToHead(cacheentry);
			CurrTexture[nTextureUnit] = cacheentry;
		}
		else // Obviously, if creating, can't also be repeat uploading!
		{
			CurrTexture[nTextureUnit] = NULL;
			re_upload = 0;
		}

		if (!cacheentry || re_upload) // Cache it into VRAM
		{
			// Load the texture data
			Info.Load();

			void* source = Info.Mips[0]->DataPtr; // At any point this is the 'valid' data: original or munged

			// Munging test
			if (MeTaLFlags & MF_LightMap)
				source = ConvertLightMaps(Info);

			if (Info.Format == TEXF_DXT1) // S3TC source data
			{
				mtl_native_format = MTL_TEX_S3TC;
				mtl_logtex_format = MTL_LOGTEX_S3TC;
				stride = Info.USize/2;
			}
			else if ((Info.Format == TEXF_RGBA7) || (MeTaLFlags & MF_LightMap)) // Lightmap
			{
				check(Info.Format == TEXF_RGBA7);
				if(Info.VSize == 8 && Info.USize > 32) // Work around tiling problem
					mtl_native_format=MTL_TEX_RGB565;
				else
					mtl_native_format=MTL_TEX_ARGB8888;
				mtl_logtex_format=MTL_LOGTEX_ARGB8888;
				stride=Info.USize*4;
			}
			else // Paletted texture
			{
				mtl_native_format=MTL_TEX_PAL;
				mtl_logtex_format=MTL_LOGTEX_PAL;
				stride=Info.USize;
				if(MeTaLFlags&MF_Alpha)
				   mtl_pal_format=MTL_PAL_ARGB1555;
				else
				   mtl_pal_format=MTL_PAL_RGB565;
			}

			// Calculate miplevels
			int miplevels = 1;
			for(int w = max(Info.USize, Info.VSize) ; w>1; w>>=1)
				miplevels++;

			// Clamp miplevels
			if (Info.NumMips < miplevels)
				miplevels = 1;
			else if ((source != scratchpad) && miplevels > 1) // If haven't been through de-palettiser, must do munged upload
				noncontiguous_mipmaps = 1;

			// Create a new entry unless we are replacing an old texture
			if (re_upload) // Do upload only
			{
				check(cacheentry->vram_handle);
				if (noncontiguous_mipmaps)
				{
					int w = Info.USize, h = Info.VSize; 
					float sf = (float) stride/Info.USize;
					for(i=0; i<miplevels; i++)
					{
						metal->mtlUpdateTexture(cacheentry->vram_handle, mtl_logtex_format, 0, 0,
													 w, w*sf, h,
													 i, 1, Info.Mips[i]->DataPtr);
						w = (w+1)>>1;
						h = (h+1)>>1;
					}
				}
				else
					metal->mtlUpdateTexture(cacheentry->vram_handle, mtl_logtex_format, 0, 0,
												 Info.USize, stride, Info.VSize,
												 0, miplevels, source);

#ifdef MTL_STATS
				m_nStatUploadsThisFrame++;
#endif

#ifdef _DEBUG // Debug info 
				check(cacheentry->width == Info.USize);
				check(cacheentry->height == Info.VSize);
				check(cacheentry->MeTaLFlags == MeTaLFlags);
#endif // DEBUG
#ifdef CRC_TEXTURES
				metal->mtlCRCTexture(cacheentry->vram_handle);
#endif // CRC_TEXTURES
			}
			else // Create an entry, upload data
			{
				// PERFORMANCE HIT - for same reason as hash table; this can cycle the whole
				// CPU cache every frame, must rethink!

				for(i=0; i<MAX_TEXTURE_CACHE; i++)
				{
					if (!texinfo[next_texture].used)
						break;
					next_texture = (next_texture+1)%MAX_TEXTURE_CACHE;
				}
				if (i<MAX_TEXTURE_CACHE)
					cacheentry = &texinfo[next_texture];
				else
				{
					cacheentry = texture_cache_tail; // out of texture cache handles
					FreeTailEntry();
				}

				check(cacheentry);

				// Actual allocate & cache freeing
				cacheentry->palette = NULL;
				int allocation_retries = 0;
				MTL_RESULT ok = MTL_FAILED;
				while(ok == MTL_FAILED)
				{
					// Attempt to create
					cacheentry->vram_handle=0;
					if (noncontiguous_mipmaps)
					{
						ok = metal->mtlCreateTexture((MTL_TEX_FORMAT) (mtl_native_format | m_nFirstPrefMemory),
													 Info.USize, stride, Info.VSize, 
													 miplevels, mtl_logtex_format, NULL, &cacheentry->vram_handle);
						if(!ok)
							ok = metal->mtlCreateTexture((MTL_TEX_FORMAT) (mtl_native_format | m_nSecondPrefMemory),
													 Info.USize, stride, Info.VSize, 
													 miplevels, mtl_logtex_format, NULL, &cacheentry->vram_handle);

					}
					else
					{
						ok = metal->mtlCreateTexture((MTL_TEX_FORMAT) (mtl_native_format | m_nFirstPrefMemory),
													 Info.USize, stride, Info.VSize, 
													 miplevels, mtl_logtex_format, NULL, &cacheentry->vram_handle);
						if(!ok)
							ok = metal->mtlCreateTexture((MTL_TEX_FORMAT) (mtl_native_format | m_nSecondPrefMemory),
													 Info.USize, stride, Info.VSize, 
													 miplevels, mtl_logtex_format, NULL, &cacheentry->vram_handle);
					}
					if (!ok) // Failed; free some memory for the retry
					{
						DeselectTexture(nTextureUnit);
						if (!texture_cache_tail) // No more entries; so fail
							break;

						// Detect if texture cache is very seriously fragged; if so, clear the whole thing out
						allocation_retries++;
						if (allocation_retries == 40)
							ClearTextureCache();
						else
							FreeTailEntry();
					}
				}

				if (ok)
				{
					// Upload data
					if (noncontiguous_mipmaps)
					{
						int w = Info.USize, h = Info.VSize;
						float sf = (float) stride/Info.USize;
						for(i=0; i<miplevels; i++)
						{
							ok = metal->mtlUpdateTexture(cacheentry->vram_handle, mtl_logtex_format, 0, 0,
														 w, w*sf, h,
														 i, 1, Info.Mips[i]->DataPtr);
							w = (w+1)>>1;
							h = (h+1)>>1;
						}
					}
					else
					{
						try
						{
							metal->mtlUpdateTexture(cacheentry->vram_handle, mtl_logtex_format, 0, 0,
													 Info.USize, stride, Info.VSize, 
													 0, miplevels, source);
						}
						catch( ... )
						{
							debugf(TEXT("FAULT in mtlUpdateTexture (Metal driver non-mipped texture upload)"));
						}
					}


					cacheentry->used = 1;
					cacheentry->id = TestID;
					cacheentry->mtl_native_format = mtl_native_format;
					cacheentry->mipmap_levels = miplevels;
#ifdef _DEBUG // Debug info 
					cacheentry->width = Info.USize;
					cacheentry->height = Info.VSize;
					cacheentry->MeTaLFlags = MeTaLFlags;
#endif // DEBUG
#ifdef CRC_TEXTURES
					metal->mtlCRCTexture(cacheentry->vram_handle);
#endif // CRC_TEXTURE
#ifdef MTL_STATS
					cacheentry->nStatTexSize = CalcSurfaceSize(Info.USize, Info.VSize, mtl_native_format, miplevels);
					m_nStatUploadsThisFrame++;
					m_nStatTexMemAlloced += cacheentry->nStatTexSize;
					if(m_bPreCaching)
					{
						m_nStatTexMemInLevel += cacheentry->nStatTexSize;
						m_nStatTexUploadPrecache += cacheentry->nStatTexSize;
					}
					else
						m_nStatTexUploadLevel += cacheentry->nStatTexSize;
#endif
					next_texture = (next_texture+1)%MAX_TEXTURE_CACHE;

					// Add to the head of the cache
					AddEntryToHead(cacheentry);
					
					// Put it in the tail if there isn't one there yet
					if (!texture_cache_tail)
						texture_cache_tail = cacheentry;

					// Add to head of hash table
					cacheentry->next_on_hash = hash_table_head[HashIndex];
					hash_table_head[HashIndex] = cacheentry;
				}
				else // Couldn't allocate texture at all
				{
					debugf(NAME_Log,TEXT("Failed to allocate texture at all"));
					cacheentry = 0;
				}
			}
			CurrTexture[nTextureUnit] = cacheentry;

			// Unload the texture data
			Info.Unload();
		}

		if (cacheentry)	// Handle palettes if not repeat-uploading
		{
			if (!re_upload && (cacheentry->mtl_native_format == MTL_TEX_PAL)) // Have a palette with this texture 
			{
				QWORD PaletteTestID = Info.PaletteCacheID + (((QWORD)MeTaLFlags&MF_Alpha) << 60);
				if (cacheentry->palette_id !=PaletteTestID) // New palette or already cached?
				{
					int free_palette=-1;
					for(i=0; i<MAX_PALETTES; i++)
					{
						if (!palette_table[i].used)
							free_palette = i;
						else if (palette_table[i].id == PaletteTestID) // We already have this one in the cache...
							break;
					}

					if (i == MAX_PALETTES) // Not allocated; must create
					{
						if (free_palette>=0) 
						{
							// Copy the colours to Metal format
							MTL_COLOR_STRUCT palette_32bit[NUM_PAL_COLORS];
							for( INT i=0/*1*/; i<NUM_PAL_COLORS; i++ )
							{
								palette_32bit[i].r = Info.Palette[i].R;
								palette_32bit[i].g = Info.Palette[i].G;
								palette_32bit[i].b = Info.Palette[i].B;
								palette_32bit[i].af = Info.Palette[i].A;
							}
							palette_32bit[0].af = 0;

							do // Create it; THIS CAN FAIL with out of memory...
							{	
								if (metal->mtlCreatePalette(mtl_pal_format, 256, &palette_table[free_palette].handle) != MTL_OK)
								{
									// No memory; so free some by losing a texture UNLESS the texture
									// at the tail is the one we're trying to use
									if (!texture_cache_tail || (texture_cache_tail == cacheentry))
									{
										MTL_REPORT_ERR;
										palette_table[free_palette].handle = fallback_palette; // Use the fallback METAL palette
										palette_table[free_palette].cannot_destroy = 1;
										break;
									}
									else
										FreeTailEntry();
								}
								else // Successfully allocated, so do setup and then exit the allocate palette loop
								{
									palette_table[free_palette].cannot_destroy = 0;
									check(palette_table[free_palette].handle);
									metal->mtlWritePalette(palette_table[free_palette].handle, 0, NUM_PAL_COLORS, palette_32bit);
									break;
								}
							}
							while(1);

							// Mark palette entry as used and referenced by first texture
							palette_table[free_palette].used = 1;
							palette_table[free_palette].id = PaletteTestID;
							palette_table[free_palette].ref_count = 1;

							cacheentry->palette = &palette_table[free_palette];

						}
						else // No free palettes; BIG problem....
						{
							// Should deallocate from texture_cache_tail until a palette is free...
							// If we hit this, just crank up MAX_PALETTE_CACHE
							debugf( NAME_Log, TEXT("Metal Driver: PALETTE TABLE EXHAUSTED; increase MAX_PALETTE_CACHE") );
						}
					}
					else // Found palette on our cached list
					{
						cacheentry->palette = &palette_table[i];
						palette_table[i].ref_count++;
					}

					cacheentry->palette_id = PaletteTestID;

				} // ID doesn't match
			}	// !re_upload && Format paletted

			// If paletted, set the palette up
			if (cacheentry->palette)
				metal->mtlSetState(MTL_ST_TEX_PAL, (DWORD) cacheentry->palette->handle);

			// Check that the texture is as we expect
#ifdef _DEBUG
			check(cacheentry->width == Info.USize);
			check(cacheentry->height == Info.VSize);
			check(cacheentry->MeTaLFlags== MeTaLFlags);
#endif // _DEBUG
			check(cacheentry->vram_handle);
#ifdef CRC_TEXTURES
			if(m_nFrameCounter >= 1000)
			{
				check(metal->mtlCRCTexture(cacheentry->vram_handle));
			}
#endif // CRC_TEXTURES
			// Select the built entry
			MTL_CALL(metal->mtlSetState(MTL_ST_TEX_SELECT, (DWORD)cacheentry->vram_handle));

			UScale[nTextureUnit] = 1.0f / (Info.USize*Info.UScale);
			VScale[nTextureUnit] = 1.0f / (Info.VSize*Info.VScale);

			metal->mtlSetState(MTL_ST_TEX_ENABLE, TRUE);
			if (cacheentry->mipmap_levels == 1)
			{
				metal->mtlSetState(MTL_ST_TEX_MIPMAP, MTL_TEX_MIPMAP_OFF);
				metal->mtlSetState(MTL_ST_TEX_FILTER, MTL_TEX_FILTER_4TPP);
			}
			else
			{
				metal->mtlSetState(MTL_ST_TEX_MIPMAP, MTL_TEX_MIPMAP_ON);
				metal->mtlSetState(MTL_ST_TEX_FILTER, MTL_TEX_FILTER_16TPP);
			}
		}
		else // therefore cacheentry must be invalid after texture creation attempt
			metal->mtlSetState(MTL_ST_TEX_ENABLE, FALSE); // Disable texturing

		TextureCacheID[nTextureUnit] = TestID;
	}	// TestID == TextureCacheID[nTextureUnit]

	unguard;
}

void UMeTaLRenderDevice::DeselectTexture( int nTextureUnit)
{
	guard(UMeTaLRenderDevice::DeselectTexture);

	check(nTextureUnit < m_nTextureUnits);

	metal->mtlSetState(MTL_ST_TEX_STAGE, nTextureUnit);
	metal->mtlSetState(MTL_ST_TEX_SELECT, 0);
	metal->mtlSetState(MTL_ST_TEX_ENABLE, FALSE);

	TextureCacheID[nTextureUnit] = NULL;
	CurrTexture[nTextureUnit] = NULL;

	unguard;
}

//-----------------------------------------------------------------------------
//	UMeTaLRenderDevice Lock & Unlock.
//-----------------------------------------------------------------------------

//
// Lock the MeTaL device.
//
void UMeTaLRenderDevice::Lock( FPlane InFlashScale, FPlane InFlashFog, FPlane Screen, DWORD InLockFlags, BYTE* HitData, INT* HitSize )
{
  	guard(UMeTaLRenderDevice::Lock);

	// Remember parameters.
	LockFlags  = InLockFlags;
	FlashScale = InFlashScale;
	FlashFog   = InFlashFog;

	// Clear the Z-buffer... is this actually necessary???
	if (firstframes > 0) // Clear back buffer for first few frames to eliminate garbage in screen borders
	{
		MTL_CALL(metal->mtlEraseBuffers(MTL_BUF_BACK | MTL_BUF_Z16));
		firstframes--;
	}
	else
		MTL_CALL(metal->mtlEraseBuffers(MTL_BUF_Z16));

	metal->mtlBeginDraw();
	Locked = true;

#ifdef CRC_TEXTURES
	m_nFrameCounter++;
#endif

	unguard;
};

//
// Clear the Z-buffer.
//
void UMeTaLRenderDevice::ClearZ( FSceneNode* Frame )
{
	guard(UMeTaLRenderDevice::ClearZ);

	if (Locked)
		metal->mtlEndDraw();

	// Clear only the Z-buffer.
	MTL_CALL(metal->mtlEraseBuffers(MTL_BUF_Z16));

	if (Locked)
		metal->mtlBeginDraw();

	unguard;
}

//
// Perform screenflashes.
//
// DAVE: looks like a routine to draw an alpha-blended polygon over the whole scene to me.
void UMeTaLRenderDevice::EndFlash()
{
	guard(UMeTaLRenderDevice::EndFlash);

	if( FlashScale!=FVector(.5,.5,.5) || FlashFog!=FVector(0,0,0) )
	{
		FColor MetalColor = FColor(FPlane(FlashFog.X,FlashFog.Y,FlashFog.Z,Min(FlashScale.X*2.f,1.f)));
		DWORD color = (MetalColor.B)|(MetalColor.G<<8)|(MetalColor.R<<16)|(MetalColor.A<<24);

		metal->mtlSetState( MTL_ST_Z_ENABLE, FALSE);
		metal->mtlSetState( MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState( MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_SRC);
		metal->mtlSetState( MTL_ST_TEX_ENABLE, FALSE);
		
		if(m_bIsMS1)
		{
			FVF_VERTEX Verts[4];
			Verts[0].sx=0.5;             Verts[0].sy=0.5;             Verts[0].rhw=0.5;	
			Verts[0].color = color;
			Verts[1].sx=0.5;             Verts[1].sy=Viewport->SizeY; Verts[1].rhw=0.5;	
			Verts[1].color = color;
			Verts[2].sx=Viewport->SizeX; Verts[2].sy=Viewport->SizeY; Verts[2].rhw=0.5;	
			Verts[2].color = color;
			Verts[3].sx=Viewport->SizeX; Verts[3].sy=0.5;             Verts[3].rhw=0.5;	
			Verts[3].color = color;
			metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, 4, Verts);
		}
		else
		{
			MTL_VERTEX Verts[4];
			Verts[0].sx=0.5;             Verts[0].sy=0.5;             Verts[0].rhw=0.5;	
			Verts[0].color = color;
			Verts[1].sx=0.5;             Verts[1].sy=Viewport->SizeY; Verts[1].rhw=0.5;	
			Verts[1].color = color;
			Verts[2].sx=Viewport->SizeX; Verts[2].sy=Viewport->SizeY; Verts[2].rhw=0.5;	
			Verts[2].color = color;
			Verts[3].sx=Viewport->SizeX; Verts[3].sy=0.5;             Verts[3].rhw=0.5;	
			Verts[3].color = color;
			metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, 4, Verts);
		}

		metal->mtlSetState( MTL_ST_Z_ENABLE, TRUE);
		metal->mtlSetState( MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState( MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_ZERO);
		metal->mtlSetState(MTL_ST_TEX_ENABLE, TRUE);
	}
	unguard;
}

//
// Unlock the MeTaL rendering device.
//
// DAVE: Again, I think this is what is performed at the end of each frame
void UMeTaLRenderDevice::Unlock( UBOOL Blit )
{
	guard(UMeTaLRenderDevice::Unlock);

	// End frame
	metal->mtlEndDraw();
	Locked = false;

#ifdef CRC_TEXTURES
	if(m_nFrameCounter >= 1000)
		m_nFrameCounter = 0;
#endif

#ifdef MTL_STATS
	m_bPreCaching = true;
	m_nStatUploadsLastFrame = m_nStatUploadsThisFrame;
	m_nStatUploadsThisFrame = 0;
#endif
	
	// Blit it.
	if( Blit )
	{
		// Flip pages.
		guard(mtlSwapBuffers);
		
		MTL_CALL(metal->mtlSwapBuffers());

		unguard;
	}
	unguard;
};

void UMeTaLRenderDevice::SetBlending( DWORD PolyFlags )
{
	// Types.
	if( PolyFlags & PF_Translucent )
	{
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_INVCOL);
		metal->mtlSetState(MTL_ST_ALPHA_TEST, TRUE);
		if( !(PolyFlags & PF_Occlude) )
			metal->mtlSetState(MTL_ST_Z_UPDATE, FALSE);
	}
	else if( PolyFlags & PF_Modulated )
	{
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_COL);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_COL);
		if( !(PolyFlags & PF_Occlude) )
			metal->mtlSetState(MTL_ST_Z_UPDATE, FALSE);
	}
	else if( PolyFlags & PF_Masked )
	{
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_SRC);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_INVSRC);
		metal->mtlSetState(MTL_ST_ALPHA_TEST, TRUE);
		metal->mtlSetState(MTL_ST_Z_AFTER_ALPHA, TRUE);
	}
	else
	{
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_ZERO);
	}

	// Flags.
	if( PolyFlags & PF_Invisible )
		metal->mtlSetState(MTL_ST_DEST_UPDATE, FALSE);

	if( PolyFlags & PF_NoSmooth )
		metal->mtlSetState(MTL_ST_TEX_FILTER, MTL_TEX_FILTER_1TPP);

	if( (LockFlags & LOCKR_LightDiminish) && !(PolyFlags & PF_Unlit) )
	{
		// DAVE: need to do something about table fog
	}
}

void UMeTaLRenderDevice::ResetBlending( DWORD PolyFlags )
{
	// Types.
	if( PolyFlags & PF_Invisible )
		metal->mtlSetState(MTL_ST_DEST_UPDATE, TRUE);

	if( PolyFlags & PF_Masked )
	{
		metal->mtlSetState(MTL_ST_ALPHA_TEST, FALSE);
		metal->mtlSetState(MTL_ST_Z_AFTER_ALPHA, FALSE);
	}
	if( PolyFlags & (PF_Translucent|PF_Modulated) )
	{
		if( !(PolyFlags & PF_Occlude) )
			metal->mtlSetState(MTL_ST_Z_UPDATE, TRUE);

		if(PolyFlags & PF_Translucent)
			metal->mtlSetState(MTL_ST_ALPHA_TEST, FALSE);

		// DAVE: Should there not be an alpha state change here too???
	}

		// Flags.
	if( PolyFlags & PF_NoSmooth )
		metal->mtlSetState(MTL_ST_TEX_FILTER, MTL_TEX_FILTER_4TPP);

	if( (LockFlags & LOCKR_LightDiminish) && !(PolyFlags & PF_Unlit) )
	{
		// DAVE: need to do something about table fog
	}
}

//-----------------------------------------------------------------------------
//	UMeTaLRenderDevice texture vector polygon drawer.
//-----------------------------------------------------------------------------

//
// Draw a textured polygon using surface vectors.
//

typedef struct
{
	MTL_VALUE MASTER_S, MASTER_T;
} MASTER_VERTS;

#define MAX_VERTS 2048
MASTER_VERTS m_pool[MAX_VERTS];

#define VERTS(poly)  (v_pool + (DWORD)((poly)->User))
#define MVERTS(poly) (m_pool + (DWORD)((poly)->User))

void UMeTaLRenderDevice::DrawComplexSurface( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet )
{
	guard(UMeTaLRenderDevice::DrawComplexSurface);

	FMemMark Mark(GMem);

	// If there's no surface texture then the others don't make sense
	if( !Surface.Texture )
		return;

	// Mutually exclusive effects.
	if( Surface.DetailTexture && Surface.FogMap)
		Surface.DetailTexture = NULL;

	if(m_bIsMS1)
		DrawComplexSurfaceMS1( Frame, Surface, Facet );
	else
		DrawComplexSurfaceGX3( Frame, Surface, Facet );

	Mark.Pop();
	unguard;
}

void UMeTaLRenderDevice::DrawComplexSurfaceGX3( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet )
{
	static MTL_VERTEX v_pool[MAX_VERTS];
	int current_vertex = 0;

	// Flags.
	DWORD MeTaLFlags
		=	((Surface.PolyFlags & PF_Masked) ? MF_Alpha : 0)
		|	((Surface.PolyFlags & (PF_Modulated|PF_Translucent))||Surface.Texture->bRealtime ? MF_NoScale : 0);

	// Set up all poly vertices.
	for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
	{
		// Set up vertices.
#ifdef _DEBUG
		if ((current_vertex + Poly->NumPts) > MAX_VERTS)
			debugf(NAME_Log, TEXT("Vertex count exceeded; INCREASE MAX_VERTS"));
#endif

		Poly->User = (void *)current_vertex;
		current_vertex += Poly->NumPts;
        
		for( INT i=Poly->NumPts-1; i>=0; --i )
		{
			MVERTS(Poly)[i].MASTER_S = Facet.MapCoords.XAxis | (*(FVector*)Poly->Pts[i] - Facet.MapCoords.Origin);
			MVERTS(Poly)[i].MASTER_T = Facet.MapCoords.YAxis | (*(FVector*)Poly->Pts[i] - Facet.MapCoords.Origin);
			VERTS(Poly)[i].sx       = Poly->Pts[i]->ScreenX + Frame->XB;
			VERTS(Poly)[i].sy	    = Poly->Pts[i]->ScreenY + Frame->YB;
			VERTS(Poly)[i].rhw      = Poly->Pts[i]->RZ * Frame->RProj.Z;
			VERTS(Poly)[i].sz	    = Z_CONVERT(Poly->Pts[i]->Point.Z);
			VERTS(Poly)[i].color	= 0x00ffffff;
		}
	}

	// Count things to draw.
	// DAVE: I think this is always decal, simply because I've always set the colour to 0xffffff
	INT ModulateThings = (Surface.Texture!=NULL) + (Surface.LightMap!=NULL) + (Surface.MacroTexture!=NULL);
	metal->mtlSetState(MTL_ST_TEX_BLENDING, MTL_TEX_BLENDING_COPY);	// DAVE: COPY being DECAL on Savage

	// Draw normal texture.
	// Setup texture.
	SetBlending( Surface.PolyFlags );
	SelectTexture( 0, *Surface.Texture, MeTaLFlags );
	for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
	{
		for( INT i=0; i<Poly->NumPts; i++ )
		{
			float r1, r2;
			r1 = (MVERTS(Poly)[i].MASTER_S - Surface.Texture->Pan.X) * UScale[0];
			r2 = (MVERTS(Poly)[i].MASTER_T - Surface.Texture->Pan.Y) * VScale[0];
			VERTS(Poly)[i].tu = r1;
			VERTS(Poly)[i].tv = r2;
		}

		// DAVE: This is a polygon draw; it requires TRIFAN not TRILIST
		metal->mtlSetState(MTL_ST_TEX_ENABLE, 1);
		metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, Poly->NumPts, (void*)VERTS(Poly));
	}
	ResetBlending( Surface.PolyFlags );

	// Handle depth buffering the appropriate areas of masked textures.
	if( Surface.PolyFlags & PF_Masked )
	   metal->mtlSetState( MTL_ST_Z_COMPARE, MTL_COMPARE_EQUAL);

	// Modulation blend the rest of the textures.
	if( ModulateThings>0 || (Surface.DetailTexture && DetailTextures) )
	{
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_COL);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_COL);
	}

	// Light map.
	if( Surface.LightMap )
	{
		// Set the light map.
		SelectTexture( 0, *Surface.LightMap, MF_NoPalette|MF_LightMap );

		// DAVE: I think these are the right correction factors. It makes _most_ of the castle look OK....
		float PanX = Surface.LightMap->Pan.X - 0.5*Surface.LightMap->UScale;
		float PanY = Surface.LightMap->Pan.Y - 0.5*Surface.LightMap->VScale;
		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			for( INT i=0; i<Poly->NumPts; i++ )
			{
				VERTS(Poly)[i].tu = (MVERTS(Poly)[i].MASTER_S - PanX) * UScale[0];
				VERTS(Poly)[i].tv = (MVERTS(Poly)[i].MASTER_T - PanY) * VScale[0];
			}
			metal->mtlPrimitiveDraw( MTL_PRIM_TRIFAN,Poly->NumPts, (void*)VERTS(Poly));
		}
	}

	// Draw detail texture overlaid.
	if( Surface.DetailTexture && DetailTextures )
	{
		const FLOAT NearZ = 200.0f;

		metal->mtlSetState(MTL_ST_FOG_ENABLE, TRUE);
		metal->mtlSetState(MTL_ST_FOG_MODE_VERTEX, TRUE);

		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			UBOOL IsNear[32], CountNear=0;
			for( int i=0; i<Poly->NumPts; i++ )
			{
				IsNear[i] = Poly->Pts[i]->Point.Z < NearZ;
				CountNear += IsNear[i];
			}
			if( CountNear )
			{
				INT NumNear=0;
				SelectTexture( 0, *Surface.DetailTexture, MF_NoPalette | MF_NoScale );
				MTL_VERTEX Near[32];
				for( INT i=0,j=Poly->NumPts-1; i<Poly->NumPts; j=i++ )
				{
					if( IsNear[i] ^ IsNear[j] )
					{
						FLOAT zi = Poly->Pts[i]->Point.Z;
						FLOAT zj = Poly->Pts[j]->Point.Z;
						FLOAT G				= (zi - NearZ) / (zi - zj);
						FLOAT F				= 1.0 - G;
						Near[NumNear].sx	= (F*Poly->Pts[i]->ScreenX*zi + G*Poly->Pts[j]->ScreenX*zj) * Near[NumNear].rhw + Frame->XB;
						Near[NumNear].sy	= (F*Poly->Pts[i]->ScreenY*zi + G*Poly->Pts[j]->ScreenY*zj) * Near[NumNear].rhw + Frame->YB;
						Near[NumNear].rhw	= 1.0 / NearZ;
						Near[NumNear].color = 0xffffffff;
						Near[NumNear].sz	= Z_CONVERT(NearZ);
						Near[NumNear].specular = 0;
						Near[NumNear].tu	= (F*MVERTS(Poly)[i].MASTER_S + G*MVERTS(Poly)[j].MASTER_S - Surface.DetailTexture->Pan.X) * UScale[0];
						Near[NumNear].tv	= (F*MVERTS(Poly)[i].MASTER_T + G*MVERTS(Poly)[j].MASTER_T - Surface.DetailTexture->Pan.Y) * VScale[0];
						NumNear++;
					}
					if( IsNear[i] )
					{
						Near[NumNear].sx	= VERTS(Poly)[i].sx;
						Near[NumNear].sy	= VERTS(Poly)[i].sy;
						Near[NumNear].rhw	= 1.0f / Poly->Pts[i]->Point.Z;
						Near[NumNear].color = 0xffffffff;
						Near[NumNear].sz	= VERTS(Poly)[i].sz;
						Near[NumNear].tu	= (MVERTS(Poly)[i].MASTER_S - Surface.DetailTexture->Pan.X) * UScale[0];
						Near[NumNear].tv	= (MVERTS(Poly)[i].MASTER_T - Surface.DetailTexture->Pan.Y) * VScale[0];
						Near[NumNear].specular = f2i((1 - (Poly->Pts[i]->Point.Z/NearZ)) * 120.0f)<<24;
						NumNear++;
					}
				}
				
				/* DAVE:
				 * Need to set up the following:
				 * Res = f*c2 + (1-f)*c1
				 * where f = iterated alpha in vertex
				 * c2 = 0x7f7f7f
				 * c1 = texture
				 *
				 * This is then blending with COL, COL blending.
				 * My head hurts
				 *
				 * I _think_ the effect of this is as follows; if alpha == 255, then this results in
				 * 0x7f7f7f which when fed through the COL, COL blending produces no change.
				 * Other values of alpha - which I don't think can ever go less than 100, from what
				 * I see above - produce progressively more detail texture.
				 *
				 *
				 * ANDY: I think the correct setup is as follows:
				 *
				 * metal->mtlSetState(metal, MTL_ST_FOG_COLOR, 0x7f7f7f);
				 * metal->mtlSetState(metal, MTL_ST_FOG_MODE_VERTEX, TRUE);
				 * metal->mtlSetState(metal, MTL_ST_FOG_ENABLE, TRUE);
				 * metal->mtlSetState(metal, MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_COL);
				 * metal->mtlSetState(metal, MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_COL);
				 *
				 * Alternatively we can simply modulate the colour factor, and load it into the
				 * Specular colour member (if this is not being used for anything else), and this
				 * should have the same effect.
				 *
				 * DAVE: That works apart from the bit about specular, which doesn't, because
				 * then you don't get the (1-f).
				 *
				 */
				metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, NumNear, (void *)Near);
			}
		}
		metal->mtlSetState(MTL_ST_FOG_ENABLE, FALSE);
		metal->mtlSetState(MTL_ST_FOG_MODE_VERTEX, FALSE);
	}
	// Fog map.
	if( Surface.FogMap )
	{
		SelectTexture( 0, *Surface.FogMap, MF_NoPalette|MF_LightMap );
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_INVCOL);
		// DAVE: also set Modulate and set values into color I think

		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			for( int i=0; i<Poly->NumPts; i++ )
			{
				VERTS(Poly)[i].tu = (MVERTS(Poly)[i].MASTER_S - Surface.FogMap->Pan.X + 0.5*Surface.FogMap->UScale) * UScale[0];
				VERTS(Poly)[i].tv = (MVERTS(Poly)[i].MASTER_T - Surface.FogMap->Pan.Y + 0.5*Surface.FogMap->VScale) * VScale[0];
			}
			metal->mtlPrimitiveDraw( MTL_PRIM_TRIFAN, Poly->NumPts, (void *)VERTS(Poly));
		}
	}

	// Finish mask handling.
	if( Surface.PolyFlags & PF_Masked )
       metal->mtlSetState(MTL_ST_Z_COMPARE, MTL_COMPARE_LESSEQUAL);
}

void UMeTaLRenderDevice::DrawComplexSurfaceMS1( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet )
{
	static FVF_VERTEX v_pool[MAX_VERTS];
	int current_vertex = 0;

	// Flags.
	DWORD MeTaLFlags
		=	((Surface.PolyFlags & PF_Masked) ? MF_Alpha : 0)
		|	((Surface.PolyFlags & (PF_Modulated|PF_Translucent))||Surface.Texture->bRealtime ? MF_NoScale : 0);

	// Set up all poly vertices.
	for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
	{
		// Set up vertices.
		check((current_vertex + Poly->NumPts) <= MAX_VERTS);
		Poly->User = (void *)current_vertex;
		current_vertex += Poly->NumPts;
        
		for( INT i=Poly->NumPts-1; i>=0; --i )
		{
			MVERTS(Poly)[i].MASTER_S = Facet.MapCoords.XAxis | (*(FVector*)Poly->Pts[i] - Facet.MapCoords.Origin);
			MVERTS(Poly)[i].MASTER_T = Facet.MapCoords.YAxis | (*(FVector*)Poly->Pts[i] - Facet.MapCoords.Origin);
			VERTS(Poly)[i].sx       = Poly->Pts[i]->ScreenX + Frame->XB;
			VERTS(Poly)[i].sy	    = Poly->Pts[i]->ScreenY + Frame->YB;
			VERTS(Poly)[i].rhw      = Poly->Pts[i]->RZ * Frame->RProj.Z;
			VERTS(Poly)[i].color	= 0x00ffffff;
		}
	}

	bool bLightMap		= (Surface.LightMap!=NULL);
	bool bDetailTexture = (Surface.DetailTexture && DetailTextures);
	bool bFogMap		= (Surface.FogMap!=NULL);
	
	// Draw normal texture.
	// Setup texture.
	SetBlending( Surface.PolyFlags );
	SelectTexture( 0, *Surface.Texture, MeTaLFlags );
	MTL_CALL(metal->mtlSetState(MTL_ST_TEX_BLEND, (DWORD) &stage0copy));

	float PanX = 0;
	float PanY = 0;
	bool bMultiTex = false;

	if( bLightMap )
	{
		PanX = Surface.LightMap->Pan.X - 0.5*Surface.LightMap->UScale;
		PanY = Surface.LightMap->Pan.Y - 0.5*Surface.LightMap->VScale;
		SelectTexture(1, *Surface.LightMap, MF_NoPalette|MF_LightMap );
		bMultiTex = true;
		if( bFogMap )
			metal->mtlSetState(MTL_ST_FLUSH_Z, 1);
	}
	else if( bFogMap )
	{
		PanX = Surface.FogMap->Pan.X + 0.5*Surface.FogMap->UScale;
		PanY = Surface.FogMap->Pan.Y + 0.5*Surface.FogMap->VScale;
		SelectTexture( 1, *Surface.FogMap, MF_NoPalette|MF_LightMap );
		bMultiTex = true;
		bFogMap = false;
	}
	
	if( bMultiTex )
	{
		MTL_CALL(metal->mtlSetState(MTL_ST_TEX_BLEND, (DWORD) &stage1multitex));
		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			for( INT i=0; i<Poly->NumPts; i++ )
			{
				VERTS(Poly)[i].tu0 = (MVERTS(Poly)[i].MASTER_S - Surface.Texture->Pan.X) * UScale[0];
				VERTS(Poly)[i].tv0 = (MVERTS(Poly)[i].MASTER_T - Surface.Texture->Pan.Y) * VScale[0];
				VERTS(Poly)[i].tu1 = (MVERTS(Poly)[i].MASTER_S - PanX) * UScale[1];
				VERTS(Poly)[i].tv1 = (MVERTS(Poly)[i].MASTER_T - PanY) * VScale[1];
			}

			metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, Poly->NumPts, (void*)VERTS(Poly));
		}
		DeselectTexture(1);
		MTL_CALL(metal->mtlSetState(MTL_ST_TEX_BLEND, (DWORD) &stage1off));
		metal->mtlSetState(MTL_ST_TEX_STAGE, 0);
	}
	else
	{
		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			for( INT i=0; i<Poly->NumPts; i++ )
			{
				VERTS(Poly)[i].tu0 = (MVERTS(Poly)[i].MASTER_S - Surface.Texture->Pan.X) * UScale[0];
				VERTS(Poly)[i].tv0 = (MVERTS(Poly)[i].MASTER_T - Surface.Texture->Pan.Y) * VScale[0];
			}

			metal->mtlSetState(MTL_ST_TEX_ENABLE, 1);
			metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, Poly->NumPts, (void*)VERTS(Poly));
		}
	}

	ResetBlending( Surface.PolyFlags );

	// Handle depth buffering the appropriate areas of masked textures.
	if( Surface.PolyFlags & PF_Masked )
	   metal->mtlSetState( MTL_ST_Z_COMPARE, MTL_COMPARE_EQUAL);

	// Draw detail texture overlaid.
	if( bDetailTexture )
	{
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_COL);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_COL);
		SelectTexture( 0, *Surface.DetailTexture, MF_NoPalette | MF_NoScale );
		metal->mtlSetState(MTL_ST_TEX_MIPMAP_BIAS, (DWORD) 0.8 * 0x10);

		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			for( INT i=0; i<Poly->NumPts; i++ )
			{
				VERTS(Poly)[i].tu0 = (MVERTS(Poly)[i].MASTER_S - Surface.DetailTexture->Pan.X) * UScale[0];
				VERTS(Poly)[i].tv0 = (MVERTS(Poly)[i].MASTER_T - Surface.DetailTexture->Pan.Y) * VScale[0];
			}

			metal->mtlSetState(MTL_ST_TEX_ENABLE, 1);
			metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, Poly->NumPts, (void*)VERTS(Poly));
		}

		metal->mtlSetState(MTL_ST_TEX_MIPMAP_BIAS, 0);
	}

	// Fog map.
	if( bFogMap )
	{
		SelectTexture( 0, *Surface.FogMap, MF_NoPalette|MF_LightMap );
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_INVCOL);
		// DAVE: also set Modulate and set values into color I think

		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			for( int i=0; i<Poly->NumPts; i++ )
			{
				VERTS(Poly)[i].tu0 = (MVERTS(Poly)[i].MASTER_S - Surface.FogMap->Pan.X + 0.5*Surface.FogMap->UScale) * UScale[0];
				VERTS(Poly)[i].tv0 = (MVERTS(Poly)[i].MASTER_T - Surface.FogMap->Pan.Y + 0.5*Surface.FogMap->VScale) * VScale[0];
			}
			metal->mtlPrimitiveDraw( MTL_PRIM_TRIFAN, Poly->NumPts, (void *)VERTS(Poly));
		}
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_ZERO);
		metal->mtlSetState(MTL_ST_FLUSH_Z, 0);
	}

	// Finish mask handling.
	if( Surface.PolyFlags & PF_Masked )
       metal->mtlSetState(MTL_ST_Z_COMPARE, MTL_COMPARE_LESSEQUAL);
}

//-----------------------------------------------------------------------------
//	UMeTaLRenderDevice texture coordinates polygon drawer.
//-----------------------------------------------------------------------------


//
// Draw a polygon with texture coordinates.
//
void UMeTaLRenderDevice::DrawGouraudPolygon
(
	FSceneNode*		Frame,
	FTextureInfo&	Texture,
	FTransTexture**	Pts,
	INT				NumPts,
	DWORD			PolyFlags,
	FSpanBuffer*	Span
)
{
	guard(UMeTaLRenderDevice::DrawGouraudPolygon);

	if(m_bIsMS1)
		DrawGouraudPolygonMS1( Frame, Texture, Pts, NumPts, PolyFlags, Span );
	else
		DrawGouraudPolygonGX3( Frame, Texture, Pts, NumPts, PolyFlags, Span );

	// Unlock.
	unguard;
}

void UMeTaLRenderDevice::DrawGouraudPolygonGX3
(
	FSceneNode*		Frame,
	FTextureInfo&	Texture,
	FTransTexture**	Pts,
	INT				NumPts,
	DWORD			PolyFlags,
	FSpanBuffer*	Span
)
{
	guard(UMeTaLRenderDevice::DrawGouraudPolygon);

	// Set up verts.
	static MTL_VERTEX Verts[32];
	SelectTexture( 0, Texture, MF_NoScale | ((PolyFlags&PF_Masked)?MF_Alpha:0) );
	for( INT i=0; i<NumPts; i++ )
	{
		Verts[i].sx	 	= Pts[i]->ScreenX + Frame->XB;
		Verts[i].sy	 	= Pts[i]->ScreenY + Frame->YB;
		Verts[i].rhw	= Pts[i]->RZ * Frame->RProj.Z;
		// DAVE: R, G and B are float in the 0-1 range I presume. Would be better in asm
		Verts[i].color	= 	(f2i(Pts[i]->Light.X*(255.0f))<<16) +
							(f2i(Pts[i]->Light.Y*(255.0f))<<8) +
							(f2i(Pts[i]->Light.Z*(255.0f))) | 0xff000000;
		Verts[i].sz		= Z_CONVERT(Pts[i]->Point.Z);
		Verts[i].tu		= Pts[i]->U*UScale[0];
		Verts[i].tv		= Pts[i]->V*VScale[0];
	}

	// Draw it.
	SetBlending( PolyFlags );

	// DAVE: ??? This is strange; queries for modulated but if TRUE sets decal ELSE sets modulate???
	// DAVE: I suspect this is because 'modulated' refers to 'lighting mapped' usually... or something...
	if (PolyFlags & PF_Modulated)
		metal->mtlSetState(MTL_ST_TEX_BLENDING, MTL_TEX_BLENDING_COPY);
	else
		metal->mtlSetState(MTL_ST_TEX_BLENDING, MTL_TEX_BLENDING_MODULATE_ALPHA);

	metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, NumPts, (void *)Verts);

	ResetBlending( PolyFlags );

	// Fog.
	if( (PolyFlags & (PF_RenderFog|PF_Translucent|PF_Modulated))==PF_RenderFog )
	{
		for( INT i=0; i<NumPts; i++ )
			Verts[i].color = (f2i(Pts[i]->Fog.X*(255.0f))<<16) +
							(f2i(Pts[i]->Fog.Y*(255.0f))<<8) +
							(f2i(Pts[i]->Fog.Z*(255.0f))) | 0xff000000;

		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_INVCOL);
		metal->mtlSetState(MTL_ST_TEX_BLENDING, MTL_TEX_BLENDING_MODULATE_ALPHA);

		metal->mtlSetState(MTL_ST_TEX_ENABLE,FALSE);
		metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, NumPts, (void *)Verts);

		metal->mtlSetState(MTL_ST_TEX_ENABLE,TRUE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_ZERO);
	}

	// Unlock.
	unguard;
}

void UMeTaLRenderDevice::DrawGouraudPolygonMS1
(
	FSceneNode*		Frame,
	FTextureInfo&	Texture,
	FTransTexture**	Pts,
	INT				NumPts,
	DWORD			PolyFlags,
	FSpanBuffer*	Span
)
{
	guard(UMeTaLRenderDevice::DrawGouraudPolygon);

	if( (PolyFlags & (PF_RenderFog|PF_Translucent|PF_Modulated))==PF_RenderFog )
		metal->mtlSetState(MTL_ST_FLUSH_Z, 1);

	// Set up verts.
	static FVF_VERTEX Verts[32];
	SelectTexture( 0, Texture, MF_NoScale | ((PolyFlags&PF_Masked)?MF_Alpha:0) );
	for( INT i=0; i<NumPts; i++ )
	{
		Verts[i].sx	 	= Pts[i]->ScreenX + Frame->XB;
		Verts[i].sy	 	= Pts[i]->ScreenY + Frame->YB;
		Verts[i].rhw	= Pts[i]->RZ * Frame->RProj.Z;
		// DAVE: R, G and B are float in the 0-1 range I presume. Would be better in asm
		Verts[i].color	= 	(f2i(Pts[i]->Light.X*(255.0f))<<16) +
							(f2i(Pts[i]->Light.Y*(255.0f))<<8) +
							(f2i(Pts[i]->Light.Z*(255.0f))) | 0xff000000;
		Verts[i].tu0		= Pts[i]->U*UScale[0];
		Verts[i].tv0		= Pts[i]->V*VScale[0];
	}

	// Draw it.
	SetBlending( PolyFlags );

	// DAVE: ??? This is strange; queries for modulated but if TRUE sets decal ELSE sets modulate???
	// DAVE: I suspect this is because 'modulated' refers to 'lighting mapped' usually... or something...
	if (PolyFlags & PF_Modulated)
	{
		MTL_CALL(metal->mtlSetState(MTL_ST_TEX_BLEND, (DWORD) &stage0copy));
	}
	else
	{
		MTL_CALL(metal->mtlSetState(MTL_ST_TEX_BLEND, (DWORD) &stage0modulate));
	}

	metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, NumPts, (void *)Verts);

	ResetBlending( PolyFlags );

	// Fog.
	if( (PolyFlags & (PF_RenderFog|PF_Translucent|PF_Modulated))==PF_RenderFog )
	{
		for( INT i=0; i<NumPts; i++ )
			Verts[i].color = (f2i(Pts[i]->Fog.X*(255.0f))<<16) +
							(f2i(Pts[i]->Fog.Y*(255.0f))<<8) +
							(f2i(Pts[i]->Fog.Z*(255.0f))) | 0xff000000;

		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_INVCOL);
		MTL_CALL(metal->mtlSetState(MTL_ST_TEX_BLEND, (DWORD) &stage0modulate));

		metal->mtlSetState(MTL_ST_TEX_ENABLE,FALSE);
		metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, NumPts, (void *)Verts);

		metal->mtlSetState(MTL_ST_TEX_ENABLE,TRUE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_ZERO);

		metal->mtlSetState(MTL_ST_FLUSH_Z, 0);
	}

	// Unlock.
	unguard;
}

//-----------------------------------------------------------------------------
//	Textured tiles.
//-----------------------------------------------------------------------------

// DAVE: I think these are screen-aligned (billboard) sprites like the ones in the particle demo
// We'll get a big performance boost from batching, I think
void UMeTaLRenderDevice::DrawTile
(
	FSceneNode* Frame,
	FTextureInfo& Texture,
	FLOAT X, FLOAT Y,
	FLOAT XL, FLOAT YL,
	FLOAT U, FLOAT V,
	FLOAT UL, FLOAT VL,
	class FSpanBuffer* Span,
	FLOAT Z,
	FPlane Color,
	FPlane Fog,
	DWORD PolyFlags
	)
{
	guard(UMeTaLRenderDevice::DrawTile);

	if(m_bIsMS1)
		DrawTileMS1( Frame, Texture, X, Y, XL, YL, U, V, UL, VL, Span, Z, Color, Fog, PolyFlags );
	else
		DrawTileGX3( Frame, Texture, X, Y, XL, YL, U, V, UL, VL, Span, Z, Color, Fog, PolyFlags );

	unguard;
}

void UMeTaLRenderDevice::DrawTileGX3
(
	FSceneNode* Frame,
	FTextureInfo& Texture,
	FLOAT X, FLOAT Y,
	FLOAT XL, FLOAT YL,
	FLOAT U, FLOAT V,
	FLOAT UL, FLOAT VL,
	class FSpanBuffer* Span,
	FLOAT Z,
	FPlane Color,
	FPlane Fog,
	DWORD PolyFlags
	)
{
	// Setup color.
	FColor MetalColor = FColor(Color);

	// Set up verts.
	MTL_VERTEX Verts[4];
	SelectTexture( 0, Texture, MF_NoScale | ((PolyFlags&PF_Masked)?MF_Alpha:0) );
	FLOAT RZ    = 1.0 / Z;
	X	+= Frame->XB + 0.25;
	Y	+= Frame->YB + 0.25;
	Z = Z_CONVERT(Z);
	Verts[0].sx=X   ; Verts[0].sy=Y   ; Verts[0].rhw=RZ;
	Verts[0].sz = Z; 
	Verts[0].tu=U*UScale[0];		Verts[0].tv=V*VScale[0]; 
	Verts[0].color = (MetalColor.B)|(MetalColor.G<<8)|(MetalColor.R<<16)|0xff000000;//(MetalColor.A<<24);

	Verts[1].sx=X   ; Verts[1].sy=Y+YL; Verts[1].rhw=RZ;
	Verts[1].sz = Z; 
	Verts[1].tu=U*UScale[0];		Verts[1].tv=(V+VL)*VScale[0]; 
	Verts[1].color = Verts[0].color;

	Verts[2].sx=X+XL; Verts[2].sy=Y+YL; Verts[2].rhw=RZ;
	Verts[2].sz = Z; 
	Verts[2].tu=(U+UL)*UScale[0]; Verts[2].tv=(V+VL)*VScale[0]; 
	Verts[2].color = Verts[0].color;

	Verts[3].sx=X+XL; Verts[3].sy=Y   ; Verts[3].rhw=RZ;
	Verts[3].sz = Z; 
	Verts[3].tu=(U+UL)*UScale[0]; Verts[3].tv=V*VScale[0];
	Verts[3].color = Verts[0].color;

	// Draw it.
	SetBlending( PolyFlags );
	// Here's that interesting 'backwards' if again
	if (PolyFlags & PF_Modulated)
		metal->mtlSetState(MTL_ST_TEX_BLENDING, MTL_TEX_BLENDING_COPY);
	else
		metal->mtlSetState(MTL_ST_TEX_BLENDING, MTL_TEX_BLENDING_MODULATE_ALPHA);
		
	metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, 4, (void *)Verts);
	ResetBlending( PolyFlags );
	
	// Fog.
	if( PolyFlags & PF_RenderFog )
	{
		if( PolyFlags & (PF_Translucent|PF_Modulated) )
			metal->mtlSetState(MTL_ST_Z_UPDATE, FALSE);

		MetalColor = FColor(Fog);
		Verts[0].color = (MetalColor.B)|(MetalColor.G<<8)|(MetalColor.R<<16)|(MetalColor.A<<24);
		Verts[1].color = Verts[0].color;
		Verts[2].color = Verts[0].color;
		Verts[3].color = Verts[0].color;
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_INVCOL);
		metal->mtlSetState(MTL_ST_TEX_BLENDING, MTL_TEX_BLENDING_MODULATE_ALPHA);
		
		metal->mtlPrimitiveDraw( MTL_PRIM_TRIFAN, 4, (void *)Verts);

		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_ZERO);

		if( PolyFlags & (PF_Translucent|PF_Modulated) )
			metal->mtlSetState(MTL_ST_Z_UPDATE,TRUE);
	}
}

void UMeTaLRenderDevice::DrawTileMS1
(
	FSceneNode* Frame,
	FTextureInfo& Texture,
	FLOAT X, FLOAT Y,
	FLOAT XL, FLOAT YL,
	FLOAT U, FLOAT V,
	FLOAT UL, FLOAT VL,
	class FSpanBuffer* Span,
	FLOAT Z,
	FPlane Color,
	FPlane Fog,
	DWORD PolyFlags
	)
{
	// Setup color.
	FColor MetalColor = FColor(Color);

	// Set up verts.
	FVF_VERTEX Verts[4];
	SelectTexture( 0, Texture, MF_NoScale | ((PolyFlags&PF_Masked)?MF_Alpha:0) );
	FLOAT RZ    = 1.0 / Z;
	X	+= Frame->XB + 0.25;
	Y	+= Frame->YB + 0.25;
	Verts[0].sx=X   ; Verts[0].sy=Y   ; Verts[0].rhw=RZ;
	Verts[0].tu0=U*UScale[0];		Verts[0].tv0=V*VScale[0]; 
	Verts[0].color = (MetalColor.B)|(MetalColor.G<<8)|(MetalColor.R<<16)|0xff000000;//(MetalColor.A<<24);

	Verts[1].sx=X   ; Verts[1].sy=Y+YL; Verts[1].rhw=RZ;
	Verts[1].tu0=U*UScale[0];		Verts[1].tv0=(V+VL)*VScale[0]; 
	Verts[1].color = Verts[0].color;

	Verts[2].sx=X+XL; Verts[2].sy=Y+YL; Verts[2].rhw=RZ;
	Verts[2].tu0=(U+UL)*UScale[0]; Verts[2].tv0=(V+VL)*VScale[0]; 
	Verts[2].color = Verts[0].color;

	Verts[3].sx=X+XL; Verts[3].sy=Y   ; Verts[3].rhw=RZ;
	Verts[3].tu0=(U+UL)*UScale[0]; Verts[3].tv0=V*VScale[0];
	Verts[3].color = Verts[0].color;

	// Draw it.
	SetBlending( PolyFlags );
	if( PolyFlags & PF_RenderFog )
		metal->mtlSetState(MTL_ST_FLUSH_Z, 1);

	// Here's that interesting 'backwards' if again
	if (PolyFlags & PF_Modulated)
	{
		MTL_CALL(metal->mtlSetState(MTL_ST_TEX_BLEND, (DWORD) &stage0copy));
	}
	else
	{
		MTL_CALL(metal->mtlSetState(MTL_ST_TEX_BLEND, (DWORD) &stage0modulate));
	}
	
	metal->mtlPrimitiveDraw(MTL_PRIM_TRIFAN, 4, (void *)Verts);
	ResetBlending( PolyFlags );
	
	// Fog.
	if( PolyFlags & PF_RenderFog )
	{
		if( PolyFlags & (PF_Translucent|PF_Modulated) )
			metal->mtlSetState(MTL_ST_Z_UPDATE, FALSE);

		MetalColor = FColor(Fog);
		Verts[0].color = (MetalColor.B)|(MetalColor.G<<8)|(MetalColor.R<<16)|(MetalColor.A<<24);
		Verts[1].color = Verts[0].color;
		Verts[2].color = Verts[0].color;
		Verts[3].color = Verts[0].color;
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_SRC, MTL_ALPHA_BLEND_ONE);
		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_INVCOL);
		MTL_CALL(metal->mtlSetState(MTL_ST_TEX_BLEND, (DWORD) &stage0modulate));
		
		metal->mtlPrimitiveDraw( MTL_PRIM_TRIFAN, 4, (void *)Verts);

		metal->mtlSetState(MTL_ST_ALPHA_BLEND_DEST, MTL_ALPHA_BLEND_ZERO);

		if( PolyFlags & (PF_Translucent|PF_Modulated) )
			metal->mtlSetState(MTL_ST_Z_UPDATE,TRUE);

		metal->mtlSetState(MTL_ST_FLUSH_Z, 0);
	}
}

//-----------------------------------------------------------------------------
//	Command line.
//-----------------------------------------------------------------------------

//
// Get stats.
//
void UMeTaLRenderDevice::GetStats( TCHAR* Result )
{
	guard(UMeTaLRenderDevice::GetStats);
#ifdef MTL_STATS
    appSprintf(Result, TEXT("%i x %i x %i x %i. %i. %li/%li/%li/%li/%li/%li A/L/UP/FP/UL/FL"), 
		Viewport->SizeX, Viewport->SizeY, Viewport->ColorBytes*8, m_nBufferMode == MTL_BUF_DOUBLE_Z ? 2 : 3, 
		m_nStatUploadsLastFrame/1024, m_nStatTexMemAlloced/1024, m_nStatTexMemInLevel/1024, m_nStatTexUploadPrecache/1024, m_nStatTexFreedPrecache/1024, 
		m_nStatTexUploadLevel/1024, m_nStatTexFreedLevel/1024);
#else // !MTL_STATS
    appSprintf(Result, TEXT("Mode = %i x %i x %i - %s."), Viewport->SizeX, Viewport->SizeY, Viewport->ColorBytes*8,
		m_nBufferMode == MTL_BUF_DOUBLE_Z ? TEXT("double buffered") : TEXT("triple buffered"));
#endif
	unguard;
}

//
// Execute a command.
//
UBOOL UMeTaLRenderDevice::Exec( const TCHAR* Cmd, FOutputDevice& A )
{
	guard(UMeTaLRenderDevice::Exec);

	if(ParseCommand(&Cmd,TEXT("GetRes")))
	{
		if(m_nVRAMSize > 0x800000) // Card has more than 8meg free
			A.Logf( TEXT("512x384 640x480 800x600 1024x768 1280x1024 1600x1200" ));
		else
			A.Logf( TEXT("512x384 640x480 800x600 1024x768") );
		return 1;
	}
	else if(ParseCommand(&Cmd,TEXT("GetCurrentRes")))
	{
		A.Logf( TEXT("%ix%i"), Viewport->SizeX, Viewport->SizeY, Viewport->ColorBytes*8);
		return 1;
	}
	else 
		return 0;

    unguard;
}


//-----------------------------------------------------------------------------
//	Unimplemented.
//-----------------------------------------------------------------------------

void UMeTaLRenderDevice::Draw2DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector P1, FVector P2 )
{
	guard(UMeTaLRenderDevice::Draw2DLine);
	// Not implemented (not needed for Unreal I).
	unguard;
}
void UMeTaLRenderDevice::Draw2DPoint( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FLOAT X1, FLOAT Y1, FLOAT X2, FLOAT Y2, FLOAT Z )
{
	guard(UMeTaLRenderDevice::Draw2DPoint);
	// Not implemented (not needed for Unreal I).
	unguard;
}
void UMeTaLRenderDevice::PushHit( const BYTE* Data, INT Count )
{
	guard(UMeTaLRenderDevice::PushHit);
	// Not implemented (not needed for Unreal I).
	unguard;
}
void UMeTaLRenderDevice::PopHit( INT Count, UBOOL bForce )
{
	guard(UMeTaLRenderDevice::PopHit);
	// Not implemented (not needed for Unreal I).
	unguard;
}

//-----------------------------------------------------------------------------
//	Pixel reading.
//-----------------------------------------------------------------------------

void UMeTaLRenderDevice::ReadPixels( FColor* InPixels )
{ 
	guard(ReadPixels);
	BYTE* Pixels=(BYTE*)InPixels;

	// Lock the frame buffer.  
	LPDIRECTDRAWSURFACE3 lpdds;
	DDSURFACEDESC ddsd;
	memset(&ddsd,0,sizeof(ddsd));
	ddsd.dwSize=sizeof(ddsd);

	metal->mtlGetState(MTL_ST_BUFFER_FRONT,&lpdds);
	lpdds->Lock(NULL,&ddsd,DDLOCK_SURFACEMEMORYPTR|DDLOCK_WAIT,NULL);
	
	INT nWidth=ddsd.dwWidth; 
	INT nHeight=ddsd.dwHeight;
	INT nSize=nWidth*nHeight;
   
	// Try to handle both 16-bit and 32-bit cases here
	if(m_nScreenBpp == 32)
	{
		BYTE* sdata=(BYTE*)ddsd.lpSurface;
		INT k=0;
		for( INT i=0; i<nHeight; i++ )
		{
			for(INT j=0;j<nWidth;j++)
			{	
				Pixels[k*4+0] = *sdata++;
				Pixels[k*4+1] = *sdata++;
				Pixels[k*4+2] = *sdata++;
				sdata++;//Skip Alpha-Channel
				k++;
			}
			sdata+=(ddsd.lPitch-ddsd.dwWidth*4);
		}
	}
	else // Now the 16-bit kludgy code
	{
		// Read the frame buffer.
		FMemMark Mark(GMem);
		WORD* Buffer = New<_WORD>(GMem,nSize);
		WORD* Src = (WORD*)ddsd.lpSurface;
		WORD* Dest = Buffer;
		for( INT y=0; y<nHeight; y++ )
		{
			WORD* End = &Dest[nWidth];
			while(Dest < End)
				*Dest++ = *Src++;
			Src += ddsd.lPitch/2 - nWidth;
		}
		// Unlock the frame buffer.
		for( INT i=0; i<nSize; i++ )
		{
			// Left it the same way for 16-bit case
			Pixels[i*4+0] = (Buffer[i] & 0xf800) >> 8;
			Pixels[i*4+1] = (Buffer[i] & 0x07e0) >> 3;
			Pixels[i*4+2] = (Buffer[i] & 0x001f) << 3;
		}

		// Expand to truecolor.
		DWORD* Data = (DWORD*)Pixels;
		for( y=0; y < nHeight; y++ )
		{
			for( INT x=0; x < nWidth; x++ )
			{
				DWORD rgb = *Data;
				DWORD r = (rgb >> 16) & 0xFF;
				DWORD g = (rgb >> 8) & 0xFF;
				DWORD b = rgb & 0xFF;
				r += r>>5;
				g += g>>6;
				b += b>>5;
				if( r > 255 )
					r = 255;
				if( g > 255 )
					g = 255;
				if( b > 255 )
					b = 255;
				rgb = (r<<16) | (g<<8) | b;
				*Data++ = rgb;
			}
		}
	}

	lpdds->Unlock(NULL);
	lpdds->Release();

	// Init the gamma table.
	FLOAT Gamma=Viewport->GetOuterUClient()->Brightness;

	if(Gamma != 1.0)
	{
		DWORD GammaTable[256];
		for( INT i=0; i<256; i++ )
			GammaTable[i] = appFloor(appPow(i/255.,1.0/Gamma) * 255.0);

		// Gamma correct.
		DWORD* Data = (DWORD*)Pixels;
		for( INT y=0; y<Y; y++ )
		{
			for( INT x=0; x<nWidth; x++ )
			{
				DWORD r = GammaTable[(*Data >> 16) & 0xFF];
				DWORD g = GammaTable[(*Data >> 8 ) & 0xFF];
				DWORD b = GammaTable[(*Data >> 0 ) & 0xFF];
				*InPixels++ = FColor(r,g,b);
				Data++;
			}
		}
	}

	unguard;
}

//-----------------------------------------------------------------------------
//	The End.
//-----------------------------------------------------------------------------

#ifdef MTL_STATS

DWORD UMeTaLRenderDevice::CalcSurfaceSize(DWORD dwWidth, DWORD dwHeight, MTL_TEX_FORMAT format, MTL_DWORD cMip)
{
	int bytePerPixel2;
	DWORD size;

	bytePerPixel2=CalcBPP2(format);
	// now step through each mip level

	size=0;
	while (cMip-- > 0)
	{
		int helpW,helpH;

		// special case?
		if (dwWidth<=4&&dwHeight<=4)
		{
			// texture is size 4x4 or less
			size+=8*8*bytePerPixel2;	// Last 3 mip levels; 2 4x8 subtiles containing all three
			break;
		}

		// round up width/height if necessary
		helpW = dwWidth<8?8:dwWidth;
		helpH = dwHeight<8?8:dwHeight;

		// add size of current level
		size += helpW*helpH*bytePerPixel2;

		// scale down
		dwWidth=(dwWidth+1)>>1;
		dwHeight=(dwHeight+1)>>1;
	}

	return size/2;
}

int UMeTaLRenderDevice::CalcBPP2(MTL_TEX_FORMAT format)
{
	switch(format&0x3fffffff)
	{
		case MTL_TEX_S3TC:
			return 1;
		case MTL_TEX_PAL:
			return 2;
		case MTL_TEX_ARGB8888:
			return 8;
		default:
			return 4;
	}
}
#endif // MTL_STATS
