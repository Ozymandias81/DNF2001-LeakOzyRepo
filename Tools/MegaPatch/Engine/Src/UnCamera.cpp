/*=============================================================================
	UnViewport.cpp: Generic Unreal viewport code
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	URenderDevice.
-----------------------------------------------------------------------------*/


//
// Init URenderDevice class.
//
void URenderDevice::StaticConstructor()
{
	new(GetClass(),TEXT("VolumetricLighting"),RF_Public)UBoolProperty(CPP_PROPERTY(VolumetricLighting), TEXT("Client"), CPF_Config );
	new(GetClass(),TEXT("ShinySurfaces"),     RF_Public)UBoolProperty(CPP_PROPERTY(ShinySurfaces     ), TEXT("Client"), CPF_Config );
	new(GetClass(),TEXT("Coronas"),           RF_Public)UBoolProperty(CPP_PROPERTY(Coronas           ), TEXT("Client"), CPF_Config );
	new(GetClass(),TEXT("HighDetailActors"),  RF_Public)UBoolProperty(CPP_PROPERTY(HighDetailActors  ), TEXT("Client"), CPF_Config );
	new(GetClass(),TEXT("Description"),       RF_Public)UStrProperty(CPP_PROPERTY(Description        ), TEXT("Client"), CPF_Config );
	new(GetClass(),TEXT("DescFlags"),         RF_Public)UIntProperty(CPP_PROPERTY(DescFlags          ), TEXT("Client"), CPF_Config );
	new(GetClass(),TEXT("DetailTextures"),    RF_Public)UBoolProperty(CPP_PROPERTY(DetailTextures     ), TEXT("Client"), CPF_Config );

	DecompFormat = TEXF_P8;
}

#if 1
void URenderDevice::Draw2DClippedLine
(
	FSceneNode*		Frame,
	FPlane			Color,
	DWORD			LineFlags,
	FVector			P1,
	FVector			P2
)
{
	// X clip it.
	if( P1.X > P2.X )
		Exchange( P1, P2 );
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

	// Y clip it.
	if( P1.Y > P2.Y )
		Exchange( P1, P2 );
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

	// Assure no coordinates are out of bounds. 
	ClipFloatFromZero(P1.X,Frame->FX);
	ClipFloatFromZero(P2.X,Frame->FX);
	ClipFloatFromZero(P1.Y,Frame->FY);
	ClipFloatFromZero(P2.Y,Frame->FY);

	// Draw it.
	Draw2DLine( Frame, Color, LineFlags, P1, P2 );
}

#else
//
// Draw a clipped 2D line.
//
void URenderDevice::Draw2DClippedLine
(
	FSceneNode*		Frame,
	FPlane			Color,
	DWORD			LineFlags,
	FVector			P1,
	FVector			P2
)
{
	// X clip it.
	if( P1.X > P2.X )
		Exchange( P1, P2 );
	if( P2.X<0 || P1.X>Frame->FX )
		return;
	if( P1.X<0 )
	{
		if( Abs(P2.X-P1.X)<0.001f )
			return;
		P1.Y += (0-P1.X)*(P2.Y-P1.Y)/(P2.X-P1.X);
		P1.X  = 0;
	}
	if( P2.X>=Frame->FX )
	{
		if( Abs(P2.X-P1.X)<0.001f )
			return;
		P2.Y += ((Frame->FX-1.f)-P2.X)*(P2.Y-P1.Y)/(P2.X-P1.X);
		P2.X  = Frame->FX-1.f;
	}

	// Y clip it.
	if( P1.Y > P2.Y )
		Exchange( P1, P2 );
	if( P2.Y < 0 || P1.Y > Frame->FY )
		return;
	if( P1.Y < 0 )
	{
		if( Abs(P2.Y-P1.Y)<0.001f )
			return;
		P1.X += (0-P1.Y)*(P2.X-P1.X)/(P2.Y-P1.Y);
		P1.Y  = 0;
	}
	if( P2.Y >= Frame->FY )
	{
		if( Abs(P2.Y-P1.Y)<0.001f )
			return;
		P2.X += ((Frame->FY-1.f)-P2.Y)*(P2.X-P1.X)/(P2.Y-P1.Y);
		P2.Y  = Frame->FY-1.f;
	}

	// Assure no coordinates are out of bounds. 
	ClipFloatFromZero(P1.X,Frame->FX);
	ClipFloatFromZero(P2.X,Frame->FX);
	ClipFloatFromZero(P1.Y,Frame->FY);
	ClipFloatFromZero(P2.Y,Frame->FY);

	// Draw it.
	Draw2DLine( Frame, Color, LineFlags, P1, P2 );
}
#endif

UBOOL URenderDevice::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	if( ParseCommand(&Cmd,TEXT("GetDetailTextures")) )
	{
		Ar.Logf( TEXT("%i"), DetailTextures );
		return 1;
	} 
	else if( ParseCommand(&Cmd,TEXT("ToggleDetailTextures")) )
	{
		DetailTextures ^= 1;
		SaveConfig();
		return 1;
	}
	else
		return 0;
}

//
// Draw a clipped 3D line.
//
void URenderDevice::Draw3DLine
(
	FSceneNode*		Frame,
	FPlane			Color,
	DWORD			LineFlags,
	FVector			P1,
	FVector			P2
)
{
	#define LINE_NEAR_CLIP_Z 1.f

	FLOAT SX2 = Frame->FX2;
	FLOAT SY2 = Frame->FY2;

	// Transform.
	P1 = P1.TransformPointBy( Frame->Coords );
	P2 = P2.TransformPointBy( Frame->Coords );
	if( Frame->Viewport->IsOrtho() )
	{
		// Zoom.
		P1 = P1 / Frame->Zoom + FVector( SX2, SY2, 0 );
		P2 = P2 / Frame->Zoom + FVector( SX2, SY2, 0 );

		// See if points form a line parallel to our line of sight (i.e. line appears as a dot).
		if( Abs(P2.X-P1.X)+Abs(P1.Y-P2.Y)<0.2f )
		{
			// Line is visible as a point.
			if( Frame->Viewport->Actor->OrthoZoom < ORTHO_LOW_DETAIL )
				Draw2DPoint( Frame, Color, LINE_None, P1.X-1, P1.Y-1, P1.X+1, P1.Y+1, 1.0 );
			return;
		}
	}
	else
	{
		// Calculate delta, discard line if points are identical.
		FVector D = P2-P1;
		if( D.SizeSquared() < Square(0.01f) )
			return;

		// Clip to near clipping plane.
		if( P1.Z <= LINE_NEAR_CLIP_Z )
		{
			// Clip P1 to NCP.
			if( P2.Z<(LINE_NEAR_CLIP_Z-0.01f) )
				return;
			P1.X +=  (LINE_NEAR_CLIP_Z-P1.Z) * D.X/D.Z;
			P1.Y +=  (LINE_NEAR_CLIP_Z-P1.Z) * D.Y/D.Z;
			P1.Z  =  (LINE_NEAR_CLIP_Z);
		}
		else if( P2.Z<(LINE_NEAR_CLIP_Z-0.01f) )
		{
			// Clip P2 to NCP.
			P2.X += (LINE_NEAR_CLIP_Z-P2.Z) * D.X/D.Z;
			P2.Y += (LINE_NEAR_CLIP_Z-P2.Z) * D.Y/D.Z;
			P2.Z =  (LINE_NEAR_CLIP_Z);
		}

		// Calculate perspective.
		P1.Z = 1.f/P1.Z; P1.X = P1.X * Frame->Proj.Z * P1.Z + SX2; P1.Y = P1.Y * Frame->Proj.Z * P1.Z + SY2;
		P2.Z = 1.f/P2.Z; P2.X = P2.X * Frame->Proj.Z * P2.Z + SX2; P2.Y = P2.Y * Frame->Proj.Z * P2.Z + SY2;
	}

	// Clip it and draw it.
	Draw2DClippedLine( Frame, Color, LineFlags, P1, P2 );
}

/*-----------------------------------------------------------------------------
	UViewport object implementation.
-----------------------------------------------------------------------------*/
void UViewport::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << Console << MiscRes << Canvas << RenDev << Input;
}

IMPLEMENT_CLASS(UViewport);

/*-----------------------------------------------------------------------------
	Dragging.
-----------------------------------------------------------------------------*/

//
// Set mouse dragging.
// The mouse is dragging when and only when one or more button is held down.
//
UBOOL UViewport::SetDrag( UBOOL NewDrag )
{
	UBOOL Result = Dragging;
	Dragging = NewDrag;
	if( GIsRunning )
	{
		if( Dragging && !Result )
		{
			// First hit.
			GetOuterUClient()->Engine->MouseDelta( this, MOUSE_FirstHit, 0, 0 );
		}
		else if( Result && !Dragging )
		{
			// Last release.
			GetOuterUClient()->Engine->MouseDelta( this, MOUSE_LastRelease, 0, 0 );
		}
	}
	return Result;
}

/*-----------------------------------------------------------------------------
	Scene frames.
-----------------------------------------------------------------------------*/

//
// Precompute rendering info.
//
void FSceneNode::ComputeRenderCoords( FVector& Location, FRotator& Rotation )
{
	check(Viewport->Actor);
	Coords =
	(	Viewport->Actor->RendMap==REN_OrthXY ? FCoords(FVector(0,0,0),FVector(+1,0,0),FVector(0,+1,0),FVector(0,0,+1))
	:	Viewport->Actor->RendMap==REN_OrthXZ ? FCoords(FVector(0,0,0),FVector(+1,0,0),FVector(0,0,-1),FVector(0,+1,0))
	:	Viewport->Actor->RendMap==REN_OrthYZ ? FCoords(FVector(0,0,0),FVector(0,+1,0),FVector(0,0,-1),FVector(+1,0,0))
	:								           GMath.ViewCoords / Rotation) / Location;
	Uncoords = Coords.Transpose();
	ComputeRenderSize();
}

//
// Precompute sizing info.
//
void FSceneNode::ComputeRenderSize()
{
	check(Viewport&&Viewport->RenDev);

	// Compute Hor+ FOV.
	FLOAT Ratio = (Viewport->SizeX / (FLOAT)Viewport->SizeY) / (4 / 3.f);
	FLOAT Fov   = (180.f / PI) * 2 * appAtan(appTan((Viewport->Actor->FovAngle * PI / 180.f) / 2) * Ratio);

	// Precomputes.
	FX 			= (FLOAT)X;
	FY 			= (FLOAT)Y;
	FX2			= FX * 0.5f;
	FY2			= FY * 0.5f;	
	FX15		= (FX+1.0001f) * 0.5f;
	FY15		= (FY+1.0001f) * 0.5f;	
	Proj		= FVector( 0.5f-0.5f*FX, 0.5f-0.5f*FY, 0.5f*FX / appTan(Fov * PI/360.f) );
	RProj		= FVector( 1/Proj.X, 1/Proj.Y, 1/Proj.Z );
	Zoom 		= Viewport->Actor->OrthoZoom / (FX * 15.f);
	PrjXM		= (0  - FX2)*(-RProj.Z);
	PrjXP		= (FX - FX2)*(+RProj.Z);
	PrjYM		= (0  - FY2)*(-RProj.Z);
	PrjYP		= (FY - FY2)*(+RProj.Z);

	// Precompute side info.
	FLOAT TempSigns[2]={-1.f,+1.f};
	for( INT i=0; i<2; i++ )
	{
		for( INT j=0; j<2; j++ )
		{
			ViewSides[i*2+j] = FVector(TempSigns[i] * FX2, TempSigns[j] * FY2, Proj.Z).UnsafeNormal().TransformVectorBy(Uncoords);
		}
		ViewPlanes[i] = FPlane
		(
			Coords.Origin,
			FVector(0,TempSigns[i] / FY2,1.f/Proj.Z).UnsafeNormal().TransformVectorBy(Uncoords)
		);
		ViewPlanes[i+2] = FPlane
		(
			Coords.Origin,
			FVector(TempSigns[i] / FX2,0,1.f/Proj.Z).UnsafeNormal().TransformVectorBy(Uncoords)
		);
	}

	// Tell rendering device.
	Viewport->RenDev->SetSceneNode( this );
}

/*-----------------------------------------------------------------------------
	Custom viewport creation and destruction.
-----------------------------------------------------------------------------*/

// UViewport constructor.  Creates the viewport object but doesn't open its window.
UViewport::UViewport()
{
	// Update viewport array.
	GetOuterUClient()->Viewports.AddItem( this );

	// Create canvas.
	UClass* CanvasClass = StaticLoadClass( UCanvas::StaticClass(), NULL, TEXT("ini:Engine.Engine.Canvas"), NULL, LOAD_NoFail, NULL );
	Canvas = CastChecked<UCanvas>(StaticConstructObject( CanvasClass ));
	Canvas->Init( this );

	// Create input system.
	UClass* InputClass = StaticLoadClass( UInput::StaticClass(), NULL, TEXT("ini:Engine.Engine.Input"), NULL, LOAD_NoFail, NULL );
	Input = (UInput*)StaticConstructObject( InputClass );

	// Set initial time.
	LastUpdateTime = appSeconds();
}

//
// Close a viewport.
//warning: Lots of interrelated stuff is happening here between the viewport code,
// object code, platform-specific viewport manager code, and Windows.
//
void UViewport::Destroy()
{
	// Temporary for editor!!
	if( GetOuterUClient()->Engine->Audio && GetOuterUClient()->Engine->Audio->GetViewport()==this )
		GetOuterUClient()->Engine->Audio->SetViewport( NULL );

	// Close the viewport window.
	CloseWindow();

	// Delete the input subsystem.
	if(Input) { delete Input; Input=NULL; }

	// Delete the console.
	if(Console) { delete Console; Console=NULL; }

	// Delete the canvas.
	if(Canvas) { Canvas->Shutdown(); delete Canvas; Canvas=NULL; }

	// Shut down rendering.
	if( RenDev )
	{
		RenDev->Exit();
		delete RenDev; RenDev=NULL;
	}

	// Remove from viewport list.
	GetOuterUClient()->Viewports.RemoveItem( this );

	Super::Destroy();
}

/*---------------------------------------------------------------------------------------
	Viewport information functions.
---------------------------------------------------------------------------------------*/

//
// Is this camrea a wireframe view?
//
UBOOL UViewport::IsWire()
{
	return
	Actor &&
	(	Actor->GetLevel()->Model->Nodes.Num()==0
	||	Actor->RendMap==REN_OrthXY
	||	Actor->RendMap==REN_OrthXZ
	||	Actor->RendMap==REN_OrthYZ
	||	Actor->RendMap==REN_Wire );
}

UBOOL UViewport::IsTopView()
{
	return Actor &&	(Actor->RendMap==REN_OrthXY||Actor->RendMap==REN_OrthXZ||Actor->RendMap==REN_OrthYZ);
}

AActor* UViewport::GetPortalView( FName& PortalName )
{
	ULevel* CurrentLevel = Actor->GetLevel();

	AActor** FoundActor = CurrentLevel->PortalViewMap.Find( PortalName );
	if (FoundActor != NULL)
		return *FoundActor;

	INT MaxActors = CurrentLevel->Actors.Num();
	for ( INT i=0; i<MaxActors; i++ )
	{
		AActor* TestActor = CurrentLevel->Actors(i);
		if ( TestActor && TestActor->Tag == PortalName )
		{
			TestActor->bPortalView = true;
			TestActor->PortalViewName = PortalName;
			CurrentLevel->PortalViewMap.Set( PortalName, TestActor );
			return TestActor;
		}
	}
	return NULL;
}

/*-----------------------------------------------------------------------------
	Viewport locking & unlocking.
-----------------------------------------------------------------------------*/

//
// Lock the viewport for rendering.
//
//UBOOL UViewport::Lock( FPlane FlashScale, FPlane FlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* HitData, INT* HitSize )
UBOOL UViewport::Lock( FColor FogColor, float FogDensity, INT FogDistance, FPlane FlashScale, FPlane FlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* HitData, INT* HitSize )
{
	check(this);
	check(RenDev);

	// Set info.
	CurrentTime = appSeconds();
	HitTesting = HitData!=NULL;
	RenderFlags = RenderLockFlags;
	ExtraPolyFlags = ((Actor->RendMap==REN_PolyCuts) || (Actor->RendMap==REN_Zones)) ? PF_NoMerge : 0;
	FrameCount++;

	// Lock rendering device.
	RenDev->Lock( FogColor, FogDensity, FogDistance, FlashScale, FlashFog, ScreenClear, RenderLockFlags, HitData, HitSize );

	// Successfully locked it.
	return 1;
}

//
// Unlock the viewport.
//
void UViewport::Unlock( UBOOL Blit )
{
	check(this);
	check(RenDev);
	// Unlock rendering device.
	RenDev->Unlock( Blit );

	// Update time.
	if( Blit )
		LastUpdateTime = CurrentTime;
}

/*-----------------------------------------------------------------------------
	Command line.
-----------------------------------------------------------------------------*/

//
// UViewport command line.
//

UBOOL UViewport::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	check(Actor);
	if( Input && Input->Exec(Cmd,Ar) )
	{
		return 1;
	}
	else if( RenDev && RenDev->Exec(Cmd,Ar) )
	{
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GETPING")) )
	{
		Ar.Logf( TEXT("0") );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("INJECT")) )
	{
		UNetDriver* Driver = Actor->GetLevel()->NetDriver;
		if( Driver && Driver->ServerConnection )
		{
			Ar.Logf(TEXT("Injecting: %s"),Cmd);
			Driver->ServerConnection->Logf( Cmd );
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("NETSPEED")) )
	{
		INT Rate = appAtoi(Cmd);
		UNetDriver* Driver = Actor->GetLevel()->NetDriver;
		GetDefault<UPlayer>()->ConfiguredInternetSpeed = Rate;
		GetDefault<UPlayer>()->SaveConfig();
		if( Rate>=500 && Driver && Driver->ServerConnection )
		{
			if( !Driver->ServerConnection->URL.HasOption(TEXT("LAN")) )
			{
				CurrentNetSpeed = Driver->ServerConnection->CurrentNetSpeed = Clamp( Rate, 500, Driver->MaxClientRate );
				Driver->ServerConnection->Logf( TEXT("NETSPEED %i"), Rate );
			}
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("LANSPEED")) )
	{
		INT Rate = appAtoi(Cmd);
		UNetDriver* Driver = Actor->GetLevel()->NetDriver;
		GetDefault<UPlayer>()->ConfiguredInternetSpeed = Rate;
		GetDefault<UPlayer>()->SaveConfig();
		if( Rate>=500 && Driver && Driver->ServerConnection )
		{
			if( Driver->ServerConnection->URL.HasOption(TEXT("LAN")) )
			{
				CurrentNetSpeed = Driver->ServerConnection->CurrentNetSpeed = Clamp( Rate, 500, Driver->MaxClientRate );
				Driver->ServerConnection->Logf( TEXT("NETSPEED %i"), Rate );
			}
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("SHOWALL")) )
	{
		for( INT i=0; i<Actor->GetLevel()->Actors.Num(); i++ )
			if( Actor->GetLevel()->Actors(i) )
				Actor->GetLevel()->Actors(i)->bHidden = 0;
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("REPORT")) )
	{
		FStringOutputDevice Str;
		Str.Log ( TEXT("Report:\r\n") );
		Str.Logf( TEXT("   Version: %s %s\r\n"), appFromAnsi(__DATE__), appFromAnsi(__TIME__) );
		Str.Logf( TEXT("   Player class: %s\r\n"), Actor->GetClass()->GetName() );
		Str.Logf( TEXT("   URL: %s\r\n"), *Actor->GetLevel()->URL.String() );
		Str.Logf( TEXT("   Location: %i %i %i\r\n"), (INT)Actor->Location.X, (INT)Actor->Location.Y, (INT)Actor->Location.Z );
		if( Actor->Level->Game==NULL )
		{
			Str.Logf( TEXT("   Network client\r\n") );
		}
		else
		{
			Str.Logf( TEXT("   Game class: %s\r\n"), Actor->Level->Game->GetClass()->GetName() );
			Str.Logf( TEXT("   Difficulty: %i\r\n"), Actor->Level->Game->Difficulty );
		}
		appClipboardCopy( *Str );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("SHOT")) )
	{
		// Screenshot.
		TCHAR File[32];
		for( INT i=0; i<256; i++ )
		{
			appSprintf( File, TEXT("Shot%04i.bmp"), i );
			if( GFileManager->FileSize(File) < 0 )
				break;
		}
		if( GFileManager->FileSize(File)<0 )
		{
			FMemMark Mark(GMem);
			FColor* Buf = new(GMem,SizeX*SizeY)FColor;
			RenDev->ReadPixels( Buf );

			FArchive* Ar = GFileManager->CreateFileWriter( File );
			if( Ar )
			{
				// Types.
				#if _MSC_VER
					#pragma pack (push,1)
				#endif
				struct BITMAPFILEHEADER
				{
					_WORD   bfType GCC_PACK(1);
					DWORD   bfSize GCC_PACK(1);
					_WORD   bfReserved1 GCC_PACK(1); 
					_WORD   bfReserved2 GCC_PACK(1);
					DWORD   bfOffBits GCC_PACK(1);
				} FH; 
				struct BITMAPINFOHEADER
				{
					DWORD  biSize GCC_PACK(1); 
					INT    biWidth GCC_PACK(1);
					INT    biHeight GCC_PACK(1);
					_WORD  biPlanes GCC_PACK(1);
					_WORD  biBitCount GCC_PACK(1);
					DWORD  biCompression GCC_PACK(1);
					DWORD  biSizeImage GCC_PACK(1);
					INT    biXPelsPerMeter GCC_PACK(1); 
					INT    biYPelsPerMeter GCC_PACK(1);
					DWORD  biClrUsed GCC_PACK(1);
					DWORD  biClrImportant GCC_PACK(1); 
				} IH;
				#if _MSC_VER
					#pragma pack (pop)
				#endif

				// File header.
				FH.bfType		= 'B' + 256*'M';
				FH.bfSize		= sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + 3 * SizeX * SizeY;
				FH.bfReserved1	= 0;
				FH.bfReserved2	= 0;
				FH.bfOffBits	= sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
				Ar->Serialize( &FH, sizeof(FH) );

				// Info header.
				IH.biSize			= sizeof(BITMAPINFOHEADER);
				IH.biWidth			= SizeX;
				IH.biHeight			= SizeY;
				IH.biPlanes			= 1;
				IH.biBitCount		= 24;
				IH.biCompression	= 0; //BI_RGB
				IH.biSizeImage		= SizeX * SizeY * 3;
				IH.biXPelsPerMeter	= 0;
				IH.biYPelsPerMeter	= 0;
				IH.biClrUsed		= 0;
				IH.biClrImportant	= 0;
				Ar->Serialize( &IH, sizeof(IH) );

				// Colors.
				#if _MSC_VER
				for( INT i=SizeY-1; i>=0; i-- )
					for( INT j=0; j<SizeX; j++ )
						Ar->Serialize( &Buf[i*SizeX+j], 3 );
				#else
				for( INT i=SizeY; i>0; i-- )
					for( INT j=0; j<SizeX; j++ )
						Ar->Serialize( &Buf[i*SizeX+j], 3 );
				#endif

				// Success.
				delete Ar;
			}
			Mark.Pop();
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("QUICKSHOT")) )
	{
		static int LastShot=0;
		
		double StartTime=appSeconds();
		// Screenshot.
		TCHAR File[32];
		appSprintf( File, TEXT("Shot%04i.bmp"), LastShot++ );

	
		if( GFileManager->FileSize(File)<0 )
		{
			FMemMark Mark(GMem);
			FColor* Buf = new(GMem,SizeX*SizeY)FColor;
			RenDev->ReadPixels( Buf );
			
			FArchive* Ar = GFileManager->CreateFileWriter( File );
			if( Ar )
			{
				// Types. 
				#if _MSC_VER
					#pragma pack (push,1)
				#endif
				struct BITMAPFILEHEADER
				{
					_WORD   bfType GCC_PACK(1);
					DWORD   bfSize GCC_PACK(1);
					_WORD   bfReserved1 GCC_PACK(1); 
					_WORD   bfReserved2 GCC_PACK(1);
					DWORD   bfOffBits GCC_PACK(1);
				} FH; 
				struct BITMAPINFOHEADER
				{
					DWORD  biSize GCC_PACK(1); 
					INT    biWidth GCC_PACK(1);
					INT    biHeight GCC_PACK(1);
					_WORD  biPlanes GCC_PACK(1);
					_WORD  biBitCount GCC_PACK(1);
					DWORD  biCompression GCC_PACK(1);
					DWORD  biSizeImage GCC_PACK(1);
					INT    biXPelsPerMeter GCC_PACK(1); 
					INT    biYPelsPerMeter GCC_PACK(1);
					DWORD  biClrUsed GCC_PACK(1);
					DWORD  biClrImportant GCC_PACK(1); 
				} IH;
				#if _MSC_VER
					#pragma pack (pop)
				#endif

				// File header.
				FH.bfType		= 'B' + 256*'M';
				FH.bfSize		= sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + 3 * SizeX * SizeY;
				FH.bfReserved1	= 0;
				FH.bfReserved2	= 0;
				FH.bfOffBits	= sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
				Ar->Serialize( &FH, sizeof(FH) );

				// Info header.
				IH.biSize			= sizeof(BITMAPINFOHEADER);
				IH.biWidth			= SizeX;
				IH.biHeight			= SizeY;
				IH.biPlanes			= 1;
				IH.biBitCount		= 24;
				IH.biCompression	= 0; //BI_RGB
				IH.biSizeImage		= SizeX * SizeY * 3;
				IH.biXPelsPerMeter	= 0;
				IH.biYPelsPerMeter	= 0;
				IH.biClrUsed		= 0;
				IH.biClrImportant	= 0;
				Ar->Serialize( &IH, sizeof(IH) );

				// Colors.
				#if _MSC_VER
				for( INT i=SizeY-1; i>=0; i-- )
					for( INT j=0; j<SizeX; j++ )
						Ar->Serialize( &Buf[i*SizeX+j], 3 );
				#else
				for( INT i=SizeY; i>0; i-- )
					for( INT j=0; j<SizeX; j++ )
						Ar->Serialize( &Buf[i*SizeX+j], 3 );
				#endif

				// Success.
				delete Ar;
			}
			
			Mark.Pop();

			Actor->Level->TimeDilation=1.0f/(30*(appSeconds()-StartTime));

		}
		return 1;
	}

	else if( ParseCommand(&Cmd,TEXT("SHOWACTORS")) )
	{
		Actor->ShowFlags |= SHOW_Actors;
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("HIDEACTORS")) )
	{
		Actor->ShowFlags &= ~SHOW_Actors;
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("RMODE")) )
	{
		INT Mode = appAtoi(Cmd);
		if( Mode>REN_None && Mode<REN_MAX )
			Actor->RendMap = Mode;
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("EXEC")) )
	{
		TCHAR Filename[64];
		if( ParseToken( Cmd, Filename, ARRAY_COUNT(Filename), 0 ) )
			ExecMacro( Filename, Ar );
		return 1;
	}
	else if( Console && Console->ScriptConsoleExec(Cmd,Ar,Actor) )
	{
		return 1;
	}
	else if( UPlayer::Exec(Cmd,Ar) )
	{
		return 1;
	}
	else return 0;
}

//
// Execute a macro on this viewport.
//
void UViewport::ExecMacro( const TCHAR* Filename, FOutputDevice& Ar )
{
	// Create text buffer and prevent garbage collection.
	UTextBuffer* Text = ImportObject<UTextBuffer>( GetTransientPackage(), NAME_None, 0, Filename );
	if( Text )
	{
		Text->AddToRoot();
		debugf( TEXT("Execing %s"), Filename );
		TCHAR Temp[256];
		const TCHAR* Data = *Text->Text;
		while( ParseLine( &Data, Temp, ARRAY_COUNT(Temp) ) )
			Exec( Temp, Ar );
		Text->RemoveFromRoot();
		delete Text;
	}
	else Ar.Logf( NAME_ExecWarning, LocalizeError("FileNotFound",TEXT("Core")), Filename );
}

/*-----------------------------------------------------------------------------
	UViewport FArchive interface.
-----------------------------------------------------------------------------*/

//
// Output a message on the viewport's console.
//
void UViewport::Serialize( const TCHAR* Data, EName MsgType )
{
	// Pass to console.
	if( Console )
		Console->Serialize( Data, MsgType );
}

/*-----------------------------------------------------------------------------
	Input.
-----------------------------------------------------------------------------*/

//
// Read input from the viewport.
//
void UViewport::ReadInput( FLOAT DeltaSeconds )
{
	check(Input);

	// Update input.
	if( DeltaSeconds!=-1.f )
		UpdateInput( 0 );

	// Get input from input system.
	Input->ReadInput( DeltaSeconds, *GLog );
}

/*-----------------------------------------------------------------------------
	Viewport hit testing.
-----------------------------------------------------------------------------*/

//
// Viewport hit-test pushing.
//
void UViewport::PushHit( const HHitProxy& Hit, INT Size )
{
	Hit.Size = Size;
	HitSizes.AddItem(Size);
	RenDev->PushHit( (BYTE*)&Hit, Size );
}

//
// Pop the most recently pushed hit.
//
void UViewport::PopHit( UBOOL bForce )
{
	checkSlow(RenDev);
	checkSlow(HitTesting);
	check(HitSizes.Num());

	RenDev->PopHit( HitSizes.Pop(), bForce );
}

//
// Execute all hits in the hit buffer.
//
void UViewport::ExecuteHits( const FHitCause& Cause, BYTE* HitData, INT HitSize )
{
	// String together the hit stack.
	HHitProxy* TopHit=NULL;
	while( HitSize>0 )
	{
		HHitProxy* ThisHit = (HHitProxy*)HitData;
		HitData           += ThisHit->Size;
		HitSize           -= ThisHit->Size;
		ThisHit->Parent    = TopHit;
		TopHit             = ThisHit;
	}
	check(HitSize==0);

	// Call the innermost hit.
	if( TopHit )
		TopHit->Click( Cause );
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
