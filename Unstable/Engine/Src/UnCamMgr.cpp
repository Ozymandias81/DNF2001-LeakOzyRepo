/*=============================================================================
	UnCamMgr.cpp: Unreal viewport manager, generic implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	UClient implementation.
-----------------------------------------------------------------------------*/

//
// Constructor.
//
UClient::UClient()
{
	// Hook in.
	UBitmap::__Client = this;//!!why?
}
void UClient::PostEditChange()
{
	Super::PostEditChange();
	Brightness = Clamp(Brightness,0.f,1.f);
	MipFactor = Clamp(MipFactor,-3.f,3.f);
}
void UClient::StaticConstructor()
{

	UEnum* Details=new(GetClass(),TEXT("Details"))UEnum( NULL );
	new(Details->Names)FName( TEXT("High")     );
	new(Details->Names)FName( TEXT("Medium")   );
	new(Details->Names)FName( TEXT("Low")      );
	new(Details->Names)FName( TEXT("Ultra Low"));

	if(GIsEditor) UseWindowedGamma=TRUE;
	new(GetClass(),TEXT("WindowedViewportX"),	RF_Public)UIntProperty  (CPP_PROPERTY(WindowedViewportX     ), TEXT("Client"),  CPF_Config );
	new(GetClass(),TEXT("WindowedViewportY"),	RF_Public)UIntProperty  (CPP_PROPERTY(WindowedViewportY     ), TEXT("Client"),  CPF_Config );
	new(GetClass(),TEXT("WindowedColorBits"),	RF_Public)UIntProperty  (CPP_PROPERTY(WindowedColorBits     ), TEXT("Client"),  CPF_Config );
	new(GetClass(),TEXT("FullscreenViewportX"),	RF_Public)UIntProperty  (CPP_PROPERTY(FullscreenViewportX   ), TEXT("Client"),  CPF_Config );
	new(GetClass(),TEXT("FullscreenViewportY"),	RF_Public)UIntProperty  (CPP_PROPERTY(FullscreenViewportY	), TEXT("Client"),  CPF_Config );
	new(GetClass(),TEXT("FullscreenColorBits"),	RF_Public)UIntProperty  (CPP_PROPERTY(FullscreenColorBits	), TEXT("Client"),  CPF_Config );
	new(GetClass(),TEXT("MipFactor"),			RF_Public)UFloatProperty(CPP_PROPERTY(MipFactor				), TEXT("Client"),  CPF_Config );
	new(GetClass(),TEXT("Brightness"),			RF_Public)UFloatProperty(CPP_PROPERTY(Brightness			), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("Contrast"),			RF_Public)UFloatProperty(CPP_PROPERTY(Contrast				), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("Gamma"),				RF_Public)UFloatProperty(CPP_PROPERTY(Gamma					), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("UseWindowedGamma"),    RF_Public)UBoolProperty (CPP_PROPERTY(UseWindowedGamma      ), TEXT("Display"), CPF_Config ); 
	new(GetClass(),TEXT("CaptureMouse"),		RF_Public)UBoolProperty (CPP_PROPERTY(CaptureMouse			), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("CurvedSurfaces"),		RF_Public)UBoolProperty (CPP_PROPERTY(CurvedSurfaces		), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("TextureDetail"),		RF_Public)UByteProperty (CPP_PROPERTY(TextureLODSet[1]		), TEXT("Display"), CPF_Config, Details );
	new(GetClass(),TEXT("SkinDetail"),			RF_Public)UByteProperty (CPP_PROPERTY(TextureLODSet[2]		), TEXT("Display"), CPF_Config, Details );
	new(GetClass(),TEXT("ScreenFlashes"),		RF_Public)UBoolProperty (CPP_PROPERTY(ScreenFlashes			), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("NoLighting"),			RF_Public)UBoolProperty (CPP_PROPERTY(NoLighting			), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("MinDesiredFrameRate"),	RF_Public)UFloatProperty(CPP_PROPERTY(MinDesiredFrameRate	), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("Decals"),				RF_Public)UBoolProperty (CPP_PROPERTY(Decals				), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("NoDynamicLights"),		RF_Public)UBoolProperty (CPP_PROPERTY(NoDynamicLights		), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("NoFractalAnim"),		RF_Public)UBoolProperty (CPP_PROPERTY(NoFractalAnim 		), TEXT("Display"), CPF_Config );
	new(GetClass(),TEXT("ParticleDensity"),		RF_Public)UIntProperty  (CPP_PROPERTY(ParticleDensity		), TEXT("Display"), CPF_Config );

	new(GetClass(),TEXT("ShadowDetail"),		RF_Public)UIntProperty  (CPP_PROPERTY(ShadowDetail			), TEXT("Display"), CPF_Config );		// JEP
}
void UClient::Destroy()
{
	UBitmap::__Client = NULL;
	Super::Destroy();
}

//
// Command line.
//
UBOOL UClient::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	if( ParseCommand(&Cmd,TEXT("BRIGHTNESS")) )
	{
		if( *Cmd == '+' )
		{
			Brightness+=0.05;
			if(Brightness>=0.75) Brightness=0.25;
		} else
		if( *Cmd )
			Brightness = Clamp<FLOAT>( appAtof(Cmd), 0.f, 1.f );
		else
			Brightness = 0.5f;
		Engine->Flush(1);
		SaveConfig();
		if( Viewports.Num() && Viewports(0)->Actor )//!!ugly
			Viewports(0)->Actor->eventClientMessage( *FString::Printf(TEXT("Brightness %i"), (INT)(((Brightness-.25)*2)*10)), NAME_None, 0  );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("CONTRAST")) )
	{
		if( *Cmd == '+' )
			Contrast = Contrast >= 0.9f ? 0.f : Contrast + 0.1f;
		else
		if( *Cmd )
			Contrast = Clamp<FLOAT>( appAtof(Cmd), 0.f, 2.f );
		else
			Contrast = 0.5f;
		Engine->Flush(1);
		SaveConfig();
		if( Viewports.Num() && Viewports(0)->Actor )//!!ugly
			Viewports(0)->Actor->eventClientMessage( *FString::Printf(TEXT("Contrast %i"), (INT)(Contrast*10)), NAME_None, 0 );
		return 1;
	}
	else
	if( ParseCommand(&Cmd,TEXT("GAMMA")) )
	{
		if( *Cmd == '+' )
			Gamma = Gamma >= 2.4f ? 0.5f : Gamma + 0.1f;
		else
		if( *Cmd )
			Gamma = Clamp<FLOAT>( appAtof(Cmd), 0.5f, 2.5f );
		else
			Gamma = 1.7f;
		Engine->Flush(1);
		SaveConfig();
		if( Viewports.Num() && Viewports(0)->Actor )//!!ugly
			Viewports(0)->Actor->eventClientMessage( *FString::Printf(TEXT("Gamma %1.1f"), Gamma), NAME_None, 0 );
		return 1;
	}
	else return 0;
}

//
// Init.
//
void UClient::Init( UEngine* InEngine )
{
	Engine = InEngine;
}

//
// Flush.
//
void UClient::Flush( UBOOL AllowPrecache )
{
	for( INT i=0; i<Viewports.Num(); i++ )
		if( Viewports(i)->RenDev )
			Viewports(i)->RenDev->Flush(AllowPrecache);
}

//
// Serializer.
//
void UClient::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

	// Only serialize objects, since this can't be loaded or saved.
	Ar << Viewports;
}

IMPLEMENT_CLASS(UClient);

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
