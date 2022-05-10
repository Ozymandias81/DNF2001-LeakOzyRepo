/*=============================================================================
	UnGlide.cpp: Unreal support for the 3dfx Glide library.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
		* Multitexture and context support - Andy Hanson (hanson@3dfx.com) and
		  Jack Mathews (jack@3dfx.com)

	Notes:
		In reality, both Voodoo2 and V3 have a palette per TMU, 
		however our next generation does not. So we decided it was best 
		to not expose this feature, otherwise many games would not work 
		on the next generation hardware. Palettes are very large on the chip 
		and we decided to focus on compressed textures instead (like S3TC). 
		So although our current hardware really does have 2 palettes, Glide 
		sets both whenever you set one, making it look like there's only one. 
		--Gary Tarolli (on error in docs saying there is one palette per tmu).
=============================================================================*/

// Precompiled header.
#if _MSC_VER
#pragma warning( disable:4201 )
#pragma warning( disable:4701 )
#include <windows.h>
#endif

#include "../../Render/Src/RenderPrivate.h"

// 3dfx Glide includes.
#if _MSC_VER
#define __MSC__
#include <Glide.h>
#elif __LINUX__
#include <glide.h>
#endif

// njs:	Conver fog table index to w value
__forceinline double fogTableIndexToW(int i)
{
	return appPow(2.0,3.0+(double)(i>>2))/(8-(i&3));
}

// Globals.
#define PYR(n) ((n)*((n+1))/2)
static UBOOL GGlideCheckErrors=1;
_WORD RScale[PYR(128)+256], GScale[PYR(128)+256], BScale[PYR(128)+256];

// Texture upload flags.
enum EGlideFlags
{
	GF_Alpha		= 0x01, // 5551 rgba texture.
	GF_NoPalette    = 0x02, // Non-palettized.
	GF_NoScale      = 0x04, // Scale for precision adjust.
	GF_RGBA4        = 0x08, // RGBA 4444.
};

// Pixel formats.
union FGlideColor
{
#if __INTEL_BYTE_ORDER__
	struct{ _WORD B:5, G:5, R:5, A:1; } Color5551;
	struct{ _WORD B:4, G:4, R:4, A:4; } Color4444;
	struct{ _WORD B:5, G:6, R:5;      } Color565;
#else
	struct{ _WORD A:1, R:5, G:5, B:5  } Color5551;
	struct{ _WORD A:4, R:4, G:4, B:4  } Color4444;
	struct{ _WORD R:5, G:6, B:5;      } Color565;
#endif
};

// DrawComplexSurface macros.
#define VERTS(poly) ((GrVertex*)(poly)->User)
#define MASTER_S r
#define MASTER_T g

// Unreal package implementation.
IMPLEMENT_PACKAGE(GlideDrv);

/*-----------------------------------------------------------------------------
	Globals.
-----------------------------------------------------------------------------*/

//
// Mask a floating point value for Glide.
//
__forceinline FLOAT Mask( FLOAT f )
{
	return f + (FLOAT)( 3 << 18 );
}

// CDH...

// Change this to 1 if you want to try the sgr functions
#if 0

//CMDVAR(UBOOL, glide_nosgr, 0);

__forceinline void sgrAlphaBlendFunction(GrAlphaBlendFnc_t p1, GrAlphaBlendFnc_t p2, GrAlphaBlendFnc_t p3, GrAlphaBlendFnc_t p4)
{
	static GrAlphaBlendFnc_t _p1=0xFFFFFFFF,_p2=0xFFFFFFFF,_p3=0xFFFFFFFF,_p4=0xFFFFFFFF;
	if (/*(glide_nosgr) || */(p1!=_p1)||(p2!=_p2)||(p3!=_p3)||(p4!=_p4))
	{
		grAlphaBlendFunction(p1,p2,p3,p4);
		_p1=p1; _p2=p2; _p3=p3; _p4=p4;
	}
}

__forceinline void sgrAlphaTestFunction(GrCmpFnc_t p1)
{
	static GrCmpFnc_t _p1=0xFFFFFFFF;
	if (/*(glide_nosgr) || */(p1!=_p1))
	{
		grAlphaTestFunction(p1);
		_p1=p1;
	}
}

__forceinline void sgrDepthMask(FxBool p1)
{
	static FxBool _p1=0xFF;
	if (/*(glide_nosgr) || */(p1!=_p1))
	{
		grDepthMask(p1);
		_p1=p1;
	}
}

static GrColorCombineFnc_t gucc_p1=0xf0f0f0f0;

__forceinline void sgrColorCombine(GrCombineFunction_t p1, GrCombineFactor_t p2, GrCombineLocal_t p3, GrCombineOther_t p4, FxBool p5)
{
	gucc_p1=0xf0f0f0f0;
	grColorCombine(p1,p2,p3,p4,p5);
}

__forceinline void sguColorCombineFunction(GrColorCombineFnc_t p1)
{
	if (/*(glide_nosgr) ||*/ (p1!=gucc_p1))
	{
		guColorCombineFunction(p1);
		gucc_p1=p1;
	}
}

#else

#define sgrAlphaBlendFunction grAlphaBlendFunction
#define sgrAlphaTestFunction grAlphaTestFunction
#define sgrDepthMask grDepthMask
#define sgrColorCombine grColorCombine
#define sguColorCombineFunction guColorCombineFunction

#endif

// ...CDH

/*-----------------------------------------------------------------------------
	Global Glide error handler.
-----------------------------------------------------------------------------*/

//
// Handle a Glide error.
//
static void GlideErrorHandler( const char* String, FxBool Fatal )
{
	if( GGlideCheckErrors )
		appErrorf( TEXT("Glide error: %s"), appFromAnsi(String) );
}

/*-----------------------------------------------------------------------------
	Statistics.
-----------------------------------------------------------------------------*/

//
// Statistics.
//
static struct FGlideStats
{
	// Stat variables.
	INT DownloadsPalette;
	INT Downloads8;
	INT Downloads16;
	INT PolyVTime;
	INT PolyCTime;
	INT PaletteTime;
	INT Download8Time;
	INT Download16Time;
	DWORD Surfs, Polys, Tris, Masking;
	INT DownloadSize[5];
} Stats;

/*-----------------------------------------------------------------------------
	UGlideRenderDevice definition.
-----------------------------------------------------------------------------*/

//
// The 3dfx Glide rendering device.
//
class DLL_EXPORT_CLASS UGlideRenderDevice : public URenderDevice
{
	DECLARE_CLASS(UGlideRenderDevice,URenderDevice,CLASS_Config)

	// Constants.
	enum {MAX_TMUS=2};
	enum {ALIGNMENT=32};
	enum ETextureType
	{
		TT_Empty,
		TT_Normal,
		TT_Masked,
		TT_DetailMacro,
		TT_LightMap,
	};
	enum ECacheStatus
	{
		CS_Empty,
		CS_Stale,
		CS_Fresh,
		CS_Locked
	};

	// Variables.
	GrHwConfiguration	hwconfig;
	INT					NumTmu, X, Y;

	// NJS: Foggy goodness:
	FColor				FogColor;		// NJS: Foggy goodness.
	FLOAT				FogDensity;		// NJS: Foggy goodness.
	BYTE				FogDistance;	// NJS: mmmmm Foggy goodness.

	FPlane				FlashScale;
	FPlane				FlashFog;
	DWORD				LockFlags;
	DWORD				OldPolyFlags;
	BITFIELD			DisableVSync;
	BITFIELD			ScreenSmoothing;
	BITFIELD			AlreadySetRes;
	BITFIELD			Locked;
	FLOAT				DetailBias;
	BYTE				RefreshRate;
	static INT			InitCount;

	// Constructors.
	void StaticConstructor();

	// UObject interface.
	void PostEditChange();
	void ShutdownAfterError();

	// URenderDevice interface.
	UBOOL __fastcall Init( UViewport* InViewport, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen );
	UBOOL __fastcall SetRes( INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen );
	void __fastcall Exit();
	void __fastcall Flush( UBOOL AllowPrecache );
	//void Lock( FPlane FlashScale, FPlane FlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* HitData, INT* HitSize );
	// NJS: Fogo tasto:
	void __fastcall Lock( FColor FogColor, float FogDensity, BYTE FogDistance, FPlane FlashScale, FPlane FlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* HitData, INT* HitSize );

	void __fastcall Unlock( UBOOL Blit );
	//void DrawComplexSurface( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet, TArray<FTransSample> lightingInfo);
	void __fastcall DrawComplexSurface( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet);

	void __fastcall DrawGouraudPolygon( FSceneNode* Frame, FTextureInfo& Info, FTransTexture** Pts, int NumPts, DWORD PolyFlags, FSpanBuffer* Span );
	void __fastcall DrawTile(	FSceneNode* Frame, 
					FTextureInfo& Info, 
					FLOAT X, FLOAT Y, 
					FLOAT XL, FLOAT YL, 
					FLOAT U, FLOAT V, 
					FLOAT UL, FLOAT VL, 
					class FSpanBuffer* Span, 
					FLOAT Z, 
					FPlane Color, FPlane Fog, 
					DWORD PolyFlags, 
					UBOOL bilinear, 
					FLOAT alpha,
					FLOAT rot,
					FLOAT rotationOffsetX,
					FLOAT rotationOffsetY,
					UBOOL MirrorHoriz,
					UBOOL MirrorVert
	);
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	//void __fastcall dnDraw3DLine( FSceneNode* Frame, UTexture *Texture, DWORD PolyFlags, FVector Start, FVector End, FLOAT StartWidth, FLOAT EndWidth, FColor StartColor, FColor EndColor );
	//void dnDrawParticles( ASoftParticleSystem *System, FSceneNode* Frame, FParticle *Particles, INT ParticleCount, DWORD PolyFlags,UBOOL VariableAlpha,FLOAT SystemAlphaScale);
	void __fastcall Draw3DLine( FSceneNode* Frame, FPlane Color, DWORD	LineFlags, FVector P1, FVector P2 );
	void __fastcall Draw2DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector P1, FVector P2 );
	void __fastcall Draw2DPoint( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FLOAT X1, FLOAT Y1, FLOAT X2, FLOAT Y2, FLOAT Z );
	void __fastcall GetStats( TCHAR* Result );
	void __fastcall ClearZ( FSceneNode* Frame );
	void __fastcall PushHit( const BYTE* Data, INT Count );
	void __fastcall PopHit( INT Count, UBOOL bForce );
	void __fastcall ReadPixels( FColor* Pixels, UBOOL BackBuffer = false);
	void __fastcall EndFlash();

	// Functions
	void Destroy();

	// State of a texture map unit.
	struct FGlideTMU
	{
		// Identification.
		UGlideRenderDevice* Glide;
		INT tmu;

		// State variables.
		FMemCache	Cache;
		FColor		MaxColor;
		FCacheItem*	TextureItem;
		QWORD		TextureCacheID;
		DWORD		GlideFlags;
		FLOAT		Scale;
		FLOAT		UScale, VScale;
		FLOAT		UPan,   VPan;
		DWORD		MinAddress, MaxAddress;
		static FColor PaletteMaxColor;
		static QWORD PaletteCacheID;

		// tmu download functions.
		DWORD DownloadTexture( FTextureInfo& TextureInfo, DWORD Address, DWORD GlideFlags, INT iFirstMip, INT iLastMip, GrTexInfo* texinfo, QWORD CacheID, FCacheItem*& Item, INT USize, INT VSize );
		void DownloadPalette( FTextureInfo& TextureInfo, FColor InPaletteMaxColor );

		// State functions.
		void Init( INT Intmu, UGlideRenderDevice* InGlide )
		{

			// Init variables.
			Glide			= InGlide;
			tmu				= Intmu;
			MaxColor	    = FColor(255,255,255,255);
			PaletteMaxColor = FColor(255,255,255,255);
			TextureItem		= NULL;
			PaletteCacheID	= 0;
			MinAddress      = grTexMinAddress(tmu);
			MaxAddress      = grTexMaxAddress(tmu);

			// Init cache.
			debugf
			(
				NAME_Init,
				TEXT("Glide tmu %i: tmuRev=%i tmuRam=%i Space=%i"),
				tmu,
				Glide->hwconfig.SSTs[0].sstBoard.VoodooConfig.tmuConfig[tmu].tmuRev,
				Glide->hwconfig.SSTs[0].sstBoard.VoodooConfig.tmuConfig[tmu].tmuRam,
				MaxAddress - MinAddress
			);
			Cache.Init( MaxAddress - MinAddress, 1024, (BYTE*)grTexMinAddress(tmu)+ALIGNMENT, 2 * 1024 * 1024 );
			grTexLodBiasValue( tmu, Clamp( Glide->DetailBias, -3.f, 3.f ) );
			grTexClampMode( tmu, GR_TEXTURECLAMP_WRAP, GR_TEXTURECLAMP_WRAP );
			guTexCombineFunction( tmu, GR_TEXTURECOMBINE_DECAL );
			grTexMipMapMode( tmu, GR_MIPMAP_NEAREST, FXFALSE );
			grTexFilterMode( tmu, GR_TEXTUREFILTER_BILINEAR, GR_TEXTUREFILTER_BILINEAR );

			// Reset remembered info.
			ResetTexture();

		}
		void Exit()
		{
			Cache.Exit(0);
		}
		void ResetTexture()
		{
			if( TextureItem != NULL )
			{
				TextureItem->Unlock();
				TextureItem = NULL;
			}
			TextureCacheID = 0;
		}
		void Tick()
		{

			// Unlock and reset the texture.
			ResetTexture();

			// Update the texture cache.
			Cache.Tick();
		}
		void Flush()
		{
			debugf( NAME_Log, TEXT("Flushed Glide TMU %i"), tmu );
			Cache.Flush();
		}
		void SetBogusTexture()
		{
			GrTexInfo info;
			info.aspectRatio = GR_ASPECT_1x1;
			info.largeLod    = GR_LOD_1;
			info.smallLod    = GR_LOD_1;
			info.format      = GR_TEXFMT_RGB_565;
			grTexSource( tmu, MinAddress, GR_MIPMAPLEVELMASK_BOTH, &info );
			TextureCacheID = 0;
		}
		void SetTexture( FTextureInfo& Info, DWORD GlideFlags, FLOAT PanBias )
		{
			if( Info.Palette && Info.Palette[128].A!=255 )
				GlideFlags |= GF_NoScale | GF_RGBA4;
			if( Info.Format!=TEXF_P8 )
				GlideFlags |= GF_NoPalette;
			QWORD TestID = Info.CacheID + (((QWORD)GlideFlags) << 59);
			if( TestID!=TextureCacheID )
			{
				// Get the texture into 3dfx memory.
				ResetTexture();
				TextureCacheID = TestID;

				// Make a texinfo.
				GrTexInfo texinfo;
				texinfo.format      = (GlideFlags & GF_RGBA4    ) ? GR_TEXFMT_ARGB_4444
									: (GlideFlags & GF_Alpha    ) ? GR_TEXFMT_ARGB_1555
									: (GlideFlags & GF_NoPalette) ? GR_TEXFMT_RGB_565
									:                               GR_TEXFMT_P_8;
				INT GlideUBits      = Max( (INT)Info.Mips[0]->UBits, (INT)Info.Mips[0]->VBits-3);
				INT GlideVBits      = Max( (INT)Info.Mips[0]->VBits, (INT)Info.Mips[0]->UBits-3);
				INT MaxDim          = Max(GlideUBits,GlideVBits);
				INT FirstMip        = Max(MaxDim,8) - 8;
				INT LastMip			= Min(FirstMip+8,Info.NumMips-1);
				if( FirstMip >= Info.NumMips )
					appErrorf( TEXT("Encountered texture over 256x256 without sufficient mipmaps") );
				texinfo.aspectRatio = GlideVBits + 3 - GlideUBits;
				texinfo.largeLod    = Max( 8-MaxDim, 0 );
				texinfo.smallLod    = texinfo.largeLod + LastMip - FirstMip;

				// Download texture if needed.
				DWORD Address = ALIGNMENT + (DWORD)Cache.Get( TestID, TextureItem, ALIGNMENT );
				if
				(	(Address==ALIGNMENT)
				||	Info.bRealtimeChanged
				||	(Info.Format==TEXF_RGBA7 && GET_COLOR_DWORD(*Info.MaxColor)==0xffffffff) )
					Address = DownloadTexture( Info, Address, GlideFlags, FirstMip, LastMip, &texinfo, TestID, TextureItem, 1<<(GlideUBits-FirstMip), 1<<(GlideVBits-FirstMip) );

				// Make it current.
				grTexSource( tmu, Address, GR_MIPMAPLEVELMASK_BOTH, &texinfo );

				// Set MaxColor.
				MaxColor
				=	Info.Format==TEXF_RGBA7 ? *Info.MaxColor
				:   (GlideFlags & (GF_RGBA4|GF_Alpha|GF_NoPalette|GF_NoScale)) ? FColor(255,255,255,255)
				:	*Info.MaxColor;

				// Set scale.
				Scale = (256 >> FirstMip) / (FLOAT)Min(256, Max(Info.USize, Info.VSize));

				// Handle palette.
				if( !(GlideFlags & (GF_Alpha|GF_RGBA4|GF_NoPalette)) )
					if
					(	( Info.PaletteCacheID!=PaletteCacheID || Info.bRealtimeChanged) // NJS: Video Stuff
					||	GET_COLOR_DWORD(PaletteMaxColor)!=GET_COLOR_DWORD(MaxColor) )
						DownloadPalette( Info, MaxColor );
			}

			// Update this surface's scaling and panning.
			UScale	= Scale / Info.UScale;
			VScale  = Scale / Info.VScale;
			UPan	= Info.Pan.X + PanBias*Info.UScale;
			VPan	= Info.Pan.Y + PanBias*Info.VScale;
		}
		void CopyVerts( FSavedPoly* Poly )
		{
			for( INT i=0; i<Poly->NumPts; i++ )
			{
				VERTS(Poly)[i].tmuvtx[tmu].sow = VERTS(Poly)[i].oow * (VERTS(Poly)[i].MASTER_S - UPan) * UScale;
				VERTS(Poly)[i].tmuvtx[tmu].tow = VERTS(Poly)[i].oow * (VERTS(Poly)[i].MASTER_T - VPan) * VScale;
			}
		}
	} States[MAX_TMUS];

	// Glide specific functions.
	void __fastcall SetTextureClampMode( INT Mode )
	{
		if ( Mode == 1 )
			grTexClampMode( 0, GR_TEXTURECLAMP_CLAMP, GR_TEXTURECLAMP_CLAMP );
		else
			grTexClampMode( 0, GR_TEXTURECLAMP_WRAP, GR_TEXTURECLAMP_WRAP );
	}
	void UpdateModulation( FColor& FinalColor, FColor Color, INT& Count )
	{
		FinalColor.R = (FinalColor.R * Color.R) >> 8;
		FinalColor.G = (FinalColor.G * Color.G) >> 8;
		FinalColor.B = (FinalColor.B * Color.B) >> 8;
		if( --Count == 0 )
		{
			grConstantColorValue( *(GrColor_t*)&FinalColor );
			sgrColorCombine( GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_LOCAL, GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_TEXTURE, FXFALSE );
		}
	}
	void SetBlending( DWORD PolyFlags )
	{
		// Types.
		if( PolyFlags & PF_Translucent )
		{
			sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ONE_MINUS_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO );
			if( !(PolyFlags & PF_Occlude) )
				sgrDepthMask( 0 );
		}
		else if( PolyFlags & PF_Modulated )
		{
			sgrAlphaBlendFunction( GR_BLEND_DST_COLOR, GR_BLEND_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO );
			if( !(PolyFlags & PF_Occlude) )
				sgrDepthMask( 0 );
		}
		else if( PolyFlags & PF_Highlighted )
		{
			guAlphaSource( GR_ALPHASOURCE_TEXTURE_ALPHA );
			sgrAlphaBlendFunction( GR_BLEND_SRC_ALPHA, GR_BLEND_ONE_MINUS_SRC_ALPHA, GR_BLEND_ZERO, GR_BLEND_ZERO );
			if( !(PolyFlags & PF_Occlude) )
				sgrDepthMask( 0 );
		}
		else if( PolyFlags & PF_Masked )
		{
			guAlphaSource( GR_ALPHASOURCE_TEXTURE_ALPHA );
			sgrAlphaBlendFunction( GR_BLEND_SRC_ALPHA, GR_BLEND_ONE_MINUS_SRC_ALPHA, GR_BLEND_ZERO, GR_BLEND_ZERO );
			sgrAlphaTestFunction( GR_CMP_GREATER );
		}
		else
		{
			sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ZERO, GR_BLEND_ZERO, GR_BLEND_ZERO );
		}

		// Flags.
		if( PolyFlags & PF_Invisible )
		{
			grColorMask( FXFALSE, FXFALSE );
		}
		if( PolyFlags & PF_NoSmooth )
		{
			grTexFilterMode( GR_TMU0, GR_TEXTUREFILTER_POINT_SAMPLED, GR_TEXTUREFILTER_POINT_SAMPLED );
		}
		//if( (LockFlags & LOCKR_LightDiminish) && !(PolyFlags & PF_Unlit) )
		//{
		//	grFogMode( GR_FOG_WITH_TABLE );
		//}
		SetFog(PolyFlags);

		// Remember flags.
		OldPolyFlags = PolyFlags;
	}
	void ResetBlending( DWORD PolyFlags )
	{
		// Types.
		if( PolyFlags & PF_Invisible )
		{
			grColorMask( FXTRUE, FXFALSE );
		}
		if( PolyFlags & PF_Masked )
		{
			sgrAlphaTestFunction( GR_CMP_ALWAYS );
		}
		if( PolyFlags & (PF_Translucent|PF_Modulated|PF_Highlighted) )
		{
			if( !(PolyFlags & PF_Occlude) )
				sgrDepthMask( 1 );
		}

		// Flags.
		if( PolyFlags & PF_NoSmooth )
		{
			grTexFilterMode( GR_TMU0, GR_TEXTUREFILTER_BILINEAR, GR_TEXTUREFILTER_BILINEAR );
		}
		//if( (LockFlags & LOCKR_LightDiminish) && !(PolyFlags & PF_Unlit) )
		//{
		//	grFogMode(GR_FOG_DISABLE);
		//}
		ResetFog(PolyFlags);
	}

	// NJS:
	__forceinline void SetFog(DWORD PolyFlags)
	{
		//if( (LockFlags & LOCKR_LightDiminish) && !(PolyFlags & PF_Unlit) /*&& !(PolyFlags & PF_NoDepthFog)*/)
		//	grFogMode( GR_FOG_WITH_TABLE );

	}

	__forceinline void ResetFog(DWORD PolyFlags)
	{
		//if( (LockFlags & LOCKR_LightDiminish) && !(PolyFlags & PF_Unlit) /*&& !(PolyFlags & PF_NoDepthFog)*/)
		//	grFogMode(GR_FOG_DISABLE);
	}
	void DrawStatsSummary( FSceneNode* Frame )
	{
		const INT CS_Total = CS_Fresh + 1;
		static TCHAR* TextureTypeStr[] = 
		{
			TEXT("Empty:"),
			TEXT("Normal:"),
			TEXT("Masked:"),
			TEXT("Detail:"),
			TEXT("Lightmap:"),
		};
		INT Size[ ARRAY_COUNT(TextureTypeStr) ][ CS_Total + 1 ] = { 0 };
		INT Count[ ARRAY_COUNT(TextureTypeStr) ][ CS_Total + 1 ] = { 0 };
		INT tmu = 0;
		FMemCache* Cache = &States[tmu].Cache;
		FMemCache::FCacheItem* Item;

		for( Item = Cache->First(); Item != Cache->Last(); Item = Cache->Next( Item ) )
		{
			INT Status = CS_Empty;
			if( Item->GetCost() >= FMemCache::COST_INFINITE )
				Status = CS_Fresh; //CS_Locked
			else if( Item->GetId() == 0 )
				Status = CS_Empty;
			else if( Cache->GetTime() - Item->GetTime() >= 1 )
				Status = CS_Stale;
			else
				Status = CS_Fresh;
			Size[ Item->GetExtra() ][ Status ] += Item->GetSize();
			Count[ Item->GetExtra() ][ Status ]++;
		}

		GRender->ShowStat( Frame, TEXT("Glide Cache TMU 0 Summary") );
		GRender->ShowStat( Frame, TEXT(" ") );
		GRender->ShowStat( Frame, TEXT("               Stale         Fresh      Download") );
		GRender->ShowStat( Frame, TEXT("----------- --------      --------      --------") );
		INT Total[ CS_Total + 1 ] = { 0 };
		for( INT i = 0; i < ARRAY_COUNT(TextureTypeStr); i++ )
		{
			for( INT Status = 0; Status <= CS_Fresh; Status++ )
			{
				Total[ Status ] += Size[i][ Status ];
			}
			Total[ CS_Total ] += Stats.DownloadSize[i];
			if( i > 0 )
			{
				GRender->ShowStat( Frame, TEXT("%-11s %8i %-4i %8i %-4i %8i"), 
					TextureTypeStr[i], Size[i][ CS_Stale ], Count[i][ CS_Stale ], Size[i][ CS_Fresh ], Count[i][ CS_Fresh ], Stats.DownloadSize[i] );
			}
		}
		GRender->ShowStat( Frame, TEXT("----------- --------      --------      --------") );
		GRender->ShowStat( Frame, TEXT("%-11s %8i      %8i      %8i"), 
			"Total:", Total[ CS_Stale ], Total[ CS_Fresh ], Total[ CS_Total ] );
		GRender->ShowStat( Frame, TEXT(" ") );
		GRender->ShowStat( Frame, TEXT("%-11s %8i"), "Free:", Total[ CS_Empty ] );
		GRender->ShowStat( Frame, TEXT("%-11s %8i"), "Available:", Total[ CS_Empty ] + Total[ CS_Stale ] );
		GRender->ShowStat( Frame, TEXT(" ") );
	}
	void DrawStatsDetail( FSceneNode* Frame )
	{
		static TCHAR* TextureTypeStr[] = 
		{
			TEXT(" "),
			TEXT("N"), //Normal
			TEXT("M"), //Masked
			TEXT("D"), //Detail/Macro
			TEXT("L"), //Lightmap
		};
		static TCHAR* CacheStatusStr[] = 
		{
			TEXT(" "), //Empty
			TEXT("-"), //Stale
			TEXT("X"), //Fresh
			TEXT("L"), //Locked
		};

		INT tmu = 0;
		FMemCache* Cache = &States[tmu].Cache;
		FMemCache::FCacheItem* Item;

		GRender->ShowStat( Frame, TEXT("Glide Cache TMU 0 Detail") );
		INT CurX = (INT) Frame->Viewport->Canvas->CurX;
		INT TopY = (INT) Frame->Viewport->Canvas->CurY;
		for( Item = Cache->First(); Item != Cache->Last(); Item = Cache->Next( Item ) )
		{
			INT Status = CS_Empty;
			if( Item->GetCost() >= FMemCache::COST_INFINITE )
				Status = CS_Locked;
			else if( Item->GetId() == 0 )
				Status = CS_Empty;
			else if( Cache->GetTime() - Item->GetTime() >= 1 )
				Status = CS_Stale;
			else
				Status = CS_Fresh;
			if( Frame->Viewport->Canvas->CurY > Frame->Viewport->Canvas->Y - 10 )
			{
				Frame->Viewport->Canvas->CurY = TopY;
				CurX += 80;
			}
			Frame->Viewport->Canvas->CurX = CurX;
			GRender->ShowStat( Frame, TEXT("%7i %s %s"), Item->GetSize(), TextureTypeStr[ Item->GetExtra() ], CacheStatusStr[ Status ] );
		}
	}
	void __fastcall DrawStats( FSceneNode* Frame )
	{
		if( bDetailStats )
			DrawStatsDetail( Frame );
		else
			DrawStatsSummary( Frame );
	}
private:
	UBOOL bDetailStats;
};
IMPLEMENT_CLASS(UGlideRenderDevice);
INT UGlideRenderDevice::InitCount=0;
FColor UGlideRenderDevice::FGlideTMU::PaletteMaxColor=FColor(0,0,0,0);
QWORD UGlideRenderDevice::FGlideTMU::PaletteCacheID=0;

/*-----------------------------------------------------------------------------
	UGlideRenderDevice Init & Exit.
-----------------------------------------------------------------------------*/

//
// Shut down.
//
void UGlideRenderDevice::Destroy()
{
	Super::Destroy();
	if( --InitCount==0 ) 
		grGlideShutdown();
}

//
// Initializes Glide.  Can't fail.
//
UBOOL UGlideRenderDevice::Init( UViewport* InViewport, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
{

	// Remember variables.
	OldPolyFlags		= 0;
	Viewport			= InViewport;

	// Driver flags.
	SpanBased			= 0;
	FullscreenOnly		= 1;
	SupportsFogMaps		= 1;
	SupportsDistanceFog	= 1;

	// Log message.
	debugf( NAME_Init, TEXT("Initializing Glide...") );

	// Verify that hardware exists.
	ANSICHAR GlideVer[80];
	grGlideGetVersion( GlideVer );
	debugf( NAME_Init, TEXT("Found Glide: %s"), appFromAnsi(GlideVer) );
	if( !grSstQueryBoards(&hwconfig) )
		return 0;

	// Checks.
	check(sizeof(FGlideColor)==2);

	// Initialize the Glide library.
	if( !InitCount++ ) 
		grGlideInit();

	// Set error callback.
	grErrorSetCallback( GlideErrorHandler );

	// Make sure 3Dfx hardware is present.
	GGlideCheckErrors=0;
	if( !grSstQueryHardware( &hwconfig ) )
	{
		//grGlideShutdown();
		debugf( NAME_Init, TEXT("grSstQueryHardware failed") );
		return 0;
    }
	GGlideCheckErrors=1;

	// Init pyramic-compressed scaling tables.
	for( INT A=0; A<128; A++ )
	{
		for( INT B=0; B<=A; B++ )
		{
			INT M            = Max(A,1);
			RScale[PYR(A)+B] = Min(((B*0x10000)/M),0xf800) & 0xf800;
			GScale[PYR(A)+B] = Min(((B*0x00800)/M),0x07e0) & 0x07e0;
			BScale[PYR(A)+B] = Min(((B*0x00020)/M),0x001f) & 0x001f;
		}
	}

	// Check hardware info.
	debugf
	(
		NAME_Init,
		TEXT("Glide info: Type=%i, fbRam=%i fbiRev=%i nTexelfx=%i Sli=%i"),
		hwconfig.SSTs[0].type,
		hwconfig.SSTs[0].sstBoard.VoodooConfig.fbRam,
		hwconfig.SSTs[0].sstBoard.VoodooConfig.fbiRev,
		hwconfig.SSTs[0].sstBoard.VoodooConfig.nTexelfx,
		(INT)hwconfig.SSTs[0].sstBoard.VoodooConfig.sliDetect
	);
	NumTmu = Min(hwconfig.SSTs[0].sstBoard.VoodooConfig.nTexelfx,(INT)MAX_TMUS);
	check(NumTmu>0);
	if( ParseParam(appCmdLine(),TEXT("NoMultiTexture")) )
		NumTmu = 1;

	// Select the first board.
	grSstSelect( 0 );

	// Try it.
	return SetRes( NewX, NewY, NewColorBytes, Fullscreen );
}

//
// Set the resolution.
//
UBOOL UGlideRenderDevice::SetRes( INT NewX, INT NewY, INT NewColorBytes, UBOOL NewFullscreen )
{
	GrScreenRefresh_t Ref = RefreshRate;
	INT   MaxColorBuffers = (hwconfig.SSTs[0].type==GR_SSTTYPE_SST96 || !NewFullscreen) ? 2 : 3;
	INT   NumColorBuffers = MaxColorBuffers;
	UBOOL Result;

	// Shut down if not the first SetRes call.
	if( AlreadySetRes )
	{
		#if _MSC_VER
			grSstWinClose();
		#endif
		for( INT tmu=0; tmu<NumTmu; tmu++ )
			States[tmu].Exit();
	}
	AlreadySetRes = 1;

	// Round the resolution up to the next supported one.
	INT Res;
	if		( NewX<=640  && NewY<=480  ) Res=GR_RESOLUTION_640x480;
	else if ( NewX<=800  && NewY<=600  ) Res=GR_RESOLUTION_800x600;
	else if ( NewX<=1024 && NewY<=768  ) Res=GR_RESOLUTION_1024x768;
	else if ( NewX<=1280 && NewY<=1024 ) Res=GR_RESOLUTION_1280x1024;
	else						         Res=GR_RESOLUTION_1600x1200;

	// Open the display.
	Result = 1;
	GGlideCheckErrors=0;
	#if _MSC_VER
	while( !grSstWinOpen( (INT)Viewport->GetWindow(), Res, Ref, GR_COLORFORMAT_ABGR, GR_ORIGIN_UPPER_LEFT, NumColorBuffers, 1 ) )
	#else
	while( !grSstWinOpen( 0, Res, Ref, GR_COLORFORMAT_ABGR, GR_ORIGIN_UPPER_LEFT, NumColorBuffers, 1 ) )
	#endif
	{
		if( NumColorBuffers==3 )
		{
			debugf( NAME_Init, TEXT("Glide: Color buffers %i failed, falling back..."), NumColorBuffers );
			NumColorBuffers = 2;
			continue;
		}
		NumColorBuffers = MaxColorBuffers;
		if( Res != GR_RESOLUTION_640x480 )
		{
			// Try again.
			debugf( NAME_Init, TEXT("Glide: Resolution %i failed, falling back..."), Res );
			Res = GR_RESOLUTION_640x480;
			continue;
		}
		else if( Ref!=GR_REFRESH_72Hz )
		{
			// Try again.
			debugf( NAME_Init, TEXT("Glide: Refresh %i failed, falling back..."), Ref );
			Ref = GR_REFRESH_72Hz;
			continue;
		}
		debugf( NAME_Init, TEXT("grSstOpen failed (%i, %i)"), Ref, Res );
		Result = 0;
    }
	GGlideCheckErrors = 1;
	if( Result )
	{
		debugf( NAME_Init, TEXT("grSstOpen Res=%i Ref=%i Buffers=%i"), Res, Ref, NumColorBuffers );
		//GrFog_t Fog[GR_FOG_TABLE_SIZE];
		//INT i;

		// Set parameters.
		grDepthBufferMode( GR_DEPTHBUFFER_WBUFFER );
		sgrDepthMask( 1 );
		grDitherMode( GR_DITHER_2x2 );
		grChromakeyValue(0);
		grChromakeyMode(0);
		grAlphaTestReferenceValue( (GrAlpha_t) 127.0 );
		grDepthBiasLevel(16);
		grDepthBufferFunction( GR_CMP_LEQUAL );
		grHints( GR_HINT_STWHINT, 0 );

		// Fog.
		//for( i=0; i < GR_FOG_TABLE_SIZE; i++ )
		//{
		//	FLOAT W = guFogTableIndexToW( i );
		//	Fog[i]  = Clamp( 0.1f * W, 0.f, 255.f );
		//}
		//grFogTable( Fog );
		//grFogColorValue( 0 ); 
		grFogMode( GR_FOG_DISABLE );

		// Init all TMU's.
		for( INT tmu=0; tmu<NumTmu; tmu++ )
			States[tmu].Init( tmu, this );

		// Send initialization to viewport.
		if( NewFullscreen )
		{
			// Hardware fullscreen.
			Viewport->ResizeViewport( BLIT_Fullscreen, grSstScreenWidth(), grSstScreenHeight(), 2 );
		}
		else if( hwconfig.SSTs[0].type==GR_SSTTYPE_SST96 )
		{
			// Voodoo Rush fullscreen.
			Viewport->ResizeViewport( 0, grSstScreenWidth(), grSstScreenHeight(), 2 );
		}
		else
		{
			// Emulated fullscreen. !!experimential
			//FullscreenOnly = 0;
			//grSstControl( GR_CONTROL_DEACTIVATE );
			//Viewport->ResizeViewport( BLIT_DibSection, grSstScreenWidth(), grSstScreenHeight(), 2 );
			Result = 0;
		}
		Flush(0);
	}
	return Result;
}

//
// Register configurable properties.
//
void UGlideRenderDevice::StaticConstructor()
{

	UEnum* RefreshRates=new(GetClass(),TEXT("RefreshRates"))UEnum( NULL );
		new(RefreshRates->Names)FName( TEXT("60Hz")  );
		new(RefreshRates->Names)FName( TEXT("70Hz")  );
		new(RefreshRates->Names)FName( TEXT("72Hz")  );
		new(RefreshRates->Names)FName( TEXT("75Hz")  );
		new(RefreshRates->Names)FName( TEXT("80Hz")  );
		new(RefreshRates->Names)FName( TEXT("90Hz")  );
		new(RefreshRates->Names)FName( TEXT("100Hz") );
		new(RefreshRates->Names)FName( TEXT("85Hz")  );
		new(RefreshRates->Names)FName( TEXT("120Hz") );
	new(GetClass(),TEXT("DisableVSync"),    RF_Public)UBoolProperty ( CPP_PROPERTY(DisableVSync    ), TEXT("Options"), CPF_Config );
	new(GetClass(),TEXT("ScreenSmoothing"), RF_Public)UBoolProperty ( CPP_PROPERTY(ScreenSmoothing ), TEXT("Options"), CPF_Config );
	new(GetClass(),TEXT("DetailBias"),      RF_Public)UFloatProperty( CPP_PROPERTY(DetailBias      ), TEXT("Options"), CPF_Config );
	new(GetClass(),TEXT("RefreshRate"),     RF_Public)UByteProperty ( CPP_PROPERTY(RefreshRate     ), TEXT("Options"), CPF_Config, RefreshRates );
}

//
// Validate configuration changes.
//
void UGlideRenderDevice::PostEditChange()
{
	RefreshRate = Clamp((INT)RefreshRate,0,GR_REFRESH_120Hz);
	DetailBias  = Clamp(DetailBias,-3.f,3.f);
}

//
// Shut down the Glide device.
//
void UGlideRenderDevice::Exit()
{
	debugf( NAME_Exit, TEXT("Shutting down Glide...") );

	// Shut down windowing.
	grSstWinClose();

	// Shut down each texture mapping unit.
	for( INT i=0; i<NumTmu; i++ )
		States[i].Exit();

	//warning: Don't call grGlideShutdown, since Glide's
	// support for reinitialization is broken.

	debugf( NAME_Exit, TEXT("Glide shut down") );
};

void UGlideRenderDevice::ShutdownAfterError()
{
	debugf( NAME_Exit, TEXT("UGlideRenderDevice::ShutdownAfterError") );
	grSstWinClose();
}

//
// Flush all cached data.
//
void UGlideRenderDevice::Flush( UBOOL AllowPrecache )
{

	for( INT i=0; i<NumTmu; i++ )
		States[i].Flush();
	grGammaCorrectionValue( 0.5 + 1.5*Viewport->GetOuterUClient()->Brightness );
}

/*-----------------------------------------------------------------------------
	UGlideRenderDevice Downloaders.
-----------------------------------------------------------------------------*/

//
// Download the texture and all of its mipmaps.
//
DWORD UGlideRenderDevice::FGlideTMU::DownloadTexture
(
	FTextureInfo&	Info,
	DWORD			Address,
	DWORD			GlideFlags,
	INT				iFirstMip,
	INT				iLastMip,
	GrTexInfo*		texinfo,
	QWORD			TestID,
	FCacheItem*&	Item,
	INT				USize,
	INT				VSize
)
{
	FMemMark Mark(GMem);
	INT MaxSize = USize * VSize;

	// Create cache entry.
	INT GlideSize = grTexCalcMemRequired( texinfo->smallLod, texinfo->largeLod, texinfo->aspectRatio, texinfo->format );
	if( Address==ALIGNMENT )
		Address = ALIGNMENT + (DWORD)Cache.Create( TestID, Item, GlideSize + 3*ALIGNMENT, ALIGNMENT );
	if( Info.Format==TEXF_RGBA7 )
	{
		// Source format is 32-bit RGB.
		Stats.Downloads16++;
		Stats.DownloadSize[ TT_LightMap ] += Item->GetSize();
		Item->SetExtra( TT_LightMap );
		clock(Stats.Download16Time);
		//!!handle mipmaps!

		// Convert 8-8-8-8 textures to 5-6-5.
		Info.CacheMaxColor();
		_WORD* RPtr  = RScale + PYR(Info.MaxColor->R/2);
		_WORD* GPtr  = GScale + PYR(Info.MaxColor->G/2);
		_WORD* BPtr  = BScale + PYR(Info.MaxColor->B/2);
		_WORD* Space = New<_WORD>(GMem,MaxSize), *Ptr=Space;
		for( INT c=0; c<VSize; c+=Info.VSize )
		{
			FRainbowPtr Src = Info.Mips[0]->DataPtr;
			for( INT i=0; i<Info.VClamp; i++ )
			{
				for( INT d=0; d<USize; d+=Info.USize )
				{
					FRainbowPtr InnerSrc=Src;
					for( INT j=0; j<Info.UClamp; j++ )
					{
						*Ptr++
						=	BPtr[InnerSrc.PtrBYTE[0]]
						+	GPtr[InnerSrc.PtrBYTE[1]]
						+	RPtr[InnerSrc.PtrBYTE[2]];
						InnerSrc.PtrDWORD++;
					}
					Ptr += Info.USize - Info.UClamp;
				}
				Src.PtrDWORD += Info.USize;
			}
			Ptr += (Info.VSize - Info.VClamp) * Info.USize;
		}
		grTexDownloadMipMapLevelPartial
		(
			tmu,
			Address,
			texinfo->largeLod,
			texinfo->largeLod,
			texinfo->aspectRatio,
			texinfo->format,
			GR_MIPMAPLEVELMASK_BOTH,
			Space,
			0,
			Info.VClamp-1
		);
		unclock(Stats.Download16Time);
	}
	else if( Info.Format==TEXF_P8 )
	{
		// Source format is 8-bit paletted.
		clock(Stats.Download8Time);

		// Make buffer for copying the texture to fix its aspect ratio.
		BYTE* Copy=NULL;
		if( USize!=Info.Mips[iFirstMip]->USize || VSize!=Info.Mips[iFirstMip]->VSize )
			Copy = New<BYTE>( GMem, MaxSize );

		// Make buffer for alpha conversion.
		FGlideColor* Alpha        = NULL;
		FGlideColor* AlphaPalette = NULL;
		if( GlideFlags & GF_RGBA4 )
		{
			AlphaPalette = New<FGlideColor>( GMem, NUM_PAL_COLORS );
			Alpha        = New<FGlideColor>( GMem, MaxSize        );
			for( INT i=0; i<NUM_PAL_COLORS; i++ )
			{
				AlphaPalette[i].Color4444.R = Info.Palette[i].R >> (8-4);
				AlphaPalette[i].Color4444.G = Info.Palette[i].G >> (8-4);
				AlphaPalette[i].Color4444.B = Info.Palette[i].B >> (8-4);
				AlphaPalette[i].Color4444.A = Info.Palette[i].A >> (8-4);
			}
			Stats.Downloads16++;
			Stats.DownloadSize[ TT_Masked ] += Item->GetSize();
			Item->SetExtra( TT_Masked );
		}
		else if( GlideFlags & GF_Alpha )
		{
			AlphaPalette = New<FGlideColor>( GMem, NUM_PAL_COLORS );
			Alpha        = New<FGlideColor>( GMem, MaxSize        );
			for( INT i=0; i<NUM_PAL_COLORS; i++ )
			{
				AlphaPalette[i].Color5551.R = Info.Palette[i].R >> (8-5);
				AlphaPalette[i].Color5551.G = Info.Palette[i].G >> (8-5);
				AlphaPalette[i].Color5551.B = Info.Palette[i].B >> (8-5);
				AlphaPalette[i].Color5551.A = 1;
			}
			AlphaPalette[0].Color5551.R = 0;
			AlphaPalette[0].Color5551.G = 0;
			AlphaPalette[0].Color5551.B = 0;
			AlphaPalette[0].Color5551.A = 0;
			Stats.Downloads16++;
			Stats.DownloadSize[ TT_Masked ] += Item->GetSize();
			Item->SetExtra( TT_Masked );
		}
		else if( GlideFlags & GF_NoPalette )
		{
			AlphaPalette = New<FGlideColor>( GMem, NUM_PAL_COLORS );
			Alpha        = New<FGlideColor>( GMem, MaxSize        );
			for( INT i=0; i<NUM_PAL_COLORS; i++ )
			{
				AlphaPalette[i].Color565.R = Info.Palette[i].R >> (8-5);
				AlphaPalette[i].Color565.G = Info.Palette[i].G >> (8-6);
				AlphaPalette[i].Color565.B = Info.Palette[i].B >> (8-5);
			}
			Stats.Downloads16++;
			Stats.DownloadSize[ TT_DetailMacro ] += Item->GetSize();
			Item->SetExtra( TT_DetailMacro );
		}
		else
		{
			Stats.Downloads8++;
			Stats.DownloadSize[ TT_Normal ] += Item->GetSize();
			Item->SetExtra( TT_Normal );
		}

		// Download the texture's mips.
		for( INT iMip=iFirstMip; iMip<=iLastMip; iMip++,MaxSize/=4 )
		{
			FMipmapBase* Mip = Info.Mips[iMip];
			BYTE*        Src = Mip->DataPtr;
			if( Copy )
			{
				BYTE* To = Copy;
				for( INT j=0; j<VSize; j+=Mip->VSize )
				{
					BYTE* From = Src;
					for( INT k=0; k<Mip->VSize; k++ )
					{
						for( INT l=0; l<USize; l+=Mip->USize )
						{
							appMemcpy( To, From, Mip->USize );
							To += Mip->USize;
						}
						From += Mip->USize;
					}
				}
				Src = Copy;
			}
			if( Alpha )
			{
				for( INT i=0; i<MaxSize; i++ )
					Alpha[i] = AlphaPalette[Src[i]];
				Src = (BYTE*)Alpha;
			}
			grTexDownloadMipMapLevel
			(
				tmu,
				Address,
				texinfo->largeLod + iMip - iFirstMip,
				texinfo->largeLod,
				texinfo->aspectRatio,
				texinfo->format,
				GR_MIPMAPLEVELMASK_BOTH,
				Src
			);
		}
		unclock(Stats.Download8Time);
	}
	else appErrorf( TEXT("Unsupported texture format %i"), Info.Format );
	Mark.Pop();
	return Address;
}

//
// Download the palette and all of its mipmaps.
//
void UGlideRenderDevice::FGlideTMU::DownloadPalette
(
	FTextureInfo&	TextureInfo,
	FColor			InMaxColor
)
{
	clock(Stats.PaletteTime);
	Stats.DownloadsPalette++;

	// Update state.
	PaletteCacheID   = TextureInfo.PaletteCacheID;
	PaletteMaxColor  = InMaxColor;
	QWORD NewCacheID = (TextureInfo.PaletteCacheID & ~(QWORD)255) + CID_GlidePal + ((QWORD)GET_COLOR_DWORD(InMaxColor)<<32);
	FCacheItem* Item = NULL;
	struct FGlidePal {BYTE B,G,R,A;}* GlidePal = (FGlidePal*)GCache.Get( NewCacheID, Item );


	if( !GlidePal || TextureInfo.bRealtimeChanged)
	{
		// Create it.
		if(!GlidePal) GlidePal     = (FGlidePal*)GCache.Create( NewCacheID, Item, 1024 );
		
		FLOAT ScaleR = 255.f / Max(PaletteMaxColor.R, (BYTE)1);
		FLOAT ScaleG = 255.f / Max(PaletteMaxColor.G, (BYTE)1);
		FLOAT ScaleB = 255.f / Max(PaletteMaxColor.B, (BYTE)1);
		for( INT i=0; i<NUM_PAL_COLORS; i++ )
		{
			GlidePal[i].R = appFloor(TextureInfo.Palette[i].R * ScaleR);
			GlidePal[i].G = appFloor(TextureInfo.Palette[i].G * ScaleG);
			GlidePal[i].B = appFloor(TextureInfo.Palette[i].B * ScaleB);
			GlidePal[i].A = 0;
		}
	} 


	// Send the palette.
	grTexDownloadTable( tmu, GR_TEXTABLE_PALETTE, GlidePal );
	Item->Unlock();

	unclock(Stats.PaletteTime);
}

/*-----------------------------------------------------------------------------
	UGlideRenderDevice Lock & Unlock.
-----------------------------------------------------------------------------*/

//
// Lock the Glide device.
//
//void UGlideRenderDevice::Lock( FPlane InFlashScale, FPlane InFlashFog, FPlane ScreenClear, DWORD InLockFlags, BYTE* HitData, INT* HitSize )
void UGlideRenderDevice::Lock( FColor InFogColor, float InFogDensity, BYTE InFogDistance, FPlane InFlashScale, FPlane InFlashFog, FPlane ScreenClear, DWORD InLockFlags, BYTE* HitData, INT* HitSize )
{
	check(!Locked++);

	// Remember parameters.
	LockFlags  = InLockFlags;
	FlashScale = InFlashScale;
	FlashFog   = InFlashFog;

	// NJS: Some foggy fun:
#if 0
	if(LockFlags&LOCKR_LightDiminish)
	{
		static unsigned char fogTable[GR_FOG_TABLE_SIZE];
		int i;
		
		// Check the density:
		if(InFogDensity!=FogDensity||InFogDistance!=FogDistance)
		{
			FogDensity=InFogDensity;
			FogDistance=InFogDistance;
	
			for(i=0;i<=FogDistance;i++)
				fogTable[i]=0;

			for(i=0;i<(GR_FOG_TABLE_SIZE-FogDistance);i++)
				fogTable[FogDistance+i]=((1.0-appExp((-FogDensity)*fogTableIndexToW(i)))*255.0);

			grFogTable(fogTable);
		}

		// Check the color:
		if(InFogColor!=FogColor)
		{
			FogColor=InFogColor;
			grFogColorValue((FogColor.B << 16) + (FogColor.G << 8) + FogColor.R);
		}
	} 
#endif
	// Clear the Z-buffer.
	grColorMask( (LockFlags & LOCKR_ClearScreen) ? 1 : 0, 0 );
	grBufferClear( FColor(ScreenClear).TrueColor(), 0, GR_WDEPTHVALUE_FARTHEST );
	grColorMask( 1, 0 );

	// Init stats.
	appMemzero( &Stats, sizeof(Stats) );
};



//
// Clear the Z-buffer.
//
void UGlideRenderDevice::ClearZ( FSceneNode* Frame )
{
	check(Locked);

	// Clear only the Z-buffer.
	grColorMask( FXFALSE, FXFALSE );
	grBufferClear( 0, 0, GR_WDEPTHVALUE_FARTHEST );
	grColorMask( FXTRUE, FXFALSE );
}

//
// Perform screenflashes.
//
void UGlideRenderDevice::EndFlash()
{
	if( FlashScale!=FPlane(.5f,.5f,.5f,0) || FlashFog!=FPlane(0,0,0,0) )
	{
		// Setup color.
		FColor GlideColor = FColor(FPlane(FlashFog.X,FlashFog.Y,FlashFog.Z,Min(FlashScale.X*2.f,1.f)));
		grConstantColorValue( *(GrColor_t*)&GlideColor );

		// Set up verts.
		GrVertex Verts[4];
		Verts[0].x=0;               Verts[0].y=0;               Verts[0].oow=0.5f;
		Verts[1].x=0;               Verts[1].y=Viewport->SizeY; Verts[1].oow=0.5f;
		Verts[2].x=Viewport->SizeX; Verts[2].y=Viewport->SizeY; Verts[2].oow=0.5f;
		Verts[3].x=Viewport->SizeX; Verts[3].y=0;               Verts[3].oow=0.5f;

		// Draw it.
		sgrDepthMask( 0 );
		grDepthBufferFunction( GR_CMP_ALWAYS );
		sguColorCombineFunction( GR_COLORCOMBINE_CCRGB );
		guAlphaSource( GR_ALPHASOURCE_CC_ALPHA );
		sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_SRC_ALPHA, GR_BLEND_ZERO, GR_BLEND_ZERO );
		grDrawPlanarPolygonVertexList( 4, Verts );
		sgrDepthMask( 1 );
		grDepthBufferFunction( GR_CMP_LEQUAL );
	}
}

//
// Unlock the Glide rendering device.
//
void UGlideRenderDevice::Unlock( UBOOL Blit )
{
	check(Locked--);

	// Tick each of the states.
	for( INT i=0; i<NumTmu; i++ )
		States[i].Tick();

	// Blit it.
	if( Blit )
	{
		// Flip pages.
		if( Viewport->IsFullscreen() || hwconfig.SSTs[0].type==GR_SSTTYPE_SST96 )
		{
			// Throttle if we are rendering much faster than the refresh rate.
			DOUBLE Seconds = appSeconds();
			while( grBufferNumPending()>0 && appSeconds()-Seconds<0.1 );
			grBufferSwap( !DisableVSync );
		}
		else
		{
			// Emulated screen blit. !!experimential
			grBufferSwap( 1 );
			GrLfbInfo_t lfbInfo;
			appMemzero( &lfbInfo, sizeof(lfbInfo) );
			lfbInfo.size = sizeof( GrLfbInfo_t );
			grLfbLock
			(
				GR_LFB_READ_ONLY,
				GR_BUFFER_FRONTBUFFER,
				GR_LFBWRITEMODE_ANY,
				GR_ORIGIN_UPPER_LEFT,
				FXFALSE,
				&lfbInfo
			);
			BYTE* Src  = (BYTE*)lfbInfo.lfbPtr;
			BYTE* Dest = (BYTE*)Viewport->ScreenPointer;
			for( INT y=0; y<Viewport->SizeY; y++ )
			{
				appMemcpy( Dest, Src, Viewport->SizeX * Viewport->ColorBytes );
				Dest += Viewport->Stride * Viewport->ColorBytes;
				Src  += lfbInfo.strideInBytes;
			}
			grLfbUnlock( GR_LFB_READ_ONLY, GR_BUFFER_FRONTBUFFER );
		}
	}
};

/*-----------------------------------------------------------------------------
	UGlideRenderDevice texture vector polygon drawer.
-----------------------------------------------------------------------------*/
EXECVAR(float,	FogBottom,		0);
EXECVAR(float,	FogTop,			100);
EXECVAR(int,	Darken,			255);
EXECVAR(UBOOL,	bGouraud,		false);
EXECVAR(float,	bGouraudRed,	255);
EXECVAR(float,	bGouraudGreen,	255);
EXECVAR(float,	bGouraudBlue,	255);
EXECVAR(float,	bGouraudAlpha,  255);

//
// Draw a textured polygon using surface vectors.
//
#include <CannibalUnr.h>

float NearZ=200.f;


//void UGlideRenderDevice::DrawComplexSurface( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet, TArray<FTransSample> lightingInfo )
void UGlideRenderDevice::DrawComplexSurface( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet)
{
	FColor FinalColor( 255, 255, 255, 0 );
	//FLOAT NearZ        = 200.0;
	INT ModulateThings = (Surface.Texture!=NULL) + (Surface.LightMap!=NULL) + (Surface.MacroTexture!=NULL);
	INT Tmu            = 0;


	clock(Stats.PolyVTime);
	FMemMark Mark(GMem);
	Stats.Surfs++;

	UBOOL bHeatVision = Frame->Viewport->Actor->CameraStyle == PCS_HeatVision; // CDH
	UBOOL bNightVision = Frame->Viewport->Actor->CameraStyle == PCS_NightVision; // CDH
	
	// Mutually exclusive effects.
	if( Surface.DetailTexture && ( Surface.FogMap /*|| Surface.PolyFlags &PF_HeightFog*/ ))
		Surface.DetailTexture = NULL;

	// Set up all poly vertices.
	for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
	{
		// Set up vertices.
		Poly->User = New<GrVertex>(GMem,Poly->NumPts);
		for( INT i=0; i<Poly->NumPts; i++ )
		{
			VERTS(Poly)[i].MASTER_S = Facet.MapCoords.XAxis | (*(FVector*)Poly->Pts[i] - Facet.MapCoords.Origin);
			VERTS(Poly)[i].MASTER_T = Facet.MapCoords.YAxis | (*(FVector*)Poly->Pts[i] - Facet.MapCoords.Origin);
			VERTS(Poly)[i].x        = Mask(Poly->Pts[i]->ScreenX + Frame->XB);
			VERTS(Poly)[i].y	    = Mask(Poly->Pts[i]->ScreenY + Frame->YB);
			VERTS(Poly)[i].z	    = Poly->Pts[i]->Point.Z;
			VERTS(Poly)[i].oow      = Poly->Pts[i]->RZ * Frame->RProj.Z;
		}
	}

	// NJS: Translucency should not be depth masked, nevermind, yes it should.
	//if( Surface.PolyFlags & (PF_Translucent|PF_Modulated) )
	//	sgrDepthMask( 0 );

	// Draw texture and lightmap.
	DWORD MainGlideFlags
	=	((Surface.PolyFlags & PF_Masked) ? GF_Alpha : 0)
	|	((Surface.PolyFlags & (PF_Modulated|PF_Translucent))||Surface.Texture->bRealtime ? GF_NoScale : 0);
	if
	(	(NumTmu==1)
	||	(!Surface.LightMap)
	||	(Surface.FogMap && (Surface.PolyFlags & PF_Masked)) )
	{
		if( ModulateThings > 1 )
			sguColorCombineFunction( GR_COLORCOMBINE_DECAL_TEXTURE );

		// Draw normal texture.
		if( Surface.Texture )
		{
			// Setup texture.
			FColor OrigFinalColor = FinalColor;
			if (bHeatVision)
			{
				FinalColor.R = 7.5f;
				FinalColor.G = 0.f;
				FinalColor.B = 38.f;
			} else if (bNightVision) {
				FinalColor.R = 0.f;
				FinalColor.G = 128.f;
				FinalColor.B = 0.f;
			}

			SetBlending( Surface.PolyFlags );
			States[GR_TMU0].SetTexture( *Surface.Texture, MainGlideFlags, 0.0 );
			UpdateModulation( FinalColor, States[GR_TMU0].MaxColor, ModulateThings ); 
			for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
			{
				States[GR_TMU0].CopyVerts( Poly );
				grDrawPolygonVertexList( Poly->NumPts, VERTS(Poly) );
				Stats.Polys++;
			}
			ResetBlending( Surface.PolyFlags );

			if (bHeatVision || bNightVision)
				FinalColor = OrigFinalColor;
		}

		SetFog( Surface.PolyFlags ); // NJS

		// Handle depth buffering the appropriate areas of masked textures.
		if( Surface.PolyFlags & PF_Masked )
			grDepthBufferFunction( GR_CMP_EQUAL );

		// Modulation blend the rest of the textures.
		if( ModulateThings>0 || (Surface.DetailTexture && DetailTextures) )
			sgrAlphaBlendFunction( GR_BLEND_DST_COLOR, GR_BLEND_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO );

		// Light map.
		if( Surface.LightMap )
		{
			// Set the light map.
			States[GR_TMU0].SetTexture( *Surface.LightMap, GF_NoPalette, -0.5 );
			UpdateModulation( FinalColor, States[GR_TMU0].MaxColor, ModulateThings ); 
			for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
			{
				States[GR_TMU0].CopyVerts( Poly );
				grDrawPolygonVertexList( Poly->NumPts, VERTS(Poly) );
			}
		}
	}
	else
	{
		// Texture.
		States[GR_TMU1].SetTexture( *Surface.Texture, MainGlideFlags, 0.0 );
		for( Poly=Facet.Polys; Poly; Poly=Poly->Next ) 
			States[GR_TMU1].CopyVerts( Poly );

		// Lightmap.
		States[GR_TMU0].SetTexture( *Surface.LightMap, 0, -0.5 );
		for( Poly=Facet.Polys; Poly; Poly=Poly->Next ) 
			States[GR_TMU0].CopyVerts( Poly );

		// Adjust color.
		FinalColor.R = Min(appRound(1./255.f*States[0].MaxColor.R*States[1].MaxColor.R),255);
		FinalColor.G = Min(appRound(1./255.f*States[0].MaxColor.G*States[1].MaxColor.G),255);
		FinalColor.B = Min(appRound(1./255.f*States[0].MaxColor.B*States[1].MaxColor.B),255);

		FColor OrigFinalColor = FinalColor;
		if (bHeatVision)
		{
			FinalColor.R = 7.5f;
			FinalColor.G = 0.f;
			FinalColor.B = 38.0f;
		} else if (bNightVision) {
			FinalColor.R = 0.f;
			FinalColor.G = 128.f;
			FinalColor.B = 32.f;
		}

		// Draw with multitexture.
		SetBlending( Surface.PolyFlags );
#if 0
		if(bGouraud)
		{
			int TotalCount=0;
			for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
			{
				for( INT i=0; i<Poly->NumPts; i++ )
				{
					VERTS(Poly)[i].r=128+Mask(lightingInfo(TotalCount).Light.X*128.0f);//Mask(bGouraudRed); 
					VERTS(Poly)[i].g=128+Mask(lightingInfo(TotalCount).Light.Y*128.0f);//Mask(bGouraudGreen);
					VERTS(Poly)[i].b=128+Mask(lightingInfo(TotalCount).Light.Z*128.0f);//Mask(bGouraudBlue); 
					//VERTS(Poly)[i].a=Mask(bGouraudAlpha); //128;
					
					TotalCount++;
				}
			}

			sgrColorCombine( GR_COMBINE_FUNCTION_SCALE_OTHER, 
						     GR_COMBINE_FACTOR_LOCAL, 
							 GR_COMBINE_LOCAL_ITERATED, 
							 GR_COMBINE_OTHER_TEXTURE, 
							 FXFALSE );

			grHints( GR_HINT_STWHINT, GR_STWHINT_ST_DIFF_TMU1 );
			grTexCombine ( GR_TMU0,
				GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_LOCAL,
				GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_LOCAL,
				FXFALSE, FXFALSE );
			grConstantColorValue ( *(GrColor_t*)&FinalColor );

			for( Poly = Facet.Polys; Poly; Poly = Poly->Next ) 
				grDrawPolygonVertexList( Poly->NumPts, VERTS(Poly) );
		} else
#endif
		{
			sgrColorCombine( GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_LOCAL, GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_TEXTURE, FXFALSE );

			grHints( GR_HINT_STWHINT, GR_STWHINT_ST_DIFF_TMU1 );
			grTexCombine ( GR_TMU0,
				GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_LOCAL,
				GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_LOCAL,
				FXFALSE, FXFALSE );
			grConstantColorValue ( *(GrColor_t*)&FinalColor );

			for( Poly = Facet.Polys; Poly; Poly = Poly->Next ) 
				grDrawPolygonVertexList( Poly->NumPts, VERTS(Poly) );

		}

		ResetBlending ( Surface.PolyFlags );

		if (bHeatVision || bNightVision)
			FinalColor = OrigFinalColor;

		// Clean up.
		grTexCombine( GR_TMU0, GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_ONE, GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_ONE, FXFALSE, FXFALSE );
		States[0].SetBogusTexture();
		Tmu = 1;
	}
	grAlphaBlendFunction( GR_BLEND_DST_COLOR, GR_BLEND_SRC_COLOR, GR_BLEND_ONE, GR_BLEND_ZERO );

	// Macrotexture.
	if( Surface.MacroTexture )
	{
		// Set the macrotexture.
		States[Tmu].SetTexture( *Surface.MacroTexture, GF_NoPalette, 0.0 );
		UpdateModulation( FinalColor, States[Tmu].MaxColor, ModulateThings ); 
		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			States[Tmu].CopyVerts( Poly );
			grDrawPolygonVertexList( Poly->NumPts, VERTS(Poly));
		}
	}

	// Draw detail texture overlaid, in a separate pass.
	if( Surface.DetailTexture && DetailTextures )
	{
		States[Tmu].SetTexture( *Surface.DetailTexture, GF_NoPalette | GF_NoScale, 0.0 );
		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			UBOOL IsNear[32], CountNear=0;
			for( INT i=0; i<Poly->NumPts; i++ )
			{
				IsNear[i] = VERTS(Poly)[i].z<NearZ;
				CountNear += IsNear[i];
			}
			if( CountNear )
			{
				INT NumNear=0;
				GrVertex Near[32];

				States[Tmu].SetTexture( *Surface.DetailTexture, GF_NoPalette | GF_NoScale, 0.0 );
				for( INT i=0,j=Poly->NumPts-1; i<Poly->NumPts; j=i++ )
				{
					if( IsNear[i] ^ IsNear[j] )
					{
						FLOAT G           = (VERTS(Poly)[i].z - NearZ) / (VERTS(Poly)[i].z - VERTS(Poly)[j].z);
						FLOAT F           = 1.0 - G;
						Near[NumNear].z   = NearZ;
						Near[NumNear].oow = 1.0 / NearZ;
						Near[NumNear].x   = Mask( (F*Poly->Pts[i]->ScreenX*VERTS(Poly)[i].z + G*Poly->Pts[j]->ScreenX*VERTS(Poly)[j].z) * Near[NumNear].oow + Frame->XB);
						Near[NumNear].y   = Mask( (F*Poly->Pts[i]->ScreenY*VERTS(Poly)[i].z + G*Poly->Pts[j]->ScreenY*VERTS(Poly)[j].z) * Near[NumNear].oow + Frame->YB);
						Near[NumNear].tmuvtx[Tmu].sow = Near[NumNear].oow*( F*VERTS(Poly)[i].MASTER_S + G*VERTS(Poly)[j].MASTER_S - Surface.DetailTexture->Pan.X ) * States[Tmu].UScale;
						Near[NumNear].tmuvtx[Tmu].tow = Near[NumNear].oow*( F*VERTS(Poly)[i].MASTER_T + G*VERTS(Poly)[j].MASTER_T - Surface.DetailTexture->Pan.Y ) * States[Tmu].VScale;
						NumNear++;
					}
					if( IsNear[i] )
					{
						Near[NumNear].z   = VERTS(Poly)[i].z;
						Near[NumNear].oow = VERTS(Poly)[i].oow;
						Near[NumNear].x   = VERTS(Poly)[i].x;
						Near[NumNear].y   = VERTS(Poly)[i].y;
						Near[NumNear].tmuvtx[Tmu].sow = Near[NumNear].oow*( VERTS(Poly)[i].MASTER_S - Surface.DetailTexture->Pan.X ) * States[Tmu].UScale;
						Near[NumNear].tmuvtx[Tmu].tow = Near[NumNear].oow*( VERTS(Poly)[i].MASTER_T - Surface.DetailTexture->Pan.Y ) * States[Tmu].VScale;
						NumNear++;
					}
				}
				for( i=0; i<NumNear; i++ )
					Near[i].a = Min( 100.f * (NearZ / Near[i].z - 1), 255.f );
				grDepthBiasLevel(0);
				grAlphaCombine( GR_COMBINE_FUNCTION_LOCAL_ALPHA, GR_COMBINE_FACTOR_ONE, GR_COMBINE_LOCAL_ITERATED, GR_COMBINE_OTHER_NONE, FXFALSE );
				grConstantColorValue( 0x7f7f7f );
				sgrColorCombine( GR_COMBINE_FUNCTION_BLEND, GR_COMBINE_FACTOR_LOCAL_ALPHA, GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_TEXTURE, FXFALSE );
				grDrawPolygonVertexList( NumNear, Near );
				grDepthBiasLevel(16);
			}
		}
	}

	// Fog map.
	if( Surface.FogMap )
	{
		States[Tmu].SetTexture( *Surface.FogMap, GF_NoPalette, -0.5 );
		FinalColor.R = States[Tmu].MaxColor.R;
		FinalColor.G = States[Tmu].MaxColor.G;
		FinalColor.B = States[Tmu].MaxColor.B;
		grConstantColorValue( *(GrColor_t*)&FinalColor );
		sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ONE_MINUS_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO );
		sgrColorCombine( GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_LOCAL, GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_TEXTURE, FXFALSE );
		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			States[Tmu].CopyVerts( Poly );
			grDrawPolygonVertexList( Poly->NumPts, VERTS(Poly) );
		}
	}
	// NJS: Handle height fog:
	if(0/*Surface.PolyFlags2 & PF_Darken*/)
	{
		//States[Tmu].SetTexture( *Surface.FogMap, GF_NoPalette, -0.5 );
		// NJS: Red fogoliciousness: - TW: Nick, You are sick! - NJS: I'M NOT INSANE!
		// In reality, I would want to set non-fog bounding vertices to max, max, max, and fog bounding vertices to 1,0,0
		
		// Set heightfog color:
		FinalColor.R = States[Tmu].MaxColor.R;
		FinalColor.G = States[Tmu].MaxColor.G;
		FinalColor.B = States[Tmu].MaxColor.B;
		FinalColor.A = 0;
		
		grConstantColorValue( *(GrColor_t*)&FinalColor );

		// Set colorcombine for a simple flatshaded polygon:
		grColorCombine( GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_NONE, GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_NONE, FXFALSE );

		grAlphaCombine(GR_COMBINE_FUNCTION_LOCAL,GR_COMBINE_FACTOR_ONE_MINUS_LOCAL,GR_COMBINE_LOCAL_ITERATED,GR_COMBINE_OTHER_NONE,FXFALSE);
		grAlphaBlendFunction( GR_BLEND_SRC_ALPHA, GR_BLEND_ONE_MINUS_SRC_ALPHA, GR_BLEND_ZERO, GR_BLEND_ZERO );
	
		Darken++;
		//grDepthBufferFunction( GR_CMP_EQUAL);
		for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
		{
			for(int index=0;index<Poly->NumPts;index++)
			{
				//float currentY=((FVector)Poly->Pts[index]->Point + Facet.MapCoords.Origin).Y;
				//FLOAT currentY = Facet.MapCoords.YAxis | Poly->Pts[index]->Point;
				//VERTS(Poly)[index].a=((int)(currentY*0xFF))&0xFF; 
				//continue;
				
				//if(currentY<FogBottom
				// ||currentY>FogTop)
				//{
				//	VERTS(Poly)[index].a=0xFF; 
				//} else
				//{
					
				//	VERTS(Poly)[index].a=0x00;

				//	float alpha=(currentY-FogBottom)/(FogTop-FogBottom);
				//	VERTS(Poly)[index].a=0xFF-(int)(alpha*0xFF);
				//}
				//VERTS(Poly)[index].r=Darken;
				//VERTS(Poly)[index].g=Darken;
				//VERTS(Poly)[index].b=Darken;
				VERTS(Poly)[index].a=Darken;
			}

			States[Tmu].CopyVerts( Poly );
			grDrawPolygonVertexList( Poly->NumPts, VERTS(Poly) );
		}
		
		//FinalColor.R = 255;
		//FinalColor.G = 255; //States[Tmu].MaxColor.G;
		//FinalColor.B = 255; //States[Tmu].MaxColor.B;
		//grConstantColorValue( *(GrColor_t*)&FinalColor );
 
		//grDepthBufferFunction( GR_CMP_LEQUAL );

		//sgrColorCombine( GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_ONE, GR_COMBINE_LOCAL_NONE, GR_COMBINE_OTHER_TEXTURE, FXFALSE );
		//grTexCombine( GR_TMU0, GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_NONE, GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_NONE, FXFALSE, FXFALSE );
	}

	// Cleanup.
	if( NumTmu > 1 )
	{
		sgrColorCombine( GR_COMBINE_FUNCTION_SCALE_OTHER, GR_COMBINE_FACTOR_ONE, GR_COMBINE_LOCAL_NONE, GR_COMBINE_OTHER_TEXTURE, FXFALSE );
		grTexCombine( GR_TMU0, GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_NONE, GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_NONE, FXFALSE, FXFALSE );
		States[1].SetBogusTexture ();
		grHints( GR_HINT_STWHINT, 0 );
	}

	// NJS: Translucency should not be depth masked
	//if( Surface.PolyFlags & (PF_Translucent|PF_Modulated) )
	//	sgrDepthMask( 1 );

	if( Surface.PolyFlags & PF_Masked ) 
		grDepthBufferFunction( GR_CMP_LEQUAL );

	ResetFog( Surface.PolyFlags ); // NJS


	Mark.Pop();
	unclock( Stats.PolyVTime );
}

/*-----------------------------------------------------------------------------
	UGlideRenderDevice texture coordinates polygon drawer.
-----------------------------------------------------------------------------*/

//
// Draw a polygon with texture coordinates.
//
void UGlideRenderDevice::DrawGouraudPolygon
(
	FSceneNode*		Frame,
	FTextureInfo&	Texture,
	FTransTexture**	Pts,
	INT				NumPts,
	DWORD			PolyFlags,
	FSpanBuffer*	Span
)
{
	clock(Stats.PolyCTime);
	Stats.Tris++;

	// Optimize flags.
	FColor Saved = Texture.Palette[0];
	if( (PolyFlags&PF_Masked) && (PolyFlags&PF_Translucent) )
		{PolyFlags &= ~PF_Masked; Texture.Palette[0]=FColor(0,0,0,255);}

	// Set up verts.
	static GrVertex Verts[32];
	INT Tmu = 0;
	States[Tmu].SetTexture( Texture, GF_NoScale | ((PolyFlags&PF_Masked)?GF_Alpha:0), 0.0 );
	for( INT i=0; i<NumPts; i++ )
	{
		Verts[i].x	 			= Mask(Pts[i]->ScreenX + Frame->XB);
		Verts[i].y	 			= Mask(Pts[i]->ScreenY + Frame->YB);
		Verts[i].r				= Pts[i]->Light.X*255.f;
		Verts[i].g				= Pts[i]->Light.Y*255.f;
		Verts[i].b				= Pts[i]->Light.Z*255.f;
		Verts[i].oow 			= Pts[i]->RZ * Frame->RProj.Z;
		Verts[i].tmuvtx[0].sow	= Verts[i].oow * Pts[i]->U * States[Tmu].UScale;
		Verts[i].tmuvtx[0].tow	= Verts[i].oow * Pts[i]->V * States[Tmu].VScale;
	}

	// Draw it.
	SetBlending( PolyFlags );

	sguColorCombineFunction( (PolyFlags & PF_Modulated) ? GR_COLORCOMBINE_DECAL_TEXTURE : GR_COLORCOMBINE_TEXTURE_TIMES_ITRGB );

	// CDH... decals
	if (PolyFlags & PF_MeshUVClamp)
		grTexClampMode(Tmu, GR_TEXTURECLAMP_CLAMP, GR_TEXTURECLAMP_CLAMP);
	// ...CDH

	grDrawPolygonVertexList( NumPts, Verts );

	// CDH... decals
	if (PolyFlags & PF_MeshUVClamp)
		grTexClampMode(Tmu, GR_TEXTURECLAMP_WRAP, GR_TEXTURECLAMP_WRAP);
	// ...CDH

	ResetBlending( PolyFlags );

	// Fog.
	if( (PolyFlags & (PF_RenderFog|PF_Translucent|PF_Modulated))==PF_RenderFog )
	{
		for( INT i=0; i<NumPts; i++ )
		{
			Verts[i].r = Pts[i]->Fog.X*255.f;
			Verts[i].g = Pts[i]->Fog.Y*255.f;
			Verts[i].b = Pts[i]->Fog.Z*255.f;
		}
		sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ONE_MINUS_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO );
		sguColorCombineFunction( GR_COLORCOMBINE_ITRGB );
		grDrawPolygonVertexList( NumPts, Verts );
		sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ZERO, GR_BLEND_ZERO, GR_BLEND_ZERO );
	}

	// Unlock.
	Texture.Palette[0] = Saved;
	unclock(Stats.PolyCTime);
}

/*-----------------------------------------------------------------------------
	Textured tiles.
-----------------------------------------------------------------------------*/
__forceinline void RotateAboutOrigin2D(float originX, float originY, float &x, float &y, float theta)
{
	float xTick, yTick;

	x-=originX; y-=originY;
	xTick = ((GMath.CosFloat(theta)*x) - (GMath.SinFloat(theta)*y)); 
	yTick = ((GMath.SinFloat(theta)*x) + (GMath.CosFloat(theta)*y));

	x=xTick+originX; y=yTick+originY;
}

void UGlideRenderDevice::DrawTile(	FSceneNode* Frame, 
									FTextureInfo& Texture, 
									FLOAT X, FLOAT Y, 
									FLOAT XL, FLOAT YL, 
									FLOAT U, FLOAT V, 
									FLOAT UL, FLOAT VL, 
									class FSpanBuffer* Span, 
									FLOAT Z, 
									FPlane Color, FPlane Fog, 
									DWORD PolyFlags, 
									UBOOL bilinear, 
									FLOAT alpha,
									FLOAT rot,
									FLOAT rotationOffsetX,
									FLOAT rotationOffsetY,
									UBOOL MirrorHoriz,
									UBOOL MirrorVert)
{
	Stats.Tris++;
	UBOOL UsingAlpha=false;

	// Optimize flags.
	FColor Saved = Texture.Palette[0];
	if( (PolyFlags&(PF_Masked|PF_Translucent))==(PF_Masked|PF_Translucent) )
		{PolyFlags &= ~PF_Masked; Texture.Palette[0]=FColor(0,0,0,255);}
	if( Texture.Palette[128].A!=255 && !(PolyFlags&PF_Translucent) )
		PolyFlags |= PF_Highlighted;


	// Setup color.
	FColor GlideColor = FColor(Color);
	grConstantColorValue( *(GrColor_t*)&GlideColor );

	// Set up verts.
	GrVertex Verts[8];
	INT Tmu = 0;
	States[Tmu].SetTexture( Texture, GF_NoScale | ((PolyFlags&PF_Masked) ? GF_Alpha : 0), 0.0 );

	FLOAT RZ    = 1.0 / Z; 
	X          += Frame->XB + 0.25;
	Y          += Frame->YB + 0.25;
	if (MirrorHoriz && !MirrorVert)
	{
		Verts[0].x=Mask(X   ); Verts[0].y=Mask(Y   ); Verts[0].oow=RZ; Verts[0].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[0].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;
		Verts[1].x=Mask(X   ); Verts[1].y=Mask(Y+YL); Verts[1].oow=RZ; Verts[1].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[1].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
		Verts[2].x=Mask(X+XL); Verts[2].y=Mask(Y+YL); Verts[2].oow=RZ; Verts[2].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[2].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
		Verts[3].x=Mask(X+XL); Verts[3].y=Mask(Y   ); Verts[3].oow=RZ; Verts[3].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[3].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;
	} else if (MirrorVert && !MirrorHoriz) {
		Verts[0].x=Mask(X   ); Verts[0].y=Mask(Y   ); Verts[0].oow=RZ; Verts[0].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[0].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
		Verts[1].x=Mask(X   ); Verts[1].y=Mask(Y+YL); Verts[1].oow=RZ; Verts[1].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[1].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;
		Verts[2].x=Mask(X+XL); Verts[2].y=Mask(Y+YL); Verts[2].oow=RZ; Verts[2].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[2].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;
		Verts[3].x=Mask(X+XL); Verts[3].y=Mask(Y   ); Verts[3].oow=RZ; Verts[3].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[3].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
	} else if (MirrorHoriz && MirrorVert) {
		Verts[0].x=Mask(X   ); Verts[0].y=Mask(Y   ); Verts[0].oow=RZ; Verts[0].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[0].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
		Verts[1].x=Mask(X   ); Verts[1].y=Mask(Y+YL); Verts[1].oow=RZ; Verts[1].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[1].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;
		Verts[2].x=Mask(X+XL); Verts[2].y=Mask(Y+YL); Verts[2].oow=RZ; Verts[2].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[2].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;
		Verts[3].x=Mask(X+XL); Verts[3].y=Mask(Y   ); Verts[3].oow=RZ; Verts[3].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[3].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
	} else {
		Verts[0].x=Mask(X   ); Verts[0].y=Mask(Y   ); Verts[0].oow=RZ; Verts[0].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[0].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;
		Verts[1].x=Mask(X   ); Verts[1].y=Mask(Y+YL); Verts[1].oow=RZ; Verts[1].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[1].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
		Verts[2].x=Mask(X+XL); Verts[2].y=Mask(Y+YL); Verts[2].oow=RZ; Verts[2].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[2].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
		Verts[3].x=Mask(X+XL); Verts[3].y=Mask(Y   ); Verts[3].oow=RZ; Verts[3].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[3].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;
	}

	// NJS: Do I have rotation?
	if(rot)	
	{
		//float rotationOffsetX=0, rotationOffsetY=0; 
		float originX=(Verts[0].x+XL/2.0)+rotationOffsetX, originY=(Verts[0].y+YL/2.0)+rotationOffsetY;

		for(int index=0;index<4;index++)
		{	float x=Verts[index].x,
				  y=Verts[index].y;

			RotateAboutOrigin2D(originX,originY,x,y, rot);
			Verts[index].x=Mask(x);
			Verts[index].y=Mask(y);
		}
	}
	// Draw it.
	SetBlending( PolyFlags );

	sguColorCombineFunction( (PolyFlags & PF_Modulated) ? GR_COLORCOMBINE_DECAL_TEXTURE : GR_COLORCOMBINE_TEXTURE_TIMES_CCRGB );

	if(bilinear)	// NJS: Bileniar filtering
		grTexFilterMode(GR_TMU0,GR_TEXTUREFILTER_BILINEAR,GR_TEXTUREFILTER_BILINEAR);

	// NJS: real alpha effects:
	if(alpha!=1.0)
	{
		// Clamp Alpha:
		if(alpha>1) alpha=1;
		else if(alpha<0) alpha=0;
		UsingAlpha=true;

		sgrColorCombine(GR_COMBINE_FUNCTION_SCALE_OTHER, 
						GR_COMBINE_FACTOR_LOCAL,
		                GR_COMBINE_LOCAL_CONSTANT, 
						GR_COMBINE_OTHER_TEXTURE, 
						FXFALSE
		);
		
		grAlphaCombine(//	GR_COMBINE_FUNCTION_SCALE_OTHER,	
						GR_COMBINE_FUNCTION_SCALE_OTHER_MINUS_LOCAL, 
		  				GR_COMBINE_FACTOR_ONE, 
						GR_COMBINE_LOCAL_ITERATED, 
						GR_COMBINE_OTHER_TEXTURE, 
						FXFALSE
		);

		/* Original: */
		//sgrAlphaBlendFunction(GR_BLEND_SRC_ALPHA, 
		//						GR_BLEND_ONE_MINUS_SRC_ALPHA, 
		//						GR_BLEND_ONE, 
		//						GR_BLEND_ZERO
		//);


		{
			/* VERY MUCH HAS THE CIGAR: */
			sgrAlphaBlendFunction( GR_BLEND_SRC_ALPHA, GR_BLEND_ONE, GR_BLEND_ZERO , GR_BLEND_ZERO );
			
			//sgrAlphaBlendFunction( GR_BLEND_ALPHA_SATURATE, GR_BLEND_ONE, GR_BLEND_ALPHA_SATURATE, GR_BLEND_ZERO );


		}

		//if(PolyFlags&PF_Masked)
		{
			sgrAlphaTestFunction(GR_CMP_GREATER); 
			grAlphaTestReferenceValue(0);
		}

		for(int i=0;i<4;i++)
		{
			//	TLW: Don't want to zero out colors
			//Verts[i].r=Verts[i].g=Verts[i].b=0;
			Verts[i].a=Mask(255-(alpha*255.0)); 
		}
	}
	
	grDrawPlanarPolygonVertexList( 4, Verts );

	if(bilinear)
		grTexFilterMode(GR_TMU0,GR_TEXTUREFILTER_POINT_SAMPLED,GR_TEXTUREFILTER_POINT_SAMPLED);
		
	if(UsingAlpha)
	{
		sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ZERO, GR_BLEND_ZERO, GR_BLEND_ZERO );
		sgrAlphaTestFunction( GR_CMP_ALWAYS );
	}

	ResetBlending( PolyFlags );

	// Fog.
	if( PolyFlags & PF_RenderFog )
	{
		if( PolyFlags & (PF_Translucent|PF_Modulated) )
			sgrDepthMask( 0 );
		GlideColor = FColor(Fog);
		grConstantColorValue( *(GrColor_t*)&GlideColor );
		sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ONE_MINUS_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO );
		sguColorCombineFunction( GR_COLORCOMBINE_TEXTURE_TIMES_CCRGB );
		grDrawPlanarPolygonVertexList( 4, Verts );
		sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ZERO, GR_BLEND_ZERO, GR_BLEND_ZERO );
		if( PolyFlags & (PF_Translucent|PF_Modulated) )
			sgrDepthMask( 1 );
	}

	// Done.
	Texture.Palette[0] = Saved;
}
#if 0
void UGlideRenderDevice::dnDrawParticles( ASoftParticleSystem *System, FSceneNode* Frame, FParticle *Particles, INT ParticleCount, DWORD PolyFlags, UBOOL VariableAlpha,FLOAT SystemAlphaScale)
{
	INT	  X1, Y1, X2, Y2;
	FLOAT ScreenX, ScreenY, Z, Persp;

	// Setup color.
	BOOL   BlendingModeSet=0;
	FPlane Color = FPlane(1,1,1,0);
	FColor GlideColor = FColor(Color);
	grConstantColorValue( *(GrColor_t*)&GlideColor );

	// Texture Management:
	UTexture *CurrentTexture=NULL;
	FTextureInfo CurrentTextureInfo;
	FColor Saved;
	const INT Tmu = 0;

	FLOAT UF=0.f, VF=0.f;
			
	for(INT i=0;i<ParticleCount;i++)
	{

		if(!Particles[i].Texture) continue;		// Ignore untextured particles

		// Manage the texture swaps:
		if(Particles[i].Texture!=CurrentTexture)
		{
			// If I already have a texture:
			if(CurrentTexture)
			{
				CurrentTextureInfo.Palette[0] = Saved;
				CurrentTexture->Unlock( CurrentTextureInfo );
				CurrentTexture=NULL;
			}

			CurrentTexture=Particles[i].Texture;
			CurrentTexture->Lock( CurrentTextureInfo, Frame->Viewport->CurrentTime, -1, Frame->Viewport->RenDev );
			Saved= CurrentTextureInfo.Palette[0];
			UF=CurrentTextureInfo.UScale*CurrentTextureInfo.USize/CurrentTexture->USize; 
			VF=CurrentTextureInfo.VScale*CurrentTextureInfo.VSize/CurrentTexture->VSize; 
			States[Tmu].SetTexture( CurrentTextureInfo, GF_NoScale|((PolyFlags&PF_Masked) ? GF_Alpha : 0), 0.0 );

			if(!BlendingModeSet)
			{
				BlendingModeSet=1;
				if((PolyFlags&(PF_Masked|PF_Translucent))==(PF_Masked|PF_Translucent) )
					{PolyFlags &= ~PF_Masked; CurrentTextureInfo.Palette[0]=FColor(0,0,0,255);}

				if( CurrentTextureInfo.Palette[128].A!=255 && !(PolyFlags&PF_Translucent) )
					PolyFlags |= PF_Highlighted;


				SetBlending( PolyFlags );
				sguColorCombineFunction( (PolyFlags & PF_Modulated) ? GR_COLORCOMBINE_DECAL_TEXTURE : GR_COLORCOMBINE_TEXTURE_TIMES_CCRGB );

				// NJS: real alpha effects:
				if(VariableAlpha)
				{
					sgrColorCombine(GR_COMBINE_FUNCTION_SCALE_OTHER, 
									GR_COMBINE_FACTOR_LOCAL,
									GR_COMBINE_LOCAL_CONSTANT, 
									GR_COMBINE_OTHER_TEXTURE, 
									FXFALSE
					);
					
					grAlphaCombine( GR_COMBINE_FUNCTION_SCALE_OTHER_MINUS_LOCAL, 
		  							GR_COMBINE_FACTOR_ONE, 
									GR_COMBINE_LOCAL_ITERATED, 
									GR_COMBINE_OTHER_TEXTURE, 
									FXFALSE
					);

					/* VERY MUCH HAS THE CIGAR: */
					sgrAlphaBlendFunction( GR_BLEND_SRC_ALPHA, GR_BLEND_ONE, GR_BLEND_ZERO , GR_BLEND_ZERO );

					if(PolyFlags&PF_Masked)
					{
						sgrAlphaTestFunction(GR_CMP_GREATER); 
						grAlphaTestReferenceValue(0);
					}
				} 
			}
		}
		FLOAT DrawScale = Particles[i].DrawScale;

		// Setup projection plane.
		Z=((Particles[i].WorldLocation-Frame->Coords.Origin)|Frame->Coords.ZAxis)-0;
		//Z-=Particles[i].ZBias;

		// See if this is occluded.
		if(!GRender->Project(Frame,Particles[i].WorldLocation,ScreenX,ScreenY,&Persp))
			continue;

		// X extent.
		FLOAT XSize=Persp*DrawScale*CurrentTexture->USize; //!!expensive (??)
		X1=appRound(appCeil(ScreenX-XSize/2));
		X2=appRound(appCeil(ScreenX+XSize/2));
		if(X1>X2) Exchange(X1,X2);

		if( X1 < 0 )
		{
			X1=0;
			if(X2<0) X2=0;
		}

		if(X2>Frame->X)
		{
			X2=Frame->X;
			if(X1>Frame->X) X1=Frame->X;
		}

		if(X2<=0||X1>=Frame->X-1) continue;

		// Y extent.
		FLOAT YSize = Persp * DrawScale * CurrentTexture->VSize;
		Y1          = appRound(appCeil(ScreenY-YSize/2));
		Y2          = appRound(appCeil(ScreenY+YSize/2));
		if( Y1 > Y2 ) Exchange( Y1, Y2 );

		if( Y1 < 0 )
		{
			Y1 = 0;
			if( Y2 < 0 ) Y2 = 0;
		}

		if( Y2 > Frame->Y )
		{
			Y2 = Frame->Y;
			if( Y1 > Frame->Y ) Y1 = Frame->Y;
		}
		if( Y2<=0 || Y1>=Frame->Y || Y1>=Y2 )
			continue;


		// Draw the actor.
		{
			// Sprite.
			FLOAT DrawScale=Particles[i].DrawScale;

			FLOAT XScale=Persp*DrawScale*CurrentTexture->USize;
			FLOAT YScale=Persp*DrawScale*CurrentTexture->VSize;

			// Previous Canvas DrawTile:
			{
				FLOAT X=ScreenX-XScale/2;
				FLOAT Y=ScreenY-YScale/2;
				FLOAT XL=XScale;
				FLOAT YL=YScale;
				FLOAT U=0;
				FLOAT V=0;
				FLOAT UL=CurrentTexture->USize;
				FLOAT VL=CurrentTexture->VSize;
	
				// Compute clipping region.
				FLOAT ClipY0=0;
				FLOAT ClipY1=Frame->FY;

				// Reject.
				if(XL<=0.f || YL<=0.f || X+XL<=0.f || Y+YL<=ClipY0 || X>=Frame->FX || Y>=ClipY1)
					continue;
			
				// Clip.
				if( X<0.f ) {FLOAT C=X*UL/XL; U-=C; UL+=C; XL+=X; X=0.f;}
				if( Y<0.f ) {FLOAT C=Y*VL/YL; V-=C; VL+=C; YL+=Y; Y=0.f;}
				if( XL>Frame->FX-X ) {UL+=(Frame->FX-X-XL)*UL/XL; XL=Frame->FX-X;}
				if( YL>Frame->FY-Y ) {VL+=(Frame->FY-Y-YL)*VL/YL; YL=Frame->FY-Y;}

				// Draw it.
				U *= UF; UL *= UF;
				V *= VF; VL *= VF;
				
				// Set up vertices:
				GrVertex Verts[4];
				FLOAT RZ=1.f/Z; 
				X+=Frame->XB+0.25f;
				Y+=Frame->YB+0.25f;
				Verts[0].x=Mask(X   ); Verts[0].y=Mask(Y   ); Verts[0].oow=RZ; Verts[0].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[0].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;
				Verts[1].x=Mask(X   ); Verts[1].y=Mask(Y+YL); Verts[1].oow=RZ; Verts[1].tmuvtx[0].sow=(U   )*RZ*States[GR_TMU0].UScale; Verts[1].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
				Verts[2].x=Mask(X+XL); Verts[2].y=Mask(Y+YL); Verts[2].oow=RZ; Verts[2].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[2].tmuvtx[0].tow=(V+VL)*RZ*States[Tmu].VScale;
				Verts[3].x=Mask(X+XL); Verts[3].y=Mask(Y   ); Verts[3].oow=RZ; Verts[3].tmuvtx[0].sow=(U+UL)*RZ*States[GR_TMU0].UScale; Verts[3].tmuvtx[0].tow=(V   )*RZ*States[Tmu].VScale;

				// NJS: Do I have rotation?
				if(Particles[i].Rotation)	
				{
					float rotationOffsetX=0, rotationOffsetY=0; 
					float originX=(Verts[0].x+XL/2.0)+rotationOffsetX, originY=(Verts[0].y+YL/2.0)+rotationOffsetY;

					for(int index=0;index<4;index++)
					{	
						float x=Verts[index].x,
							  y=Verts[index].y;

						RotateAboutOrigin2D(originX,originY,x,y, Particles[i].Rotation);
						Verts[index].x=Mask(x);
						Verts[index].y=Mask(y);
					}
				}

				// Compute alpha if nessecary.					
				if(VariableAlpha)
				{
					FLOAT alpha=Particles[i].Alpha*SystemAlphaScale;
					if(alpha>1) alpha=1; else if(alpha<0) alpha=0;

					for(int i=0;i<4;i++)
						//	TLW: Don't want to zero out colors
						Verts[i].a=Mask(255-(alpha*255.0)); 
				}
				
				// Draw it:
				grDrawPlanarPolygonVertexList(4,Verts);		
			}
		}
	}

	if(CurrentTexture)
	{
		if(VariableAlpha)
		{
			sgrAlphaBlendFunction(GR_BLEND_ONE,GR_BLEND_ZERO,GR_BLEND_ZERO,GR_BLEND_ZERO);
			sgrAlphaTestFunction(GR_CMP_ALWAYS);
		}

		ResetBlending(PolyFlags);
		CurrentTextureInfo.Palette[0]=Saved;
		CurrentTexture->Unlock(CurrentTextureInfo);
		CurrentTexture=NULL;
	}
}

#endif
/*-----------------------------------------------------------------------------
	Command line.
-----------------------------------------------------------------------------*/

//
// Get stats.
//
void UGlideRenderDevice::GetStats( TCHAR* Result )
{
	appSprintf
	(
		Result,
		_T("pal=%03i (%04.1f) down8=%03i (%04.1f) down16=%03i (%04.1f) surfs=%03i/%03i (%04.1f) tris=%03i (%04.1f)"),
		Stats.DownloadsPalette,
		GSecondsPerCycle*1000 * Stats.PaletteTime,
		Stats.Downloads8,
		GSecondsPerCycle*1000 * Stats.Download8Time,
		Stats.Downloads16,
		GSecondsPerCycle*1000 * Stats.Download16Time,
		Stats.Surfs,
		Stats.Polys,
		GSecondsPerCycle*1000 * Stats.PolyVTime,
		Stats.Tris,
		GSecondsPerCycle*1000 * Stats.PolyCTime
	);
}

//
// Execute a command.
//
UBOOL UGlideRenderDevice::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	if( URenderDevice::Exec( Cmd, Ar ) )
	{
		return 1;
	}
	if( ParseCommand(&Cmd,TEXT("TMUDETAIL")) )
	{
		bDetailStats = !bDetailStats;
		return 1;
	}
	if( ParseCommand(&Cmd,TEXT("GetRes")) )
	{
		Ar.Logf( TEXT("640x480 800x600 1024x768 1280x1024 1600x1200") );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GetColorDepths")) )
	{
		Ar.Logf( TEXT("16") );
		return 1;
	}
	else return 0;
}

/*-----------------------------------------------------------------------------
	Unimplemented.
-----------------------------------------------------------------------------*/
#if 0

void __fastcall UGlideRenderDevice::dnDraw3DLine
( 
	FSceneNode *Frame, 
	UTexture   *Texture,
	DWORD       PolyFlags, 
	FVector     Start, 
	FVector     End, 
	FLOAT       StartWidth, 
	FLOAT		EndWidth, 
	FColor		StartColor, 
	FColor		EndColor 
)
{
	UBOOL NonOneWidth=true;

	if((StartWidth==1.0)&&(EndWidth==1.0)) NonOneWidth=false;

	FLOAT SX2 = Frame->FX2;
	FLOAT SY2 = Frame->FY2;

	// Transform.
	FVector P1=Start.TransformPointBy(Frame->Coords);
	FVector P2=End.TransformPointBy(Frame->Coords);
	FVector P3=P1;
	FVector P4=P2;

	if(NonOneWidth)
	{
		P3.X+=StartWidth;
		P4.X+=EndWidth;
	}

	// Calculate delta, discard line if points are identical.
	FVector D=P2-P1;
	if( D.SizeSquared() < Square(0.01) )
		return;

	// Clip to near clipping plane.
	if( P1.Z <= LINE_NEAR_CLIP_Z )
	{
		// Clip P1 to NCP.
		if( P2.Z<(LINE_NEAR_CLIP_Z-0.01) )
			return;
		P1.X+=(LINE_NEAR_CLIP_Z-P1.Z) * D.X/D.Z;
		P1.Y+=(LINE_NEAR_CLIP_Z-P1.Z) * D.Y/D.Z;
		P1.Z =(LINE_NEAR_CLIP_Z);
	}
	else if( P2.Z<(LINE_NEAR_CLIP_Z-0.01) )
	{
		// Clip P2 to NCP.
		P2.X+=(LINE_NEAR_CLIP_Z-P2.Z) * D.X/D.Z;
		P2.Y+=(LINE_NEAR_CLIP_Z-P2.Z) * D.Y/D.Z;
		P2.Z =(LINE_NEAR_CLIP_Z);
	}

	if(NonOneWidth)
	{
		// Clip to near clipping plane.
		if( P3.Z <= LINE_NEAR_CLIP_Z )
		{
			// Clip P1 to NCP.
			if( P4.Z<(LINE_NEAR_CLIP_Z-0.01) )
				return;
			P3.X +=  (LINE_NEAR_CLIP_Z-P3.Z) * D.X/D.Z;
			P3.Y +=  (LINE_NEAR_CLIP_Z-P3.Z) * D.Y/D.Z;
			P3.Z  =  (LINE_NEAR_CLIP_Z);
		}
		else if( P4.Z<(LINE_NEAR_CLIP_Z-0.01) )
		{
			// Clip P2 to NCP.
			P4.X += (LINE_NEAR_CLIP_Z-P4.Z) * D.X/D.Z;
			P4.Y += (LINE_NEAR_CLIP_Z-P4.Z) * D.Y/D.Z;
			P4.Z =  (LINE_NEAR_CLIP_Z);
		}
	}

	// Calculate perspective.
	P1.Z = 1.0/P1.Z; P1.X = P1.X * Frame->Proj.Z * P1.Z + SX2; P1.Y = P1.Y * Frame->Proj.Z * P1.Z + SY2;
	P2.Z = 1.0/P2.Z; P2.X = P2.X * Frame->Proj.Z * P2.Z + SX2; P2.Y = P2.Y * Frame->Proj.Z * P2.Z + SY2;
	
	if(NonOneWidth)
	{
		P3.Z = 1.0/P3.Z; P3.X = P3.X * Frame->Proj.Z * P3.Z + SX2; P3.Y = P3.Y * Frame->Proj.Z * P3.Z + SY2;
		P4.Z = 1.0/P4.Z; P4.X = P4.X * Frame->Proj.Z * P4.Z + SX2; P4.Y = P4.Y * Frame->Proj.Z * P4.Z + SY2;
	}
	// Clip it and draw it.
	// X clip it.
	if( P1.X > P2.X )
	{
		Exchange( P1, P2 );
		Exchange( P3, P4 );
		Exchange(StartColor,EndColor);
		Exchange(StartWidth,EndWidth);
	}
	if( P2.X<0 || P1.X>Frame->FX )
		return;
	if( P1.X<0 )
	{
		if( Abs(P2.X-P1.X)<0.001 )
			return;
		P1.Y += (0-P1.X)*(P2.Y-P1.Y)/(P2.X-P1.X);
		P1.X  = 0;
	}
	if( P2.X>=Frame->FX )
	{
		if( Abs(P2.X-P1.X)<0.001 )
			return;
		P2.Y += ((Frame->FX-1.0)-P2.X)*(P2.Y-P1.Y)/(P2.X-P1.X);
		P2.X  = Frame->FX-1.0;
	}

	if(NonOneWidth)
	{
		// X clip it.
		if( P3.X > P4.X )
		{
			Exchange( P1, P2 );
			Exchange( P3, P4 );
			Exchange(StartColor,EndColor);
			Exchange(StartWidth,EndWidth);
		}
		if( P4.X<0 || P3.X>Frame->FX )
			return;
		if( P3.X<0 )
		{
			if( Abs(P4.X-P3.X)<0.001 )
				return;
			P3.Y += (0-P3.X)*(P4.Y-P3.Y)/(P4.X-P3.X);
			P3.X  = 0;
		}
		if( P4.X>=Frame->FX )
		{
			if( Abs(P4.X-P3.X)<0.001 )
				return;
			P4.Y += ((Frame->FX-1.0)-P4.X)*(P4.Y-P3.Y)/(P4.X-P3.X);
			P4.X  = Frame->FX-1.0;
		}
	}

	// Y clip it.
	if( P1.Y > P2.Y )
	{
		Exchange( P1, P2 );
		Exchange( P3, P4 );

		Exchange(StartColor,EndColor);
		Exchange(StartWidth,EndWidth);
	}
	if( P2.Y < 0 || P1.Y > Frame->FY )
		return;
	if( P1.Y < 0 )
	{
		if( Abs(P2.Y-P1.Y)<0.001 )
			return;
		P1.X += (0-P1.Y)*(P2.X-P1.X)/(P2.Y-P1.Y);
		P1.Y  = 0;
	}
	if( P2.Y >= Frame->FY )
	{
		if( Abs(P2.Y-P1.Y)<0.001 )
			return;
		P2.X += ((Frame->FY-1.0)-P2.Y)*(P2.X-P1.X)/(P2.Y-P1.Y);
		P2.Y  = Frame->FY-1.0;
	}

	if(NonOneWidth)
	{
		// Y clip it.
		if( P3.Y > P4.Y )
		{
			Exchange( P1, P2 );
			Exchange( P3, P4 );

			Exchange(StartColor,EndColor);
			Exchange(StartWidth,EndWidth);
		}
		if( P4.Y < 0 || P3.Y > Frame->FY )
			return;
		if( P3.Y < 0 )
		{
			if( Abs(P4.Y-P3.Y)<0.001 )
				return;
			P3.X += (0-P3.Y)*(P4.X-P3.X)/(P4.Y-P3.Y);
			P3.Y  = 0;
		}
		if( P4.Y >= Frame->FY )
		{
			if( Abs(P4.Y-P3.Y)<0.001 )
				return;
			P4.X += ((Frame->FY-1.0)-P4.Y)*(P4.X-P3.X)/(P4.Y-P3.Y);
			P4.Y  = Frame->FY-1.0;
		}
	}

	// Assure no coordinates are out of bounds. 
	ClipFloatFromZero(P1.X,Frame->FX);
	ClipFloatFromZero(P2.X,Frame->FX);
	ClipFloatFromZero(P1.Y,Frame->FY);
	ClipFloatFromZero(P2.Y,Frame->FY);
	if(NonOneWidth)
	{
		ClipFloatFromZero(P3.X,Frame->FX);
		ClipFloatFromZero(P4.X,Frame->FX);
		ClipFloatFromZero(P3.Y,Frame->FY);
		ClipFloatFromZero(P4.Y,Frame->FY);
	}

	// Draw it.
	if(LineFlags&LINE_AntiAliased)
		sgrAlphaBlendFunction( GR_BLEND_SRC_ALPHA, GR_BLEND_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO );
	else if(LineFlags&LINE_Transparent)
		sgrAlphaBlendFunction( GR_BLEND_DST_COLOR, GR_BLEND_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO );
	else
		sgrAlphaBlendFunction(GR_BLEND_ONE, GR_BLEND_ONE_MINUS_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO);

	guAlphaSource( GR_ALPHASOURCE_ITERATED_ALPHA );
	sguColorCombineFunction(GR_COLORCOMBINE_ITRGB);

	// Source position:
	GrVertex V1, V2;
	ZeroMemory(&V1,sizeof(V1));
	ZeroMemory(&V2,sizeof(V2));

	V1.x=Frame->XB+P1.X;
	V1.y=Frame->YB+P1.Y;
	V1.z=0; 
	V1.r=StartColor.R;
	V1.g=StartColor.G;
	V1.b=StartColor.B;
	V1.a=StartColor.A;
	//V1.oow=P1.Z * Frame->RProj.Z;
	V1.oow=P1.Z;

	// Dest position:
	V2.x=Frame->XB+P2.X;
	V2.y=Frame->YB+P2.Y;
	V2.z=0;	
	V2.r=EndColor.R;
	V2.g=EndColor.G;
	V2.b=EndColor.B;
	V2.a=EndColor.A;
	//V2.oow=P2.Z * Frame->RProj.Z;
	V2.oow=P2.Z;

	if(!NonOneWidth)
	{
		if(LineFlags&LINE_AntiAliased) grAADrawLine(&V1,&V2);
		else						   grDrawLine(&V1, &V2);
	} else
	{
		GrVertex V3, V4;
		V3.x=Frame->XB+P3.X;
		V3.y=Frame->YB+P3.Y;
		V3.z=0;	
		V3.r=StartColor.R;
		V3.g=StartColor.G;
		V3.b=StartColor.B;
		V3.a=StartColor.A;
		//V2.oow=P2.Z * Frame->RProj.Z;
		V3.oow=P3.Z;

		V4.x=Frame->XB+P4.X;
		V4.y=Frame->YB+P4.Y;
		V4.z=0;	
		V4.r=EndColor.R;
		V4.g=EndColor.G;
		V4.b=EndColor.B;
		V4.a=EndColor.A;
		//V2.oow=P2.Z * Frame->RProj.Z;
		V4.oow=P4.Z;

		grDrawTriangle(&V1,&V3,&V2);
		grDrawTriangle(&V2,&V4,&V3);
	}

	sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ZERO, GR_BLEND_ZERO, GR_BLEND_ZERO );
}

#endif
#define LINE_NEAR_CLIP_Z 1.0

void UGlideRenderDevice::Draw3DLine
(
	FSceneNode*		Frame,
	FPlane			Color,
	DWORD			LineFlags,
	FVector			P1,
	FVector			P2
)
{
	FLOAT SX2 = Frame->FX2;
	FLOAT SY2 = Frame->FY2;

	// Transform.
	P1 = P1.TransformPointBy( Frame->Coords );
	P2 = P2.TransformPointBy( Frame->Coords );

	// Calculate delta, discard line if points are identical.
	FVector D = P2-P1;
	if( D.SizeSquared() < Square(0.01) )
		return;

	// Clip to near clipping plane.
	if( P1.Z <= LINE_NEAR_CLIP_Z )
	{
		// Clip P1 to NCP.
		if( P2.Z<(LINE_NEAR_CLIP_Z-0.01) )
			return;
		P1.X +=  (LINE_NEAR_CLIP_Z-P1.Z) * D.X/D.Z;
		P1.Y +=  (LINE_NEAR_CLIP_Z-P1.Z) * D.Y/D.Z;
		P1.Z  =  (LINE_NEAR_CLIP_Z);
	}
	else if( P2.Z<(LINE_NEAR_CLIP_Z-0.01) )
	{
		// Clip P2 to NCP.
		P2.X += (LINE_NEAR_CLIP_Z-P2.Z) * D.X/D.Z;
		P2.Y += (LINE_NEAR_CLIP_Z-P2.Z) * D.Y/D.Z;
		P2.Z =  (LINE_NEAR_CLIP_Z);
	}

	// Calculate perspective.
	P1.Z = 1.0/P1.Z; P1.X = P1.X * Frame->Proj.Z * P1.Z + SX2; P1.Y = P1.Y * Frame->Proj.Z * P1.Z + SY2;
	P2.Z = 1.0/P2.Z; P2.X = P2.X * Frame->Proj.Z * P2.Z + SX2; P2.Y = P2.Y * Frame->Proj.Z * P2.Z + SY2;

	// Clip it and draw it.
	Draw2DClippedLine( Frame, Color, LineFlags, P1, P2 );

}

void UGlideRenderDevice::Draw2DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector P1, FVector P2 )
{
	FColor Color2(Color);
	
	sgrAlphaBlendFunction(GR_BLEND_ONE, GR_BLEND_ONE_MINUS_SRC_COLOR, GR_BLEND_ZERO, GR_BLEND_ZERO);
	sguColorCombineFunction(GR_COLORCOMBINE_ITRGB);

	grConstantColorValue(*(GrColor_t*)&Color2);
	
	sgrDepthMask(0); 
	grDepthBufferFunction(GR_CMP_ALWAYS); 

	// Source position:
	GrVertex V1, V2;
	ZeroMemory(&V1,sizeof(V1));
	ZeroMemory(&V2,sizeof(V2));

	V1.x=Frame->XB+P1.X;
	V1.y=Frame->YB+P1.Y;
	V1.z=0; 
	V1.r=Color2.R;
	V1.g=Color2.G;
	V1.b=Color2.B;
	V1.a=Color2.A;
	V1.oow=P1.Z;

	// Dest position:
	V2.x=Frame->XB+P2.X;
	V2.y=Frame->YB+P2.Y;
	V2.z=0;	
	V2.r=Color2.R;
	V2.g=Color2.G;
	V2.b=Color2.B;
	V2.a=Color2.A;
	V2.oow=P2.Z;

	grDrawLine(&V1, &V2);
	
	sgrDepthMask( 1 );
	grDepthBufferFunction(GR_CMP_LEQUAL);

	sgrAlphaBlendFunction( GR_BLEND_ONE, GR_BLEND_ZERO, GR_BLEND_ZERO, GR_BLEND_ZERO );
}
void UGlideRenderDevice::Draw2DPoint( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FLOAT X1, FLOAT Y1, FLOAT X2, FLOAT Y2, FLOAT Z )
{
}
void UGlideRenderDevice::PushHit( const BYTE* Data, INT Count )
{
}
void UGlideRenderDevice::PopHit( INT Count, UBOOL bForce )
{
}

/*-----------------------------------------------------------------------------
	Pixel reading.
-----------------------------------------------------------------------------*/

void UGlideRenderDevice::ReadPixels( FColor* InPixels, UBOOL BackBuffer = false)
{ 
	INT    X      = grSstScreenWidth();
	INT    Y      = grSstScreenHeight();
	BYTE*  Pixels = (BYTE*)InPixels;

	// Allocate memory.
	FMemMark Mark(GMem);
	_WORD* Buffer = New<_WORD>(GMem,X*Y);
	grLfbReadRegion( GR_BUFFER_FRONTBUFFER, 0, 0, X, Y, X*2, Buffer );

	// Convert to RGB.
	for( INT i=0; i<X*Y; i++ )
	{
		Pixels[i*4+2] = (Buffer[i] & 0xf800) >> 8; Pixels[i*4+2] += Pixels[i*4+2]>>5;
		Pixels[i*4+1] = (Buffer[i] & 0x07e0) >> 3; Pixels[i*4+1] += Pixels[i*4+1]>>6;
		Pixels[i*4+0] = (Buffer[i] & 0x001f) << 3; Pixels[i*4+0] += Pixels[i*4+0]>>5;
	}
	Mark.Pop();
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
