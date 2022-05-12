/*=============================================================================
	UnSGL.cpp: Unreal support for the PowerVR SGL library.

	Copyright 1997 NEC Electronics Inc.
	Based on code copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Jayeson Lee-Steere from code by Tim Sweeney
		* 970112 JLS - Started changes to use new hardware interface.

=============================================================================*/
// Precompiled header.
#pragma warning( disable:4201 )
#include <windows.h>
#include "Engine.h"
#include "UnRender.h"

// SGL includes.
#include <ddraw.h>
#include "unsgl.h"

// Unreal package implementation.
IMPLEMENT_PACKAGE(SGLDrv);

IMPLEMENT_CLASS(USGLRenderDevice);

//*****************************************************************************
// Public SGL rendering device functions
//*****************************************************************************
//*****************************************************************************
// Register configurable properties.
//*****************************************************************************
void USGLRenderDevice::StaticConstructor()
{
	guard(USGLRenderDevice::StaticConstructor);

	UEnum* ColorDepth=new(GetClass(),TEXT("Color Depth"))UEnum(NULL);
		new(ColorDepth->Names)FName( TEXT("16") );
		new(ColorDepth->Names)FName( TEXT("24") );
	UEnum* TextureDetailBias=new(GetClass(),TEXT("Texture Detail Bias"))UEnum(NULL);
		new(TextureDetailBias->Names)FName( TEXT("Near") );
		new(TextureDetailBias->Names)FName( TEXT("Far") );
	new(GetClass(),TEXT("VertexLighting"),    RF_Public)UBoolProperty( CPP_PROPERTY(VertexLighting    ),TEXT("Options"),CPF_Config);
	new(GetClass(),TEXT("FastUglyRefresh"),   RF_Public)UBoolProperty( CPP_PROPERTY(FastUglyRefresh   ),TEXT("Options"),CPF_Config);
	new(GetClass(),TEXT("ColorDepth"),        RF_Public)UByteProperty( CPP_PROPERTY(ColorDepth        ),TEXT("Options"),CPF_Config,ColorDepth);
	new(GetClass(),TEXT("TextureDetailBias"), RF_Public)UByteProperty( CPP_PROPERTY(TextureDetailBias ),TEXT("Options"),CPF_Config,TextureDetailBias);

	unguard;
}

//*****************************************************************************
// Validate configuration changes.
//*****************************************************************************
void USGLRenderDevice::PostEditChange()
{
	guard(USGLRenderDevice::PostEditChange);

	unguard;
}

//*****************************************************************************
// Initializes SGL.
//*****************************************************************************
UBOOL USGLRenderDevice::Init( UViewport* InViewport, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
{
	guard(USGLRenderDevice::Init);

	int Status=0;
	int X,Y,Bpp,NumBuffers;

	debugf(NAME_Init,TEXT("SGL: Initializing..."));

	// Save off the viewport
	Viewport=InViewport;

	// Driver flags.
	SpanBased			= 0;
	FullscreenOnly		= 1;
#ifdef SUPPORT_FOG
	SupportsFogMaps		= 1;
#else
	SupportsFogMaps		= 0;
#endif
	SupportsDistanceFog	= 1;

	// Try and dynalink to the .DLL.
	if(!HookSGL())
	{
		// No good.
		debugf(NAME_Init,TEXT("SGL: Failed load the SGL library."));
		return 0;
	}

	X=Viewport->SizeX;
	Y=Viewport->SizeY;

	// Choose color depth.
	if (ColorDepth==0)
		Bpp=16;
	else
		Bpp=24;

	// Choose number of buffers.
	if (FastUglyRefresh)
		NumBuffers=1;
	else
		NumBuffers=3;
	
	// Init the rendering device.
	guard(DDCInit);
	Status=DDCInit();
	unguard;
	if (Status==DDCERR_OK)
	{
		guard(DDCCreateRenderingObject);
		Status=DDCCreateRenderingObject((HWND)Viewport->GetWindow(),TRUE,X,Y,Bpp,NumBuffers);
		unguard;
	}
	if (Status!=DDCERR_OK)
	{
		// No good.
		debugf(NAME_Init,TEXT("SGL: Failed to create screen device (%ix%i) (%s)"),
			   X,Y,DDCGetErrorMessage(Status));
		return 0;
	}

	// Init the SGLCONTEXT structure.
	memset(&SglContext,0,sizeof(SGLCONTEXT));
	SglContext.u32Flags=SGLTT_BILINEAR;
	SglContext.uLineWidth=1;
	SglContext.eTransSortMethod=NO_SORT;
	SglContext.eFilterType=sgl_tf_bilinear;
	SglContext.bDoClipping=UNSGL_DISABLE_SGL_CLIPPING_VALUE;
	if (TextureDetailBias)
	{
		SglContext.u32Flags|=SGLTT_MIPMAPOFFSET;
		SglContext.n32MipmapOffset=-1;
	}

	// Create default textures.
	CreateDefaultTextures();
	SglContext.nTextureName=DefaultTextureMap;
	SglContext.u32Flags|=SGLTT_TEXTURE;

	// Init the texture caching class.
	InitCaching();

	// Set variables.
	CurrentFrame=0;
	InFrame=0;
	ScaleInvW=NormalScaleInvW=UNSGL_START_SCALE_INVW;
	SkyScaleInvW=NormalScaleInvW*UNSGL_SKY_SCALE_INVW;

	RESET_SIMPLE_VERTEX_BUFFER();
	SimplePolyFlags=0xFFFFFFFF;

//todo: [USGLRenderDevice::Init] Initialize any other variables etc.
	
	// Gamma table(s)
	GammaTable=new int[0x100];
	IntensityAdjustTable=new int [128];
	UpdateGammaTables(1.0f);

	// Flush.
	Flush(1);

	// Success.
    Viewport->ResizeViewport( BLIT_Fullscreen, X, Y, 0 );

	debugf(NAME_Init,TEXT("SGL: Initialized."));
	return 1;
	unguard;
}

//
// Set resolution.
//
UBOOL USGLRenderDevice::SetRes( INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
{
	guard(USGLRenderDevice::SetRes);
	check(!InFrame);

	// Wait for a render to complete if any.
	guard(DDCWaitForRenderToComplete);
	DDCWaitForRenderToComplete( 500 );
	unguard;

	// Destroy existing rendering object and shut down DDC.
	guard(DDCDestroyRenderingObject);
	DDCDestroyRenderingObject();
	unguard;

	// Init and create a new rendering object
	guard(DDCCreateRenderingObject);
	INT Status = DDCCreateRenderingObject( (HWND)Viewport->GetWindow(), TRUE, NewX, NewY, (ColorDepth==0)?16:24, (FastUglyRefresh)?1:3 );
	if( Status!=DDCERR_OK )
		appErrorf(TEXT("SGL: Failed to change resolution"));
	unguard;

	// Resize the owning viewport.
	Viewport->ResizeViewport( BLIT_Fullscreen, NewX, NewY, 0 );

	return 1;
	unguard;
}

//*****************************************************************************
// Shut down rendering device.
//*****************************************************************************
void USGLRenderDevice::Exit()
{
	guard(USGLRenderDevice::Exit);

	debugf(NAME_Exit,TEXT("SGL: Shutting down..."));

	// If we are in the middle of a frame, we MUST render it off.
	if (InFrame)
	{
		guard(DDCRender);
		DDCRender();
		unguard;
		InFrame=0;
	}

	// Wait for a render to complete if any.
	DDCWaitForRenderToComplete(500);

	// Shut down the texture caching code. This will remove all textures from SGL
	// memory so must be done after the render is complete.
	ShutDownCaching();

	// Free up any allocated memory.
	delete [] GammaTable;
	delete [] IntensityAdjustTable;

	// Shut down SGL.
	DDCDestroyRenderingObject();
	DDCShutdown();

	// Unload the SGL library.
	UnhookSGL();
		
	debugf(NAME_Exit,TEXT("SGL: Terminated."));

	unguard;
};

//*****************************************************************************
// Perform safe shutdown after critical errors. 
//*****************************************************************************

void USGLRenderDevice::ShutdownAfterError()
{
	guard(USGLRenderDevice::ShutdownAfterError);
	
	// Note: Avoid any dangerous shutdown activities.
	Exit();

	unguard;
}

//*****************************************************************************
// Flush the device. 
//*****************************************************************************
void USGLRenderDevice::Flush( UBOOL AllowPrecache )
{
	guard(USGLRenderDevice::Flush);

	// Flush the simple vertex buffer if it isn't empty.
	FLUSH_SIMPLE_VERTEX_BUFFER_IF_NOT_EMPTY();

	// Update the gamma settings.
	debugf(NAME_Log,TEXT("Brightness=%f, Gamma=%f"),Viewport->GetOuterUClient()->Brightness,0.5 + 1.5*Viewport->GetOuterUClient()->Brightness);
//	UpdateGammaTables(0.5 + 1.5*Viewport->Client->Brightness);
	UnloadAllTextures();

	unguard;
}

//*****************************************************************************
// Lock the SGL device. This sends a "startofframe".
//*****************************************************************************
void USGLRenderDevice::Lock( FPlane InFlashScale, FPlane InFlashFog, FPlane ScreenClear, DWORD InLockFlags, BYTE* HitData, INT* HitSize )
{
	guard(USGLRenderDevice::Lock);

	// Remember parameters.
	LockFlags  = InLockFlags;
	FlashScale = InFlashScale;
	FlashFog   = InFlashFog;

	// Init stats.
	memset(&Stats,0,sizeof(Stats));

	// Start the frame if necessary.
	if (!InFrame)
	{
		guard(DDCStartOfFrame);
		CLOCK(Stats.StartOfFrameTime);
		DDCStartOfFrame();
		UNCLOCK(Stats.StartOfFrameTime);
		unguard;
		InFrame=1;

		// Reset the scaling value.
		ScaleInvW=NormalScaleInvW=UNSGL_START_SCALE_INVW;
		SkyScaleInvW=NormalScaleInvW*UNSGL_SKY_SCALE_INVW;
		NoZInvW=UNSGL_Z_START;

		// Zero these so texture changes are forced. Otherwise dynamic textures may
		// not update.
		PolyCTex.CacheID=0;
		PolyVTex.CacheID=0;
		BumpMapTex.CacheID=0;
		MacroTex.CacheID=0;
		LightMapTex.CacheID=0;
		DetailTex.CacheID=0;
		FogMapTex.CacheID=0;
	}

	unguard;
};

//*****************************************************************************
// Unlock the SGL rendering device. This sends a "render".
//*****************************************************************************
void USGLRenderDevice::Unlock( UBOOL Blit )
{
	guard(USGLRenderDevice::Unlock);

	// Flush the simple vertex buffer if it isn't empty.
	FLUSH_SIMPLE_VERTEX_BUFFER_IF_NOT_EMPTY();

	// Screen flashes.
	if( FlashScale!=FVector(.5,.5,.5) || FlashFog!=FVector(0,0,0) )
	{
		static int FaceList[][4]={{0,1,2,3}};

		// Setup color.
		SGLColor Color = SGLColor(FPlane(FlashFog.X,FlashFog.Y,FlashFog.Z,Min(FlashScale.X*2.f,1.f)));
		int Divisor=Max((unsigned char)1,Max(Max(Color.R,Color.G),Max(Color.B,Color.A)));
		Color.R=Color.R*255/Divisor;
		Color.G=Color.G*255/Divisor;
		Color.B=Color.B*255/Divisor;
		Color.A=255-Color.A;

		// Set up verts.
		VERTEX V[4];
		FLOAT InvW=0.99*NormalScaleInvW;
		V[0].fX=0;               V[0].fY=0;               V[0].fInvW=InvW; V[0].Color=Color.D;
		V[1].fX=0;               V[1].fY=Viewport->SizeY; V[1].fInvW=InvW; V[1].Color=Color.D;
		V[2].fX=Viewport->SizeX; V[2].fY=Viewport->SizeY; V[2].fInvW=InvW; V[2].Color=Color.D;
		V[3].fX=Viewport->SizeX; V[3].fY=0;               V[3].fInvW=InvW; V[3].Color=Color.D;

		// Set up SGLCONTEXT.
		int OrgFlags=SglContext.u32Flags;
		SglContext.u32Flags&=~(SGLTT_TEXTURE | SGLTT_GOURAUD | SGLTT_NEWPASSPERTRI);
		SglContext.u32Flags|=SGLTT_VERTEXTRANS;
		sgltri_quads(&SglContext,1,FaceList,(SGLVERTEX *)V);
		SglContext.u32Flags=OrgFlags;
	}

	// Blit it.
	if(Blit && InFrame)
	{
#ifdef DOSTATS
		// Wait for the last render to complete so we see if the game is hardware bound.
		guard(DDCWaitForRenderToComplete);
		CLOCK(Stats.RenderFinishTime);
		DDCWaitForRenderToComplete(500);
		UNCLOCK(Stats.RenderFinishTime);
		unguard;
#endif

		// Render and flip pages.
		guard(DDCRender);
		CLOCK(Stats.RenderTime);
		DDCRender();
		UNCLOCK(Stats.RenderTime);
		unguard;

		// Now the stats are valid, copy them so they will be displayed next frame.
		memcpy(&LastStats,&Stats,sizeof(FSGLStats));

		// No longer in a frame.
		InFrame=0;

		// Increment frame counter.
		CurrentFrame++;

		// Frees any textures that are in the queue and are no longer being used.
		FreeQueuedTextures();
	}

	unguard;
};

//*****************************************************************************
// Clear the Z-buffer.
//*****************************************************************************
void USGLRenderDevice::ClearZ( FSceneNode* Frame )
{
        guard(USGLRenderDevice::ClearZ);

		ScaleInvW*=UNSGL_CLEAR_SCALE_INVW;
		NormalScaleInvW*=UNSGL_CLEAR_SCALE_INVW;
		SkyScaleInvW*=UNSGL_CLEAR_SCALE_INVW;
		NoZInvW=UNSGL_Z_START;

        unguard;
}

//*****************************************************************************
// Get stats.
//*****************************************************************************
void USGLRenderDevice::GetStats( TCHAR* Result )
{
	guard(USGLRenderDevice::GetStats);

	if (LastStats.DisplayCount==0)
	{
		appSprintf
		(
				Result,
				TEXT("startofframe=(%04.1f) renderfinish=(%04.1f) render=(%04.1f)"),
				GSecondsPerCycle*1000 * LastStats.StartOfFrameTime,
				GSecondsPerCycle*1000 * LastStats.RenderFinishTime,
				GSecondsPerCycle*1000 * LastStats.RenderTime
		);
	}
	else if (LastStats.DisplayCount==1)
	{
		appSprintf
		(
				Result,
				TEXT("csurfs=%03i (%04.1f) cpolys=%03i gpolys=%03i (%04.1f) tiles=%03i (%04.1f)"),
				LastStats.ComplexSurfs,
				GSecondsPerCycle*1000 * LastStats.ComplexSurfTime,
				LastStats.ComplexPolys,
				LastStats.GouraudPolys,
				GSecondsPerCycle*1000 * LastStats.GouraudPolyTime,
				LastStats.Tiles,
				GSecondsPerCycle*1000 * LastStats.TileTime
		);
	}
	else if (LastStats.DisplayCount==2)
	{
		appSprintf
		(
				Result,
				TEXT("texloads=(%04.1f) pal=%03i (%04.1f) tex=%03i (%04.1f) lmap=%03i (%04.1f) fmap=%03i (%04.1f) reload=%03i (%04.1f) lmaxcolor=%03i (%04.1f) fmaxcolor=%03i (%04.1f) \n"),
				GSecondsPerCycle*1000 * LastStats.TextureLoadTime,
				LastStats.Palettes,
				GSecondsPerCycle*1000 * LastStats.PaletteTime,
				LastStats.Textures,
				GSecondsPerCycle*1000 * LastStats.TextureTime,
				LastStats.LightMaps,
				GSecondsPerCycle*1000 * LastStats.LightMapTime,
				LastStats.FogMaps,
				GSecondsPerCycle*1000 * LastStats.FogMapTime,
				LastStats.Reloads,
				GSecondsPerCycle*1000 * LastStats.ReloadTime,
				LastStats.LightMaxColors,
				GSecondsPerCycle*1000 * LastStats.LightMaxColorTime,
				LastStats.FogMaxColors,
				GSecondsPerCycle*1000 * LastStats.FogMaxColorTime
		);
	}
	else if (LastStats.DisplayCount==3)
	{
		appSprintf
		(
				Result,
				TEXT("LM Max U/V=%03i,%03i, LM Max Dim=%03i"),
				LastStats.LargestLMU,
				LastStats.LargestLMV,
				LastStats.LargestLMDim
		);
	}
	else
	{
		appSprintf(Result,TEXT(""));
	}

	LastStats.DisplayCount++;
	if (LastStats.DisplayCount>3)
		LastStats.DisplayCount=0;
	unguard;
}

//*****************************************************************************
// Execute a command.
//*****************************************************************************

int USGLRenderDevice::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(USGLRenderDevice::Exec);
	if( ParseCommand(&Cmd,TEXT("GetRes")) )
	{
		Ar.Logf( TEXT("320x200 512x384 640x480 800x600 1024x768") );
		return 1;
	}
	else return 0;
	unguard;
}

//*****************************************************************************
// Implement reading of the frame buffer.
//*****************************************************************************
void USGLRenderDevice::ReadPixels( FColor* InPixels )
{ 
	guard(USGLRenderDevice::ReadPixels);

	UnloadAllTextures();
	DDCStartOfFrame();
	DDCRender();
	DDCStartOfFrame();
	DDCRender();
	CurrentFrame+=2;
	FreeQueuedTextures();

	// Get DirectDraw surface.
	IDirectDrawSurface *Surface=DDCGetRenderingObjectBufferForScreenshot(TRUE);
	
	// Lock the surface
	DDSURFACEDESC SurfaceInfo;
	ZeroMemory(&SurfaceInfo, sizeof(SurfaceInfo));
	SurfaceInfo.dwSize = sizeof(SurfaceInfo);
	SurfaceInfo.dwFlags = DDLOCK_SURFACEMEMORYPTR;	/* Request valid memory pointer */
    HRESULT ddrval=Surface->Lock( NULL,&SurfaceInfo,
								   DDLOCK_SURFACEMEMORYPTR | DDLOCK_WAIT | DDLOCK_WRITEONLY,
								   NULL);
	// Make sure lock worked
	if (ddrval!=DD_OK)
	{
		debugf(NAME_Log,TEXT("SGL: ERROR: Failed to lock frame buffer for screenshot."));
		return;
	}

	// Copy data.
	BYTE *Src=(BYTE *)SurfaceInfo.lpSurface;
	int X,Y;
	switch (DDCGetRenderingObjectRealBpp())
	{
		case 15:
			for (Y=0;Y<Viewport->SizeY;Y++,Src+=SurfaceInfo.lPitch - Viewport->SizeX*2)
			{
				for (X=0;X<Viewport->SizeX;X++,Src+=2)
				{
					FColor* Dst=InPixels + 	X + Y*Viewport->SizeX;
					WORD Val=*((WORD *)Src);
					int R=Val & 0x7C00;
					int G=Val & 0x03E0;
					int B=Val & 0x001F;
					Dst->B=(R >> 7) | (R >> 12);
					Dst->G=(G >> 2) | (G >> 7);
					Dst->R=(B << 3) | (B >> 2);
				}
			}
			break;
		case 16:
			for (Y=0;Y<Viewport->SizeY;Y++,Src+=SurfaceInfo.lPitch - Viewport->SizeX*2)
			{
				for (X=0;X<Viewport->SizeX;X++,Src+=2)
				{
					FColor* Dst=InPixels + 	X + Y*Viewport->SizeX;
					WORD Val=*((WORD *)Src);
					int R=Val & 0xF800;
					int G=Val & 0x07E0;
					int B=Val & 0x001F;
					Dst->B=(R >> 8) | (R >> 13);
					Dst->G=(G >> 3) | (G >> 9);
					Dst->R=(B << 3) | (B >> 2);
				}
			}
			break;
		case 24:
			for (Y=0;Y<Viewport->SizeY;Y++,Src+=SurfaceInfo.lPitch - Viewport->SizeX*3)
			{
				for (X=0;X<Viewport->SizeX;X++,Src+=3)
				{
					FColor* Dst=InPixels + 	X + Y*Viewport->SizeX;
					Dst->B=Src[0];
					Dst->G=Src[1];
					Dst->R=Src[2];
				}
			}
			break;
	}

	// Unlock surface.
	Surface->Unlock(NULL);

	unguard;
}

//*****************************************************************************
// Unimplemented.
//*****************************************************************************
void USGLRenderDevice::Draw2DLine( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FVector P1, FVector P2 )
{
	guard(USGLRenderDevice::Draw2DLine);
	// Not implemented (not needed for Unreal I).
	unguard;
}
void USGLRenderDevice::Draw2DPoint( FSceneNode* Frame, FPlane Color, DWORD LineFlags, FLOAT X1, FLOAT Y1, FLOAT X2, FLOAT Y2, FLOAT Z )
{
	guard(USGLRenderDevice::Draw2DPoint);
	// Not implemented (not needed for Unreal I).
	unguard;
}

void USGLRenderDevice::PushHit( const BYTE* Data, INT Count )
{
	guard(USGLRenderDevice::PushHit);
	// Not implemented (not needed for Unreal I).
	unguard;
}
void USGLRenderDevice::PopHit( INT Count, UBOOL bForce )
{
	guard(USGLRenderDevice::PopHit);
	// Not implemented (not needed for Unreal I).
	unguard;
}

//*****************************************************************************
// Draw a textured polygon using surface vectors.
//*****************************************************************************
void USGLRenderDevice::DrawComplexSurface
(
	FSceneNode* Frame,
	FSurfaceInfo& Surface,
	FSurfaceFacet& Facet
)
{
	guard(USGLRenderDevice::DrawComplexSurface);
	CLOCK(Stats.ComplexSurfTime);
	STATS_INC(Stats.ComplexSurfs);

	// Flush the simple vertex buffer if it isn't empty.
	FLUSH_SIMPLE_VERTEX_BUFFER_IF_NOT_EMPTY();
	// Set flags to something invalid to force the next call to DrawGouraudPoolygon 
	// or DrawTileto set up the SGLCONTEXT state.
	SimplePolyFlags=0xFFFFFFFF;

	// Select correct scaling value for InvW.
	if ( Cast<ASkyZoneInfo>(Frame->Level->Model->Zones[Frame->ZoneNumber].ZoneActor) )
		ScaleInvW=SkyScaleInvW;
	else
		ScaleInvW=NormalScaleInvW;

	// We can't draw invisible polygons so bail.
	if (Surface.PolyFlags & PF_Invisible)
		return;

	FMemMark Mark(GMem);

	// Count up how many vertices we need to allocate memory for.
	int VertexCount=0;
	int FaceCount=0;
	for(FSavedPoly* Poly=Facet.Polys ; Poly; Poly=Poly->Next )
	{
		VertexCount+=Poly->NumPts;
		FaceCount+=Poly->NumPts-2;
	}

	// Allocate memory for vertices and face list.
	PVERTEX	Vertices=New<VERTEX>(GMem,VertexCount);
	int	(*FaceList)[3];
	FaceList=New<int [3]>(GMem,FaceCount);

	// Set the X and Y bias values.
	// On PCX2, the calculations SGL does go to pot when the X/Y values are a tiny
	// bit negative. The values can go a bit negative due to rounding errors in the
	// clipping Unreal does. Adding this small offset fixes the problem (most of the time).
	FLOAT XBias=Frame->XB + 0.1;
	FLOAT YBias=Frame->YB + 0.1;

	// Set up all poly vertices and build face list.
	PVERTEX Vertex=Vertices;
	int	(*Face)[3]=FaceList;
	int VertexIndex=0;
	FLOAT AdjScaleInvW	=ScaleInvW*Frame->RProj.Z;
	for( Poly=Facet.Polys ; Poly; Poly=Poly->Next )
	{
		// Set up vertices.
		FTransform **PtPtr	=Poly->Pts;
		for( int Count=Poly->NumPts; Count>0; Count--, Vertex++,PtPtr++ )
		{
			FTransform *Pt		= *PtPtr;
			Vertex->fX			= Pt->ScreenX + XBias;
			Vertex->fY			= Pt->ScreenY + YBias;
			Vertex->fMasterS	= Facet.MapCoords.XAxis | (*(FVector*)Pt - Facet.MapCoords.Origin);
			Vertex->fInvW		= Pt->RZ * AdjScaleInvW;
			Vertex->fMasterT	= Facet.MapCoords.YAxis | (*(FVector*)Pt - Facet.MapCoords.Origin);
		}
		// Set up faces.
		for (int i=2;i<Poly->NumPts;i++,Face++)
		{
			(*Face)[0]=VertexIndex;
			(*Face)[1]=VertexIndex+i-1;
			(*Face)[2]=VertexIndex+i;
		}
		VertexIndex+=Poly->NumPts;
	}

	// Set to flat shading, no vertex translucency.
	SglContext.u32Flags&=~(SGLTT_GOURAUD | SGLTT_VERTEXTRANS | SGLTT_NEWPASSPERTRI);

	// See if we have a surface texture.
	if (Surface.Texture)
	{
		// We have a surface texture, set set it.
		DWORD TextureFlags =	
			((Surface.PolyFlags & PF_Masked)			 ? SF_ColorKey                     : 0) |
			((Surface.PolyFlags & PF_Translucent)		 ? (SF_NoScale | SF_AdditiveBlend) : 0) |
			((Surface.PolyFlags & PF_Modulated)	         ? (SF_NoScale | SF_ModulationBlend) : 0) |
			((Surface.Texture->bRealtime) ? SF_NoScale                      : 0);
		// See if texture or flags have changed.
		QWORD TestID=Surface.Texture->CacheID + (((QWORD)TextureFlags) << TEXTURE_FLAGS_SHIFT);
		if (TestID!=PolyVTex.CacheID)
		{
			// Texture/flags have changed so set new texture/flags.
			SetTexture(*Surface.Texture,TextureFlags,TestID,PolyVTex);
		}
		SglContext.nTextureName=PolyVTex.SglTextureName;
		
		// Calculate U/V adjustment value.
		FLOAT USub=(Vertices[0].fMasterS - Surface.Texture->Pan.X) * PolyVTex.UScale;
		FLOAT VSub=(Vertices[0].fMasterT - Surface.Texture->Pan.Y) * PolyVTex.VScale;
		USub=appRound(USub) + Surface.Texture->Pan.X * PolyVTex.UScale;
		VSub=appRound(VSub) + Surface.Texture->Pan.Y * PolyVTex.VScale;
		
		// See if we have a lightmap.
		if (Surface.LightMap)
		{
			// We do have a lightmap so see if want vertex lighting or not.
			if ( !((Surface.PolyFlags & (PF_Masked | PF_Translucent | PF_Modulated)) | VertexLighting))
			{
				// We are doing lightmap lighting so set lightmap texture.
				// See if texture has changed.
				if (Surface.LightMap->CacheID!=LightMapTex.CacheID)
				{
					// Texture has changed so set new texture.
					SetTexture(*Surface.LightMap,SF_LightMap,Surface.LightMap->CacheID,LightMapTex);
					LightMapTex.User=IntensityAdjustTable[Max(LightMapTex.MaxColor.R,Max(LightMapTex.MaxColor.G,LightMapTex.MaxColor.B))/2]*16/14;
				}	

				// Set up base vertices and render.
				SGLColor	MaxColor=SGLColor((PolyVTex.MaxColor.R * LightMapTex.User)>>8,
											  (PolyVTex.MaxColor.G * LightMapTex.User)>>8,
											  (PolyVTex.MaxColor.B * LightMapTex.User)>>8);
				sgl_uint32 iBaseColor=MaxColor.D;
				// Loop through vertices, updating them.
				int Count;
				for (Vertex=Vertices,Count=VertexCount;Count>0;Count--,Vertex++)
				{
					Vertex->Color	= iBaseColor;
					Vertex->fUOverW	= Vertex->fInvW * ((Vertex->fMasterS) * PolyVTex.UScale - USub);
					Vertex->fVOverW	= Vertex->fInvW * ((Vertex->fMasterT) * PolyVTex.VScale - VSub);
				}
				sgltri_triangles(&SglContext,FaceCount,FaceList,(SGLVERTEX *)Vertices);

				// Set up lightmap vertices and render.
				SglContext.nTextureName=LightMapTex.SglTextureName;
				SglContext.u32Flags|=SGLTT_OPAQUE;
				iBaseColor	=LightMapTex.MaxColor.D;
				FLOAT AdjPanX=Surface.LightMap->Pan.X - 0.5*Surface.LightMap->UScale;
				FLOAT AdjPanY=Surface.LightMap->Pan.Y - 0.5*Surface.LightMap->VScale;
				// Loop through vertices, updating them.
				for (Vertex=Vertices,Count=VertexCount;Count>0;Count--,Vertex++)
				{
					Vertex->Color	= iBaseColor;
					Vertex->fUOverW	= Vertex->fInvW * (Vertex->fMasterS - AdjPanX) * LightMapTex.UScale;
					Vertex->fVOverW	= Vertex->fInvW * (Vertex->fMasterT - AdjPanY) * LightMapTex.VScale;
				}
				sgltri_triangles(&SglContext,FaceCount,FaceList,(SGLVERTEX *)Vertices);
				SglContext.u32Flags&=~SGLTT_OPAQUE;
			}
			else
			{
				// We are doing vertex lighting, so setup vertices and render.
				SglContext.u32Flags|=SGLTT_GOURAUD;
			
				// Loop through vertices, updating them.
				FLOAT InvUScale=1.0f/Surface.LightMap->UScale;
				FLOAT InvVScale=1.0f/Surface.LightMap->VScale;
				FLOAT AdjPanX=Surface.LightMap->Pan.X - 0.5f*Surface.LightMap->UScale;
				FLOAT AdjPanY=Surface.LightMap->Pan.Y - 0.5f*Surface.LightMap->VScale;
				int Count;
				for (Vertex=Vertices,Count=VertexCount;Count>0;Count--,Vertex++)
				{
					FLOAT X=(Vertex->fMasterS - AdjPanX)*InvUScale;
					FLOAT Y=(Vertex->fMasterT - AdjPanY)*InvVScale;
					INT XI=appFloor(X);
					INT YI=appFloor(Y);
					BYTE *Src=Surface.LightMap->Mips[0]->DataPtr + (XI + YI * Surface.LightMap->Mips[0]->USize)*4;
					SGLColor VertColor=SGLColor(IntensityAdjustTable[Src[2]],IntensityAdjustTable[Src[1]],IntensityAdjustTable[Src[0]]);
					Vertex->Color	= VertColor.D;
					Vertex->fUOverW	= Vertex->fInvW * ((Vertex->fMasterS) * PolyVTex.UScale - USub);
					Vertex->fVOverW	= Vertex->fInvW * ((Vertex->fMasterT) * PolyVTex.VScale - VSub);
				}
				sgltri_triangles(&SglContext,FaceCount,FaceList,(SGLVERTEX *)Vertices);
				// Put this back in case there are any fog maps.
				SglContext.u32Flags&=~SGLTT_GOURAUD;
			}
		}
		else
		{
			// There is no lightmap, so just render the base.
			sgl_uint32	iBaseColor	=PolyVTex.MaxColor.D;
			// Loop through vertices, updating them.
			int Count;
			for (Vertex=Vertices,Count=VertexCount;Count>0;Count--,Vertex++)
			{
				Vertex->Color	= iBaseColor;
				Vertex->fUOverW	= Vertex->fInvW * ((Vertex->fMasterS) * PolyVTex.UScale - USub);
				Vertex->fVOverW	= Vertex->fInvW * ((Vertex->fMasterT) * PolyVTex.VScale - VSub);
			}
			sgltri_triangles(&SglContext,FaceCount,FaceList,(SGLVERTEX *)Vertices);
		}
	}
	else
	{
		// There is no base texture but we don't support just rendering the light map on its own.
		// Doing so would require another light map conversion routine which did not expect
		// the a base pass which would reduce intensity through vertex lighting.
	}

#ifdef SUPPORT_FOG
	// Fog map.
	if( Surface.FogMap )
	{
		// See if texture has changed.
		if (Surface.FogMap->CacheID!=FogMapTex.CacheID)
		{
			// Texture has changed so set new texture.
			SetTexture(*Surface.FogMap,SF_FogMap,Surface.FogMap->CacheID,FogMapTex);
		}
		// Set the fog map.
		SglContext.nTextureName=FogMapTex.SglTextureName;
		// Loop through vertices, updating them.
		int Count;
		sgl_uint32  iBaseColor  =0xFFFFFFFF;
		FLOAT AdjPanX=Surface.FogMap->Pan.X - 0.5*Surface.FogMap->UScale;
		FLOAT AdjPanY=Surface.FogMap->Pan.Y - 0.5*Surface.FogMap->VScale;
		for (Vertex=Vertices,Count=VertexCount;Count>0;Count--,Vertex++)
		{
			Vertex->Color	= iBaseColor;
			Vertex->fUOverW	= Vertex->fInvW * (Vertex->fMasterS - AdjPanX) * FogMapTex.UScale;
			Vertex->fVOverW	= Vertex->fInvW * (Vertex->fMasterT - AdjPanY) * FogMapTex.VScale;
		}
		sgltri_triangles(&SglContext,FaceCount,FaceList,(SGLVERTEX *)Vertices);
	}
#endif

	Mark.Pop();
	UNCLOCK(Stats.ComplexSurfTime);
	unguard;
}

//*****************************************************************************
// Draw a polygon with texture coordinates.
//*****************************************************************************
void USGLRenderDevice::DrawGouraudPolygon
(
	FSceneNode*		Frame,
	FTextureInfo&	Texture,
	FTransTexture**	Pts,
	INT				NumPts,
	DWORD			PolyFlags,
	FSpanBuffer*	Span
)
{
	guard(USGLRenderDevice::DrawGouraudPolygon);
	CLOCK(Stats.GouraudPolyTime);
	STATS_INC(Stats.GouraudPolys);

	// Mask off stuff we don't care about out of PolyFlags;
	PolyFlags&=SIMPLE_POLYFLAGS_MASK;

	// See if flags or texture has changed, in which case we need to update SGLCONTEXT state.
	if (PolyFlags!=SimplePolyFlags || Texture.CacheID!=SimplePolyTextureCacheID)
	{
		// Render off anything we have.
		FLUSH_SIMPLE_VERTEX_BUFFER_IF_NOT_EMPTY();
		// Handle state change if necessary.
		if (PolyFlags!=SimplePolyFlags)
		{
			// Update state.
			if (PolyFlags & PF_Translucent)
				SglContext.u32Flags|=SGLTT_VERTEXTRANS | SGLTT_GOURAUD, SglContext.u32Flags&=~SGLTT_NEWPASSPERTRI;
			else
				SglContext.u32Flags|=SGLTT_GOURAUD, SglContext.u32Flags&=~(SGLTT_VERTEXTRANS | SGLTT_NEWPASSPERTRI);
			// Select new vertex generation handler.
			if (PolyFlags & PF_Modulated)
				SimplePolyHandler=SIMPLE_HANDLER_MODULATED;
			else if (PolyFlags & PF_Translucent)
				SimplePolyHandler=SIMPLE_HANDLER_TRANSLUCENT;
			else
				SimplePolyHandler=SIMPLE_HANDLER_NORMAL;
#ifdef SUPPORT_FOG
			if ((PolyFlags & (PF_RenderFog|PF_Translucent|PF_Modulated))==PF_RenderFog)
				SimplePolyHandler+=SIMPLE_HANDLER_FOG_OFFSET;
#endif
			// Save new poly flags.
			SimplePolyFlags=PolyFlags;
		}
		// Handle texture change if necessary.
		DWORD TextureFlags=((PolyFlags&PF_Translucent)?SF_AdditiveBlend:0) |
						   ((PolyFlags&PF_Modulated)?SF_ModulationBlend:0) |
						   ((PolyFlags&PF_Masked)?SF_ColorKey:0) |
						   SF_NoScale;
		// See if texture or flags have changed.
		QWORD TestID=Texture.CacheID + (((QWORD)TextureFlags) << TEXTURE_FLAGS_SHIFT);
		if (TestID!=PolyCTex.CacheID)
		{
			// Texture/flags have changed so set new texture/flags.
			SetTexture(Texture,TextureFlags,TestID,PolyCTex);
			// Save new texture CacheID.
			SimplePolyTextureCacheID=Texture.CacheID;
		}
		// Make sure texture name is set in SGLCONTEXT.
		SglContext.nTextureName=PolyCTex.SglTextureName;
	}
	else
	{
		// Make sure vertex buffer has enough room for this polygon.
		if ((SimpleVertexCount+NumPts) > SIMPLE_VERTEX_BUFFER_SIZE)
			FLUSH_SIMPLE_VERTEX_BUFFER()
	}

	// Set the X and Y bias values.
	// On PCX2, the calculations SGL does go to pot when the X/Y values are a tiny
	// bit negative. The values can go a bit negative due to rounding errors in the
	// clipping Unreal does. Adding this small offset fixes the problem (most of the time).
	FLOAT XBias=Frame->XB + 0.1;
	FLOAT YBias=Frame->YB + 0.1;
	FLOAT AdjScaleInvW=ScaleInvW * Frame->RProj.Z;

	INT Count;
	PVERTEX Vertex;
	// Switch to the appropriate handler to generate the vertices.
	switch (SimplePolyHandler)
	{
		case SIMPLE_HANDLER_NORMAL:
			// Normal version.
			for(Count=NumPts,Vertex=SimpleVertexPtr;Count>0;Count--,Vertex++,Pts++)
			{
				FTransTexture* Pt=*Pts;
			
				Vertex->fX	 			= Pt->ScreenX + XBias;
				Vertex->fY	 			= Pt->ScreenY + YBias;
				Vertex->fInvW			= Pt->RZ * AdjScaleInvW;
				INT r					= GammaTable[appRound(Pt->Light.X*255.f)];
				INT g					= GammaTable[appRound(Pt->Light.Y*255.f)];
				INT b					= GammaTable[appRound(Pt->Light.Z*255.f)];
				// On PCX, we must limit the amount of colour in the vertex lighting since we
				// can't do full colour intensity lightmap lighting with the hack.
				INT in					= Max(r,Max(g,b));
				r						= (in+r)>>1;
				g						= (in+g)>>1;
				b						= (in+b)>>1;
				Vertex->u32Colour		= (r << 16) | (g << 8) | b;
				Vertex->fUOverW			= Vertex->fInvW * Pt->U * PolyCTex.UScale;
				Vertex->fVOverW			= Vertex->fInvW * Pt->V * PolyCTex.VScale;
			}
			SimpleVertexPtr=Vertex;
			break;
		case SIMPLE_HANDLER_TRANSLUCENT:
			// Translucent. Handles vertex color differently to normal version.
			for(Count=NumPts,Vertex=SimpleVertexPtr;Count>0;Count--,Vertex++,Pts++)
			{
				FTransTexture* Pt=*Pts;
			
				Vertex->fX	 			= Pt->ScreenX + XBias;
				Vertex->fY	 			= Pt->ScreenY + YBias;
				Vertex->fInvW			= Pt->RZ * AdjScaleInvW;
				INT r					= GammaTable[appRound(Pt->Light.X*255.f)];
				INT g					= GammaTable[appRound(Pt->Light.Y*255.f)];
				INT b					= GammaTable[appRound(Pt->Light.Z*255.f)];
				INT a					= Max(Max(1,r),Max(g,b));
				INT Scale				= 0x100*255/a;
				r						=(r*Scale)&0xFF00;
				g						=(g*Scale)&0xFF00;
				b						=(b*Scale);
				a+=256;	// Stop alpha going below 128.
				Vertex->u32Colour		= (r << 8) | (g) | (b>>8) | (a << 23);
				Vertex->fUOverW			= Vertex->fInvW * Pt->U * PolyCTex.UScale;
				Vertex->fVOverW			= Vertex->fInvW * Pt->V * PolyCTex.VScale;
			}
			SimpleVertexPtr=Vertex;
			break;
		case SIMPLE_HANDLER_MODULATED:
			// Modulation blend. Color always 0xFFFFFFFF
			for(Count=NumPts,Vertex=SimpleVertexPtr;Count>0;Count--,Vertex++,Pts++)
			{
				FTransTexture* Pt=*Pts;
			
				Vertex->fX	 			= Pt->ScreenX + XBias;
				Vertex->fY	 			= Pt->ScreenY + YBias;
				Vertex->fInvW			= Pt->RZ * AdjScaleInvW;
				Vertex->u32Colour		= 0xFFFFFFFF;
				Vertex->fUOverW			= Vertex->fInvW * Pt->U * PolyCTex.UScale;
				Vertex->fVOverW			= Vertex->fInvW * Pt->V * PolyCTex.VScale;
			}
			SimpleVertexPtr=Vertex;
			break;
		case SIMPLE_HANDLER_NORMAL_FOG:
			// Normal version w/ fog.
			for(Count=NumPts,Vertex=SimpleVertexPtr;Count>0;Count--,Vertex++,Pts++)
			{
				FTransTexture* Pt=*Pts;
			
				Vertex->fX	 			= Pt->ScreenX + XBias;
				Vertex->fY	 			= Pt->ScreenY + YBias;
				Vertex->fInvW			= Pt->RZ * AdjScaleInvW;
				INT r					= GammaTable[appRound(Pt->Light.X*255.f)];
				INT g					= GammaTable[appRound(Pt->Light.Y*255.f)];
				INT b					= GammaTable[appRound(Pt->Light.Z*255.f)];
				// On PCX, we must limit the amount of colour in the vertex lighting since we
				// can't do full colour intensity lightmap lighting with the hack.
				INT in					= Max(r,Max(g,b));
				r						= (in+r)>>1;
				g						= (in+g)>>1;
				b						= (in+b)>>1;
				Vertex->u32Colour		= (r << 16) | (g << 8) | b;
				// Calculate fog color value.
				r						= appRound(Pt->Fog.X*255.f);
				g						= appRound(Pt->Fog.Y*255.f);
				b						= appRound(Pt->Fog.Z*255.f);
				INT	a					= Max(r,Max(g,b));
				INT i					= Max(1,a);
				INT Scale				= 0x100*255/i;
				r						= (r*Scale)&0xFF00;
				g						= (g*Scale)&0xFF00;
				b						= (b*Scale);
				a						= Min(255,a+12);
				Vertex->u32Specular		= (r << 8) | (g) | (b>>8) | (a << 24);
				Vertex->fUOverW			= Vertex->fInvW * Pt->U * PolyCTex.UScale;
				Vertex->fVOverW			= Vertex->fInvW * Pt->V * PolyCTex.VScale;
			}
			SimpleVertexPtr=Vertex;
			break;
		case SIMPLE_HANDLER_TRANSLUCENT_FOG:
			// Translucent w/ fog. Handles vertex color differently to normal version.
			for(Count=NumPts,Vertex=SimpleVertexPtr;Count>0;Count--,Vertex++,Pts++)
			{
				FTransTexture* Pt=*Pts;
			
				Vertex->fX	 			= Pt->ScreenX + XBias;
				Vertex->fY	 			= Pt->ScreenY + YBias;
				Vertex->fInvW			= Pt->RZ * AdjScaleInvW;
				INT r					= GammaTable[appRound(Pt->Light.X*255.f)];
				INT g					= GammaTable[appRound(Pt->Light.Y*255.f)];
				INT b					= GammaTable[appRound(Pt->Light.Z*255.f)];
				INT a					= Max(Max(1,r),Max(g,b));
				INT Scale=0x100*255/a;
				r*=Scale;
				g*=Scale;
				b*=Scale;
				a+=256;	// Stop alpha going below 128.
				Vertex->u32Colour		= (r << 8) | (g) | (b>>8) | (a << 23);
				// Calculate fog color value.
				r						= appRound(Pt->Fog.X*255.f);
				g						= appRound(Pt->Fog.Y*255.f);
				b						= appRound(Pt->Fog.Z*255.f);
				a						= Max(r,Max(g,b));
				INT i					= Max(1,a);
				Scale					= 0x100*255/i;
				r						= (r*Scale)&0xFF00;
				g						= (g*Scale)&0xFF00;
				b						= (b*Scale);
				a						= Min(255,a+12);
				Vertex->u32Specular		= (r << 8) | (g) | (b>>8) | (a << 24);
				Vertex->fUOverW			= Vertex->fInvW * Pt->U * PolyCTex.UScale;
				Vertex->fVOverW			= Vertex->fInvW * Pt->V * PolyCTex.VScale;
			}
			SimpleVertexPtr=Vertex;
			break;
		case SIMPLE_HANDLER_MODULATED_FOG:
			// Modulation blend w/ fog. Color always 0xFFFFFFFF
			for(Count=NumPts,Vertex=SimpleVertexPtr;Count>0;Count--,Vertex++,Pts++)
			{
				FTransTexture* Pt=*Pts;
			
				Vertex->fX	 			= Pt->ScreenX + XBias;
				Vertex->fY	 			= Pt->ScreenY + YBias;
				Vertex->fInvW			= Pt->RZ * AdjScaleInvW;
				Vertex->u32Colour		= 0xFFFFFFFF;
				// Calculate fog color value.
				INT r					= appRound(Pt->Fog.X*255.f);
				INT g					= appRound(Pt->Fog.Y*255.f);
				INT b					= appRound(Pt->Fog.Z*255.f);
				INT	a					= Max(r,Max(g,b));
				INT i					= Max(1,a);
				INT Scale				= 0x100*255/i;
				r						= (r*Scale)&0xFF00;
				g						= (g*Scale)&0xFF00;
				b						= (b*Scale);
				a						= Min(255,a+12);
				Vertex->u32Specular		= (r << 8) | (g) | (b>>8) | (a << 24);
				Vertex->fUOverW			= Vertex->fInvW * Pt->U * PolyCTex.UScale;
				Vertex->fVOverW			= Vertex->fInvW * Pt->V * PolyCTex.VScale;
			}
			SimpleVertexPtr=Vertex;
			break;
	}
	// Add faces.
	int i,(*Face)[3],BaseIndex;
	for (i=2,Face=SimpleFacePtr,BaseIndex=SimpleVertexCount;i<NumPts;i++,Face++)
	{
		(*Face)[0]=BaseIndex;
		(*Face)[1]=BaseIndex+i-1;
		(*Face)[2]=BaseIndex+i;
	}
	SimpleVertexCount=BaseIndex+NumPts;
	SimpleFaceCount+=NumPts-2;
	SimpleFacePtr=Face;

	UNCLOCK(Stats.GouraudPolyTime);
	unguard;
}


//*****************************************************************************
//	Textured tiles.
//*****************************************************************************
void USGLRenderDevice::DrawTile( FSceneNode* Frame, FTextureInfo& Texture, FLOAT X, FLOAT Y, FLOAT XL, FLOAT YL, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL, class FSpanBuffer* Span, FLOAT Z, FPlane Color, FPlane Fog, DWORD PolyFlags )
{
	guard(USGLRenderDevice::DrawTile);

	CLOCK(Stats.TileTime);
	STATS_INC(Stats.Tiles);

	// Mask off stuff we don't care about out of PolyFlags;
	PolyFlags&=SIMPLE_POLYFLAGS_MASK;
	PolyFlags|=PF_Flat;

	// See if flags or texture has changed, in which case we need to update SGLCONTEXT state.
	if (PolyFlags!=SimplePolyFlags || Texture.CacheID!=SimplePolyTextureCacheID)
	{
		// Render off anything we have.
		FLUSH_SIMPLE_VERTEX_BUFFER_IF_NOT_EMPTY();
		// Handle state change if necessary.
		if (PolyFlags!=SimplePolyFlags)
		{
			// Update state.
			if (PolyFlags & PF_Translucent)
				SglContext.u32Flags|=(SGLTT_VERTEXTRANS | SGLTT_NEWPASSPERTRI), SglContext.u32Flags&=~SGLTT_GOURAUD;
			else
				SglContext.u32Flags&=~(SGLTT_VERTEXTRANS | SGLTT_GOURAUD | SGLTT_NEWPASSPERTRI);
			// Select new color generation handler.
			if (PolyFlags & PF_Modulated)
				SimplePolyHandler=SIMPLE_HANDLER_MODULATED;
			else if (PolyFlags & PF_Translucent)
				SimplePolyHandler=SIMPLE_HANDLER_TRANSLUCENT;
			else
				SimplePolyHandler=SIMPLE_HANDLER_NORMAL;
#ifdef SUPPORT_FOG
			if (PolyFlags & PF_RenderFog)
				SimplePolyHandler+=SIMPLE_HANDLER_FOG_OFFSET;
#endif
			// Save new poly flags.
			SimplePolyFlags=PolyFlags;
		}
		// Handle texture change if necessary.
		DWORD TextureFlags=((PolyFlags&PF_Translucent)?SF_AdditiveBlend:0) |
						   ((PolyFlags&PF_Modulated)?SF_ModulationBlend:0) |
						   ((PolyFlags&PF_Masked)?SF_ColorKey:0) |
						   SF_NoScale;
		// See if texture or flags have changed.
		QWORD TestID=Texture.CacheID + (((QWORD)TextureFlags) << TEXTURE_FLAGS_SHIFT);
		if (TestID!=PolyCTex.CacheID)
		{
			// Texture/flags have changed so set new texture/flags.
			SetTexture(Texture,TextureFlags,TestID,PolyCTex);
			// Save new texture CacheID.
			SimplePolyTextureCacheID=Texture.CacheID;
		}
		// Make sure texture name is set in SGLCONTEXT.
		SglContext.nTextureName=PolyCTex.SglTextureName;
	}
	else
	{
		// Make sure vertex buffer has enough room for this polygon.
		if (SimpleVertexCount >= (SIMPLE_VERTEX_BUFFER_SIZE-4))
			FLUSH_SIMPLE_VERTEX_BUFFER()
	}

	// Calculate base and fog colors.
	FColor BaseColor = FColor(Color);
	int iColor=0xFFFFFFF;
	int iFog=0;
	switch (SimplePolyHandler)
	{
		case SIMPLE_HANDLER_NORMAL:
			{
				// Calculate base color value.
				INT r					= GammaTable[BaseColor.R];
				INT g					= GammaTable[BaseColor.G];
				INT b					= GammaTable[BaseColor.B];
				// On PCX, we must limit the amount of colour in the vertex lighting since we
				// can't do full colour intensity lightmap lighting with the hack.
				INT in					= Max(r,Max(g,b));
				r						= (in+r)>>1;
				g						= (in+g)>>1;
				b						= (in+b)>>1;
				iColor					= (r << 16) | (g << 8) | b;
			}
			break;
		case SIMPLE_HANDLER_TRANSLUCENT:
			{
				// Calculate base color value.
				INT r					= GammaTable[BaseColor.R];
				INT g					= GammaTable[BaseColor.G];
				INT b					= GammaTable[BaseColor.B];
				INT a					= Max(Max(1,r),Max(g,b));
				INT Scale				= 0x100*255/a;
				r						=(r*Scale)&0xFF00;
				g						=(g*Scale)&0xFF00;
				b						=(b*Scale);
				a+=256;	// Stop alpha going below 128.
				iColor					= (r << 8) | (g) | (b>>8) | (a << 23);
			}
			break;
		case SIMPLE_HANDLER_MODULATED:
			// Nothing to do. Defaults are ok.
			break;
		case SIMPLE_HANDLER_NORMAL_FOG:
			{
				// Calculate base color value.
				INT r					= GammaTable[BaseColor.R];
				INT g					= GammaTable[BaseColor.G];
				INT b					= GammaTable[BaseColor.B];
				// On PCX, we must limit the amount of colour in the vertex lighting since we
				// can't do full colour intensity lightmap lighting with the hack.
				INT in					= Max(r,Max(g,b));
				r						= (in+r)>>1;
				g						= (in+g)>>1;
				b						= (in+b)>>1;
				iColor					= (r << 16) | (g << 8) | b;
				// Calculate fog color value.
				r						= appRound(Fog.X*255.f);
				g						= appRound(Fog.Y*255.f);
				b						= appRound(Fog.Z*255.f);
				INT	a					= Max(r,Max(g,b));
				INT i					= Max(1,a);
				INT Scale				= 0x100*255/i;
				r						= (r*Scale)&0xFF00;
				g						= (g*Scale)&0xFF00;
				b						= (b*Scale);
				a						= Min(255,a+12);
				iFog					= (r << 8) | (g) | (b>>8) | (a << 24);
			}
			break;
		case SIMPLE_HANDLER_TRANSLUCENT_FOG:
			{
				// Calculate base color value.
				INT r					= GammaTable[BaseColor.R];
				INT g					= GammaTable[BaseColor.G];
				INT b					= GammaTable[BaseColor.B];
				INT a					= Max(Max(1,r),Max(g,b));
				INT Scale				= 0x100*255/a;
				r						=(r*Scale)&0xFF00;
				g						=(g*Scale)&0xFF00;
				b						=(b*Scale);
				a+=256;	// Stop alpha going below 128.
				iColor					= (r << 8) | (g) | (b>>8) | (a << 23);
				// Calculate fog color value.
				r						= appRound(Fog.X*255.f);
				g						= appRound(Fog.Y*255.f);
				b						= appRound(Fog.Z*255.f);
				a						= Max(r,Max(g,b));
				INT i					= Max(1,a);
				Scale					= 0x100*255/i;
				r						= (r*Scale)&0xFF00;
				g						= (g*Scale)&0xFF00;
				b						= (b*Scale);
				a						= Min(255,a+12);
				iFog					= (r << 8) | (g) | (b>>8) | (a << 24);
			}
			break;
		case SIMPLE_HANDLER_MODULATED_FOG:
			{
				// Calculate fog color value.
				INT r					= appRound(Fog.X*255.f);
				INT g					= appRound(Fog.Y*255.f);
				INT b					= appRound(Fog.Z*255.f);
				INT	a					= Max(r,Max(g,b));
				INT i					= Max(1,a);
				INT Scale				= 0x100*255/i;
				r						= (r*Scale)&0xFF00;
				g						= (g*Scale)&0xFF00;
				b						= (b*Scale);
				a						= Min(255,a+12);
				iFog					= (r << 8) | (g) | (b>>8) | (a << 24);
			}
			break;
	}

	// Add verts.
	FLOAT	X1		= X + Frame->XB + 0.5;
	FLOAT	X2		= X1+ XL;
	FLOAT	Y1		= Y + Frame->YB + 0.5;
	FLOAT	Y2		= Y1+ YL;
	FLOAT	RZ;
	if (Z==1.0f)
	{
		RZ = NoZInvW * ScaleInvW;
		NoZInvW*=UNSGL_Z_STEP;
	}
	else
	{
		RZ = 1.0/Z * ScaleInvW;
	}
	FLOAT	RZUS	= RZ*PolyCTex.UScale;
	FLOAT	U1		= (U   )*RZUS;
	FLOAT	U2		= (U+UL)*RZUS;
	FLOAT	RZVS	= RZ*PolyCTex.VScale;
	FLOAT	V1		= (V   )*RZVS;
	FLOAT	V2		= (V+VL)*RZVS;

	if (PolyFlags & PF_NoSmooth)
	{
		FLOAT HalfOffset=RZ*0.5f/(float)PolyCTex.Dimensions;
		U1-=HalfOffset;
		U2-=HalfOffset;
		V1-=HalfOffset;
		V2-=HalfOffset;
	}
	PVERTEX V=SimpleVertexPtr;
	V[0].fX=X1; V[0].fY=Y1; V[0].fInvW=RZ; V[0].u32Colour=iColor; V[0].u32Specular=iFog; V[0].fU=U1; V[0].fV=V1;
	V[1].fX=X1; V[1].fY=Y2; V[1].fInvW=RZ; V[1].u32Colour=iColor; V[1].u32Specular=iFog; V[1].fU=U1; V[1].fV=V2;
	V[2].fX=X2; V[2].fY=Y2; V[2].fInvW=RZ; V[2].u32Colour=iColor; V[2].u32Specular=iFog; V[2].fU=U2; V[2].fV=V2;
	V[3].fX=X2; V[3].fY=Y1; V[3].fInvW=RZ; V[3].u32Colour=iColor; V[3].u32Specular=iFog; V[3].fU=U2; V[3].fV=V1;
	SimpleVertexPtr=V+4;

	// Generate faces
	int (*Face)[4],Index;
	Face=SimpleQuadFacePtr;
	Index=SimpleVertexCount;
	(*Face)[0]=Index;
	(*Face)[1]=Index+1;
	(*Face)[2]=Index+2;
	(*Face)[3]=Index+3;
	SimpleVertexCount=Index+4;
	SimpleFaceCount++;
	SimpleQuadFacePtr=Face+1;

	// Unlock.
	UNCLOCK(Stats.TileTime);

	unguard;
}
