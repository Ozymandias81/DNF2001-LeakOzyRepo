/*=============================================================================
	SoftDrv.cpp: Unreal software rendering driver.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

#include "SoftDrvPrivate.h"

/*-----------------------------------------------------------------------------
	Global implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(SoftDrv);
IMPLEMENT_CLASS(USoftwareRenderDevice);

/*-----------------------------------------------------------------------------
	Stubs.
-----------------------------------------------------------------------------*/

void USoftwareRenderDevice::StaticConstructor()
{
	guard(USoftwareRenderDevice::StaticConstructor);

	new(GetClass(),TEXT("HighResTextureSmooth"),RF_Public)UBoolProperty (CPP_PROPERTY(HighResTextureSmooth), TEXT("Options"), CPF_Config );
	new(GetClass(),TEXT("LowResTextureSmooth"), RF_Public)UBoolProperty (CPP_PROPERTY(LowResTextureSmooth ), TEXT("Options"), CPF_Config );
	new(GetClass(),TEXT("FastTranslucency"),    RF_Public)UBoolProperty (CPP_PROPERTY(FastTranslucency    ), TEXT("Options"), CPF_Config );
	new(GetClass(),TEXT("DetailBias"),		    RF_Public)UFloatProperty(CPP_PROPERTY(DetailBias          ), TEXT("Options"), CPF_Config );

	unguard;
}

UBOOL USoftwareRenderDevice::Init( UViewport* InViewport, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
{
	guard(USoftwareRenderDevice::Init);

	// Variables.
	Viewport			= InViewport;
	FrameLocksCounter	= 0;
	SurfPalBuilds		= 0;
	SetupFastSqrt();

	// Driver flags.
	SpanBased			= 1;
	FullscreenOnly		= 0;
	SupportsFogMaps		= GIsMMX;
	SupportsDistanceFog	= 0;
	InitDrawSurf();

	// Setup viewport.
	return SetRes( NewX, NewY, NewColorBytes, Fullscreen );

	unguard;
}

UBOOL USoftwareRenderDevice::SetRes( INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
{
	guard(USoftwareRenderDevice::SetRes);
	if( NewColorBytes!=2 && NewColorBytes!=4 )
		NewColorBytes = 4;
	if( !GIsEditor )
	{
		NewX = Clamp(NewX,320,MaximumXScreenSize);
		NewY = Clamp(NewY,200,MaximumYScreenSize);
	}
	return Viewport->ResizeViewport( Fullscreen ? (BLIT_Fullscreen|BLIT_DirectDraw) : BLIT_DibSection, Align(NewX,2), NewY, NewColorBytes );
	unguard;
}

void USoftwareRenderDevice::Exit()
{
	guard(USoftwareRenderDevice::Exit);
	unguard;
}

void USoftwareRenderDevice::Flush( UBOOL )
{
	guard(USoftwareRenderDevice::Flush);
	unguard;
}

UBOOL USoftwareRenderDevice::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(USoftwareRenderDevice::Exec);
	return 0;
	unguard;
}

//
// Called at the start of every frame.
//
void USoftwareRenderDevice::Lock( FPlane InFlashScale, FPlane InFlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* InHitData, INT* InHitSize )
{
	guard(USoftwareRenderDevice::Lock);	
	check(Viewport);

	FrameLocksCounter++; // Software frame counter. 

	GByteStride = Viewport->Stride * Viewport->ColorBytes ;


	// CPU and bit depth detection.
	if (GIsMMX)
	{
		if (Viewport->ColorBytes==4) ColorMode = MMX32;
		else ColorMode = (Viewport->Caps & CC_RGB565) ? MMX16 : MMX15;
	}
	else
	{
		if (Viewport->ColorBytes==4) ColorMode = Pentium32;
		else ColorMode = (Viewport->Caps & CC_RGB565) ? Pentium16 : Pentium15;
	}

	FlashScale = InFlashScale * 255.0f;
	FlashFog   = InFlashFog   * 255.0f;

	HitCount   = 0;
	HitData    = InHitData;
	HitSize    = InHitSize;

	guardSlow(Cleanings);

	// Colordepth-specific actions
	if( Viewport->ColorBytes==2 && (Viewport->Caps & CC_RGB565) )
	{
		// various color scalers for DrawPolyC
		GMaxColor.X = (31*8)/256.0f;
		GMaxColor.Y = (63*4)/256.0f;
		GMaxColor.Z = (31*8)/256.0f;

		// Clear the screen.
		if( RenderLockFlags & LOCKR_ClearScreen )
		{
			_WORD ColorWord = FColor(ScreenClear).HiColor565(), *Dest=(_WORD*)Viewport->ScreenPointer;
			ClearScreenFast16(Dest,ColorWord);
		}
	}
	else if( Viewport->ColorBytes==2 )
	{
		GMaxColor.X = (31*8)/256.0f;
		GMaxColor.Y = (31*8)/256.0f;
		GMaxColor.Z = (31*8)/256.0f;

		// Clear the screen.
		if( RenderLockFlags & LOCKR_ClearScreen )
		{
			_WORD ColorWord = FColor(ScreenClear).HiColor555(), *Dest=(_WORD*)Viewport->ScreenPointer;
			ClearScreenFast16(Dest,ColorWord);
		}
	}
	else  if( Viewport->ColorBytes==4 )
	{
		GMaxColor.X = 1.0f;
		GMaxColor.Y = 1.0f;
		GMaxColor.Z = 1.0f;

		// Clear the screen.
		if( RenderLockFlags & LOCKR_ClearScreen )
		{
			DWORD ColorDWord = FColor(ScreenClear).TrueColor(), *Dest=(DWORD*)Viewport->ScreenPointer;
			ClearScreenFast32(Dest,ColorDWord);
		}
	}

	unguardSlow; //cleanings

	// FlashScale 128.0 = no flash.
	GMasterScale = ( 0.5 + Viewport->GetOuterUClient()->Brightness ); // global brightness scaler
	FLOAT BrightScale = (1.0f/128.0f)*GMasterScale;
	
	// #debug scale by GMaxColor rather than clip by it...
	GFloatFog.X =  MinPositiveFloat( InFlashFog.X , GMaxColor.X ); 
	GFloatFog.Y =  MinPositiveFloat( InFlashFog.Y , GMaxColor.Y ); 
	GFloatFog.Z =  MinPositiveFloat( InFlashFog.Z , GMaxColor.Z );

	GFloatScale.X = BrightScale * FlashScale.X; 
	GFloatScale.Y = BrightScale * FlashScale.Y;
	GFloatScale.Z = BrightScale * FlashScale.Z;

	// Ensure global light and fog factors will always combine without overflow, regardless
	// of bit depth.

	// GFloatRange is maximum color a light can have when only Global fog is taken into account.
	GFloatRange.X = GMaxColor.X - GFloatFog.X;
	GFloatRange.Y = GMaxColor.Y - GFloatFog.Y;
	GFloatRange.Z = GMaxColor.Z - GFloatFog.Z;

	unguard;
}

//
// Called at end of frame.
//
void USoftwareRenderDevice::Unlock( UBOOL Blit )
{
	guard(USoftwareRenderDevice::Unlock);

	check(HitStack.Num()==0);
	if( HitSize )
		*HitSize = HitCount;

	unguard;
}

//
// Get device's rendering stats.
//
void USoftwareRenderDevice::GetStats( TCHAR* Result )
{
	guard(USoftwareRenderDevice::GetStats);
	appSprintf( Result, TEXT("No stats available") );
	unguard;
}

//
// Square root tables.
//
FLOAT FastSqrtTbl[2 << FASTAPPROX_MAN_BITS];
void SetupFastSqrt()
{
	// Setup square root tables.
	for( DWORD D=0; D< (1 << FASTAPPROX_MAN_BITS ); D++ )
	{
		union {FLOAT F; DWORD D;} Temp;
		Temp.F = 1.0;
		Temp.D = (Temp.D & 0xff800000 ) + (D << (23 - FASTAPPROX_MAN_BITS));
		Temp.F = appSqrt(Temp.F);
		Temp.D = (Temp.D - ( 64 << 23 ) );   // exponent bias re-adjust
		FastSqrtTbl[ D ] = (FLOAT)(Temp.F * appSqrt(2.0)); // for odd exponents
		FastSqrtTbl[ D + (1 << FASTAPPROX_MAN_BITS) ] =  (FLOAT) (Temp.F * 2.0);
	}
}

/*-----------------------------------------------------------------------------
	The end.
-----------------------------------------------------------------------------*/
