/*=============================================================================
	UnRenDev.h: 3D rendering device class.

	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
	Compiled with Visual C++ 4.0. Best viewed with Tabs=4.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

/*------------------------------------------------------------------------------------
	URenderDevice.
------------------------------------------------------------------------------------*/

struct FTransSample;

// Flags for locking a rendering device.
enum ELockRenderFlags
{
	LOCKR_ClearScreen	    = 1,
	LOCKR_LightDiminish     = 2,
};
enum EDescriptionFlags
{
	RDDESCF_Certified       = 1,
	RDDESCF_Incompatible    = 2,
	RDDESCF_LowDetailWorld  = 4,
	RDDESCF_LowDetailSkins  = 8,
	RDDESCF_LowDetailActors = 16,
};

//
// A low-level 3D rendering device.
//
#define RENDEV_MAGIC 'Rend'
#define RENDEV_FREE  'Free'
class ENGINE_API URenderDevice : public USubsystem
{
	DECLARE_ABSTRACT_CLASS(URenderDevice,USubsystem,CLASS_Config)
	
	// Variables.
	BYTE			DecompFormat;
	UViewport*		Viewport;
	FString			Description;
	DWORD			DescFlags;
	BITFIELD		SpanBased;
	BITFIELD		SupportsFogMaps;
	BITFIELD		SupportsDistanceFog;
	BITFIELD		VolumetricLighting;
	BITFIELD		ShinySurfaces;
	BITFIELD		Coronas;
	BITFIELD		HighDetailActors;
	BITFIELD		SupportsTC;
	BITFIELD		PrecacheOnFlip;
	BITFIELD		DetailTextures;
	BITFIELD		Pad1[8];
	DWORD			Pad0[8];

	FSceneNode  *CurrentFrame;
	FVector      ViewLocation;
	FRotator     ViewRotation;

	// Constructors.
	void StaticConstructor();

	// URenderDevice low-level functions that drivers must implement.
	virtual UBOOL __fastcall Init( UViewport* InViewport, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )=0;
	virtual UBOOL __fastcall SetRes( INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )=0;
	virtual void __fastcall Exit()=0;
	virtual void __fastcall Flush( UBOOL AllowPrecache )=0;
	virtual UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	virtual void __fastcall Lock( FColor FogColor, float FogDensity, INT FogDistance, FPlane FlashScale, FPlane FlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* HitData, INT* HitSize )=0;

	virtual void __fastcall Unlock( UBOOL Blit )=0;
	virtual void __fastcall DrawComplexSurface( FSceneNode* Frame, FSurfaceInfo& Surface, FSurfaceFacet& Facet )=0;
	virtual void __fastcall DrawGouraudPolygon( FSceneNode* Frame, FTextureInfo& Info, FTransTexture** Pts, int NumPts, DWORD PolyFlags, FSpanBuffer* Span, DWORD PolyFlagsEx=0 ) {};
	virtual bool __fastcall QueuePolygonDoes()  { return false; }
	virtual bool __fastcall QueuePolygonBegin(FSceneNode *Frame) { CurrentFrame=Frame; return false; }
	virtual void __fastcall QueuePolygonEnd(DWORD ProjectorFlags = 0)	{}
	virtual void __fastcall QueuePolygon( /*FSceneNode* Frame, */FTextureInfo* Info, FTransTexture** Pts, INT NumPts, DWORD PolyFlags, DWORD ExFlags, FSpanBuffer *Span ) 
	{ DrawGouraudPolygon(CurrentFrame,*Info,Pts,NumPts,PolyFlags,Span); }
	
	// JEP... (for building shadow textures fast)
	virtual bool __fastcall QueuePolygonBeginFast(FSceneNode *Frame) { CurrentFrame=Frame; return false; }
	virtual void __fastcall QueuePolygonEndFast() {}
	virtual void __fastcall QueuePolygonFast(FTransTexture** Pts, INT NumPts) {}
	// ...JEP

	virtual void __fastcall DrawTile(
							FSceneNode* Frame, 
							FTextureInfo& Info, 
							FLOAT X, FLOAT Y, 
							FLOAT XL, FLOAT YL, 
							FLOAT U, FLOAT V, 
							FLOAT UL, FLOAT VL, 
							class FSpanBuffer* Span=NULL, 
							FLOAT Z=0, 
							FPlane Color=FVector(0,0,0), FPlane Fog=FVector(0,0,0), 
							DWORD PolyFlags=0, 
							DWORD PolyFlagsEx=0, 
							FLOAT alpha=1.0,
							FLOAT rot=0.0,
							FLOAT rotationOffsetX=0.0,
							FLOAT rotationOffsetY=0.0
	)=0;
	virtual void __fastcall PreRender( FSceneNode* Frame ) {}
	

	// NJS:
	void __fastcall Draw3DSplineSection( FSceneNode *Frame, FPlane Color, DWORD LineFlags,
	 			              int Tesselations,
  							  FVector PreviousLocation, FRotator PreviousRotation,
							  FVector Location,		    FRotator Rotation,
							  FVector NextLocation,     FRotator NextRotation,
							  FVector Next2Location,    FRotator Next2Rotation
							 )
	{
		check(Tesselations);

		FVector  OldLocation=Location, NewLocation;
		FRotator OldRotation=Rotation, NewRotation;
		float OneOverTesselations=1.f/(float)Tesselations;

		for(float t=0.0;
				  t<=1.f;
				  t+=OneOverTesselations
		   )
		{
			KRSpline_Sample(t,NewLocation,NewRotation,
							  PreviousLocation, PreviousRotation,
							  Location, Rotation,
							  NextLocation, NextRotation,
							  Next2Location, Next2Rotation);
			// Draw 3D Line:
			Queue3DLine(Frame,Color,LineFlags,OldLocation,NewLocation);

			// Set up for next one:
			OldLocation=NewLocation;
			OldRotation=NewRotation;
		}

		// Connect the last point manually: 
		KRSpline_Sample(1.f,NewLocation,NewRotation,
								     PreviousLocation, PreviousRotation,
									 Location, Rotation,
									 NextLocation, NextRotation,
									 Next2Location, Next2Rotation);

		Queue3DLine(Frame,Color,LineFlags,OldLocation,NewLocation);	
	}

	virtual void __fastcall dnDrawParticles( ASoftParticleSystem &System, FSceneNode *Frame ) {}
	virtual void __fastcall dnDrawBeam( ABeamSystem &System, FSceneNode *Frame ) {}
	
	virtual void __fastcall Draw3DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector OrigP, FVector OrigQ);
	virtual void __fastcall Queue3DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector OrigP, FVector OrigQ) 
	{
		Draw3DLine(Frame,Color,LineFlags,OrigP,OrigQ); 	// NJS: Punt to original routine by default:
	}
	virtual void __fastcall Queued3DLinesFlush(FSceneNode* Frame) {}

	virtual void __fastcall Draw2DClippedLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector P1, FVector P2 );
	virtual void __fastcall Draw2DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector P1, FVector P2 )=0;
	virtual void __fastcall Draw2DPoint( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FLOAT X1, FLOAT Y1, FLOAT X2, FLOAT Y2, FLOAT Z )=0;
	virtual void __fastcall ClearZ( FSceneNode* Frame )=0;
	virtual void __fastcall PushHit( const BYTE* Data, INT Count )=0;
	virtual void __fastcall PopHit( INT Count, UBOOL bForce )=0;
	virtual void __fastcall GetStats( TCHAR* Result )=0;
	virtual void __fastcall ReadPixels( FColor* Pixels, UBOOL BackBuffer = false)=0;
	virtual void __fastcall EndFlash() {}
	virtual void __fastcall DrawStats( FSceneNode* Frame ) {}
	virtual void __fastcall SetSceneNode( FSceneNode* Frame ) {}
	virtual void __fastcall PrecacheTexture( FTextureInfo& Info, DWORD PolyFlags, DWORD PolyFlagsEx=0 ) {}
	virtual void __fastcall SetTextureClampMode( INT Mode=0 ) {};

	// NJS: Attempt to validate the integrity of the driver ... useful in debugging.
	#define DriverValidate() _Validate(__FILE__,__LINE__)
	virtual void __fastcall _Validate(char *File="unknown",int Line=-1) { check(this); } // Stub consistancy check

	// JEP...
	virtual void *CreateRenderTarget(INT W, INT H) {return NULL;};
	virtual void DestroyRenderTarget(void **pRenderTarget) {};
	virtual void SetRenderTarget(void *pRenderTarget, void *pNewZStencil) {};
	virtual void RestoreRenderTarget(void) {};
	virtual void __fastcall AddProjector(FSceneNode *Frame, void *pRenderTarget, FTextureInfo *Info, FLOAT wNear, FLOAT wFar, FLOAT FadeScale) {};
	virtual void __fastcall ResetProjectors(void) {};
	// ...JEP
};

/*------------------------------------------------------------------------------------
	The End.
------------------------------------------------------------------------------------*/
