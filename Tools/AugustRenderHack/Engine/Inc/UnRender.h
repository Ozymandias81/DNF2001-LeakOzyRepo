/*=============================================================================
	UnRender.h: Rendering functions and structures
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

/*------------------------------------------------------------------------------------
	Forward declarations.
------------------------------------------------------------------------------------*/

class  URenderDevice;
class  FSpan;
class  FSpanBuffer;
class  FRasterPoly;
struct FTransTexture;
struct FScreenBounds;
struct FSurfaceInfo;
struct FSurfaceFacet;
struct FSceneNode;
struct FDynamicItem;
struct FDynamicSprite;
struct FBspDrawList;
struct FSavedPoly;


/*------------------------------------------------------------------------------------
	Includes.
------------------------------------------------------------------------------------*/

//#include "UnRenderResource.h"
#include "UnRenDev.h"

/*------------------------------------------------------------------------------------
	Defines.
------------------------------------------------------------------------------------*/

#define ORTHO_LOW_DETAIL 40000.0f

/*------------------------------------------------------------------------------------
	FSceneNode.
------------------------------------------------------------------------------------*/

//
// A scene frame is a temporary object representing a portion of
// the view of the world to render.
//
class FSpanBuffer;
struct FBspDrawList;
struct FDynamicSprite;
struct ENGINE_API FSceneNode
{
	// Variables.
	UViewport*		Viewport;		// Viewport the scene frame is attached to.
	ULevel*			Level;			// Level this scene is being rendered from.
	FSceneNode*		Parent;			// Frame from whence this was created, NULL=top level.
	FSceneNode*		Sibling;		// Next sibling scene frame.
	FSceneNode*		Child;			// Next child scene frame.
	INT				iSurf;			// Surface seen through (Parent,iSurface pair is unique).
	INT				ZoneNumber;		// Inital rendering zone of viewport in destination level (NOT the zone of the viewpoint!)
	INT				Recursion;		// Recursion depth, 0 if initial.
	FLOAT			Mirror;			// Mirror value, 1.f or -1.f.
	FPlane			NearClip;		// Near-clipping plane in screenspace.
	FCoords			Coords;			// Transform coordinate system.
	FCoords			Uncoords;		// Inverse coordinate system.
	FSpanBuffer*	Span;			// Initial span buffer for the scene.
	FBspDrawList*	Draw[3];		// Draw lists (portals, occluding, non-occluding).
	FDynamicSprite* Sprite;			// Sprites to draw.
	INT				X, Y;			// Frame size.
	INT				XB, YB;			// Offset of top left active viewport.

	// Precomputes.
	FLOAT			FX, FY;			// Floating point X,Y.
	FLOAT			FX15, FY15;		// (Floating point SXR + 1.0001f)/2.f.
	FLOAT			FX2, FY2;		// Floating point SXR / 2.f.
	FLOAT			Zoom;			// Zoom value, based on OrthoZoom and size.
	FVector			Proj;      		// Projection vector.
	FVector			RProj;			// Reverse projection vector.
	FLOAT			PrjXM, PrjYM;	// Minus clipping numbers.
	FLOAT			PrjXP, PrjYP;	// Plus clipping numbers.
	FVector			ViewSides [4];	// 4 unit vectors indicating view frustrum extent lines.
	FPlane			ViewPlanes[4];	// 4 planes indicating view frustrum extent planes.

	// Functions.
	BYTE* Screen( INT X, INT Y ) {return Viewport->ScreenPointer + (X+XB+(Y+YB)*Viewport->Stride)*Viewport->ColorBytes;}
	void ComputeRenderSize();
	void ComputeRenderCoords( FVector& Location, FRotator& Rotation );
};

/*------------------------------------------------------------------------------------
	Transformations.
------------------------------------------------------------------------------------*/

//
// Transformed vector with outcode info.
//
struct FOutVector
{
	FVector Point;
	BYTE    Flags;
};

//
// Transformed and projected vector.
//
struct FTransform : public FOutVector
{
	FLOAT ScreenX;
	FLOAT ScreenY;
	INT   IntY;
	FLOAT RZ;
	__forceinline void Project( const FSceneNode* Frame )
	{
		// JEP: Added check for divide by zero (I'm actually hitting the assert on my P3 laptop)
		//check(Point.Z != 0.0f);
		if (Point.Z == 0.0f)
			Point.Z = 0.001f;

		RZ      = Frame->Proj.Z / Point.Z;
		ScreenX = Point.X * RZ + Frame->FX15;
		ScreenY = Point.Y * RZ + Frame->FY15;
		IntY    = appFloor( ScreenY );
	}
	void ComputeOutcode( const FSceneNode* Frame )
	{
		static FLOAT ClipXM, ClipXP, ClipYM, ClipYP;
		static const BYTE OutXMinTab [2] = { 0, FVF_OutXMin };
		static const BYTE OutXMaxTab [2] = { 0, FVF_OutXMax };
		static const BYTE OutYMinTab [2] = { 0, FVF_OutYMin };
		static const BYTE OutYMaxTab [2] = { 0, FVF_OutYMax };

#if ASM
		__asm
		{
			; 30 cycle clipping number and outcode computation.
			;
			mov  ecx,[this]					; Get this pointer
			mov  esi,[Frame]				; Get scene frame pointer
			;
			; Compute clipping numbers:
			;
			fld  [ecx]FVector.Z				; Z
			fld  [ecx]FVector.Z				; Z Z
			fxch							; Z Z
			fmul [esi]FSceneNode.PrjXM		; Z*ProjZM Z
			fxch							; Z Z*ProjXM
			fmul [esi]FSceneNode.PrjYM		; Z*ProjYM Z*ProjXM
			fld  [ecx]FVector.Z				; Z Z*ProjYM Z*ProjXM
			fld  [ecx]FVector.Z				; Z Z Z*ProjYM Z*ProjXM
			fxch                            ; Z Z Z*ProjYM Z*ProjXM
			fmul [esi]FSceneNode.PrjXP      ; Z*ProjXP Z Z*ProjYM Z*ProjXM
			fxch                            ; Z Z*ProjXP Z*ProjYM Z*ProjXM
			fmul [esi]FSceneNode.PrjYP      ; Z*ProjYP Z*ProjXP Z*ProjYM Z*ProjXM
			fxch st(3)                      ; Z*ProjXM Z*ProjXP Z*ProjYM Z*ProjYP
			fadd [ecx]FVector.X             ; X+Z*ProjXM Z*ProjXP Z*ProjYM Z*ProjYP
			fxch st(2)                      ; Z*ProjYM Z*ProjXP X+Z*ProjXM Z*ProjYP
			fadd [ecx]FVector.Y             ; Y+Z*ProjYM Z*ProjXP X+Z*ProjXM Z*ProjYP
			fxch st(1)                      ; Z*ProjXP Y+Z*ProjYM X+Z*ProjXM Z*ProjYP
			fsub [ecx]FVector.X             ; X-Z*ProjXP Y+Z*ProjYM X+Z*ProjXM Z*ProjYP
			fxch st(3)                      ; Z*ProjYP Z+Y*ProjYM Z+X*ProjXM Z+X*ProjXP
			fsub [ecx]FVector.Y             ; Y-Z*ProjYP Z+Y*ProjYM Z+X*ProjXM Z+X*ProjXP
			fxch st(2)                      ; Z+X*ProjXM Z+Y*ProjYM Z+Y*ProjYP Z+X*ProjXP
			fstp ClipXM                     ; Z+Y*ProjYM Z+Y*ProjYP Z+X*ProjXP
			fstp ClipYM                     ; Z+Y*ProjYP Z+X*ProjXP
			fstp ClipYP                     ; Z+X*ProjXP
			fstp ClipXP                     ; (empty)
			;
			; Compute flags.
			;
			mov  ebx,ClipXM					; ebx = XM clipping number as integer
			mov  edx,ClipYM					; edx = YM clipping number as integer
			;
			shr  ebx,31						; ebx = XM: 0 iff clip>=0.0, 1 iff clip<0.0
			mov  edi,ClipXP					; edi = XP
			;
			shr  edx,31                     ; edx = YM: 0 or 1
			mov  esi,ClipYP					; esi = YP: 0 or 1
			;
			shr  edi,31						; edi = XP: 0 or 1
			mov  al,OutXMinTab[ebx]			; al = 0 or FVF_OutXMin
			;
			shr  esi,31						; esi = YP: 0 or 1
			mov  bl,OutYMinTab[edx]			; bl = FVF_OutYMin
			;
			or   bl,al						; bl = FVF_OutXMin, FVF_OutYMin
			mov  ah,OutXMaxTab[edi]			; ah = FVF_OutXMax
			;
			or   bl,ah						; bl = FVF_OutXMin, FVF_OutYMin, OutYMax
			mov  al,OutYMaxTab[esi]			; bh = FVF_OutYMax
			;
			or   al,bl                      ; al = FVF_OutYMin and FVF_OutYMax
			;
			mov  [ecx]FOutVector.Flags,al	; Store flags
		}
#elif ASMLINUX
		// Load member variables into local variables.
		asm volatile ("
			#
			# Compute clipping numbers.
			#
			flds %0;				# Z
			flds %0;				# Z Z
			fxch;					# Z Z
			fmuls %1;				# Z*ProjXM Z
			fxch;					# Z Z*ProjXM
			fmuls %2;				# Z*ProjYM Z*ProjXM
			flds %0;				# Z Z*ProjYM Z*ProjXM
			flds %0;				# Z Z Z*ProjYM Z*ProjXM
			fxch;					# Z Z Z*ProjYM Z*ProjXM
			fmuls %3;				# Z*ProjXP Z Z*ProjYM Z*ProjXM
			fxch;					# Z Z*ProjXP Z*ProjYM Z*ProjXM
			fmuls %4;				# Z*ProjYP Z*ProjXP Z*ProjYM Z*ProjXM
			fxch %%st(3);			# Z*ProjXM Z*ProjXP Z*ProjYM Z*ProjYP
			fadds %5;				# Z*ProjXM+X Z*ProjXP Z*ProjYM Z*ProjYP
			fxch %%st(2);			# Z*ProjYM Z*ProjXP Z*ProjXM+X Z*ProjYP
			fadds %6;				# Z*ProjYM+Y Z*ProjXP Z*ProjXM+X Z*ProjYP
			fxch %%st(1);			# Z*ProjXP Z*ProjYM+Y Z*ProjXM+X Z*ProjYP
			fsubs %5;				# Z*ProjXP-X Z*ProjYM+Y Z*ProjXM+X Z*ProjYP
			fxch %%st(3);			# Z*ProjYP Z*ProjYM+Y Z*ProjXM+X Z*ProjXP-X
			fsubs %6;				# Z*ProjYP-Y Z*ProjYM+Y Z*ProjXM+X Z*ProjXP-X
			fxch %%st(2);			# Z*ProjXM+X Z*ProjYM+Y Z*ProjYP-Y Z*ProjXP-X
		"
		:
		: "g" (Point.Z),
		  "g" (Frame->PrjXM),
		  "g" (Frame->PrjYM),
		  "g" (Frame->PrjXP),
		  "g" (Frame->PrjYP),
		  "g" (Point.X),
		  "g" (Point.Y)
		);
		asm volatile ("
								# Z*ProjXM+X Z*ProjYM+Y Z*ProjYP-Y Z*ProjXP-X
			fstps %0;			# Z*ProjYM+Y Z*ProjYP-Y Z*ProjXP-X
			fstps %1;			# Z*ProjYP-Y Z*ProjXP-X
			fstps %2;			# Z*ProjXP-X
			fstps %3;			# (empty)
		"
		: "=g" (ClipXM),
		  "=g" (ClipYM),
		  "=g" (ClipYP),
		  "=g" (ClipXP)
		);
		Flags  =
		(	OutXMinTab [ClipXM < 0.0]
		+	OutXMaxTab [ClipXP < 0.0]
		+	OutYMinTab [ClipYM < 0.0]
		+	OutYMaxTab [ClipYP < 0.0]);
#else
		ClipXM = Frame->PrjXM * Point.Z + Point.X;
		ClipXP = Frame->PrjXP * Point.Z - Point.X;
		ClipYM = Frame->PrjYM * Point.Z + Point.Y;
		ClipYP = Frame->PrjYP * Point.Z - Point.Y;
		Flags  =
		(	OutXMinTab [ClipXM < 0.0]
		+	OutXMaxTab [ClipXP < 0.0]
		+	OutYMinTab [ClipYM < 0.0]
		+	OutYMaxTab [ClipYP < 0.0]);
#endif
	}
	FTransform operator+( const FTransform& V ) const
	{
		FTransform Temp;
		Temp.Point = Point + V.Point;
		return Temp;
	}
	FTransform operator-( const FTransform& V ) const
	{
		FTransform Temp;
		Temp.Point = Point - V.Point;
		return Temp;
	}
	FTransform operator*(FLOAT Scale ) const
	{
		FTransform Temp;
		Temp.Point = Point * Scale;
		return Temp;
	}
};

//
// Transformed sample point.
//
struct FTransSample : public FTransform
{
	FPlane Normal, Light, Fog;
	FTransSample operator+( const FTransSample& T ) const
	{
		FTransSample Temp;
		Temp.Point = Point + T.Point;
		Temp.Light = Light + T.Light;
		Temp.Fog.X = Fog.X + T.Fog.X;
		Temp.Fog.Y = Fog.Y + T.Fog.Y;
		Temp.Fog.Z = Fog.Z + T.Fog.Z;
		Temp.Fog.W = Fog.W + T.Fog.W;
		return Temp;
	}
	FTransSample operator-( const FTransSample& T ) const
	{
		FTransSample Temp;
		Temp.Point = Point - T.Point;
		Temp.Light = Light - T.Light;
		Temp.Fog.X = Fog.X - T.Fog.X;
		Temp.Fog.Y = Fog.Y - T.Fog.Y;
		Temp.Fog.Z = Fog.Z - T.Fog.Z;
		Temp.Fog.W = Fog.W - T.Fog.W;
		return Temp;
	}
	FTransSample operator*( FLOAT Scale ) const
	{
		FTransSample Temp;
		Temp.Point = Point * Scale;
		Temp.Light = Light * Scale;
		Temp.Fog.X = Fog.X * Scale;
		Temp.Fog.Y = Fog.Y * Scale;
		Temp.Fog.Z = Fog.Z * Scale;
		Temp.Fog.W = Fog.W * Scale;
		return Temp;
	}
};

//
// Transformed texture mapped point.
//
struct FTransTexture : public FTransSample
{
	FLOAT U, V;
	FTransTexture operator+( const FTransTexture& T ) const
	{
		FTransTexture Temp;
		Temp.Point = Point + T.Point;
		Temp.Light = Light + T.Light;
		Temp.Fog.X = Fog.X + T.Fog.X;
		Temp.Fog.Y = Fog.Y + T.Fog.Y;
		Temp.Fog.Z = Fog.Z + T.Fog.Z;
		Temp.Fog.W = Fog.W + T.Fog.W;
		Temp.U     = U     + T.U;
		Temp.V     = V     + T.V;
		return Temp;
	}
	FTransTexture operator-( const FTransTexture& T ) const
	{
		FTransTexture Temp;
		Temp.Point = Point - T.Point;
		Temp.Light = Light - T.Light;
		Temp.Fog.X = Fog.X - T.Fog.X;
		Temp.Fog.Y = Fog.Y - T.Fog.Y;
		Temp.Fog.Z = Fog.Z - T.Fog.Z;
		Temp.Fog.W = Fog.W - T.Fog.W;
		Temp.U     = U     - T.U; 
		Temp.V     = V     - T.V;
		return Temp;
	}
	FTransTexture operator*( FLOAT Scale ) const
	{
		FTransTexture Temp;
		Temp.Point = Point * Scale;
		Temp.Light = Light * Scale;
		Temp.Fog.X = Fog.X * Scale;
		Temp.Fog.Y = Fog.Y * Scale;
		Temp.Fog.Z = Fog.Z * Scale;
		Temp.Fog.W = Fog.W * Scale;
		Temp.U     = U     * Scale;
		Temp.V     = V     * Scale;
		return Temp;
	}
};

/*------------------------------------------------------------------------------------
	FSurfaceInfo.
------------------------------------------------------------------------------------*/

//
// Description of a renderable surface.
//
struct FSurfaceInfo
{
	DWORD			PolyFlags;		// Surface flags.
	FColor			FlatColor;		// Flat-shaded color.
	ULevel*			Level;			// Level to render.
	FTextureInfo*	Texture;		// Regular texture mapping info, if any.
	FTextureInfo*	LightMap;		// Light map, if any.
	FTextureInfo*	MacroTexture;	// Macrotexture, if any.
	FTextureInfo*	DetailTexture;	// Detail map, if any.
	FTextureInfo*	FogMap;			// Fog map, if any.
};

//
// A saved polygon.
//
struct FSavedPoly
{
	FSavedPoly* Next;
	INT			iNode;
	void*       User;
	INT         NumPts;
	FTransform* Pts[ZEROARRAY];
};

//
// Description of a surface facet, represented as either
// a convex polygon or a concave span buffer.
//
struct FSurfaceFacet
{
	FCoords			MapCoords;		// Mapping coordinates.
	FCoords			MapUncoords;	// Inverse mapping coordinates.
	FSpanBuffer*	Span;			// Span buffer, if rendering device wants it.
	FSavedPoly*		Polys;			// Polygon list.
};

/*------------------------------------------------------------------------------------
	FScreenBounds.
------------------------------------------------------------------------------------*/

//
// Screen extents of an axis-aligned bounding box.
//
struct ENGINE_API FScreenBounds
{
	FLOAT MinX, MinY;
	FLOAT MaxX, MaxY;
	FLOAT MinZ;
};

/*------------------------------------------------------------------------------------
	URenderBase - removed (CDH, render integration with engine)
------------------------------------------------------------------------------------*/

//
// Line drawing flags.
//
enum ELineFlags
{
	LINE_None		=0x00000000,
	LINE_Transparent=0x00000001,
	LINE_DepthCued  =0x00000002,
	LINE_AntiAliased=0x00000004
};

/*-----------------------------------------------------------------------------
	Hit proxies.
-----------------------------------------------------------------------------*/

// Hit a Bsp surface.
struct ENGINE_API HBspSurf : public HHitProxy
{
	DECLARE_HIT_PROXY(HBspSurf,HHitProxy)
	INT iSurf;
	HBspSurf( INT iInSurf ) : iSurf( iInSurf ) {}
};

// Hit an actor.
struct ENGINE_API HActor : public HHitProxy
{
	DECLARE_HIT_PROXY(HActor,HHitProxy)
	AActor* Actor;
	HActor( AActor* InActor ) : Actor( InActor ) {}
};

// Hit ray descriptor.
struct ENGINE_API HCoords : public HHitProxy
{
	DECLARE_HIT_PROXY(HCoords,HHitProxy)
	FCoords Coords, Uncoords;
	FVector Direction;
	HCoords( FSceneNode* InFrame )
	:	Coords  ( InFrame->Coords   )
	,	Uncoords( InFrame->Uncoords )
	{
		FLOAT X = InFrame->Viewport->HitX+InFrame->Viewport->HitXL/2;
		FLOAT Y = InFrame->Viewport->HitY+InFrame->Viewport->HitYL/2;
		Direction
		=	InFrame->Coords.ZAxis
		+	InFrame->Coords.XAxis * (X - InFrame->FX2) * InFrame->RProj.Z
		+	InFrame->Coords.YAxis * (Y - InFrame->FY2) * InFrame->RProj.Z;
	}
};

/*-----------------------------------------------------------------------------
	CDH: Render DLL integration
-----------------------------------------------------------------------------*/
#include "..\..\Render\Src\Amd3d.h"
#include "..\..\Render\Src\UnSpan.h"

#define MAKELABEL(A,B,C,D) A##B##C##D

struct FBspDrawList
{
	INT 			iNode;
	INT				iSurf;
	INT				iZone;
	INT				Key;
	DWORD			PolyFlags;
	DWORD			PolyFlagsEx;
	FSpanBuffer		Span;
	AZoneInfo*		Zone;
	FBspDrawList*	Next;
	FBspDrawList*	SurfNext;
	FActorLink*		Volumetrics;
	FSavedPoly*		Polys;
	FActorLink*		SurfLights;
};

/*------------------------------------------------------------------------------------
	Subsystem definition
------------------------------------------------------------------------------------*/

// Function pointer types.
typedef void (__fastcall *LIGHT_SPATIAL_FUNC)( FTextureInfo& Tex, class FLightInfo* Info, BYTE* Src, BYTE* Dest );

// Information about one special lighting effect.
struct FLocalEffectEntry
{
	LIGHT_SPATIAL_FUNC	SpatialFxFunc;		// Function to perform spatial lighting
	INT					IsSpatialDynamic;	// Indicates whether light spatiality changes over time.
	INT					IsMergeDynamic;		// Indicates whether merge function changes over time.
};

// Light classification.
enum ELightKind
{
	ALO_StaticLight		= 0,	// Actor is a non-moving, non-changing lightsource
	ALO_DynamicLight	= 1,	// Actor is a non-moving, changing lightsource
	ALO_MovingLight		= 2,	// Actor is a moving, changing lightsource
	ALO_NotLight		= 3,	// Not a surface light (probably volumetric only).
};

// Information about a lightsource.
class /* ENGINE_API*/ FLightInfo
{
public:
	// For all lights.
	AActor*		Actor;					// All actor drawing info.
	ELightKind	Opt;					// Light type.
	FVector		Location;				// Transformed screenspace location of light.
	FLOAT		Radius;					// Maximum effective radius.
	FLOAT		RRadius;				// 1.0 / Radius.
	FLOAT		RRadiusMult;			// 16383.0 / (Radius * Radius).
	FLOAT		Brightness;				// Center brightness at this instance, 1.0=max, 0.0=none.
	FLOAT		Diffuse;				// BaseNormalDelta * RRadius.
	BYTE*		IlluminationMap;		// Temporary illumination map pointer.
	BYTE*		ShadowBits;				// Temporary shadow map.
	UBOOL		IsVolumetric;			// Whether it's volumetric.

	// Clipping region.
	INT MinU, MaxU, MinV, MaxV;

	// For volumetric lights.
	FLOAT		VolRadius;				// Volumetric radius.
	FLOAT		VolRadiusSquared;		// VolRadius*VolRadius.
	FLOAT		VolBrightness;			// Volumetric lighting brightness.
	FLOAT		LocationSizeSquared;	// Location.SizeSqurated().
	FLOAT		RVolRadius;				// 1/Volumetric radius.
	FLOAT		RVolRadiusSquared;		// 1/VolRadius*VolRadius.
	UBOOL       VolInside;               // Viewpoint is inside the sphere.

	// Information about the lighting effect.
	FLocalEffectEntry Effect;

	// Coloring.
	FPlane		FloatColor;				// Incident lighting color.
	FPlane		VolumetricColor;		// Volumetric lighting color.
	FColor*		Palette;				// Brightness scaler.
	FColor*     VolPalette;             // Volumetric color scaler.
	
	// Functions.
	void ComputeFromActor( FTextureInfo* Map, FSceneNode* Frame );
};


class FLightManager // : public FLightManagerBase
{
public:
	// FLightManagerBase functions.
	void __fastcall    Init();
	DWORD __fastcall SetupForActor( FSceneNode* Frame, AActor* Actor, struct FVolActorLink* LeafLights, FActorLink* Volumetrics );
	void __fastcall SetupForSurf( FSceneNode* Frame, FCoords& FacetCoords, FBspDrawList* Draw, FTextureInfo*& LightMap, FTextureInfo*& FogMap, UBOOL Merged );
	//void __fastcall FinishSurf();

	// Finish surface lighting. (NJS: Inlined because it's small and shows up on the profile
	void __forceinline FLightManager::FinishSurf()
	{
		// Release working memory.
		Mark.Pop();

		// Unlock any locked cache items.
		while( TopItemToUnlock > &ItemsToUnlock[0] )
			(*--TopItemToUnlock)->Unlock();

		// Update stats.
		//STAT(GStat.Lightage += LightMap.UClamp * LightMap.VClamp);
		//STAT(GStat.LightMem += LightMap.UClamp * LightMap.VClamp * sizeof(FLOAT));
	}

	void __forceinline FinishActor()
	{
		// Release working memory.
		Mark.Pop();

		// Unlock any locked cache items.
		while( TopItemToUnlock > &ItemsToUnlock[0])
			(*--TopItemToUnlock)->Unlock();
	}

	void __fastcall LightAndFog( FTransSample& Point, DWORD PolyFlags );

	// Constants and types.
	enum {MAX_LIGHTS=256};
	typedef DWORD FILTER_TAB[4];

	// Spatial lighting functions.
	static void __fastcall spatial_None			( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_SearchLight	( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_SlowWave		( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_FastWave		( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_CloudCast	( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_Shock		( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_Disco		( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_Interference	( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_Cylinder		( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_Rotor		( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_Spotlight	( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_NonIncidence	( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_Shell		( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );
	static void __fastcall spatial_Test			( FTextureInfo& Tex, FLightInfo* Info, BYTE* Src, BYTE* Dest );

	// FLightManager functions.
	static void  __fastcall Merge( FTextureInfo& Tex, BYTE LightEffect, INT Key, FLightInfo* Light, DWORD* Stream, DWORD* Dest );
	static FLOAT __fastcall Volumetric( FLightInfo* Info, FVector& Vertex );
		   void  __fastcall ShadowMapGen( FTextureInfo& Tex, BYTE* SrcBits, BYTE* Dest1 );
		   UBOOL __fastcall AddLight( AActor* Actor, AActor* Other );

	// Variables.
	static FCoords			*MapCoords, MapUncoords;
	static FVector			VertexBase, VertexDU, VertexDV;
	static FSceneNode*		Frame;
	static ULevel*			Level;
	static FMemMark			Mark;
	static INT				ShadowMaskU, ShadowMaskSpace, ShadowSkip;
	static INT				StaticLights, DynamicLights, MovingLights, StaticLightingChanged;
	static FTextureInfo		LightMap, FogMap;
	static FMipmap			LightMip, FogMip;
	static FLightInfo*		LastLight, **LastVtric;
	static FLightInfo*const FinalLight;
	static FLightInfo		FirstLight[MAX_LIGHTS], *FirstVtric[MAX_LIGHTS];
	static ALevelInfo*		LevelInfo;
	static AZoneInfo*		Zone;
	static FPlane			AmbientVector;
	static FLOAT			Diffuse;
	static INT              TemporaryTablesBuilt;
	static FLOAT			BackdropBrightness;
	static FLOAT            LightSqrt[4096];
	static FILTER_TAB		FilterTab[128];
	static BYTE				ByteFog[0x4000];
	static AActor*			Actor;
	static const FLocalEffectEntry Effects[LE_MAX];

	// Memory cache info.
	enum {MAX_UNLOCKED_ITEMS=256};
	static FCacheItem* ItemsToUnlock[MAX_UNLOCKED_ITEMS];
	static FCacheItem** TopItemToUnlock;
};
/*------------------------------------------------------------------------------------
	Links.
------------------------------------------------------------------------------------*/

//
// Linked list of actors with volumetric flag.
//
struct FVolActorLink
{
	// Variables.
	FVector			Location;
	AActor*			Actor;
	FVolActorLink*	Next;
	UBOOL			Volumetric;

	// Functions.
	FVolActorLink( FCoords& Coords, AActor* InActor, FVolActorLink* InNext, UBOOL InVolumetric )
	:	Location	( InActor->Location.TransformPointBy( Coords ) )
	,	Actor		( InActor )
	,	Next		( InNext )
	,	Volumetric	( InVolumetric )
	{}
	FVolActorLink( FVolActorLink& Other, FVolActorLink* InNext )
	:	Location	( Other.Location )
	,	Actor		( Other.Actor )
	,	Volumetric	( Other.Volumetric )
	,	Next		( InNext )
	{}
};
//extern AActor* Consider[120];
//extern INT NumConsider;

/*------------------------------------------------------------------------------------
	Dynamic Bsp contents.
------------------------------------------------------------------------------------*/

struct FDynamicItem
{
	// Variables.
	FDynamicItem*	FilterNext;
	FLOAT			Z;

	// Functions.
	FDynamicItem() {}
	FDynamicItem( INT iNode );
	virtual void __fastcall Filter( UViewport* Viewport, FSceneNode* Frame, INT iNode, INT Outside ) {}
	virtual void __fastcall PreRender( UViewport* Viewport, FSceneNode* Frame, FSpanBuffer* SpanBuffer, INT iNode, FVolActorLink* Volumetrics ) {}
};

struct FDynamicSprite : public FDynamicItem
{
	// Variables.
	FSpanBuffer*	SpanBuffer;
	FDynamicSprite*	RenderNext;
	FTransform		ProxyVerts[4];
	AActor*			Actor;
	INT				X1, Y1;
	INT				X2, Y2;
	FLOAT 			ScreenX, ScreenY;
	FLOAT			Persp;
	FActorLink*		Volumetrics;
	FVolActorLink*	LeafLights;

	// Functions.
	FDynamicSprite( FSceneNode* Frame, INT iNode, AActor* Actor );
	FDynamicSprite( AActor* InActor ) : Actor( InActor ), SpanBuffer( NULL ), Volumetrics( NULL ), LeafLights( NULL ) {}
	UBOOL Setup( FSceneNode* Frame );
};

struct FDynamicChunk : public FDynamicItem
{
	// Variables.
	FRasterPoly*	Raster;
	FDynamicSprite* Sprite;

	// Functions.
	FDynamicChunk( INT iNode, FDynamicSprite* InSprite, FRasterPoly* InRaster );
	void __fastcall Filter( UViewport* Viewport, FSceneNode* Frame, INT iNode, INT Outside );
};

struct FDynamicFinalChunk : public FDynamicItem
{
	// Variables.
	FRasterPoly*	Raster;
	FDynamicSprite* Sprite;

	// Functions.
	FDynamicFinalChunk( INT iNode, FDynamicSprite* InSprite, FRasterPoly* InRaster, INT IsBack );
	void __fastcall PreRender( UViewport* Viewport,  FSceneNode* Frame, FSpanBuffer* SpanBuffer, INT iNode, FVolActorLink* Volumetrics );
};

struct FDynamicLight : public FDynamicItem
{
	// Variables.
	AActor*			Actor;
	UBOOL			IsVol;
	UBOOL			HitLeaf;

	// Functions.
	FDynamicLight( INT iNode, AActor* Actor, UBOOL IsVol, UBOOL InHitLeaf );
	void __fastcall Filter( UViewport* Viewport, FSceneNode* Frame, INT iNode, INT Outside );
};

/*------------------------------------------------------------------------------------
	Globals.
------------------------------------------------------------------------------------*/

ENGINE_API extern FLightManager GLightManager;
ENGINE_API extern FMemStack GDynMem, GSceneMem;

/*------------------------------------------------------------------------------------
	Debugging stats.
------------------------------------------------------------------------------------*/

//
// General-purpose statistics:
//
#if STATS
struct FRenderStats
{
	// Misc.
	INT ExtraTime;

	// MeshStats.
	INT MeshTime;
	INT MeshGetFrameTime, MeshProcessTime, MeshLightSetupTime, MeshLightTime, MeshSubTime, MeshClipTime, MeshTmapTime;
	INT MeshCount, MeshPolyCount, MeshSubCount, MeshVertLightCount, MeshLightCount, MeshVtricCount;

	// ActorStats.

	// FilterStats.
	INT FilterTime;

	// RejectStats.

	// SpanStats.

	// ZoneStats.

	// OcclusionStats.
	INT OcclusionTime, ClipTime, RasterTime, SpanTime;
	INT NodesDone, NodesTotal;
	INT NumRasterPolys, NumRasterBoxReject;
	INT NumTransform, NumClip;
	INT BoxTime, BoxChecks, BoxBacks, BoxIn, BoxOutOfPyramid, BoxSpanOccluded;
	INT NumPoints;

	// IllumStats.
	INT IllumTime;

	// PolyVStats.
	INT PolyVTime;

	// Actor drawing stats:
	INT NumSprites;			// Number of sprites filtered.
	INT NumChunks;			// Number of final chunks filtered.
	INT NumFinalChunks;		// Number of final chunks.
	INT NumMovingLights;    // Number of moving lights.
	INT ChunksDrawn;		// Chunks drawn.

	// Texture subdivision stats
	INT DynLightActors;		// Number of actors shining dynamic light.

	// Span buffer:
	INT SpanTotalChurn;		// Total spans added.
	INT SpanRejig;			// Number of span index that had to be reallocated during merging.

	// Clipping:
	INT ClipAccept;			// Polygons accepted by clipper.
	INT ClipOutcodeReject;	// Polygons outcode-rejected by clipped.
	INT ClipNil;			// Polygons clipped into oblivion.

	// Memory:
	INT GMem;				// Bytes used in global memory pool.
	INT GDynMem;			// Bytes used in dynamics memory pool.

	// Zone rendering:
	INT CurZone;			// Current zone the player is in.
	INT NumZones;			// Total zones in world.
	INT VisibleZones;		// Zones actually processed.
	INT MaskRejectZones;	// Zones that were mask rejected.

	// Illumination cache:
	INT PalCycles;			// Time spent in palette regeneration.

	// Lighting:
	INT Lightage,LightMem,MeshPtsGen,MeshesGen,VolLightActors;

	// Textures:
	INT UniqueTextures,UniqueTextureMem,CodePatches;

	// Actors:
	INT BListedActors;

	// Extra:
	INT Extra1,Extra2,Extra3,Extra4;

	// Decal stats
	INT DecalTime, DecalClipTime, DecalCount;

	// Routine timings:
	INT GetValidRangeCycles;
	INT BoxIsVisibleCycles;
	INT CopyFromRasterUpdateCycles;
	INT CopyFromRasterCycles;
	INT CopyIndexFromCycles;
	INT MergeWithCycles;
	INT CalcRectFromCycles;
	INT CalcLatticeFromCycles;
	INT GenerateCycles;
	INT CalcLatticeCycles;
	INT RasterSetupCycles;
	INT RasterGenerateCycles;
	INT TransformCycles;
	INT ClipCycles;
	INT AsmCycles;

	// JEP: Collision
	INT	CollisionCount;			// How many multiline checks per frame
	INT	CollisionCycles;		// cycles for all multiline checks last frame

	// JEP: Misc
	INT	MountPhysCycles, SetMeshCycles, GetFrameCycles, GetMountCoordsCycles;
	INT MeshMountRenderCycles, MeshGetFrameCycles, MeshOutCodesCycles, MeshSetupTrisCycles;
	INT MeshLightingCycles, MeshParticleCycles, MeshQueuePolygonCycles;

	// JEP: Projector stats (includes shadow stuff, which uses projectors)
	INT OccludeProjectorCycles, ShadowRenderCycles;
	INT NumFinalShadowActors, NumRenderedFinalShadowActors, NumProjectorSurfs;
};
extern FRenderStats GStat;
#endif

/*------------------------------------------------------------------------------------
	Profile Subsystem:
------------------------------------------------------------------------------------*/

class Profile
{
public:

	bool Valid;
	bool Expanded;
	int  TimesCalled;
	TCHAR Description[128];
	__int64 StartCycles;
	__int64 TotalCycles;
	Profile *Parent;
	Profile *FirstChild;
	Profile *NextSibling;
	double   RunningAveragePercent;
	double   MinPercent;
	double	 MaxPercent;

	Profile() 
	{ 
		Reset();
	}

	Profile(Profile *Parent,TCHAR *Description)
	{
		Reset();
		this->Parent=Parent;
		NextSibling=Parent->FirstChild;
		Parent->FirstChild=this;

		
		for(Profile *Iterator=Parent;Iterator;Iterator=Parent->Parent)
			appStrcat(this->Description,_T("  "));

		appStrcat(this->Description,Description);

	}

	~Profile()
	{
	}

	void Reset()
	{
		Valid=false;
		Expanded=false;
		TimesCalled=0;
		Description[0]=0;
		StartCycles=TotalCycles=0;
		Parent=FirstChild=NextSibling=NULL;
		RunningAveragePercent=0.0;
	}

	void Start()
	{
		Valid=true;
		TimesCalled++;
		StartCycles=appRDTSC();
	}

	void Stop()
	{
		if(!Valid) return;
		TotalCycles+=(appRDTSC()-StartCycles);
	}

	void Collapse()
	{
		// Collapse myself:
		Expanded=false;

		// Collapse any of my children recursively:
		for(Profile *Iterator=FirstChild;Iterator;Iterator=Iterator->NextSibling)
			Iterator->Collapse();
	}

	void Show( URender* RenDev, FSceneNode* Frame, int Depth=0 );
};

extern Profile	Profile_Frame;
extern Profile		Profile_Game;
extern Profile		Profile_Client;
extern Profile	    Profile_Blit;

/*------------------------------------------------------------------------------------
	Random numbers.
------------------------------------------------------------------------------------*/

// Random number subsystem.
// Tracks a list of set random numbers.
class FGlobalRandoms
{
public:
	// Functions.
	void __fastcall Tick(FLOAT TimeSeconds); // Mark one unit of passing time.

	// Inlines.
	FLOAT RandomBase( int i ) {return RandomBases[i & RAND_MASK]; }
	FLOAT Random(     int i ) {return Randoms    [i & RAND_MASK]; }

protected:
	// Constants.
	enum {RAND_CYCLE = 16       }; // Number of ticks for a complete cycle of Randoms.
	enum {N_RANDS    = 256      }; // Number of random numbers tracked, guaranteed power of two.
	enum {RAND_MASK  = N_RANDS-1}; // Mask so that (i&RAND_MASK) is a valid index into Randoms.

	// Variables.
	static FLOAT RandomBases	[N_RANDS]; // Per-tick discontinuous random numbers.
	static FLOAT Randoms		[N_RANDS]; // Per-tick continuous random numbers.

	// Variables.
	static FLOAT RandomDeltas	[N_RANDS]; // Deltas used to update Randoms.
	static DWORD LastTicks;

};
extern FGlobalRandoms GRandoms;

/*------------------------------------------------------------------------------------
	Fast approximate math code.
------------------------------------------------------------------------------------*/

#define APPROX_MAN_BITS 10		/* Number of bits of approximate square root mantissa, <=23 */
#define APPROX_EXP_BITS 9		/* Number of bits in IEEE exponent */

extern FLOAT SqrtManTbl[2<<APPROX_MAN_BITS];
extern FLOAT DivSqrtManTbl[1<<APPROX_MAN_BITS],DivManTbl[1<<APPROX_MAN_BITS];
extern FLOAT DivSqrtExpTbl[1<<APPROX_EXP_BITS],DivExpTbl[1<<APPROX_EXP_BITS];

//
// Macro to look up from a power table.
//
#if ASM
#define POWER_ASM(ManTbl,ExpTbl)\
	__asm\
	{\
		/* Here we use the identity sqrt(a*b) = sqrt(a)*sqrt(b) to perform\
		** an approximate floating point square root by using a lookup table\
		** for the mantissa (a) and the exponent (b), taking advantage of the\
		** ieee floating point format.\
		*/\
		__asm mov  eax,[F]									/* get float as int                   */\
		__asm shr  eax,(32-APPROX_EXP_BITS)-APPROX_MAN_BITS	/* want APPROX_MAN_BITS mantissa bits */\
		__asm mov  ebx,[F]									/* get float as int                   */\
		__asm shr  ebx,32-APPROX_EXP_BITS					/* want APPROX_EXP_BITS exponent bits */\
		__asm and  eax,(1<<APPROX_MAN_BITS)-1				/* keep lowest 9 mantissa bits        */\
		__asm fld  DWORD PTR ManTbl[eax*4]					/* get mantissa lookup                */\
		__asm fmul DWORD PTR ExpTbl[ebx*4]					/* multiply by exponent lookup        */\
		__asm fstp [F]										/* store result                       */\
	}\
	return F;
//
// Fast floating point power routines.
// Pretty accurate to the first 10 bits.
// About 12 cycles on the Pentium.
//
__forceinline FLOAT DivSqrtApprox(FLOAT F) {POWER_ASM(DivSqrtManTbl,DivSqrtExpTbl);}
inline FLOAT DivApprox    (FLOAT F) {POWER_ASM(DivManTbl,    DivExpTbl    );}
inline FLOAT SqrtApprox   (FLOAT F)
{
	__asm
	{
		mov  eax,[F]                        // get float as int.
		shr  eax,(23 - APPROX_MAN_BITS) - 2 // shift away unused low mantissa.
		mov  ebx,[F]						// get float as int.
		and  eax, ((1 << (APPROX_MAN_BITS+1) )-1) << 2 // 2 to avoid "[eax*4]".
		and  ebx, 0x7F000000				// 7 bit exp., wipe low bit+sign.
		shr  ebx, 1							// exponent/2.
		mov  eax,DWORD PTR SqrtManTbl [eax]	// index hi bit is exp. low bit.
		add  eax,ebx						// recombine with exponent.
		mov  [F],eax						// store.
	}
	return F;								// compiles to fld [F].
}
#else
inline FLOAT DivSqrtApprox(FLOAT F) {return 1.0/appSqrt(F);}
inline FLOAT DivApprox    (FLOAT F) {return 1.0/F;}
inline FLOAT SqrtApprox   (FLOAT F) {return appSqrt(F);}
#endif

/*------------------------------------------------------------------------------------
	URender.
------------------------------------------------------------------------------------*/

//
// Software rendering subsystem.
//
class ENGINE_API URender : public USubsystem
{
	DECLARE_CLASS(URender,USubsystem,CLASS_Transient|CLASS_Config)

	// Friends.
	friend class  FGlobalSpanTextureMapper;
	friend struct FDynamicItem;
	friend struct FDynamicSprite;
	friend struct FDynamicChunk;
	friend struct FDynamicFinalChunk;
	friend struct FDynamicLight;
	friend class  FLightManager;
	friend void __fastcall RenderSubsurface
	(
		UViewport*		Viewport,
		FSceneNode*	Frame,
		UTexture*		Texture,
		FSpanBuffer*	Span,
		FTransTexture*	Pts,
		DWORD			PolyFlags,
		INT				SubCount
	);

	// obsolete!!
	enum EDrawRaster
	{
		DRAWRASTER_Flat				= 0,	// Flat shaded
		DRAWRASTER_Normal			= 1,	// Normal texture mapped
		DRAWRASTER_Masked			= 2,	// Masked texture mapped
		DRAWRASTER_Blended			= 3,	// Blended texture mapped
		DRAWRASTER_Fire				= 4,	// Fire table texture mapped
		DRAWRASTER_MAX				= 5,	// First invalid entry
	};

	// Constructor.
	URender();
	void StaticConstructor();

	// UObject interface.
	void Destroy();

	// URender interface.
	void Init( UEngine* InEngine );
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar=*GLog );
	void PreRender( FSceneNode* Frame );
	void PostRender( FSceneNode* Frame );
	void  __fastcall DrawWorld( FSceneNode* Frame );
	UBOOL __fastcall Deproject( FSceneNode* Frame, INT ScreenX, INT ScreenY, FVector& V );
	UBOOL __fastcall Project( FSceneNode* Frame, const FVector& V, FLOAT& ScreenX, FLOAT& ScreenY, FLOAT* Scale );
	void __fastcall DrawActor( FSceneNode* Frame, AActor* Actor );
	void GetVisibleSurfs( UViewport* Viewport, TArray<INT>& iSurfs );
	void __fastcall OccludeBsp( FSceneNode* Frame );
//	void SetupDynamics( FSceneNode* Frame, AActor* Exclude, TArray<AActor*> &Relevent  );

	void __fastcall OccludeProjector(FSceneNode* Frame, INT ProjectorIndex);		// JEP
	void __fastcall SetupActorForProjectors(FSceneNode *Frame, AActor *Actor);
	
	UBOOL __fastcall BoundVisible( FSceneNode* Frame, FBox* Bound, FSpanBuffer* SpanBuffer, FScreenBounds& Results );
	void GlobalLighting( UBOOL Realtime, AActor* Owner, FLOAT& Brightness, FPlane& Color );
	FSceneNode* CreateMasterFrame( UViewport* Viewport, FVector Location, FRotator Rotation, FScreenBounds* Bounds );
	FSceneNode* CreateChildFrame( FSceneNode* Frame, FSpanBuffer* Span, ULevel* Level, INT iSurf, INT iZone, FLOAT Mirror, const FPlane& NearClip, const FCoords& Coords, FScreenBounds* Bounds );
	void FinishMasterFrame();
	void DrawCircle( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector& Location, FLOAT Radius, UBOOL bScaleRadiusByZoom = 0 );
	void DrawBox( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector Min, FVector Max );
	void DrawCylinder( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector& Location, FLOAT Radius, FLOAT Height );
	void Precache( UViewport* Viewport );

	// Dynamics cache.
	FVolActorLink* FirstVolumetric;

	// Scene frames.
	enum {MAX_FRAME_RECURSION=4};

	// Dynamic lighting.
	enum {MAX_DYN_LIGHT_SURFS=2048};
	enum {MAX_DYN_LIGHT_LEAVES=1024};
	static INT				NumDynLightSurfs;
	static INT				NumDynLightLeaves;
	static INT				MaxSurfLights;
	static INT				MaxLeafLights;
	static INT				DynLightSurfs[MAX_DYN_LIGHT_SURFS];
	static INT				DynLightLeaves[MAX_DYN_LIGHT_LEAVES];
	static FActorLink**		SurfLights;
	static FVolActorLink**	LeafLights;

	// Base variables. (CDH)
	UEngine* Engine;

	// Variables.
	UBOOL					Toggle;
	UBOOL					LeakCheck;
	FLOAT					GlobalMeshLOD;
	FLOAT					GlobalShapeLOD;
	FLOAT					GlobalShapeLODAdjust;
	INT                     ShapeLODMode;
	FLOAT                   ShapeLODFix;

	// Timing.
	DOUBLE					LastEndTime;
	DOUBLE					StartTime;
	DOUBLE					EndTime;
	DWORD					NodesDraw;
	DWORD					PolysDraw;

	// Scene.
	FMemMark				SceneMark, MemMark, DynMark;
	INT						SceneCount;

	// Which stats to display.
	UBOOL ProfileStats;
	UBOOL NetStats;
	UBOOL ActorChanStats;
	UBOOL FpsStats;
	UBOOL GlobalStats;
	UBOOL MeshStats;
	UBOOL ActorStats;
	UBOOL FunctionStats;
	UBOOL FilterStats;
	UBOOL RejectStats;
	UBOOL SpanStats;
	UBOOL ZoneStats;
	UBOOL LightStats;
	UBOOL OcclusionStats;
	UBOOL GameStats;
	UBOOL SoftStats;
	UBOOL CacheStats;
	UBOOL PolyVStats;
	UBOOL PolyCStats;
	UBOOL IllumStats;
	UBOOL HardwareStats;
	UBOOL MemoryStats;
	UBOOL SoundStats;
	UBOOL CollisionStats;
	UBOOL ProjectorStats;
	UBOOL Extra7Stats;
	UBOOL Extra8Stats;

	// OccludeBsp dynamics.
	static struct FDynamicsCache
	{
		FDynamicItem* Dynamics[2];
	}* DynamicsCache;
	static struct FStampedPoint
	{
		FTransform* Point;
		DWORD		Stamp;
	}* PointCache;
	static FMemStack VectorMem;
	static DWORD Stamp;
	INT						NumPostDynamics;
	FDynamicsCache**		PostDynamics;
	FDynamicItem*& Dynamic( INT iNode, INT i )
	{
		return DynamicsCache[iNode].Dynamics[i];
	}

	// Implementation.
	void __fastcall OccludeFrame( FSceneNode* Frame, TArray<AActor*> &Relevent );
	void __fastcall DrawFrame( FSceneNode* Frame );
	void LeafVolumetricLighting( FSceneNode* Frame, UModel* Model, INT iLeaf );
	INT __fastcall ClipBspSurf( INT iNode, FTransform**& OutPts );
	INT __fastcall AMD3DClipBspSurf( INT iNode, FTransform**& OutPts );
	//INT ClipTexPoints( FSceneNode* Frame, FTransTexture* InPts, FTransTexture* OutPts, INT Num0 );
	void __fastcall DrawActorSprite( FSceneNode* Frame, FDynamicSprite* Sprite );
	void __fastcall DrawMesh( FSceneNode* Frame, AActor* Owner, AActor* LightSink, FSpanBuffer* SpanBuffer, AZoneInfo* Zone, const FCoords& Coords, FVolActorLink* LeafLights, FActorLink* Volumetrics, DWORD PolyFlags, DWORD PolyFlagsEx = 0 );
	void __fastcall DrawMeshFast( FSceneNode* Frame, AActor* Owner, AZoneInfo* Zone, const FCoords& Coords, DWORD PolyFlags, DWORD PolyFlagsEx = 0);
	/* CDH: removed (now handled by delegate functions)
	void DrawLodMesh( FSceneNode* Frame, AActor* Owner, AActor* LightSink, FSpanBuffer* SpanBuffer, AZoneInfo* Zone, const FCoords& Coords, FVolActorLink* LeafLights, FActorLink* Volumetrics, DWORD PolyFlags );
	*/
	void ShowStat( FSceneNode* Frame, const TCHAR* Fmt, ... );
	void DrawStats( FSceneNode* Frame );
	INT __fastcall ClipDecal( FSceneNode* Frame, FDecal *Decal, UModel* Model, FBspSurf* Surf, FSavedPoly* Poly, FTransTexture**& DecalPoints, INT& NumPts );


/*	// NJS: SetupDynamics is admittedly a bit insane to inline, but it is called from one of the biggest spikes
	// in the game (OccludeFrame) and as that is the only place it is ever called from, it makes sense to inline it.
	void __forceinline SetupDynamics( FSceneNode* Frame, AActor* Exclude, TArray<AActor*> &Relevent  )
	{
		if
		(	!(Frame->Level->Model->Nodes.Num())
		||	!(Frame->Viewport->Actor->ShowFlags & SHOW_Actors) )
			return;
		STAT(clock(GStat.FilterTime));
		UBOOL HighDetailActors=Frame->Viewport->RenDev->HighDetailActors;
		UBOOL bHeatVision = Frame->Viewport->Actor->CameraStyle == PCS_HeatVision; // CDH

		// Traverse entire actor list.
		for( INT iActor=0; iActor<Relevent.Num(); iActor++ )
		{
			AActor* Actor=Relevent(iActor);
			if(!Actor) break;

			ARenderActor* RenderActor = NULL;
			if ( Actor->bIsRenderActor )
				RenderActor = (ARenderActor*) Actor;

			// Add this actor to dynamics if it's renderable.
			//AActor* Actor = Frame->Level->Actors(iActor);
			//if(!Actor) continue;

			if ( RenderActor )
			{
				if
				(	RenderActor
				&&	(!RenderActor->bHighDetail || HighDetailActors) 
				&&  (!RenderActor->bDontReflect || Frame->Recursion==0)
				&&	(Frame->Recursion!=0 || Frame->Viewport->Actor->bBehindView || RenderActor!=Frame->Viewport->Actor->ViewTarget) )
				{
					if
					(	(RenderActor != Exclude)
					&&	(GIsEditor ? !RenderActor->bHiddenEd : (!RenderActor->bHidden || (bHeatVision ? RenderActor->bHeatNoHide : 0)) ) // CDH: even if hidden, may be visible in heatvision

					// Call PlayerPawn Render Control Interface (RCI) to assess visible actors
					&&	( ( GIsEditor && !( Frame->Viewport->Actor->ShowFlags & SHOW_PlayerCtrl ) )
						|| ( Frame->Viewport->Actor->IsA( APlayerPawn::StaticClass() ) 
							&& Frame->Viewport->Actor->IsActorVisible( RenderActor ) ) )
					// Clip actors that aren't "visible" 
					&&	( (RenderActor->VisibilityRadius == 0.f || (RenderActor->Location - Frame->Coords.Origin).SizeSquared2D() < RenderActor->VisibilityRadius*RenderActor->VisibilityRadius)
						&&(RenderActor->VisibilityHeight == 0.f || Abs    ((RenderActor->Location - Frame->Coords.Origin).Z              ) < RenderActor->VisibilityHeight) )

					&&  (!RenderActor->bOwnerSeeSpecial || !RenderActor->IsOwnedBy(Frame->Viewport->Actor) || (RenderActor->IsOwnedBy(Frame->Viewport->Actor) && (Frame->Viewport->Actor->bBehindView || (Frame->Recursion!=0))))
					&&	(!RenderActor->bOnlyOwnerSee || (RenderActor->IsOwnedBy(Frame->Viewport->Actor) && !Frame->Viewport->Actor->bBehindView))
					&&	(!RenderActor->IsOwnedBy(Frame->Viewport->Actor) || !RenderActor->bOwnerNoSee || (RenderActor->IsOwnedBy(Frame->Viewport->Actor) && Frame->Viewport->Actor->bBehindView)) )
					{				
						// Add the sprite proxy.
						if( !RenderActor->IsMovingBrush() )
						{
							new(GDynMem)FDynamicSprite( Frame, 0, RenderActor );
						}
						else if( Frame->Level->BrushTracker )
						{
							//bounding box reject!!
							Frame->Level->BrushTracker->Update( RenderActor );
						}
					}

					if
					(	(RenderActor->LightType)
					&&	(!(RenderActor->bStatic || RenderActor->bNoDelete) || RenderActor->bDynamicLight)
					&&	(RenderActor->LightBrightness)
					&&	(RenderActor->LightRadius) )
					{
						// Add the dynamic light.
						FLOAT MaxRadius = Max( RenderActor->WorldLightRadius(), RenderActor->WorldVolumetricRadius() );
						for( int i=0; i<4; i++ )
							if( Frame->ViewPlanes[i].PlaneDot(RenderActor->Location) < -MaxRadius )
								break;
						if( i==4 )
						{
							UBOOL IsVolumetric = RenderActor->Region.Zone->bFogZone && RenderActor->VolumeRadius && RenderActor->VolumeBrightness;
							for( i=0; IsVolumetric && i<4; i++ )
								if( Frame->ViewPlanes[i].PlaneDot(RenderActor->Location) < -RenderActor->WorldVolumetricRadius() )
									IsVolumetric = 0;
							new(GDynMem)FDynamicLight( 0, RenderActor, IsVolumetric, 0 );
							STAT(GStat.DynLightActors++);
						}
					}
				}
			}
			else
			{
				if
				(	Actor
				&&  (!Actor->bDontReflect || Frame->Recursion==0)
				&&	(Frame->Recursion!=0 || Frame->Viewport->Actor->bBehindView || Actor!=Frame->Viewport->Actor->ViewTarget) )
				{
					if
					(	(Actor != Exclude)
					&&	(GIsEditor ? !Actor->bHiddenEd : !Actor->bHidden)

					// Call PlayerPawn Render Control Interface (RCI) to assess visible actors
					&&	( ( GIsEditor && !( Frame->Viewport->Actor->ShowFlags & SHOW_PlayerCtrl ) )
						|| ( Frame->Viewport->Actor->IsA( APlayerPawn::StaticClass() ) 
							&& Frame->Viewport->Actor->IsActorVisible( Actor ) ) ) )
					{				
						// Add the sprite proxy.
						if( !Actor->IsMovingBrush() )
						{
							new(GDynMem)FDynamicSprite( Frame, 0, Actor );
						}
						else if( Frame->Level->BrushTracker )
						{
							//bounding box reject!!
							Frame->Level->BrushTracker->Update( Actor );
						}
					}

					if
					(	(Actor->LightType)
					&&	(!(Actor->bStatic || Actor->bNoDelete) || Actor->bDynamicLight)
					&&	(Actor->LightBrightness)
					&&	(Actor->LightRadius) )
					{
						// Add the dynamic light.
						FLOAT MaxRadius = Max( Actor->WorldLightRadius(), Actor->WorldVolumetricRadius() );
						for( int i=0; i<4; i++ )
							if( Frame->ViewPlanes[i].PlaneDot(Actor->Location) < -MaxRadius )
								break;
						if( i==4 )
						{
							UBOOL IsVolumetric = Actor->Region.Zone->bFogZone && Actor->VolumeRadius && Actor->VolumeBrightness;
							for( i=0; IsVolumetric && i<4; i++ )
								if( Frame->ViewPlanes[i].PlaneDot(Actor->Location) < -Actor->WorldVolumetricRadius() )
									IsVolumetric = 0;
							new(GDynMem)FDynamicLight( 0, Actor, IsVolumetric, 0 );
							STAT(GStat.DynLightActors++);
						}
					}
				}
			}
		}
		STAT(unclock(GStat.FilterTime));
	}
*/
};

extern ENGINE_API URender* GRender;

/*------------------------------------------------------------------------------------
	The End.
------------------------------------------------------------------------------------*/
