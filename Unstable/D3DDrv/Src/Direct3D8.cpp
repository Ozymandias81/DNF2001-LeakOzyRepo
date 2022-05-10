/*=============================================================================
	Direct3D8.cpp: Duke Forever Direct3D8 support.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by independent contractor who wishes to remanin anonymous.
		* Taken over by Tim Sweeney.
		* Completed vertex buffer and GeForce support, hit detection. - Erik 
		* Fog on gouraud polygons enabled if hardware has single-pass specular capability.
=============================================================================*/

// Includes.
#pragma warning(disable : 4291)
#pragma warning(disable : 4201)
#pragma warning(disable : 4701)
#pragma warning(disable : 4800)

// Unreal includes.
#include "Engine.h"
#include "UnRender.h"

#pragma hdrstop
EXECVAR		(float,	FogStart,		 50.f  );
EXECVAR		(float,	FogEnd,			 100.f );
EXECVAR		(INT,   RenderParticles, true  );
EXECVAR		(INT,	RenderMeshes,	 true  );
EXECVAR		(INT,	RenderSurfaces,	 true  );
EXECVAR		(INT,	RenderLines,	 true  );
EXECVAR		(INT,	RenderTiles,	 true  );
EXECVAR		(INT,	RenderPoints,	 true  );
EXECVAR		(INT,	WorldDetail,	 true  );
EXECVAR_HELP(INT,   CacheBlending,	 true, "Whether or not D3D's render states should be cached.  Useful for debugging render state problems." );

float LodBias=-0.60;

//#define LOG_PRESENT_PARMS

// NJS: When the following is defined, Validate() is called on entry to every driver function.
// When VALIDATE_ALL is not defined, it compiles away to nothing.
//#define VALIDATE_ALL


#ifdef VALIDATE_ALL
	#define VALIDATE DriverValidate()
#else
	#define VALIDATE 
#endif

EXECVAR_HELP(float, NearZ, 200.f, "Detail texture Z range.");
EXECFUNC(GetNearZ)
{
	GDnExec->Printf(TEXT("%f"), NearZ);
}

static const FLOAT NEAR_CLIP	 =1.f;
static const FLOAT FAR_CLIP		 =65535.f; 
static const FLOAT NEAR_CLIP_HACK=NEAR_CLIP*1.01f; // vogel: workaround for precision issues

// Globals.
HRESULT h; 

#define DOHITTEST
const int HIT_SIZE = 8;
#define IGNOREPIX 0xfe0d
static DWORD HitPixels[HIT_SIZE][HIT_SIZE];

#define WORLDSURFACE_VERTEXBUFFER_SIZE  4096   // UT levels reach a maximum of about 380; can get well over 512 for complex surfaces.
#define ACTORPOLY_VERTEXBUFFER_SIZE     16384  // Reaches 7 at most (clipped triangles) - used for tiles, lines and points also.
											   // NJS: Increased to 4096 in the desperate hope that we might be able to fit an entire mesh in one.
#define LINE_VERTEXBUFFER_SIZE	        16384    // Only draws 1 line at a time, so 2 verts is all we need
#define PARTICLE_VERTEXBUFFER_SIZE	    16384  // NJS: Expand when ready.
#define LoadLibraryX(a) TCHAR_CALL_OS(LoadLibraryW(a),LoadLibraryA(TCHAR_TO_ANSI(a)))
#define SAFETRY(cmd) {try{cmd;}catch(...){debugf(TEXT("Exception in ") TEXT(#cmd));}}
static bool ErrorCalled=false;

#define D3D_CHECK(VALUE) \
	do\
	{\
		HRESULT __hr=(VALUE);\
		if(FAILED(__hr))\
		{		\
			appErrorf(TEXT("[%s, %i] D3D ERROR: ") TEXT(#VALUE) TEXT(" == %s"),appFromAnsi(__FILE__),__LINE__,DXGetErrorString8(__hr));\
		}\
	} while(0)
						


//
// GetFormatBPP
// Returns the number of bits/pixel used by a specified format.
// If you add support for another format, you must add a case for it here.
//
int GetFormatBPP(D3DFORMAT Format)
{
	switch(Format)
	{
		case D3DFMT_A8R8G8B8:
		case D3DFMT_X8R8G8B8:
		case D3DFMT_D24S8:
		case D3DFMT_D32:		
			return 32;

		case D3DFMT_A1R5G5B5:
		case D3DFMT_R5G6B5:	
		case D3DFMT_X1R5G5B5:
		case D3DFMT_D16:
			return 16;

		case D3DFMT_P8:
			return 8;
	
		case D3DFMT_DXT1:
			return 4;
	
		default:
			return 0;
	}
}

#ifdef LOG_PRESENT_PARMS
static void LogPresentParms(D3DPRESENT_PARAMETERS &PresentParms)
{
	debugf(TEXT("--- PresentParms:"));

	//PresentParms.Flags = D3DPRESENTFLAG_LOCKABLE_BACKBUFFER;

	debugf(TEXT("PresentParms.Windowed=%i"),PresentParms.Windowed);
	debugf(TEXT("PresentParms.hDeviceWindow=%08x"),PresentParms.hDeviceWindow);
	
	debugf(TEXT("PresentParms.BackBufferWidth=%i"),PresentParms.BackBufferWidth);
	debugf(TEXT("PresentParms.BackBufferHeight=%i"),PresentParms.BackBufferHeight);
	debugf(TEXT("PresentParms.BackBufferCount=%i"),PresentParms.BackBufferCount);
	debugf(TEXT("PresentParms.EnableAutoDepthStencil=%i"),PresentParms.EnableAutoDepthStencil);

	TCHAR *PresentationInterval;
	switch(PresentParms.FullScreen_PresentationInterval)
	{
		case D3DPRESENT_INTERVAL_DEFAULT:	PresentationInterval=TEXT("D3DPRESENT_INTERVAL_DEFAULT"); break;
		case D3DPRESENT_INTERVAL_IMMEDIATE: PresentationInterval=TEXT("D3DPRESENT_INTERVAL_IMMEDIATE"); break;
		case D3DPRESENT_INTERVAL_ONE:		PresentationInterval=TEXT("D3DPRESENT_INTERVAL_ONE"); break;
		case D3DPRESENT_INTERVAL_TWO:		PresentationInterval=TEXT("D3DPRESENT_INTERVAL_TWO"); break;
		case D3DPRESENT_INTERVAL_THREE:		PresentationInterval=TEXT("D3DPRESENT_INTERVAL_THREE"); break;
		case D3DPRESENT_INTERVAL_FOUR:		PresentationInterval=TEXT("D3DPRESENT_INTERVAL_FOUR"); break;
		default: PresentationInterval=TEXT("Unknown"); break;
	}

	debugf(TEXT("PresentParms.FullScreen_PresentationInterval=%s"),PresentationInterval);
	debugf(TEXT("PresentParms.FullScreen_RefreshRateInHz=%i"),PresentParms.FullScreen_RefreshRateInHz);
	debugf(TEXT("PresentParms.SwapEffect=%i"),PresentParms.SwapEffect);


	TCHAR *BackBufferFormatName;
	#define CHECK_FORMAT(NAME) case NAME: BackBufferFormatName=TEXT(#NAME); break

	switch(PresentParms.BackBufferFormat)
	{
		CHECK_FORMAT(D3DFMT_X8R8G8B8);
		CHECK_FORMAT(D3DFMT_A8R8G8B8);
		CHECK_FORMAT(D3DFMT_R5G6B5);
		CHECK_FORMAT(D3DFMT_X1R5G5B5);
		default: BackBufferFormatName=TEXT("Unknown"); break;
	}
	debugf(TEXT("PresentParms.BackBufferFormat=%u(%u-bit) (%s)"),PresentParms.BackBufferFormat,GetFormatBPP(PresentParms.BackBufferFormat),BackBufferFormatName);
	debugf(TEXT("PresentParms.AutoDepthStencilFormat=%u(%u-bit)"),PresentParms.AutoDepthStencilFormat,GetFormatBPP(PresentParms.AutoDepthStencilFormat));

}
#endif

//#define BATCH_PROJECTOR_POLYS

#ifdef BATCH_PROJECTOR_POLYS
	#define PROJECTOR_VERTEXBUFFER_SIZE		(16384)
#endif

/*-----------------------------------------------------------------------------
	Vertex definitions.
-----------------------------------------------------------------------------*/
struct FD3DDefaultVertexBuffer
{
	enum {USAGE=D3DUSAGE_WRITEONLY|D3DUSAGE_DYNAMIC};
};

struct FD3DScreenVertex : public FD3DDefaultVertexBuffer
{
	enum {FVF=D3DFVF_XYZRHW | D3DFVF_DIFFUSE | D3DFVF_TEX2};
	FPlane		Position;
	FColor		Color;
	FLOAT		U[2];
	FLOAT		U2[2];
};

struct FD3DTLVertex : public FD3DDefaultVertexBuffer
{
	enum {FVF=D3DFVF_XYZRHW | D3DFVF_DIFFUSE | D3DFVF_SPECULAR | D3DFVF_TEX2};
	FPlane		Position;
	FColor		Diffuse, 
				Specular;
	FLOAT		U[2];
	FLOAT		U2[2];
};

struct FD3DTileVertex : public FD3DDefaultVertexBuffer
{
	enum {FVF=D3DFVF_XYZRHW | D3DFVF_DIFFUSE | D3DFVF_TEX1};
	FPlane		Position;
	FLOAT		U[2];
};

struct FD3DVertex : public FD3DDefaultVertexBuffer
{
	enum {FVF=D3DFVF_XYZ  | D3DFVF_DIFFUSE};
	FVector		Position;
	FColor		Diffuse;
};

typedef struct FD3DParticle : public FD3DDefaultVertexBuffer
{
	enum { FVF=D3DFVF_XYZ | D3DFVF_DIFFUSE | D3DFVF_TEX1 | D3DFVF_TEXCOORDSIZE2(0) };
    FVector Position;
    DWORD   Diffuse;
	D3DXVECTOR2 TextureVector;
} PARTICLE_VERTEX;


template <class T>
class FD3DVertexBuffer
{
public:
	IDirect3DDevice8*		Device;
	IDirect3DVertexBuffer8*	VertexBuffer8;
	INT						Length,
							First,
							Rover;

	// Constructor.
	FD3DVertexBuffer()
	{
		// Setup member variables.
		Length = 0;
		Rover = 0;
		VertexBuffer8 = NULL;
		Device=NULL;
	}

	~FD3DVertexBuffer()
	{
		Exit(); 
	}

	// Init - Initialize the vertex buffer.
	void Init(IDirect3DDevice8*	InDevice, INT InLength)
	{
		Exit();	// Destroy any previous vertex buffer.

		check(InDevice); Device = InDevice;
		check(InLength); Length = InLength;
		
		// Create the vertex buffer.
		D3D_CHECK(Device->CreateVertexBuffer(Length*sizeof(T),
											 T::USAGE,
											 T::FVF,
											 D3DPOOL_DEFAULT,
											 &VertexBuffer8));
	}

	// Exit - Releases the vertex buffer.
	void Exit()
	{
		SafeRelease(VertexBuffer8);
	}

	// Lock - Locks a range of vertices for writing.
	// NJS: Start Extension added so existing VB's can be relocked.
	T* Lock(INT Num, INT Start=-1)
	{
		check(VertexBuffer8);
		check(Length);
		check(Num<Length);

 		T*	VertexData;

		// Lock the vertex buffer.
		if(Start!=-1)
		{
			D3D_CHECK(VertexBuffer8->Lock(Start * sizeof(T),Num * sizeof(T),(BYTE**) &VertexData,D3DLOCK_NOOVERWRITE));
		} 
		else if(Rover + Num < Length)
		{
			D3D_CHECK(VertexBuffer8->Lock(Rover * sizeof(T),Num * sizeof(T),(BYTE**) &VertexData,D3DLOCK_NOOVERWRITE));
			First =Rover;

			Rover+=Num;

		} else
		{
			D3D_CHECK(VertexBuffer8->Lock(0,Num * sizeof(T),(BYTE**) &VertexData,D3DLOCK_DISCARD));
			First=0;
			Rover=Num;
		}

		return VertexData;
	}

	// Unlock - Unlocks the locked vertices.
	INT Unlock()
	{
		check(VertexBuffer8);

		D3D_CHECK(VertexBuffer8->Unlock());

		return First;
	}

	// Set - Makes this vertex buffer the current vertex buffer.
	void Set()
	{
		check(Device);
		check(VertexBuffer8);

		// Set stream source 0 and the vertex shader.
		D3D_CHECK(Device->SetRenderState(D3DRS_SOFTWAREVERTEXPROCESSING,FALSE));
		D3D_CHECK(Device->SetVertexShader(T::FVF));
		D3D_CHECK(Device->SetStreamSource(0,VertexBuffer8,sizeof(T)));
	}
};

// NJS: Globals related to D3D initialization.  In the process of being cleaned up:
static IDirect3D8 *Direct3D8;
TArray<D3DADAPTER_IDENTIFIER8> Adapters;
INT	BestAdapterIndex = 0;
D3DCAPS8				DeviceCaps8;
D3DADAPTER_IDENTIFIER8	DeviceIdentifier;
TArray<D3DDISPLAYMODE>	DisplayModes;
#define PYR(n)         ((n)*((n+1))/2)
_WORD					RScale[PYR(128)];
_WORD					GScale[PYR(128)];
_WORD					BScale[PYR(128)];

// Texture information classes.
struct FPixFormat
{
	// Pixel format info.
	bool 				Supported;		// Whether this pixel format is supported for textures with the current device.
	D3DFORMAT			Direct3DFormat;	// The corresponding Direct3D pixel format.
	FPixFormat*			Next;			// Next in linked list of all compatible pixel formats.
	const TCHAR*		Desc;			// Stat: Human readable name for stats.
	INT					BitsPerPixel;	// Total bits per pixel.

	// Multi-frame stats.
	INT					Binned;			// Stat: How many textures of this format are available in bins.
	INT					BinnedRAM;		// Stat: How much RAM is used by total textures of this format in the cache.
	INT					ActiveRAMPeak;	// Stat: The highest active ram has ever been:
	// Per-frame stats.
	INT					Active;			// Stat: How many textures of this format are active.
	INT					ActiveRAM;		// Stat: How much RAM is used by active textures of this format per frame.
	INT					Sets;			// Stat: Number of SetTexture was called this frame on textures of this format.
	INT					Uploads;		// Stat: Number of texture Blts this frame.
	INT					UploadCycles;	// Stat: Cycles spent Blting.

	
	FPixFormat() 
	{ 
		memset(this,0,sizeof(*this));
	}

	void ResetStats()
	{
		ActiveRAMPeak=ActiveRAM;
		Sets = Uploads = UploadCycles = Active = ActiveRAM = 0;
	}
};

D3DDISPLAYMODE			OriginalDisplayMode;

/*-----------------------------------------------------------------------------
	UD3DRenderDevice definition.
-----------------------------------------------------------------------------*/
class DLL_EXPORT UD3DRenderDevice : public URenderDevice
{
    DECLARE_CLASS(UD3DRenderDevice,URenderDevice,CLASS_Config)

	// Defines.
	struct FTexInfo;

	// JEP...
	struct ProjectorInfo
	{
		FSceneNode				*Frame;
		IDirect3DTexture8		*pRenderTargetTex;
		IDirect3DSurface8		*pRenderTargetSurf;

		FBspNode				*GNodes;

		FCoords					CameraToLight;

		// Pre computes
		FLOAT					OneOverX;			// Pre-computed 1/Frame->X
		FLOAT					OneOverY;			// Pre-computed 1/Frame->Y
		FLOAT					_33;				// wFar / (wFar - wNear);
		FLOAT					_43;				// -_33 * wNear;
		FLOAT					FadeScale;
	};

	TArray<ProjectorInfo>		ProjectorArray;

	struct RenderTargetInfo
	{
		UBOOL					Active;					// == false if it was freed (and put on the freed list)
		IDirect3DTexture8		*pRenderTargetTex;
		IDirect3DSurface8		*pRenderTargetSurf;
		INT						Width;
		INT						Height;
	};

	TArray<RenderTargetInfo>	RenderTargetArray;
	TArray<INT>					FreeRenderTargets;
	// ...JEP

	// 'Abstract base class' of the texture fillers: 
	struct FTexFiller
	{
		FPixFormat* PixelFormat;
		virtual void BeginUpload( FTexInfo* Tex, const FTextureInfo& Info, DWORD PolyFlags, DWORD PolyFlagsEx ) {}
		virtual void UploadMipmap( FTexInfo* Tex, FRainbowPtr Dest, INT Stride, const FTextureInfo& Info, INT MipIndex, DWORD PolyFlags ) {}
	};

	struct FTexInfo
	{
		IDirect3DTexture8*	Texture8;
		DWORD				SizeBytes;

		QWORD				CacheId;
		UBOOL				Masking;
		INT					FirstMip;
		FLOAT				UScale,
							VScale;
		FColor				MaxColor;
		UBOOL				UseMips;

		FTexFiller*			Filler;
		INT					FrameCounter;

		FTexInfo*			HashNext;
		FTexInfo*			NextTexture;
	};

	struct FTexFillerDXT1 : public FTexFiller
	{
		FTexFillerDXT1( UD3DRenderDevice* InOuter ) { PixelFormat=&InOuter->FormatDXT1; }
		void UploadMipmap( FTexInfo* ti, FRainbowPtr Dest, INT Stride, const FTextureInfo& Info, INT MipIndex, DWORD PolyFlags )
		{
			INT USize = Max(Info.Mips[MipIndex]->USize, 4);
			INT VSize = Max(Info.Mips[MipIndex]->VSize, 4);
			appMemcpy( Dest.PtrVOID, Info.Mips[MipIndex]->DataPtr, (USize * VSize)/2 );
		}
	};

	struct FTexFillerP8_P8 : public FTexFiller
	{
		FTexFillerP8_P8( UD3DRenderDevice* InOuter ) { PixelFormat=&InOuter->FormatP8; }
		void UploadMipmap( FTexInfo* Tex, FRainbowPtr Dest, INT Stride, const FTextureInfo& Info, INT MipIndex )
		{
			FRainbowPtr Src  = Info.Mips[MipIndex]->DataPtr;
			for( INT j=Info.Mips[MipIndex]->VSize-1; j>=0; j-- )
			{
				for( INT k=Info.Mips[MipIndex]->USize-1; k>=0; k-- )
					*Dest.PtrBYTE++ = *Src.PtrBYTE++;
				Dest.PtrBYTE += Stride - Info.Mips[MipIndex]->USize;
			}
		}
	};
	struct FTexFiller8888_RGBA8 : public FTexFiller
	{
		FTexFiller8888_RGBA8( UD3DRenderDevice* InOuter ) { PixelFormat=&InOuter->Format8888; }
		void UploadMipmap( FTexInfo* ti, FRainbowPtr Dest, INT Stride, const FTextureInfo& Info, INT MipIndex, DWORD PolyFlags )
		{
			INT  USize      = Info.Mips[MipIndex]->USize;
			INT  VSize      = Info.Mips[MipIndex]->VSize;
			FRainbowPtr Src = Info.Mips[MipIndex]->DataPtr;
			for( INT j=VSize-1; j>=0; j--,Dest.PtrDWORD += Stride-USize*sizeof(DWORD) )
				for( INT k=USize-1; k>=0; k--,Dest.PtrDWORD++ )
				{
					*Dest.PtrDWORD = *Src.PtrDWORD++;
					//*Dest.PtrDWORD|=0xFF000000; 
				}
		}
	};
	struct FTexFiller8888_RGBA7 : public FTexFiller
	{
		FTexFiller8888_RGBA7( UD3DRenderDevice* InOuter ) { PixelFormat=&InOuter->Format8888; }
		void UploadMipmap( FTexInfo* ti, FRainbowPtr Dest, INT Stride, const FTextureInfo& Info, INT MipIndex, DWORD PolyFlags )
		{

			DWORD*		TempBuffer = new DWORD[Info.Mips[MipIndex]->USize * Info.Mips[MipIndex]->VSize];
			FRainbowPtr	RealDest = Dest;

			Dest.PtrDWORD = TempBuffer;
			Stride = Info.Mips[MipIndex]->USize * 4;

			FRainbowPtr Src  = Info.Mips[MipIndex]->DataPtr;
			for( INT v=0; v<Info.VClamp; v++,Dest.PtrBYTE+=Stride-Info.UClamp*sizeof(DWORD),Src.PtrDWORD+=Info.USize-Info.UClamp )
				for( INT u=0; u<Info.UClamp; u++,Src.PtrDWORD++,Dest.PtrDWORD++ )
					*Dest.PtrDWORD = *Src.PtrDWORD*2;

		}
	};
	struct FTexFiller8888_P8 : public FTexFiller
	{
		DWORD AlphaPalette[256]; 

		FTexFiller8888_P8( UD3DRenderDevice* InOuter ) { PixelFormat=&InOuter->Format8888; }
		void UploadMipmap( FTexInfo* ti, FRainbowPtr Dest, INT Stride, const FTextureInfo& Info, INT MipIndex, DWORD PolyFlags )
		{
			INT		USize      = Info.Mips[MipIndex]->USize;
			INT		VSize      = Info.Mips[MipIndex]->VSize;

			FRainbowPtr Src = Info.Mips[MipIndex]->DataPtr;
			for( INT j=VSize-1; j>=0; j--,Dest.PtrBYTE+=Stride-USize*sizeof(DWORD) )
				for( INT k=USize-1; k>=0; k--,Dest.PtrDWORD++ )
					*Dest.PtrDWORD = AlphaPalette[*Src.PtrBYTE++];

		}
		void BeginUpload( FTexInfo* ti, const FTextureInfo& Info, DWORD PolyFlags, DWORD PolyFlagsEx )
		{
			// Compute the alpha palette:
			for( INT i=0; i<NUM_PAL_COLORS; i++ )
				AlphaPalette[i] = D3DCOLOR_RGBA(Info.Palette[i].R,Info.Palette[i].G,Info.Palette[i].B,Info.Palette[i].A);
			
			if( PolyFlags & PF_Masked )
				AlphaPalette[0] = 0;
		}
	};
	struct FTexFiller1555_RGBA7 : public FTexFiller
	{
		FTexFiller1555_RGBA7( UD3DRenderDevice* InOuter ) { PixelFormat=&InOuter->Format1555; }
		void UploadMipmap( FTexInfo* ti, FRainbowPtr Dest, INT Stride, const FTextureInfo& Info, INT MipIndex, DWORD PolyFlags )
		{
			_WORD*      RPtr     = RScale + PYR(Info.MaxColor->R/2);
			_WORD*      GPtr     = GScale + PYR(Info.MaxColor->G/2);
			_WORD*      BPtr     = BScale + PYR(Info.MaxColor->B/2);
			FRainbowPtr Src      = Info.Mips[MipIndex]->DataPtr;
			for( INT v=0; v<Info.VClamp; v++,Dest.PtrBYTE+=Stride-Info.UClamp*2,Src .PtrDWORD+=Info.USize-Info.UClamp )
				for( INT u=0; u<Info.UClamp; u++,Src.PtrDWORD++ )
					*Dest.PtrWORD++ = BPtr[Src.PtrBYTE[0]] + GPtr[Src.PtrBYTE[1]] + RPtr[Src.PtrBYTE[2]];
		}
	};
	struct FTexFiller1555_P8 : public FTexFiller
	{
		DWORD AlphaPalette[256]; 

		FTexFiller1555_P8( UD3DRenderDevice* InOuter ) { PixelFormat=&InOuter->Format1555; }
		void UploadMipmap( FTexInfo* ti, FRainbowPtr Dest, INT Stride, const FTextureInfo& Info, INT MipIndex, DWORD PolyFlags )
		{
			INT  USize      = Info.Mips[MipIndex]->USize;
			INT  VSize      = Info.Mips[MipIndex]->VSize;
			FRainbowPtr Src = Info.Mips[MipIndex]->DataPtr;

			for( INT j=VSize-1; j>=0; j--,Dest.PtrBYTE+=Stride-Info.Mips[MipIndex]->USize*2 )
				for( INT k=USize-1; k>=0; k-- )
					*Dest.PtrWORD++ = AlphaPalette[*Src.PtrBYTE++];
		}

		void BuildAlphaPalette( FColor* Pal, DWORD FracA, DWORD MaskA, DWORD FracR, DWORD MaskR, DWORD FracG, DWORD MaskG, DWORD FracB, DWORD MaskB )
		{
			DWORD* Dest = AlphaPalette;
			for( FColor *End=Pal+NUM_PAL_COLORS; Pal<End; Pal++ )
			{
				
				*Dest++
				=  (((Min(MaskA,FracA*Pal->A))&MaskA)
				|	((Min(MaskR,FracR*Pal->R))&MaskR)
				|   ((Min(MaskG,FracG*Pal->G))&MaskG)
				|	((Min(MaskB,FracB*Pal->B))&MaskB))>>16;
			}
		}
		void BeginUpload( FTexInfo* ti, const FTextureInfo& Info, DWORD PolyFlags, DWORD PolyFlagsEx )
		{
			// Convert lighten and darknen modulate as a modulated texture, but don't add one.
			if(PolyFlagsEx&(PFX_LightenModulate|PFX_DarkenModulate))
			{
				FColor* Pal = Info.Palette;
				DWORD* Dest = AlphaPalette;

				for( FColor *End=Pal+NUM_PAL_COLORS; Pal<End; Pal++ )
				{
					*Dest++
					=((Min<INT>(0x80000000,(Pal->A*0x01000000)&0x80000000))
					| (Min<INT>(0x7C000000,(Pal->R*0x007fffff)&0x7C000000))
					| (Min<INT>(0x03E00000,(Pal->G*0x0003ffff)&0x03E00000))
					| (Min<INT>(0x001F0000,(Pal->B*0x00001fff)&0x001F0000)) )>>16;
				}
			} else
			// Have to add one to the texture, so we can darken it down by half an element later.
			if((PolyFlags & (PF_Modulated|PF_Translucent)) == PF_Modulated)// Prevent brightness adjustment when modulating 
			{
				FColor* Pal = Info.Palette;
				DWORD* Dest = AlphaPalette;

				for( FColor *End=Pal+NUM_PAL_COLORS; Pal<End; Pal++ )
				{
					*Dest++
					=((Min<INT>(0x80000000,(Pal->A*0x01000000)&0x80000000))
					| (Min<INT>(0x7C000000,((Pal->R+1)*0x007fffff)&0x7C000000))
					| (Min<INT>(0x03E00000,((Pal->G+1)*0x0003ffff)&0x03E00000))
					| (Min<INT>(0x001F0000,((Pal->B+1)*0x00001fff)&0x001F0000)) )>>16;
				}
			} else
			BuildAlphaPalette
			(
				Info.Palette,
				0x1000000, 0x80000000,
				/*appRound(*/0x07fffffff/Max<INT>(ti->MaxColor.R,1)/*)*/, 0x7C000000,
				/*appRound(*/0x003ffffff/Max<INT>(ti->MaxColor.G,1)/*)*/, 0x03E00000,
				/*appRound(*/0x0001fffff/Max<INT>(ti->MaxColor.B,1)/*)*/, 0x001F0000
				/* Adjustment of 1.4* for 16-bit rendering modes to make 
				   brightness scaling of world textures comparable to that of 3dfx.
				   NJS: removed the 1.4 scaling.
				*/
			);
			if( PolyFlags & PF_Masked )
				AlphaPalette[0] = 0; //0x3DEF;
		}
	};

	struct FD3DStats
	{
		INT	  SurfTime, PolyTime, TileTime, ParticleTime, BeamTime, QueueTime, D3DPolyTime, D3DVertexRender, D3DVertexSetup, D3DVertexLock;
		DWORD Surfs, Polys, MaskedPolys, Tiles, GouraudPolys, Particles, ParticleTextureChanges, Beams, SuccessorMisses, QueueCount;
		DWORD TexUploads;			
		INT   VBLocks;
	};

	// Cached texture hash. !! Unify with vertex buffer/index buffer caching.
	FTexInfo*				CachedTextures;
	FTexInfo*				TextureHash[4096];
	FTexInfo				NoTexture;

	// Round robin vertex buffers used to contain world surfaces and mesh triangles.
	FD3DVertexBuffer<FD3DScreenVertex> WorldVertices;
	FD3DVertexBuffer<FD3DTLVertex>	   ActorVertices;
	FD3DVertexBuffer<FD3DVertex>	   LineVertices;
	FD3DVertexBuffer<FD3DParticle>	   ParticleVertices;


#ifdef BATCH_PROJECTOR_POLYS
	FD3DVertexBuffer<FD3DScreenVertex>	ProjectorVertices;	
#endif

	void CleanupVertexBuffers()
	{
		WorldVertices.Exit();
		ActorVertices.Exit();
		LineVertices.Exit();
		ParticleVertices.Exit();
	
	#ifdef BATCH_PROJECTOR_POLYS
		ProjectorVertices.Exit();
	#endif
	}

	// Saved viewport info.
    INT						ViewportX;
    INT						ViewportY;
    HWND					ViewporthWnd;
    DWORD					ViewportColorBits;
    UBOOL					ViewportFullscreen;

	// Pixel formats from D3D.
    FPixFormat				FormatDXT1;
    FPixFormat				FormatP8;
    FPixFormat				Format8888;
    FPixFormat				Format1555;
	FPixFormat*				FirstPixelFormat;

	// Fillers.
	FTexFillerDXT1			FillerDXT1;
	FTexFiller8888_RGBA8	Filler8888_RGBA8;
	FTexFiller8888_RGBA7	Filler8888_RGBA7;
	FTexFiller8888_P8		Filler8888_P8;
	FTexFiller1555_RGBA7	Filler1555_RGBA7;
	FTexFiller1555_P8		Filler1555_P8;
	FTexFillerP8_P8			FillerP8_P8;

	// From D3D.
	D3DFORMAT				BackBufferFormat;

	D3DFORMAT				RenderTargetFormat;			// Current format to create rendertargets at
	IDirect3DSurface8		*pOriginalRenderTarget;		// Used to restore back to original render target
	IDirect3DSurface8		*pOriginalZStencil;			// Used to restore back to original zstencil
	IDirect3DTexture8		*ClipperTexture;			// Texture used to clip textures to the projector frustum
	void					*TempRT;
	void					*CurrentRenderTarget;

	// Direct3D init sequence objects and variables.
    IDirect3DDevice8*		Direct3DDevice8;

	// Direct3D-specific render options.
	BITFIELD				UseTrilinear;
    BITFIELD				UseEditorGammaCorrection;
	BITFIELD				UseD3DSoftwareRenderer;
	BITFIELD				UseTripleBuffering;
	BITFIELD				UseVSync;
	BITFIELD				UseVertexSpecular;
	BITFIELD				UsePrecache;
	BITFIELD				Use2ndTierTextureCache;
	BITFIELD				Use32BitTextures;
	INT						MaxResWidth, MaxResHeight;
	
	// Info used while rendering a frame.
	D3DVIEWPORT8			ViewportInfo;
	D3DXMATRIX				WorldMatrix;
	D3DXMATRIX				ViewMatrix;
	D3DXMATRIX				ViewMatrix4x3;
	D3DXMATRIX				InvViewMatrix;
    D3DXMATRIX				ProjectionMatrix;
	D3DXMATRIX				ProjViewMatrix;

    FPlane					FlashScale;
    FPlane					FlashFog;
    DWORD					LockFlags;
	DWORD					CurrentPolyFlags;
	DWORD					CurrentPolyFlagsEx;
    FD3DStats				Stats;
	FTexInfo*				Stages[8];
	FD3DTLVertex			Verts[ACTORPOLY_VERTEXBUFFER_SIZE];
	INT						FrameCounter;
	INT						PrecacheCycle;

	// JEP...
#ifdef BATCH_PROJECTOR_POLYS
	#define MAX_PROJECTOR_VERTS				(PROJECTOR_VERTEXBUFFER_SIZE)	// Upper bounds before a forced flush
	#define MAX_PROJECTOR_SURFS				(512)
	#define MAX_PROJECTOR_POLYS				(16384)
	
	struct ProjectorSurf
	{
		DWORD				ProjectorFlags;

		INT					FirstVert;
		INT					NumVerts;
		INT					FirstPoly;
		INT					NumPolys;
	};

	ProjectorSurf			ProjectorSurfs[MAX_PROJECTOR_SURFS];	
	INT						NumProjectorSurfs;
	INT						ProjectorPolys[MAX_PROJECTOR_POLYS];
	INT						NumProjectorPolys;
	FD3DTLVertex			ProjectorVerts[MAX_PROJECTOR_VERTS];
	FVector					ProjectorPoints[MAX_PROJECTOR_VERTS];
	INT						NumProjectorVerts;
#endif
	// ...JEP

	// Hit detection
	TArray<BYTE>	HitStack;
	BYTE*			HitData;
	INT*			HitSize;
	INT				HitCount;

	// Current state.
	UViewport*		LockedViewport;
	UBOOL			CurrentFullscreen;
	INT				CurrentColorBytes;
	INT				FullScreenWidth;
	INT				FullScreenHeight;
	UBOOL			ForceReset;
	INT				PaletteIndex;

	// Used for D3D render state emulation and caching.
	float			ZBias;
	D3DBLEND		SrcBlend;
	D3DBLEND		DstBlend;
	INT 			AlphaBlendEnable;
	INT				TextureClampMode;
	INT				BeginSceneCount;

	INT				LockCount;

	UBOOL			DistanceFogEnabled;
	UBOOL			UseDistanceFog;

	FLOAT			DistanceFogBegin;
	FLOAT			DistanceFogEnd;
	FColor			DistanceFogColor;

    // UObject interface.
    void StaticConstructor()
	{
		new(GetClass(),TEXT("UseTrilinear"),            RF_Public)UBoolProperty( CPP_PROPERTY(UseTrilinear				), TEXT("Options"), CPF_Config );
		new(GetClass(),TEXT("UseEditorGammaCorrection"),RF_Public)UBoolProperty( CPP_PROPERTY(UseEditorGammaCorrection	), TEXT("Options"), CPF_Config );
		new(GetClass(),TEXT("UseTripleBuffering"),      RF_Public)UBoolProperty( CPP_PROPERTY(UseTripleBuffering		), TEXT("Options"), CPF_Config );
		new(GetClass(),TEXT("UseVSync"),                RF_Public)UBoolProperty( CPP_PROPERTY(UseVSync					), TEXT("Options"), CPF_Config );
		new(GetClass(),TEXT("UsePrecache"),             RF_Public)UBoolProperty( CPP_PROPERTY(UsePrecache				), TEXT("Options"), CPF_Config );
		new(GetClass(),TEXT("Use2ndTierTextureCache"),	RF_Public)UBoolProperty( CPP_PROPERTY(Use2ndTierTextureCache	), TEXT("Options"), CPF_Config );
		new(GetClass(),TEXT("Use32BitTextures"),		RF_Public)UBoolProperty( CPP_PROPERTY(Use32BitTextures			), TEXT("Options"), CPF_Config );

		DetailTextures			= TRUE;
		SpanBased				= FALSE;
		SupportsFogMaps			= TRUE;
		MaxResWidth				= MAXINT;
		MaxResHeight			= MAXINT;
	}

    // URenderDevice interface.
	UD3DRenderDevice()
	:	Filler1555_RGBA7(this)
	,	Filler8888_RGBA7(this)
	,	Filler8888_RGBA8(this)
	,	FillerDXT1		(this)
	,	Filler1555_P8	(this)
	,	Filler8888_P8	(this)
	,   FillerP8_P8		(this)
	{
		VALIDATE;
	}

	// Basically the destructor, called directly from the destructor at least.
	void Destroy()
	{
		QueueParticleShutdown();

		// Punt to my superclass:  FIXME: don't think this is a good idea with virtual destructors.
		Super::Destroy();
	}

	static void __fastcall InitD3D()
	{
		// Have we already been initialized?
		if(Direct3D8) 
			return;

		// Create the Direct3D object.
		verify(Direct3D8=Direct3DCreate8(D3D_SDK_VERSION));

		// Enumerate Direct3D adapters.
		INT	NumAdapters = Direct3D8->GetAdapterCount();
		Adapters.Empty(NumAdapters);

		debugf(NAME_Init,TEXT("Direct3D adapters detected:"));

		for(INT Index=0;Index<NumAdapters;Index++)
		{
			D3DADAPTER_IDENTIFIER8 AdapterIdentifier;

			D3D_CHECK(Direct3D8->GetAdapterIdentifier(Index,D3DENUM_NO_WHQL_LEVEL,&AdapterIdentifier));

			debugf(TEXT("Adaptor Detected: %s/%s"),appFromAnsi(AdapterIdentifier.Driver),appFromAnsi(AdapterIdentifier.Description));
			Adapters.AddItem(AdapterIdentifier);
		}

		if(!Adapters.Num())
			appErrorf(TEXT("No Direct3D adapters found"));

		// Find best Direct3D adapter.
		for(Index = 0;Index < Adapters.Num();Index++)
			if(appStrstr(appFromAnsi(Adapters(Index).Description),TEXT("Primary")))
				BestAdapterIndex = Index;

		// Get the Direct3D caps for the best adapter.
		D3D_CHECK(Direct3D8->GetDeviceCaps(BestAdapterIndex,D3DDEVTYPE_HAL,&DeviceCaps8));

		// Get device identifier.
		// szDriver, szDescription aren't guaranteed consistent (might change by mfgr, distrubutor, language, etc). Don't do any compares on these.
		// liDriverVersion is safe to do QWORD comparisons on.
		// User has changed drivers/cards iff guidDeviceIdentifier changes.
		DeviceIdentifier = Adapters(BestAdapterIndex);

		debugf(NAME_Init,TEXT("DukeForever Direct3D support initializing."));

		// Init pyramic-compressed scaling tables.
		for( INT A=0; A<128; A++ )
		{
			for( INT B=0; B<=A; B++ )
			{
				INT M=Max(A,1);
				RScale[PYR(A)+B] = (Min((B*0x08000)/M,0x7C00) & 0xf800);
				GScale[PYR(A)+B] = (Min((B*0x00400)/M,0x03e0) & 0x07e0);
				BScale[PYR(A)+B] = (Min((B*0x00020)/M,0x001f) & 0x001f);
			}
		}

		D3D_CHECK(Direct3D8->GetAdapterDisplayMode(BestAdapterIndex,&OriginalDisplayMode));
	}

	UBOOL __fastcall Init( UViewport* InViewport, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
	{
		DescFlags=RDDESCF_Certified;

		// Ensure that D3D has been properly initialized:
		InitD3D();

		Description=appFromAnsi(DeviceIdentifier.Description);

		// Local settings:
		Viewport=InViewport;
		DistanceFogEnabled=UseDistanceFog=FALSE;

		return SetRes( NewX, NewY, NewColorBytes, Fullscreen );
	}

	void __fastcall Exit()
	{
		UnSetRes(NULL,0);  

		if(Viewport) Flush(0); // (Unsetres calls flush anyways)
		else
		{
			CleanupVertexBuffers();
			RestoreGamma();
			
			SAFETRY(SafeRelease(Direct3DDevice8));
		}
	}
	void ShutdownAfterError()
	{
		ErrorCalled=true;
		debugf(NAME_Exit, TEXT("UD3DRenderDevice::ShutdownAfterError"));
		UnSetRes(NULL,0);

		SAFETRY(SafeRelease(Direct3DDevice8));
	}

	void UpdateGamma( UViewport* Viewport )
	{
		UBOOL UseWindowedGamma = UseEditorGammaCorrection && GIsEditor;

		if( Direct3DDevice8 && (ViewportFullscreen||UseWindowedGamma) && (DeviceCaps8.Caps2 & D3DCAPS2_FULLSCREENGAMMA) )
		{
			FLOAT Brightness = Viewport->GetOuterUClient()->Brightness;

			Brightness*=2;
			if(Brightness<=0) Brightness=0.01f;
			D3DGAMMARAMP Ramp;
			for( INT x=0; x<256; x++ )
			{
					Ramp.red[x] = Ramp.green[x] = Ramp.blue[x] = Clamp<INT>(appPow(x/255.0,1.0/Brightness)*65535.0,0,65535);
			}
			Direct3DDevice8->SetGammaRamp(D3DSGR_CALIBRATE, &Ramp);
		}
	}

	void RestoreGamma()
	{
		if( Direct3DDevice8 && (DeviceCaps8.Caps2 & D3DCAPS2_FULLSCREENGAMMA) )
		{
			D3DGAMMARAMP Ramp;
			for( INT x=0; x<256; x++ )
				Ramp.red[x] = Ramp.green[x] = Ramp.blue[x] = x << 8;
			Direct3DDevice8->SetGammaRamp(D3DSGR_CALIBRATE, &Ramp);		
		}
	}
	
	void __fastcall Flush( UBOOL AllowPrecache )
	{
		if( Direct3DDevice8 )
		{
			for( DWORD i=0; i<DeviceCaps8.MaxSimultaneousTextures; i++ )
			{
				SetTextureNULL(i);
			}

			while(CachedTextures)
			{
				FTexInfo*	TexInfo = CachedTextures;

				CachedTextures = TexInfo->NextTexture;

				TexInfo->Filler->PixelFormat->ActiveRAM=0; 
				TexInfo->Filler->PixelFormat->BinnedRAM=0; 
				TexInfo->Filler->PixelFormat->Active=0; 
				TexInfo->Filler->PixelFormat->Binned=0; 
				if(TexInfo->Texture8)
					D3D_CHECK(SafeRelease(TexInfo->Texture8));

				SafeDelete(TexInfo);
			};

			PaletteIndex = 0;

			for( i=0; i<ARRAY_COUNT(TextureHash); i++ )
				TextureHash[i]=NULL;

			UBOOL UseWindowedGamma = UseEditorGammaCorrection && GIsEditor;

			if( (ViewportFullscreen||UseWindowedGamma) && DeviceCaps8.Caps2 & D3DCAPS2_FULLSCREENGAMMA)
			{
				FLOAT Brightness = Viewport->GetOuterUClient()->Brightness;

				D3DGAMMARAMP Ramp;
				Brightness*=2;
			    if(Brightness<=0) Brightness=0.01;

				for( INT x=0; x<256; x++ )
				{
						Ramp.red[x] = Ramp.green[x] = Ramp.blue[x] = Clamp<INT>(appPow(x/255.0,1.0/Brightness)*65535.0,0,65535);

				}
				Direct3DDevice8->SetGammaRamp(D3DSGR_CALIBRATE, &Ramp);				
			}

			Direct3DDevice8->SetStreamSource(0,NULL,0);
			Direct3DDevice8->SetIndices(NULL,0);
		}

		if( AllowPrecache )
			PrecacheOnFlip = UsePrecache;
	}

	void __fastcall PreRender( FSceneNode* Frame )
	{
		// Setup view matrix.
		memset( &ViewMatrix, 0, sizeof(ViewMatrix));
		ViewMatrix._11 = Frame->Coords.XAxis.X;
		ViewMatrix._12 = -Frame->Coords.YAxis.X;
		ViewMatrix._13 = Frame->Coords.ZAxis.X;
		ViewMatrix._21 = Frame->Coords.XAxis.Y;
		ViewMatrix._22 = -Frame->Coords.YAxis.Y;
		ViewMatrix._23 = Frame->Coords.ZAxis.Y;
		ViewMatrix._31 = Frame->Coords.XAxis.Z;
		ViewMatrix._32 = -Frame->Coords.YAxis.Z;
		ViewMatrix._33 = Frame->Coords.ZAxis.Z;
		ViewMatrix._41 = Frame->Coords.XAxis | -Frame->Coords.Origin;
		ViewMatrix._42 = Frame->Coords.YAxis | Frame->Coords.Origin;
		ViewMatrix._43 = Frame->Coords.ZAxis | -Frame->Coords.Origin;
		ViewMatrix._44 = 1;

		// Setup inverse view matrix.
		D3DXMatrixInverse( &InvViewMatrix, NULL, &ViewMatrix );
		Direct3DDevice8->SetTransform( D3DTS_VIEW, &ViewMatrix );

		// ONLY X-movement seems correct...
		// _Not_ just transpose of the Viewmatrix above ???
		// Alternative arrangement for vertex shader.
		// just output Y and Z reversed works!!!
		FCoords View = Frame->Coords;
		ViewMatrix4x3._11 =  View.XAxis.X;
		ViewMatrix4x3._12 =  View.XAxis.Y;
		ViewMatrix4x3._13 =  View.XAxis.Z;
		ViewMatrix4x3._14 = -View.XAxis | View.Origin;
		ViewMatrix4x3._21 = -View.YAxis.X;
		ViewMatrix4x3._22 = -View.YAxis.Y;
		ViewMatrix4x3._23 = -View.YAxis.Z;
		ViewMatrix4x3._24 =  View.YAxis | View.Origin;
		ViewMatrix4x3._31 = -View.ZAxis.X;
		ViewMatrix4x3._32 = -View.ZAxis.Y;
		ViewMatrix4x3._33 = -View.ZAxis.Z;
		ViewMatrix4x3._34 =  View.ZAxis | View.Origin;
		ViewMatrix4x3._41 = 0.0f;
		ViewMatrix4x3._42 = 0.0f;
		ViewMatrix4x3._43 = 0.0f;
		ViewMatrix4x3._44 = 1.0f;

		if(Frame->Viewport->IsOrtho())
		{
			FLOAT	Width = Frame->Zoom * Frame->FX2,
					Height = Frame->Zoom * Frame->FY2;

			appMemzero( &ProjectionMatrix, sizeof(ProjectionMatrix));
			ProjectionMatrix._11 = 1.0f / Width;
			ProjectionMatrix._22 = 1.0f / Height;
			ProjectionMatrix._44 = 1.0f;
		}
		else
		{
			// Setup projection matrix.
			appMemzero( &ProjectionMatrix, sizeof(ProjectionMatrix));
			FLOAT wNear=NEAR_CLIP, wFar=FAR_CLIP;
			FLOAT FOV = Frame->Viewport->Actor->FovAngle * PI/360.f;
			ProjectionMatrix._11 = 1/appTan( FOV );
			ProjectionMatrix._22 = Frame->FX / appTan( FOV ) / Frame->FY;
			ProjectionMatrix._33 = wFar / (wFar - wNear);
			ProjectionMatrix._34 = 1.f;
			ProjectionMatrix._43 = -ProjectionMatrix._33 * wNear;
			ProjectionMatrix._44 = 0.f;

			// Hacked part-negative matrix for skeletal -> FIX at skeletal shader(viewmatrix?) level instead!
			D3DXMATRIX NegativeMatrix;
			appMemzero( &NegativeMatrix, sizeof(NegativeMatrix) );
			NegativeMatrix._11 = 1/appTan( FOV );
			NegativeMatrix._22 = Frame->FX / appTan( FOV ) / Frame->FY;
			NegativeMatrix._33 =- wFar / (wFar - wNear);
			NegativeMatrix._34 =- 1.f;
			NegativeMatrix._43 =- -NegativeMatrix._33 * wNear;
			NegativeMatrix._44 =- 0.f;
			D3DXMatrixMultiply(&ProjViewMatrix, &NegativeMatrix, &ViewMatrix4x3);
		}

		Direct3DDevice8->SetTransform( D3DTS_PROJECTION, &ProjectionMatrix );

		// disable hardware lighting mode
		Direct3DDevice8->SetRenderState( D3DRS_LIGHTING, 0 ); 
	}

	void __fastcall Lock( FColor FogColor, float FogDensity, INT FogDistance, FPlane InFlashScale, FPlane InFlashFog, FPlane ScreenClear, DWORD InLockFlags, BYTE* InHitData, INT* InHitSize )
	{
		LockCount++; 
		if(!GIsEditor) 
		{
			//check(LockCount==1);
		}

		INT FailCount=0;
		FrameCounter++;

		// NJS: Deal with multi-viewport strangeness in the editor:
		if(GIsEditor)
		{			
			ZBias=-1.f;	// Set ZBias to an invalid state to force it to be reset next time SetZBias is called
			AlphaBlendEnable=-1;
			// BeginSceneCount=0;	// Should match up reguardless
			SrcBlend=(D3DBLEND)0; // Setting Src Blending to an invalid state will force it to be reset next time SetSrcBlend is called.
			DstBlend=(D3DBLEND)0; // Setting Dst Blending to an invalid state will force it to be reset next time SetSrcBlend is called.
			SetBlending(0xFFFFFFFF,0xFFFFFFFF);	// NJS: FIXME
			SetBlending(0,0);					// NJS: FIXME
			SetDistanceFog(true);
			SetDistanceFog(false);
			SetTextureNULL(0);
			SetTextureNULL(1);
		}

		{
			DistanceFogColor=FogColor;
			DistanceFogBegin=FogDistance;
			FLOAT FogDensitySquared=FogDensity*FogDensity;
			if(!FogDensitySquared) FogDensitySquared=0.001f;
			if(FogDensity<DistanceFogBegin) DistanceFogEnd=DistanceFogBegin+700.f;
			else DistanceFogEnd=FogDensity;
		}

		UseDistanceFog=(bool)((LockFlags&LOCKR_LightDiminish));
		SetDistanceFog(false);

		// Remember parameters.
		LockFlags  = InLockFlags;
		FlashScale = InFlashScale;
		FlashFog   = InFlashFog;

		// Hit detection.
		HitCount   = 0;
		HitData    = InHitData;
		HitSize    = InHitSize;

		// Check cooperative level.
		HRESULT hr=NULL, hr2=NULL;
		verify(Direct3DDevice8);
		hr=Direct3DDevice8->TestCooperativeLevel();
		if( hr!=D3D_OK )
		{
			debugf(TEXT("TestCooperativeLevel failed (%s)"),DXGetErrorString8(hr));
			Failed:
			// D3DERR_DEVICELOST is returned if the device was lost, but exclusive mode isn't available again yet.
			// D3DERR_DEVICENOTRESET is returned if the device was lost, but can be reset.

			// Wait to regain exclusive access to the device.

			do hr2=Direct3DDevice8->TestCooperativeLevel();
			while(hr2==D3DERR_DEVICELOST);

			if(hr2==D3DERR_DEVICENOTRESET)
			{
				debugf(TEXT("Resetting mode (%s)"),DXGetErrorString8(hr2));
				if( !SetRes(ViewportX, ViewportY, ViewportColorBits/8, ViewportFullscreen) )
					if(!ErrorCalled)
					{
						ErrorCalled=true;
						appErrorf(TEXT("Failed resetting mode. (%s)"),DXGetErrorString8(hr2));
					}
			}
		}

		// Lock the back buffer to prevent the driver from queueing frames, causing 'input lag':
		if(!GIsEditor)
		{
			IDirect3DSurface8 *BackBuffer;
			Direct3DDevice8->GetBackBuffer(0,D3DBACKBUFFER_TYPE_MONO,&BackBuffer);
			D3DLOCKED_RECT Rect;
			BackBuffer->LockRect(&Rect,NULL,D3DLOCK_READONLY|D3DLOCK_NO_DIRTY_UPDATE );
			BackBuffer->UnlockRect();
			SafeRelease(BackBuffer);
		}
		
		// Clear the Z-buffer.
		Direct3DDevice8->Clear( 0, NULL, D3DCLEAR_ZBUFFER | ((LockFlags & LOCKR_ClearScreen) ? D3DCLEAR_TARGET : 0), (D3DCOLOR)FColor(ScreenClear).TrueColor(), 1.f, 0 );

		// Init stats.
		memset( &Stats, 0, sizeof(Stats) );
		for( FPixFormat* Fmt=FirstPixelFormat; Fmt; Fmt=Fmt->Next )
			Fmt->ResetStats();

		// Begin scene.
		//check(BeginSceneCount==0);
		if( FAILED(h=Direct3DDevice8->BeginScene()) )
		{
			if( ++FailCount==1 )
				goto Failed;

			appErrorf(TEXT("BeginScene failed (%s)"),DXGetErrorString8(h));
		}

		BeginSceneCount++;
	}

	void __fastcall PrecacheTexture( FTextureInfo& Info, DWORD PolyFlags, DWORD PolyFlagsEx )
	{
		SetTexture( 0, Info, PolyFlags|Info.Texture->PolyFlags, 1, PolyFlagsEx|Info.Texture->PolyFlagsEx );
		PrecacheCycle = 1;
	}

	void __fastcall Unlock( BOOL Blit )
	{
		LockCount--; 
		if(!GIsEditor)
		{
			//check(LockCount==0);
		}

		check(Direct3DDevice8);

	#ifdef BATCH_PROJECTOR_POLYS
		FlushProjectorPolys();
	#endif

		//Direct3DDevice8->EndScene();
		EndScene();

		if( PrecacheCycle )
		{
			PrecacheCycle = 0;
		}
		if( Blit )
			Direct3DDevice8->Present(NULL,NULL,NULL,NULL);

		// Hit detection.
		check(HitStack.Num()==0);
		if( HitSize )
			*HitSize = HitCount;
	}

	void __fastcall DrawComplexSurface( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet )
	{
		if(!RenderSurfaces) 
			return;

		clock(Stats.SurfTime);
		Stats.Surfs++;

		PreRender(Frame);
		UBOOL bHeatVision  = (Frame->Viewport->Actor->CameraStyle == PCS_HeatVision);  
		UBOOL bNightVision = (Frame->Viewport->Actor->CameraStyle == PCS_NightVision); 
		
		FColor myFinalColor( 255, 255, 255, 0 );
		if(bHeatVision)
		{
			myFinalColor.R = 7.5f;
			myFinalColor.G = 0.f;
			myFinalColor.B = 38.f;
			Surface.PolyFlags&=~PF_FlatShaded;
		} else if(bNightVision) 
		{
			myFinalColor.R = 0.f;
			myFinalColor.G = 128.f;
			myFinalColor.B = 0.f;
			Surface.PolyFlags&=~PF_FlatShaded;
		}

		// Mutually exclusive effects.
		if((Surface.DetailTexture && Surface.FogMap) || (!DetailTextures))
			Surface.DetailTexture = NULL;

		INT VertexCount=0;
		for( FSavedPoly* Poly=Facet.Polys; Poly; Poly = Poly->Next )
			VertexCount += Poly->NumPts;
		UBOOL IsSelected = GIsEditor && (( Surface.PolyFlags & PF_Selected )!= 0);
		DWORD SurfPolyFlags   = ( Surface.PolyFlags & ~PF_Selected ) | PF_TwoSided | (Surface.Texture->Texture->PolyFlags);
		DWORD SurfPolyFlagsEx = Surface.PolyFlagsEx | (Surface.Texture->Texture->PolyFlagsEx);

		SetDistanceFog(!(SurfPolyFlags&PF_Unlit));
		SetZBias(0);

		INT StoreVertInfo = (IsSelected) + (Surface.LightMap!=NULL) + (Surface.MacroTexture!=NULL) + (Surface.DetailTexture!=NULL) + (Surface.FogMap!=NULL) + (ProjectorArray.Num() > 0);		

		WorldVertices.Set();

		// Render texture and lightmap. 
		if( /*UseMultitexture &&*/ Surface.LightMap!=NULL && Surface.MacroTexture==NULL )
		{
			StoreVertInfo--;
			// Use multitexturing when rendering base + lightmap.			
			if(SurfPolyFlags&PF_FlatShaded)
			{
				SetTextureNULL( 0 );
				SetTextureNULL( 1 );
				SetBlending();
			}
			else
			{
				SetTexture( 0, *Surface.Texture, SurfPolyFlags, 0, SurfPolyFlagsEx );
				SetTexture( 1, *Surface.LightMap, 0, 0, true );
				// PF_Memorize to signify multitexturing.
				SetBlending( SurfPolyFlags|PF_Memorized, SurfPolyFlagsEx );
			}
			// Set up all poly vertices.
			FD3DScreenVertex* V=(FD3DScreenVertex*) WorldVertices.Lock(VertexCount);
			D3DCOLOR clr;

			if(Surface.PolyFlags&PF_FlatShaded)
				clr = FColor( Surface.FlatColor).TrueColor() | 0xff000000;
			else
				clr = FColor(Stages[0]->MaxColor.Plane() * Stages[1]->MaxColor.Plane()).TrueColor() | 0xff000000;

			if(bHeatVision||bNightVision)
			{
				clr=myFinalColor.TrueColor() | 0xFF000000;
			}

			if(SurfPolyFlagsEx&(PFX_LightenModulate|PFX_DarkenModulate))
			{
				clr=0xFFFFFFFF;
			}
			else if(SurfPolyFlags&PF_Modulated)
			{
				clr = (0xFF<<24)|(248<<16)|(248<<8)|248;	// NJS: 248 is the darkening correction needed to remove boxes from modulated decals, etc
			}

			INT n=0;
			for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
			{
				for( INT i=0; i<Poly->NumPts; i++, n++, V++ )
				{
					GET_COLOR_DWORD(V->Color)   = clr;
					FLOAT R = V->Position.W   = Poly->Pts[i]->RZ * Frame->RProj.Z;
					FLOAT Z = V->Position.Z    = ProjectionMatrix._33 + ProjectionMatrix._43 * R;					
					FLOAT Y = V->Position.Y    = Poly->Pts[i]->ScreenY + Frame->YB - 0.5f; 
					FLOAT X = V->Position.X    = Poly->Pts[i]->ScreenX + Frame->XB - 0.5f;
					
					//X=V->Position.X+= (appSin(Poly->Pts[i]->Point.Y+appSeconds()*2.2f)*3.1f);  // NJS: Caustics simulation
					
					FVector TexPlane = (*(FVector*)Poly->Pts[i] - Facet.MapCoords.Origin);
					FLOAT u  = Facet.MapCoords.XAxis | TexPlane;
					FLOAT v  = Facet.MapCoords.YAxis | TexPlane;

					// *************************
					// NJS: Been getting random crashes around here recently, so just be sure of a few things:
					check(Surface.Texture);
					check(Surface.LightMap);
					check(Stages[0]);
					check(Stages[1]);
					check(V);
					check(V->U);
					check(V->U2);
					// *************************

					V->U [0] = (u - Surface.Texture->Pan.X                                   ) * Stages[0]->UScale;
					V->U [1] = (v - Surface.Texture->Pan.Y                                   ) * Stages[0]->VScale;
					V->U2[0] = (u - Surface.LightMap->Pan.X + 0.5f * Surface.LightMap->UScale) * Stages[1]->UScale;
					V->U2[1] = (v - Surface.LightMap->Pan.Y + 0.5f * Surface.LightMap->VScale) * Stages[1]->VScale;

					//V->U[2] = 1.0f;
					//V->U[3] = 1.0f;
					
					if( StoreVertInfo ) 
					{
						check(n<ARRAY_COUNT(Verts));
						Verts[n].Position.X = X;    
						Verts[n].Position.Y = Y;
						Verts[n].Position.Z = Z;
						Verts[n].Position.W = R;
						Verts[n].U[0]= u;
						Verts[n].U[1]= v;
					}			
				}
			}

			// Draw base texture + lightmap.
			INT First = WorldVertices.Unlock();
		
			for( Poly=Facet.Polys; Poly; Poly=Poly->Next)
			{
				Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, Poly->NumPts - 2 );
				First += Poly->NumPts;
				Stats.Polys++;
			}

			SetTextureNULL(1);
			// Handle depth buffering the appropriate areas of masked textures.
			if( SurfPolyFlags & PF_Masked )
				Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_EQUAL );
		}
		else
		{
			// Set up all poly vertices.
			if(SurfPolyFlags&PF_FlatShaded)
			{
				SetTextureNULL(0);
				SetTextureNULL(1);
				SetBlending();
			} else
			{
				SetTexture( 0, *Surface.Texture, SurfPolyFlags, 0 );
				SetBlending( SurfPolyFlags&~PF_Memorized, SurfPolyFlagsEx );
			}

			// Count things to draw to plan when to do the final color-scaling pass.
			INT ModulateThings = (Surface.Texture!=NULL) + (Surface.LightMap!=NULL) + (Surface.MacroTexture!=NULL);
			FPlane FinalColor(1,1,1,1);			
			FD3DScreenVertex* V=(FD3DScreenVertex*) WorldVertices.Lock(VertexCount);
			D3DCOLOR Clr;
			if( SurfPolyFlags & PF_FlatShaded )
				Clr = FColor( Surface.FlatColor).TrueColor() | 0xff000000;
			else
				Clr = UpdateModulation( ModulateThings, FinalColor, Stages[0]->MaxColor.Plane() );

			if(bHeatVision||bNightVision)
			{
				Clr=myFinalColor.TrueColor() | 0xFF000000;
			}

			if(SurfPolyFlagsEx&(PFX_LightenModulate|PFX_DarkenModulate))
			{
				Clr=0xFFFFFFFF;
			}
			else if(SurfPolyFlags&PF_Modulated)
			{
				Clr = (0xFF<<24)|(248<<16)|(248<<8)|248;
			}

			INT n=0;
			//Queued3DLinesFlush(Frame);

			for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
			{
				// Set up vertices.
				for( INT i=0; i<Poly->NumPts; i++, n++, V++ )
				{
					GET_COLOR_DWORD(V->Color) = Clr;
					//GET_COLOR_DWORD(V->Color) =appRand() ^ (appRand()<<16);
					FLOAT X = V->Position.X  = Poly->Pts[i]->ScreenX + Frame->XB - 0.5f;
					FLOAT Y = V->Position.Y  = Poly->Pts[i]->ScreenY + Frame->YB - 0.5f;
					FLOAT R = V->Position.W = Poly->Pts[i]->RZ * Frame->RProj.Z;
					FLOAT Z = V->Position.Z  = ProjectionMatrix._33 + ProjectionMatrix._43 * R;
					FVector TexPlane = (*(FVector*)Poly->Pts[i] - Facet.MapCoords.Origin);
					FLOAT u  = Facet.MapCoords.XAxis | TexPlane;
					FLOAT v  = Facet.MapCoords.YAxis | TexPlane;
					V->U[0] = (u - Surface.Texture->Pan.X) * Stages[0]->UScale;
					V->U[1] = (v - Surface.Texture->Pan.Y) * Stages[0]->VScale;

					if( StoreVertInfo )
					{
						Verts[n].Position.X = X;    
						Verts[n].Position.Y = Y;
						Verts[n].Position.Z = Z;
						Verts[n].Position.W = R;
						Verts[n].U[0]= u;
						Verts[n].U[1]= v;
					}
				}
			}

			// Draw bare base texture.
			INT First = WorldVertices.Unlock();
			//WorldVertices.Set();
			for( Poly=Facet.Polys; Poly; n+=Poly->NumPts,Poly=Poly->Next)
			{
				Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, Poly->NumPts - 2 );
				First += Poly->NumPts;
				Stats.Polys++;
			}

			SetDistanceFog(false);

			// Handle depth buffering the appropriate areas of masked textures.
			if( SurfPolyFlags & PF_Masked )
				Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_EQUAL );
			
			// Macrotexture.
			if( Surface.MacroTexture )
			{
				// Set the macrotexture.
				SetBlending( PF_Modulated );
				SetTexture( 0, *Surface.MacroTexture, 0, 0 );
				D3DCOLOR Clr = UpdateModulation( ModulateThings, FinalColor, Stages[0]->MaxColor.Plane() );
				FD3DScreenVertex* V=(FD3DScreenVertex*) WorldVertices.Lock(VertexCount);
				INT n=0;
				for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
				{
					for( INT i=0; i<Poly->NumPts; i++,n++,V++ )
					{
						V->Color = Clr;
						V->Position.X = Verts[n].Position.X;    
						V->Position.Y = Verts[n].Position.Y;
						V->Position.W = Verts[n].Position.W;
						V->Position.Z = Verts[n].Position.Z;
						V->U[0] = (Verts[n].U[0] - Surface.MacroTexture->Pan.X) * Stages[0]->UScale;
						V->U[1] = (Verts[n].U[1] - Surface.MacroTexture->Pan.Y) * Stages[0]->VScale;
					}
				}

				// Draw.
				INT First = WorldVertices.Unlock();

				for( Poly=Facet.Polys; Poly; n+=Poly->NumPts,Poly=Poly->Next)
				{
					Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN,  First, Poly->NumPts - 2 );
					First += Poly->NumPts;
					Stats.Polys++;
				}
			}

			// Non-multitextured light map.
			if( Surface.LightMap )
			{
				// Set the light map.
				SetBlending( PF_Modulated );
				SetTexture( 0, *Surface.LightMap, 0, 0 );
				D3DCOLOR Clr = UpdateModulation( ModulateThings, FinalColor, Stages[0]->MaxColor.Plane() );
				FD3DScreenVertex* V=(FD3DScreenVertex*) WorldVertices.Lock(VertexCount);
				INT n=0;
				for( Poly=Facet.Polys; Poly; Poly=Poly->Next )
				{
					for( INT i=0; i<Poly->NumPts; i++,n++,V++ )
					{
						V->Color = Clr;
						V->Position.X  = Verts[n].Position.X;    
						V->Position.Y  = Verts[n].Position.Y;
						V->Position.W = Verts[n].Position.W;
						V->Position.Z  = Verts[n].Position.Z;
						V->U[0] = (Verts[n].U[0] - Surface.LightMap->Pan.X + 0.5f * Surface.LightMap->UScale) * Stages[0]->UScale;
						V->U[1] = (Verts[n].U[1] - Surface.LightMap->Pan.Y + 0.5f * Surface.LightMap->VScale) * Stages[0]->VScale;
					}
				}

				// Draw.
				INT First = WorldVertices.Unlock();

				for( Poly=Facet.Polys; Poly; n+=Poly->NumPts,Poly=Poly->Next)
				{
					Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, Poly->NumPts - 2 );
					First += Poly->NumPts;
					Stats.Polys++;
				}
			}
		}

		SetDistanceFog(false);

		// Draw detail texture overlaid.
		if(Surface.DetailTexture&&!(SurfPolyFlags&PF_FlatShaded)) 
		{			
			INT DetailMax = 1; 

			FLOAT DetailScale=1.f; 
			FLOAT LocalNearZ=NearZ; //380.0f;
			//if( !GIsEditor )
				*Surface.DetailTexture->MaxColor = FColor(255,255,255,255);
			
			INT AreDetailing = 0;			
			while( DetailMax-- > 0 )			
			{				
				FLOAT InvZ = (1.f/LocalNearZ);
				FLOAT SZ = ProjectionMatrix._33 + ProjectionMatrix._43 * InvZ;

				INT n=0;
				for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
				{
					UBOOL IsNear[32], CountNear = 0;				
					// Any textures close enough that they need detail texturing ?
					for( INT i=0; i<Poly->NumPts; i++ )
					{
						IsNear[i] = Poly->Pts[i]->Point.Z < LocalNearZ;
						CountNear += IsNear[i];
					}										
					if( CountNear )
					{
						INT NumNear = 0;
						FD3DScreenVertex* V=(FD3DScreenVertex*) WorldVertices.Lock(32);  // Safe upper limit for (clipped) facet's triangles * 3						
						// Prepare state, minimize changes.
						if( AreDetailing==0 ) 
						{
							SetBlending( PF_Modulated );
							Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_BLENDDIFFUSEALPHA );
							SetZBias(15.f);
							SetTexture( 0, *Surface.DetailTexture, 0, 0 );
							AreDetailing = 1;
						}
						// j = one before i; m is one before n;  n is the index into serialized predigested vertex MasterU/V
						for( INT i=0, j=Poly->NumPts-1, m=n+Poly->NumPts-1; i<Poly->NumPts; j=i++, m=n++ )
						{	
							// Extra vertex if needed to create a new boundary of visible detailing.
							if( IsNear[i] ^ IsNear[j] )
							{
								// near-point-to-detailboundary distance divided by full edge Z distance.
								// slip Z, X and Y up to that point.
								FLOAT G    = (Poly->Pts[i]->Point.Z - LocalNearZ) / (Poly->Pts[i]->Point.Z - Poly->Pts[j]->Point.Z);
								FLOAT F    = 1.f - G;
								V->Position.W = InvZ;
								V->Position.Z = SZ;
								V->Position.X = (F * Poly->Pts[i]->ScreenX * Poly->Pts[i]->Point.Z + G * Poly->Pts[j]->ScreenX * Poly->Pts[j]->Point.Z) * InvZ + Frame->XB - 0.5f;
								V->Position.Y = (F * Poly->Pts[i]->ScreenY * Poly->Pts[i]->Point.Z + G * Poly->Pts[j]->ScreenY * Poly->Pts[j]->Point.Z) * InvZ + Frame->YB - 0.5f;
								if(!WorldDetail)
								{
									V->U[0] = (F * Verts[n].U[0] + G * Verts[m].U[0] - Surface.DetailTexture->Pan.X) * Stages[0]->UScale * DetailScale;
									V->U[1] = (F * Verts[n].U[1] + G * Verts[m].U[1] - Surface.DetailTexture->Pan.Y) * Stages[0]->VScale * DetailScale;
								} else
								{
									V->U[0] = (F * Verts[n].U[0] + G * Verts[m].U[0] - Surface.DetailTexture->Pan.X) * DetailScale * 0.052083;
									V->U[1] = (F * Verts[n].U[1] + G * Verts[m].U[1] - Surface.DetailTexture->Pan.Y) * DetailScale * 0.052083 ;

								}

								V->Color = D3DCOLOR_RGBA(0x7F, 0x7F, 0x7F, 0);
								V++;
								NumNear++;
							}
							if( IsNear[i] )
							{
								V->Position.W =Verts[n].Position.W;
								V->Position.Z =Verts[n].Position.Z;
								V->Position.X =Verts[n].Position.X;
								V->Position.Y =Verts[n].Position.Y;
								if(!WorldDetail)
								{
									V->U[0] = (Verts[n].U[0] - Surface.DetailTexture->Pan.X) * Stages[0]->UScale * DetailScale;
									V->U[1] = (Verts[n].U[1] - Surface.DetailTexture->Pan.Y) * Stages[0]->VScale * DetailScale;
								} else
								{
									V->U[0] = (Verts[n].U[0] - Surface.DetailTexture->Pan.X) * DetailScale * 0.052083;
									V->U[1] = (Verts[n].U[1] - Surface.DetailTexture->Pan.Y) * DetailScale * 0.052083;

								}
								DWORD A               = Min<DWORD>( appRound(100.f * (LocalNearZ / Poly->Pts[i]->Point.Z - 1.f)), 255 );
								V->Color = D3DCOLOR_RGBA( 0x7F, 0x7F, 0x7F, A );
								V++;
								NumNear++;
							}

						}
						n -= Poly->NumPts;
						
						INT First = WorldVertices.Unlock();

						Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, NumNear - 2 );
						Stats.Polys++;
					}							
					n += Poly->NumPts;
				}
				DetailScale *= 4.223f;
				LocalNearZ  /= 4.223f;
			}		
			if( AreDetailing )
			{
				Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
				SetZBias(0);
				AreDetailing = 0;
			}
		}
		else if( Surface.FogMap )
		{
			SetBlending( PF_Highlighted );
			SetTexture( 0, *Surface.FogMap, 0, 0 );
			D3DCOLOR Clr = Stages[0]->MaxColor.TrueColor() | 0xff000000;
			if( !Format8888.Supported ) // Texture has no alpha.
				Clr&=~0xff000000;

			FD3DScreenVertex* V=(FD3DScreenVertex*) WorldVertices.Lock(VertexCount);
			INT n = 0;
			for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
			{
				for( INT i=0; i<Poly->NumPts; i++, n++, V++ )
				{
					GET_COLOR_DWORD(V->Color) = Clr;
					V->Position.X  = Verts[n].Position.X;    
					V->Position.Y  = Verts[n].Position.Y;
					V->Position.W = Verts[n].Position.W;
					V->Position.Z  = Verts[n].Position.Z;
					V->U[0] = (Verts[n].U[0] - Surface.FogMap->Pan.X + 0.5f * Surface.FogMap->UScale) * Stages[0]->UScale;
					V->U[1] = (Verts[n].U[1] - Surface.FogMap->Pan.Y + 0.5f * Surface.FogMap->VScale) * Stages[0]->VScale;
				}
			}
			// Draw 
			INT First = WorldVertices.Unlock();

			for( Poly=Facet.Polys; Poly; n+=Poly->NumPts,Poly=Poly->Next)
			{
				Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, Poly->NumPts - 2 );
				First += Poly->NumPts;
				Stats.Polys++;
			}		
		}

		if( Surface.PolyFlags & PF_FlatShaded )  // Wireframe Overlay
		{
			SetZBias(16.f);
						// Set up all poly vertices.
			FD3DScreenVertex* V=(FD3DScreenVertex*) WorldVertices.Lock(VertexCount);
			
			for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
			{
				for( INT i=0; i<Poly->NumPts; i++, V++ )
				{
					GET_COLOR_DWORD(V->Color)   = 0; //clr;
					V->Position.X    = Poly->Pts[i]->ScreenX + Frame->XB - 0.5f;
					V->Position.Y    = Poly->Pts[i]->ScreenY + Frame->YB - 0.5f;
					FLOAT R = V->Position.W   = Poly->Pts[i]->RZ * Frame->RProj.Z;
					V->Position.Z    = ProjectionMatrix._33 + ProjectionMatrix._43 * R;								
				}
			}

			// Draw base texture + lightmap.
			INT First = WorldVertices.Unlock();
			WorldVertices.Set();

			
			//First=OriginalFirst;
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_DISABLE  );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_DISABLE );
			
			for( Poly=Facet.Polys; Poly; Poly=Poly->Next)
			{
				Direct3DDevice8->DrawPrimitive( D3DPT_LINESTRIP,First,Poly->NumPts-1); 
				First += Poly->NumPts;
			}
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
			
			SetZBias(0.f);
		}

		//	Draw selection markings on a surface: specular overlay.
		if( IsSelected )
		{
			SetBlending(PF_Translucent);
			SetTextureNULL( 0 );
			SetTextureNULL( 1 );

			INT n=0;
			for( FSavedPoly* Poly=Facet.Polys; Poly; Poly=Poly->Next )
			{
				// draw per facet...
				FD3DTLVertex* V=(FD3DTLVertex*) ActorVertices.Lock(Poly->NumPts);
				for( INT i=0; i<Poly->NumPts; i++, n++, V++ )
				{
					V->Position.X = Verts[n].Position.X;
					V->Position.Y = Verts[n].Position.Y;
					V->Position.Z = Verts[n].Position.Z;
					V->Position.W = Verts[n].Position.W;

					V->Specular   = D3DCOLOR_RGBA( 255,255,255,255);
					V->Diffuse    = D3DCOLOR_RGBA( 10,5,60,255);		 // Arbitrary marker color.
				}

				INT	First = ActorVertices.Unlock();

				ActorVertices.Set();

				Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, Poly->NumPts - 2 );
				Stats.Polys++;
			}
		}

		// JEP... Project all projector textures onto surface
		if (ProjectorArray.Num() > 0 && Frame->Recursion == 0 && Surface.ProjectorFlags)
		{
		#ifdef BATCH_PROJECTOR_POLYS
			ProjectorSurf		*ProjSurf;

			ProjSurf = &ProjectorSurfs[NumProjectorSurfs];

			ProjSurf->ProjectorFlags = Surface.ProjectorFlags;
			ProjSurf->FirstVert = NumProjectorVerts;
			ProjSurf->NumVerts = 0;
			ProjSurf->FirstPoly = NumProjectorPolys;
			ProjSurf->NumPolys = 0;

			INT		*PPoly = &ProjectorPolys[ProjSurf->FirstPoly];
			FVector *PP = &ProjectorPoints[ProjSurf->FirstVert];

			for( Poly=Facet.Polys; Poly; Poly=Poly->Next)
			{
				//if (!Frame->Level->Model->Nodes(Poly->iNode).ProjectorFlags)
				//	continue;

				PPoly[ProjSurf->NumPolys++] = Poly->NumPts;

				// Copy camera space verts over (need them to generate uv's during rendering pass)
				for (INT j=0; j< Poly->NumPts; j++)
					PP[ProjSurf->NumVerts++] = Poly->Pts[j]->Point;
			}

			memcpy(&ProjectorVerts[ProjSurf->FirstVert], &Verts[0], ProjSurf->NumVerts*sizeof(Verts[0]));
			
			NumProjectorVerts += ProjSurf->NumVerts;
			NumProjectorPolys += ProjSurf->NumPolys;
			
			NumProjectorSurfs++;

			if (NumProjectorSurfs > 64)
				FlushProjectorPolys();
		#else
			SetTextureNULL( 0 );
			SetTextureNULL( 1 );
			SetBlending( PF_Modulated );
			SetDistanceFog(false);

			SetTextureClampMode(1);

			//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
			//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_DESTCOLOR );
			//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_ZERO );
			SetAlphaBlendEnable(TRUE);
			SetSrcBlend(D3DBLEND_DESTCOLOR);
			SetDstBlend(D3DBLEND_ZERO);

			// Setup clipper texture (also used for fade out)
			Direct3DDevice8->SetTexture(1, ClipperTexture);
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_ADD);
			//Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_DISABLE);
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);

			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSU, D3DTADDRESS_CLAMP );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSV, D3DTADDRESS_CLAMP );

			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MAGFILTER, D3DTEXF_POINT);
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MINFILTER, D3DTEXF_POINT);
			
			for (int i=ProjectorArray.Num()-1; i>=0 ; i--)
			{
				DWORD Mask = 1<<i;

				if (!(Surface.ProjectorFlags & Mask))
					continue;

				ProjectorInfo *pProjector = &ProjectorArray(i);

				if (!pProjector->GNodes)
					continue;

				// Set the texture to the render target that belongs to this projector
				Direct3DDevice8->SetTexture(0, pProjector->pRenderTargetTex);

				// Lock the world verts
				FD3DScreenVertex* V=(FD3DScreenVertex*)WorldVertices.Lock(VertexCount);

				INT n = 0;

				// For each poly, project the verts onto the projector front plane to get the UV's
				for( Poly=Facet.Polys; Poly; Poly=Poly->Next)
				{
					if (!(pProjector->GNodes[Poly->iNode].ProjectorFlags & Mask))
					{
						n += Poly->NumPts;
						continue;
					}

					for( INT j=0; j<Poly->NumPts; j++, n++, V++ )
					{
						V->Position.X = Verts[n].Position.X;    
						V->Position.Y = Verts[n].Position.Y;
						V->Position.Z = Verts[n].Position.Z;
						V->Position.W = Verts[n].Position.W;
						V->Color = 0xffffffff;

						// Grab a copy of the vert
						FTransform		P;

						// Transform point into projector space
						P.Point = Poly->Pts[j]->Point.TransformPointBy(pProjector->CameraToLight);
						
					#if 1	
						// Project point onto projector front plane
						P.Point.Z = max(1.0f, P.Point.Z);
						P.Project(pProjector->Frame);

						// Snag UV's
						V->U[0] = P.ScreenX*pProjector->OneOverX;
						V->U[1] = P.ScreenY*pProjector->OneOverY; 
						
						V->Position.W *= P.Point.Z;
					#else
						// Ortho projection
						V->U[0] = (P.Point.X/125)+0.5f;
						V->U[1] = (P.Point.Y/125)+0.5f;
					#endif

						// Clip and fade out (this is the UV's for the clipper/fade out texture layer)
					#if 1
						FLOAT R = P.RZ * pProjector->Frame->RProj.Z;		// (1.0f/Z)
						V->U2[0] = (pProjector->_33 + pProjector->_43 * R)*pProjector->FadeScale;
						V->U2[1] = 0.0f;
					#endif
					}
				}

				// Unlock world verts
				INT First = WorldVertices.Unlock();

				for( Poly=Facet.Polys; Poly; Poly=Poly->Next)
				{
					if (!(pProjector->GNodes[Poly->iNode].ProjectorFlags & Mask))
						continue;
					Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, Poly->NumPts - 2 );
					First += Poly->NumPts;
				}
			}
			SetTextureNULL(0);
			SetTextureNULL(1);

			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_DISABLE);

			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MAGFILTER, D3DTEXF_LINEAR );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MINFILTER, D3DTEXF_LINEAR );

			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSU, D3DTADDRESS_WRAP );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSV, D3DTADDRESS_WRAP );

			//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
			//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_DESTCOLOR );
			//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_SRCCOLOR );
			SetAlphaBlendEnable(TRUE);
			SetSrcBlend(D3DBLEND_DESTCOLOR);
			SetDstBlend(D3DBLEND_SRCCOLOR);
			SetTextureClampMode(0);

		#endif
		}
		// ...JEP

		// Finish mask handling.
		if( SurfPolyFlags & PF_Masked )
			Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_LESSEQUAL );

		VALIDATE;

		unclock(Stats.SurfTime);
	}

	struct QueuedPolygon
	{
		DWORD PolyFlags,
			  PolyFlagsEx;
		FTextureInfo *Texture;
		UTexture *Tex;
		FTransTexture v[3];
	};

	TArray<QueuedPolygon> QueuedPolygons;

	bool __fastcall QueuePolygonDoes()  
	{ 
		return true; 
	}

	bool __fastcall QueuePolygonBegin(FSceneNode* Frame)
	{
		CurrentFrame=Frame;
		return true;
	}

	void __fastcall QueuePolygonEnd(DWORD ProjectorFlags = 0)
	{
		int QueuedPolygonCount=QueuedPolygons.Num();

		if(!QueuedPolygonCount) 
			return;

		check(Direct3DDevice8);

		clock(Stats.PolyTime);
		Stats.QueueCount++;
		Stats.Polys+=QueuedPolygonCount;

		PreRender(CurrentFrame);

		FLOAT ZBiasHack=((GUglyHackFlags&1)&&ViewportColorBits==16 )? 0.25f : 1.0f;

		int VertexCount=QueuedPolygonCount*3;
		verify(VertexCount<=ACTORPOLY_VERTEXBUFFER_SIZE);
		clock(Stats.D3DVertexLock);

		FD3DTLVertex *Vertex = (FD3DTLVertex*)ActorVertices.Lock(VertexCount);
		Stats.VBLocks++;
		unclock(Stats.D3DVertexLock);

		clock(Stats.D3DVertexSetup);

		INT	 n = 0;
		BOOL StoreVert = (ProjectorArray.Num() > 0 && CurrentFrame->Recursion == 0 && ProjectorFlags) ? true : false;

		for(int i=0;i<QueuedPolygonCount;i++)
		{
			QueuedPolygon &p=QueuedPolygons(i);				

			SetTexture(0,*p.Texture, p.PolyFlags, false,p.PolyFlagsEx );	// NJS: Fixme! No need for texture set to be here other than to compute scaling factors

			UBOOL DoFog=((p.PolyFlags&(PF_RenderFog|PF_Translucent|PF_Modulated))==PF_RenderFog);		

			for( INT Index = 0; Index < 3; Index++ )
			{	
				FD3DTLVertex V;
				FLOAT	RHW = ZBiasHack * p.v[Index].RZ * CurrentFrame->RProj.Z;

				V.Position.X = p.v[Index].ScreenX + CurrentFrame->XB - 0.5f;
				V.Position.Y = p.v[Index].ScreenY + CurrentFrame->YB - 0.5f;
				V.Position.Z = ProjectionMatrix._33 + ProjectionMatrix._43 * RHW;
				V.Position.W = RHW;

				// JEP...
				if (StoreVert)
				{
					Verts[n].Position.X = V.Position.X;
					Verts[n].Position.Y = V.Position.Y;
					Verts[n].Position.Z = V.Position.Z;
					Verts[n].Position.W = V.Position.W;
					n++;
				}
				// JEP...

				V.U[0] = p.v[Index].U * Stages[0]->UScale;
				V.U[1] = p.v[Index].V * Stages[0]->VScale;

				V.Specular=0;
				if(p.PolyFlagsEx&(PFX_LightenModulate|PFX_DarkenModulate))
				{
					V.Diffuse  = 0xffffffff;

				}
				else if ( p.PolyFlags & PF_Modulated )
				{
					// NJS: Diffuse is scaled down to compensate for the fact that the src=dst dst=src blending 
					// mode doesn't work so well with 16 bit textures.  Thus to fix it, we lighten the texture 
					// up by one, and then drop it down here to compensate.  Doing this allows us to hit 127 exactly.
					V.Diffuse = (0xFF<<24)|(248<<16)|(248<<8)|248;
					//V.Diffuse = 0xffffffff;
				}
				else if ( DoFog )
				{
					FLOAT W=1.f-p.v[Index].Fog.W;

					check(Stages[0]);
					V.Diffuse=FColor((p.v[Index].Light.Z*Stages[0]->MaxColor.B*W),	
							         (p.v[Index].Light.Y*Stages[0]->MaxColor.G*W),
									 (p.v[Index].Light.X*Stages[0]->MaxColor.R*W),
									 255);
				}
				else
				{
					check(Stages[0]);
					V.Diffuse=FColor((p.v[Index].Light.Z*Stages[0]->MaxColor.B), 
									 (p.v[Index].Light.Y*Stages[0]->MaxColor.G), 
									 (p.v[Index].Light.X*Stages[0]->MaxColor.R), 
									 255);
				}

				*Vertex=V;
				Vertex++;

			}
		}
		unclock(Stats.D3DVertexSetup);

		SetTextureNULL(0);
		SetTextureNULL(1);
		SetZBias(0);

		clock(Stats.D3DVertexRender);
		INT	First = ActorVertices.Unlock();
		ActorVertices.Set();
		
		bool CurrentDoFog=false;
		for(i=0;i<QueuedPolygonCount;)
		{
			QueuedPolygon &p=QueuedPolygons(i);
			// Set the polygon texture.

			SetTexture(0,*p.Texture, p.PolyFlags, false, p.PolyFlagsEx );	
			SetBlending(p.PolyFlags,p.PolyFlagsEx);
			//SetBlending(PF_Translucent,0);
			//SetBlending(p.PolyFlags,0);

			SetDistanceFog(!(p.PolyFlags&PF_Unlit));

			// Set the correct fog mode:
			UBOOL DoFog=((p.PolyFlags&(PF_RenderFog|PF_Translucent|PF_Modulated))==PF_RenderFog);		

			if(DoFog&&(!CurrentDoFog))
			{
				CurrentDoFog=true;
				Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_SPECULAR );			
				Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP,   D3DTOP_ADD );
			} else if((!DoFog)&&CurrentDoFog)
			{
				CurrentDoFog=false;
				Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
				Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP,   D3DTOP_DISABLE );
			}
			
			// Set the correct clamping mode:
			SetTextureClampMode((p.PolyFlags & PF_MeshUVClamp)?1:0);

			// See how many of my sucessor polys share my attributes, and draw them as well:
			for(int j=i+1;j<QueuedPolygonCount;j++)
			{
				if(p.PolyFlags!=QueuedPolygons(j).PolyFlags)	 break;
				if(p.PolyFlagsEx!=QueuedPolygons(j).PolyFlagsEx) break;
				if(p.Texture!=QueuedPolygons(j).Texture)		 break;
			}
			int count=j-i;
			Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLELIST, First+(i*3), count );
			i+=count;
		} 

		SetDistanceFog(true);
		SetTextureClampMode(0);

		if(CurrentDoFog==true)
		{
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_DISABLE );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
		}

		RenderQueuedPolygonsForProjectors(ProjectorFlags);		// JEP

		QueuedPolygons.Clear();

		// Terminate polygon clipping:
		unclock(Stats.D3DVertexRender);
		unclock(Stats.PolyTime);
	}

	void __fastcall QueuePolygon( FTextureInfo* Info, FTransTexture** Pts, INT NumPts, DWORD PolyFlags, DWORD ExFlags, FSpanBuffer *Span ) 
	{
		if(!RenderMeshes) 
			return;

		clock(Stats.QueueTime);
		clock(Stats.PolyTime);

		if(PolyFlags&PF_Masked) Stats.MaskedPolys++;

		QueuedPolygon &p=QueuedPolygons(QueuedPolygons.Add());
		p.PolyFlags=PolyFlags&(~PF_Memorized);
		p.PolyFlagsEx=ExFlags|PFX_Clip;
		p.Texture=Info;

		memcpy(&p.v[0],Pts[0],sizeof(FTransTexture));
		memcpy(&p.v[1],Pts[1],sizeof(FTransTexture));
		memcpy(&p.v[2],Pts[2],sizeof(FTransTexture));
		
		unclock(Stats.PolyTime);
		unclock(Stats.QueueTime);
	}
	
	bool __fastcall QueuePolygonBeginFast(FSceneNode* Frame)
	{
		CurrentFrame=Frame;
		return true;
	}

	void __fastcall QueuePolygonFast(FTransTexture** Pts, INT NumPts) 
	{
		clock(Stats.QueueTime);
		clock(Stats.PolyTime);

		QueuedPolygon &p=QueuedPolygons(QueuedPolygons.Add());

		memcpy(&p.v[0],Pts[0],sizeof(FTransTexture));
		memcpy(&p.v[1],Pts[1],sizeof(FTransTexture));
		memcpy(&p.v[2],Pts[2],sizeof(FTransTexture));
		
		unclock(Stats.PolyTime);
		unclock(Stats.QueueTime);
	}

	#define PROJECT_VERT(p, pProj, V)								\
	{																\
		FTransform		P;											\
		/* Transform point into projector space	*/					\
		P.Point = p.TransformPointBy(pProj->CameraToLight);			\
		P.Point.Z = max(1.0f, P.Point.Z);							\
		/* Project point onto projector front plane */				\
		P.Project(pProj->Frame);									\
		V->U[0] = P.ScreenX*pProjector->OneOverX;					\
		V->U[1] = P.ScreenY*pProjector->OneOverY;					\
		V->Position.W *= P.Point.Z;									\
		FLOAT R = P.RZ * pProj->Frame->RProj.Z;						\
		/* Clip and fade out (this is the UV's for the clipper/fade out texture layer) */	\
		V->U2[0] = (pProj->_33 + pProj->_43 * R)*pProj->FadeScale;	\
		V->U2[1] = 0.0f;											\
	}																\

	void __fastcall QueuePolygonEndFast()
	{
		VALIDATE;
		int QueuedPolygonCount=QueuedPolygons.Num();

		if(!QueuedPolygonCount) 
			return;

		check(Direct3DDevice8);

		clock(Stats.PolyTime);
		Stats.QueueCount++;
		Stats.Polys+=QueuedPolygonCount;

		PreRender(CurrentFrame);

		int VertexCount=QueuedPolygonCount*3;
		verify(VertexCount<=ACTORPOLY_VERTEXBUFFER_SIZE);

		//Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_ALWAYS );

		clock(Stats.D3DVertexLock);
		FD3DTLVertex *Vertex = (FD3DTLVertex*)ActorVertices.Lock(VertexCount);
		Stats.VBLocks++;
		unclock(Stats.D3DVertexLock);

		clock(Stats.D3DVertexSetup);
		for(int i=0;i<QueuedPolygonCount;i++)
		{
			QueuedPolygon &p=QueuedPolygons(i);				

			for( INT Index = 0; Index < 3; Index++ )
			{	
				FD3DTLVertex	V;

				V.Position.X = p.v[Index].ScreenX + CurrentFrame->XB - 0.5f;
				V.Position.Y = p.v[Index].ScreenY + CurrentFrame->YB - 0.5f;


				if (V.Position.X < CurrentFrame->XB)
					V.Position.X = CurrentFrame->XB;
				else if (V.Position.X > CurrentFrame->X)
					V.Position.X = CurrentFrame->X;

				if (V.Position.Y < CurrentFrame->YB)
					V.Position.Y = CurrentFrame->YB;
				else if (V.Position.Y > CurrentFrame->Y)
					V.Position.Y = CurrentFrame->Y;

				V.Position.Z = 1.0f;
				V.Position.W = 1.0f;

				V.Specular=0;
				
				#define SHADOW_VAL		(0)

				V.Diffuse  = (SHADOW_VAL<<16) | (SHADOW_VAL<<8) | SHADOW_VAL;

				*Vertex=V;
				Vertex++;

			}
		}
		unclock(Stats.D3DVertexSetup);

		SetTextureNULL( 0 );

		clock(Stats.D3DVertexRender);
		INT	First = ActorVertices.Unlock();
		ActorVertices.Set();
		
		SetZBias(0);
		SetDistanceFog(false);
		SetBlending();
		
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP,   D3DTOP_DISABLE );

		// Turn off zbuffering
		Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_ALWAYS);
		
		// Draw the VB
		//Direct3DDevice8->SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME);
		Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLELIST, First, QueuedPolygonCount);
		//Direct3DDevice8->SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
		
		// Turn zbuffering back on
		Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_LESSEQUAL );

		SetDistanceFog(true);
		SetTextureClampMode(0);

		QueuedPolygons.Clear();

		// Terminate polygon clipping:
		unclock(Stats.D3DVertexRender);
		unclock(Stats.PolyTime);
	}

	void RenderQueuedPolygonsForProjectors(DWORD ProjectorFlags)
	{
		int QueuedPolygonCount=QueuedPolygons.Num();

		if(!QueuedPolygonCount) 
			return;
		
		int VertexCount=QueuedPolygonCount*3;
		verify(VertexCount<=ACTORPOLY_VERTEXBUFFER_SIZE);

		if (ProjectorArray.Num() <= 0 || CurrentFrame->Recursion != 0 || !ProjectorFlags)
			return;			// No projectors to check

		// Setup projector render states
		SetTextureNULL( 0 );
		SetTextureNULL( 1 );
		SetBlending( PF_Modulated );
		SetDistanceFog(false);

		SetTextureClampMode(1);

		//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_DESTCOLOR );
		//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_ZERO );
		SetAlphaBlendEnable(TRUE);
		SetSrcBlend(D3DBLEND_DESTCOLOR);
		SetDstBlend(D3DBLEND_ZERO);
	#if 1
		// Setup clipper texture (also used for fade out)
		Direct3DDevice8->SetTexture(1, ClipperTexture);
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_ADD);
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);

		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSU, D3DTADDRESS_CLAMP );
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSV, D3DTADDRESS_CLAMP );

		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MAGFILTER, D3DTEXF_POINT);
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MINFILTER, D3DTEXF_POINT);
	#endif
			
		for (int p=ProjectorArray.Num()-1; p>=0 ; p--)
		{
			DWORD		Mask = 1<<p;

			if (!(Mask & ProjectorFlags))
				continue;

			ProjectorInfo *pProjector = &ProjectorArray(p);

			// Set the texture to the render target that belongs to this projector
			Direct3DDevice8->SetTexture(0, pProjector->pRenderTargetTex);

			// Fill up the VB with the verts for this projector
			clock(Stats.D3DVertexLock);
			FD3DTLVertex *Vertex = (FD3DTLVertex*)ActorVertices.Lock(VertexCount);
			Stats.VBLocks++;
			unclock(Stats.D3DVertexLock);

			clock(Stats.D3DVertexSetup);

			INT n = 0, NumMaskedPolys = 0;

			for(int i=0;i<QueuedPolygonCount;i++)
			{
				QueuedPolygon &p=QueuedPolygons(i);				

				if (p.PolyFlags&PF_Masked)
					NumMaskedPolys++;

				for( INT Index = 0; Index < 3; Index++, n++)
				{	
					Vertex->Position.X = Verts[n].Position.X;
					Vertex->Position.Y = Verts[n].Position.Y;
					Vertex->Position.Z = Verts[n].Position.Z;
					Vertex->Position.W = Verts[n].Position.W;
			
					Vertex->Specular = 0;
					Vertex->Diffuse  = 0xffffffff;

					//PROJECT_VERT(p.v[Index].Point, pProjector, Vertex);

					// Grab a copy of the vert
					FTransform		P;

					// Transform point into projector space
					P.Point = p.v[Index].Point.TransformPointBy(pProjector->CameraToLight);
						
					// Project point onto projector front plane
					P.Point.Z = max(1.0f, P.Point.Z);
					P.Project(pProjector->Frame);

					// Snag UV's
					Vertex->U[0] = P.ScreenX*pProjector->OneOverX;
					Vertex->U[1] = P.ScreenY*pProjector->OneOverY; 
						
					Vertex->Position.W *= P.Point.Z;

					// Clip and fade out (this is the UV's for the clipper/fade out texture layer)
				#if 1
					FLOAT R = P.RZ * pProjector->Frame->RProj.Z;		// (1.0f/Z)
					Vertex->U2[0] = (pProjector->_33 + pProjector->_43 * R)*pProjector->FadeScale;
					Vertex->U2[1] = 0.0f;
				#endif
			
					Vertex++;
				}
			}
			unclock(Stats.D3DVertexSetup);

			INT	First = ActorVertices.Unlock();
			ActorVertices.Set();
		
			// If we have some masked polygons, we have to seperate them out, and compare only equal zbuffer values
			//	This way, we don't see shadows in mid-air (shadows being projected onto the invisible parts of textures)
			if (NumMaskedPolys)
			{
				for(i=0;i<QueuedPolygonCount;)
				{
					QueuedPolygon &p=QueuedPolygons(i);

					for(int j=i+1;j<QueuedPolygonCount;j++)
					{
						if ((p.PolyFlags&PF_Masked) != (QueuedPolygons(j).PolyFlags&PF_Masked)) 
							break;
					}
				
					INT Count = j-i;

					// Handle masked polygons
					if (p.PolyFlags & PF_Masked)
						Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_EQUAL );

					Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLELIST, First+(i*3), Count);
				
					// Finish masked polygons
					if (p.PolyFlags & PF_Masked)
						Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_LESSEQUAL );
					
					i += Count;
				}
			}
			else
			{
				// Draw the entire VB (no masked polygons)
				Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLELIST, First, QueuedPolygonCount);
			}
		}

		// Restore render states
		Direct3DDevice8->SetTexture(0, NULL);

		//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_DESTCOLOR );
		//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_SRCCOLOR );
		SetAlphaBlendEnable(TRUE);
		SetSrcBlend(D3DBLEND_DESTCOLOR);
		SetDstBlend(D3DBLEND_SRCCOLOR);

		Direct3DDevice8->SetTexture(1, NULL);
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_DISABLE);

		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MAGFILTER, D3DTEXF_LINEAR );
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MINFILTER, D3DTEXF_LINEAR );

		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSU, D3DTADDRESS_WRAP );
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSV, D3DTADDRESS_WRAP );

		SetDistanceFog(true);
		SetTextureClampMode(0);
	}

	// NJS: FIXME: Still needed for to keep world decals working correctly:
	void __fastcall DrawGouraudPolygon( FSceneNode* Frame, FTextureInfo& Info, FTransTexture** Pts, INT NumPts, DWORD PolyFlags, FSpanBuffer* Span, DWORD PolyFlagsEx )
	{
		if(!RenderMeshes) 
			return;

		clock(Stats.PolyTime);

		Stats.Polys++;
		if(PolyFlags&PF_Masked) Stats.MaskedPolys++;

		UBOOL DoFog=((PolyFlags&(PF_RenderFog|PF_Translucent|PF_Modulated))==PF_RenderFog);		

		// Set up vertices.
		PolyFlags&=(~PF_Memorized)/*&(~PF_Selected)*/;

		// Set the polygon texture.
		PolyFlags|=PF_TwoSided;   // NJS: Hack, shouldn't have to do this.
		PolyFlagsEx|=PFX_Clip;

		SetBlending( PolyFlags, PolyFlagsEx );		
		SetTexture(0,Info,PolyFlags,0, PolyFlagsEx);
		SetZBias(0);



		if(PolyFlags&PF_Unlit) SetDistanceFog(false);
		else				   SetDistanceFog(true);

		// Kludge for 16-bit zbuffer limitations - compress weapon in 1/z space.
		// "Have HUD draw the player's weapon on top (and any other overlays which should happen before screen flashes)"
		FLOAT ZBiasHack = ( (GUglyHackFlags&1) && ViewportColorBits==16 )? 0.25f : 1.0f;

		FTransTexture**	SourceVertex;
		FD3DTLVertex*	Vertex = (FD3DTLVertex*) ActorVertices.Lock(NumPts);

		SourceVertex = Pts;

		for( INT Index = 0; Index < NumPts; Index++ )
		{	
			FLOAT	RHW = ZBiasHack * (*SourceVertex)->RZ * Frame->RProj.Z;

			Vertex->Position.X = (*SourceVertex)->ScreenX + Frame->XB - 0.5f;
			Vertex->Position.Y = (*SourceVertex)->ScreenY + Frame->YB - 0.5f;
			Vertex->Position.Z = ProjectionMatrix._33 + ProjectionMatrix._43 * RHW;
			Vertex->Position.W = RHW;

			Vertex->U[0] = (*SourceVertex)->U * Stages[0]->UScale;
			Vertex->U[1] = (*SourceVertex)->V * Stages[0]->VScale;

			Vertex->Specular=0;
			if(PolyFlagsEx&(PFX_LightenModulate|PFX_DarkenModulate))
			{
				Vertex->Diffuse  = 0xffffffff;

			} else
			if ( PolyFlags & PF_Modulated )
			{
				Vertex->Diffuse = (0xFF<<24)|(248<<16)|(248<<8)|248;
			}
			else if ( DoFog )
			{
				FLOAT W = 1.f - (*SourceVertex)->Fog.W;

				Vertex->Diffuse  = FColor(
					appRound((*SourceVertex)->Light.Z*Stages[0]->MaxColor.B*W),	
					appRound((*SourceVertex)->Light.Y*Stages[0]->MaxColor.G*W),
					appRound((*SourceVertex)->Light.X*Stages[0]->MaxColor.R*W),
					255 );				
			}
			else
			{
				Vertex->Diffuse	 = FColor( 
					appRound((*SourceVertex)->Light.Z*Stages[0]->MaxColor.B), 
					appRound((*SourceVertex)->Light.Y*Stages[0]->MaxColor.G), 
					appRound((*SourceVertex)->Light.X*Stages[0]->MaxColor.R), 
					255 );
				Vertex->Specular = 0;
			}

			Vertex++;
			SourceVertex++;
		}

		INT	First = ActorVertices.Unlock();


		ActorVertices.Set();

		if(PolyFlags & PF_MeshUVClamp) 
		{
			SetTextureClampMode(1);
		}
		
		if ( DoFog )
		{
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_SPECULAR );			
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_ADD );

			Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, NumPts - 2 );

			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_DISABLE );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
		}
		else
			Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, NumPts - 2 );


		if(PolyFlags & PF_MeshUVClamp) 
			SetTextureClampMode(0);

		//SetBlending();
		unclock(Stats.PolyTime);
	}
	__forceinline void RotateAboutOrigin2D(float originX, float originY, float &x, float &y, float theta)
	{
		float xTick, yTick;
		x-=originX; y-=originY;
		xTick = ((GMath.CosFloat(theta)*x) - (GMath.SinFloat(theta)*y)); 
		yTick = ((GMath.SinFloat(theta)*x) + (GMath.CosFloat(theta)*y));
		x=xTick+originX; y=yTick+originY;
	}

	// Modify the texture clamp mode:
	void __fastcall SetTextureClampMode( INT Mode )
	{
		if(TextureClampMode!=Mode)
		{
			TextureClampMode=Mode;
			D3DTEXTUREADDRESS TextureMode=(Mode==1)?D3DTADDRESS_CLAMP:D3DTADDRESS_WRAP;
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ADDRESSU, TextureMode );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ADDRESSV, TextureMode );
		}
	}

	void __fastcall DrawTile(FSceneNode* Frame, 
							 FTextureInfo& Info, 
							 FLOAT X, FLOAT Y, 
							 FLOAT XL, FLOAT YL, 
							 FLOAT U, FLOAT V, 
							 FLOAT UL, FLOAT VL, 
							 class FSpanBuffer* Span, 
							 FLOAT Z, 
							 FPlane InColor, FPlane Fog, 
							 DWORD PolyFlags, 
							 DWORD PolyFlagsEx,
							 FLOAT alpha,
							 FLOAT rot,
							 FLOAT rotationOffsetX,
							 FLOAT rotationOffsetY
	)
	{
		// Exclude tiles from rendering?
		if(!RenderTiles) 
			return;

		clock(Stats.TileTime);
		Stats.Tiles++;			// Keep track of tiles rendered.
		SetDistanceFog(false);


		//PolyFlags  =PF_TwoSided | PF_NoOcclude ;
		//PolyFlagsEx=PFX_Translucent2;

		//alpha=Clamp<float>(appSin(appSeconds()),0,1);


		PolyFlags&=~(PF_Memorized/*|PF_Selected*/);		// Remove multitexture and editor flags.
		if(!GIsEditor) PolyFlags&=~PF_Selected;	// NJS: test this and take teh PF_Selected out the above.


		if( Info.Palette && Info.Palette[128].A!=255 && !(PolyFlags&PF_Translucent) )
			PolyFlags |= PF_Highlighted;

		if(alpha!=1.f) 
		{
			if(!(PolyFlags&PF_Translucent)
			 &&!(PolyFlagsEx&PFX_Translucent2))
				PolyFlags|=PF_Translucent;
		}

		PolyFlags|=PF_TwoSided;
		PolyFlagsEx|=PFX_Clip|Info.Texture->PolyFlagsEx;
	
		if(PolyFlagsEx&PFX_AlphaMap) 
		{
			PolyFlags&=~PF_Translucent;
			PolyFlags&=~PF_Modulated;
			if(!GIsEditor) PolyFlags&=~PF_Highlighted;
			PolyFlagsEx&=~(PFX_Translucent2|PFX_LightenModulate|PFX_DarkenModulate);
		}

		SetBlending(PolyFlags,PolyFlagsEx);
		SetTexture(0,Info,PolyFlags,0,PolyFlagsEx);	
		
		// Offset points to guarantee that we will sample directly from the center of the texture pixels
		X += Frame->XB - 0.5f;
		Y += Frame->YB - 0.5f;

		// NJS: Hack to compensate for the fact that software was depending on wrap around integer arithmetic:
		if(GIsEditor) 
		{
			if(Z==0.f)	Z+=2000;
			if(Z<0)		Z*=-1;
		}

		FColor			Color = (PolyFlagsEx & (PFX_LightenModulate|PFX_DarkenModulate)) ? FColor(255,255,255,255) : FColor(Stages[0]->MaxColor.Plane() * InColor);
		if(PolyFlags&PF_Modulated) Color = (0xFF<<24)|(248<<16)|(248<<8)|248;

		FLOAT			RZ = 1.f/Z,
						SZ = ProjectionMatrix._33 + ProjectionMatrix._43 * RZ;
		FD3DTLVertex*	Vertices = (FD3DTLVertex*) ActorVertices.Lock(4);

		DWORD dwDiffuse;
		if(alpha!=1.f/*&&(!(PolyFlagsEx&PFX_AlphaMap))*/)
		{
			DWORD R=Stages[0]->MaxColor.R*alpha*InColor.X,
				  G=Stages[0]->MaxColor.G*alpha*InColor.Y,
				  B=Stages[0]->MaxColor.B*alpha*InColor.Z,
				  A=Stages[0]->MaxColor.A*alpha; // *InColor.X
			
			if(R>Stages[0]->MaxColor.R) R=Stages[0]->MaxColor.R;
			if(G>Stages[0]->MaxColor.G) G=Stages[0]->MaxColor.G;
			if(B>Stages[0]->MaxColor.B) B=Stages[0]->MaxColor.B;
			if(A>Stages[0]->MaxColor.A) A=Stages[0]->MaxColor.A;

			dwDiffuse=D3DCOLOR_RGBA(R,G,B,A);
		} else
		{
			dwDiffuse=Color.TrueColor()|0xFF000000;
		}

		//dwDiffuse=0xFFFFFFFF;
		Vertices[0].Diffuse    = dwDiffuse;
		Vertices[0].Position.Z = SZ;
		Vertices[0].Position.W = RZ;
		Vertices[1].Diffuse	   = dwDiffuse;
		Vertices[1].Position.Z = SZ;
		Vertices[1].Position.W = RZ;
		Vertices[2].Diffuse	   = dwDiffuse;
		Vertices[2].Position.Z = SZ;
		Vertices[2].Position.W = RZ;
		Vertices[3].Diffuse	   = dwDiffuse;
		Vertices[3].Position.Z = SZ;
		Vertices[3].Position.W = RZ;

		bool MirrorHoriz = ( PolyFlagsEx & PFX_MirrorHorizontal ) ? true : false,
			 MirrorVert  = ( PolyFlagsEx & PFX_MirrorVertical )   ? true : false;

		if (MirrorHoriz && !MirrorVert)
		{
			Vertices[0].Position.X=X;    Vertices[0].Position.Y=Y;    Vertices[0].U[0]=U+UL; Vertices[0].U[1]=V;
			Vertices[1].Position.X=X;    Vertices[1].Position.Y=Y+YL; Vertices[1].U[0]=U+UL; Vertices[1].U[1]=V+VL;
			Vertices[2].Position.X=X+XL; Vertices[2].Position.Y=Y+YL; Vertices[2].U[0]=U;    Vertices[2].U[1]=V+VL;
			Vertices[3].Position.X=X+XL; Vertices[3].Position.Y=Y;    Vertices[3].U[0]=U; 	 Vertices[3].U[1]=V;

		} else if (MirrorVert && !MirrorHoriz) 
		{
			Vertices[0].Position.X=X;    Vertices[0].Position.Y=Y;    Vertices[0].U[0]=U;		Vertices[0].U[1]=V+VL;
			Vertices[1].Position.X=X;    Vertices[1].Position.Y=Y+YL; Vertices[1].U[0]=U;	    Vertices[1].U[1]=V;
			Vertices[2].Position.X=X+XL; Vertices[2].Position.Y=Y+YL; Vertices[2].U[0]=U+UL;    Vertices[2].U[1]=V;
			Vertices[3].Position.X=X+XL; Vertices[3].Position.Y=Y;    Vertices[3].U[0]=U+UL; 	Vertices[3].U[1]=V+VL;

		} else if (MirrorHoriz && MirrorVert) 
		{
			Vertices[0].Position.X=X;    Vertices[0].Position.Y=Y;    Vertices[0].U[0]=U+UL;	Vertices[0].U[1]=V+VL;
			Vertices[1].Position.X=X;    Vertices[1].Position.Y=Y+YL; Vertices[1].U[0]=U+UL;    Vertices[1].U[1]=V;
			Vertices[2].Position.X=X+XL; Vertices[2].Position.Y=Y+YL; Vertices[2].U[0]=U   ;    Vertices[2].U[1]=V;
			Vertices[3].Position.X=X+XL; Vertices[3].Position.Y=Y;    Vertices[3].U[0]=U   ; 	Vertices[3].U[1]=V+VL;

		} else 
		{
			Vertices[0].Position.X=X;    Vertices[0].Position.Y=Y;    Vertices[0].U[0]=U;		Vertices[0].U[1]=V   ;
			Vertices[1].Position.X=X;    Vertices[1].Position.Y=Y+YL; Vertices[1].U[0]=U;	    Vertices[1].U[1]=V+VL;
			Vertices[2].Position.X=X+XL; Vertices[2].Position.Y=Y+YL; Vertices[2].U[0]=U+UL;    Vertices[2].U[1]=V+VL;
			Vertices[3].Position.X=X+XL; Vertices[3].Position.Y=Y;    Vertices[3].U[0]=U+UL; 	Vertices[3].U[1]=V   ;
		}

		Vertices[0].U[0]*=Stages[0]->UScale;
		Vertices[0].U[1]*=Stages[0]->VScale;
		Vertices[1].U[0]*=Stages[0]->UScale;
		Vertices[1].U[1]*=Stages[0]->VScale;
		Vertices[2].U[0]*=Stages[0]->UScale;
		Vertices[2].U[1]*=Stages[0]->VScale;
		Vertices[3].U[0]*=Stages[0]->UScale;
		Vertices[3].U[1]*=Stages[0]->VScale;

		// NJS: Do I have rotation?
		if(rot)	
		{
			float originX=(Vertices[0].Position.X+XL/2.f)+rotationOffsetX, originY=(Vertices[0].Position.Y+YL/2.f)+rotationOffsetY;

			for(int index=0;index<4;index++)
			{	
				float x=Vertices[index].Position.X,
					  y=Vertices[index].Position.Y;

				RotateAboutOrigin2D(originX,originY,x,y,rot);
				Vertices[index].Position.X=x;
				Vertices[index].Position.Y=y;
			}
		}

		INT	First=ActorVertices.Unlock();
		ActorVertices.Set();

		Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, 2 );
		unclock(Stats.TileTime);
	}
	
	void __fastcall RecursiveSubdivideLine(UCanvas *c, UTexture *t, FColor BeamColor, FColor BeamEndColor, FLOAT BeamStartWidth, FLOAT BeamEndWidth, DWORD PolyFlags, FLOAT MaxAmplitude, FVector LineStart, FVector LineEnd, FVector RangeStart, FVector RangeEnd, INT depth)
	{
		VALIDATE;
		verify(c);
		// Have I traversed to the lowest point?
		if(!depth)
		{
			// Draw the segment:
			dnDraw3DLine(c->Frame,t,PolyFlags,RangeStart,RangeEnd,BeamStartWidth,BeamEndWidth,BeamColor,BeamColor,true);
			return;
		} 

		FVector Direction=RangeEnd-RangeStart;
		FVector Midpoint=RangeStart+(Direction/2); 
		
		// Move the midpoint around randomly on the plane that the direction is the normal of.
		Direction=LineEnd-LineStart;
		Direction.Normalize();

		FVector Axis1, Axis2;
		Direction.FindBestAxisVectors( Axis1, Axis2 );
		Axis1.Normalize();
		Axis2.Normalize();

		Midpoint+=Axis1*(((MaxAmplitude*2)*appFrand())-MaxAmplitude);
		Midpoint+=Axis2*(((MaxAmplitude*2)*appFrand())-MaxAmplitude);

		FColor ColorMidpoint=BeamColor;
		ColorMidpoint.R+=(BeamEndColor.R-BeamColor.R)/2;
		ColorMidpoint.G+=(BeamEndColor.G-BeamColor.G)/2;
		ColorMidpoint.B+=(BeamEndColor.B-BeamColor.B)/2;
		ColorMidpoint.A+=(BeamEndColor.A-BeamColor.A)/2;
 
		// Delegate the rendering of the 2 line segments: 
		RecursiveSubdivideLine(c,t,BeamColor,ColorMidpoint,BeamStartWidth, BeamEndWidth,PolyFlags,MaxAmplitude/2,LineStart,LineEnd,RangeStart,Midpoint,depth-1);
		RecursiveSubdivideLine(c,t,ColorMidpoint,BeamEndColor,BeamStartWidth, BeamEndWidth,PolyFlags,MaxAmplitude/2,LineStart,LineEnd,Midpoint,RangeEnd,depth-1);
	}

	void __fastcall SineWave(UCanvas *c, UTexture *t, FColor BeamColor, FColor BeamEndColor, FLOAT BeamStartWidth, FLOAT BeamEndWidth, DWORD PolyFlags, FLOAT MaxAmplitude, FLOAT MaxFrequency, FLOAT Noise, FLOAT TimeSeconds, FVector LineStart, FVector LineEnd, FVector RangeStart, FVector RangeEnd, INT depth,FLOAT TimeScale)
	{
		VALIDATE;
		int LineSegments=((int)appPow(2,depth))+1;
		FVector CurrentPosition=LineStart;
		FVector PreviousPosition=CurrentPosition;
		FVector Distance=LineEnd-LineStart;
		FVector Direction=Distance;
		Direction.Normalize();
		FLOAT Length=Distance.Size();
		FLOAT StepLength=Length/LineSegments;

		FVector Axis1, Axis2;
		Direction.FindBestAxisVectors( Axis1, Axis2 );
		Axis1.Normalize();
		Axis2.Normalize();

		FColor PreviousColor=BeamColor,
			   CurrentColor=BeamColor;

		FLOAT RFactor=(((FLOAT)(BeamEndColor.R-BeamColor.R))/(FLOAT)LineSegments);
		FLOAT GFactor=(((FLOAT)(BeamEndColor.G-BeamColor.G))/(FLOAT)LineSegments);
		FLOAT BFactor=(((FLOAT)(BeamEndColor.B-BeamColor.B))/(FLOAT)LineSegments);
		FLOAT AFactor=(((FLOAT)(BeamEndColor.A-BeamColor.A))/(FLOAT)LineSegments);

		for(int i=0;i<LineSegments;i++)
		{
			FLOAT LengthToHere=(i*StepLength);
			CurrentPosition=LineStart+(LengthToHere*Direction);
			
			CurrentPosition+=(Axis1*(appSin(TimeSeconds*13*TimeScale+LengthToHere*MaxFrequency+appFrand()*Noise-(Noise/2))*MaxAmplitude));
			CurrentPosition+=(Axis2*(appCos(TimeSeconds*13*TimeScale+LengthToHere*MaxFrequency+appFrand()*Noise-(Noise/2))*MaxAmplitude));

			// Compute current color:
			CurrentColor=BeamColor;
			CurrentColor.R+=(int)(RFactor*i);
			CurrentColor.G+=(int)(GFactor*i);
			CurrentColor.B+=(int)(BFactor*i);
			CurrentColor.A+=(int)(AFactor*i);

			// Draw the line:
			dnDraw3DLine(c->Frame,t,PolyFlags,PreviousPosition,CurrentPosition,BeamStartWidth,BeamEndWidth,PreviousColor,CurrentColor,true);

			PreviousPosition=CurrentPosition;
			PreviousColor=CurrentColor;
		}
	}

	void __fastcall DoubleSineWave(UCanvas *c, UTexture *t, FColor BeamColor, FColor BeamEndColor, FLOAT BeamStartWidth, FLOAT BeamEndWidth, DWORD PolyFlags, FLOAT MaxAmplitude, FLOAT MaxFrequency, FLOAT Noise, FLOAT TimeSeconds, FVector LineStart, FVector LineEnd, FVector RangeStart, FVector RangeEnd, INT depth,FLOAT TimeScale)
	{
		int LineSegments=((int)appPow(2,depth))+1;
		FVector CurrentPosition=LineStart;
		FVector PreviousPosition=CurrentPosition;
		FVector Distance=LineEnd-LineStart;
		FVector Direction=Distance;
		Direction.Normalize();
		FLOAT Length=Distance.Size();
		FLOAT StepLength=Length/LineSegments;

		FVector Axis1, Axis2;
		Direction.FindBestAxisVectors(Axis1,Axis2);
		Axis1.Normalize();
		Axis2.Normalize();

		FColor PreviousColor=BeamColor,
			   CurrentColor=BeamColor;

		FLOAT RFactor=(((FLOAT)(BeamEndColor.R-BeamColor.R))/(FLOAT)LineSegments);
		FLOAT GFactor=(((FLOAT)(BeamEndColor.G-BeamColor.G))/(FLOAT)LineSegments);
		FLOAT BFactor=(((FLOAT)(BeamEndColor.B-BeamColor.B))/(FLOAT)LineSegments);
		FLOAT AFactor=(((FLOAT)(BeamEndColor.A-BeamColor.A))/(FLOAT)LineSegments);

		for(int i=0;i<LineSegments;i++)
		{
			FLOAT LengthToHere=(i*StepLength);
			CurrentPosition=LineStart+(LengthToHere*Direction);
			
			FLOAT OriginalMaxAmplitude=MaxAmplitude;
			MaxAmplitude*=appSin(((FLOAT)i/(FLOAT)LineSegments)*10+TimeSeconds*4.5);
			CurrentPosition+=(Axis1*(appSin(TimeSeconds*13*TimeScale+LengthToHere*MaxFrequency+appFrand()*Noise-(Noise/2))*MaxAmplitude));
			CurrentPosition+=(Axis2*(appCos(TimeSeconds*13*TimeScale+LengthToHere*MaxFrequency+appFrand()*Noise-(Noise/2))*MaxAmplitude));
			MaxAmplitude=OriginalMaxAmplitude;

			// Compute current color:
			CurrentColor=BeamColor;
			CurrentColor.R+=(int)(RFactor*i);
			CurrentColor.G+=(int)(GFactor*i);
			CurrentColor.B+=(int)(BFactor*i);
			CurrentColor.A+=(int)(AFactor*i);

			// Draw the line:
			dnDraw3DLine(c->Frame,t,PolyFlags,PreviousPosition,CurrentPosition,BeamStartWidth,BeamEndWidth,PreviousColor,CurrentColor,true);

			PreviousPosition=CurrentPosition;
			PreviousColor=CurrentColor;
		}
	}

	float inline __fastcall SamplePoint(int x, int y,FLOAT MaxAmplitude, FLOAT MaxFrequency, FLOAT Noise,FLOAT TimeSeconds)
	{
		VALIDATE;

		FLOAT value=0;
		
		MaxFrequency*=8;
		value+=appSin(TimeSeconds*8+x*MaxFrequency)*MaxAmplitude;
		
		return value;
	}

	void __fastcall MovingGrid(UCanvas *c, UTexture *t, FColor BeamColor, FColor BeamEndColor, FLOAT BeamStartWidth, FLOAT BeamEndWidth, DWORD PolyFlags, FLOAT MaxAmplitude, FLOAT MaxFrequency, FLOAT Noise, FLOAT TimeSeconds, FVector LineStart, FVector LineEnd, INT Tesselation)
	{
		VALIDATE;

		FVector AxisZ=LineEnd-LineStart;
		FLOAT Length=AxisZ.Size();
		FLOAT LengthIncrement=Length/Tesselation;
		AxisZ.Normalize();

		FVector AxisX, AxisY;
		AxisZ.FindBestAxisVectors( AxisX, AxisY );
		AxisX.Normalize();
		AxisY.Normalize();

		FVector AxisXIncrement=AxisX*LengthIncrement;
		FVector AxisYIncrement=AxisY*LengthIncrement;
		for(INT x=0;x<Tesselation;x++)
		{
			FVector CurrentLocation=LineStart+(AxisXIncrement*(x-Tesselation/2.0f))-(AxisYIncrement*(Tesselation/2.0f));
			for(INT y=0;y<Tesselation;y++)
			{
				FVector A=CurrentLocation;
				A.Z+=SamplePoint(x,y,MaxAmplitude, MaxFrequency, Noise, TimeSeconds);

				// Connect this point to it's four neighbors:
				if(x!=Tesselation-1) 
				{
					FVector B=CurrentLocation+AxisXIncrement;
					B.Z+=SamplePoint(x+1,y,MaxAmplitude, MaxFrequency, Noise,TimeSeconds);
					dnDraw3DLine(c->Frame,t,PolyFlags,A,B,BeamStartWidth,BeamEndWidth,BeamColor,BeamEndColor);
				}
				if(y!=Tesselation-1) 
				{
					FVector B=CurrentLocation+AxisYIncrement;
					B.Z+=SamplePoint(x,y+1,MaxAmplitude, MaxFrequency, Noise,TimeSeconds);
					dnDraw3DLine(c->Frame,t,PolyFlags,A,B,BeamStartWidth,BeamEndWidth,BeamColor,BeamEndColor);
				}
				CurrentLocation+=AxisYIncrement;
			}
		}
	}

	void __fastcall DrawSpline(ABeamSystem &System, UCanvas *c, UTexture *t, FColor BeamColor, FColor BeamEndColor, FLOAT BeamStartWidth, FLOAT BeamEndWidth, DWORD PolyFlags, FLOAT MaxAmplitude, FLOAT MaxFrequency, FLOAT Noise, FLOAT TimeSeconds, FVector LineStart, FVector LineEnd, INT Tesselation)
	{
		VALIDATE;
		// Ensure that the beam is tesselated:
		if(System.TesselationLevel<=0)  return;
		if(System.ControlPointCount<=0) return;

		int i;

		// Update the positions of the control points based on their actor's positions (if any):
		for(i=0;i<ARRAY_COUNT(System.ControlPoint);i++)
			if(System.ControlPoint[i].PositionActor)
				System.ControlPoint[i].Position=System.ControlPoint[i].PositionActor->Location;


		FVector PreviousLocation=System.ControlPoint[0].Position;
		FRotator Bogus=FRotator(0,0,0);
		FVector LastPoint=PreviousLocation;
		FVector NewLastPoint=PreviousLocation;

		for(i=0;i<System.ControlPointCount-1;i++)
		{

			FVector CurrentLocation=System.ControlPoint[i].Position;
			int k=i+1;
			if(k>=System.ControlPointCount) k=System.ControlPointCount-1;
			FVector NextLocation=System.ControlPoint[k].Position;
			k++;
			if(k>=System.ControlPointCount) k=System.ControlPointCount-1;
			FVector NextLocation1=System.ControlPoint[k].Position;

			for(int j=0;j<System.TesselationLevel;j++)
			{
				KRSpline_Sample(((float)j/(float)System.TesselationLevel),
								 NewLastPoint,    Bogus,
  								 PreviousLocation,Bogus,
								 CurrentLocation, Bogus,
								 NextLocation,	  Bogus,
								 NextLocation1,	  Bogus);

				dnDraw3DLine(c->Frame,t, 0,LastPoint,NewLastPoint,System.BeamStartWidth,System.BeamEndWidth,System.BeamColor,System.BeamEndColor,true);

				LastPoint=NewLastPoint;
			}
		
			PreviousLocation=System.ControlPoint[i].Position;
		}
	}

	void __fastcall dnDrawBeam( ABeamSystem &System, FSceneNode *Frame )
	{
		VALIDATE;

		// Don't worry about it if not enabled:
		if(!System.Enabled) return;

		if(System.BeamType==BST_Spline) System.NumberDestinations=1;

		// Check to see if destination actor is valid: 
		if(!System.NumberDestinations) 
			return;

		// CDH... check to make sure camera style matches, if applicable
		if (!GIsEditor && System.BeamPlayerCameraStyleMode!=BPCS_None)
		{
			if ((System.BeamPlayerCameraStyleMode==BPCS_Equal) && (System.BeamPlayerCameraStyle!=Frame->Viewport->Actor->CameraStyle))
				return;
			else if ((System.BeamPlayerCameraStyleMode==BPCS_NotEqual) && (System.BeamPlayerCameraStyle==Frame->Viewport->Actor->CameraStyle))
				return;
		}
		// ...CDH
		clock(Stats.BeamTime);

		FLOAT TimeSeconds = System.Level->GameTimeSeconds;
		appSrand((*(DWORD *)&TimeSeconds)^((DWORD)&System));	// Makes the beams pausable, as they are based off of game time.

		UCanvas *c=Frame->Viewport->Canvas;

		PreRender(Frame);

		if(System.BeamStartWidth<1) System.BeamStartWidth=1;
		if(System.BeamEndWidth<1)   System.BeamEndWidth=1;

		if(System.TesselationLevel>16)     System.TesselationLevel=16;
		else if(System.TesselationLevel<1) System.TesselationLevel=1;

		System.BoundingBoxMin=System.Location-FVector(5,5,5);
		System.BoundingBoxMax=System.Location+FVector(5,5,5);

		// Force animated textures to update:
		UTexture *BeamTexture=System.BeamTexture;
		if(BeamTexture) BeamTexture=BeamTexture->Get(appSeconds());

		for(INT i=0;i<System.NumberDestinations;i++)
		{
			Stats.Beams++;

			FVector DestinationLocation;
			if(System.BeamType!=BST_Spline)
			{
				DestinationLocation=System.DestinationActor[i]->Location + System.DestinationOffset[i];

					 if(DestinationLocation.X<System.BoundingBoxMin.X) System.BoundingBoxMin.X=DestinationLocation.X;
				else if(DestinationLocation.X>System.BoundingBoxMax.X) System.BoundingBoxMax.X=DestinationLocation.X;

					 if(DestinationLocation.Y<System.BoundingBoxMin.Y) System.BoundingBoxMin.Y=DestinationLocation.Y;
				else if(DestinationLocation.Y>System.BoundingBoxMax.Y) System.BoundingBoxMax.Y=DestinationLocation.Y;

					 if(DestinationLocation.Z<System.BoundingBoxMin.Z) System.BoundingBoxMin.Z=DestinationLocation.Z;
				else if(DestinationLocation.Z>System.BoundingBoxMax.Z) System.BoundingBoxMax.Z=DestinationLocation.Z;
			}

			// Draws from Location to DestinationActor->Location. 
			switch(System.BeamType)
			{
				case BST_RandomWalk:
					// BST_RandomWalk not implemented Yet, fall through to recursive subdivide:

				case BST_RecursiveSubdivide:
					RecursiveSubdivideLine(c, BeamTexture, System.BeamColor, System.BeamEndColor, System.BeamStartWidth, System.BeamEndWidth, 0, System.MaxAmplitude, System.Location, DestinationLocation,System.Location, DestinationLocation, System.TesselationLevel);
					break;

				case BST_SineWave:
					SineWave(c, BeamTexture, System.BeamColor, System.BeamEndColor, System.BeamStartWidth, System.BeamEndWidth, 0, System.MaxAmplitude, System.MaxFrequency, System.Noise, TimeSeconds, System.Location, DestinationLocation,System.Location, DestinationLocation, System.TesselationLevel,System.TimeScale);
					break;

				case BST_DoubleSineWave:
					DoubleSineWave(c, BeamTexture, System.BeamColor, System.BeamEndColor, System.BeamStartWidth, System.BeamEndWidth, 0, System.MaxAmplitude, System.MaxFrequency, System.Noise, TimeSeconds, System.Location, DestinationLocation,System.Location, DestinationLocation, System.TesselationLevel,System.TimeScale);
					break;

				case BST_Spline:
					DrawSpline(System,c, BeamTexture, System.BeamColor, System.BeamEndColor, System.BeamStartWidth, System.BeamEndWidth, 0, System.MaxAmplitude, System.MaxFrequency, System.Noise, TimeSeconds, System.Location, DestinationLocation,System.TesselationLevel);
					break;

				case BST_Straight:
					dnDraw3DLine(c->Frame,BeamTexture, 0,System.Location,DestinationLocation,System.BeamStartWidth,System.BeamEndWidth,System.BeamColor,System.BeamEndColor,true);
					break;

				case BST_Grid:
					MovingGrid(c, BeamTexture, System.BeamColor, System.BeamEndColor, System.BeamStartWidth, System.BeamEndWidth, 0, System.MaxAmplitude, System.MaxFrequency, System.Noise, TimeSeconds, System.Location, DestinationLocation,System.TesselationLevel);
					break;
			}
			QueuedLinesFlush(System,Frame,BeamTexture,0);

		}
		QueueParticleFlush(System,Frame);
		unclock(Stats.BeamTime);
	}

	// Particle output subsystem:
	struct QueuedParticle
	{
		FD3DParticle v[6];
	};

	struct QueuedParticleByTexture
	{
		UTexture *Texture;
		QueuedParticle *p;
		int ParticleCount, ParticleMax;
	};

	TArray<QueuedParticleByTexture> QueuedParticles;
	void __fastcall QueueParticleShutdown()
	{
		VALIDATE;

		for(int i=0;i<QueuedParticles.Num();i++)
			if(QueuedParticles(i).p&&QueuedParticles(i).ParticleMax)
				appFree(QueuedParticles(i).p);
	}

	// NJS: The texture is passed in order to insert it into the proper queue.
	inline QueuedParticle &QueuedParticleAlloc(UTexture *Texture=NULL)
	{
		VALIDATE;

		// Attempt to find the bin this texture fits under, or allocate one if nessecary:
		for(int bin=0;bin<QueuedParticles.Num();bin++)
			if(QueuedParticles(bin).Texture==Texture)
				break;

		// Couldn't locate the bin for this particle system, allocate one of the free bins.
		if(bin>=QueuedParticles.Num())
		{
			// Find an empty bin (ie, particle count is zero)
			for(bin=0;bin<QueuedParticles.Num();bin++)
				if(!QueuedParticles(bin).ParticleCount)
					break;

			// No bins available, allocate and initialize one:
			if(bin>=QueuedParticles.Num())
				bin=QueuedParticles.AddZeroed();

			// Set the bin's texture to my own.
			QueuedParticles(bin).Texture=Texture;
		}

		// Ok, I've got a valid bin, now allocate a particle out of it:
	    int ParticleIndex=QueuedParticles(bin).ParticleCount;
		QueuedParticles(bin).ParticleCount++;

		// Do I need to allocate more particles to make room for the new one?
		if(QueuedParticles(bin).ParticleCount>=QueuedParticles(bin).ParticleMax)
		{
			QueuedParticles(bin).ParticleMax+=Min(Max(QueuedParticles(bin).ParticleMax+1,4),256);	// Basically double the size of the particle queue until we hit 256 particles, then alloc no more than 256 at a time.
			QueuedParticles(bin).p=(QueuedParticle *)appRealloc(QueuedParticles(bin).p,(QueuedParticles(bin).ParticleMax+1)*sizeof(QueuedParticle),_T("Queued Particles"));
		}
		
		// Return a reference to the allocated particle:
		return QueuedParticles(bin).p[ParticleIndex];
	}

	void __fastcall QueueParticleFlush(AParticleSystem &System, FSceneNode *Frame)
	{
		VALIDATE;

		// Early out if there are no particles queued for rendering.
		if(!QueuedParticles.Num()) 
			return;

		DWORD PolyFlags,
			  PolyFlagsEx;
		//GetActorPolyFlags(Frame,&System,PolyFlags,PolyFlagsEx);
		System.STY2PolyFlags( Frame, PolyFlags, PolyFlagsEx);
		PolyFlags|=PF_TwoSided;
		PolyFlagsEx|=PFX_Clip;

		// Configure the Z-Buffer
		     if(System.ZBufferMode==ZBM_Occlude) PolyFlags|=PF_Occlude;	// Full Z buffer occlusion	
		else if(System.ZBufferMode==ZBM_None)							// No Z buffer interaction whatsoever
		{
			Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_ALWAYS );
			PolyFlags&=~PF_Occlude;
		}
		else PolyFlags&=~PF_Occlude;	// Read only Z Buffer

		UBOOL VariableAlpha=true;
		if((System.AlphaStart==1.f)&&(System.AlphaEnd==1.f)) VariableAlpha=false;
		if(VariableAlpha) PolyFlags|=PF_Translucent;
		
		SetBlending(PolyFlags,PolyFlagsEx);

		// Set the zbias for the entire particle system:
		SetZBias(System.ZBias); //Direct3DDevice8->SetRenderState(D3DRS_ZBIAS,System.ZBias);
		SetTextureNULL(1);

		SetDistanceFog(false);

		// Count the total number of particles in this system, tallying the particles queued for each material.
		int TotalParticleCount=0;
		for(int i=0;i<QueuedParticles.Num();i++)
		{
			TotalParticleCount+=QueuedParticles(i).ParticleCount;
		}

		Stats.Particles+=TotalParticleCount;

		// First set up the vertex buffer:
		verify(TotalParticleCount*6<PARTICLE_VERTEXBUFFER_SIZE);
		FD3DParticle *Vertices=(FD3DParticle*)ParticleVertices.Lock(TotalParticleCount*6);
		FD3DParticle *v=Vertices;
		for(i=0;i<QueuedParticles.Num();i++)
			if(QueuedParticles(i).ParticleCount)
			{
				memcpy(v,QueuedParticles(i).p,QueuedParticles(i).ParticleCount*sizeof(QueuedParticle));
				v+=QueuedParticles(i).ParticleCount*6;
			}

		INT	First = ParticleVertices.Unlock();
		
		// Now render the vertex buffer:
		ParticleVertices.Set();

		UTexture *CurrentTexture=NULL;
		FTextureInfo CurrentTextureInfo;
		int ParticleIndex=0;
		SetTextureNULL(1);

		for(i=0;i<QueuedParticles.Num();i++)
		{
			int RunLength=QueuedParticles(i).ParticleCount;
			QueuedParticles(i).ParticleCount=0;	
			if(!RunLength) 
				continue;

			// Unset the current texture if any:
			if(CurrentTexture)
			{
				CurrentTexture->Unlock( CurrentTextureInfo );
				CurrentTexture=NULL;
			}


			CurrentTexture=QueuedParticles(i).Texture;
			if(CurrentTexture)
			{
				Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
				Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
				
				CurrentTexture->Lock( CurrentTextureInfo, 0/*Frame->Viewport->CurrentTime*/, -1, Frame->Viewport->RenDev );
				SetTexture( 0, CurrentTextureInfo, PolyFlags, 0, PolyFlagsEx|CurrentTexture->PolyFlagsEx );
				SetBlending(PolyFlags,PolyFlagsEx|CurrentTexture->PolyFlagsEx);
			} 
			else
			{
				//!!should optimize to avoid changing shade mode, color op, alpha op.
				Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_DISABLE  );
				Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_DISABLE );
			}


			Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLELIST, First+(ParticleIndex*6), RunLength*2);
			ParticleIndex+=RunLength;
		}

		if(CurrentTexture)
		{
			CurrentTexture->Unlock(CurrentTextureInfo);
			CurrentTexture=NULL;
		} else
		{
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
		}

		if(System.ZBufferMode==ZBM_None)							// No Z buffer interaction whatsoever
			Direct3DDevice8->SetRenderState(D3DRS_ZFUNC,D3DCMP_LESSEQUAL);
	}

	void __fastcall dnDrawParticles( ASoftParticleSystem &System, FSceneNode *Frame )
	{
		VALIDATE;

		if(!RenderParticles) 
			return;

		clock(Stats.ParticleTime);
		INT ParticleCount=System.HighestParticleNumber;
		
		// Make sure the xform matrix is correctly set up:
		PreRender(Frame);
		FParticle *Particles=(FParticle *)System.ParticleSystemHandle;

		// Texture Management:
		UTexture *CurrentTexture=NULL;
		FTextureInfo CurrentTextureInfo;

		if(System.UseLines)
		{
			for(INT i=0; i<ParticleCount; i++)
			{
				FVector PreviousLocation;
				FVector NextLocation;

				// Am I drawing a series of connected particle lines?
				if(System.Connected)
				{
					int SuccessorIndex=-1;

					// Attempt to find my successor: 
					// First try the very next particle in sequence.  In non-starved particle systems, where particles have a constant lifetime, it is VERY likely to be the next particle in sequence. 
					if((i<(ParticleCount-1))&&((Particles[i+1].SpawnNumber)==(Particles[i].SpawnNumber+1)))
						SuccessorIndex=i+1;
					else
					{
						Stats.SuccessorMisses++;	// Track how many sucessors were missed.
						// Scan through the particles and try to find my successor:
						for(INT j=0;j<ParticleCount;j++)							 // Scan through all potentially active particles.
							if(Particles[j].SpawnNumber==Particles[i].SpawnNumber+1) // And it's my successor.
							{
								SuccessorIndex=j;
								break;
							}
					}

					if(SuccessorIndex==-1) continue; // No sucessor found, can't draw this segment.
					PreviousLocation=Particles[i].Location;
					NextLocation=Particles[SuccessorIndex].Location;
				} else
				{
					PreviousLocation=Particles[i].PreviousLocation;
					NextLocation=Particles[i].Location;

					// If drawscale isn't one, then compute new line length:
					if((Particles[i].DrawScale!=1)||System.ConstantLength)
					{
						FVector Distance=NextLocation-PreviousLocation;
						FLOAT   Length=System.ConstantLength?1:Distance.Size();
						
						if(Length)
						{
							FVector Direction=Distance;
							Direction.Normalize();
							FVector Midpoint=System.ConstantLength?NextLocation:(PreviousLocation+Direction*(Length/2));

							Length*=Particles[i].DrawScale;
							Length/=2;

							PreviousLocation=Midpoint-(Direction*Length);
							NextLocation=Midpoint+(Direction*Length);
						}
					}
				}
				dnDraw3DLine(Frame,Particles[i].Texture,0,PreviousLocation,NextLocation,System.LineStartWidth,System.LineEndWidth,System.LineStartColor,System.LineEndColor);
			}
		} else	
		{

			float BaseParticleScaleX=1.f,
				  BaseParticleScaleY=1.f;
	
			if(Particles[0].Texture)
			{
				//Particles[0].Texture=Particles[0].Texture->Get(appSeconds()/*Frame->Viewport->CurrentTime*/);
				Particles[0].Texture->Lock( CurrentTextureInfo, 0/*Frame->Viewport->CurrentTime*/, -1, Frame->Viewport->RenDev );
				SetTexture( 0, CurrentTextureInfo, 0, false );
				Particles[0].Texture->Unlock(CurrentTextureInfo);
			} 

			UBOOL VariableAlpha=true;
			if((System.AlphaStart==1.f)&&(System.AlphaEnd==1.f)) VariableAlpha=false;
			FLOAT SystemAlphaScale=System.AlphaStartUseSystemAlpha?1.f:System.SystemAlphaScale; 

			for(INT i=0;i<ParticleCount;i++)
			{
				if(!Particles[i].Texture) continue;		// Ignore untextured particles

				QueuedParticle &p=QueuedParticleAlloc(Particles[i].Texture);
				
				// Manage the texture swaps:
				if(Particles[i].Texture!=CurrentTexture)
				{
					CurrentTexture=Particles[i].Texture;
					BaseParticleScaleX=System.TextureScaleX*128*(Particles[i].Texture->USize*(1/256.f));
					BaseParticleScaleY=System.TextureScaleY*128*(Particles[i].Texture->VSize*(1/256.f));
				}
				
				FD3DParticle *Vertices=p.v;

				DWORD dwDiffuse;
				
				if(VariableAlpha)
				{
					FLOAT alphaLevel=Clamp((float)(Particles[i].Alpha*SystemAlphaScale),0.f,1.f);
					dwDiffuse=D3DCOLOR_RGBA((int)Clamp(((float)(alphaLevel*Stages[0]->MaxColor.R)),0.f,(float)Stages[0]->MaxColor.R),
											(int)Clamp(((float)(alphaLevel*Stages[0]->MaxColor.G)),0.f,(float)Stages[0]->MaxColor.G),
											(int)Clamp(((float)(alphaLevel*Stages[0]->MaxColor.B)),0.f,(float)Stages[0]->MaxColor.B),
											(int)Clamp(((float)(alphaLevel*Stages[0]->MaxColor.A)),0.f,(float)Stages[0]->MaxColor.A));

				} else
				{
					dwDiffuse=D3DCOLOR_RGBA(Stages[0]->MaxColor.R,
										    Stages[0]->MaxColor.G, 
											Stages[0]->MaxColor.B,
											Stages[0]->MaxColor.A); 

				}

				float DrawScaleU=(Particles[i].DrawScale*BaseParticleScaleX);
				float DrawScaleV=(Particles[i].DrawScale*BaseParticleScaleY);
			
				// NJS: New:
				FVector RightVector=Frame->Coords.XAxis;
				FVector UpVector   =Frame->Coords.YAxis;
				FVector forward    =Frame->Coords.ZAxis;

				// NJS: Do I have rotation?
				if(Particles[i].Rotation)	
				{
					UpVector   =RotateAboutAxis(UpVector,Particles[i].Rotation,forward);
					RightVector=RotateAboutAxis(RightVector,Particles[i].Rotation,forward);
				}

				UpVector*=DrawScaleV;
				RightVector*=DrawScaleU; 
				FVector vecPos=Particles[i].WorldLocation;

				Vertices[0].Position = vecPos + (-RightVector+UpVector);
				Vertices[0].Diffuse = dwDiffuse;
				Vertices[0].TextureVector = D3DXVECTOR2(1.0f, 1.0f);

				Vertices[1].Position = vecPos + (RightVector+UpVector);
				Vertices[1].Diffuse = dwDiffuse;
				Vertices[1].TextureVector = D3DXVECTOR2(0.0f, 1.0f);

				Vertices[2].Position = vecPos + (RightVector+-UpVector);
				Vertices[2].Diffuse = dwDiffuse;
				Vertices[2].TextureVector = D3DXVECTOR2(0.0f, 0.0f);

				Vertices[3]=Vertices[2];

				Vertices[4].Position = vecPos + (-RightVector+-UpVector) ;
				Vertices[4].Diffuse = dwDiffuse;
				Vertices[4].TextureVector = D3DXVECTOR2(1.0f, 0.0f);

				Vertices[5]=Vertices[0];
			}
		}

		QueueParticleFlush(System,Frame);
		unclock(Stats.ParticleTime);
	}

	struct QueuedLineSegment
	{
		FVector v[2];
		FLOAT Width;
		FColor StartColor,
			   EndColor;
	};

	TArray<QueuedLineSegment> QueuedLines;
	void __fastcall QueuedLinesFlush(ABeamSystem &System,
									 FSceneNode *Frame,
									 UTexture *Texture,
									 DWORD PolyFlags)
	{
		VALIDATE;

		int QueuedLineCount=QueuedLines.Num();
		if(!QueuedLineCount) return;
		SetZBias(0);

		FVector LastStart[2];

		// Compute the height of a sub texture segment
		float SubTextureHeight=1.f;
		if(System.SubTextureCount>1) SubTextureHeight=(1.f/System.SubTextureCount);

		// Whether the reverse pan pass has been performed yet or not.
		bool ReversePanPassDone=false;

		for(;;)
		{
			float XSystemStart=System.BeamTexturePanOffsetX+(System.BeamTexturePanX*System.Level->GameTimeSeconds);
			float XSystemEnd=XSystemStart+System.BeamTextureScaleX;

			if((System.BeamReversePanPass&&ReversePanPassDone))
				Exchange(XSystemStart,XSystemEnd);

			float XFraction=(XSystemEnd-XSystemStart)/QueuedLineCount;

			int SubTextureIndex=0;

			if(System.SubTextureCount>1) 
				SubTextureIndex=appRand()%System.SubTextureCount;

			for(int i=0;i<QueuedLineCount;i++)
			{
				QueuedLineSegment &l=QueuedLines(i);
				QueuedParticle &p=QueuedParticleAlloc(Texture);	// Alloc the particle to hold this line segment.
				FVector &Start=l.v[0];
				FVector &End  =l.v[1];

				FD3DParticle *Vertices=p.v; 
				DWORD dwDiffuseStart=l.StartColor.TrueColor(); 
				DWORD dwDiffuseEnd  =l.EndColor.TrueColor(); 
			
				//FVector forward=Frame->Coords.ZAxis;			
				FVector UpVector=(Start-ViewLocation) cross (End-ViewLocation);
				UpVector.Normalize();

				// texture coordinates:
				float TexLeft=0.f,
					  TexTop=1.f,
					  TexRight=1.f,
					  TexBottom=0.f;

				if(System.SubTextureCount>1) 
				{
					TexBottom=SubTextureIndex*SubTextureHeight;
					TexTop=TexBottom+SubTextureHeight;
				}

				TexLeft=XSystemStart+(i*XFraction);
				TexRight=TexLeft+XFraction;

				Exchange(TexLeft,TexRight);

				float VertPan=System.BeamTexturePanOffsetY+(System.BeamTexturePanY*System.Level->GameTimeSeconds);
				TexTop+=VertPan;
				TexBottom+=VertPan;

				if(i)
				{
					Vertices[0].Position=LastStart[0];
					Vertices[1].Position=LastStart[1];
				} else
				{
					Vertices[0].Position=Start+UpVector*l.Width;
					Vertices[1].Position=Start-UpVector*l.Width;
				}

				Vertices[0].Diffuse=dwDiffuseStart;
				Vertices[0].TextureVector=D3DXVECTOR2(TexRight, TexBottom);

				Vertices[1].Diffuse=dwDiffuseStart;
				Vertices[1].TextureVector=D3DXVECTOR2(TexRight, TexTop);

				Vertices[2].Position=End -UpVector * l.Width; //EndWidth;
				Vertices[2].Diffuse=dwDiffuseEnd;
				Vertices[2].TextureVector=D3DXVECTOR2(TexLeft, TexTop);

				Vertices[3]=Vertices[2];
				
				Vertices[4].Position=End+UpVector*l.Width; 
				Vertices[4].Diffuse=dwDiffuseEnd;
				Vertices[4].TextureVector=D3DXVECTOR2(TexLeft, TexBottom);

				Vertices[5]=Vertices[0];

				LastStart[1]=Vertices[2].Position;
				LastStart[0]=Vertices[4].Position;
			}
			if(System.BeamReversePanPass&&!ReversePanPassDone)
			{
				ReversePanPassDone=true;
				continue;
			}

			break;
		}

		QueuedLines.Clear();
		QueueParticleFlush(System,Frame);
	}

	// Soon to be merged with draw particles, will be modified to dump all lines out at once.
	void __fastcall dnDraw3DLine
	( 
		FSceneNode *Frame, 
		UTexture   *Texture,
		DWORD       PolyFlags, 
		FVector     Start, 
		FVector     End, 
		FLOAT       StartWidth, 
		FLOAT		EndWidth, 
		FColor		StartColor, 
		FColor		EndColor,
		bool		Connected=false
	)
	{
		VALIDATE;

		if(!RenderLines) 
			return;

		// Special case single width lines:
		if((StartWidth==1.f)&&(EndWidth==1.f))
		{
			DWORD PolyFlagsEx=PFX_Clip;
			if(Texture) PolyFlagsEx|=Texture->PolyFlagsEx;

			SetBlending(PolyFlags,PolyFlagsEx);
			SetZBias(0);
			FTextureInfo CurrentTextureInfo;
			
			if(Texture) 
			{
				Texture->Lock( CurrentTextureInfo, Frame->Viewport->CurrentTime, -1, this );
				SetTexture( 0, CurrentTextureInfo, PolyFlags, 0, PolyFlagsEx );
			} else
			{
				//!!should optimize to avoid changing shade mode, color op, alpha op.
				Direct3DDevice8->SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_DISABLE);
				Direct3DDevice8->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
			}

			// Handle lines with a width of one:
			FD3DVertex*	Vertices = (FD3DVertex*) LineVertices.Lock(2);

			Vertices[0].Position=Start;
			Vertices[0].Diffuse = FColor(StartColor).TrueColor();

			Vertices[1].Position=End;
			Vertices[1].Diffuse = FColor(EndColor).TrueColor();

			INT	First = LineVertices.Unlock();

			LineVertices.Set();

			Direct3DDevice8->DrawPrimitive( D3DPT_LINELIST, First, 1 );
			Stats.Particles++;

			if(Texture)
			{
				Texture->Unlock(CurrentTextureInfo);
			} else
			{
				Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
				Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
			}

			return;
		} 

		if(Connected)
		{
			QueuedLineSegment &l=QueuedLines(QueuedLines.Add());

			l.v[0]=Start;
			l.v[1]=End;
			l.Width=StartWidth;
			l.StartColor=StartColor;
			l.EndColor=EndColor;
			return;
		} 

		// Draw unconnected non single width lines:
		QueuedParticle &p=QueuedParticleAlloc(Texture);

		FD3DParticle *Vertices=p.v; 
		DWORD dwDiffuseStart = StartColor.TrueColor(); 
		DWORD dwDiffuseEnd   = EndColor.TrueColor(); 

		// Compute forward and up vectors
		FVector UpVector=(Start-ViewLocation) cross (End-ViewLocation);
		UpVector.Normalize();


		Vertices[0].Position = Start   + UpVector * StartWidth;
		Vertices[0].Diffuse = dwDiffuseStart;
		Vertices[0].TextureVector = D3DXVECTOR2(1.f, 1.f);

		Vertices[1].Position = Start -  UpVector* StartWidth;
		Vertices[1].Diffuse = dwDiffuseStart;
		Vertices[1].TextureVector = D3DXVECTOR2(0.f, 1.f);

		Vertices[2].Position = End -UpVector * EndWidth;
		Vertices[2].Diffuse = dwDiffuseEnd;
		Vertices[2].TextureVector = D3DXVECTOR2(0.f, 0.f);

		Vertices[3]=Vertices[2];
		
		Vertices[4].Position = End + UpVector * EndWidth;
		Vertices[4].Diffuse = dwDiffuseEnd;
		Vertices[4].TextureVector = D3DXVECTOR2(1.f, 0.f);

		Vertices[5]=Vertices[0];
	}

	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar )
	{
		VALIDATE;

		if( URenderDevice::Exec( Cmd, Ar ) )
		{
			return 1;
		}
		else if( ParseCommand(&Cmd,TEXT("GetRes")) )
		{
			if(DisplayModes.Num())
			{
				TArray<FVector> Res;
				for( TArray<D3DDISPLAYMODE>::TIterator It(DisplayModes); It; ++It )
					if( GetFormatBPP(It->Format) == 16)
						Res.AddUniqueItem( FVector(It->Width, It->Height, 0) );
				for( INT i=0; i<Res.Num() && i<16/*script limitation*/; i++ )
					if( Res(i).X<=MaxResWidth && Res(i).Y<=MaxResHeight )
						Ar.Logf( i ? TEXT(" %ix%i") : TEXT("%ix%i"), (INT)Res(i).X, (INT)Res(i).Y );
				return 1;
			}
		}
		else if( ParseCommand(&Cmd,TEXT("LodBias")) )
		{
			LodBias=appAtof(Cmd);
			Ar.Logf(TEXT("Texture LodBias = %f"),LodBias);	
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MIPMAPLODBIAS, *(DWORD*)&LodBias );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MIPMAPLODBIAS, *(DWORD*)&LodBias );
			return 1;
		}

		return 0;
	}

	void __fastcall _Validate(char *File,int Line)
	{
		Super::_Validate(File,Line);

		int Count=Queued3DLineVertices.Num();
		if((Count>=LINE_VERTEXBUFFER_SIZE)||(Count<0))
		{
			appErrorf(TEXT("check((Count<LINE_VERTEXBUFFER_SIZE)&&(Count>=0)) failed! Count=%i this:%08x [%s:%i]"),Queued3DLineVertices.Num(),this,appFromAnsi(File),Line);
			DebugBreak();
		}

	}

	TArray<FD3DVertex> Queued3DLineVertices;
	void __fastcall Queue3DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector OrigP, FVector OrigQ) 
	{
		if(!RenderLines) 
			return;
		
		VALIDATE;
		// Ensure that we don't overflow the line vertex buffer:
		if((Queued3DLineVertices.Num()+12)>=LINE_VERTEXBUFFER_SIZE)
			Queued3DLinesFlush(Frame);


		FD3DVertex &v=Queued3DLineVertices(Queued3DLineVertices.Add());

		v.Position=OrigP;
		v.Diffuse = FColor(Color).TrueColor() | 0xff000000;

		FD3DVertex &v1=Queued3DLineVertices(Queued3DLineVertices.Add());

		v1.Position=OrigQ;
		v1.Diffuse = FColor(Color).TrueColor() | 0xff000000;		
	}

	void __fastcall Queued3DLinesFlush(FSceneNode* Frame) 
	{
		VALIDATE;

		int Count=Queued3DLineVertices.Num();

		// Make sure we don't exceed our maximum size:

		if(!Count) return;
		SetBlending(PF_TwoSided,PFX_Clip|PFX_FlatShade);
		SetZBias(0);

		//!!should optimize to avoid changing shade mode, color op, alpha op.
		//Direct3DDevice8->SetRenderState( D3DRS_SHADEMODE, D3DSHADE_FLAT );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_DISABLE  );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_DISABLE );

		check(Count<LINE_VERTEXBUFFER_SIZE); // NJS: URGENT FIX.. iterate through line vertices. - should never happen because of the check in Queue3DLine, but still.
		FD3DVertex*	Vertices = (FD3DVertex*) LineVertices.Lock(Count);
		memcpy(Vertices,Queued3DLineVertices.GetData(),Count*sizeof(FD3DVertex));
		INT	First = LineVertices.Unlock();
		LineVertices.Set();

		Direct3DDevice8->DrawPrimitive( D3DPT_LINELIST, First, Count/2 );
		// Line code:

		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
		//Direct3DDevice8->SetRenderState( D3DRS_SHADEMODE, D3DSHADE_GOURAUD );

		Queued3DLineVertices.Clear();
	}

	virtual void __fastcall Draw3DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector OrigP, FVector OrigQ )
	{
		VALIDATE;
		if(!RenderLines) return;

		SetBlending(0,PFX_Clip);
		SetZBias(0);

		FD3DVertex*	Vertices = (FD3DVertex*) LineVertices.Lock(2);

		//!!should optimize to avoid changing shade mode, color op, alpha op.
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_DISABLE  );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_DISABLE );

		Vertices[0].Position.X = OrigP.X;
		Vertices[0].Position.Y = OrigP.Y;
		Vertices[0].Position.Z = OrigP.Z;
		Vertices[0].Diffuse = FColor(Color).TrueColor() | 0xff000000;

		Vertices[1].Position.X = OrigQ.X;
		Vertices[1].Position.Y = OrigQ.Y;
		Vertices[1].Position.Z = OrigQ.Z;
		Vertices[1].Diffuse = FColor(Color).TrueColor() | 0xff000000;

		INT	First = LineVertices.Unlock();

		LineVertices.Set();

		Direct3DDevice8->DrawPrimitive( D3DPT_LINELIST, First, 1 );

		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
	}

	void __fastcall Draw2DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector P1, FVector P2 )
	{
		VALIDATE;
		//appErrorf(_T("******** Draw2DLine called, please report to Nick"));
		///*	
		if(!RenderLines) return;
		SetBlending();
		FD3DTLVertex*	Vertices = (FD3DTLVertex*) ActorVertices.Lock(2);

		//!!should optimize to avoid changing shade mode, color op, alpha op.
		Direct3DDevice8->SetRenderState( D3DRS_SHADEMODE, D3DSHADE_FLAT );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_DISABLE  );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_DISABLE );

		Vertices[0].Position.X = P1.X - 0.5f;
		Vertices[0].Position.Y = P1.Y - 0.5f;
		Vertices[0].Position.Z = ProjectionMatrix._33 + ProjectionMatrix._43;
		Vertices[0].Position.W = 1.f;
		Vertices[0].Diffuse = FColor(Color).TrueColor() | 0xff000000;
		Vertices[0].Specular = 0;

		Vertices[1].Position.X = P2.X - 0.5f;
		Vertices[1].Position.Y = P2.Y - 0.5f;
		Vertices[1].Position.Z = ProjectionMatrix._33 + ProjectionMatrix._43;
		Vertices[1].Position.W = 1.f;
		Vertices[1].Diffuse = FColor(Color).TrueColor() | 0xff000000;
		Vertices[1].Specular = 0;

		INT	First = ActorVertices.Unlock();

		ActorVertices.Set();

		Direct3DDevice8->DrawPrimitive( D3DPT_LINELIST, First, 1 );

		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
		Direct3DDevice8->SetRenderState( D3DRS_SHADEMODE, D3DSHADE_GOURAUD );
	}

	void __fastcall UD3DRenderDevice::Draw2DPoint( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FLOAT X1, FLOAT Y1, FLOAT X2, FLOAT Y2, FLOAT Z )
	{
		VALIDATE;
		if(!RenderPoints) 
			return;

		PreRender(Frame);
		SetBlending(0,PFX_FlatShade);

		FD3DTLVertex*	Vertices = (FD3DTLVertex*) ActorVertices.Lock(5);

		//!!should optimize to avoid changing shade mode, color op, alpha op.
		//Direct3DDevice8->SetRenderState( D3DRS_SHADEMODE, D3DSHADE_FLAT );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_DISABLE );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_DISABLE );

		float PositionZ=ProjectionMatrix._33 + ProjectionMatrix._43;
		Vertices[0].Position.X = X1;
		Vertices[0].Position.Y = Y1;
		Vertices[0].Position.Z = PositionZ;
		Vertices[0].Position.W = 1.f;
		Vertices[0].Diffuse = FColor(Color).TrueColor() | 0xff000000;
		Vertices[0].Specular = 0;

		Vertices[1].Position.X = X2;
		Vertices[1].Position.Y = Y1;
		Vertices[1].Position.Z = PositionZ;
		Vertices[1].Position.W = 1.f;
		Vertices[1].Diffuse = FColor(Color).TrueColor() | 0xff000000;
		Vertices[1].Specular = 0;
		
		Vertices[2].Position.X = X2;
		Vertices[2].Position.Y = Y2;
		Vertices[2].Position.Z = PositionZ;
		Vertices[2].Position.W = 1.f; 
		Vertices[2].Diffuse = FColor(Color).TrueColor() | 0xff000000;
		Vertices[2].Specular = 0;

		Vertices[3].Position.X = X1;
		Vertices[3].Position.Y = Y2;
		Vertices[3].Position.Z = PositionZ;
		Vertices[3].Position.W = 1.f;
		Vertices[3].Diffuse = FColor(Color).TrueColor() | 0xff000000;
		Vertices[3].Specular = 0;

		Vertices[4].Position.X = X1;
		Vertices[4].Position.Y = Y1;
		Vertices[4].Position.Z = PositionZ;
		Vertices[4].Position.W = 1.f;
		Vertices[4].Diffuse = FColor(Color).TrueColor() | 0xff000000;
		Vertices[4].Specular = 0;

		INT	First = ActorVertices.Unlock();

		ActorVertices.Set();

		Direct3DDevice8->DrawPrimitive( D3DPT_LINESTRIP, First, 4 );

		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
		Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
	}


#ifdef DOHITTEST
	//	Hit testing.		
	//  Push hit data.
	void __fastcall UD3DRenderDevice::PushHit( const BYTE* Data, INT Count )
	{

		VALIDATE;

		check(Viewport->HitYL<=HIT_SIZE);
		check(Viewport->HitXL<=HIT_SIZE);

		// Get the current render target surface.
		IDirect3DSurface8*	RenderTarget;

		if(FAILED(h=Direct3DDevice8->GetRenderTarget(&RenderTarget)))
		{
			debugf(TEXT("D3D Driver: GetRenderTarget failed (%s)"),DXGetErrorString8(h));
			return;
		}

		// Lock the render target.

		D3DLOCKED_RECT	LockedRect;

		if(FAILED(h=RenderTarget->LockRect(&LockedRect,NULL,0)))
		{
			debugf(TEXT("D3D Driver: LockRect failed (%s)"),DXGetErrorString8(h));
			return;
		}

		// Save the passed info on the working stack.

		INT	Index = HitStack.Add(Count);

		appMemcpy(&HitStack(Index),Data,Count);

		// Cleanup under cursor.
		switch( ViewportColorBits )
		{
			case 16:
			{
				_WORD* src = (_WORD*) LockedRect.pBits;
				src = (_WORD*) ((BYTE*)src + Viewport->HitX * 2 + Viewport->HitY * LockedRect.Pitch);
				for( INT Y=0; Y<Viewport->HitYL; Y++, src=(_WORD*)((BYTE*)src + LockedRect.Pitch) )
				{
					for( INT X=0; X<Viewport->HitXL; X++ )
					{
						HitPixels[X][Y] = src[X];
						src[X] = IGNOREPIX;
					}
				}
				break;
			}
			case 24:
			{
				BYTE* src = (BYTE*) LockedRect.pBits;
				src = src + Viewport->HitX*3  + Viewport->HitY * LockedRect.Pitch;
				for( INT Y=0; Y<Viewport->HitYL; Y++, src+=LockedRect.Pitch )
				{
					for( INT X=0; X<Viewport->HitXL; X++ )
					{
						HitPixels[X][Y] = *((DWORD*)&src[X*3]);
						*((DWORD*)&src[X*3]) = IGNOREPIX;
					}
				}			
				break;
			}
			case 32:
			{
				DWORD* src = (DWORD*) LockedRect.pBits;
				src = (DWORD*)((BYTE*)src + Viewport->HitX * 4 + Viewport->HitY * LockedRect.Pitch);
				for( INT Y=0; Y<Viewport->HitYL; Y++, src=(DWORD*)((BYTE*)src + LockedRect.Pitch) )
				{
					for( INT X=0; X<Viewport->HitXL; X++ )
					{
						HitPixels[X][Y] = src[X];
						src[X] = IGNOREPIX;
					}
				}
				break;
			}
		}

		// Unlock the render target, and release our reference to it.

		RenderTarget->UnlockRect();
		SafeRelease(RenderTarget);
	};

	// Pop hit data.
	void __fastcall UD3DRenderDevice::PopHit( INT Count, UBOOL bForce )
	{
		VALIDATE;

		//debugf(TEXT("POPHIT stacknum   %i  Count %i "),HitStack.Num(),Count);
		check(Count <= HitStack.Num());
		UBOOL Hit=0;

		// Get the current render target surface.
		IDirect3DSurface8*	RenderTarget;

		if(FAILED(h=Direct3DDevice8->GetRenderTarget(&RenderTarget)))
		{
			debugf(TEXT("D3D Driver: GetRenderTarget failed (%s)"),DXGetErrorString8(h));
			return;
		}

		// Lock the render target.
		D3DLOCKED_RECT	LockedRect;

		if(FAILED(h=RenderTarget->LockRect(&LockedRect,NULL,0)))
		{
			debugf(TEXT("D3D Driver: LockRect failed (%s)"),DXGetErrorString8(h));
			return;
		}

		// Check under cursor and restore.
		switch( ViewportColorBits )
		{
			case 16:
			{
				_WORD* src = (_WORD*) LockedRect.pBits;
				src = (_WORD*) ((BYTE*)src + Viewport->HitX * 2 + Viewport->HitY * LockedRect.Pitch);
				for( INT Y=0; Y<Viewport->HitYL; Y++, src=(_WORD*)((BYTE*)src + LockedRect.Pitch) )
				{
					for( INT X=0; X<Viewport->HitXL; X++ )
					{
						if( src[X] != IGNOREPIX )
							Hit=1;
						src[X] = (_WORD)HitPixels[X][Y];	
					
					}
				}
				break;
			}
			case 24:
			{
				BYTE* src = (BYTE*) LockedRect.pBits;
				src = src + Viewport->HitX*3  + Viewport->HitY * LockedRect.Pitch;
				for( INT Y=0; Y<Viewport->HitYL; Y++, src+=LockedRect.Pitch )
				{
					for( INT X=0; X<Viewport->HitXL; X++ )
					{
						if( *((DWORD*)&src[X*3]) != IGNOREPIX )
							Hit=1;
						*((DWORD*)&src[X*3]) = HitPixels[X][Y];						
					}
				}			
				break;
			}
			case 32:
			{
				DWORD* src = (DWORD*) LockedRect.pBits;
				src = (DWORD*)((BYTE*)src + Viewport->HitX * 4 + Viewport->HitY * LockedRect.Pitch);
				for( INT Y=0; Y<Viewport->HitYL; Y++, src=(DWORD*)((BYTE*)src + LockedRect.Pitch) )
				{
					for( INT X=0; X<Viewport->HitXL; X++ )
					{						
						if ( src[X] != IGNOREPIX ) 
							Hit=1;
						src[X] = HitPixels[X][Y];						
					}
				}
				break;
			}		
		}

		// Unlock the render target, and release our reference to it.

		RenderTarget->UnlockRect();
		SafeRelease(RenderTarget);

		// Handle hit.
		if( Hit || bForce )
		{
			if( HitStack.Num() <= *HitSize )
			{
				HitCount = HitStack.Num();
				appMemcpy( HitData, &HitStack(0), HitCount );
			}
			else HitCount = 0;
		}
		// Remove the passed info from the working stack.
		HitStack.Remove( HitStack.Num()-Count, Count );
	}
#else
	void __fastcall UD3DRenderDevice::PushHit( const BYTE* Data, INT Count ) { VALIDATE; }
	void __fastcall UD3DRenderDevice::PopHit( INT Count, UBOOL bForce )		 { VALIDATE; }
#endif 

	void __fastcall GetStats( TCHAR* Result )
	{
		VALIDATE;

		*Result=0;
		appSprintf
		(
			Result,
			TEXT("total:%.1fms (surf=%04i, %03.1fms) (poly=%05i, %.1fms (Queue:%1.fms Render: %.1fms, VertexSetup:%1.fms (Lock:%i %1.fms) DrawPrim:%.1fms) (%i masked)) (tile=%i, %.1fms) (particles=%i, %.1fms (texture changes:%i, succ misses:%i)) (beams=%i, %.1fms) texuploads=%i"),
			GSecondsPerCycle * 1000 *(Stats.SurfTime+Stats.PolyTime+Stats.TileTime+Stats.ParticleTime+Stats.BeamTime),
			Stats.Surfs,
			GSecondsPerCycle * 1000 * Stats.SurfTime,
			Stats.Polys,
			GSecondsPerCycle * 1000 * Stats.PolyTime,
			GSecondsPerCycle * 1000 * Stats.QueueTime,
			GSecondsPerCycle * 1000 * Stats.D3DVertexRender,
			GSecondsPerCycle * 1000 * Stats.D3DVertexSetup,
			Stats.VBLocks,
			GSecondsPerCycle * 1000 * Stats.D3DVertexLock,
			GSecondsPerCycle * 1000 * Stats.D3DPolyTime,
			Stats.MaskedPolys,
			Stats.Tiles,
			GSecondsPerCycle * 1000 * Stats.TileTime,
			Stats.Particles,
			GSecondsPerCycle * 1000 * Stats.ParticleTime,			
			Stats.ParticleTextureChanges,
			Stats.SuccessorMisses,
			Stats.Beams,
			GSecondsPerCycle * 1000 * Stats.BeamTime,			
			Stats.TexUploads
		);

		for( FPixFormat* Fmt=FirstPixelFormat; Fmt; Fmt=Fmt->Next )
			appSprintf
			(
				Result + appStrlen(Result),
				TEXT(" Format:%s (Active/Binned Ram:%iK/%iK, textures:%i/%i) sets:%i (uploads:%i, %.1fms)"),
				Fmt->Desc,
				Fmt->ActiveRAM/1024,
				Fmt->BinnedRAM/1024,
				Fmt->Active,
				Fmt->Binned,
				Fmt->Sets,
				Fmt->Uploads,
				Fmt->UploadCycles * GSecondsPerCycle * 1000.f
			);
	}
	void __fastcall ClearZ( FSceneNode* Frame )
	{
		VALIDATE;

		// Clear only the Z-buffer.
		Direct3DDevice8->Clear( 0, NULL, D3DCLEAR_ZBUFFER|D3DCLEAR_STENCIL, 0, 1.0, 0 );

	}
	void __fastcall ReadPixels( FColor* Pixels, UBOOL BackBuffer = false)
	{
		VALIDATE;

		IDirect3DSurface8*	TempScreenBuffer;
	
		if (!BackBuffer)
		{
			// Create the temp surface to hold the front buffer
			D3D_CHECK((h=Direct3DDevice8->CreateImageSurface( ViewportX, ViewportY, D3DFMT_A8R8G8B8, &TempScreenBuffer )));

			// Fill the temporary surface with the contents of the front buffer.
			D3D_CHECK((h=Direct3DDevice8->GetFrontBuffer( TempScreenBuffer )));
		}
		else
		{
			EndScene();

			// Get a pointer to the back buffer
			D3D_CHECK((h=Direct3DDevice8->GetBackBuffer(0, D3DBACKBUFFER_TYPE_MONO, &TempScreenBuffer)));
		}

		// Lock the temporary surface.
		D3DLOCKED_RECT	LockedRect;
		memset(&LockedRect,0,sizeof(LockedRect));

		D3D_CHECK((TempScreenBuffer->LockRect(&LockedRect,NULL,D3DLOCK_READONLY)));

		// Compute gamma correction.
		BYTE	GammaCorrect[256];
		INT		Index;

		if(DeviceCaps8.Caps2 & D3DCAPS2_FULLSCREENGAMMA)
		{
			//FLOAT Gamma = Viewport->GetOuterUClient()->Gamma;
			FLOAT Brightness = Viewport->GetOuterUClient()->Brightness;
			//FLOAT Contrast = Viewport->GetOuterUClient()->Contrast;

			if(!Brightness) Brightness=0.01;
			for(Index = 0;Index < 256;Index++)
				GammaCorrect[Index] = Clamp<INT>(appPow(Index/255.0,1.0/Brightness)*65535.0,0,65535);

				//GammaCorrect[Index] = Clamp<INT>( appRound( (Contrast+0.5f)*appPow(Index/255.f,1.0f/Gamma)*65535.f + (Brightness-0.5f)*32768.f - Contrast*32768.f + 16384.f ) / 256, 0, 255 );
		}
		else
		{
			for(Index = 0;Index < 256;Index++)
				GammaCorrect[Index] = Index;
		}
		

		// Copy the contents of the temporary surface to the destination.
		FColor*	Dest = Pixels;
		INT		X, Y;

		if (BackBuffer)
		{
			D3DSURFACE_DESC	Desc;
			DWORD			rl, rr, gl, gr, bl, br, mask;
			DWORD			RBitMask = 0, GBitMask = 0, BBitMask = 0, BitCount = 0;
			DWORD			R, G, B;

			TempScreenBuffer->GetDesc(&Desc);

			switch (Desc.Format)
			{
				case D3DFMT_R8G8B8:
				{
					RBitMask = 0xff0000;
					GBitMask = 0x00ff00;
					BBitMask = 0x0000ff;
					BitCount = 24;
					break;
				}
				case D3DFMT_A8R8G8B8:
				case D3DFMT_X8R8G8B8:
				{
					RBitMask = 0xff0000;
					GBitMask = 0x00ff00;
					BBitMask = 0x0000ff;
					BitCount = 32;
					break;
				}
				case D3DFMT_R5G6B5:
				{
					RBitMask = (31<<11);
					GBitMask = (63<<5 );
					BBitMask = (31<<0 );
					BitCount = 16;
					break;
				}
				case D3DFMT_X1R5G5B5:
				case D3DFMT_A1R5G5B5:
				{
					RBitMask = (31<<10);
					GBitMask = (31<<5 );
					BBitMask = (31<<0 );
					BitCount = 16;
					break;
				}
			}

			// Compute needed bit shifts.
			for( rr=0, mask=RBitMask; !(mask&1); mask>>=1, ++rr );
			for( rl=8; mask&1; mask>>=1, --rl );
			for( gr=0, mask=GBitMask; !(mask&1); mask>>=1, ++gr );
			for( gl=8; mask&1; mask>>=1, --gl );
			for( br=0, mask=BBitMask; !(mask&1); mask>>=1, ++br );
			for( bl=8; mask&1; mask>>=1, --bl );

			switch (BitCount)
			{
				case 16:
				{
					WORD	*Src = (WORD*) LockedRect.pBits;
					INT		Extra = (LockedRect.Pitch/sizeof(WORD)) - ViewportX;
				
					for(Y = 0;Y < ViewportY;Y++)
					{
						for(X = 0;X < ViewportX;X++)
						{		
							R = (((*Src) & RBitMask) >> rr) << rl;
							G = (((*Src) & GBitMask) >> gr) << gl;
							B = (((*Src) & BBitMask) >> br) << bl;

							GET_COLOR_DWORD(*Dest++) = (R<<16)|(G<<8)|B;
							Src++;
						}
			
						Src += Extra;
					}
					break;
				}
				case 24:
				{
					char	*Src = (char*) LockedRect.pBits;
					INT		Extra = (LockedRect.Pitch - ViewportX*3);
				
					for(Y = 0;Y < ViewportY;Y++)
					{
						for(X = 0;X < ViewportX;X++)
						{		
							R = (((*((DWORD*)Src)) & RBitMask) >> rr) << rl;
							G = (((*((DWORD*)Src)) & GBitMask) >> gr) << gl;
							B = (((*((DWORD*)Src)) & BBitMask) >> br) << bl;

							GET_COLOR_DWORD(*Dest++) = (R<<16)|(G<<8)|B;
							Src+=3;
						}
			
						Src += Extra;
					}
					break;
				}

				case 32:
				{
					DWORD	*Src = (DWORD*) LockedRect.pBits;
					INT		Extra = (LockedRect.Pitch/sizeof(DWORD)) - ViewportX;
				
					for(Y = 0;Y < ViewportY;Y++)
					{
						for(X = 0;X < ViewportX;X++)
						{		
							R = (((*Src) & RBitMask) >> rr) << rl;
							G = (((*Src) & GBitMask) >> gr) << gl;
							B = (((*Src) & BBitMask) >> br) << bl;

							GET_COLOR_DWORD(*Dest++) = (R<<16)|(G<<8)|B;
							Src++;
						}
			
						Src += Extra;
					}
					break;
				}
			}
		}
		else
		{
			char*	Src = (char*) LockedRect.pBits;

			for(Y = 0;Y < ViewportY;Y++)
			{
				for(X = 0;X < ViewportX;X++)
				{
					GET_COLOR_DWORD(*Dest++) = *((DWORD*) Src);
					Src += sizeof(DWORD);
				}
			
				Src += (LockedRect.Pitch - (ViewportX * sizeof(DWORD)));
			}
		}
		// Unlock the temporary surface.

		TempScreenBuffer->UnlockRect();

		// Release the temporary surface.
		SafeRelease(TempScreenBuffer);

		if (BackBuffer)
			BeginScene();

	}
	void __fastcall UD3DRenderDevice::EndFlash()
	{
		VALIDATE;

		if( FlashScale!=FVector(.5f,.5f,.5f) || FlashFog!=FVector(0,0,0) )
		{
			// Set up color.
			FColor	 D3DColor = FColor(FPlane(FlashFog.X,FlashFog.Y,FlashFog.Z,Min(FlashScale.X*2.f,1.f)));					
			D3DCOLOR Color    = D3DCOLOR_RGBA(D3DColor.R, D3DColor.G, D3DColor.B, D3DColor.A);

			// Initialize vertex array
			FD3DScreenVertex Vertices[4];

			Vertices[0].Position.X = 0;
			Vertices[0].Position.Y = 0;
			Vertices[0].Position.W = 0.5f;
			Vertices[0].Position.Z = ProjectionMatrix._33 + ProjectionMatrix._43 * 0.5f;
			GET_COLOR_DWORD(Vertices[0].Color) = Color;

			Vertices[1].Position.X = 0;
			Vertices[1].Position.Y = Viewport->SizeY;
			Vertices[1].Position.W = 0.5f;
			Vertices[1].Position.Z = ProjectionMatrix._33 + ProjectionMatrix._43 * 0.5f;
			GET_COLOR_DWORD(Vertices[1].Color) = Color;

			Vertices[2].Position.X = Viewport->SizeX;
			Vertices[2].Position.Y = Viewport->SizeY;
			Vertices[2].Position.Z = ProjectionMatrix._33 + ProjectionMatrix._43 * 0.5f;
			Vertices[2].Position.W = 0.5f;
			GET_COLOR_DWORD(Vertices[2].Color) = Color;

			Vertices[3].Position.X = Viewport->SizeX;
			Vertices[3].Position.Y = 0;
			Vertices[3].Position.W = 0.5f;
			Vertices[3].Position.Z = ProjectionMatrix._33 + ProjectionMatrix._43 * 0.5f;
			GET_COLOR_DWORD(Vertices[3].Color) = Color;			

			
			// Draw it.
			SetBlending( PF_Translucent| PF_NoOcclude | PF_TwoSided, PFX_Clip );
			//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
			//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_ONE );			
			//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_SRCALPHA );
			SetAlphaBlendEnable(TRUE);
			SetSrcBlend(D3DBLEND_ONE);
			SetDstBlend(D3DBLEND_SRCALPHA);

			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_DISABLE ); // v 0.4
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG2 );
			Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_ALWAYS );

			Direct3DDevice8->SetVertexShader( FD3DScreenVertex::FVF );
			Direct3DDevice8->DrawPrimitiveUP( D3DPT_TRIANGLEFAN, 2, Vertices, sizeof(FD3DScreenVertex) );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
			Direct3DDevice8->SetRenderState( D3DRS_ZFUNC, D3DCMP_LESSEQUAL );
			SetBlending();
		}
	}

	//============================================================================================
	//	API's for caching and Tracking D3D's internal state:
	//============================================================================================
	float __fastcall SetZBias( FLOAT NewZBias=0.f )
	{
		VALIDATE;

		float FormerZBias=ZBias;

		NewZBias=Clamp(NewZBias,0.f,16.f);
		if(ZBias!=NewZBias || !CacheBlending)
		{
			ZBias=NewZBias;
			Direct3DDevice8->SetRenderState(D3DRS_ZBIAS,ZBias);
		}

		return FormerZBias;
	}

	D3DBLEND __fastcall SetSrcBlend( D3DBLEND NewSrcBlend = D3DBLEND_ZERO )
	{
		D3DBLEND FormerSrcBlend=SrcBlend;

		if(NewSrcBlend!=FormerSrcBlend || !CacheBlending)
		{
			check((NewSrcBlend>0)&&(NewSrcBlend<=D3DBLEND_BOTHINVSRCALPHA));
			Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND,  NewSrcBlend );
			SrcBlend=NewSrcBlend;
		}

		return FormerSrcBlend;
	}

	D3DBLEND __fastcall SetDstBlend( D3DBLEND NewDstBlend = D3DBLEND_ZERO )
	{
		D3DBLEND FormerDstBlend=DstBlend;

		if(NewDstBlend!=FormerDstBlend || !CacheBlending)
		{
			check((NewDstBlend>0)&&(NewDstBlend<=D3DBLEND_BOTHINVSRCALPHA));
			Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND,  NewDstBlend );
			DstBlend=NewDstBlend;
		}

		return FormerDstBlend;
	}

	INT __fastcall SetAlphaBlendEnable(INT NewAlphaBlendEnable)
	{
		INT FormerAlphaBlendEnable=AlphaBlendEnable;
		check((NewAlphaBlendEnable==TRUE)||(NewAlphaBlendEnable==FALSE));
		if(NewAlphaBlendEnable!=FormerAlphaBlendEnable || !CacheBlending )
		{
			Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, NewAlphaBlendEnable );
			AlphaBlendEnable=NewAlphaBlendEnable;
		}

		return FormerAlphaBlendEnable;
	}

	HRESULT __fastcall BeginScene()
	{
		BeginSceneCount++;
		//check(BeginSceneCount==1);

		return Direct3DDevice8->BeginScene();
	}

	HRESULT __fastcall EndScene()
	{
		BeginSceneCount--;
		//check(BeginSceneCount==0);

		return Direct3DDevice8->EndScene();
	}

	//============================================================================================
	// Unreal's Original Blending System, trying to get away from this, and go with direct D3D
	// state caching:
	//============================================================================================
	void __fastcall SetBlending( DWORD PolyFlags=0, DWORD PolyFlagsEx=0 )
	{
		VALIDATE;

		//if(!GIsEditor) PolyFlags&=~PF_Selected;
		// Adjust PolyFlags according to Unreal's precedence rules.
		// Allows gouraud-polygonal fog only if specular is supported (1-pass fogging).
		if( (PolyFlags & (PF_RenderFog|PF_Translucent|PF_Modulated))!=PF_RenderFog || !UseVertexSpecular )
			PolyFlags &= ~PF_RenderFog;

		if( (!(PolyFlags & (PF_Translucent|PF_Modulated))&&(!(PolyFlagsEx & (PFX_AlphaMap|PFX_LightenModulate|PFX_DarkenModulate|PFX_Translucent2)))) )
			PolyFlags |= PF_Occlude;
		else if( PolyFlags & PF_Translucent )
			PolyFlags &= ~PF_Masked;

		// Detect changes in the blending modes.
		DWORD Xor   = CurrentPolyFlags   ^ PolyFlags;
		DWORD XorEx = CurrentPolyFlagsEx ^ PolyFlagsEx;
		// Adjust Cull Mode based on 'two sided flag*
		if(Xor&PF_TwoSided)
		{
			Direct3DDevice8->SetRenderState( D3DRS_CULLMODE,(PolyFlags&PF_TwoSided)?D3DCULL_NONE:D3DCULL_CCW);
		}

		if(XorEx&PFX_Clip)
		{
			Direct3DDevice8->SetRenderState( D3DRS_CLIPPING, (bool)(PolyFlagsEx&PFX_Clip));
		}

		if(XorEx&PFX_FlatShade)
		{
			Direct3DDevice8->SetRenderState( D3DRS_SHADEMODE, (PolyFlagsEx&PFX_FlatShade)?D3DSHADE_FLAT:D3DSHADE_GOURAUD );
		}

		if( (Xor  & (PF_Translucent|PF_Modulated|PF_Invisible|PF_Occlude|PF_Masked|PF_Highlighted|PF_NoSmooth|PF_RenderFog|PF_Memorized|PF_Selected)) 
		  ||(XorEx& (PFX_AlphaMap|PFX_LightenModulate|PFX_DarkenModulate|PFX_Translucent2)))
		{
			if( Xor&(PF_Invisible|PF_Translucent|PF_Modulated|PF_Highlighted) || (XorEx&(PFX_AlphaMap|PFX_LightenModulate|PFX_DarkenModulate|PFX_Translucent2)))
			{
				if ((XorEx & PFX_AlphaMap) && (!(PolyFlagsEx & PFX_AlphaMap)))
				{
					if (UseTrilinear)
						Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MIPFILTER , D3DTEXF_LINEAR );
					else
						Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MIPFILTER , D3DTEXF_POINT  );
					
					Direct3DDevice8->SetRenderState( D3DRS_ALPHAREF, 127);
					Direct3DDevice8->SetRenderState( D3DRS_ALPHATESTENABLE, FALSE );
				}

				if( !(PolyFlags & (PF_Invisible|PF_Translucent|PF_Modulated|PF_Highlighted)) && !(PolyFlagsEx & (PFX_AlphaMap|PFX_LightenModulate|PFX_DarkenModulate|PFX_Translucent2)))
				{
					SetAlphaBlendEnable(FALSE);
					//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, FALSE );
				}
				else if( PolyFlagsEx & PFX_Translucent2)
				{
					//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
					//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, Src);
					//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, Dst );
					SetAlphaBlendEnable(TRUE);
					SetSrcBlend(D3DBLEND_SRCALPHA);
					SetDstBlend(D3DBLEND_INVSRCCOLOR);
				}
				else if( PolyFlags & PF_Invisible )
				{
					//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
					//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_ZERO );
					//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_ONE );
					SetAlphaBlendEnable(TRUE);
					SetSrcBlend(D3DBLEND_ZERO);
					SetDstBlend(D3DBLEND_ONE);
				}
				else if(PolyFlagsEx &PFX_DarkenModulate )
				{
					//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
					//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, 1  );
					//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, 3  );
					SetAlphaBlendEnable(TRUE);
					SetSrcBlend(D3DBLEND_ZERO);
					SetDstBlend(D3DBLEND_SRCCOLOR);
				}
				else if( PolyFlagsEx & PFX_LightenModulate )
				{
					//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
					//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, 2  );
					//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, 2  );
					SetAlphaBlendEnable(TRUE);
					SetSrcBlend(D3DBLEND_ONE);
					SetDstBlend(D3DBLEND_ONE);
				} 
				else if( PolyFlags & PF_Translucent )
				{
					//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
					//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_ONE );
					//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCCOLOR );
					SetAlphaBlendEnable(TRUE);
					SetSrcBlend(D3DBLEND_ONE);
					SetDstBlend(D3DBLEND_INVSRCCOLOR);
				}
				else if( PolyFlags & PF_Modulated )
				{
					//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
					//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_DESTCOLOR );
					//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_SRCCOLOR );
					SetAlphaBlendEnable(TRUE);
					SetSrcBlend(D3DBLEND_DESTCOLOR);
					SetDstBlend(D3DBLEND_SRCCOLOR);
				}
				else if( PolyFlags & PF_Highlighted )
				{
					//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
					//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_ONE );
					//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA );
					SetAlphaBlendEnable(TRUE);
					SetSrcBlend(D3DBLEND_ONE);
					SetDstBlend(D3DBLEND_INVSRCALPHA);
				}
				else if( PolyFlagsEx & PFX_AlphaMap )
				{
					//debugf(_T("**Turning alphamap on."));
					//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE);
					//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
					//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
					SetAlphaBlendEnable(TRUE);
					SetSrcBlend(D3DBLEND_SRCALPHA);
					SetDstBlend(D3DBLEND_INVSRCALPHA);

					Direct3DDevice8->SetRenderState( D3DRS_ALPHAREF, 8);
					Direct3DDevice8->SetRenderState( D3DRS_ALPHAFUNC, D3DCMP_GREATER );
					Direct3DDevice8->SetRenderState( D3DRS_ALPHATESTENABLE, 1 );

					Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG1);
					Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
					Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
					
					Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MIPFILTER , D3DTEXF_NONE );
				}
			}
			
			if( Xor & PF_Invisible )
			{
				UBOOL Invisible = ((PolyFlags&PF_Invisible)!=0);
				SetAlphaBlendEnable(Invisible);
				//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, Invisible );
				//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_ZERO );
				//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_ONE );
				SetSrcBlend(D3DBLEND_ZERO);
				SetDstBlend(D3DBLEND_ONE);

			}
			if( Xor & PF_Occlude )
			{
				Direct3DDevice8->SetRenderState( D3DRS_ZWRITEENABLE, (PolyFlags&PF_Occlude)!=0 );
			}
			if( Xor & PF_Masked )
			{
				if( PolyFlags&PF_Masked )
				{
					Direct3DDevice8->SetRenderState( D3DRS_ALPHAREF, 127 );
					Direct3DDevice8->SetRenderState( D3DRS_ALPHAFUNC, D3DCMP_GREATER );
					Direct3DDevice8->SetRenderState( D3DRS_ALPHATESTENABLE, 1 );
				}
				else
				{
					Direct3DDevice8->SetRenderState( D3DRS_ALPHATESTENABLE, 0 );
				}
			}
			if( Xor & PF_NoSmooth )
			{
				Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MAGFILTER, (PolyFlags & PF_NoSmooth) ? D3DTEXF_POINT : D3DTEXF_LINEAR );
				Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MINFILTER, (PolyFlags & PF_NoSmooth) ? D3DTEXF_POINT : D3DTEXF_LINEAR );
			}
			if( Xor & PF_RenderFog )
			{
				Direct3DDevice8->SetRenderState( D3DRS_SPECULARENABLE, (PolyFlags&PF_RenderFog)!=0 );
			}
			if( (Xor & PF_Memorized) || (Xor & PF_Selected) )
			{
				if( PolyFlags&PF_Memorized )
				{
					// Lightmap
					Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_MODULATE );
					Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ALPHAOP, D3DTOP_SELECTARG2 );
				}
				else
				if( PolyFlags&PF_Selected )
				{
					// Alphamap
					Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_SELECTARG2 );
					Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1 );
				}
				else
				{
					Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_DISABLE );
					Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ALPHAOP, D3DTOP_DISABLE );
				}
			}
		}

		CurrentPolyFlags  =PolyFlags;
		CurrentPolyFlagsEx=PolyFlagsEx;
	}


	void __forceinline ReleaseOldestTexture()
	{
		VALIDATE;

		if(!CachedTextures) return;

		INT Threshold=CachedTextures->Filler->PixelFormat->ActiveRAMPeak+1024*1024*3;
		if(Threshold<7*1024*1024) Threshold=7*1024*1024;

		while(CachedTextures && (CachedTextures->Filler->PixelFormat->BinnedRAM>Threshold))
		{
			FTexInfo *LowestFrameCount=NULL;
			FTexInfo *LowestFrameCountPrevious=NULL;
			FTexInfo *Previous=NULL;
			for(FTexInfo *Iterator=CachedTextures;Iterator;Previous=Iterator,Iterator=Iterator->NextTexture)
			{
				if(!LowestFrameCount||(Iterator->FrameCounter<=LowestFrameCount->FrameCounter))
				{
					// Don't kick out anything that isn't over 60 frames old.
					if((FrameCounter-Iterator->FrameCounter)>60)
					{
						LowestFrameCount=Iterator;
						LowestFrameCountPrevious=Previous;
					}
				}
			}

			if(!LowestFrameCount) return;

			LowestFrameCount->Filler->PixelFormat->BinnedRAM -= LowestFrameCount->SizeBytes;
			LowestFrameCount->Filler->PixelFormat->Binned--;

			// Detach myself from the normal list:
			if(!LowestFrameCountPrevious)
			{
				CachedTextures=CachedTextures->NextTexture;
			} else
			{
				LowestFrameCountPrevious->NextTexture=LowestFrameCount->NextTexture;
			}

			INT	HashIndex = ((7*(DWORD)LowestFrameCount->CacheId+(DWORD)(LowestFrameCount->CacheId>>32))) & (ARRAY_COUNT(TextureHash)-1);

			Previous=NULL;
			for(Iterator = TextureHash[HashIndex];
				Iterator && Iterator!=LowestFrameCount;
				Previous=Iterator,Iterator = Iterator->HashNext)
				;

			if(Iterator==LowestFrameCount)
			{
				if(!Previous)
				{
					TextureHash[HashIndex]=TextureHash[HashIndex]->HashNext;
				} else
				{
					Previous->HashNext=LowestFrameCount->HashNext;
				}
			}

			if(LowestFrameCount->Texture8)
				SafeRelease(LowestFrameCount->Texture8);
			
			SafeDelete(LowestFrameCount);

		}
	}

	void __forceinline __fastcall SetTextureNULL( DWORD dwStage )
	{
		check((dwStage>=0)&&(dwStage<ARRAY_COUNT(Stages)));

		Direct3DDevice8->SetTexture( dwStage, NULL );
		Stages[dwStage] = &NoTexture;
	}

	void __fastcall SetTexture( DWORD dwStage, FTextureInfo& Info, DWORD PolyFlags=0, UBOOL Precache=FALSE, DWORD PolyFlagsEx=0, UBOOL IsLightmap=FALSE )
	{
		check((dwStage>=0)&&(dwStage<ARRAY_COUNT(Stages)));

		UBOOL Masking=(PolyFlags&PF_Masked)?TRUE:FALSE;
		if(Stages[dwStage] && Stages[dwStage]->CacheId == Info.CacheID && Stages[dwStage]->Masking==Masking)
			return;

		INT	HashIndex = (7 * (DWORD) Info.CacheID + (DWORD) (Info.CacheID >> 32)) & (ARRAY_COUNT(TextureHash) - 1);


		for(FTexInfo* TexInfo = TextureHash[HashIndex];
			TexInfo && !(TexInfo->CacheId == Info.CacheID && TexInfo->Masking==Masking);
			TexInfo = TexInfo->HashNext)
			;

		if(!TexInfo)
		{
			if(Use2ndTierTextureCache) 
				ReleaseOldestTexture();

			// Create a new Direct3D texture.
			TexInfo = new FTexInfo;
			TexInfo->CacheId = Info.CacheID;
			TexInfo->Masking=Masking;

			TexInfo->NextTexture = CachedTextures;
			CachedTextures = TexInfo;

			TexInfo->HashNext = TextureHash[HashIndex];
			TextureHash[HashIndex] = TexInfo;

			// Get filler object.

			FTexFiller*	Filler = NULL;

			switch(Info.Format)
			{
				case TEXF_P8:    Filler = ( !Format1555.Supported || Use32BitTextures )? (FTexFiller*) &Filler8888_P8 : (FTexFiller*) &Filler1555_P8; break;
				case TEXF_DXT1:  Filler = &FillerDXT1; break;
				case TEXF_RGBA7: Filler = (!Format1555.Supported || Use32BitTextures ) ? (FTexFiller*) &Filler8888_RGBA7 : (FTexFiller*) &Filler1555_RGBA7; break;
				case TEXF_RGBA8: Filler = &Filler8888_RGBA8; break;
				default:
					appErrorf(TEXT("Unsupported Texture Format"));
			}
			
			TexInfo->Filler=Filler;
			if(Info.bParametric) 
			{
				TexInfo->UseMips=false;
				Info.NumMips=1;
			}

			// Calculate the mipmap to use.
			DWORD	FirstMip = 0;

			while(Info.Mips[FirstMip]->USize > (INT) DeviceCaps8.MaxTextureWidth || Info.Mips[FirstMip]->VSize > (INT) DeviceCaps8.MaxTextureHeight)
				if(++FirstMip >= (DWORD) Info.NumMips)
					appErrorf(TEXT("D3D Driver: Encountered oversize texture without sufficient mipmaps"));

			DWORD	USize = Info.Mips[FirstMip]->USize,
					VSize = Info.Mips[FirstMip]->VSize;

			// Setup the texture info.
			TexInfo->FirstMip = FirstMip;
			TexInfo->UScale	= 1.f / (USize * (1 << FirstMip) * Info.UScale);
			TexInfo->VScale	= 1.f / (VSize * (1 << FirstMip) * Info.VScale);
			TexInfo->UseMips = (FirstMip < (DWORD) Info.NumMips - 1);

			// Create the Direct3D texture.
			D3D_CHECK((h=Direct3DDevice8->CreateTexture(USize,VSize,Info.NumMips - FirstMip,0,Filler->PixelFormat->Direct3DFormat,
				D3DPOOL_MANAGED,&TexInfo->Texture8)));

			TexInfo->SizeBytes = Info.USize * Info.VSize * TexInfo->Filler->PixelFormat->BitsPerPixel / 8;
			if(!Info.NumMips) TexInfo->SizeBytes+=TexInfo->SizeBytes/3;		

			TexInfo->Filler->PixelFormat->Binned++;
			TexInfo->Filler->PixelFormat->BinnedRAM += TexInfo->SizeBytes;

			Info.bRealtimeChanged = 1;
		}

		// Transfer texture data.
		if( Info.bRealtimeChanged /*&& Info.bParametric || (Info.Format==TEXF_RGBA7 && GET_COLOR_DWORD(*Info.MaxColor)==0xFFFFFFFF)*/ )
		{
			DWORD Cycles=0;
			clock(Cycles);

			// Get ready for blt.		
			if(!IsLightmap&&!Use2ndTierTextureCache) Info.Load();	// Dynamically load the texture if it hasn't already been done. (auto checks for parametric)

			//debugf(_T("Uploading texture:%s"),Info.Texture->GetFullName());
			Info.CacheMaxColor();
			TexInfo->MaxColor = (Format8888.Supported && Use32BitTextures) ? FColor(255,255,255,1) : *Info.MaxColor;

			// Update texture data.
			TexInfo->Filler->PixelFormat->Uploads++;
			TexInfo->Filler->BeginUpload( TexInfo, Info, PolyFlags, PolyFlagsEx );
			INT	Count = Info.NumMips - TexInfo->FirstMip;
			for( INT MipIndex=TexInfo->FirstMip, ListIndex=0; ListIndex<Count; ListIndex++,MipIndex++ )
			{
				// Lock the mip-level.
				D3DLOCKED_RECT	LockedRect;
				D3DSURFACE_DESC	SurfaceDesc;
				int				BPP=GetFormatBPP(TexInfo->Filler->PixelFormat->Direct3DFormat);

				TexInfo->Texture8->GetLevelDesc(ListIndex,&SurfaceDesc);
				TexInfo->Texture8->LockRect(ListIndex,&LockedRect,NULL,0);
				
				if(Info.Mips[MipIndex]->DataPtr)
				{
					if(Info.Format==TEXF_RGBA7)
					{
						TexInfo->Filler->UploadMipmap(TexInfo,(BYTE*) LockedRect.pBits,LockedRect.Pitch,Info,MipIndex,PolyFlags);
					} else
					{
						for(DWORD u = 0;u < SurfaceDesc.Width;u += Info.Mips[MipIndex]->USize)
							for(DWORD v = 0;v < SurfaceDesc.Height;v += Info.Mips[MipIndex]->VSize)
								TexInfo->Filler->UploadMipmap(TexInfo,(BYTE*) LockedRect.pBits + u * BPP / 8 + v * LockedRect.Pitch,LockedRect.Pitch,Info,MipIndex,PolyFlags);
					}
				}

				// Unlock the mip-level.
				TexInfo->Texture8->UnlockRect(ListIndex);
			}
			Stats.TexUploads++;

			// Unload texture.
			Info.bRealtimeChanged = 0;
			
			if(!Info.bRealtime&&!Info.bParametric&&!IsLightmap&&!Use2ndTierTextureCache&&(Info.Texture&&!Info.Texture->IsA(UProceduralTexture::StaticClass()))) Info.Unload();	
			unclock(Cycles);
			TexInfo->Filler->PixelFormat->UploadCycles += Cycles;
		}
		
		if( Precache )
		{
			Stages[dwStage] = TexInfo;
			return;
		}
		// Update texture info.

		if(TexInfo->FrameCounter != FrameCounter)
		{
			TexInfo->Filler->PixelFormat->Active++;
			TexInfo->Filler->PixelFormat->ActiveRAM += TexInfo->SizeBytes;
		}

		TexInfo->FrameCounter = FrameCounter;
		TexInfo->Filler->PixelFormat->Sets++;

		// Set Direct3D state.
		Direct3DDevice8->SetTexture(dwStage,TexInfo->Texture8);

		if(!Stages[dwStage] || TexInfo->UseMips != Stages[dwStage]->UseMips)
			Direct3DDevice8->SetTextureStageState(dwStage,D3DTSS_MIPFILTER,TexInfo->UseMips == 0 ? D3DTEXF_NONE : UseTrilinear ? D3DTEXF_LINEAR : D3DTEXF_POINT);
		
		Stages[dwStage] = TexInfo;
		VALIDATE;

	}

	// JEP...
	void CleanupRenderTargetResources(void)
	{
		for (INT i = 0; i < RenderTargetArray.Num(); i++)
			ShutdownRenderTargetRes(&RenderTargetArray(i));

		SafeRelease(ClipperTexture);
	}
	// ...JEP

	void RecognizePixelFormat( FPixFormat& Dest, const D3DFORMAT Direct3DFormat, const TCHAR* InDesc )
	{
		VALIDATE;

		Dest.Supported		 = true;
		Dest.Direct3DFormat  = Direct3DFormat;
		Dest.Desc		     = InDesc;
		Dest.BitsPerPixel	 = GetFormatBPP(Direct3DFormat);
		Dest.Next            = FirstPixelFormat;
		FirstPixelFormat     = &Dest;
	}

	UBOOL __fastcall SetRes( INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
	{
		debugf(TEXT("SetRes(NewX=%i,NewY=%i,NewColorBytes=%i,Fullscreen%i) (this:%08x);"),NewX,NewY,NewColorBytes,Fullscreen,this);
		// Verify my current state:
		verify(this);
		verify(Direct3D8);
		verify(NewColorBytes<=4);
		//if(BeginSceneCount) EndScene();
		//check(LockCount==0);
		if(LockCount>0) 
			Unlock(0);

		// If D3D already inited, uninit it now.:
		UnSetRes(NULL,0);

		// Enumerate device display modes.
		DisplayModes.Empty(Direct3D8->GetAdapterModeCount(BestAdapterIndex));

		for(DWORD Index=0;Index<Direct3D8->GetAdapterModeCount(BestAdapterIndex);Index++)
		{
			D3DDISPLAYMODE	DisplayMode;
			Direct3D8->EnumAdapterModes(BestAdapterIndex,Index,&DisplayMode);

			if((DisplayMode.Width >=640)
			 &&(DisplayMode.Height>=480))
				DisplayModes.AddItem(DisplayMode);
		}

		// Exit if just testing.
		if(!Viewport)
		{
			SaveConfig();
			UnSetRes(TEXT("Successfully tested Direct3D presence"),0);
			return 1;
		}

		// Remember parameters.
		ViewporthWnd       = (HWND)Viewport->GetWindow();
		ViewportX          = Min( NewX, MaxResWidth  );
		ViewportY          = Min( NewY, MaxResHeight );
		ViewportColorBits  = NewColorBytes * 8;
		ViewportFullscreen = Fullscreen;

		D3DFORMAT AdapterFormat;

		// See if the window is full screen.
		if(Fullscreen)
		{
			if(DisplayModes.Num()==0 )
				return UnSetRes(TEXT("No fullscreen display modes found"),0);

			// Find matching display mode.

			INT	BestMode = 0,
				BestError = MAXINT;

			for(INT Index = 0;Index < DisplayModes.Num();Index++)
			{
				INT ThisError
				=	Abs((INT)DisplayModes(Index).Width -(INT)ViewportX)
				+	Abs((INT)DisplayModes(Index).Height-(INT)ViewportY)
				+	Abs((INT)GetFormatBPP(DisplayModes(Index).Format)-(INT)ViewportColorBits);

				if(ThisError < BestError && (GetFormatBPP(DisplayModes(Index).Format)==16 || GetFormatBPP(DisplayModes(Index).Format)==24 || GetFormatBPP(DisplayModes(Index).Format)==32) && (DisplayModes(Index).Format >= D3DFMT_R8G8B8 && DisplayModes(Index).Format <= D3DFMT_X4R4G4B4))
				{
					BestMode = Index;
					BestError = ThisError;
				//	debugf(NAME_Init,TEXT("Next mode is best match so far:"));
				}
				
				//debugf(NAME_Init,TEXT("Enum modes: %ix%ix%i "),(INT)DisplayModes(Index).Width,(INT)DisplayModes(Index).Height,GetFormatBPP(DisplayModes(Index).Format));
			}

			if(BestError == MAXINT)
				return UnSetRes(TEXT("No acceptable display modes found"),0);

			ViewportColorBits = GetFormatBPP(DisplayModes(BestMode).Format);
			ViewportX         = DisplayModes(BestMode).Width;
			ViewportY         = DisplayModes(BestMode).Height;

			AdapterFormat = DisplayModes(BestMode).Format;

			debugf(NAME_Init,TEXT("Best-match display mode: %ix%ix%i (Error=%i)"),DisplayModes(BestMode).Width,DisplayModes(BestMode).Height,GetFormatBPP(DisplayModes(BestMode).Format),BestError);

		}
		else
		{
#if 0
			D3DDISPLAYMODE	DisplayMode;

			if(FAILED(h=Direct3D8->GetAdapterDisplayMode(BestAdapterIndex,&DisplayMode)))
				return UnSetRes(TEXT("GetAdapterDisplayMode"),h);

			AdapterFormat = DisplayMode.Format;
			ViewportColorBits = GetFormatBPP(AdapterFormat);
#else
			AdapterFormat = OriginalDisplayMode.Format;
			//ViewportX = OriginalDisplayMode.Width;
			//ViewportY= OriginalDisplayMode.Height;
			ViewportColorBits = GetFormatBPP(AdapterFormat);
#endif
		}

		// Setup the presentation parameters.
		D3DPRESENT_PARAMETERS PresentParms;
		appMemzero(&PresentParms,sizeof(PresentParms));

		//Fullscreen=1;
		//if(GIsEditor)
		PresentParms.Flags = D3DPRESENTFLAG_LOCKABLE_BACKBUFFER;

		PresentParms.Windowed = !Fullscreen;
		PresentParms.hDeviceWindow = (HWND)ViewporthWnd;
		PresentParms.SwapEffect = Fullscreen ? D3DSWAPEFFECT_DISCARD : D3DSWAPEFFECT_COPY;
		PresentParms.BackBufferWidth = Max(ViewportX,1);
		PresentParms.BackBufferHeight = Max(ViewportY,1);
		PresentParms.BackBufferCount = (Fullscreen ? (UseTripleBuffering ? 3: 2) : 1);
		PresentParms.EnableAutoDepthStencil = TRUE;
		PresentParms.FullScreen_PresentationInterval = Fullscreen ? (UseVSync ? D3DPRESENT_INTERVAL_ONE : D3DPRESENT_INTERVAL_IMMEDIATE) : D3DPRESENT_INTERVAL_DEFAULT;
		PresentParms.FullScreen_RefreshRateInHz=D3DPRESENT_RATE_DEFAULT;

		//PresentParms.FullScreen_PresentationInterval=D3DPRESENT_INTERVAL_DEFAULT/*D3DPRESENT_INTERVAL_ONE*/ /*D3DPRESENT_INTERVAL_IMMEDIATE*/;
		//PresentParms.SwapEffect=D3DSWAPEFFECT_COPY;
		
		// Determine which back buffer format to use.
		D3DFORMAT BackBufferFormat = (ViewportColorBits == 32 ? D3DFMT_A8R8G8B8 : ViewportColorBits == 16 ? D3DFMT_R5G6B5 : D3DFMT_X8R8G8B8);
		while(Direct3D8->CheckDeviceFormat(BestAdapterIndex,D3DDEVTYPE_HAL,AdapterFormat,D3DUSAGE_RENDERTARGET,D3DRTYPE_SURFACE,BackBufferFormat) != D3D_OK)
		{
				 if(BackBufferFormat == D3DFMT_A8R8G8B8)	BackBufferFormat = D3DFMT_X8R8G8B8; 
			else if(BackBufferFormat == D3DFMT_X8R8G8B8)	BackBufferFormat = D3DFMT_R5G6B5;
			else if(BackBufferFormat == D3DFMT_R8G8B8)		BackBufferFormat = D3DFMT_X8R8G8B8;
			else if(BackBufferFormat == D3DFMT_R5G6B5)		BackBufferFormat = D3DFMT_X1R5G5B5;
			else return UnSetRes(TEXT("CheckDeviceFormat"),0);

			if(Fullscreen)
				AdapterFormat = BackBufferFormat;
		}

		PresentParms.BackBufferFormat = BackBufferFormat;

		// Determine which depth buffer format to use.
		D3DFORMAT DepthFormat = (ViewportColorBits==32 ? D3DFMT_D32 : D3DFMT_D16);

		while(Direct3D8->CheckDeviceFormat(BestAdapterIndex,D3DDEVTYPE_HAL,AdapterFormat,D3DUSAGE_DEPTHSTENCIL,D3DRTYPE_SURFACE,DepthFormat) != D3D_OK ||
			  Direct3D8->CheckDepthStencilMatch(BestAdapterIndex,D3DDEVTYPE_HAL,AdapterFormat,BackBufferFormat,DepthFormat) != D3D_OK)
		{
			     if(DepthFormat == D3DFMT_D32)    DepthFormat = D3DFMT_D24S8;
			else if(DepthFormat == D3DFMT_D24S8)  DepthFormat = D3DFMT_D16;
			else if(DepthFormat == D3DFMT_D16)
				return UnSetRes(TEXT("CheckDepthStencilMatch"),0);
		}

		//debugf(TEXT("Using depth-buffer format %u(%u-bit)"),DepthFormat,GetFormatBPP(DepthFormat));
		PresentParms.AutoDepthStencilFormat = DepthFormat;

#ifdef LOG_PRESENT_PARMS
		// Dump present parms, useful for debugging.
		LogPresentParms(PresentParms);
#endif

		if(Direct3DDevice8)
		{
			CleanupRenderTargetResources();
			CleanupVertexBuffers();

			//SafeRelease(Direct3DDevice8);

			D3D_CHECK(Direct3DDevice8->Reset(&PresentParms));
		} 

		if(!Direct3DDevice8)
		{ 
			//PresentParms.SwapEffect=D3DSWAPEFFECT_DISCARD;
			PresentParms.MultiSampleType=D3DMULTISAMPLE_NONE;
			
			// Create the Direct3D device.
			if(FAILED(h=Direct3D8->CreateDevice(BestAdapterIndex,D3DDEVTYPE_HAL,ViewporthWnd,D3DCREATE_HARDWARE_VERTEXPROCESSING,&PresentParms,&Direct3DDevice8)))
			{
				debugf(TEXT("ViewporthWnd:%08x"),ViewporthWnd);
				debugf(TEXT("Failed to set hardware vertex processing: %s, attempting to set software vertexprocessing"),DXGetErrorString8(h));
				// If hardware vertex processing failed, switch to software:
				if(FAILED(h=Direct3D8->CreateDevice(BestAdapterIndex,D3DDEVTYPE_HAL,ViewporthWnd,D3DCREATE_SOFTWARE_VERTEXPROCESSING,&PresentParms,&Direct3DDevice8)))
					return UnSetRes(TEXT("CreateDevice (Failed to set software vertex processing)"),h);
				else
					debugf(_T("Device is using software vertex processing."));
			} 
		}

		// Set viewport.
		ViewportInfo.X      = 0;
		ViewportInfo.Y      = 0;
		ViewportInfo.Width  = ViewportX;
		ViewportInfo.Height = ViewportY;
		ViewportInfo.MaxZ   = 1.f;
		ViewportInfo.MinZ   = 0.f;
		verify(!FAILED(Direct3DDevice8->SetViewport(&ViewportInfo)));
		verify(!FAILED(Direct3DDevice8->GetViewport(&ViewportInfo)));

		// Handle the texture formats we need.
		{
			// Determine which texture formats the device supports by calling CheckDeviceFormat for each supported format.
			FirstPixelFormat = NULL;

			if(!FAILED(Direct3D8->CheckDeviceFormat(BestAdapterIndex,D3DDEVTYPE_HAL,AdapterFormat,0,D3DRTYPE_TEXTURE,D3DFMT_A8R8G8B8)))
				RecognizePixelFormat(Format8888,D3DFMT_A8R8G8B8,TEXT("A8R8G8B8"));
						
			if(!FAILED(Direct3D8->CheckDeviceFormat(BestAdapterIndex,D3DDEVTYPE_HAL,AdapterFormat,0,D3DRTYPE_TEXTURE,D3DFMT_A1R5G5B5)))
			   RecognizePixelFormat(Format1555,D3DFMT_A1R5G5B5,TEXT("A1R5G5B5"));
		}

		// Verify mipmapping supported.
		if(!(DeviceCaps8.TextureFilterCaps & D3DPTFILTERCAPS_MIPFPOINT)
		 &&!(DeviceCaps8.TextureFilterCaps & D3DPTFILTERCAPS_MIPFLINEAR))
		{
			appErrorf(TEXT("D3D Driver: Mipmapping not available with this driver"));
		} else
		{
			if( DeviceCaps8.TextureFilterCaps & D3DPTFILTERCAPS_MIPFLINEAR )
				debugf( NAME_Init, TEXT("D3D Driver: Supports trilinear"));
			else
				UseTrilinear = 0;
		}

		// Check caps.
		if( DeviceCaps8.ShadeCaps & D3DPSHADECAPS_SPECULARGOURAUDRGB )
 			debugf( NAME_Init, TEXT("D3D Driver: Supports specular gouraud") );
		else
			UseVertexSpecular = 0;

		if( DeviceCaps8.TextureOpCaps & D3DTEXOPCAPS_BLENDDIFFUSEALPHA )
			debugf( NAME_Init, TEXT("D3D Driver: Supports BLENDDIFFUSEALPHA") );
		else
			DetailTextures = 0;


		// Depth buffering.
		Direct3DDevice8->SetRenderState( D3DRS_ZENABLE, D3DZB_TRUE  );
#if 0
		/* NJS: Potentially enable W-buffering if it exists. */
		if(	DeviceCaps8.RasterCaps & D3DPRASTERCAPS_WBUFFER)
		{
			debugf( NAME_Init, TEXT("D3D Driver: Supports w-buffering.") );
			if((ViewportColorBits==16) ) // NVidia w-buffering in 32-bit color is borked on Pentium III's.
			{
				Direct3DDevice8->SetRenderState( D3DRS_ZENABLE, D3DZB_USEW );
				debugf( NAME_Init, TEXT("D3D Driver: w-buffering enabled.") );
			} else
				debugf(NAME_Init, TEXT("D3D Driver: w-buffering NOT enabled."));
		}
#endif

		// Init render states.
		{
			Direct3DDevice8->SetRenderState( D3DRS_SPECULARENABLE, FALSE );
			Direct3DDevice8->SetRenderState( D3DRS_DITHERENABLE, TRUE );
			Direct3DDevice8->SetRenderState( D3DRS_ZFUNC,D3DCMP_LESSEQUAL);
			Direct3DDevice8->SetRenderState( D3DRS_FOGCOLOR, 0 );        
			Direct3DDevice8->SetRenderState( D3DRS_FOGTABLEMODE, D3DFOG_LINEAR );
			FLOAT FogStart=0.f, FogEnd = 65535.f;
			Direct3DDevice8->SetRenderState( D3DRS_FOGSTART, *(DWORD*)&FogStart );
			Direct3DDevice8->SetRenderState( D3DRS_FOGEND, *(DWORD*)&FogEnd );
			Direct3DDevice8->SetRenderState( D3DRS_LIGHTING, FALSE );
			ZBias=-1.f;	// Set ZBias to an invalid state to force it to be reset next time SetZBias is called
			SrcBlend=(D3DBLEND)0;
			DstBlend=(D3DBLEND)0;
			AlphaBlendEnable=-1;
			BeginSceneCount=0;
			LockCount=0;
			TextureClampMode=-1;

			D3DMATERIAL8 Material8;
			memset(&Material8,0,sizeof(Material8));

			Material8.Ambient.r = 1.0f; Material8.Ambient.g = 1.0f; Material8.Ambient.b = 1.0f; Material8.Ambient.a = 1.0f;
			Material8.Diffuse.r = 0.5f; Material8.Diffuse.g = 0.5f; Material8.Diffuse.b = 0.5f; Material8.Diffuse.a = 1.0f;
			Material8.Power = 0.f;

			Direct3DDevice8->SetMaterial(&Material8);
			Direct3DDevice8->SetRenderState(D3DRS_SHADEMODE,D3DSHADE_GOURAUD);
			Direct3DDevice8->SetRenderState(D3DRS_EMISSIVEMATERIALSOURCE,D3DMCS_COLOR1);
			Direct3DDevice8->SetRenderState(D3DRS_DIFFUSEMATERIALSOURCE,D3DMCS_MATERIAL);
		}

		// Init texture stage state.
		{
			// Set stage 0 state.
			//FLOAT LodBias=-0.5f;
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MIPMAPLODBIAS, *(DWORD*)&LodBias );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ADDRESSU,   D3DTADDRESS_WRAP );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ADDRESSV,   D3DTADDRESS_WRAP );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLORARG2, D3DTA_DIFFUSE );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_COLOROP,   D3DTOP_MODULATE );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_ALPHAOP,   D3DTOP_MODULATE );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MAGFILTER, D3DTEXF_LINEAR );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MINFILTER, D3DTEXF_LINEAR );
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_MIPFILTER, (UseTrilinear ? D3DTEXF_LINEAR : D3DTEXF_POINT));
			Direct3DDevice8->SetTextureStageState( 0, D3DTSS_TEXCOORDINDEX, 0 );

			// Set stage 1 state.
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MIPMAPLODBIAS, *(DWORD*)&LodBias );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSU,   D3DTADDRESS_WRAP );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSV,   D3DTADDRESS_WRAP );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG2, D3DTA_CURRENT );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP,   D3DTOP_DISABLE );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ALPHAARG1, D3DTA_TEXTURE );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ALPHAARG2, D3DTA_CURRENT );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ALPHAOP,   D3DTOP_DISABLE );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MAGFILTER, D3DTEXF_LINEAR );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MINFILTER, D3DTEXF_LINEAR );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MIPFILTER, UseTrilinear ? D3DTEXF_LINEAR : D3DTEXF_POINT  );
			Direct3DDevice8->SetTextureStageState( 1, D3DTSS_TEXCOORDINDEX, 1 );
		}

		// Update the viewport.
		verify(Viewport->ResizeViewport((Fullscreen ? BLIT_Fullscreen : 0) | BLIT_Direct3D, NewX, ViewportY, ViewportColorBits / 8 ));
		Lock( FColor(0,0,0), 0, 0, FPlane(0,0,0,0), FPlane(0,0,0,0), FPlane(0,0,0,0), LOCKR_ClearScreen, NULL, NULL );
		Unlock(1);

		// Allocate dynamic vertex buffers.
		WorldVertices.Init(Direct3DDevice8,WORLDSURFACE_VERTEXBUFFER_SIZE);
		ActorVertices.Init(Direct3DDevice8,ACTORPOLY_VERTEXBUFFER_SIZE);
		LineVertices.Init(Direct3DDevice8,LINE_VERTEXBUFFER_SIZE);
		ParticleVertices.Init(Direct3DDevice8,PARTICLE_VERTEXBUFFER_SIZE);

	#ifdef BATCH_PROJECTOR_POLYS
		ProjectorVertices.Init(Direct3DDevice8, PROJECTOR_VERTEXBUFFER_SIZE);
	#endif
		Flush(!GIsEditor);	// Don't force a precache.

		// JEP...
		// Determine which rendertarget format to use, and create clipper texture
		{
			D3DDISPLAYMODE		DisplayMode;

			Direct3D8->GetAdapterDisplayMode(BestAdapterIndex,&DisplayMode);

			AdapterFormat = DisplayMode.Format;

			//RenderTargetFormat = D3DFMT_R5G6B5;
			RenderTargetFormat = AdapterFormat;

			TCHAR *FmtStr = TEXT("Unknown");

			if (Direct3D8->CheckDeviceFormat(BestAdapterIndex,D3DDEVTYPE_HAL,AdapterFormat,D3DUSAGE_RENDERTARGET,D3DRTYPE_SURFACE,RenderTargetFormat) != D3D_OK)
				RenderTargetFormat = D3DFMT_UNKNOWN;

			#define FMT2STR(x) case x: FmtStr = TEXT(#x); break;

			switch (RenderTargetFormat)
			{
				FMT2STR(D3DFMT_A8R8G8B8);
				FMT2STR(D3DFMT_X8R8G8B8);
				FMT2STR(D3DFMT_R5G6B5);
				FMT2STR(D3DFMT_X1R5G5B5);
			}

			debugf(NAME_Init,TEXT("Rendertarget format: %s"), FmtStr);
		
			if (RenderTargetFormat != D3DFMT_UNKNOWN)
			{
				// Create a 128x1 clipper texture (also used to fade projected textures out)
				if (Direct3DDevice8->CreateTexture(128,1,1,0,D3DFMT_R5G6B5,D3DPOOL_MANAGED,&ClipperTexture) == D3D_OK)
				{
					debugf(NAME_Init,TEXT("Clipper texture created"));

					D3DLOCKED_RECT	LockedRect;
					D3DSURFACE_DESC	SurfaceDesc;

					ClipperTexture->GetLevelDesc(0,&SurfaceDesc);

					if (ClipperTexture->LockRect(0,&LockedRect,NULL,0) == D3D_OK)
					{
						WORD *Bits = (WORD*)LockedRect.pBits;

						// Create a grey scale ramp
						for(DWORD u = 0;u < SurfaceDesc.Width; u++)
						{
							WORD	Val = (u<<1);
				
							if (u == 0)		// This is the pixel that will actually clip out pixels that are behind the near projector plane
								Val = 255;

							Bits[u] = ((Val>>3)<<11) | ((Val>>2)<<5) | (Val>>3);
						}

						ClipperTexture->UnlockRect(0);
					}
				}
			}

			// If we already have some render targets, re-create them with (potentially) new format
			for (INT i = 0; i < RenderTargetArray.Num(); i++)
				if (!InitRenderTargetRes(&RenderTargetArray(i)))
					appErrorf(TEXT("SetRes: InitRenderTargetRes FAILED"));
		}
		// ...JEP

		return 1;
	}

	UBOOL __fastcall UnSetRes( const TCHAR* Msg, HRESULT h )
	{
		if(BeginSceneCount) EndScene();

		Flush(0);
		CleanupRenderTargetResources();	// JEP: Free render targets
		CleanupVertexBuffers();

		if( Msg ) debugf(NAME_Init,TEXT("%s (%s)"),Msg,DXGetErrorString8(h));
		return 0;
	}

	D3DCOLOR UpdateModulation( INT& ModulateThings, FPlane& FinalColor, const FPlane& MaxColor )
	{
		VALIDATE;

		FinalColor *= MaxColor;
		return --ModulateThings ? 0xffffffff : (FColor(FinalColor).TrueColor() | 0xff000000);
	}

	void SetDistanceFog(UBOOL Enable)
	{	
		VALIDATE;

		if((!UseDistanceFog)||(Enable==DistanceFogEnabled)) return;

		if(Enable)
		{		
			// Enable fog.
			Direct3DDevice8->SetRenderState(D3DRS_FOGENABLE, TRUE);
			Direct3DDevice8->SetRenderState(D3DRS_RANGEFOGENABLE, TRUE);

			// Set the fog color.
			Direct3DDevice8->SetRenderState(D3DRS_FOGCOLOR, ((DWORD)(DistanceFogColor.R)<<16) | ((DWORD)(DistanceFogColor.G)<<8) | ((DWORD)(DistanceFogColor.B)));

			// Set fog parameters.
			Direct3DDevice8->SetRenderState(D3DRS_FOGTABLEMODE, D3DFOG_LINEAR);
			Direct3DDevice8->SetRenderState(D3DRS_FOGSTART, *(DWORD *)(&DistanceFogBegin));
			Direct3DDevice8->SetRenderState(D3DRS_FOGEND,   *(DWORD *)(&DistanceFogEnd));
		}
		else
			Direct3DDevice8->SetRenderState(D3DRS_FOGENABLE, FALSE);		

		DistanceFogEnabled=Enable;
	}

	// JEP...
	#define RENDER_TARGET_TO_INDEX(x) ((INT)x-1)
	#define INDEX_TO_RENDER_TARGET(x) ((void*)(x+1))		// The +1 is so that we can assume 0 is NULL

	//============================================================================================
	//	InitRenderTargetRes
	//============================================================================================
	UBOOL InitRenderTargetRes(RenderTargetInfo *RT)
	{
		if (!RT->Active)
		{
			if (RT->pRenderTargetTex || RT->pRenderTargetSurf)
				appErrorf(TEXT("InitRenderTargetRes: RenderTarget is invalid."));
			return true;
		}

		if (RT->pRenderTargetTex)
		{
			if (!RT->pRenderTargetSurf)
				appErrorf(TEXT("InitRenderTargetRes: RenderTarget is invalid (no surface)."));
			return true;
		}

		if (Direct3DDevice8->CreateTexture(RT->Width,RT->Height,1,D3DUSAGE_RENDERTARGET,RenderTargetFormat,D3DPOOL_DEFAULT,&RT->pRenderTargetTex) != D3D_OK)
			return false;

		RT->pRenderTargetTex->GetSurfaceLevel(0, &RT->pRenderTargetSurf);

		return true;
	}

	//============================================================================================
	//	ShutdownRenderTargetRes
	//============================================================================================
	UBOOL ShutdownRenderTargetRes(RenderTargetInfo *RT)
	{
		if (!RT->Active)
		{
			if (RT->pRenderTargetSurf || RT->pRenderTargetTex)
				appErrorf(TEXT("ShutdownRenderTargetRes: RenderTarget is invalid."));
			return true;
		}

		SafeRelease(RT->pRenderTargetSurf);

		SafeRelease(RT->pRenderTargetTex);

		RT->pRenderTargetSurf = NULL;
		RT->pRenderTargetTex = NULL;

		return true;
	}

	//============================================================================================
	//	CreateRenderTarget
	//============================================================================================
	void *CreateRenderTarget(INT W, INT H)
	{
		if (RenderTargetFormat == D3DFMT_UNKNOWN)
			return NULL;

		RenderTargetInfo	RenderTarget;

		memset(&RenderTarget, 0, sizeof(RenderTarget));

		RenderTarget.Width = W;
		RenderTarget.Height = H;

		RenderTarget.Active = true;

		if (!InitRenderTargetRes(&RenderTarget))
			return NULL;

		// Look on the free'd list first
		if (FreeRenderTargets.Num())
		{
			INT FreeIndex = FreeRenderTargets(0);
			RenderTargetArray(FreeIndex) = RenderTarget;
			FreeRenderTargets.Remove(0);
			return INDEX_TO_RENDER_TARGET(FreeIndex);
		}

		return INDEX_TO_RENDER_TARGET(RenderTargetArray.AddItem(RenderTarget));
	}
	
	//============================================================================================
	//	DestroyRenderTarget
	//============================================================================================
	void DestroyRenderTarget(void **pRenderTarget) 
	{
		INT	Index = RENDER_TARGET_TO_INDEX(*pRenderTarget);

		if (Index < 0 || Index >= RenderTargetArray.Num())
			appErrorf(TEXT("DestroyRenderTarget: Invalid RenderTarget"));
		
		ShutdownRenderTargetRes(&RenderTargetArray(Index));
		
		RenderTargetArray(Index).Active = false;

		*pRenderTarget = NULL;
		
		FreeRenderTargets.AddItem(Index);
	}

	//============================================================================================
	//	SetRenderTarget
	//============================================================================================
	void SetRenderTarget(void *pRenderTarget, void *pNewZStencil)
	{
		INT Index = RENDER_TARGET_TO_INDEX(pRenderTarget);

		if (Index < 0 || Index >= RenderTargetArray.Num())
			appErrorf(TEXT("SetRenderTarget: Invalid RenderTarget"));

		if (!pOriginalZStencil)
		{
			// Remember the original render targets
			Direct3DDevice8->GetRenderTarget(&pOriginalRenderTarget);
			Direct3DDevice8->GetDepthStencilSurface(&pOriginalZStencil);
		}

		if (!RenderTargetArray(Index).pRenderTargetSurf)
			appErrorf(TEXT("AddProjector: NULL RenderTargetSurf"));

		// Set the render target
		Direct3DDevice8->SetRenderTarget(RenderTargetArray(Index).pRenderTargetSurf, NULL);
		
		// Clear the render target
		Direct3DDevice8->Clear(0, NULL, D3DCLEAR_TARGET, 0xffffffff, 1.f, 0 );
		/*
		D3DRECT		Rect;

		Rect.x1 = 1;
		Rect.y1 = 1;
		Rect.x2 = 127;
		Rect.y2 = 127;

		Direct3DDevice8->Clear(1, &Rect, D3DCLEAR_TARGET, 0, 1.f, 0 );
		*/
		
		CurrentRenderTarget = pRenderTarget;
	}
	
	//============================================================================================
	//	RestoreRenderTarget
	//============================================================================================
	void RestoreRenderTarget(void)
	{
		if (!pOriginalZStencil)
			return;			// Already using original rendertarget
		
		// Set the rendertarget/zstencil back to the original
		Direct3DDevice8->SetRenderTarget(pOriginalRenderTarget, pOriginalZStencil);

		// Release the copies we had
		SafeRelease(pOriginalRenderTarget);
		SafeRelease(pOriginalZStencil);

		// Set them to NULL to we know next time around that we have been restored
		pOriginalRenderTarget = NULL;
		pOriginalZStencil = NULL;

		CurrentRenderTarget = NULL;
	}

	//============================================================================================
	//	DrawTex
	//============================================================================================
	void __fastcall DrawTex(FSceneNode			*Frame, 
							FLOAT				X, FLOAT Y, 
							FLOAT				XL, FLOAT YL, 
							FLOAT				U, FLOAT V,
							FLOAT				UL, FLOAT VL,
							IDirect3DTexture8	*Tex)
	{
		VALIDATE;
		
		SetDistanceFog(false);
	
		//SetBlending(PFX_DarkenModulate);//PF_Modulated);
		SetBlending();
		SetTextureNULL(0);
		
		Direct3DDevice8->SetTexture(0, Tex);

		SetTextureClampMode(1);

		FD3DTLVertex	*Vertices = (FD3DTLVertex*) ActorVertices.Lock(4);

		DWORD dwDiffuse = 0xffffffff;

		for (INT i=0; i<4; i++)
		{
			Vertices[i].Diffuse    = dwDiffuse;
			Vertices[i].Position.Z = 1.0f;
			Vertices[i].Position.W = 1.0f;
		}

		Vertices[0].Position.X=X;    Vertices[0].Position.Y=Y;    Vertices[0].U[0]=U;		Vertices[0].U[1]=V   ;
		Vertices[1].Position.X=X+XL; Vertices[1].Position.Y=Y;    Vertices[1].U[0]=U+UL; 	Vertices[1].U[1]=V   ;
		Vertices[2].Position.X=X+XL; Vertices[2].Position.Y=Y+YL; Vertices[2].U[0]=U+UL;    Vertices[2].U[1]=V+VL;
		Vertices[3].Position.X=X;    Vertices[3].Position.Y=Y+YL; Vertices[3].U[0]=U;	    Vertices[3].U[1]=V+VL;

		INT	First=ActorVertices.Unlock();
		
		ActorVertices.Set();

		Direct3DDevice8->DrawPrimitive( D3DPT_TRIANGLEFAN, First, 2 );
		Direct3DDevice8->SetTexture(0, NULL);
		
		SetTextureClampMode(0);
	}

	//============================================================================================
	//	AddProjector
	//============================================================================================
	void __fastcall AddProjector(FSceneNode *Frame, void *pRenderTarget, FTextureInfo *Info, FLOAT wNear, FLOAT wFar, FLOAT FadeScale)
	{
		ProjectorInfo	Projector;
		
		Projector.Frame = Frame;
		
		Projector.CameraToLight = Frame->Coords;
		Projector.CameraToLight <<= Frame->Parent->Uncoords;
		
		Projector.OneOverX = 1.0f/(float)Frame->X;
		Projector.OneOverY = 1.0f/(float)Frame->Y;

		Projector._33 = wFar / (wFar - wNear);
		Projector._43 = -Projector._33 * wNear;
		Projector.FadeScale = FadeScale;

		if (Frame->Level && Frame->Level->Model)
			Projector.GNodes = &Frame->Level->Model->Nodes(0);
		else
			Projector.GNodes = NULL;

		if (pRenderTarget)
		{
			INT Index = RENDER_TARGET_TO_INDEX(pRenderTarget);

			if (Index < 0 || Index >= RenderTargetArray.Num())
				appErrorf(TEXT("AddProjector: Invalid RenderTarget"));

			RenderTargetInfo &RT = RenderTargetArray(Index);

			// Assign the texture to this projector
			Projector.pRenderTargetTex = RT.pRenderTargetTex;

	#if 1
		// Render tex into itself, have convolution smooth texture out
		#if 1
			if (CurrentRenderTarget == pRenderTarget)
			{
				if (!TempRT)
					TempRT = CreateRenderTarget(128, 128);

				if (TempRT)
				{
					INT Index2 = RENDER_TARGET_TO_INDEX(TempRT);

					if (Index2 < 0 || Index2 >= RenderTargetArray.Num())
						appErrorf(TEXT("AddProjector: Invalid RenderTarget2"));

					RenderTargetInfo &RT2 = RenderTargetArray(Index2);

					SetRenderTarget(TempRT, NULL);

					float Val = (1.0f/128.0f);

					DrawTex(Frame, 0.0f, 0.0f, 127.0f, 127.0f,Val*0.5f,Val*0.5f, 1.0f, 1.0f, RT.pRenderTargetTex);
					SetRenderTarget(pRenderTarget, NULL);
					DrawTex(Frame, 0.0f, 0.0f, 127.0f, 127.0f,-Val*0.5f,-Val*0.5f, 1.0f, 1.0f, RT2.pRenderTargetTex);
				}
			}
		#else
			if (CurrentRenderTarget == pRenderTarget)
			{
				float Val = (1.0f/128.0f);
			
				EndScene();
				BeginScene();

				DrawTex(Frame, 0.0f, 0.0f, 127.0f, 127.0f,Val*0.5f,Val*0.5f, 1.0f, 1.0f, RT.pRenderTargetTex);
				DrawTex(Frame, 0.0f, 0.0f, 127.0f, 127.0f,-Val*0.5f,-Val*0.5f, 1.0f, 1.0f, RT.pRenderTargetTex);
			}
		#endif
	#endif

			if (!Projector.pRenderTargetTex)
				appErrorf(TEXT("AddProjector: NULL RenderTarget"));
		}
		else
		{
			//Projector.pRenderTargetTex = NULL;
			//Projector.Texture = Info->Texture;
		}

		ProjectorArray.AddItem(Projector);
	}

	//============================================================================================
	//	ResetProjectors
	//============================================================================================
	void __fastcall ResetProjectors(void)
	{
	#ifdef BATCH_PROJECTOR_POLYS
		FlushProjectorPolys();
	#endif

		ProjectorArray.Clear();
	}
	
#ifdef BATCH_PROJECTOR_POLYS
	//============================================================================================
	//	FlushProjectorPolys
	//============================================================================================
	void __fastcall FlushProjectorPolys(void)
	{
		if (!NumProjectorSurfs)
		{
			check(NumProjectorPolys == 0);
			check(NumProjectorVerts == 0);
			return;
		}
	
		ProjectorVertices.Set();

		SetTextureNULL( 0 );
		SetTextureNULL( 1 );
		SetBlending( PF_Modulated );
		SetDistanceFog(false);

		SetTextureClampMode(1);

		//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_DESTCOLOR );
		//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_ZERO );
		SetAlphaBlendEnable(TRUE);
		SetSrcBlend(D3DBLEND_DESTCOLOR);
		SetDstBlend(D3DBLEND_ZERO);

		// Setup clipper texture (also used for fade out)
		Direct3DDevice8->SetTexture(1, ClipperTexture);
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_ADD);
		//Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_DISABLE);
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);

		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSU, D3DTADDRESS_CLAMP );
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSV, D3DTADDRESS_CLAMP );

		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MAGFILTER, D3DTEXF_POINT);
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MINFILTER, D3DTEXF_POINT);

		for (INT p=0; p< ProjectorArray.Num(); p++)
		{
			ProjectorInfo *pProjector = &ProjectorArray(p);

			// Lock the projector verts
			FD3DScreenVertex *V= (FD3DScreenVertex*)ProjectorVertices.Lock(NumProjectorVerts);

			static	PolysVisible[1024];

			for (INT i=0; i< NumProjectorSurfs; i++)
			{
				ProjectorSurf	*Surf = &ProjectorSurfs[i];

				if (!(Surf->ProjectorFlags & (1<<p)))
					continue;

				INT				*Poly = &ProjectorPolys[Surf->FirstPoly];
				FVector			*PP = &ProjectorPoints[Surf->FirstVert];
				FD3DTLVertex	*PV = &ProjectorVerts[Surf->FirstVert];

				for (INT j=0; j<Surf->NumPolys; j++)
				{
					// Compute outcodes.
					BYTE Outcode = FVF_OutReject;

					for (INT v=0; v<Poly[j]; v++)
					{
						V->Position.X = PV->Position.X;    
						V->Position.Y = PV->Position.Y;
						V->Position.Z = PV->Position.Z;
						V->Position.W = PV->Position.W;
						V->Color = 0xffffffff;
						
						// Grab a copy of the vert
						FTransform		P;

						// Transform point into projector space
						P.Point = PP->TransformPointBy(pProjector->CameraToLight);

					#if 1	
						// Project point onto projector front plane
						P.Point.Z = max(1.0f, P.Point.Z);
						P.Project(pProjector->Frame);
						
						P.ComputeOutcode(pProjector->Frame);
						Outcode &= P.Flags;

						// Snag UV's
						V->U[0] = P.ScreenX*pProjector->OneOverX;
						V->U[1] = P.ScreenY*pProjector->OneOverY; 
						
						V->Position.W *= P.Point.Z;
					#else
						// Ortho projection
						V->U[0] = (P.Point.X/125)+0.5f;
						V->U[1] = (P.Point.Y/125)+0.5f;
					#endif

						// Clip and fade out (this is the UV's for the clipper/fade out texture layer)
					#if 1
						FLOAT R = P.RZ * pProjector->Frame->RProj.Z;		// (1.0f/Z)
						V->U2[0] = (pProjector->_33 + pProjector->_43 * R)*0.6;
						V->U2[1] = 0.0f;
					#endif

						V++;
						PP++;
						PV++;

						PolysVisible[j] = (Outcode == 0);
					}
				}
			}
			
			// Unlock world verts
			INT First = ProjectorVertices.Unlock();

			// Set the texture to the render target that belongs to this projector
			Direct3DDevice8->SetTexture(0, pProjector->pRenderTargetTex);

			for (i=0; i< NumProjectorSurfs; i++)
			{
				ProjectorSurf	*Surf = &ProjectorSurfs[i];

				if (!(Surf->ProjectorFlags & (1<<p)))
					continue;

				INT		*Poly = &ProjectorPolys[Surf->FirstPoly];

				for (INT j=0; j<Surf->NumPolys; j++)
				{
					if (PolysVisible[j])
						Direct3DDevice8->DrawPrimitive(D3DPT_TRIANGLEFAN, First, Poly[j]-2);
					First += Poly[j];
				}
			}
		}
			
		Direct3DDevice8->SetTexture(1, NULL);
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_COLOROP, D3DTOP_DISABLE);

		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MAGFILTER, D3DTEXF_LINEAR );
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_MINFILTER, D3DTEXF_LINEAR );

		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSU, D3DTADDRESS_WRAP );
		Direct3DDevice8->SetTextureStageState( 1, D3DTSS_ADDRESSV, D3DTADDRESS_WRAP );

		Direct3DDevice8->SetTexture(0, NULL);
		//Direct3DDevice8->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		//Direct3DDevice8->SetRenderState( D3DRS_SRCBLEND, D3DBLEND_DESTCOLOR );
		//Direct3DDevice8->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_SRCCOLOR );
		SetAlphaBlendEnable(TRUE);
		SetSrcBlend(D3DBLEND_DESTCOLOR);
		SetDstBelnd(D3DBLEND_SRCCOLOR);
		SetTextureClampMode(0);

		NumProjectorVerts = 0;
		NumProjectorPolys = 0;
		NumProjectorSurfs = 0;
	}
#endif
	// ...JEP
};

// Package and class implementation:
IMPLEMENT_PACKAGE(D3DDrv);
IMPLEMENT_CLASS(UD3DRenderDevice);






